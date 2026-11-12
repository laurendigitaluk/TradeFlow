# TradeFlow LIVE — Scheduled Market Evidence Research Batch 07

**Research date:** 2026-11-12  
**Repository:** laurendigitaluk/TradeFlow  
**Branch:** production  
**Environment:** LIVE only  
**Scope:** 20 existing active catalogue master products with no active shared_market_evidence at selection time. No catalogue, schema, valuation, tenant, TEST or Stripe changes.

## Preflight: production memory and checkpoints

Read the production-branch scheduled research records before selecting products:

- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-04.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-05.md
- CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-06.md
- PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-06.md

The batch-03 checkpoint exists, but its corresponding PROJECT-MEMORY file was not present in the production directory. The scheduled checkpoint directory currently contains batches 02–06; batch 02 also records the preceding batch-01 exclusion set.

## Selection and exclusion audit

- Extracted and excluded all product UUIDs present in scheduled checkpoint files 02–06 (142 unique UUIDs in the checkpoint extraction used for selection).
- Excluded product IDs from the outstanding manual AI research prompt. LIVE prompt status snapshot: one completed prompt and one ready prompt; the ready prompt covers 20 product IDs.
- Excluded all outstanding LIVE queue candidates by manufacturer/model and any linked LIVE master product ID. Queue status snapshot before selection: 28 imported, 10 needs_research, 43 rejected, 0 pending_review.
- Used a dynamic anti-join against the excluded checkpoint IDs, outstanding manual prompt product IDs, outstanding queue candidates and active shared_market_evidence. No fixed SQL OFFSET was used.
- Selected the next 20 active LIVE catalogue master products with no active shared_market_evidence.
- Rechecked the selected products immediately before research. Each had 0 active evidence, 0 matching outstanding queue candidates and 0 outstanding manual prompt matches.
- Rechecked after research; all 20 still had 0 active evidence, 0 matching outstanding queue candidates and 0 outstanding manual prompt matches.

## Authentication and queue staging

Checked LIVE owner-auth context before any queue write and again after research:

- current_user = postgres
- auth.uid() = null
- auth.role() = null
- public.platform_cloud_ai_owner_check() = false

The supported platform-owner RPCs require an authenticated platform-owner context. No queue write was attempted. No direct table insert, impersonated claim, RLS bypass or alternate write path was used. The 20 findings are preserved in this checkpoint for later authenticated staging.

## Research method and evidence rules

Searched manufacturer sites, UK retailers, specialist AV/camera retailers, marketplaces and product-shopping search results. Opened the actual merchant/product pages where accessible and checked model/package, displayed price/currency, condition and availability.

- Never invent a price or convert USD/EUR/SEK/JPY/other currency into GBP.
- Leave the GBP price blank when a reliable UK GBP price is not visible; record the source-displayed currency and amount in the notes.
- Retain sold-out, ended, backorder, unverified and no-price links.
- Use RED VERIFY for uncertainty, model/package mismatch, conflicting prices or availability.
- Do not treat a bundle price as a standalone-body price.
- Do not import uncertain prices into automatic valuation.
- Google Shopping limitation: direct Google Shopping search URLs (Google search with tbm=shop) were inaccessible to the available browser, and indexed shopping.google.com searches returned only generic guides rather than product-specific offer pages. Product-shopping search results were also queried; merchant leads were opened where accessible. Do not claim that Google Shopping product cards were fully click-verified in this run.

---

## 1. Shure — MV88+ Video Kit

**Product ID:** 3711e70b-84a6-4300-827f-4fd8d3af8f58  
**Package:** MV88+ Video Kit

