# TradeFlow LIVE — Scheduled Market Evidence Project Memory (Batch 13)

**Date:** 2026-11-12  
**Branch:** production  
**Environment:** LIVE only  
**Status:** 20 products researched; checkpoint saved; queue staging blocked by missing owner auth.

## Instructions and selection history

Read scheduled evidence checkpoint and project-memory files from batch 02 through batch 12 before selecting products. Excluded all product UUIDs from scheduled checkpoints 02–12, all product IDs in manual AI research prompt arrays, all products covered by outstanding LIVE queue candidates (including 10 existing `needs_research` records), and known cross-UUID duplicate identities recorded in prior memory. Selection used a dynamic SQL anti-join and no fixed OFFSET. Immediately before research, each selected product had 0 active shared evidence, 0 matching outstanding queue candidates and 0 manual prompt matches.

## Batch 13 — researched products and source findings

1. **Sony ECM-B10 Microphone** — ID `c9c80125-7a21-4730-9413-a30350cc738d`. Wex £175 limited stock; Park/Bristol £175; Harrison £179; Norwich £168 but seller is HK entity with no VAT; ProAV £190.92 inc VAT with conflicting in-stock/backorder text. RED VERIFY seller/VAT and ProAV stock. Sources: https://www.wexphotovideo.com/sony-ecm-b10-wireless-shotgun-microphone-3052619/ ; https://www.parkcamera.live/shop/sony-ecm-b10-wireless-shotgun-microphone_7680123n ; https://www.bristolcameras.co.uk/product/sony-ecm-b10-shotgun-microphone/ ; https://harrisoncameras.co.uk/products/sony-ecm-b10-shotgun-microphone-ecmb10-ce7 ; https://norwich-cameras.co.uk/products/sony-ecm-b10-compact-camera-mount-digital-shotgun-microphone ; https://proav.co.uk/sony-compact-shotgun-microphone

2. **Sony FE 85mm F1.4 GM II Lens Only** — ID `ca3129be-6d49-4c7b-ba63-007b859ee343`. Sony UK page £1,799, only 1 left; dynamic search card also showed £1,599. Sony Centre Direct £1,799. RED VERIFY checkout price mismatch and unusually low Shopping leads. Sources: https://www.sony.co.uk/store/product/sel85f14gm2b.syx/FE-85mm-F1-4-GM-II-Full-Frame-Prime-Lens ; https://sonycentresdirect.co.uk/p-55783-fe-85mm-f14-gm-ii.aspx ; https://www.sony.co.uk/electronics/interchangeable-lenses/sel85f14gm2

3. **Sony FE 12-24mm F2.8 GM Standard** — ID `cc1aa201-fee6-43f4-b295-a04a49251b57`. Sony £2,645; Clifton £2,645 awaiting stock, box includes hood/caps/case; Sony Centre Direct £2,645. RED VERIFY lower Shopping leads not confirmed. Sources: https://www.sony.co.uk/store/product/sel1224gm.syx/buy ; https://www.cliftoncameras.co.uk/sony-fe-12-24mm-f28-gm-lens ; https://sonycentresdirect.co.uk/p-41047-sony-sel1224gm-fe-12-24mm-f28-gm-lens.aspx

4. **RadioMaster Ranger 2.4GHz ExpressLRS External Module** — ID `cd15ac76-7393-43a8-9f68-3da93c1bc851`. HobbyRC £99.99 inc VAT in stock; Flying Tech £99 inc VAT, 5 left; 3DXR £99.99 inc VAT, 39 in stock. RED VERIFY do not confuse Ranger full-size module with Ranger Micro or three-receiver Starter Combo. Sources: https://www.hobbyrc.co.uk/radiomaster-ranger-24ghz-elrs-module ; https://www.flyingtech.co.uk/product/radiomaster-ranger-2-4ghz-expresslrs-elrs-module/ ; https://www.3dxr.co.uk/products/radiomaster-ranger-2-4ghz-elrs-module-lbt ; https://www.flyingtech.co.uk/product/radiomaster-ranger-2-4ghz-elrs-module-starter-combo/

5. **Sony PDW-F800 Standard** — ID `d4555efd-c678-4f22-b982-06ca8230ea5b`. Cineworks page shows £260 but does not state whether this is a sale price or hire rate; no condition/availability. RED VERIFY price basis, condition and package. Source: https://www.cineworks.tv/product/sony-pdw-f800/

