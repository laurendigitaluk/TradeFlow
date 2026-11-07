# Gemma 3D Printer Research — Lane, Extraction and Monitoring Checkpoint

Date: 7 November 2026  
Scope: TradeFlow LIVE Gemma only — category `3d-printers-equipment`, branch `3d-printers`.

## Operating boundary
- Repository: `laurendigitaluk/TradeFlow`.
- Production branch: `production`; TEST branch/environment remains separate.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`; TEST Supabase: `nnsshnfkjcflucjrftzi`.
- Do not use retired project `twfbmjwwqzxdxvclxbun`.
- Gemma stages raw candidates only. ChatGPT/owner verifies; no automatic catalogue/evidence approval or import.
- Preserve the Research PC's existing private `.env`, secrets and `TRADEFLOW_GEMMA_ENV_FILE` path. Do not point the updater at GearCashOut configuration.

## LIVE controlled research batch observed
- Task key: `owner-3d-printers-new-used-capture-20261107-2016`.
- Eight subtasks: Anycubic Kobra S1, Bambu Lab A1, Creality K1 and Elegoo Neptune 4 Pro, each with separate `uk_new` and `uk_used` passes.
- Worker claimed the task on the Research PC; task lease continued to renew and no task error was recorded.
- First subtask (Anycubic Kobra S1 / uk_new) completed and staged 9 individual page captures in LIVE `platform_catalogue_research_queue`, all with `needs_research`.
- All 9 raw captures contained visible GBP price mentions (2–8 mentions per page). All 9 had null structured `observed_price` and `evidence_type`.
- All 9 raw payloads reported: `Gemma returned JSON without a findings array`. The capture-first fallback retained source URL, page title, full extracted text and price mentions. No evidence was lost from the raw review capture.
- The second subtask (Anycubic Kobra S1 / uk_used) had reached extraction with 8 fetched pages as of 20:34 UTC. Do not cancel or enqueue a duplicate; allow the active eight-subtask task to finish.
- As of 20:34 UTC, 9 new captures from this batch were present, 0 had structured prices, 0 had structured evidence type; total 3D-printer needs_research captures were 13. These are raw review queue counts, not accepted evidence counts.
- The last status source was an individual eBay `/itm/` listing. An earlier progress field briefly showed an eBay `/splashui/challenge` URL, which is a challenge route and must not be confused with the later individual listing.

## First measured loss point
The first subtask successfully discovered, fetched and preserved 9 pages. The first measured loss occurred after page fetch, when Ollama returned valid JSON without a recognised findings array. The parser rejected the response envelope, so all nine pages used the raw fallback and retained no structured price/condition/type fields. This is not a discovery failure and not a price-visibility failure. The fallback is working as designed; parser compatibility and diagnostics are the improvement target.

## Confirmed production-code issues addressed in PR #278
1. **New/used lane leak:** `isApprovedSourceForTask()` checked category and manufacturer only. Both `uk_new` and `uk_used` tasks could receive the same source allow-list; approved-source probing also rotated through both lanes. PR #278 adds lane-aware filtering to the category web-search domains, direct host validation and approved-source probing. `uk_both` keeps both lanes.
2. **3D search result ceiling:** `searchWebResults()` defaults to 18 retained results, with a maximum of 30. PR #278 raises the 3D-printer-only default to 30, configurable downward with `GEMMA_3D_PRINTER_SEARCH_RESULTS_PER_TASK`. Other categories retain their previous behaviour.
3. **HTML pound entity mismatch:** `extractRelevantPageText()` converts pound entities to `GBP`, but `extractVisibleGbpPriceMentions()` only matched `£`. PR #278 recognises both labels and preserves context.
4. **Challenge-page ambiguity:** known anti-bot/captcha routes are now excluded from direct product-page eligibility and counted as blocked discovery results. The change does not bypass anti-bot controls.
5. **Extraction-envelope mismatch:** PR #278 accepts the required findings array, recognised common wrapper arrays/objects, and a single `source_id` object. If the shape is still unknown, it records the top-level keys. Every fetched page still gets a raw fallback capture.
6. **Monitoring gap:** PR #278 emits start/completion/failure progress for each Ollama batch and reports source-route, pagination, page-fetch, search, extraction and capture metrics in task results, LIVE telemetry and Common Room handovers.

## Code branch and review
- Feature branch: `feature/gemma-3d-printer-lanes-metrics-20261107`.
- PR: https://github.com/laurendigitaluk/TradeFlow/pull/278
- Current PR head at checkpoint update: `10a81ce7c7fed055cd391f59ffcfdad2a1962432` (latest code commit `0cb9f6b603a10769895d5fe1bd955c06a4a95982`; later commits are documentation/checkpoint updates).
- PR is open and unmerged. Do not merge or deploy without owner review.
- GitHub Actions Gemma Research Tests runs 42411454578, 42411512585, 42411518602, 42411597295, 42411603001, 42411615477, 42411650325, 42411660316, 42411686018, 42411719991 and 42411824125 passed. Run 42411844905 for the README update also passed. All listed Gemma Research Tests runs are green.
- The latest worker-code change adds a periodic LIVE telemetry heartbeat during active subtasks, preserving the current extraction stage while Ollama is waiting. Its CI run 42411824125 passed.
- No Supabase schema, source registry, product catalogue, shared evidence, TEST/LIVE tenant/customer/order/domain/Stripe data, Cloudflare deployment or local PC files were changed by the PR work.

## Documentation updated on the feature branch
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-GEMMA-RESEARCH-PIPELINE.md`
- `tools/tradeflow-gemma-agent/README.md`

## Post-merge acceptance plan
1. Verify PR #278 CI is green and owner approves merge.
2. Wait for the active eight-subtask LIVE research task to complete; do not interrupt it.
3. After merge, update the existing Research PC installation in place using the current updater. Preserve the existing private `.env`, `TRADEFLOW_GEMMA_ENV_FILE` and backup workflow. Do not use GearCashOut paths.
4. Confirm a fresh LIVE worker heartbeat and Common Room round-trip.
5. Run one controlled `uk_new` and one `uk_used` test for a known printer. Verify new tasks probe only manufacturer/new-retailer sources and used tasks only used-marketplace/refurbished-dealer sources.
6. Verify the 3D-only 30-result limit, route outcome metrics, page discovery/fetch counts, per-batch Ollama progress, JSON-envelope parsing, GBP mentions and staged review captures.
7. ChatGPT opens the source pages and checks exact model/package, current price, condition and availability. Keep all candidates at `needs_research` until manually reviewed. No automatic catalogue/evidence import.
