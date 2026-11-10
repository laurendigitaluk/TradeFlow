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
