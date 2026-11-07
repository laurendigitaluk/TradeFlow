# Gemma Review Queue Duplicate Enrichment

Date: 7 November 2026
Scope: TradeFlow LIVE Gemma only — category 3d-printers-equipment, branch 3d-printers.
Production base: 6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4
Feature branch: feature/gemma-review-queue-enrichment-20261107

## Confirmed loss
The active controlled task owner-3d-printers-controlled-rerun-20261107-2225 fetched seven Anycubic Kobra S1 new-lane pages. Extraction batches 1, 2 and 4 returned five structured observations in total; batch 3 failed JSON parsing and retained two raw fallback pages. All seven URLs already existed in the review queue from the earlier run, so the dedupe block skipped all seven and staged zero. The existing rows remain needs_research with null observed_price and evidence_type. The useful new extraction therefore did not reach the review rows.

Two used subtasks also discovered three eBay item pages but all three direct fetches returned HTTP 403. Do not bypass anti-bot controls. This remains a separate used-market fetch limitation.

## Safe fix on branch
- For 3D Printers only, enrich an existing duplicate row only when it remains status=needs_research, review_classification=unverified_capture, and reviewed/approved/imported fields are all null.
- Require exact match on dedupe key, category, branch, manufacturer, model, package and source URL.
- Append the new unverified structured observation to raw_payload.enrichment_history and research_notes. Preserve the original raw page capture.
- Do not alter top-level observed_price, price_currency, evidence_type, item_condition, availability, review_notes, status, approval/import fields or catalogue data.
- Count enriched rows as staged for ChatGPT review, but keep the global evidence_queued counter for new unique rows only.
- Propagate the parent task key to 3D-printer task objects and expose model/lane context in progress telemetry.
- Add regression tests for enrichment eligibility, preservation of review state/top-level fields, duplicate-history prevention and staged counts.

## Safeguards
No existing queue row was modified by this automation. No evidence approved/imported. No new task queued. TEST/LIVE separation and secrets preserved. No Research PC update, worker restart, merge or deployment. CI and PR review required before merge.


## Final controlled-run metrics — 7 November 2026, 22:54 UTC

All eight subtasks completed. Aggregate: 31 search results, 13 product pages discovered, 8 fetched, 8 candidate captures, 5 Gemma calls, 2 malformed-JSON batch failures, 0 accepted candidates, 0 new review rows staged, 8 duplicate skips.

- Anycubic Kobra S1 / uk_new: 7 fetched; five structured observations across extraction batches 1, 2 and 4; two raw fallbacks from batch 3; all seven URLs matched existing queue rows and were skipped by dedupe.
- Anycubic Kobra S1 / uk_used: 2 discovered, 0 fetched; both page fetches failed.
- Bambu Lab A1 / uk_new: 0 results, 0 pages discovered.
- Bambu Lab A1 / uk_used: 3 discovered, 0 fetched; all three page fetches failed.
- Creality K1 / uk_new: one Creality K1 Max sibling-variant page fetched; extraction JSON failed; duplicate skipped and retained for ChatGPT classification.
- Creality K1 / uk_used: 0 pages discovered.
- Elegoo Neptune 4 Pro / uk_new: 0 results; the ELEGOO UK source was added after the run loaded source rows.
- Elegoo Neptune 4 Pro / uk_used: 0 pages discovered.

The used-lane five page fetch failures included eBay HTTP 403 responses. Do not bypass anti-bot controls. New-retailer routes for 3DFLO, iDig3DPrinting and 123-3D failed under the old generic route configuration; the source registry was corrected after this run began.

PR #281 (source-route correction) remains open/unmerged; CI run 42422365717 passed 35 tests and Cloudflare PR preview builds completed. PR #282 (safe review-queue duplicate enrichment) remains open/unmerged; CI run 42423080557 passed 35 tests and the Cloudflare build check was still in progress at the last check.

The LIVE review queue remains 40 needs_research rows (3 top-level observed prices, 1 typed evidence row). No rows from this run were added or updated; no approval/import occurred. The safe enrichment PR intentionally appends observations only to unreviewed raw captures and leaves top-level price/evidence fields and review status unchanged.
