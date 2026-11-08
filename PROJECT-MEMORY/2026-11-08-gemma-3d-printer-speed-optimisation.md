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


## 8 November 2026 — Creality dynamic product discovery repair (TEST investigation)

### Reproduced failure

The controlled TEST task `owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-01` completed in 6.9 seconds but produced zero captures. Activity showed 11 search results, one approved-source collection candidate, zero HTML product links, and the explicit fallback message `site HTML only; no API fallback configured`. No product page was fetched and Gemma/Ollama calls remained zero. This isolated the current blocker to source discovery, not price extraction.

### Evidence and minimal change

The public Creality UK storefront exposes the individual Ender-3 V3 KE page at `https://store.creality.com/uk/products/ender-3-v3-ke-3d-printer` and category collections including `/uk/collections/fdm-3d-printer` and `/uk/collections/ender-3-v3-series`. The current playbook had an obsolete `/uk/collections/3d-printers` route and did not declare a supported collection API, so dynamically rendered product cards could not be enumerated.

A focused code change is on branch `fix/creality-dynamic-printer-discovery-20261108`: enable the already-implemented Shopify collection JSON fallback for `store.creality.com`, replace the obsolete collection route with the two verified Creality UK collection routes, and add a regression test requiring the exact Ender-3 V3 KE product to be discovered while rejecting Ender-3 V3 SE and upgrade-kit results. No price extraction, task queue, review policy, or LIVE settings are changed.

### Validation status

Automated CI and the next single controlled TEST run are still required. Do not claim the repair is complete until CI passes and the TEST worker captures the individual product page. Do not approve/import the capture. LIVE remains untouched.


### 8 November 2026 validation update

- PR #305 merged into `production` after the first CI run exposed two stale/missing test assertions; both were corrected, and the rerun passed all 69 tests with zero failures.
- Merge commit: `5b967ee7bba50ac5319a097d2d3555cb6149aaf8`.
- The Research PC still needs the production-branch updater applied before runtime verification. The next controlled TEST task must confirm that the Creality collection API fallback discovers the individual Ender-3 V3 KE page, captures its full page, and stages an unverified review record. The current earlier test task is completed with zero captures and must not be counted as success.
- No LIVE research task, database write, catalogue import or production worker restart was performed as part of this change.



## 8 November 2026 — LIVE 3D-printer watch, review-backlog state and current-production price-capture correction

Scope: category `3d-printers-equipment`, branch `3d-printers` only. Read-only LIVE audit at approximately 22:31 UTC. No research task was queued, no worker was restarted, and no evidence was approved or imported by this watch.

### LIVE worker and task state

- Category status row: idle; `current_task=null`; 81 tasks completed; 119 candidates found; `evidence_queued=65`; last recorded heartbeat/completion 2026-11-08 21:49:02 UTC; status-row worker identity `DESKTOP-LVASEUB-84452`; no last error.
- No queued/running/pending rows were found in `platform_ai_agent_tasks` for this category/branch.
- Latest registered platform task remains `owner-3d-printers-capture-only-smoke-20261108-2020`, worker `DESKTOP-LVASEUB-22608`, Anycubic Kobra S1 Max Standard, completed 20:18:57 UTC. Metrics: 10 search results; 1 product page discovered and fetched; 27 approved-source route attempts (10 matches, 11 empty, 6 errors); 4 collection pagination pages; 0 direct page-fetch errors; 0 Gemma calls; 1 existing LIVE review row enriched; 0 new rows; 20.796 seconds total.
- A separate activity-only `K1` dry-run completed at 21:49:02 UTC. It found one Creality UK source, fetched the K1 Speedy page, ran one Gemma call and reported one candidate, but made zero TEST/LIVE catalogue writes or lookups. It is not a row in `platform_ai_agent_tasks`. The target was Creality K1 Standard; the page title is K1 Speedy 3D Printer, visible text indicates in-stock, while structured Offer availability says OutOfStock. Retain this as a conflicting/borderline observation, not accepted evidence.
- Worker identities remain unreconciled: category status `DESKTOP-LVASEUB-84452`; capture-only platform task `DESKTOP-LVASEUB-22608`; generic worker identity previously recorded as `DESKTOP-LVASEUB-47588`. Do not infer multiple active processes from these stale/role-specific rows. Reconcile the installed Research PC process identity before restarting or running another batch.

