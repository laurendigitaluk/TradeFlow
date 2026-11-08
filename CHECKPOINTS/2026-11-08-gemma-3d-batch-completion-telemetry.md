# 3D-printer batch completion telemetry — 8 November 2026

## Finding
LIVE task `owner-3d-printers-exact-identity-acceptance-20261108-0032` completed eight 3D-printer subtasks from 00:32:26 to 00:47:00 UTC. Its stored parent result contains 85 searches, 15 product pages discovered, 6 fetched, 4 Gemma calls, 2 extraction failures, 6 captures, 4 new queue rows and 2 existing rows enriched.

The last subtask was Bambu Lab A1 Combo / uk_used. It correctly rejected nine Audi A1 car URLs and had zero captures. However, production `task-worker.mjs` emitted a `task_completed` activity and Common Room status inside the per-product loop. The last event therefore said zero captures, making the parent task appear to have produced zero, despite the parent result containing six.

## Change in PR #289
- Add a strict multi-task 3D batch predicate: every subtask must have category `3d-printers-equipment` and branch `3d-printers`.
- Label per-product completion events `subtask_completed` for those batches.
- After the parent task queue completion succeeds, publish one aggregate `task_completed` telemetry event and Common Room batch handover.
- Aggregate search/discovery/fetch/GBP/extraction metrics, route metrics/failures, candidate captures and new/enriched/duplicate write counts.
- Preserve counter semantics: existing per-subtask deltas remain; parent summary adds no counter deltas.
- Leave other categories and single-task runs unchanged.

## Regression coverage
- 3D-only multi-subtask detection.
- Reject single-task, mixed-category and wrong-branch batches.
- Sum research and route metrics across subtasks.
- Keep search-result limit as a per-subtask maximum, not a sum.
- Aggregate route and Gemma failure details.
- Count new and enriched review writes as staged, excluding duplicate skips.

## Verification and release
The GitHub Actions Gemma Research Tests workflow is triggered by the PR. The Research PC updater already installs and tests all three changed source/test files. Await green CI and review. Do not merge/deploy without explicit approval. After approval, use the existing updater in place, preserve the private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`, then verify the parent summary in one controlled 3D-only acceptance run.

## Safeguards
No Supabase schema/data, task queue, review queue, catalogue, source registry, TEST data, credentials, private .env or Research PC runtime changed. No research task was queued. No evidence was approved or imported.
