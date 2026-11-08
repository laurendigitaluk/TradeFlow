# LIVE Cameras source coverage checkpoint — 8 November 2026

## Environment and safety
- Environment changed: TradeFlow LIVE only (gxsrajtqzdjvmceqcpgv, eu-west-2).
- TEST (nnsshnfkjcflucjrftzi) was not modified.
- LIVE remains the authoritative shared catalogue; TEST is reserved for software and regression testing.
- No product rows, market-evidence rows, customer/tenant data, task rows or worker state were changed.

## Verified baseline
- Cameras active products: 722.
- Cameras active products without active market evidence: 305.
- Enabled category-scoped research sources before change: 14.

## Change
Added seven official manufacturer sources to public.platform_research_sources, each with category_slugs = ['cameras'], source_kind = 'manufacturer', research_scope = 'official', country GB:
1. Nikon UK Official — nikon.co.uk.
2. Canon UK Store — canon.co.uk.
3. FUJIFILM UK Official eShop — eshop.fujifilm-x.com.
4. Panasonic UK Store — uk.store.eu.panasonic.com.
5. OM SYSTEM UK Official — explore.omsystem.com.
6. Polaroid UK Official Store — polaroid.com.
7. Z CAM Official — z-cam.com.

Manufacturer sources are for exact identity, configuration, specifications and release/discontinuation status. They are not automatically price evidence. Z CAM is a global specification source, not a UK price source. UK price capture must use a visible GBP offer from an approved UK source; where ex-VAT and inc-VAT are both shown, use inc-VAT for consumer evidence.

## Post-change verification
- New source rows returned by INSERT: 7.
- Enabled Cameras-scoped source count: 21.
- Active Cameras products: 722.
- Active Cameras products without active evidence: 305 (unchanged, as expected).
- Supabase activity record: owner-live-camera-source-coverage-20261108 inserted and verified.
- No research tasks queued; no worker restarted; no TEST data changed.

## Dashboard cleanup status
- Production code uses p_status='active' for tasks and p_status='open' for research review rows.
- LIVE database contains 20 completed tasks, 0 active tasks, 28 imported and 37 rejected research rows, 0 open review rows.
- Completed/rejected history is retained; no deletion was performed.
- Production HTML/JS and LIVE RPC migration are present, but Cloudflare Worker tradeflow deployment and browser hard-refresh remain unverified. Do not claim the browser deployment is complete until checked.

## Gemma readiness gates
- PR #300: 54/54 CI tests passed; remains draft/open, not merged.
- PR #312: 73/73 CI tests passed; open/ready for review, not merged.
- Research PC installation and local Ollama structured-output acceptance are not yet verified in the production acceptance sequence.
- Do not launch a full worker run until approved code is installed and local runtime acceptance plus discovery/source-routing checks pass.

## Next step
Continue LIVE-only manufacturer/UK retailer source coverage using the measured evidence gap, then perform the coordinated Gemma agent/updater acceptance. Do not queue research during source preparation. Keep used and new evidence separate, GBP only, and never feed used-market references into automatic valuation.


## Follow-up: Blackmagic Design UK source

Added Blackmagic Design UK Official (blackmagicdesign.com, https://www.blackmagicdesign.com/uk/products) as an official GB manufacturer source scoped only to cameras. It is suitable for exact camera model identity/specifications and visible UK GBP offers; separate camera bodies from accessories. Post-change verification: 22 enabled camera-scoped sources, 722 active camera products, 305 still without active evidence. No product/evidence rows or TEST data changed. Supabase activity record owner-live-camera-source-coverage-blackmagic-20261108 verified.
