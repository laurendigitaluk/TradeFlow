# Gemma 3D printer short-model identity guard

Date: 7 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: feature/gemma-3d-printer-model-identity-guard-20261107
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
- Existing PR #278 remains open and unmerged for lane routing, parser compatibility and heartbeat/metrics work.
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
- Neither PR has been deployed to the Research PC. No LIVE review rows were approved or imported.
