# TradeFlow LIVE — Scheduled Market Evidence Batch 04

**Research date:** 12 November 2026  
**Repository:** `laurendigitaluk/TradeFlow`  
**Branch:** `production`  
**Environment:** TradeFlow LIVE only  
**Scope:** 20 active catalogue master products with no active shared market evidence  
**Outcome:** Research completed and recorded here; queue staging blocked by missing authenticated platform-owner context.

## 1. Continuity and selection controls

Read before selecting products:

- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md`
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md`

The scheduled batch 02 and batch 03 checkpoint UUIDs were excluded. The selection also excluded every product referenced by manual AI research prompts (including completed prompts, to avoid repeating earlier work) and every product covered by a LIVE research-queue candidate with status `needs_research`, `pending_review` or `approved`.

No fixed SQL OFFSET was used. The next 20 eligible active LIVE masters were selected using anti-joins against active shared evidence, checkpoint exclusions, manual prompt product arrays and outstanding queue candidates. Immediately before research, all 20 were rechecked: each remained active and had 0 active shared-market-evidence rows, 0 matching outstanding queue candidates and 0 matching outstanding manual AI prompts.

Queue/prompt context at selection:
- LIVE research queue: 28 imported, 10 needs_research, 43 rejected.
- Manual AI prompts: one completed prompt covering 20 products and one ready/in-progress prompt covering 20 products.
- The 10 outstanding queue candidates and both prompt product sets were excluded from this batch.

## 2. Queue staging / authentication limitation

Checked the LIVE owner-auth context before any write:

- `auth.uid()`: null
- `auth.role()`: null
- `public.platform_cloud_ai_owner_check()`: false

The authenticated platform-owner RPC cannot be safely called in this context. No direct insert/update was attempted against `platform_catalogue_research_queue`; no claims were impersonated; RLS was not bypassed. No research candidates from this batch have been staged as pending review.

This checkpoint and the paired project-memory file are the recovery record requested for the next run. The 20 records below are research candidates only, not imported evidence. No master products, valuation logic, schema, TEST environment or Stripe data were changed.

## 3. Research method and data rules

Searched manufacturer sources, UK retailer pages, used marketplaces and Google Shopping/product-shopping results. Opened actual product pages or shopping click-through pages where a product result was available. Checked product/package identity, selectable variants where exposed, displayed GBP prices, condition and availability. Google Shopping results that resolved to a different model, package or accessory were not treated as exact matches.

GBP prices below are only values displayed in GBP by the source. EUR, USD, BRL and other currencies are preserved as displayed and are not converted. A blank GBP price means no reliable GBP price for the exact master/package was established. Sold-out, ended, imported, unverified and close-match links are retained with their limitations.

## 4. Batch products and evidence findings

