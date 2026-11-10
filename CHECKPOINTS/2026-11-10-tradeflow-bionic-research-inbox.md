# Checkpoint — TradeFlow Bionic Research Inbox connector

Date: 10 November 2026
Repository: laurendigitaluk/TradeFlow
Target: TradeFlow LIVE Supabase project `gxsrajtqzdjvmceqcpgv`

## User requirement
Keep the user's existing LM Studio Bionic research application and existing prompt workflow. Add a secure connection so Bionic can look up the LIVE master catalogue and existing evidence, then save a Markdown research report and structured JSON findings for ChatGPT/owner verification. No automatic catalogue or shared-evidence writes.

## Pre-change checks
- Read the final Gemma retirement checkpoint and the 7 November Common Room / capture-first handoff checkpoints.
- Confirmed old worker/control-plane RPCs were revoked by migration `20261110173027`.
- Confirmed the former research queue remains historical (75 rows; 10 currently `needs_research`) and is not repurposed for new prompt reports.
- Confirmed LIVE master tables and evidence schema. Product table joins use `catalogue_master_categories` and `catalogue_master_manufacturers`.
- Confirmed existing private Storage buckets; created a separate bucket to avoid touching subscriber/customer media.

## Applied LIVE schema
Migration: `20261110200000_tradeflow_research_inbox`
- Created `public.platform_research_reports` with report title, prompt, category, source app/model, markdown, JSON, finding/source counts, storage paths, status and review metadata.
- RLS enabled; no privileges for PUBLIC/anon/authenticated; service_role only.
- Created private `tradeflow-research-inbox` bucket, 20 MiB limit, MIME types Markdown/plain text/JSON.
- Verification: table exists, RLS enabled, report count 0, private bucket exists, zero anon/authenticated table grants.

## Deployed LIVE MCP endpoint
- Edge Function `tradeflow-research-mcp`, ACTIVE, version 1, `verify_jwt=false`.
- Source committed at `supabase/functions/tradeflow-research-mcp/index.ts` on production.
- Endpoint: `https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-research-mcp`.
- Function requires server secret `TRADEFLOW_RESEARCH_MCP_TOKEN` as a bearer token. It returns 503 while this secret is absent; invalid token returns 401.
- Function uses Supabase service role internally only. Never expose service-role credentials to LM Studio.
- Tools:
  1. `search_catalogue`: read-only active product/category/manufacturer search.
  2. `get_existing_evidence`: read-only evidence lookup for a master product.
  3. `submit_research_report`: creates a submitted_for_review report and writes Markdown + JSON files to private Storage.
- No tool can create products, approve evidence, or write shared_market_evidence.

## Security advisor note
The advisor reports an INFO finding that the new report table has RLS enabled with no policies. This is intentional: all direct table privileges are revoked from anon/authenticated and the private Edge Function uses service_role after its separate bearer-token check. Existing unrelated advisor warnings predate this change and were not modified.

## Pending owner connection step
1. In Supabase Dashboard > Edge Function Secrets, create `TRADEFLOW_RESEARCH_MCP_TOKEN` with a high-entropy random value. Do not send it in chat or commit it to GitHub.
2. Add remote server to LM Studio's `mcp.json`:
```json
{
  "mcpServers": {
    "tradeflow-research": {
      "url": "https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-research-mcp",
      "headers": {
        "Authorization": "Bearer <same-token>"
      }
    }
  }
}
```
3. Save/reload LM Studio, enable the connector for the research model/chat.
4. Test catalogue lookup, existing evidence lookup, report submission and private Storage object readback.
5. Verify report is visible to ChatGPT via approved project tools before any catalogue import flow is built.

## Explicit non-goals
- No local PC/PowerShell changes.
- No GitHub or Supabase connector credential changes.
- No reactivation of Gemma, old worker RPCs, desktop supervisor or Common Room.
- No TEST/LIVE data sync.
- No edits to existing product, category, manufacturer, tenant, customer, Stripe or shared evidence records.
