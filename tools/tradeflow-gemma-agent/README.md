# TradeFlow Gemma Local Research Agent — foundation 0.1

TradeFlow-first local research agent for Ollama. The sample `.env` defaults to `gemma3:4b` and 18 search results per product; set `OLLAMA_MODEL` to the Gemma tag actually installed on the Research PC. Existing local `.env` files are not overwritten by updates: change `SEARCH_RESULTS_PER_TASK=8` to `SEARCH_RESULTS_PER_TASK=18` manually if the older setting is present. It does not import or execute the retired GearCashOut agent.

- Coordinator with bounded worker concurrency.
- One product-level research task combines UK-new and UK-used discovery; each source is classified separately during one Gemma extraction pass.
- GearCashOut-compatible independent DuckDuckGo, Bing and Mojeek search discovery; Gemma extracts only visible facts from fetched direct pages. No local Docker/SearXNG service or paid search API is required.
- Rejects non-UK sources, non-GBP prices, wrong evidence type, unsupported prices, mismatched product identity and search/category pages.
- Research itself does not look up TEST/LIVE catalogue products; verified candidates are handed to ChatGPT for review.
- Checks `(source_name, source_record_key)` before insertion.
- Dry-run is default; `--enqueue` stages evidence candidates for owner review. Gemma does not write directly to `shared_market_evidence`.
- UK-used evidence remains reference-only and does not alter automatic valuation.

## Research PC setup

1. Keep this folder separate from the retired GearCashOut agent. TradeFlow interactive runs, Node entry point and background worker all read this folder's `.env` by default. The old `C:\\GearCashOut-Config\\.env` is not read, copied, moved or overwritten.
2. Create the TradeFlow `.env` from `.env.example` once, then populate the separate TEST and LIVE URL/key settings and the installed `OLLAMA_MODEL` tag. Never paste keys into chat or commit `.env`.
3. Confirm `ollama list` contains the configured model tag and Ollama responds at `http://127.0.0.1:11434`.
4. Run `npm test` and then `Start-TradeFlow-Gemma.ps1` for a dry run. Web discovery uses independent public search providers; Docker and SearXNG are not required. Only after a successful dry run should `-Enqueue` be used to stage candidates for owner review. Importing remains a separate owner-approved step.

## Foundation 0.1 limits

Evidence-only for an exact master product already present in both environments. New categories, branches, manufacturers and product masters are not created yet; that is the next increment. If either environment has an ambiguous or missing product match, the task fails closed. No schema, RLS, valuation, Edge Function or Worker deployment changes.

## ChatGPT review queue (foundation increment)

Gemma no longer writes directly to `shared_market_evidence`. It resolves the exact product independently in TEST and LIVE, then stages a candidate in the TEST-only control-plane table `public.platform_catalogue_research_queue`. The row includes both environment-specific product IDs, the source observation, excerpt and raw extraction. It remains `pending_review` until the platform owner reviews it through ChatGPT. Use `--enqueue` to submit candidates; default remains dry-run. The former `--apply` flag is deliberately rejected. Queue records are not catalogue evidence and do not affect valuations.

The queue schema and owner-review RPCs were applied to TEST only. LIVE catalogue data is not changed by queue submissions. After approval, the import stage must independently re-resolve products and duplicate-check both environments before writing evidence to either. No automated ChatGPT API agent is assumed: the owner uses the existing ChatGPT conversation and connected Supabase access to review the queue.


## Official product release monitoring — 5 November 2026

A separate `ReleaseMonitor` worker is available at `src/release-monitor.mjs`. Its manufacturer watchlist is `tasks/release-watchlist.json`. It searches official manufacturer domains, fetches official product/news pages, asks the configured local Ollama model to extract only explicitly named releases, then checks exact model presence independently in TEST and LIVE. Rumours are excluded from confirmed release candidates. A product present in only one environment is queued as `needs_research`; a product absent from both is queued for owner review. It does not create master products or update lifecycle fields.

Run a dry scan with `npm run release-monitor`; stage candidates with `npm run release-monitor:enqueue`. The latter writes only to the TEST control-plane queue and never to either master catalogue. The daily/weekly/monthly cadence is defined in the watchlist but is not scheduled on the Research PC yet. Source discovery and extraction have not been run against the Research PC runtime in this environment.


## Owner-approved evidence import

The separate importer is `src/import-approved.mjs`, invoked with `npm run import-approved` from the agent directory. It reads only `approved` evidence candidates from the TEST control-plane queue. It preflights every candidate against both databases, re-resolves category, branch, manufacturer and exact package identity independently, checks both evidence stores for the stable source key, and only then writes missing evidence rows. It marks the queue item imported only after both environment writes are verified. A partial cross-environment failure can be retried safely because the source key is idempotent. UK-used notes explicitly mark the evidence as reference-only. The importer has not yet been executed against the Research PC credentials.


## Agent activity reporting

