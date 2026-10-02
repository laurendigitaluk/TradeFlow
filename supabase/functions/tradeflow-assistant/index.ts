import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
const fail = (message: string, status: number) => json({ error: message }, status);

const SUPPORTED_PROVIDERS = ["none", "gemma", "openai", "anthropic", "google", "subscriber"] as const;
type Provider = typeof SUPPORTED_PROVIDERS[number];
type AiConfig = { provider?: string; allowed?: string[] };

type ProviderRequest = {
  question: string;
  mode: "help" | "research";
  tenantId: string;
  userId: string;
};

type ProviderResponse = {
  provider: Provider;
  status: "not_configured";
  answer: null;
};

interface ProviderAdapter {
  readonly provider: Provider;
  execute(request: ProviderRequest): Promise<ProviderResponse>;
}

class NotConfiguredAdapter implements ProviderAdapter {
  constructor(readonly provider: Provider) {}

  async execute(_request: ProviderRequest): Promise<ProviderResponse> {
    return { provider: this.provider, status: "not_configured", answer: null };
  }
}

function getProviderAdapter(provider: Provider): ProviderAdapter {
  // Provider-specific network calls are deliberately not implemented until
  // that provider's credentials, limits and request/response contract are approved.
  return new NotConfiguredAdapter(provider);
}

function readConfig(): { provider: Provider; allowed: Provider[] } {
  const raw = Deno.env.get("TRADEFLOW_AI_CONFIG")?.trim();
  if (!raw) return { provider: "none", allowed: ["none"] };
  try {
    const parsed = JSON.parse(raw) as AiConfig;
    const allowed = Array.isArray(parsed.allowed)
      ? parsed.allowed.filter((p): p is Provider =>
          typeof p === "string" && (SUPPORTED_PROVIDERS as readonly string[]).includes(p))
      : [];
    const provider = typeof parsed.provider === "string" &&
      (SUPPORTED_PROVIDERS as readonly string[]).includes(parsed.provider)
      ? parsed.provider as Provider
      : "none";
    return { provider, allowed: allowed.length ? allowed : ["none"] };
  } catch {
    return { provider: "none", allowed: ["none"] };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return fail("POST required", 405);

  const auth = req.headers.get("Authorization");
  if (!auth) return fail("Authentication required", 401);
  const token = auth.replace(/^Bearer\s+/i, "");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const publishableKey = Deno.env.get("SUPABASE_ANON_KEY") || Deno.env.get("SUPABASE_PUBLISHABLE_KEY") || "";
  if (!supabaseUrl || !serviceRoleKey || !publishableKey) return fail("Assistant service configuration is incomplete", 500);

  const userClient = createClient(supabaseUrl, publishableKey, { global: { headers: { Authorization: `Bearer ${token}` } } });
  const { data: { user }, error: userError } = await userClient.auth.getUser(token);
  if (userError || !user) return fail("Authentication required", 401);

  const body = await req.json().catch(() => null);
  const tenantId = typeof body?.tenant_id === "string" ? body.tenant_id.trim() : "";
  const question = typeof body?.question === "string" ? body.question.trim() : "";
  const mode = typeof body?.mode === "string" ? body.mode : "help";
  if (!tenantId) return fail("tenant_id is required", 400);
  if (!question) return fail("question is required", 400);
  if (question.length > 4000) return fail("Question is too long.", 400);
  if (!["help", "research"].includes(mode)) return fail("Unsupported assistant mode.", 400);

  const { data: membership, error: membershipError } = await userClient.from("tenant_memberships")
    .select("tenant_id,role_code,status").eq("tenant_id", tenantId).eq("user_id", user.id).eq("status", "active").maybeSingle();
  if (membershipError || !membership) return fail("You do not have access to this TradeFlow business.", 403);

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: tenant, error: tenantError } = await admin.from("tenants").select("id,name").eq("id", tenantId).maybeSingle();
  if (tenantError || !tenant) return fail("TradeFlow business could not be resolved.", 404);

  const config = readConfig();
  const providerAllowed = config.allowed.includes(config.provider);

  if (config.provider === "none") {
    return json({
      status: "accepted",
      assistant: {
        mode,
        provider: "none",
        provider_allowed: true,
        available_providers: config.allowed,
        read_only: true,
        tenant_id: tenantId,
        tenant_name: tenant.name,
        user_id: user.id,
        role: membership.role_code,
        question,
      },
      next_step: "No AI provider is enabled. Change the server-side TRADEFLOW_AI_CONFIG setting to select an approved provider; subscriber code does not need to change.",
    });
  }

  if (!providerAllowed) {
    return fail("The configured AI provider is not allowed by the server configuration.", 503);
  }

  const adapter = getProviderAdapter(config.provider);
  const result = await adapter.execute({
    question,
    mode: mode as "help" | "research",
    tenantId,
    userId: user.id,
  });

  if (result.status === "not_configured") {
    return fail(
      `The ${result.provider} provider is selected but its server-side adapter is not configured. No external AI request was made.`,
      503,
    );
  }

  return json({ status: "ok", assistant: result });
});
