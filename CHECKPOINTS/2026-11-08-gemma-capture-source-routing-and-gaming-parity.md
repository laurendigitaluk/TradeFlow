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


## 8 November 2026 — PR #314 merged; Research PC verification still pending

### Production source state
- PR #314, “Combine Gemma GBP capture and category-scoped source routing”, merged to the production branch at 22:47:19 UTC.
- Merge commit: `e4ee0454b6e901d08dc43673df16b4637c10b712`.
- GitHub Actions Gemma Research Tests run #392 (ID `42531908294`) completed successfully: **76 passed, 0 failed**. The run checked updater PowerShell syntax, Gemma source syntax, all Gemma/playbook tests and Owner Dashboard JavaScript syntax.
- The merged code now uses `buildApprovedResearchSourcesPath(task)` to request only enabled GB sources whose `category_slugs` overlap the task category or the explicit universal `*` marker. Missing/malformed categories fail closed. Only Amazon UK and eBay UK are universal.
- For the 3D-printer branch only, matching manufacturer/model JSON-LD Product/Offer facts are placed before long flattened page text. GBP is emitted in parser-recognisable form; other currencies are not relabelled. Other categories retain their prior content-first ordering.
- PR #312 was closed as superseded by #314; its structured GBP change is included in the merged implementation. No code from #312 was separately merged.

### LIVE 3D-printer worker snapshot (read-only)
- Scope: category `3d-printers-equipment`, branch `3d-printers`.
- No queued, running or failed `platform_ai_agent_tasks` rows; no active task.
- Category status is idle, 81 completed tasks, 119 candidates, 65 historical queue rows, no last error. Last category heartbeat: 2026-11-08 21:49:02 UTC. Status metadata still identifies worker `DESKTOP-LVASEUB-84452`; the latest registered capture task used `DESKTOP-LVASEUB-22608`. The K1 dry-run activity has no worker ID. Do not infer concurrent workers; the Research PC process identity remains unverified.
- Latest registered task remains `owner-3d-printers-capture-only-smoke-20261108-2020` (Anycubic Kobra S1 Max Standard): 10 search results; 1 individual product page discovered and fetched; 27 approved-source route attempts (10 matched, 11 empty, 6 errors); 4 collection pages; 0 direct page-fetch errors; 0 Gemma/Ollama calls; 1 existing review record enriched; 0 new rows; 20.796 seconds.
- Route failures in that task: Uni3Dverse HTTP 404; eBay UK HTTP 403 twice and 404 once; Amazon UK HTTP 404; SecondHand.org.uk HTTP 404.
- A separate 21:48 K1 activity-only dry-run found/fetched the Creality K1 Speedy page, made one Gemma call and reported one candidate, but wrote zero review rows because it was explicitly `mode=dry-run`. The activity record does not retain the candidate payload. It is not a registered platform task and is not a ChatGPT review capture.

### First measured loss point
- In the earlier six-product 16:45 benchmark, 21 discovered pages reduced to 11 fetched, with 9 explicit product-page fetch errors; Gemma then failed 5 of 7 extraction calls.
- In the latest registered capture-only task, the fetch stage succeeded for the one discovered page (1/1, zero fetch errors). The current measurable bottleneck has therefore shifted earlier: 10 search results yielded only 1 individual product page. Route-match counts are not product-page counts.
- No post-merge Research PC run exists yet. Do not claim the merged source filter or JSON-LD fix has improved LIVE runtime until a controlled post-install run measures it.

### Review queue and evidence audit
- LIVE 3D-printer review queue: 65 rows total — 28 imported, 37 rejected, zero open.
- All 28 imported queue rows link to LIVE shared evidence: 23 `uk_new`, 5 `uk_used`. The 37 rejected rows have no evidence link.
- Only 1 of the 28 imported queue rows has `reviewed_by` populated; 27 do not. The queue rows also have only one explicit `evidence_type='uk_new'`; the linked shared-evidence records carry the 23/5 classification. Treat the missing reviewer IDs as an audit gap. Do not infer who authorised those rows, rewrite history or reverse imports without owner direction.
- The normal `platform_owner_review_catalogue_research_item` RPC requires an authenticated active platform owner and writes `reviewed_by=auth.uid()` and `reviewed_at`. This watch performed no approval or import and made no queue/evidence changes.

### Source registry and environment separation
- LIVE currently has 15 enabled GB sources loadable for 3D printers: 13 category-specific and 2 universal.
- The last recorded TEST registry audit was 5 loadable sources versus LIVE 15. This is a known parity gap, not permission to copy source rows. Recheck TEST independently before its next smoke test and add only individually verified sources if authorised.
- PR #314 is a production source merge, not proof of Research PC installation. Worker control plane defaults to TEST; LIVE requires explicit environment selection and matching project credentials. Preserve both project configurations and the private `.env` / `TRADEFLOW_GEMMA_ENV_FILE`.

### Next verification gate
1. Update the Research PC from the production branch using the approved updater, without `-StartWorker`; preserve the existing private environment file.
2. Confirm the updater reports TEST as the selected control plane and both regression suites pass locally.
3. Reconcile the installed worker identity before starting it.
4. Use the already-existing 3D-printer TEST smoke task only after rechecking that it is still queued; do not create a duplicate task. Inspect the category-filtered source list, structured GBP capture and raw review handoff.
5. Only after successful TEST verification and explicit owner approval should a single bounded LIVE replay be considered.
- No worker was restarted, no task was queued, no source registry was edited, no evidence was approved/imported, and no TEST/LIVE data or secrets were changed during this watch.
