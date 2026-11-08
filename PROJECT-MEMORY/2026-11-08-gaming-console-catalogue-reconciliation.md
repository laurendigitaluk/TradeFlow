# Project Memory — Gaming catalogue parity and Gemma source routing

Date: 8 November 2026.

User's next category after 3D-printer backlog/dashboard cleanup is Gaming Consoles & Accessories. The user previously requested TEST/LIVE alignment. Follow the project rule: never copy IDs or rows between environments; independently verify and apply canonical values in each project.

Final gaming parity in LIVE and TEST:
- 285 total product rows, 284 active, one inactive duplicate product row.
- 411 active evidence rows: 246 UK-new and 165 UK-used.
- 20 branches, 24 manufacturers, 12 category-specific UK source assignments plus 2 universal UK marketplaces (Amazon UK and eBay UK), 14 loadable sources.
- 0 open queue records, 0 active/failed gaming tasks.
- Programmatic comparison shows 0 product-field differences across all 285 rows and 0 active-evidence-field differences across all 411 active rows.
- TEST retains one additional inactive historical Xbox Series X Digital listing evidence row. It is inactive; do not copy it into LIVE. Inactive evidence totals: LIVE 14, TEST 15.

Reconciled:
- Hyperkin Silver product model/package key to Hyperkin The Competitor Xbox & PC Wired Controller - Silver / hyperkin-competitor-xbox-pc-silver.
- PowerA Fire Red key to powera-advantage-xbox-wired-fire-red.
- Microsoft Carbon Black/Shock Blue metadata, Nintendo Joy-Con pair metadata, Sony DualSense colour/product links, Atari condition wording and 29 evidence notes/URLs aligned.
- Nintendo Switch 2 Joy-Con 2 Charging Grip had duplicate single-charging-grip and canonical nintendo-switch2-joycon2-charging-grip products. Duplicate row marked inactive, alias “Single Charging Grip” added to canonical package, unique used eBay evidence moved, duplicate Argos/Smyths evidence marked inactive. No rows deleted.

Gaming sources in both environments: 12 category-specific UK sources (Argos UK, CeX UK, Currys UK, EE UK, GAME UK, John Lewis UK, Microsoft Xbox UK, Nintendo UK, Selfridges UK, Smyths Toys UK, Sony PlayStation UK, Very UK) plus Amazon UK and eBay UK universal. Only three official manufacturer sources (Microsoft, Nintendo, PlayStation). Other enabled UK source counts (category-specific plus universal) are 3D printers LIVE 15 / TEST 5, cameras 16 in both, drones 8 in both, laptops 9 in both, metal detectors 8 in both and mobile phones 13 in both. The 3D-printer source registry remains a parity gap. Candidate UK manufacturer sources to add after worker category filter deployment: Atari UK, PowerA UK, Gioteck, HORI Europe UK, Turtle Beach UK, Venom UK, SanDisk UK, Seagate UK, WD_BLACK UK. Only accept GBP prices as UK market evidence.

Category source-loading repair:
- Current worker loads enabled sources globally before filtering.
- PR #311 branch fix/gemma-category-scoped-source-loading-20261108c adds server-side category-array overlap filter plus universal * sources, enabled GB rows, fail-closed category validation.
- Test file tools/tradeflow-gemma-agent/src/agent.source-selection.test.mjs added to CI and Research PC updater.
- PR #308 draft was closed as stale/conflicted; it was not merged.
- Do not start gaming research or add source rows until PR #311 passes CI, merges, and Research PC updater is run from production. Update worker without starting; run one controlled TEST gaming task first, then LIVE.
