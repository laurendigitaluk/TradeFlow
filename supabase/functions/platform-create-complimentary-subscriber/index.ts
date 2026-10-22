import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "https://tradeflow-test.leannelaurenlowe.workers.dev",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Vary": "Origin",
};
const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);
  const origin = req.headers.get("origin") || "";
  if (origin !== "https://tradeflow-test.leannelaurenlowe.workers.dev") {
    return json({ error: "This action is only available from the TradeFlow TEST owner portal." }, 403);
  }
  const authorization = req.headers.get("Authorization");
  if (!authorization) return json({ error: "Sign in as the platform owner first." }, 401);
  try {
    const ownerResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: authorization },
    });
    if (!ownerResponse.ok) return json({ error: "Your session could not be verified. Sign in again." }, 401);
    const owner = await ownerResponse.json();
    const ownerMembershipResponse = await fetch(
      SUPABASE_URL + "/rest/v1/platform_memberships?select=id&user_id=eq." +
      encodeURIComponent(owner.id) + "&status=eq.active&limit=1",
      { headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY } },
    );
    if (!ownerMembershipResponse.ok) return json({ error: "Unable to verify platform-owner permissions." }, 500);
    const ownerMemberships = await ownerMembershipResponse.json();
    if (!Array.isArray(ownerMemberships) || ownerMemberships.length === 0) {
      return json({ error: "Active platform-owner access is required." }, 403);
    }

    const body = await req.json();
    const email = String(body?.email || "").trim().toLowerCase();
    const ownerName = String(body?.owner_name || "").trim();
    const businessName = String(body?.business_name || "").trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return json({ error: "Enter a valid subscriber email address." }, 400);
    if (!ownerName || !businessName) return json({ error: "Owner name and business name are required." }, 400);
    if (ownerName.length > 120 || businessName.length > 120) return json({ error: "Names must be 120 characters or fewer." }, 400);

    const slugBase = businessName.toLowerCase().normalize("NFKD").replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 48);
    if (!slugBase) return json({ error: "Choose a business name containing letters or numbers." }, 400);

    const inviteResponse = await fetch(SUPABASE_URL + "/auth/v1/invite?redirect_to=" + encodeURIComponent(origin + "/subscriber-invitation-accept.html"), {
      method: "POST",
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: "Bearer " + SERVICE_ROLE_KEY, "Content-Type": "application/json" },
      body: JSON.stringify({
        email,
        data: { full_name: ownerName, name: ownerName, business_name: businessName, complimentary_access: true },
      }),
    });
    const inviteText = await inviteResponse.text();
    let invited: any = null;
    try { invited = inviteText ? JSON.parse(inviteText) : null; } catch {}
    if (!inviteResponse.ok) {
      const raw = String(invited?.msg || invited?.message || invited?.error_description || invited?.error || inviteText || "");
      if (/already registered|already been registered|user already exists|already exists/i.test(raw)) {
        return json({ error: "That email already has a TradeFlow authentication account. For safety, this form will not attach an existing account automatically." }, 409);
      }
      console.error("Subscriber invitation request failed", { status: inviteResponse.status });
      return json({ error: "Unable to send the subscriber invitation. Check the email address and TEST owner logs before retrying." }, inviteResponse.status);
    }
    const userId = invited?.id || invited?.user?.id;
    if (!userId) return json({ error: "The invitation was sent but did not return a user ID. Check TEST Authentication users before retrying." }, 502);

    const rpcResponse = await fetch(SUPABASE_URL + "/rest/v1/rpc/platform_owner_create_complimentary_subscriber", {
      method: "POST",
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: authorization, "Content-Type": "application/json" },
      body: JSON.stringify({
        p_user_id: userId,
        p_business_name: businessName,
        p_business_slug: slugBase,
        p_owner_email: email,
      }),
    });
    const rpcText = await rpcResponse.text();
    let tenantId: string | null = null;
    try { tenantId = rpcText ? JSON.parse(rpcText) : null; } catch {}
    if (!rpcResponse.ok) {
      console.error("Complimentary subscriber workspace provisioning failed after invitation", { status: rpcResponse.status });
      return json({ error: "The invitation was sent, but workspace provisioning did not finish. Do not resend the invitation. Platform owner follow-up is required." }, 500);
    }
    return json({ success: true, email, business_name: businessName, tenant_id: tenantId, message: "Complimentary subscriber workspace created. The owner has been invited to set up access by email." });
  } catch {
    console.error("Unexpected provisioning error in TEST platform-create-complimentary-subscriber");
    return json({ error: "Unexpected provisioning error. Check the TEST Edge Function logs." }, 500);
  }
});