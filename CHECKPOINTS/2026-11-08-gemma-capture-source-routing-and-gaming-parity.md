# Combined Gemma capture and source routing checkpoint

Date: 8 November 2026 (UTC)
Branch: fix/gemma-3d-price-capture-and-category-source-routing-20261108
PR: #312
Scope: 3D-printer structured GBP page capture + category-scoped approved-source loading.

## Combined code changes

1. For 3D-printer tasks only, extractRelevantPageText now parses matching JSON-LD Product/Offer facts and places those structured facts before long flattened page content. Manufacturer/model identity must match the task. GBP amounts are rendered with an explicit GBP prefix; non-GBP currencies remain distinct. Other categories retain content-first ordering.
2. buildApprovedResearchSourcesPath(task) loads only enabled GB sources whose category_slugs overlap the task category or the explicit universal * marker. Missing/malformed category fails closed. Existing manufacturer checks, 3D-printer new/used lane checks, URL/host validation and raw capture hand-off remain.
3. Regression tests are included in GitHub CI and the Research PC updater:
   - agent-speed.test.mjs covers structured GBP capture, non-GBP handling and preserving other-category ordering.
   - agent.source-selection.test.mjs covers all seven specialist categories, universal sources, enabled/GB filters and fail-closed category validation.
4. Update-TradeFlow-Gemma.ps1 includes both test files and validates before/after installation.

## Important merge history

- PR #310 was the original 3D-printer structured GBP capture fix.
- PR #311 was the original category-source filter.
- Both modified agent.mjs and conflicted. PR #311 was closed as superseded; PR #310 was not merged because its base had become stale.
- PR #312 is the clean combined branch from current production. Do not merge either stale PR separately.

## Gaming catalogue parity already completed

LIVE project gxsrajtqzdjvmceqcpgv and TEST project nnsshnfkjcflucjrftzi independently reconciled:
- 285 total product rows, 284 active, one inactive duplicate product row.
- 411 active evidence rows: 246 UK-new, 165 UK-used.
- 20 branches, 24 manufacturers.
- Zero product field differences and zero active evidence field differences.
- Zero open gaming queue records and zero active gaming tasks.
- Gaming source registry: 12 category-specific UK sources plus 2 universal marketplaces (Amazon UK, eBay UK), 14 loadable sources in both environments.
- TEST has one additional inactive historical Xbox Series X Digital evidence row; do not copy it to LIVE.
- Nintendo Switch 2 Joy-Con 2 Charging Grip duplicate package row retained inactive, “Single Charging Grip” alias added, unique used eBay evidence moved, duplicate Argos/Smyths captures marked inactive. No records deleted.

## Source registry audit

Enabled UK sources including universal marketplaces:
- 3D printers: LIVE 15 / TEST 5 (known source-registry parity gap).
- Cameras: 16 both.
- Drones: 8 both.
- Gaming consoles: 14 both.
- Laptops: 9 both.
- Metal detectors: 8 both.
- Mobile phones: 13 both.

Only Amazon UK and eBay UK are explicitly universal. Vinted has no category assignment and US sources are excluded. Do not add manufacturer sources until the category filter is merged and installed.

## Deployment gate

PR #312 must pass the combined CI workflow and merge. Then run Update-TradeFlow-Gemma.ps1 on the Research PC from production without -StartWorker. Verify its syntax and both test suites. Start one controlled gaming task in TEST, inspect source list/raw capture/evidence, then queue LIVE. No worker restart/deployment has occurred yet.
