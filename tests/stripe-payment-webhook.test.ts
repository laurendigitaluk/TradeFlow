// Behaviour tests execute the actual Edge Function entrypoint with mocked external services.
const webhookSecret = "whsec_tradeflow_unit_test";
let capturedHandler: ((request: Request) => Promise<Response>) | undefined;

Deno.env.set("SUPABASE_URL", "https://tradeflow-unit-test.supabase.co");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "service-role-unit-test");
Deno.env.set("STRIPE_WEBHOOK_SECRET", webhookSecret);
Deno.env.set("STRIPE_SECRET_KEY", "sk_test_unit_test");

const denoRuntime = Deno as unknown as { serve: (handler: (request: Request) => Promise<Response>) => unknown };
const originalServe = denoRuntime.serve;
denoRuntime.serve = (handler) => {
  capturedHandler = handler;
  return undefined;
};
await import("../supabase/functions/stripe-payment-webhook/index.ts");
denoRuntime.serve = originalServe;

if (!capturedHandler) throw new Error("Webhook handler was not registered by the actual Edge Function entrypoint.");
const handler = capturedHandler;

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}
function responseJson(value: unknown, status = 200): Response {
  return new Response(JSON.stringify(value), { status, headers: { "Content-Type": "application/json" } });
}
function hex(bytes: ArrayBuffer): string {
  return [...new Uint8Array(bytes)].map((value) => value.toString(16).padStart(2, "0")).join("");
}
async function signature(raw: string, timestamp = Math.floor(Date.now() / 1000)): Promise<string> {
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(webhookSecret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const digest = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(`${timestamp}.${raw}`));
  return `t=${timestamp},v1=${hex(digest)}`;
}
async function requestFor(event: unknown, signatureOverride?: string, timestamp?: number): Promise<Request> {
  const raw = JSON.stringify(event);
  const sig = signatureOverride ?? await signature(raw, timestamp);
  return new Request("https://tradeflow-unit-test.invalid/stripe-webhook", {
    method: "POST",
    headers: { "stripe-signature": sig },
    body: raw,
  });
}
async function bodyOf(response: Response): Promise<Record<string, unknown>> {
  return await response.json() as Record<string, unknown>;
}
function event(type: string, object: Record<string, unknown>, account?: string) {
  return { id: `evt_test_${type.replaceAll(".", "_")}`, type, ...(account ? { account } : {}), data: { object } };
}

