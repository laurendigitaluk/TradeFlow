# Gemma 3D Printer Extraction Performance Checkpoint

## 8 November 2026 — PR #298 merged

PR #298 is now merged into `production` (merge commit `3417c5dced183fedcf13a7af266c67c2dd697d0a`). GitHub Actions validation passed 53/53 tests. This is not yet installed on the Research PC and has not been runtime-benchmarked. Next: use the existing updater with the correct dedicated install folder, preserving the separate private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify installed commit/heartbeat before queuing a controlled 3D-printer batch. Do not change other agent branches or import/approval controls.


Date: 8 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: perf/gemma-3d-printer-two-page-extraction-20261108
Base: production
Scope: LIVE category 3d-printers-equipment / branch 3d-printers only

## Baseline

LIVE task: owner-3d-printers-chatgpt-evidence-batch-20261108-1315
- Six product subtasks completed sequentially in 70m 49s.
- 30 individual product pages discovered; 18 fetched.
- 18 one-page Ollama extraction calls; 10 extraction failures.
- All fetched pages were retained in the LIVE review queue; no approval/import was performed.

## Confirmed execution path

- task-worker.mjs processes the product task array sequentially.
- Each runTask performs web search, approved-source probing, collection discovery, direct page fetching, Gemma extraction and LIVE review-queue writes.
- Direct product pages are fetched concurrently in groups of four.
- Ollama extraction is serialised by ollamaExtractionQueue.
- 3D-printer extraction used one page per Ollama call. The 3D prompt required a single observation object.

## Merged production optimisation (PR #298)

- Production code changes only the 3D-printer extraction batch size to two pages per Ollama call.
- Change the 3D prompt to require one top-level findings array with exactly one finding per supplied source_id.
- Reduce each model page excerpt from 6,200 to 2,800 characters; retain up to eight compact nearby GBP price contexts and the visible GBP amount list.
- Keep the complete fetched page text, all deterministic price mentions and fallback captures in the LIVE review queue.
- Raise the 3D call output budget to 1,536 tokens for two concise observations.
- Add stage duration metrics: web search, approved-source probing, collection discovery, direct page fetch, Gemma extraction, LIVE queue write and total elapsed time.
- Prompt/batch regression tests are included in GitHub Actions and the existing Research PC updater; the local worker has not yet produced a post-merge runtime result.

## Verification status

- Code and documentation changes committed to this branch.
- GitHub Actions run `42497005002` passed: 53 tests passed, 0 failed; all Gemma source syntax checks and Owner Dashboard JavaScript syntax passed. This verifies code/tests only; no local Ollama inference or Research PC test has been run.
- PR #298 merged into production at `3417c5dced183fedcf13a7af266c67c2dd697d0a`; GitHub Actions passed 53/53 tests. Two-page extraction remains unverified on the Research PC until a post-merge controlled task reports two-page calls and `stage_durations_ms`.
- Research PC worker `DESKTOP-LVASEUB-80488` started at 16:12:56 UTC and stopped cleanly at 16:15:29 UTC without claiming a task. No queued/running 3D-printer task remains. The installed source version is not identifiable from the worker-start event alone.
- Preserve the dedicated private .env and TRADEFLOW_GEMMA_ENV_FILE.
- Compare next-run wall time, per-stage durations, structured findings per page, extraction failures and raw fallback retention.

## Safety

No LIVE/TEST database rows, source registry, queue task, review candidate, catalogue record, approval/import state, credentials or private .env was changed by this audit. The observed worker start/stop events did not update the Research PC source. No new research task was queued.


## 8 November 2026 — LIVE 3D-printer audit and HTTP 403 source backoff

- Latest LIVE task `owner-3d-printers-chatgpt-evidence-batch-20261108-1315`: 6 sequential subtasks, 70m 49s, 123 search results, 30 product pages discovered, 18 fetched, 18 one-page Ollama calls and 10 extraction failures (4 timeouts, 4 unterminated JSON responses, 2 unrecognised findings-array shapes).
- All 18 fetched pages were preserved as review captures: 12 new queue rows and 6 existing rows enriched. LIVE queue now contains 64 3D-printer rows; all are `needs_research`, with zero approved and zero imported. Research-lane metadata in raw payload: 42 `uk_new`, 6 `uk_used`, 16 `uk_both`. The top-level `evidence_type` is null on 63/64 rows; the raw task lane remains available for ChatGPT review. Do not treat a raw capture as approved evidence.
- First loss points: 12 of 30 discovered pages did not reach page capture (11 recorded direct-fetch errors); for pages successfully fetched, the first systematic loss of structured findings was Gemma extraction (10/18 failed). Raw page text and price contexts were retained, so this is a structured-extraction loss, not deletion of the source captures.
- The six-product batch used `uk_both` for every subtask. Approved-source route probing made 159 attempts with 39 errors. eBay's three configured routes returned two HTTP 403s and one HTTP 404 for each product (18 repeated eBay route attempts); direct eBay listing fetches also returned HTTP 403. Do not bypass these blocks.
- New review PR #299: [fix(gemma): stop 3D printer source retries after HTTP 403](https://github.com/laurendigitaluk/TradeFlow/pull/299), branch `fix/gemma-3d-printer-403-domain-block-20261108`. It scopes a blocked-host set to one claimed 3D-printer queue batch, probes eBay routes sequentially, stops after the first HTTP 403, skips eBay results for the remainder of that batch, and records blocked-domain/route/result metrics. The set resets for the next queue batch. 404s do not trigger a block. Other categories retain existing route behaviour. Regression tests model six subtasks: eBay route attempts fall from 18 to 1 (17 skipped; 94.4% fewer) when the first route returns 403. This is test-simulated, not a LIVE runtime benchmark; PR #299 is not merged or deployed. GitHub Actions Gemma Research Tests run #206 (run ID `42499597425`) passed `57/57` tests on PR head `67cd25b7500f5227222a7ad90f5fcbdef1eb015e`; source syntax checks and the full Gemma test suite passed. This is unit/CI verification only, not a LIVE Research PC benchmark.
- No new research task was queued, no evidence approved/imported, and no source registry, TEST data, LIVE catalogue data, secrets or private environment file was changed by this audit.
