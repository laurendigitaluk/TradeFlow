# Combined Gemma capture and source routing checkpoint

Date: 8 November 2026 (UTC)
Branch: fix/gemma-capture-source-routing-20261108c
PR: #314
Scope: 3D-printer structured GBP page capture + category-scoped approved-source loading.

## Combined code changes

1. For 3D-printer tasks only, extractRelevantPageText parses matching JSON-LD Product/Offer facts and places those structured facts before long flattened page content. Manufacturer/model identity must match the task. GBP amounts are rendered with explicit GBP; non-GBP currencies remain distinct. Other categories retain content-first ordering.
2. buildApprovedResearchSourcesPath(task) loads only enabled GB sources whose category_slugs overlap the task category or explicit universal * sources. Missing/malformed category fails closed. Existing manufacturer checks, 3D-printer new/used lane checks, URL/host validation and raw capture hand-off remain.
3. Regression tests are included in GitHub CI and the Research PC updater:
   - agent-speed.test.mjs covers structured GBP capture, non-GBP handling and preserving other-category ordering.
   - agent.source-selection.test.mjs covers all seven specialist categories, universal sources, enabled/GB filters and fail-closed category validation.
4. Update-TradeFlow-Gemma.ps1 includes both test files and validates before/after installation.

## Merge history

- PR #310 was the original 3D-printer structured GBP capture fix.
- PR #311 was the original category-source filter.
- PR #313 combined both but became conflicted after concurrent documentation updates.
- PRs #310, #311 and #313 are closed/superseded. PR #314 is the clean branch from current production. Do not merge the stale PRs independently.

## Gaming catalogue parity already completed

LIVE project gxsrajtqzdjvmceqcpgv and TEST project nnsshnfkjcflucjrftzi independently reconciled:
- 285 total product rows, 284 active, one inactive duplicate product row.
- 411 active evidence rows: 246 UK-new, 165 UK-used.
- 20 branches, 24 manufacturers.
- Zero product field differences and zero active evidence field differences.
- Zero open gaming queue records and zero active gaming tasks.
- Gaming source registry: 12 category-specific UK sources plus 2 universal marketplaces (Amazon UK, eBay UK), 14 loadable sources in both environments.
- TEST has one additional inactive historical Xbox Series X Digital listing evidence row; do not copy it to LIVE.
- Nintendo Switch 2 Joy-Con 2 Charging Grip duplicate package row retained inactive, “Single Charging Grip” alias added, unique used eBay evidence moved, duplicate Argos/Smyths captures marked inactive. No records deleted.

## Source registry audit

Enabled UK sources including universal marketplaces:
- 3D printers: LIVE 15 / TEST 5 (known source-registry parity gap).
- Cameras: 16 both.
- Drones: 8 both.
- Gaming consoles: 14 both.
- Laptops: 12 both (Dell, HP and Lenovo official UK sources added independently to both environments).
- Metal detectors: 8 both.
- Mobile phones: 13 both.

Only Amazon UK and eBay UK are explicitly universal. Vinted has no category assignment and US sources are excluded. Do not add more manufacturer sources until the category filter is merged and installed.

## Deployment gate

PR #314 must pass the combined CI workflow and merge. Then run Update-TradeFlow-Gemma.ps1 on the Research PC from production without -StartWorker. Verify syntax and both test suites. Start one controlled gaming task in TEST, inspect source list/raw capture/evidence, then queue LIVE. No worker restart/deployment has occurred yet.


## 9 November 2026 — 3D-printer LIVE watch: legacy dry-run identified and idle heartbeat corrected

Scope: LIVE category `3d-printers-equipment`, branch `3d-printers` only. No research task was queued, no worker was restarted, and no evidence was approved or imported during this watch.