The worker runner reports each specialist's task start, per-source progress, completion and failure through `src/agent-telemetry.mjs` to both TEST and LIVE. The Agent Control Centre in the corresponding Platform Owner dashboard reads the local environment's telemetry. Specialist identities are mapped from `agent_key` or the task's `category_slug`; `research_type` remains the evidence type (`uk_new` or `uk_used`) and must not be used as the agent identity. ReleaseMonitor and the approved evidence importer also report their lifecycle events. The dashboard refreshes every 30 seconds. Initial seeded agents remain Not started until the Research PC sends a heartbeat.


## Owner-approved product master import

New confirmed product masters are staged as `product_candidate` rows in the TEST-only owner review queue. After a platform owner approves a candidate, run `npm run import-approved-products` on the Research PC. The importer accepts only confirmed release statuses (announced, preorder, released or available), an official manufacturer-domain source, and an excerpt explicitly naming the exact model. It independently resolves category, manufacturer and optional branch in TEST and LIVE; detects ambiguous/duplicate identities including NULL-branch matches; creates missing master rows with separate environment UUIDs; verifies both sides; and only then marks the queue item imported. Newly created products default to `customer_visible=false` pending catalogue curation. The importer has not been run against the live Research PC credentials; validate with `npm test` and a reviewed test candidate before operational use.


## Safe launcher and first-run sequence — 5 November 2026

`Start-TradeFlow-Gemma.ps1` is the supported Windows entry point. It verifies the local `.env` exists, required setting names are populated without displaying secret values, TEST/LIVE URLs match the expected Supabase project refs, the configured Ollama model is installed, and `npm test` passes before starting research. Default invocation is dry-run: it performs independent DuckDuckGo, Bing and Mojeek discovery, fetches eligible product pages, performs one Gemma extraction pass per product, and records agent telemetry. It does not write review-queue or catalogue evidence/product rows. Search results are balanced round-robin across providers; skipped candidates are logged with provider, title and URL for diagnosis. Use `./Start-TradeFlow-Gemma.ps1 -Enqueue` only after reviewing dry-run output; this stages candidates in the TEST-only owner review queue and does not import catalogue products/evidence. The retired `--apply` mode is not supported. The launcher requires both environment service-role credentials because exact product identity is checked independently in both environments. Keep `.env` local and never share or commit its contents.


## Search provider — GearCashOut-compatible fallback

TradeFlow uses the same resilient search-provider pattern as the established GearCashOut agent: DuckDuckGo, Bing and Mojeek are queried independently and in parallel. A timeout, block or unavailable response from one provider does not prevent the others from returning results. No local SearXNG container, Docker Desktop, paid search API or search-provider API key is required. Search results are still only discovery candidates; direct page retrieval, UK storefront checks, GBP price visibility, exact model matching and evidence validation remain mandatory before a candidate can be staged.

The old SearXNG-only implementation was an unnecessary architectural divergence and has been removed from the main research and release-monitor paths. The SEARXNG_BASE_URL setting is no longer used and should not be added to the TradeFlow .env.


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


## Persistent background task service

The supported unattended mode uses the TEST-only `platform_ai_agent_tasks` control-plane queue. ChatGPT/owner control inserts task instructions into TEST; the Research PC worker claims one task every 15 seconds, renews its 10-minute lease every 45 seconds, runs the existing UK evidence research pipeline and stages candidates for owner review. It reports task lifecycle and specialist progress to both TEST and LIVE Agent Control Centres. The task worker does not write master products or evidence directly.

One-time Windows setup: download `src/task-worker.mjs`, `Start-TradeFlow-Gemma-Service.ps1` and `Install-TradeFlow-Gemma-Service.ps1` from the same feature branch into this folder, then run `Install-TradeFlow-Gemma-Service.ps1`. This registers a per-user Windows logon scheduled task and starts the auto-restarting supervisor. The supervisor uses this folder's `.env`; it does not read or change `C:\\GearCashOut-Config\\.env`. Logs are written to `logs/gemma-supervisor.log`. The service has not yet been installed on the Research PC.


## Gemma Research PC low-VRAM fallback — 6 November 2026

The Research PC has approximately 80 GB system RAM and an NVIDIA GeForce GTX 1650 with approximately 4 GB VRAM. Ollama reported HTTP 500 `model runner has unexpectedly stopped` while extracting with `gemma3:4b` (approximately 3.5 GB). The agent now defaults to CPU-only inference via `num_gpu: 0` to avoid exhausting GPU memory. Keep `OLLAMA_NUM_GPU=0` in the local `.env` until CPU inference is confirmed stable. A non-negative integer override is available for later controlled GPU testing. The 180-second extraction timeout and evidence-validation rules remain unchanged.


## SearXNG launcher fallback — 6 November 2026

The Windows launcher now tries the configured `SEARXNG_BASE_URL` first and then the known local Compose endpoint `http://127.0.0.1:8080` if the configured address fails or does not return JSON results. This handles stale local `.env` endpoint values without editing or displaying `.env`, changing the old GearCashOut configuration, or requiring the user to diagnose Docker. It fails closed if neither endpoint responds. The launcher change is committed as `a142f71cc24f2ab36152f00f900ddeab1fb4ccf2`.


