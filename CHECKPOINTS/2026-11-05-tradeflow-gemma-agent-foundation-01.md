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
