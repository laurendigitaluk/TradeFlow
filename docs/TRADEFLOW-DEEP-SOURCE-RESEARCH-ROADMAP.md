# TradeFlow Deep Source Research — Developer Diagnostic Roadmap
Date: 5 November 2026
Status: Architecture and preflight established; implementation not yet deployed.

## Goal
Build a dedicated, local-PC-operated TradeFlow research service using the existing Ollama/Gemma 3:4B installation. Cover all active master catalogue categories, branches and products except Pokémon Trading Cards. Search every branch explicitly; do not treat a parent-category search as completion of its branches. Research UK GBP new and used market evidence with exact model/package matching, source URLs, observed dates, availability and condition/price-basis notes. Used evidence remains reference-only and must not become an automatic buying valuation input.

## Current verified components
- Research PC: Windows PC; Ollama responds at http://127.0.0.1:11434/ and /api/tags/ returns the installed model gemma3:4b. Gemma Desktop web UI at 127.0.0.1 is currently unavailable; it is not required for the new service.
- Current old GearCashOut launcher is not the target architecture. Do not depend on its supervisor, config, queue, or old local folder. Do not delete old files as part of this build until the new service is independently running.
- LIVE Supabase project: gxsrajtqzdjvmceqcpgv. TEST: nnsshnfkjcflucjrftzi. Environments and tenant/customer/website/domain/Stripe/transaction data remain separate.
- Master catalogue tables: catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers, catalogue_master_products, catalogue_master_product_identifiers, catalogue_master_product_package_aliases.
- Platform evidence table: shared_market_evidence. Columns include master_product_id, evidence_type (uk_new/uk_used/overseas), source_name, source_url, observed_price, price_currency, item_condition, sales_channel, availability, observed_at, notes, is_active, source_record_key. Unique key is (source_name, source_record_key). Writes must be trusted server-side ingestion only.
- Subscriber research is a separate table, tenant_buying_research. Do not use it as the platform master evidence destination.
- Existing buying-research.html/js is a manual subscriber-facing tenant research UI. It retrieves one tenant's categories/branches/products and writes tenant_buying_research. It is not a global catalogue research worker and must not be repurposed to write shared evidence.
- Existing tradeflow-assistant Edge Function research mode only looks up/approves tenant_buying_products and tenant_buying_research. It explicitly does not perform external research. Do not overload it with platform ingestion.
- Existing public catalogue browser RPC is read-only and paginated; it intentionally excludes evidence, IDs, tenant data and buying rules. Do not repurpose it for research ingestion.

## Catalogue hierarchy and branch traversal
Current schema is category -> branch -> product (catalogue_master_categories -> catalogue_master_branches -> catalogue_master_products.category_id/branch_id). There is no parent_id hierarchy on these two tables. The coordinator must enumerate all active categories, then all active branches for each category, then fetch active products by exact category_id + branch_id in bounded pages. Also handle products with a null branch_id explicitly in a separate per-category pass. Persist branch completion and cursor state in the research task store when that store is implemented. Do not mark a category complete until all its branches and unbranched products have been handled. Exclude category slug pokemon-trading-cards from task generation and enforce a second exclusion by category ID/slug in the trusted ingestion endpoint.

## Baseline captured 5 November 2026
- LIVE active master products 28,387; visible 28,363.
- TEST active master products 28,396; visible 28,371.
- LIVE qualifying active GBP/source-URL evidence: 2,136 UK-new and 2,320 UK-used.
- TEST qualifying active GBP/source-URL evidence: 2,298 UK-new and 2,532 UK-used.
- Pokémon Trading Cards category has 23,780 active products in each environment and is excluded from all research.
- Non-Pokémon product totals are therefore LIVE 4,607 and TEST 4,616. These are not aligned; investigate exact product/category/branch differences before attempting broad automated research writes.
- Observed category-level parity gaps include LIVE Drone Accessories branch count 5 vs TEST 6, and TEST has a Laptops category with 8 products not present in LIVE at the time of this preflight. Mobile Phones showed LIVE 158 vs TEST 159. Do not sync whole catalogue or blindly copy TEST records to LIVE. Reconcile only approved catalogue master differences with exact product keys and separate environment IDs.

