# Project Memory — TradeFlow Gemma Foundation 0.1 — 5 November 2026

TradeFlow Gemma is being rebuilt as a separate local TradeFlow-first research agent, not by reviving the retired GearCashOut local agent.

Selected runtime: Node.js 22+ and Ollama on the Research PC. The sample `.env` defaults to `gemma3:4b`, but `OLLAMA_MODEL` is configurable; the installed tag has not yet been verified. Initial architecture: task coordinator with bounded concurrency; distinct UK-new and UK-used research roles; Brave Search source discovery; Gemma structured extraction from direct source pages; deterministic validation; independent product lookup in TEST and LIVE; duplicate-safe mirrored inserts into `shared_market_evidence`.

Important data distinction:
- `shared_market_evidence`: shared master-catalogue research evidence; local Gemma target.
- `tenant_buying_research`: subscriber Research Centre records, tenant-scoped and separate.
- `platform_ai_settings.gemma_enabled`: platform/subscriber AI provider setting, not the local Ollama Gemma switch. It was false in both environments at inspection and was not changed.

Verified environments: TEST `nnsshnfkjcflucjrftzi`; LIVE `gxsrajtqzdjvmceqcpgv`. Product master UUIDs are environment-specific and must be resolved independently. Product unique key is category + branch + manufacturer + model + package key. Evidence unique key is source name + source record key. Shared evidence direct writes are not allowed to authenticated client roles; keep service-role credentials local to the Research PC.

Foundation 0.1 is committed to `feature/tradeflow-gemma-agent-foundation-20261105`. Dry-run is default; `--apply` is explicit. Only exact existing products in both environments are supported. UK sources and GBP only. New evidence is classified `uk_new`; used evidence `uk_used`; opened-never-used/sealed must not be classed as used. UK-used remains reference-only and excluded from automatic valuation.

Six deterministic validation tests passed locally, including a guard against accepting a near-match price. No Supabase writes, schema/RLS/Edge Function changes, Worker deployments, valuation changes, or TEST/LIVE customer/transaction data changes were made. Research PC installation and runtime verification remain open. Next step: install, configure secrets locally, run tests and dry-run; then build safe master product creation as a separate increment.
