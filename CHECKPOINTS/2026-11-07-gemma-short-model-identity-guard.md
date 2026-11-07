# Gemma 3D printer short-model identity guard

Date: 7 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: feature/gemma-3d-printer-identity-guard-production-rebase-20261107
Scope: LIVE research category `3d-printers-equipment`, branch `3d-printers` only.

## LIVE observations
- The aggregate task contains eight product/lane subtasks. Four subtask handovers have completed; a fifth was started. The parent task remains running and its queue lease is being renewed. The last agent-status heartbeat field is older than the task lease update; production status telemetry does not emit a fresh status heartbeat during long extraction calls.
- Four completed subtask handovers report 42 fetched page captures in total and 28 staged queue captures. Current queue counts are 28 total: 4 with structured Gemma observations and 24 raw fallback captures. The current production handover does not persist per-write duplicate status, so the 14-page difference cannot be conclusively attributed from stored telemetry alone.
- All four structured observations in the Bambu Lab A1 pass describe Audi A1 cars, not 3D printers. They were preserved for review and remain `needs_research`; none was imported or approved.
- Two later Gumtree raw captures are genuine used-printer candidates after direct ChatGPT inspection:
  - Bambu A1, £150, Loughor, collection only, visible condition “As good as new”, additional nozzles and PLA.
  - Bambu Lab A1 Combo with AMS Lite, £250, Nottingham, 134 print hours, visible condition “As good as new”, posted 12 hours before inspection. Suggested offer values are not the asking price. Captured structured markup says NewCondition, but visible page wording identifies a used item.
- Both queue rows retain the generic `Standard Printer` package label, so the Combo variant needs manual classification during review.

## First confirmed identity failure
Production `matchesTaskModel` intentionally performs broad matching but checks only the model token. A short identifier such as `A1` therefore matched unrelated Audi A1 car pages. The raw page capture preserved them, but structured observations could still be misrepresented under the requested printer identity.

## Change on this feature branch
- For this 3D-printer branch only, model identifiers of two characters or fewer now require manufacturer tokens or explicit “3D printer” context.
- Clearly automotive URL categories are excluded from this branch's candidate matching.
- Generic “A1 3D Printer” listings remain discoverable for ChatGPT review.
- Other categories and longer model identifiers retain existing broad matching behaviour.
- Regression tests cover false-positive Audi A1 pages, genuine Bambu A1 Combo pages, generic A1 3D-printer pages, and cross-category non-interference.

## Safety and next steps
- No LIVE queue records, product catalogue rows, shared evidence, source registry, TEST data, credentials, local .env files or Research PC installation were changed.
- Existing PR #278 is merged into production for lane routing, parser compatibility and heartbeat/metrics work.
- This change is submitted separately for review; CI must pass before it is considered verified.
- Keep all evidence in `needs_research` until ChatGPT/owner review. No automatic approval or import.


## Completed controlled run metrics (7 November 2026)

The eight-subtask LIVE task completed at 21:38:26 UTC. The worker returned to idle; the queue lease was cleared. No duplicate task was created.

| Metric | New lane | Used lane | Total |
|---|---:|---:|---:|
| Search results | 62 | 61 | 123 |
| Product pages discovered | 42 | 41 | 83 |
| Pages fetched with visible GBP | 30 | 21 | 51 |
| Unique review captures staged | 30 | 6 | 36 |
| Duplicate URL skips | 0 | 15 | 15 |
| Gemma extraction calls | 16 | 11 | 27 |
| Gemma batch failures | 14 | 6 | 20 |

The 15 used-lane duplicate skips were confirmed from the stored task result: five Anycubic official-store pages, nine Gumtree Audi A1 car pages, and one Creality K1 Max official-store page. These were already captured by the new passes. They were not 15 unique useful listings lost; they demonstrate the confirmed new/used source-lane contamination that PR #278 addresses.

The four structured queue observations all describe Audi A1 cars, not Bambu Lab A1 printers. The other 32 staged captures are raw fallback records. Every fetched page had visible GBP price mentions, but the 20 failed Gemma batches prevented reliable structured extraction for most pages.

The 83 discovered versus 51 fetched page gap remains unclassified in the current production task result. Production handovers do not persist per-page fetch errors or post-fetch model-mismatch counts. PR #278 adds route and page-fetch telemetry; a future follow-up should also count post-fetch model-variant skips so this gap can be reconciled exactly.

Elegoo Neptune 4 Pro produced five search results in each lane but zero eligible product pages, zero fetched pages and zero captures. Current production telemetry does not identify whether this was a source-route, page-eligibility or discovery failure.

## CI and review
- PR #279: https://github.com/laurendigitaluk/TradeFlow/pull/279
- CI run 42416812188 passed: 24 tests, 24 passed, 0 failed.
- PR #279 remains open and unmerged. PR #278 also remains open and unmerged; its latest Gemma Research Tests run 42412984353 passed.
- Neither change has yet been installed on the Research PC. No LIVE review rows were approved or imported.


## Additional ChatGPT source investigation

- 123-3D's direct page confirms `Refurbished Grade A: Anycubic Kobra S1 Combo` at £370. It explicitly says second-hand/Grade A and identifies the ACE Pro Combo variant. Availability is contradictory on the page: “backordered and will ship as soon as it is back in stock” and “In stock / same-day dispatch” both appear. Treat it as a strong refurbished-price candidate with unresolved availability, not a clean in-stock observation. The LIVE source registry currently marks 123-3D `new_uk`; PR #278's used-lane isolation would exclude it from used searches. No source-registry change was made; the owner must decide whether this mixed new/refurb retailer should be `all` or separately represented.
- Anycubic's official Kobra S1 page shows £319 sale versus £549 regular price; this is new retail, not used evidence. The Kobra S1 Max Combo page shows £857 versus £1,218.97 and is a distinct Max Combo package, not standard Kobra S1.
- The Creality K1 eBay product page reports “currently sold out”. The £208.69 + £20 postage mention belongs to a related pre-owned item, not a confirmed active listing for the target page. Do not use it as current used asking-price evidence.
- The Amazon direct K1 capture contains £299.00 in the fetched page text, but the live Amazon page returned HTTP 503 during ChatGPT inspection. Keep the raw capture for later re-check; do not mark the price as independently verified.
- Creality's official K1 Max page currently shows £589 sale versus £729 previous, with separate package options including K1 MAX + CFS-C £799, K1 Max + PLA*2 £599, K1 Max + Ferret Pro £839, K1 Max + build plate/nozzle kit £609, and Sermoon S1 + K1 Max £2,599. These are K1 Max or bundle variants, not the requested standard K1. The page's package selector is useful variant evidence but must not be copied into the Standard Printer product.


## Elegoo source coverage gap

Both Elegoo Neptune 4 Pro subtasks returned five search results but zero discovered product pages and zero captures. LIVE `platform_research_sources` contains no Elegoo domain (including no wildcard entry). ChatGPT found the official UK product page at `https://uk.elegoo.com/products/elegoo-neptune-4-pro-fdm-3d-printer`, showing £169 sale versus £290 regular and UK delivery information. This is a strong candidate for a category-scoped `new_uk` manufacturer source. The LIVE source registry was not changed; owner approval is required before the worker uses it.

Latest verification for this branch: CI run 42417043572 passed on head `555c75f32dc9e997200ef405c687970ee957f07d` (24 tests, 24 passed, 0 failed). The original PR #279 branch could not be merged after PR #278 changed production; this production-based follow-up carries the same identity guard. PR #278 is merged into production; latest known Gemma Research Tests run 42412984353 passed.
