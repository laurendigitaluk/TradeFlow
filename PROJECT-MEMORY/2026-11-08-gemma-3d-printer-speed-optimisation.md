## 8 November 2026 — Research PC updater path friction removed

The Research PC was already in the correct installation folder and the `.env` file was visibly present there. Updated draft updater to auto-detect the current directory by `src/agent.mjs`, select sibling `.env`, and strip wrapping quotes if paths are explicitly supplied. This avoids asking owner to copy folder/file paths again. Await CI; then one command, no worker start. No LIVE data, tasks, approvals or imports changed.

## 8 November 2026 — Updater parser failure and corrected validation

The owner attempted the PR #300 updater on Research PC; PowerShell parser errors stopped execution before installation. No source files were installed and private `.env` was not changed. Root cause: truncated `SourceBranch` validation line and duplicated updater body. Rebuilt updater from production baseline, retaining existing safeguards and adding one explicit branch parameter. Added a PowerShell AST parser check to GitHub Actions. Do not ask owner to rerun until latest-head CI succeeds. Next: corrected updater run without `-StartWorker`, then local Ollama schema test; only then controlled 3D-printer task. No task queued, approvals/imports unchanged.

## 8 November 2026 — PR #300 CI and local test gate

PR #300 passed GitHub Actions run #219 at head `f8fe6f78ebf77c971526d650293a7f0d22951207` (source syntax, Gemma research tests, Owner Dashboard JavaScript syntax). It remains draft/open and not deployed. Updater in the branch accepts `-SourceBranch` (default production) for controlled draft-branch installation, preserving backups, local test gates, TEST/LIVE target validation and private .env. Research PC installation and Ollama schema compatibility are still pending; do not start worker or queue new research until verified.

## 8 November 2026 — benchmark learning and reliability follow-up

LIVE benchmark `owner-3d-printers-speed-benchmark-20261108-1645` completed in 25m 17s, compared with 70m 49s baseline (64.3% faster). Eleven pages were fetched using seven Gemma calls; five calls failed JSON extraction. All eleven raw captures and deterministic GBP observations remained in review-only queue; no approval/import. Gemma inference used about 92% of aggregate subtask runtime.

The failure is in `extractBatch()`: invalid/truncated model JSON is caught and immediately replaced by raw fallback. Follow-up branch `fix/gemma-3d-printer-json-reliability-20261108` adds a bounded JSON schema, source_id coverage validation, output-length termination diagnostics and regression coverage. This branch is a proposal only; GitHub Actions run 42505764030 (#215) passed 54/54 tests; Research PC Ollama/schema acceptance remains pending. Do not deploy or enqueue another full batch until verified. Preserve TEST/LIVE separation, private environment files and all owner/ChatGPT approval gates.

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

GitHub Actions run 42497005002 passed 53/53 tests and all syntax checks. This is code-level verification only; the change is not runtime-verified. Research PC Ollama acceptance is pending. Do not merge/deploy, update the Research PC, or queue another LIVE task until CI passes and the owner explicitly approves use of the existing updater. Preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. No approval/import behaviour may change.
