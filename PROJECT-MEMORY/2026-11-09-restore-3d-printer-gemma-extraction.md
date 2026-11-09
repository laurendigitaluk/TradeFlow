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


## 9 November 2026 — post-merge verification status after PR #320

Scope remains LIVE category `3d-printers-equipment`, branch `3d-printers` only.

### Production code and CI
- PR #320, “Restore 3D-printer Gemma extraction path”, merged at 2026-11-09 02:06:14 UTC. Merge commit: `e81ede671bfc03e73dc16169638011372b5b6117`.
- The first workflow run #415 failed on commit `80fd198`: the raw-fallback test found that the 3D-printer fallback was using the Gaming-only `isCaptureOnlyResearchTask()` predicate and promoted a single visible price (actual 549; expected null).
- Follow-up commit `9a16d2d3c306d446f79c692ba59c4dda5bbc5384` separated the two responsibilities: `isCaptureOnlyResearchTask()` is Gaming-only, while `fallbackPageCapture()` still treats both 3D-printer and Gaming captures as raw/unverified and leaves `observed_price` null.
- GitHub Actions run #419 on the final PR head passed all **80/80** Node tests; PowerShell syntax, Node source syntax and Owner Dashboard JavaScript syntax also passed. The initial failed run is superseded by this final successful run.
- Current production `agent.mjs` has the Gaming-only capture bypass and the 3D-printer Gemma/Ollama `extractBatch()` path. The deterministic raw fallback remains available when extraction fails.

### LIVE task state at this checkpoint
- LIVE `platform_ai_agent_tasks`: 20 registered 3D-printer tasks, all completed; 0 queued, 0 running, 0 failed.
- Category status: idle; cumulative counters 85 completed / 122 candidates; last category heartbeat 2026-11-09 01:56:42.331 UTC. Category status metadata identifies `DESKTOP-LVASEUB-84452`.
- Generic queue-worker status: idle; last recorded heartbeat 01:16:09.583 UTC, worker ID `DESKTOP-LVASEUB-86464`. Current production `task-worker.mjs` emits heartbeats during task claims, not during idle polling; the old idle timestamp therefore does not prove the process is stopped.
- The latest two registered tasks both ran **before** PR #320 merged:
  - Ender-3 V3 KE, 01:55:49–01:56:09 UTC: 11 search results; 0 product pages discovered; 0 fetched; 0 Gemma calls; 0 candidates. 28 approved-source route attempts: 11 matched routes, 11 empty and 6 failed; two Creality collection JSON routes returned HTTP 404. The six route errors included Uni3Dverse 404, eBay 403 twice and 404, Amazon 404, and SecondHand.org.uk 404.
  - K1 Max, 01:56:24–01:56:42 UTC: 11 search results; 1 product page discovered and fetched; 0 Gemma calls because the old pre-merge capture-only code was still installed; 1 raw candidate. 28 route attempts: 11 matched, 11 empty, 6 failed; one collection error; 0 direct page-fetch errors. Queue write was `duplicate-skipped`, not a new or enriched row.
- The K1 Max duplicate points to an existing imported queue row already linked to active LIVE `uk_new` evidence at **£589 GBP** (`b21f9d59-b871-4c36-b7e6-456c85827bef`). This duplicate was not a missing evidence record. The new task result remains in task history; the imported queue row was not overwritten.
- No registered task has run after the PR #320 merge. Therefore the restored Gemma path is **merged and CI-verified, but not yet Research-PC/LIVE-runtime verified**.

### LIVE source and review evidence snapshot
- Enabled UK source registry: 15 sources — 13 category-specific and 2 universal (Amazon UK and eBay UK). No source rows were changed.
- Latest discovery loss is still search/route response to exact individual product page: Ender-3 V3 KE returned 11 search results but discovered 0 product pages. K1 Max discovered/fetched 1 of 11 search results.
- LIVE 3D-printer review queue: 65 historical rows — 28 imported, 37 rejected, 0 open. The 28 linked active `shared_market_evidence` rows comprise 23 `uk_new` and 5 `uk_used`; all 28 have GBP prices.
- Audit exception: 27 of the 28 imported queue rows have `reviewed_by IS NULL`; one has a reviewer ID. Queue-level evidence_type/observed_price fields are null on 27 rows even though their linked shared evidence records carry the evidence type and price. Do not infer unauthorised imports from the missing queue reviewer field alone. Preserve this for platform-owner audit; do not edit, reapprove or reimport these records.
- No new or used evidence was added by the two latest tasks. K1 was duplicate-skipped against existing imported evidence; Ender-3 V3 KE produced no product page.

### Outstanding worker observability
- PR #319 (idle generic queue-worker heartbeat) remains open/draft and GitHub reports `mergeable=false`. It is not merged or installed. No duplicate heartbeat PR has been created.
- The category status worker ID and generic queue-worker ID represent separate telemetry identities; do not assume they are the same process. Verify the installed Research PC process and its control-plane selection before interpreting them as one worker.

### Next verification gate
- Do not queue a duplicate task. After owner-authorised Research PC installation from production (preserving the existing private `.env`), verify the startup line confirms LIVE project `gxsrajtqzdjvmceqcpgv` and the installed test suite passes.
- Then use one owner-authorised, bounded 3D-printer LIVE task only when the worker is confirmed idle. Verify `extraction_batch_started`, `gemma_calls > 0`, retained raw fallback on extraction failure, and a new/enriched review capture as appropriate. Do not automatically approve or import evidence. Keep TEST and LIVE data separate.
