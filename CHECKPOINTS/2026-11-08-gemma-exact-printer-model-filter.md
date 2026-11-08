# Gemma exact printer model and package matching

Date: 8 November 2026 (UTC)
Scope: TradeFlow LIVE Gemma — category 3d-printers-equipment, branch 3d-printers.
Base: production after PR #284 merge 6064c0ef3205a5832fbac68ce5e5d9ebf640c6bd.
Branch: feature/gemma-exact-printer-model-filter-20261108.

## Diagnosis
LIVE review queue captures for a Creality K1 Standard Printer task included direct pages for K1 Max machines and K1 accessories/upgrade kits. The matcher intentionally retained sibling variants and accessory references for broad ChatGPT classification, but the resulting queue rows carried the requested task's Standard Printer identity. This creates avoidable model/package ambiguity.

## Change
- 3D-printer-only exact matching rejects sibling model suffixes when not part of the requested model.
- 3D-printer-only matching rejects accessory, spare, replacement and upgrade pages.
- Standard tasks reject Combo/AMS/ACE/CFS/multicolour package pages; Combo tasks require the matching package marker.
- Exact sibling-model tasks (for example K1 Max) and matching Combo tasks remain eligible.
- Short-model manufacturer/3D-printer context guard remains active.
- Other categories are unchanged.

## Verification and safety
Regression tests added for exact K1/K1 Max separation, standard/Combo separation, accessories and exact sibling task matching. CI pending. No LIVE/TEST data or source registry changes; no evidence approval/import; no task queued; no local .env or worker change; no deployment.

## Next step
After CI passes and merge, update the Research PC installation in place using the existing updater, preserving the private .env and TRADEFLOW_GEMMA_ENV_FILE. Confirm a fresh LIVE heartbeat and run a small 3D-only K1/K1 Max/Combo acceptance batch. Inspect staged rows to ensure no cross-model/package capture.
