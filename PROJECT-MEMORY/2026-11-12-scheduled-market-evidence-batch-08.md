# TradeFlow LIVE Project Memory — Scheduled Market Evidence Batch 08

**Date:** 2026-11-12  
**Repository/branch:** `laurendigitaluk/TradeFlow` / `production`  
**LIVE Supabase project:** `gxsrajtqzdjvmceqcpgv`  
**Status:** 20 products researched; 0 candidates staged because owner-auth context was unavailable.

## Canonical detailed checkpoint

Read the full evidence, source URLs, prices/currencies, condition, availability and RED VERIFY notes here:

- `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-08.md`
- Checkpoint commit: `69d1eceaf09840cb021269822755df1c318ba2bb`

This memory file intentionally keeps a compact index, but preserves the primary source links and the key findings for all 20 products.

## Preflight and exclusions

Read checkpoint 02 and project memory 02 first, then all available scheduled evidence checkpoints 03–07 and project memories 04–07. A Batch 03 project-memory file is absent from production; its checkpoint was present and read.

Excluded every product ID from scheduled checkpoints 02–07, all products covered by outstanding LIVE queue candidates, and all products in outstanding manual AI research prompts. Current preflight state:
- Queue: 28 imported, 10 `needs_research`, 43 rejected; no `pending_review`.
- One outstanding manual AI prompt: `4e9d16d5-baae-4fb7-8617-2e3a0a829cb5`, status `ready`, 20 products.
- No selected product overlapped with those queue candidates or the manual prompt.
- Selection used dynamic anti-joins and created_at ordering; no fixed SQL OFFSET.
- All 20 selected products were rechecked immediately before research: 0 active evidence, 0 outstanding queue candidates, 0 outstanding manual prompt matches.
- An exact Nikon Ai-S NIKKOR 28mm f/2 identity was skipped because an older checkpoint already covered the model/package, despite a different current catalogue UUID. Nikon COOLPIX P7700 replaced it.

## Batch 08 product index

All prices below are observed source prices, not valuation recommendations. Non-GBP currencies are not converted. Every uncertain record must retain the source URL and its `RED VERIFY` note.

