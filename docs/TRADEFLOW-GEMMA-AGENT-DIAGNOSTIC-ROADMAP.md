# TradeFlow Gemma Local Research Agent — Developer Diagnostic Roadmap

**Version:** 0.1  
**Date:** 5 November 2026  
**Status:** Foundation in feature branch; not yet installed or verified on the Research PC.

## Purpose and boundaries

Map the local TradeFlow-first Gemma workflow. This is not a copy of the code and is not the subscriber-facing AI assistant. Do not reuse the retired GearCashOut agent, its scripts, configuration or database endpoints.

## User action and entry point

1. Operator creates or edits a research task JSON file.
2. Operator runs `npm start -- tasks/example.json` from `tools/tradeflow-gemma-agent/`.
3. `src/index.mjs` reads local `.env`, loads the task file and starts a bounded worker pool.
4. Default mode is dry-run. Operator must explicitly add `--apply` after reviewing the candidate output.

Research PC installation, a Windows service/Power-shell launcher and owner-facing control panel are **not yet implemented**. Do not invent their paths or claim they are running.

## Current code map

| Responsibility | Current path | Behaviour |
|---|---|---|
| Windows launcher | `tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1` | Checks Node/npm/Ollama/model/config, runs tests, defaults to dry-run; `-Apply` is explicit |
| CLI/coordinator | `tools/tradeflow-gemma-agent/src/index.mjs` | Loads environment/task JSON; bounds worker concurrency; reports failed-closed tasks |
| Research, extraction, validation and DB adapter | `tools/tradeflow-gemma-agent/src/agent.mjs` | Brave Search → direct page fetch → Ollama/Gemma JSON extraction → deterministic checks → independent TEST/LIVE product lookup → duplicate-safe evidence write |
| Runtime/dependencies | `tools/tradeflow-gemma-agent/package.json` | Node.js 22+; no npm runtime dependencies |
| Local configuration template | `tools/tradeflow-gemma-agent/.env.example` | Ollama, Brave Search and separate Supabase TEST/LIVE keys; real `.env` is gitignored |
| Example task | `tools/tradeflow-gemma-agent/tasks/example.json` | Existing Creality K1 master, UK-new and UK-used research roles |
| Tests | `tools/tradeflow-gemma-agent/test/agent.test.mjs` | Deterministic source-key and evidence rejection checks |

## Data flow

`Task JSON → Coordinator → Brave Search API → direct UK source page → Ollama using the `OLLAMA_MODEL` tag (example default `gemma3:4b`) → structured evidence candidate → deterministic validation → exact master-product resolution in TEST and LIVE → duplicate preflight → shared_market_evidence insert`.

The source page is untrusted data. Instructions embedded in source content must never be followed. Gemma is an extractor, not an authority for inventing missing prices, condition, location, product identity or URLs.

## Verified backend contract — 5 November 2026

The following objects and columns were inspected in both TradeFlow projects:

- `catalogue_master_categories`: `id`, `name`, `slug`, `active`.
- `catalogue_master_branches`: `id`, `category_id`, `name`, `slug`, `active`.
- `catalogue_master_manufacturers`: `id`, `name`, `active`.
- `catalogue_master_products`: `id`, `category_id`, `branch_id`, `manufacturer_id`, `model`, `package_key`, `package_name`, `active`, `customer_visible`.
- `shared_market_evidence`: `master_product_id`, `evidence_type`, `source_name`, `source_url`, `observed_price`, `price_currency`, `item_condition`, `sales_channel`, `availability`, `observed_at`, `notes`, `is_active`, `source_record_key`.

Important constraints:

- Product uniqueness: `(category_id, branch_id, manufacturer_id, model, package_key)`.
- Evidence type check currently permits `uk_new`, `uk_used`, `overseas`; Gemma foundation deliberately permits only `uk_new` and `uk_used`.
- Evidence uniqueness: `(source_name, source_record_key)`.
- `shared_market_evidence.master_product_id` references `catalogue_master_products.id`.
- Direct client writes to shared catalogue products are denied by RLS; authenticated evidence policy is read-only for active rows. The local service-role credential is therefore restricted to the Research PC and must never be committed or used in browser code.

## Environment boundaries

- TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- The code checks both project hostnames and resolves category, branch, manufacturer and exact product independently in each database. UUIDs must never be copied between environments.
- TEST and LIVE must both resolve the exact product before either environment is written.
- A missing or ambiguous product causes a fail-closed task. Foundation 0.1 does not create catalogue masters.
- No Edge Function, Worker, schema migration or RLS change is required for this local evidence-only stage.

## Separate research stores

