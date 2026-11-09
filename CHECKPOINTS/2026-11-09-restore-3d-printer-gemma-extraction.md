# Checkpoint — Restore 3D-printer Gemma extraction

Date: 9 November 2026 (UTC)
Branch: fix/restore-3d-printer-gemma-extraction-20261109
PR: #320 — https://github.com/laurendigitaluk/TradeFlow/pull/320

## Confirmed regression
PR #316 changed `isCaptureOnlyResearchTask()` to return true for both 3D-printer and Gaming tasks. This caused the 3D-printer worker to skip `extractBatch()` and local Ollama/Gemma inference. LIVE task `owner-3d-printers-live-verification-k1max-20261109-01` (id `0ce88391-e5c2-45c4-adf9-149d364c702c`) explicitly recorded the capture-only stage and `gemma_calls: 0`. It retained a raw page capture but did not produce a new review-queue row because the matching source capture was duplicate-skipped. This is the concrete regression introduced by the Gaming rollout.

## Separate discovery issue
LIVE task `owner-3d-printers-live-verification-20261109-01` (id `5b3e53b0-b857-4f0b-89a0-e255596afd3c`) completed with 11 search results but zero eligible product pages; two Creality collection routes returned Shopify JSON 404. This is a distinct source-discovery problem, not evidence that Gemma extraction itself failed.

## Current LIVE source settings
The enabled 3D-printer source registry remains populated with the existing UK-new, UK-used and universal sources. No source rows were changed during this repair. Research PC configuration and worker installation were not changed.

## Correction
PR #320 changes only `isCaptureOnlyResearchTask()` so that Gaming remains capture-only and 3D printers resume the established Gemma/Ollama `extractBatch()` workflow. It adds a regression test asserting 3D printer false / Gaming true. Raw fallback and ChatGPT review remain in place. No catalogue data, queue records, approvals, imports or TEST data are modified.

## Verification gate
- CI workflow: Gemma Research Tests, run #415 (commit `80fd19836aa7396da827c788209e9e7168db4281`).
- After merge, run one controlled 3D-printer LIVE task only after checking worker status; confirm `extraction_batch_started`, `gemma_calls > 0`, and a new/enriched review capture as appropriate.
- Do not alter 3D source settings or Research PC installation unless independent telemetry proves they need attention.


## 9 November 2026 04:27 UTC — LIVE 3D-printer worker and idle-heartbeat watch

Scope: LIVE project only, category `3d-printers-equipment`, branch `3d-printers`. TEST project `nnsshnfkjcflucjrftzi` was not read or changed in this watch. LIVE project `gxsrajtqzdjvmceqcpgv` was queried read-only.

### Current LIVE task and worker state
- Exactly 19 registered `platform_ai_agent_tasks` rows match this category/branch: 19 completed, 0 queued, 0 running, 0 failed. Latest registered task completed 2026-11-09 01:56:42 UTC. No post-merge research task exists after PR #320 merged at 02:06:14 UTC.
- Category status `3d-printers-equipment`: idle; cumulative counters 85 tasks / 122 candidates; last status heartbeat 01:56:42 UTC; metadata worker `DESKTOP-LVASEUB-84452`. Generic `gemma-task-worker`: idle; worker `DESKTOP-LVASEUB-86464`; last status update 01:16:09 UTC. Alias `3d-printers` remains `registered_not_started` with no heartbeat. These are separate status records; do not assume the IDs are one process.
- Latest Ender-3 V3 KE task (01:55:49–01:56:09): 11 search results, 0 exact product pages discovered/fetched, 0 Gemma calls, 0 candidates. It attempted 28 approved-source routes (11 matched route candidates, 11 empty, 6 failed); two Creality collection JSON routes returned 404.
- Latest K1 Max task (01:56:24–01:56:42): 11 search results, 1 exact product page discovered/fetched, 0 Gemma calls because this task ran before PR #320 merged, 1 raw candidate, queue write `duplicate-skipped`. The duplicate is already linked to active LIVE `uk_new` evidence at £589 GBP. It is not a lost new evidence row.
- Earlier Kobra S1 Max capture-only task: 10 search results, 1 page discovered/fetched, 0 Gemma calls, 1 existing review row enriched, 0 new rows, 20.796 seconds. Earlier Neptune 4 Pro extraction run: 16 search results, 1 page discovered/fetched, 1 Gemma call, no batch failure, 248.309 seconds. Six-product baseline: 123 search results, 30 pages discovered, 18 fetched, 18 Gemma calls, 10 extraction failures, 70m49s.

