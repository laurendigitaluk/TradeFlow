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

## Windows Gemma Research Control Centre — Developer Diagnostic Roadmap (9 November 2026)

### User action and local entry points
- Owner opens `TradeFlow-Research-Control-Centre.ps1` or one of the generated `Gemma - <specialist>.lnk` shortcuts.
- UI writes only local `%LOCALAPPDATA%\TradeFlow\ResearchControlCentre\config.json`.
- `Run-TradeFlow-Gemma-Supervisor.ps1` is launched by Windows Task Scheduler at user sign-in.
- Supervisor reads `service.json` (existing Gemma install path and private .env path), starts the existing `src\task-worker.mjs`, and restarts unexpected exits with a delay.
- Worker receives `TRADEFLOW_GEMMA_AGENT_CONFIG`, `TRADEFLOW_GEMMA_ENV_FILE`, and `TRADEFLOW_GEMMA_ENVIRONMENT=LIVE`. It writes non-secret `status.json` for the UI and stdout/stderr logs under the app's `logs\` directory.

### Task and data flow
1. Website/owner dashboard queues work through `platform_owner_enqueue_ai_agent_task` into LIVE `platform_ai_agent_tasks`.
2. Desktop worker reads enabled canonical specialist keys from local config.
3. It calls `platform_ai_agent_claim_task_for_agents` with its worker ID and enabled key set.
4. SQL checks every subtask in `payload.tasks`, resolves the effective agent identity (including the legacy 3D identity rule), and claims only tasks whose subtasks all belong to enabled agents.
5. Existing `task-worker.mjs` and `agent.mjs` execute the task; category-specific approved UK sources are loaded from `platform_research_sources`.
6. Raw product-page captures continue through the existing `platform_catalogue_research_queue` review flow. ChatGPT/owner approval remains required before any catalogue/evidence import.

### Relevant code and database surfaces
- Desktop UI: `tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1`
- Supervisor: `tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1`
- Installer: `tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1`
- Specialist roster: `tools/tradeflow-gemma-desktop/agents.json`
- Local policy helpers: `tools/tradeflow-gemma-agent/src/desktop-control.mjs`
- Queue worker: `tools/tradeflow-gemma-agent/src/task-worker.mjs`
- Website routes: `tools/tradeflow-gemma-agent/src/source-playbooks.mjs`
- Existing worker identity: `src/agent-identity.mjs`
- LIVE queue table: `public.platform_ai_agent_tasks`
- LIVE status/activity: `public.platform_ai_agent_status`, `public.platform_ai_agent_activity`
- LIVE website registry: `public.platform_research_sources`
- LIVE review destination: `public.platform_catalogue_research_queue`
- New migration in PR #325: `supabase/migrations/20261109150000_gemma_agent_scoped_task_claim.sql`
- Existing owner dashboard website controls: `platform-owner-dashboard.js` and `platform_owner_list_research_sources`, `platform_owner_add_research_source`, `platform_owner_set_research_source_category`.

### Known constraints and failure points
- Desktop mode must never fall back to `platform_ai_agent_claim_task`; missing scoped RPC means `requires_migration` and stop.
- One shared Node/Ollama execution lane is intentional; do not spawn one Node worker per category or increase parallelism without memory/runtime tests.
- Mixed-agent queue payloads remain queued until every subtask's specialist is enabled.
- Disabling a specialist during a running task is applied before the next queue claim; do not kill a task mid-flight.
- The `.env` is private and stays in its original path. Never store service-role key values in desktop config or status.
- Existing manual workers must be stopped cleanly before desktop install. Installer refuses to overwrite a process that is already running.
- Preserve 3D-printer extraction/capture behaviour and Gaming capture-only behaviour; neither is modified by this feature.
- `catalogue-importer` remains approval-gated. `release-monitor` is not yet compatible with this catalogue queue worker.

### Acceptance gates
1. CI passes Node tests and PowerShell parser checks for the desktop scripts.
2. Review and merge PR #325; apply the new RPC migration to LIVE only after owner approval.
3. On the Research PC, run the installer in the existing Gemma folder; verify it preserves the .env, creates seven specialist shortcuts, and registers the sign-in task.
4. Confirm one worker process only and that status shows all enabled specialists waiting without active research tasks.
5. Submit one bounded TEST task per representative specialist only after the installation is fingerprinted; verify disabled specialist tasks remain queued and enabled tasks are claimed only when enabled.
6. Run one controlled LIVE acceptance task only after TEST and source-route acceptance. Confirm raw captures appear in review queue; no automatic approval/import.


## Post-merge rollout state — 9 November 2026

- PR #325 merged to production: `b20123fd8f832388011589ac8e7f9e602bb98f08`.
- Production CI run #473 passed all Gemma checks: PowerShell/Node syntax, 92 tests with zero failures, Owner Dashboard JavaScript syntax.
- LIVE RPC `platform_ai_agent_claim_task_for_agents(text,text[],integer)` exists. Permission audit: service_role can execute; authenticated cannot; SECURITY DEFINER enabled.
- TEST does not contain the scoped RPC and remains separate.
- Installer is available at `tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1` on production.
- Research PC installation has not happened. No local worker restart, stop, task dispatch or evidence capture was performed as part of this deployment verification.

### Next operator action

On the Research PC, open PowerShell in the existing Gemma folder containing `src\task-worker.mjs`, download and run the production installer using the command in `tools/tradeflow-gemma-desktop/README.md`. Stop any active old worker cleanly with Ctrl+C before running it. Reuse the existing private .env path; never copy or disclose its contents.

After installation, verify the single background supervisor and seven switches. All seven are enabled by default and wait for matching website-originated work. Desktop icons enable the corresponding specialist and open the Control Centre. Then run one bounded LIVE review-only acceptance task and verify raw capture in `platform_catalogue_research_queue`; no automatic approval/import. Do not use TEST for this desktop service.

 
### Live worker snapshot before Research PC installation — 11:57 UTC
The LIVE `platform_ai_agent_status` and activity records show one generic TradeFlow Gemma task worker connected and idle, polling every 15 seconds. The queue currently contains 24 completed tasks and no queued/running tasks. This is the existing legacy worker, not the new desktop supervisor. The installer will refuse to overwrite it while active. When installing on the Research PC, stop the existing worker cleanly with Ctrl+C first; do not terminate an active task or force-kill the process.