| # | Product ID | Product / package | Observed UK GBP evidence | Primary source links | Important note |
|---:|---|---|---|---|---|
| 1 | `8b2b368b-e1d6-42ab-a3ed-755f33d64157` | FIMI X8 Mini V2 — with bag | No reliable UK GBP price; avXperten NOK 4,959, out of stock | [Ubuy](https://www.u-buy.co.uk/product/IKE12TH9K-fimi-f9miniv3-drone-orange-version-with-camera-4k-rth-rc-quadcopter), [avXperten](https://www.avxperten.no/droner/fimi-x8-mini-v2-combo-drone-3x-intelligent-flight-battery-taske-8km.asp), [FIMI](https://store.fimi.com/en-br) | RED VERIFY — avXperten is a three-battery-plus-bag combo; no UK GBP offer. |
| 2 | `a3b3e15e-8298-425f-b88e-b6773b421430` | Freefly Flux H1 LiDAR | No UK GBP price; official USD $32,995, ships 7–10 business days | [Freefly portal](https://portal.freeflysystems.com/products/flux-h1), [Freefly overview](https://freeflysystems.com/flux) | RED VERIFY — preserve USD only; do not convert. |
| 3 | `9d94644e-8638-40ab-a365-699ed8b2c57f` | Freefly Wave 2TB SSD | No UK GBP price; refurbished USD $6,995, in stock | [Freefly refurbished Wave](https://store.freeflysystems.com/collections/wave/products/wave-refurbished) | RED VERIFY — it is a Wave camera with 2TB internal SSD, not a standalone SSD; refurbished with 6-month warranty. |
| 4 | `bf1f899b-d3c1-41f5-aa41-f78158e48d84` | GoPro HERO6 Black | UsedLens £79 low / £103 typical / £130 high; MPB Good £82, Excellent £123 | [UsedLens](https://usedlens.co.uk/product/gopro-hero-6-black) | RED VERIFY — eBay prices include bundles with batteries/accessories; separate body-only from bundles. |
| 5 | `b7405ab6-ec10-44ed-b616-afa1a4a72fff` | GoPro MISSION 1 PRO Grip Edition | H2O £779, sold out; GoPro UK search index £679.99 but page text dynamic | [H2O Sports](https://www.h2o-sports.co.uk/products/mission-1-pro-grip-edition), [GoPro UK](https://gopro.com/en/gb/), [GoPro release](https://investor.gopro.com/press-releases/press-release-details/2026/GoPros-New-MISSION-1-Series-Cameras-Mounts-and-Accessories-Now-Available-on-Retail-Shelves-Globally-and-at-GoPro-com/default.aspx) | RED VERIFY — H2O exact bundle includes camera, grip, Enduro 2 battery, lens hood and case; confirm official UK checkout price. USD MSRP is not GBP. |
| 6 | `e2776acc-9d95-4180-a60d-5f1794454e89` | HoverAir X1 PROMAX Standard | Very £609 sale / £639 regular | [Very](https://www.very.co.uk/hoverair-x1-promax-standard-self-flying-camera-drone/1601321442.prd), [AO](https://ao.com/product/sp06h006-hoverair-x1-promax-drone-black-111519-755.aspx) | RED VERIFY — 64GB standard version; charger not included; do not substitute Jessops Retail Combo. |
| 7 | `a8806ece-5fb3-42e4-be27-a20268d7a043` | Hubsan H109 X4 Brushless | Closest official H109S Pro Professional £699, out of stock; Gumtree used lead £150 | [Hubsan H109S Pro](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=6), [Gumtree](https://www.gumtree.com/p/drones/hubsan-x4-h109s-drone/1512642681), [Hubsan China Standard](https://chn.hubsan.com/index.php?main_page=product_info&products_id=8) | RED VERIFY — catalogue H109 vs H109S Pro suffix/package mismatch; Gumtree page not re-opened; China Standard price CNY 2,999 not converted. |
| 8 | `bd1fcdb9-62e0-46ea-b047-0af37a6aa724` | Hubsan H501A | Official standard £199 out of stock; H906A combo £249 out of stock | [Hubsan H501A](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=521), [H501A + H906A](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=590), [G-Force Japan](https://www.gforce-hobby.jp/products/H501A.html), [eBay Shopping lead](https://www.ebay.co.uk/itm/318348365081?chn=ps&_ul=GB&mkevt=1&mkcid=28&google_free_listing_action=view_item) | RED VERIFY — £312.70 Shopping/eBay lead page inaccessible; distinguish standard from H906A combo. G-Force JPY 49,800 before tax not converted. |
| 9 | `9e1fead2-e365-4ac7-a207-45e36fdac49e` | Hubsan H501M X4 Waypoints FPV | Official £139, out of stock | [Hubsan H501M](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=218) | Exact model-family match; 720p, 2,700mAh battery, GPS/waypoints. |
| 10 | `7b8312f1-df34-4fd8-81d9-780ad62ca78d` | Hubsan HT55 | Official £350, out of stock | [Hubsan HT55](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=1093) | RED VERIFY — exact model, but “In the Box” is image-only; check package contents. |
| 11 | `ad547a9f-1c83-4858-8d49-76cfb563c7e0` | Hubsan MINI standard version | Official £439, out of stock | [Hubsan Mini Standard](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=1059) | Exact one-battery standard version. |
| 12 | `79871190-a705-454d-b166-efb9c3fbff45` | Hubsan ZINO MINI PRO 128GB / one battery | Official £569, out of stock; Unmanned Tech 64GB variant £284.95, unavailable/backorder | [Hubsan 128GB](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=947), [Unmanned Tech 64GB](https://www.unmannedtechshop.co.uk/fr/products/hubsan-zino-mini-pro-4k-drone-sub-250g) | RED VERIFY — 64GB retailer offer is not the 128GB catalogue package. |
| 13 | `a43c3673-d3a0-496b-a2f6-f78dfa349ffb` | Hubsan Zino Pro Standard Package | Menkind £279 standard; £349 spare-battery-and-bag bundle; Hubsan portable version £335 out of stock | [Menkind Standard](https://www.menkind.co.uk/hubsan-zino-pro-folding-drone-4k), [Menkind Bundle](https://www.menkind.co.uk/hubsan-zino-pro-folding-drone-with-battery-and-bag), [Hubsan Portable](https://www.hubsan.com/eur/index.php?main_page=product_info&products_id=669), [Sussex spare part](https://sussex-model-centre.co.uk/collections/hubsan/products/hubsan-zino-pro-gps) | RED VERIFY — use £279 closest standard; £349 is different bundle; £37.98 Sussex listing is a spare part, not drone. |
| 14 | `6e8daf15-edc7-4418-8974-d5ae45f4a450` | NEEWER KM19 wireless lav mic | Official £39.99; eBay £39.62 new (private seller in Wolverhampton, away until 19 Nov 2026); Amazon Shopping leads £38.99/£47.99 | [NEEWER](https://uk.neewer.com/collections/portable-microphone/products/neewer-km19-wireless-lavalier-microphone-66609101), [eBay](https://www.ebay.co.uk/itm/880041406167), [Amazon lead 1](https://www.amazon.co.uk/NEEWER-KM19-Microphone-Compatible-Cancellation-Black/dp/B0H7S7RWB4), [Amazon lead 2](https://www.amazon.co.uk/NEEWER-KM19-Microphone-Compatible-Cancellation-Black/dp/B0GXV9QBJ4) | RED VERIFY — official stock text contradictory; eBay is a private seller with no returns and is away until 19 Nov 2026; Amazon pages inaccessible. |
| 15 | `ab1ef244-d761-425c-9d03-7480e30e8bfd` | NEEWER LS-29 PRO fisheye | YPC historical £67.49 (2026-08-15); official UK search index £58.99 but page unavailable | [YPC product](https://www.ypc.co.uk/product/neewer-8mm-fisheye-lens-with-220-wide-angle-17mm-thread-phone-lens-clip-also-for-17mm-threaded-phone-cage-case-clamp-backplate-ls-29-pro/) | RED VERIFY — historical aggregator price, not current checkout; 8mm/220°/17mm-thread exact lens. AliExpress £33.06 result was a different VR fisheye. |
| 16 | `632b988e-13dd-4429-b236-c61bfaec68fd` | NEEWER NL660 2 Pack Softbox Kit | Official £229.99; used Gumtree £75 | [NEEWER exact kit](https://uk.neewer.com/collections/top-daily-sellers/products/neewer-2-pack-bi-color-660-led-video-light-and-stand-kit-with-softbox-66604920), [Gumtree](https://www.gumtree.com/p/lighting-studio/neewer-2-pack-nl660-led-video-lights/1512800837), [Amazon Shopping lead](https://www.amazon.co.uk/Upgraded-Control-3200K-5600K-Streaming-Photography/dp/B0BKS8B1ZM) | RED VERIFY — official stock status contradictory; Gumtree used/as good as new and battery pack not included; Amazon page 503. |
| 17 | `bc03b00f-bea0-4b73-a20f-cbce6e725947` | NEEWER PA028E Bluetooth side handle | Official £45.99; Shopping variant £50.99; Amazon lead £32.99 | [NEEWER PA028E](https://uk.neewer.com/products/neewer-pa028-bluetooth-side-handle-with-phone-holder-ssd-holder-for-15-pro-max-66604178), [Shopping variant](https://uk.neewer.com/products/neewer-pa028-bluetooth-side-handle-with-phone-holder-ssd-holder-for-15-pro-max-66604178?variant=49412501373227&country=GB&currency=GBP) | RED VERIFY — title says PA028E but spec field says PA028; variant page inaccessible; verify model/variant and price. |
| 18 | `fdcf0188-0cf2-425a-8e8a-33ddf74d9242` | NEEWER RH12C RGB ring light | Official £79.99 | [NEEWER RH12C](https://uk.neewer.com/products/neewer-rh12c-12-24w-high-power-rgb-led-ring-light-66606469), [RH12B Shopping mismatch](https://www.amazon.co.uk/NEEWER-Compatible-Recording-Streaming-Ringlight/dp/B0D2566PLT) | RED VERIFY — official stock message contradictory; Shopping RH12B is not RH12C. |
| 19 | `70961335-22f9-4b5b-859d-f74a9995aa97` | NEEWER TP014 overhead tripod/monopod | Official £102.99; Shopping leads £82.39 Neewer, £74.39 Amazon, £113 Ubuy | [NEEWER TP014](https://uk.neewer.com/collections/20-off-products/products/neewer-basics-tp014-overhead-camera-tripod-monopod-66609186), [Shopping variant](https://uk.neewer.com/products/neewer-basics-tp014-overhead-camera-tripod-monopod-66609186?variant=62533408522611&country=GB&currency=GBP) | RED VERIFY — variant pages inaccessible; official stock text contradictory; check checkout price. |
| 20 | `59de3715-2ec7-47c1-93d3-57048b4355ac` | Nikon COOLPIX P7700 | MPB Good £239 / Excellent £294; UsedLens low £213 / typical £239 / high £294 | [MPB](https://www.mpb.com/en-uk/product/nikon-coolpix-p7700), [UsedLens](https://usedlens.co.uk/product/nikon-coolpix-p7700), [UsedLens alternate snapshot](https://mail.usedlens.co.uk/product/nikon-coolpix-p7700), [eBay lead](https://www.ebay.co.uk/itm/407268626032) | RED VERIFY — Japan eBay Shopping lead £175.32 is not UK market evidence; body-only and accessory bundles differ. |

## Queue-staging limitation

LIVE owner-auth check:
- `current_user = postgres`
- `auth.uid() = null`
- `auth.role() = null`
- `platform_cloud_ai_owner_check() = false`

Therefore:
- no direct write to `platform_catalogue_research_queue`
- no claims impersonation or RLS bypass
- no unauthenticated owner RPC attempt
- 20 research candidates preserved in GitHub, 0 staged as `pending_review`
- no master product, schema, valuation or automatic valuation changes
- TEST and Stripe untouched

## Next scheduled run

The existing hourly automation remains enabled and its saved prompt already contains the full selection/research/authentication rules. On the next run:
1. Read checkpoint 08 and this project-memory file.
2. Exclude all product IDs from checkpoints 02–08.
3. Recheck outstanding queue candidates and manual AI prompts.
4. Select the next 20 eligible active LIVE master products dynamically without SQL OFFSET.
5. Recheck active evidence and queue/prompt status immediately before researching.
6. Attempt staging only through the authenticated platform-owner RPC if owner auth passes; otherwise create Batch 09 checkpoint and project-memory files.


## 12 November 2026 — Batch 08 RED VERIFY follow-up

Six further records were imported and read back: Hubsan H501A X4 Air Pro / Elite Models £209.99 sold out; Hubsan H501M X4 / Elite Models £139.99 sold out; Hubsan ZINO Pro / Elite Models £389.99 supplier stock; NEEWER NL660 2-pack / Gumtree £75 used, battery pack not included; GoPro HERO6 Black / UsedLens MPB Excellent £119; NEEWER KM19 / eBay £47.94 new, seller away until 19 Nov, stored inactive.

Updated existing observations: Nikon COOLPIX P7700 MPB is now one Good unit at £229 (replacing the stale £239/£294 range); Very HOVERAir X1 PROMAX Standard is confirmed at £609 sale (£639 regular), charger not included, in stock with 3–5 day delivery. The NEEWER KM19 eBay row is inactive until seller returns; the official NEEWER £39.99 row remains active.

Batch 08 now has 14 total GBP rows: 13 active (10 UK New, 3 UK Used) and one inactive UK New seller-away row. Official Hubsan /eur prices for MINI and ZINO MINI PRO remain RED VERIFY because the UK delivery region is not confirmed. Other unresolved suffix, package and accessory bundles remain in the checkpoint. No master, schema, valuation logic, TEST or Stripe changes.


## 12 November 2026 — Batch 08 RED VERIFY follow-up

Six additional GBP observations were added and read back: Hubsan H501A £209.99 new/out of stock; Hubsan H501M £139.99 new/out of stock; Hubsan Zino Pro £389.99 new/supplier stock; NEEWER NL660 two-pack £75 used on Gumtree; GoPro HERO6 Black £119 used Excellent via UsedLens/MPB; NEEWER KM19 £47.94 new via eBay but seller away, so inactive.

Corrected Nikon COOLPIX P7700 MPB from £239 to £229 (Good, in stock, battery and charger included) and confirmed HOVERAir X1 PROMAX Standard / Very at £609 sale, £639 regular, in stock. Batch 08 now has 14 total rows, 13 active (10 UK New, 3 UK Used), one inactive seller-away row, all GBP. Exact details and unresolved leads are in the checkpoint. No master data, schema, valuation logic, TEST or Stripe changes.
