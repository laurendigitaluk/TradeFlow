import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.0";
import { McpServer } from "npm:@modelcontextprotocol/sdk@1.25.3/server/mcp.js";
import { WebStandardStreamableHTTPServerTransport } from "npm:@modelcontextprotocol/sdk@1.25.3/server/webStandardStreamableHttp.js";
import { z } from "npm:zod@4.1.13";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const MCP_TOKEN = Deno.env.get("TRADEFLOW_RESEARCH_MCP_TOKEN")!;

function constantTimeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

function jsonError(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "content-type": "application/json", "cache-control": "no-store" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "access-control-allow-origin": "*",
        "access-control-allow-headers": "authorization, content-type, mcp-session-id, mcp-protocol-version",
        "access-control-allow-methods": "GET, POST, DELETE, OPTIONS",
        "access-control-expose-headers": "mcp-session-id",
      },
    });
  }

  if (!MCP_TOKEN || !SUPABASE_URL || !SERVICE_ROLE_KEY) {
    return jsonError("TradeFlow Research MCP is not configured. Add its server secret before connecting a client.", 503);
  }

  const auth = req.headers.get("authorization") ?? "";
  const supplied = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  if (!supplied || !constantTimeEqual(supplied, MCP_TOKEN)) return jsonError("Unauthorized", 401);

  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const server = new McpServer({ name: "tradeflow-research-inbox", version: "1.0.0" });

  server.registerTool("search_catalogue", {
    title: "Search TradeFlow master catalogue",
    description: "Read-only search of active LIVE master products. Use before researching to identify existing products and avoid duplicates. Never creates or edits products.",
    inputSchema: {
      query: z.string().min(2).max(160),
      category_slug: z.string().max(120).optional(),
      limit: z.number().int().min(1).max(40).default(20),
    },
  }, async ({ query, category_slug, limit }) => {
    let categoryId: string | undefined;
    if (category_slug) {
      const { data: cat, error } = await supabase.from("catalogue_master_categories")
        .select("id,name,slug").eq("slug", category_slug).eq("active", true).maybeSingle();
      if (error) throw new Error(error.message);
      if (!cat) return { content: [{ type: "text", text: JSON.stringify({ products: [], note: "No active category matched that slug." }) }] };
      categoryId = cat.id;
    }
    const select = "id,model,package_key,package_name,catalogue_category,main_category,product_type,active,category:catalogue_master_categories(name,slug),manufacturer:catalogue_master_manufacturers(name)";
    let modelQuery = supabase.from("catalogue_master_products").select(select).eq("active", true).ilike("model", `%${query}%`).limit(limit);
    let packageQuery = supabase.from("catalogue_master_products").select(select).eq("active", true).ilike("package_name", `%${query}%`).limit(limit);
    if (categoryId) {
      modelQuery = modelQuery.eq("category_id", categoryId);
      packageQuery = packageQuery.eq("category_id", categoryId);
    }
    const [models, packages] = await Promise.all([modelQuery, packageQuery]);
    if (models.error) throw new Error(models.error.message);
    if (packages.error) throw new Error(packages.error.message);
    const unique = new Map<string, unknown>();
    for (const row of [...(models.data ?? []), ...(packages.data ?? [])]) unique.set((row as { id: string }).id, row);
    const products = [...unique.values()].slice(0, limit);
    return { content: [{ type: "text", text: JSON.stringify({ count: products.length, products }) }] };
  });

  server.registerTool("get_existing_evidence", {
    title: "Read existing market evidence",
    description: "Read-only lookup of active evidence attached to a LIVE master product. Never inserts, updates or deletes evidence.",
    inputSchema: { master_product_id: z.string().uuid() },
  }, async ({ master_product_id }) => {
    const { data, error } = await supabase.from("shared_market_evidence")
      .select("id,evidence_type,source_name,source_url,observed_price,price_currency,item_condition,sales_channel,availability,observed_at,notes,source_record_key")
      .eq("master_product_id", master_product_id).eq("is_active", true)
      .order("observed_at", { ascending: false }).limit(100);
    if (error) throw new Error(error.message);
    return { content: [{ type: "text", text: JSON.stringify({ count: data?.length ?? 0, evidence: data ?? [] }) }] };
  });

  server.registerTool("submit_research_report", {
    title: "Submit research report for review",
    description: "Stores a completed research report and structured findings in the private TradeFlow Research Inbox. It does NOT create products, approve evidence, or write to shared_market_evidence.",
    inputSchema: {
      title: z.string().min(1).max(200),
      prompt: z.string().min(1).max(20000),
      category_slug: z.string().max(120).optional(),
      model_name: z.string().max(160).optional(),
      report_markdown: z.string().min(1).max(180000),
      report_json: z.record(z.string(), z.unknown()),
      finding_count: z.number().int().min(0).max(500),
      source_count: z.number().int().min(0).max(1000),
      metadata: z.record(z.string(), z.unknown()).optional(),
    },
  }, async ({ title, prompt, category_slug, model_name, report_markdown, report_json, finding_count, source_count, metadata }) => {
    const { data: inserted, error } = await supabase.from("platform_research_reports").insert({
      title, prompt, category_slug: category_slug ?? null, source_app: "LM Studio Bionic",
      model_name: model_name ?? null, status: "submitted_for_review", report_markdown,
      report_json, finding_count, source_count, metadata: metadata ?? {},
    }).select("id,title,status,submitted_at").single();
    if (error) throw new Error(error.message);

    const markdownPath = `${inserted.id}/research-report.md`;
    const jsonPath = `${inserted.id}/findings.json`;
    const markdownUpload = await supabase.storage.from("tradeflow-research-inbox").upload(
      markdownPath, new Blob([report_markdown], { type: "text/markdown" }),
      { contentType: "text/markdown", upsert: false },
    );
    const jsonUpload = await supabase.storage.from("tradeflow-research-inbox").upload(
      jsonPath, new Blob([JSON.stringify(report_json, null, 2)], { type: "application/json" }),
      { contentType: "application/json", upsert: false },
    );
    const storageErrors = [markdownUpload.error?.message, jsonUpload.error?.message].filter(Boolean);
    if (markdownUpload.data && jsonUpload.data) {
      const { error: updateError } = await supabase.from("platform_research_reports").update({
        storage_markdown_path: markdownPath, storage_json_path: jsonPath,
      }).eq("id", inserted.id);
      if (updateError) storageErrors.push(updateError.message);
    }
    return { content: [{ type: "text", text: JSON.stringify({
      report_id: inserted.id, title: inserted.title, status: inserted.status,
      submitted_at: inserted.submitted_at, finding_count, source_count,
      stored_files: storageErrors.length === 0,
      storage_warning: storageErrors.length ? storageErrors.join("; ") : null,
      review_note: "Saved for independent review. No catalogue or shared evidence records were changed.",
    }) }] };
  });

  const transport = new WebStandardStreamableHTTPServerTransport();
  await server.connect(transport);
  return await transport.handleRequest(req);
});
