# Project Memory — Combined Gemma capture and source routing

Date: 8 November 2026.
PR: #314
Branch: fix/gemma-capture-source-routing-20261108c

The 3D-printer structured GBP capture fix and category-scoped source loader both touch tools/tradeflow-gemma-agent/src/agent.mjs. Original PRs #310 (3D capture) and #311 (source routing) conflicted. PR #313 combined them but became conflicted after concurrent documentation commits. PRs #310, #311 and #313 are closed/superseded. PR #314 is the clean branch from current production. Do not merge stale PRs separately.

Combined behavior:
- For 3D printers only, extractRelevantPageText parses matching JSON-LD Product/Offer records and places them before long flattened text. Manufacturer/model identity must match. GBP offers are emitted with explicit GBP prefix; other currencies are not relabelled. Other categories retain content-first order.
- Source loader filters enabled sources at query time by category_slugs overlap with task category or explicit universal *. Also filters country_code=GB. Missing/malformed category fails closed.
- Existing manufacturer and research-lane filters, page validation and raw capture hand-off remain.
- agent-speed.test.mjs and agent.source-selection.test.mjs are both included in GitHub CI and Update-TradeFlow-Gemma.ps1.
- PR #314 must pass CI and merge before updating the Research PC. Run updater from production without -StartWorker; then one controlled TEST gaming task before LIVE. No worker restart has occurred.

Gaming category reconciliation is complete:
- LIVE and TEST each have 285 total product rows / 284 active, 411 active evidence rows (246 UK-new,165 UK-used), 20 branches,24 manufacturers.
- Exact comparison: zero product field differences and zero active evidence field differences.
- Zero open gaming queue rows and zero active tasks.
- 12 category-specific sources + 2 universal Amazon UK/eBay UK sources =14 loadable in both.
- One inactive historical Xbox Series X Digital evidence record remains TEST-only; do not copy to LIVE.
- Duplicate Nintendo Switch 2 Joy-Con 2 Charging Grip package row marked inactive, alias Single Charging Grip added to canonical product, unique used eBay evidence moved, duplicate Argos/Smyths evidence retained inactive. No rows deleted.

Source registry audit (category-specific plus universal):
- 3D printers LIVE 15 / TEST 5 (known parity gap).
- Cameras 16 both; drones 8 both; gaming 14 both; laptops 12 both; metal detectors 8 both; mobile phones 13 both.
- Only Amazon UK and eBay UK are universal. Vinted has no category assignment. US sources are excluded.
- Do not add new manufacturer sources until PR #314 merges and Research PC uses the category filter.
