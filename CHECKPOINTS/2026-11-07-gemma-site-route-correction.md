# Gemma 3D Printer Source Route Correction

Date: 7 November 2026
Scope: TradeFlow LIVE Gemma only — category 3d-printers-equipment, branch 3d-printers.
Repository: laurendigitaluk/TradeFlow
Production base: 6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4
Feature branch: feature/gemma-3d-printer-source-routes-20261107

## Confirmed LIVE diagnosis
- Active task: owner-3d-printers-controlled-rerun-20261107-2225 (queue ID 8bd45c5a-0c0a-4848-b053-2701ca742aff). It was running on DESKTOP-LVASEUB-42580 with renewing heartbeats.
- First Anycubic Kobra S1 / uk_new pass: one collection page yielded seven exact-model links; seven individual pages were fetched. Extraction batches 1 and 2 each returned two structured observations and zero raw fallbacks; batch 3 was in progress at the last check. Parent task results and queue writes are not committed until the subtask finishes.
- Route failures in that pass: 3DFLO generic search returned HTTP 404 plus an empty WordPress search route; iDig generic search routes returned HTTP 404/empty; 123-3D generic search routes returned no matching links. The opposite-lane sources (eBay, Gumtree, SecondHand, Uni3Dverse, 3DGBIRE) were skipped by the new lane filter as intended.
- Previous completed run (8 subtasks): 123 search results, 83 product pages discovered, 51 fetched, 36 unique review captures, 27 Gemma calls, 20 batch failures, 15 duplicate URL skips. Four structured observations were all Audi A1 car pages. This is the baseline; the active run is incomplete and must not be compared as a completed aggregate.

## Verified source routes
- 3DFLO UK: https://www.3dflo.com/product-category/3d-printers/ (WordPress category discovery page).
- iDig3DPrinting UK: https://www.idig3dprinting.co.uk/product-category/3d-printers/ (WordPress category discovery page).
- 123-3D new: https://www.123-3d.co.uk/collections/3d-printers.
- 123-3D used/refurbished: https://www.123-3d.co.uk/collections/refurbished-printers.

The LIVE source registry was updated: 3DFLO and iDig search_url_template now point to their verified category pages; the 123-3D row remains scope all and its notes record both collection routes. The code playbook selects 123-3D routes by research_type, keeping new and refurbished routes separate.

## First point of loss
For these approved sources, useful pages were lost before individual page fetching because the worker generated generic search URLs that returned 404 or no links. A further classification gap meant WordPress /product-category/ pages were not recognised as collection discovery pages and were not explicitly excluded from direct product-page classification.

## Proposed code correction
- Use lane-specific 123-3D routes for uk_new and uk_used; retain both only for a combined uk_both task.
- Use the verified WordPress 3D-printer category routes for 3DFLO and iDig.
- Recognise /product-category/ as a discovery page and exclude it from direct product-page eligibility.
- Add regression tests for route isolation, WordPress category classification and extraction of exact individual product links.

## Safeguards
- No new research task queued; no duplicate work.
- No candidate approved, rejected or imported; queue remains review-only.
- TEST and LIVE remain separate. No schema, Stripe, Cloudflare, tenant, customer or payment data changed.
- No Research PC files, .env, secrets, Ollama settings or worker process changed.
- PR review and CI are required before merge. Do not deploy or update the Research PC until explicitly approved and the current active run is complete.


## Verification update — 7 November 2026, 22:46 UTC

- PR #281 is open and mergeable: https://github.com/laurendigitaluk/TradeFlow/pull/281.
- Gemma Research Tests run 42422054014 completed successfully: 35 tests passed, 0 failed, 0 skipped. The syntax checks also passed.
- Cloudflare Workers preview builds for the tradeflow and tradeflow-test services both completed successfully. The tradeflow check returned a feature-branch preview URL; these are PR previews, not a production merge/deployment.
- No merge, production deployment, Research PC update or worker restart was performed.
- The LIVE worker remains on the existing active task. At 22:46 UTC it was still in the fourth extraction batch of the first Anycubic Kobra S1 / uk_new subtask, with a renewing heartbeat/lease. Batch 3 had failed JSON parsing and its two pages were retained as raw fallback captures. No completed subtask handover or queue rows from this active task had yet been committed.
- All review captures remain unapproved and unimported. No TEST/LIVE crossover or secret changes occurred.