6. **PowerVision PowerDolphin Wizard Package** — ID `d85ca7a7-e811-427a-a23c-d1abe267536a`. eBay new £1,449 (Nottingham business seller, no returns); used £449.99 listing sold 2 Oct 2026 (Dundee business seller, no returns). Kamera Express contents include base station, controller, 70m comm cable, bait drop, PowerSeeker, goggles and trolley. RED VERIFY contents of current new listing and used condition. Sources: https://www.ebay.co.uk/itm/116741484492 ; https://www.ebay.co.uk/itm/147582064972 ; https://www.kamera-express.be/powervision-powerdolphin-wizard ; https://www.manualslib.com/manual/1940291/Powervision-Powerdolphin.html

7. **PowerVision PowerEgg X Waterproof Case** — ID `df53bb7c-cbc1-4eed-b114-5cf840ec196c`. Wex £209 (RRP £299), limited stock; box contains one standalone case only. Source: https://www.wexphotovideo.com/powervision-poweregg-x-waterproof-case-1735465/

8. **Sony XDCA-FS7 Extension Unit** — ID `df9f8a4d-8754-44d0-b443-150be2ceb41a`. Used Visual Impact £120 (3+ stock); MPB £123–£144 (3 units, Good/Excellent, 12-month warranty); 3D Broadcast £390 inc VAT (2 stock); eBay £175 used (3 available). RED VERIFY price spread, exact attachments and condition. Sources: https://www.visuals.co.uk/sony-xdca-fs7-camera-extension-box-for-pxw-fs7-fs7k-used.html ; https://www.mpb.com/en-uk/product/sony-xdca-fs7-extension-unit ; https://3dbroadcastsales.com/products/sony-xdca-fs7-extension-unit-for-pxw-fs7-and-pxw-fs7k-cameras-used ; https://www.ebay.co.uk/itm/147502069035

9. **Skydio 2+ Dual Charger** — ID `e0634f33-3a02-4fe0-9a2d-8705808497d2`. Official price $149 USD, wall adapter separate; eBay UK £72.92 used, no returns. Shopping card showed £52.70 but opened page showed £72.92. RED VERIFY Shopping mismatch and official store US/Canada restriction. Sources: https://shop.skydio.com/products/skydio-2-charger ; https://www.ebay.co.uk/itm/187918127220

10. **Sony HXR-MC50E Standard** — ID `e4b6f3e4-7592-4551-876b-8b9fe7cd6c4d`. Cash Converters £129.99 historical but now sold, 12-month warranty, camera/charger, no external mic/lens guard; eBay £229.99 sold used/working with battery and charger; eBay £69.99 faulty. RED VERIFY separate working vs faulty evidence. Sources: https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/video-cameras/video-camera/017900194034 ; https://www.ebay.co.uk/itm/317543403106 ; https://www.ebay.co.uk/itm/357137612058

11. **PowerVision PowerEgg X Wizard Package** — ID `e6c149dd-1bce-4b5e-9806-0e970e7ce3e5`. Official launch MSRP $1,249 USD; Crutchfield package includes waterproof case, pontoons, controller, wrist strap, arms/props, three spare prop pairs, two batteries and charger. Google Shopping lead £650.64 eBay card failed click-through; no direct listing URL captured. RED VERIFY seller, price and full Wizard contents. Sources: https://www.prnewswire.com/news-releases/poweregg-x-personal-ai-camera---the-ultimate-tool-for-content-creators-301068006.html ; https://www.crutchfield.com/p_230PXW10/PowerVision-PowerEgg-X-Wizard.html ; https://www.kamera-express.nl/powervision-poweregg-x-wizard

12. **Skydio Beacon** — ID `e858c5cf-42fd-409f-93e0-6863c3b41261`. Official Skydio 2+ Beacon $219 USD, SKU SKYBC350NA, compatible with Skydio 2/2+, ships 3–5 business days; Skydio sells only in US/Canada. RED VERIFY no UK GBP offer; confirm exact intended Beacon SKU. Source: https://shop.skydio.com/collections/essential-accessories/products/skydio-2-plus-beacon

13. **Z CAM P2-R1N 24x Standard Package** — ID `ef07cfd8-6ce5-425d-8de0-f73ba77beffb`. G&G exact P2-R1N 24X, part P2R1N0124B, $3,299 USD, special order 1–3 weeks, no returns. P2-R1 24X without N is $2,799 USD and is not a match. RED VERIFY no UK GBP price; leave GBP blank. Sources: https://www.ggvideo.com/zcam_p2-r1n-24x.php ; https://www.ggvideo.com/zcam_p2-r1-24x.php

