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


## Release monitoring increment — 5 November 2026

ReleaseMonitor source added at `tools/tradeflow-gemma-agent/src/release-monitor.mjs`; watchlist at `tools/tradeflow-gemma-agent/tasks/release-watchlist.json`. It searches official manufacturer domains, verifies final redirect domain, extracts only explicit confirmed release states, and compares exact models independently across TEST/LIVE. Rumours are excluded. Candidates stage in TEST review queue; no product masters are auto-created. Daily/weekly/monthly cadence is specified but not scheduled. Added package scripts and tests; runtime execution on Research PC remains pending.


## Approved importer

Added `tools/tradeflow-gemma-agent/src/import-approved.mjs` and `npm run import-approved`. It imports approved evidence only, with full TEST/LIVE preflight and idempotent source-key checks. It has not been run on the Research PC; no evidence was imported in this change.


## Approved importer hardening — 5 November 2026

`tools/tradeflow-gemma-agent/src/import-approved.mjs` is the separate owner-approved evidence import path. It preflights all approved evidence candidates in TEST and LIVE, re-resolves exact product identities independently, validates HTTPS UK source and GBP price, checks stable source-key duplicates, writes missing evidence and updates queue status only after both sides verify. `npm run import-approved`. Research PC execution remains pending; no product/evidence data was imported by this change.


## Agent Control Centre increment — 5 November 2026

Agent telemetry is live in TEST and LIVE databases. Tables: `platform_ai_agent_status`, `platform_ai_agent_activity`. RPCs: `platform_owner_get_ai_agent_control_centre` (owner read) and `platform_ai_agent_report_event` (service-role write). Nine agents are seeded as Not started. The Gemma task runner, ReleaseMonitor and approved evidence importer report status/activity. Owner dashboard UI is staged on separate LIVE and TEST feature branches; not deployed. Current counts: 9 agents in each environment, 0 activity events. No Research PC heartbeat or continuous schedule yet.


## Approved product-master importer increment — 5 November 2026

The feature branch now includes `tools/tradeflow-gemma-agent/src/import-approved-products.mjs` and package command `npm run import-approved-products`. It processes only owner-approved `product_candidate` queue rows from TEST. It requires confirmed release status, an official manufacturer HTTPS domain and an excerpt naming the exact model. It resolves active category, manufacturer, optional branch and exact package identity independently in TEST/LIVE; rejects ambiguous/duplicate identities (including NULL branch), inactive matches and package conflicts; creates missing rows independently with distinct UUIDs and `customer_visible=false`; verifies both sides; and only then marks the queue item imported with both product IDs. README and both manuals/diagnostic roadmap/checkpoint updated on the same feature branch. This is not deployed or runtime-tested. No Supabase catalogue rows have been written. Research PC tests and one controlled approved-candidate import are the next verification gates.


## GBP price-validation encoding fix — 5 November 2026

On `feature/tradeflow-gemma-agent-foundation-20261105`, `tools/tradeflow-gemma-agent/src/agent.mjs` now builds the pound sign using `String.fromCharCode(163)` to avoid Windows encoding corruption in the source file. Exact-price matching and the existing evidence validation rules are retained. Commit `88b00bb64b371f798d8eb2487a9995d4e0c63532`. Awaiting local Research PC `npm test`; no catalogue/database writes or deployments were made.


## Research PC launcher correction — 5 November 2026

`Start-TradeFlow-Gemma.ps1` now has a dry-run default and explicit `-Enqueue` option. Removed the obsolete `-Apply` switch. Preflight checks `.env` required values, TEST/LIVE Supabase project hostnames, Ollama model availability and passing tests. Dry-run performs source research and exact product reads in both environments plus agent telemetry, without queue/catalogue writes. Enqueue stages evidence candidates only in the TEST owner review queue. Not yet run on Research PC; no catalogue changes or deployment.
