# Project memory — 3D-printer discovery, capture and used-lane repair

Date: 9 November 2026 UTC
Repository: `laurendigitaluk/TradeFlow`
Base: production `de1b8d4e12edf0102cea28f935a763826ff1c06b`
Feature branch: `fix/gemma-3d-discovery-capture-elegoo-used-20261109`
PR #332: https://github.com/laurendigitaluk/TradeFlow/pull/332

## LIVE baseline
Scope is only category `3d-printers-equipment`, branch `3d-printers`, LIVE project `gxsrajtqzdjvmceqcpgv`.
- 19 exact registered task rows, 56 product subtasks; 19 completed, 0 queued/running/failed. Latest task completed 01:56:42 UTC.
- Ender-3 V3 KE: 11 search results, 0 exact pages discovered/fetched, 0 Gemma calls; 28 approved-source route attempts, 11 route matches, 11 empty, 6 errors, two Creality collection JSON 404s.
- K1 Max: 11 search results, 1 exact page discovered/fetched, 0 Gemma calls because it predates PR #320 merge, 1 raw candidate, queue write duplicate-skipped against existing imported evidence. It also probed the unrelated Ender-3 V3 family collection and got one 404.
- First loss: search to exact individual product page. Next loss after a successful page: structured Gemma output and final review handoff cap the page at 10,000 characters.

## Category and evidence counts
Correct master category ID for `3d-printers-equipment`: `ab8b13b0-b070-4534-838b-3ebd4d7261e5`.
- 208 master products, 201 active/customer-visible.
- 277 shared evidence rows: 260 active (239 UK-new, 21 UK-used), 17 inactive.
- Review queue: 65 historical rows (28 imported, 37 rejected, 0 open). 28 queue rows link to active evidence (23 new, 5 used), all GBP.
- 62 queue rows contain page captures; maximum stored capture text and source excerpt are 10,000 characters.
- 64/65 queue rows lack reviewer ID; 8 imported rows also lack review timestamp; 64/65 queue rows lack top-level evidence_type. Do not infer reviewer identity or alter historical review decisions.

## Proposed current-production fixes
1. Full-page retention: `shouldRetainFullPageCapture(task)` retains full page text for 3D printers and existing Gaming capture path, while other categories keep the 10,000-character cap. A 40,642-character fixture improves from 10,000 retained (24.6%) to 40,642 (100%), +30,642 characters.
2. Creality route scope: the Ender-3 V3 collection is selected only when the model contains `ender-3 v3`; K1 Max no longer probes that unrelated route. Ender-3 V3 KE keeps the route. This does not claim the Shopify JSON 404 is fixed.
3. ELEGOO used lane: exact existing LIVE ELEGOO UK source remains `research_scope='new_uk'`, while the existing playbook already has FDM new and pre-owned used routes. Add ordered update-only migration `20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql` changing that exact source to `all`; do not apply it without explicit approval. TEST has no matching row per prior checkpoint; no data is copied.

## Regression tests
Four new tests cover full-page category retention, successful mocked Gemma extraction with a long page, Creality model-specific route selection, and ELEGOO lane eligibility while preserving manufacturer/category boundaries. Collection pages remain discovery only; no automatic evidence approval or import.

## Safeguards
No task queued, no worker restarted, no LIVE/TEST data copied, no source row changed, no migration applied, no review/evidence row changed, no approval/import, no secret or private .env accessed or modified.

## Acceptance
After review/approval, install current-production-based code while preserving private .env; apply the update-only migration only through approved release; run one bounded 3D-printer verification and confirm exact page discovery, Gemma extraction, full capture handoff, and new/used separation.


## Verification
GitHub Actions Gemma Research Tests run #504 passed on code/test head `4e0f13230de6833f6e4f0fe11e64a70f6f1458ed`. PowerShell updater syntax, Node syntax, the full Gemma test command (including full-page, Creality route and ELEGOO lane regressions), and Owner Dashboard JavaScript syntax passed. Both Workers Builds checks (`tradeflow` and `tradeflow-test`) passed. PR #332 is ready for review and mergeable; the ordered migration remains unapplied and no deployment was performed.


## LIVE latency and evidence-multiplicity follow-up — 9 November 2026

