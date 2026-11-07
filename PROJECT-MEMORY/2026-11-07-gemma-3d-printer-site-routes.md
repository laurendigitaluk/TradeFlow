# Project Memory — Gemma 3D Printer Source Routes

Date: 7 November 2026
Status: LIVE source URLs recorded; code correction on feature branch; PR/CI pending.

## Scope and operating rules
- Only TradeFlow LIVE category 3d-printers-equipment, branch 3d-printers.
- Gemma collects and reports; ChatGPT/owner inspects. Never auto-approve or import catalogue evidence.
- Preserve TEST/LIVE separation, secrets, the Research PC .env, and TRADEFLOW_GEMMA_ENV_FILE.
- Do not enqueue a duplicate task or alter another agent/category.

## Verified LIVE source routes
- 3DFLO: https://www.3dflo.com/product-category/3d-printers/.
- iDig3DPrinting: https://www.idig3dprinting.co.uk/product-category/3d-printers/.
- 123-3D new: https://www.123-3d.co.uk/collections/3d-printers.
- 123-3D used/refurbished: https://www.123-3d.co.uk/collections/refurbished-printers.

The LIVE platform_research_sources rows for 3DFLO and iDig now store their category routes in search_url_template; the 123-3D row remains scope all, with both routes recorded in its notes. The 123-3D worker playbook must choose the collection by research_type, not probe both collections in each lane.

## Runtime findings
The active controlled task owner-3d-printers-controlled-rerun-20261107-2225 started before the source-registry update. At the latest inspection, it was still processing Anycubic Kobra S1 / uk_new: seven individual pages fetched; first two of four extraction batches each produced two structured observations and no raw fallback captures; batch three was in progress. No queue rows from this task had yet been committed. This is early progress, not a completed-run metric.

The previous completed eight-subtask run recorded 123 search results, 83 discovered pages, 51 fetched pages, 36 review captures, 27 Gemma calls, 20 batch failures and 15 duplicate skips. All four structured observations were Audi A1 car pages. PR #278 is merged into production; production commit 6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4 contains the short-model identity guard even though PR #279 remains open/unmerged. Do not merge the divergent PR #279 branch blindly.

## Confirmed route failure
The first active Anycubic new pass tried generic search routes for 3DFLO, iDig and 123-3D. 3DFLO and iDig returned 404/empty responses; 123-3D returned no matching links. Web inspection verified the category/collection URLs above. Production isCollectionDiscoveryPage did not recognise WordPress /product-category/ routes, and isEligibleProductPage did not explicitly exclude them.

## Proposed correction
Feature branch feature/gemma-3d-printer-source-routes-20261107 adds lane-specific 123-3D routes, verified 3DFLO/iDig category routes, WordPress discovery-page classification, and regression tests. Wait for CI and PR review. No merge/deploy or Research PC update is authorised yet.


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
