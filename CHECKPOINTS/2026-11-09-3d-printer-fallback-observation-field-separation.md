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
