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
