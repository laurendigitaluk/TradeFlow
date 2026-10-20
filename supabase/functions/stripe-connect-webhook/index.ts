import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_CONNECT_WEBHOOK_SECRET = Deno.env.get("STRIPE_CONNECT_WEBHOOK_SECRET");
const EXPECTED_STRIPE_MODE = Deno.env.get("TRADEFLOW_STRIPE_MODE") || "live";
const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers });

function hex(buffer: ArrayBuffer) {
  return [...new Uint8Array(buffer)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
async function hmac(secret: string, message: string) {
  const key = await crypto.subtle.importKey(
    "raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"],
  );
  return hex(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(message)));
}
function safeEqual(a: string, b: string) {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return result === 0;
}
async function rest(path: string, init: RequestInit = {}) {
  return await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...init,
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
      ...(init.headers || {}),
    },
  });
}
async function rpc(name: string, body: unknown) {
  const response = await rest(`rpc/${name}`, { method: "POST", body: JSON.stringify(body) });
  const raw = await response.text();
  let data: any;
  try { data = raw ? JSON.parse(raw) : null; } catch { data = raw; }
  if (!response.ok) throw new Error(data?.message || data?.details || data?.hint || String(data));
  return data;
}

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);
  if (!STRIPE_CONNECT_WEBHOOK_SECRET) return json({ error: "Connected-account webhook secret is not configured." }, 503);

  const signature = request.headers.get("stripe-signature");
  if (!signature) return json({ error: "Missing Stripe signature" }, 400);
  const rawBody = await request.text();

  try {
    const parts = signature.split(",").reduce((acc: Record<string, string[]>, item) => {
      const splitAt = item.indexOf("=");
      if (splitAt > 0) (acc[item.slice(0, splitAt)] ||= []).push(item.slice(splitAt + 1));
      return acc;
    }, {});
    const timestamp = Number(parts.t?.[0]);
    if (!Number.isFinite(timestamp) || Math.abs(Date.now() / 1000 - timestamp) > 300) {
      return json({ error: "Expired Stripe signature" }, 400);
    }
    const expected = await hmac(STRIPE_CONNECT_WEBHOOK_SECRET, `${timestamp}.${rawBody}`);
    const valid = (parts.v1 || []).some((candidate) => safeEqual(expected, candidate));
    if (!valid) return json({ error: "Invalid Stripe signature" }, 400);

    const event = JSON.parse(rawBody);
    if ((EXPECTED_STRIPE_MODE !== "live" && EXPECTED_STRIPE_MODE !== "test") || event.livemode !== (EXPECTED_STRIPE_MODE === "live")) {
      return json({ error: "Stripe webhook mode does not match this TradeFlow environment." }, 400);
    }
    const object = event?.data?.object;
    if (!event?.id || !event?.type || !object) return json({ received: true });

    // Account capability changes update only the matching subscriber connection.
    if (event.type === "account.updated") {
      const accountId = String(object.id || event.account || "");
      if (!accountId.startsWith("acct_")) return json({ received: true, ignored: "missing_connected_account_id" });
      const enabled = object.charges_enabled === true &&
        object.payouts_enabled === true &&
        object.details_submitted === true &&
        object.capabilities?.card_payments === "active";
      const existingResponse = await rest(
        `payment_provider_connections?select=id,metadata&provider=eq.stripe&connection_type=eq.customer_payments&provider_account_id=eq.${encodeURIComponent(accountId)}&limit=1`,
      );
      if (!existingResponse.ok) return json({ error: "Unable to load the saved Stripe connection metadata." }, 500);
      const existingRows = await existingResponse.json();
      const priorMetadata = existingRows?.[0]?.metadata || {};
      const patch = {
        // The database status constraint uses "active", not "connected".
        status: enabled ? "active" : "onboarding",
        charges_enabled: object.charges_enabled === true,
        payouts_enabled: object.payouts_enabled === true,
        details_submitted: object.details_submitted === true,
        // livemode is an event-level property; do not downgrade a live connection
        // because the Account object omitted its own livemode field.
        livemode: event.livemode === true,
        default_currency: object.default_currency ? String(object.default_currency).toUpperCase() : null,
        country_code: object.country ? String(object.country).toUpperCase() : null,
        metadata: {
          ...priorMetadata,
          stripe_account_id: accountId,
          card_payments_capability: object.capabilities?.card_payments || null,
          requirements_due: object.requirements?.currently_due || [],
          requirements_past_due: object.requirements?.past_due || [],
          stripe_event_id: event.id,
          last_webhook_update_at: new Date().toISOString(),
        },
        updated_at: new Date().toISOString(),
      };
      const updated = await rest(
        `payment_provider_connections?provider=eq.stripe&connection_type=eq.customer_payments&provider_account_id=eq.${encodeURIComponent(accountId)}`,
        { method: "PATCH", headers: { Prefer: "return=representation" }, body: JSON.stringify(patch) },
      );
      if (!updated.ok) return json({ error: await updated.text() }, 500);
      const rows = await updated.json();
      return json({ received: true, connected_account_updated: true, matched_connections: Array.isArray(rows) ? rows.length : 0, status: enabled ? "connected" : "onboarding" });
    }

    const supported = new Set([
      "checkout.session.completed",
      "checkout.session.async_payment_succeeded",
      "checkout.session.expired",
      "payment_intent.succeeded",
      "payment_intent.payment_failed",
    ]);
    if (!supported.has(event.type)) return json({ received: true, ignored: "unsupported_event" });

    // Retail customer payments must be created on the connected account, never the platform account.
    const accountId = String(event.account || "");
    if (!accountId.startsWith("acct_")) return json({ error: "Retail payment event did not identify a connected account." }, 400);

    const metadata = object.metadata || {};
    const tenantId = String(metadata.tenant_id || "");
    const paymentId = String(metadata.payment_id || "");
    if (!tenantId || !paymentId) return json({ received: true, ignored: "not_a_tradeflow_order_payment" });

    const connectionResponse = await rest(
      `payment_provider_connections?tenant_id=eq.${encodeURIComponent(tenantId)}&provider=eq.stripe&connection_type=eq.customer_payments&provider_account_id=eq.${encodeURIComponent(accountId)}&select=id,livemode&limit=1`,
    );
    if (!connectionResponse.ok) return json({ error: "Unable to validate connected Stripe account." }, 500);
    const connections = await connectionResponse.json();
    if (!Array.isArray(connections) || connections.length !== 1 || connections[0].livemode !== (EXPECTED_STRIPE_MODE === "live")) {
      return json({ error: "Connected Stripe account does not match this TradeFlow tenant." }, 403);
    }

    let newStatus: "paid" | "failed" | "cancelled";
    let amountMinor: number;
    let currency = String(object.currency || "gbp").toUpperCase();
    let providerPaymentId: string;
    let paymentIntentId: string | null = null;

    if (event.type.startsWith("checkout.session.")) {
      if (event.type === "checkout.session.completed" || event.type === "checkout.session.async_payment_succeeded") {
        if (object.payment_status !== "paid") return json({ received: true, ignored: "payment_not_paid" });
        newStatus = "paid";
      } else {
        newStatus = "cancelled";
      }
      amountMinor = Number(object.amount_total ?? 0);
      providerPaymentId = String(object.id || "");
      paymentIntentId = object.payment_intent ? String(object.payment_intent) : null;
    } else {
      newStatus = event.type === "payment_intent.succeeded" ? "paid" : "failed";
      amountMinor = Number(event.type === "payment_intent.succeeded" ? (object.amount_received ?? object.amount) : object.amount);
      paymentIntentId = String(object.id || "");
      // TradeFlow records the Checkout Session as provider_payment_id. Keep that stable
      // when processing the separate PaymentIntent event to satisfy the database guard.
      const paymentLookup = await rest(
        `payment_records?id=eq.${encodeURIComponent(paymentId)}&tenant_id=eq.${encodeURIComponent(tenantId)}&select=provider_payment_id,amount,currency,status,metadata&limit=1`,
      );
      if (!paymentLookup.ok) return json({ error: "Unable to locate the payment record for this Stripe event." }, 500);
      const rows = await paymentLookup.json();
      const payment = rows?.[0];
      if (!payment) return json({ error: "Payment record not found." }, 404);
      providerPaymentId = String(payment.provider_payment_id || "");
      if (!providerPaymentId) return json({ error: "Payment record has no Checkout Session reference." }, 409);
      if (Number(payment.amount) !== amountMinor / 100 || String(payment.currency).toUpperCase() !== currency) {
        return json({ error: "Stripe PaymentIntent amount/currency does not match the TradeFlow payment record." }, 409);
      }
    }

    if (!providerPaymentId || !Number.isFinite(amountMinor) || amountMinor < 0) {
      return json({ error: "Stripe payment details are incomplete." }, 400);
    }

    const result = await rpc("process_external_payment_event", {
      p_provider: "stripe",
      p_event_id: String(event.id),
      p_event_type: String(event.type),
      p_tenant_id: tenantId,
      p_payment_id: paymentId,
      p_provider_payment_id: providerPaymentId,
      p_new_status: newStatus,
      p_amount: amountMinor / 100,
      p_currency: currency,
      p_metadata: {
        stripe_event_id: event.id,
        stripe_event_type: event.type,
        stripe_connected_account_id: accountId,
        stripe_checkout_session_id: event.type.startsWith("checkout.session.") ? object.id : providerPaymentId,
        stripe_payment_intent_id: paymentIntentId,
        stripe_order_id: metadata.order_id || null,
      },
    });

    const conflict = result === false || (Array.isArray(result) && result[0] === false);
    if (conflict && newStatus === "paid") {
      // Do not issue refunds from TradeFlow. Flag for the subscriber to review in their own Stripe account.
      const current = await rest(
        `payment_records?id=eq.${encodeURIComponent(paymentId)}&tenant_id=eq.${encodeURIComponent(tenantId)}&select=metadata&limit=1`,
      );
      if (current.ok) {
        const rows = await current.json();
        const prior = rows?.[0]?.metadata || {};
        await rest(
          `payment_records?id=eq.${encodeURIComponent(paymentId)}&tenant_id=eq.${encodeURIComponent(tenantId)}`,
          {
            method: "PATCH",
            body: JSON.stringify({
              metadata: {
                ...prior,
                stripe_conflict_event_id: event.id,
                stripe_conflict_payment_intent_id: paymentIntentId,
                subscriber_review_required: true,
                subscriber_review_reason: "Payment succeeded but the order or listing was no longer available. Review/refund in the subscriber's own Stripe account.",
              },
              updated_at: new Date().toISOString(),
            }),
          },
        );
      }
      return json({ received: true, subscriber_review_required: true, reason: "paid_payment_order_unavailable" });
    }
    return json({ received: true, payment_processed: true });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});