Deno.test("Stripe webhook entrypoint: signature, domain orders, connected accounts and subscription paths", async () => {
  const originalFetch = globalThis.fetch;
  try {
    // Signature validation: missing, invalid and expired signatures must be rejected before dispatch.
    const unsigned = new Request("https://tradeflow-unit-test.invalid/stripe-webhook", {
      method: "POST",
      body: JSON.stringify(event("test.ignored", { id: "obj_1" })),
    });
    const missing = await handler(unsigned);
    assert(missing.status === 400, "Missing Stripe signature should return 400.");

    const invalid = await handler(await requestFor(event("test.ignored", { id: "obj_2" }), "t=1,v1=invalid"));
    assert(invalid.status === 400, "Invalid Stripe signature should return 400.");

    const expiredTimestamp = Math.floor(Date.now() / 1000) - 600;
    const expired = await handler(await requestFor(event("test.ignored", { id: "obj_3" }), undefined, expiredTimestamp));
    assert(expired.status === 400, "Expired Stripe signature should return 400.");

    // A correctly signed event with an unsupported type is acknowledged without external calls.
    globalThis.fetch = (async () => { throw new Error("Unexpected fetch for ignored event."); }) as typeof fetch;
    const ignored = await handler(await requestFor(event("test.ignored", { id: "obj_4" })));
    assert(ignored.status === 200 && (await bodyOf(ignored)).received === true, "Unknown signed event should be acknowledged.");

    // Paid domain order: service-role GET followed by status/metadata PATCH.
    const paidCalls: Array<{ url: string; method: string; body?: string }> = [];
    globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = String(input);
      const method = String(init?.method || "GET").toUpperCase();
      paidCalls.push({ url, method, body: typeof init?.body === "string" ? init.body : undefined });
      if (method === "GET") return responseJson([{ id: "domain-order-1", tenant_id: "tenant-1", status: "pending_payment", payment_reference: null, metadata: {} }]);
      if (method === "PATCH") return new Response(null, { status: 204 });
      throw new Error(`Unexpected paid-domain-order request: ${method} ${url}`);
    }) as typeof fetch;
    const paid = await handler(await requestFor(event("checkout.session.completed", {
      id: "cs_test_domain",
      payment_status: "paid",
      metadata: { domain_order_id: "domain-order-1" },
    })));
    const paidBody = await bodyOf(paid);
    assert(paid.status === 200 && paidBody.domain_payment_confirmed === true, "Paid domain order should be confirmed.");
    const paidPatch = paidCalls.find((call) => call.method === "PATCH");
    assert(!!paidPatch && JSON.parse(paidPatch.body || "{}").status === "payment_confirmed", "Paid domain order should be patched to payment_confirmed.");
    assert(paidCalls.every((call) => call.url.includes("/rest/v1/tenant_domain_orders")), "Domain-order path must use Supabase REST.");

    // Expired domain order: cancellation PATCH must be conditional on pending_payment.
    let expiryUrl = "";
    globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
      expiryUrl = String(input);
      assert(String(init?.method).toUpperCase() === "PATCH", "Expired order should issue only a PATCH.");
      return new Response(null, { status: 204 });
    }) as typeof fetch;
    const expiredOrder = await handler(await requestFor(event("checkout.session.expired", {
      id: "cs_test_expired",
      metadata: { domain_order_id: "domain-order-2" },
    })));
    assert(expiredOrder.status === 200, "Expired domain order should be acknowledged.");
    assert(expiryUrl.includes("status=eq.pending_payment"), "Expiry PATCH must be guarded by pending_payment.");

    // Connected account lifecycle event updates only the matching Stripe customer-payments connection.
    let accountPatchUrl = "";
    globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
      accountPatchUrl = String(input);
      assert(String(init?.method).toUpperCase() === "PATCH", "account.updated should PATCH the connection.");
      return responseJson([{ id: "connection-1" }]);
    }) as typeof fetch;
    const accountUpdated = await handler(await requestFor(event("account.updated", {
      id: "acct_test_123",
      charges_enabled: true,
      payouts_enabled: true,
      details_submitted: true,
      capabilities: { card_payments: "active" },
      livemode: false,
      default_currency: "gbp",
      country: "GB",
      requirements: { currently_due: [], past_due: [] },
    })));
    const accountBody = await bodyOf(accountUpdated);
    assert(accountUpdated.status === 200 && accountBody.connected_account_updated === true, "account.updated should be processed.");
    assert(accountPatchUrl.includes("provider_account_id=eq.acct_test_123"), "account.updated must be scoped to the Stripe account ID.");

    // A retail payment from an unrecognised connected account must be rejected.
    globalThis.fetch = (async () => responseJson([])) as typeof fetch;
    const mismatch = await handler(await requestFor(event("payment_intent.succeeded", {
      id: "pi_test_mismatch",
      amount_received: 1000,
      currency: "gbp",
      metadata: { tenant_id: "tenant-1", payment_id: "payment-1" },
    }, "acct_wrong")));
    assert(mismatch.status === 403, "Connected account mismatch must return 403.");

    // A matching connected account is allowed to reach the idempotent payment RPC.
    const matchedCalls: string[] = [];
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      const url = String(input);
      matchedCalls.push(url);
      if (url.includes("/payment_provider_connections?")) return responseJson([{ id: "connection-1" }]);
      if (url.includes("/rpc/process_external_payment_event")) return responseJson(true);
      throw new Error(`Unexpected connected-payment request: ${url}`);
    }) as typeof fetch;
    const matched = await handler(await requestFor(event("payment_intent.succeeded", {
      id: "pi_test_match",
      amount_received: 1000,
      currency: "gbp",
      metadata: { tenant_id: "tenant-1", payment_id: "payment-1" },
    }, "acct_right")));
    assert(matched.status === 200 && matchedCalls.some((url) => url.includes("/rpc/process_external_payment_event")), "Matching connected account should reach payment RPC.");

    // Subscription updates must call the subscriber sync RPC.
    let subscriptionRpc = "";
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      subscriptionRpc = String(input);
      return responseJson(true);
    }) as typeof fetch;
    const subscriptionUpdated = await handler(await requestFor(event("customer.subscription.updated", {
      id: "sub_test_1",
      status: "active",
      customer: "cus_test_1",
      items: { data: [{ price: { id: "price_test_monthly" } }] },
      cancel_at_period_end: false,
      metadata: {},
    })));
    assert(subscriptionUpdated.status === 200 && subscriptionRpc.includes("/rpc/subscriber_sync_subscription"), "Subscription update should call subscriber_sync_subscription.");

    // Subscriber Checkout completion must retrieve the Stripe subscription and finalise via RPC.
    const signupCalls: string[] = [];
    globalThis.fetch = (async (input: RequestInfo | URL) => {
      const url = String(input);
      signupCalls.push(url);
      if (url.includes("/v1/subscriptions/sub_test_signup")) {
        return responseJson({
          id: "sub_test_signup",
          status: "trialing",
          customer: "cus_test_signup",
          items: { data: [{ price: { id: "price_test_monthly" } }] },
          trial_end: null,
          current_period_start: 1790000000,
          current_period_end: 1792592000,
          cancel_at_period_end: false,
          metadata: {},
        });
      }
      if (url.includes("/rpc/subscriber_finalize_signup")) return responseJson("tenant-test-1");
      throw new Error(`Unexpected subscriber-signup request: ${url}`);
    }) as typeof fetch;
    const signup = await handler(await requestFor(event("checkout.session.completed", {
      id: "cs_test_signup",
      mode: "subscription",
      subscription: "sub_test_signup",
      metadata: { user_id: "00000000-0000-0000-0000-000000000001", business_name: "Unit Test Business", plan_code: "enhanced" },
    })));
    const signupBody = await bodyOf(signup);
    assert(signup.status === 200 && signupBody.subscriber_signup === true, "Subscriber Checkout should finalise.");
    assert(signupCalls.some((url) => url.includes("/rpc/subscriber_finalize_signup")), "Subscriber Checkout must call subscriber_finalize_signup.");

    // A sold-item conflict must refund through the connected account with a stable idempotency key.
    let paymentRpcCount = 0;
    let refundIdempotencyKey = "";
    let refundAccount = "";
    globalThis.fetch = (async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = String(input);
      if (url.includes("/payment_provider_connections?")) return responseJson([{ id: "connection-refund" }]);
      if (url.includes("/rpc/process_external_payment_event")) {
        paymentRpcCount++;
        return responseJson(paymentRpcCount === 1 ? false : true);
      }
      if (url === "https://api.stripe.com/v1/refunds") {
        const headers = new Headers(init?.headers);
        refundIdempotencyKey = headers.get("Idempotency-Key") || "";
        refundAccount = headers.get("Stripe-Account") || "";
        return responseJson({ id: "re_test_conflict", status: "succeeded" });
      }
      throw new Error(`Unexpected conflict-refund request: ${url}`);
    }) as typeof fetch;
    const conflictRefund = await handler(await requestFor(event("checkout.session.completed", {
      id: "cs_test_conflict",
      payment_status: "paid",
      amount_total: 1000,
      currency: "gbp",
      payment_intent: "pi_test_conflict",
      metadata: { tenant_id: "tenant-1", payment_id: "payment-conflict", order_id: "order-conflict" },
    }, "acct_refund")));
    const conflictBody = await bodyOf(conflictRefund);
    assert(conflictRefund.status === 200 && conflictBody.refunded === true, "Sold-item conflict should complete the refund path.");
    assert(refundIdempotencyKey === "tradeflow-conflict-refund-pi_test_conflict", "Conflict refund must use the stable PaymentIntent idempotency key.");
    assert(refundAccount === "acct_refund", "Conflict refund must be scoped to the connected Stripe account.");
    assert(paymentRpcCount === 2, "Conflict refund must record the cancellation after the refund.");
  } finally {
    globalThis.fetch = originalFetch;
  }
});
