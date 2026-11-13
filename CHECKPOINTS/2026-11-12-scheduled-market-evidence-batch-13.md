# TradeFlow LIVE — Scheduled Market-Evidence Research Batch 13

**Research date:** 2026-11-12  
**Environment:** LIVE only  
**Branch:** production  
**Scope:** Next 20 active catalogue master products without active shared market evidence, after scheduled-checkpoint, manual-prompt and outstanding-queue exclusions.

## Selection and pre-research checks

- Read production `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md` and `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md`, then the scheduled batch checkpoint/project-memory history through batch 12.
- Excluded product UUIDs in all scheduled checkpoints 02–12.
- Excluded products in every manual AI research prompt, including completed and outstanding prompt product arrays.
- Excluded products covered by outstanding LIVE research-queue candidates, including the 10 existing `needs_research` candidates, by linked master ID or exact manufacturer/model/package identity.
- No fixed SQL OFFSET used. Selection was a dynamic anti-join over active LIVE master products, active evidence, checkpoint UUIDs, manual-prompt product arrays and outstanding queue candidates.
- Rechecked all 20 selected IDs immediately before research. Each had 0 active `shared_market_evidence`, 0 matching outstanding queue candidates and 0 manual-prompt matches.
- Excluded known cross-UUID identity duplicates noted in prior project memory, including Nikon Ai-S NIKKOR 28mm f/2 and Skydio 2+ Sports Kit.
- No master product, valuation, schema, TEST or Stripe changes.

## Research method and evidence rules

Searched manufacturer pages, UK retailers, marketplaces and Google Shopping/product-shopping results. Opened actual product pages where accessible and inspected product identity, package/variant, price, condition and availability. Do not treat a search card as verified when its click-through resolves to a different model, an inaccessible page or a different package. Keep uncertain leads with a `RED VERIFY` note. Non-GBP prices remain in their original currency; no currency conversions have been made.

## Batch 13 — 20 products

### 1. Sony — ECM-B10 Microphone
- **LIVE master product ID:** `c9c80125-7a21-4730-9413-a30350cc738d`
- **Package:** Accessory.
- **Evidence (2026-11-12):**
  - Wex: £175 new, limited stock / selling fast. Product code 3052619. https://www.wexphotovideo.com/sony-ecm-b10-wireless-shotgun-microphone-3052619/
  - Park Cameras: £175 new. https://www.parkcamera.live/shop/sony-ecm-b10-wireless-shotgun-microphone_7680123n
  - Bristol Cameras: £175 inc VAT, available to order, genuine UK stock. https://www.bristolcameras.co.uk/product/sony-ecm-b10-shotgun-microphone/
  - Harrison Cameras: £179, 1 in stock. https://harrisoncameras.co.uk/products/sony-ecm-b10-shotgun-microphone-ecmb10-ce7
  - Norwich Cameras: £168, stated stock available with 5–7 day lead; seller is Futronix Electronic Ltd (HK) with no VAT, while Norwich handles payment/customer service/returns. https://norwich-cameras.co.uk/products/sony-ecm-b10-compact-camera-mount-digital-shotgun-microphone
  - ProAV: £190.92 inc VAT / £159.10 ex VAT; page simultaneously says in stock and backorder, usually within 10 working days. https://proav.co.uk/sony-compact-shotgun-microphone
- **Condition/package:** New standalone ECM-B10 microphone; cable-free/battery-free shotgun microphone, three pickup patterns.
- **RED VERIFY:** ProAV stock wording conflicts. Norwich listing is sold by an overseas entity without VAT; verify VAT/import treatment and seller responsibility. Price-comparison page shows £159 at CameraWorld but retailer page not independently opened; do not treat that comparison-only amount as verified.

### 2. Sony — FE 85mm F1.4 GM II
- **LIVE master product ID:** `ca3129be-6d49-4c7b-ba63-007b859ee343`
- **Package:** Lens Only.
- **Evidence:**
  - Sony UK store: £1,799, page showed only 1 left; product selector/search result also surfaced a £1,599 sale-price card, so checkout price is inconsistent. https://www.sony.co.uk/store/product/sel85f14gm2b.syx/FE-85mm-F1-4-GM-II-Full-Frame-Prime-Lens
  - Sony Centre Direct: £1,799. https://sonycentresdirect.co.uk/p-55783-fe-85mm-f14-gm-ii.aspx
  - Sony product page confirms exact GM II identity and 77mm filter thread. https://www.sony.co.uk/electronics/interchangeable-lenses/sel85f14gm2
- **Condition/package:** New standalone E-mount FE 85mm F1.4 GM II lens.
- **RED VERIFY:** Confirm Sony checkout price because the page and dynamic selector/search card showed £1,799 and £1,599. Other Shopping leads around £1,199 and £1,049 were unusually low or failed to resolve to a verified matching offer; retain only as leads, not prices.

### 3. Sony — FE 12-24mm F2.8 GM
- **LIVE master product ID:** `cc1aa201-fee6-43f4-b295-a04a49251b57`
- **Package:** Standard.
- **Evidence:**
  - Sony UK: £2,645, standalone lens. https://www.sony.co.uk/store/product/sel1224gm.syx/buy
  - Clifton Cameras: £2,645; awaiting stock, orders accepted, usually 5–7 days. Box includes lens hood, front/rear caps and lens case. https://www.cliftoncameras.co.uk/sony-fe-12-24mm-f28-gm-lens
  - Sony Centre Direct: £2,645. https://sonycentresdirect.co.uk/p-41047-sony-sel1224gm-fe-12-24mm-f28-gm-lens.aspx
- **Condition/package:** New standard lens package; no additional camera body or accessory bundle identified.
- **RED VERIFY:** Clifton accepts orders but is awaiting stock. Google Shopping returned lower offers including £1,802 and other unusually low amounts; exact retailer/checkout/stock not confirmed, so do not treat those as verified prices.

### 4. RadioMaster — Ranger 2.4GHz ExpressLRS External Module
- **LIVE master product ID:** `cd15ac76-7393-43a8-9f68-3da93c1bc851`
- **Package:** Ranger 2.4GHz ExpressLRS External Module.
- **Evidence:**
  - HobbyRC: £99.99 inc VAT, in stock. https://www.hobbyrc.co.uk/radiomaster-ranger-24ghz-elrs-module
  - Flying Tech: £99 inc VAT, 5 left; page shows next shipping 11/11/2026. https://www.flyingtech.co.uk/product/radiomaster-ranger-2-4ghz-expresslrs-elrs-module/
  - 3DXR: £99.99 inc VAT / £83.33 ex VAT, 39 in stock. https://www.3dxr.co.uk/products/radiomaster-ranger-2-4ghz-elrs-module-lbt
