# TradeFlow Gemma Local Research Agent — Foundation 0.1

**Date:** 5 November 2026  
**Branch:** `feature/tradeflow-gemma-agent-foundation-20261105`  
**Status:** Code foundation committed to feature branch; Research PC installation and runtime verification outstanding.

## Goal

Build a new TradeFlow-first Gemma catalogue research agent. Do not revive the old GearCashOut agent or investigate its obsolete code as part of this work.

## Preflight completed

- Read current TradeFlow AI Operating Manual, System Handbook and Master Roadmap.
- Confirmed permanent branch roles: `main` is TEST/staging code; `production` is LIVE release code.
- Confirmed Supabase TEST `nnsshnfkjcflucjrftzi` and LIVE `gxsrajtqzdjvmceqcpgv` are the distinct TradeFlow projects.
- Inspected both environments' master category, branch, manufacturer, product and shared evidence schemas.
- Confirmed product uniqueness on category/branch/manufacturer/model/package key.
- Confirmed shared evidence uniqueness on source name/source record key.
- Confirmed direct authenticated client writes to the shared catalogue are denied/read-only; local service-role access is required for writes.
- Confirmed `shared_market_evidence` is the master-catalogue evidence table. `tenant_buying_research` is a separate tenant-scoped Research Centre table.
- Confirmed `platform_ai_settings.gemma_enabled=false` and `active_provider=none` in TEST. This setting belongs to the subscriber/platform assistant and was not changed.

## Foundation created

`tools/tradeflow-gemma-agent/` contains:

- Node.js 22+ ESM CLI and bounded task coordinator.
- Dedicated PowerShell launcher `tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1` with explicit `-Apply` switch; PowerShell runtime verification remains outstanding.
- Ollama extraction client; `.env.example` defaults to `gemma3:4b`, but `OLLAMA_MODEL` is configurable and the installed model tag is not yet verified on the Research PC.
- Brave Search discovery adapter.
- Direct-page fetch and deterministic UK/GBP/product/condition/price validation.
- Separate UK-new and UK-used research task roles.
- Independent exact-product resolution in TEST and LIVE.
- Duplicate preflight against `(source_name, source_record_key)`.
- Dry-run default; explicit `--apply` for evidence writes.
- Separate environment service-role configuration; `.env` is gitignored.
- Example Creality K1 task and five deterministic validation tests.

The first stage only writes evidence for a product already present uniquely in both databases. It does not create categories, branches, manufacturers or products. UK-used remains reference-only and is not connected to valuation.

## Verification

- Local committed-code tests: 6 passed, 0 failed, including exact GBP price-token matching.
- Current Supabase inspection was read-only.
- No database rows changed.
- No schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment, ownership or Worker changes.
- No Research PC runtime test or real Supabase write has been performed.
- No merge to `main` or deployment to LIVE.

## Next safe action

Install the feature branch on the Research PC, configure local secrets without sharing them, verify Ollama and Brave Search connectivity, run tests and execute the example task in dry-run mode. Review all candidates before any `--apply`. Then build controlled new-product creation as the next increment.


## Review-gated update — 5 November 2026

Gemma evidence submissions are now staged for review rather than inserted directly. `agent.mjs` resolves the exact product in both environments and writes one candidate to the TEST-only `platform_catalogue_research_queue`. The CLI now supports `--enqueue`; `--apply` is rejected. The queue table has RLS enabled, direct client access revoked, and owner-only list/review RPCs. TEST migration was applied and the RLS flag was verified. LIVE queue migration remains pending. No product or evidence rows were imported.

The test and LIVE Platform Owner dashboard feature branches remove the subscriber-supplied AI provider option while preserving the TradeFlow Assistant and all subscriber records. Current database values already show `active_provider='none'` and `subscriber_provider_enabled=false` in both projects. The enforcement migration is not yet applied.

Correction to prior foundation note: the six test cases are authored, but execution in the Research PC runtime has not been verified in this environment. Do not report them as runtime-passed until `npm test` is run on the configured Research PC.


## Release monitoring increment — 5 November 2026

