# 3D Printers Gemma project memory — 9 November 2026

Owner requirement: one independent Gemma per category. This work is confined to branch `gemma/3d-printers` and PC clone `C:\CTFGemma2\Gemma-3D-Printers`. Do not modify any other category branch or folder.

## Current runtime
- Independent 3D Printer Gemma was started from the new local folder on 9 Nov 2026.
- LIVE control plane: `gxsrajtqzdjvmceqcpgv`.
- Canonical key: `3d-printers-equipment`.
- Config branch: `gemma/3d-printers`.
- Screenshot showed all eight isolation/startup tests passing and the worker polling LIVE at 15 seconds.
- Supabase activity recorded a worker_started event for the isolated key. No new research batch has yet been completed by this new process.
- Keep only one 3D Printer process active against LIVE. Do not run the old shared 3D Printer worker concurrently.

## Findings and targeted changes
- Existing Anycubic route playbook contains UK collection/search routes and direct model routes for Kobra 3 Max V2, Kobra 4 and Kobra S1.
- New regression test covers both Kobra 3 Max V2 machine-only and ACE 2 Pro Combo direct routes, Kobra 4 direct route, Kobra S1 combo route, plus collection/search routes.
- The prior eight-product task `owner-3d-printers-equipment-1794264123497` failed at `platform_ai_agent_complete_task` with PostgREST `PGRST102 Empty or invalid json`. It had performed product page fetches and extraction, but the full task result was not saved.
- The exact cause of PGRST102 was not conclusively proven. The worker had been duplicating large raw page captures in the task completion JSON even though captures are already stored separately in the review queue. A targeted compact-summary change removes raw captures and long excerpts from the task completion payload while retaining product identity, capture URLs, classification, price observations, queue-write references, metrics and bounded failures.
- Compact result helper and regression tests live in `src/task-result-summary.mjs` and `src/task-result-summary.test.mjs`.
- CI run `42720630028` passed after the compact-summary and Anycubic-route tests.

## Next
1. Stop the current independent 3D Printer worker cleanly.
2. Run the folder-local `Update-Gemma-Agent.ps1 -Environment LIVE` from this clone. It updates only `gemma/3d-printers`.
3. Restart Gemma 3D Printers from its desktop shortcut.
4. Queue one controlled block of 3D Printer tasks (the intended eight Anycubic model/package tasks are suitable once the owner dashboard queue is refreshed).
5. Confirm all tasks complete without PGRST102, inspect route attempts, page fetches and review queue captures. Keep evidence unapproved pending ChatGPT/owner review.
6. Lock this branch/folder at a verified checkpoint before any Gaming work.

Do not update the old shared Research Control Centre, other category clones, Supabase schema, queue RPCs or category source configuration as part of this fix.


## 9 November 2026 — 3D Printer updater package and heartbeat-stage hardening

A review of the isolated `gemma/3d-printers` branch found that `task-worker.mjs` imports `task-result-summary.mjs`, but the category-local `Update-TradeFlow-Gemma.ps1` source manifest did not download that helper or its regression test. Its pre-install and post-install test lists also omitted the compact-result test. Running that updater from a clone with this manifest could therefore install a worker whose relative helper import is missing. The updater itself is not self-updating; the local clone must first be fast-forwarded to the current `gemma/3d-printers` branch before the folder-local updater is run.

The 22:42–22:46 LIVE eight-product task also recorded four worker heartbeat events with `details.stage='extraction_batch_started'`. The activity table consequently counted eight `extraction_batch_started` stage events even though only four extraction batches actually started; the other four were heartbeat telemetry. The proposed correction assigns heartbeat events their own `stage='heartbeat'` and preserves the in-progress stage as `active_stage`.

A category-only feature branch, `fix/3d-printer-updater-package-heartbeat-telemetry-20261109`, adds the missing updater files/tests, startup preflight coverage, a manifest regression test that checks every relative task-worker import is packaged, and the heartbeat-stage correction. This is pending review and CI. It has not been installed on the Research PC. No worker, source registry, queue, evidence, catalogue, migration, TEST data or secret was changed.


## Latest LIVE reconciliation — 9 November 2026, 23:49 UTC
- Exact task-key query: 24 parent task rows (23 completed, 1 failed); the failed parent contains eight product subtasks and all eight emitted task-completed handovers before the parent RPC failure. Across the 24 parent rows, 76 product subtasks are represented.
- Failed parent: `owner-3d-printers-equipment-1794264123497`, worker `DESKTOP-LVASEUB-130972`, failed at `platform_ai_agent_complete_task` with `PGRST102 Empty or invalid json`; the parent result remains empty. The eight product captures/queue writes had already been persisted separately.
- Its activity contains 9 `fetching_page` events, 4 post-fetch model-variant rejections and 5 retained raw page captures. There were 4 real Gemma batch starts, all 4 timed out; 4 raw-fallback completions followed. The stage query counted 8 `extraction_batch_started` events because 4 heartbeat events reused that stage label. This is the telemetry defect addressed by the new branch.
- Aggregate source activity: 44 search results, 112 approved-source route attempts, 24 route matches, 80 empty routes and 8 failures (eBay UK HTTP 403, one per product subtask). No page-fetch HTTP errors were recorded.
- Review handoff: 5 captures retained, 2 new pending rows, 2 existing pending rows enriched and 1 duplicate skipped. Current queue: 70 records (28 imported, 37 rejected, 5 needs_research); pending records are 2 UK-new and 3 unclassified; no new UK-used capture from this batch. No evidence was approved or imported.
- The isolated worker `DESKTOP-LVASEUB-3d-printers-equipment-128700` started at 23:20:07 and stopped cleanly at 23:30:32 without claiming a new research task. There is no active or queued 3D-printer task.
- Current source registry confirms Amazon UK and eBay UK are enabled wildcard sources (`category_slugs=['*']`); the roadmap's earlier statement that they were not enabled for this category was incorrect and is corrected above.
- The category updater manifest omitted `task-result-summary.mjs` even though `task-worker.mjs` imports it. The new manifest regression test is intended to prevent an incomplete install. Do not run the existing local updater until the local clone is fast-forwarded and this packaging correction is approved/available.
