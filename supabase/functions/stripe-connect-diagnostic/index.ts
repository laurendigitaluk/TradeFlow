import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") || "";

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Authentication required" }, 401);

  // Read-only diagnostic. It refuses live Stripe keys before making any Stripe request.
  if (!/^(sk|rk)_test_/.test(STRIPE_SECRET_KEY)) {
    return json({
      error: "The TEST environment does not have a recognised Stripe test secret configured. No Stripe request was made.",
      code: "TEST_STRIPE_KEY_REQUIRED",
    }, 503);
  }

  try {
    const userResponse = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: authorization },
    });
    if (!userResponse.ok) return json({ error: "Your subscriber session could not be verified." }, 401);
    const user = await userResponse.json();
    if (!user?.id) return json({ error: "Your subscriber session could not be verified." }, 401);

    const body = await req.json();
    const tenantId = String(body?.tenant_id || "");
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(tenantId)) {
      return json({ error: "A valid subscriber tenant is required." }, 400);
    }

    const membershipResponse = await fetch(
      `${SUPABASE_URL}/rest/v1/tenant_memberships?tenant_id=eq.${encodeURIComponent(tenantId)}&user_id=eq.${encodeURIComponent(user.id)}&status=eq.active&role_code=in.(owner,admin)&select=id&limit=1`,
      { headers: { apikey: SERVICE_ROLE_KEY, Authorization: `Bearer ${SERVICE_ROLE_KEY}` } },
    );
    if (!membershipResponse.ok) return json({ error: "Unable to verify subscriber permissions." }, 500);
    const memberships = await membershipResponse.json();
    if (!Array.isArray(memberships) || memberships.length === 0) {
      return json({ error: "Only an active subscriber owner or admin can verify the payment connection." }, 403);
    }

    const stripeResponse = await fetch("https://api.stripe.com/v1/account", {
      headers: { Authorization: `Bearer ${STRIPE_SECRET_KEY}` },
    });
    const account = await stripeResponse.json();
    if (!stripeResponse.ok || !account?.id) {
      return json({
        error: "TradeFlow TEST could not verify the configured Stripe test account. Check that its sandbox secret key is configured in the TEST Supabase project.",
        code: "STRIPE_TEST_ACCOUNT_CHECK_FAILED",
      }, 502);
    }

    return json({
      ok: true,
      mode: "test",
      livemode: false,
      account_id: account.id,
      account_name: account.business_profile?.name || account.company?.name || account.email || "Stripe test platform",
      country: account.country || null,
      charges_enabled: account.charges_enabled === true,
      payouts_enabled: account.payouts_enabled === true,
      details_submitted: account.details_submitted === true,
      read_only: true,
    });
  } catch (_error) {
    return json({ error: "The Stripe test-account check failed unexpectedly. No payment or account was created." }, 500);
  }
});
