# Gemma concatenated Combo URL package matching — 8 November 2026

## Finding
Controlled LIVE task: `owner-3d-printers-exact-identity-acceptance-20261108-0032`.

The official Creality UK page `https://store.creality.com/uk/products/essential-combok1-max-hyper-pla-2` was staged under the Creality K1 Max Standard Printer task. Captured title: `K1 Max + PLA*2(White+Red)`; visible page price: £599.00. This is a printer bundle and must not be treated as standalone Standard evidence.

## Root cause
The matcher normalised URL punctuation but did not split concatenated bundle markers such as `combok1`. The package detector consequently missed the Combo marker in the URL even though the title and model tokens were present.

## Change
- Restore a token boundary after concatenated `combo`, `ams`, `ace`, and `cfs` URL markers before identity/package checks.
- Add a regression assertion for the exact Creality URL/title; it must be rejected for the K1 Max Standard task.
- Preserve existing sibling-model, accessory, short-ID, source-scope and category-isolation rules.
- Update both manuals and the Gemma research diagnostic roadmap.

## Scope and safeguards
3D-printer matching only. No LIVE queue rows, catalogue products/evidence, approvals/imports, source registry, task dispatch, TEST data, secrets, .env files or Research PC runtime changed by this code/documentation branch. The existing Research PC updater already installs `agent.mjs` and `source-playbooks.test.mjs`.

## Verification
GitHub workflow CI and the local Research PC updater test run are required before merge/deployment. Then rerun a small exact K1/K1 Max Standard-vs-Combo test and inspect page captures and package text. Do not approve/import automatically.


## 8 November 2026 — post-update LIVE acceptance and regression-fixture correction

- The latest completed 3D-only LIVE task was `owner-3d-printers-exact-identity-acceptance-20261108-0032` (00:32:26–00:47:00 UTC), with eight subtasks: 85 search results, 15 individual product pages discovered, 6 fetched, 6 captured, 4 Gemma extraction calls and 2 extraction-batch failures. It staged 4 new unverified queue rows and enriched 2 existing unreviewed rows; no evidence was approved or imported.
- The short-model guard is working: Bambu Lab A1 / Combo used research found 9 search results, but all 9 were Audi A1 car URLs rejected at `model_variant_skipped`; 0 product pages, captures or queue writes resulted. The Bambu A1 Standard used pass found one page but it was blocked at fetch (HTTP 403).
- Exact K1 Max new research exposed the still-open Combo-slug fault: `/products/essential-combok1-max-hyper-pla-2` was captured under K1 Max / Standard Printer with title `K1 Max + PLA*2(White+Red)`, visible £599.00. The same URL now exists in two unreviewed queue rows, one incorrectly attached to K1 Standard and one to K1 Max Standard. Both remain `needs_research`; no queue correction or approval was made.
- The first PR #287 regression assertion used the base K1 task. The existing sibling-model guard rejected K1 Max before package matching, so that assertion did not isolate the reported Combo-vs-Standard defect. The test has been corrected to use the exact K1 Max Standard task (must reject) and the exact K1 Max Combo task (must accept) against the same captured URL/title. This directly exercises the concatenated `combok1` boundary and package decision.
- Latest worker status is idle with no active/pending 3D task. Its last heartbeat is 00:47:00 UTC (65 minutes old at inspection); Supabase does not prove the Research PC process is currently online while idle. Do not queue another task until the PR is reviewed/merged and the local worker's current state is verified.
- Source routing still records 32 approved-route errors across 114 route attempts, plus 9 direct product-page fetch errors. Main blockers include Bambu official Shopify and Amazon route 404s, 3DFLO timeout, eBay HTTP 403, Uni3Dverse and SecondHand HTTP 404, and 123-3D direct listing 404/redirects. Do not bypass access controls.
- Queue now contains 44 3D-branch rows: 3 top-level prices, 2 enrichment histories, 1 reviewed marker, 0 approved and 0 imported. All new captures remain unverified review material.


### Verification note — exact package matcher smoke test
- Ran six focused assertions against the current PR branch matcher: K1 rejects K1 Max sibling; K1 Max Standard rejects the exact `essential-combok1-max-hyper-pla-2` bundle; K1 Max Combo accepts that same URL/title; standalone K1 Max remains accepted; Audi A1 car is rejected; genuine Bambu A1 Combo printer listing is accepted. Result: **6/6 passed**.
- This is a focused matcher smoke test, not the full repository suite. GitHub Actions run 42433260646 passed before the strengthened K1 Max Standard/Combo fixture was committed. A new CI run for the corrected test commit has not yet been observed; do not merge until it passes.
