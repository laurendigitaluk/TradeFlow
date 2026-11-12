# TradeFlow LIVE — Scheduled Market-Evidence Research Batch 12

Research date: 2026-11-12  
Environment: **TradeFlow LIVE only**  
Status: **20 products researched; checkpoint saved; no queue candidates staged**  
Selection method: dynamic exclusion query; **no SQL OFFSET used**

## Pre-selection continuity and exclusion checks

Read from the production branch before selecting:
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md`
- All scheduled market-evidence checkpoints present through Batch 11 (02–11)
- All corresponding project-memory files present through Batch 11 (02, 04–11; no Batch 03 project-memory file was present)

The checkpoint UUIDs were collected and matched against LIVE catalogue masters. Product identity was also checked to avoid cross-UUID repeats. In particular, the previously researched **Nikon Ai-S NIKKOR 28mm f/2** and **Skydio 2+ Sports Kit** identities were excluded even where a different master UUID/field representation existed.

Outstanding exclusions before selection:
- 10 LIVE `platform_catalogue_research_queue` candidates in `needs_research`; matching manufacturer/model/package identities excluded.
- One outstanding manual AI research prompt, ID `4e9d16d5-baae-4fb7-8617-2e3a0a829cb5`, status `ready`, containing 20 product IDs; those IDs excluded.
- Queue status snapshot: 28 imported, 10 needs_research, 43 rejected. Manual prompts: one completed and one ready.

Selected 20 active LIVE master products with no active `shared_market_evidence`, after those exclusions. The 20 were rechecked immediately before research and again after research: every selected product still had 0 active evidence, 0 matching outstanding queue candidates and 0 matching outstanding manual prompts.

## Research rules applied

- Search manufacturer sites, UK retailers, marketplaces and Google Shopping/product-shopping results.
- Open actual product pages and compare the model, package, condition, price and availability against the catalogue.
- Preserve sold-out, unverified, foreign-currency and uncertain links.
- Do not convert foreign currency into GBP. GBP remains blank when no reliable UK GBP amount was visible.
- Prefix uncertain findings with **RED VERIFY**.
- Do not change catalogue masters, evidence, valuation logic, schema, TEST or Stripe.

## Batch 12 — detailed product findings

### 1. Skydio — Skydio X2 Controller
- **LIVE master product ID:** `99acc43c-5183-48d9-9e16-b2f78ee675b7`
- **Package:** Skydio X2 Controller
- **UK GBP price:** blank
- **Sources:**
  - Skydio official controller page: https://shop.skydio.com/products/skydio-controller
  - Skydio/Axon pricing PDF: https://esc13.net/assets/uploads/docs/Axon_Pricing.pdf
- **Findings:** Skydio's current consumer Controller page displays USD $179 and says the store sells only in the United States and Canada. The page groups it with Skydio 2/2+ accessories, so this is not confirmed as the enterprise X2 controller. The Axon pricing PDF separately lists an “SKYDIO ENTERPRISE CONTROLLER 5GHZ (X2D OFFLINE), ANZ” at USD $5,400.15 and an X2E controller at USD $4,499. These are foreign-currency enterprise price references, not UK offers.
- **RED VERIFY:** Confirm whether the catalogue master means the X2/X2D enterprise 5GHz controller or the consumer Skydio 2/2+ controller. Do not attach the $179 consumer controller price to the X2 master. Check whether the X2D/ANZ pricing record is relevant to the exact SKU.

### 2. Sony — HVR-HD1000E
- **LIVE master product ID:** `9c4263d6-f966-459c-8716-d390b040ec51`
- **Package:** Standard
- **Sources:**
  - eBay UK, item 336522927009: https://www.ebay.co.uk/itm/336522927009
  - eBay UK, item 298314587796: https://www.ebay.co.uk/itm/298314587796
  - eBay product page: https://www.ebay.co.uk/p/100062910
- **Findings:** Direct eBay item 336522927009 displays **£325.00**, used, seller describes very good condition and fully working; business seller in London, 100% feedback. Item 298314587796 displays **£249.00**, used, very good, includes three batteries and Sony charger; business seller in Worthing, 99.8% positive. eBay product page 100062910 displays **£260.00 + £12.36 postage**, used; seller says original mains unit cable had to be spliced/soldered and no returns. Google Shopping also returned an Etsy £741.30 card and an eBay £248.75 card; the Etsy and eBay product result did not agree with the direct £325 page.
- **RED VERIFY:** Compare package/accessory contents and seller terms before treating the prices as equivalent. Keep the £260 modified-mains-unit listing separate from fully working examples.

### 3. Sony — E 35mm F1.8 OSS
- **LIVE master product ID:** `9d4cbee0-2c22-4331-954b-f147349c594f`
- **Package:** Lens Only
- **Sources:**
  - Sony UK official store: https://www.sony.co.uk/store/product/sel35f18.ae/E-35mm-F1-8-OSS
  - CameraWorld: https://www.cameraworld.co.uk/sony-35mm-f1-8-oss-sel35f18.html
  - Cotswold Cameras: https://www.cotswoldcameras.co.uk/Sony-E-35mm-F18-OSS-Lens-SEL35F18
  - Castle Cameras: https://www.castlecameras.co.uk/sony-e-35mm-f18-oss-lens/p1473
  - Norwich Cameras: https://norwich-cameras.co.uk/products/sony-e-35mm-f1-8-oss-sel35f18-available-now
- **Findings:** Sony UK page identifies SKU SEL35F18.AE and displays £325.00; its quick-view product card also showed a £225.00 sale price against £325.00, so the same store page exposes conflicting price contexts. CameraWorld search result showed £319, in stock; Cotswold £269; Castle £325 but awaiting stock; Norwich Cameras £299 with 5–7 day availability. Norwich listing has a Hong Kong seller/no-VAT caveat in the search result.
- **RED VERIFY:** Confirm whether Sony's £225 quick-view offer is live for the same selectable item as the £325 product-page price. Check Norwich seller/dispatch/VAT. Google Shopping also returned FE 35mm F1.4 and FE 35mm F2.8 products; those are different lenses and must not be attached.

### 4. Skydio — Skydio X2 Dual Charger
- **LIVE master product ID:** `a20f3d12-0219-4d6a-bcfe-3bbef02e1513`
- **Package:** Skydio X2 Dual Charger
- **UK GBP price:** no confirmed exact X2 price
- **Sources:**
  - Skydio official store: https://shop.skydio.com/
  - Axon pricing PDF: https://esc13.net/assets/uploads/docs/Axon_Pricing.pdf
  - eBay UK, item 187918127220: https://www.ebay.co.uk/itm/187918127220
- **Findings:** Skydio's consumer store displays a USD $149 Dual Charger for Skydio 2/2+ accessories and sells only in the US/Canada. The Axon PDF lists a Skydio X2 Dual Charger at USD $439 and an ANZ version at USD $474.30. The eBay UK listing displays **£72.92**, used, private seller, but the actual title is “Skydio 2 + Dual Battery Charger”; it is not an X2 enterprise charger. The Google Shopping card showed £52.70, but clicking through exposed £72.92 on the actual eBay listing.
- **RED VERIFY:** Do not attach the consumer Skydio 2/2+ charger listing to the X2 master. Confirm whether the master is the enterprise X2 dual charger and whether the Axon USD price list is relevant.

### 5. Yuneec — E10Tvx
- **LIVE master product ID:** `a45a2ae6-48fa-4cae-9fe3-e03eaaf7f0ff`
- **Package:** E10Tvx Thermal Camera
- **UK GBP price:** blank
- **Sources:**
  - Yuneec Germany official store: https://shop.yuneec.com/E10TvX-Kamera-FLIR/YUNE10TvX32EU
  - Yuneec Poland: https://yuneec.pl/product-pol-12373-Kamera-termowizyjna-Yuneec-E10TvX-640p-32-FOV-14mm-dla-Yuneec-H520E.html
  - Aerodron Poland: https://www.aerodron.pl/produkt/kamera-termowizyjna-yuneec-e10tvx-640p-32-fov14mm-dla-yuneec-h520e/
- **Findings:** Exact E10TvX 640p/640×512 thermal camera, 32° FOV/14mm, for H520E. Yuneec Germany displays **€11,198.01 incl. VAT** and says not available. Yuneec Poland displays **57,473.96 PLN gross** and sold out/not available for shop pickup, while also showing an on-order message. Aerodron displays **46,726.80 PLN gross / 37,989.27 PLN net**, available on order. No GBP conversion made.
- **RED VERIFY:** Check whether the Polish order lead can actually be fulfilled and confirm exact E10TvX sensor/32°/14mm variant. Do not convert PLN or EUR into GBP.

### 6. Sony — PXW-FS5
- **LIVE master product ID:** `a8117520-8f48-4b53-8a56-9aa8e2e42a01`
- **Package:** Standard Package
- **Sources:**
  - Wex used listing: https://www.wexphotovideo.com/sony-pxw-fs5-4k-professional-camcorder-used-3348017/
  - MPB used listing: https://www.mpb.com/en-uk/product/sony-pxw-fs5-camcorder
- **Findings:** Wex direct page displays **£468.00**, in stock, used Good (8). Included: white box, Sony AC adapter BC-UA1, top handle, LCD screen, BP-U30 battery pack and grip remote. Excluded: original box, RMT-845 wireless remote, accessory shoe kit and large eyecup. MPB search result shows two used examples around **£609–£644**, with differing hours and included accessories.
- **RED VERIFY:** Compare the exact accessory bundle and condition before treating Wex and MPB prices as equivalent. Keep body-only and bundled listings separate.

### 7. Sony — HZCU-FZ90
- **LIVE master product ID:** `a906c6de-bca7-49ee-9894-7a6308c3928b`
- **Package:** Standard
- **UK GBP price:** blank
- **Sources:**
  - Sony Japan official release: https://www.sony.jp/professional/News/newsrelease/20230614/
  - ProAV UK HXC-FZ90 camera head page: https://proav.co.uk/sony-hxc-fz90-4k-hdr-studio-camera
- **Findings:** **RED VERIFY — catalogue model code appears to be wrong.** Sony's official product code is **HXCU-FZ90**, not HZCU-FZ90. Sony's June 2023 release lists the HXCU-FZ90 CCU at approximately **JPY 880,000 incl. tax / JPY 800,000 ex tax**, with winter 2023 launch. ProAV's UK page is for the **HXC-FZ90 camera head**, SKU HXC-FZ90, not the CCU; it says “Call for Availability” and does not display a price.
- **RED VERIFY:** Confirm whether the master should be HXCU-FZ90 CCU. Do not attach the HXC-FZ90 camera-head page or price to the CCU.

### 8. Walkera — Vitus Starlight
- **LIVE master product ID:** `a9a1a521-b0a4-4136-92b0-b17722b755b3`
- **Package:** Vitus Starlight
- **Source:** https://www.rchobby-avenues.co.uk/walkera-vitus-starlight-foldable-night-vision-drone-vitus-starlight
- **Finding:** UK retailer displays **£544.91**, stock marked In Stock. Package contents shown: Vitus 320, case, 8 propellers, 3 batteries, remote controller, phone holder and instruction manual. Page says 0 samples sold.
- **RED VERIFY:** Product title is Vitus Starlight but the included-item list calls the drone “Vitus 320”. Confirm whether that is the correct Starlight variant/package before treating as exact catalogue evidence.

### 9. Sony — HXR-MC2500
- **LIVE master product ID:** `adbd27dc-ef2f-4379-a3a2-157cac36d14a`
- **Package:** Standard Package
- **Source:** https://www.ebay.co.uk/itm/318668491967
- **Finding:** Direct eBay listing for **HXR-MC2500E**, **£789.99**, used, described as excellent used condition with minor cosmetic marks, fully tested and working; seller says brand-new battery and charger included. Business seller KRTN Plaza, 99.8% positive, located Gainsborough, UK, 30-day returns.
- **RED VERIFY:** Catalogue model omits the E suffix. Confirm that HXR-MC2500E is the intended regional variant and whether its 32GB internal memory / included battery and charger match the Standard Package.

### 10. Sony — PXW-Z1500
- **LIVE master product ID:** `b00d81e5-87e4-4d6c-abaf-109ff4bb68d9`
- **Package:** Standard
- **Sources:**
  - Sony UK announcement for PXW-Z150: https://www.sony.co.uk/presscentre/1237494241730
  - Sony Japan PXW-Z150 product page: https://www.sony.jp/xdcam/products/PXW-Z150/
  - MPB PXW-Z150 used: https://www.mpb.com/en-uk/product/sony-pxw-z150-camcorder/sku-3957071
  - Camix PXW-Z150: https://camix.co.uk/product/sony-pxw-z150-4k-xdcam-camcorder/
  - eBay UK PXW-Z150 listing: https://www.ebay.co.uk/itm/406069172128
- **Findings:** **RED VERIFY — no official Sony PXW-Z1500 model found.** Sony's official model is **PXW-Z150**, announced by Sony UK in 2016; Sony Japan marks it discontinued and shows historical MSRP **JPY 480,700 incl. tax**. UK comparators for the different PXW-Z150 model: MPB used price card £1,329; Camix new listing price lead around £3,067; eBay UK used listing with 810 hours and flightcase appeared in Shopping, but the clicked page did not expose a reliable current GBP price. The eBay page confirms model PXW-Z150, used, located Milton Keynes, no returns.
- **RED VERIFY:** Confirm whether catalogue master PXW-Z1500 is a typo for PXW-Z150 or another Sony model. Do not attach PXW-Z150 prices to PXW-Z1500 without confirmation.

### 11. Sony — PXW-Z190V
- **LIVE master product ID:** `b01f1809-1787-4086-8de1-c2c67cbf09a1`
- **Package:** Standard Package
- **Sources:**
  - eBay UK exact Z190V listing: https://www.ebay.co.uk/itm/336719998477
  - MPB PXW-Z190 (no V suffix): https://www.mpb.com/en-uk/product/sony-pxw-z190-4k-camcorder
- **Findings:** Exact eBay title **Sony PXW-Z190V**, **£1,700.00**, used, described as excellent condition and fully working; business seller with 100% feedback. MPB has PXW-Z190 without the V suffix at **£1,819 Excellent** and **£1,849 Like New**, with 12-month warranty and differing batteries/eyecups/hoods.
- **RED VERIFY:** Keep exact Z190V eBay evidence separate from PXW-Z190 MPB comparators until the suffix and package equivalence are confirmed.

### 12. SmallRig — MagicFIZ Wireless Receiver Motor 3263
- **LIVE master product ID:** `b2201d78-6ba2-4f40-959d-29457e84fcd2`
- **Package:** Wireless Receiver Motor 3263
- **UK GBP price:** blank
- **Sources:**
  - SmallRig official 3263 page: https://www.smallrig.com/SmallRig-Wireless-Receiver-Motor-3263.html
  - Digistore France: https://digistore.fr/smallrig-wireless-receiver-motor-3263/
  - Cyfrowe Poland: https://www.cyfrowe.pl/smallrig-silnik-wireless-receiver-motor-3263-p.html
  - ProAV compatible rod clamp (not the motor): https://proav.co.uk/smallrig-rod-clamp-with-nato-rail
- **Findings:** Official SmallRig search result displayed **USD $109.99**; opened page identifies SKU 3263, 0.5 N·m peak torque, 15mm rod clamp, fast charging and independent power, but dynamic price selector rendered USD $0.00. Digistore displays **€114.70 incl. VAT / €95.58 ex VAT**, on order 14–30+ days. Cyfrowe displays **536 PLN**, extended delivery. ProAV page is a different rod clamp (3011) that is compatible with 3263, not the motor. Google Shopping returned SmallRig 4297 receiver motor and 3781 MagicFIZ kit; both are different products.
- **RED VERIFY:** Check whether the official $109.99 search price remains current; no reliable UK GBP offer was established. Do not attach the 4297/3781 Shopping prices to 3263.

### 13. Sony — FE 100mm F2.8 Macro GM OSS
- **LIVE master product ID:** `b4f97278-cad6-44c5-b420-65f085d91df9`
- **Package:** Standard
- **Sources:**
  - Sony UK official store: https://www.sony.co.uk/store/product/sel100m28gmb.syx/FE-100mm-F2-8-Macro-GM-OSS-Full-Frame-Macro-Lens
  - E-Infinity UK: https://www.e-infin.com/uk/item/20195/sony_fe_100mm_f/2.8_macro_gm_oss_(sel100m28gm)
  - Camix: https://camix.co.uk/product/sony-fe-100mm-f2-8-macro-gm-oss-lens/
  - CeX Shopping product page: https://uk.webuy.com/product-detail/?id=SLENSONSEL100M28GMS
- **Findings:** Sony official price **£1,399.00**. Sony page also offers a teleconverter bundle at £1,678. E-Infinity displays **£899.00**, in stock, 100% brand new, 12-month warranty, free shipping and import tax included. Camix search result price lead **£1,208**. CeX Shopping card displayed **£752.95**, but direct page fetch timed out, so stock/condition were not verified.
- **RED VERIFY:** Verify the E-Infinity price, seller/dispatch and import-tax wording at checkout; check Camix price on checkout; CeX condition/stock remains unverified. Do not treat the CeX card as confirmed current stock.

### 14. Sony — NEX-FS100
- **LIVE master product ID:** `b5c849cc-f19d-4774-bcd6-e48d73a12c88`
- **Package:** Standard
- **Source:** https://www.ebay.co.uk/itm/375841867680
- **Finding:** eBay UK listing **£1,995.97**, used, business seller Snet Technologies, 96.6% positive, described as sold with warranty. Google Shopping product card title described a NEX-FS100 with 18–200mm lens and PortaBrace bag, but the opened listing text did not expose sufficient contents to verify that package.
- **RED VERIFY:** Confirm body-only versus lens/bag bundle and exact included accessories before comparing with the Standard Package.

### 15. Sony — MKS-R3210
- **LIVE master product ID:** `b6bb8fe0-d24c-4daf-9621-1d76f9cfcde7`
- **Package:** Standard
- **UK GBP price:** blank for exact model
- **Sources:**
  - Sony official MKS-R3210 product PDF: https://pro.sony/en_HR/pdf/mks-r3210
  - Pro-Media Austria: https://www.pro-media.at/mks-r3210
  - eBay UK BKS-R3210 (different model): https://www.ebay.co.uk/itm/202660963073
- **Findings:** Sony confirms exact MKS-R3210 is a 32-button remote control panel for IP/SDI router crosspoints. Pro-Media Austria displays **€2,472 ex VAT** (list price €2,626), not GBP. eBay UK listing is **2 × BKS-R3210**, **£61.75** used, plus £95 postage; this is BKS-R3210, not MKS-R3210.
- **RED VERIFY:** Do not attach the BKS-R3210 two-panel price to MKS-R3210. Seek a UK dealer quote for the exact MKS-R3210.

### 16. Sony — HDCE-TX30
- **LIVE master product ID:** `c0bd2f6c-4337-4304-b60e-22f2b27ad718`
- **Package:** Standard
- **Source:** https://www.visuals.co.uk/hdce-tx30.html
- **Finding:** Direct Visual Impact page identifies SKU **HDCE-TX30** and displays **£11,347.13 inc VAT / £9,455.94 ex VAT**, available to order but not currently held in stock. Product is an IP camera extension adaptor for Sony HDC-3500/3200/3100 and HDC-2500/2400/1700 systems. Earlier Shopping/search snippet showed £11,801.02; direct page is the more recent displayed price.
- **Notes:** Exact SKU and use confirmed; availability is supplier-order rather than warehouse stock.

### 17. Z CAM — ExAscend CFast Reader
- **LIVE master product ID:** `c34c7706-d042-47f5-8184-b2a14b6b35fa`
- **Package:** Z CAM ExAscend CFast 2.0 Card Reader
- **Source:** https://cvp.com/product/z-cam-excrcft1-card-reader
- **Finding:** CVP direct page identifies **Z-CAM-EXCRCFT1**, single-slot CFast 2.0 reader, 10 Gbps; **£51.60 inc VAT / £43 ex VAT**.
- **Notes:** Google Shopping/search also surfaced 128GB/256GB/512GB CFast cards at separate prices; those are memory cards, not the reader, and were not matched.

### 18. Sony — UHC-8300
- **LIVE master product ID:** `c4cc8a15-4406-4002-b624-63d8a23b96ac`
- **Package:** Standard
- **Source:** https://www.visuals.co.uk/uhc-8300.html
- **Finding:** Visual Impact page identifies SKU **UHC-8300**, 8K portable studio camera head with 1.25-type 8K 3CMOS sensor; **£396,117.94 inc VAT / £330,098.28 ex VAT**. Available to order, not held in stock. Product works with the separate UHCU-8300 camera control unit.
- **RED VERIFY:** Confirm whether the Standard Package expects the camera head only or includes any system components; CCU is explicitly separate.

### 19. Sony — HDC-3200
- **LIVE master product ID:** `c7422817-2dfd-4837-8d75-d7a092d2a8b3`
- **Package:** Standard
- **Sources:**
  - Visual Impact UK: https://www.visuals.co.uk/sony-hdc-3200-4k-hd-smpte-fibre-interface.html
  - Axis One Europe: https://axis-one.be/
- **Findings:** Visual Impact page identifies SKU **HDC-3200/DF**, displays **£37,651.84 inc VAT / £31,376.53 ex VAT**, available to order but not held in stock. The listed SKU includes the dual-filter option. Axis One result displays €28,800 ex VAT for an HDC-3200 reference, not GBP. Google Shopping returned an HXC-FB75 camera result; that is a different Sony model and was not matched.
- **RED VERIFY:** Check whether HDC-3200/DF dual-filter configuration matches the catalogue's Standard Package. Do not assume the HXC-FB75 Shopping result is relevant.

### 20. Sony — FE 50mm F1.4 GM
- **LIVE master product ID:** `c9c16a53-ff9e-4483-8828-1c0df7187053`
- **Package:** Standard
- **Sources:**
  - Sony UK: https://www.sony.co.uk/store/product/sel50f14gm.syx/FE-50mm-F1-4-GM
  - LCE: https://www.lcegroup.co.uk/New/Sony-FE-50mm-F1.4-G-Master-Lens_135488.html
  - Camix: https://camix.co.uk/product/sony-fe-50mm-f1-4-gm-lens/
  - CameraWorld: https://www.cameraworld.co.uk/sony-fe-50mm-f14-gm-lens.html
  - SCAN: https://www.scan.co.uk/products/sony-fe-sel50f14gm-50mm-f14-g-master-lens-sony-e-mount-full-frame-lens
  - Clifton Cameras: https://www.cliftoncameras.co.uk/sony-fe-50mm-f14-gm-lens
  - Cotswold Cameras: https://www.cotswoldcameras.co.uk/Sony-FE-50mm-f1-4-GM-Lens
- **Findings:** Sony official **£1,499**, delivery from 12 November. LCE **£1,499**, in stock; £1,299 after £200 cashback. Camix direct page **£1,007 inc VAT / £839.17 ex VAT**, two left, in stock, brand new, one-year warranty, free UK delivery. CameraWorld direct page **£1,489 new** in stock (3–5 days) and **£1,425 open-box** unique item. SCAN **£1,498.99** awaiting ETA. Clifton **£1,499** awaiting stock. Cotswold Shopping/search result displayed £739, but opened product page did not expose that amount.
- **RED VERIFY:** Check the unusually low Cotswold £739 search-card price; direct page did not confirm it. Camix £1,007 is a material discount to Sony/LCE pricing; verify stock and checkout price. Shopping also returned FE 50mm F1.2 and filter accessories, which are not this F1.4 lens.

## Google Shopping / product-result click-through notes

Product-shopping cards were clicked/opened where available. Important mismatches found:
- HVR-HD1000E card surfaced an Etsy £741.30 result and eBay £248.75 lead; direct UK eBay listing 336522927009 showed £325.
- Skydio dual-charger card showed £52.70; clicked eBay page showed £72.92 and the title was Skydio 2+, not X2.
- Sony E 35mm F1.8 OSS searches returned FE 35mm F1.4 and FE 35mm F2.8 lenses; these are not the APS-C E 35mm F1.8 OSS.
- SmallRig 3263 searches returned SmallRig 4297 and MagicFIZ 3781 kit; neither is 3263.
- Sony PXW-Z1500 searches returned PXW-Z150; no official Z1500 product was found.
- Sony PXW-Z190V searches returned PXW-Z190 without V suffix.
- Sony MKS-R3210 searches returned BKS-R3210 two-panel listing; different model.
- Sony HDC-3200 searches returned HXC-FB75; different camera.
- Sony FE 50mm F1.4 GM searches returned FE 50mm F1.2 and filter accessories; not exact.
- Sony FE100 Macro GM shopping card produced a CeX £752.95 lead, but CeX direct page fetch timed out; retain as unverified lead.

## Queue-staging/authentication result

The final LIVE owner-auth check returned:
- `auth.uid()`: `null`
- `auth.role()`: `null`
- `platform_cloud_ai_owner_check()`: `false`

The LIVE schema exposes platform-owner RPCs for listing, reviewing and deleting catalogue research queue items, but no supported authenticated insert/stage RPC was found. Because the owner context failed and there is no staging RPC, **no direct table write, impersonation, claim manipulation or RLS bypass was attempted**.

Batch 12 therefore has **0 pending-review queue rows staged**. All 20 researched candidates are preserved in this checkpoint for later authenticated staging.

## Final verification and safety

- 20 selected LIVE product IDs documented.
- Recheck after research: each still had 0 active shared market evidence, 0 matching outstanding queue candidates and 0 matching outstanding manual prompts.
- Queue status snapshot: 28 imported / 10 needs_research / 43 rejected.
- Manual AI prompt status snapshot: 1 completed / 1 ready.
- No master product rows created or changed.
- No shared market evidence rows created or changed.
- No valuation logic or schema changed.
- No TEST or Stripe access/writes.
- No GBP conversion of foreign currency.

## Next run — Batch 13

1. Read Batch 02 continuity files and every scheduled checkpoint/project-memory file through the latest production batch (Batch 12).
2. Exclude every product ID and product identity already researched, including cross-UUID duplicates.
3. Exclude outstanding LIVE queue candidates and outstanding manual AI research prompts.
4. Select the next 20 active LIVE master products with no active shared market evidence using a dynamic query; do not use SQL OFFSET.
5. Recheck evidence and queue status immediately before research.
6. Research and click through manufacturer, UK retailer, marketplace and Google Shopping links.
7. Preserve uncertain links with RED VERIFY notes.
8. Check owner auth first. Only stage through a supported authenticated platform-owner RPC. If auth.uid is null or owner check false, create the next checkpoint and project-memory files instead of writing directly.


## 6. RED VERIFY follow-up — 12 November 2026

Thirteen additional source observations were inserted and read back; one earlier price-conflict observation was deactivated.

| Master product | Source | Price | Evidence / status |
|---|---|---:|---|
| Sony HVR-HD1000E | eBay UK — saff_19 | £312.70 | Used; plus £12.36 postage; four used batteries and shoulder bag; 100% feedback, no returns. Bundle differs from body-only. [Source](https://www.ebay.co.uk/p/100062910?iid=236300096693) |
| Sony E 35mm F1.8 OSS | Cotswold Cameras | £269.00 | New; reduced from £325; exact SEL35F18 APS-C E-mount; availability not explicit. [Source](https://www.cotswoldcameras.co.uk/Sony-E-35mm-F18-OSS-Lens-SEL35F18) |
| Sony E 35mm F1.8 OSS | CameraWorld | £319.00 | New; product code 166936 / EAN 4905524894912; in stock, 3–5 day dispatch. [Source](https://www.cameraworld.co.uk/sony-35mm-f1-8-oss-sel35f18.html) |
| Sony PXW-FS5 | Wex Photo Video | £493.00 | Used Good; item 3348017; 6,000 shutter count, clean sensor, in stock; accessory contents noted. [Source](https://www.wexphotovideo.com/sony-pxw-fs5-4k-professional-camcorder-used-3348017/) |
| Sony PXW-FS5 | Wex Photo Video | £425.00 | Used Well Used; item 3348010; 750 shutter count but sensor dust visible from f/10; in stock. Fault retained. [Source](https://www.wexphotovideo.com/sony-pxw-fs5-4k-professional-camcorder-used-3348010/) |
| Sony FE 100mm F2.8 Macro GM OSS | Camix | £1,208.00 | New; two left, in stock, 1-year warranty, free UK delivery. [Source](https://camix.co.uk/product/sony-fe-100mm-f2-8-macro-gm-oss-lens/) |
| Sony FE 100mm F2.8 Macro GM OSS | London Camera Exchange | £1,399.00 | New; UK stock, Add to Basket, free delivery. [Source](https://www.lcegroup.co.uk/New/Sony-FE-100mm-F2.8-Macro-GM-OSS-Lens_211626.html) |
| Sony FE 100mm F2.8 Macro GM OSS | Campkins Cameras | £1,399.00 | New; one in stock, UK stock/warranty, free delivery over £100. [Source](https://www.campkinscameras.com/sony-fe-100mm-f2-8-macro-gm-oss-lens/) |
| Sony FE 100mm F2.8 Macro GM OSS | Wilkinson Cameras | £1,399.00 | New; stock at Liverpool and Preston branches, UK warranty. [Source](https://www.wilkinson.co.uk/sony-fe-100mm-f2-8-macro-gm-oss-lens/) |
| Sony FE 50mm F1.4 GM | Sony UK | £1,499.00 | New; official store, one left, Add to Basket. [Source](https://www.sony.co.uk/store/product/sel50f14gm.syx/FE-50-mm-F1-4-GM-G-Master-Full-frame-Standard-Lens) |
| Sony FE 50mm F1.4 GM | London Camera Exchange | £1,499.00 | New; in stock; £200 cashback after claim (pay £1,499 first). [Source](https://www.lcegroup.co.uk/New/Sony-FE-50mm-F1.4-G-Master-Lens_135488.html) |
| Sony FE 50mm F1.4 GM | CameraWorld | £1,499.00 | New; one available, 3–5 day dispatch, free UK delivery; £200 cashback claim. [Source](https://www.cameraworld.co.uk/sony-fe-50mm-f14-gm-lens.html?condition=new) |
| Sony FE 50mm F1.4 GM | CameraWorld | £1,425.00 | Open-box unique item, in stock; recorded separately from new stock. [Source](https://www.cameraworld.co.uk/sony-fe-50mm-f14-gm-lens.html) |

The Sony UK E 35mm F1.8 OSS £225 observation was rechecked. The same page exposed £225 sale-price context and £325 original/product-page price without a clear selectable checkout price; it was retained but marked inactive / price_conflict. This prevents the uncertain £225 from becoming the latest active UK New valuation source. The active CameraWorld £319 and Cotswold £269 observations remain.

The existing HXR-MC2500E eBay £789.99 row was rechecked: current search result confirms free delivery in three days, seller 99.8% positive, 9.1K feedback; E suffix and 32GB internal-memory regional variant caveat remains.

Batch 12 now has **25 total records: 24 active (16 UK New, 8 UK Used) and one inactive price-conflict row; all 25 are GBP**. The inactive row is the ambiguous Sony UK E 35mm F1.8 £225 price. Used rows remain reference-only. The PXW-FS5 sensor-dust listing remains clearly marked as faulty/condition-limited; HVR-HD1000E listing includes a different accessory bundle.

Other RED VERIFY items remain excluded: Skydio X2 enterprise controller/charger has USD-only or consumer 2/2+ mismatches; Yuneec E10Tvx has EUR/PLN only; Walkera Vitus Starlight listing contents say Vitus 320; PXW-Z1500 appears to be a PXW-Z150 typo; HZCU-FZ90 appears to be HXCU-FZ90 CCU; PXW-Z190V seller's GSP UK delivery total not confirmed; Sony NEX-FS100 package contents not confirmed; MKS-R3210 only EUR quote and BKS-R3210 wrong model; SmallRig 3263 no UK GBP price; UHC-8300 CCU is separate; HDC-3200 dual-filter SKU package needs comparison; E-Infinity Sony FE100 macro price needs import/checkout confirmation. No unverified currency, model or package match was promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 7. Further RED VERIFY review — 12 November 2026

Two further exact UK observations were added to LIVE and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| Sony NEX-FS100 | eBay UK — ashuk786 | £768.08 | Used; private UK seller in Luton, 100% positive; no returns; listing does not itemise lens/accessories, so package remains unspecified. [Source](https://www.ebay.co.uk/itm/204601074708) |
| Z CAM ExAscend CFast 2.0 Reader | ProAV | £51.60 inc VAT (£43 ex VAT) | Exact single-slot 10Gbps reader, UK price; backorder, typical delivery when stocked around four weeks. [Source](https://proav.co.uk/accessories/card-readers/cfast/) |

Two existing observations were rechecked and clarified:
- Walkera Vitus Starlight: the direct RC Hobby Avenues page title and model field both say Vitus Starlight. Its technical specifications identify the underlying aircraft platform as Vitus 320; this is not a different product listing. £544.91, in stock. The earlier RED VERIFY identity concern is resolved. Package contents are case, 8 propellers, 3 batteries, DEVO F8S remote, phone holder and instructions.
- Sony FE 50mm F1.4 GM / Camix: direct product page reconfirmed £1,032 inc VAT (£860 ex), brand new, in stock, one-year warranty, free UK delivery; box contents are lens, front/rear caps and hood. The previously low price is verified on the opened retailer page and remains active.

Batch 12 now has **27 total GBP records: 26 active (17 UK New, 9 UK Used) and one inactive price-conflict row**. The inactive row remains Sony UK E 35mm F1.8 OSS £225, because the same page exposed £225 sale context and £325 original/product-page price without a clear checkout selection. The two new rows are one UK New (Z CAM reader) and one UK Used (NEX-FS100).

Other RED VERIFY exclusions remain: Skydio X2 controller/charger has no verified UK price and consumer 2/2+ products are different; Yuneec E10Tvx has EUR/PLN only; HZCU-FZ90 is likely a catalogue typo for HXCU-FZ90 CCU and ProAV HXC-FZ90 is a different camera head; PXW-Z1500 is not an identified Sony model (PXW-Z150 is different); PXW-Z190V remains suffix/package-specific; SmallRig 3263 has no confirmed UK GBP offer; MKS-R3210 has no exact UK price; NEX-FS100 high-price Snet listing has bundle contents unresolved; HDC-3200 dual-filter SKU package needs comparison; UHC-8300 CCU is separate from camera head. No foreign-currency or wrong-model evidence was promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## Exact HXR-MC2500E master correction — 12 November 2026

The existing £789.99 eBay UK used observation (row a92bb4e6-7fb1-436f-bb26-19f4795ed61f; source_record_key batch12-sony-hxr-mc2500e-ebay-78999) had been attached to the non-E HXR-MC2500 master. A fresh direct listing check confirmed exact model HXR-MC2500E, 32GB internal memory and Wi-Fi; the seller's item specifics confirm HXR-MC2500E, excellent used condition, fully tested and working, brand-new battery and charger, UK business seller KRTN Plaza, 99.8% positive and 30-day returns. The LIVE catalogue already contains an exact HXR-MC2500E / Standard master, ID 7c3e5517-1c19-4080-bd65-7cb41a4925f3.

Corrected the existing evidence row's master_product_id to the exact HXR-MC2500E master; no duplicate inserted and no price/condition/source data changed. Direct listing: https://www.ebay.co.uk/itm/318668491967. LIVE read-back confirms the row now joins to model HXR-MC2500E / Standard at £789.99 GBP, UK Used, active. The non-E HXR-MC2500 master no longer receives this row.

Batch 12 counts are unchanged: 27 total, 26 active (17 UK New, 9 UK Used), one inactive price-conflict row. Cumulative Batches 03–13 now 246 observations, 243 active (133 UK New, 110 UK Used), three inactive. No master product, schema or valuation logic changed; TEST and Stripe untouched.


## Camera-head package scope re-verification — UHC-8300 and HDC-3200 — 12 November 2026

Direct Visual Impact pages were reopened to resolve the remaining package-scope RED VERIFY notes. Existing evidence rows were updated in place; no duplicate observations were inserted:
- UHC-8300 row 1b7ae87f-0944-44d2-ab66-128d462fe934: exact UHC-8300 8K portable studio camera head, £396,117.94 inc VAT (£330,098.28 ex), available to order but not held in stock. Page explicitly says the complete system is UHC-8300 head + separate UHCU-8300 CCU. In The Box lists manual, cable clamp belt, camera number label, screws and lens mount cap; no CCU, lens or viewfinder. Source https://www.visuals.co.uk/uhc-8300.html.
- HDC-3200 row 337cdfd8-3967-413b-b61c-7d64c4381df5: exact HDC-3200/DF camera head with dual-filter option, £37,651.84 inc VAT (£31,376.53 ex), available to order but not held in stock. HDCU-3500/3100 CCU or HDCE extension adaptor are separate system components; lens/viewfinder not listed as included. Source https://www.visuals.co.uk/sony-hdc-3200-4k-hd-smpte-fibre-interface.html.

Both observations are explicitly camera-head-only, not complete camera systems. This resolves the package-scope question for their existing Standard masters without changing master catalogue data.

MKS-R3210 remains RED VERIFY: no exact UK GBP source found. Sony UK/Europe pages confirm the 32-button NS-BUS remote panel but no price; Pro-Media/Videolinea prices are EUR; eBay UK £61.75 is for 2 × BKS-R3210, a different model. Do not map that price to MKS-R3210. Batch 12 counts unchanged at 27 total, 26 active (17 UK New, 9 UK Used), one inactive. No master/schema/valuation changes; TEST and Stripe untouched.