### First point where useful results are lost
- The current measurable bottleneck is search/source probing to exact individual product-page discovery. Ender-3 V3 KE returned 11 search results but zero exact product pages. K1 Max returned 11 search results and one exact page. The `approved_source_routes_found` metric counts matching route candidates, not confirmed exact product pages.
- For the K1 Max page that was found and fetched, the next loss was the pre-merge capture-only branch bypassing Gemma. PR #320 corrected that production regression. No post-merge LIVE task has yet verified the restored extraction path.
- Repeated route failures: Uni3Dverse HTTP 404; eBay UK HTTP 403/404; Amazon UK HTTP 404; SecondHand.org.uk HTTP 404; Creality Shopify collection products JSON HTTP 404. No direct product-page fetch errors occurred in the latest K1 Max task.
- LIVE source registry currently has 15 enabled GB sources for this category: 13 category-specific plus 2 universal (Amazon/eBay). No source rows were changed.

### Review queue and evidence state
- 65 historical 3D-printer review rows: 28 imported, 37 rejected, 0 open. The 28 linked active `shared_market_evidence` records comprise 23 `uk_new` and 5 `uk_used`; all 28 have GBP prices.
- Reviewer audit exception: 27/28 imported queue rows have `reviewed_by IS NULL`; across all 65 queue rows, 64 have no reviewer ID. This is an audit gap, not proof by itself of unauthorised approval. Do not alter these records without owner direction.
- No queue row, shared evidence record, approval or import was changed by this watch.

### Production correction and heartbeat observability
- PR #320 merged to production at 02:06:14 UTC as `e81ede671bfc03e73dc16169638011372b5b6117`; final CI run #419 passed 80/80 tests. Current production `agent.mjs` confirms 3D-printer tasks use the established Gemma/Ollama extraction path; Gaming alone remains capture-only. The Research PC has not yet demonstrated this post-merge behaviour.
- Current production `task-worker.mjs` reports `worker_started` once and sends periodic task heartbeats only inside `processClaim()`. Its idle polling loop does not refresh `last_heartbeat`; a stale idle timestamp cannot distinguish a running idle process from a stopped process.
- New current-production feature branch: `fix/gemma-idle-worker-heartbeat-current-production-20261109`; PR #322. It adds a generic queue-worker idle heartbeat after successful queue polls, bounded to 60 seconds–5 minutes and suppressed during active polls/tasks, failed polls, shutdown or overlapping heartbeat writes. Four regression tests cover cadence, invalid intervals, gating and generic-only telemetry. Updater, launcher and CI test lists include the new helper/test. CI run #421 is pending at the time of this note. No merge/deployment or Research PC installation has occurred.
- Existing PR #319 was based on an older production commit and diverged from current production (27 ahead / 6 behind); it is superseded by the current-production branch. PR #321's post-merge documentation is consolidated into this branch.

### Safety and next gate
- No research task queued or duplicated; no worker restarted; no source registry, category, TEST/LIVE setting, credential or private `.env` changed.
- No catalogue evidence was approved or imported.
- After PR #322 CI passes and review/explicit owner approval, install the reviewed production-based branch without starting the worker, preserve the existing private `.env`, run the installed tests, then verify a fresh idle heartbeat for the same LIVE worker ID. Separately, only after the Research PC version is confirmed should one bounded 3D-printer task be considered to verify `extraction_batch_started`, `gemma_calls > 0`, and a review-only handoff. Do not queue a task merely to test idle heartbeat.
