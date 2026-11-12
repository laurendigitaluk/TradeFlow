# TradeFlow LIVE — Scheduled Market-Evidence Research — Batch 05

**Research date:** 12 November 2026  
**Repository / branch:** laurendigitaluk/TradeFlow — production  
**Environment:** TradeFlow LIVE only  
**Status:** Research completed; 20 products recorded below. No candidates were staged to the LIVE research queue because authenticated platform-owner context was unavailable.  
**Purpose:** Preserve all useful market evidence, including sold-out, historical, unverified, near-match and incomplete-price links. Uncertain records are explicitly marked RED VERIFY.

## 1. Selection and exclusion audit

Read before selection:
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-04.md

The latest scheduled research checkpoint was Batch 04. All 102 unique product UUIDs listed across scheduled checkpoint files 02, 03 and 04 were excluded. The selection also excluded all product IDs in the two existing manual AI research prompts (one completed prompt covering 20 IDs and one ready prompt covering 20 IDs), plus every product matched to an outstanding LIVE research-queue candidate.

LIVE queue snapshot at selection:
- imported: 28
- needs_research: 10
- rejected: 43
- pending_review: 0

The ten outstanding queue candidates were Anycubic Kobra S1 (4-Color Combo), Anycubic Kobra 3 Max V2 (Standard Printer and 4-Color Combo variants), Anycubic Kobra 4 (Standard Printer), Bambu Lab A1 (Standard Printer), and Sony PlayStation 5 Digital Edition 825 GB (two candidates). All were excluded.

No fixed SQL OFFSET was used. The next 20 active catalogue master products were selected dynamically with anti-joins against:
1. the 102 checkpoint UUIDs;
2. all manual AI prompt product arrays;
3. outstanding LIVE queue candidates by linked product ID or exact manufacturer/model/package match; and
4. active shared_market_evidence.

Each selected product was rechecked immediately before research. A second recheck after research confirmed every selected product still had 0 active shared_market_evidence rows, 0 matching outstanding queue candidates and 0 outstanding manual AI prompts.

## 2. Owner-auth check and queue-staging limitation

Checked LIVE owner context before any queue write:
- auth.uid(): null
- auth.role(): null
- public.platform_cloud_ai_owner_check(): false

The supported authenticated platform-owner staging context is unavailable. No RPC write was attempted without owner authentication. No direct table insert/update, impersonated claim, service-role workaround or RLS bypass was attempted. No candidates from Batch 05 were staged as pending_review. The findings are preserved here for later authenticated staging.

## 3. Research method

Searched manufacturer pages, UK retailers, used dealers, eBay, Gumtree, specialist marketplaces and Google Shopping/product-feed results. Opened actual product pages wherever the page was accessible, checked variant/package selectors and inspected price, condition and availability. Where a product card or listing URL could not be opened, the URL and displayed price are retained with a RED VERIFY note rather than discarded.

Prices are recorded exactly as displayed. Non-GBP values are not converted. A price for a different model, suffix, variant or package is not assigned to the catalogue product. Where only a complete kit was found for a camera-only master, the exact camera-only GBP price is left blank and the kit price is recorded in notes.

## 4. Product findings

### 1) Casio EX-ZR5100 — Standard Package
**LIVE product ID:** 1f8831cc-a4e7-4f1f-9727-b2de60469701  
**GBP price for exact UK offer:** blank — no exact UK camera listing found.