- [GuitarGuitar product page](https://www.guitarguitar.co.uk/product/190111337421008--shure-motiv-mv88-video-kit) — £259.00; page showed in stock, 2 available. Manufacturer part number MV88+DIG-VIDKIT. Exact Video Kit.
- [Bax Music UK product page](https://www.bax-shop.co.uk/android-ios-microphones/shure-mv88-dig-vidkit-video-kit) — £236.00 inc VAT; in stock, 4 in warehouse plus supplier stock. Exact MV88+DIG-VIDKIT. Contents shown: MV88+ microphone, AMV-88WS windscreen, phone holder, shoe-mount microphone holder, Lightning cable, USB-C cable, Manfrotto PIXI tripod and roll-up pouch.
- [Thomann UK product page](https://www.thomann.co.uk/shure_motiv_mv88_video_kit.htm) — £233.00 incl VAT; in stock and immediately shippable. Contents include Manfrotto PIXI mini tripod, Lightning and USB-C cables, phone clip, clamp microphone holder, neoprene roll-up bag and AMV-88WS windscreen.
- [Electronic Centre product page](https://electroniccentre.co.uk/products/shure-mv88-video-kit-microphone) — £239.00 displayed. Page description confirms Manfrotto PIXI tripod, phone clamp/mount and iOS/USB-C cables; stock status not clearly exposed in the opened page.

**Finding:** Exact product and package confirmed across multiple UK retailers. Current observed UK range £233–£259.  
**Verification:** No model/package mismatch identified. Check checkout price and stock before treating any individual offer as live.

## 2. Skydio — Skydio 2+ Sports Kit

**Product ID:** 384cb481-e8fd-47b1-9d12-befdf5a4a3f1  
**Package:** Sports Kit

- [Skydio consumer drone offering FAQ](https://support.skydio.com/hc/en-us/articles/17737443890331-Consumer-Drone-Offering-FAQ) — manufacturer states Skydio 2+ consumer kits, including Sports Kit, have been discontinued. Enterprise kit remains available to Enterprise/Public Sector customers.
- [Skydio official Sports Upgrade page](https://shop.skydio.com/products/skydio-2-plus-sports-kit-upgrade) — $550 USD. This is an upgrade/accessory kit, not the complete Sports Kit drone package. Contents shown: Skydio 2+ Beacon, two Skydio 2+ batteries, dual charger and SanDisk 128GB Extreme microSD. Page says ships within 3–5 business days.
- [Skydio UK sales site](https://skydiouk.com/) — UK sales/contact lead; no verifiable GBP price exposed.

**RED VERIFY:** Do not attach the $550 USD Sports Upgrade price to the complete Sports Kit. Manufacturer says the consumer Sports Kit is discontinued. Check whether any UK seller has remaining complete-kit stock and capture the full drone/controller/battery package and seller status. GBP price blank.

## 3. Sony — SRG-XB25

**Product ID:** 3bca1bc7-000e-4c7c-98ac-bdd212a36617  
**Package:** Standard

- [SCAN UK SRG-XB25W product page](https://www.scan.co.uk/products/sony-srg-xb25-box-style-remote-camera-white-1-25-cmos-4k-60p-25x-optical-zoom-poe-hdmi) — £2,799.98; white SRG-XB25W, 1/2.5-inch CMOS, 4K 60p, 25x optical zoom, PoE and HDMI. Page says awaiting ETA and pre-order.
- [Converge Technology UK product page](https://www.convergetp.co.uk/sony-srg-xb25-conference-camera-colour-8-5-mp-3840-x-2160-motorized-audio-wired-hdmi-h-264-h-265-dc-12-v-poe-1tsecspd-003540/) — search result displayed £1,210 ex VAT / £1,452 inc VAT, manufacturer code SRG-XB25W, checking delivery. Direct page returned HTTP 410 when opened.

**RED VERIFY:** Two UK price leads differ substantially (£1,452 inc VAT versus £2,799.98). The Converge page is no longer accessible and its stock/delivery cannot be confirmed. SCAN is awaiting ETA. Verify current seller quote, stock and exact white/black colour before approving either price.

## 4. Hubsan — H501S X4 Air

**Product ID:** 3ec6cf28-d691-4e70-a15a-b90f8c5ebf3d  
**Package:** H501S X4 Air

- [eBay UK used H501S X4 Air with range extender](https://www.ebay.co.uk/itm/396841988479) — £207.25 or Best Offer; used; private seller in Ryde, UK; 75% positive feedback; no returns accepted. Exact H501S X4 Air title and range extender.
- [eBay UK sold H501S X4 Air standard listing](https://www.ebay.co.uk/itm/137140926562) — £57.42 including buyer-protection fee; sold 2 September 2026; condition Opened – never used; private seller. Historical completed listing, not current stock.
- [eBay UK H501S X4 Air two-drone lot](https://www.ebay.co.uk/itm/306936247752) — £104.70 or Best Offer for two used H501S X4 Air drones; private seller in Walsall, UK. Package is a two-unit lot, not a single drone.
- [Gumtree UK new H501S X4 Air listing](https://www.gumtree.com/p/drones/new-hubsan-drone-x4-air-h501s/1507338545) — £139; described as brand new in box, Standard Edition, brushless, 1080p. Listing page returned HTTP 410 when opened; search record was crawled five months ago.
- [OnBuy Hubsan H501S X4 listing](https://www.onbuy.com/gb/p/hubsan-h501s-x4-58g-fpv-brushless-with-1080p-hd-camera-gps-rc-drone-quadcopter-bnf~p82790489/) — search result lead displayed £543.15 for a new BNF package; direct page returned 404. Seller, availability and bundle contents cannot be checked.

**RED VERIFY:** Retain all leads, but distinguish single drone, range-extender package and two-drone lot. eBay £207.25 is a private-seller used asking price with no returns; Gumtree and OnBuy pages could not be verified directly. Do not treat the ended £57.42 listing as a current offer.

## 5. Nikon — AF-S DX Nikkor 18-55mm f/3.5-5.6G VR

**Product ID:** 3f8caa8b-3436-4124-badb-63fb16b3b272  
**Package:** Lens

- [MPB UK exact lens page](https://www.mpb.com/en-uk/product/nikon-af-s-dx-nikkor-18-55mm-f-3-5-5-6g-vr) — 58 available used, £35–£67. Condition examples: Well Used £35, Good £62, Excellent £67.
- [London Camera Exchange used lens listing](https://www.lcegroup.co.uk/Used/Nikon-AF-S-18-55mm-f/3.5-5.6G-DX-VR-%5B4*%5D-%7C-10120321_501856.html) — £59.99; 4-star Good condition; Guildford branch; in store now, next-working-day home delivery available subject to confirmation.

**Finding:** Exact AF-S DX VR lens, not VR II or AF-P.  
**Verification:** No significant mismatch. Check exact cosmetic condition and included caps/accessories on each used unit.

## 6. Nikon — F2 Photomic SB

**Product ID:** 42ab017d-69c0-4401-b7dc-9eea35d84722  
**Package:** Standard

- [eBay UK Nikon F2 Photomic SB DP-3 black near-mint listing](https://www.ebay.co.uk/itm/318878210211) — search result displayed £335.23; used, near-mint; seller in Japan, private seller, 99.3% positive.
- [eBay UK Nikon F2 Photomic SB DP-3 black near-mint body](https://www.ebay.co.uk/itm/407222967268) — search result displayed £340.76; used, near-mint; seller in Japan, private seller, 100% positive.
- [eBay UK Nikon F2 Photomic SB DP-3 silver with strap](https://www.ebay.co.uk/itm/800555492684) — £346.29 including buyer protection; used, MINT description; listing ended 28 August 2026 because item no longer available; seller in Japan, private seller.
- [eBay UK Nikon F2 SB Photomic DP-3 black UK listing](https://www.ebay.co.uk/itm/278383948832) — ended 27 September 2026; £660 displayed auction figure, 0 bids, £973 Buy It Now; used, seller in Bucks, UK, private seller, 100% positive, no returns.

**RED VERIFY:** All exact DP-3/SB leads are used listings, with three Japan-based sellers and import/delivery considerations. The UK £660 figure was an ended listing with zero bids, not a completed sale. Check whether the catalogue standard package expects body and DP-3 finder only or includes strap/accessories.

## 7. Skydio — X10 Ready Case Kit

**Product ID:** 43025083-45ca-41ba-9997-acd9fc1135f5  
**Package:** Ready Case Kit

- [Skydio official X10 kit and case-layout guide](https://support.skydio.com/hc/en-us/articles/20370028789019-What-kits-and-software-bundles-are-available-with-Skydio-X10) — official Ready Case layout lists X10 Dual Charger, X10 Controller, spare propellers, 230W fast power supply, X10 battery, X10 drone, 100W power supply and flex spaces. No price is displayed.
- [Maverick authorised dealer — X10 Starter Kit VT300-L](https://www.maverickdrone.com/products/skydio-x10-starter-kit-vt300-l) — $17,900 USD; backordered, about three months. Includes X10 aircraft and VT300-L sensor package; mandatory RTK/PPK attachment $920 and Data Management Suite $1,200 are added. This is a Starter Kit with a different sensor/case package, not the catalogue Ready Case Kit.

**RED VERIFY:** Official Ready Case contents are identified, but no exact Ready Case sale price was found. Do not attach Maverick's $17,900 USD Starter Kit price to the Ready Case package. GBP price blank.

## 8. Z CAM — E2-M5G Cinema Camera

**Product ID:** 445e129d-8513-46ca-87d6-62988841b4fa  
**Package:** Z CAM E2-M5G Cinema Camera

- [B&H eXplora E2-M5G launch article](https://www.bhphotovideo.com/explora/video/news/capture-crisp-action-with-the-z-cam-e2-m5g-global-shutter-cine-camera) — launch coverage for the E2-M5G global-shutter 5K cinema camera; confirms 5K60 and high-speed 4K modes. Article is not a live retail offer and does not provide a verified UK price.
- [Voosestore E2-M5G product page](https://www.voosestore.com/product/z-cam-e2-m5g-cinema-kamera) — 58,995 SEK incl VAT displayed on the opened Swedish-language page; external warehouse, approximately 3–7 days depending on availability. Article number 4734. Currency is SEK, not GBP.
- [Z CAM official company/product-line information](https://www.z-cam.com/support/about/) — current brand history/product-line context; page highlights the E2 Mark II series launched in 2025 but does not provide an E2-M5G price.

**RED VERIFY:** No reliable UK GBP price found. Voosestore page is Sweden-facing and displays SEK 58,995; do not convert. Confirm that the E2-M5G is actually orderable and not a stale catalogue entry before using the external-warehouse estimate.

## 9. Sony — HXC-D70 Standard

**Product ID:** 44ac30d9-9985-4ebb-8548-3caced8ee039  
**Package:** Standard

- [N.I Broadcast — HXC-D70 camera channel with cable, CCU, RCP and monitor](https://www.nibroadcast.com/1x-sony-hxc-d70-hdsdi-high-definition-multicore-camera-channel-with-cable-rcp-ccu-etc..html) — £4,000 per channel; used; page stated 4 available at time of listing. Each channel includes HXC-D70 camera head, HXCU-D70 CCU, approx. 25m multicore cable, modified Sony DVF-L700 7-inch monitor and RM-B150 small remote RCP. Lenses, RCP cable and tripod plate are extra.

**RED VERIFY:** The £4,000 price is for a complete camera channel, not the HXC-D70 camera head alone. Keep the link and package contents explicit; do not attach the bundle price to a body-only valuation without review.

## 10. Manfrotto — Video Alu Tripod with 500X Fluid Head

**Product ID:** 4534d392-cfcf-4ac3-a017-4dad979267bd  
**Package:** Manfrotto Video Alu Tripod with 500X Fluid Head

- [CVP exact MVK500XAM kit page](https://cvp.com/product/manfrotto-video-alu-tripod-with-500x-fluid-head) — £307.50 ex VAT / £369 inc VAT; product number MVK500XAM. Page says in stock in CVP's EU warehouse, expected 2–3 days.

**Finding:** Exact tripod/head kit and product code confirmed.  
**Verification:** Check UK delivery and final landed price because displayed stock is in CVP's EU warehouse.

## 11. Walkera — DEVO-10 Radio + RX1002 Receiver

**Product ID:** 494b619b-5354-4cc4-aee9-d9ac3c0930b8  
**Package:** DEVO-10 Radio + RX1002 receiver

- [BuzzFlyer UK DEVO-10 product page](https://www.buzzflyer.co.uk/Devo-10__p-2298.aspx) — £124.96 ex VAT / £149.95 inc VAT. Product description explicitly says the 10-channel system comes with the RX1002 receiver. Page displays a Notify Me control and does not clearly confirm current stock; page crawl is old.

**RED VERIFY:** Exact radio/receiver package identified, but availability is unclear and the page is stale. Check BuzzFlyer directly before treating £149.95 as a current obtainable price.

## 12. Sony — DSR-400

**Product ID:** 4a0496fd-d9ce-4dc2-8b47-4759e76b5fe6  
**Package:** Standard

- [Sony Japan official DSR-400K product page](https://www.sony.jp/pro/products/DSR-400K/) — manufacturer marks DSR-400K as discontinued. Historical Japanese list price 1,628,000 JPY incl tax. The K package includes a 17x zoom lens, DXF-801 viewfinder, microphone, windscreen, shoulder strap, VCT-U14 tripod adapter, lens cap, back-focus chart, manual and warranty.
- [eBay UK adjacent Sony DSR-450WSP listing](https://www.ebay.co.uk/itm/204360637965) — £499; used; business seller N.I Broadcast Ltd in Craigavon, UK. This is DSR-450WSP, not DSR-400, and is only a nearby-model reference.

**RED VERIFY:** No exact UK DSR-400 Standard GBP sale listing was verified. Sony's historical price is JPY and for DSR-400K with a 17x lens; do not convert or treat it as the Standard package. The DSR-450 listing is a different model and must remain a comparison-only lead.

## 13. Z CAM — ZBlade 4TB for E2-F6 Pro

**Product ID:** 4d423c23-4ff3-4a9a-beb5-039ff4def019  
**Package:** Z CAM ZBlade for E2-F6 Pro 4TB

- [Syntex exact Exascend ZBlade Gen4 4TB page](https://www.syntex.tv/exascend-zblade-gen4-storage-for-z-cam-e3-f6-pro-4tb) — SKU EXP4M6G004TB; €2,049 incl VAT / €1,693.39 ex VAT; availability on request. Product description says certified for Z CAM E2-F6 Pro. Page title/URL says E3-F6 Pro, while description says E2-F6 Pro.
- [CVP Exascend ZBlade Pro 1TB/2TB/4TB page](https://cvp.com/product/exascend-zblade-pro-portable-ssd-zcam) — product family page confirms 1TB, 2TB and 4TB capacities and 4TB performance specs. Static page price £665.99 inc VAT is not clearly tied to the 4TB variant; do not use it as the 4TB price.

**RED VERIFY:** Syntex is the exact 4TB SKU but EUR and availability on request; page title has a model typo. CVP's visible/default price is not proven to be the 4TB option. GBP price blank.

## 14. Sony — PMW-F55

**Product ID:** 4ecf0857-2b22-49bd-8755-9845a5c24dd4  
**Package:** Standard Package

- [eBay UK Sony PMW-F55 body-only listing](https://www.ebay.co.uk/itm/236722363296) — £1,099 or Best Offer; used body only; business seller Refresh_IT_Store, 96.6% positive feedback.
- [ES Broadcast used Sony PMW-F55 listing](https://esbroadcast.com/product/used-sony-pmw-f55-4k-digital-cinema-camera/) — search result showed £9,750 ex VAT; used, described as very good with 1,090 hours. Direct page returned HTTP 503 when opened, so full package/stock could not be checked.
- [eBay/European PMW-F55 product lead](https://www.ebay.co.uk/sch/i.html?_nkw=Sony+PMW-F55) — product-search lead surfaced non-GBP offers as well; no non-GBP amount is converted.

**RED VERIFY:** Large price difference likely reflects body-only versus different package/accessories and condition. ES Broadcast page could not be opened. Check exact contents, operating hours, accessories and seller availability before comparing.

## 15. Nikon — S3M

**Product ID:** 4f7e69c9-9638-4edd-bdff-9be4772a5a50  
**Package:** Standard

- [CameraWorth Nikon S3M sales-history page](https://www.cameraworth.com/n/nikon/s3m/) — exact 1960 Nikon S3M half-frame rangefinder sales index. Page lists auction sales including EUR 15,000 Leitz Auction (chrome, June 2024) and other historic EUR auction results. The page also presents GBP-normalised estimates/price ranges; those are not direct UK GBP seller prices and must not be treated as observed GBP offers.
- [Leitz Photographica Auction](https://www.leitz-auction.com/en/) — auction source linked from the CameraWorth sales record.

**RED VERIFY:** No current UK GBP retail offer found. Exact version (chrome/black, motor/no motor, lens/outfit) materially affects value. Leave GBP price blank; retain raw auction currencies and check exact variant. Do not use a converted index estimate as a UK asking price.

## 16. Z CAM — IPMAN Gemini Pro

**Product ID:** 4fd9b673-e12f-4087-9f10-312ac85ef170  
**Package:** Z CAM IPMAN Gemini Pro Dual HDMI to USB Converter

- [ProAV Z CAM catalogue page](https://proav.co.uk/shop-by-brand/z-cam) — exact IPMAN Gemini Pro listing £39.99 ex VAT / £47.99 inc VAT. Backorder; delivery when in stock, usually within 7 working days, subject to change.
- [Z CAM official IPMAN Gemini Pro product page](https://www.z-cam.com/products/others/ipman-gemini-pro/ipman-gemini-pro/) — manufacturer page confirms dual HDMI to single USB converter; recommended retail price USD $49.90 and original scheduled ship date September 2021.

**Finding:** Exact product identity and UK GBP price found.  
**Verification:** ProAV is backorder, not confirmed immediate stock. Manufacturer USD MSRP is historical and not converted.

## 17. Sony — HDCU-3500

**Product ID:** 4fedfd46-1dc5-4b63-a27b-15e0bf0cf108  
**Package:** Standard

- [Axis-One HDCU-3500//U product page](https://axis-one.be/products/cameras/system-cameras/control-units/portable-fiber-ccu-for-hdc-3100-3500/) — €14,400 ex VAT; exact SKU HDCU-3500//U; page offers Add to Cart. No UK GBP price and no clear stock status.
- [KitPlus used Sony HDC-3500 camera channel](https://kitplus.com/for-sale/cameras-and-accessories-1/sony/hdc-3500u/31737) — £31,000 + VAT; used, UK premium dealer. Bundle includes HDC-3500 camera, HDCU-3500 CCU, HZCU-UHD35 4K HDR software licence, RCP-3500 and HDVF-EL75 viewfinder. This is a complete camera channel, not standalone HDCU-3500.

**RED VERIFY:** Standalone exact HDCU-3500 price found only in EUR. The UK £31,000 + VAT listing is a different complete system bundle; do not attach that price to the standalone CCU.

## 18. Leica — M11 Monochrom

**Product ID:** 511f350a-d1c9-4aca-9f6d-b04fe5a5a3d0  
**Package:** Leica M11 Monochrom

- [Leica official UK store](https://leica-camera.com/en-GB/photography/cameras/m/m11-monochrom/shop-now) — £8,500 incl VAT; delivery available in 3–5 business days; reserve/collect and add-to-cart shown.
- [Camera Centre UK](https://www.cameracentreuk.com/leica-m11-monochrom-rangefinder-camera) — £8,300; in stock; free shipping.
- [The Classic Camera UK](https://theclassiccamera.com/product/leica-m11-monochrom-pre-order/) — £8,100; page shows 1 in stock, add to basket and free UK next-day delivery, but a separate section on the same page contains a pre-order form. Availability text is contradictory.
- [Clifton Cameras](https://www.cliftoncameras.co.uk/leica-m11-monochrom) — £8,500; pre-order; page says stock was due September 2026, a date already passed at this research date.
- [Park Cameras](https://www.parkcameras.com/shop/leica-m11-monochrom-camera_l014467e) — £8,500; UK retailer page, stock/dispatch not clearly stated in the search result.

**Finding:** Exact product; UK retail price leads £8,100–£8,500.  
**RED VERIFY:** Check The Classic Camera's contradictory stock/pre-order messaging and Clifton's stale September 2026 stock estimate. Confirm checkout availability before treating the lowest price as immediately obtainable.

## 19. Sony — HDC-5500RV

**Product ID:** 5138a9c6-5f19-41c4-8347-64014bfc8c21  
**Package:** Standard

- [Sony Professional official HDC-5500RV page](https://pro.sony/en_FI/products/4k-and-hd-camera-systems/hdc-5500rv) — exact model and 2/3-type 4K 3-CMOS system-camera specifications; price by contact/where-to-buy, no GBP price.
- [Teltec HDC-5500RV product page](https://teltec.de/sony-hdc-5500rv.html) — exact HDC-5500RV, article number 12352095; price on request; delivery date unconfirmed.
- [Visual Impact HDC-5500 listing](https://www.visuals.co.uk/sony-hdc-5500.html) — £50,030 ex VAT / £60,036 inc VAT; 3+ in stock. This is HDC-5500 without the RV suffix, so it is not an exact match.

**RED VERIFY:** Exact RV model has no visible price; the £60,036 listing is the related HDC-5500, not HDC-5500RV. Keep it as a close-model comparison only.

## 20. Parrot — Jumping Race Max

**Product ID:** 52023314-a46b-4652-b6e9-eba5c72a9ed0  
**Package:** Standard

- [MediaMarkt Spain exact Jumping Race Max red product page](https://www.mediamarkt.es/es/product/_drone-minidrone-jumping-race-max-rojo-1289703.html) — €159 incl VAT; exact Parrot Minidrone Jumping Race Max, red, article 1289703. Home delivery and store collection both unavailable.
- [Zavvi UK Jumping Race EVO Jett listing](https://www.zavvi.com/p/toys-radio-control/parrot-minidrones-jumping-racing-evo-drone-jett/11352472/) — historical £39.99 sold-out price from search result, but this is Jumping Race EVO Jett, not Jumping Race Max. Current URL redirects to Zavvi's administration notice; ZavviGroup ceased trading on 12 October 2026 and says it cannot fulfil orders.
- [Allegro Parrot Jumping Race Max camera/housing accessory](https://allegro.pl/produkt/kamera-i-obudowa-pf070134aa-b52625a7-4b9f-450d-afaf-d2a1a4defc00) — 2.87 PLN; accessory camera and housing only, not the complete drone. Not a comparable drone price.

**RED VERIFY:** Exact Jumping Race Max price found only in EUR and sold out/unavailable. The Zavvi £39.99 lead is a different Jett variant and Zavvi is in administration; do not attach it as an exact Max price. GBP price blank.

---

## Final batch audit and next-run instructions

- 20 product IDs researched and recorded above.
- 20/20 still have zero active shared_market_evidence after research.
- 20/20 still have zero matching outstanding queue candidates.
- 20/20 still have zero outstanding manual prompt matches.
- No new queue candidates were staged because auth.uid/auth.role are null and owner check is false.
- No direct database writes or RLS bypasses.
- No uncertain price was added to automatic valuation.
- No master product, schema, valuation, TEST or Stripe change was made.
- Google Shopping direct product-card click-through remains a limitation: Google Shopping search pages were inaccessible, so merchant-page leads found through other search/product results were opened where possible.

**Next scheduled run:** Read this Batch 07 checkpoint and PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-07.md first. Exclude all 20 product IDs above, every product ID from scheduled checkpoints 02–07, outstanding LIVE queue candidates and outstanding manual AI prompts. Recheck evidence/queue/prompt status immediately before research. Select the next 20 dynamically without SQL OFFSET. Stage only through the supported authenticated platform-owner RPC if a real owner-auth context is present; otherwise create the next checkpoint and project-memory files and do not write to the queue.