### 1) Sony — FE 85mm F1.4 GM II
- **LIVE master product ID:** `00b78f50-3b57-4ff5-bfdf-554942669ca8`
- **Catalogue package:** Standard
- **Exact match:** Yes.
- **Manufacturer page:** [Sony UK FE 85mm F1.4 GM II](https://www.sony.co.uk/store/product/sel85f14gm2b.syx/FE-85mm-F1-4-GM-II-Full-Frame-Prime-Lens) — £1,799 standalone; page showed low stock (one left in one capture). Sony also displayed £1,599 as the lens price within a custom α7 V bundle; this is not the standalone price.
- **UK retailer:** [ProAV](https://proav.co.uk/sony-fe-85mm-f1-4-gm-ii-full-frame-prime-lens) — £1,698 inc VAT / £1,415 ex VAT; search page showed three in stock for immediate dispatch.
- **UK retailer:** [Camera Centre UK](https://www.cameracentreuk.com/sony-fe-85mm-f1-4-ii-g-master-full-frame-e-mount-lens) — £1,799, with £100 cashback / £1,699 after cashback; page showed in stock.
- **Shopping click-through:** [Cotswold Cameras](https://www.cotswoldcameras.co.uk/Sony-FE-85mm-f14-G-Master-II-Lens-SEL85F14GM2) — product page showed £1,049; Shopping card showed a different £1,004 and other merchant values. **RED VERIFY:** price differs materially from Sony and other UK dealers; check seller, VAT, stock and checkout total before relying on the low figure.
- **Condition/availability:** New retail listings; stock varies by retailer.
- **Notes:** Do not treat Sony's £1,599 bundle component price as a standalone offer.

### 2) RØDE — Wireless GO II
- **LIVE master product ID:** `02467f84-18d4-46db-b045-1038a52e791c`
- **Catalogue package:** Standard Item
- **Exact match:** Exact dual-channel kit references found; some retailers offer single-transmitter packages and those must remain separate.
- **UK retailer:** [RadioActive dual-channel system](https://radioactive.org.uk/product/rode-wireless-go-ii-dual-channel-wireless-microphone-system/) — £239; product page identifies the dual-channel system.
- **UK retailer:** [Production Gear](https://productiongear.co.uk/products/rode-wireless-go-ii-compact-wireless-microphone-system) — £180 inc VAT / £150 ex VAT. Product description identifies receiver plus two transmitters. Page simultaneously displayed “Sale Sold out” and “Only 1 left in stock”. **RED VERIFY:** contradictory availability; retain price and link, confirm with seller.
- **Import marketplace:** [Ubuy UK 2 TX + 1 RX](https://www.u-buy.co.uk/product/2K552BS-rode-microphones-wireless-go-ii-dual-channel-wireless-microphone-system) — GBP 158 displayed, in stock, imported from USA. Price excludes shipping, VAT and customs charges. Contents explicitly list one receiver and two transmitters. **RED VERIFY:** confirm landed price, import charges, warranty and return route.
- **UK retailer:** [DealMonday dual-channel system](https://www.dealmonday.co.uk/rode-wireless-go-ii-microphone-system-dual-channel) — £209.99, brand new, VAT included; 12-month warranty and 14-day returns stated. **RED VERIFY:** verify seller and actual stock before relying on this unusually discounted price.
- **Marketplace:** [eBay UK dual microphone system](https://www.ebay.co.uk/itm/366432956788) — £99.99, used Grade B; seller notes confirm two transmitters, one receiver, two windscreens and pouch, no original box. London business seller; listing page currently says out of stock and no returns. Retain as used-market evidence.
- **Package mismatch excluded:** [Park Cameras single set](https://www.parkcameras.com/shop/rode-wireless-go-ii-single-set-wireless-microphone-system_9101096s) — £159, but one transmitter only; not an exact dual-transmitter package.
- **Condition/availability:** New and used references; sold-out/out-of-stock flags retained.
- **Notes:** Do not confuse Wireless GO II single set, transmitter-only or receiver-only parts with the full 2 TX + 1 RX kit.

### 3) Autel Robotics — EVO Lite 6K Enterprise
- **LIVE master product ID:** `02a01cd0-e018-49c2-81fb-2bfc45917022`
- **Catalogue package:** EVO Lite 6K Enterprise Basic Bundle
- **Exact match:** Product family identified; exact basic-bundle contents not confirmed.
- **French retailer:** [Prodrones Autel EVO Lite 6K Enterprise](https://shop.prodrones.fr/autel-robotics/1688-autel-evo-lite-6k-enterprise.html) — EUR 1,619.00 TTC displayed; page says on order and also says product is no longer available for sale. Page fetch returned 403 after search indexing, but the product result exposed model and specifications. **GBP price left blank.**
- **German distributor:** [DP-Dynamic Autel distributor](https://www.dp-dynamic.de/) — lists EVO Lite Enterprise 6K at EUR 1,619.00 UVP; no exact basic-bundle contents or GBP price.
- **US package comparison:** [DSLRPros Premium Package](https://www.dslrpros.com/products/autel-evo-lite-6k-enterprise-premium-package) — USD 2,059.00, not converted. This is a **Premium Package**, not the catalogue's Basic Bundle. In-box list: aircraft with battery/props/gimbal cover, Smart Controller SE V2, two spare batteries (three total), power adapter, spare propeller pairs, RC cables, ND filters, vertical stand and hard case.
- **Non-match excluded:** [OpticsWorld EVO Lite 640T Enterprise](https://www.opticsworld.co.uk/product/autel-evo-lite-640t-enterprise-thermal-imaging-drone/) — £3,099 inc VAT, in stock, but this is the 640T thermal model, not the 6K Basic Bundle.
- **Shopping findings:** Shopping surfaced EVO II Pro / EVO Lite+ and other Autel models, not a verified UK listing for this exact Basic Bundle.
- **Condition/availability:** EUR listing on order/unavailable; US premium bundle listed.
- **Notes:** **RED VERIFY** exact basic-package contents and UK seller availability. Do not convert EUR or USD into GBP.

### 4) Z CAM — EVF / EV101 Electronic Viewfinder
- **LIVE master product ID:** `037bf6aa-c253-47f5-a629-b369161acf48`
- **Catalogue package:** Z CAM EVF Electronic Viewfinder EV101
- **Exact match:** Yes, EV101.
- **Manufacturer:** [Z CAM EVF official product page](https://www.z-cam.com/products/professional-cameras/e2-accessories/evf/) — confirms EV101 model and 1440×1440 display, HDMI/SDI, wireless HDR, LUTs and exposure tools; no price.
- **UK retailer:** [ProAV](https://proav.co.uk/z-cam-evf-electronic-viewfinder) — £958.80 inc VAT / £799 ex VAT; page says in stock but also says backorder available, typically within one week. Call to confirm.
- **UK retailer:** [CVP](https://cvp.com/product/z-cam-ev101-electronic-viewfinder) — £895 inc VAT / £745.83 ex VAT; exact EV101 page, stock status not clearly stated in the captured page.
- **UK retailer:** [Production Gear](https://productiongear.co.uk/products/z-cam-evf-electronic-viewfinder) — £895 inc VAT / £745.83 ex VAT; sold out / out of stock.
- **UK retailer:** [Cinegearpro](https://www.cinegearpro.co.uk/collections/viewfinders/products/z-cam-evf-electronic-viewfinder) — £1,123.87 inc VAT / £936.56 ex VAT; pre-order, London store and external warehouse out of stock.
- **Shopping findings:** Shopping click-through resolved to ProAV at £958.80. A separate eBay card showed approximately £618.70, but the exact item URL/seller page was not resolved in this run. Do not stage that price without the direct listing link.
- **Condition/availability:** New; stock/backorder differs by seller.
- **Notes:** Multiple exact UK GBP prices captured; retain individual source and VAT basis rather than averaging.

### 5) Sony — DSR-PD175P Camcorder
- **LIVE master product ID:** `03a54715-6098-401e-91ba-9140a55f6901`
- **Catalogue package:** Standard Package
- **Exact match:** Yes.
- **Used/refurbished seller:** [Kabayo DSR-PD175P](https://kabayo.ltd/en/products/44-sony-dsr-pd175p-pro-dvcam-camcorder-uk-eu.html) — £400. Used, fully tested, refurbished cassette transport and seller says known C:32:10 lens error was fixed. Includes camcorder body/lens hood, working 90-minute battery and AC adapter/power cable. Seller states free insured delivery within EU/UK. No customer reviews. **RED VERIFY:** seller identity/reputation, warranty and repair claim.
- **Retailer:** [Photospecialist UK](https://www.photospecialist.co.uk//sony-dsr-pd175p-camcorder) — £3,357.00, on order / purchased exclusively for customer. Product page request was rate-limited, but exact product result was returned.
- **Shopping findings:** Shopping results returned DSR-PD170P and DSR-450WSP variants, not DSR-PD175P; those are not exact matches.
- **Condition/availability:** Used/refurbished £400 listing; new/on-order £3,357 reference.
- **Notes:** Preserve both price points with the different condition and source reliability.

### 6) Olympus/OM SYSTEM — VF-4 Electronic Viewfinder
- **LIVE master product ID:** `03ebaec4-f328-4744-b8b5-7355eb03e182`
- **Catalogue package:** Standard
- **Exact match:** Yes.
- **Used retailer:** [MPB Olympus VF-4](https://www.mpb.com/en-uk/product/olympus-vf-4-electronic-viewfinder) — five used units from £146 to £164; Good £146 and Excellent £164; 12-month warranty. Direct page fetch timed out, but indexed product page shows all five individual stock entries.
- **Marketplace:** [eBay UK VF-4](https://www.ebay.co.uk/itm/820200334696) — £235.23, used, seller in Tokyo, Japan, business seller with 98.5% positive feedback; page opened and identified exact VF-4. Check shipping/import costs.
- **Additional eBay listing:** [VF-4 listing #0007](https://www.ebay.co.uk/itm/820176710510) — £207.16 used, Japan seller; retain as a second comparison.
- **Shopping findings:** Shopping results surfaced VF-1/VF-2/VF-3 accessories, not exact VF-4 matches; those were rejected as model mismatches.
- **Condition/availability:** Used; MPB five units shown; eBay import listings.
- **Notes:** MPB currently provides the strongest UK used reference.

### 7) Hubsan — ZINO 2+
- **LIVE master product ID:** `04533da4-4a56-493a-93f7-f928a84ae237`
- **Catalogue package:** ZINO2 PLUS
- **Exact match:** Yes for Sussex Model Centre standard listing.
- **UK retailer:** [Sussex Model Centre ZINO 2+](https://sussex-model-centre.co.uk/products/hubsan-zino-2-folding-drone-4k-fpv-5-8g-gps-follow-rth) — £519.99, sold out/unavailable, SKU/barcode H517P; page describes 4K, three-axis gimbal, smart battery and 9km transmission.
- **UK bundle listing:** [ZINO 2+ with extra battery and bag](https://sussex-model-centre.co.uk/products/hubsan-zino-2-folding-drone-w-storage-bag-extra-battery) — £599.99, sold out; additional battery and storage bag, so different package.
- **Marketplace:** [Fruugo ZINO 2+ three-battery listing](https://www.fruugo.co.uk/drone-hubsan-zino-2-gps-fpv-4k-60fps-camera-3-axis-detachable-gimbal-9km-wifi-3-battery-white/p-70437367-141284121) — £799.00, currently unavailable, seller Naiwangshop, listing brand field says “Unbranded”; title says ZINO 2+ and three batteries. **RED VERIFY:** exact manufacturer/model authenticity, package contents and seller.
- **Shopping findings:** Shopping results mostly surfaced older Zino / Zino Pro products, not exact ZINO 2+; do not map those as exact.
- **Condition/availability:** Standard and extra-battery UK listings sold out; Fruugo currently unavailable.
- **Notes:** Retain sold-out prices as historical asking-price evidence.

### 8) Nikon — D2HS
- **LIVE master product ID:** `0510c179-9f73-493a-b139-96890a49d875`
- **Catalogue package:** Nikon D2HS
- **Exact match:** Yes.
- **Completed-sale marketplace:** [eBay UK D2HS body-only item 298530064911](https://www.ebay.co.uk/itm/298530064911) — sold used listing, displayed £114.25 including £4.25 Buyer Protection; seller private in Ilkley, UK; no returns.
- **Completed-sale marketplace with fault:** [eBay UK D2HS LCD fault item 336674844711](https://www.ebay.co.uk/itm/336674844711) — sold listing displayed £91.52 including £3.52 Buyer Protection and states Best Offer accepted; rear LCD not working. **RED VERIFY:** actual accepted offer amount is not visible; £91.52 is not a confirmed sale proceeds figure.
- **Google Shopping lead:** [eBay UK D2HS “Junk Used” item](https://www.ebay.co.uk/itm/318940217780) — Shopping result showed £220.19 from Hard-Off Japan. Direct click-through was inaccessible in this run; title indicates junk/used. **RED VERIFY:** direct listing, defect, seller, shipping and import charges.
- **Shopping findings:** Exact D2HS result surfaced, but the current item page could not be opened.
- **Condition/availability:** Historical used completed sales plus one unverified current/Shopping junk listing.
- **Notes:** Buyer Protection fees are part of displayed buyer totals; do not infer seller proceeds.

### 9) DJI — Matrice 350 RTK
- **LIVE master product ID:** `0517047c-a570-420a-878e-6f5590fffd59`
- **Catalogue package:** Standard Package
- **Exact match:** Product model exact; package alias needs review.
- **UK retailer / Shopping click-through:** [Drone Sales UK Matrice 350 RTK Worry-Free Basic Combo](https://dronesales.co.uk/product/dji-matrice-350-rtk-worry-free-basic-combo/) — £10,959.00. Page opened from the Shopping result and lists: aircraft, RC Plus, WB37 battery, two TB65 batteries, carrying case, BS65 battery station, two landing gear, propellers, screws/tools, cleaning tools, four spare gimbal dampers and rubber port cover. Quote request; page says orders over £10,000 excluding VAT require contact with sales.
- **UK retailer:** [QuadRotor Services Matrice 350 RTK “Drone Only”](https://www.quadrotor.co.uk/store-all/p/dji-matrice-350-rtk-drone-only) — £8,389.00. Despite title “Drone Only”, page says package includes aircraft, RC Plus, WB37 battery, carrying case, two landing gear, propellers, screws/tools and spare gimbal dampers; it does not list TB65 batteries or BS65 charging station. Payment/shipping via enquiry form.
- **Manufacturer:** [DJI Matrice 350 RTK official page](https://enterprise.dji.com/matrice-350-rtk) — official model/specification reference; page redirected to DJI's Portuguese locale during access; no UK price.
- **Condition/availability:** New enterprise product listings; Drone Sales quote required, QuadRotor enquiry required.
- **Notes:** **RED VERIFY** whether the catalogue “Standard Package” should match Drone Sales Worry-Free Basic Combo or the smaller QuadRotor package. Do not collapse the two prices or package contents.

### 10) Hubsan — MINI 7
- **LIVE master product ID:** `05e9a890-ea1b-4712-ade3-18210908defa`
- **Catalogue package:** HUBSAN MINI 7
- **Exact match:** Product model confirmed; only Brazilian source located.
- **Manufacturer/distributor information:** [Aerion Hubsan Mini 7 product page](https://aerion.com.br/produtos/hubsan-mini-7/) — confirms Mini 7, under 249g, 1-inch 48MP sensor, 4K/30fps, 3-axis gimbal, up to 28-minute flight, HT55 controller and stated 16km transmission; Brazilian Anatel approval.
- **Brazilian store listing:** [Aerion Mini 7 store page](https://aerion.com.br/loja/produto/hubsan-mini-7/) — search result displayed R$ 5.999,99. Product page itself did not expose a GBP price. **GBP price left blank.**
- **Shopping findings:** No exact UK Google Shopping match found; other Hubsan Zino/Hs07a cards are different models.
- **Condition/availability:** New retail product page; local Brazilian availability.
- **Notes:** Preserve R$ 5.999,99 as BRL in notes only; do not convert. **RED VERIFY** UK availability and whether this model is officially supplied in the UK.

### 11) Skydio — Skydio 2
- **LIVE master product ID:** `0b135055-2325-49bf-af9e-673434e179cb`
- **Catalogue package:** Standard Package
- **Exact match:** Yes for eBay used drone listing; bundle accessories differ.
- **Marketplace:** [eBay UK Skydio 2 with spare batteries and hard case](https://www.ebay.co.uk/itm/198638051381) — ended 20 September 2026; used; £750 displayed as auction figure with zero bids, and £1,050 Buy It Now shown. Listing included spare batteries and hard transport case. Private seller in Bristol. **RED VERIFY:** neither £750 nor £1,050 is a confirmed completed sale price.
- **Marketplace mirror / faulty item:** [Grelly Skydio 2 listing](https://www.grelly.uk/itm/skydio-2-autonomous-drone-and-multiple-accessories-used--267663614820) — £500 plus £15.95 shipping, seller in Greece, “for parts or not working”, camera gimbal issue. Retain link but clearly mark non-working condition; not a working-unit price comparable.
- **Shopping findings:** No exact UK Shopping product listing surfaced; app and Skydio 2+ results were not treated as Skydio 2 product evidence.
- **Condition/availability:** Ended used listing; faulty parts listing.
- **Notes:** **RED VERIFY** whether eBay relisted item has a new URL and current condition.

### 12) Nikon — F-801
- **LIVE master product ID:** `0e19c5f6-3c26-4fe7-a23c-2cb0f7e6ea4e`
- **Catalogue package:** Nikon F-801
- **Exact match:** Exact body listing found; other bundle/suffix matches are separate.
- **UK retailer:** [Camera Centre UK used Nikon F-801 body](https://www.cameracentreuk.com/used-nikon-f-801-35mm-film-slr-camera-body-autofocus-nikon-f-mount) — £99, used, good condition, fully tested body-only, in stock, free shipping and 3-month warranty. Page returned 403 on open but search result provided the full product details. 
- **Google Shopping click-through:** [Hard to Find Camera Store F-801 kit](https://www.htf-store.com/products/nikon-f-801-35mm-slr-kit-with-sigma-28-70mm-f-3-5-4-5?variant=56082028888404&country=GB&currency=GBP&utm_medium=product_sync&utm_source=google&utm_content=sag_organic&utm_campaign=sag_organic) — Shopping card displayed £149.20; kit includes Sigma 28–70mm lens. **RED VERIFY:** condition, stock and exact package; not body-only.
- **Close suffix match:** [eBay UK Nikon F-801s](https://www.ebay.co.uk/itm/287612211300) — £109.19, used, private seller in Glasgow. This is F-801s, not exact F-801; retain only as a close comparison and do not map as exact.
- **Shopping findings:** F-801 kit results surfaced; package mismatch noted.
- **Condition/availability:** Used body listing in stock; kit and F-801s comparisons.
- **Notes:** Keep F-801 and F-801s separate.

### 13) NEEWER — Pro 340cm C Stand
- **LIVE master product ID:** `0ff8aa32-9e56-4ee3-8039-5aaf06e84031`
- **Catalogue package:** NEEWER Pro 340cm C Stand
- **Exact match:** Exact variant selectable on the official combined product page.
- **Manufacturer UK page:** [NEEWER Pro 330cm/340cm C Stand](https://uk.neewer.com/products/neewer-100-stainless-steel-c-stand-with-boom-arm-pro-66602216) — displayed “from £175.99” in the opened page; an earlier crawl showed £179.99. Variant options are 330cm SC320AC and 340cm SC340AW. The SC340AW specification confirms 340cm maximum height, 3 wheels, stainless steel, air-cushioned/spring-loaded pole and 20kg central load capacity. Package contents for SC340AW: crossbar, adjustable centre pole, collapsible turtle base, two grip heads, three wheels and manual.
- **Availability:** Page top says “More stock coming soon”, while option section says “In stock”; selected-variant stock and price are not isolated in the captured page.
- **Shopping findings:** Shopping results returned other NEEWER stands (320cm/120-inch or unrelated light stands), not the exact SC340AW variant.
- **Notes:** **RED VERIFY** exact SC340AW price and stock; do not attach the starting price to the 340cm variant without selecting it.

### 14) Bebob — V150microC V-Mount Battery
- **LIVE master product ID:** `15cdcd88-f159-43cb-b0ac-54547b220723`
- **Catalogue package:** Bebob V150microC V-Mount Battery
- **Exact match:** Yes, SKU V150MICRO-C.
- **UK retailer:** [ProAV Bebob V150microC](https://proav.co.uk/bebob-v150microc-v-mount-li-ion-battery) — £406.80 inc VAT / £339 ex VAT. Page says “Availability: In stock” but also “Backorder available — order now; delivery when in stock, typically within 2 weeks”; advises calling to confirm.
- **Google Shopping click-through:** [CVP Bebob V150microC](https://cvp.com/product/bebob-v150microc-battery) — Shopping card displayed £406.80, CVP/Top Teks merchant references.
- **Near match excluded:** [Production Gear V150micro](https://productiongear.co.uk/products/bebob-v150micro-v-mount-lithium-ion-battery-144v-102ah) — £375.60 inc VAT, sold out, but model omits the “C” suffix; do not merge without confirming variant equivalence.
- **Condition/availability:** New retail product; ProAV stock/backorder wording is contradictory.
- **Notes:** Preserve V150micro and V150microC as separate until model equivalence is confirmed.

### 15) Nikon — AF-S DX Nikkor 18-200mm f/3.5-5.6G ED VR II
- **LIVE master product ID:** `1bff3357-d9bc-4441-80c1-4d5de1c5cd4d`
- **Catalogue package:** Lens
- **Exact match:** Yes, VR II version.
- **Used marketplace / Shopping click-through:** [MPB exact VR II listing](https://www.mpb.com/en-uk/product/nikon-af-s-dx-nikkor-18-200mm-f-3-5-5-6g-if-ed-vr-ii/sku-4233171) — Shopping click-through showed £87.95; direct page timed out in this run.
- **Used marketplace / Shopping click-through:** [eBay UK item 318292861793](https://www.ebay.co.uk/itm/318292861793) — Shopping click-through showed £106.04; direct page fetch inaccessible.
- **Used marketplace:** [eBay UK item 254901977062](https://www.ebay.co.uk/itm/254901977062) — £170.10, used, last one / three sold, seller in Goole, UK.
- **UK retailer:** [London Camera Exchange used VR II](https://www.lcegroup.co.uk/Used/Nikon-AF-S-18-200mm-f/3.5-5.6G-II-ED-VR-DX-%7C-10119797_496745.html) — £149.99, used, good condition, in store Guildford.
- **UK retailer:** [Microglobe VR II](https://www.microglobe.co.uk/nikondxafsnikkor18200mmf3556gedvriilens-p-6847.html) — £539.35 inc VAT (RRP £755.09); exact manufacturer code 2192 / UPC 018208021925. Product page notes it entered catalogue in 2009 and current stock status is unclear. **RED VERIFY** whether this old price is still purchasable.
- **Other marketplace listing:** [eBay UK item 127527564110](https://www.ebay.co.uk/itm/127527564110) — £539.99 used, excellent-condition claim, London business seller; price is unusually high relative to other used references. **RED VERIFY**.
- **Notes:** Current used references range substantially. Do not average; retain condition, seller and stock per source. The older non-VR-II 18-200mm and other variants are not exact matches.

### 16) Casio — EX-ZR3000
- **LIVE master product ID:** `1c0fd153-450e-4201-b9dc-98b9d65daf73`
- **Catalogue package:** Standard Package
- **Exact match:** Yes.
- **Current marketplace:** [eBay UK item 298698768566](https://www.ebay.co.uk/itm/298698768566) — current page showed £190.70 or Best Offer, used, seller Five Star Camera in Toyama, Japan, business seller with 99.9% positive feedback. Seller notes say import tax is not included and shipping method/delivery varies. Exact EX-ZR3000 black.
- **Ended marketplace:** [eBay UK item 206576622846](https://www.ebay.co.uk/itm/206576622846) — ended 7 October 2026, £268.56 including Buyer Protection; used, seller in Japan.
- **Earlier search result:** [eBay UK item 298259345611](https://www.ebay.co.uk/itm/298259345611) — ended/out of stock; search result displayed US$324.29. **No GBP price recorded and no conversion made.**
- **Condition/availability:** Current used Japan listing and ended used listings.
- **Notes:** **RED VERIFY** UK delivery and import tax/landed cost. Keep only source-displayed GBP values where present.

### 17) Sony — HXC-D70L Camera
- **LIVE master product ID:** `1c14094a-4ac9-431b-bee9-c5deb57546ab`
- **Catalogue package:** Standard Package
- **Exact match:** No exact HXC-D70L page found; a close HXC-D70 channel listing was located.
- **Close UK used listing:** [N.I. Broadcast HXC-D70 channel](https://www.nibroadcast.com/1x-sony-hxc-d70-hdsdi-high-definition-multicore-camera-channel-with-cable-rcp-ccu-etc..html) — £4,000, used, stock level 3. This is HXC-D70, not HXC-D70L. Package includes HXC-D70 camera head, HXCU-D70 CCU, approx. 25m multicore cable, modified DVF-L700 monitor and RM-B150 RCP; lens extra. Page says fully working, used in one studio from new.
- **Shopping/search:** No exact HXC-D70L shopping or retailer page surfaced.
- **Notes:** **RED VERIFY** suffix/model identity and whether the catalogue's D70L includes a different lens or camera-channel configuration. Keep GBP price blank for the exact D70L; £4,000 is only a close HXC-D70 channel comparison.

### 18) NEEWER — NS14S 30×120cm Rectangular Softbox Kit
- **LIVE master product ID:** `1d189a97-6ad9-42f2-a1e9-3f8c690e06e4`
- **Catalogue package:** NEEWER BASICS NS14S 30×120cm Rectangular Softbox Kit
- **Exact match:** Exact selectable NS14S variant found.
- **Manufacturer UK page:** [NEEWER NS12S/NS14S softbox kit](https://uk.neewer.com/products/neewer-basics-ns12s-ns14s-rectangular-softbox-kit-66607854) — from £52.99. Options are 24×35in (60×90cm) NS12S and 12×47in (30×120cm) NS14S. NS14S specification confirms 30×120cm size.
- **Availability:** Page top says “More stock coming soon”; option/SKU area says “In stock”. Price is “from” and the selected NS14S price is not isolated.
- **Package-content discrepancy:** Generic package contents list says “1 × NS12S Strip Softbox” plus internal/external diffusers, honeycomb grid and carrying bag, even though NS14S is a selectable option. **RED VERIFY:** confirm actual NS14S package contents and selected variant price.
- **Shopping findings:** No exact Shopping listing surfaced; official manufacturer page is the strongest match.

### 19) Nikon — Nikonos III
- **LIVE master product ID:** `1dd0ad3d-1f21-4c8f-8220-b2fa3da64861`
- **Catalogue package:** NIKONOS III
- **Exact match:** Camera body/model exact; listing also includes 35mm f/2.5 lens.
- **UK retailer:** [Castle Cameras used Nikonos III](https://www.castlecameras.co.uk/used-nikon-nikonos-iii-underwater-35mm-camera-with-35mm-f25-lens/p26737) — £134 current price, was £149, in stock at Bournemouth, six-month warranty. Three-star used condition; product summary says tested and in good working order with slight wear. Includes strap, bracket and an untested strobe flash.
- **Condition/availability:** Used, in stock at Bournemouth.
- **Notes:** Exact camera price is useful. **RED VERIFY** the included strobe because it is explicitly untested; do not infer that the strobe works.

### 20) Olympus/OM SYSTEM — FL-50R Electronic Flash
- **LIVE master product ID:** `1ea7d671-95d5-483a-bb32-eeed10f364b7`
- **Catalogue package:** Standard
- **Exact match:** Yes.
- **Used retailer:** [Kamerastore Olympus FL-50R](https://kamerastore.com/en-gb/products/olympus-fl-50r-electronic-flash-micro-four-thirds-t158979) — £87 GBP, used certified, in stock online; seller says inspected/tested and working with cosmetic wear. UK shipping from £8.50; duties/taxes calculated at checkout; 30-day returns and 12-month warranty.
- **Used marketplace:** [eBay UK FL-50R item 318914535826](https://www.ebay.co.uk/itm/318914535826) — ended 3 October 2026, £79.35 including Buyer Protection, used, seller in Japan.
- **UK retailer close naming:** [London Camera Exchange FS-FL50R](https://www.lcegroup.co.uk/Used/Olympus-FS-FL50R-Flash-%5B4%5D-%7C-10116890_467836.html) — £89.99, used good condition, in store Guildford. **RED VERIFY** whether “FS-FL50R” is merely listing nomenclature or an exact FL-50R package.
- **Non-match excluded:** LCE Olympus FL-50 (without R) is not the FL-50R master; do not merge.
- **Condition/availability:** Used certified listing in stock plus ended eBay reference.

## 5. Google Shopping click-through summary

Shopping/product search was run across all 20 targets. Exact or useful click-throughs included Sony FE 85mm GM II to Cotswold Cameras, Z CAM EVF to ProAV/CVP, DJI Matrice 350 RTK Basic Combo to Drone Sales UK, Bebob V150microC to CVP, Nikon 18-200 VR II to MPB/eBay, Nikon F-801 kit to Hard to Find Camera Store, RØDE Wireless GO II to Ubuy, and a Nikon D2HS eBay “junk” result.

Shopping results for Autel EVO Lite 6K Enterprise, Sony DSR-PD175P, Olympus VF-4, Hubsan ZINO 2+, Hubsan MINI 7, Skydio 2, NEEWER SC340AW, Sony HXC-D70L, NEEWER NS14S, Nikon Nikonos III and Olympus FL-50R were absent or returned a different model/variant/accessory. Those mismatches were not silently assigned to the master; useful close links are retained above with RED VERIFY notes where applicable.

## 6. Next-run instructions

1. Read this batch 04 checkpoint and `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-04.md` first.
2. Exclude all 20 product IDs in this checkpoint, all product IDs in earlier scheduled checkpoints, and products covered by any outstanding LIVE research-queue candidate or outstanding manual AI research prompt.
3. Recheck active evidence, queue status and prompt coverage immediately before selecting the next 20.
4. Do not use a fixed OFFSET.
5. Recheck authenticated owner context. If `auth.uid()` is null or the owner check fails, do not write to the queue; create the next checkpoint and project-memory files instead.
6. Do not create/alter master products, valuation logic or schema. Do not touch TEST or Stripe.


## 7. RED VERIFY follow-up — 12 November 2026

The follow-up rechecked the original RED VERIFY leads against direct source pages and current LIVE product/evidence state. Four further exact UK GBP used-market observations were imported into LIVE using the established idempotent migration route and read back successfully:

| Master product | Source | Price | Status / notes |
|---|---|---:|---|
| Olympus VF-4 Electronic Viewfinder | MPB UK | £146.00 | Used, Good; five units shown between £146 and £164; 12-month warranty. [Source](https://www.mpb.com/en-uk/product/olympus-vf-4-electronic-viewfinder) |
| Nikon AF-S DX Nikkor 18-200mm f/3.5-5.6G ED VR II | eBay UK — Fivercam | £170.10 | Used; UK business seller, last item, three sold, free tracked delivery. [Source](https://www.ebay.co.uk/itm/254901977062) |
| Nikon AF-S DX Nikkor 18-200mm f/3.5-5.6G ED VR II | London Camera Exchange | £149.99 | Used, Good; Guildford stock, next-working-day delivery available. [Source](https://www.lcegroup.co.uk/Used/Nikon-AF-S-18-200mm-f/3.5-5.6G-II-ED-VR-DX-%7C-10119797_496745.html) |
| RØDE Wireless GO II dual-channel system | eBay UK — DR Beauties | £99.99 | Used Grade B; exact 2 TX + 1 RX kit, out of stock; retained as historical reference. [Source](https://www.ebay.co.uk/itm/366432956788) |

LIVE read-back confirms Batch 04 now has **18 active records: 8 UK New and 10 UK Used; all 18 are GBP**. The four follow-up rows are all UK Used. Current LIVE calculate_buying_item_valuation(uuid,uuid) selects only GBP uk_new research evidence as its shared-market reference; these used observations remain comparison-only and do not alter automatic valuation.

Other leads remain outside active valuation evidence where the source or package is not sufficiently resolved. Examples include the unusually low Cotswold Sony 85mm GM II offer (seller/checkout/price discrepancy remains a verification risk), Production Gear's contradictory Wireless GO II stock message, the imported Ubuy landed-cost uncertainty, the DSR-PD175P on-order offer, package differences on the Matrice 350 RTK, and NEEWER variant pricing/package ambiguity. Foreign-currency-only, overseas-seller, faulty, ended-with-no-bid and unverified close-model references remain in this checkpoint, not promoted to exact UK evidence.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed. No queue status or owner-auth context was bypassed.