Added a central manufacturer watchlist and a separate ReleaseMonitor worker. The worker only considers official manufacturer domains and confirmed release states, excludes rumours, and independently checks exact model presence in TEST and LIVE. It stages release candidates in the TEST review queue. TEST-only review queue remains isolated from LIVE; no master products, evidence or tenant data were changed. Package commands and release-monitor tests were added. Research PC execution, scheduling, and approved product importer remain outstanding.


## Approved importer

Added `tools/tradeflow-gemma-agent/src/import-approved.mjs` and `npm run import-approved`. It imports approved evidence only, with full TEST/LIVE preflight and idempotent source-key checks. It has not been run on the Research PC; no evidence was imported in this change.


## Approved importer hardening — 5 November 2026

Added `src/import-approved.mjs` and `npm run import-approved`. The importer reads only owner-approved evidence candidates, revalidates HTTPS UK source eligibility and GBP currency, preflights all candidates against both databases, independently resolves exact product/package UUIDs, checks duplicate source keys and marks queue rows imported only after both evidence writes verify. The importer has not been run on the Research PC. No catalogue evidence rows were added.


## Agent Control Centre increment — 5 November 2026

Added agent status and activity telemetry tables and owner/service-role RPCs to both TEST and LIVE. Seeded nine named specialist agents. Added `agent-telemetry.mjs`; Gemma task runner reports task lifecycle and source progress to both environments. ReleaseMonitor and approved evidence importer also report activity. Added Agent Control Centre panel, sidebar link, cards, activity table and 30-second refresh to the corresponding LIVE and TEST dashboard feature branches. The dashboard code is not deployed. Both environments currently show nine registered agents and zero activity events; no worker heartbeat has been received. Research PC runtime and scheduling remain outstanding.


## Approved product-master importer increment — 5 November 2026

Committed to `feature/tradeflow-gemma-agent-foundation-20261105`:
- Added `tools/tradeflow-gemma-agent/src/import-approved-products.mjs`.
- Added package script `npm run import-approved-products`.
- Documented operation and limitations in the agent README.
- Import reads only approved `product_candidate` rows from the TEST owner queue.
- Requires confirmed release status, official manufacturer HTTPS source and exact model in source excerpt.
- Resolves category/manufacturer/optional branch/product independently in TEST and LIVE; fails closed on ambiguity, duplicate identity, inactive product or package conflict.
- Creates missing master rows separately with independent UUIDs and `customer_visible=false`; verifies both environments before marking the TEST queue row imported.
- No runtime tests, Research PC execution, Supabase writes, branch merge or deployment have occurred. Production and TEST application branches remain unchanged. Next: run `npm test` on Research PC, inspect source schema assumptions, then test one owner-approved candidate with a controlled pre/post DB comparison before larger batches.


## GBP price-validation fix — 5 November 2026

Updated `tools/tradeflow-gemma-agent/src/agent.mjs` on the Gemma foundation feature branch so the pound sign is generated with `String.fromCharCode(163)` instead of a literal source character. This addresses Windows text-encoding/mojibake risk without relaxing exact price matching. Commit: `88b00bb64b371f798d8eb2487a9995d4e0c63532`. Research PC `npm test` is still required; no database writes, imports, merges or deployments occurred.


## Research PC launcher correction — 5 November 2026

Fixed `Start-TradeFlow-Gemma.ps1` on the Gemma foundation feature branch. It now exposes safe dry-run by default and `-Enqueue` for TEST review-queue staging; it no longer offers the retired `--Apply` flag that would pass a rejected `--apply` argument. Preflight checks local `.env` presence, required settings, fixed TEST/LIVE project hostnames, Ollama/model availability and `npm test` before the worker starts. This script change has not yet been executed on the Research PC. No catalogue/queue import or deployment occurred.


## Free local search provider — 5 November 2026