### Source discovery and route failures

- The 3D-printer source registry currently has 13 enabled category rows. No registry change was made by this watch. PR #308 (category-scoped source loading) is closed unmerged; do not treat its proposed source changes as deployed.
- The Kobra capture-only run had 6 route errors: Uni3Dverse 404; eBay UK 403 twice and 404 once; Amazon UK 404; SecondHand.org.uk 404. 11 routes were empty. The single discovered page was the official Anycubic page, not a used-market listing.
- The later K1 dry-run found one Creality URL; 3D Prima and 3DJake search routes returned no exact-model product link; eBay routes returned 403/404; Amazon routes returned 404. Unrelated camera-category sources were correctly skipped.

### Review queue — new state since the previous checkpoint

A LIVE activity event at 22:08:30 UTC records a ChatGPT-supervisor evidence-backlog operation: 65 rows processed, 28 matched/imported, 37 processed without import, raw captures retained, zero open review rows. Current queue statuses are 28 `imported` and 37 `rejected`. The 28 linked `shared_market_evidence` records comprise 23 `uk_new` and 5 `uk_used`; all 28 have a GBP observed price. This watch did not perform that operation and did not modify queue/evidence rows.

Audit caveat: all 28 imported queue rows have `approved_at` and `imported_at`, but only one has `reviewed_by` populated; 27 have no reviewer identity recorded. The activity event identifies the workflow as ChatGPT supervisor but does not establish the human authorisation. Preserve this as an audit gap; do not reverse, re-import, approve or otherwise alter these records without owner direction. The status-row `evidence_queued=65` predates this 22:08 processing event and is not the current open-row count.

### First confirmed price-capture loss and correction

Current production `extractRelevantPageText()` still appends matching JSON-LD Product/Offer text after flattened page content and formats offers as `Price: 549 Currency: GBP`. The deterministic GBP parser recognises `£549` or `GBP 549`, so structured GBP offer values are not parsed from that format. This is a post-fetch extraction loss; the page text itself is retained. The earlier 9,998-character capture predates PR #302's 100,000-character 3D-printer cap and must not be used to claim the new cap failed.

PR #306 contains the fix and passed CI run #352 (73 tests), but its base is stale after PR #305 merged and GitHub reports it non-mergeable. The same focused change has been ported onto a fresh branch based on current production: `fix/gemma-3d-jsonld-gbp-capture-current-prod-20261108`. It formats GBP structured offers as `GBP <amount>`, places matching structured facts before long flattened text for 3D printers only, leaves other categories content-first, and adds four regression tests (long-page retention, multiple GBP offers/non-GBP exclusion, non-GBP-only exclusion, and non-3D ordering). CI is pending. No merge or deployment is authorised.

### Next verification gate

Wait for CI on the fresh current-production branch. If green, keep the PR for review. Research PC TEST installation and replay must be separately authorised and must preserve the existing private `.env`. Do not start LIVE research, enqueue duplicate tasks, change other categories, or approve/import evidence as part of the verification.



### PR handoff correction — 8 November 2026, 22:38 UTC

- The previous non-mergeable PR #306 was closed as superseded; it was not merged.
- Its reviewed code and regression tests were ported onto the fresh current-production branch `fix/gemma-3d-jsonld-gbp-capture-current-prod-20261108` and opened as draft PR #310: https://github.com/laurendigitaluk/TradeFlow/pull/310.
- PR #310 CI has not yet appeared in the commit workflow-run listing. Do not call it tested or mergeable until the current head receives a green CI run. No deployment or Research PC install has occurred.



### Final PR #310 verification — 8 November 2026, 22:39 UTC

- Final code/test head `e07f456339bf3c9021b8b89005918e91860c82f6` passed GitHub Actions run #371: 73 tests passed, 0 failed; PowerShell updater syntax, Node source syntax and Owner Dashboard JavaScript syntax also passed.
- The long-page regression explicitly checks the before/after parser result: old `Price: 169.00 Currency: GBP` rendering returns 0 recognised GBP prices; the corrected structured rendering returns exactly 1. The multi-offer fixture recognises two GBP offers and excludes the USD offer.
- PR #310 is open, ready for review and mergeable. It remains unmerged and undeployed. CI is not Research PC runtime verification; owner-authorised TEST installation/replay remains the next gate.
