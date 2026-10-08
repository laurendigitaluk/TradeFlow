import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const CLOUDFLARE_API_TOKEN = Deno.env.get("CLOUDFLARE_API_TOKEN");
const CLOUDFLARE_ZONE_ID = Deno.env.get("CLOUDFLARE_ZONE_ID");
const CLOUDFLARE_CNAME_TARGET = Deno.env.get("CLOUDFLARE_SAAS_CNAME_TARGET");

const headers = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers });

async function sb(path: string, init: RequestInit = {}) {
  return fetch(SUPABASE_URL + path, {
    ...init,
    headers: {
      apikey: SERVICE_ROLE_KEY,
      Authorization: "Bearer " + SERVICE_ROLE_KEY,
      "Content-Type": "application/json",
      ...(init.headers || {}),
    },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "Authentication required" }, 401);

  if (!CLOUDFLARE_API_TOKEN || !CLOUDFLARE_ZONE_ID || !CLOUDFLARE_CNAME_TARGET) {
    return json({
      error: "Cloudflare custom-domain automation is not configured yet.",
      required_configuration: [
        "CLOUDFLARE_API_TOKEN",
        "CLOUDFLARE_ZONE_ID",
        "CLOUDFLARE_SAAS_CNAME_TARGET"
      ]
    }, 503);
  }

  try {
    const userResponse = await fetch(SUPABASE_URL + "/auth/v1/user", {
      headers: { apikey: SERVICE_ROLE_KEY, Authorization: auth }
    });
    if (!userResponse.ok) return json({ error: "Authentication required" }, 401);
    const user = await userResponse.json();

    const membershipResponse = await sb(
      "/rest/v1/platform_memberships?select=id,status&user_id=eq." +
      encodeURIComponent(user.id) +
      "&status=eq.active&limit=1"
    );
    const memberships = membershipResponse.ok ? await membershipResponse.json() : [];
    if (!Array.isArray(memberships) || !memberships.length) {
      return json({ error: "Platform owner access required" }, 403);
    }

    const body = await req.json().catch(() => ({}));
    const actionId = String(body.action_id || "");
    if (!actionId) return json({ error: "action_id is required" }, 400);

    // The Owner Dashboard already uses the authorised public RPC for domain
    // actions. Keep this Edge Function on that same contract rather than
    // querying the underlying action table directly through PostgREST.
    // The RPC must run with the authenticated Platform Owner JWT so its
    // auth.uid()/owner checks remain intact.
    const actionListResponse = await fetch(
      SUPABASE_URL + "/rest/v1/rpc/platform_owner_list_domain_actions",
      {
        method: "POST",
        headers: {
          apikey: SERVICE_ROLE_KEY,
          Authorization: auth,
          "Content-Type": "application/json"
        },
        body: "{}"
      }
    );
    if (!actionListResponse.ok) {
      const actionListBody = await actionListResponse.text().catch(() => "");
      return json({
        error: "Unable to load domain requests",
        detail: actionListBody || "platform_owner_list_domain_actions failed"
      }, 500);
    }

    const actionRows = await actionListResponse.json().catch(() => []);
    const action = Array.isArray(actionRows)
      ? actionRows.find((row: any) => String(row?.action_id || "") === actionId)
      : null;

    if (!action) return json({ error: "Domain request not found" }, 404);
    if (action.action_status === "active") return json({ error: "Domain is already active" }, 409);

    const tenantId = String(action.tenant_id || "");
    const hostnameFromAction = String(action.hostname || "").toLowerCase().trim();
    if (!tenantId || !hostnameFromAction) {
      return json({ error: "Domain request is missing tenant or hostname information" }, 500);
    }

    const domainResponse = await sb(
      "/rest/v1/tenant_domains?tenant_id=eq." +
      encodeURIComponent(tenantId) +
      "&hostname=eq." +
      encodeURIComponent(hostnameFromAction) +
      "&select=id,tenant_id,hostname,status,domain_type,acquisition_source,metadata&limit=1"
    );
    if (!domainResponse.ok) return json({ error: "Unable to load requested domain" }, 500);
    const domains = await domainResponse.json();
    const domain = domains?.[0];
    if (!domain) return json({ error: "Requested domain not found" }, 404);

    const hostname = String(domain.hostname || "").toLowerCase().trim();
    if (!hostname) return json({ error: "Requested hostname is empty" }, 400);

    const existingResponse = await fetch(
      "https://api.cloudflare.com/client/v4/zones/" +
      encodeURIComponent(CLOUDFLARE_ZONE_ID) +
      "/custom_hostnames?hostname=" +
      encodeURIComponent(hostname),
      { headers: { Authorization: "Bearer " + CLOUDFLARE_API_TOKEN, "Content-Type": "application/json" } }
    );
    const existingBody = await existingResponse.json().catch(() => null);
    if (!existingResponse.ok) {
      return json({ error: "Cloudflare hostname lookup failed", cloudflare: existingBody }, 502);
    }

    let custom = existingBody?.result?.[0];

    if (!custom) {
      const createResponse = await fetch(
        "https://api.cloudflare.com/client/v4/zones/" +
        encodeURIComponent(CLOUDFLARE_ZONE_ID) +
        "/custom_hostnames",
        {
          method: "POST",
          headers: {
            Authorization: "Bearer " + CLOUDFLARE_API_TOKEN,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({
            // Do not send custom_metadata: this Cloudflare account/zone is not
            // provisioned for the Custom Hostnames metadata feature. TradeFlow
            // keeps the tenant/domain mapping in its own database metadata.
            hostname,
            ssl: {
              method: "http",
              type: "dv",
              bundle_method: "ubiquitous",
              settings: { min_tls_version: "1.2" }
            }
          })
        }
      );
      const createBody = await createResponse.json().catch(() => null);
      if (!createResponse.ok) {
        return json({ error: "Cloudflare custom hostname creation failed", cloudflare: createBody }, 502);
      }
      custom = createBody?.result;
    }

    if (!custom?.id) return json({ error: "Cloudflare did not return a custom hostname ID" }, 502);

    // Cloudflare may populate validation records asynchronously. Fetch the
    // hostname details again so the Owner Dashboard gets the actual records.
    let detail = custom;
    for (let i = 0; i < 2; i++) {
      const detailResponse = await fetch(
        "https://api.cloudflare.com/client/v4/zones/" +
        encodeURIComponent(CLOUDFLARE_ZONE_ID) +
        "/custom_hostnames/" +
        encodeURIComponent(custom.id),
        { headers: { Authorization: "Bearer " + CLOUDFLARE_API_TOKEN, "Content-Type": "application/json" } }
      );
      const detailBody = await detailResponse.json().catch(() => null);
      if (detailResponse.ok && detailBody?.result) {
        detail = detailBody.result;
        if (detail.ssl?.validation_records?.length || detail.ownership_verification) break;
      }
      await new Promise((resolve) => setTimeout(resolve, 1500));
    }

    const validationRecords = detail.ssl?.validation_records || [];
    const ownership = detail.ownership_verification || null;
    const dnsInstructions = [
      "CNAME",
      hostname,
      CLOUDFLARE_CNAME_TARGET
    ].join(" | ");

    const metadata = {
      ...(action.metadata || {}),
      connection_prepared: true,
      cloudflare_custom_hostname_id: custom.id,
      cloudflare_hostname_status: detail.status || custom.status || null,
      cloudflare_ssl_status: detail.ssl?.status || null,
      cloudflare_ownership_verification: ownership,
      cloudflare_ssl_validation_records: validationRecords,
      cloudflare_cname_target: CLOUDFLARE_CNAME_TARGET,
      dns_instructions: dnsInstructions,
      prepared_at: new Date().toISOString()
    };

    const updateResponse = await sb(
      "/rest/v1/rpc/platform_owner_update_domain_action",
      {
        method: "POST",
        body: JSON.stringify({
          p_action_id: actionId,
          p_status: "dns_ready",
          p_notes: "Cloudflare custom hostname prepared automatically.",
          p_metadata: metadata
        })
      }
    );
    const updateBody = await updateResponse.json().catch(() => null);
    if (!updateResponse.ok) {
      return json({ error: "Cloudflare connection was created, but TradeFlow could not save the domain workflow state.", detail: updateBody }, 500);
    }

    return json({
      ok: true,
      hostname,
      custom_hostname_id: custom.id,
      cloudflare_status: detail.status || custom.status || null,
      ssl_status: detail.ssl?.status || null,
      cname_target: CLOUDFLARE_CNAME_TARGET,
      validation_records: validationRecords,
      ownership_verification: ownership
    });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});