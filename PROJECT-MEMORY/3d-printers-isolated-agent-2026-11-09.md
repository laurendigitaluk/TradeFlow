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


## 10 November 2026 — post-merge verification

### 10 November 2026 — 3D Printers post-merge LIVE verification

The latest LIVE parent task `owner-3d-printers-equipment-1794272051590` completed normally with five product subtasks. It returned 48 search results, discovered 10 individual product pages, fetched 6 and retained/staged 6 page captures (three new records and three enrichments). Four of four Gemma extraction batches timed out under the pre-merge 45-second batching policy. The compact task-result helper submitted a 9,811-byte parent result; the earlier PGRST102 completion error did not recur on this five-product batch.

The 6 staged captures remain review-only. The pending queue currently has 8 `needs_research` records: 2 typed UK-new and 6 unclassified; there are no typed UK-used pending captures. The latest batch's six writes were 3 new and 3 enrichments; the Kobra 4 Standard enrichment retained its existing UK-new £159 observation, while the other raw captures remain unclassified. Active shared evidence is 239 UK-new and 21 UK-used. No catalogue evidence was approved or imported.

The first loss in this run was search-to-exact-page discovery (48 results to 10 individual pages), followed by page fetching (10 discovered to 6 fetched). The largest avoidable post-fetch loss was Gemma extraction: all four batches timed out, although all six raw captures were preserved. PR #348 merged to production at 01:17:10 UTC (merge commit `83ee9fdf533cac92bbf4bcc96384205ee31ea7f5`) and adds verified Anycubic/3DJake/123-3D/eBay routes plus one-page, 90-second 3D-printer extraction. The latest task predates that merge, so no post-merge Research PC runtime acceptance has yet occurred.

The LIVE status row reports the 3D-printer agent idle, with no current task and a heartbeat at 01:21:21 UTC from worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`. The local installed commit is not reported, so the heartbeat does not prove that PR #348's post-merge code is installed.

A second defect was confirmed in the actual review-queue write path: raw `item_condition_text` and `availability_text` snippets are copied into the normalized queue columns. Six pending rows have condition values over 100 characters and eight have availability values over 100 characters. The earlier PR #346 added and tested a normalization helper but did not call it from the final database row builder; its tests therefore did not prove the persisted row was corrected. The new 3D-only branch centralizes the final row builder, calls the helper at extraction/validation/persistence boundaries, and tests the actual persisted-row shape. Raw snippets and full page captures remain in `raw_payload.evidence` and `page_capture`.

The same 3D-only branch separates heartbeat event stage (`stage=heartbeat`) from the active research stage (`active_stage`). The latest task produced 8 heartbeat activity rows, 4 of which were incorrectly labelled `extraction_batch_started`, inflating stage counts. The updater, launcher and CI already referenced the telemetry and installer-manifest tests, but the test files were absent from the branch; this branch supplies them and verifies the download/preflight contract.

PR #348's own merge/checkpoint records say shared worker source/tests were synchronised across all seven isolated category branches. That cross-category synchronization occurred outside this 3D-only follow-up. No additional branch or code changes were made to other categories here. Keep subsequent work confined to `gemma/3d-printers`.

The LIVE schema has no dedicated project-memory/checkpoint table in any schema; the repository's `PROJECT-MEMORY` and `CHECKPOINTS` files remain the durable project record. The category-scoped Common Room is stored separately in `platform_ai_agent_messages`.

## Current branch/review state
- Production contains PR #348 at merge commit `83ee9fdf533cac92bbf4bcc96384205ee31ea7f5`.
- The isolated `gemma/3d-printers` branch contains the route/extraction and compact-result code. The latest task result was 9,811 bytes and completed normally.
- New branch `fix/3d-printer-review-row-heartbeat-installer-20261110` is confined to `gemma/3d-printers`; it corrects the actual review-row call sites and heartbeat/installer regression coverage. Existing PR #346's helper was not wired into the final row builder, and PR #347 is stale.
- No Research PC update, restart, queue task, evidence approval or import was performed.



### Correction — worker lifecycle and exact-branch counts (10 November 2026, 01:30 UTC)

The earlier 01:21:21 status timestamp was the `worker_stopped` event for worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`, not proof of an actively polling idle process. A later isolated process `DESKTOP-LVASEUB-3d-printers-equipment-133276` started at 01:29:56 and stopped cleanly at 01:30:43 without claiming a task. The category status row is `idle`, `current_task=null`, `last_error=null`; there is no active worker process at this check. Neither start nor stop was triggered by this watch. No post-PR #348 research task has run, and worker telemetry does not expose the installed commit SHA.

