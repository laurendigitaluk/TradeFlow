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
