# TradeFlow LIVE Project Memory — Scheduled Market Evidence Batch 09

**Date:** 2026-11-12  
**Repository/branch:** laurendigitaluk/TradeFlow / production  
**LIVE Supabase:** gxsrajtqzdjvmceqcpgv  
**Status:** 20 products researched; 0 staged because owner-auth context is null.

## Canonical detailed research record

The full record below includes all 20 product IDs, source URLs, observed prices/currencies, condition, availability, uncertainties and RED VERIFY notes. The same detailed checkpoint is maintained at CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-09.md.

# TradeFlow LIVE — Scheduled Market Evidence Batch 09

- Research date: 2026-11-12
- Repository/branch: laurendigitaluk/TradeFlow / production
- Supabase project: LIVE only (gxsrajtqzdjvmceqcpgv)
- Status: 20 products researched; not staged to LIVE review queue
- No master products, schema, valuation logic, TEST or Stripe changed.

## 1. Preflight and product selection

Read on production before selection:
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md through batch-08.md.
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md and available files 04, 05, 06, 07 and 08.
- No PROJECT-MEMORY batch-03 file exists; its checkpoint was present and read.
- Also checked separate camera-catalogue evidence checkpoints 01–07; no selected product identity overlapped those named products.

Exclusion and selection:
- 184 distinct UUID-shaped values were collected from scheduled checkpoints 02–08. The database anti-join excluded values that matched catalogue master product IDs; UUID-like source identifiers were not treated as catalogue products.
- One outstanding manual AI research prompt was found, status ready, covering 20 product IDs. Those IDs were excluded.
- Ten outstanding LIVE research-queue candidates were found (statuses other than imported/rejected). Products matching linked master IDs or exact manufacturer/model/package identity were excluded.
- The exact identity Nikon / Ai-S NIKKOR 28mm f/2 was also excluded despite a duplicate catalogue UUID, following Batch 08's identity note.
- Dynamic anti-joins and ORDER BY created_at, id were used. No fixed SQL OFFSET was used.
- Selection returned the next 20 active products with no active shared_market_evidence.

Immediately before research, all 20 selected IDs were rechecked:
- active = true for all 20
- active shared_market_evidence = 0 for all 20
- outstanding queue candidate match = 0 for all 20
- outstanding manual prompt match = 0 for all 20

## 2. Research method

Each product was searched across manufacturer references, UK retailers, used marketplaces and Google Shopping. Product/Shopping cards were opened where available and actual merchant pages were inspected. Variant/package details and availability were checked where exposed. A Google Shopping search URL is retained for every product so the user can inspect further results.

Price handling:
- GBP prices are recorded only where a source displayed a GBP amount.
- USD, JPY and other currencies are left in their displayed currency; no conversion to GBP was made.
- Sold-out, backordered, foreign-seller, private-seller, unverified and uncertain matches are retained with RED VERIFY notes.
- Google Shopping converted cards were not treated as verified GBP when the opened seller page displayed another currency.
- No uncertain prices were sent to automatic valuation.

## 3. Product research records

