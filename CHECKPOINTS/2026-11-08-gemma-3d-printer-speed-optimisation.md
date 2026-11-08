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


## 8 November 2026 — restore capture-first research architecture

Owner confirmed the intended division: Gemma should collect as much source information as possible in the shortest time; ChatGPT should interpret and decide evidence suitability. Review of the current implementation showed the 3D-printer worker still called extractBatch() and waited for local Ollama structured generation before it could use fallbackPageCapture(). A timeout therefore delayed the exact raw capture that was already available.

Changed the 3D-printer path so it bypasses Ollama/Gemma inference entirely after source discovery and page fetch. It now immediately retains each fetched page through deterministic capture: title, URL, extracted page text, all visible GBP observations and contexts, package/variant snippets, condition snippets, availability snippets and UK/location clues. It records capture_only_started, page_capture_retained and capture_only_completed; the 3D-printer gemma_extraction_ms metric is zero and no Ollama extraction is called. Other research categories retain their existing extraction path.

For 3D-printer captures, observed_price is always null and evidence_type remains null until ChatGPT review. A page containing only one price is not enough to promote that amount to a product price. The raw page and its price context are retained for ChatGPT to determine the correct product/package/condition. All detected price contexts are preserved rather than limiting the context array to the first 12. The queue remains needs_research / unverified_capture; no approval or import is authorised.

Added/updated tests to ensure a single visible printer price is never promoted before review, the page text and price observation remain available, and the prior fallback test now expects a null top-level price.

Important integration boundary: the inspected TradeFlow research worker stages raw captures in platform_catalogue_research_queue for ChatGPT review; no direct OpenAI/ChatGPT API call was found in this worker. ChatGPT analysis is therefore a downstream review/handoff, not an automatic API stage in this code path. Do not describe it as automatically analysed until a separate, explicitly configured analysis integration exists.

PR #302 remains draft and unmerged. The Research PC has the draft installed, but the worker has not been restarted. Do not start the worker until this capture-only change passes CI and the updated launcher/source is installed. No LIVE or TEST queue rows were changed by this code edit; no task was started, approved or imported. Current CI run #312 (42518986367) is pending at the time of this documentation update.

Next gate: complete CI, install the updated capture-only branch on the Research PC without starting the worker, then run one controlled 3D-printer capture-only task. Verify fast page capture, all visible prices/contexts in the LIVE review queue, null top-level price/evidence type, and no Ollama inference or timeout. ChatGPT then reviews the retained page.


## 8 November 2026 — capture-only implementation CI verification

The capture-first 3D-printer change passed GitHub Actions run #312 (run ID 42518986367) on implementation commit 48eec9d682aa0d8ff6ecdb5f3ee0463a98a46596. Result: 61 tests passed, 0 failed. PowerShell updater/launcher syntax, all Gemma source syntax checks and Owner Dashboard JavaScript syntax also passed. PR #302 remains draft and unmerged; current branch head after documentation commits is 6763e76dbce6ef37cbffaab74b3e5a6fdaff6904.

The Research PC still has the earlier draft version installed. It must be updated again to this capture-only branch before a controlled task is run. Do not start the worker until the user has installed the latest branch and we have verified the installed source. No research task or queue write has been performed by this code verification.


## 8 November 2026 — LIVE capture-only smoke result and complete-page retention

The first controlled LIVE capture-only smoke task owner-3d-printers-capture-only-smoke-20261108-2020 completed successfully on worker DESKTOP-LVASEUB-22608 in 20.796 seconds (started 20:18:35.877 UTC; completed 20:18:57.315 UTC). Task result: 10 search results, one exact product page discovered/fetched, one review capture retained/enriched, zero Gemma calls, zero Gemma extraction milliseconds, 781 ms product-page fetch, 124 ms LIVE queue write. No Ollama call or timeout occurred. The task completed with no task error.

The captured Anycubic Kobra S1 Max page preserved separate GBP observations for £549, £849, £300 saving, £749, £935 and £1,307. Top-level observed_price and evidence_type remained null; row status remained needs_research; review/approval/import fields were untouched. The capture was enriched into existing LIVE review row 2dd24f89-7165-4b1a-9f75-7a96cf40430c (dedupe match to earlier Kobra S1 Max capture), not inserted as a new duplicate row. Six observations in page_capture.gbp_price_mentions; no catalogue valuation was promoted.

Smoke review found an additional data-retention defect: the HTML-to-text extractor, fallback capture, and enrichment history imposed 10,000 / 4,000 character limits. The fetched page was therefore not being preserved completely. Updated 3D-printer capture path to allow up to 100,000 characters at HTML text extraction and to preserve the full extracted text in source_excerpt, page_capture.captured_text and raw_payload.enrichment_history.page_capture_excerpt. Existing 10,000-character defaults remain unchanged for non-printer categories. Added regression tests for full captures over 10,000 characters and configurable extraction limit.

GitHub Actions run #322 (42519658760) passed on commit f08259de763dfef0f1e4b75e3d7cfdeac6e22892: 63 tests passed, 0 failed; PowerShell updater syntax, Gemma source syntax and Owner Dashboard JavaScript syntax passed. PR #302 remains draft/unmerged. The Research PC currently has the earlier capture-only version installed; it must be stopped and updated to this full-capture build before another task. Do not run another task until updated source is installed. No new research task was created after the smoke run; no approvals/imports or TEST writes occurred.

