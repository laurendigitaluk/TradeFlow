## 8 November 2026 — Launcher/test-suite mismatch corrected in PR #300

After the Research PC accepted the strict JSON schema and returned populated Bambu Lab A1 Standard fields (source TEST02, £289.00, Brand new, In stock), starting the worker failed safely: the locally retained legacy launcher ran stale `test/agent.test.mjs` and `test/collection-discovery.test.mjs`, which import the removed `combineProductResearchTasks` export. The PR updater had only replaced `src` files and did not replace the root launcher, so its own 55 source tests passed while the stale launcher gate failed. Corrected PR #300 by adding a version-controlled `Start-TradeFlow-Gemma.ps1` that runs exactly the four current source test files before starting `src/task-worker.mjs`, and updating `Update-TradeFlow-Gemma.ps1` to download, back up and install this matching launcher alongside source files, with PowerShell parser validation. GitHub Actions now syntax-checks both updater and launcher. This correction is still in PR #300 and has not been installed or deployed. Next: wait for CI on the latest PR head; if green, ask owner to run updater once (worker remains stopped), verify updated launcher is installed, then start worker and run one controlled review-only task. Do not manually delete legacy tests or bypass tests. No database, approvals, imports, or LIVE catalogue data changed.

## 8 November 2026 — Required extraction fields enforced

Ollama schema acceptance alone was not sufficient: the real Gemma smoke test produced valid JSON with blank title and price fields. PR #300 now enforces non-empty core fields and directs exact copy of supplied title/visible GBP amounts. CI run #251 passed. Research PC must be updated to latest PR branch and one-page output retested before worker restart or research task.

## 8 November 2026 — Single-page recovery added

PR #300 keeps two-page extraction for speed, but on malformed/truncated output retries the pages separately using a shorter excerpt, one-finding schema and 1,024-token budget. Each successful retry becomes structured data; only failed retries remain raw fallback. Run #244 passed all CI checks. Draft PR is not merged/deployed and local Ollama support is not yet proven.

## 8 November 2026 — Updater path handling simplified

Research PC screenshots confirmed PowerShell was already in the installed Gemma folder and `.env` existed beside it. Updater now auto-detects current folder from `src/agent.mjs`, selects adjacent `.env`, and strips outer quotes on explicit paths. Wait for latest-head CI, then one launch command only; no manual path prompts expected. Do not start worker until installation and local Ollama schema test pass.

## 8 November 2026 — Updater parser failure repaired in PR #300

Research PC attempt failed at PowerShell parse time; installation did not begin and existing `.env` was not changed. Root cause: truncated branch validation and duplicated updater body in PR branch. Rebuilt updater from production baseline with explicit `-SourceBranch` parameter, defaulting to production. Added PowerShell parser validation to Gemma CI. Await latest-head CI result, then request one controlled owner-side updater run with no worker start. Local Ollama JSON-schema acceptance is still the gate before further 3D-printer research.

## 8 November 2026 — PR #300 CI passed

PR #300 head `f8fe6f78ebf77c971526d650293a7f0d22951207` passed GitHub Actions run #219, including source syntax, Gemma task/playbook tests and Owner Dashboard JavaScript syntax. PR remains draft/open and is not deployed. The branch updater now accepts `-SourceBranch` (default `production`) for controlled local installation of the draft branch; existing backups, Node test gates, TEST/LIVE URL checks and private .env preservation remain. Next gate: Research PC installation without starting worker, then Ollama schema compatibility check. No new task queued.

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

## 2026-11-08 — Explicit Gemma price-observation contract (PR #302)

The 3D-printer extraction contract now represents every visible GBP amount as a separate `price_observations` item. Each item contains the exact displayed price, nearby source context, product/variant association, price role, condition and availability. Gemma must not associate a price with the requested product based only on proximity; uncertain associations remain `ambiguous` for ChatGPT review. The JSON schema and downstream consumer now agree on the allowed fields. The worker cross-checks every reported amount against deterministic GBP observations extracted from the fetched page. It only sets `observed_price` when exactly one source-verified observation is explicitly associated with the requested product; otherwise it leaves the price unset. This remains an unverified review capture, never an approval/import decision.

Scope is limited to category `3d-printers-equipment`, branch `3d-printers`. PR #302 is draft and not merged or deployed. No Research PC installation, worker restart, LIVE task, TEST/LIVE data mutation, source registry change, approval or import has occurred. CI and historical-capture replay remain required before installation.


## 8 November 2026 — PR #302 CI finding and context-verification correction

The first PR #302 CI run (#272) failed one legacy assertion in `agent-speed.test.mjs`: it still expected the retired `price_mentions` prompt field. The other 55 tests passed, including the new observation-schema checks and PowerShell/source syntax checks. Updated that assertion to the new contract. During review of the actual downstream consumer, found that price verification matched only the numeric amount against the page, not the observation's nearby context. Tightened the prompt to require exact copying of the supplied context and changed the consumer to require both the exact extracted GBP amount and an exact normalised match to the deterministic page-context excerpt before setting `source_context_verified` or selecting `observed_price`. Also corrected the GBP parser to accept both £ and GBP values. Latest branch head: `734f184765dd9971f15334f5461af853fd798490`; latest CI result not yet available. PR remains draft and unmerged. No Research PC, Ollama runtime, LIVE/TEST database, task queue, approvals or imports changed. Historical capture replay remains the next acceptance gate after CI passes.
