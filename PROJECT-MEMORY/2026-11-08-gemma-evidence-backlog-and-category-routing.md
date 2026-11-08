# Project Memory — Gemma evidence backlog and category routing

Date: 8 November 2026 (UTC)

The user has confirmed the operating model: Gemma gathers all useful page observations and preserves uncertainty; ChatGPT performs product/package matching against the master catalogue and decides which observations become market evidence. Do not force Gemma to approve or reject evidence. Preserve raw captures and source links.

LIVE 3D-printer backlog processing:
- 65 queue rows reviewed.
- 9 exact product/package matches imported into shared_market_evidence.
- 56 rows processed without import and marked rejected with notes.
- All raw queue records retained.
- Queue verified at 9 imported / 56 rejected / 0 open (pending_review or needs_research) for category 3d-printers-equipment.
- Imported evidence: Bambu Lab A1 AMS Lite Combo (new £315 3D Prima, new £305.83 3DJake, used £250 Gumtree); Anycubic Kobra S1 Max standard (new £549 Anycubic UK, £619 3D Prima out of stock); Kobra S1 Max 4-colour Combo (new £749 Anycubic UK, £819 3D Prima); Creality K1 (£299 new) and K1 Max (£589 new).
- All were matched to existing LIVE master products. No TEST data was copied. Evidence does not change valuation rules.

The owner queue RPC platform_owner_list_catalogue_research_queue supports separate imported and rejected completed-history filters; default is pending_review. Processed rows must leave the outstanding list but remain retrievable. Never delete raw captures to clear the dashboard.

LIVE source registry already has category-specific UK assignments: 3D printers 13, cameras 14, camera equipment 14, drones 6, gaming consoles 12, laptops 7, metal detectors 6, mobile phones 11; universal marketplaces are explicitly marked. Current worker loads up to 100 enabled sources globally and filters later, causing unrelated source skip logs. PR #308 proposes category-array overlap filtering at load time plus UK/enabled constraints. PR #308 is draft; do not deploy or restart Research PC until CI/review pass.

Follow-up: verify completed-history UI in browser; verify PR #308 and controlled runtime category routing for each specialist agent. Keep TEST and LIVE strictly separate.
