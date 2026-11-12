# Scheduled Market-Evidence Research — Batch 03

**Research date:** 12 November 2026  
**Repository:** \`laurendigitaluk/TradeFlow\`  
**Branch:** \`production\`  
**Environment:** TradeFlow LIVE only  
**Status:** Research completed; queue staging blocked by missing authenticated owner context  
**Scope:** 20 active catalogue master products with no active \`shared_market_evidence\`

## 1. Continuity and selection controls

Read before selecting:
- \`CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-02.md\`
- \`PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-02.md\`

The batch-02 checkpoint contains the earlier scheduled batch-01 and batch-02 product-ID history. The production branch had no separate scheduled-market-evidence checkpoint beyond batch-02 when this run began.

Selection was performed dynamically from active LIVE \`catalogue_master_products\`, with no fixed SQL OFFSET. Exclusions applied:
1. Every product UUID found in the previous scheduled checkpoint history (41 UUIDs in batch-02's checkpoint).
2. Product IDs covered by all manual AI research prompt records, including completed prompts, to avoid repeating previously researched products; outstanding prompt IDs were also excluded.
3. Products matching outstanding LIVE \`platform_catalogue_research_queue\` candidates.
4. The 20 AKASO product IDs already reported in the preceding conversation batch but not yet represented in the scheduled checkpoint. Those IDs are recorded in section 4 so later runs do not select them again.

Immediately before research, all 20 selected LIVE master products were rechecked. Each returned:
- \`active_evidence_count = 0\`
- \`outstanding_queue_count = 0\`
- \`outstanding_prompt_count = 0\`

No fixed OFFSET was used. The selection was ordered from the remaining eligible master products and limited to the next 20.

## 2. Owner-auth check and queue-staging limitation

The supported authenticated platform-owner context was checked before any write:
- \`auth.uid() = NULL\`
- \`auth.role() = NULL\`
- database session role reported as \`postgres\`, which is not evidence of an authenticated platform owner
- \`public.platform_cloud_ai_owner_check() = false\`

**No candidates were written to \`platform_catalogue_research_queue\`.** No direct table insert, impersonated claim, service-role bypass, or RLS bypass was attempted. This run therefore created this checkpoint and its matching PROJECT-MEMORY file as the continuity fallback.

All uncertain findings below are marked with **RED VERIFY**. No uncertain price is authorised for automatic valuation. No master product, schema, valuation logic, TEST data, or Stripe configuration was changed.

## 3. Research results — 20 products

Research included manufacturer sites, UK retailers, UK and international marketplaces, product/Shopping results, and direct product-page inspection. Where a Shopping card showed a converted GBP estimate but the opened seller page displayed another currency, the GBP value is deliberately left blank and the original currency is recorded instead.

### 1) AKASO — V50 Pro — With SD Bundle
- **Master product ID:** \`f8dea24b-70ac-467f-996e-f326dd7523d2\`
- **Exact package evidence:** Official ShopAKASO product page lists the V50 Pro With SD option at **US$129.99** and identifies the SD-card package. The official product page's variant-level stock state was not reliably exposed. The separate AKASO store card lists the base V50 Pro at US$119.99 and marks that base card out of stock.
- **Additional seller lead:** bol.com page title and product details identify a V50 Pro 4K action camera with a 64GB card. The page showed an availability statement, but the main product price was not exposed in the retrieved page text. A €113.99 price visible elsewhere on that page belongs to a related Brave 4 Pro item, not this V50 Pro; do not attribute it to this product.
- **Sources:** [Official ShopAKASO V50 Pro page](https://shopakaso.com/products/akaso-v50-pro-action-camera); [bol.com V50 Pro 64GB page](https://www.bol.com/nl/nl/p/akaso-v50-pro-action-camera-4k-wifi-waterdicht-40m-64gb-grijs/9300000240949747/); [AKASO official store](https://www.akasotech.com/store/)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — no reliable UK GBP price was visible. Confirm whether the bol.com offer is still live and whether the selected package is exactly the catalogue's With SD Bundle. Do not use the unrelated €113.99 related-product price.

### 2) AKASO — V50 Pro SE — Standalone
- **Master product ID:** \`57bd36b8-b96d-4331-a908-8f2082a0fe3e\`
- **Official reference:** AKASO's official store lists V50 Pro SE at **US$134.99**, marked out of stock.
- **UK-facing lead:** Ubuy UK lists “V50 Pro Leave No Trace Special Edition”, marked out of stock and imported from the USA. The page does not expose a reliable price. Its description includes three batteries, wrist strap and an accessory kit, so it is not clearly the catalogue's Standalone package.
- **Sources:** [AKASO official store](https://www.akasotech.com/store/); [Ubuy V50 Pro Leave No Trace Special Edition](https://www.u-buy.co.uk/product/E5HQHTY-akaso-v50-pro-leave-no-trace-special-edition-action-camera-touch-screen-4k60-waterproof-camera-features-eis-and-wi-fi-remote-control-sports-camera-wit)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — confirm that “Leave No Trace Special Edition” is the same hardware/model as V50 Pro SE and not a different package. Ubuy's three-battery accessory package does not match Standalone. No UK GBP price visible.

### 3) AKASO — V50 X — Diving Bundle
- **Master product ID:** \`ef460bc4-10ab-4718-b546-5d2b5c63db26\`
- **Official reference:** [AKASO V50 X product/specification page](https://www.akasotech.com/v50x). The official store card lists the base V50 X at **US$99.99**, marked out of stock; no official Diving Bundle selector/price was found.
- **UK close match:** YPC lists the V50 X Floating Hand Grip Bundle at **£119.99** (price snapshot 21 October 2026). It includes V50 X camera, floating hand grip, two batteries, carrying case and accessory kit. The page explicitly says a microSD card is not included.
- **Additional UK-facing comparison:** Ubuy's V50 X product page shows a GBP price but describes a different generic camera/accessory configuration; it is imported from the USA and does not establish the Diving Bundle package.
- **Sources:** [AKASO V50 X official page](https://www.akasotech.com/v50x); [YPC Floating Hand Grip Bundle](https://www.ypc.co.uk/product/akaso-v50-x-action-camera-floating-hand-grip-bundle-includes-v50-x-4k-underwater-camera-floating-hand-grip-2-batteries-carrying-case-and-accessories-kit/); [Ubuy V50 X product lead](https://www.u-buy.co.uk/product/M1JK059BE-akaso-v50x-native-4k30fps-wifi-action-camera-with-eis-touch-screen-4x-zoom-131-feet-waterproof-camera-support-external-mic-remote-control-with-helmet)
- **GBP price:** £119.99 (close match, not exact package).
- **Notes:** RED VERIFY — the YPC listing has the floating grip but no microSD card. Confirm whether the catalogue Diving Bundle expects a 64GB card as well. YPC's price is a dated Amazon-linked snapshot, not a live checkout guarantee.

### 4) AKASO — V50 X — Vlog Bundle
- **Master product ID:** \`0473c207-1a18-458b-96a2-f51c8a2b12e8\`
- **Official reference:** [AKASO V50 X product/specification page](https://www.akasotech.com/v50x); no official Vlog Bundle price/selector found.
- **UK retailer lead:** OnBuy lists an AKASO V50 X Selfie Stick Bundle at **£205.87**, new and shown in stock, sold by SSA Trade Store. The bundle includes V50 X camera, extendable selfie stick (17.5–60cm), two batteries, carrying case and accessory kit. The page does not list a microSD card.
- **Source:** [OnBuy V50 X Selfie Stick Bundle](https://www.onbuy.com/gb/p/akaso-v50-x-action-camera-selfie-stick-bundle-includes-v50-x-4k-underwater-camera-selfie-stick-2-batteries-carrying-case-and-accessories-kit~p137166896/)
- **GBP price:** £205.87.
- **Notes:** RED VERIFY — this is a close package match, not a confirmed exact Vlog Bundle. The stick length/type differs from the 22cm selfie-stick-tripod wording seen on other AKASO bundle pages, and no SD card is listed. Confirm package contents and seller stock before treating it as exact.

### 5) AKASO — V50 X — With SD Bundle
- **Master product ID:** \`d763014a-70e2-4a0e-a7ce-bf8e0afdb0e1\`
- **UK retailer evidence:** YPC lists the V50 X with 64GB microSDXC, waterproof case, remote and mounting accessories at **£109.99** (price snapshot 22 October 2026).
- **Marketplace evidence:** eBay UK listing **£153.99**, new, two available/one sold, seller Clarkson Direct with 95.5% positive feedback. The listing title identifies the V50 X with 64GB microSDXC. A Shopping/search card showed a lower figure, but the opened listing page showed £153.99; use the opened page as the source-of-record capture.
- **Sources:** [YPC V50 X 64GB Bundle](https://www.ypc.co.uk/product/akaso-v50-x-action-camera-with-64gb-microsdxc-memory-card-native-4k-wifi-underwater-40m-eis-anti-shake-cam-with-touch-screen-remote-control-waterproof-case-and-mounting-accessories-kit/); [eBay UK V50 X 64GB listing](https://www.ebay.co.uk/itm/326424455596); [AKASO V50 X official page](https://www.akasotech.com/v50x)
- **GBP prices:** £109.99 (dated YPC snapshot); £153.99 (opened eBay listing).
- **Notes:** RED VERIFY — the eBay listing is new and currently shows two available, but confirm the 64GB card is included in the exact package being offered. Price spread is substantial; retain both source observations rather than averaging them.

### 6) CaddxFPV — Peanut — Standard Item
- **Master product ID:** \`dbf3777c-4f84-4cd1-86db-03d8ed66482f\`
- **UK evidence:** YourFPV lists the Caddx Peanut at **£218.99**, but the page is out of stock. It describes a 27g camera, 2.5K/1440p at 50fps and Insta360 GO 2-derived stabilisation.
- **International package/stock evidence:** RC Mester Norway lists the Caddx Peanut at **NOK 1,395**, with three in stock. Its package information includes the 27g camera, 32GB internal storage, mount adapter, power/USB connectors, cables, step-down module, ND8/ND16 filters, screws and manual.
- **Sources:** [YourFPV Caddx Peanut](https://yourfpv.co.uk/product/caddx-peanut-insta360/); [RC Mester Caddx Peanut](https://rcmester.no/produsent/produkt/caddx-fpv/caddx-peanut-fpv-action-camera-8)
- **GBP price:** £218.99 (UK listing, sold out). Norway price remains NOK 1,395; no conversion.
- **Notes:** UK price is useful historical/stock-gap evidence, not an available offer. The Norwegian listing is a current exact-model lead but not UK GBP evidence. No official Caddx manufacturer product page was located in this search.

### 7) CaddxFPV — Walnut — Standard Item
- **Master product ID:** \`a628320d-771b-43f9-8503-206e06221d49\`
- **UK retailer evidence:** FlyingTech lists **£117.90 inc VAT**, sold out, for the Caddx Walnut FPV action camera with ND8/ND16 filters. UnmannedTech lists the exact Caddx Walnut at **£129.00**, sold out/backorder; the product page describes the 4K60 camera and included mount/case/filter/accessory set.
- **Marketplace lead:** Fruugo lists **£269.00 + £6.49 shipping**, shown in stock, but the seller is Mickcara and the listing brand is shown as “Unbranded”.
- **Sources:** [FlyingTech Caddx Walnut](https://www.flyingtech.co.uk/product/caddx-walnut-fpv-action-camera-w-nd8-nd16-filters/); [UnmannedTech Caddx Walnut](https://www.unmannedtechshop.co.uk/products/caddx-walnut-action-camera); [Fruugo Caddx Walnut listing](https://www.fruugo.co.uk/caddx-walnut-action-camera-magnetic-charging-4k-quality-60g-built-in-els-anti-shake-gyroflow-support-wifi-max-256g-sd-fpv-camera/p-149831660-316390864)
- **GBP prices:** £117.90 and £129.00 (both specialist UK listings sold out); £269.00 + £6.49 shipping (Fruugo).
- **Notes:** RED VERIFY — Fruugo's unbranded product/seller identity is not established and the price is much higher than the specialist UK listings. Keep the link, but Gary should verify genuine Caddx branding, seller and exact package before accepting the £269 offer.

### 8) Casio — EX-FR200 — Standard Item
- **Master product ID:** \`ab146701-f933-4082-aa7d-794b7da5bda9\`
- **eBay UK completed/ended observations:** Listing #0004 showed **£132.59 incl. Buyer Protection**, used, “Near Mint”, but ended 4 October 2026. Seller step-f is a registered business with 98.5% positive feedback, located Tokyo, Japan. Seller notes say the camera/controller work but AC adapter and tripod nut are missing.
- **Second ended observation:** Listing #0005 showed **£79.66 incl. Buyer Protection**, used, “Excellent”, ended 14 September 2026; same seller and Tokyo location. It included camera and controller units.
- **Additional lead:** Gumtree result showed an EX-FR200BK at £116 in good condition, but the listing page is no longer available.
- **Sources:** [eBay EX-FR200 #0004](https://www.ebay.co.uk/itm/820148393082); [eBay EX-FR200 #0005](https://www.ebay.co.uk/itm/820116723985); [Gumtree EX-FR200 listing](https://www.gumtree.com/p/digital-cameras/exilim-casio-digital-camera/1514940284)
- **GBP prices:** £132.59 and £79.66 (historical ended listings); £116 (Gumtree search result, page unavailable).
- **Notes:** These are useful historical UK-facing price observations but the eBay sellers are in Japan. Check postage/import implications and included accessories; the #0004 listing specifically lacked the AC adapter and tripod nut.

### 9) Casio — EX-TR100 — Standard Item
- **Master product ID:** \`0edf0eb6-ede4-45d3-b896-121a6b0ed322\`
- **Marketplace evidence:** eBay UK listing **£153.19**, used, title explicitly says EX-TR100 and “Screen Burn”. Seller HARD OFF JAPAN in UK is a registered business with 99.8% positive feedback; item is located in Hino, Japan. The listing was updated 10 November 2026.
- **Source:** [eBay Casio EX-TR100 screen-burn listing](https://www.ebay.co.uk/itm/318914536671)
- **GBP price:** £153.19 as displayed on eBay UK.
- **Notes:** RED VERIFY — screen burn is a material condition defect, and the listing's item-specific model field is not as strong as the title. Verify the model from the camera label/photos and assess screen burn severity. Seller is Japan-based despite the UK-facing eBay page.

### 10) Casio — EX-TR150 — Standard Item
- **Master product ID:** \`084a3fdf-0acf-48b2-95c8-00442cfaad20\`
- **Sold marketplace evidence:** Mercari Japan sold listing at **JPY 8,800**. Used white EX-TR150; includes camera, AC adapter, cable and quick-start guide. Seller notes the touch panel responds slightly slowly. No GBP price.
- **Additional marketplace leads:** Carousell Hong Kong search results showed EX-TR150 offers around **HKD 400** (about eight months old) and **HKD 1,000** (about two years old). These are search-result leads, not verified current offers.
- **Sources:** [Mercari EX-TR150 sold listing](https://jp.mercari.com/item/m40520442708); [Carousell Hong Kong EX-TR150 search](https://www.carousell.com.hk/tr150/q/)
- **GBP price:** Blank. Source currencies are JPY 8,800 and HKD 400/HKD 1,000; no conversion.
- **Notes:** RED VERIFY — the Mercari sale is historical and the touch-panel fault may affect value. Check whether any Carousell listing is still live and whether the exact variant/condition matches.

### 11) Casio — EX-TR200 — Standard Item
- **Master product ID:** \`8972f174-6674-4604-9842-06ad5cd72249\`
- **Marketplace evidence:** eBay UK page displays **US$86.00**, used, four available/one sold, seller Snap Pro Cameras with 100% positive feedback. Seller is located in Zhoukou, Henan, China; shipping is US$13.00 and the page says import fees are included. eBay also displays an approximate GBP conversion, which is not recorded as a GBP price.
- **Source:** [eBay EX-TR200 tested-working listing](https://www.ebay.co.uk/itm/137598371650)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — confirm the seller will ship to the UK on the displayed terms and check the camera's condition/returns. Record US$86.00 and US$13.00 shipping only; do not use eBay's automatic GBP estimate.

### 12) Casio — EX-TR300 — Standard Item
- **Master product ID:** \`56499d0d-1ba5-4bf3-a862-4e671506d4f4\`
- **Marketplace lead:** Taiwan Carousell listing displays **TWD 2,500**, posted roughly two years ago. The title groups EX-TR300, TR350, TR10 and TR15; description is ambiguous about which model is actually offered and says around 90% condition. The page returned an access restriction during direct inspection.
- **Source:** [Carousell Taiwan EX-TR300/TR350/TR10/TR15 listing](https://tw.carousell.com/p/%E3%80%90%E5%87%BA%E5%94%AE%E3%80%91casio-ex-tr300-tr350-tr10-tr15-1269831838/)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — exact model, current availability and condition are not established. Keep the link as a lead; do not treat TWD 2,500 as an exact EX-TR300 price.

### 13) Casio — EX-TR350S — Standard Item
- **Master product ID:** \`e3a44366-29a1-4983-8793-70b3a665841b\`
- **Exact model source:** Five Star Camera Japan page identifies a blue EX-TR350S, used, with one unit shown in stock. Displayed price is **JPY 23,000**; no GBP price.
- **Google Shopping lead:** A Google Shopping/eBay card for the same seller/model displayed £134.65, but the direct eBay item page could not be fetched and the seller is Japan-based. Treat the card's GBP figure as an unverified converted display, not a verified GBP asking price.
- **Near-model UK comparison:** eBay UK EX-TR350 (without “S”) is **£142.99**, used, seller Nexus_digital_official 100% positive, located in Shenzhen, China; shipping is £41.80. It is not the EX-TR350S.
- **Sources:** [Five Star Camera EX-TR350S](https://fivestarcamera.net/en/products/f0046498); [Google Shopping/eBay EX-TR350S lead](https://www.ebay.co.uk/itm/900014478453); [eBay EX-TR350 non-S comparison](https://www.ebay.co.uk/itm/298443947391)
- **GBP price:** Blank for the exact EX-TR350S. The £142.99 comparison is for EX-TR350, not EX-TR350S.
- **Notes:** RED VERIFY — keep the exact JPY 23,000 source and the Google Shopping link. Do not use the £134.65 card as GBP until the direct listing confirms currency and availability. Do not merge EX-TR350 and EX-TR350S.

### 14) Casio — EX-TR500 — Standard Item
- **Master product ID:** \`19023a33-7fc0-4ebd-83b3-c1bd313150c8\`
- **UK retailer lead:** SLRHut lists **£452.86**, “In Stock AND Brand New”, with one-year warranty. However, the title and MPN combine EX-TR50/EX-TR500 (MPN \`CasioTR50/TR500WHT\`), so exact model identity is not certain.
- **Exact-model marketplace lead:** eBay US lists a gold EX-TR500 at **US$171.53**, used, seller says 85–90% new, three available. Seller is overseas; no GBP price.
- **Google Shopping lead:** A red EX-TR500 eBay card showed £145.96 from seller kindly_shop, but its direct listing URL could not be independently retrieved in this run. Do not use the card as a verified GBP price.
- **Sources:** [SLRHut EX-TR50/EX-TR500 page](https://slrhut.co.uk/item-2323c4-casio-exilim-ex-tr50-ex-tr500-selfie-digital-camera-ice-white); [eBay US exact EX-TR500 listing](https://www.ebay.com/itm/407220438315)
- **GBP price:** £452.86 for the ambiguous SLRHut listing only; exact-model GBP price blank.
- **Notes:** RED VERIFY — SLRHut's combined TR50/TR500 title/MPN must be checked against the exact camera model. The eBay US source is a separate exact-model USD observation; do not convert it. The £145.96 Shopping card needs a direct seller URL before acceptance.

### 15) Casio — EX-TR550 — Standard Item
- **Master product ID:** \`f5206006-2f32-49f0-9373-c0a3a5a0bb62\`
- **Marketplace evidence:** eBay Malaysia direct listing identifies “Casio TR550 kamera”, used, at **EUR 120.00** plus **EUR 14.49** international shipping. Seller aswk2592 has zero feedback, is located in Berlin, Germany, and accepts no returns. Listing was last updated 1 March 2026.
- **Google Shopping note:** A Shopping card showed approximately £143.75, but the opened seller page is denominated in EUR. Do not record the card's conversion as a GBP price.
- **Source:** [eBay Casio TR550 listing](https://www.ebay.com.my/itm/365933404434)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — exact model title is present, but seller has zero feedback, no returns and is outside the UK. Record EUR 120.00 + EUR 14.49 only; verify seller and delivery before relying on it.

### 16) Casio — EX-TR700 — Standard Item
- **Master product ID:** \`2c082b75-a79d-40d9-82a3-a97f1d78320e\`
- **Accessory evidence only:** eBay UK charger/USB cable listing at **£19.72**, used, one available, seller located in Accrington, UK. The compatibility selector includes EX-TR700. This is not the camera itself.
- **Source:** [eBay EX-TR700-compatible charger/cable](https://www.ebay.co.uk/itm/317556145571)
- **GBP camera price:** Blank.
- **Notes:** RED VERIFY — no exact EX-TR700 camera listing was found across the searches/Shopping results. Keep the accessory link as model-compatibility evidence only; do not treat £19.72 as a camera price.

### 17) Casio — EX-TR750 — Standard Item
- **Master product ID:** \`7d455d6a-cfe8-43af-a445-859709604ff0\`
- **Google Shopping/eBay lead:** Product card title identifies a Casio EX-TR750 camera and displayed £135.32 from seller kindly_shop. Direct eBay item page could not be fetched, so stock, seller country and original currency remain unverified.
- **International marketplace comparison:** eBay Malaysia category results show a pre-owned Casio TR750 listing at **MYR 694.01** plus **MYR 40.59** shipping. This is a category/search result, not a verified direct item page.
- **Model reference:** Manuals.co.uk hosts an EX-TR750 manual, confirming the model name.
- **Sources:** [eBay UK Google Shopping listing lead](https://www.ebay.co.uk/itm/800850197032); [eBay Malaysia Casio TR listings](https://www.ebay.com.my/b/Casio-Tr/31388/bn_7023339685); [Casio EX-TR750 manual](https://www.manuals.co.uk/casio/exilim-ex-tr750/manual)
- **GBP price:** Blank pending direct-page verification.
- **Notes:** RED VERIFY — the £135.32 card may be a converted overseas seller price; the direct page was inaccessible. Record MYR 694.01 + MYR 40.59 only as the currency shown on the Malaysia result. Gary should verify seller location, original currency, stock and exact model.

### 18) Casio — GZE-1 — Standard Item
- **Master product ID:** \`3e95ae11-d44d-46ab-960f-cfd0b02b6f83\`
- **Official model reference:** Casio marks GZE-1 as a past model; official information identifies the G'z EYE camera, 6.9MP, 50m water resistance, 4m drop resistance and dust resistance.
- **Marketplace evidence:** eBay UK page displays **US$429.00**, used, last one available, seller No.1 Field of Japan with 99.6% positive feedback, located in Japan; import fees included. eBay also displays an approximate GBP conversion, which is not recorded as a GBP price. Item specifics show Model/Type as “NA” despite the title identifying GZE-1BK.
- **Sources:** [Casio GZE-1 official product page](https://www.casio-intl.com/asia/en/dc/products/gze_1/); [Casio GZE-1 official specifications](https://www.casio-intl.com/asia/en/dc/products/gze_1/spec/); [eBay GZE-1BK listing](https://www.ebay.co.uk/itm/304053621917)
- **GBP price:** Blank.
- **Notes:** RED VERIFY — check camera label/photos to confirm GZE-1 and not another G'z EYE model. Record US$429.00 only; do not use eBay's automatic GBP estimate.

### 19) GoPro — HERO — Standard Item
- **Master product ID:** \`42d6393c-8d47-422b-a6db-06ce5f8c4759\`
- **UK retailer evidence:** MPB's GoPro HERO 2014 page shows three used units from **£31 to £45**, with standard 12-month warranty. Individual units include Good-condition examples at £31 and £41.
- **Historical marketplace evidence:** eBay UK listing at **£32.50**, used, ended/out of stock, 41 sold; the listing included a 32GB microSD card. Seller Begoodies UK Ltd has 99.6% positive feedback.
- **Sources:** [MPB GoPro HERO 2014](https://www.mpb.com/en-uk/product/gopro-hero-2014); [eBay GoPro HERO 2014 listing](https://www.ebay.co.uk/itm/315804013360)
- **GBP prices:** £31–£45 (MPB used stock); £32.50 (ended eBay listing).
- **Notes:** RED VERIFY — catalogue model “HERO” should be checked against the original 2014 HERO generation. Do not match later GoPro HERO generations to this master without confirming the model year.

### 20) GoPro — HERO Session — Standard Item
- **Master product ID:** \`f474b652-b819-4679-9cea-ca16f26b6978\`
- **Refurbished UK evidence:** Back Market lists the HERO Session at **£149.99**, Excellent condition, shown in stock, with 12-month seller warranty; seller Reboot Republic Ltd.
- **Used UK evidence:** Cash Converters lists one at **£54.99**, used, very minor cosmetic wear, 12-month warranty, with add-to-cart shown; delivery £7.95. A second Cash Converters listing at **£49.99** is no longer available and includes a soft case/accessories but no charger or box.
- **Sources:** [Back Market GoPro HERO Session](https://www.backmarket.co.uk/en-gb/p/video-camera-gopro-hero-session-black/556da998-19eb-4b3f-9e2e-511d6d0fd330); [Cash Converters HERO Session £54.99](https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/waterproof--action-cameras/action-camera/053000253199); [Cash Converters HERO Session £49.99 ended](https://www.cashconverters.co.uk/shop/phones-cameras--computers/cameras/waterproof--action-cameras/action-camera/060500004720)
- **GBP prices:** £149.99 refurbished Excellent; £54.99 used; £49.99 historical unavailable listing.
- **Notes:** Compare condition and warranty separately. The £149.99 Back Market price is refurbished Excellent, not a like-for-like used private-sale price.

## 4. Additional prior-work exclusions (not researched again)

The preceding conversation had already reported this AKASO batch, but those IDs were not yet present in the scheduled batch-02 checkpoint. They were excluded from this run to avoid repeating the previous report:

- \`b162fdc0-2b9b-4e6b-9a7a-5e3c9280c0aa\`
- \`90b65f3f-85f8-4cad-8618-0b299e3ed772\`
- \`41359541-440d-4984-ac65-24837595a213\`
- \`ae1a9089-70b2-45c7-a5eb-ca891bc68546\`
- \`da1ddeed-1b8a-4936-b406-2505a20c44a5\`
- \`0558ebd6-28a5-45bc-abf3-2b159132420e\`
- \`9b711fbf-1bb7-4562-ad59-951eda86f386\`
- \`69fbffdb-a37e-4c28-aaf8-2277ec3a8c15\`
- \`8c0da10d-cd63-4271-a261-ae75e87950a8\`
- \`06f1eddb-7716-4c58-babd-5d467e84c7c8\`
- \`b8197316-0d22-4889-a922-b8ce1fa36215\`
- \`dfde7088-45ff-41cf-a601-c4c5501fdc0a\`
- \`de39566c-6a26-442a-981d-19b2a31c7d72\`
- \`87aa6c7e-86b4-4105-9994-4768cd6677ca\`
- \`21ac2570-a9c8-40aa-a35d-fdcb446a9ca9\`
- \`44b13287-3351-4a6d-8f02-8a6612552718\`
- \`2a3da40b-1724-40c3-8dbb-a7f5276d902c\`
- \`9873a255-e265-4ed6-b8b3-c8b1257ef3f4\`
- \`8a1fa3da-6e70-4c3a-aab2-7053ef848818\`
- \`891cc66e-1ea1-4a74-8c92-2781ddeb7540\`

## 5. Next scheduled run

1. Read this batch-03 checkpoint and matching PROJECT-MEMORY file first.
2. Exclude all product IDs in scheduled batches 01, 02 and 03, plus any newly completed research checkpoints.
3. Re-read current LIVE evidence, outstanding queue candidates and manual AI research prompts. Exclude all covered products before selection.
4. Select the next 20 active LIVE master products with no active \`shared_market_evidence\`, dynamically and without a fixed OFFSET.
5. Recheck evidence/queue/prompt status immediately before research.
6. Search manufacturer sites, UK retailers, marketplaces and Google Shopping; open the actual product pages and inspect variants/package contents.
7. Keep uncertain links and use \`RED VERIFY\`; do not invent prices or convert foreign currencies to GBP.
8. Stage only through the supported authenticated platform-owner RPC. If \`auth.uid()\` is null or owner check fails, do not write directly; create the next checkpoint and PROJECT-MEMORY file instead.
9. Do not change master products, schema, valuation logic, TEST or Stripe.


## Verified UK source follow-up imports — 12 November 2026

Four of the outstanding RED VERIFY candidates were resolved to exact existing LIVE catalogue masters and imported:

1. Sony Alpha A7C / Body Only, master 9d83dbc2-cd8d-4d8b-8307-faafbc94b44a — E-Infinity UK £799.00, new, in stock, 12-month warranty, free shipping and import tax included. Exact black body-only variant, EAN 027242920576; box lists body cap, battery, AC adapter, USB cable and strap; memory card not included. Evidence ID 3a302f1a-67e6-4ed0-8b2b-4c71ed4c7fac. Source https://www.e-infin.com/uk/item/4170/sony_a7c_mirrorless_camera_body_only_%28black%29.
2. Parrot ANAFI Work / Standard, master 55138955-6661-49f3-828f-0695244ec90a — Sunbelt Sales SKU PF728100AA £1,040.00 GBP ex VAT, new, in stock. Exact kit includes ANAFI, Skycontroller 3, compact shoulder bag, four smart batteries, multi-port USB charger, eight propellers, 16GB SD card, USB-C cables and one-year Pix4Dmodel subscription. The database amount is the source's ex-VAT price; it is not VAT-inclusive. Evidence ID f3b537ef-4eb1-4d3c-93a4-2618f1630b49. Source https://www.sunbeltsales.co.uk/parrot-anafi-work-uav.
3. AKASO Brave 4 / With SD Bundle, master fa12fe2d-7f85-49a4-a38a-2bb3d5fd5d71 — Desertcart UK £147.22, new, in stock, duties/taxes included, sold by Amazon UK and delivered by Desertcart. Exact Brave 4 model with 64GB U3 microSD; listing also states two 1050mAh batteries and bicycle/helmet accessory kit, so retain the extra-accessory note because it is a richer bundle than the bare With SD variant. Evidence ID bfae9943-66a3-47bc-a76c-a65b0753fc54. Source https://www.desertcart.co.uk/products/538890770-akaso-brave-4-4k30fps-20mp-wifi-action-camera-with-64gb.
4. Sony Alpha SLT-A68 / Body Only, master 76ae42da-da35-40bf-bb03-7a317303bab0 — MPB SKU 4297151 £279.00, one available, Good, 5,410 shutter count, 12-month warranty and 14-day returns. Slight smoke odour; third-party battery, charger, cap, strap, box and eyecup included; Sony-branded original battery and USB cable not included. UK Used reference only. Evidence ID 3e426a85-bab4-4f84-bd20-8d5d5b599125. Source https://www.mpb.com/en-uk/product/sony-alpha-slt-a68/sku-4297151.

All four rows were read back from LIVE and match their exact master/package IDs. Batch 03 now has four active GBP rows (3 UK New, 1 UK Used). Cumulative Batches 03–13 now contain 246 observations: 243 active (133 UK New, 110 UK Used), three inactive.

The remaining Batch 03 RED VERIFY leads are not being forced into mismatched catalogue entries: foreign-currency-only Casio/Sony sources, the Sony TR50 mixed TR50/TR500 seller title, model/package uncertainties in AKASO V50/Brave variants, the original GoPro HERO generation, Freefly US-only prices, ANAFI charger compatibility, ANAFI Extended bundle mismatch, and BVP-9500WSP vs BVP-9500W suffix difference. Keep those source links and notes for follow-up; do not convert foreign currencies or invent a GBP price. No master product, schema or valuation change; TEST and Stripe untouched.


## AKASO V50 X With SD Bundle — current UK marketplace source verified — 12 November 2026

The previous YPC snapshot (£109.99, dated 22 October) was not used as a current checkout price. A current direct eBay UK listing was opened and checked instead:
- LIVE master: AKASO V50 X / V50 X With SD Bundle, ID d763014a-70e2-4a0e-a7ce-bf8e0afdb0e1.
- Clarkson Direct listing: £153.99, New, 2 available / 1 sold; exact listing title and item specifics identify V50 X-U3 and “With 64GB microSD Card”. Seller description confirms V50 X, two 1350mAh batteries and the model's 4K/EIS features.
- Seller is a UK business based in Beverley HU17 8YA, 95.5% positive feedback, 11K items sold. Listing last updated 19 August 2026; page was still live with two available when checked 12 November. No returns accepted; eBay Money Back Guarantee applies.
- Direct listing: https://www.ebay.co.uk/itm/326424455596. Seller description: https://itm.ebaydesc.com/itmdesc/326424455596?category=11724&cspheader=1&descgauge=1&domain=ebay.com&excSoj=1&excTrk=1&ittenable=false&lang=en&lsite=3&oneClk=2&secureDesc=1&seller=95clarksonw&t=0&ver=1.
- Imported as active UK New GBP £153.99 against exact With SD Bundle master. LIVE evidence row 8c8b32c5-e38d-4c5c-83f9-a0af9ee3aa3d; source_record_key batch03-followup-akaso-v50x-with-sd-ebay-15399-20261112. Read-back confirmed exact master/package, source, price, condition, availability and active state.

Batch 03 now has 5 active rows (4 UK New, 1 UK Used). Batches 01–13 now contain 255 observations: 252 active (137 UK New, 115 UK Used), three inactive. The £109.99 YPC snapshot remains a dated comparison lead, not an additional live offer. No master/schema/valuation change; TEST and Stripe untouched.


## Caddx Walnut — two UK specialist retailer price references — 12 November 2026

The previously unverified £117.90 and £129 leads were re-opened at their direct UK specialist retailer pages. Both are exact Caddx Walnut camera offers and both are explicitly unavailable at the time checked; they are imported as price-reference observations with availability preserved, not as in-stock offers:
- FlyingTech, SKU FPV-WALNUTND816 — £117.90 inc VAT, explicitly Sold out / Out of stock. Package: camera, adjustable mount, charging cable, thumb screw, camera case, ND8 and ND16 filters, lens cloth and cable set. Source https://www.flyingtech.co.uk/product/caddx-walnut-fpv-action-camera-w-nd8-nd16-filters/. LIVE evidence row 3b791f3e-c1ab-455d-946e-add1a4b9e7b8.
- Unmanned Tech, product CDX-WLNT-AC — £129.00 GBP, taxes included, explicitly Sale Sold out / Out of stock / Backorder awaiting stock. Package guide lists camera, adjustable mount, charging cable, thumb screw, camera case, ND8/ND16 filters, lens cloth and cable set; supplier says accessories may vary. Source https://www.unmannedtechshop.co.uk/products/caddx-walnut-action-camera. LIVE evidence row 7d57b245-5b93-4c0c-a570-c31639e50c7b.

Both rows are attached to existing Caddx Walnut / Caddx Walnut Action Camera master a628320d-771b-43f9-8503-206e06221d49, active evidence with availability out_of_stock/backorder. No current-stock or buying recommendation should be inferred from these prices.

Batch 03 now has 7 active rows (6 UK New, 1 UK Used). Batches 01–13 now total 257 observations, 254 active (139 UK New, 115 UK Used), three inactive. No master/schema/valuation change; TEST and Stripe untouched.
