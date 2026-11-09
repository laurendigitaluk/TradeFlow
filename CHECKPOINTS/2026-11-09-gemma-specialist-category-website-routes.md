# Checkpoint: Gemma specialist category website routes — 9 November 2026

## Objective
Prepare independently switchable Gemma specialists for all seven TradeFlow product-research categories, with a complete category-to-source website playbook and a safe Windows Control Centre.

## LIVE source registry baseline
- 119 UK source records total; 116 enabled.
- Enabled category coverage including shared universal sources: 3D Printers 15; Gaming Consoles 17; Drones 21; Metal Detectors 13; Mobile Phones 23; Laptops 12; Cameras 24.
- Counts overlap because shared universal and multi-category sources are counted in each relevant category.
- No source registry rows were added, removed or changed in LIVE or TEST.

## Final website playbook state
- 3D Printers: preserve existing source playbook, routes and extraction path unchanged.
- Gaming: preserve capture-only handoff and PlayStation/Xbox/Nintendo branch identity. Add explicit UK discovery routes for Argos, Currys, Smyths, Very, Cash Converters, Cash Express, Xbox, PlayStation and Nintendo. Gumtree uses its UK slug search; Amazon/eBay use their dedicated marketplace search paths. Other mapped retailers use homepage discovery; guessed generic /search?q paths are disabled.
- Drones: include the missing registered dealer domains HobbyRC, Heliguy, DJI Retail, DMTL, Leicester Drones and Quadcopters. Aetha is homepage discovery; MPB uses /en-uk; store.dji.com is explicitly skipped because its public route redirects to sign-in.
- Metal Detectors: add Amazon/eBay marketplace definitions, Regton's verified /metal-detectors category, and homepage discovery routes for Spin A Disc, UK History Finders, Unearthed UK, Wolds Detecting and LP Metal Detecting.
- Mobile Phones: include Argos, Currys, John Lewis, EE, Very, OPPO and realme routes/navigation alongside existing manufacturer sources.
- Laptops: retain existing UK manufacturer and retailer routes.
- Cameras: include Sony UK, Jessops, Park Cameras, Clifton Cameras, Harrison Cameras, Camera Price Buster, Castle Cameras and Production Gear alongside existing sources.
- Approved international source hosts accept UK locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en; host must still match an approved source record.
- Routes are discovery only. Gemma must follow individual product/listing links and preserve raw page evidence for ChatGPT/owner review. Do not bypass 403/429 blocks or treat sign-in/category pages as evidence.

## Key implementation files
- tools/tradeflow-gemma-desktop/agents.json
- tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1
- tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1
- tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1
- tools/tradeflow-gemma-agent/src/desktop-control.mjs
- tools/tradeflow-gemma-agent/src/task-worker.mjs
- tools/tradeflow-gemma-agent/src/source-playbooks.mjs
- tools/tradeflow-gemma-agent/src/source-playbooks.test.mjs
- supabase/migrations/20261109150000_gemma_agent_scoped_task_claim.sql

## Verification
- PR #325: feature/gemma-desktop-control-centre-20261109.
- Code/test head: 14da7fa38fec9a75cf95137985a49d20a2208abb.
- GitHub Actions run #472 passed all checks: 92 tests, 0 failures; Node and PowerShell syntax; Owner Dashboard JS syntax.
- PR remains open/unmerged. Scoped-claim migration is not applied to LIVE or TEST.
- No Research PC installation or worker restart has occurred.

## Rollout gates
1. Owner approval to merge PR #325.
2. Apply the additive scoped-claim migration to LIVE only after merge/approval.
3. Install from production on the Research PC, preserving the existing private .env and stopping any old worker cleanly first.
4. Verify one background supervisor and seven independent switches; run one bounded LIVE review-only acceptance task.
5. Verify raw capture reaches the existing LIVE review queue. Do not start a broad category batch as an installation test.
6. TEST remains separate and untouched; desktop runtime is LIVE-only.
