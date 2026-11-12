# TradeFlow LIVE — Scheduled Market Evidence Batch 08

- Research date: 2026-11-12
- Repository: `laurendigitaluk/TradeFlow`
- Branch: `production`
- Supabase project: LIVE only (`gxsrajtqzdjvmceqcpgv`)
- Batch status: researched; not staged to the LIVE review queue
- Selected: 20 active catalogue master products
- Active evidence before research: 0 for each selected product
- Outstanding queue candidate matches: 0 for each selected product
- Outstanding manual-prompt matches: 0 for each selected product

## 1. Preflight and selection

Read before selection:
- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md`
- `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md`
- Scheduled evidence checkpoints 03, 04, 05, 06 and 07
- Latest available scheduled evidence project memory: `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-07.md`
- Project-memory files 04, 05 and 06

The production directory contains a Batch 03 checkpoint but no matching Batch 03 project-memory file. The Batch 03 checkpoint was still read and included in exclusions.

All product IDs present in scheduled checkpoints 02–07 were excluded. The scan found 163 UUID-shaped strings; one is a non-catalogue UUID embedded in a source URL, so the database anti-join only excluded IDs that actually match master catalogue products.

Current outstanding LIVE research state at selection:
- `platform_catalogue_research_queue`: 28 imported, 10 `needs_research`, 43 rejected; no `pending_review` records.
- Outstanding manual AI research: one prompt, ID `4e9d16d5-baae-4fb7-8617-2e3a0a829cb5`, status `ready`, covering 20 products.
- Those queue candidates and all 20 products in the outstanding manual prompt were excluded.
- Selection used dynamic exclusion/anti-join logic and `ORDER BY created_at`; no fixed SQL OFFSET was used.

A second catalogue row for Nikon Ai-S NIKKOR 28mm f/2 had the same manufacturer/model identity as an older checkpoint entry but a different UUID from the older checkpoint. It was skipped by exact identity to avoid repeating the already researched product. Nikon COOLPIX P7700 was used as the replacement twentieth product.

Immediately before research, all 20 selected IDs were rechecked:
- active shared market evidence count = 0
- outstanding LIVE queue candidate count = 0
- outstanding manual AI prompt count = 0

## 2. Research method and rules

For each product, searched manufacturer sources, UK retailers, marketplaces and Google Shopping/product-shopping results. Opened actual merchant/manufacturer pages when a result was available. Variant, bundle, condition and availability differences are retained below.

Rules applied:
- Preserve sold-out and unavailable listings.
- Preserve unverified seller and uncertain match leads with a clear reason to check.
- Never invent a price or convert non-GBP currencies into GBP.
- Where no reliable UK GBP price was visible, GBP price is left blank and the source currency/amount is recorded in notes.
- Do not treat a bundle, accessory or related model as an exact match.
- Prefix uncertain notes with `RED VERIFY`.
- Avoid duplicate source URLs and duplicate evidence records.

Google Shopping search links are included per product so the end user can inspect the result set. Some Shopping merchant pages (notably Amazon and certain eBay/variant URLs) were inaccessible to the browser; those links are retained as unverified leads rather than being described as verified product pages.

## 3. Product research records

### 1. FIMI — X8 Mini V2
- Product ID: `8b2b368b-e1d6-42ab-a3ed-755f33d64157`
- Package: FIMI X8 Mini V2 Camera Drone with Bag
- UK GBP price: blank (no reliable UK GBP price visible)
- Source findings:
  - Ubuy UK page identifies the exact FIMI X8 Mini V2 with carrying bag; page says out of stock and imported from USA. No visible price was available on the opened page.
  - avXperten Norway exact X8 Mini V2 combo with 3 intelligent flight batteries and bag: 4,959 NOK including 25% VAT; page says out of stock. Do not convert.
  - FIMI official store currently surfaces newer products (MINI 3, X8 Pro 2025, X8 Tele Max) rather than the older X8 Mini V2.
- Condition/availability: new retail listing, unavailable/out of stock at the opened sellers.
- RED VERIFY: only foreign-currency combo evidence and an imported/out-of-stock listing were found. The avXperten package adds three batteries; check whether the catalogue package means the drone plus bag only or the three-battery combo.
- Sources:
  - https://www.u-buy.co.uk/product/IKE12TH9K-fimi-f9miniv3-drone-orange-version-with-camera-4k-rth-rc-quadcopter
  - https://www.avxperten.no/droner/fimi-x8-mini-v2-combo-drone-3x-intelligent-flight-battery-taske-8km.asp
  - https://store.fimi.com/en-br
  - Google Shopping: https://www.google.com/search?tbm=shop&q=FIMI+X8+Mini+V2+drone+with+bag

### 2. Freefly — Flux H1
- Product ID: `a3b3e15e-8298-425f-b88e-b6773b421430`
- Package: Freefly Flux H1 LiDAR
- UK GBP price: blank
- Source findings:
  - Official Freefly portal: from USD $32,995, SKU 950-00181; notice says ships in 7–10 business days.
  - Official overview identifies the Hesai XT-32MX scanner, 20MP RGB camera, 715g package, 300m range and 1.9M points/second.
  - DroneFly US listing also surfaced at USD $32,995; it is not UK GBP evidence.
- Condition/availability: new official order page; shipping estimate 7–10 business days.
- RED VERIFY: no UK GBP seller price found. Preserve USD $32,995 exactly as displayed; do not convert.
- Sources:
  - https://portal.freeflysystems.com/products/flux-h1
  - https://freeflysystems.com/flux
  - https://www.dronefly.com/products/freefly-flux-h1
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Freefly+Flux+H1+LiDAR

### 3. Freefly — Wave
- Product ID: `9d94644e-8638-40ab-a365-699ed8b2c57f`
- Package: Freefly Wave 2TB SSD
- UK GBP price: blank
- Source findings:
  - Official Freefly refurbished Wave: USD $6,995; 2TB internal storage selected; in stock with free domestic shipping.
  - Refurbished trade-in camera, fully functional, possible minor cosmetic blemishes/signs of use, 6-month warranty.
  - In-the-box list: refurbished Wave camera, US-plug AC charger (110/220V capable), D-Tap power adapter, lens-mount shims, USB A-C cable, hex driver and travel case.
- Condition/availability: refurbished; in stock (Freefly domestic shipping only).
- RED VERIFY: the catalogue package wording says “2TB SSD”, but the source product is the Wave high-speed camera with a 2TB internal SSD, not a standalone SSD. Confirm that this camera/package is the intended match. USD price is not converted.
- Sources:
  - https://store.freeflysystems.com/collections/wave/products/wave-refurbished
  - https://store.freeflysystems.com/collections/wave
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Freefly+Wave+2TB+SSD

### 4. GoPro — HERO6 Black
- Product ID: `bf1f899b-d3c1-41f5-aa41-f78158e48d84`
- Package: HERO6 Black
- UK GBP price: used-market range £79–£130; MPB Good £82, Excellent £123
- Source findings:
  - UsedLens shows 5 listings from 2 retailers, low £79, typical £103, high £130.
  - MPB listings: Good £82 and Excellent £123.
  - eBay bundle leads: £78.70 (five batteries, dual charger, case and mount), £130.40, and £97.68. Bundle contents differ.
- Condition/availability: used; condition varies by listing. UsedLens reports two new listings this week and five current listings at time of crawl.
- RED VERIFY: do not treat the eBay bundle prices as body-only prices. Check battery condition, waterproof door/seals, lens condition and exact accessories.
- Sources:
  - https://usedlens.co.uk/product/gopro-hero-6-black
  - Google Shopping: https://www.google.com/search?tbm=shop&q=GoPro+HERO6+Black+UK+used

### 5. GoPro — MISSION 1 PRO Grip Edition
- Product ID: `b7405ab6-ec10-44ed-b616-afa1a4a72fff`
- Package: MISSION 1 PRO Grip Edition
- UK GBP price: £779.00 (H2O Sports; sold out). Official GoPro UK homepage search index displayed £679.99, but the opened homepage did not expose the price in its page text.
- Source findings:
  - H2O Sports exact bundle £779.00 including MISSION 1 PRO camera, Point-and-Shoot Grip, Enduro 2 battery, lens hood and carrying case; page says sold out.
  - GoPro official UK homepage search result displayed £679.99.
  - GoPro official release gives USD $779.99 MSRP and USD $679.99 subscriber price; these are USD figures, not GBP.
- Condition/availability: new retail bundle; H2O listing sold out; official UK dynamic page price needs confirmation.
- RED VERIFY: confirm current GoPro UK checkout price and whether £679.99 is subscriber-only or a standard UK price. H2O bundle contents are exact but its offer is sold out.
- Sources:
  - https://www.h2o-sports.co.uk/products/mission-1-pro-grip-edition
  - https://gopro.com/en/gb/
  - https://gopro.com/en/gb/news/mission-1-series-now-available
  - https://investor.gopro.com/press-releases/press-release-details/2026/GoPros-New-MISSION-1-Series-Cameras-Mounts-and-Accessories-Now-Available-on-Retail-Shelves-Globally-and-at-GoPro-com/default.aspx
  - Google Shopping: https://www.google.com/search?tbm=shop&q=GoPro+MISSION+1+PRO+Grip+Edition+UK

### 6. HoverAir — X1 PROMAX
- Product ID: `e2776acc-9d95-4180-a60d-5f1794454e89`
- Package: HOVERAir X1 PROMAX
- UK GBP price: £609 sale at Very (regular £639)
- Source findings:
  - Very exact Standard version: £609 current sale, £639 regular; EAN 6977791920012; 64GB onboard storage; charger included: No.
  - AO exact Standard product page confirms 64GB storage, 1,920mAh battery and 1-year manufacturer warranty; page did not expose a reliable price in opened text.
  - Google Shopping also surfaced French retailer LaCaméraEmbarquée at £596.24 and Photospecialist at £601; these are foreign sellers, not UK price evidence.
- Condition/availability: new standard version; Very page offers Add to basket and delivery information.
- RED VERIFY: verify final checkout price and contents/charger. Do not substitute the Jessops Retail Combo price for the Standard package.
- Sources:
  - https://www.very.co.uk/hoverair-x1-promax-standard-self-flying-camera-drone/1601321442.prd
  - https://ao.com/product/sp06h006-hoverair-x1-promax-drone-black-111519-755.aspx
  - https://www.lacameraembarquee.fr/en/drones-hoverair-x1-series/19068-drone-hoverair-x1-pro-max-standard-6977791920012.html
  - Google Shopping: https://www.google.com/search?tbm=shop&q=HoverAir+X1+PROMAX+Standard+UK

### 7. Hubsan — H109
- Product ID: `a8806ece-5fb3-42e4-be27-a20268d7a043`
- Package: H109 X4 Brushless
- UK GBP price: £699 official closest variant; £150 used Gumtree lead
- Source findings:
  - Official Hubsan H109S X4 PRO PROFESSIONAL: £699; page says out of stock. Specs include 3-axis gimbal, H7000 Android transmitter, 7,000mAh battery, 1080p camera and 21-minute max flight time.
  - Gumtree Hubsan X4 H109S used listing: £150 search lead; private seller, older listing, page no longer accessible. Search excerpt described hard case, camera, spare props, prop guards, remote, battery and charger.
  - Hubsan China H109S X4 Pro Standard page surfaced at CNY 2,999; out of stock. Do not convert.
- Condition/availability: official professional variant out of stock; used private-seller lead not independently re-opened.
- RED VERIFY: catalogue model is H109, package says H109 X4 Brushless; official offer is H109S X4 PRO PROFESSIONAL, a suffix/package difference. Check whether it is the intended match before accepting £699. The £150 used seller/listing needs verification.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=6
  - https://www.gumtree.com/p/drones/hubsan-x4-h109s-drone/1512642681
  - https://chn.hubsan.com/index.php?main_page=product_info&products_id=8
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+H109+X4+Brushless

### 8. Hubsan — H501A
- Product ID: `bd1fcdb9-62e0-46ea-b047-0af37a6aa724`
- Package: H501A
- UK GBP price: £199 standard H501A; £249 H501A + H906A bundle
- Source findings:
  - Official Hubsan H501A X4 WIFI Brushless FPV RTF: £199; page says out of stock. 1080p, GPS/waypoints, brushless motors, 2,700mAh battery, 20-minute flight time.
  - Official Hubsan H501A X4 Air Pro & H906A bundle: £249; page says out of stock.
  - G-Force Japan official H501A page: JPY 49,800 before tax; no conversion.
  - Google Shopping/eBay result: £312.70; one review; direct eBay page inaccessible, seller and package not confirmed.
- Condition/availability: official new listings out of stock; Shopping marketplace lead unverified.
- RED VERIFY: distinguish the £199 standard H501A from the £249 H906A-controller bundle. The £312.70 eBay Shopping result requires seller, package and availability verification.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=521
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=590
  - https://www.gforce-hobby.jp/products/H501A.html
  - https://www.ebay.co.uk/itm/318348365081?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+H501A+X4+Air+Pro

### 9. Hubsan — H501M
- Product ID: `9e1fead2-e365-4ac7-a207-45e36fdac49e`
- Package: H501M X4 Waypoints FPV
- UK GBP price: £139
- Source findings:
  - Official Hubsan H501M X4 Air Basic Edition: £139; page says out of stock.
  - Page specs include 720p camera, 2,700mAh battery, brushless motors, app waypoint control and 20-minute flight time.
- Condition/availability: new official listing, out of stock.
- Notes: exact model family/package evidence; keep as sold-out manufacturer price evidence.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=218
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+H501M+X4+Waypoints+FPV

### 10. Hubsan — HT55
- Product ID: `7b8312f1-df34-4fd8-81d9-780ad62ca78d`
- Package: HT55
- UK GBP price: £350
- Source findings:
  - Official Hubsan HT55 product page: £350; page says out of stock.
  - Page identifies exact HT55 model. “In the Box” contents are image-only, not text-readable.
- Condition/availability: new official listing, out of stock.
- RED VERIFY: exact model and price are identified, but Gary should check the package-content images and confirm what the standard HT55 kit includes.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=1093
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+HT55

### 11. Hubsan — MINI
- Product ID: `ad547a9f-1c83-4858-8d49-76cfb563c7e0`
- Package: Hubsan Mini standard version
- UK GBP price: £439
- Source findings:
  - Official Hubsan “Hubsan Mini standard version with 1 battery”: £439; page says out of stock.
  - Exact standard package wording and one-battery configuration match the catalogue package.
- Condition/availability: new official listing, out of stock.
- Notes: retain as sold-out manufacturer price evidence.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=1059
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+Mini+standard+version+1+battery

### 12. Hubsan — ZINO MINI PRO
- Product ID: `79871190-a705-454d-b166-efb9c3fbff45`
- Package: ZINO MINI PRO standard version with 1 battery (128GB)
- UK GBP price: £569 official 128GB package; £284.95 Unmanned Tech 64GB package
- Source findings:
  - Official Hubsan exact 128GB standard version with one battery: £569; page says out of stock.
  - Unmanned Tech UK: £284.95 for Standard 64GB with one battery; variant unavailable/sold out and page says backorder awaiting stock.
- Condition/availability: official 128GB out of stock; UK retailer 64GB variant unavailable/backorder.
- RED VERIFY: Unmanned Tech’s £284.95 price is a 64GB variant, not the catalogue’s 128GB package. Keep both links and do not treat the prices as interchangeable.
- Sources:
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=947
  - https://www.unmannedtechshop.co.uk/fr/products/hubsan-zino-mini-pro-4k-drone-sub-250g
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+ZINO+MINI+PRO+128GB+one+battery

### 13. Hubsan — Zino Pro
- Product ID: `a43c3673-d3a0-496b-a2f6-f78dfa349ffb`
- Package: Standard Package
- UK GBP price: £279 standard; £349 spare-battery-and-bag bundle; £335 official portable-version reference
- Source findings:
  - Menkind standard Hubsan Zino Pro Folding Drone 4K: £279 (was £379), product code 87256; delivery options shown, not available for Click & Collect. Contents: one drone, one controller, one battery, four propellers and one charger.
  - Menkind separate “with Battery and Bag” package: £349; includes spare battery and bag.
  - Official Hubsan Zino Pro Portable Version: £335; out of stock. Related product text distinguishes “Zino Portable Version With One Extra Battery” at £335, so package needs checking.
  - Sussex Model Centre £37.98 listing is a Zino Pro spare part and unavailable/backorder; it is NOT the drone.
- Condition/availability: Menkind standard page available for delivery; Hubsan portable version out of stock; £37.98 spare-part page unavailable.
- RED VERIFY: use £279 as the closest standard-package price. Do not use £349 bundle or £37.98 spare-part price as the standard drone price. Confirm final delivery availability.
- Sources:
  - https://www.menkind.co.uk/hubsan-zino-pro-folding-drone-4k
  - https://www.menkind.co.uk/hubsan-zino-pro-folding-drone-with-battery-and-bag
  - https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=669
  - https://sussex-model-centre.co.uk/collections/hubsan/products/hubsan-zino-pro-gps
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Hubsan+Zino+Pro+standard+package

### 14. NEEWER — KM19
- Product ID: `6e8daf15-edc7-4418-8974-d5ae45f4a450`
- Package: NEEWER KM19 Mini Wireless Lavalier Microphone
- UK GBP price: £39.99 official; £39.62 eBay; Google Shopping Amazon leads £38.99 and £47.99
- Source findings:
  - Official NEEWER UK: from £39.99 (was £53.99); top message says “More stock coming soon” while page also says “In stock”.
  - Package: one receiver, two transmitters, one charging case, two OTG adapters, charging cable, two windscreens and pouch.
  - eBay: £39.62, new, private seller in Wolverhampton, 100% positive feedback, 123 feedback; no returns accepted. The seller is away until 19 November 2026, so dispatch is delayed.
  - Google Shopping Amazon leads: £38.99 and £47.99; opened Amazon pages were inaccessible.
- Condition/availability: official new listing with contradictory stock messaging; eBay new private-seller listing.
- RED VERIFY: check the official selected colour/variant and checkout stock. Keep the eBay seller as private/unverified despite positive feedback; no returns accepted; seller away until 19 November 2026, so dispatch is delayed.
- Sources:
  - https://uk.neewer.com/collections/portable-microphone/products/neewer-km19-wireless-lavalier-microphone-66609101
  - https://www.ebay.co.uk/itm/880041406167
  - https://www.amazon.co.uk/NEEWER-KM19-Microphone-Compatible-Cancellation-Black/dp/B0H7S7RWB4
  - https://www.amazon.co.uk/NEEWER-KM19-Microphone-Compatible-Cancellation-Black/dp/B0GXV9QBJ4
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+KM19+Mini+Wireless+Lavalier+Microphone+UK

### 15. NEEWER — LS-29 PRO
- Product ID: `ab1ef244-d761-425c-9d03-7480e30e8bfd`
- Package: NEEWER LS-29 PRO 8mm Fisheye Lens with 17mm Thread
- UK GBP price: £67.49 historical Amazon-price reference on YPC (as of 2026-08-15); official UK search index previously showed £58.99 but direct page was unavailable/404
- Source findings:
  - YPC exact LS-29 PRO page describes 8mm fisheye, 220° field of view, 17mm threaded clip and compatibility with 17mm threaded phone cage/case/clamp/backplate. SKU B0DHRHMDY4. Price £67.49 as of 15 August 2026; YPC page states Amazon price/availability at the time of purchase applies.
  - Official NEEWER UK indexed result displayed £58.99 and zero stock, but the direct product page could not be opened.
  - Google Shopping also surfaced an AliExpress “200 Fish Eye VR Lens” at £33.06; this is not the exact LS-29 PRO and must not be matched as exact.
- Condition/availability: YPC price is a historical aggregator reference; official UK listing unavailable; AliExpress result is a different product.
- RED VERIFY: £67.49 is not a current verified retailer checkout price. Check the Amazon link/availability and verify the exact 17mm LS-29 PRO, not the unrelated VR fisheye lens.
- Sources:
  - https://www.ypc.co.uk/product/neewer-8mm-fisheye-lens-with-220-wide-angle-17mm-thread-phone-lens-clip-also-for-17mm-threaded-phone-cage-case-clamp-backplate-ls-29-pro/
  - https://uk.neewer.com
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+LS-29+PRO+8mm+Fisheye+17mm+Thread

### 16. NEEWER — NL660 2 Pack Softbox Kit
- Product ID: `632b988e-13dd-4429-b236-c61bfaec68fd`
- Package: NEEWER NL660 2 Pack Softbox Kit
- UK GBP price: £229.99 official; £75 used Gumtree
- Source findings:
  - Official NEEWER UK exact 2-pack Bi-Color NL660 LED Video Light and Stand Kit with Softboxes: £229.99, SKU 66604920, 5 reviews. Page says “More stock coming soon” and also “In stock”.
  - Package: two bi-colour LED video lights, two power adapters, two UK power cables, two light stands, two softboxes and two carrying bags.
  - Gumtree: £75, “as good as new”; seller says opened once, includes two LED lights, adjustable stands, barn doors and softboxes. Battery pack not included. Seller in Peterculter/Aberdeen; page posted 44 days ago.
  - Amazon Shopping lead £249.99; direct Amazon page returned 503.
- Condition/availability: official new listing with contradictory stock text; Gumtree used/as good as new, private seller.
- RED VERIFY: check official checkout stock and Gumtree seller/collection. Do not assume battery packs are included; seller explicitly says battery pack not included.
- Sources:
  - https://uk.neewer.com/collections/top-daily-sellers/products/neewer-2-pack-bi-color-660-led-video-light-and-stand-kit-with-softbox-66604920
  - https://www.gumtree.com/p/lighting-studio/neewer-2-pack-nl660-led-video-lights/1512800837
  - https://www.amazon.co.uk/Upgraded-Control-3200K-5600K-Streaming-Photography/dp/B0BKS8B1ZM
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+NL660+2+Pack+Softbox+Kit

### 17. NEEWER — PA028E
- Product ID: `bc03b00f-bea0-4b73-a20f-cbce6e725947`
- Package: NEEWER PA028E Bluetooth Side Handle with Phone Holder & SSD Holder
- UK GBP price: £45.99 official; Google Shopping variant lead £50.99; Amazon Shopping lead £32.99 (not opened)
- Source findings:
  - Official NEEWER UK page title says PA028E, £45.99 (was £64.99), SKU 66604178; page says “More stock coming soon” and 4 in stock.
  - Package: one Bluetooth handle with phone clamp and SSD holder.
  - Official specifications list model as PA028 (without E), while product title and catalogue model say PA028E.
  - Google Shopping Neewer UK variant result showed £50.99; variant page was inaccessible. Amazon Shopping surfaced £32.99, no direct page verification.
- Condition/availability: new official listing; 4 in stock with “More stock coming soon” notice.
- RED VERIFY: confirm whether PA028 and PA028E are the same SKU/variant and which colour/variant the £50.99 Shopping offer represents. Keep £32.99 as an unverified Shopping lead only.
- Sources:
  - https://uk.neewer.com/products/neewer-pa028-bluetooth-side-handle-with-phone-holder-ssd-holder-for-15-pro-max-66604178
  - https://uk.neewer.com/products/neewer-pa028-bluetooth-side-handle-with-phone-holder-ssd-holder-for-15-pro-max-66604178?variant=49412501373227&country=GB&currency=GBP
  - https://uk.neewer.com/collections/universal-rigs
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+PA028E+Bluetooth+Side+Handle+Phone+SSD+Holder

### 18. NEEWER — RH12C
- Product ID: `fdcf0188-0cf2-425a-8e8a-33ddf74d9242`
- Package: NEEWER RH12C 12 Inch 24W High Power RGB LED Ring Light
- UK GBP price: £79.99 official
- Source findings:
  - Official NEEWER UK: £79.99, SKU 66607222; page says “More stock coming soon” and 2–3 in stock (page variants differed slightly).
  - Exact package: ring light, light stand, ball head, flexible phone holder, RT116 Bluetooth shutter release, UK-plug USB power adapter, USB-C cable and manual.
  - Google Shopping surfaced NEEWER RH12B at £65.99 Amazon and £100.99 eBay. RH12B is a different model and is not evidence for RH12C.
- Condition/availability: new official listing, stock wording contradictory.
- RED VERIFY: do not use RH12B prices as exact RH12C evidence. Check official checkout stock.
- Sources:
  - https://uk.neewer.com/products/neewer-rh12c-12-24w-high-power-rgb-led-ring-light-66606469
  - https://www.amazon.co.uk/NEEWER-Compatible-Recording-Streaming-Ringlight/dp/B0D2566PLT
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+RH12C+12+inch+24W+RGB+Ring+Light

### 19. NEEWER — TP014
- Product ID: `70961335-22f9-4b5b-859d-f74a9995aa97`
- Package: NEEWER BASICS TP014 76" Overhead Camera Tripod Monopod
- UK GBP price: £102.99 official; Google Shopping variant leads £82.39 Neewer UK, £74.39 Amazon seller and £113 Ubuy
- Source findings:
  - Official NEEWER UK exact TP014: £102.99, SKU 66609186; page says “More stock coming soon” and “In stock”.
  - Specifications: 76" tripod height, 66.7" monopod height, 12.6" adjustable centre column, 8kg load, ball head and monopod conversion.
  - Package: TP014 tripod/monopod, two L-shaped hex keys, carrying bag and user manual.
  - Google Shopping showed a Neewer UK variant at £82.39, Amazon seller £74.39 and Ubuy £113. Variant/product pages were not accessible from the Shopping result URLs.
- Condition/availability: new official listing with stock message contradiction.
- RED VERIFY: verify the Shopping variant and checkout prices; do not replace the opened official £102.99 listing without checking the selected variant.
- Sources:
  - https://uk.neewer.com/collections/20-off-products/products/neewer-basics-tp014-overhead-camera-tripod-monopod-66609186
  - https://uk.neewer.com/products/neewer-basics-tp014-overhead-camera-tripod-monopod-66609186?variant=62533408522611&country=GB&currency=GBP
  - https://uk.neewer.com/collections/all?page=23
  - Google Shopping: https://www.google.com/search?tbm=shop&q=NEEWER+TP014+76+inch+Overhead+Camera+Tripod+Monopod

### 20. Nikon — COOLPIX P7700
- Product ID: `59de3715-2ec7-47c1-93d3-57048b4355ac`
- Package: COOLPIX P7700
- UK GBP price: MPB Good £239, Excellent £294; UsedLens low £213, typical £239, high £294
- Source findings:
  - MPB: two used units available from £239–£294. Good £239, Excellent £294; both include standard 12-month warranty, Nikon EN-EL14 battery, MH-24 charger and compact case.
  - UsedLens: 9 listings from 2 retailers, low £213, typical £239, high £294; includes MPB and eBay comparisons.
  - Another UsedLens snapshot: 3 listings from 2 retailers, low £220, typical £224, high £246.
  - Google Shopping eBay Japan seller lead £175.32; direct page inaccessible and not a UK seller.
  - An older eBay listing showed out of stock; £245.69 price lead includes remote, 32GB SD card and case. Another eBay page for an accessory-rich listing did not expose a price when opened.
- Condition/availability: used; MPB shows Good and Excellent stock available; eBay condition/accessories vary.
- RED VERIFY: do not use Japan seller’s £175.32 as UK market price. Confirm eBay condition and accessories individually; body-only and bundles must remain separate.
- Sources:
  - https://www.mpb.com/en-uk/product/nikon-coolpix-p7700
  - https://usedlens.co.uk/product/nikon-coolpix-p7700
  - https://mail.usedlens.co.uk/product/nikon-coolpix-p7700
  - https://www.ebay.co.uk/itm/389506802022
  - https://www.ebay.co.uk/itm/940037895600
  - https://www.ebay.co.uk/itm/407268626032
  - Google Shopping: https://www.google.com/search?tbm=shop&q=Nikon+COOLPIX+P7700+UK+used

## 4. Owner-auth check and queue-staging limitation

The LIVE owner-auth context was checked before any write:
- `current_user = postgres`
- `auth.uid() = null`
- `auth.role() = null`
- `platform_cloud_ai_owner_check() = false`

Per instruction, no direct table write, impersonated claims, RLS bypass or unauthenticated RPC attempt was made. The supported authenticated platform-owner RPC could not be used because the owner-auth check failed.

Queue staging result:
- researched: 20
- new `pending_review` candidates staged: 0
- direct database writes: 0
- no uncertain price entered into automatic valuation
- no master product, schema or valuation changes
- TEST and Stripe untouched

All 20 researched product IDs, source URLs, prices/currencies, conditions, availability and RED VERIFY notes are preserved in this checkpoint. The next run must read this file and the matching project-memory file first, then exclude these 20 IDs and all prior checkpoint IDs before selecting the next batch.

## 5. Next scheduled run

Continue with the next 20 eligible active LIVE master products:
1. Read this checkpoint and `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-08.md`.
2. Exclude every product ID from scheduled checkpoints 02–08.
3. Exclude outstanding LIVE queue candidates and outstanding manual AI research prompts.
4. Select dynamically without SQL OFFSET.
5. Recheck active evidence and queue/prompt status immediately before research.
6. Research actual product pages and Google Shopping results; preserve uncertain leads with RED VERIFY.
7. Attempt staging only through the authenticated platform-owner RPC if `auth.uid()` is non-null and the owner check passes. Otherwise create the next detailed checkpoint and project-memory files.


## 6. RED VERIFY follow-up — 12 November 2026

Six additional records were imported and read back from LIVE:

| Master product | Source | Price | Evidence/status |
|---|---|---:|---|
| Hubsan H501A X4 Air Pro | Elite Models Online | £209.99 | New; out of stock; exact model listing. [Source](https://www.elitemodelsonline.co.uk/Aircraft/Helicopters/By-Manufacturers/Hubsan/136604-/HUBSAN-501A-X4-AIR-PRO-DRONE-w%2AGPS-1080P%2A-1KEY%2A-FOLLOW%2A-WAYPOINT) |
| Hubsan H501M X4 | Elite Models Online | £139.99 | New; out of stock; exact H501M, package contents verified (drone, HT009 transmitter, charger, props, battery, instructions). [Source](https://www.elitemodelsonline.co.uk/Aircraft/Helicopters/By-Manufacturers/Hubsan/136614-/HUBSAN-501M-X4-DRONE-WAYPOINTS-FPV-720P%2A-RTH%2A-FOLLOW%2A-GPS) |
| Hubsan ZINO Pro | Elite Models Online | £389.99 | New; supplier stock, usually dispatches in 1–2 working days; standard drone package, not the extra-battery/bag bundles. [Source](https://www.elitemodelsonline.co.uk/Aircraft/Helicopters/By-Manufacturers/Hubsan/135624-/HUBSAN-ZINO-Pro-FOLDING-DRONE-4K%2A-FPV%2A-5%2A-8G%2A-GPS%2A-FOLLOW%2A-RTH) |
| NEEWER NL660 2-pack light kit | Gumtree | £75.00 | Used, as good as new; two lights, stands, barn doors and softboxes; battery pack not included; collection only. [Source](https://www.gumtree.com/p/lighting-studio/neewer-2-pack-nl660-led-video-lights/1512800837) |
| GoPro HERO6 Black | UsedLens / MPB listing | £119.00 | Used, Excellent; one current MPB listing, sale price £119 (regular £123). Other eBay prices were accessory bundles and not treated as body-only comparables. [Source](https://usedlens.co.uk/product/gopro-hero-6-black) |
| NEEWER KM19 wireless microphone | eBay UK — poundstretcher_uk | £47.94 | New; seller in Wolverhampton, 100% positive, no returns; seller away until 19 Nov 2026. Retained inactive until seller returns. [Source](https://www.ebay.co.uk/itm/880041406167) |

Existing evidence was rechecked:
- MPB Nikon COOLPIX P7700 is now one Good unit at £229, not the earlier £239/£294 range. The existing row was updated to £229, in stock, with the included battery, charger and 12-month warranty.
- Very HOVERAir X1 PROMAX Standard is confirmed at £609 sale price (regular £639), in stock with 3–5 day delivery; charger not included. The existing row's notes and availability were refreshed.
- The NEEWER KM19 eBay seller-away observation is stored but inactive; the existing NEEWER official £39.99 observation remains active.

Batch 08 now has **14 database rows: 13 active (10 UK New, 3 UK Used) and one inactive UK New seller-away row; all 14 are GBP**.

Other leads remain RED VERIFY: official Hubsan /eur pages show GBP prices for MINI and ZINO MINI PRO but the UK delivery region is not confirmed; Hubsan HT55 package contents remain unclear; H109 page suffix does not match the H109 master; Menkind Zino Pro £279 is an old crawl and was superseded by the current Elite Models £389.99 standard package; GoPro HERO6 eBay offers are bundles with differing batteries/accessories; the earlier MPB Good £82 HERO6 listing is no longer visible; NEEWER KM19 seller-away price is inactive; NEEWER PA028E is now cross-checked by exact UK product title/SKU 66604178 and the official Australian page for the same SKU; the UK specs field still says PA028 without E, so retain that caveat in notes; NEEWER NL660 official stock wording remains mixed. No unsupported region, package or model match was promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 7. RED VERIFY follow-up — 12 November 2026

Six additional exact UK GBP observations were imported and read back from LIVE:
- Hubsan H501A X4 Air Pro — Elite Models Online £209.99, exact model, out of stock.
- Hubsan H501M X4 — Elite Models Online £139.99, exact model, out of stock.
- Hubsan Zino Pro — Elite Models Online £389.99, supplier stock; kept separate from battery/bag bundles.
- NEEWER NL660 2-pack — Gumtree £75 used, opened once; two lights, stands, barn doors and softboxes, battery pack excluded.
- GoPro HERO6 Black — UsedLens/MPB Excellent £119 used; eBay accessory bundles were not treated as body-only comparisons.
- NEEWER KM19 — eBay £47.94 new, seller away until 19 Nov; retained inactive until seller returns.

Existing evidence corrections:
- Nikon COOLPIX P7700 MPB price updated from £239 to £229 after direct page recheck; one Good unit in stock, with EN-EL14 battery, MH-24 charger and 12-month MPB warranty.
- HOVERAir X1 PROMAX Standard / Very price confirmed at £609 sale (£639 regular), in stock, charger not included.

Batch 08 now has **14 total records: 13 active (10 UK New, 3 UK Used), one inactive UK New seller-away row; all 14 are GBP**. Out-of-stock Hubsan UK New observations remain active as historical UK price observations with explicit status; this follows current LIVE evidence policy. The seller-away KM19 row is inactive so it cannot be selected by the valuation function while the seller cannot fulfil orders.

Exact source URLs and evidence notes are retained in the inserted records and this checkpoint. Unresolved leads remain RED VERIFY: FIMI X8 Mini V2 has no reliable UK GBP exact source; Freefly Flux H1 and Wave lack UK retail pricing; GoPro MISSION 1 PRO Grip Edition now has an exact official UK package/price observation at £679.99 with Add To Cart shown; stock count is not separately displayed and checkout was not completed, so retain the availability caveat.; Hubsan H109/HT55/MINI and ZINO MINI PRO lack qualifying UK GBP offers; NEEWER LS-29 PRO now has an exact official UK £58.99 package/price observation, but is out of stock; PA028E still needs exact model/package and current UK pricing; NEEWER RH12C £79.99 and TP014 £102.99 official UK pages have now been rechecked; both are in stock with Add to Cart and exact package contents confirmed. The TP014 Google Shopping £82.39 variant remains unverified.. These were not promoted.

No master product, tenant, customer, schema, valuation function, TEST or Stripe data was changed.


## 8. Additional RED VERIFY follow-up — 12 November 2026

One further exact UK New observation was imported into LIVE and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| NEEWER LS-29 PRO 8mm Fisheye Lens with 17mm Thread Phone Lens Clip (SKU 66605766) | NEEWER UK | £58.99 inc VAT (was £86.99) | Exact official UK product page and package contents confirmed; 0 in stock / Sold Out / More stock coming soon. Retained as active historical UK New evidence with explicit out-of-stock status. [Source](https://uk.neewer.com/products/neewer-ls-29-pro-8mm-fisheye-lens-with-17mm-thread-phone-lens-clip-66605766) |

Batch 08 now has 15 database rows: 14 active (11 UK New, 3 UK Used) and one inactive UK New seller-away row; all 15 are GBP. The existing NEEWER RH12C £79.99 row was rechecked: the official page says “More stock coming soon” and shows 3 in stock with Add to Cart; treat this as three current units plus replenishment, not a stock contradiction. The TP014 £82.39 Shopping variant remains unverified because the variant page could not be opened; do not replace the official £102.99 observation without confirming that exact variant and its checkout availability.

The NEEWER LS-29 PRO lead is no longer RED VERIFY for model/package/price; availability is still out of stock. PA028E remains RED VERIFY pending exact model/package and current UK price. UK Used remains reference-only and excluded from automatic valuation. No valuation logic, schema, TEST or Stripe data was changed.


## 9. PA028E suffix cross-check — 12 November 2026

The existing NEEWER UK PA028E row was rechecked in place, not duplicated. Direct UK page: £45.99 (was £64.99), SKU 66604178, 3 in stock, Add to Cart, UK warehouse dispatch normally 2–5 working days. Product title and SKU identify PA028E; UK specifications field says PA028, while the official NEEWER Australia page for the same SKU explicitly says PA028E. The existing evidence notes and observed_at were updated, preserving the minor UK specs-field suffix caveat. PA028E is no longer RED VERIFY for model/package/price. Cumulative totals remain 231 GBP observations: 227 active (124 UK New, 103 UK Used), four inactive.


## 10. TP014 and RH12C official UK stock recheck — 12 November 2026

Two existing UK New rows were refreshed in place; no duplicates inserted:
- NEEWER BASICS TP014, SKU 66609186: £102.99, In Stock, Add to Cart, UK warehouse shipping normally 2–5 working days. Exact package contents: TP014 tripod/monopod, two L-shaped hex keys, carrying bag and user manual. The Google Shopping £82.39 variant remains unverified and does not replace the direct official £102.99 page.
- NEEWER RH12C, SKU 66607222: £79.99, 3 in stock, Add to Cart, UK warehouse shipping normally 2–5 working days. Package contents: ring light, stand, ball head, flexible phone holder, RT116 Bluetooth shutter release, UK-plug USB adapter, USB-C cable and manual. The “More stock coming soon” label is a replenishment notice alongside three currently available units, not a stock contradiction.

Both rows' notes and observed_at were updated and read back. Batch 08 remains 15 database rows: 14 active (11 UK New, 3 UK Used) and one inactive UK New seller-away row; all 15 GBP. Cumulative totals remain 231 GBP observations: 227 active (124 UK New, 103 UK Used), four inactive.


## 11. GoPro MISSION 1 PRO Grip Edition — 12 November 2026

One further exact UK New observation was imported into LIVE and read back:

| Product | Source | Price | Verification |
|---|---|---:|---|
| GoPro MISSION 1 PRO Grip Edition | GoPro UK | £679.99 | Official UK bundle listing displays the exact Grip Edition at £679.99; selected product page shows Add To Cart. All bundles include the MISSION 1 PRO camera, Enduro 2 battery and camera case; Grip Edition adds the Point-and-Shoot Grip. [Price listing](https://gopro.com/en/gb/shop/deals/camera-bundle-deals) · [Selected product](https://gopro.com/en/gb/shop/buy-cameras/mission-1-series?bundle-id=CHDRW-011-master&product-id=CHDHW-011-master) |

The earlier £579.99 search snippet was stale; the current official GoPro UK listing shows £679.99. The selected product page does not expose a separate stock count and checkout was not completed, so the evidence availability note records Add To Cart shown but stock count unconfirmed. Batch 08 now has 16 database rows: 15 active (12 UK New, 3 UK Used) and one inactive UK New seller-away row; all 16 are GBP. Cumulative Batches 04–13 now total 232 GBP observations: 228 active (125 UK New, 103 UK Used), four inactive. UK Used remains excluded from automatic valuation.