### 1. Sony RM-BR300H
- Product ID: 5229123a-7609-4706-a614-18c54ab26d7d
- Package: Standard
- Observed price: No reliable GBP price for exact H suffix. Closest base RM-BR300 UK used listing £499.00.
- Condition: Used base RM-BR300; other seller listing USD $449.95.
- Availability: N.I. Broadcast: 2 in stock. BMI Surplus: 3 in stock.
- Visible note: RED VERIFY — opened listings identify RM-BR300, not RM-BR300H. Do not treat base-model price as an exact H-suffix match. Google Shopping surfaced a converted GBP card for BMI Surplus, but opened seller page displays USD $449.95; do not use converted card price.
- Source pages:
  - [N.I. Broadcast — RM-BR300, £499 used, 2 in stock](https://www.nibroadcast.com/sony-rm-br300-ptz-camera-remote-panel.html)
  - [BMI Surplus — RM-BR300, USD $449.95, 3 in stock, power supply included](https://bmisurplus.com/products/sony-model-rm-br300-remote-control-unit/)
  - [Smacom Japan — RM-BR300 rental reference JPY 66,000 (2022)](https://www.smacom.jp/sony_rm-br300/)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20RM-BR300H%20Standard%20UK%20price

### 2. PowerVision PowerDolphin Intelligent Battery
- Product ID: 563ce2c3-c876-4673-a017-530707a18c66
- Package: Intelligent Battery
- Observed price: £24.21–£24.71 for third-party Cameron Sino PDOIB10 replacements; eBay £50.74.
- Condition: New replacement batteries; eBay seller lists 5800mAh.
- Availability: Energystox and Bigupgadgets show in stock; eBay shows 6 available.
- Visible note: RED VERIFY — exact compatible part PDOIB10 identified, but UK offers are third-party replacement batteries, not confirmed genuine PowerVision originals. Check capacity, connector, compatibility and seller provenance. eBay seller is a Hong Kong business; shipping/import costs are additional.
- Source pages:
  - [Bigupgadgets — PDOIB10 replacement, £24.71, in stock](https://uk.bigupgadgets.com/battery-powervision-powerdolphin-wizard-underwate-powerdolphin-intellijet-p-n-pdoib10-01-0039568)
  - [Energystox — PDOIB10 Cameron Sino replacement, £24.21, in stock](https://uk.energystox.com/battery-powervision-pdoib10-for-powerdolphin-intellijet-powerdolphin-wizard-underwate-ex-ag702)
  - [eBay UK — PDOIB10 5800mAh, £50.74, new, 6 available; seller in Hong Kong](https://www.ebay.co.uk/itm/298335329965)
  - [AolsteCell — PDOIB10 replacement, USD $53.39, 5800mAh, US delivery estimate](https://www.aolstecell.com/powervision/pdoib10-battery-for-powerdolphin-wizard-underwater)
- Google Shopping: https://www.google.com/search?tbm=shop&q=PowerVision%20PowerDolphin%20Intelligent%20Battery%20Intelligent%20Battery%20UK%20price

### 3. Sony HVR-Z5U
- Product ID: 566ba03a-0262-4552-a97c-c9ae1c807b31
- Package: Standard
- Observed price: No reliable current UK GBP price confirmed. Ubuy indexed result showed GBP 2,469 ex VAT, but opened page is out of stock and has no live price. Less-established UK-facing seller shows £1,110.89.
- Condition: eBay exact U model used; other UK price lead presented as new/retail.
- Availability: Ubuy out of stock; usamarafiquephotography page has Add to Cart; eBay US listing available when crawled.
- Visible note: RED VERIFY — exact U model is NTSC. UK HVR-Z5E listings are PAL variants and must not be treated as exact matches. £1,110.89 seller has not been independently verified. Ubuy imports from USA and currently shows out of stock; indexed GBP amount is not a live offer.
- Source pages:
  - [Ubuy UK — exact HVR-Z5U, currently out of stock; prior indexed price GBP 2,469 ex VAT](https://www.u-buy.co.uk/product/8JOVNVI2-sony-hvr-z5u-high-definition-handheld-professional-camcorder)
  - [usamarafiquephotography — exact HVR-Z5U, £1,110.89, accessories listed; seller needs verification](https://usamarafiquephotography.co.uk/product/sony-hvr-z5u-camcorder-1080p-1-12-mp-20x-optical-zoom-mini-dv-hdv)
  - [eBay UK — exact HVR-Z5U, USD $930, used, 2 batteries and charger, US seller](https://www.ebay.co.uk/itm/324789009548)
  - [eBay UK — HVR-Z5E near variant, £437.67, used](https://www.ebay.co.uk/itm/325932287113)
  - [DigiBroadcast — HVR-Z5E with Vinten Vision 100 tripod, £720 gross / £600 ex VAT; different PAL model and package](https://www.digibroadcast.com/used-equipment-c211/camcorders-c213/sony-hvr-z5e-14x10-hrs-vinten-vision-blue-tripod-used-p50916)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20HVR-Z5U%20Standard%20UK%20price

### 4. Pentax WG-90
- Product ID: 56977dfa-b65e-4e39-ba45-b0d9116107ec
- Package: Standard
- Observed price: £329.00–£329.99 current retailer leads; £379.00–£379.99 other UK listings. Google Shopping card showed £299 Jessops, but direct page shows £379.
- Condition: New standard camera, black/blue variants.
- Availability: Carmarthen Cameras shows 1 in stock; Camera Centre UK shows in stock; Currys delivery/stock check; Maplin stock wording inconsistent.
- Visible note: RED VERIFY — Google Shopping £299 Jessops card conflicts with opened product page showing £379. HDEW Cameras Shopping lead £235 was not independently verified. Confirm colour and checkout price.
- Source pages:
  - [Carmarthen Cameras — blue, £329.99, 1 in stock](https://carmarthencameras.com/products/pentax-wg-90-waterproof-tough-compact-camera-blue)
  - [Camera Centre UK — black, £329.00, page reports in stock](https://www.cameracentreuk.com/pentax-wg-90-waterproof-digital-compact-camera-black)
  - [Currys — black, £379.00](https://www.currys.co.uk/products/pentax-wg90-tough-compact-camera-black-10268535.html)
  - [Currys — blue, £379.00](https://www.currys.co.uk/products/pentax-wg90-tough-compact-camera-blue-10268534.html)
  - [Maplin — blue, £379.00, delivery shown but availability message also says email when available](https://www.maplin.co.uk/products/pentax-wg-90-16mp-5x-zoom-tough-compact-camera-blue)
  - [Jessops — blue, direct page £379.00; Shopping card had £299 lead](https://www.jessops.com/p/pentax/wg-90-digital-camera-in-blue-206260)
  - [Argos — blue, £379.99, postcode stock check required](https://www.argos.co.uk/product/7619607)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Pentax%20WG-90%20Standard%20UK%20price

### 5. Sony NP-FV70 Battery
- Product ID: 57432398-7bcb-43fa-9bda-dcc2d280b78a
- Package: Accessory
- Observed price: £49.99 Bristol Cameras; £96.00 BPS; £103.02 Ballicom.
- Condition: New rechargeable battery offers.
- Availability: Bristol says genuine UK stock; BPS delivery 2–4 weeks; Ballicom low stock, 3 units.
- Visible note: RED VERIFY — retailer pages identify NP-FV70A / NP-FV70A2.CE variants in NP-FV70 family. Exact original non-A version is not independently confirmed. Google Shopping surfaced NP-FV90/NP-FV100 and other replacement batteries; those are not exact matches.
- Source pages:
  - [Bristol Cameras — NP-FV70 family, £49.99, genuine UK stock](https://www.bristolcameras.co.uk/product/sony-np-fv70-infolithium-rechargeable-battery/)
  - [BPS TV — NP-FV70 family, £96.00, 2–4 week delivery](https://www.bps-tv.co.uk/product/sony-np-fv70-battery-1900mah/)
  - [Ballicom — NP-FV70A2.CE, £103.02, low stock](https://www.ballicom.co.uk/npfv70a2-ce-sony-np-fv70a-battery.p1639917.html)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20NP-FV70%20Battery%20Accessory%20UK%20price

### 6. Sony HDC-F5500V
- Product ID: 58c44c6a-edcb-4350-a831-019c08b8161d
- Package: Standard Package
- Observed price: £85,619.24 inc VAT / £71,349.37 ex VAT.
- Condition: New.
- Availability: Available to order; not currently held in stock.
- Visible note: RED VERIFY — exact HDC-F5500V-4K SKU confirmed. Page does not enumerate the complete system package or included accessories; ask dealer whether this is camera head only or a configured system package.
- Source pages:
  - [Visuals — Sony HDC-F5500V 4K Studio Camera, exact SKU, price and availability](https://www.visuals.co.uk/hdc-f5500/4k-1.html)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20HDC-F5500V%20Standard%20Package%20UK%20price

### 7. Pentax smc PENTAX-DA* 55mm F1.4 SDM
- Product ID: 59ad737a-f7e4-4bfa-9dde-3fc35dbffbaa
- Package: Standard
- Observed price: £559.00 Peter Rogers; £799.00 Bristol/Clifton; £855.00 CameraWorld. eBay Japan listing displays £234.82.
- Condition: New retailer listings; used near-mint Japan eBay listing.
- Availability: Peter Rogers in stock; Bristol available to order; Clifton awaiting stock 5–7 days; CameraWorld awaiting stock with stale expected date.
- Visible note: RED VERIFY — same SKU 21790 across UK retailers. Bristol confirms lens hood, front/rear caps and flexible pouch. Peter Rogers price reduced from £799 with £9.99 delivery. Japan eBay listing near mint, seller in Kanagawa; shipping/import costs vary.
- Source pages:
  - [Bristol Cameras — £799 inc VAT, available to order, SKU 21790, package contents specified](https://www.bristolcameras.co.uk/product/pentax-55mm-f1-4-smc-da-sdm-lens)
  - [Peter Rogers — £559, in stock, SKU 21790](https://shop.peterrogers-photo.co.uk/pentax-55mm-f1-4-smc-da-sdm/)
  - [Clifton Cameras — £799, awaiting stock](https://www.cliftoncameras.co.uk/Pentax-55mm-f1.4-SMC-DA-SDM)
  - [CameraWorld — £855, awaiting stock; expected date displayed as 13 June 2026](https://www.cameraworld.co.uk/pentax-da-55mm-f1-4-sdm-lens.html)
  - [eBay UK — near-mint used lens, £234.82 displayed, seller in Kanagawa, Japan](https://www.ebay.co.uk/itm/820113732708)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Pentax%20smc%20PENTAX-DA*%2055mm%20F1.4%20SDM%20Standard%20UK%20price

### 8. Panasonic Lumix DMC-GF7
- Product ID: 5b2b7291-cac6-44d8-ae4e-4cc1bb50d9e4
- Package: Standard
- Observed price: £186.69 UK body-only private listing; £129.95 historic sold body-only listing; £213.90–£249.99 used lens-kit aggregator leads. Foreign-currency listings are not converted.
- Condition: Used body-only and used 12–32mm lens-kit offers.
- Availability: £186.69 body-only eBay listing active when crawled; £129.95 listing sold; CameraWorld £279 lens kit sold out; SDS aggregator tracks 2 used kit offers.
- Visible note: RED VERIFY — separate body-only from 12–32mm kit prices. Japan eBay body listing displays USD $275.29 plus USD $49 shipping; approximate GBP display is not used as a GBP price. UK eBay body listing is private seller in Cheadle. UK eBay kit listing is seller in Stratford-upon-Avon, but direct page did not expose a live price.
- Source pages:
  - [eBay UK — body only, £186.69, private seller in Cheadle](https://www.ebay.co.uk/itm/358922423033)
  - [eBay UK — brown body plus 12–32mm lens kit, seller in Stratford-upon-Avon](https://www.ebay.co.uk/itm/257755102329)
  - [SDS — used GF7 listings from £213.90 to £249.99, two available](https://sds.net/buy/panasonic-lumix-gf7)
  - [eBay UK — body only, £129.95, sold 15 June 2026](https://www.ebay.co.uk/itm/267552694206)
  - [CameraWorld — 12–32mm kit, £279, sold out](https://www.cameraworld.co.uk/used-panasonic-lumix-gf7-mirrorless-camera-12-32mm-lens.html)
  - [CameraPriceBuster — historic used prices only; no current used prices](https://cpb.camerapricebuster.co.uk/Panasonic/Panasonic-G-System-Cameras/Panasonic-Lumix-DMC-GF7-with-12-32mm-Lens)
  - [eBay UK — Japan seller, USD $275.29 plus USD $49 shipping; no GBP conversion](https://www.ebay.co.uk/itm/127575821816)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Panasonic%20Lumix%20DMC-GF7%20Standard%20UK%20price

### 9. Sony FE 35mm F1.4 GM
- Product ID: 5d05e9c4-62af-4d31-bf68-e4f67d46ddee
- Package: Standard
- Observed price: Wex used £728, £829 and £835; LCE used £629.99 lead; Norwich Cameras £843 indexed page; Amazon Renewed Shopping lead £835.
- Condition: Used Very Good/Mint/Excellent; new/retail leads; Amazon renewed lead.
- Availability: Wex listings in stock; LCE page redirects to search; Norwich page indicates 5–7 days and seller is HK-based; Amazon page could not be opened.
- Visible note: RED VERIFY — compare condition and accessories. Wex £728 Very Good includes original box/manual/caps/hood but no soft case; Wex £829 Mint has brown box and soft case; Wex £835 Excellent includes original box/manual/soft case and notes a fine rear-optic scratch. LCE £629.99 not independently re-opened. Norwich seller Futronix HK and no VAT. Amazon Shopping title says Renewed, not new.
- Source pages:
  - [Wex used — £728, Very Good, in stock, Norwich](https://www.wexphotovideo.com/sony-fe-35mm-f1-4-gm-lens-used-3374329/)
  - [Wex used — £829, Mint, in stock](https://www.wexphotovideo.com/sony-fe-35mm-f1-4-gm-lens-used-3372761/)
  - [Wex used — £835, Excellent, in stock](https://www.wexphotovideo.com/sony-fe-35mm-f1-4-gm-lens-used-3334009/)
  - [LCE used — £629.99 search lead; page redirects to second-hand search](https://www.lcegroup.co.uk/Used/Sony-FE-35mm-F1.4-GM-_497865.html)
  - [Norwich Cameras — £843 indexed price; seller Futronix HK, no VAT](https://norwich-cameras.co.uk/products/sony-fe-35mm-f-1-4-gm-sel35f14gm)
  - [Amazon Renewed Shopping lead — £835; direct page could not be opened](https://www.amazon.co.uk/Sony-SEL35F14GM-Full-Frame-Premium-Renewed/dp/B0HKLLLQQ3)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20FE%2035mm%20F1.4%20GM%20Standard%20UK%20price

### 10. Skydio X2E
- Product ID: 5d1a85ab-8bec-41b1-a64f-2a57b0f8895c
- Package: X2E 5GHz Color/Thermal Starter Kit
- Observed price: No reliable UK GBP price. Exact US eBay listing USD $14,299.00.
- Condition: New.
- Availability: eBay US listing showed 4 available; no returns.
- Visible note: RED VERIFY — exact kit title found, but seller in Forsyth, Georgia, USA and package contents not fully enumerated. Do not convert USD. Check export restrictions, UK delivery, import charges and included controller/batteries/accessories. AirPixels price information is an estimate, not a confirmed seller offer.
- Source pages:
  - [eBay US — exact X2E 5GHz Color/Thermal Starter Kit, USD $14,299, 4 available, no returns](https://www.ebay.com/itm/147248080702)
  - [AirPixels — X2E technical/price estimate, not a confirmed retail offer](https://www.airpixels.com/drones/skydio-x2e-color-thermal)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Skydio%20X2E%20X2E%205GHz%20Color%2FThermal%20Starter%20Kit%20UK%20price

### 11. Sony FE 28-60mm F4-5.6
- Product ID: 61234bf4-1f07-492c-a2ea-453b7a5654e8
- Package: Standard
- Observed price: Used UK offers £126 MPB, £149.99 LCE, £141.12 and £169.99 eBay; new UK-facing leads £399–£449; Norwich Cameras £207 from HK seller.
- Condition: Used Excellent/Good and new retail leads.
- Availability: MPB 30 available when crawled; LCE used in store; eBay offers active; several new retailer pages show order/backorder or stock-on-way.
- Visible note: RED VERIFY — standard lens only; check caps and any bundled camera kit. Norwich Cameras seller Futronix HK/no VAT. Shopping eBay card £145.02 differed from direct eBay pages; treat as a lead. MPB direct page timed out, but search listing showed £126 and 30 Excellent-condition units.
- Source pages:
  - [MPB used — from £126, 30 available, Excellent](https://www.mpb.com/en-uk/product/sony-fe-28-60mm-f-4-5-6)
  - [LCE used — £149.99, Excellent, Nottingham](https://www.lcegroup.co.uk/Used/Sony-FE-28-60mm-F4-5.6_500639.html)
  - [eBay UK — £169.99, Excellent, business seller in Croydon](https://www.ebay.co.uk/itm/206365080386)
  - [eBay UK — £141.12 search lead, Good, private seller in Wokingham](https://www.ebay.co.uk/itm/336807491138)
  - [Norwich Cameras — £207 indexed price, HK seller/no VAT](https://norwich-cameras.co.uk/products/sony-fe-28-60mm-f4-5-6-sel2860)
  - [Bristol Cameras — £399 available to order](https://www.bristolcameras.co.uk/product/sony-28-60mm-f4-5-6-fe-lens-e-mount/)
  - [Cambrian Photo — £449 retail lead](https://www.cambrianphoto.co.uk/products/sony-fe-28-60mm-f4-5-6-lens-sony-e-mount)
  - [UsedLens — UK used-price aggregate, from £126](https://usedlens.co.uk/product/sony-fe-28-60mm-f-4-5-6)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20FE%2028-60mm%20F4-5.6%20Standard%20UK%20price

### 12. Nikon F55
- Product ID: 66fc5073-932f-4c70-95f4-35012d6f7b1a
- Package: Body
- Observed price: Bristol Cameras £24 used body-only; eBay £28.60; Vinted £49 (or £52.15 incl. buyer fee) with 28–80mm lens and case; Ffordes £59/£69.50 discrepancy; sold-out body-only leads £20–£65.
- Condition: Used body-only and used kit offers.
- Availability: Bristol search result says in stock; Vinted active; Ffordes price/stock needs recheck; Vintage Camera Hut and Colins listings sold out.
- Visible note: RED VERIFY — distinguish body-only from 28–80mm lens kits. Bristol page returned HTTP 520 when opened, but indexed result showed £24 and 3-month guarantee. Ffordes Shopping card £69.50 differs from earlier £59 search price. Film Camera Store £165 page title says F55 with 28–80mm lens but URL slug says F50 and stock is backordered. Vinted listing includes lens and case, not body-only.
- Source pages:
  - [Bristol Cameras — Nikon F55 body only, £24 used search listing; page failed to open](https://www.bristolcameras.co.uk/product/nikon-f55-body-only-35mm-film-camera-used/)
  - [eBay UK — body only, £28.60, used Very Good](https://www.ebay.co.uk/itm/326836970654)
  - [Ffordes — F55 chrome body only; price £59 search lead / £69.50 Shopping card, verify checkout](https://www.ffordes.com/p/SH-28-086880/nikon-af/f55-chrome-body-only)
  - [Vinted — £49, Very Good, includes 28–80mm lens and case; £52.15 incl. fee](https://www.vinted.co.uk/items/10557364348-nikon-f55-camera-very-little-used)
  - [Film Camera Store — £165, F55 with 28–80mm lens, backordered; URL slug says F50](https://filmcamerastore.co.uk/collections/slr-cameras/products/nikon-f50-35mm-slr-film-camera-body-only-copy)
  - [Vintage Camera Hut — £65 body only, sold out](https://www.vintagecamerahut.com/products/nikon-f55-35mm-film-camera-body-only)
  - [Colins Cameras — £20 body-only search lead, sold out; Shopping card showed £26](https://colinscameras.co.uk/products/nikon-f55)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Nikon%20F55%20Body%20UK%20price

### 13. Nikon MB-N12 Battery Pack
- Product ID: 67905d4d-0261-4189-a519-44a0e591a4c0
- Package: Standard Item
- Observed price: £299.00 Jessops; £329.00 Harrison Cameras. Shopping also surfaced £259 CamerasDori and £289 Cotswold leads.
- Condition: New.
- Availability: Jessops available to order/awaiting stock; Harrison Cameras 1 in stock.
- Visible note: RED VERIFY — exact VFC01001 MB-N12 for Nikon Z8. Shopping prices from CamerasDori and Cotswold were not independently opened. Jessops direct page says awaiting stock despite a product card; Harrison has one unit.
- Source pages:
  - [Jessops — £299, was £349, awaiting stock, VFC01001](https://www.jessops.com/p/nikon/mb-n12-power-battery-pack-grip-204449)
  - [Harrison Cameras — £329, 1 in stock](https://harrisoncameras.co.uk/products/nikon-mb-n12-power-battery-pack-for-z8-vfc01001)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Nikon%20MB-N12%20Battery%20Pack%20Standard%20Item%20UK%20price

### 14. SmallRig RC100B
- Product ID: 681d9e3a-6c48-4d25-ae80-b43fb81aa782
- Package: RC100B COB LED Video Light Pro Version UK Standard 5143
- Observed price: £218.40 inc VAT / £182 ex VAT ProAV; £242.90 eBay UK; USD $249.99 SmallRig reseller.
- Condition: New.
- Availability: ProAV page says In Stock and also backorder delivery typically within 5 weeks; eBay SmallRig Direct UK Store 3 available; SmallRigReseller 1 in stock.
- Visible note: RED VERIFY — exact Pro Version/UK Standard SKU 5143. ProAV stock wording is contradictory and needs phone confirmation. SmallRigReseller price is USD, not GBP. Google Shopping results included RC100C lights/accessories; those are not exact RC100B matches.
- Source pages:
  - [ProAV — £218.40 inc VAT, SKU SR-5143, conflicting in-stock/backorder message](https://proav.co.uk/smallrig-rc-100b-cob-led-video-light-pro-version)
  - [eBay UK — SmallRig RC100B 5143, £242.90, new, 3 available, SmallRig Direct UK Store](https://www.ebay.co.uk/itm/376205386123)
  - [SmallRigReseller — UK Standard 5143, USD $249.99, 1 in stock](https://www.smallrigreseller.com/smallrig-rc-100b-cob-led-video-light-pro-version-uk-standard-5143.html)
- Google Shopping: https://www.google.com/search?tbm=shop&q=SmallRig%20RC100B%20RC100B%20COB%20LED%20Video%20Light%20Pro%20Version%20UK%20Standard%205143%20UK%20price

### 15. Sony NXLK-IP50Y
- Product ID: 6bb402b5-9124-482e-b3fd-4eb1ec51cdc1
- Package: Standard
- Observed price: No UK GBP price found. Official Sony Japan list price JPY 1,694,000 including tax.
- Condition: Official product information.
- Availability: Official Sony Japan product page; no UK stock or price.
- Visible note: RED VERIFY — Sony Japan page confirms SDI-IP converter board, 4K/HD SDI-to-ST 2110 IP conversion and SFP28 interface; included item is operation manual. Do not convert JPY to GBP. Ask UK broadcast suppliers for GBP quote and lead time.
- Source pages:
  - [Sony Japan official NXLK-IP50Y product page and JPY list price](https://www.sony.jp/nxl/products/NXLK-IP50Y/)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20NXLK-IP50Y%20Standard%20UK%20price

### 16. Sony HDC-1500
- Product ID: 6d0ab23c-abbe-45ab-b4b3-6701937ca27c
- Package: Standard Package
- Observed price: £8,900.00 or Best Offer for a used camera channel; another multi-channel package is price on application.
- Condition: Used.
- Availability: eBay UK N.I. Broadcast listing showed 10 available; KitPlus listing is price on application.
- Visible note: RED VERIFY — eBay title says fibre HD camera channel, 1080i/720p, but opened listing does not clearly enumerate whether CCU, RCP, viewfinder, fibre cable or other parts are included. Do not treat £8,900 as a bare camera-head price until seller confirms one channel's contents. KitPlus listing is a larger 6-camera package: five HDC-1500 heads plus one HDC-1500R, six HDCU-1500 CCUs, six RCP-920 panels and six HDVF-730W viewfinders.
- Source pages:
  - [eBay UK — HDC-1500 fibre HD camera channel, £8,900, used, 10 available, N.I. Broadcast](https://www.ebay.co.uk/itm/198054902757)
  - [KitPlus — HDC-1500 multi-camera system package, price on application](https://kitplus.com/for-sale/cameras-and-accessories-1/sony/hdc-1500/44848)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20HDC-1500%20Standard%20Package%20UK%20price

### 17. Sony HDC-3000
- Product ID: 6f5fb923-fe39-4e52-8e20-9abf7d0063e0
- Package: Standard
- Observed price: No exact GBP or other-currency price found.
- Condition: Not established.
- Availability: No exact HDC-3000 product listing found.
- Visible note: RED VERIFY — searches returned HDC-3500, HDC-3200, HSC-300, HDCU-3500 camera control unit and references to an HDC-3000 series, but no exact HDC-3000 camera product page or seller offer. Confirm whether catalogue model is a series label, typo or distinct model before attaching related camera prices.
- Source pages:
  - [Google Shopping search for exact Sony HDC-3000](https://www.google.com/search?tbm=shop&q=Sony+HDC-3000+studio+broadcast+camera)
  - [Sony UK HDC-P50A article mentioning HDC-3000 series compatibility; not an HDC-3000 listing](https://www.sony.co.uk/presscentre/sony-introduces-the-hdc-p50a-a-multi-purpose-camera-supporting-smpte-st-2110-ip-transmission-and-camera-control-unit-connection-for-a-simple-and-versatile-system-integration)
  - [Sony HDCU-3500 CCU page; related system, not the HDC-3000 camera](https://pro.sony/fr_LU/products/camera-control-unit/hdcu-3500)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Sony%20HDC-3000%20Standard%20UK%20price

### 18. Pentax HD PENTAX-FA 31mm F1.8 Limited
- Product ID: 72838f15-dd07-43f3-8bae-f7130e83fdce
- Package: Standard
- Observed price: £999.00 Clifton Cameras; £1,099.00 Park Cameras; eBay Japan seller displays £616.17.
- Condition: New retailer offers and used Japan marketplace offer.
- Availability: Clifton awaiting stock; Park page asks user to select options/check availability; eBay listing active when crawled.
- Visible note: RED VERIFY — confirm black/silver finish and exact HD FA 31mm version. eBay seller camera_kyoto_japan is in Kyoto, Japan; shipping/import charges vary. Do not treat Japan offer as UK-local seller price.
- Source pages:
  - [Clifton Cameras — black, £999, awaiting stock](https://www.cliftoncameras.co.uk/pentax-hd-pentax-fa-31mm-f18-limited-lens/lens-colour/black)
  - [Park Cameras — black, £1,099, availability requires selection/check](https://www.parkcameras.com/shop/hd-pentax-fa-31mm-f18-limited-lens-black_5241030e)
  - [eBay UK — used Japan seller lead, £616.17 displayed](https://www.ebay.co.uk/itm/287519627037)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Pentax%20HD%20PENTAX-FA%2031mm%20F1.8%20Limited%20Standard%20UK%20price

### 19. Shure SM81
- Product ID: 738dfe4c-ea96-4547-80fc-cdf403e967d7
- Package: SM81
- Observed price: £381.00 Andertons; £405.00 Stage Supply; £399.00 guitarguitar; £430.80 Amber Sound; £439.00 OnBuy plus delivery.
- Condition: New.
- Availability: Andertons 1 in stock; Stage Supply 8 available online with further supply 1–3 weeks; guitarguitar in stock; Amber Sound backordered; OnBuy listed in stock.
- Visible note: RED VERIFY — retailer pages commonly identify SM81-LC. LC denotes microphone package without cable; check whether catalogue SM81 package expects cable/stand adapter/case. Prices are retailer asking prices, not used evidence.
- Source pages:
  - [Andertons — £381, 1 in stock](https://www.andertons.co.uk/shure-sm81-condenser-mic/)
  - [Stage Supply — £405 inc VAT / £337.50 ex VAT, 8 available online, SM81-LC](https://stagesupply.co.uk/product/shure-sm81-cardioid-condenser-instrument-microphone/)
  - [guitarguitar — SM81-LC, £399, in stock](https://www.guitarguitar.co.uk/product/13040917344332--shure-sm81-lc)
  - [Amber Sound — £430.80, backordered](https://ambersound.co.uk/products/shure-instrument-condenser-microphone)
  - [OnBuy — £439 plus £4.95 delivery](https://www.onbuy.com/gb/p/shure-sm81-condenser-instrument-microphone~p20834907/)
- Google Shopping: https://www.google.com/search?tbm=shop&q=Shure%20SM81%20SM81%20UK%20price

### 20. RED Digital Cinema DSMC2 GEMINI
- Product ID: 75ae9fed-cf40-437e-922f-516369c329f9
- Package: DSMC2 GEMINI 5K S35
- Observed price: DigiBroadcast £7,200 inc VAT / £6,000 ex VAT; eBay UK £4,342.25; eBay Japan £2,540.17 and £2,347.95 displayed; Visuals historic sold listing £7,140 inc / £5,950 ex.
- Condition: Used; DigiBroadcast Great Condition, 765 hours, 3-month warranty. eBay Japan near mint.
- Availability: DigiBroadcast usually dispatches within 24 hours; eBay listings active when crawled; Visuals page now 404 and marked sold.
- Visible note: RED VERIFY — DigiBroadcast direct page switched to GBP and was opened: exact product, 765 hours, Great Condition, 3-month warranty. Contents: RED DSMC2 Gemini, 4-inch touchscreen, side handle, two 2TB Kippertie mags with hard case, mag reader, EF and PL mounts, two Pogo cables, Wooden Camera A-Box, pass-through top plate and trigger handle, power cable, Tentacle timecode cable, Low Light OLPF and V-lock I/O expander. eBay UK private seller in Newark has lower £4,342.25 asking price but accessories/condition need checking. Japan eBay sellers display GBP but are located in Japan; shipping/import not included. Visuals page sold/404, historical only.
- Source pages:
  - [DigiBroadcast — £7,200 inc VAT / £6,000 ex, 765 hours, Great Condition, 3-month warranty and contents](https://www.digibroadcast.com/used-equipment-c211/camcorders-c213/red-gemini-dsmc2-5k-s35-765-hours-used-p47765)
  - [eBay UK — £4,342.25 or Best Offer, used private seller in Newark](https://www.ebay.co.uk/itm/296570338282)
  - [eBay UK — near-mint Japan seller, £2,540.17 displayed](https://www.ebay.co.uk/itm/298620988955)
  - [eBay UK — near-mint Japan seller, £2,347.95 displayed](https://www.ebay.co.uk/itm/900036256597)
  - [Visuals — historic sold page £7,140 inc VAT / £5,950 ex VAT; now 404](https://www.visuals.co.uk/red-710-0305-dsmc2-gemini-5k-s35-used.html)
- Google Shopping: https://www.google.com/search?tbm=shop&q=RED%20Digital%20Cinema%20DSMC2%20GEMINI%20DSMC2%20GEMINI%205K%20S35%20UK%20price

## 4. Google Shopping click-through audit

- Sony RM-BR300H: Shopping card led to BMI Surplus. Direct seller page displays USD $449.95, not converted GBP; retained USD only. N.I. Broadcast UK offer is base RM-BR300, not H suffix.
- PowerDolphin battery: Shopping results included PowerDolphin drone products rather than the battery; those were not matched. Exact PDOIB10 replacement battery pages were found separately.
- HVR-Z5U: Shopping results included HVR-Z5E and HVR-Z5J variants; suffix mismatch recorded. Exact U model pages were found separately.
- Pentax WG-90: Shopping card showed Jessops £299, but direct Jessops page showed £379; HDEW £235 card was not independently verified.
- NP-FV70: Shopping returned NP-FV90/NP-FV100 and other battery variants; not accepted as exact NP-FV70 evidence.
- HDC-F5500V: exact Visuals product card opened and direct page confirmed SKU and price.
- Pentax DA*55: Shopping surfaced Bristol Cameras £799; direct Bristol page confirmed £799, product code 21790 and included accessories.
- Panasonic GF7: Shopping surfaced Japan eBay offers; direct UK body-only listing £186.69 and UK lens-kit leads were checked separately.
- Sony FE 35mm GM: Shopping surfaced Wex used and Amazon Renewed prices. Wex direct listings were opened; Amazon page was not accessible, so Renewed remains a lead.
- Skydio X2E: no reliable UK Shopping offer found; exact US eBay offer retained in USD.
- Sony FE 28-60: Shopping eBay card price differed from opened direct eBay listings; multiple UK used listings retained separately.
- Nikon F55: Shopping surfaced sold-out and body/kit variants; direct pages show different prices and packages.
- Nikon MB-N12: Shopping card Jessops £299 was confirmed on direct page, which says awaiting stock.
- SmallRig RC100B: Shopping results included RC100C lights/accessories; those are not exact matches. Exact RC100B 5143 UK eBay and ProAV pages were opened.
- Sony NXLK-IP50Y, HDC-1500, HDC-3000, Pentax FA31, Shure SM81 and RED Gemini: product cards were absent or weak; direct official/retailer/marketplace pages were searched and opened where available.

## 5. Owner-auth check and queue staging

LIVE owner-auth context was checked before any write:
- current_user = postgres
- auth.uid() = null
- auth.role() = null
- platform_cloud_ai_owner_check() = false

Per instruction, no direct table write, claims impersonation, RLS bypass or unauthenticated owner RPC attempt was made.
- Researched: 20
- New pending_review candidates staged: 0
- Queue staging limitation: owner-auth context unavailable
- No uncertain price entered into automatic valuation
- No master product, schema or valuation changes
- TEST and Stripe untouched

## 6. Next scheduled run

Read this checkpoint and PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-09.md first. Exclude all 20 product IDs above, all IDs in scheduled checkpoints 02–08, all outstanding LIVE queue candidates and outstanding manual AI prompts. Recheck evidence and queue status immediately before selecting and researching the next 20. Use dynamic anti-joins, no SQL OFFSET. Attempt queue staging only through the supported authenticated platform-owner RPC if auth.uid() is non-null and the owner check passes; otherwise create the next checkpoint and project-memory file.

