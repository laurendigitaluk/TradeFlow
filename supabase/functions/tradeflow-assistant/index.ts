import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { retrieveKnowledge } from "./knowledge.ts";
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
  audience: "subscriber" | "customer";
  customerId?: string;
  customerContext?: unknown;
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

  const admin = createClient(supabaseUrl, serviceRoleKey);
  const { data: tenant, error: tenantError } = await admin.from("tenants").select("id,name").eq("id", tenantId).maybeSingle();
  if (tenantError || !tenant) return fail("TradeFlow business could not be resolved.", 404);

    const audience = body?.audience === "customer" ? "customer" : "subscriber";
  let membership: any = null;
  let customer: any = null;
  let customerContext: any = null;

  if (audience === "customer") {
    if (mode !== "help") return fail("Customer assistant supports help only.", 400);
    const { data: customerRow, error: customerError } = await admin.from("customers")
      .select("id,tenant_id,auth_user_id,customer_reference,first_name,last_name,status")
      .eq("tenant_id", tenantId)
      .eq("auth_user_id", user.id)
      .maybeSingle();
    if (customerError || !customerRow) return fail("Customer account could not be resolved for this business.", 403);
    customer = customerRow;

    const { data: requests } = await admin.from("buying_requests")
      .select("id,request_reference,status,submitted_at,updated_at")
      .eq("tenant_id", tenantId).eq("customer_id", customer.id)
      .order("updated_at", { ascending: false }).limit(10);

    const requestIds = (requests || []).map((row: any) => row.id);
    const { data: items } = requestIds.length
      ? await admin.from("buying_items")
        .select("id,buying_request_id,item_reference,status,title,purchase_stage,purchase_stage_updated_at")
        .eq("tenant_id", tenantId).in("buying_request_id", requestIds)
        .order("updated_at", { ascending: false }).limit(20)
      : { data: [] as any[] };

    const itemIds = (items || []).map((row: any) => row.id);
    const { data: offers } = itemIds.length
      ? await admin.from("offers")
        .select("id,buying_item_id,offer_reference,status,amount,currency,published_at,responded_at,expires_at")
        .eq("tenant_id", tenantId).in("buying_item_id", itemIds)
        .order("updated_at", { ascending: false }).limit(20)
      : { data: [] as any[] };

    const { data: acquisitions } = await admin.from("acquisitions")
      .select("id,acquisition_reference,status,agreed_total,currency,accepted_at,received_at,finalised_at,paid_at,completed_at,shipping_carrier,shipping_service,shipping_tracking_number,shipping_tracking_url,shipping_status")
      .eq("tenant_id", tenantId).eq("customer_id", customer.id)
      .order("updated_at", { ascending: false }).limit(10);

    const { data: retailOrders } = await admin.from("retail_orders")
      .select("id,order_reference,status,currency,total,payment_status,placed_at,paid_at,completed_at,cancelled_at")
      .eq("tenant_id", tenantId).eq("customer_id", customer.id)
      .order("updated_at", { ascending: false }).limit(10);

    const { data: returns } = await admin.from("returns")
      .select("id,return_reference,return_type,status,order_id,acquisition_id,requested_at,authorised_at,received_at,resolved_at,closed_at,refund_amount,currency")
      .eq("tenant_id", tenantId).eq("customer_id", customer.id)
      .order("updated_at", { ascending: false }).limit(10);

    customerContext = {
      customer: {
        customer_reference: customer.customer_reference,
        first_name: customer.first_name,
        last_name: customer.last_name,
        status: customer.status,
      },
      buying_requests: requests || [],
      buying_items: items || [],
      offers: offers || [],
      acquisitions: acquisitions || [],
      retail_orders: retailOrders || [],
      returns: returns || [],
    };
  } else {
    const { data: membershipRow, error: membershipError } = await userClient.from("tenant_memberships")
      .select("tenant_id,role_code,status").eq("tenant_id", tenantId).eq("user_id", user.id).eq("status", "active").maybeSingle();
    if (membershipError || !membershipRow) return fail("You do not have access to this TradeFlow business.", 403);
    membership = membershipRow;
  }


type ResearchAction = "lookup" | "approve";
const RESEARCH_TYPES = ["uk_new", "uk_used", "overseas"] as const;
type ResearchType = typeof RESEARCH_TYPES[number];