## SearXNG preflight warm-up timeout adjustment — 6 November 2026

The Research PC returned one result from `http://127.0.0.1:8080/search?q=tradeflow&format=json` with a 10-second manual timeout, while the launcher fallback timed out with an 8-second limit. The launcher preflight now allows 25 seconds per attempt and retries once after a two-second pause before failing closed. This accommodates a slow/warming local search service without changing the search URL, `.env`, Docker configuration, Ollama settings, or catalogue data. Commit: `75cd7bcf00787b8ac477ac8503aebc288e7049c8`.


## Architecture audit correction — 6 November 2026

A direct comparison with the working GearCashOut implementation in `laurendigitaluk/Action-Buyer-UK` found that GearCashOut uses independent DuckDuckGo, Bing and Mojeek search providers (plus optional configured Google), not a mandatory local SearXNG service. TradeFlow foundation 0.1 had incorrectly replaced that resilient provider layer with a single SearXNG dependency and added a blocking PowerShell preflight. This was an unnecessary divergence and caused the Research PC startup loop.

Correction on the TradeFlow Gemma feature branch:
- `src/agent.mjs` now queries DuckDuckGo, Bing and Mojeek independently in parallel and merges deduplicated results; provider failures are isolated.
- `src/release-monitor.mjs` now reuses the same shared search implementation.
- `Start-TradeFlow-Gemma.ps1` no longer checks Docker or SearXNG before starting.
- `.env.example` no longer includes `SEARXNG_BASE_URL`.
- The GearCashOut `.env` remains untouched and is never loaded by TradeFlow.
- UK/GBP validation, exact TEST/LIVE product matching, Ollama extraction, dry-run default and owner-review queue boundary remain unchanged.

This correction supersedes the SearXNG-only setup notes and the two SearXNG launcher timeout adjustments earlier in this README. Search providers can individually block or rate-limit requests; the intended behaviour is to continue with the remaining providers, not fail the entire research run because one local service is unavailable.

Commits: `8c83d666b602d149c2e1fbcbf158100053bbaa31` (research search), `53dc247da01c37bf743e0e63c54e3abce537160c` (tests), `27a3e964022400f0af903b286de66d9fb4a53517` (launcher), `34a127fb26e908974c3e891331dcfd01795e2728` (release monitor), `6987a2c782e4ea227dde131bb92e476f0e3f21ff` (.env example).


## Batched research pipeline — 6 November 2026

The earlier implementation called Ollama once for every fetched source page. With separate UK-new and UK-used workers and eight search results per worker, one product run could issue up to sixteen serialized model requests. That kept the local CPU busy for several minutes and sent collection pages, forums and search-result pages into extraction unnecessarily.

The current pipeline changes the order:

1. Search DuckDuckGo, Bing and Mojeek independently in parallel.
2. Reject search, category, collection, forum and other non-product URLs before fetching.
3. Fetch remaining pages in bounded groups of four.
4. Reject pages without a visible positive GBP price before calling Ollama.
5. Send the remaining page excerpts to one consolidated Ollama request per research task.
6. Bind each model response to a supplied source ID; the agent supplies the authoritative source URL, host, GBP currency and task evidence type.
7. Run the existing strict UK source, exact product identity, visible-price, condition and availability validation.
8. Resolve exact product identity independently in TEST and LIVE; stage only valid candidates in the TEST owner-review queue.

The UK-new and UK-used research tasks remain separate. Ollama calls remain serialized across tasks, CPU-only inference remains the safe default after the previous GTX 1650 runner crash, and no catalogue/evidence rows are written directly. Dry-run remains the default.

The run summary now reports search results, eligible URLs, fetched price-bearing pages, Gemma call count and accepted candidates. Progress events distinguish URL prefiltering, missing-price rejection, batch extraction and validation rejection.

**Important limitation:** this pipeline deliberately does not turn a page without a visible GBP price into a priced evidence candidate. Such a page is recorded in run progress as excluded before Gemma, rather than inventing a price. A future owner-review-only note workflow can preserve exact-product pages with missing prices without weakening the evidence schema.

Automated regression coverage now includes direct-product URL filtering, visible GBP-price screening and a mocked multi-page extraction test that asserts one Ollama request handles multiple source pages. The GitHub Actions test workflow is configured; the local Research PC benchmark and real dry-run are still required before marking the change verified live.

Implementation branch: `fix/gemma-batched-extraction-20261106`.
Pre-change restore branch: `checkpoint-gemma-research-pipeline-pre-batch-20261106`.


The GitHub Actions regression suite passed on the latest implementation commit `53ced5c47674a13e1f92d4f6ce4b4106af0ede52` (run `42143240473`, conclusion `success`). The Research PC benchmark and real dry-run remain outstanding.


Merged-branch verification: GitHub Actions run `42143345106` completed successfully on merged commit `e31d974b0b513e1d5101fa6678d798ac1555a2df`. The remaining verification is the Research PC pull, dry-run timing and responsiveness check.
