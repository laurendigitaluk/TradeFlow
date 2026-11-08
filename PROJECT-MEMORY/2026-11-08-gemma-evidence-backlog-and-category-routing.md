# Project Memory — Gemma evidence backlog and category routing

Date: 8 November 2026 (UTC)

The user has confirmed the operating model: Gemma gathers all useful page observations and preserves uncertainty; ChatGPT performs product/package matching against the master catalogue and decides which observations become market evidence. Do not force Gemma to approve or reject evidence. Preserve raw captures and source links.

LIVE 3D-printer backlog processing:
- 65 queue rows reviewed.
- 28 exact product/package matches imported into shared_market_evidence.
- 37 rows processed without import and marked rejected with notes.
- All raw queue records retained.
- Queue verified at 28 imported / 37 rejected / 0 open (pending_review or needs_research) for category 3d-printers-equipment.
- Imported evidence includes Bambu Lab A1 Combo and Standard; Bambu Lab H2S AMS 2 Pro Combo; Anycubic Kobra S1 Standard, 4-Color Combo and ACE 2 Pro 4-Color Combo; Anycubic Kobra S1 Max Standard, 4-, 8- and 16-Color Combos; ELEGOO Neptune 4 Pro; Creality K1 and K1 Max. New, used, refurbished, unavailable and conflicting stock states are explicitly recorded.
- All were matched to existing LIVE master products. No TEST data was copied. Evidence does not change valuation rules.

The owner queue RPC platform_owner_list_catalogue_research_queue supports separate imported and rejected completed-history filters; default is pending_review. Processed rows must leave the outstanding list but remain retrievable. Never delete raw captures to clear the dashboard.

LIVE source registry already has category-specific UK assignments: 3D printers 13, cameras 14, camera equipment 14, drones 6, gaming consoles 12, laptops 7, metal detectors 6, mobile phones 11; universal marketplaces are explicitly marked. Current worker loads up to 100 enabled sources globally and filters later, causing unrelated source skip logs. PR #308 proposes category-array overlap filtering at load time plus UK/enabled constraints. PR #308 is draft; do not deploy or restart Research PC until CI/review pass.

Follow-up: verify completed-history UI in browser; verify PR #308 and controlled runtime category routing for each specialist agent. Keep TEST and LIVE strictly separate.
