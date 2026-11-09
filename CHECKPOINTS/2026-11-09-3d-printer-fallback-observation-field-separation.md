## 9 November 2026 23:38 UTC — exact pending queue-field audit

The current LIVE queue has 70 rows: 28 imported, 37 rejected and 5 needs_research. The five pending rows are:
- Anycubic Kobra 4 Standard Printer: UK-new, £159 GBP, item_condition length 3, availability length 222, page capture 12,909 characters.
- Bambu Lab A1 Standard Printer: UK-new, £215 GBP, item_condition length 3, availability length 150, page capture 5,220 characters.
- Three unclassified Kobra 3 Max V2 Combo raw captures: full pages 19,514 / 16,120 / 16,285 characters; normalized item_condition lengths 1,282 / 1,281 / 1,282; availability lengths 780 / 1,040 / 1,040.
All five remain needs_research; reviewed_at, approved_at and imported_at are null. There is no pending UK-used capture. PR #343/#346 caps normalized 3D-printer values at 100 characters and leaves raw fallback snippets in the retained raw payload; existing rows are not backfilled or changed.



## 9 November 2026 23:37 UTC — production isolation merge and stale promotion PR

GitHub now records PR #342 (independent category-agent/control-centre foundation) as merged at 23:36:54 UTC, producing production commit 1f72b6d199cae9f19639f3ae1dd6c662ffc105e8. This merge was not performed by this watch. Production now contains the isolation guard, category launcher/updater and control-centre code. No Research PC process was started/stopped by this watch, and no Cloudflare or Research PC deployment was performed here.

The gemma/3d-printers branch remains at b95513d34fb5f55114788a869d07f6f461dedcc9. Compared with new production head 1f72b6, it is 27 commits ahead and 1 behind. Draft PR #345 is now mergeable_state=dirty because the production isolation foundation was merged while the 3D promotion branch remained based on the older 9b2027 commit. Do not merge PR #345 until it is rebased/reconciled against current production and reverified.

PR #346 remains clean/mergeable against gemma/3d-printers and passed 110/110 tests. PR #343 remains clean/mergeable against production and its code/test commit passed 106/106. PR #344 is closed without merge as superseded. PR #341's mergeability is currently recalculating/unknown.

LIVE worker state has not changed: isolated 3D worker 128700 stopped cleanly at 23:30:32; generic worker 129276 stopped at 23:31:33; generic worker 108588 has a start event at 23:23 and no stop event. The generic status row is stale due the worker-identity upsert race documented below. There are zero active exact-branch tasks.



## 9 November 2026 23:36 UTC — isolated PR refreshed against current 3D branch

PR #346 replaces PR #344, which was closed without merge because its base branch had advanced. PR #346 is based on current gemma/3d-printers head b95513d34fb5f55114788a869d07f6f461dedcc9 and combines the 3D-only fallback-field correction with the 3DJake retailer-parent-taxonomy matcher correction. Its combined GitHub Actions run #42721655690 passed 110/110 tests with zero failures, including the current base's compact task-result-summary and direct Anycubic route tests.

Release ordering: review/merge PR #346 into gemma/3d-printers before promoting that branch through draft PR #345. Production counterparts PR #343 (fallback queue fields) and PR #341 (3DJake matcher) remain open for the shared production worker path. No merge/deployment has occurred.



## Supabase memory-write limitation — 9 November 2026

The LIVE schema inspection found no dedicated public project-memory or checkpoint table; the shared agent message store is the Common Room table. Its posting RPC platform_ai_agent_post_message explicitly requires a service_role JWT. The available SQL connector was rejected with "Service role required". No attempt was made to bypass that permission. No Common Room message or other Supabase write was made. The System Handbook, AI Operating Manual, 3D-printer diagnostic roadmap, project-memory file and checkpoint were updated on this review branch instead.



## 9 November 2026 23:32 UTC — confirmed generic worker identity race

LIVE activity now records:
- 23:16:18 — generic worker_started, DESKTOP-LVASEUB-129276.
- 23:20:07 — isolated 3D worker_started, DESKTOP-LVASEUB-3d-printers-equipment-128700.
- 23:23:00 — a second generic worker_started, DESKTOP-LVASEUB-108588.
- 23:30:32 — isolated 3D worker_stopped, DESKTOP-LVASEUB-3d-printers-equipment-128700.
- 23:31:33 — generic worker_stopped, DESKTOP-LVASEUB-129276.
No worker_stopped event is recorded for the newer generic worker 108588.

The generic status row now points back to 129276 and says idle because the older worker's stop event updated it after the newer 108588 start. The isolated 3D status row points to 128700 and says idle after its clean stop. There are no active 3D-printer parent tasks. Supabase status therefore cannot prove whether 108588 is still alive; its start event has no matching stop and its identity was overwritten by the older stop event.

The LIVE RPC platform_ai_agent_report_event was inspected. Its ON CONFLICT(agent_key) update does not compare p_details.worker_id with the current metadata worker_id. A late stop/heartbeat from an older process can overwrite a newer process's status and metadata. PR #331 adds idle heartbeat cadence but does not add this worker-identity guard. Do not merge PR #331 until the lifecycle race is addressed or local process state is reconciled.

This is shared worker telemetry, not a safe 3D-only code change. No RPC/migration or other-category worker change was made. Before another 3D task, reconcile the Research PC process list and shared/isolated configs; do not infer that the generic worker is stopped from the current status row.



## 9 November 2026 23:32 UTC — isolated 3D PR now combines queue-field and retailer-matcher fixes