- `shared_market_evidence` is the shared master-catalogue evidence store used by this local agent.
- `tenant_buying_research` is tenant-scoped Research Centre data. It is not the master catalogue evidence target and must retain its tenant/RLS boundary.
- `platform_ai_settings.gemma_enabled` controls the platform/subscriber AI provider configuration, not local Ollama Gemma. It was false in both projects at the time of inspection and was not changed.

## Guardrails and failure points

1. **No search key:** stop; never invent source URLs.
2. **Non-UK or redirected source:** reject.
3. **Search/category URL:** reject; require direct product/listing page.
4. **Price not visible as GBP on the page:** reject.
5. **Wrong evidence type/condition:** reject. Opened-never-used and sealed are not used evidence.
6. **Manufacturer/model tokens absent from page:** reject.
7. **Category/branch/manufacturer/product missing or ambiguous in either DB:** fail closed; no write.
8. **Duplicate source key:** skip existing row.
9. **One side insert fails after the other succeeds:** retry is idempotent through duplicate preflight; inspect both DBs before manual repair.
10. **UK-used evidence:** reference-only; do not connect it to automatic valuation.

## Known fix history and exclusions

- Old GearCashOut/Action Buyer code is not a source of truth and is not imported.
- Do not toggle `platform_ai_settings` to make local Gemma run.
- Do not create an Edge Function or Cloudflare Worker for this local workload.
- Do not create product masters in 0.1; that is a later, separately verified increment.
- No database or application-code deployment has been performed.

## Next safe actions

1. Install the feature-branch folder on the Research PC and confirm Node/Ollama model availability.
2. Configure local `.env` with a search key and separate TEST/LIVE service-role credentials; do not send credentials in chat.
3. Run tests on the Research PC.
4. Run the example task in dry-run mode and inspect every source/candidate.
5. Test duplicate handling and mirrored write behaviour on one preselected exact product before enabling larger batches.
6. Build the next increment for safe manufacturer/product creation and package-variant reconciliation.
7. Only after successful Research PC tests, merge feature branch to `main` and follow the existing TEST → verified release → `production` → LIVE process.


## Central review queue handoff — 5 November 2026

- Gemma evidence worker entry: `tools/tradeflow-gemma-agent/src/agent.mjs` → `enqueueCandidate(...)`.
- Coordinator/CLI: `tools/tradeflow-gemma-agent/src/index.mjs`; dry-run is default and `--enqueue` is the only write mode. `--apply` is retired and fails closed.
- Queue control plane: TEST Supabase `public.platform_catalogue_research_queue`; RLS enabled, direct anon/authenticated table access revoked. Owner RPCs: `platform_owner_list_catalogue_research_queue(text,integer)` and `platform_owner_review_catalogue_research_item(uuid,text,text)`.
- Gemma resolves exact product rows independently in TEST and LIVE before enqueueing one queue record into TEST. The queue stores both UUIDs but does not modify either catalogue.
- ChatGPT review is interactive through the existing conversation and connected Supabase tools; no separate API chatbot or autonomous ChatGPT background worker is assumed.
- Importer is not yet implemented. Do not manually treat `approved` as imported. Import must preflight both environments, write idempotently and verify exact parity.
- TEST queue migration applied; LIVE migration not applied. Research PC runtime/tests and scheduled execution remain pending.


## ReleaseMonitor specialist — 5 November 2026

- Entry point: `tools/tradeflow-gemma-agent/src/release-monitor.mjs`.
- Watchlist: `tools/tradeflow-gemma-agent/tasks/release-watchlist.json`.
- Commands: `npm run release-monitor` (dry-run); `npm run release-monitor:enqueue` (writes only release-candidate rows to TEST review queue).
- Discovery: Brave Search API, constrained to each watchlist official domain. Source fetch follows redirects only when final URL remains on the official domain.
- Extraction: local Ollama configured by `OLLAMA_MODEL`; candidate states restricted to announced/preorder/released/available/update. Rumours are excluded.
- Catalogue parity: exact manufacturer/model lookup is independently executed in TEST and LIVE. Missing on both -> pending review; present in one only -> needs_research; exact product already in both -> review as release/update note, never auto-create.
- No product master creation, lifecycle-field updates, UK price evidence capture or Task Scheduler install in this increment. Tests authored; Research PC runtime execution remains pending.


## Importer source path

`tools/tradeflow-gemma-agent/src/import-approved.mjs` reads approved evidence candidates from TEST, resolves exact product IDs separately in both environments, checks duplicate keys and inserts missing evidence. Command: `npm run import-approved`. Runtime verification remains pending.


