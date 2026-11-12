# TradeFlow LIVE — Scheduled Market Evidence Batch 10

- Research date: 2026-11-12
- Branch: production
- Scope: LIVE catalogue only
- Batch size: 20 products
- Status: researched and checkpointed; not staged to the LIVE review queue
- Prior checkpoint read: CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md and PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md, plus scheduled batches 03 through 09 and latest batch-09 project memory.
- Latest previous checkpoint before selection: batch 09.

## Selection and exclusion method

Selected the next 20 active LIVE catalogue master products using a dynamic query ordered by catalogue creation time and product ID. No fixed SQL OFFSET was used.

Excluded:
1. Every UUID found in scheduled market-evidence checkpoints 02 through 09.
2. Products covered by any manual AI research prompt (all prompt product ID arrays were excluded, a stricter exclusion than outstanding prompts alone).
3. Products matching outstanding LIVE research-queue candidates by manufacturer and model.
4. Any product with an active shared_market_evidence record.
5. The known duplicate identity Nikon Ai-S NIKKOR 28mm f/2, previously called out in project memory.

Immediately before researching, all 20 selected rows were rechecked:
- active = true for all 20;
- active shared_market_evidence count = 0 for all 20;
- outstanding research-queue matches = 0 for all 20;
- manual prompt matches = 0 for all 20.

## LIVE owner-auth check and staging decision

Checked the current LIVE database auth context before any queue operation:
- current database user: postgres
- auth.uid(): null
- auth.role(): null
- platform_cloud_ai_owner_check(): false

Per instruction, no platform-owner RPC was invoked without an authenticated owner context. No direct table writes, impersonated claims, RLS bypass or alternate write path were used. Result: 0 candidates staged to platform_catalogue_research_queue; all findings are preserved in this checkpoint and the matching project-memory file for the next scheduled run.

## Research method and limitations

Searched manufacturer sites, UK retailers, marketplaces, eBay and product/Shopping results. Actual merchant product pages were opened wherever the browser exposed a usable page. Search and Shopping result cards were not treated as verified product pages unless a matching merchant page was opened. Several Shopping cards were mismatches or their merchant URL could not be resolved through the browser; those are retained as Shopping query leads with RED VERIFY notes rather than being silently discarded.

Direct Google Shopping pages using the tbm=shop endpoint were not accessible to the research browser. Product-search/Shopping cards and Google Shopping query links are preserved per product. Exact merchant product pages were opened from web search where possible. No claim is made that every Shopping card merchant page was independently verified.

No price was invented. No non-GBP price was converted to GBP. Where no reliable UK GBP price was visible, the GBP price is explicitly blank and the source's displayed currency and amount are retained in notes. Sold-out, unverified, old, foreign, incomplete-package and near-match listings are retained with reasons to check.

## Batch summary

| # | Product ID | Product / package | Main finding |
|---:|---|---|---|
| 1 | 75fabe8a-7cd8-4419-9cc3-235443d881a3 | Sony HDC-5500 — Standard | £60,036.00 inc VAT (£50,030.00 ex VAT) at Visual Impact; 3+ in stock. KitPlus used listing £54,000. |
| 2 | 7996f27d-337c-4536-85cf-ec32486c3730 | Sony LMD-A240 — Standard | £3,030.00 inc VAT (£2,525.00 ex VAT) ProAV; £3,156.56 inc (£2,630.47 ex) Visual Impact; £2,525 ex VAT Videonorm. Used: £1,560 inc (£1,300 ex) Visual Impact; £1,150 eBay. |
| 3 | 7a2977a9-6d59-4a75-9470-c29c08a31d3f | Pentax K-X — Body | £125.99. |
| 4 | 7b6c5851-a821-4365-9710-bd83d727fd49 | Sony FE 100-400mm F4.5-5.6 GM OSS II — Standard | Exact target price blank. Closest first-generation FE 100-400mm F4.5-5.6 GM OSS (SEL100400GM) £2,149 inc VAT. Different current FE 100-400mm F4.5 GM OSS (SEL100400MCW) £4,399 inc VAT. |
| 5 | 7bfcbbdc-a7bf-465b-bc34-808422e25bc0 | Potensic T18 — Standard Package | £62.58 or Best Offer. |
| 6 | 7d1bd30b-b955-4b3c-a2a9-6ec653e2a04d | Sony EVI-D90 — Standard | Exact UK standalone camera price blank. UK HSSL Vaddio/Sony EVI-D90 SD PTZ system search result £880.56. US direct camera listing USD $959.00; GBP price blank. |
| 7 | 7e4c7a09-cb59-4a59-90a3-55b1f204ccca | Tamron SP 15-30mm F/2.8 Di VC USD G2 — Standard Item | MPB Nikon fit £569-£624 used; MPB Canon EF fit £489 used; Ffordes eBay Nikon fit £599 used; private eBay listing £463.08 used; Japan eBay listing £393.51 used. |
| 8 | 7e5d3f2e-c814-434e-96a7-80118c70830b | Sony PMW-160 — Standard | SLRHut page A £4,071.67; SLRHut page B £3,664.61. Yahoo Japan ended auction JPY 64,980; GBP price blank. |
| 9 | 7efe0b3c-cb0c-4649-b93e-9a0f05c71ac7 | Sony XVS-G1 — Standard | C2S Media £20,765.70. Google Shopping/product card showed ProAV £29,067.40, but that price was not confirmed on the opened ProAV page. |
| 10 | 8399292b-f81c-4a0e-9344-bddb3c7d732b | Sony PMW-150 — Standard | Alfatec £3,766.56 ex VAT / £4,519.87 inc VAT. eBay used £867.15. |
| 11 | 88401408-ada2-44cd-9d24-5fc61383ad86 | Shure MV7+ — MV7+ Podcast Microphone | Shure UK RRP £295.00. ProAV £256.80 inc VAT / £214 ex VAT; SCAN £259; GuitarGuitar £289; Stage Supply £302 inc VAT; Park Cameras £275. |
| 12 | 89c50f7b-f542-4b1c-ac6a-f53e5896b7ee | Skydio Skydio Controller — Standard Item | GBP price blank. Official Skydio store displays USD $179.00. |
| 13 | 8f5cb09a-4069-4f4b-ade5-e9866f84b086 | Shure MoveMic Two — MoveMic Two | Shure UK £221.00 sale display / £369.00 displayed RRP. Canford £305 ex VAT; Clifton £335. |
| 14 | 8fbf5c30-6222-4c19-8a0b-b07c1659127b | Sony SRG-A40 — Standard | CVP £3,082.80 inc VAT (£2,569 ex); Production Gear same; Northamber £2,796.71 ex; SCAN £4,299.98; Currys Business £3,635.98 inc; TopAV £5,054.39 inc. |
| 15 | 90917fa8-dbc3-4aed-9650-e73d8e35692f | Sony HDC1500R — Standard Package | Exact HDC1500R price blank. Closest HDC1500 (without R) eBay listing £8,010 used. |
| 16 | 93aecd5f-ad0d-4aac-95ec-b7094e8caec1 | Sony VG-C3EM Vertical Grip — Accessory | New Sony UK £239.00. MPB used £61-£81. Park / Clifton / LCE new £239. |
| 17 | 94bb730e-b137-4778-b335-173aca953d99 | Sony FE 28-135mm F4 G OSS — Standard | Sony UK page shows £1,799 sale / £1,999 original in bundle-offer section. Cotswold £1,499. Park £1,999. Camera Centre £1,999. MPB used £514-£1,099. eBay Japan listing £1,152.87. |
| 18 | 95c66087-a0b7-4682-b96c-705706295858 | Sony PDW-U1 — Standard | eBay used £155.58; £208.63; £1,459.95. Google Shopping cards also showed £114 Visual Impact, £299 eBay and £334.12 VCRShop, not directly verified. |
| 19 | 9709e49e-c48a-41b8-abcd-cbf4599d09e9 | Shure MoveMic Two Receiver Kit — MoveMic Two Receiver Kit | Shure official RRP £519.00; official search result showed a £311.40 offer but the opened page shows £519.00. DigiBroadcast £496.80 inc VAT / £414 ex; Canford £517.20 inc / £431 ex; Leisuretec £517.20 inc; Bax search/page lead £439 inc (Shopping card £419); Clifton £474. |
| 20 | 992a246f-db39-44e6-9c07-c25a82175e98 | Sony HDC3100 — Standard Package | £25,066.80 inc VAT (£20,889.00 ex VAT) at Visual Impact; available to order, not currently held in stock. |

