# Scheduled market-evidence research — batch 06

**Date:** 2026-11-12  
**Repository:** laurendigitaluk/TradeFlow  
**Branch:** production  
**Environment:** TradeFlow LIVE only  
**Scope:** 20 existing active catalogue master products; no master-product, schema, valuation or tenant changes.

## Selection and exclusion audit

Read the production-branch scheduled research records before selecting products:

- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md`
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md`
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-04.md`
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-05.md`

The batch-03 checkpoint exists, but its corresponding PROJECT-MEMORY file was not present on production. Also inspected the related camera-catalogue evidence checkpoints 01–07 and available project-memory records 05–07 to avoid overlap with the separate camera evidence work.

Exclusions applied:

- **122 unique product UUIDs** extracted from scheduled-market-evidence checkpoints 02–05. Batch 02 also records the preceding batch-01 exclusions.
- All product UUIDs covered by manual AI research prompts were excluded to prevent overlap, including the completed prompt (20 product IDs) and the outstanding ready prompt (20 product IDs).
- All 10 current `needs_research` LIVE research-queue candidates were excluded. Queue status counts at selection: 28 imported, 10 needs_research, 43 rejected; no pending_review rows.
- Previously covered Blackmagic Design, Aaton, Pentax and AJA camera-checkpoint products were excluded by manufacturer/model where those camera checkpoint records did not contain UUIDs.
- The query used no fixed SQL OFFSET. It selected the next 20 active catalogue master products with no active `shared_market_evidence`, excluding the checkpoint IDs, manual prompt IDs and outstanding queue candidates.
- The selected 20 were rechecked immediately before research. Every selected ID had 0 active evidence, 0 outstanding queue candidates and 0 outstanding manual prompts. A second recheck after research returned the same result for all 20.

## Owner authentication and staging result

Checked LIVE owner-auth context before any queue write:

- `current_user = postgres`
- `auth.uid() = null`
- `auth.role() = null`
- `platform_cloud_ai_owner_check() = false`

Therefore **no candidate was written to `platform_catalogue_research_queue`**. No direct table write, impersonated claim, RLS bypass or other write path was used. The 20 research records below are preserved here for subsequent authenticated staging.

## Research method and price rules

Searched manufacturer pages, UK retailers, marketplaces and Google Shopping/product-search results. Opened actual product pages and inspected package names, selected variants, displayed price/currency, condition and availability where the pages exposed them. Search/Shopping cards were treated as leads only; the target product page was opened where possible.

- Research observation date: **2026-11-12**.
- Never convert non-GBP prices to GBP. If the source displayed USD/EUR/another currency, GBP price is left blank and the source amount is recorded in notes.
- Sold-out, backorder, expired and unverified listings are retained as evidence with availability/condition notes.
- Similar-but-not-exact models, mounts, rear optics, bundles and accessory variants are not treated as exact matches. They are retained as **RED VERIFY** leads with the mismatch stated.
- Rental rates are clearly labelled as rental evidence and are not sale prices.
- Do not import uncertain prices into automatic valuation.

---

## 1. Angenieux EZ-1 45-135mm T3 PL

**Master product ID:** `5f1516fd-71cb-4977-9e0b-840a61538e46`  
**Package:** EZ-1 45-135mm T3 PL

Evidence and links:

1. [KitPlus — Angenieux EZ-1 45-135mm T3 PL](https://kitplus.com/for-sale/lenses-36/angenieux/ez-1/28193) — **£9,000.00** historical asking price; used; listing published 6 June 2023 and now expired. The model/focal range/mount match. Retain as historical used-price evidence, not a current offer.
2. [CVP Angenieux used catalogue](https://cvp.com/catalogue/show/used/manufacturer/angenieux) — exact Used Angenieux EZ-1 45-135mm T3 PL product is listed, but the page directs the customer to contact CVP for price/availability; no GBP price visible.
3. [Shoot Blue EZ-1 hire listing](https://shootblue.tv/products/angenieux-type-ez-1-45-135mm-t3-zoom-lens/) — £295 daily hire rate (the page also shows £354); rental only, not a sale price. Full-frame 45-135mm T3 configuration identified.
4. [FOMO Rentals EZ-1 FF 45-135mm T3](https://www.fomorentals.co.uk/equipment/angenieux-ez-1-ff-45-135mm-t3-zoom-lens) — £250/day ex VAT; rental only. Full-frame rear group and PL mount identified.

**RED VERIFY:** Current UK sale price is not visible. Check CVP's current used unit and whether the expired KitPlus £9,000 asking price remains a useful historical comparator. Do not use rental rates as sale evidence.

## 2. Angenieux EZ-2 22-60mm T3 PL

**Master product ID:** `f57be330-e51b-4d3f-accc-970c5b8b4ce7`  
**Package:** EZ-2 22-60mm T3 PL

Evidence and links:

1. [CVP used EZ-2 22-60mm T3 PL — UK listing](https://cvp.com/product/used-angenieux_ez-2_ff_vistavision/used-angenieux_ez-2_ff_vistavision-430426) — **£9,500.00 ex VAT**; used, Like New; in stock for immediate delivery. The opened page's box contents show the EZ2 Pack (S35 + FF), front/rear caps, S35 rear optics, iris scale/red cosmetic ring, support stubs and shim set.
2. [CVP used Angenieux catalogue — French/EU view](https://cvp.com/fr/catalogue/show/used/manufacturer/angenieux) — same EZ-2 22-60mm T3 PL family displayed at **€11,240.98 ex VAT** and described as in stock in the UK for 1–2 day delivery. This is EUR, not GBP; do not convert it. It may be a separate unit/listing from the UK £9,500 record.

**RED VERIFY:** Confirm whether the catalogue package being valued expects both rear optics or a single configured rear group. Keep the two CVP currency/listing observations separate.

## 3. Aputure LS 600d Pro

**Master product ID:** `861653f3-18da-4f63-8177-4d4714dbc67f`  
**Package:** Aputure Light Storm LS 600d Pro

Evidence and links:

1. [CVP used LS 600D Pro — exact product page](https://cvp.com/product/used-aputure-ls-600d-light/used-aputure-ls-600d-light-460526) — **£1,000.00 ex VAT**; page says the unit is currently **Coming Soon**, condition **Awaiting Grading**, not currently available for immediate purchase. Product details identify the 600W LS 600D Pro, P/N 6971842181292. The box contents on the coming-soon record are currently only described as one used LS 600D Pro light; full accessory contents need confirmation.
2. [eBay UK — Aputure LS 600D Pro 600W](https://www.ebay.co.uk/itm/127463990329) — **£1,225.58**; used; private seller, 100% positive; seller location Edinburgh, UK; no returns accepted; listing last updated 25 July 2026. Exact Pro model confirmed in title and item specifics.
3. [Grelly UK / eBay listing — Aputure LS 600d Pro Daylight Kit](https://www.grelly.uk/itm/aputure-ls-600d-pro-daylight-kit-local-pick-up-demo-extra-gear-20-off-227484467233) — displayed **£849.41**, seller shown in Birmingham, UK, collection only; used kit described as including lamp head, rolling/padded case and F10 Fresnel. The aggregator page could not be opened (403), so seller/listing/package must be checked directly before relying on it.
4. [eBay UK — Aputure LS 600d Pro Monolight](https://www.ebay.co.uk/itm/286844430488) — **£899.00 or Best Offer**; used; seller in Prague 9, Czech Republic. Overseas seller; verify delivery and exact accessories.

**RED VERIFY:** CVP's £1,000 ex VAT is a coming-soon/awaiting-grading record, not current stock. Check availability and package contents. Check the Birmingham £849.41 listing directly; it is collection-only and includes a particular accessory set. Do not confuse LS 600d Pro with the non-Pro LS 600D or LS 600X Pro.

## 4. Autel Robotics EVO Lite 6K Enterprise — Plus Bundle

**Master product ID:** `decba5bd-39f5-465e-9c1c-c1a51f5c8fb1`  
**Package:** EVO Lite 6K Enterprise Plus Bundle

Evidence and links:

1. [Autel Robotics official store — EVO Lite 6K Enterprise](https://shop.autelrobotics.com/collections/valentine-day-flash-sale/products/evo-lite-copy) — manufacturer page displays **$1,579.00 USD** with Basic Bundle selected and selectors for Basic, Plus and Premium. The page did not expose a separate price after selecting Plus in the static page content. Do not assign the Basic price to the Plus package.
2. [OBDPrice — Autel EVO Lite 6K Enterprise Plus Combo](https://www.obdprice.com/products/autel-evo-lite-6k-enterprise-plus-combo) — **$2,059.00 USD**; page says in stock/ships within 24 hours and lists free ND filter and landing pad. The product page's shipping text says ships from New Jersey or California, while a separate shipping-location table lists United Kingdom / Leicestershire, UK / 5–7 days. Currency is USD; do not convert.

**RED VERIFY:** Exact Plus bundle contents and actual UK dispatch origin are unclear. Confirm seller identity, whether the UK warehouse option applies to this SKU and whether the $2,059 price is checkout-valid for UK delivery. GBP price remains blank.

## 5. AVerMedia Live Gamer ULTRA 2.1

**Master product ID:** `bda698b1-3c34-4297-a8f3-35ac6f2a764f`  
**Package:** AVerMedia Live Gamer ULTRA 2.1 Capture Card

Evidence and links:

1. [ProAV — AVerMedia Live Gamer ULTRA 2.1](https://proav.co.uk/midwich-avermedia-live-gamer-ultra-2-1) — **£226.80 inc VAT / £189.00 ex VAT**; SKU AVRMGC553G2; page showed 1 in stock for immediate dispatch. Exact model and price visible on the opened product page.

No reliable manufacturer-direct UK price was found in the reviewed pages. ProAV is the strongest exact UK retail observation in this batch.

## 6. Bebob V98 V-Mount Battery

**Master product ID:** `cd3eb6f1-5e74-4403-b905-61803eb7749b`  
**Package:** Bebob V98 V-Mount Battery

Evidence and links:

1. [ProAV — Bebob V98 14.4V / 98Wh](https://proav.co.uk/bebob-v98-v-mount-battery-14-4v-6-8ah-98wh) — **£312.00 inc VAT / £260.00 ex VAT**; SKU V98. The page says Availability: In stock but also displays a backorder message saying delivery when in stock, usually within 10 working days.
2. [Production Gear — Bebob V98 14.4V / 98Wh](https://productiongear.co.uk/products/bebob-v98-v-mount-battery-144v-68ah-98wh) — **£324.00 inc VAT / £270.00 ex VAT**; sold out; stock in transit.

**RED VERIFY:** ProAV stock wording conflicts. Production Gear explicitly says sold out/stock in transit. Retain both links and price observations.

## 7. Benro GH2N Gimbal Head

**Master product ID:** `6b08e278-3a88-415a-8632-1fe71b0a4497`  
**Package:** Benro GH2N Gimbal Head

Evidence and links:

1. [Clifton Cameras — Benro GH2N](https://www.cliftoncameras.co.uk/benro-gh2n-gimbal-head) — **£289.00**; exact GH2N/MPN; in stock, one available.
2. [Harrison Cameras — Benro GH2N](https://harrisoncameras.co.uk/products/benro-gh2n-gimbal-head-gh2n) — **£299.00**; exact GH2N; page showed 2 in stock.
3. [CameraWorld — Benro GH2N](https://www.cameraworld.co.uk/benro-gh2n-gimbal-tripod-head.html) — exact GH2N; page showed in stock and a current price of **£342.00** (with £359 shown as the higher/list price). A Shopping/search snippet had previously shown a lower £248 figure; the opened page did not confirm that amount.
4. [The Photography Shop — Benro GH2N](https://www.thephotographyshop.co.uk/products/benro-gh2n-gimbal-head-for-tripod-monopod-camera-mount-25kg-load-arca-swiss-uk) — **£259.95**; sold out.

No model/package mismatch on these four exact GH2N listings.

## 8. BetaFPV Meteor65 Pro II O4

**Master product ID:** `8c454b34-15c6-4963-8d31-0637f4dfd1fd`  
**Package:** Meteor65 Pro II O4 Brushless Whoop Quadcopter

Evidence and links:

1. [YourFPV — Meteor65 Pro II O4 Wide ELRS](https://yourfpv.co.uk/product/betafpv-meteor65-pro-ii-o4-wide-elrs/) — **£216.90**; UK stock / in stock; exact O4 Wide version with integrated ELRS 2.4GHz receiver.
2. [Unmanned Tech — Meteor65 Pro II O4 Wide](https://www.unmannedtechshop.co.uk/products/betafpv-meteor65-pro-ii-o4-the-finally-fixed-the-battery-1s-hd-whoop) — **£214.90 GBP**; sold out/backorder awaiting stock. Product selector exposes DJI O4 Wide versus PNP without HD VTX and ELRS 2.4G versus SBUS (DJI).
3. [eBay UK — BetaFPV Meteor65 Pro II O4 listing](https://www.ebay.co.uk/itm/298506604085) — Shopping/search lead displayed **£192.13**; new; overseas seller. The listing has variant choices, so exact selected VTX/receiver package and UK delivery cost need checking.

**RED VERIFY:** Keep O4 Wide/ELRS separate from PNP or SBUS variants. Check the eBay seller's country, selected variant and landed delivery cost.

## 9. BetaFPV Meteor65 Pro O4

**Master product ID:** `ea2dc2f3-ab90-4376-a2db-2ace222860b8`  
**Package:** Meteor65 Pro O4 Brushless Whoop Quadcopter

Evidence and links:

1. [Unmanned Tech — Meteor65 Pro O4](https://www.unmannedtechshop.co.uk/products/betafpv-meteor65-pro-o4-brushless-whoop-quadcopter) — **£179.90 GBP**; sold out/backorder awaiting stock. Selector exposes DJI O4, PNP without VTX and DJI O4 ELRS BMI270 options.
2. [BETAFPV official product page — Meteor65 Pro O4](https://betafpv.com/products/meteor65-pro-o4-brushless-whoop-quadcopter) — **$184.99 USD** displayed; sold out. Do not convert.

**RED VERIFY:** Confirm the intended O4 and receiver option before treating either page as the exact selected package. The Unmanned Tech price is a sold-out/backorder observation.

## 10. Bright Tangerine Misfit Kick Mk II 2-Stage ONE Tray Kit

**Master product ID:** `ffcac882-61e9-45a9-8d11-e2716f7089c1`  
**Package:** Bright Tangerine Misfit Kick Mk II 2-Stage ONE Tray Kit

Evidence and links:

1. [Production Gear — exact ONE Tray Kit](https://productiongear.co.uk/products/bright-tangerine-misfit-kick-mk-ii-2-stage-one-tray-kit) — **£1,412.40 inc VAT / £1,177.00 ex VAT**; SKU BT-B1235.0105; sold out; stock in transit. Opened page confirms the kit includes the Misfit Kick Core Mk II, two 4×5.65-inch filter trays, quick-release top flag and ONE Tray.
2. [ProAV — Misfit Kick 360 Mk II 2-Stage Kit](https://proav.co.uk/bright-tangerine-misfit-kick-360-mk-ii-2-stage-kit) — related but **not the same ONE Tray package**. Retain only as a near-match lead; do not attach its price to this exact product.

**RED VERIFY:** Production Gear gives a useful exact package price but the listing is sold out/stock in transit. Do not substitute the 360 kit price.

## 11. Bright Tangerine OpenRig Base Kit

**Master product ID:** `51221038-0385-426d-bc46-5f8d1bb0dec4`  
**Package:** Bright Tangerine OpenRig Base Kit

Evidence and links:

1. [CVP — OpenRig Base Kit](https://cvp.com/product/bright-tangerine-openrig-base-kit) — **£189.00 inc VAT / £157.50 ex VAT**; available to pre-order. The page's estimated stock date is 1 September 2026, which is already past relative to this research date. Page states a 24-month warranty. Included box contents: 160mm OpenRig Rail (B4013.1046), OpenRig Arca Base (B4013.1047) and OpenRig Anti-Twist Plate (B4013.1049).
2. [Wex Photo Video — OpenRig Base Kit](https://www.wexphotovideo.com/bright-tangerine-openrig-base-kit-3366065/) — Google Shopping/product card displayed **£197.00**. Direct page fetch failed, so price, stock and contents are not independently confirmed.

**RED VERIFY:** CVP's preorder stock date is stale/past; confirm actual dispatch timing. Wex's £197 is a Shopping card lead only because the product page could not be opened.

## 12. Brinno TLC5000 4K Time Lapse Camera

**Master product ID:** `f7affd6e-9b9f-4eb7-ae1d-0d4e2dcc6501`  
**Package:** TLC5000 4K Time Lapse Camera

Evidence and links:

1. [Brinno UK — BCC5000 4K Connected Timelapse Camera Kit](https://www.brinnouk.com/products/preorder-bcc5000-4k-connected-timelapse-camera-kit) — **£1,899.00 tax included**. The BCC5000 kit contains the TLC5000 camera with Sony STARVIS 2 sensor, IP65 weatherproof casing and camera clamp.
2. [Amazon UK — Brinno BCC5000 bundle](https://www.amazon.co.uk/Brinno-BCC5000-Lapse-Camera-Bundle/dp/B0F6T64YNX) — Shopping/product card displayed **£1,904.94** for the BCC5000 bundle. Amazon page fetch returned 503, so seller, stock and package contents were not independently checked.

**RED VERIFY:** Neither price is for the standalone TLC5000 camera. Keep the BCC5000 bundle price separate and do not assign it as a camera-only price.

## 13. Casio EX-100F

**Master product ID:** `86c529ed-55d2-485f-8085-6ae7dce991a3`  
**Package:** Standard Package

Evidence and links:

1. [eBay UK — Casio High Speed Exilim EX-100F](https://www.ebay.co.uk/itm/134043034576) — displayed **US $449.99 or Best Offer**; used; 2 available; private seller, 98.9% positive; seller located in Chuo Ward, Tokyo, Japan. Shipping displayed **US $39.99**; import fees stated as included. eBay itself displayed an approximate GBP figure, but that conversion is deliberately not recorded as a GBP price.

**RED VERIFY:** GBP price field must remain blank. Verify seller, UK delivery date and final checkout currency. Source amount is USD $449.99 plus USD $39.99 shipping.

## 14. Casio EX-ZR20

**Master product ID:** `43fb75be-3f8e-4d2d-bb88-6bd486a0e3e9`  
**Package:** Standard Package

Evidence and links:

1. [Gumtree — Casio EX-ZR20 16MP 8x Zoom](https://www.gumtree.com/p/digital-cameras/casio-ex-zr-20-16mp-8x-zoom-high-speed-camera-silver/1495909645) — **£75.00**; used, Good condition; seller in Storrington, West Sussex; collection only. Description says battery, wrist strap, USB/charging cable and pouch case included.
2. [eBay UK — EX-ZR20 product page / all listings](https://www.ebay.co.uk/p/11086729600) — opened product page showed **£105.37 + £15.05 postage** for a used listing and multiple other listings: £116.72 + £15.05, £138.59, £140.98, £143.83 + £12.54, £203.07 + £12.54 and £286.63 + £12.54. Seller step-f has 98.5% feedback; some associated listings are from Japan. Check individual listing status and seller location.
3. [eBay UK — EX-ZR20 #0006](https://www.ebay.co.uk/itm/820116791901) — **£86.30**; used; listing ended; seller notes excellent condition with minor scuffs/scratches and an LCD with fine scratches.
4. [eBay UK — EX-ZR20 #0012](https://www.ebay.co.uk/itm/820195577612) — opened page shows the listing ended at **£79.64**; used; retain as historical evidence. A search card had shown a different current-looking amount, so use the opened ended-page amount.
5. [eBay UK — EX-ZR20 #0004](https://www.ebay.co.uk/itm/820200595935) — search card displayed **£142.24**; used, excellent condition; seller step-f, Tokyo. Opened page did not expose the current price, so verify the live listing.
6. [Google Shopping click-through — eBay item 377592107678](https://www.ebay.co.uk/itm/377592107678) — Shopping card title said “Casio EX-ZR20” and displayed **£80.05**. After opening the actual page, item specifics showed **Model: CASIO EXILIM EX-ZR400**, not EX-ZR20. This is a confirmed title/model mismatch; do not attach the £80.05 to EX-ZR20. Preserve the URL as a **RED VERIFY** example of a Shopping false match.

**RED VERIFY:** The EX-ZR400 click-through is not an exact match despite the Shopping title. Keep its link and mismatch note, but leave it out of EX-ZR20 price evidence. Check the eBay Japan seller locations and live status on other listings.

## 15. Casio EX-ZR2000

**Master product ID:** `525e69d7-5087-4fa3-9042-45ffdf0b2439`  
**Package:** Standard Package

Evidence and links:

1. [Casio official EX-ZR2000 product page](https://www.casio-intl.com/asia/en/dc/products/ex_zr2000/) — exact model identified as a **Past Model**; 16.1MP, 18× optical zoom; no price.
2. [Casio official EX-ZR2000 specifications](https://www.casio-intl.com/asia/en/dc/products/ex_zr2000/spec/) — exact model specifications; no price.
3. [eBay UK — EX-Z2000 example](https://www.ebay.co.uk/itm/820140740736) — search result displayed £131.75 for **EX-Z2000**, not EX-ZR2000.
4. [eBay UK — EX-Z2000 example](https://www.ebay.co.uk/itm/820164755625) — search result displayed £85.49 for **EX-Z2000**, not EX-ZR2000.
5. [eBay UK — EX-Z2000 product listing](https://www.ebay.co.uk/itm/377444979291) — product card displayed £161.12 for **EX-Z2000**, not EX-ZR2000.

**RED VERIFY:** Exact official model exists but is discontinued. The three eBay examples are EX-Z2000 without the “R” and are not exact matches. Do not assign their prices to EX-ZR2000. Continue looking for the exact EX-ZR2000 used listing.

## 16. Casio EX-ZR500

**Master product ID:** `ffd2590d-9921-42a2-bf0b-5c7a3d55d5b0`  
**Package:** Standard Package

Evidence and links:

1. [eBay UK — Casio EX-ZR500 #0003](https://www.ebay.co.uk/itm/820200199469) — **£138.74**; used, Good condition with scratches/scuffs; seller step-f, business seller, 98.5% positive; located Tokyo, Japan. Description says battery, AC adapter, USB cable and strap included.
2. [eBay UK — Casio EX-ZR500 #0011](https://www.ebay.co.uk/itm/820231527905) — **£157.66**; used, “Top Mint”; same business seller step-f, located Tokyo, Japan. Seller notes clean body/lens and fully functional; items shown in photos included.

**RED VERIFY:** These are GBP-displayed eBay listings from a Japanese seller, not domestic UK stock. Confirm delivery, import treatment and exact included accessories.

## 17. DJI Mini 3 — Fly More Combo Plus (DJI RC)

**Master product ID:** `9a112018-4477-4b5f-886b-76e12901f529`  
**Package:** Fly More Combo Plus (DJI RC)

Evidence and links:

1. [Argos — DJI Mini 3 Fly More Combo Drone & DJI RC Remote Controller](https://www.argos.co.uk/product/1347092) — **£509.00**; exact DJI RC named in the product title; stock must be checked by postcode. The opened page did not expose full package contents.
2. [SCAN — DJI Mini 3 (DJI RC) Fly More Combo](https://www.scan.co.uk/products/dji-mini-3-fly-more-combo-dji-rc-2024) — **£509.00**; pre-order, due **30 November 2026**. Opened page explicitly lists DJI Mini 3, DJI RC, three Intelligent Flight Batteries, three pairs of spare propellers, spare screws, screwdriver, gimbal protector, USB-C PD cable, shoulder bag and two-way charging hub.
3. [Camix — DJI Mini 3 Fly More Combo (DJI RC) 2024](https://camix.co.uk/product/dji-mini-3-fly-more-combo-dji-rc-2024/) — **£573.00**; awaiting stock; one-year warranty and free UK delivery. Description confirms DJI RC controller, spare Intelligent Flight Batteries, spare propellers and shoulder bag.
4. [Very — DJI Mini 3 Fly More Combo Drone](https://www.very.co.uk/dji-mini-3-fly-more-combo-drone-with-nbspremote-control/1600838205.prd) — **£579.00** displayed; availability and exact controller/package contents need checking.

**RED VERIFY:** The master package explicitly requires DJI RC. Do not merge standard RC-N1 packages or basic Fly More packages. SCAN's package contents are the clearest exact match, but it is a preorder for 30 November 2026. Argos stock and package contents need postcode/page confirmation.

## 18. FIMI X6

**Master product ID:** `4babc50b-32bf-4f28-884b-0a79c0736e30`  
**Package:** Standard Package  
**Existing catalogue note:** Older/discontinued model.

Evidence and links:

1. [FIMI official English site page/navigation](https://www.fimi.com/mi-smartphone-gimbal.html) — FIMI X6 appears in the manufacturer's product navigation, but the opened page is the Mi Smartphone Gimbal page, not an X6 product-detail page. No price.
2. [FIMI official Chinese site](https://www.fimi.com/cn/) — manufacturer navigation lists FIMI X6 under the drone section. No accessible X6 detail page or price was found.
3. [Fruugo — generic X6 dual-camera drone](https://www.fruugo.co.uk/x6-drone-with-dual-camera-hd-4k-optical-flow-localization-foldable-quadcopter-three-sides-obstacles-avoidance/p-272775578-605018025) — **£59.00 + £11.99 shipping**; unbranded generic X6, seller name is a Chinese company. This is **not identified as FIMI** and is not a defensible match.

**RED VERIFY:** Manufacturer site confirms an X6 name in its navigation, but no exact product page or price was retrieved. The Fruugo generic X6 must not be attached as exact evidence. Keep its link as a rejected near-match with the reason.

## 19. FIMI X8 Pro

**Master product ID:** `f57752f8-152c-4911-bf22-805e613ba8da`  
**Package:** Standard Package  
**Existing catalogue note:** Older/discontinued model.

Evidence and links:

1. [FIMI official X8 Pro product page](https://www.fimi.com/fimi-x8-pro.html) — exact standard X8 Pro model and specifications; no GBP price.
2. [FIMI official X8 Pro 2025 page](https://www.fimi.com/fimi-x8-pro2025.html) — separate 2025 model variant; no GBP price. Do not automatically merge with the older standard X8 Pro.
3. [InwayChina — FIMI X8 Pro AI-enhanced drone](https://inwaychina.com/en/product/fimi-x8-pro-ai-enhanced-drone-super-night-video) — search result displayed **£632.56** and free delivery in 5–14 days, but direct page fetch returned 502. Seller identity, dispatch country, exact package and checkout currency could not be verified.

**RED VERIFY:** GBP field remains blank for the InwayChina lead. Record only that the source displayed £632.56; verify seller/dispatch, currency at checkout and package contents. Do not confuse X8 Pro with X8 Pro 2025 or X8 Tele.

## 20. FIMI Mi Smartphone Gimbal

**Master product ID:** `e47e6644-1a8e-48db-bbe2-ca417e8518ca`  
**Package:** Mi Smartphone Gimbal Standard Package

Evidence and links:

1. [FIMI official Mi Smartphone Gimbal page](https://www.fimi.com/mi-smartphone-gimbal.html) — exact manufacturer product page, overview/specifications and official “Buy Now” link; no price visible.
2. [FIMI-linked AliExpress product page](https://www.aliexpress.com/item/4000181984682.html) — linked from the manufacturer's Buy Now control; web page could not be opened, so price/availability are unknown.
3. [FIMI official store](https://www.aliexpress.com/store/5063216) — linked from the manufacturer page as its AliExpress Official Store; page fetch was blocked.

**RED VERIFY:** Preserve official links; no reliable UK GBP price or accessible current seller listing found. Do not substitute DJI/Hohem/Zhiyun gimbals.

---

## Batch 06 outcome

- Products researched: **20**
- Products with at least one exact UK GBP sale/used price lead: multiple; see individual product records.
- Products with GBP price deliberately blank due non-GBP or unverified source currency: Autel Plus Bundle, Casio EX-100F, FIMI X8 Pro third-party lead, FIMI X6 and FIMI Mi Smartphone Gimbal.
- Exact-model or package mismatches retained with RED VERIFY notes: Angenieux EZ-1 rear-optic configuration, Autel Plus dispatch/package, Aputure used kit completeness, Bebob V98 stock, BetaFPV variant selectors, Bright Tangerine 360-vs-ONE Tray, Brinno standalone-vs-BCC5000, Casio EX-ZR20 Shopping card actually EX-ZR400, Casio EX-ZR2000 vs EX-Z2000, DJI RC-vs-RC-N1, FIMI generic X6 and X8 Pro/2025/Tele distinctions.
- Queue candidates staged: **0**.
- Reason: owner auth context returned null `auth.uid()`, null `auth.role()` and owner check false. No direct write or bypass attempted.
- Active shared evidence created: **0**.
- Master products changed: **0**.
- Schema/valuation changes: **0**.
- TEST/Stripe changes: **0**.

## Next run instructions

1. Read this Batch 06 checkpoint and `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-06.md` first.
2. Exclude all 20 product UUIDs listed above, plus every UUID in scheduled batches 02–06, all outstanding LIVE queue candidates and all outstanding manual AI prompts.
3. Recheck active `shared_market_evidence`, queue and manual prompt status immediately before researching.
4. Select the next 20 active LIVE catalogue master products dynamically, with no fixed SQL OFFSET.
5. Open actual manufacturer/retailer/marketplace/Google Shopping product pages. Retain useful links even when uncertain; use RED VERIFY and explain the exact uncertainty.
6. Check owner-auth context first. Only stage candidates through the supported authenticated platform-owner RPC when `auth.uid()` is non-null and owner check passes. Otherwise create the next checkpoint and project-memory files; do not write directly to the queue.
