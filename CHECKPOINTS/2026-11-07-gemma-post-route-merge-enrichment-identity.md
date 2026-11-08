# Gemma post-route-merge review enrichment and telemetry identity

Date: 7 November 2026 (UTC)
Scope: TradeFlow LIVE Gemma — category 3d-printers-equipment, branch 3d-printers.
Production base: bae3c4145bc0fd78de9ac803e81cd9077ba0c930.
Feature branch: feature/gemma-post-pr281-enrichment-identity-20261107.
Pull request: https://github.com/laurendigitaluk/TradeFlow/pull/284.

## Current LIVE state
- No active/pending 3D printer task. Latest genuine task owner-3d-printers-controlled-rerun-20261107-2225 completed 8/8 subtasks at 22:54:46 UTC.
- Latest run: 31 search results, 13 product pages discovered, 8 fetched, 5 Gemma calls, 2 failures, 8 captures, 8 duplicate skips, 0 new rows.
- Previous run: 123 search results, 83 discovered, 51 fetched, 27 Gemma calls, 20 failures, 51 captures, 15 duplicate skips, 36 unique rows staged.
- LIVE review queue: 40 rows (30 new, 6 used, 4 both); 3 with top-level prices, 1 typed, 1 reviewed marker, 0 approved/imported, 0 enriched.
- Used eBay item fetches returned HTTP 403; do not bypass access controls.
- PR #278 and #281 are merged to production; the Research PC has not yet been updated to use the merged route-aware code.

## Schema correction
The actual LIVE queue schema has reviewed_by, reviewed_at, approved_at and imported_at. It does not have approved_by or imported_by. The original PR #282 selected and filtered the two nonexistent columns and must not be merged unchanged.

## PR #284 replacement
- Adds append-only, 3D-branch-only enrichment for exact category/branch/manufacturer/model/package/source identity.
- Only needs_research rows with raw_payload.review_classification=unverified_capture and null actual review markers can be enriched.
- Appends bounded unverified observations to raw_payload.enrichment_history and research_notes; preserves top-level price/evidence fields, status, reviewer notes and catalogue data.
- Repeats actual marker checks in the PATCH filter and uses updated_at optimistic concurrency.
- Separates new and enriched staged counts; only new rows increment evidence_queued.
- Propagates parent task key and 3D product/lane context.
- Corrects the observed mismatched 3D agent key / explicit non-3D category telemetry attribution.

## Tests and safeguards
Regression coverage includes append-only enrichment, review-state safeguards, identity mismatch, duplicate-history prevention, actual LIVE schema column selection, staged-count separation and five telemetry identity cases. The workflow now includes the identity test file; GitHub Actions run 42428499719 passed on PR #284 head 96ad070d9377bac128f0d4dc4685e5b9765c5428: 45 tests passed, 0 failed; Gemma source syntax and Owner Dashboard JavaScript syntax checks passed.
No queue rows, source rows, catalogue records or approvals/imports were changed. No task was queued. TEST/LIVE separation and all secrets/private .env paths are preserved. No Research PC update, restart, merge or deployment occurred.