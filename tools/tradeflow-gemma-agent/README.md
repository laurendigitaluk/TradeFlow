# TradeFlow Gemma Local Research Agent — foundation 0.1

TradeFlow-first local research agent for Ollama `gemma3:4b`. It does not import or execute the retired GearCashOut agent.

- Coordinator with bounded worker concurrency.
- Separate UK-new and UK-used research tasks.
- Brave Search source discovery; Gemma extracts only visible facts from fetched direct pages.
- Rejects non-UK sources, non-GBP prices, wrong evidence type, unsupported prices, mismatched product identity and search/category pages.
- Resolves exact master product independently in TEST and LIVE; environment UUIDs are never copied.
- Checks `(source_name, source_record_key)` before insertion.
- Dry-run is default; `--apply` is required for mirrored writes to `shared_market_evidence`.
- UK-used evidence remains reference-only and does not alter automatic valuation.

## Research PC setup

1. Copy this folder to the Research PC working directory. Use `Start-TradeFlow-Gemma.ps1` as the dedicated Windows launcher; do not use the retired GearCashOut launcher.
2. Run `npm test`.
3. Copy `.env.example` to `.env`; configure Ollama, Brave Search and separate TEST/LIVE service-role keys. Never commit `.env`.
4. Confirm `ollama list` contains `gemma3:4b` and Ollama responds at `http://127.0.0.1:11434`.
5. Run `npm start -- tasks/example.json` first. Inspect the output and sources. Only run with `--apply` after review.

## Foundation 0.1 limits

Evidence-only for an exact master product already present in both environments. New categories, branches, manufacturers and product masters are not created yet; that is the next increment. If either environment has an ambiguous or missing product match, the task fails closed. No schema, RLS, valuation, Edge Function or Worker deployment changes.