- **Condition/package:** New standalone Ranger full-size external module; T antenna and Moxon antenna included by 3DXR/HobbyRC descriptions.
- **RED VERIFY:** Do not substitute Ranger Micro or Ranger Starter Combo. Starter combo offers £119.99 at Flying Tech and includes three receivers (2x RP1 + 1x RP2); it is a different package. https://www.flyingtech.co.uk/product/radiomaster-ranger-2-4ghz-elrs-module-starter-combo/

### 5. Sony — PDW-F800
- **LIVE master product ID:** `d4555efd-c678-4f22-b982-06ca8230ea5b`
- **Package:** Standard.
- **Evidence:**
  - Cineworks product page displays £260.00 and describes the exact Sony PDW-F800 XDCAM HD422 camcorder. https://www.cineworks.tv/product/sony-pdw-f800/
- **Condition/availability:** Not stated. No sale stock indicator, condition grade, included accessories or checkout information found.
- **RED VERIFY:** Cineworks site navigation includes an Equipment Hire section; the £260 price basis is unclear and may not be a sale price. Ask whether £260 is a hire rate, sale price or another charge, and verify condition, package contents and availability. Do not use as a verified purchase price.

### 6. PowerVision — PowerDolphin Wizard Package
- **LIVE master product ID:** `d85ca7a7-e811-427a-a23c-d1abe267536a`
- **Package:** Wizard Package.
- **Evidence:**
  - eBay new listing: £1,449, business seller in Nottingham, 100% positive, no returns. Model PowerDolphin Wizard, MPN PDW10. https://www.ebay.co.uk/itm/116741484492
  - eBay used listing: £449.99, business seller in Dundee, 99.7% positive, no returns; listing page confirms it sold on 2 October 2026. Model PowerDolphin Wizard, MPN PDW10. https://www.ebay.co.uk/itm/147582064972
  - Kamera Express package contents: PowerDolphin Wizard, base station, controller, handset clip, intelligent charger and cable, 70m communication cable, bait drop, PowerSeeker and charging cable, ZEISS VR ONE Plus goggles and trolley. https://www.kamera-express.be/powervision-powerdolphin-wizard
  - PowerVision manual identifies Wizard kit components. https://www.manualslib.com/manual/1940291/Powervision-Powerdolphin.html
- **Condition/package:** One current new listing; one ended used listing. The Wizard package is materially more complete than the standard/Explorer package.
- **RED VERIFY:** Confirm that the £1,449 seller's actual box contains the Wizard sonar/bait-drop/controller/accessory kit. Used £449.99 is a completed listing, not a current asking price; seller's listing had no returns.

### 7. PowerVision — PowerEgg X Waterproof Case
- **LIVE master product ID:** `df53bb7c-cbc1-4eed-b114-5cf840ec196c`
- **Package:** Waterproof Case.
- **Evidence:**
  - Wex: £209, RRP £299, limited stock / selling fast. Exact box contents: 1x PowerVision PowerEgg X waterproof case only. https://www.wexphotovideo.com/powervision-poweregg-x-waterproof-case-1735465/
- **Condition/availability:** New accessory; limited stock.
- **Notes:** Exact match. Do not confuse the standalone case with the PowerEgg X Wizard drone bundle, which also includes the case.

### 8. Sony — XDCA-FS7 Extension Unit
- **LIVE master product ID:** `df9f8a4d-8754-44d0-b443-150be2ceb41a`
- **Package:** Standard.
- **Evidence:**
  - Visual Impact: £120 used, 3+ in stock. https://www.visuals.co.uk/sony-xdca-fs7-camera-extension-box-for-pxw-fs7-fs7k-used.html
  - MPB: 3 used available from £123–£144; Good £123, Excellent £144, standard 12-month warranty. https://www.mpb.com/en-uk/product/sony-xdca-fs7-extension-unit
  - 3D Broadcast: £390 inc VAT / £325 ex VAT, 2 used units in stock. https://3dbroadcastsales.com/products/sony-xdca-fs7-extension-unit-for-pxw-fs7-and-pxw-fs7k-cameras-used
  - eBay: £175 used, 3 available, business seller in London, 14-day returns. https://www.ebay.co.uk/itm/147502069035
- **Condition/package:** Used extension unit; attaches to PXW-FS7/FS7K. Adds ProRes 422, RAW output support, timecode/genlock and V-mount battery interface.
- **RED VERIFY:** Large used-price spread (£120–£390). Check included plate/attachments, exact condition, warranty and whether all units are the same XDCA-FS7 model.

### 9. Skydio — 2+ Dual Charger
- **LIVE master product ID:** `e0634f33-3a02-4fe0-9a2d-8705808497d2`
- **Package:** Standard Item.
- **Evidence:**
  - Official Skydio store: $149 USD; charges two batteries; 65W wall adapter sold separately; ships in 3–5 business days. https://shop.skydio.com/products/skydio-2-charger
  - eBay UK: £72.92 used, private seller in Holyhead, no returns. https://www.ebay.co.uk/itm/187918127220
- **Condition/package:** Official new product and used UK listing. The charger itself does not include the wall adapter.
- **RED VERIFY:** Google Shopping card displayed £52.70 for the same eBay link, but the clicked listing displayed £72.92. Retain £72.92 as the opened listing price; flag the Shopping-card discrepancy. Official Skydio store states sales are limited to the US and Canada.

### 10. Sony — HXR-MC50E
- **LIVE master product ID:** `e4b6f3e4-7592-4551-876b-8b9fe7cd6c4d`
- **Package:** Standard.
- **Evidence:**
  - Cash Converters: historical £129.99, very minor cosmetic wear, 12-month warranty, camera and charger; page now says sold/no longer available and no external microphone or lens guard. https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/video-cameras/video-camera/017900194034
  - eBay sold listing: £229.99, used, fully tested/working, good used condition, battery and new charger included; sold 15 August. https://www.ebay.co.uk/itm/317543403106
  - eBay faulty listing: £69.99, for parts/not working, London business seller, no returns. https://www.ebay.co.uk/itm/357137612058
- **Condition/availability:** No currently verified in-stock exact listing. Cash Converters listing sold; £229.99 eBay listing sold; £69.99 is faulty.
- **RED VERIFY:** Keep working and faulty examples separate. Do not use the faulty £69.99 as a working-camera reference.