Known remaining issue: only one product page was discovered/fetched from 10 search results. Approved-source probing attempted 27 routes across 12 approved sources; 10 found matches, 11 empty, 6 failed (eBay 403s and route 404s included). The capture-first latency is now good, but discovery/source coverage needs separate improvement after full-page retention is installed and verified.


## 8 November 2026 — TEST/LIVE control-plane isolation correction

A Research PC screenshot exposed a critical integration fault after the local source suite passed: the launcher printed that it was starting the LIVE Gemma queue worker, and the worker itself declared `control plane: LIVE only; TEST retained for software regression`. The updater's optional `-StartWorker` path and the installed launcher both hard-coded LIVE. Therefore the 63 passing tests did not validate a TEST worker, and the earlier instruction to proceed with a controlled TEST task was not safe.

Corrective work on PR #302 now adds `src/control-plane.mjs` with a strict allowlist for the two approved project IDs. Worker environment selection defaults to TEST; LIVE requires an explicit `TRADEFLOW_GEMMA_ENVIRONMENT=LIVE` selection. The selected URL is checked against its exact approved project ID and only that environment's service-role credentials are used. The queue worker, Common Room RPCs, research-source registry reads, review-queue writes and agent telemetry all use the selected control plane. The PowerShell launcher and updater default to TEST, accept only TEST or LIVE, and print the selected environment. The new control-plane tests cover TEST default, explicit LIVE, invalid environment names, mismatched project URLs and missing credentials. CI and full regression suite are pending for this correction; do not merge or restart the worker until they pass.

TEST project `nnsshnfkjcflucjrftzi` was inspected read-only: 51 approved research-source rows total, 3 enabled sources scoped to `3d-printers-equipment`, 0 queued tasks and 0 review-queue rows. Its 3D-printer agents were idle; the equipment agent's last heartbeat was historical (2026-11-07 12:12:55 UTC). No TEST task was created and no TEST queue rows were changed during this inspection. Do not use the owner dashboard. The next gate is CI, then a TEST-only worker start and a single bounded TEST task, followed by verification that all source reads, queue writes, Common Room traffic and telemetry remain in TEST. LIVE remains out of scope.


## 8 November 2026 — TEST Common Room schema gap found and repaired

After the Research PC was updated from production and started with the default TEST control plane, its console confirmed TEST-only operation. The first Common Room RPC calls failed with PostgREST HTTP 404 / PGRST202. Direct inspection of TEST project `nnsshnfkjcflucjrftzi` confirmed the root cause: the TEST database did not contain `public.platform_ai_agent_messages`, `platform_ai_agent_post_message`, or `platform_ai_agent_list_messages`. The task queue RPCs were present. This was a missing TEST schema migration, not an environment-routing error and not a LIVE connection.

Applied the repository's existing Common Room migrations to TEST only, using the exact production SQL files: `20261107190000_platform_ai_agent_common_room.sql` (table, indexes, RLS, grants and owner/agent RPCs), `20261107162000_harden_common_room_agent_post.sql`, and `20261107163000_harden_common_room_owner_rpcs.sql`. All three migration calls returned success. Post-migration verification confirms the messages table and both worker RPC signatures now exist. The TEST Common Room currently has zero messages; no task or review-queue rows were created by this repair. LIVE was not accessed or modified.

The running worker's idle loop retries the Common Room inbox read on its normal polling cycle. Confirm the repeated PGRST202 errors have stopped and that the worker remains on TEST before enqueueing a controlled task. If the old PostgREST schema cache continues to report PGRST202, stop and restart the worker once to reconnect; do not change its environment or use the dashboard. Keep the first research task bounded to one 3D-printer product and inspect all captured prices before any approval/import.


## 8 November 2026 — TEST task enqueue compatibility and first controlled task

The owner explicitly required TEST-only verification and reported that Gemma stopped producing results after the recent control-plane change. Investigation of TEST project `nnsshnfkjcflucjrftzi` found two separate gaps:

1. Common Room RPC schema was missing initially. The existing production Common Room migrations were applied to TEST and both worker RPC signatures plus the messages table were verified. A PostgREST schema-cache reload was requested. Common Room read/write failures are ancillary: the current worker catches these failures and continues without Common Room context; they do not block the research task loop.
2. TEST had the task table and worker claim/complete/fail RPCs, but it did not have `platform_owner_enqueue_ai_agent_task`. Consequently, no task could be submitted through the normal owner enqueue path. TEST contained zero tasks and zero review rows. This is the key reason the worker had nothing to research. The production source migration `20261107130000_gemma_live_supervisor_control_plane.sql` contains this owner enqueue RPC, but its LIVE-only scope comment meant it had not been installed in TEST.

Minimal TEST-only repair: installed `platform_owner_enqueue_ai_agent_task(text,jsonb,integer)` with the same owner-membership check, task-key idempotency, payload validation, priority bounds and authenticated grant as the existing production migration. No existing task, review queue, catalogue, source, customer, tenant or LIVE data was modified.

A single bounded TEST task was then enqueued through that RPC using the active platform owner membership: `owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-01`, for Creality Ender-3 V3 KE, Standard Printer, UK new-price research only. Queue task UUID: `b7b1463f-0f90-4f83-9b4b-d0e76780e587`. It is queued, not yet claimed; the Research PC worker was stopped by the owner before this task was enqueued. TEST currently has three enabled 3D-printer sources (Creality UK Official Store, 3D Prima UK, 3DJake UK). Next: restart the already-updated worker in its existing folder; it defaults to TEST and should claim this one task. Verify heartbeat, task claim, page captures and TEST review-queue rows. Do not use the dashboard, do not select LIVE, and do not approve/import any result.