## Approved evidence importer — 5 November 2026

`tools/tradeflow-gemma-agent/src/import-approved.mjs` is invoked with `npm run import-approved`. It reads only approved evidence candidates from TEST, independently resolves exact products in TEST/LIVE, preflights all candidates and source-key duplicates before writes, inserts missing evidence and marks the queue item imported only after both sides verify. UK source/HTTPS and GBP are revalidated. No runtime execution on Research PC has been verified.


## Agent Control Centre telemetry — 5 November 2026

- Dashboard entry: `platform-owner-dashboard.html#agent-control-centre`; JS: `platform-owner-dashboard.js`; CSS: `platform-owner-dashboard.css`.
- Read path: authenticated owner session -> `POST /rest/v1/rpc/platform_owner_get_ai_agent_control_centre` -> agent status/activity tables.
- Write path: Research PC worker -> service-role `POST /rest/v1/rpc/platform_ai_agent_report_event` -> status upsert + append-only activity event.
- Tables in both TEST and LIVE: `platform_ai_agent_status`, `platform_ai_agent_activity`. RLS enabled; anon/authenticated table grants revoked. Owner RPC checks active `platform_memberships`; telemetry RPC requires `auth.role()='service_role'`.
- Refresh: manual button and 30-second dashboard polling. Running status older than five minutes is labelled heartbeat overdue.
- Current seeded roster: mobile phones, gaming consoles, 3D printers, drones, cameras, metal detectors, laptops, release monitor, catalogue importer. Initial status is Not started until worker telemetry arrives.
- Worker integration: Gemma task runner reports task start/progress/completion/failure; release monitor and approved evidence importer report lifecycle events. No Research PC execution or scheduler is verified yet.


## Approved product-master import diagnostic path — 5 November 2026

- Owner review: TEST `platform_catalogue_research_queue` → `record_type=product_candidate`, `status=approved`.
- Local entry point: `tools/tradeflow-gemma-agent/src/import-approved-products.mjs`; package command `npm run import-approved-products`.
- Credentials: Research PC local `.env`; separate TEST/LIVE `TRADEFLOW_*_URL` and `TRADEFLOW_*_SERVICE_ROLE_KEY`; project hostnames are pinned in code. Never expose service-role keys to browser code or commit `.env`.
- Source validation: HTTPS and official manufacturer domain allowlist; exact model must appear in source excerpt; accepted lifecycle states are announced/preorder/released/available. Rumoured/discontinued/replaced/update candidates are not auto-created by this importer.
- TEST and LIVE lookup chain: active `catalogue_master_categories.slug` → active `catalogue_master_manufacturers.name` → optional active `catalogue_master_branches(category_id,slug)` → `catalogue_master_products(category_id,branch_id,manufacturer_id,model,package_key)`.
- Failure points: missing/ambiguous category, manufacturer or branch; duplicate product identity (including NULL branch); inactive product; package-name conflict; invalid source/status/excerpt; failed insert or failed post-write verification. Fail closed.
- Write path: create missing product independently in each environment; preserve environment-specific UUIDs; set `customer_visible=false`; verify exact model/package and active state in each environment; only then update TEST queue status to imported and save both product IDs.
- Verification state: committed on feature branch only. Research PC tests, controlled single-candidate import and post-import database parity check remain outstanding. No TEST/LIVE product writes or deployment have occurred.


## Free local search provider — 5 November 2026

Brave Search API is no longer a dependency of TradeFlow Gemma. The evidence research worker in `tools/tradeflow-gemma-agent/src/agent.mjs` and the official release monitor in `src/release-monitor.mjs` now query a local SearXNG JSON endpoint configured by `SEARXNG_BASE_URL` (default `http://127.0.0.1:8080`). The Research PC package includes `docker-compose.yml` and `searxng/settings.yml`; Docker binds the search service to loopback only. `.env.example` no longer contains `BRAVE_SEARCH_API_KEY`. No paid search API, subscription or card is required by the agent. SearXNG is free software, but upstream search engines can rate-limit or block automated traffic; do not describe this as unlimited guaranteed search capacity. Worker failure remains fail-closed when SearXNG is unavailable. The PowerShell launcher now checks the local JSON endpoint before research starts.

Verification at this checkpoint: GitHub feature-branch code and test fixtures updated. The Research PC has not yet downloaded these changes, Docker Desktop/SearXNG have not yet been installed or started, and the new runtime tests have not yet been executed locally. No Supabase data, schema, queues, product/evidence rows, tenant data, Stripe settings, Workers or deployments were changed. Production and TEST application branches remain untouched.