### Controlled LIVE finding (pre-fix baseline)
Task \`owner-live-3d-printers-worker-check-neptune4pro-20261109-1445\` (UUID \`2d5f202f-d37e-4180-ba54-7274d99f4c98\`) completed on the single LIVE worker in 1,156.5 seconds. It found 29 search results, checked 12 approved sources, identified six direct-page candidates, successfully fetched three pages and received three eBay HTTP 403 responses. The first two-page Gemma request timed out at five minutes; the old implementation then performed sequential single-page retries with the same timeout. Three raw page captures were retained, but all three were duplicate-skipped against existing imported captures for the same source URL. This demonstrated a queue-blocking extraction timeout and an idempotent duplicate hand-off, not a discovery failure.

### Repair made on the PR #332 branch
- 3D printers continue to use Gemma/Ollama; do not revert to capture-only mode (the PR #320 restoration of the 3D Gemma path remains intentional).
- Added \`getGemmaExtractionTimeoutMs\`: default 45 seconds for 3D-printer batches, hard-capped at 45 seconds; optional \`GEMMA_3D_EXTRACTION_TIMEOUT_MS\` can lower/retain that limit. Other categories retain their established \`OLLAMA_TIMEOUT_MS\` behaviour.
- Removed sequential 3D per-page retries. A timeout or invalid Gemma response immediately yields full raw captures for every fetched page in that batch and continues the hand-off, so the shared queue is not held for repeated five-minute waits.
- Reduced the 3D model output budget to 768 tokens, source excerpt to 1,800 characters, structured price observation limit to eight, and the input price preview to 12 entries. Full page text and the full deterministic GBP price/context list remain in raw captures for ChatGPT.
- Each source page now passes its approved website navigation note into the Gemma prompt. The worker, not Gemma, discovers pages through the approved source playbooks. Gemma is told not to browse, invent URLs, approve/reject evidence or decide suitability.
- Tightened 3D-printer website routes and instructions for Creality, Bambu Lab, Anycubic, ELEGOO, Uni3Dverse, 3DGBIRE, 3D Prima, 123-3D, iDig3DPrinting, 3DFLO, 3DJake, Gumtree, SecondHand, eBay and Amazon; removed redundant generic search fallbacks. Creality Ender-3-family collection remains model-specific.
- Extracted \`buildEvidenceCaptureDedupeKey\` without changing the existing hash tuple. Same product/package/source URL remains idempotent; distinct source URLs create separate captures.
- LIVE index/schema verification: \`platform_catalogue_research_queue\` is unique on \`dedupe_key\`; \`shared_market_evidence\` is unique on \`(source_name, source_record_key)\` and has a non-unique product/type/date index. LIVE currently contains active products with up to 10 UK-new and 20 UK-used records of the same type per product. No database uniqueness change is needed.

### Release status / safeguards
- Code and regression tests are on this PR branch only; not deployed to the Research PC and not merged to production.
- The LIVE ELEGOO UK source is still \`research_scope=new_uk\`. PR #332 carries the update-only migration \`20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql\`; it has not been applied.
- No LIVE source, evidence, catalogue, customer, tenant, website, ownership or Stripe data was modified. No worker restarted and no private \`.env\` or local PC settings were changed.
- Current CI run must pass before merge. After review/merge, apply the ELEGOO source-scope migration only through the approved release process, update the single installed Research Control Centre worker preserving its private environment, then run one bounded LIVE 3D-printer task. Acceptance requires: a completed task within the bounded extraction envelope, raw full-page captures present for Gemma success and failure, all qualifying distinct source pages retained in Research awaiting review, multiple same-type source records for one product preserved, and the shared queue proceeds to the next task.


## Release update — 9 November 2026 (PR #332 merged to LIVE production)

- PR #332 was reopened at the owner's request and squash-merged into \`production\`.
- Merge commit: \`5887f8fadae09a51cdb0048eaef67d8a23dcf0ca\`.
- Production GitHub Actions run \`42684047133\` (“Gemma Research Tests”) completed successfully on the merge commit.
- LIVE Supabase migration \`20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql\` was applied via the approved Supabase migration path and recorded as migration version \`20261109193254\` / name \`enable_elegoo_uk_3d_printer_used_lane_20261109\`.
- The existing LIVE ELEGOO UK source row is enabled with \`research_scope='all'\`; there is still only the existing source row, no duplicate.
- The production repository now contains the bounded 45-second 3D-printer Gemma batch timeout, no sequential single-page timeout retries, full raw-page fallback, the compact extraction prompt and website-specific 3D-printer routes.
- **Research PC installation remains pending.** Merging to GitHub and applying the LIVE database migration do not update the local Node worker already running on the PC. The connected Control Centre must be stopped after the current task, then the current production \`Update-TradeFlow-Gemma.ps1\` run against the existing paths in \`%LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre\\service.json\`. This updater validates both LIVE/TEST targets in the existing private \`.env\`, backs up installed source, downloads production code, runs Node syntax and test suites, and does not edit the private \`.env\` or specialist selection in \`config.json\`.
- After local update, restart the existing Control Centre background service and confirm it connects to LIVE. Then run a single bounded 3D-printer acceptance task. Acceptance requires a short extraction stage, full page captures whether Gemma succeeds or times out, evidence records from distinct qualifying source pages, preservation of multiple UK-new/UK-used records for one product, and completion/release of the shared queue so it can claim the next category task.
- No TEST project schema, data, queue, sources or customer/tenant rows were changed by the production migration.


## 9 November 2026 — post-PR #332 LIVE review handoff and snapshot revision checkpoint

- Current production base: `3e0f712d5c3c93fa5c6e9b9aa2828716247e75ef` (PR #332 merged at 19:30:46 UTC).
- LIVE migration `20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql` is applied as version `20261109193254`; the one existing ELEGOO UK source row is enabled with `research_scope='all'`. The FDM new route and pre-owned used route remain lane-specific. TEST has no matching ELEGOO row and was not changed.
- Correct LIVE master category ID for `3d-printers-equipment`: `ab8b13b0-b070-4534-838b-3ebd4d7261e5`. The earlier ID recorded in this checkpoint was incorrect and is corrected here.
- Exact branch task count: 20 registered tasks, 57 product subtasks; 20 completed, 0 running, 0 queued, 0 failed. Latest task completion: 2026-11-09 15:03:59 UTC.
- Latest Neptune 4 Pro run: 29 search results; 6 exact pages discovered; 3 fetched; 3 page-fetch errors (all three individual eBay URLs returned HTTP 403); 26 approved-source route attempts across 12 sources (11 matches, 9 empty, 6 errors); 3 full captures retained; two Gemma batches; three extraction failures; 18m49s in Gemma; all three queue writes were duplicate-skipped.
- LIVE review queue remains 65 exact-branch rows: 28 imported, 37 rejected, 0 open; 62 contain page captures. 64/65 lack queue-level reviewer ID, eight imported rows also lack review timestamp, and 64/65 lack queue-level evidence_type. Do not infer reviewer identity or rewrite historical decisions.
- Category-wide shared evidence: 239 active UK-new rows, 21 active UK-used rows, 17 inactive UK-new rows; all GBP. Master catalogue: 208 products, 201 active. The queue's missing evidence_type must not be used as a substitute for linked shared-evidence classification.
- PR #336 adds snapshot-aware same-URL review revisions and legacy `review-` / `borderline-` key compatibility. An unchanged snapshot remains duplicate-skipped. A materially changed snapshot for an imported/rejected/reviewed row becomes a new `needs_research` / `unverified_capture` review row; the old terminal row is immutable. Only an unreviewed pending row can use guarded enrichment.
- Read-only replay of the three latest Neptune captures detected 3/3 as materially changed against their existing imported captures. Before: 3 captures, 0 new/0 enriched review rows. Proposed after: 3 new review revisions, 0 existing rows modified. This is a dry-run comparison, not a LIVE write.
- PR #336 also exposes actual Ollama HTTP requests, skipped timeout recovery, new snapshot revisions, enrichment and duplicate-skip counts separately. No approval/import is introduced.
- Repeated eBay HTTP 403 handling remains a separate outstanding 3D-printer fix in PR #299; it is not silently folded into this snapshot-only change. The current production worker still has no batch-scoped 403 block.
- No research task queued, no worker restarted, no LIVE review/evidence/catalogue row modified, no TEST data copied, and no private configuration or secrets accessed.


## Verification update — 9 November 2026, 20:09 UTC (PR #336)

- PR #336 is based directly on production `3e0f712d5c3c93fa5c6e9b9aa2828716247e75ef`, 8 commits ahead and 0 behind; it remains open, mergeable and unmerged.
- First PR CI run #42689823144 exposed one stale source-playbook assertion: the queue lookup had been renamed from `existing` to `exactExisting`, and the test did not also inspect the legacy lookup's selected columns. The test was updated to validate both query paths against the LIVE schema; application code was not weakened.
- Retest run #42690215260 passed **110/110** Gemma/source-playbook/task-group tests. PowerShell updater syntax, Node syntax and Owner Dashboard JavaScript syntax also passed.
- Repeated the read-only snapshot replay using the actual three candidate captures and their exact LIVE imported queue rows. All three are terminal imported rows with review/approval/import timestamps, and all three incoming fingerprints differ from the historical fingerprints:
  - ELEGOO UK: 10,000 → 42,207 captured characters; `new_snapshot`.
  - 3DJake UK: 10,000 → 14,328 captured characters; `new_snapshot`.
  - 3D Prima: 3,493 → 3,506 captured characters; `new_snapshot`.
- Proposed outcome: 3 new unverified review revisions, 0 existing terminal rows modified. Actual LIVE inserts/updates remain **0**; this was a read-only replay.
- Exact unchanged snapshots still select `duplicate`; the legacy compatibility tests cover old `review-` and `borderline-` keys. Only unreviewed pending rows can use guarded enrichment.
- No evidence approval/import, research task, worker restart, source change, migration, TEST write, or secret/private-`.env` access occurred.
