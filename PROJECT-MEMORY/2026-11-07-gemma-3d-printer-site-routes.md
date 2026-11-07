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