PR #344 has been extended to carry both the raw-fallback observation-field correction and the 3DJake retailer-parent-taxonomy matcher correction into gemma/3d-printers. It now changes only agent.mjs, agent-speed.test.mjs and source-playbooks.test.mjs on the isolated 3D branch. Updated CI run #42721156282 passed 110/110 tests with zero failures. PR #344 is open/mergeable, unmerged and undeployed.

Production counterparts remain separate: PR #343 carries the queue-field correction to production; PR #341 carries the matcher correction to production. Draft PR #345 promotes the isolated 3D branch to production and contains the compact parent-task summary mitigation, but it does not yet contain PR #344's two corrections. Review/merge sequencing must preserve these changes; do not merge or deploy automatically.

The latest isolated branch also contains the compact task-result summary (100,000-character fixture to below 5,000 characters) and direct Anycubic route regression tests. PR #345 CI run #42720715939 passed 106/106, but the compact summary has not been installed/runtime-tested. The isolated 3D worker started at 23:20:07 UTC before the summary commits at 23:26 UTC, so assume its running process has not loaded them until verified.



## 9 November 2026 23:28 UTC — compact parent-task result added on isolated 3D branch

The independent gemma/3d-printers branch has advanced to ca38a0d2fbc706e1e48b259d992d83975c91537d. It now adds task-result-summary.mjs and task-result-summary.test.mjs; the isolated task-worker submits product identity, capture URLs, classification, price observations, queue-write references, metrics and bounded failures, but excludes raw page captures and long excerpts already persisted in the review queue. It logs the serialized summary byte count before the completion RPC.

The regression fixture includes 100,000-character raw page captures and asserts that the compact task result remains below 5,000 characters. This is a targeted mitigation for the 8-product parent task's PGRST102 completion failure, but it is not yet a LIVE runtime retest. The isolated worker started at 23:20:07 UTC, before the compact-summary commits at 23:26 UTC; the current process must not be assumed to have loaded them.

PR #345 is a draft/open promotion of the isolated 3D branch to production. GitHub Actions run #42720715939 was in progress at this checkpoint. Do not merge or deploy it without explicit approval. The branch also adds direct Anycubic route regression coverage and includes the compact-summary test in its workflow.

The existing generic worker and isolated 3D worker both report idle. Generic worker scope remains unknown; no task should be queued until the Research PC process list and local configuration are reconciled. No worker was stopped/restarted by this check.



# Checkpoint — 3D-printer fallback observation-field separation

Date: 9 November 2026 UTC
Scope: LIVE 3d-printers-equipment / 3d-printers only.
Base: production 9b2027528243735a2fff35f9abc671673f864032.
Branch: fix/3d-printer-fallback-observation-fields-20261109.
PR #343: https://github.com/laurendigitaluk/TradeFlow/pull/343

## Current LIVE state
- Parent task counts: 28 completed, 1 failed, 0 queued/running (29 exact-branch tasks).
- Latest eight-product parent owner-3d-printers-equipment-1794264123497: eight task_completed subtask events; queue writes persisted; parent completion RPC failed with HTTP 400 / PGRST102. No aggregate result.
- No active 3D-printer parent task.
- Isolated 3D worker: DESKTOP-LVASEUB-3d-printers-equipment-128700, started 23:20:07 UTC, idle.
- Generic worker DESKTOP-LVASEUB-129276 started 23:16:18 UTC with no stop event; another generic worker_started event appeared at 23:23:00 UTC for DESKTOP-LVASEUB-108588. Isolated 3D worker DESKTOP-LVASEUB-3d-printers-equipment-128700 started at 23:20:07 UTC. Latest status rows are idle/current_task null. Idle timestamps are not periodic heartbeats; generic enabled category scope is not visible. Verify the Research PC process list and local configs before another task. No worker action taken.

## Latest batch metrics
44 search results; 9 pages discovered; 5 fetched; 5 raw captures; 4 Gemma batches; 4 timeouts; 112 route attempts; 24 route matches; 80 empty; 8 eBay UK HTTP 403 failures; no collection/page-fetch errors. Four subtasks had zero search results. Kobra 3 Max V2 Standard was rejected by exact-model guard; 3DJake Combo pages were rejected by retailer parent-path accessory matching (PR #341).

## Queue finding
70 review records: 28 imported, 37 rejected, 5 pending. Pending includes two typed UK-new rows and three unclassified raw Kobra 3 Max V2 Combo captures. No new UK-used capture from the latest batch.

Three pending raw captures have full pages 19,514 / 16,120 / 16,285 characters, but normalized condition fields contain 1,281–1,282 characters and availability fields 780–1,040 characters. They remain needs_research and have no reviewer, approval or import timestamps.

## Repair in PR #343
Root cause: raw fallback snippet fields were copied into normalized queue columns. The 3D-only queue mapper now accepts only concise explicit values (maximum 100 characters) and otherwise leaves normalized fields null. Raw snippets and full page remain in raw_payload/page_capture. Other categories retain existing mapping. Three regression tests added. No LIVE data migration or queue repair performed.

## Verification and release gate
- Verify GitHub Actions on the final PR #343 head.
- PR #343 remains open/unmerged/undeployed.
- Do not merge or install without explicit approval.
- Before another task, confirm the isolated 3D worker's installed branch/SHA and verify the generic worker cannot also claim 3D tasks.
- If PGRST102 recurs, capture local request-body byte count and worker logs before changing task-worker or RPC code.
- No task queued, no worker stopped/restarted, no source registry changes, no approval/import, no TEST/LIVE transfer, no secret/private ENV access.
