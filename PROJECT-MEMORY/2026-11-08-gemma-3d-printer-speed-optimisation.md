# Project Memory — Gemma 3D Printer Extraction Performance

## 8 November 2026 — PR #298 merged

PR #298 is now merged into `production` (merge commit `3417c5dced183fedcf13a7af266c67c2dd697d0a`). GitHub Actions validation passed 53/53 tests. This is not yet installed on the Research PC and has not been runtime-benchmarked. Next: use the existing updater with the correct dedicated install folder, preserving the separate private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify installed commit/heartbeat before queuing a controlled 3D-printer batch. Do not change other agent branches or import/approval controls.


Date: 8 November 2026
Scope: TradeFlow LIVE 3D Printers research pipeline only.

The six-product LIVE batch owner-3d-printers-chatgpt-evidence-batch-20261108-1315 took 70m 49s. The worker processed the six subtasks sequentially. Across the task, 30 product pages were discovered, 18 fetched, 18 one-page Ollama extraction calls were made and 10 extraction failures were recorded. Fetched pages remained preserved in the LIVE review queue; none was approved or imported.

Code inspection established:
- task-worker.mjs iterates product subtasks sequentially.
- Product-page fetching is already concurrent in groups of four.
- Ollama extraction is serialised by ollamaExtractionQueue.
- The 3D-printer branch used one page per model call and a single-object prompt.
- Search fans five query variants across four providers concurrently; approved source routes are probed separately in groups of four per source. Request counts alone do not establish wall-clock cost.

Performance branch: perf/gemma-3d-printer-two-page-extraction-20261108.
The proposed change batches two 3D-printer pages per Ollama call, changes the prompt contract to a findings array with one row per source_id, reduces model excerpts to 2,800 characters per page while retaining price strings and compact nearby contexts, and records per-stage durations. Full page text remains preserved for ChatGPT. Other categories are unchanged.

GitHub Actions run 42497005002 passed 53/53 tests and all syntax checks. This is code-level verification only; the change is not runtime-verified. Research PC Ollama acceptance is pending. PR #298 is merged and CI passed, but the Research PC source remains unverified. The worker `DESKTOP-LVASEUB-80488` started at 16:12:56 UTC and stopped cleanly at 16:15:29 UTC without claiming a task. Do not deploy or queue another LIVE task without explicit owner approval. Preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. No approval/import behaviour may change.


## 8 November 2026 — LIVE 3D-printer audit and HTTP 403 source backoff

- Latest LIVE task `owner-3d-printers-chatgpt-evidence-batch-20261108-1315`: 6 sequential subtasks, 70m 49s, 123 search results, 30 product pages discovered, 18 fetched, 18 one-page Ollama calls and 10 extraction failures (4 timeouts, 4 unterminated JSON responses, 2 unrecognised findings-array shapes).
- All 18 fetched pages were preserved as review captures: 12 new queue rows and 6 existing rows enriched. LIVE queue now contains 64 3D-printer rows; all are `needs_research`, with zero approved and zero imported. Research-lane metadata in raw payload: 42 `uk_new`, 6 `uk_used`, 16 `uk_both`. The top-level `evidence_type` is null on 63/64 rows; the raw task lane remains available for ChatGPT review. Do not treat a raw capture as approved evidence.
- First loss points: 12 of 30 discovered pages did not reach page capture (11 recorded direct-fetch errors); for pages successfully fetched, the first systematic loss of structured findings was Gemma extraction (10/18 failed). Raw page text and price contexts were retained, so this is a structured-extraction loss, not deletion of the source captures.
- The six-product batch used `uk_both` for every subtask. Approved-source route probing made 159 attempts with 39 errors. eBay's three configured routes returned two HTTP 403s and one HTTP 404 for each product (18 repeated eBay route attempts); direct eBay listing fetches also returned HTTP 403. Do not bypass these blocks.
- New review branch: `fix/gemma-3d-printer-403-domain-block-20261108`. It scopes a blocked-host set to one claimed 3D-printer queue batch, probes eBay routes sequentially, stops after the first HTTP 403, skips eBay results for the remainder of that batch, and records blocked-domain/route/result metrics. The set resets for the next queue batch. 404s do not trigger a block. Other categories retain existing route behaviour. Regression tests model six subtasks: eBay route attempts fall from 18 to 1 (17 skipped; 94.4% fewer) when the first route returns 403. This is test-simulated, not a LIVE runtime benchmark; PR is not merged or deployed.
- No new research task was queued, no evidence approved/imported, and no source registry, TEST data, LIVE catalogue data, secrets or private environment file was changed by this audit.