## Architecture to implement
1. Local TradeFlow coordinator on the existing Windows PC. It communicates with a dedicated authenticated server-side research API; it must not hold Supabase service-role credentials locally.
2. One Ollama/Gemma service shared by workers. Start with two concurrent workers; make concurrency configurable and increase only after memory/network stability tests.
3. Task allocator generates bounded work units by category_id + branch_id + evidence gap. No full catalogue download per worker or per poll.
4. Query API returns only one branch's product page (bounded page size) and the evidence summary needed for those exact product IDs/types. Use stable pagination/cursors and server-side grouped counts; do not repeatedly download historical evidence rows.
5. Source adapters search exact products and package variants. Use MPB dynamic SKU inventory only when product match is exact; retailer and marketplace adapters must preserve source, URL, price basis, condition, availability and observed_at.
6. Candidate validation: UK only, GBP only for UK evidence, valid source URL, exact master product/package match, non-negative price, observed date, evidence type, source key. Ambiguous matches go to review and are never auto-attached.
7. Trusted server-side writer inserts only into shared_market_evidence with ON CONFLICT (source_name, source_record_key) DO NOTHING. Write and verify each environment independently; product UUIDs are environment-specific. No cross-environment blind UUID reuse.
8. Idempotent tasks, lease/heartbeat, bounded retries/backoff, source rate limits, failure quarantine and resumable branch cursor.
9. Dashboard/logs report category/branch progress, product counts, evidence gaps, candidate/review/rejected counts, source errors and separate LIVE/TEST write verification.
10. Research is database-only; no Worker deployment is needed for evidence rows. Do not modify valuation logic, lifecycle flags, app behaviour, RLS, Stripe, tenants, customers, orders, payments or domains unless separately authorised.

## Acceptance tests before production operation
- Category and branch enumeration totals reconcile to bounded product queries in each environment.
- Every active non-Pokémon branch is represented as a task; null-branch products are represented too.
- No Pokémon product can be requested or written.
- Each worker retrieves only its assigned branch page and evidence summaries for those product IDs.
- Two workers can run concurrently without duplicate task leases or duplicate evidence writes.
- Restarting coordinator resumes from last committed branch cursor.
- A source 403/timeout is isolated to that source and does not stop other workers.
- Candidate product/package mismatches are rejected or queued for review.
- Same candidate maps independently to exact product IDs in LIVE and TEST; each write is read back.
- Used evidence cannot enter the automatic valuation input path.
- No deployment occurs as part of database-only research.

## Implementation sequence
A. Finish preflight reconciliation of LIVE/TEST non-Pokémon master catalogue and inspect existing RPCs/indexes/RLS.
B. Add dedicated research task/progress storage and narrowly scoped authenticated Edge Function API using migrations, with no public/anon access and no service-role key on PC.
C. Build local Node coordinator and worker modules in a dedicated repository folder; use pinned dependencies and lockfile.
D. Run dry-run against one small non-Pokémon branch; inspect candidates without writing.
E. Write a tiny approved sample to TEST and LIVE independently; verify.
F. Increase to two workers and then tune concurrency.
G. Expand across all non-Pokémon categories and branches.
H. Update operator instructions and diagnostic roadmap; only then retire old GearCashOut startup shortcut if the user chooses.

## Known constraints / avoid repeating faults
- Old GearCashOut worker previously hit ECONNRESET; old source monitor got autopilot.co.uk HTTP 403. Treat source failures as isolated and use retries/backoff; do not assume model failure.
- Old Gemma Desktop UI is not required. Ollama model endpoint is healthy.
- Do not restart/reinstall Ollama because the model is available.
- Do not use broad full-catalogue reads repeatedly; use branch-scoped bounded queries and aggregated evidence summaries.
- Do not confuse tenant_buying_research with shared_market_evidence.
- Do not infer additional nested levels from names. Current master schema explicitly exposes categories and branches; inspect any other website taxonomy source separately if it adds further levels.