async function handleResearch(
  client: ReturnType<typeof createClient>,
  tenantId: string,
  userId: string,
  body: any,
) {
  const action = body?.research_action as ResearchAction;
  if (action !== "lookup" && action !== "approve") return fail("Unsupported research action.", 400);

  if (action === "lookup") {
    const manufacturer = typeof body?.manufacturer === "string" ? body.manufacturer.trim() : "";
    const model = typeof body?.model === "string" ? body.model.trim() : "";
    const packageName = typeof body?.package_name === "string" ? body.package_name.trim() : "";
    if (!manufacturer || !model) return fail("Manufacturer and model are required.", 400);

    let productQuery = client.from("tenant_buying_products")
      .select("id,manufacturer,model,package_name,active,manual_offer_price,automatic_percentage,pricing_notes")
      .eq("tenant_id", tenantId)
      .eq("active", true)
      .ilike("manufacturer", manufacturer)
      .ilike("model", model)
      .limit(10);

    const { data: products, error: productError } = await productQuery;
    if (productError) return fail("Unable to search the Buying Catalogue.", 500);

    const filteredProducts = (products || []).filter((p: any) =>
      !packageName || (p.package_name || "").toLowerCase().includes(packageName.toLowerCase())
    );

    const results = [];
    for (const product of filteredProducts) {
      const { data: evidence, error: evidenceError } = await client.from("tenant_buying_research")
        .select("id,evidence_type,source_name,source_url,observed_price,price_currency,item_condition,availability,notes,checked_at,created_by")
        .eq("tenant_id", tenantId)
        .eq("buying_product_id", product.id)
        .order("checked_at", { ascending: false })
        .limit(20);
      if (evidenceError) return fail("Unable to retrieve existing research evidence.", 500);
      results.push({ product, evidence: evidence || [] });
    }

    return json({
      status: "accepted",
      assistant: {
        mode: "research",
        research_action: "lookup",
        tenant_id: tenantId,
        read_only: true,
        external_research_enabled: false,
        products: results,
        message: results.length
          ? "Existing approved research evidence was found. No external research request was made."
          : "No matching active Buying Catalogue product was found. No external research request was made.",
      },
    });
  }

  const productId = typeof body?.buying_product_id === "string" ? body.buying_product_id.trim() : "";
  const evidence = body?.evidence && typeof body.evidence === "object" ? body.evidence : null;
  if (!productId || !evidence) return fail("buying_product_id and evidence are required for approval.", 400);

  const evidenceType = typeof evidence.evidence_type === "string" ? evidence.evidence_type.trim() : "";
  const sourceName = typeof evidence.source_name === "string" ? evidence.source_name.trim() : "";
  const sourceUrl = typeof evidence.source_url === "string" ? evidence.source_url.trim() : null;
  const observedPrice = evidence.observed_price === null || evidence.observed_price === undefined || evidence.observed_price === ""
    ? null : Number(evidence.observed_price);

  if (!(RESEARCH_TYPES as readonly string[]).includes(evidenceType)) return fail("Unsupported evidence type.", 400);
  if (!sourceName || sourceName.length > 300) return fail("A valid source name is required.", 400);
  if (sourceUrl && sourceUrl.length > 2000) return fail("Source URL is too long.", 400);
  if (observedPrice !== null && (!Number.isFinite(observedPrice) || observedPrice < 0)) return fail("Observed price must be a valid non-negative number.", 400);

  const { data: product, error: productError } = await client.from("tenant_buying_products")
    .select("id,manufacturer,model,package_name")
    .eq("tenant_id", tenantId)
    .eq("id", productId)
    .eq("active", true)
    .maybeSingle();
  if (productError) return fail("Unable to validate the Buying Catalogue product.", 500);
  if (!product) return fail("Buying Catalogue product not found or not available to this business.", 404);

  const { data: inserted, error: insertError } = await client.from("tenant_buying_research").insert({
    tenant_id: tenantId,
    buying_product_id: productId,
    evidence_type: evidenceType,
    source_name: sourceName,
    source_url: sourceUrl,
    observed_price: observedPrice,
    price_currency: "GBP",
    item_condition: typeof evidence.item_condition === "string" ? evidence.item_condition.trim() || null : null,
    availability: typeof evidence.availability === "string" ? evidence.availability.trim() || null : null,
    notes: typeof evidence.notes === "string" ? evidence.notes.trim() || null : null,
    checked_at: new Date().toISOString(),
    created_by: userId,
  }).select("id,evidence_type,source_name,source_url,observed_price,price_currency,item_condition,availability,notes,checked_at,created_by").single();

  if (insertError) return fail(insertError.message || "Unable to save approved research evidence.", 400);

  return json({
    status: "approved",
    assistant: {
      mode: "research",
      research_action: "approve",
      tenant_id: tenantId,
      read_only: false,
      approved_by: userId,
      product,
      evidence: inserted,
      message: "Research evidence was explicitly approved and saved to tenant_buying_research. Existing buying calculations can use the latest matching evidence.",
    },
  });
}

  const knowledge = retrieveKnowledge(question);

  if (mode === "research") {
    if (audience !== "subscriber") return fail("Customer assistant does not have access to Product Research.", 403);
    return await handleResearch(userClient, tenantId, user.id, body);
  }

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
        role: audience === "customer" ? "customer" : membership.role_code,
        audience,
        customer_id: customer?.id || null,
        customer_context: customerContext,
        question,
        knowledge,
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
    audience,
    customerId: customer?.id,
    customerContext,
  });

  if (result.status === "not_configured") {
    return fail(
      `The ${result.provider} provider is selected but its server-side adapter is not configured. No external AI request was made.`,
      503,
    );
  }

  return json({ status: "ok", assistant: result });
});
