# Project Memory — Gemma Anycubic route and extraction repair

Date: 10 November 2026 UTC  
Scope: TradeFlow LIVE, 3D Printers & Equipment; shared runtime/test files for the seven isolated category specialists.

The independent Anycubic cross-check of LIVE task owner-3d-printers-equipment-1794272051590 found that Gemma had five subtasks, not six. Kobra S1 Standard was omitted from the payload. Across the five actual subtasks, six raw captures were retained/staged (three new, three enrichments), but all four Gemma extraction batches timed out. New review rows remain needs_research with no structured observed_price or evidence_type. The parent task completed and the worker returned idle; this is not a parent completion RPC failure.

Independent navigation of the same approved UK sites identified concrete missed routes:
- 3DJake UK generic /search?query route yielded no useful exact Anycubic links. Use https://www.3djake.uk/anycubic-3d-printer-and-accessories/anycubic-3d-printer, inspect its printer category and pagination, then follow direct exact product pages.
- 123-3D generic /collections/3d-printers missed the manufacturer-specific Anycubic collection. For new Anycubic products use https://www.123-3d.co.uk/collections/anycubic-3d-printers; for used/refurbished use /collections/refurbished-printers. Preserve lane separation. Reject Kobra 3 Max (not V2), Kobra 3 V2 and first-generation ACE Pro when task identity differs.
- eBay UK exact search returned HTTP 403. Add the approved ANYCUBIC FDM seller category https://www.ebay.co.uk/str/anycubic/FDM-3D-Printers/_i.html?store_cat=39698507014 as discovery. Direct item 403 remains blocked; do not bypass.
- Anycubic UK Kobra 4 Combo page https://uk.anycubic3d.com/products/kobra-4-combo-3d-printer was missing from the model-specific direct routes.

Matcher fault: the 3D-printer matcher searched accessory keywords across the full URL path and rejected a genuine 3DJake Kobra 3 Max V2 Combo page because its parent taxonomy contains "accessories". The fix applies accessory filtering to title and terminal product slug only, retaining exact model/package/sibling/accessory checks. The stale PR #341 branch is 22 commits ahead and 44 behind current production and GitHub marks it unmergeable. Its tested code correction is carried into a new branch based on current production: fix/gemma-research-route-extraction-all-seven-20261110.

Extraction fault: LIVE telemetry showed 47,282 ms for a two-page Gemma inference call, while the 3D-specific timeout was 45,000 ms. The replacement uses one direct page per Gemma call and one bounded 90,000 ms attempt. No per-page retries. Other category agents keep their existing batch size and timeout. Full page captures and visible GBP contexts remain available for ChatGPT review on failure; no price is inferred or auto-approved.

Seven isolated branches are:
gemma/3d-printers, gemma/gaming, gemma/cameras, gemma/drones, gemma/metal-detectors, gemma/mobile-phones, gemma/laptops.
The same shared worker and regression-test files must be synchronised to all seven while preserving each agent.config.json and source isolation. The production Control Centre Update all workers operation is designed to preflight all seven, wait for active tasks to finish without force-killing Node, update each category clone sequentially from its own branch, and restart only workers that were running before and updated successfully. Preserve the shared private ENV pointer and existing .env. Research PC rollout is not complete until all seven logs and LIVE telemetry have been checked.

Canonical docs updated on the replacement feature branch: docs/TRADEFLOW-SYSTEM-HANDBOOK.md, docs/TRADEFLOW-AI-OPERATING-MANUAL.md, docs/3D-PRINTER-GEMMA-AGENT-DIAGNOSTIC-ROADMAP.md. No LIVE database source, schema, task queue, review queue, catalogue, evidence, approval/import, tenant/customer, Stripe or secret data was changed. TEST remains separate. All evidence remains review-only.
