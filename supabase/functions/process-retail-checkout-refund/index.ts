import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers });

async function rpc(name: string, body: unknown) {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  const raw = await response.text();
  let data: any;
  try { data = raw ? JSON.parse(raw) : null; } catch { data = raw; }
  if (!response.ok) throw new Error(`RPC ${name} failed (${response.status}): ${String(data?.message || data?.details || data).slice(0, 400)}`);
  return data;
}

async function stripeGetSession(sessionId: string, accountId: string) {
  return await fetch(`https://api.stripe.com/v1/checkout/sessions/${encodeURIComponent(sessionId)}`, {
    headers: {
      Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
      "Stripe-Account": accountId,
    },
  });
}

async function finish(input: {
  attemptId: string;
  idempotencyKey: string;
  status: "requested" | "succeeded" | "failed" | "reconciliation_required";
  refundId?: string | null;
  paymentIntentId?: string | null;
  error?: string | null;
}) {
  return await rpc("finish_retail_checkout_refund", {
    p_attempt_id: input.attemptId,
    p_refund_idempotency_key: input.idempotencyKey,
    p_refund_status: input.status,
    p_stripe_refund_id: input.refundId ?? null,
    p_payment_intent_id: input.paymentIntentId ?? null,
    p_error: input.error ?? null,
  });
}

