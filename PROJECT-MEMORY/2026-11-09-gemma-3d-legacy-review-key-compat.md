# Project memory — 3D-printer legacy review-key compatibility

Date: 9 November 2026 UTC
Scope: LIVE category `3d-printers-equipment`, branch `3d-printers`.
Parent: PR #334, `fix/gemma-3d-review-snapshot-versioning-20261109`.
Feature branch: `fix/gemma-3d-legacy-review-key-compat-20261109`.

## LIVE baseline inspected

- Project: `gxsrajtqzdjvmceqcpgv`.
- Exact-branch task rows: 20, all completed; 57 product subtasks; zero running, queued or failed.
- Latest task: `owner-live-3d-printers-worker-check-neptune4pro-20261109-1445`, completed 15:03:59 UTC under `DESKTOP-LVASEUB-78412`.
- Latest task metrics: 29 search results, 6 individual pages discovered, 3 fetched, 2 Gemma batches, 3 extraction failures, 3 raw captures; total 19m16s, Gemma stage 18m49s. All 3 review writes were duplicate-skipped.
- Latest route metrics: 12 approved sources, 26 route attempts, 11 matches, 9 empty, 6 failed; 3 product-page fetch errors. Failures included Uni3Dverse 404, eBay 403 twice/404, Amazon 404, SecondHand 404; the three direct fetch failures were eBay 403.
- Category status idle; last category heartbeat 15:03:59 UTC. Generic worker heartbeat 12:39:53 UTC. No fresh idle heartbeat is emitted by current production code.
- Review queue: 65 rows (28 imported, 37 rejected, zero open); 62 have page captures; maximum stored capture/excerpt 10,000 characters. 27 imported rows lack reviewer ID; eight imported rows lack review timestamp; all 37 rejected rows lack reviewer ID; 64/65 have no top-level evidence_type.

## New defect found in PR #334 review

Current LIVE dedupe-key distribution for this exact branch:
- 62 rows use `capture-`.
- One imported Creality K1 row uses `review-`.
- Two Anycubic Kobra S1 Max rows use `borderline-` (one imported, one rejected).

PR #334 checks the new `capture-` base key first. If no row matches, it previously inserted a new capture without searching older keys. An unchanged page for any of these three legacy rows could therefore be duplicated after rollout.

## Repair on this branch

- Keep the current `capture-` lookup as the fast path.
- Only when that lookup misses for a 3D-printer task, fall back to an exact identity query: record type, category, branch, manufacturer, model, package and source URL.
- Compare the incoming fingerprint with all matching legacy rows. An exact match is duplicate-skipped. A changed terminal (imported/rejected/reviewed) row creates a separate unverified snapshot. A genuinely unreviewed `needs_research` row may be enriched only through the existing guarded optimistic update.
- Imported/rejected history is never modified; no reviewer identity is inferred; no approval/import is performed.
- The lookup is read-only. No LIVE queue row was inserted or updated.

## Regression tests added

1. Legacy lookup filters exact category/branch/product/package/source URL.
2. Same snapshot against legacy imported/rejected rows remains idempotent.
3. Materially changed snapshot creates a new snapshot while preserving terminal history.
4. An unreviewed legacy pending capture can be enriched without changing its legacy dedupe key.

## Release status

Stacked on PR #334 head `3adcfd230a948f1187775eea3f72e305a284e891`. PR #334 remains open, unmerged and undeployed. This compatibility branch is not installed on the Research PC. CI for this new branch is pending at checkpoint creation.

No research task queued; no worker restarted; no source registry or migration changed; no catalogue evidence approved/imported; no TEST/LIVE data copied; no private `.env` or secrets accessed or changed.


## 9 November 2026 — PR #335 verification status update

PR #335 now targets `production` and consolidates the full PR #334 3D-printer change set plus legacy review-key compatibility. Current head is `fbe7a44b5f404b21b3d613406cc5a6e18abedfcb`; the PR is open and GitHub reports it mergeable. Five new regression tests are present.

Gemma Research Tests run #549 failed before scheduling any jobs (GitHub reported zero jobs), so it did not execute the suite. The prior PR #334 head passed run #548 with 105 tests, but that result does not cover the five new legacy-compatibility tests. Cloudflare Workers Builds for both `tradeflow` and `tradeflow-test` passed on the current PR #335 head; these are preview/build checks, not production deployment. Do not merge until the current Gemma test suite has executed successfully and the Research PC runtime acceptance has been completed.

PR #334 remains open as the separately tested parent version until the consolidated PR's test suite is verified. No LIVE database write, source change, migration, task queueing, worker restart, evidence approval/import, TEST/LIVE copy or secret/configuration change occurred.


## CI workflow blocker found — 9 November 2026 18:26 UTC

The Gemma Research Tests workflow exists on `production` but is absent from the repository's default `main` branch (which currently contains only `.github/workflows/businessflow-test-release.yml`). PR #335 attempts #549 and #553 both completed as failures before creating any jobs (zero jobs); neither executed the test suite. The latest head's Cloudflare Workers Builds for both `tradeflow` and `tradeflow-test` passed, but these are build/preview checks and do not run the Gemma regression suite.

The previous PR #334 head passed Gemma run #548 (105 tests), but that does not cover the five new legacy-key tests. Do not treat the current PR as test-verified. No change was made to `main`: it is the repository default branch and not the production branch, and changing its CI configuration is outside the authorised 3D-printer production change. A separate, explicitly approved CI-default-branch change or another authorised test runner is required before merge.


## Correction — legacy row attribution and CI verification

one imported Creality K1 row uses `review-`, one rejected Creality K1 row uses `borderline-`, and one imported Anycubic Kobra S1 Max combo-8-color row uses `borderline-`. PR #335 run #560 passed 110/110 tests after two test-assertion corrections; runs #549 and #553 had zero jobs, run #556 had 109/110, and run #558 had 109/110. The default-branch workflow absence is observed but is not established as the cause of the zero-job runs. The latest `tradeflow` preview build passed; the `tradeflow-test` preview build was still running at this update.


## Correction — CI diagnosis and exact legacy-row attribution (9 November 2026)

The three legacy queue rows are: one imported Creality K1 row with a `review-` key; one rejected Creality K1 row with a `borderline-` key; and one imported Anycubic Kobra S1 Max combo-8-color row with a `borderline-` key. The earlier wording that attributed both `borderline-` rows to Anycubic was incorrect.

CI history on PR #335: runs #549 and #553 failed before scheduling jobs (zero jobs). Run #556 executed 110 tests: 109 passed and one existing source-playbook schema assertion failed because it still expected the old local variable name `existing` after the code renamed it to `exactExisting`. Run #558 executed 110 tests and had one failure in the new assertion because it included the `?select=` prefix in the selected-column comparison. The five new legacy-key regression tests passed. Both test assertions were corrected; Gemma Research Tests run #560 on code/test commit `eff09502183075c3bab334afb45328ba2c947fdd` passed **110/110**. The default `main` branch does not contain the Gemma workflow, but that absence is not established as the cause of the zero-job runs because #556 and #560 executed successfully. No change was made to `main`.

The subsequent commits on this feature branch are documentation-only. The `tradeflow` Cloudflare preview build passed on the tested head; the `tradeflow-test` preview build was still running at the time of this correction. No production deployment occurred.