Brave Search API is no longer a dependency of TradeFlow Gemma. The evidence research worker in `tools/tradeflow-gemma-agent/src/agent.mjs` and the official release monitor in `src/release-monitor.mjs` now query a local SearXNG JSON endpoint configured by `SEARXNG_BASE_URL` (default `http://127.0.0.1:8080`). The Research PC package includes `docker-compose.yml` and `searxng/settings.yml`; Docker binds the search service to loopback only. `.env.example` no longer contains `BRAVE_SEARCH_API_KEY`. No paid search API, subscription or card is required by the agent. SearXNG is free software, but upstream search engines can rate-limit or block automated traffic; do not describe this as unlimited guaranteed search capacity. Worker failure remains fail-closed when SearXNG is unavailable. The PowerShell launcher now checks the local JSON endpoint before research starts.

Verification at this checkpoint: GitHub feature-branch code and test fixtures updated. The Research PC has not yet downloaded these changes, Docker Desktop/SearXNG have not yet been installed or started, and the new runtime tests have not yet been executed locally. No Supabase data, schema, queues, product/evidence rows, tenant data, Stripe settings, Workers or deployments were changed. Production and TEST application branches remain untouched.


## External Research PC secrets configuration — 5 November 2026

Preserve the existing separate GearCashOut configuration folder. The Gemma PowerShell launcher and Node entry point now read the existing secrets file at `C:\\GearCashOut-Config\\.env` by default; an alternate path can be supplied through `TRADEFLOW_GEMMA_ENV_FILE`. Do not create a new `.env` inside the downloaded repository, copy `.env.example` over the existing secrets file, or move/rename the GearCashOut config folder. The launcher validates required TradeFlow TEST/LIVE setting names and project hostnames without printing secret values. SearXNG uses its built-in local default unless `SEARXNG_BASE_URL` is already configured. Changes are committed on the Gemma feature branch only; no PC config, Supabase data or deployment has been changed.


## Gemma Research PC extraction performance correction — 5 November 2026

Research PC runtime diagnosis confirmed that local SearXNG and direct manufacturer-page retrieval work: the tested Creality UK page returned HTTP 200 and 5,807 characters of extracted text in approximately 1.25 seconds. A direct Ollama chat request using the installed `gemma3:4b` model did not complete within a 60-second diagnostic window. The installed model was visible in `ollama ps` with a 4,096-token context. The earlier agent implementation used the generic 30-second HTTP helper for Ollama extraction and allowed two research workers to issue model calls concurrently; this was too restrictive for the Research PC runtime.

Correction committed to the Gemma feature branch:
- Ollama extraction now uses its own configurable timeout: `OLLAMA_TIMEOUT_MS`, default 180,000 ms and bounded to 60,000–300,000 ms.
- Ollama requests are serialized through a process-local queue to avoid competing Gemma 3 4B inference requests from concurrent research workers.
- Requests keep the model loaded for 10 minutes, use deterministic temperature 0, cap output at 256 tokens, and explicitly use the installed 4,096-token context.
- Direct-page text supplied to the model is capped at 10,000 characters to reduce context overflow risk.
- SearXNG request timeout, page-fetch timeout, Supabase request timeout, evidence validation, UK/GBP rules, exact TEST/LIVE product matching and review-queue boundary are unchanged.
- Timeout errors now identify the Ollama extraction stage and configured duration.

Runtime evidence before correction: two dry runs completed with zero verified candidates and no queue writes. The TEST research queue remained at zero rows; LIVE has no research queue table and was not written. No catalogue/evidence, tenant, customer, payment, Stripe, schema, RLS, RPC, Edge Function, Worker or deployment changes were made.

Commit: `64e78d95f3f114ec73c4f9eee6b2b71abd3fe85b`.
Status: source and documentation updated on the feature branch; Research PC download and one post-fix validation run remain outstanding. Do not use `-Enqueue` until a dry run returns valid, reviewable evidence candidates.


## Persistent ChatGPT-controlled Gemma task service — 5 November 2026

The previous GearCashOut Research PC operating pattern was recovered from prior project history: Windows logon startup shortcut → supervisor → local worker → Ollama/Gemma → 15-second polling → automatic worker restart. The old GearCashOut agent/configuration is preserved and is not modified. TradeFlow now implements the equivalent as a separate agent service.