## Detailed product records

### 20. Sony HDC3100 — Standard Package
- **LIVE master product ID:** 992a246f-db39-44e6-9c07-c25a82175e98
- **Catalogue category:** Video Cameras / Cinema Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** £25,066.80 inc VAT (£20,889.00 ex VAT) at Visual Impact.
- **Condition:** New listing.
- **Availability:** Available to order; Visual Impact says it is not currently held in stock and must be ordered from the supplier.
- **Notes:** RED VERIFY — exact HDC-3100 SKU and price confirmed on the opened Visual Impact page. The page's In The Box list only names the operating instructions, cable clamp belt, screws and labels; it does not list a CCU, lens or viewfinder. The description says the camera connects to an HDCU-3100/HDCU-2000 series CCU. Confirm whether the catalogue Standard Package is camera head only and whether any CCU/viewfinder/lens are excluded. Do not assume the £25,066.80 includes the complete camera channel.
- **Google Shopping:** Exact HDC-3100 result appeared at Visual Impact for £25,066.80. Merchant page was opened and verified; Shopping result and direct page align.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20HDC3100%20Standard%20Package%20UK
- **Sources opened / retained:** [Visual Impact — Sony HDC-3100, £25,066.80 inc VAT / £20,889 ex VAT, available to order](https://www.visuals.co.uk/hdc-3100-camera.html)


### 1. Sony HDC-5500 — Standard
- **LIVE master product ID:** 75fabe8a-7cd8-4419-9cc3-235443d881a3
- **Catalogue category:** Video Cameras / Studio-Broadcast Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** £60,036.00 inc VAT (£50,030.00 ex VAT) at Visual Impact; 3+ in stock. KitPlus used listing £54,000.
- **Condition:** New listing at Visual Impact; used listing at KitPlus.
- **Availability:** Visual Impact says 3+ in stock. KitPlus listing is a used offer published 24 Feb 2025; current availability needs reconfirmation.
- **Notes:** RED VERIFY — Visual Impact SKU HDC-5500//U identifies the camera, but the page does not give a complete included-items list. KitPlus describes a used camera head package containing 1x HDC-5500, 1x HDCU-5500 and installed HZC-PRV50, HZC-UHD50 and HZC-HFR50 options. Do not compare the £54,000 package directly with the standard camera-only record until contents are confirmed. Shopping product cards also surfaced HDC-F5500V, which is a different model.
- **Google Shopping:** Shopping cards included an HDC-F5500V result rather than a confirmed HDC-5500 offer. Exact Shopping merchant link not verified; use the Shopping query below.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20HDC-5500%20Standard%20UK
- **Sources opened / retained:** [Visual Impact UK — HDC-5500//U, £60,036 inc VAT, 3+ in stock](https://www.visuals.co.uk/sony-hdc-5500.html); [KitPlus — used HDC-5500 camera head package, £54,000](https://kitplus.com/for-sale/cameras-and-accessories-1/sony/hdc-5500/33631)

### 2. Sony LMD-A240 — Standard
- **LIVE master product ID:** 7996f27d-337c-4536-85cf-ec32486c3730
- **Catalogue category:** Video Production Equipment / Monitor
- **Research date:** 2026-11-12
- **Observed GBP price:** £3,030.00 inc VAT (£2,525.00 ex VAT) ProAV; £3,156.56 inc (£2,630.47 ex) Visual Impact; £2,525 ex VAT Videonorm. Used: £1,560 inc (£1,300 ex) Visual Impact; £1,150 eBay.
- **Condition:** New and used listings.
- **Availability:** ProAV shows an in-stock label but also says backorder, usually within 10 working days. Visual Impact new listing is available to order. Visual Impact used has 2 in stock. eBay used listing has one item.
- **Notes:** RED VERIFY — ProAV availability wording conflicts. Visual Impact used page is two units in stock at £1,560 inc VAT. eBay seller is a UK business with 100% feedback, but the £1,150 used listing states Good condition and no returns. Keep new and used evidence separate.
- **Google Shopping:** Shopping search surfaced a Visual Impact price lead around £3,187.51; the current opened Visual Impact product page shows £3,156.56 inc VAT. Use the direct pages below rather than the card price.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20LMD-A240%20Standard%20UK
- **Sources opened / retained:** [ProAV — new LMD-A240, £3,030 inc VAT / £2,525 ex VAT](https://proav.co.uk/sony-lmd-a240-24-inch-lcd-production-monitor); [Videonorm — £2,525 ex VAT](https://www.videonorm.co.uk/product/sony-lmd-a240-24in-hd-monitor/); [Visual Impact — new, £3,156.56 inc VAT, available to order](https://www.visuals.co.uk/lmd-a240.html); [Visual Impact — used, £1,560 inc VAT, 2 in stock](https://www.visuals.co.uk/sony-lmd-a240-24inch-lcd-professional-monitor-used.html); [eBay UK — used, £1,150, Good condition](https://www.ebay.co.uk/itm/127676752525)

### 3. Pentax K-X — Body
- **LIVE master product ID:** 7a2977a9-6d59-4a75-9470-c29c08a31d3f
- **Catalogue category:** Cameras / Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** £125.99.
- **Condition:** Used, body only.
- **Availability:** eBay says last one available and 2 sold.
- **Notes:** RED VERIFY — exact K-x body-only listing from Fivercam, a UK business seller with 99.6% positive feedback. No charger included. Postage displayed at £49.99; seller location Goole. Check shutter count, battery, charger and included accessories. Google Shopping search returned K-70/K-r results, not the exact K-x.
- **Google Shopping:** Shopping card results were different Pentax models (including K-70); the exact match was found and opened on eBay.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Pentax%20K-X%20Body%20UK
- **Sources opened / retained:** [eBay UK — Pentax K-x body only, £125.99 used](https://www.ebay.co.uk/itm/256725751763)

### 4. Sony FE 100-400mm F4.5-5.6 GM OSS II — Standard
- **LIVE master product ID:** 7b6c5851-a821-4365-9710-bd83d727fd49
- **Catalogue category:** Lenses / Lenses
- **Research date:** 2026-11-12
- **Observed GBP price:** Exact target price blank. Closest first-generation FE 100-400mm F4.5-5.6 GM OSS (SEL100400GM) £2,149 inc VAT. Different current FE 100-400mm F4.5 GM OSS (SEL100400MCW) £4,399 inc VAT.
- **Condition:** New retailer listings for the two different lens models.
- **Availability:** First-generation SEL100400GM is available to order at Bristol Cameras and awaiting stock at UK Digital; Park Cameras displays add-to-basket and £2,149. New constant-F4.5 SEL100400MCW is in stock at CVP and shows delivery from 13 Nov.
- **Notes:** RED VERIFY — I could not establish a Sony product called FE 100-400mm F4.5-5.6 GM OSS II. Sony's current constant-F4.5 model is SEL100400MCW and is not the same lens. The older variable-aperture F4.5-5.6 model is SEL100400GM and has no II designation. Check whether the catalogue product name should refer to SEL100400GM or SEL100400MCW; do not assign either price as an exact II match.
- **Google Shopping:** Shopping cards surfaced the first-generation SEL100400GM and the newer constant-F4.5 model, not a verified II model.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20FE%20100-400mm%20F4.5-5.6%20GM%20OSS%20II%20Standard%20UK
- **Sources opened / retained:** [Sony UK — current FE 100-400mm F4.5 GM OSS, SEL100400MCW, £4,399](https://www.sony.co.uk/store/product/sel100400mcw.syx/FE-100-400mm-F4-5-GM-OSS); [Bristol Cameras — first-generation SEL100400GM, £2,149 inc VAT, available to order](https://www.bristolcameras.co.uk/product/sony-100-400mm-f4-5-5-6-fe-gm-oss-lens-e-mount/); [UK Digital — first-generation SEL100400GM, £2,149, awaiting stock](https://www.ukdigital.co.uk/sony-fe-100-400mm-f-4-5-5-6-gm-oss-lens-sel100400gm.html); [Park Cameras — first-generation SEL100400GM, £2,149 with £100 cashback offer](https://www.parkcameras.com/shop/sony-fe-100-400mm-f45-56-gm-oss-telephoto-zoom-lens_7240793t); [Jessops — first-generation FE 100-400mm F4.5-5.6 GM OSS, £2,149](https://www.jessops.com/p/sony/fe-100-400mm-f-4-5-5-6-gm-oss-lens-122982); [CVP — first-generation SEL100400GM, £2,149 inc VAT](https://cvp.com/product/sony_sel100400gm)

### 5. Potensic T18 — Standard Package
- **LIVE master product ID:** 7bfcbbdc-a7bf-465b-bc34-808422e25bc0
- **Catalogue category:** Drones / Drone
- **Research date:** 2026-11-12
- **Observed GBP price:** £62.58 or Best Offer.
- **Condition:** Used.
- **Availability:** eBay listing displayed as available when checked; no returns accepted.
- **Notes:** RED VERIFY — exact T18 GPS 1080P drone listing, controller named in title, private seller in Saltash, UK. No returns accepted. Check battery condition, charger, spare propellers, controller and flight-test status. The opened page extraction did not expose the price line, but the search result did. Shopping results were mostly Potensic ATOM models, not T18.
- **Google Shopping:** Shopping results for Potensic surfaced ATOM SE/ATOM models, not the T18. Exact product listing found on eBay.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Potensic%20T18%20Standard%20Package%20UK
- **Sources opened / retained:** [eBay UK — Potensic T18 GPS 1080P drone with controller, £62.58 used](https://www.ebay.co.uk/itm/318924343101)

### 6. Sony EVI-D90 — Standard
- **LIVE master product ID:** 7d1bd30b-b955-4b3c-a2a9-6ec653e2a04d
- **Catalogue category:** Video Cameras / PTZ Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** Exact UK standalone camera price blank. UK HSSL Vaddio/Sony EVI-D90 SD PTZ system search result £880.56. US direct camera listing USD $959.00; GBP price blank.
- **Condition:** HSSL system listing condition not stated; OfficeWonderland describes new camera.
- **Availability:** HSSL says vendor direct ship / ETA by quote; direct page blocked to the research browser. OfficeWonderland says in stock, ships to lower 48 US states.
- **Notes:** RED VERIFY — HSSL listing is a Vaddio-branded EVI-D90 system, not confirmed as a camera-only package; ask for included mount/controller and delivery ETA. OfficeWonderland is the exact EVI-D90 camera, but its displayed price is USD $959 and its shipping/PO terms are US/Canada focused. No currency conversion made.
- **Google Shopping:** No exact UK Google Shopping product card was confirmed. Shopping search link retained for follow-up.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20EVI-D90%20Standard%20UK
- **Sources opened / retained:** [HSSL — Vaddio/Sony EVI-D90 SD PTZ system, black, £880.56 search-result price; page restricted](https://hssl.uk/vaddio-sony-evi-d90-sd-ptz-system-black/); [HSSL — Vaddio/Sony EVI-D90 SD PTZ system, white; page restricted](https://hssl.uk/vaddio-sony-evi-d90-sd-ptz-system-white/); [OfficeWonderland — exact Sony EVID90 camera, USD $959, in stock](https://officewonderland.com/collections/sony/products/sony-evid90-28x-sd-ptz-camera); [OfficeWonderland — white Sony EVID90W, USD $895, in stock](https://officewonderland.com/products/sony-evid90w-ptz-camera)

### 7. Tamron SP 15-30mm F/2.8 Di VC USD G2 — Standard Item
- **LIVE master product ID:** 7e4c7a09-cb59-4a59-90a3-55b1f204ccca
- **Catalogue category:** Lenses / Lenses
- **Research date:** 2026-11-12
- **Observed GBP price:** MPB Nikon fit £569-£624 used; MPB Canon EF fit £489 used; Ffordes eBay Nikon fit £599 used; private eBay listing £463.08 used; Japan eBay listing £393.51 used.
- **Condition:** Used, from Excellent to Like New / Near Mint depending on listing.
- **Availability:** MPB has 3 Nikon-fit units and 1 Canon EF-fit unit. eBay listings show availability; private listing has no returns.
- **Notes:** RED VERIFY — retain mount-specific evidence separately. MPB Nikon listings include 12-month warranty and rear/front caps; £624 Like New and £569 Excellent. MPB Canon EF listing £489 Excellent. Ffordes £599 is Nikon F, boxed, very good cosmetic condition; eBay shows unusual £54.52 international shipping although seller is in Beauly. Private eBay listing title says Canon EF/Nikon F but item specifics show Nikon F; no returns and additional shipping/import fee display. Japan seller listing is Canon EF mount and located in Osaka; displayed GBP amount is retained as shown, not converted.
- **Google Shopping:** Shopping results included both G2 and older first-generation 15-30mm lenses. Only mount- and G2-confirmed offers are used below.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Tamron%20SP%2015-30mm%20F%2F2.8%20Di%20VC%20USD%20G2%20Standard%20Item%20UK
- **Sources opened / retained:** [MPB — G2 Nikon Fit, 3 used from £569 to £624](https://www.mpb.com/en-uk/product/tamron-sp-15-30mm-f-2-8-di-vc-usd-g2-nikon-fit); [MPB — G2 Canon EF Fit, 1 used at £489](https://www.mpb.com/en-uk/product/tamron-sp-15-30mm-f-2-8-di-vc-usd-g2-canon-ef-fit); [eBay UK / Ffordes — G2 Nikon F, boxed, £599 used](https://www.ebay.co.uk/itm/326739685322); [eBay UK / private seller — G2, £463.08 used; mount specifics need checking](https://www.ebay.co.uk/itm/168171126916); [eBay UK / Japan seller — G2 Canon EF, £393.51 used, Near Mint](https://www.ebay.co.uk/itm/117260422151); [UsedLens — G2 UK retailer comparison, 8 listings / 4 retailers](https://usedlens.co.uk/product/tamron-sp-15-30mm-f-2-8-di-vc-usd-g2)

### 8. Sony PMW-160 — Standard
- **LIVE master product ID:** 7e5d3f2e-c814-434e-96a7-80118c70830b
- **Catalogue category:** Video Cameras / Camcorder
- **Research date:** 2026-11-12
- **Observed GBP price:** SLRHut page A £4,071.67; SLRHut page B £3,664.61. Yahoo Japan ended auction JPY 64,980; GBP price blank.
- **Condition:** SLRHut claims new / brand new; Yahoo Japan listing used B-grade.
- **Availability:** Both SLRHut pages claim in stock and new with one-year warranty and 3-5 day free delivery. Yahoo auction ended.
- **Notes:** RED VERIFY — exact PMW-160 pages opened. SLRHut page A shows an implausible crossed-out price of £86,126,017.00 next to £4,071.67. Page B shows £3,664.61 against £6,153.00 and states in stock/brand new. Page B's included items: camera, 16GB SxS card, BC-U1 charger, BP-U30 battery, shoulder strap, manual, lens hood, IR remote, A/V cable and backup batteries. Verify seller, actual stock and whether a legacy camcorder is genuinely new. Yahoo Japan ended price is JPY 64,980; do not convert. Shopping search surfaced PXW-X160, which is a different model.
- **Google Shopping:** Google Shopping/product search results included PXW-X160, not PMW-160. Exact SLRHut pages were opened separately.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20PMW-160%20Standard%20UK
- **Sources opened / retained:** [SLRHut — PMW-160, £4,071.67, claimed new/in stock](https://slrhut.co.uk/product/ID478C6/pmw-160_Sony_PMW_160_XDCAM_HD422_Camcorder_PMW160/); [SLRHut — PMW-160, £3,664.61, claimed new/in stock; package contents listed](https://slrhut.co.uk/product/ID687C13/PMW-160_Sony_PMW_160_XDCAM_HD422_Camcorder/); [Yahoo Japan — ended PMW-160 auction, JPY 64,980, used B-grade](https://auctions.yahoo.co.jp/jp/auction/j1142082538)

### 9. Sony XVS-G1 — Standard
- **LIVE master product ID:** 7efe0b3c-cb0c-4649-b93e-9a0f05c71ac7
- **Catalogue category:** Video Production Equipment / Live Production Switcher
- **Research date:** 2026-11-12
- **Observed GBP price:** C2S Media £20,765.70. Google Shopping/product card showed ProAV £29,067.40, but that price was not confirmed on the opened ProAV page.
- **Condition:** New listings / quote pages.
- **Availability:** C2S product page displays a price. ProAV page says backorder, usually about 10 working days.
- **Notes:** RED VERIFY — exact model match, but the standard package/configuration is unclear. XVS-G1 is a 4RU processor; I/O boards and control panels are configuration-dependent. Confirm whether C2S price is the base processor only and what control panel / I/O is included. ProAV's opened page did not expose its card price, so the £29,067.40 Shopping lead is unverified and conflicts with C2S.
- **Google Shopping:** Shopping result surfaced a ProAV price card of £29,067.40. Opened C2S direct page shows £20,765.70; ProAV direct page shows backorder but no price.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20XVS-G1%20Standard%20UK
- **Sources opened / retained:** [C2S Media — Sony XVS-G1, £20,765.70](https://c2s-media.com/product/sony-xvs-g1/); [ProAV — Sony XVS-G1 live production switcher, backorder information](https://proav.co.uk/sony-xvs-g1-live-production-switcher)

### 10. Sony PMW-150 — Standard
- **LIVE master product ID:** 8399292b-f81c-4a0e-9344-bddb3c7d732b
- **Catalogue category:** Video Cameras / Camcorder
- **Research date:** 2026-11-12
- **Observed GBP price:** Alfatec £3,766.56 ex VAT / £4,519.87 inc VAT. eBay used £867.15.
- **Condition:** Alfatec condition not clearly stated in extracted page; eBay used, seller says works perfectly.
- **Availability:** Alfatec search result says in stock; direct page returned 403. eBay listing availability visible but seller is in Germany.
- **Notes:** RED VERIFY — Alfatec page could not be opened (403); search result identifies exact PMW-150 SKU and says in stock. Check whether its price is new and current. eBay listing is exact PMW-150, used, business seller with 99.1% positive feedback, located in Krefeld, Germany, 30-day returns; confirm UK delivery and any import handling. Google Shopping surfaced PXW-Z150, which is a different model.
- **Google Shopping:** Google Shopping result included PXW-Z150 rather than PMW-150. Exact Alfatec and eBay pages were found separately.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20PMW-150%20Standard%20UK
- **Sources opened / retained:** [Alfatec — Sony PMW-150, £4,519.87 inc VAT, search result says in stock; direct page 403](https://alfatec.co.uk/cameras-camcorders/digital-camcorders/sony-pmw-150-xdcam-hd422-camcorder.html); [eBay UK — Sony PMW-150, £867.15 used, seller in Germany](https://www.ebay.co.uk/itm/257182271969)

### 11. Shure MV7+ — MV7+ Podcast Microphone
- **LIVE master product ID:** 88401408-ada2-44cd-9d24-5fc61383ad86
- **Catalogue category:** Audio / Audio
- **Research date:** 2026-11-12
- **Observed GBP price:** Shure UK RRP £295.00. ProAV £256.80 inc VAT / £214 ex VAT; SCAN £259; GuitarGuitar £289; Stage Supply £302 inc VAT; Park Cameras £275.
- **Condition:** New.
- **Availability:** ProAV search result shows stock/availability information; SCAN shows in stock; GuitarGuitar shows 4 available; Stage Supply says supplier order 1-3 weeks.
- **Notes:** RED VERIFY — Shure official page has stand selector NONE / DESKTOP / BOOM. £295 is the mic-only default price; do not mix in the desktop stand bundle at £329 from AStrings. ProAV £256.80 inc VAT is the lowest opened direct dealer price, but confirm current stock before treating as immediately available.
- **Google Shopping:** Shopping results included the exact Shure MV7+ at £295 and some non-plus MV7 listings. Keep MV7 and MV7+ separate.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Shure%20MV7%2B%20MV7%2B%20Podcast%20Microphone%20UK
- **Sources opened / retained:** [Shure UK — MV7+, £295 RRP, stand selector](https://www.shure.com/en-GB/products/microphones/mv7); [ProAV — MV7+, £256.80 inc VAT / £214 ex VAT](https://proav.co.uk/shure-mv7-dynamic-podcast-microphone-black); [SCAN — MV7+, £259, in stock](https://www.scan.co.uk/products/shure-mv7plus-dynamic-usb-c-and-xlr-microphone-for-podcasters); [GuitarGuitar — MV7+, £289, 4 available](https://www.guitarguitar.co.uk/product/240304420424027--shure-mv7-black-hybrid-usbxlr-microphone); [Stage Supply — MV7+, £302 inc VAT, supplier order 1-3 weeks](https://stagesupply.co.uk/product/shure-mv7-dynamic-podcast-led-microphone-black/); [Park Cameras — MV7+ price lead £275](https://www.parkcameras.com/shop/shure-mv7-podcast-microphone_9705082s)

### 12. Skydio Skydio Controller — Standard Item
- **LIVE master product ID:** 89c50f7b-f542-4b1c-ac6a-f53e5896b7ee
- **Catalogue category:** Camera Accessories / Accessory
- **Research date:** 2026-11-12
- **Observed GBP price:** GBP price blank. Official Skydio store displays USD $179.00.
- **Condition:** New official product listing.
- **Availability:** Official page says ships within 3-5 business days; store terms indicate US/Canada sales focus.
- **Notes:** RED VERIFY — official controller is for Skydio 2 / 2+ and includes USB-C to USB-C and USB-C to Lightning cables. No UK GBP price found; leave price blank and retain USD $179 in notes. Shopping search surfaced Skydroid T12 remote controllers (different brand) and an eBay Skydio 2+ Beacon at USD $199.95; Beacon is not the handheld controller and must not be matched.
- **Google Shopping:** Shopping result for Skydio Controller included Skydroid T12, not Skydio. The official Skydio product page was opened.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Skydio%20Skydio%20Controller%20Standard%20Item%20UK
- **Sources opened / retained:** [Skydio official store — Controller, USD $179, Skydio 2 / 2+ compatible](https://shop.skydio.com/collections/controls/products/skydio-controller); [Skydio — Controller 2 product page; different controller generation](https://www.skydio.com/products/controller-2); [eBay US — Skydio 2+ Beacon, USD $199.95; not the controller](https://www.ebay.com/itm/117270592590)

### 13. Shure MoveMic Two — MoveMic Two
- **LIVE master product ID:** 8f5cb09a-4069-4f4b-ade5-e9866f84b086
- **Catalogue category:** Audio / Audio
- **Research date:** 2026-11-12
- **Observed GBP price:** Shure UK £221.00 sale display / £369.00 displayed RRP. Canford £305 ex VAT; Clifton £335.
- **Condition:** New.
- **Availability:** Shure page offers Add to Cart. Canford says ordered on demand, 3-4 weeks. Clifton says awaiting stock, estimated 5-7 days.
- **Notes:** The standard MoveMic Two package is two wireless lavalier microphones and a charging case; it does not include the MoveMic Receiver. Shure says receiver is sold separately. Keep this distinct from the MoveMic Two Receiver Kit product below. Shopping results also surfaced MoveMic One; do not match it.
- **Google Shopping:** Shopping cards included a MoveMic One result and the exact Shure MoveMic Two. Direct official Shure and retailer pages were opened.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Shure%20MoveMic%20Two%20MoveMic%20Two%20UK
- **Sources opened / retained:** [Shure UK — MoveMic Two, £221, displayed RRP £369, receiver sold separately](https://www.shure.com/en-GB/products/microphones/movemic-two); [Canford — MoveMic Two transmitter pair and charge case, £305 ex VAT](https://www.canford.co.uk/Products/2031431/74-5421_SHURE-MOVEMIC-TWO-RADIOMIC-TRANSMITTER-Lavalier-two-channel-with-charge-case); [Clifton Cameras — MoveMic Two, £335, awaiting stock](https://www.cliftoncameras.co.uk/shure-movemic-two-two-channel-wireless-lavalier-microphones)

### 14. Sony SRG-A40 — Standard
- **LIVE master product ID:** 8fbf5c30-6222-4c19-8a0b-b07c1659127b
- **Catalogue category:** Video Cameras / PTZ Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** CVP £3,082.80 inc VAT (£2,569 ex); Production Gear same; Northamber £2,796.71 ex; SCAN £4,299.98; Currys Business £3,635.98 inc; TopAV £5,054.39 inc.
- **Condition:** New.
- **Availability:** CVP backorder typically 1-2 weeks. Production Gear sold out. Northamber availability not stated. SCAN black awaiting ETA; white ETA 1-3 days. Currys Business white 6 available. TopAV white in stock, dispatch within 2 working days.
- **Notes:** RED VERIFY — distinguish black/white SKUs and availability. TopAV price is substantially higher than CVP / Currys. Northamber price is ex VAT. Shopping cards also showed eBay £2,243.40, JP-UK £2,853.98 and AGP France £3,470.66, but merchant product pages could not be verified from those cards; retain as leads only and check seller, SKU, colour and VAT.
- **Google Shopping:** Shopping search returned an SRG-A12 result (not SRG-A40) and several SRG-A40 leads. Direct merchant pages opened for CVP, Production Gear, Northamber, SCAN, Currys and TopAV.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20SRG-A40%20Standard%20UK
- **Sources opened / retained:** [Sony Professional — SRG-A40 product specification](https://pro.sony/en_GB/products/ptz-network-cameras/srg-a40); [CVP — SRG-A40 black, £3,082.80 inc VAT, backorder lead](https://cvp.com/product/sony-srg-a40bc-ptz-camera-black); [Production Gear — SRG-A40 black, £3,082.80 inc VAT, sold out](https://productiongear.co.uk/products/sony-srg-a40-ptz-camera-black); [Northamber — SRG-A40 black, £2,796.71 ex VAT](https://www.northamber.com/audio-visual/livestream-solutions/broadcast-cameras/srg-a40-ptz-camera-with-ptz-auto-framing); [SCAN — SRG-A40 black, £4,299.98, awaiting ETA](https://www.scan.co.uk/products/sony-srg-a40-4k-ptz-camera-black-1-25-exmor-r-cmos-4k30-20x-optical-zoom-poeplusplus-3g-sdi-hdmi); [Currys Business — SRG-A40 white, £3,635.98 inc VAT, 6 available](https://business.currys.co.uk/catalogue/commercial-appliances-tech/video-conferencing/sony-srg-a40-conference-camera-turret/P309466P); [TopAV — SRG-A40 white, £5,054.39 inc VAT, in stock](https://www.topav.co.uk/products/sony-srg-a40-ptz-camera-white)

### 15. Sony HDC1500R — Standard Package
- **LIVE master product ID:** 90917fa8-dbc3-4aed-9650-e73d8e35692f
- **Catalogue category:** Video Cameras / Cinema Camera
- **Research date:** 2026-11-12
- **Observed GBP price:** Exact HDC1500R price blank. Closest HDC1500 (without R) eBay listing £8,010 used.
- **Condition:** Used closest-model listing.
- **Availability:** eBay listing says 10 available.
- **Notes:** RED VERIFY — the opened listing is specifically model HDC1500, not HDC1500R. It is a fibre HD camera channel, not confirmed as a camera body only; seller N.I. Broadcast has 100% positive feedback and lists £200 postage. Do not import £8,010 as an exact HDC1500R price. Google Shopping returned HXR-MC1500, a different consumer camcorder.
- **Google Shopping:** Shopping results included HXR-MC1500, not HDC1500R. Closest broadcast model HDC1500 opened on eBay.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20HDC1500R%20Standard%20Package%20UK
- **Sources opened / retained:** [eBay UK — Sony HDC1500 fibre HD camera channel, £8,010 used, 10 available; not HDC1500R](https://www.ebay.co.uk/itm/198054902757)

### 16. Sony VG-C3EM Vertical Grip — Accessory
- **LIVE master product ID:** 93aecd5f-ad0d-4aac-95ec-b7094e8caec1
- **Catalogue category:** Camera Accessories / Accessory
- **Research date:** 2026-11-12
- **Observed GBP price:** New Sony UK £239.00. MPB used £61-£81. Park / Clifton / LCE new £239.
- **Condition:** New and used.
- **Availability:** Sony page shows Add to Basket but delivery date displayed is stale (8 Sept). MPB has 2 used units. Park price £239 with cashback offer; Clifton says awaiting stock; LCE search result says in stock.
- **Notes:** RED VERIFY — Sony's £239 page has an old delivery date, so check current stock. MPB used options: £81 Excellent and £61 Well Used, both with 12-month warranty. Park's £50 cashback means £189 net only if the promotion is valid and claimed. Clifton's cashback offer runs to 31 Jan 2027 but page says awaiting stock.
- **Google Shopping:** Shopping returned the exact Sony grip at £239 alongside unrelated grip accessories; use the exact Sony / MPB pages.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20VG-C3EM%20Vertical%20Grip%20Accessory%20UK
- **Sources opened / retained:** [Sony UK — VG-C3EM, £239](https://www.sony.co.uk/store/product/vgc3em.syu/Vertical-Grip); [MPB — used VG-C3EM, £61-£81, 2 available](https://www.mpb.com/en-uk/product/sony-vg-c3em-vertical-battery-grip); [Park Cameras — VG-C3EM, £239 with cashback offer](https://www.parkcameras.com/shop/sony-vg-c3em-vertical-grip-for-sony-a9-and-a7-iii-series_7152043e); [Camera Jungle — used VG-C3EM, £69 price lead](https://www.camerajungle.co.uk/products/72204/sony-vg-c3em-vertical-grip); [Clifton Cameras — VG-C3EM, £239, awaiting stock](https://www.cliftoncameras.co.uk/Sony-VGC3EM-Battery-Grip); [London Camera Exchange — VG-C3EM, £239 stock lead](https://www.lcegroup.co.uk/New/Sony-VG-C3EM-Vertical-Grip-for-A7-III--A7R-III--A9_16329.html)

### 17. Sony FE 28-135mm F4 G OSS — Standard
- **LIVE master product ID:** 94bb730e-b137-4778-b335-173aca953d99
- **Catalogue category:** Lenses / Lenses
- **Research date:** 2026-11-12
- **Observed GBP price:** Sony UK page shows £1,799 sale / £1,999 original in bundle-offer section. Cotswold £1,499. Park £1,999. Camera Centre £1,999. MPB used £514-£1,099. eBay Japan listing £1,152.87.
- **Condition:** New and used.
- **Availability:** Park says free next-day delivery; Camera Centre says in stock; LCE says stock on way around 15 working days. MPB has 4 used units. eBay Japan listing used / near mint.
- **Notes:** RED VERIFY — Sony product code SELP28135G confirms the FE PZ 28-135mm F4 G OSS; catalogue display name omits PZ but appears to refer to this lens. Sony's £1,799 price is shown in a bundle-offer section against £1,999 original, so check whether a qualifying bundle is required. Cotswold £1,499 differs materially from £1,999 dealer pricing. Used MPB prices vary by condition. Shopping product cards included filter/accessory results, not the lens; use exact product pages.
- **Google Shopping:** Shopping results included filter/accessory products and not a reliable exact lens card. Direct manufacturer and dealer product pages opened.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20FE%2028-135mm%20F4%20G%20OSS%20Standard%20UK
- **Sources opened / retained:** [Sony UK — FE PZ 28-135mm F4 G OSS, SELP28135G; £1,799 offer / £1,999 original shown in bundle section](https://www.sony.co.uk/store/product/selp28135g.syx/buy); [Cotswold Cameras — FE PZ 28-135mm F4 G OSS, £1,499 price lead](https://www.cotswoldcameras.co.uk/Sony-FE-PZ-28-135mm-F4-G-OSS-SELP28135G-1); [Park Cameras — FE PZ 28-135mm F4 G OSS, £1,999](https://www.parkcameras.com/shop/sony-fe-pz-28-135mm-f4-g-oss-cine-lens_7240758g); [Camera Centre UK — FE 28-135mm F4 G PZ OSS, £1,999 in stock](https://www.cameracentreuk.com/sony-fe-28-135mm-f4-g-pz-power-zoom-oss-lens); [MPB — used FE PZ 28-135mm F4 G OSS, £514-£1,099](https://www.mpb.com/en-uk/product/sony-fe-pz-28-135mm-f-4-g-oss); [eBay UK — used / near-mint Japan seller, £1,152.87 price lead](https://www.ebay.co.uk/itm/267709712735); [London Camera Exchange — FE PZ 28-135mm F4 G OSS, £1,999 stock-on-way lead](https://www.lcegroup.co.uk/New/sony-fe-28-135mm-f4-g-pz-oss-lens_5689.html)

### 18. Sony PDW-U1 — Standard
- **LIVE master product ID:** 95c66087-a0b7-4682-b96c-705706295858
- **Catalogue category:** Video Production Equipment / Professional Disc Drive
- **Research date:** 2026-11-12
- **Observed GBP price:** eBay used £155.58; £208.63; £1,459.95. Google Shopping cards also showed £114 Visual Impact, £299 eBay and £334.12 VCRShop, not directly verified.
- **Condition:** Used.
- **Availability:** £155.58 private seller listing says 2 available. £208.63 private seller listing says last one. £1,459.95 Snet Technologies listing says 2 available and sold with warranty.
- **Notes:** RED VERIFY — very wide used-price spread. £155.58 is a private seller listing with 2 available; £208.63 is a private seller, good working order, last one, no returns, located Godalming; £1,459.95 is a business seller listing with warranty and 2 available, but price is unusually high. Shopping card leads for Visual Impact / VCRShop were not opened to exact merchant pages; retain links via Shopping query and verify exact condition, PSU, cables, firmware and warranty.
- **Google Shopping:** Shopping results included exact PDW-U1 cards but widely differing prices. Direct eBay pages opened for £155.58, £208.63 and £1,459.95.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Sony%20PDW-U1%20Standard%20UK
- **Sources opened / retained:** [eBay UK — PDW-U1, £155.58 used, 2 available](https://www.ebay.co.uk/itm/267675275030); [eBay UK / Snet Technologies — PDW-U1 sold with warranty, £1,459.95 used, 2 available](https://www.ebay.co.uk/itm/375841867687); [eBay UK — PDW-U1 with PSU, £208.63 used, last one](https://www.ebay.co.uk/itm/156530063005)

### 19. Shure MoveMic Two Receiver Kit — MoveMic Two Receiver Kit
- **LIVE master product ID:** 9709e49e-c48a-41b8-abcd-cbf4599d09e9
- **Catalogue category:** Audio / Audio
- **Research date:** 2026-11-12
- **Observed GBP price:** Shure official RRP £519.00; official search result showed a £311.40 offer but the opened page shows £519.00. DigiBroadcast £496.80 inc VAT / £414 ex; Canford £517.20 inc / £431 ex; Leisuretec £517.20 inc; Bax search/page lead £439 inc (Shopping card £419); Clifton £474.
- **Condition:** New.
- **Availability:** DigiBroadcast says usually dispatched within 24 hours. Canford says on demand, 3-4 weeks. Leisuretec says currently not in stock. Bax card/page price differs; Clifton awaiting stock.
- **Notes:** RED VERIFY — package must include two MoveMic lavalier microphones, MoveMic Receiver and charging case. DigiBroadcast page lists two mics, charging case, receiver, two USB-C cables, 3.5mm cable and roll bag; usually dispatched within 24 hours. Canford lists two mics, receiver, case, cables and roll bag, on demand 3-4 weeks. Leisuretec lists two mics, receiver and charging case, not in stock. Bax page title/description says receiver kit and general description says receiver included, but its visible box-contents list omits the receiver; its Shopping card showed £419 while search result/direct page lead showed £439. Shure official search result showed £311.40 offer but opened official page shows only £519 RRP. Verify price and contents before approval.
- **Google Shopping:** Shopping surfaced exact MoveMic Two Receiver Kit cards from Bax (£419), Amber Sound (£517.20) and Reporterstore (£413.49). Direct merchant verification was partial; Bax page contents list omits the receiver despite title/description.
- **Google Shopping query:** https://www.google.com/search?tbm=shop&q=Shure%20MoveMic%20Two%20Receiver%20Kit%20MoveMic%20Two%20Receiver%20Kit%20UK
- **Sources opened / retained:** [Shure UK — MoveMic Two Receiver Kit, £519 RRP; search offer £311.40 not confirmed on opened page](https://www.shure.com/en-GB/products/wireless-systems/movemic-wireless/movemic-two-kit); [DigiBroadcast — MoveMic Two Twin Receiver Kit, £496.80 inc / £414 ex, usually dispatched within 24 hours](https://www.digibroadcast.com/audio-c63/microphones-c90/shure-movemic-two-twin-receiver-kit-p47846); [Canford — MoveMic Two Receiver Kit, £517.20 inc / £431 ex, on demand 3-4 weeks](https://www.canford.co.uk/Products/2031431/74-5422_SHURE-MOVEMIC-TWO-RECEIVER-KIT-2x-lavalier-1x-MoveMic-Receiver-with-charge-case); [Leisuretec — MoveMic Two Receiver Kit, £517.20 inc VAT, currently not in stock](https://leisuretec.co.uk/products/movemic-two-reciever-kit-2-ch-wireless-lav-system-2xmics-reciever); [Bax Music — MoveMic Two Kit, Shopping/search price discrepancy £419-£439; receiver contents need confirmation](https://www.bax-shop.co.uk/wireless-lavalier-microphones/shure-movemic-mv-two-kit-dual-wireless-clip-on-microphone-system); [Clifton Cameras — MoveMic Two Receiver Kit, £474, awaiting stock](https://www.cliftoncameras.co.uk/shure-movemic-two-receiver-kit-two-channel-wireless-lavalier-microphone-system-with-receiver)

## Queue / database state after research

- 20 researched product IDs recorded.
- 0 pending-review candidates saved.
- 0 direct table writes.
- 0 master-product changes.
- 0 valuation changes.
- 0 schema changes.
- No TEST or Stripe access or changes.
- No uncertain prices imported into automatic valuation.

## Next scheduled run instructions

1. Read this batch-10 checkpoint and PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-10.md first.
2. Read earlier scheduled checkpoints 02 onward and latest project memory.
3. Exclude all product IDs in every scheduled evidence checkpoint, plus outstanding LIVE queue candidates and outstanding manual AI prompts.
4. Select the next 20 active LIVE master products with no active shared_market_evidence using dynamic exclusions; do not use SQL OFFSET.
5. Recheck active evidence, queue and manual prompt status immediately before researching.
6. Research actual product pages and variants, preserve all useful URLs and RED VERIFY uncertainties.
7. Check auth.uid() and platform owner status before staging. If auth.uid is null or owner check fails, do not write; create the next detailed checkpoint and project-memory file instead.
8. Do not touch TEST, Stripe, master products, valuation logic or schema.


## 7. RED VERIFY follow-up — 12 November 2026

Twelve further exact-source observations were imported into LIVE and read back:

| Master product | Source | Price | Evidence / status |
|---|---|---:|---|
| Sony LMD-A240 | Visual Impact | £1,560.00 | Used; two in stock; £1,300 ex VAT. [Source](https://www.visuals.co.uk/sony-lmd-a240-24inch-lcd-professional-monitor-used.html) |
| Sony LMD-A240 | eBay UK — N.I. Broadcast | £1,150.00 | Used Good; UK business seller, 100% feedback; package accessories to confirm. [Source](https://www.ebay.co.uk/itm/127676752525) |
| Shure MV7+ | SCAN | £259.00 | New, exact MV7+-K, in stock; microphone only, no stand bundle. [Source](https://www.scan.co.uk/products/shure-mv7plus-dynamic-usb-c-and-xlr-microphone-for-podcasters) |
| Sony SRG-A40 white | Currys Business | £3,635.98 | New, six available; £3,029.99 ex VAT. [Source](https://business.currys.co.uk/catalogue/commercial-appliances-tech/video-conferencing/sony-srg-a40-conference-camera-turret/P309466P) |
| Sony SRG-A40 white | TopAV | £5,054.39 | New, in stock, UK stock, 2-working-day dispatch; £4,211.99 ex VAT. [Source](https://www.topav.co.uk/products/sony-srg-a40-ptz-camera-white) |
| Sony VG-C3EM | Wex Photo Video | £69.00 | Used Very Good; in stock; Wex Certified 12-month warranty. [Source](https://www.wexphotovideo.com/sony-vg-c3em-battery-grip-used-3373479/) |
| Sony VG-C3EM | Harrison Cameras | £70.00 | Used Mint; one in stock; box/instructions, fully tested, 12-month warranty. [Source](https://harrisoncameras.co.uk/products/used-sony-vg-c3em-grip-for-a9-a7-iii-and-a7r-iii-used-3353315) |
| Sony FE PZ 28-135mm F4 G OSS | CameraWorld | £1,960.00 | New, two available, free UK delivery, 2-year guarantee. [Source](https://www.cameraworld.co.uk/sony-fe-28-135mm-f4-g-pz-oss-lens.html) |
| Sony FE PZ 28-135mm F4 G OSS | MPB | £814.00 | Used Good, SKU 4275015, caps and hood, 12-month warranty. £514 spares/repairs excluded. [Source](https://www.mpb.com/en-uk/product/sony-fe-pz-28-135mm-f-4-g-oss) |
| Sony PDW-U1 | eBay UK — jaytomtom | £208.70 | Used, good working order, PSU included; last one, one sold; seller in Godalming. [Source](https://www.ebay.co.uk/itm/156530063005) |
| Sony PDW-U1 | eBay UK — Snet Technologies | £1,459.95 | Used, business seller in London, two available, warranty; £14.49 postage. High seller/warranty price tier retained separately. [Source](https://www.ebay.co.uk/itm/375841867687) |
| Shure MoveMic Two Receiver Kit | Shure UK | £311.40 | New official offer against £519 RRP; exact receiver kit SKU MV-TWO-KIT-Z6. [Source](https://www.shure.com/en-GB/products/wireless-systems/movemic-wireless/movemic-two-kit) |

Existing rows were also rechecked: ProAV Sony LMD-A240 £3,030 inc VAT / £2,525 ex VAT now explicitly marked backorder (the page shows an in-stock label but says delivery usually within 10 working days); MPB Sony VG-C3EM confirms two used units £68 Good and £77 Excellent; Shure UK MoveMic Two pair confirms £258.30 sale against £369 RRP, receiver sold separately. The existing Shure MoveMic Two Receiver Kit DigiBroadcast £496.80 remains a separate package/source. Do not merge the pair-only and receiver-kit prices.

Batch 10 now has **24 active records: 12 UK New and 12 UK Used; all 24 are GBP**. Twelve follow-up records were added. Used rows remain reference-only and do not affect automatic valuation.

Other leads remain RED VERIFY and were not promoted: Sony HDC-5500 £60,036 is exact but the page does not enumerate full camera-channel contents; Sony FE 100-400mm F4.5-5.6 GM OSS II could not be verified as a real exact model (first-gen SEL100400GM and current SEL100400MCW are different); Potensic T18 page did not expose price on direct page; EVI-D90 UK page blocked and package uncertain; Tamron G2 prices are mount-specific; SLRHut PMW-160 legacy/new claims and seller reliability need confirmation; Sony XVS-G1 configuration/I/O unclear; Alfatec PMW-150 page returned 403; HDC1500 is not HDC1500R; Shure MoveMic Two receiver kit and pair are distinct; Skydio has USD only. No foreign currency or uncertain package price was promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 8. Further RED VERIFY review — 12 November 2026

Three further direct-source observations were added to LIVE and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| Potensic T18 GPS 1080P camera quadcopter with controller | eBay UK — samgar_8065 | £62.58 | Used; private UK seller in Saltash, 100% positive; no returns; package contents/flight condition not itemised. [Source](https://www.ebay.co.uk/itm/318924343101) |
| Tamron SP 15-30mm f/2.8 Di VC USD G2 — Nikon F fit | MPB | £624.00 | Used Like New, SKU 4103368; original packaging, front/rear caps, 12-month warranty. [Source](https://www.mpb.com/en-uk/product/tamron-sp-15-30mm-f-2-8-di-vc-usd-g2-nikon-fit) |
| Tamron SP 15-30mm f/2.8 Di VC USD G2 — Nikon F fit | MPB | £569.00 | Used Excellent, two units at this price; front/rear caps, 12-month warranty. [Source](https://www.mpb.com/en-uk/product/tamron-sp-15-30mm-f-2-8-di-vc-usd-g2-nikon-fit) |

Batch 10 now has **27 active GBP records: 12 UK New and 15 UK Used**. The three additions are used-market reference only. The Tamron master package does not specify a mount; the Nikon F observations are explicitly mount-specific and must not be generalized to Canon EF or other mounts.

Other leads remain RED VERIFY: HDC-5500 KitPlus package contains camera head, HDCU-5500 and installed options, not a bare camera; FE 100-400mm F4.5-5.6 GM OSS II exact identity unresolved; EVI-D90 HSSL result is a system bundle and blocked; PMW-160 SLRHut new/stock claims require seller verification; XVS-G1 configuration and I/O unclear; PMW-150 Alfatec page returned 403; HDC1500 is not HDC1500R; Skydio Controller USD only. No foreign-currency or package-mismatch price was imported.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 9. Sony HDC-5500 exact UK source resolved and imported — 12 November 2026

A direct UK retailer source was re-opened and the Standard package identity was checked against the LIVE master before insertion:
- LIVE master: Sony HDC-5500 / Standard, ID 75fabe8a-7cd8-4419-9cc3-235443d881a3.
- Visuals exact SKU HDC-5500//U: £60,036.00 inc VAT (£50,030.00 ex VAT), 3+ in stock. Direct page: https://www.visuals.co.uk/sony-hdc-5500.html.
- The source In The Box list contains cable clamp belt, two screws and attached label only. The observation is the camera-head Standard offer; it is not a complete channel with CCU, RCP, viewfinder or lens. The separate £54,000 KitPlus used channel remains a different package and is not attached to this Standard record.
- Inserted idempotently into LIVE shared_market_evidence as active UK New GBP, source_record_key batch10-followup-sony-hdc5500-visuals-60036-20261112.
- Evidence row ID: 10248d49-cc2b-43eb-8546-acd1881a3c86. Insert result succeeded and direct LIVE read-back confirmed exact master, package, source, URL, £60,036 GBP, new condition, retailer channel and in_stock status.

Batch 10 now has 28 active GBP rows: 13 UK New and 15 UK Used. Cumulative Batches 04–13 now contain 237 GBP observations: 233 active (128 UK New, 105 UK Used), four inactive. No master product, tenant/customer, schema or valuation changes. TEST and Stripe untouched.

Additional source rechecks retained as RED VERIFY / no import:
- Sony XVS-G1: C2S Media direct page displays £20,765.70 but does not establish VAT basis or exact base-unit/control-panel/I/O configuration; ProAV page has no visible price and contradictory In Stock / Backorder wording. Do not import yet. C2S: https://c2s-media.com/product/sony-xvs-g1/ ; ProAV: https://proav.co.uk/sony-xvs-g1-live-production-switcher.
- Sony NP-FV70: UK retailer pages resolve to NP-FV70A / NP-FV70A2.CE, not the exact original non-A variant; do not map the A-version £49.99 price to the non-A master. Bristol: https://www.bristolcameras.co.uk/product/sony-np-fv70-infolithium-rechargeable-battery/.
- Sony FE 100-400mm F4.5-5.6 GM OSS II: no exact II model verified. SEL100400GM (first-generation variable-aperture lens) and SEL100400MCW (current constant-F4.5 lens) are different products; do not assign either price to the II master.
- PowerDolphin Wizard £1,449 eBay offer is active/new, but the direct listing does not establish the full Wizard sonar/bait-drop/controller/accessory package. Keep the existing package-unverified row inactive; do not reactivate from title alone.
- Sony HDC-F5500V Visuals £85,619.24 record already exists against the separate HDC-F5500V Standard Package master. The refreshed page confirms SKU HDC-F5500V-4K and Available to Order; no duplicate was inserted.

The Sony HDC-3000 checkpoint remains unresolved: Sony's “HDC-3000 series” wording is a series designation, not proof of a distinct sellable HDC-3000 camera model. Keep related HDC-3500/HDC-3200/HSC-300 and CCU offers separate.


## Sony FE 100-400mm — first-generation model matched correctly — 12 November 2026

The RED VERIFY lead named “Sony FE 100-400mm F4.5-5.6 GM OSS II” was not matched to that catalogue row because no exact II model was verified. Instead, the direct source was matched to the existing first-generation master:
- LIVE master: FE 100-400mm F4.5-5.6 GM OSS / Lens Only, ID 69e7a468-cb45-474e-9c28-ca3611514a72.
- Carmarthen Cameras exact SKU 4548736058422 / SEL100400GM: £2,149, new, one unit in stock and ready to ship. In the box: lens hood, front/rear caps, case and shoulder strap. Direct page: https://carmarthencameras.com/products/sony-fe-100-400mm-f4-5-5-6-gm-oss-super-telephoto-zoom-lens.
- Imported as active UK New GBP against the first-generation Lens Only master, not the unverified “II” product and not the newer constant-F4.5 SEL100400MCW.
- LIVE row ID 78d2841a-c109-4933-a786-d5ebe559aaff; source_record_key batch10-followup-sony-fe100400gm-firstgen-carmarthen-2149-20261112. Direct read-back confirmed exact master/package, source URL, £2,149 GBP, new condition and in_stock.

Batch 10 now has 29 active GBP rows (14 UK New, 15 UK Used). Cumulative Batches 04–13 now contain 241 GBP observations: 238 active (130 UK New, 108 UK Used), three inactive. No catalogue master was changed; the inaccurate “II” catalogue identity remains RED VERIFY for a separate catalogue correction decision. TEST, Stripe, schema and valuation logic untouched.


## Shure MoveMic currency correction — 12 November 2026

The earlier DigiBroadcast Shure MoveMic Two Receiver Kit £496.80 row was deactivated after reopening the direct page. DigiBroadcast currently defaults to EUR and displays €593.29 / €494.41, with RRP €617.65 / €514.71; the prior £496.80 capture is not supported by the page as currently rendered. Existing row dee5cf7a-27cb-4097-84a1-a918764c0cf2 remains retained but inactive with availability currency_unverified. The exact package contents are confirmed (two MoveMic lavaliers, charging case, receiver, two USB-C cables, 3.5mm cable and roll bag); use separately verified Canford GBP evidence instead. No duplicate or foreign-currency conversion.

Batch 10 now 30 total, 29 active (14 UK New, 15 UK Used), one inactive currency-unverified record.


## Shure MoveMic Two Receiver Kit — verified Canford GBP source and official RRP correction — 12 November 2026

After the DigiBroadcast currency issue was identified, the direct Shure UK page and Canford UK dealer page were reopened:
- Shure UK exact SKU MV-TWO-KIT-Z6: £519.00 Recommended Retail Price, not the £311.40 offer from the earlier search snippet. Direct page confirms the full receiver kit: two MoveMic wireless lavaliers, charging case, MoveMic Receiver, two USB-C cables, 3.5mm cable and roll bag. Existing LIVE official row b5e0c19c-179a-465e-954c-b1dab8da9286 corrected to £519.00 RRP; the note explicitly says this is not a discounted checkout offer. Source https://www.shure.com/en-GB/products/wireless-systems/movemic-wireless/movemic-two-kit.
- Canford exact stock code 74-5422 / model MV-TWO-KIT-Z6: £431.00 ex VAT, on demand, available in 3–4 weeks. Page confirms the receiver, two lav transmitters, two windscreens, USB-C cable, charging case and roll bag. Imported as active UK New GBP/backorder against existing MoveMic Two Receiver Kit master 9709e49e-c48a-41b8-abcd-cbf4599d09e9. Evidence row 1c662613-7d5f-40e3-84eb-5ed2b84b5962; source https://www.canford.co.uk/Products/2031431/74-5422_SHURE-MOVEMIC-TWO-RECEIVER-KIT-2x-lavalier-1x-MoveMic-Receiver-with-charge-case.
- DigiBroadcast row dee5cf7a-27cb-4097-84a1-a918764c0cf2 remains inactive/currency_unverified because the page currently defaults to EUR and no GBP price was confirmed; its former £496.80 is not a valid active GBP observation.

Batch 10 now 30 total, 29 active (14 UK New, 15 UK Used), one inactive currency-unverified row. LIVE Batches 01–13 now total 261 observations, 257 active (140 UK New, 117 UK Used), four inactive. UK Used remains reference-only. No master/schema/valuation changes; TEST and Stripe untouched.
