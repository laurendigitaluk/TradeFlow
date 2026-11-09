# Project memory — 3D-printer fallback observation-field separation

Date: 9 November 2026 UTC
Scope: LIVE category 3d-printers-equipment, branch 3d-printers only.
Production base: 9b2027528243735a2fff35f9abc671673f864032.
Feature branch: fix/3d-printer-fallback-observation-fields-20261109.
PR #343: https://github.com/laurendigitaluk/TradeFlow/pull/343

## LIVE worker and task state
- Exact branch parent tasks: 29 total; 28 completed, 1 failed; no queued/running parent tasks.
- Latest parent: owner-3d-printers-equipment-1794264123497. All eight product subtasks emitted task_completed events and their review writes persisted. The parent completion RPC then returned HTTP 400 / PGRST102 (Empty or invalid json), so the parent row is failed and its aggregate result is absent. The eight subtask outputs/captures remain in activity and queue records.
- Isolated 3D worker started 23:20:07 UTC as DESKTOP-LVASEUB-3d-printers-equipment-128700; idle, no active task.
- Generic worker DESKTOP-LVASEUB-129276 started 23:16:18 UTC; idle, no active task. Both pollers are present. Generic worker enabled category scope is not exposed in LIVE telemetry; verify the local legacy config before another task. Do not stop/restart either worker from this watch.
- PR #342 isolation implementation is draft/open and its CI passed. The new isolated worker status matches its isolation identity format, but the installed source SHA is not exposed. Do not assume exact local branch commit.

## Latest eight-product batch
Task owner-3d-printers-equipment-1794264123497:
- 44 search results; 112 approved-source route attempts; 24 route matches; 80 empty; 8 failed (eBay UK HTTP 403 once per product subtask).
- 12 approved sources probed per subtask; 24 pagination pages followed; zero collection errors and zero product-page HTTP fetch errors.
- 9 exact product pages discovered; 5 fetched; 5 raw captures retained.
- Four Gemma extraction batches; all four timed out at the 45-second limit. Raw fallbacks were retained.
- Four of eight subtasks had zero search results. Kobra 3 Max V2 Standard had one discovered page rejected by the exact-model guard. 3DJake Kobra 3 Max V2 Combo pages were rejected because the parent URL taxonomy contains “accessories”; PR #341 addresses that separate matcher issue.
- Compared with the prior five-product repeat: 18 search results, 3 discovered, 1 fetched/captured. Latest batch: 44, 9, 5, 5.

## Review queue
- 70 records: 28 imported, 37 rejected, 5 needs_research.
- Pending: 2 UK-new typed rows (Kobra 4 Standard £159; Bambu Lab A1 £215), plus 3 unclassified Kobra 3 Max V2 Combo raw captures. No new UK-used capture from this batch.
- Three unclassified raw captures remain unreviewed/unapproved/unimported. Full page lengths: 19,514 / 16,120 / 16,285 characters.
- Their top-level item_condition lengths: 1,282 / 1,281 / 1,282; availability lengths: 780 / 1,040 / 1,040. These are concatenated context snippets, not normalized condition/availability values.

## Confirmed code defect and correction
Root cause in production agent.mjs: fallbackPageCapture() intentionally preserves contextual snippets in item_condition_text and availability_text, but the review-queue row builder copied those raw snippet strings into normalized item_condition and availability columns.

PR #343:
- Adds buildReviewQueueObservationFields() for the 3D-printer branch.
- Only explicit normalized values up to 100 characters may populate top-level item_condition/availability; otherwise null.
- Raw snippets remain in raw_payload.evidence and full page_capture remains intact.
- Non-3D category mapping remains unchanged.
- Three regression tests cover raw fallback preservation, concise/overlong structured values and non-3D compatibility.
- PR open, unmerged, undeployed. CI must be checked on final head before review completion.

## Separate unresolved parent-completion error
Production task-worker.mjs serializes RPC arguments with JSON.stringify and sends Content-Type application/json. The LIVE completion RPC returned PGRST102 after the subtask writes. No local request-body byte count or request log is available, so the exact cause is not established. Do not add speculative worker/RPC changes. Capture local request-body size and worker logs if the error recurs.

## Safeguards and next gate
- No LIVE queue row or evidence was modified by this work.
- No approval/import, source-registry change, migration, worker restart or task enqueue.
- TEST remains separate; no TEST data copied.
- No private .env or secrets accessed.
- Next: confirm PR #343 CI; review/approve explicitly; only then install the approved 3D-printer code and run one controlled task after confirming the generic worker cannot also claim 3D tasks.
