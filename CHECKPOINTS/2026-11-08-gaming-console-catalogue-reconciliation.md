# Gaming catalogue parity and Gemma source routing checkpoint

Date: 8 November 2026 (UTC)
Projects: TradeFlow LIVE gxsrajtqzdjvmceqcpgv and TEST nnsshnfkjcflucjrftzi.
Research category: gaming-consoles-accessories.
Code branch: fix/gemma-category-scoped-source-loading-20261108c.
Planned PR: #310 (category-scoped source loading).

## Final LIVE / TEST parity

Both projects independently reconciled; no IDs or rows copied from one project to the other.

- 285 total product rows in each environment.
- 284 active products in each; one inactive duplicate product row retained for audit.
- 411 active evidence rows in each: 246 UK-new, 165 UK-used.
- 20 branches, 24 manufacturers, 12 category-specific UK source assignments plus 2 universal UK marketplaces (Amazon UK and eBay UK), 14 loadable sources.
- Zero open research queue records and zero active/failed gaming tasks in each.
- Final programmatic comparison: 0 product field differences across all 285 product rows; 0 active evidence field differences across all 411 active evidence rows.
- TEST has one additional inactive historical Xbox Series X Digital listing evidence row; it remains inactive and was not copied to LIVE. Total inactive evidence: LIVE 14, TEST 15.

## Product/evidence reconciliation

- Hyperkin The Competitor Xbox & PC Wired Controller - Silver: canonical model/package name and package key hyperkin-competitor-xbox-pc-silver; Argos UK source naming and evidence key normalised.
- PowerA Advantage Xbox Series X|S Wired Controller - Fire Red: canonical package key powera-advantage-xbox-wired-fire-red; Argos UK source naming and evidence key normalised.
- Microsoft Carbon Black and Shock Blue controller fields/notes aligned.
- Nintendo original Switch Joy-Con pair metadata aligned. Argos source links now point to exact product pages 6783651 and 2078360.
- Sony DualSense GTA VI Black/White evidence links now point to exact PlayStation UK product pages; Nova Pink and Starlight Blue Argos URLs normalised.
- Atari 2600 seller condition text is conservative and consistent; seller claims are not represented as independent tests.
- Evidence notes for the 29 differing source records were standardised while retaining price, observed date, condition, availability and sale-vs-asking distinctions.

### Duplicate Nintendo Switch 2 Joy-Con 2 Charging Grip

Two product rows represented the same single charging grip:
- Canonical active package key: nintendo-switch2-joycon2-charging-grip.
- Duplicate single-charging-grip row marked inactive in both projects, not deleted.
- Alias “Single Charging Grip” inserted in catalogue_master_product_package_aliases for the canonical product.
- Unique used eBay evidence moved to the canonical product.
- Duplicate Argos and Smyths observations marked inactive with explanatory notes; originals retained.
- Category counts after consolidation are 284 active products and 411 active evidence rows in both.

## Gaming source registry

Both environments have the same 12 category-specific source assignments plus 2 universal UK marketplaces (14 loadable sources): Argos UK, CeX UK, Currys UK, EE UK, GAME UK, John Lewis UK, Microsoft Xbox UK, Nintendo UK, Selfridges UK, Smyths Toys UK, Sony PlayStation UK and Very UK, plus Amazon UK and eBay UK universal.
Only three manufacturer source assignments currently exist: Microsoft Xbox, Nintendo and PlayStation; the other nine category-specific sources are retailers.

Candidate official UK sources identified but not yet inserted: Atari UK, PowerA UK, Gioteck, HORI Europe UK, Turtle Beach UK, Venom UK, SanDisk UK, Seagate UK and WD_BLACK UK. Other enabled UK source counts (category-specific plus universal) are 3D printers LIVE 15 / TEST 5, cameras 16 in both, drones 8 in both, laptops 9 in both, metal detectors 8 in both and mobile phones 13 in both. The 3D-printer source registry remains a parity gap. Add only after category-scoped worker loading is deployed. For all candidates, accept UK market-price evidence only when the product page actually displays GBP. Do not treat USD/EUR pages as UK evidence.

## Category-scoped source loader repair

Current production worker loads up to 100 enabled source rows globally, then filters by category/manufacturer/lane. This creates irrelevant supplier downloads and skip logs.

PR #310 branch changes loadApprovedResearchSources to use PostgREST array-overlap on category_slugs for the task category plus explicit universal * sources, restricted to enabled GB sources. Only Amazon UK and eBay UK currently use *; Vinted has no category assignment and US sources are excluded. Missing/malformed category fails closed.

Tests are added in agent.source-selection.test.mjs, included in .github/workflows/gemma-research-tests.yml and Update-TradeFlow-Gemma.ps1.

## Research PC deployment gate

No worker was restarted or deployed during this reconciliation. PR #310 must pass CI and merge first. Then run the repository's updater on the Research PC from production without -StartWorker, confirm the updater's syntax and tests pass, and start one controlled gaming task in TEST. Inspect source logs and raw captures before queueing LIVE research. Do not add the candidate manufacturer sources until the updated worker is installed.
