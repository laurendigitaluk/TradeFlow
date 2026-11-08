# Project Memory — Gemma 3D Printer Extraction Performance
## 8 November 2026 — LIVE follow-up and structured Product/Offer truncation

- Latest task `owner-3d-printers-extraction-smoke-20261108-1900` completed one Elegoo Neptune 4 Pro subtask: 16 search results, 1 product page discovered/fetched, 1 Gemma call, 0 extraction failures, 1 existing review record enriched and 0 new rows. Worker `DESKTOP-LVASEUB-84452`; completed 19:01:33 UTC.
- Gemma took 224,986 ms of 248,309 ms total (about 90.6%). Route probing: 26 attempts, 11 found, 9 empty, 6 failed; failures were uni3dverse 404, eBay 403 twice/404, Amazon 404 and SecondHand 404.
- The stored page capture is 9,998 characters and ends mid-text. Production `extractRelevantPageText()` appends matched JSON-LD Product/Offer text after flattened page text before truncating to 10,000 characters. Structured offers can therefore be lost on long pages. The original HTML was not retained; whether the exact response contained matching JSON-LD is unconfirmed.
- The page exposes multiple model/condition/bundle prices; no safe unique price was assigned. Keep the row in `needs_research`; no approvals/imports.
- PR #303 branch `fix/gemma-3d-jsonld-priority-20261108` prioritises matching structured offers for 3D printers, formats GBP offers so the deterministic parser can recognise them, and adds regression tests. Draft PR #303 open; GitHub Actions run #299 (run ID 42517043616) passed 55/55 tests and syntax checks on head d67416ea9433be5b8abf19a3bf9f8fe9b6db6a75. This verifies the regression fixture and code branch only; Research PC runtime remains unverified. Not merged/deployed.
- PR #302 head `d0e283300e9bea94f828339f7e41bba48fa938ce` passed 60 CI tests; price-observation contract still needs Research PC verification. The 19:00 run used legacy `price_mentions`/`price_contexts`.
- Current LIVE worker idle; no active/queued 3D tasks; last heartbeat 19:01:33 UTC (idle state does not prove PC connectivity). Review queue 65 rows: 42 `uk_new`, 6 `uk_used`, 17 `uk_both`; top-level prices 2/0/1 by lane; one record has an evidence type; 0 approved/imported.
- No task, queue, catalogue, TEST data, secret, private .env, approval/import state or Research PC runtime was changed. Next gate: green CI and owner-approved updater/replay; no duplicate task.


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

GitHub Actions run 42497005002 passed 53/53 tests and all syntax checks. This is code-level verification only; the change is not runtime-verified. Research PC Ollama acceptance is pending. Do not merge/deploy, update the Research PC, or queue another LIVE task until CI passes and the owner explicitly approves use of the existing updater. Preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. No approval/import behaviour may change.
