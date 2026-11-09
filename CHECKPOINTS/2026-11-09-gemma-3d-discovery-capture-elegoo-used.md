# Checkpoint — 3D-printer discovery, capture and used-lane repair

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
Correct master category ID for `3d-printers-equipment`: `ab8b13b0-cc9e-45a6-8c8e-5a0d4f6bb0a1`.
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