14. **Sony HVR-V1E Standard Package** — ID `f2b5f83e-680f-49e5-9729-8aebba707850`. Camera City £399, 1 stock, no charger, non-original battery; eBay £280 used listing (page redirect, availability to check); Colin's Cameras £260 sold out, fully tested/very good with charger/cables/NP-F960/remote; eBay £170.02 faulty/untested. RED VERIFY package/condition. Sources: https://cameracity.co.uk/product/sony-hvr-v1e-1080i-mini-dv-professional-3cmos-camcorder-no-charger/ ; https://www.ebay.co.uk/itm/117069480914 ; https://colinscameras.co.uk/products/sony-hvr-v1e ; https://www.ebay.co.uk/itm/127942911366

15. **Sony SRG-X400 Standard Package** — ID `f6372983-a0fc-4282-b9af-862f9131d96c`. ProAV black SRG-X400BC £2,754 inc VAT / £2,295 ex; conflicting in-stock/backorder (usually 10 working days); package includes camera, adapter, IR remote, ceiling brackets, screws and HDMI clamp. SCAN white SRG-X400WC £3,199.99 awaiting ETA. RED VERIFY catalogue does not specify colour; do not merge X40UH. Sources: https://proav.co.uk/sony-srg-x400bc-ptz-camera-black ; https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-white-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s ; https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-black-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s

16. **Sony PDW-F350 Standard** — ID `f87012b0-edfd-4d16-b694-e00e0e1f1b4b`. eBay UK £818.92 used, private seller in Wolverhampton, no returns. eBay US listing $625 + $175 shipping; no GBP conversion. RED VERIFY included lens, lens model, batteries/charger and operational condition. Sources: https://www.ebay.co.uk/itm/325590169943 ; https://www.ebay.co.uk/p/99934044

17. **Walkera Furious 320** — ID `fa5170e1-e2bf-47ed-a981-d93fabec232b`. BuzzFlyer £369 inc VAT (was £449.95), out of stock, free FPV Goggle 4, optional extra battery. OSD spare part €26.53 is not drone price. RED VERIFY no current full-drone stock. Sources: https://www.buzzflyer.co.uk/Walkera-Furious-F320__p-2979.aspx ; https://www.fpvracer.lt/model/walkera-furious-320-spare-part-osd-furious-320-g-z-08-12337.html

18. **Skydio X10D Battery** — ID `0061d7d0-e6c4-478c-880b-52cf31db3802`. Official X10D specs confirm battery 8,419mAh, 18.55V, 156.17Wh, ~707.6g; no standalone retail price or availability. RED VERIFY exact replacement SKU and UK authorised-distributor quote. Source: https://www.skydio.com/x10d/technical-specs

19. **HOVERAir AQUA** — ID `01bc2702-9ff1-42c4-bb9a-0b36c2edfaf6`. Official UK Standard £1,129 (1 battery, USB-C cable, Lighthouse/armband, repair kit, waterproof battery bag); Fly More £1,299 (two extra batteries, three waterproof bags, charging hub). Park Standard £1,129; Park Basic £1,219; Currys Standard £1,129; Ballicom Standard £1,113.56 inc VAT (17 stock); Selfridges Basic £1,399. RED VERIFY keep Standard, Basic and Fly More package contents distinct. Sources: https://uk.hoverair.com/products/hoverair-aqua ; https://www.parkcameras.com/shop/hoverair-x1-aqua-standard_9021170a ; https://www.parkcameras.com/shop/hoverair-x1-aqua-basic-combo_9021172a ; https://www.currys.co.uk/products/hoverair-aqua-standard-combo-drone-orange-and-black-10305877.html ; https://www.ballicom.co.uk/hoverair-sp08h004-aqua-standard-combo.p1724345.html ; https://www.selfridges.com/GB/en/product/hoverair-hoverair-aqua-basic-combo_R04735656/

20. **Yuneec H850-RTK Hexacopter** — ID `024f64f2-03b4-46f7-ab85-d1eab4f07f43`. Official German store €8,099 incl VAT (10% below €8,999, shipping extra); Poland dealer 34,400 PLN gross, 1 in stock; Yuneec Poland €8,232.18 gross. Official specs show two smart batteries; payloads are optional/separate. RED VERIFY no GBP conversion; confirm UK seller, controller/charger/case and payload package. Sources: https://shop.yuneec.com/H850-RTK/YUNH850EUSC ; https://www.aerodron.pl/produkt/yuneec-h850-rtk-dron-yunh850eusc/ ; https://yuneec.pl/eng_m_Drones_Yuneec-H850-RTK_Drones-1899.html ; https://yuneec.com/wp-content/uploads/2024/02/2023%20Flyer%20H850%20V2.pdf

## Queue staging limitation

