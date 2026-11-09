# Project memory — Restore 3D-printer Gemma extraction

Date: 9 November 2026 (UTC)
Branch: fix/restore-3d-printer-gemma-extraction-20261109
PR: #320 — https://github.com/laurendigitaluk/TradeFlow/pull/320

## Confirmed regression
PR #316 changed `isCaptureOnlyResearchTask()` to return true for both 3D-printer and Gaming tasks. This caused the 3D-printer worker to skip `extractBatch()` and local Ollama/Gemma inference. LIVE task `owner-3d-printers-live-verification-k1max-20261109-01` (id `0ce88391-e5c2-45c4-adf9-149d364c702c`) explicitly recorded the capture-only stage and `gemma_calls: 0`. It retained a raw page capture but did not produce a new review-queue row because the matching source capture was duplicate-skipped. This is the concrete regression introduced by the Gaming rollout.

## Separate discovery issue
LIVE task `owner-3d-printers-live-verification-20261109-01` (id `5b3e53b0-b857-4f0b-89a0-e255596afd3c`) completed with 11 search results but zero eligible product pages; two Creality collection routes returned Shopify JSON 404. This is a distinct source-discovery problem, not evidence that Gemma extraction itself failed.

## Current LIVE source settings
The enabled 3D-printer source registry remains populated with the existing UK-new, UK-used and universal sources. No source rows were changed during this repair. Research PC configuration and worker installation were not changed.

## Correction
PR #320 changes only `isCaptureOnlyResearchTask()` so that Gaming remains capture-only and 3D printers resume the established Gemma/Ollama `extractBatch()` workflow. It adds a regression test asserting 3D printer false / Gaming true. Raw fallback and ChatGPT review remain in place. No catalogue data, queue records, approvals, imports or TEST data are modified.

## Verification gate
- CI workflow: Gemma Research Tests, run #415 (commit `80fd19836aa7396da827c788209e9e7168db4281`).
- After merge, run one controlled 3D-printer LIVE task only after checking worker status; confirm `extraction_batch_started`, `gemma_calls > 0`, and a new/enriched review capture as appropriate.
- Do not alter 3D source settings or Research PC installation unless independent telemetry proves they need attention.
