# Project memory — Gaming Consoles & Accessories Gemma rollout

Date: 9 November 2026 (UTC)
Branch: feat/gemma-gaming-capture-rollout-20261109
Base: production after PR #314
Status: PR #316 merged into production (merge commit 5023a95c22ae027f299ded124819d74db6b7a078); GitHub Actions passed 79/79 tests. Research PC installation and runtime acceptance remain pending. This file is the structured project-memory record for the rollout.

## Preservation baseline (TradeFlow LIVE)

- Gaming Consoles & Accessories: 284 active products; 411 active linked evidence rows (246 UK-new, 165 UK-used).
- Drones: 541 active products; 542 active linked evidence rows (236 UK-new, 306 UK-used).
- Cameras: 722 active products; 573 active linked evidence rows (155 UK-new, 418 UK-used).
- Mobile Phones: 158 active products; 567 active linked evidence rows (271 UK-new, 296 UK-used).
- These counts were read from catalogue_master_products joined to shared_market_evidence; they are existing evidence and must not be re-imported or removed as part of agent rollout.
- TEST gaming parity remains 284 active products and 411 active evidence rows. No data was copied between environments.

## Code changes merged to production

- Added a Gaming Consoles & Accessories category playbook with branch-specific rules for PlayStation, Xbox, Nintendo, Sega, Atari, controllers, handhelds, headsets, VR and accessories.
- Added gaming capture-only mode: raw page content and GBP observations are retained for ChatGPT; no local model evidence classification, price promotion, approval or master-product matching.
- Added UK-new / UK-used lane filtering for the gaming category. Official/new retail sources are not probed in the used lane; used dealers/marketplaces are not probed in the new lane; universal UK sources remain available in both.
- Added regression coverage for playbook routing, branch rules, lane separation and complete raw-page retention.
- Existing 3D-printer path remains unchanged.

## Source and task state

- LIVE gaming source registry: 14 loadable UK sources (12 category-scoped plus universal Amazon UK and eBay UK).
- No gaming research task queued; no LIVE or TEST catalogue/evidence writes performed.
- The older queued TEST 3D-printer smoke task (owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-02) has been marked cancelled; its task row and history remain. It will not be claimed during the gaming test.
- Research PC updater/runtime verification is still required. Do not claim a Gemma test has run until the worker is installed and telemetry confirms a completed gaming task.

## Next gate

1. CI passed 79/79 and PR #316 is merged to production.
2. Update Research PC from production using the version-controlled updater, without starting the worker; preserve existing .env, backups, tasks and logs.
3. The stale TEST 3D-printer task is cancelled, with its history retained.
4. Queue and run one controlled Xbox Series S task in TEST (new and used lanes), inspect every source and raw capture, then run the category in LIVE only after the test passes.
5. ChatGPT reviews raw captures and decides which evidence is relevant and which existing master product it belongs to. No autonomous import.
