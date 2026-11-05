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
- Ollama `gemma3:4b` extraction client.
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
