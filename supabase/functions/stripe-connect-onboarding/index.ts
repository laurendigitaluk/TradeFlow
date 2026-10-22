import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY") || "";
const STRIPE_LIVE_MODE = /^(sk|rk)_live_/.test(STRIPE_SECRET_KEY);
const ALLOWED_ORIGINS = new Set([
  "https://tradeflow.laurendigital.co.uk",
  "https://laurendigital.co.uk",
  "https://www.scenesource.co.uk",
  "https://scenesource.co.uk",
  "https://laurendigitaluk.github.io",
]);

function corsHeaders(origin: string) {
  return {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.has(origin) ? origin : "https://tradeflow.laurendigital.co.uk",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
}
const json = (body: unknown, status = 200, origin = "") =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders(origin) });

async function stripeV2(path: string, init: RequestInit = {}) {
  const response = await fetch("https://api.stripe.com/v2/" + path, {
    ...init,
    headers: {
      Authorization: "Bearer " + STRIPE_SECRET_KEY,
      "Stripe-Version": "2026-09-30.endive",
      ...(init.body ? { "Content-Type": "application/json" } : {}),
      ...(init.headers || {}),
    },
  });
  const raw = await response.text();
  let data: any;
  try { data = raw ? JSON.parse(raw) : null; } catch { data = raw; }
  if (!response.ok) throw new Error(data?.error?.message || data?.message || "Stripe V2 request failed.");
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
  const origin = req.headers.get("origin") || "";
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders(origin) });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405, origin);
  if (!/^(sk|rk)_live_/.test(STRIPE_SECRET_KEY)) return json({ error: "LIVE Stripe Connect requires a live-mode Stripe secret key. No account was created." }, 503, origin);

  const bearer = (req.headers.get("authorization") || "").match(/^Bearer\s+(.+)$/i)?.[1];
  const publicKey = req.headers.get("apikey") || "";
  if (!bearer || !publicKey) return json({ error: "Please sign in again." }, 401, origin);

  let diagnosticStage = "auth_user_lookup";
  try {
    const authResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { apikey: publicKey, Authorization: "Bearer " + bearer },
    });
    if (!authResponse.ok) return json({ error: "Your session has expired. Please sign in again." }, 401, origin);
    const user = await authResponse.json();
    const body = await req.json();
    const tenantId = String(body?.tenant_id || "");
    const action = String(body?.action || "connect");
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(tenantId)) {
      return json({ error: "A valid business workspace is required." }, 400, origin);
    }

    diagnosticStage = "tenant_membership_lookup";
    const memberships = await rest(
      "tenant_memberships?select=tenant_id,user_id,role_code,status&tenant_id=eq." +
      encodeURIComponent(tenantId) + "&user_id=eq." + encodeURIComponent(user.id) +
      "&role_code=in.(owner,admin)&status=eq.active&limit=1",
    );
    if (!Array.isArray(memberships) || memberships.length !== 1) {
      return json({ error: "Only an active business owner or administrator can connect Stripe." }, 403, origin);
    }

    diagnosticStage = "payment_provider_connection_lookup";
    const existingRows = await rest(
      "payment_provider_connections?select=id,provider_account_id,status,metadata,connected_at&tenant_id=eq." +
      encodeURIComponent(tenantId) + "&provider=eq.stripe&connection_type=eq.customer_payments&limit=1",
    );
    const existing = Array.isArray(existingRows) ? existingRows[0] : null;

    if (action === "status") {
      if (!existing?.provider_account_id) {
        return json({ connected: false, status: "not_connected", message: "Stripe has not been connected yet." }, 200, origin);
      }
      diagnosticStage = "stripe_existing_account_retrieve";
      const account = await stripeV2("core/accounts/" + encodeURIComponent(existing.provider_account_id) + "?include%5B0%5D=configuration.merchant&include%5B1%5D=defaults&include%5B2%5D=requirements");
      const controller = account.controller || {};
      const configurationOk = account.dashboard === "full" &&
        account.defaults?.responsibilities?.fees_collector === "stripe" &&
        account.defaults?.responsibilities?.losses_collector === "stripe";
      const connected = STRIPE_LIVE_MODE && configurationOk &&
        account.configuration?.merchant?.capabilities?.card_payments?.status === "active" &&
        !["currently_due", "past_due"].includes(account.requirements?.summary?.minimum_deadline?.status);
      diagnosticStage = "payment_provider_connection_status_update";
      await rest(
        "payment_provider_connections?id=eq." + encodeURIComponent(existing.id) + "&tenant_id=eq." + encodeURIComponent(tenantId),
        {
          method: "PATCH",
          headers: { Prefer: "return=minimal" },
          body: JSON.stringify({
            status: connected ? "active" : "onboarding",
            livemode: STRIPE_LIVE_MODE,
            charges_enabled: account.configuration?.merchant?.capabilities?.card_payments?.status === "active",
            payouts_enabled: account.configuration?.merchant?.capabilities?.card_payments?.status === "active",
            details_submitted: !["currently_due", "past_due"].includes(account.requirements?.summary?.minimum_deadline?.status),
            metadata: {
              ...(existing.metadata || {}),
              stripe_connect: true,
              setup_complete: connected,
              account_country: account.identity?.country || account.country || null,
              account_type: account.type || null,
              stripe_account_configuration: {
                dashboard: account.dashboard ?? null,
                fees_collector: account.defaults?.responsibilities?.fees_collector ?? null,
                losses_collector: account.defaults?.responsibilities?.losses_collector ?? null,
                card_payments_status: account.configuration?.merchant?.capabilities?.card_payments?.status ?? null,
                minimum_deadline_status: account.requirements?.summary?.minimum_deadline?.status ?? null,
              },
              last_verified_at: new Date().toISOString(),
            },
            connected_at: connected ? (existing.connected_at || new Date().toISOString()) : null,
          }),
        },
      );
      return json({
        connected, status: connected ? "active" : "onboarding", account_id: account.id,
        charges_enabled: account.configuration?.merchant?.capabilities?.card_payments?.status === "active",
        payouts_enabled: account.configuration?.merchant?.capabilities?.card_payments?.status === "active",
        details_submitted: !["currently_due", "past_due"].includes(account.requirements?.summary?.minimum_deadline?.status),
        configuration_ok: configurationOk,
        account_configuration: {
          dashboard: account.dashboard ?? null,
          fees_collector: account.defaults?.responsibilities?.fees_collector ?? null,
          losses_collector: account.defaults?.responsibilities?.losses_collector ?? null,
          card_payments_status: account.configuration?.merchant?.capabilities?.card_payments?.status ?? null,
          minimum_deadline_status: account.requirements?.summary?.minimum_deadline?.status ?? null,
        },
        message: connected ? "Stripe is connected and payouts are enabled." :
          (!configurationOk
            ? "Saved connected-account configuration does not match TradeFlow's required settings. Actual Stripe values: dashboard=" + String(account.dashboard ?? "not returned") + ", fees_collector=" + String(account.defaults?.responsibilities?.fees_collector ?? "not returned") + ", losses_collector=" + String(account.defaults?.responsibilities?.losses_collector ?? "not returned") + ". TradeFlow expects dashboard=full, fees_collector=stripe, losses_collector=stripe. No account was created or replaced."
            : "Stripe setup still needs to be completed in Stripe."),
      }, 200, origin);
    }

    let accountId = existing?.provider_account_id || "";
    if (accountId && !/^acct_[A-Za-z0-9]+$/.test(accountId)) return json({ error: "The saved Stripe account reference is not a connected-account ID. Contact support before reconnecting." }, 409, origin);
    if (accountId) {
      diagnosticStage = "stripe_saved_account_retrieve";
      const account = await stripeV2("core/accounts/" + encodeURIComponent(accountId) + "?include%5B0%5D=configuration.merchant&include%5B1%5D=defaults&include%5B2%5D=requirements");
      if (!STRIPE_LIVE_MODE) {
        return json({ error: "The saved Stripe account is not a live connected account. Contact support before reconnecting." }, 409, origin);
      }
      const controller = account.controller || {};
      if (account.dashboard !== "full" ||
          account.defaults?.responsibilities?.fees_collector !== "stripe" ||
          account.defaults?.responsibilities?.losses_collector !== "stripe") {
        return json({
          error: "The saved Stripe account uses a different Connect configuration. TradeFlow will not silently reuse or replace it. Review the account with the platform owner before proceeding.",
          code: "CONNECTED_ACCOUNT_CONFIGURATION_MISMATCH",
        }, 409, origin);
      }
    } else {
      const payload: Record<string, unknown> = {
        display_name: String(body?.business_name || "TradeFlow subscriber"),
        identity: { country: "gb" },
        dashboard: "full",
        defaults: { responsibilities: { fees_collector: "stripe", losses_collector: "stripe" } },
        configuration: { customer: {}, merchant: { capabilities: { card_payments: { requested: true } } } },
        metadata: { tradeflow_tenant_id: tenantId, tradeflow_product: "TradeFlow" },
      };
      if (user.email) payload.contact_email = String(user.email);
      diagnosticStage = "stripe_v2_connected_account_create";
      const account = await stripeV2("core/accounts", {
        method: "POST",
        headers: { "Idempotency-Key": "tradeflow-connect-account-v3-" + tenantId },
        body: JSON.stringify(payload),
      });
      accountId = String(account.id || "");
      if (!accountId) return json({ error: "Stripe did not return a connected account ID." }, 502, origin);
      diagnosticStage = "payment_provider_connection_save";
      await rest("payment_provider_connections?on_conflict=tenant_id,provider,connection_type", {
        method: "POST",
        headers: { Prefer: "resolution=merge-duplicates,return=minimal" },
        body: JSON.stringify({
          tenant_id: tenantId, provider: "stripe", connection_type: "customer_payments",
          status: "onboarding", provider_account_id: accountId, display_name: "Stripe",
          country_code: "GB", default_currency: "GBP", livemode: true,
          charges_enabled: false, payouts_enabled: false, details_submitted: false,
          metadata: { stripe_connect: true, setup_complete: false, primary: true, account_email: user.email || null },
        }),
      });
    }

    const returnOrigin = ALLOWED_ORIGINS.has(origin) ? origin : "https://tradeflow.laurendigital.co.uk";
    const prefix = returnOrigin === "https://laurendigitaluk.github.io" ? "/TradeFlow" : "";
    const refreshUrl = returnOrigin + prefix + "/settings.html?stripe_connect=refresh";
    const returnUrl = returnOrigin + prefix + "/settings.html?stripe_connect=return";
    diagnosticStage = "stripe_v2_account_link_create";
    const link = await stripeV2("core/account_links", {
      method: "POST",
      body: JSON.stringify({
        account: accountId,
        use_case: { type: "account_onboarding", account_onboarding: {
          refresh_url: refreshUrl, return_url: returnUrl,
        } },
      }),
    });
    if (!link.url) return json({ error: "Stripe did not return an onboarding link." }, 502, origin);
    return json({ url: link.url, status: "onboarding" }, 200, origin);
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    console.error("[stripe-connect-onboarding] request_failed", { stage: diagnosticStage, message: message.slice(0, 300) });
    return json({ error: "Stripe Connect request failed.", stage: diagnosticStage }, 500, origin);
  }
});
