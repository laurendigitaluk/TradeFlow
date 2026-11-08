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


## Manufacturer-source coverage gaps identified 8 November 2026

The enabled source registry has 16 manufacturer-source rows overall. Category-specific official manufacturer coverage is materially narrower than the master catalogue manufacturer list:
- Cameras: Sony official source only, while the catalogue also contains Canon, Nikon, Fujifilm, Panasonic, OM SYSTEM, Blackmagic Design, Leica, Casio, Polaroid and others.
- Drones: DJI official source only; the catalogue also contains Autel, BetaFPV, FIMI, Freefly, GEPRC, Holy Stone, HoverAir, Hubsan, iFlight, Parrot, Potensic, PowerVision, Skydio, Walkera and Yuneec.
- Gaming: Sony PlayStation, Nintendo and Microsoft Xbox official sources are present; Atari and Sega product families also exist in the catalogue.
- Metal detectors: Minelab official source only; the catalogue also contains Garrett, Nokta, Fisher, Quest, Teknetics and XP.
- Mobile phones: Apple, Google, Motorola, OPPO and Samsung official sources are present; the catalogue also contains Doro, Fairphone, HMD, HONOR, Nothing, OnePlus, realme, TCL and Xiaomi.
- 3D printers: Anycubic, Bambu Lab, Creality and ELEGOO official sources are present; the catalogue also contains Artillery, Flashforge, FLSUN, Formlabs, Geeetech, Phrozen, Prusa, QIDI, Raise3D, Snapmaker, Sovol, Ultimaker and others. Specialist UK retailers already cover some of these brands.
- Laptops: the source registry has a laptops slug and retailer/Apple/Samsung assignments, but the current master-catalogue category query did not find a matching laptops category. Verify the category model before adding more laptop sources.

Do not add this next wave of source rows until the category-scoped worker query in PR #308 is merged and deployed. Otherwise the current global source loader will download the new rows for unrelated agents and recreate the noisy skipped-source logs. Add verified UK official stores and authorised UK distributors first; global manufacturer sites may be used for identity/specification checks but must not be treated as UK GBP price evidence unless the page actually displays UK pricing.
