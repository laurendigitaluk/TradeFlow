# TradeFlow Gemma Local Research Agent — foundation 0.1

TradeFlow-first local research agent for Ollama. The sample `.env` defaults to `gemma3:4b`; set `OLLAMA_MODEL` to the Gemma tag actually installed on the Research PC. It does not import or execute the retired GearCashOut agent.

- Coordinator with bounded worker concurrency.
- Separate UK-new and UK-used research tasks.
- Brave Search source discovery; Gemma extracts only visible facts from fetched direct pages.
- Rejects non-UK sources, non-GBP prices, wrong evidence type, unsupported prices, mismatched product identity and search/category pages.
- Resolves exact master product independently in TEST and LIVE; environment UUIDs are never copied.
- Checks `(source_name, source_record_key)` before insertion.
- Dry-run is default; `--enqueue` stages evidence candidates for owner review. Gemma does not write directly to `shared_market_evidence`.
- UK-used evidence remains reference-only and does not alter automatic valuation.

## Research PC setup

1. Copy this folder to the Research PC working directory. Use `Start-TradeFlow-Gemma.ps1` as the dedicated Windows launcher; do not use the retired GearCashOut launcher.
2. Run `npm test`.
3. Copy `.env.example` to `.env`; configure Ollama, Brave Search and separate TEST/LIVE service-role keys. Never commit `.env`.
4. Confirm `ollama list` contains the configured `OLLAMA_MODEL` tag and Ollama responds at `http://127.0.0.1:11434`.
5. Run `npm start -- tasks/example.json` first. Inspect the output and sources. Use `--enqueue` only to stage candidates; importing is a separate owner-approved step.

## Foundation 0.1 limits

Evidence-only for an exact master product already present in both environments. New categories, branches, manufacturers and product masters are not created yet; that is the next increment. If either environment has an ambiguous or missing product match, the task fails closed. No schema, RLS, valuation, Edge Function or Worker deployment changes.

## ChatGPT review queue (foundation increment)

Gemma no longer writes directly to `shared_market_evidence`. It resolves the exact product independently in TEST and LIVE, then stages a candidate in the TEST-only control-plane table `public.platform_catalogue_research_queue`. The row includes both environment-specific product IDs, the source observation, excerpt and raw extraction. It remains `pending_review` until the platform owner reviews it through ChatGPT. Use `--enqueue` to submit candidates; default remains dry-run. The former `--apply` flag is deliberately rejected. Queue records are not catalogue evidence and do not affect valuations.

The queue schema and owner-review RPCs were applied to TEST only. LIVE catalogue data is not changed by queue submissions. After approval, the import stage must independently re-resolve products and duplicate-check both environments before writing evidence to either. No automated ChatGPT API agent is assumed: the owner uses the existing ChatGPT conversation and connected Supabase access to review the queue.


## Official product release monitoring — 5 November 2026

A separate `ReleaseMonitor` worker is available at `src/release-monitor.mjs`. Its manufacturer watchlist is `tasks/release-watchlist.json`. It searches official manufacturer domains, fetches official product/news pages, asks the configured local Ollama model to extract only explicitly named releases, then checks exact model presence independently in TEST and LIVE. Rumours are excluded from confirmed release candidates. A product present in only one environment is queued as `needs_research`; a product absent from both is queued for owner review. It does not create master products or update lifecycle fields.

Run a dry scan with `npm run release-monitor`; stage candidates with `npm run release-monitor:enqueue`. The latter writes only to the TEST control-plane queue and never to either master catalogue. The daily/weekly/monthly cadence is defined in the watchlist but is not scheduled on the Research PC yet. Source discovery and extraction have not been run against the Research PC runtime in this environment.
