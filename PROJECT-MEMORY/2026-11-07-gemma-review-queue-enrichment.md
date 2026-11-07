# Project Memory — Gemma Review Queue Duplicate Enrichment

Date: 7 November 2026
Scope: TradeFlow LIVE Gemma, category 3d-printers-equipment, branch 3d-printers.

The active controlled rerun confirmed that duplicate deduplication can discard improved extraction. Anycubic Kobra S1 / uk_new fetched seven pages; extraction batches 1, 2 and 4 returned five structured observations, batch 3 failed JSON parsing and preserved two raw fallback pages. All seven URLs were already present in the review queue from the prior run. The current dedupe path checks only for an existing id and then skips; it does not enrich the existing unverified row. Those rows remain needs_research with null observed_price and evidence_type.

Two used subtasks discovered three eBay item pages but all direct fetches returned HTTP 403. Do not bypass anti-bot controls; record as a blocked source route and rely on accessible approved used sources.

Feature branch feature/gemma-review-queue-enrichment-20261107 proposes a safe enrichment path limited to 3D printers: only unreviewed/unapproved/unimported needs_research rows with unverified_capture classification and exact same category/branch/product/package/source URL may receive an append-only structured observation in raw_payload.enrichment_history and research_notes. Top-level price/evidence fields, status, reviewer notes and catalogue data remain unchanged. Enriched rows count as staged for ChatGPT review; global evidence_queued remains new unique rows only. The parent task key is propagated for traceability and model/lane context is added to progress telemetry.

No existing queue rows were changed, no evidence approved/imported, no new task queued, no TEST/LIVE crossover, no secret change, no Research PC update and no deployment. Wait for CI/PR review and explicit approval before merge or deployment.