### 11. PowerVision — PowerEgg X Wizard Package
- **LIVE master product ID:** `e6c149dd-1bce-4b5e-9806-0e970e7ce3e5`
- **Package:** Wizard Package.
- **Evidence:**
  - PowerVision launch announcement: historical Wizard package MSRP $1,249 USD; Explorer MSRP $899 USD. Wizard included waterproof accessories. https://www.prnewswire.com/news-releases/poweregg-x-personal-ai-camera---the-ultimate-tool-for-content-creators-301068006.html
  - Crutchfield Wizard package contents: waterproof casing, pontoons, remote controller, wrist strap, arms/propellers, three spare pairs of propellers, two intelligent batteries and intelligent charger. https://www.crutchfield.com/p_230PXW10/PowerVision-PowerEgg-X-Wizard.html
  - Kamera Express Wizard package contents and two-year warranty. https://www.kamera-express.nl/powervision-poweregg-x-wizard
  - Google Shopping/product card showed an eBay lead at £650.64, but the card click-through did not resolve to an accessible product listing. No direct listing URL could be captured.
- **Condition/availability:** Current UK price not verified. US historical MSRP is not a current UK price.
- **RED VERIFY:** Check the £650.64 Shopping lead manually; verify seller, model, package and whether waterproof case/pontoons/two batteries/charger are included. Do not use £760 SLRHut Explorer listing as a Wizard match; Explorer is a different package.

### 12. Skydio — Beacon
- **LIVE master product ID:** `e858c5cf-42fd-409f-93e0-6863c3b41261`
- **Package:** Standard Item.
- **Evidence:**
  - Official Skydio 2+ Beacon: $219 USD, SKU SKYBC350NA, ships within 3–5 business days, 30-day returns. Compatible with Skydio 2 and 2+. https://shop.skydio.com/collections/essential-accessories/products/skydio-2-plus-beacon
- **Condition/availability:** New official listing; page shows add-to-cart. Skydio states its products are sold only in the United States and Canada.
- **RED VERIFY:** No UK GBP offer found. Do not convert $219. Confirm whether this catalogue Standard Item is intended to match the 2+ Beacon SKU.

### 13. Z CAM — P2-R1N 24x
- **LIVE master product ID:** `ef07cfd8-6ce5-425d-8de0-f73ba77beffb`
- **Package:** Standard Package.
- **Evidence:**
  - G&G exact P2-R1N 24X, part number P2R1N0124B: $3,299 USD, special order, expected 1–3 weeks, no returns. https://www.ggvideo.com/zcam_p2-r1n-24x.php
  - Related but different model P2-R1 24X (no N) is $2,799 USD, part P2R10124B; do not match this price to P2-R1N. https://www.ggvideo.com/zcam_p2-r1-24x.php
- **Condition/availability:** New special-order listing; no UK GBP price found.
- **RED VERIFY:** Exact N suffix and P2R1N0124B part number matter. Leave GBP price blank; do not convert USD.

### 14. Sony — HVR-V1E
- **LIVE master product ID:** `f2b5f83e-680f-49e5-9729-8aebba707850`
- **Package:** Standard Package.
- **Evidence:**
  - Camera City: £399, 1 in stock, used, no charger; includes a non-original battery. https://cameracity.co.uk/product/sony-hvr-v1e-1080i-mini-dv-professional-3cmos-camcorder-no-charger/
  - eBay UK Plan B Retro: £280 used, working listing; page redirected to a generic product page on open, so current listing availability needs checking. https://www.ebay.co.uk/itm/117069480914
  - Colin's Cameras: £260, very good, fully tested, supplied with charger, cables, NP-F960 battery and remote; sold out. https://colinscameras.co.uk/products/sony-hvr-v1e
  - eBay faulty: £170.02, not tested/sold as faulty. https://www.ebay.co.uk/itm/127942911366
- **RED VERIFY:** Compare package contents carefully: Camera City has no charger; Colin's £260 kit is sold out; faulty £170.02 is not a working unit. Confirm the £280 eBay page's live listing status.

### 15. Sony — SRG-X400
- **LIVE master product ID:** `f6372983-a0fc-4282-b9af-862f9131d96c`
- **Package:** Standard Package.
- **Evidence:**
  - ProAV black SRG-X400BC: £2,754 inc VAT / £2,295 ex VAT; page says in stock but also backorder, usually 10 working days. Box includes camera, AC adapter, IR remote, two ceiling brackets, wire rope, mounting screws and HDMI clamp. https://proav.co.uk/sony-srg-x400bc-ptz-camera-black
  - SCAN white SRG-X400WC: £3,199.99, awaiting ETA/pre-order. https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-white-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s
  - SCAN black SRG-X400BC page/search result also showed £3,199.99 awaiting ETA. https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-black-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s
- **Condition/package:** New standalone PTZ camera package; black and white colour SKUs are separate.
- **RED VERIFY:** The catalogue does not specify colour. ProAV availability wording conflicts. Confirm whether the Standard Package should remain colour-neutral or be split by BC/WC SKU; do not merge SRG-X40UH.

### 16. Sony — PDW-F350
- **LIVE master product ID:** `f87012b0-edfd-4d16-b694-e00e0e1f1b4b`
- **Package:** Standard.
- **Evidence:**
  - eBay UK: £818.92 used, private seller in Wolverhampton, no returns. https://www.ebay.co.uk/itm/325590169943
  - eBay US listing: $625 USD + $175 USD postage, used, no returns; eBay page displayed an approximate GBP conversion, but it is not recorded as a GBP price. https://www.ebay.co.uk/p/99934044
- **Condition/availability:** UK used Buy It Now listing; seller private, no returns.
- **RED VERIFY:** Confirm included lens, lens model, battery/charger, recording functionality and disc drive operation. The US listing's displayed approximate GBP is not used as a price.

### 17. Walkera — Furious 320
- **LIVE master product ID:** `fa5170e1-e2bf-47ed-a981-d93fabec232b`
- **Package:** Standard Item.
- **Evidence:**
  - BuzzFlyer UK exact Furious F320: £369 inc VAT / £307.50 ex VAT, previously £449.95; page offers free FPV Goggle 4 and an optional extra-battery selector, but is out of stock. https://www.buzzflyer.co.uk/Walkera-Furious-F320__p-2979.aspx
  - Related OSD spare part for Furious 320: €26.53, not a drone price. https://www.fpvracer.lt/model/walkera-furious-320-spare-part-osd-furious-320-g-z-08-12337.html
- **Condition/availability:** Drone listing out of stock; no exact current full-drone used listing verified.
- **RED VERIFY:** £369 is a historical/out-of-stock asking price, not current availability. Do not use the OSD spare-part price as drone evidence.

### 18. Skydio — X10D Battery
- **LIVE master product ID:** `0061d7d0-e6c4-478c-880b-52cf31db3802`
- **Package:** Standard Item.
- **Evidence:**
  - Official Skydio X10D technical specifications: flight battery 8,419 mAh, 18.55 V, 156.17 Wh, weight approximately 707.6 g. No standalone battery sale price or availability on the page. https://www.skydio.com/x10d/technical-specs