- Manufacturer specification: [Casio EX-ZR5100 specifications](https://www.casio-intl.com/asia/en/dc/products/ex_zr5100/spec/) — Casio labels this a Past Model. Official bundled accessories are NP-130A rechargeable battery, USB-AC adaptor, neck strap, micro-USB cable, AC power cord and basic reference.
- Exact used listing: [Mercari Japan — Casio EX-ZR5100](https://jp.mercari.com/item/m15583233766) — ¥43,000 including shipping; used, sold. Listing says battery, SD memory card and USB cable included; no box or manual; minor cosmetic mark. Seller listing was over six months old. **No GBP conversion.**
- [Carousell Malaysia — Casio Exilim EX-ZR5100](https://www.carousell.com.my/p/casio-exilim-zr5100-used-1030663864/) — RM1,200; used like-new; reserved; older listing; box, charger and case mentioned. **No GBP conversion.**
- Supporting model/accessory matches only: [eBay NP-130 battery listing compatible with EX-ZR5100](https://www.ebay.co.uk/itm/226823361707) and [eBay NP-130 charger compatible with EX-ZR5100](https://www.ebay.co.uk/itm/183910208811). These are accessories, not camera price evidence.
- **RED VERIFY —** No exact UK camera offer was found. Check UK used-market availability and whether any imported listing is still live. Do not treat accessory prices as camera evidence.

### 2) Insta360 Flow 2 Series — Insta360 Flow 2 Series
**LIVE product ID:** 2038e2fa-0e43-4d5b-92c5-91964315461e  
**GBP price for the generic series master:** blank until the exact edition and bundle are selected.

- [Insta360 UK official Flow 2 Series page](https://store.insta360.com/gb/product/flow-2-pro) — Flow 2 Pro Standard Bundle £144.99; Action Bundle £205; AI Tracker Bundle £169.99; Creator Bundle £169.99. The Pro Standard Bundle contents are Flow 2 Pro, magnetic phone clamp, USB-C-to-USB-A charge cable and protective pouch. The page's edition selector distinguishes Flow 2 Pro from Flow 2.
- [CameraWorld — Flow 2 AI Tracker Bundle, Stone Grey](https://www.cameraworld.co.uk/insta360-flow-2-ai-tracker-bundle-stone-grey.html) — £119.00 on the opened product page; In Stock; free UK delivery; two-year guarantee. An earlier search snippet showed £114, so use the opened page's £119 and retain the earlier snippet as a price discrepancy.
- [Jessops — Flow 2 Plus Bundle in Grey](https://www.jessops.com/p/insta360/flow-2-plus-bundle-in-grey-216765) — £119.00. Box contents: Flow 2, AI Tracker, magnetic phone clamp, USB-C-to-USB-A charge cable and protective pouch. Store stock must be checked.
- [NetworkDistri — Flow 2 Standard Bundle, SKU CINSABQA](https://www.networkdistri.co.uk/product/insta360-flow-2-standard-bundle-gray-e576) — opened page £109 ex VAT / £130.80 inc VAT; In Stock. Earlier search snippet showed £149.41 inc VAT, so price has varied between crawls.
- [Park Cameras — Flow 2 AI Tracker Bundle](https://www.parkcameras.live/shop/insta360-flow-2-ai-tracker-bundle-stone-grey_9020132t) — search result £119.99; page opened but price was not exposed in page text.
- Google Shopping lead: [Amazon Flow 2 AI Tracker Bundle, White](https://www.amazon.co.uk/Insta360-Tracker-Bundle-White-Built/dp/B0F6CBMRBH?source=ps-sl-shoppingads-lpcontext&ref_=fplfs&psc=1&smid=A322DB6VYJFA77) — product card displayed £79.00; Amazon marketplace seller; direct product page was not accessible to the browser tool.
- **RED VERIFY —** The catalogue model is a generic Flow 2 Series master. The sources represent Flow 2, Flow 2 Pro and different bundles. The £79 Amazon Shopping card is unusually low and its product page could not be opened. Gary should verify edition, bundle contents, seller and checkout price before assigning a single price.

### 3) Yuneec Typhoon Q500+ — Typhoon Q500+ 4K
**LIVE product ID:** 20681866-47b8-429b-aef6-342c4ff61e78

- Exact historical used listing: [eBay UK — Yuneec Typhoon Q500+ 4K drone](https://www.ebay.co.uk/itm/286105864153) — £500 item price; £13.92 buyer-protection fee; £513.92 displayed total. Used, private seller, 100% positive, sold 28 September 2026. Postage shown as £5.88.
- Near-model current listing: [eBay UK — Yuneec Typhoon Q500 4K complete bundle](https://www.ebay.co.uk/itm/287554143399) — £181.42; used; private seller in Liverpool; model is Q500 without the plus suffix.
- Near-model current listing: [Gumtree — Yuneec Typhoon Q500 4K with camera](https://www.gumtree.com/p/drones/uuneec-typhoon-q500-drone-with-4k-camera./1803746342) — £250; used, good condition; Ely, Cambridgeshire; includes 4K camera/gimbal, handheld gimbal, backpack and replacement batteries; seller says test flown.
- Similar cross-post/near-model listing: [Gumtree — Yuneec Typhoon drone](https://www.gumtree.com/p/drones/yuneec-typhoon-drone/1804442372) — £175; Q500 4K without plus suffix; used, good condition; similar bundle description.
- [eBay UK — Yuneec Typhoon Q500 4K GPS Drone Professional Kit](https://www.ebay.co.uk/itm/236798963890) — £350; used; seller in Falkirk; Q500 without plus suffix.
- **RED VERIFY —** The £500 item/£513.92 displayed total is an exact Q500+ historical sale. The lower current Q500 listings are not the plus model and must remain comparison-only. Confirm the exact Q500+ bundle contents if using the historical price.

### 4) Sony UWP-D22 — UWP-D22 Wireless Microphone System
**LIVE product ID:** 21fd7701-aa4e-4e2f-a67e-0657dae50cd9

- [Sony UK — UWP-D22 package](https://www.sony.co.uk/store/product/uwp-d22.all/UWP-Package) — official page out of stock; describes UTX-M40 handheld microphone, URX-P40 receiver and accessories.
- [Wex — Sony UWP-D22/K33 Wireless Kit](https://www.wexphotovideo.com/sony-uwp-d22k33-wireless-kit-3038409/) — £645.00; Special Order.
- [Canford — Sony UWP-D22/K33](https://www.canford.co.uk/Products/2022416/74-6539_SONY-UWP-D22-RADIOMIC-SYSTEM-Handheld-portable-receiver-CH33-41-K33) — £543.00 ex VAT; ordered on demand, available in 1–2 months.
- [ProAV — Sony UWP-D22/K33 Wireless Mic Package](https://proav.co.uk/sony-uwp-d22-k33-wireless-mic-package) — £474.00 inc VAT / £395.00 ex VAT; page says Availability: In stock but also says backorder, delivery when in stock usually within 10 working days.
- [CVP — Sony UWP-D22/K33 Wireless Microphone Pack](https://cvp.com/product/sony-uwp-d22-k33-wireless-microphone-pack) — package contents include UTX-M40 handheld microphone and URX-P40 portable receiver; page text confirms package but did not expose a stable current price in the opened page.
- **RED VERIFY —** UK price references are for the K33 frequency-band package, while the master is generic UWP-D22. Verify the frequency band/package before treating the price as an exact match. ProAV stock status is contradictory; Wex is special order and Canford is on demand.

### 5) Sony HDC-1700 — Standard
**LIVE product ID:** 2288bc72-5e68-433b-813d-10b4f26efb2d

- [Visuals — Sony HDC-1700 with Camera Control Unit, Used](https://www.visuals.co.uk/sony-hdc-1700-w-camera-control-unit-used-1.html) — £9,600 inc VAT / £8,000 ex VAT; was £14,400; 1 in stock. SKU HDC-1700//U. Listing is used and includes the HDC-1700 camera with camera control unit; product details indicate 18,995 hours.
- **RED VERIFY —** Exact camera model match, but the retailer package includes a camera control unit whereas the master package is Standard. Do not treat this as an exact standard-body package price without checking whether the CCU is included in the catalogue package.

### 6) Nikon D5000 — Nikon D5000
**LIVE product ID:** 248de94f-60c1-47f4-90b6-f988548d5217

- [Harrison Cameras — Used Nikon D5000 DSLR Camera Body](https://harrisoncameras.co.uk/products/used-nikon-d5000-dslr-camera-body-used-7448800) — search result £55.00; used Good; shutter count 13,450; box, charger, strap, battery and instructions; 12-month warranty and free UK delivery. Direct page returned 404 when opened. **RED VERIFY —** retain the price and link, but check whether the listing has been removed.
- [LCE Oxford — Nikon D5000 Body](https://www.lcegroup.co.uk/Used/Nikon-D5000-Body_501475.html) — £79.99; average condition; in store; works perfectly; dust and scuffs; no box/front cap; 6-month guarantee.
- [LCE Hereford — Nikon D5000 Body](https://www.lcegroup.co.uk/Used/Nikon-D5000-Body_499895.html) — £69.99; good condition; in store; body cap, strap, battery and Canon mains charger; 6-month warranty.
- [LCE Southampton — Nikon D5000 Body, 57,283 shutter actuations](https://www.lcegroup.co.uk/Used/Nikon-5000D-Body-%2857283-Shutter-Actuations%29-_467677.html) — £49.99; average condition; in store; rear LCD glass cracked though screen still works; battery, charger and strap; 3-month warranty.
- [Buy Any Tech — Nikon D5000 DSLR Body Only](https://buyanytech.co.uk/product/nikon-d5000-dslr-camera-body-only-2994-3485/) — £93.99; used Good; shutter count 2,352; no accessories unless stated; older crawl, verify live stock.
- [eBay UK — Nikon D5000 body only, selling as-is](https://www.ebay.co.uk/itm/236070990996) — £85.33; used, body only, seller in Niigata, Japan; 13,388 shutter count; postage £37.16; seller notes cosmetic marks and screen yellowing.
- **RED VERIFY —** The price spread reflects different shutter counts, condition and accessories. The Harrison £55 page now returns 404; the Japanese eBay item is explicitly as-is and overseas. Do not collapse these into one condition-free price.

### 7) Nikon 1 S2 — Nikon 1 S2 Camera
**LIVE product ID:** 24e8c2f9-eca7-41e2-8996-40e48fa3f064

- [MPB UK — Used Nikon 1 S2](https://www.mpb.com/en-uk/product/nikon-1-s2) — 1 available at £73; Good condition; SKU 4242379; front body cap, Nikon AN-N1000 strap, EN-EL22 battery and MH-29 charger; 12-month warranty. No lens is listed in the included accessories.
- Google Shopping product card: [MPB Nikon 1 S2 Compact System Camera with 11–27.5mm Lens](https://www.mpb.com/en-uk/product/nikon-1-s2/sku-4242379) — product card showed £78.95 and title described a lens kit; this conflicts with the current MPB model page at £73 and its body-only accessory list.
- Google Shopping eBay lead: [Nikon 1 S2 red kit](https://www.ebay.co.uk/itm/366476053340?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item) — product card £216.07; product page did not open; exact package and seller require checking.
- **RED VERIFY —** The current MPB model page supports £73 for a Good body with accessories, but a Shopping card associates the same SKU with an 11–27.5mm lens and £78.95. Check the exact SKU/package before assigning the kit price.

### 8) Olympus PEN E-PL1s — Standard
**LIVE product ID:** 268f9e67-6c24-4374-844d-1dfc7bc67bf7

- [MPB UK — Olympus PEN E-PL1s](https://www.mpb.com/en-uk/product/olympus-pen-e-pl1s) — out of stock; no current price. Page timed out when opened.
- [eBay UK — Olympus PEN E-PL1s Body with Extra Case and Filter Set](https://www.ebay.co.uk/itm/168758155567) — £117.10; used; business seller Takeuchi Camera, Osaka, Japan; page now shows out of stock.
- [eBay UK — Olympus PEN E-PL1s White Body with Battery and Charger](https://www.ebay.co.uk/itm/187559347291) — search result £99.28; used; seller in Japan; page returned 404 when opened.
- eBay search results also surfaced E-PL1s lens-kit listings around £110.87 and £203.95, but the listings are Japan-based and package contents differ. General search page: [eBay Olympus E-PL1 listings](https://www.ebay.co.uk/b/bn_7023592423).
- **RED VERIFY —** Exact E-PL1s offers are overseas and one is out of stock; confirm import/shipping and whether the package is body-only or includes a lens. Do not substitute the original E-PL1 model for the E-PL1s.

### 9) Sony HXC-100K — Standard
**LIVE product ID:** 26be6789-9baf-493a-9de3-192258d04896  
**GBP price for exact HXC-100K:** blank — exact suffix listing not found.

- [Sony official HXC-100 product page](https://www.sony.jp/system-camera/products/HXC-100/) — HXC-100 (without K suffix), marked discontinued; Japanese suggested retail price ¥2,530,000 including tax; lens and viewfinder sold separately. **No currency conversion.**
- [KitPlus — Used Sony HXC-100 system camera](https://kitplus.com/for-sale/studio-40/sony/hxc-100/30704) — £9,495; used; ES Broadcast Ltd, verified UK premium dealer; listing published 7 February 2024. This is HXC-100, not HXC-100K.
- **RED VERIFY —** Exact HXC-100K package/suffix not found. The £9,495 HXC-100 is a close model-family reference only; do not assign its price to HXC-100K until the K suffix/package is matched.

### 10) Skydio X10D Propellers — X10D Propellers
**LIVE product ID:** 2a8fd8f9-7254-4a02-b7b1-ebf70a18c8d0  
**GBP price for exact X10D propellers:** blank — no exact listing found.

- [Skydio official propellers page](https://shop.skydio.com/collections/essential-accessories/products/skydio-2-propellers) — USD $29; available; set includes two blue clockwise and two grey counter-clockwise propellers; explicitly for Skydio 2 and 2+, not X10D. **Do not convert USD to GBP and do not match this price to X10D.**
- [Skydio X10 Restore service](https://www.skydio.com/legal/resupply-services-and-restore) — describes X10 repair/replacement service, not a propeller product or propeller price.
- **RED VERIFY —** No exact X10D propeller product URL or UK GBP price was found. Verify the X10D part number and compatibility with Skydio before using any propeller listing.

### 11) Walkera Runner 250 — Standard Package
**LIVE product ID:** 2abd478f-a522-4f17-b5d7-ae83e4503d74

- [Easy Live Auction — Walkera Runner 250 with Devention controller and fitted case](https://www.easyliveauction.com/catalogue/lot/b23df09af14cb09e2ae628426d512c68/0af8d24542e81eb9357e7ef448a6646f/general-auction-tuesday-1st-september-lot-186/) — £45 hammer; auction closed 1 September 2026; fees additional; exact drone model, controller and fitted case.
- Google Shopping/eBay product card: [Walkera Runner 250 FPV Racing Quadcopter with Devo 7 transmitter and camera](https://www.ebay.co.uk/itm/307274443750?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item) — product card £195.00; direct product page could not be opened. **RED VERIFY —** check listing is live, exact model, seller, condition and complete package.
- Spare parts only: [Runner 250 advance guard](https://www.ebay.co.uk/itm/166731503174) £4.95 new, 5 available; [TX5817 transmitter spare](https://www.ebay.co.uk/itm/166731464291) £24.95 new, 2 available; [battery fixed plate](https://www.ebay.co.uk/itm/267809193540) £13.05 new. These are not drone prices.
- **RED VERIFY —** The £45 exact drone is a closed auction. The £195 Shopping card is a useful lead but the page could not be verified. Spare-part prices must not be used as a drone valuation.

### 12) RØDE Wireless GO (3rd Gen) — Standard Item
**LIVE product ID:** 2c73d311-c15f-48c1-afa0-615dee60a8cc

- [RØDE UK official Wireless GO Gen 3](https://rode.com/en-gb/products/wireless-go-gen-3) — £179.99, tax included; in stock in black, blue, green, orange, purple, red and white; pink out of stock. Dual-channel compact wireless system.
- [The Disc DJ Store — Wireless GO Gen 3](https://www.thediscdjstore.com/products/rode-wireless-go-gen-3) — £179.00; brand new; only 1 available; free delivery; five-year warranty after registration.
- [Canford — Wireless GO Gen 3, pink](https://www.canford.co.uk/Products/2028299/74-290_RODE-WIRELESS-GO-GEN-3-RADIOMIC-SYSTEM-Dual-transmitters-2.4GHz-32-bit-float-recording-pink) — £149.90 ex VAT; ordered on demand, 3–5 working days; pink colour.
- [Argos — RØDE GO Gen 3](https://www.argos.co.uk/product/7726033) — £179.99; postcode stock check required.
- Google Shopping/eBay lead: [Wireless GO Gen 3 dual wireless system](https://www.ebay.co.uk/itm/287558210567?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item) — product card £158.50; direct page could not be opened. **RED VERIFY —** confirm condition, seller, package and current price.
- Google Shopping/Amazon lead: [Wireless GO Gen 3 with Keepdrum microfibre cloth](https://www.amazon.co.uk/Wireless-2-Channel-Microphone-Keepdrum-Microfibre-black/dp/B0DQ1Y5WHR?source=ps-sl-shoppingads-lpcontext&ref_=fplfs&psc=1&smid=A2O23RCY4WQI1I) — product card £191.32; bundle includes a microfibre cloth; seller/stock should be checked.
- **RED VERIFY —** Shopping card £158.50 is below official pricing and the direct page could not be opened. The Amazon result is an accessory bundle, not a bare standard kit. Use official £179.99 as the strongest current new UK reference.

### 13) AJA PAK Dock Pro — AJA PAK Dock Pro
**LIVE product ID:** 2cd63711-f718-4f0a-9776-63d87d3a335c

- [ProAV — AJA PAK Dock Pro](https://proav.co.uk/aja-pak-dock-pro) — £238.80 inc VAT / £199.00 ex VAT. Page says Availability: In stock, but also displays a backorder message with delivery when in stock, usually within 7 working days.
- [CVP — AJA PAK Dock Pro](https://cvp.com/product/aja-pak-dock-pro) — Google Shopping product result £238.80.
- Google Shopping also surfaced 3D Broadcast Sales at £241.10; direct product URL was not retrieved in the result.
- **RED VERIFY —** Product identity and price are clear, but ProAV's stock status conflicts with its backorder wording. Confirm stock/dispatch with the retailer.

### 14) Sony HXR-NX30 — Standard
**LIVE product ID:** 2db58348-c226-436e-91f2-fd97921f585e

- [eBay UK — Sony HXR-NX30E with 96GB memory](https://www.ebay.co.uk/itm/820268943591) — current search result £249.99 or Best Offer; used; business seller Smart_With_Media, 100% positive; seller location St Neots, UK; £55.99 shipping; listing also displays import-fee wording. The opened page did not expose the current price.
- Google Shopping product card for the same eBay item displayed £239.99; product page open failed. **RED VERIFY —** price discrepancy £239.99 vs £249.99 and unusual shipping/import-fee wording.
- [eBay UK — HXR-NX30E with projector and XLR module, sold](https://www.ebay.co.uk/itm/406620245283) — £300; used, fully functional, excellent condition; MAP Photo business seller, 99.9% positive, Brentford UK; includes projector and XLR module; sold 10 August.
- **RED VERIFY —** Listings are the E-suffix regional variant and include 96GB memory or projector/XLR extras. Check exact suffix/package against the standard HXR-NX30 master before treating the prices as exact.

### 15) Sony FE 24-70mm F2.8 GM II — Standard
**LIVE product ID:** 3002ffef-5df4-4697-b832-35991c275351

- [Park Cameras — Sony FE 24-70mm F2.8 GM II](https://www.parkcameras.live/shop/sony-fe-24-70mm-f28-gm-ii-lens_7240742g) — £1,699; £100 cashback available after purchase, making £1,599 after claim.
- [Wex — Sony FE 24-70mm F2.8 GM II](https://www.wexphotovideo.com/sony-fe-24-70mm-f2-8-g-master-ii-lens-3045543/) — current page £1,699 before £100 cashback / £1,599 after cashback; In Stock.
- [LCE — Sony FE 24-70mm F2.8 G Master II](https://www.lcegroup.co.uk/New/Sony-FE-24-70mm-F2.8-G-Master-II-Lens_112977.html) — £1,699 today; £1,599 after £100 cashback; in stock for free delivery.
- [CameraWorld — Sony FE 24-70mm F2.8 GM II](https://www.cameraworld.co.uk/sony-24-70mm-f2-8-gm-ii-fe-zoom-lens.html) — £1,813; in stock, dispatch in 3–5 days.
- [Jessops — Sony FE 24-70mm F2.8 GM II](https://www.jessops.com/p/sony/fe-24-70mm-f2-8-gm-ii-lens-200178) — £1,899.
- **RED VERIFY —** Some Google Shopping/product-feed results returned the first-generation FE 24-70mm F2.8 GM (SEL2470GM), not the GM II. Those first-generation prices were excluded. Confirm II/SEL2470GM2 suffix when matching.

### 16) Z CAM ZOLAR Vega 30C — ZOLAR Vega 30C RGBAW LED Light Panel
**LIVE product ID:** 300415f7-5866-4546-b3ad-43523ab8145a

- [ProAV — ZOLAR Vega 30C 5-colour LED Light Panel](https://proav.co.uk/zolar-vega-30c-5-color-led-light-panel) — £750 inc VAT / £625 ex VAT; SKU V03202. Page says Availability: In stock, but also says backorder available and delivery when in stock, typically within 5 weeks.
- **RED VERIFY —** Exact model/price found, but the retailer's stock label conflicts with its backorder notice. Confirm actual dispatch timing.

### 17) CaddxFPV Walksnail Avatar HD Mini 1s Lite Camera — Walksnail Avatar HD Mini 1s Lite Camera
**LIVE product ID:** 31e7b9ff-d653-4b2d-aeb9-2bb933033cf4  
**GBP price for camera-only item:** blank — all priced sources are complete VTX + camera kits.

- [Unmanned Tech — Walksnail Avatar HD Mini 1s Lite Kit (VTX + Camera)](https://www.unmannedtechshop.co.uk/products/walksnail-avatar-hd-mini-1s-lite-kit-vtx-camera) — £89.98 GBP; sold out; SKU WN05-1005B.
- [Flying Tech — Walksnail Avatar Mini 1S Lite HD FPV Kit (VTX + Camera)](https://www.flyingtech.co.uk/product/walksnail-avatar-mini-1s-lite-hd-fpv-kit-vtx-camera/) — £89.99 inc VAT; only 2 left in stock; SKU/package is the complete VTX + camera kit.
- [Drone Authority — Walksnail Avatar HD Mini 1s Lite Kit](https://www.droneauthority.co.uk/products/walksnail-avatar-hd-mini-1s-lite-kit) — £89.00 inc VAT; in stock; SKU WN05-1005B; complete kit.
- **RED VERIFY —** Catalogue master says Camera, while all three product pages are the complete VTX + camera kit. Keep the links and kit prices in notes, but leave the camera-only GBP price blank until a camera-only offer is found or the package match is confirmed.

### 18) Sony SRG-300H — Standard Package
**LIVE product ID:** 323e8f7e-1a8b-4d7e-87f6-28de0cf0d0e0

- [eBay UK — Sony SRG-300H HD PTZ Camera](https://www.ebay.co.uk/itm/206392614810) — £491.20 displayed total, including £16.20 buyer-protection fee (base item price £475); used; private seller bargain-buys247, 100% positive; £7.27 postage; 2–3 day delivery. Page opened but price was only exposed in the search result.
- [eBay UK — Sony SRG-300H HD PTZ Camera](https://www.ebay.co.uk/itm/266971897618) — £567.70; used; private seller in Tilbury, UK; 100% positive; £5.88 postage; no returns accepted. Page opened but price was only exposed in the search result.
- [eBay UK — Sony SRG-300H HD Color Video Camera](https://www.ebay.co.uk/itm/267372593811) — AU $650, seller in Australia; not a UK GBP offer, no conversion.
- **RED VERIFY —** Both UK eBay prices are useful used references, but the opened page text did not expose the price. Verify current live status, included PSU/cables and seller location/returns before relying on either.

### 19) Nikon Nikkor-H Auto 50mm f/2 — Standard
**LIVE product ID:** 33dc29a5-ed39-4118-bd0a-df3b7c75936a

- [PPP Cameras — Nikkor-H Auto 50mm f/2](https://ppprepairs.squarespace.com/lenses/p/nikkor-h-50mm-f2) — £60; certified pre-owned; Good used condition; add-to-cart page.
- [eBay UK — Nikkor-H Auto 50mm f/2 Pre-AI](https://www.ebay.co.uk/itm/178553684134) — £71.05; used, described as excellent; private seller in UK, 100% positive.
- [LCE — Nikon 50mm f/2 Nikkor-H Pre-AI](https://www.lcegroup.co.uk/Used/Nikon-50mm-f2-Nikkor-H-%5BPre-AI%5D-%5B4%5D-%7C-10118947_489332.html) — search result £69.99; used Good; in store. Direct link redirected to the general Nikon secondhand search page.
- [UsedLens — Nikkor-H Auto 50mm f/2 price guide](https://usedlens.co.uk/product/nikon-nikkor-h-auto-50mm-f-2) — 13 listings from 3 retailers; low £53, typical £68, high £105; aggregated asking-price range, not a single offer.
- [eBay UK — Nikkor-H Auto 50mm f/2 sold listing](https://www.ebay.co.uk/itm/227417681422) — £80 used, excellent, sold.
- [Soper Photographic — Nikkor-H.C 50mm f/2 Non-AI](https://www.soperphotographic.co.uk/ourshop/prod_8383534-Nikon-Nikkor-HC-50mm-f2-Non-Ai.html) — £59 sold; H.C version, near-match only.
- **RED VERIFY —** LCE's item link redirects and UsedLens is an aggregator. The H.C listing is a different lens variant; do not merge its price with the Nikkor-H Auto without checking exact version.

### 20) Sony HVR-Z7E — Standard Package
**LIVE product ID:** 34cecfb5-9fbc-404c-b003-6c2f52f4898d

- [Cash Converters — Sony HVR-Z7E 1080i camcorder](https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/video-cameras/video-camera/049300176362) — £249.99; used; page offers add to cart, 12-month warranty; Consett store pickup available; postage 3–8 days at £9.99.
- [eBay UK — Sony HVR-Z7E Digital Camcorder](https://www.ebay.co.uk/itm/306495052132) — £603.48 or Best Offer; used, described Excellent; business seller digibcltd, 100% positive, seller location Chessington UK; £150 postage and import-fee wording due item origin/customs.
- **RED VERIFY —** The eBay seller is UK-based but the listing shows substantial shipping and import-fee wording. Check actual dispatch origin and landed price. Cash Converters is the clearer current UK retail reference.

## 5. Google Shopping/product-feed click-through notes

Product-feed/Shopping results were searched for all 20 products. Useful product cards included:
- Insta360 Flow 2 AI Tracker Bundle — Amazon £79.00; direct Amazon page could not be opened. Retained above as RED VERIFY.
- Walkera Runner 250 FPV Racing Quadcopter — eBay £195.00; direct eBay page could not be opened. Retained above as RED VERIFY.
- RØDE Wireless GO Gen 3 — eBay £158.50 and Amazon £191.32; eBay page could not be opened; Amazon listing includes a microfibre cloth. Retained above as RED VERIFY.
- AJA PAK Dock Pro — CVP £238.80; product result also surfaced 3D Broadcast Sales £241.10. CVP product URL retained above.
- Sony HXR-NX30E — eBay £239.99 product card, while the eBay search result for the same item showed £249.99. Retained above as RED VERIFY.
- Nikon 1 S2 — MPB product card £78.95 titled with 11–27.5mm lens; current MPB model page shows £73 body/accessories. Retained above as a package/price discrepancy.
- Other Shopping results were rejected as non-matches, not discarded silently: Casio EX-ZR3100/EX-ZR1000 instead of EX-ZR5100; first-generation Sony FE 24-70 GM instead of GM II; Olympus E-PM1/E-PL1 instead of E-PL1s; Yuneec CGO3 camera accessory or Q500 without plus instead of Q500+; Sony HDCU-1700 CCU rather than HDC-1700 camera. No prices from these mismatches were assigned.

## 6. Queue status and next-run instructions

No Batch 05 research candidates were staged in platform_catalogue_research_queue because auth.uid() was null and platform_cloud_ai_owner_check() returned false. No direct table writes or RLS bypass were attempted. All 20 products remain research-only; no master products, schema, valuation logic, TEST or Stripe data were changed.

For the next scheduled run:
1. Read this Batch 05 checkpoint and PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-05.md first.
2. Exclude all 20 product IDs listed in this checkpoint, plus all product IDs in scheduled checkpoints 02–04.
3. Exclude products covered by outstanding LIVE queue candidates and outstanding manual AI research prompts; re-read both sources because their status may change.
4. Select the next 20 active LIVE master products with no active shared_market_evidence using dynamic anti-joins, never a fixed OFFSET.
5. Recheck each selected ID's active evidence, queue-candidate match and prompt coverage immediately before researching.
6. Continue the permissive evidence-capture policy: keep useful URLs even when sold out, unverified, missing price or near-match; prefix uncertainty with RED VERIFY; do not invent or convert non-GBP prices.
7. Check auth.uid() and platform_cloud_ai_owner_check() before queue staging. Use only the supported authenticated platform-owner RPC. If auth.uid() is null or owner check fails, do not write directly; create the next checkpoint and matching project-memory file.
8. Do not touch TEST, Stripe, master products, schema or valuation logic.
