## 8 November 2026 — LIVE benchmark and JSON reliability checkpoint

- Two-page batching is runtime-verified by LIVE task `owner-3d-printers-speed-benchmark-20261108-1645`: 25m 17s vs 70m 49s baseline (64.3% faster).
- 11 pages fetched; 7 Gemma calls; 5 extraction failures. All 11 captures and deterministic GBP observations remained available for review; 0 approvals/imports.
- Gemma extraction took approximately 1,395s of 1,513s aggregate subtask time (~92%).
- Root failure path: malformed/truncated Ollama content fails JSON.parse and immediately falls back to raw capture. Existing 4,096 context and 1,536 output token budget; don't blindly raise either.
- Follow-up branch `fix/gemma-3d-printer-json-reliability-20261108` proposes strict bounded JSON schema, exact source_id set validation, output-length diagnostics and regression tests. GitHub Actions run 42505764030 (#215) passed 54/54 tests; local Ollama/schema acceptance remains pending. Not deployed.
- Next: validate schema support on installed Ollama/Gemma; run CI; then controlled 3D-only test. Investigate Kobra S1 Max Combo no-eligible-page gap independently. Preserve private .env, `TRADEFLOW_GEMMA_ENV_FILE`, raw page retention and review gates.

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