### Implemented on the feature branch
- TEST-only control-plane table: `public.platform_ai_agent_tasks`; no task queue table is added to LIVE.
- Task states: queued, running, completed, failed, cancelled. Claims use row locking with `FOR UPDATE SKIP LOCKED`, worker identity, lease expiry, attempt count and retry after abandoned leases.
- Service-role-only RPCs: `platform_ai_agent_claim_task`, `platform_ai_agent_heartbeat_task`, `platform_ai_agent_complete_task`, `platform_ai_agent_fail_task`. Direct anon/authenticated table access is revoked and RLS is enabled.
- Local worker: `tools/tradeflow-gemma-agent/src/task-worker.mjs`; polls TEST every 15 seconds, claims one task at a time, renews its lease, runs the existing verified research pipeline, stages evidence candidates in the TEST owner-review queue and reports task progress to TEST and LIVE telemetry.
- Windows supervisor: `Start-TradeFlow-Gemma-Service.ps1`; restarts the Node worker after an exit. Installer: `Install-TradeFlow-Gemma-Service.ps1`; registers a per-user Windows logon scheduled task and starts it.
- Worker reads the new TradeFlow local `.env` in its own agent folder by default or `TRADEFLOW_GEMMA_ENV_FILE`; it does not read, overwrite or modify `C:\\GearCashOut-Config\\.env`.
- No task can directly write master catalogue products or evidence. The existing owner-review queue and separate approved importers remain the approval boundary.

### Backend verification
Migration `20261105210000_platform_ai_agent_task_queue.sql` applied successfully to TEST project `nnsshnfkjcflucjrftzi`. Verified `public.platform_ai_agent_tasks` exists and contains zero tasks immediately after migration. RPC execute privileges are granted to service_role; anon/authenticated grants are revoked. LIVE schema and catalogue data were not changed.

### Current state / remaining installation
Source and migration are committed on `feature/tradeflow-gemma-agent-foundation-20261105`. The Research PC has not yet downloaded the new worker/supervisor files or registered the Windows scheduled task. One final user-side installation is required because ChatGPT cannot install software or create Windows scheduled tasks on the local PC. After installation, task assignment and progress/results can be handled through the connected TEST Supabase control plane without repeated PowerShell commands.

### Operating boundaries
- ChatGPT submits a task to the TEST control-plane queue; it does not connect directly to the PC or expose service-role credentials.
- The PC polls TEST and runs local Ollama + SearXNG; evidence candidates are staged for owner review only.
- TEST and LIVE product identity is independently resolved by the existing research pipeline; product/evidence imports remain separate and approved.
- Worker leases expire after 10 minutes and are renewed every 45 seconds while processing. Poll interval defaults to 15 seconds.
- Do not merge/deploy to production or apply task-control schema to LIVE as part of this setup step.

## Configuration-path consistency repair — 5 November 2026

The interactive PowerShell launcher and Node research entry point previously defaulted to `C:\\GearCashOut-Config\\.env`, while the persistent supervisor and task worker defaulted to the TradeFlow agent folder `.env`. This split could make interactive runs fail credential preflight even when the TradeFlow service configuration was correct, and risked confusing the retired GearCashOut configuration with the new TradeFlow agent.

Corrected on `feature/tradeflow-gemma-agent-foundation-20261105`: `Start-TradeFlow-Gemma.ps1` now reads only `tools/tradeflow-gemma-agent/.env` and explicitly passes that path to Node; `src/index.mjs` defaults to the same local file. The supervisor and task worker already used this location. README setup instructions now describe one isolated TradeFlow configuration. The old GearCashOut `.env` is not read, copied, moved or modified. No credentials, queue rows, catalogue/evidence records, TEST/LIVE schema, or deployments were changed.

Verification still required on Research PC: refresh the three changed files from this branch, ensure TradeFlow `.env` contains the four project-specific TEST/LIVE settings and correct installed Ollama model tag without exposing secrets, run tests and dry-run. Do not install the scheduled service until the interactive dry-run succeeds.
