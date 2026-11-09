# Gemma specialist category workers and website routes — 9 November 2026

## Decision
The Windows Research Control Centre exposes one independently switchable Gemma specialist per TradeFlow product category: 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, and Cameras & Lenses.

The seven specialists share one persistent queue supervisor and one Ollama execution lane. Do not run seven competing Node workers. The desktop config defaults to all seven specialist switches enabled, with per-agent disable/enable controls and individual desktop shortcuts.

## Website research
LIVE source registry audit: 119 UK source records, 116 enabled. Existing source records are retained; no duplicate source rows are inserted. Category coverage counts overlap where sources are shared.

A full re-read of the category-specific source-playbook blocks confirmed the additional registered UK domains already had specialist site definitions. The earlier route-count script used an incorrect block boundary and falsely reported those entries as missing. No source registry rows or website definitions were added or changed in this follow-up.

A regression test now protects the existing specialist definitions for the additional drone, mobile-phone and camera websites, plus Amazon UK and eBay UK marketplace search patterns for metal detectors. Discovery pages are not evidence; Gemma must follow exact product/listing links and capture the individual page for ChatGPT review. No autonomous approval/import is introduced.

## Deployment gates and safety
Code and documentation changes are on feature/gemma-desktop-control-centre-20261109, PR #325. The latest source-route/test commit is 74705aebb170487b8d3015cd654d466430be2727; documentation updates follow it. Re-check the PR's CI against the final head before merge.

The service-role-only platform_ai_agent_claim_task_for_agents(text,text[],integer) migration is part of PR #325 and has not been applied to LIVE. It must be reviewed and applied to LIVE before desktop installation/queue processing. If missing, the desktop worker stops with requires_migration and never falls back to the unscoped claim RPC.

No LIVE or TEST database migration, source registry, task queue, catalogue, evidence, approval or import data has been modified by this follow-up. No Research PC files, private .env, existing worker process or Windows service have been changed. Do not install or start the desktop supervisor until PR review/merge and LIVE migration deployment are complete.


## 9 November 2026 — 3D-printer retailer taxonomy matcher follow-up

- Current production base: 9b2027528243735a2fff35f9abc671673f864032 (PR #340 documentation-only commit; PR #339 Anycubic direct routes already merged).
- LIVE exact-branch task count at audit: 28 registered, 28 completed, 0 running/queued/failed. Category worker DESKTOP-LVASEUB-130972 last completed 22:35:49 UTC; generic worker heartbeat remained stale at 21:53:23 UTC.
- Latest task: owner-3d-printers-equipment-1794263685224, Anycubic Kobra 3 Max V2 / 4-Color Combo. Six search results; 14 approved-source route attempts (13 empty, one eBay HTTP 403); one product page discovered/fetched; one Gemma batch timed out after 48.4 seconds; full 16,285-character raw capture retained and staged.
- New queue row: 495eaf7f-b6ba-42e7-84b3-04bbe4ab4a5b, status needs_research, raw classification unverified_capture, no evidence type/price/reviewer/approval/import. Queue now has 68 records: 28 imported, 37 rejected, 3 needs_research. Two pending rows are marked uk_new; the new raw capture remains unclassified. Active shared evidence for the branch: 221 UK-new and 21 UK-used; 17 inactive UK-new. No new shared evidence was created.
- First newly verified matcher loss: exact 3DJake Kobra 3 Max V2 Combo product page was rejected because its parent category URL contains "accessories". Current matcher applies accessory keywords to the whole path. Search result confirms the product title "Anycubic Kobra 3 Max V2 Combo, 1 Set"; page-open returned 429, so its current detail content/price is not treated as evidence.
- PR #341 fixes this by applying accessory rejection to page title and terminal product slug only. It preserves exact model, sibling and package checks. Tests accept the 3DJake Combo, reject the Standard sibling for a Combo task, and reject replacement/nozzle pages.
- The latest task logged only the two generic Anycubic collection/search routes, not the model-specific direct routes merged in PR #339. Research PC loaded playbook remains unverified; updater and runtime reload are separate. No restart/update was performed.
- No TEST/LIVE crossover, source registry change, migration, evidence import, approval, secret or private .env access occurred.


Verification: PR #341 GitHub Actions run #594 passed 104/104 tests on the final code/test head. The branch remains open and unmerged. Research PC direct-route loading is still unverified.