### LIVE task and worker state
- The LIVE `platform_ai_agent_tasks` table contains 18 registered tasks matching the 3D-printer branch: 18 completed, 0 queued, 0 running and 0 failed. The category status counters are cumulative (83 completed / 121 candidates) and include activity-only runs; they are not the number of registered task rows.
- The latest registered platform task remains `owner-3d-printers-capture-only-smoke-20261108-2020` (Anycubic Kobra S1 Max Standard): 10 search results; 1 individual product page discovered and fetched; 27 approved-source route attempts (10 matched, 11 empty, 6 errors); 4 collection pagination pages; 0 direct page-fetch errors; 0 Gemma calls; 1 existing review row enriched; 0 new rows; 20.796 seconds.
- A separate K1 activity-only dry-run ran 2026-11-09 01:03:51–01:05:13 UTC. It was not a registered platform task and wrote no review rows. It found 11 search candidates (10 DuckDuckGo, 1 approved-source); 49 unrelated source rows were logged as skipped; 6 approved routes were empty (3 each on 3D Prima and 3DJake); 6 approved routes failed (Amazon HTTP 404 three times; eBay HTTP 403 once and HTTP 404 twice); one Creality source route found a page. Two Creality collection pages failed their Shopify products JSON fallback with HTTP 404. Four page-fetch attempts were recorded, with the two eBay fetches failing HTTP 403; two price-bearing pages reached one Gemma batch. One official Creality K1 Speedy page was marked `gemma_rejected`; one candidate was reported overall; zero rows were queued because the run was explicitly `mode=dry-run`.
- The K1 activity has no worker ID or installed source revision. It is not evidence of a post-merge production runtime test: current production `runTask()` uses `isCaptureOnlyResearchTask()` for 3D printers, retains every fetched page for ChatGPT, and deliberately skips Ollama/Gemma classification. Current `buildApprovedResearchSourcesPath()` returns only the 13 enabled category-specific GB sources plus the 2 universal sources. The K1 run's 49 unrelated-source skips and Gemma rejection therefore identify an older or alternate local execution path, but the exact local binary cannot be identified from its activity record. The official page also had conflicting stock observations (visible text said in stock; JSON-LD said out of stock); this should be retained as a borderline capture, not silently discarded.
- A persistent generic LIVE queue worker started at 01:16:09 UTC as `DESKTOP-LVASEUB-86464`, polling at 15 seconds. It is currently idle with no claimed task. The 3D category status row still reflects the earlier K1 activity (01:05:13, metadata worker `DESKTOP-LVASEUB-84452`); the old `3d-printers` alias row remains historical.

### Confirmed heartbeat observability gap and scoped correction
- Production `task-worker.mjs` reports `worker_started` once and sends a 45-second heartbeat only inside `processClaim()`. Its idle loop continues polling every 15 seconds but does not refresh `platform_ai_agent_status.last_heartbeat`. Consequently, the generic worker's 01:16:09 `last_heartbeat` is its startup/status event, not a periodic idle liveness signal. A stale timestamp while idle does not prove the process has stopped.
- Feature branch `fix/gemma-idle-worker-heartbeat-20261109` adds a generic `gemma-task-worker` idle heartbeat at a bounded cadence (at least 60 seconds, no more than 5 minutes). It emits only after a successful queue poll, only while no task or poll is in progress, and never overlaps another heartbeat. It updates the generic Task control status only; it does not write to a product-category status row, change source selection, invoke Gemma, enqueue tasks or alter evidence. The updater and launcher test lists are extended to install and run the helper/regression tests. The first CI run #409 exposed one test expectation mismatch (the helper's 4-minute result for a 60-second poll was incorrectly expected to be 5 minutes); the helper was corrected. GitHub Actions run #411 (ID 42545608449) on code commit `348a71bd0dd47c891e46707b6d0f9038758d8de0` passed 83/83 tests, including PowerShell syntax, Node syntax and Owner Dashboard JavaScript syntax. Subsequent branch commits update documentation only; no code changed after the tested commit. Research PC installation and runtime verification remain pending; this is not deployed.

### Review queue and evidence audit
- LIVE 3D-printer queue: 65 historical rows — 28 imported, 37 rejected, 0 open. The 28 linked `shared_market_evidence` records comprise 23 `uk_new` and 5 `uk_used`; all 28 have GBP observed prices. The K1 dry-run has no queue row. The status counter `evidence_queued=65` is a historical total, not the number currently awaiting review.
- Audit gap remains: 27 of the 28 imported queue rows have `reviewed_by IS NULL`; one has a reviewer ID. Do not infer an unauthorised import solely from this missing field, but preserve the audit exception for owner review. This watch did not alter any queue or evidence record.

### Next verification gate
- With owner approval, update the Research PC from production while preserving the private `.env`; verify the startup log says `VERIFIED control plane: LIVE (gxsrajtqzdjvmceqcpgv)` and confirm a subsequent idle heartbeat for the same worker ID. Do not queue another 3D-printer task until the installed source path is verified. The heartbeat change proves process liveness only; a separate controlled review-only run is still required to prove the installed `capture_only_started` path and current category source filter.
