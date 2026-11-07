# Project Memory — Gemma Review Queue Duplicate Enrichment

Date: 7 November 2026
Scope: TradeFlow LIVE Gemma, category 3d-printers-equipment, branch 3d-printers.

The active controlled rerun confirmed that duplicate deduplication can discard improved extraction. Anycubic Kobra S1 / uk_new fetched seven pages; extraction batches 1, 2 and 4 returned five structured observations, batch 3 failed JSON parsing and preserved two raw fallback pages. All seven URLs were already present in the review queue from the prior run. The current dedupe path checks only for an existing id and then skips; it does not enrich the existing unverified row. Those rows remain needs_research with null observed_price and evidence_type.

Two used subtasks discovered three eBay item pages but all direct fetches returned HTTP 403. Do not bypass anti-bot controls; record as a blocked source route and rely on accessible approved used sources.

Feature branch feature/gemma-review-queue-enrichment-20261107 proposes a safe enrichment path limited to 3D printers: only unreviewed/unapproved/unimported needs_research rows with unverified_capture classification and exact same category/branch/product/package/source URL may receive an append-only structured observation in raw_payload.enrichment_history and research_notes. Top-level price/evidence fields, status, reviewer notes and catalogue data remain unchanged. Enriched rows count as staged for ChatGPT review; global evidence_queued remains new unique rows only. The parent task key is propagated for traceability and model/lane context is added to progress telemetry.

No existing queue rows were changed, no evidence approved/imported, no new task queued, no TEST/LIVE crossover, no secret change, no Research PC update and no deployment. Wait for CI/PR review and explicit approval before merge or deployment.


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