- **Condition/availability:** Technical reference only; no retail listing or GBP price found.
- **RED VERIFY:** Obtain exact replacement battery SKU and UK authorised-distributor quote. Do not substitute Skydio 2/2+ batteries.

### 19. HOVERAir — AQUA
- **LIVE master product ID:** `01bc2702-9ff1-42c4-bb9a-0b36c2edfaf6`
- **Package:** Standard Item.
- **Evidence:**
  - Official UK HOVERAir store: Standard £1,129; includes AQUA with 1 battery, USB-C cable, Lighthouse with armband, repair kit and waterproof battery bag. Fly More £1,299 includes two extra smart batteries, three waterproof battery bags and charging hub. https://uk.hoverair.com/products/hoverair-aqua
  - Park Cameras Standard: £1,129. https://www.parkcameras.com/shop/hoverair-x1-aqua-standard_9021170a
  - Park Cameras Basic Combo: £1,219; separate product code 9021172A. https://www.parkcameras.com/shop/hoverair-x1-aqua-basic-combo_9021172a
  - Currys Standard Combo: £1,129. https://www.currys.co.uk/products/hoverair-aqua-standard-combo-drone-orange-and-black-10305877.html
  - Ballicom Standard Combo: £1,113.56 inc VAT / £927.97 ex VAT, 17 immediately available. https://www.ballicom.co.uk/hoverair-sp08h004-aqua-standard-combo.p1724345.html
  - Selfridges Basic Combo: £1,399. https://www.selfridges.com/GB/en/product/hoverair-hoverair-aqua-basic-combo_R04735656/
- **Condition/package:** New; Standard, Basic Combo and Fly More are distinct packages.
- **RED VERIFY:** Do not merge Basic Combo or Fly More with Standard. Selfridges £1,399 is a substantially higher Basic Combo offer; verify contents and seller/fulfilment. Ballicom is the lowest opened retailer price with stock count.

### 20. Yuneec — H850-RTK Hexacopter
- **LIVE master product ID:** `024f64f2-03b4-46f7-ab85-d1eab4f07f43`
- **Package:** Hexacopter.
- **Evidence:**
  - Official Yuneec German store: €8,099 incl VAT, reduced from €8,999 (10%); shipping extra. Product number YUNH850EUSC_. https://shop.yuneec.com/H850-RTK/YUNH850EUSC
  - Aerodron Poland: 34,400 PLN gross / 27,967.48 PLN net, 1 in stock, stated 48-hour availability. https://www.aerodron.pl/produkt/yuneec-h850-rtk-dron-yunh850eusc/
  - Yuneec Poland: €8,232.18 gross / €6,692.83 net. https://yuneec.pl/eng_m_Drones_Yuneec-H850-RTK_Drones-1899.html
  - Official Yuneec H850 flyer describes the drone with controller, two smart batteries, case and accessories; payloads are separate/optional. https://yuneec.com/wp-content/uploads/2024/02/2023%20Flyer%20H850%20V2.pdf
- **Condition/availability:** New official store product; German price is not UK GBP. Poland retailer states 1 in stock.
- **RED VERIFY:** Leave GBP price blank. Confirm UK seller, included T-One controller/charger/hard case, battery count and whether any camera/payload is included. Do not convert EUR or PLN.

## Google Shopping / click-through observations

- Clicked through the available product-shopping cards where a direct page was supplied.
- Skydio Dual Charger Shopping card displayed £52.70 but its opened eBay page displayed £72.92; record the opened listing price and flag the mismatch.
- PowerEgg X Wizard Shopping card displayed £650.64 but its click-through did not resolve to an accessible listing. Keep as an unverified lead; no direct listing URL captured.
- Several related cards were wrong model/package variants (e.g. Ranger Micro/Starter Combo vs full Ranger module; PowerEgg X Explorer vs Wizard; P2-R1 vs P2-R1N; Skydio 2/2+ accessory vs X10D battery). Do not match those prices to the wrong product.
- Do not discard unresolved or uncertain evidence; retain links and `RED VERIFY` notes.

## Queue staging and owner-auth limitation

Checked LIVE owner context before any write:
- `auth.uid()`: null
- `auth.role()`: null
- `platform_cloud_ai_owner_check()`: false

The public schema exposes owner RPCs for listing, reviewing and deleting research queue items and for manual AI prompts, but no supported authenticated RPC for staging a new market-evidence candidate. Because owner context is absent and the owner check fails:
- Do not call an insert/staging RPC.
- Do not write directly to `platform_catalogue_research_queue`.
- Do not impersonate JWT claims or bypass RLS.
- **20 candidates researched; 0 staged.**
- No evidence has been inserted into `shared_market_evidence`; uncertain prices have not entered automatic valuation.

## Next run

Read this batch 13 checkpoint and project memory first. Exclude all 20 product IDs above, all IDs from scheduled checkpoints 02–13, all outstanding LIVE queue candidates and all outstanding manual AI research prompt product IDs. Recheck evidence and queue status immediately before research. Select the next 20 eligible active LIVE master products dynamically without SQL OFFSET. Continue source click-through, variant/package verification and `RED VERIFY` retention. If owner auth remains null or owner check fails, create the next checkpoint and project memory only.


## Background importer repair note — 12 November 2026

- The initial automated import run correctly stopped before any write because checkpoint UUID extraction included historical/recheck IDs.
- The importer now extracts only explicit product-ID fields and requires exactly 220 unique records across batches 03–13 before writing.
- Research is staged as `pending_review` reference candidates only; no price is copied without source-level matching, no foreign currency is converted, and no evidence is approved automatically.


## Additional direct-source follow-up — 12 November 2026

Twenty-four further observations were inserted into LIVE and read back. One initial PowerDolphin Wizard new listing was deactivated because the seller's package contents do not prove the full Wizard kit.

