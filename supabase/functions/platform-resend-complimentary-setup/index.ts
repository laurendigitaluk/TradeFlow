import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ORIGIN = "https://tradeflow-test.leannelaurenlowe.workers.dev";
const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": ORIGIN,
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Vary": "Origin",
};
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);
  if (req.headers.get("origin") !== ORIGIN) return json({ error: "This action is only available from the TradeFlow TEST owner portal." }, 403);
  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Sign in as the platform owner first." }, 401);
  try {
    const ownerResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: authorization },
    });
    if (!ownerResponse.ok) return json({ error: "Your session could not be verified. Sign in again." }, 401);
    const owner = await ownerResponse.json();
    const membershipResponse = await fetch(
      SUPABASE_URL + "/rest/v1/platform_memberships?select=id&user_id=eq." +
      encodeURIComponent(owner.id) + "&status=eq.active&limit=1",
      { headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY } },
    );
    if (!membershipResponse.ok) return json({ error: "Unable to verify platform-owner permissions." }, 500);
    const memberships = await membershipResponse.json();
    if (!Array.isArray(memberships) || memberships.length === 0) return json({ error: "Active platform-owner access is required." }, 403);

    const body = await req.json();
    const email = String(body?.email || "").trim().toLowerCase();
    if (!/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(email)) return json({ error: "Enter a valid subscriber email address." }, 400);

    // Only allow recovery for an existing account that already owns a complimentary/manual tenant.
    const accountResponse = await fetch(
      SUPABASE_URL + "/rest/v1/tenant_memberships?select=user_id,tenant_id,tenant:tenants!inner(status,tenant_subscriptions(status,billing_provider,provider_status))&user_id=not.is.null&status=eq.active",
      { headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY } },
    );
    if (!accountResponse.ok) return json({ error: "Unable to verify existing subscriber access. No email was sent." }, 500);
    const rows = await accountResponse.json();
    const userResponse = await fetch(SUPABASE_URL + "/auth/v1/admin/users?page=1&per_page=1000", {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY },
    });
    if (!userResponse.ok) return json({ error: "Unable to verify the existing authentication account. No email was sent." }, 500);
    const userPayload = await userResponse.json();
    const user = (userPayload.users || []).find((u: any) => String(u.email || "").toLowerCase() === email);
    if (!user) return json({ error: "No existing TradeFlow account was found for that email. Use Create complimentary subscriber for a new account." }, 404);
    const eligible = rows.some((row: any) => row.user_id === user.id &&
      row.tenant?.status === "active" &&
      Array.isArray(row.tenant?.tenant_subscriptions) &&
      row.tenant.tenant_subscriptions.some((s: any) => s.status === "active" && s.billing_provider === "manual" && s.provider_status === "complimentary"));
    if (!eligible) return json({ error: "This account does not currently have an active complimentary workspace. No recovery email was sent." }, 409);

    const recovery = await fetch(SUPABASE_URL + "/auth/v1/recover?redirect_to=" + encodeURIComponent(ORIGIN + "/subscriber-invitation-accept.html"), {
      method: "POST",
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY, "Content-Type": "application/json" },
      body: JSON.stringify({ email }),
    });
    if (!recovery.ok) {
      const detail = await recovery.text();
      return json({ error: "Supabase could not send the account setup link. No workspace was changed.", detail }, recovery.status);
    }
    return json({ success: true, message: "If the existing account is eligible, an account setup link has been sent to " + email + ". This does not create or modify a workspace." });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : "Unexpected recovery error." }, 500);
  }
});
