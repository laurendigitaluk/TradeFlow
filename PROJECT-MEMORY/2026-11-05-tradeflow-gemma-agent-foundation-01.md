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


## Review-gated workflow update — 5 November 2026

Gemma now stages evidence candidates into the TEST-only `public.platform_catalogue_research_queue`; it no longer writes directly to `shared_market_evidence`. The candidate records include product identity, package variant, UK GBP evidence, source excerpt and TEST/LIVE product IDs resolved independently. The CLI default remains dry-run; `--enqueue` is the explicit write mode and `--apply` is rejected. TEST queue table and owner-only review RPCs were applied; RLS enabled and direct client grants revoked. No LIVE queue migration or catalogue writes were made.

Subscriber-supplied AI provider selection is being removed from Platform Owner settings. The TradeFlow Assistant/customer messaging remains; subscriber accounts, tenants, websites and customer data are not to be deleted. TEST and LIVE UI changes are isolated on separate feature branches. The current DB flag is false in both environments. Provider enforcement migration remains pending.

Tests were authored but Research PC execution is pending; do not treat the earlier statement of six passing tests as verified. No scheduled background run or autonomous ChatGPT integration exists yet. ChatGPT review is interactive through the owner's existing conversation and connected Supabase tools. A separate approved-importer, release monitor, scheduler, runtime test and deployment remain outstanding.
