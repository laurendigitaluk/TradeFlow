import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const normaliseDomain = (value: string) =>
  value.trim().toLowerCase().replace(/^https?:\/\//i, "").split("/")[0].replace(/\.$/, "");

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST required" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return json({ error: "Authentication required" }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const apiBase = (Deno.env.get("RESELLERCLUB_API_BASE_URL") || "https://api.sandbox.resellerclub.com/v2").replace(/\/$/, "");
  const userId = Deno.env.get("RESELLERCLUB_X_USER_ID");
  const apiKey = Deno.env.get("RESELLERCLUB_API_KEY");

  if (!supabaseUrl || !serviceRoleKey) return json({ error: "Supabase service configuration is missing" }, 500);
  if (!userId || !apiKey) return json({ error: "ResellerClub API is not configured on this TradeFlow environment yet." }, 503);

  try {
    const token = auth.replace(/^Bearer\s+/i, "");
    const admin = createClient(supabaseUrl, serviceRoleKey);
    const { data: { user }, error: userError } = await admin.auth.getUser(token);
    if (userError || !user) return json({ error: "Authentication required" }, 401);

    const body = await req.json();
    const tenantId = String(body?.tenant_id || "");
    const requestedDomain = normaliseDomain(String(body?.domain_name || ""));
    const tld = String(body?.tld || "").trim().toLowerCase().replace(/^\./, "");

    if (!tenantId || !requestedDomain || !tld) {
      return json({ error: "tenant_id, domain_name and tld are required" }, 400);
    }

    const { data: membership } = await admin
      .from("tenant_memberships")
      .select("tenant_id")
      .eq("tenant_id", tenantId)
      .eq("user_id", user.id)
      .eq("status", "active")
      .maybeSingle();

    if (!membership) return json({ error: "Tenant membership required" }, 403);

    const labels = requestedDomain.split(".");
    if (labels.length > 1 && labels[labels.length - 1].toLowerCase() === tld) {
      return json({ error: "Enter the domain name without its TLD." }, 400);
    }
    if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(requestedDomain)) {
      return json({ error: "Enter a valid domain name." }, 400);
    }

    const endpoint = new URL(apiBase + "/domains/available");
    endpoint.searchParams.set("domainName", requestedDomain);
    endpoint.searchParams.set("tlds", tld);

    const providerResponse = await fetch(endpoint.toString(), {
      headers: {
        "x-user-id": userId,
        "Authorization": `ApiKey ${apiKey}`,
        "Accept": "application/json",
      },
    });

    const text = await providerResponse.text();
    let providerBody: any = null;
    try { providerBody = text ? JSON.parse(text) : null; } catch { providerBody = { raw: text }; }

    if (!providerResponse.ok) {
      return json({
        error: `ResellerClub availability request failed (HTTP ${providerResponse.status})`,
        provider_status: providerResponse.status,
        provider_message: providerBody?.message || providerBody?.error || null,
      }, 502);
    }

    const result = Array.isArray(providerBody?.domains) ? providerBody.domains[0] : null;
    const status = String(result?.status || "unknown").toLowerCase();
    const fullDomain = result?.domainName || `${requestedDomain}.${tld}`;

    return json({
      domain: fullDomain,
      tld: `.${tld}`,
      status: ["available", "unavailable", "unknown"].includes(status) ? status : "unknown",
      available: status === "available",
      provider: "resellerclub",
      provider_response: result || null,
    });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});
