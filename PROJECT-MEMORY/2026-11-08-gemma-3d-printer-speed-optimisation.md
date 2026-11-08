## 8 November 2026 — Launcher/test-suite mismatch corrected in PR #300

After the Research PC accepted the strict JSON schema and returned populated Bambu Lab A1 Standard fields (source TEST02, £289.00, Brand new, In stock), starting the worker failed safely: the locally retained legacy launcher ran stale `test/agent.test.mjs` and `test/collection-discovery.test.mjs`, which import the removed `combineProductResearchTasks` export. The PR updater had only replaced `src` files and did not replace the root launcher, so its own 55 source tests passed while the stale launcher gate failed. Corrected PR #300 by adding a version-controlled `Start-TradeFlow-Gemma.ps1` that runs exactly the four current source test files before starting `src/task-worker.mjs`, and updating `Update-TradeFlow-Gemma.ps1` to download, back up and install this matching launcher alongside source files, with PowerShell parser validation. GitHub Actions now syntax-checks both updater and launcher. This correction is still in PR #300 and has not been installed or deployed. Next: wait for CI on the latest PR head; if green, ask owner to run updater once (worker remains stopped), verify updated launcher is installed, then start worker and run one controlled review-only task. Do not manually delete legacy tests or bypass tests. No database, approvals, imports, or LIVE catalogue data changed.

## 8 November 2026 — Structured-output smoke test finding

Owner tested local Ollama 0.4.14 with `gemma3:4b`; strict JSON schema was accepted and response parsed, but title and price fields were blank despite supplied input. PR #300 updated core schema fields to require non-empty values and added explicit prompt rules to copy supplied page title and visible GBP prices. CI run #251 passed PowerShell parser, source syntax, Gemma tests and Owner Dashboard syntax. No worker restart or research task yet. Latest PR remains draft/unmerged; next controlled step is install current branch and verify a populated one-page response.

## 8 November 2026 — Gemma batch failure recovery

Added isolated per-page recovery in PR #300 after failed 3D-printer multi-page extraction. Two-page batch remains the normal fast path. On failure, each page is retried separately with a compact excerpt, exact one-page schema and 1,024-token output cap. Successful retries are structured; only failed retries use raw fallback. Run #244 passed all CI gates. No research task was queued, no evidence approved/imported, and no LIVE database rows changed. PR remains draft/open; Research PC installation and Ollama schema compatibility are outstanding.

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

## 2026-11-08 — Explicit Gemma price-observation contract (PR #302)

The 3D-printer extraction contract now represents every visible GBP amount as a separate `price_observations` item. Each item contains the exact displayed price, nearby source context, product/variant association, price role, condition and availability. Gemma must not associate a price with the requested product based only on proximity; uncertain associations remain `ambiguous` for ChatGPT review. The JSON schema and downstream consumer now agree on the allowed fields. The worker cross-checks every reported amount against deterministic GBP observations extracted from the fetched page. It only sets `observed_price` when exactly one source-verified observation is explicitly associated with the requested product; otherwise it leaves the price unset. This remains an unverified review capture, never an approval/import decision.

Scope is limited to category `3d-printers-equipment`, branch `3d-printers`. PR #302 is draft and not merged or deployed. No Research PC installation, worker restart, LIVE task, TEST/LIVE data mutation, source registry change, approval or import has occurred. CI and historical-capture replay remain required before installation.


## 8 November 2026 — PR #302 CI finding and context-verification correction

The first PR #302 CI run (#272) failed one legacy assertion in `agent-speed.test.mjs`: it still expected the retired `price_mentions` prompt field. The other 55 tests passed, including the new observation-schema checks and PowerShell/source syntax checks. Updated that assertion to the new contract. During review of the actual downstream consumer, found that price verification matched only the numeric amount against the page, not the observation's nearby context. Tightened the prompt to require exact copying of the supplied context and changed the consumer to require both the exact extracted GBP amount and an exact normalised match to the deterministic page-context excerpt before setting `source_context_verified` or selecting `observed_price`. Also corrected the GBP parser to accept both £ and GBP values. Latest branch head: `734f184765dd9971f15334f5461af853fd798490`; latest CI result not yet available. PR remains draft and unmerged. No Research PC, Ollama runtime, LIVE/TEST database, task queue, approvals or imports changed. Historical capture replay remains the next acceptance gate after CI passes.


## 8 November 2026 — historical capture replay, price parsing and condition-lane gate

Historical LIVE capture review found the old parser was counting split-decimal renderings twice (for example £13.99 £ 13 . 99) and globally de-duplicating equal amounts even when they appeared in separate product/variant contexts. The parser now accepts split decimals, collapses only an adjacent duplicate rendering, and preserves the same amount when it occurs elsewhere with a distinct context.

The observation schema now constrains price_role and association to explicit values. The downstream selector only populates observed_price when the observation has exact source-context verification, requested_product association, current role, and a clear condition matching the task's research lane. Crossed-out, saving, other-variant, accessory, delivery, protection-plan and warranty amounts cannot be promoted. If more than one distinct current requested-product amount remains, the top-level price stays null.

Historical capture fixtures are based on retained LIVE pages:
- Anycubic Kobra S1 Max page: standard printer, crossed-out/regular, saving, 4-colour, 8-colour and 16-colour amounts remain separate.
- Amazon Bambu Lab A1 Combo page: printer price remains distinct from protection-plan and insurance amounts; split-decimal duplicate rendering is collapsed.
- LIVE ELEGOO Neptune 4 Pro smoke capture: one page fetched; Gemma extraction took 224,986 ms; the old extractor returned no structured price/evidence type and retained the page with 14 visible GBP amounts spanning Neptune 4 Pro, Neptune 4, Neptune 3 Pro, open-box and bundle options. The review row remained needs_research, with no observed_price, no evidence_type, no approval and no import. This is a historical runtime observation, not a test of the new schema.
- The YIBEICO A1 screw-set false positive remains a separate issue in draft PR #301; it must not be treated as a printer-price observation or folded into this PR.

GitHub Actions run #293 (42516334199) passed on code commit 13feb193c6cd7741c0fc50092b0ffb8189532dfb: 60 tests passed, 0 failed; PowerShell syntax, Gemma source syntax and Owner Dashboard JavaScript syntax passed. PR #302 remains draft and unmerged. production remains the PR base (a0cf801a809e9428f66254ec66fc43ba52a77647); compare reports the draft branch ahead 88, behind 0. No Research PC installation, Ollama runtime test, new task, LIVE/TEST queue mutation, approval or import has occurred. No 3D-printer tasks are currently non-terminal in platform_ai_agent_tasks; the last recorded agent status was idle at 19:01 UTC, so its heartbeat is historical rather than a current liveness claim.

Next gate: inspect the PR preview/source contract, then install the verified draft on the Research PC using the versioned updater without starting the worker. Test local Ollama schema output with one retained page before any controlled review-only task. Keep PR #301 accessory filtering separate and retain all review/import gates.
