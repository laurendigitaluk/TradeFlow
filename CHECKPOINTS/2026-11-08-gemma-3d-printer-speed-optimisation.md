# Gemma 3D Printer Extraction Performance Checkpoint
## 8 November 2026 — PR #303: preserve structured product offers

LIVE task `owner-3d-printers-extraction-smoke-20261108-1900` completed one Elegoo Neptune 4 Pro subtask on worker `DESKTOP-LVASEUB-84452` (18:57:24–19:01:33 UTC). Search 16; product pages discovered/fetched 1/1; Gemma calls 1; extraction failures 0; 1 existing review record enriched, 0 new rows. Stage timings: search 669 ms; source probes 10,003 ms; collection discovery 11,098 ms; page fetch 918 ms; Gemma 224,986 ms; queue write 327 ms; total 248,309 ms. Gemma was about 90.6% of total time.

The capture is 9,998 characters and ends mid-text. Production appends matched JSON-LD Product/Offer text after flattened page content, then truncates at 10,000 characters. This can discard structured offers on long pages; the exact HTML was not retained, so the presence of JSON-LD in this particular response is unknown. The page contains multiple model, open-box and bundle price options; no safe single price or evidence type was assigned. Capture remains `needs_research`.

PR #303 branch `fix/gemma-3d-jsonld-priority-20261108` moves matching structured Product/Offer facts before flattened text only for the 3D-printer branch, formats GBP offers as `GBP <amount>`, and adds long-page and non-3D regression tests. Draft PR #303 is open; CI pending; not merged/deployed/installed.

PR #302 is also open/draft; head `d0e283300e9bea94f828339f7e41bba48fa938ce` passed 60 CI tests and adds price observations, split-decimal parsing, repeated-context retention and condition-lane safety. Its new output contract is not yet verified on the Research PC; the 19:00 run emitted legacy `price_mentions`/`price_contexts`.

No task was queued, no queue or catalogue row was changed by this checkpoint, no evidence was approved/imported, and no TEST data, secrets, private .env or worker runtime was changed. Next: verify PR #303 CI, then obtain owner approval for the existing updater and replay one retained 3D-printer page before another LIVE task.


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

## Proposed optimisation in this branch

- Change only the 3D-printer extraction batch size to two pages per Ollama call.
- Change the 3D prompt to require one top-level findings array with exactly one finding per supplied source_id.
- Reduce each model page excerpt from 6,200 to 2,800 characters; retain up to eight compact nearby GBP price contexts and the visible GBP amount list.
- Keep the complete fetched page text, all deterministic price mentions and fallback captures in the LIVE review queue.
- Raise the 3D call output budget to 1,536 tokens for two concise observations.
- Add stage duration metrics: web search, approved-source probing, collection discovery, direct page fetch, Gemma extraction, LIVE queue write and total elapsed time.
- Add prompt/batch regression tests and include them in GitHub Actions and the existing Research PC updater.

## Verification status

- Code and documentation changes committed to this branch.
- GitHub Actions run `42497005002` passed: 53 tests passed, 0 failed; all Gemma source syntax checks and Owner Dashboard JavaScript syntax passed. This verifies code/tests only; no local Ollama inference or Research PC test has been run.
- PR #298 is draft/open and not merged. Two-page extraction remains a hypothesis to benchmark, not a claimed speed improvement.
- Do not merge, deploy, update/restart the Research PC or enqueue another LIVE task until CI passes and the owner approves the existing updater workflow.
- Preserve the dedicated private .env and TRADEFLOW_GEMMA_ENV_FILE.
- Compare next-run wall time, per-stage durations, structured findings per page, extraction failures and raw fallback retention.

## Safety

No LIVE/TEST database rows, source registry, queue task, review candidate, catalogue record, approval/import state, credentials, private .env, Research PC installation or runtime was changed. No new research task was queued.