The exact category-and-branch task filter now returns 30 parent tasks: 29 completed and 1 failed, representing 86 product subtasks (78 in completed parents and 8 in the failed parent). Broader category-only payload filtering includes an additional non-exact-branch row and must not be used for branch-specific reporting.

The replacement PR is now open as [PR #349](https://github.com/laurendigitaluk/TradeFlow/pull/349), targeting only `gemma/3d-printers`. GitHub reports it mergeable; Gemma Research Tests run #698 passed. It contains the actual persisted-row mapping correction, heartbeat-stage separation, and the missing telemetry/installer regression files. It is not merged or deployed.



### 10 November 2026 — page-fetch funnel telemetry added

The latest task's activity log recorded 10 `fetching_page` events, 2 `source_error` events and 6 `page_capture_retained` events. It also recorded 16 `model_variant_skipped` events, but the older progress payload did not distinguish pre-fetch skips from post-fetch rejections. The parent result did not expose separate fetch-attempt, successful-HTTP-fetch, pre-filter rejection and post-fetch rejection counters; `fetched_price_pages` is not a substitute for successful HTTP fetches.

PR #349 now incorporates the 3D-printer-only page-flow telemetry correction previously proposed in PR #338: emit `product_page_fetched` after a successful HTTP fetch, label model/package skips with `phase=prefilter|postfetch`, report fetch attempts, successful fetches, pre/post validation rejections and pages eligible for capture, and include these metrics in the worker handover/parent result. The legacy `inspected_product_pages` field remains unchanged for compatibility. Regression coverage reproduces 2 attempts, 1 successful fetch, 1 prefilter rejection, 1 post-fetch rejection and 0 eligible pages.

GitHub Actions run #702 passed all workflow steps on code/test commit `5f3f77d2af3d94290e63b7a6c266e7a4555f2d14` (PowerShell syntax, Node syntax, Gemma task/website tests and Owner Dashboard JavaScript). The subsequent documentation-only commits do not change source or tests. PR #349 remains open and unmerged, targeting only `gemma/3d-printers`; it supersedes the stale PR #338.



### Supabase memory write limitation — 10 November 2026

A schema-wide read-only inspection found no dedicated Supabase project-memory or checkpoint table. The category Common Room is stored in `public.platform_ai_agent_messages`; its `platform_ai_agent_post_message` RPC requires the `service_role`. The current connector does not expose that privilege, so no Common Room insert was attempted through a lower-level bypass. Existing Common Room records were read only. This repository project-memory/checkpoint update is included in PR #349 for owner review.


## 10 November 2026 — parent task completion lifecycle and aggregate reporting

A read-only LIVE audit found that the worker emitted `event_type=task_completed` once per product subtask, from inside the `tasks[]` loop and before `platform_ai_agent_complete_task` was called. It also set the specialist status to idle and cleared `current_task` between subtasks. This made the activity feed and Common Room completion message describe only the final product subtask as if it were the whole parent batch.

Verified example — parent task `owner-3d-printers-equipment-1794272051590`:
- Five product subtasks emitted five `task_completed` activity events.
- The final event at 01:00:37.716 UTC reported only Kobra S1: 2 captures, 2 staged (2 new, 0 enriched), 2 search results, 2 pages discovered and 2 fetched.
- The parent queue row was not marked completed until 01:00:53.096 UTC, 15.38 seconds later.
- Actual aggregate across the five saved subtask results: 48 search results, 10 pages discovered, 6 fetched, 6 captures, 6 staged (3 new, 3 enriched), 78 route attempts (20 matching, 50 empty, 8 errors), and 4 Gemma batch timeouts.
- The Common Room parent-looking completion message repeated the final Kobra S1 subtask figures rather than the parent totals. The prior eight-subtask parent that later failed its completion RPC had already emitted eight `task_completed` events, demonstrating the same lifecycle ambiguity on failure.

Correction on feature branch `fix/3d-printer-parent-completion-lifecycle-20261110`, stacked on PR #349's 3D-printer-only branch:
- Per-product completion is now a `progress` event with `stage=subtask_completed`; the parent remains `running` with its current task key until the completion RPC succeeds.
- The per-subtask counter deltas are preserved, so existing cumulative product-subtask counters are not double-counted or reset.
- After `platform_ai_agent_complete_task` returns true, the worker emits one parent `task_completed` event and one aggregate Common Room completion message. If the RPC fails, no parent-completed event is emitted; the existing failure path remains authoritative.
- The compact parent result now carries aggregate search, page, capture, Gemma, route and review-write counts while retaining the individual compact subtask records and excluding raw page bodies.

Regression fixture reproduces the actual five-product LIVE totals: 48 searches, 10 discovered pages, 6 fetched/captured, 4 Gemma failures, 78 route attempts, 20 matches, 50 empty, 8 errors, and 6 review writes (3 new, 3 enriched). Local Node tests passed 5/5. GitHub Actions Gemma Research Tests run #708 (42763835025) passed PowerShell updater syntax, Node source syntax, Gemma task/playbook tests and Owner Dashboard JavaScript syntax. No Research PC update, worker restart, task enqueue, LIVE database mutation, evidence approval/import, or TEST/LIVE transfer was performed. PR #350 is review-only and must not be merged or deployed without explicit approval. The Supabase Common Room learning-note write was not attempted: the available SQL connection has no service-role JWT and the posting RPC requires service_role; repository memory/checkpoint files are updated on this branch.


## 10 November 2026 — category-scoped idle heartbeat correction (prepared, not deployed)

The current isolated specialist worker reports `worker_started` and processing heartbeats, but has no recurring heartbeat after a successful idle queue poll. Therefore an idle specialist's `last_heartbeat` becomes stale even when its process is healthy. LIVE inspection confirmed the status RPC updates `platform_ai_agent_status.last_heartbeat`, `updated_at`, status and activity rows through `platform_ai_agent_report_event`; no schema change is required.

LIVE baseline at this inspection:
- Project: `gxsrajtqzdjvmceqcpgv`; specialist: `3d-printers-equipment`; branch: `gemma/3d-printers`.
- Status: `idle`, `current_task=null`, `last_error=null`; last recorded worker ID: `DESKTOP-LVASEUB-3d-printers-equipment-10036`; last heartbeat/start: 13:43:44 UTC.
- Queue: 16 completed and 1 failed task in the last 48 hours; 0 queued/claimed/processing/running tasks.
- Three distinct `worker_started` events were recorded at 13:17:37, 13:24:46 and 13:43:44 UTC. The event log alone does not prove concurrent processes; local Research PC process/supervisor logs are required to establish whether earlier workers exited.
- The latest Anycubic task completed with two page captures retained for review; Gemma extraction timed out for the two-source batch. No candidate was accepted from that batch.

Correction prepared on `fix/gemma-specialist-idle-heartbeat-20261110`, stacked on the 3D Printer parent-lifecycle branch `fix/3d-printer-parent-completion-lifecycle-20261110` (PR #350):
- Add `specialist-idle-heartbeat.mjs` with a 60-second minimum / five-minute maximum cadence derived from the 15-second queue poll.
- Report the actual isolated specialist identity (agent key/name/category), worker ID, poll interval, `stage=idle_poll` and isolated key; do not mislabel a specialist as the generic `gemma-task-worker`.
- Emit only after a successful queue poll and only while idle. Suppress during task processing, queue polling, failed polls, shutdown, and overlapping heartbeat telemetry. A new queue poll waits for any in-flight idle heartbeat to finish, preventing an idle report from racing a task claim.
- Do not heartbeat when the specialist has no enabled agent assignment.
- Keep the existing 45-second active-task heartbeat and queue lease heartbeat unchanged.
- Package the helper and regression test through the updater; run the test in updater preflight/install verification, canonical launcher preflight and GitHub Actions.

Regression tests cover bounded cadence, invalid poll fallback, healthy-idle-only emission, suppression during processing/poll/shutdown/overlap, and preservation of the specialist identity. No Supabase migration, queue mutation, research task enqueue, source-registry change, evidence approval/import, TEST/LIVE transfer, private .env change or Research PC restart is part of this code change.

PR #331 is not a suitable substitute: it is open but GitHub reports it unmergeable, it targets the production generic queue worker and deliberately reports only `gemma-task-worker` / `Task control`. Do not merge it as the specialist fix.

Release gate:
1. CI must pass on this specialist-heartbeat branch.
2. Review/merge the stacked 3D Printer lifecycle work in its recorded order, then promote the heartbeat change to `gemma/3d-printers`.
3. Synchronise the same shared worker/helper/test/updater/launcher/CI files to all seven isolated specialist branches, preserving each branch's one-key `agent.config.json`.
4. Run the existing updater against LIVE only, preserving each private .env; verify each worker's same-ID idle heartbeats at least twice before declaring liveness fixed.
5. Do not enqueue a research task solely to test heartbeat. Once heartbeat acceptance passes, run a separately authorised bounded 3D Printer research acceptance and verify claim, active progress, parent completion and review-queue handover. Evidence remains unapproved pending owner/ChatGPT review.


### Verification update — 10 November 2026

PR #351 is open and ready for review, stacked on PR #350 (which is stacked on PR #349). GitHub Actions Gemma Research Tests run #712 passed all seven workflow steps, including PowerShell syntax, all Gemma Node syntax checks, the full task/website/heartbeat/installer regression test command, and Owner Dashboard JavaScript syntax. The PR remains unmerged and no Research PC installation or worker restart has been performed.

A read-only branch comparison confirmed all seven specialist branches currently have identical shared `task-worker.mjs`, updater and canonical launcher blobs. Their `agent.config.json` files are distinct and correctly retain exactly one category key each. This means the shared heartbeat implementation can be synchronised across the seven branches without replacing their category-specific configuration. The six non-3D branches have not yet been modified.


## 10 November 2026 — merge and branch promotion completed

Owner authorised the release. PR #349 (evidence/telemetry), PR #350 (3D Printer parent completion and aggregate reporting), and PR #351 (isolated specialist idle heartbeat) were merged in that order. Merge commits: `c63fbba74c24b9caac40230ac5f8f6549a611ff1`, `36bb6e452719bece5ded6d4c412a2af899a01a06`, and `24fa2713c3040798f82ecf63fc5ac7023a884acf`.

The merged 3D Printer worker, parent-result summary module and regression tests, specialist idle-heartbeat helper/test, updater, launcher preflight, GitHub Actions test list, manuals, diagnostic roadmaps, project memory and checkpoint have now been promoted onto `gemma/3d-printers`. The 3D Printer one-key `agent.config.json` was not modified. This is repository branch promotion only: the Research PC installation has not yet been updated or restarted, and LIVE runtime acceptance is still pending.


## 10 November 2026 — Current Research PC handover

Read `CHECKPOINTS/2026-11-10-gemma-research-pc-reconciliation.md` on production before continuing. The owner's local 3D clone is `C:\\CTFGemma2\\Gemma-3D-Printers`, remote `laurendigitaluk/TradeFlow`, branch `gemma/3d-printers`. Local HEAD `0ffa1734d071440f18b8becbbfc039ced1605d5e`; remote `90591adc2824263dbf0256df195b435456f96e46`; remote is 74 commits ahead, local 0 commits ahead. Local working tree is dirty: six tracked diffs plus untracked launcher, backups, result summary and status file. Preserve and reconcile before fast-forward; no reset/clean/blind pull. GearCashOut is a separate project, not part of TradeFlow; it only supplied category names, and TradeFlow evidence already exists. Do not inspect or use GearCashOut.