async function processAttempt(attemptId: string) {
  const rawClaim = await rpc("claim_retail_checkout_refund", { p_attempt_id: attemptId });
  const claim = Array.isArray(rawClaim) ? rawClaim[0] : rawClaim;
  if (!claim || claim.claim_status === "not_found") {
    return { attempt_id: attemptId, outcome: "not_found" };
  }
  if (claim.claim_status !== "claimed") {
    return { attempt_id: attemptId, outcome: claim.claim_status, refund_status: claim.claim_status };
  }

  const accountId = String(claim.stripe_account_id || "");
  const sessionId = String(claim.stripe_session_id || "");
  const idempotencyKey = String(claim.refund_idempotency_key || "");
  const expectedAmount = Math.round(Number(claim.payment_amount) * 100);
  const expectedCurrency = String(claim.payment_currency || "").toUpperCase();

  if (!STRIPE_SECRET_KEY || !/^acct_[A-Za-z0-9]+$/.test(accountId) ||
      !sessionId.startsWith("cs_") || !idempotencyKey ||
      !Number.isSafeInteger(expectedAmount) || expectedAmount <= 0 ||
      !/^[A-Z]{3}$/.test(expectedCurrency)) {
    await finish({
      attemptId, idempotencyKey, status: "reconciliation_required",
      error: "Refund prerequisites are missing or invalid.",
    });
    return { attempt_id: attemptId, outcome: "reconciliation_required", reason: "invalid_refund_prerequisites" };
  }

  // Retrieve the exact Checkout Session in the connected-account context.
  // Never use a PaymentIntent ID as a substitute for the canonical Session ID.
  const sessionResponse = await stripeGetSession(sessionId, accountId);
  const sessionRaw = await sessionResponse.text();
  let session: any;
  try { session = sessionRaw ? JSON.parse(sessionRaw) : null; } catch { session = null; }

  if (!sessionResponse.ok) {
    if (sessionResponse.status === 429 || sessionResponse.status >= 500) {
      await finish({
        attemptId, idempotencyKey, status: "requested",
        error: `Temporary Stripe Session retrieval failure (${sessionResponse.status}).`,
      });
      throw new Error("Temporary Stripe Session retrieval failure; retry required.");
    }
    await finish({
      attemptId, idempotencyKey, status: "reconciliation_required",
      error: `Stripe could not retrieve the exact Checkout Session (${sessionResponse.status}).`,
    });
    return { attempt_id: attemptId, outcome: "reconciliation_required", reason: "session_retrieval_rejected" };
  }

  const paymentIntentId = typeof session?.payment_intent === "string"
    ? session.payment_intent
    : String(session?.payment_intent?.id || "");
  const sessionAmount = Number(session?.amount_total);
  const sessionCurrency = String(session?.currency || "").toUpperCase();

  if (session?.id !== sessionId || session?.mode !== "payment" ||
      session?.payment_status !== "paid" || !paymentIntentId ||
      !Number.isSafeInteger(sessionAmount) || sessionAmount !== expectedAmount ||
      sessionCurrency !== expectedCurrency ||
      (claim.stripe_payment_intent_id && claim.stripe_payment_intent_id !== paymentIntentId)) {
    await finish({
      attemptId, idempotencyKey, status: "reconciliation_required",
      paymentIntentId: paymentIntentId || null,
      error: "Retrieved Session identity, paid status, PaymentIntent, amount or currency did not match the stored attempt.",
    });
    return { attempt_id: attemptId, outcome: "reconciliation_required", reason: "session_validation_mismatch" };
  }

  // No amount is supplied: this is a full refund. Reusing the same stable key
  // recovers safely if Stripe accepted the request but the database write failed.
  const params = new URLSearchParams({
    payment_intent: paymentIntentId,
    reason: "duplicate",
    "metadata[tradeflow_checkout_attempt_id]": attemptId,
    "metadata[tradeflow_payment_id]": String(claim.payment_id),
  });
  const refundResponse = await fetch("https://api.stripe.com/v1/refunds", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
      "Stripe-Account": accountId,
      "Content-Type": "application/x-www-form-urlencoded",
      "Idempotency-Key": idempotencyKey,
    },
    body: params,
  });
  const refundRaw = await refundResponse.text();
  let refund: any;
  try { refund = refundRaw ? JSON.parse(refundRaw) : null; } catch { refund = null; }

  if (!refundResponse.ok) {
    if (refundResponse.status === 429 || refundResponse.status >= 500) {
      await finish({
        attemptId, idempotencyKey, status: "requested", paymentIntentId,
        error: `Temporary Stripe refund API failure (${refundResponse.status}); retry with the same idempotency key.`,
      });
      throw new Error("Temporary Stripe refund API failure; retry required.");
    }
    await finish({
      attemptId, idempotencyKey, status: "reconciliation_required", paymentIntentId,
      error: `Stripe rejected the refund request (${refundResponse.status}): ${String(refund?.error?.code || "unknown_error")}.`,
    });
    return { attempt_id: attemptId, outcome: "reconciliation_required", reason: "stripe_refund_rejected" };
  }

  const refundId = String(refund?.id || "");
  if (!refundId) {
    await finish({
      attemptId, idempotencyKey, status: "requested", paymentIntentId,
      error: "Stripe response did not include a refund ID; retry/reconcile using the same idempotency key.",
    });
    throw new Error("Stripe refund response was incomplete; retry required.");
  }

  if (refund.status === "succeeded") {
    const result = await finish({
      attemptId, idempotencyKey, status: "succeeded", refundId, paymentIntentId,
    });
    return { attempt_id: attemptId, outcome: "succeeded", refund_id: refundId, database_result: result };
  }
  if (refund.status === "failed" || refund.status === "canceled") {
    await finish({
      attemptId, idempotencyKey, status: "failed", refundId, paymentIntentId,
      error: `Stripe refund status is ${String(refund.status)}.`,
    });
    return { attempt_id: attemptId, outcome: "failed", refund_id: refundId, stripe_status: refund.status };
  }

  await finish({
    attemptId, idempotencyKey, status: "requested", refundId, paymentIntentId,
    error: `Stripe refund is not final; current status is ${String(refund.status || "unknown")}.`,
  });
  return { attempt_id: attemptId, outcome: "requested", refund_id: refundId, stripe_status: refund.status };
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);

  // This is an internal worker, not a customer-facing endpoint. Only the exact
  // Supabase service-role credential may invoke it.
  if (!SERVICE_ROLE_KEY || request.headers.get("Authorization") !== `Bearer ${SERVICE_ROLE_KEY}`) {
    return json({ error: "Service role required" }, 401);
  }
  if (!STRIPE_SECRET_KEY) return json({ error: "Stripe secret is not configured" }, 503);

  try {
    const body = await request.json().catch(() => ({}));
    const attemptId = body?.attempt_id;
    if (typeof attemptId !== "string" || !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(attemptId)) {
      return json({ error: "A valid attempt_id is required" }, 400);
    }
    const result = await processAttempt(attemptId);
    if (result.outcome === "requested") return json({ ...result, retryable: true }, 503);
    return json(result);
  } catch (error) {
    return json({
      error: error instanceof Error ? error.message : String(error),
      retryable: true,
    }, 503);
  }
});