Owner-auth check was performed before any write:
- `auth.uid()` = null
- `auth.role()` = null
- `platform_cloud_ai_owner_check()` = false

Available public owner RPCs include list/review/delete queue operations and manual-prompt operations, but no supported authenticated RPC to stage a new evidence candidate. Therefore:
- 20 products researched, 0 candidates staged.
- No direct table writes, no claims impersonation, no RLS bypass.
- No active shared evidence inserted and no automatic valuation changed.
- All findings remain in this checkpoint until an authenticated owner context and supported staging operation are available.

## Next run instructions

Read batch 13 checkpoint and project memory first. Exclude these 20 IDs plus every product ID from scheduled checkpoints 02–13, outstanding LIVE queue candidates and outstanding manual AI prompt product arrays. Recheck evidence/queue status immediately before research. Select next 20 active LIVE master products dynamically without SQL OFFSET. Continue opening real product pages, retaining uncertain links with `RED VERIFY`, and never convert non-GBP prices. If owner auth remains null/owner check fails, create checkpoint and project memory only.


## 12 November 2026 — Batch 13 direct-source follow-up

Twenty-four further observations were added and read back: ECM-B10 Park £175/Bristol £175/Harrison £179 new and Wex £137/MPB £145 used; FE85 GM II CameraWorld £1,789 new/£1,710 open-box, Wex £1,269 used and LCE £1,249.99 used; FE12-24 GM LCE £2,645 new; Ranger full-size Flying Tech £99 and 3DXR £99.99 new; XDCA-FS7 MPB £123/£144, eBay £175 and 3D Broadcast £390 used; SRG-X400 SCAN white and black £3,199.99 each awaiting ETA; HOVERAir AQUA Standard Currys £1,129 and Ballicom £1,113.56 new; PowerDolphin Wizard eBay sold £449.99 used historical; HXR-MC50E Cash Converters sold £129.99, eBay sold £229.99 and faulty eBay £69.99.

The PowerDolphin Wizard new £1,449 eBay row was deactivated because the seller's contents do not establish the full Wizard package. eBay HVR-V1E title was not imported because its item specifics identify HVR-Z1E. Batch 13 now 36 total GBP rows, 35 active (17 UK New, 18 UK Used), one inactive. Used evidence remains reference-only.


## 12 November 2026 — second Batch 13 retailer recheck

Five more exact GBP records added/read back: ECM-B10 CameraWorld £159 new in stock; FE85 GM II LCE £1,799 new in stock and Park £1,799 new in stock (both £200 cashback after claim); FE12-24 GM CameraWorld £2,548 new, two available, and £2,548 open-box unique item. Batch 13 now 41 total rows, 40 active (21 new, 19 used), one inactive package-unverified PowerDolphin Wizard new row.


## 12 November 2026 — Batch 13 further RED VERIFY follow-up

Six further UK New records imported/read back: Wex Sony ECM-B10 £175 limited stock; Sony Centre Direct FE85 GM II £1,799; Sony UK FE12-24 GM £2,645; Sony Centre Direct FE12-24 GM £2,645; HOVERAir UK official AQUA Standard £1,129; Park Cameras AQUA Standard £1,129 in stock. Exact SKU/package details are in the checkpoint.

Corrected BuzzFlyer Walkera Furious F320 £369 row from uk_used to uk_new because it is a new retail offer, condition new, sold out. No price/status changes. Batch 13 now 47 total GBP rows, 46 active (28 UK New, 18 UK Used), one inactive package-unverified PowerDolphin Wizard new row. Remaining exact-source/package uncertainty is preserved as RED VERIFY. No master/schema/valuation changes; TEST and Stripe untouched.


## 12 November 2026 — PowerDolphin Wizard package resolved

Reverified the existing eBay UK £1,449 new offer: exact PowerDolphin Wizard, MPN PDW10 / EAN 6970820830313, unopened original retail packaging, Buy It Now, Nottingham UK business seller. The seller description identifies the Wizard PowerSeeker sonar; the Wizard manual's item list confirms remote controller, PowerSeeker, bait container/link, battery, charger, propellers, cables and storage bag. Sources and full notes are in CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-13.md. Reactivated existing row 6f11ca53-fcc7-4c39-8f3a-ec2aa2aee09e in place (source_record_key batch13-powervision-powerdolphin-wizard-ebay-1449); no duplicate inserted. LIVE read-back confirms active UK New GBP £1,449 and in_stock.

Batch 13 now 47 active (29 UK New, 18 UK Used), zero inactive. Cumulative Batches 04–13: 240 total, 237 active (129 UK New, 108 UK Used), three inactive. No master/schema/valuation changes; TEST and Stripe untouched.
