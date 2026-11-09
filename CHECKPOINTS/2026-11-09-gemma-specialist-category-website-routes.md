# Checkpoint: Gemma specialist category website routes — 9 November 2026

## Objective
Provide complete website navigation/playbooks for the seven independently switchable Gemma product-research specialists and deploy the Windows Control Centre safely.

## LIVE source registry baseline
- 119 source records total (116 GB-coded and 3 US-coded; all 119 enabled).
- Enabled category coverage including shared universal sources: 3D Printers 15; Gaming Consoles 17; Drones 21; Metal Detectors 13; Mobile Phones 23; Laptops 12; Cameras 24.
- Counts overlap because shared universal and multi-category sources are counted in each relevant category.
- No LIVE or TEST source registry rows were added, removed or changed.

## Final website playbook state
- 3D Printers: preserve existing source playbook, routes and extraction path unchanged.
- Gaming: preserve capture-only handoff and PlayStation/Xbox/Nintendo branch identity. Explicit UK discovery routes cover Argos, Currys, Smyths, Very, Cash Converters, Cash Express, Xbox, PlayStation and Nintendo. Gumtree uses its UK slug search; Amazon/eBay use dedicated marketplace search paths. Other mapped retailers use homepage discovery; guessed generic /search?q paths are disabled.
- Drones: include HobbyRC, Heliguy, DJI Retail, DMTL, Leicester Drones and Quadcopters alongside existing sources. Aetha is homepage discovery; MPB uses /en-uk; store.dji.com is skipped because its public route redirects to sign-in.
- Metal Detectors: include Amazon/eBay marketplace routes, Regton's /metal-detectors category, and homepage discovery for Spin A Disc, UK History Finders, Unearthed UK, Wolds Detecting and LP Metal Detecting.
- Mobile Phones: include Argos, Currys, John Lewis, EE, Very, OPPO and realme alongside existing manufacturer sources.
- Laptops: retain existing UK manufacturer and retailer routes.
- Cameras: include Sony UK, Jessops, Park Cameras, Clifton Cameras, Harrison Cameras, Camera Price Buster, Castle Cameras and Production Gear alongside existing sources.
- Approved international source hosts accept UK locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en; host must still match an approved source record.
- Routes are discovery only. Gemma must follow individual product/listing links and preserve raw page evidence for ChatGPT/owner review. Do not bypass 403/429 blocks or treat sign-in/category pages as evidence.

## Production verification
- PR #325 merged to production as b20123fd8f832388011589ac8e7f9e602bb98f08.
- Production CI run #473 passed: 92 tests, 0 failures; Node/PowerShell syntax; Owner Dashboard JavaScript syntax.
- LIVE source registry remains 119 records / 116 enabled; TEST source registry remains separate and unchanged.
- No Research PC install or worker restart has occurred.

## Rollout gate
- The production installer is available in tools/tradeflow-gemma-desktop.
- The LIVE agent-scoped claim RPC is present and service-role-only; TEST does not have it.
- On the Research PC, run the production installer from the existing Gemma folder, preserve the private .env, stop any old worker cleanly first, and verify one bounded LIVE review-only task reaches the existing review queue.
- Do not start a broad research batch as an installation test. TEST remains separate; desktop runtime is LIVE-only.

 
### Live worker snapshot before Research PC installation — 11:57 UTC
The LIVE `platform_ai_agent_status` and activity records show one generic TradeFlow Gemma task worker connected and idle, polling every 15 seconds. The queue currently contains 24 completed tasks and no queued/running tasks. This is the existing legacy worker, not the new desktop supervisor. The installer will refuse to overwrite it while active. When installing on the Research PC, stop the existing worker cleanly with Ctrl+C first; do not terminate an active task or force-kill the process.
