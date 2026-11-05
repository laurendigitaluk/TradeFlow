# Checkpoint — TradeFlow Deep Source Research preflight
Date: 5 November 2026



## TradeFlow Deep Source Research architecture preflight — 5 November 2026

A dedicated TradeFlow research system is now the target; the old GearCashOut supervisor/configuration/desktop are not the foundation. Preserve the existing local Ollama and Gemma 3:4B installation. Ollama responds at 127.0.0.1:11434 and /api/tags/ returns gemma3:4b; the old Gemma Desktop UI at 127.0.0.1 is unavailable but is not required.

The new system must use one coordinator and configurable concurrent workers (start with two), share one local Gemma service, traverse every active category -> branch -> product in bounded pages, and explicitly process products without a branch. Exclude Pokémon Trading Cards (23,780 active products) from all task generation and writes. The current master schema has category_id and branch_id; it does not provide recursive parent_id levels on these category/branch tables. Do not assume parent search includes branches.

Use platform catalogue tables catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers and catalogue_master_products. Use shared_market_evidence only for trusted platform evidence ingestion; tenant_buying_research is subscriber-specific and is not the global evidence destination. Existing buying-research.js is a manual tenant UI; existing tradeflow-assistant research mode only performs tenant-scoped lookup/approval and does not perform external research. Do not repurpose either for platform-wide ingestion. Public catalogue browse RPC is read-only and paginated, and must not be used as an ingestion route.

Baseline read-only counts: LIVE 28,387 active master products / 28,363 visible; TEST 28,396 / 28,371. Excluding 23,780 Pokémon products in each environment leaves 4,607 LIVE and 4,616 TEST non-Pokémon active products. Qualifying active GBP/source-URL evidence counts: LIVE 2,136 UK-new and 2,320 UK-used; TEST 2,298 UK-new and 2,532 UK-used. Category/branch parity gaps exist and must be reconciled by exact product/category/branch keys before broad automated ingestion; never bulk-copy entire catalogue or tenant/customer/transaction/domain/Stripe data. Product UUIDs differ between environments.

shared_market_evidence requires server-side trusted writes; unique key is (source_name, source_record_key). New service must keep service-role credentials off the PC, use a dedicated authenticated server-side API, write each environment independently, and verify each write. Used evidence remains reference-only and cannot alter automatic buying valuations. UK evidence GBP only; preserve exact package/model, source URL, observed_at, availability, condition and price-basis notes. Ambiguous matches go to review.

A Developer Diagnostic Roadmap was created at docs/TRADEFLOW-DEEP-SOURCE-RESEARCH-ROADMAP.md (commit b523fc661e1fa6e07531a1a46795a325108f940a). This is architecture/preflight only: no schema, RLS, Edge Function, application, valuation, tenant, customer, order, payment, Stripe, Worker or deployment changes have been made.

## Next implementation steps
1. Reconcile LIVE/TEST non-Pokémon catalogue differences by exact model/package/category/branch; do not blindly sync.
2. Inspect existing indexes, RLS and access policies for category/product/evidence tables and current Edge Function patterns.
3. Design dedicated task/lease/progress storage and an authenticated Edge Function API. Keep Supabase service-role keys server-side, never on the PC.
4. Build a Node coordinator on the current Windows PC using existing Ollama/Gemma, with two workers initially and bounded concurrency.
5. Dry-run one small non-Pokémon branch, review matches, then insert a tiny approved sample independently into TEST and LIVE and read back.
6. Expand branch by branch; update diagnostics and manuals after each material change. Do not deploy a Worker for database-only evidence imports.

No runtime or database changes have been made in this checkpoint.