### Sony ECM-B10
- Park Cameras £175 new, product code 7680123N; store selection required before basket. [Source](https://www.parkcamera.live/shop/sony-ecm-b10-wireless-shotgun-microphone_7680123n)
- Bristol Cameras £175 new, available to order, genuine UK stock. [Source](https://www.bristolcameras.co.uk/product/sony-ecm-b10-shotgun-microphone/)
- Harrison Cameras £179 new, one in stock. [Source](https://harrisoncameras.co.uk/products/sony-ecm-b10-shotgun-microphone-ecmb10-ce7)
- Wex Photo Video £137 used Mint, in stock, box/manual/windscreen/cap/carry bag. [Source](https://www.wexphotovideo.com/sony-ecm-b10-wireless-shotgun-microphone-used-3363458/)
- MPB £145 used Like New, three units, 12-month warranty. [Source](https://www.mpb.com/en-uk/product/sony-ecm-b10-shotgun-microphone)

### Sony FE 85mm F1.4 GM II
- CameraWorld £1,789 new, in stock, 3–5 day dispatch; £200 cashback after purchase. [Source](https://www.cameraworld.co.uk/sony-fe-85mm-f1.4-gm-ii-lens.html?condition=new)
- CameraWorld £1,710 open-box, one unique item in stock. [Source](https://www.cameraworld.co.uk/sony-fe-85mm-f1.4-gm-ii-lens.html?condition=open-box)
- Wex £1,269 used, in stock, item 3366284. [Source](https://www.wexphotovideo.com/sony-fe-85mm-f1-4-gm-ii-lens-used-3366284/)
- London Camera Exchange £1,249.99 used Good, Colchester in store, boxed with hood/case/caps, 6-month guarantee. [Source](https://www.lcegroup.co.uk/Used/Sony-FE-85mm-F1.4-GM-II-Boxed-%7C-4_492536.html)

### Sony FE 12-24mm F2.8 GM
- London Camera Exchange £2,645 new, in stock, Add to Basket and free delivery. [Source](https://www.lcegroup.co.uk/New/Sony-FE-12-24mm-f2.8-G-Master-Lens_64201.html)

### RadioMaster Ranger full-size 2.4GHz ExpressLRS module
- Flying Tech £99 inc VAT, five left. [Source](https://www.flyingtech.co.uk/product/radiomaster-ranger-2-4ghz-expresslrs-elrs-module/)
- 3DXR £99.99 inc VAT, 39 in stock. [Source](https://www.3dxr.co.uk/products/radiomaster-ranger-2-4ghz-elrs-module-lbt)
Both are the full-size module, not Ranger Micro or Starter Combo.

### Sony XDCA-FS7 extension unit — used
- MPB £123 Good (SKU 4018689), in stock, 12-month warranty. [Source](https://www.mpb.com/en-uk/product/sony-xdca-fs7-extension-unit)
- MPB £144 Excellent (SKU 4079559), in stock, original packaging and 12-month warranty. [Source](https://www.mpb.com/en-uk/product/sony-xdca-fs7-extension-unit)
- eBay UK £175, three available, London business seller, 100% positive, 14-day returns. [Source](https://www.ebay.co.uk/itm/147502069035)
- 3D Broadcast £390 inc VAT, two used units in stock. [Source](https://3dbroadcastsales.com/products/sony-xdca-fs7-extension-unit-for-pxw-fs7-and-pxw-fs7k-cameras-used)

### Sony SRG-X400 PTZ camera
- SCAN SRG-X400WC white £3,199.99, awaiting ETA / preorder, 36-month return-to-base warranty. [Source](https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-white-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s)
- SCAN SRG-X400BC black £3,199.99, awaiting ETA / preorder, 36-month return-to-base warranty. [Source](https://www.scan.co.uk/products/sony-srg-x400-ptz-camera-black-1-25-exmor-r-cmos-1080p60-4k-upgradable-20x-optical-zoom-poeplus-3g-s)
Colour variants are separate SKUs, retained as distinct observations under the shared model.

### HOVERAir AQUA Standard Combo
- Currys £1,129, approved third-party delivery 3–5 working days, collection unavailable; exact standard package. [Source](https://www.currys.co.uk/products/hoverair-aqua-standard-combo-drone-orange-and-black-10305877.html)
- Ballicom £1,113.56 inc VAT, 17 immediately available; exact MPN SP08H004, Standard Combo. [Source](https://www.ballicom.co.uk/hoverair-sp08h004-aqua-standard-combo.p1724345.html)
These are Standard package offers; do not merge Basic Combo or Fly More.

### Historical/fault-condition references
- PowerVision PowerDolphin Wizard eBay used listing sold 2 Oct 2026 at £449.99; seller in Dundee, 99.7% positive. Retained as historical used evidence; package contents not fully enumerated. [Source](https://www.ebay.co.uk/itm/147582064972)
- Sony HXR-MC50E Cash Converters £129.99 sold, included camera/charger but no external mic or lens guard. [Source](https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/video-cameras/video-camera/017900194034)
- Sony HXR-MC50E eBay £229.99 sold 15 Aug 2026, fully tested/working, battery and new charger. [Source](https://www.ebay.co.uk/itm/317543403106)
- Sony HXR-MC50E eBay £69.99 faulty/for parts, London business seller, no returns; not comparable with working units. [Source](https://www.ebay.co.uk/itm/357137612058)

The initial PowerVision PowerDolphin Wizard £1,449 new eBay row was marked inactive because the seller listing does not establish the full Wizard package contents (sonar, bait drop, controller and accessory kit). The historical £449.99 used sale remains active as used reference only. The eBay HVR-V1E search result was not imported: although the title says HVR-V1E, item specifics identify model/MPN HVR-Z1E, so it is a model mismatch.

Batch 13 now has **36 total rows: 35 active (17 UK New, 18 UK Used) and one inactive package-unverified new row; all 36 are GBP**. UK Used remains reference-only. Out-of-stock/preorder UK New rows are retained with their explicit status under existing behaviour; they may still be selected by the current valuation function if active.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## Additional retailer price recheck — 12 November 2026

Five more exact direct-source observations were added and read back:
- Sony ECM-B10 — CameraWorld £159 new, in stock, 3–5 day dispatch; category product listing confirms exact model.
- Sony FE 85mm F1.4 GM II — London Camera Exchange £1,799 new, in stock; £200 cashback after claim.
- Sony FE 85mm F1.4 GM II — Park Cameras £1,799 new, in stock; £200 cashback after claim, two-year warranty after registration.
- Sony FE 12-24mm F2.8 GM — CameraWorld £2,548 new, two available, 3–5 day dispatch, free delivery and 2-year guarantee.
- Sony FE 12-24mm F2.8 GM — CameraWorld £2,548 open-box, one unique item in stock, recorded separately from new.

Sources:
- [CameraWorld ECM-B10 listing](https://www.cameraworld.co.uk/videography-products/video-camera-microphones/shopby/sony.html)
- [LCE FE85 GM II](https://www.lcegroup.co.uk/New/Sony-FE-85mm-F1.4-G-Master-II_175416.html)
- [Park Cameras FE85 GM II](https://www.parkcameras.com/shop/sony-fe-85mm-f14-gm-ii-lens_7240588g)
- [CameraWorld FE12-24 GM](https://www.cameraworld.co.uk/sony-fe-12-24mm-f28-gm-lens.html?condition=new)
- [CameraWorld FE12-24 open-box](https://www.cameraworld.co.uk/sony-fe-12-24mm-f28-gm-lens.html?condition=open-box)

Batch 13 now has **41 total GBP rows: 40 active (21 UK New, 19 UK Used) and one inactive package-unverified PowerDolphin Wizard new listing**.


## Additional direct-source RED VERIFY follow-up — 12 November 2026

Six additional UK New observations were imported and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| Sony ECM-B10 | Wex Photo Video | £175.00 | Exact product code 3052619; new, limited stock/selling fast. [Source](https://www.wexphotovideo.com/sony-ecm-b10-wireless-shotgun-microphone-3052619/) |
| Sony FE 85mm F1.4 GM II | Sony Centre Direct | £1,799.00 | Exact SKU SEL85F14GM2B.SYX; standalone lens, free standard 48-hour delivery shown. [Source](https://sonycentresdirect.co.uk/p-55783-fe-85mm-f14-gm-ii.aspx) |
| Sony FE 12-24mm F2.8 GM | Sony UK | £2,645.00 | Exact SKU SEL1224GM.SYX; official store, Add to Basket and delivery date shown. [Source](https://www.sony.co.uk/store/product/sel1224gm.syx/buy) |
| Sony FE 12-24mm F2.8 GM | Sony Centre Direct | £2,645.00 | Exact SKU SEL1224GM.SYX; reduced from £2,899, free standard delivery shown. [Source](https://sonycentresdirect.co.uk/p-41047-sony-sel1224gm-fe-12-24mm-f28-gm-lens.aspx) |
| HOVERAir AQUA Standard | HOVERAir UK Official Store | £1,129.00 | Exact Standard bundle: AQUA with one battery, USB-C cable, Lighthouse/armband, repair kit and waterproof battery bag. Fly More is a different £1,299 package. [Source](https://uk.hoverair.com/products/hoverair-aqua) |
| HOVERAir AQUA Standard | Park Cameras | £1,129.00 | Exact product code 9021170A, in stock, Add to Basket; one-battery Standard bundle. [Source](https://www.parkcameras.com/shop/hoverair-x1-aqua-standard_9021170a) |

Data-quality correction: the BuzzFlyer Walkera Furious F320 £369 observation is a new retail listing (condition new, sold out), not UK Used. Its evidence_type was corrected from uk_used to uk_new; price, source URL, sold-out availability and active status were retained. It remains a sold-out new asking-price reference under the existing evidence policy.

Batch 13 now has **47 total GBP rows: 46 active (28 UK New, 18 UK Used) and one inactive package-unverified PowerDolphin Wizard new row**. UK Used/open-box records remain reference-only. The inactive PowerDolphin Wizard row remains stored for audit because the listing does not establish the full Wizard package contents.

Other RED VERIFY leads remain excluded where no exact UK GBP source or package match was established: PDW-F800 £260 basis may be hire rather than sale; Skydio Beacon/X10D battery no UK source; Z CAM P2-R1N no UK GBP price; Yuneec H850-RTK no verified UK seller/package; HXR-V1E search-result listing item specifics identify HVR-Z1E, so not matched; PowerEgg X Wizard Shopping lead did not resolve; HDC/Sony package or seller terms remain uncertain. No foreign-currency conversion or wrong-model match was imported.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## Cumulative LIVE evidence update — 12 November 2026

Six further RED VERIFY leads were resolved and imported across Batches 06–08:
- Exact Bebob V98 V-Mount Battery (SKU V98), CVP £312.00 inc VAT (£260.00 ex VAT), one remaining in stock for immediate delivery, UK battery shipping supported, two-year standard warranty. [Source](https://cvp.com/product/bebob_v98_battery). The LIVE row was read back successfully and remains separate from V98micro/V98microC.
- Exact DJI Mini 3 Fly More Combo Plus (DJI RC), SKU CP.MA.00000613.01, Drone Safe Store £509.00 inc VAT (was £579.00), explicitly out of stock. Package contents verified as DJI RC, three batteries, two-way charging hub, shoulder bag, spare propellers, screws, screwdriver, gimbal protector and cables. [Source](https://www.dronesafestore.com/products/dji-mini-3-fly-more-combo-dji-rc). The LIVE row was read back successfully and is not the RC-N1 variant.
- Exact Bright Tangerine OpenRig Base Kit (part B4013.0017), ProAV £189.00 inc VAT (£157.50 ex VAT), listed Add to Cart / Available to Order. [Source](https://proav.co.uk/support/camera-rigging/rigs/kits/). The LIVE row was read back successfully and is recorded separately from the CVP preorder source.
- Exact Leica M11 Monochrom Body (RedDot stock code L20208), £8,300.00 inc VAT (£6,916.67 ex VAT), last items in stock. [Source](https://www.reddotcameras.co.uk/m-bodies/18839-leica-m11-monochrom-body.html). The LIVE row was read back successfully; the price difference is the inc-VAT/ex-VAT display, not a price conflict.
- Exact NEEWER LS-29 PRO 8mm Fisheye Lens with 17mm Thread Phone Lens Clip (SKU 66605766), NEEWER UK £58.99 inc VAT (was £86.99), 0 in stock / Sold Out. Package contents were confirmed from the official UK page. [Source](https://uk.neewer.com/products/neewer-ls-29-pro-8mm-fisheye-lens-with-17mm-thread-phone-lens-clip-66605766). The LIVE row was read back successfully and retained as active historical UK New evidence with out-of-stock status.
- Exact GoPro MISSION 1 PRO Grip Edition, official GoPro UK £679.99, exact Grip Edition selected with Add To Cart shown; camera, Enduro 2 battery, case and Point-and-Shoot Grip package confirmed. [Price listing](https://gopro.com/en/gb/shop/deals/camera-bundle-deals) · [Selected product](https://gopro.com/en/gb/shop/buy-cameras/mission-1-series?bundle-id=CHDRW-011-master&product-id=CHDHW-011-master). Stock count is not separately displayed and checkout was not completed; the caveat is retained in the row.

Cumulative Batches 04–13 now contain **232 GBP observations: 228 active (125 UK New, 103 UK Used) and four inactive retained for audit**. Batch 06 now contains 15 active rows (11 UK New, 4 UK Used). Batch 07 now contains 15 rows: 14 active (10 UK New, 4 UK Used) and one inactive UK New Notify Me row. Batch 08 now contains 16 rows: 15 active (12 UK New, 3 UK Used) and one inactive UK New seller-away row. UK Used remains excluded from automatic valuation. The valuation function, schema, TEST and Stripe were not changed.


## Cumulative LIVE evidence update — 12 November 2026 (Batch 08 continuation)

One additional RED VERIFY lead was resolved and imported:
- Exact Hubsan Zino Mini Pro Refined three-battery package, H817DR / EAN 6922572413412, Align-Trex UK £485.99 (RRP £539.99), explicitly Out of Stock / Notify Me. The direct page confirms three batteries and 64GB onboard memory. [Source](https://www.align-trex.co.uk/hubsan-zino-mini-pro-refined-h817dr.html). The row was read back successfully and matched to the ZINO MINI PRO REFINED master, not the one-battery standard package. It remains active historical UK New evidence with explicit out_of_stock status.

Cumulative Batches 04–13 now contain **233 GBP observations: 229 active (126 UK New, 103 UK Used) and four inactive retained for audit**. Batch 08 now contains 17 rows: 16 active (13 UK New, 3 UK Used) and one inactive UK New seller-away row. UK Used remains excluded from automatic valuation. The valuation function, schema, TEST and Stripe were not changed.


## Cumulative LIVE evidence update — 12 November 2026 (Batch 09 continuation)

One additional RED VERIFY lead was resolved and imported:
- Sony HDC-1500 Standard Package, N.I. Broadcast Ltd (eBay UK), £8,010 or Best Offer, used, 10 available. Each channel includes one HDC-1500 fibre camera head, one HDCU-1500 half-rack CCU with extra HDSDI output board, one tripod plate and one RCP-920 with Ethernet option. Lenses/viewfinders are extra-cost; UK domestic shipping quote remains unconfirmed. [Listing](https://www.ebay.co.uk/itm/198054902757) · [Full seller description](https://itm.ebaydesc.com/itmdesc/198054902757?category=3319&cspheader=1&descgauge=1&domain=ebay.com&excSoj=1&excTrk=1&ittenable=false&lang=en&lsite=3&oneClk=2&secureDesc=1&seller=n.i_broadcast&t=1710364074000&ver=1). The row was read back successfully and is reference-only UK Used evidence.

Cumulative Batches 04–13 now contain **234 GBP observations: 230 active (126 UK New, 104 UK Used) and four inactive retained for audit**. Batch 09 now contains 21 active rows (9 UK New, 12 UK Used). UK Used remains excluded from automatic valuation. The valuation function, schema, TEST and Stripe were not changed.


## Cumulative LIVE evidence update — 12 November 2026 (Batch 09 continuation)

One additional RED VERIFY lead was resolved and imported:
- Shure SM81 / SM81-LC, Stage Supply product code 4736, £405.00 inc VAT (£337.50 ex VAT), 8 available online, further supplier stock in 1–3 weeks, 2-year manufacturer warranty. [Retailer listing](https://stagesupply.co.uk/product/shure-sm81-cardioid-condenser-instrument-microphone/). Shure's official page confirms SKU SM81-LC and £439 RRP; its user guide confirms the supplied clip, attenuator lock, bag and windscreen. LC means no XLR cable is supplied. [Manufacturer](https://www.shure.com/en-GB/products/microphones/sm81) · [User guide](https://www.shure.com/en-US/docs/guide/SM81). Imported against the existing SM81 master and read back successfully.

Cumulative Batches 04–13 now contain **235 GBP observations: 231 active (127 UK New, 104 UK Used) and four inactive retained for audit**. Batch 09 now contains 22 active rows (10 UK New, 12 UK Used). UK Used remains excluded from automatic valuation. The valuation function, schema, TEST and Stripe were not changed.


## Cumulative LIVE evidence update — 12 November 2026 (Batch 09 continuation)

One further UK Used observation was resolved and imported:
- Sony HXC-D70 Standard camera channel, N.I. Broadcast Ltd product code 9509, £4,000, stock level 3. Each channel includes HXC-D70 camera head, HXCU-D70 CCU, approx. 25m multicore cable, modified DVF-L700 7-inch Full HD monitor/viewfinder and RM-B150 remote RCP. RCP cable, tripod plate and lenses are optional extras. [Source](https://www.nibroadcast.com/1x-sony-hxc-d70-hdsdi-high-definition-multicore-camera-channel-with-cable-rcp-ccu-etc..html). Imported against the existing HXC-D70 Standard master and read back successfully; UK Used reference-only.

The Sony HDC-3000 exact model remains unresolved after a fresh Sony UK support-catalogue check. Do not substitute HDC-3500, HDC-3200, HSC-300 or CCU prices.

Cumulative Batches 04–13 now contain **236 GBP observations: 232 active (127 UK New, 105 UK Used) and four inactive retained for audit**. Batch 09 now contains 23 active rows (10 UK New, 13 UK Used). UK Used remains excluded from automatic valuation. The valuation function, schema, TEST and Stripe were not changed.


## PowerDolphin Wizard package verification — existing row reactivated — 12 November 2026

The previously inactive £1,449 eBay UK offer was rechecked. The listing identifies the exact PowerVision PowerDolphin Wizard, model PowerDolphin Wizard, MPN PDW10 and EAN 6970820830313; condition New, unopened original retail packaging, Buy It Now, UK business seller in Nottingham, 100% positive feedback. Direct listing: https://www.ebay.co.uk/itm/116741484492. The seller's linked description confirms the Wizard-specific PowerSeeker sonar/fish-finder feature and intelligent fishing function: https://itm.ebaydesc.com/itmdesc/116741484492?category=179697&cspheader=1&descgauge=1&domain=ebay.com&excSoj=1&excTrk=1&ittenable=false&lang=en&lsite=3&oneClk=2&secureDesc=1&seller=hp_seller_number1&t=0&ver=1.

The PowerDolphin Wizard user manual item list independently confirms the Wizard package includes PowerDolphin, intelligent battery, AC adapter, two pairs of blades, AC cable, storage bag, fishing bait container and link, remote controller, Micro USB cable, PowerSeeker and PowerSeeker charging cable: https://www.manualslib.com/manual/1940291/Powervision-Powerdolphin.html. This resolves the package-unverified reason for inactivity. The existing evidence row was reactivated in place; no duplicate was inserted.

Existing row ID 6f11ca53-fcc7-4c39-8f3a-ec2aa2aee09e, master PowerDolphin / Wizard Package (d85ca7a7-e811-427a-a23c-d1abe267536a), source_record_key batch13-powervision-powerdolphin-wizard-ebay-1449. Read-back confirms £1,449 GBP, UK New, new condition, in_stock, active.

Batch 13 now has 47 active rows (29 UK New, 18 UK Used), zero inactive. Cumulative Batches 04–13 now have 240 GBP observations, 237 active (129 UK New, 108 UK Used), three inactive. Used evidence remains reference-only. No master product, schema, valuation logic, TEST or Stripe changes.


## HVR-Z1E misidentified lead matched to existing master — 12 November 2026

The earlier Shopping candidate labelled HXR-V1E was correctly excluded from that model because the item specifics identified HVR-Z1E. Rather than discard the useful evidence, current direct UK sources were researched and matched to the existing LIVE HVR-Z1E / Standard Package master, ID ef1447f4-5967-44f8-abc0-282f2ecb40d3.

Two exact N.I. Broadcast used offers were imported and read back:
- Product code 6946 — £250, stock 1, used; tested recording, playback, audio, zoom and focus; no battery or charger supplied (seller offers them separately for £30); title records 81x10 drum hours. https://www.nibroadcast.com/sony-hvr-z1e-hdv-high-definition-camcorder-81x10-drum-hours.html
- Product code 6944 — £250, stock 1, used; includes battery and charger; tested recording, playback, audio, zoom and focus; title records 23x10 drum hours. https://www.nibroadcast.com/sony-hvr-z1e-hdv-high-definition-camcorder-23x10-drum-hours-battery.html

LIVE evidence IDs: 6c7ed3f9-4679-4e3b-98f4-5dcc0f1f7688 and 340ca15f-8d26-4c17-8fb2-46aaecb72b6d. Both are UK Used GBP reference-only, with accessory differences preserved; no valuation effect.

Batch 13 now has 49 active GBP rows (29 UK New, 20 UK Used), zero inactive. Cumulative Batches 04–13 now have 243 observations, 240 active (130 UK New, 110 UK Used), three inactive. No master/schema/valuation change; TEST and Stripe untouched.


## Sony RM-BR300 exact model redirected from RM-BR300H lead — 12 November 2026

A further UK used source was found for the related RM-BR300 model. N.I. Broadcast direct page confirms exact Sony RM-BR300 PTZ camera remote panel (not RM-BR300H), product code 7389, £499, stock level 2, Used. Imported against the separate existing RM-BR300 / Standard master ID 2c8b889e-6afc-429c-b8e6-a0d96c426764; did not attach it to the RM-BR300H master. Page does not enumerate accessories; recorded as panel-only. UK Used reference only. Source https://www.nibroadcast.com/sony-rm-br300-ptz-camera-remote-panel.html. Evidence row 48d36782-0c1b-42ff-8fd0-938e73779c31; source_record_key batch13-followup-sony-rm-br300-nibroadcast-7389-499-20261112.

Batch 13 now has 50 active rows (29 UK New, 21 UK Used), zero inactive.


## Sony RM-BR300 — exact used remote panel source matched — 12 November 2026

N.I. Broadcast direct page verifies exact Sony RM-BR300 PTZ camera remote panel, product code 7389, £499, stock level 2, condition Used. This is RM-BR300, not RM-BR300H. The page does not enumerate accessories; record as panel-only. Direct source https://www.nibroadcast.com/sony-rm-br300-ptz-camera-remote-panel.html.

The existing LIVE RM-BR300 / Standard master was used (master 2c8b889e-6afc-429c-b8e6-a0d96c426764), not the separate RM-BR300H product. Evidence row 48d36782-0c1b-42ff-8fd0-938e73779c31, source_record_key batch13-followup-sony-rm-br300-nibroadcast-7389-499-20261112. Direct LIVE read-back confirms £499 GBP, used, in_stock, active and exact RM-BR300 master.

Batch 13 now 50 active rows (29 UK New, 21 UK Used), zero inactive. Batches 01–13 now total 263 observations, 259 active (141 UK New, 118 UK Used), four inactive. UK Used remains reference-only. No master/schema/valuation change; TEST and Stripe untouched.


## Duplicate source-capture cleanup — 12 November 2026

A duplicate scan across the batch-keyed evidence found two exact same-source captures in Batch 13. In each case the same existing master, source URL, GBP price, condition and availability were present twice under separate source_record_keys. The earlier captures were preserved but deactivated; the later detailed follow-up rows remain active:
- Wex Photo Video Sony ECM-B10 £175 new: deactivated duplicate row 9d7a7b65-8a2a-4a28-90b7-2a1c64e38564; retained active row f9bb53b9-c1a1-4983-b0bd-77bdb4f6ccba.
- Sony UK FE 12-24mm F2.8 GM £2,645 new: deactivated duplicate row 0c023277-93cd-47bb-8677-4f005693e738; retained active row fa2cbd78-e707-481c-be3f-e46aa3cf18d5.

This is duplicate housekeeping only; no price, master or source observation was deleted. Batch 13 now 50 total, 48 active (27 UK New, 21 UK Used), two inactive duplicates. Batches 01–13 corrected cumulative total: 263 observations, 257 active (139 UK New, 118 UK Used), six inactive. Do not use inactive duplicates in market aggregation. TEST, Stripe, schema and valuation logic untouched.


## Duplicate evidence rows deactivated — 12 November 2026

A fresh LIVE reconciliation identified two duplicate captures in Batch 13 and deactivated the earlier rows while retaining the later follow-up rows and all independent retailer offers:
- Sony FE 12-24mm F2.8 GM, earlier Sony UK row 0c023277-93cd-47bb-8677-4f005693e738 (source_record_key batch13-sony-fe1224gm-sony-2645) deactivated; later exact same Sony UK source row fa2cbd78-e707-481c-be3f-e46aa3cf18d5 remains active. Other active sources (Sony Centre Direct, CameraWorld, LCE) are independent offers.
- Sony ECM-B10, earlier Wex row 9d7a7b65-8a2a-4a28-90b7-2a1c64e38564 (source_record_key batch13-sony-ecmb10-wex-175) deactivated; later exact same Wex source row f9bb53b9-c1a1-4983-b0bd-77bdb4f6ccba remains active. Other active sources (CameraWorld, Harrison, MPB, Bristol and Park) are independent offers.

Both inactive rows remain retained for audit; no active evidence was deleted. Batch 13 now 50 total, 48 active (27 UK New, 21 UK Used), two inactive duplicate captures. The earlier row notes were corrected so each points to its own retained duplicate, not to the other product's source.


## 13 November 2026 — Sony HVR-V1E additional UK used-market price reference

One additional exact HVR-V1E UK Used observation was imported into LIVE against master f2b5f83e-680f-49e5-9729-8aebba707850:
- Colins Cameras — £260.00, Very Good, fully tested and working; includes NP-F960 battery, charger, cables and remote. The direct product result marks the listing Sold out, so availability is recorded as out_of_stock, not in_stock. Evidence ID 20b25a7e-2959-4387-bfcd-cb3e9ca0c577. [Direct source](https://colinscameras.co.uk/products/sony-hvr-v1e)

The search result exposed the exact product, price, condition, package and sold-out status; opening the direct URL returned cache miss. This limitation is recorded for dashboard click-through recheck. Existing Camera City £399 in-stock item remains active; its no-charger and non-original-battery condition is distinct. UK Used remains reference-only. Batch 13 now has 51 total, 49 active (27 UK New, 22 UK Used), two inactive. No master/schema/valuation changes; TEST and Stripe untouched.
