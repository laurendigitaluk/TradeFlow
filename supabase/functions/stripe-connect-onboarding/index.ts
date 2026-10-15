import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") || "";
const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "https://tradeflow.laurendigital.co.uk",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Vary": "Origin",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers });

async function stripe(path: string, init: RequestInit = {}) {
  const response = await fetch("https://api.stripe.com/v1/" + path, {
    ...init,
    headers: {
      Authorization: "Bearer " + STRIPE_SECRET_KEY,
      ...(init.body ? { "Content-Type": "application/x-www-form-urlencoded" } : {}),
      ...(init.headers || {}),
    },
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data?.error?.message || "Stripe request failed.");
  }
  return data;
}

async function rest(path: string, init: RequestInit = {}) {
  const response = await fetch(SUPABASE_URL + "/rest/v1/" + path, {
    ...init,
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: "Bearer " + SERVICE_ROLE_KEY,
      ...(init.body ? { "Content-Type": "application/json" } : {}),
      ...(init.headers || {}),
    },
  });
  const raw = await response.text();
  let data: any;
  try { data = raw ? JSON.parse(raw) : null; } catch { data = raw; }
  if (!response.ok) throw new Error(data?.message || "Database request failed.");
  return data;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    const origin = req.headers.get("origin") || "";
    return new Response("ok", {
      headers: { ...headers, "Access-Control-Allow-Origin": origin === "https://tradeflow.laurendigital.co.uk" ? origin : "https://tradeflow.laurendigital.co.uk" },
    });
  }
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);
  if (!STRIPE_SECRET_KEY) return json({ error: "Stripe is not configured on this LIVE environment." }, 503);
  if (!SUPABASE_ANON_KEY) return json({ error: "Subscriber authentication is not configured on this environment." }, 503);

  const authorization = req.headers.get("authorization") || "";
  const bearer = authorization.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!bearer) return json({ error: "Please sign in again." }, 401);

  try {
    const authResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { apikey: SUPABASE_ANON_KEY, Authorization: "Bearer " + bearer },
    });
    if (!authResponse.ok) return json({ error: "Your session has expired. Please sign in again." }, 401);
    const user = await authResponse.json();
    const body = await req.json();
    const tenantId = String(body?.tenant_id || "");
    const action = String(body?.action || "connect");
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(tenantId)) {
      return json({ error: "A valid business workspace is required." }, 400);
    }

    const memberships = await rest(
      "tenant_memberships?select=tenant_id,user_id,role_code,status&tenant_id=eq." +
      encodeURIComponent(tenantId) + "&user_id=eq." + encodeURIComponent(user.id) +
      "&role_code=in.(owner,admin)&status=eq.active&limit=1",
    );
    if (!Array.isArray(memberships) || memberships.length !== 1) {
      return json({ error: "Only an active business owner or administrator can connect Stripe." }, 403);
    }

    const existingRows = await rest(
      "payment_provider_connections?select=id,provider_account_id,status,metadata&tenant_id=eq." +
      encodeURIComponent(tenantId) + "&provider=eq.stripe&connection_type=eq.customer_payments&limit=1",
    );
    const existing = Array.isArray(existingRows) ? existingRows[0] : null;

    if (action === "status") {
      if (!existing?.provider_account_id) {
        return json({ connected: false, status: "not_connected", message: "Stripe has not been connected yet." });
      }
      const account = await stripe("accounts/" + encodeURIComponent(existing.provider_account_id));
      const connected = account.charges_enabled === true && account.payouts_enabled === true && account.details_submitted === true;
      await rest(
        "payment_provider_connections?id=eq." + encodeURIComponent(existing.id) + "&tenant_id=eq." + encodeURIComponent(tenantId),
        {
          method: "PATCH",
          headers: { Prefer: "return=minimal" },
          body: JSON.stringify({
            status: connected ? "active" : "onboarding",
            livemode: account.livemode !== false,
            charges_enabled: account.charges_enabled === true,
            payouts_enabled: account.payouts_enabled === true,
            details_submitted: account.details_submitted === true,
            metadata: {
              ...(existing.metadata || {}),
              stripe_connect: true,
              setup_complete: connected,
              account_country: account.country || null,
              account_type: account.type || null,
              last_verified_at: new Date().toISOString(),
            },
            connected_at: connected ? new Date().toISOString() : null,
          }),
        },
      );
      return json({
        connected,
        status: connected ? "active" : "onboarding",
        account_id: account.id,
        charges_enabled: account.charges_enabled === true,
        payouts_enabled: account.payouts_enabled === true,
        details_submitted: account.details_submitted === true,
        message: connected ? "Stripe is connected and payouts are enabled." : "Stripe setup still needs to be completed in Stripe.",
      });
    }

    let accountId = existing?.provider_account_id || "";
    if (accountId) {
      const existingAccount = await stripe("accounts/" + encodeURIComponent(accountId));
      if (existingAccount.livemode === false) {
        return json({ error: "The saved Stripe account is in test mode. LIVE onboarding requires a live connected account." }, 409);
      }
    } else {
      const form = new URLSearchParams();
      form.set("type", "express");
      form.set("country", "GB");
      if (user.email) form.set("email", String(user.email));
      form.set("capabilities[card_payments][requested]", "true");
      form.set("capabilities[transfers][requested]", "true");
      const account = await stripe("accounts", { method: "POST", body: form.toString() });
      accountId = String(account.id || "");
      if (!accountId) return json({ error: "Stripe did not return a connected account ID." }, 502);
      const record = {
        tenant_id: tenantId,
        provider: "stripe",
        connection_type: "customer_payments",
        status: "onboarding",
        provider_account_id: accountId,
        display_name: "Stripe",
        country_code: "GB",
        default_currency: "GBP",
        livemode: account.livemode !== false,
        charges_enabled: false,
        payouts_enabled: false,
        details_submitted: false,
        metadata: { stripe_connect: true, setup_complete: false, primary: true, account_email: user.email || null },
      };
      await rest("payment_provider_connections?on_conflict=tenant_id,provider,connection_type", {
        method: "POST",
        headers: { Prefer: "resolution=merge-duplicates,return=representation" },
        body: JSON.stringify(record),
      });
    }

    const refresh = "https://tradeflow.laurendigital.co.uk/settings.html?stripe_connect=refresh";
    const returned = "https://tradeflow.laurendigital.co.uk/settings.html?stripe_connect=return";
    const linkForm = new URLSearchParams();
    linkForm.set("account", accountId);
    linkForm.set("refresh_url", refresh);
    linkForm.set("return_url", returned);
    linkForm.set("type", "account_onboarding");
    const accountLink = await stripe("account_links", { method: "POST", body: linkForm.toString() });
    if (!accountLink.url) return json({ error: "Stripe did not return an onboarding link." }, 502);
    return json({ url: accountLink.url, account_id: accountId, status: "onboarding" });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Unable to start Stripe onboarding." }, 500);
  }
});