## 7 November 2026 — canonical source URL de-duplication

The LIVE source registry and site playbook both carry the verified 3DFLO/iDig category URLs. To avoid probing the same page twice through bare-host and www redirects, the playbook now stores the verified canonical www URLs and buildWebsiteSearchRoutes accepts absolute routes as well as relative paths. The same canonical-host treatment is used for 123-3D's new/refurbished collections. Regression coverage verifies that a configured search_url_template and its playbook route collapse to one URL. This remains confined to the 3D-printer source playbook; no other category route logic is changed.


## 7 November 2026 — ELEGOO UK new/pre-owned route coverage

- LIVE already contains the enabled ELEGOO UK manufacturer source for category `3d-printers-equipment`. ChatGPT verified the official UK FDM collection `https://uk.elegoo.com/collections/fdm-printers`: it exposes 60 products and lists the Neptune 4 Pro with GBP pricing. The official pre-owned collection `https://uk.elegoo.com/collections/pre-owned-3d-printer` exposes 27 products and includes a Neptune 4 Pro entry, but that entry is currently marked sold out. Both URLs are discovery routes only; Gemma must follow individual product pages and verify current availability.
- LIVE source notes now record both URLs. The source's current `research_scope` remains `new_uk` until the lane-specific playbook is reviewed and deployed; do not let the pre-owned route enter the used lane before that coordinated change.
- This feature branch adds `uk.elegoo.com` to the 3D-printer playbook with Shopify collection discovery and strict routes: `uk_new` → `/collections/fdm-printers`; `uk_used` → `/collections/pre-owned-3d-printer`; `uk_both` → both. Generic search fallback is disabled for this site. Sold-out individual listings must not be accepted as current used evidence.
- Regression tests verify the three lane route sets and confirm both collection pages are discovery pages, not direct product evidence.
- This is confined to the 3D Printers source playbook. No catalogue/evidence import, approval, task enqueue, TEST/LIVE data copy or secret change is included.
- PR #281 remains open and unmerged. Do not merge/deploy or widen the LIVE source scope until owner review and the Research PC/runtime route acceptance test.


## 7 November 2026 — ELEGOO UK host eligibility guard

- The official storefront is hosted on `uk.elegoo.com`, which is not covered by the generic `.co.uk`/UK-path check. Without an explicit allow-list entry, the verified FDM and pre-owned collection pages and direct product pages would be rejected by `ukHost()` even though the site displays GBP and explicitly ships to the United Kingdom.
- The 3D-printer UK source-host allow-list now includes `uk.elegoo.com`. Regression coverage includes an individual Neptune 4 Pro product URL, plus the new/used collection discovery routes; collections remain ineligible as direct product evidence.
- The source registry remains `new_uk` until the lane-specific playbook is reviewed/deployed. No used-lane activation, catalogue approval/import, TEST/LIVE crossover or secret change is included.


## Verification update — 7 November 2026

- Added `uk.elegoo.com` to the explicit UK 3D-printer source-host allow-list; without this, the .com subdomain would fail the UK host check despite its GBP/UK storefront.
- Added ELEGOO lane-specific collection routing and tests for new, used and combined tasks, collection discovery-only classification, and direct Neptune 4 Pro product-page eligibility.
- Focused Node.js checks for the eight route/host assertions passed: 8 passed, 0 failed. The last available GitHub Actions run for PR #281 (42422365717) passed 35/35 before the ELEGOO additions; a new CI run covering these additions has not yet been observed. PR remains open and unmerged.
- LIVE ELEGOO source scope remains `new_uk`; the used collection is recorded but intentionally not enabled for used-lane research until after reviewed/deployed route code.
