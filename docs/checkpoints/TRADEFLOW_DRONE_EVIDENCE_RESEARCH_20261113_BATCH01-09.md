# TradeFlow LIVE — Drone evidence research checkpoint (13 November 2026)

## Scope and safeguards

- Environment: LIVE Supabase project `gxsrajtqzdjvmceqcpgv` only.
- TEST project and TEST data untouched.
- LIVE Stripe untouched.
- Pokémon Trading Cards excluded from this equipment evidence-research workload; no Pokémon catalogue records changed.
- No master catalogue products, package definitions, categories, aliases, schema, RLS or valuation logic changed.
- All inserted observations are GBP and linked to exact existing `catalogue_master_products.id` values.
- `uk_used` observations are comparison/reference only and must not enter automatic valuation. Existing valuation contract remains latest active GBP `uk_new` observation by `observed_at` then `created_at`; do not change it.
- New-condition prices that are sold out or pre-order remain valid historical/current price observations when the page explicitly shows a price; availability is recorded truthfully.

## Batch 01 — 20 products reviewed

- 8 UK New observations inserted and read back; 6 products gained first UK New coverage and 2 received additional independent/fresh observations.
- 12 products held where no exact UK GBP source/package match could be verified.
- Sources and observations:
  - Autel EVO II Dual 640T Rugged Bundle V3 — Scan UK £4,768.99, pre-order.
  - Autel EVO II Pro 6K RTK Rugged Bundle V3 — Scan UK £3,058.99, pre-order.
  - Autel EVO Lite Standard Bundle — Scan UK £976.99, pre-order.
  - Autel EVO Lite 640T Enterprise Plus Combo — Photospecialist UK £3,444.00, on order.
  - Autel EVO II Dual 640T Enterprise Bundle V3 — BuzzFlyer UK £5,359.00, in stock.
  - Autel EVO Lite+ Standard Bundle — Scan UK £1,055.99, fresh pre-order observation; previous observation retained.
  - BetaFPV Aquila16 Brushless Quadcopter — HobbyRC UK £84.35, out of stock.
  - BetaFPV Aquila20 FPV Kit — HobbyRC UK £221.55, in stock.
- 12 held: Autel Alpha; Autel EVO; Autel EVO II Pro V3 Enterprise Bundle; EVO Lite 640T Enterprise Basic and Premium Combos; EVO Lite 6K Enterprise Basic, Plus and Premium Bundles; EVO Max 4N V2, 4NZ V2 and 4T V2; BetaFPV Air65 & Air75 Wisp Limited Edition.
- Air65/Air75 product pages were also checked but not imported where receiver/VTX selections were ambiguous.
- Batch 01 dashboard status message: `Drones — 20-product research batch 01: 8 verified UK New observations added to LIVE`.

## Batch 02 — 20 products reviewed

- 9 evidence observations inserted and read back: 8 UK New and 1 UK Used, across 9 exact existing master products.
- 11 products held for exact source/package/variant uncertainty.
- Imported:
  - BetaFPV Cetus Pro FPV Kit — Unmanned Tech UK £199.95, out of stock.
  - BetaFPV Cetus X ELRS Kit — Senetic UK £217.76, out of stock.
  - BetaFPV Meteor75 Pro analogue/ELRS whoop — HobbyRC UK £85.00, out of stock.
  - BetaFPV Meteor75 Pro analogue FPV Kit — HobbyRC UK £170.00, in stock.
  - BetaFPV Meteor75 Pro P1 HD — HobbyRC UK £113.30, out of stock.
  - DJI Mavic 2 Zoom with Smart Controller — MPB UK £519.00 used, Excellent, one listed item (SKU 3974221).
  - DJI Mini 4K Fly More Combo — Drone Safe Store UK £399.00, out of stock; exact SKU/EAN 6941565980397.
  - EMAX Tinyhawk II Freestyle RTF — BuzzFlyer UK £214.95, out of stock.
  - EMAX Tinyhawk III RTF Kit — HobbyRC UK £231.30, in stock.
- Held: Autel EVO Nano Standard Bundle; BetaFPV Aquila20 standalone; Cetus X HD FPV Kit; Meteor65 Pro II O4; Meteor75 Pro II O4; Pavo Pico; Pavo20 Pocket; Pavo25 V2; Pavo30; Pavo35; DJI Matrice 350 RTK Standard Package. Reasons include no exact UK GBP source, ambiguous VTX/receiver selection, or source package mismatch (e.g. DJI Matrice Worry-Free Basic Combo vs catalogue Standard Package).
- Batch 02 dashboard status message: `Drones — 20-product research batch 02: 9 verified UK market observations added to LIVE`.

## LIVE read-back after Batch 02

- `shared_market_evidence`: 4,859 total / 4,797 active / 62 inactive.
- Active UK New: 2,330.
- Active UK Used: 2,467.
- Active Drones products: 541.
- Drones still without active UK New evidence: 378.
- Drones still without active UK Used evidence: 368.

## Research controls and continuation

- Research 20 distinct existing products per batch; evidence rows may be more or fewer than products.
- Record source, direct URL, GBP price, condition, availability and exact model/package notes. Do not infer or substitute a similar model, bundle, receiver, controller or VTX.
- Do not invent UK Used sale prices. Use a completed-sale label only when the source confirms the item sold; otherwise preserve listing/ended/out-of-stock state.
- Keep historical source observations separate; do not overwrite good existing evidence or deactivate records without a verified reason.
- Record all reviewed master product UUIDs in each dashboard message's `metadata.reviewed_product_ids` so subsequent batches cannot reselect the same products.
- Before Batch 03, use these UUIDs to exclude Batch 01 and 02 products; continue with the next 20 active Drone products without active evidence.



## Batch 03 — 20 products reviewed (13 November 2026)

- 3 verified GBP observations inserted and read back across 2 exact LIVE master products: EMAX Tinyhawk Lite RTF — Unmanned Tech UK £134.95 New/out of stock; HobbyRC UK £140.90 New/out of stock; FIMI X8 SE 2020 — eBay UK completed Used sale £47.40 (underlying item price, excluding £2.16 Buyer Protection fee), ended 25 September 2026. The used record is reference-only.
- 18 products held: BetaFPV Air65 (Racing/Freestyle variant not resolved), Air75 (ELRS/TBS variant not resolved), FIMI A3, FIMI X6, FIMI X8 Pro, FIMI X8 SE 2022, Mi Drone 1080P, Mitu Mini Drone, X8 Mini, X8 Mini V2, X8 Pro 2025, X8 SE, X8 SE 2022 V2, X8 Tele, X8T V384 (no exact UK GBP source), X8T V640 (conflicting current/cached price snapshots; live price/availability recheck required), Freefly Alta 6 (manufacturer discontinued; old sold-out new price not used as an active valuation reference), and Freefly Alta 8 (eBay listing's item specifics say Remote Control and do not confirm the standard drone package).
- Dashboard status message: `Drones — 20-product research batch 03: 3 verified observations added to LIVE`. Reviewed UUIDs are saved in metadata to prevent duplicate selection.
- LIVE after Batch 03: 4,862 evidence rows total / 4,800 active / 62 inactive; 2,332 active UK New and 2,468 active UK Used. Drones remain 541 active products; 377 without active UK New and 367 without active UK Used.



## Batch 04 — 20 products reviewed (13 November 2026)

- 4 verified GBP observations inserted and read back across 3 exact LIVE master products: GEPRC Vapor-X5 HD O4 Pro ELRS24 GPS — HobbyRC UK £359.95 New/out of stock; eBay UK completed Used sale £297.40 item price (excluding £10.50 Buyer Protection fee), sold 30 September 2026; GEPRC Vapor-X5 WTFPV ELRS 2.4G with GPS — eBay UK £227.91 New, five available, MPN GP107470, seller located Ivybridge, England; Holy Stone HS110G — eBay UK completed Used sale £26.35 item price (excluding £1.46 Buyer Protection fee), sold 29 September 2026.
- 17 held: Freefly Alta X, Alta X Gen2, Alta X Gen2 NDAA, Astro, Astro Max standard, Astro Max NDAA/Blue standard, Astro Max NDAA/Blue with LR1 payload, Astro Max Mapping Essentials, Astro Max Mapping Essentials NDAA/Blue (no exact UK GBP sources); GEPRC CineLog30 V3 O4 Pro ELRS (receiver/price ambiguity), CineLog35 V2 Analog (receiver variants), DarkStar20 ELRS (unverified seller source); Holy Stone H4831, HS110D, HS180, HS210FS and HS210P (no sufficiently reliable current exact UK GBP retail evidence).
- Dashboard status message: `Drones — 20-product research batch 04: 4 verified observations added to LIVE`. Reviewed UUIDs are saved in metadata to prevent reselection.
- LIVE after Batch 04: 4,866 evidence rows total / 4,804 active / 62 inactive; 2,334 active UK New and 2,470 active UK Used. Drones remain 541 active products; 375 without active UK New and 365 without active UK Used.



## Batch 03 follow-up — Freefly Alta 6 / Alta 8 UK Used evidence (13 November 2026)

A later source pass found three exact UK Used references for two products that had been held in Batch 03:
- Freefly Alta 6 — eBay completed sale £2,800 item price (excluding £52.25 Buyer Protection fee), sold 9 November 2026, plus a separate current UK business-seller listing at £5,000.
- Freefly Alta 8 — current UK business-seller listing at £7,000.
All three were read back from LIVE and are active `uk_used` references only; they do not affect automatic valuation. The Alta 6/Alta 8 Batch 03 hold notes are superseded for UK Used coverage only; no UK New source was added. Dashboard follow-up message: `Drone research follow-up — Freefly Alta 6 and Alta 8 UK Used evidence added to LIVE`.

LIVE after this follow-up: 4,869 evidence rows total / 4,807 active / 62 inactive; 2,334 active UK New and 2,473 active UK Used. Drones remain 541 active products; 375 without active UK New and 363 without active UK Used.



## Batch 05 — 20 products reviewed (13 November 2026)

- 9 verified UK GBP New observations inserted and read back across 9 exact LIVE master products:
  - Holy Stone HS360E — £179.99 Amazon UK price snapshot via YPC, dated 6 October 2026 (ASIN B0D4DCJY8R; stock not independently confirmed).
  - Holy Stone HS600D — £399.99 Amazon UK price snapshot via YPC, dated 15 September 2026 (ASIN B0DZSPX6MG; stock not independently confirmed).
  - Holy Stone HS900 — £248.00 official Holy Stone GB/GBP store, sold out.
  - HOVERAir X1 Standard — Currys UK £299.00, online delivery available.
  - HOVERAir X1 PRO Standard — Currys UK £459.00, online delivery available, EAN 6977791920005.
  - Hubsan ACE Standard — official Hubsan UK/GBP storefront category listing £469.00; stock not exposed.
  - Hubsan ACE 3 — official Hubsan UK/GBP storefront category listing £1,299.00; stock not exposed.
  - Hubsan ACE PRO Standard — official Hubsan UK/GBP product page £529.00, out of stock.
  - Hubsan ACE PRO REFINED Standard — official Hubsan UK/GBP product page £619.00, out of stock.
- 11 held: Holy Stone HS320 (undated affiliate snapshot only), HS420 (seller fulfilment/business identity insufficiently verified), HS440D (review-style third-party listing, not verified retailer), HS700E, HS720-4K, HS790, HS800, HS900 Pro and T60A (no sufficiently reliable exact UK GBP retail source); HOVERAir X1 PRO Max Standard (Very/Quzo price snapshots conflict; direct price/availability recheck required); Hubsan ACE2 (official source is a two-battery portable package, not the catalogue standard package).
- Dashboard status message: `Drones — 20-product research batch 05: 9 verified UK GBP observations added to LIVE`. All 20 reviewed UUIDs are saved in message metadata.
- LIVE after Batch 05: 4,878 evidence rows total / 4,816 active / 62 inactive; 2,343 active UK New and 2,473 active UK Used. Drones remain 541 active products; 366 without active UK New and 363 without active UK Used.



## Batch 06 — 20 products reviewed (13 November 2026)

- 17 verified GBP observations inserted and read back across 15 exact LIVE master products (15 UK New, 2 UK Used):
  - Hubsan ACE PRO+ Standard — official UK/GBP store £789.00 (stock unknown).
  - Hubsan ACE SE Standard — £389.00, out of stock; ACE SE REFINED Standard — £309.00, out of stock.
  - Hubsan BLACKHAWK 3 Package 1 — £499.00, out of stock; package explicitly includes two 5000mAh batteries.
  - Hubsan H107D+ — eBay UK £29.68, Opened – never used, listed.
  - Hubsan H122D X4 Storm — official new price £89.99, out of stock; Cash Converters used listing £63.99, in stock.
  - Hubsan H123D X4 Jet — official £175.00 (availability unknown); H216A X4 Desire Pro & HT011A — £149.00, out of stock.
  - Hubsan H501C X4 Brushless Cam — £146.16 (availability unknown); H501M X4 Air Basic Edition — £139.00 (availability unknown); H501M X4 Waypoints FPV — Elite Models £139.99, out of stock.
  - Hubsan H502E X4 Desire Cam — official £69.00 and Elite Models £79.99 (out of stock); H502T X4 Star — £65.00, out of stock.
  - Hubsan H507A — Menkind £39.97, online ordering available; H507A+ X4 Star Pro — official £99.99, out of stock.
- 5 held: H107C+ (available source was H107C, non-plus); H109 (available used source was H109S, not H109); H111D (no exact UK source); H501S X4 Air Black BNF and White BNF (available sources were RTF/with-controller, not exact BNF packages).
- Dashboard status message: `Drones — 20-product research batch 06: 17 verified UK GBP observations added to LIVE`. All 20 reviewed UUIDs are saved in metadata.
- LIVE after Batch 06: 4,895 evidence rows total / 4,833 active / 62 inactive; 2,358 active UK New and 2,475 active UK Used. Drones remain 541 active products; 352 without active UK New and 361 without active UK Used.



## Batch 07 — 20 products reviewed (13 November 2026)

- 11 verified UK GBP New observations inserted and read back across 11 exact master products: Hubsan HT55 £350; Hubsan Mini Standard £439; Hubsan Mini 7 £999; Hubsan ZINO £295; ZINO 2 £399 (out of stock); ZINO MINI PRO standard one-battery 128GB £569; ZINO MINI SE standard one-battery £349 (out of stock); ZINO PRO £303; ZINO PRO+ Standard £389 (out of stock); iFlight Defender25 O4 GPS £484 (one in stock, official Europe UK store, taxes included/no import fees for UK); iFlight Nazgul DC5 ECO 6S O3 HD V1.1 £389 (YourFPV UK, out of stock).
- 9 held: generic Zino/Standard Package, generic Zino 2/Standard Package and generic Zino Mini SE/Standard Package records held as possible duplicates of manufacturer-specific packages; ZINO MINI PRO 2025 held because source is 2BAT while catalogue package does not specify battery count; BOB57, Chimera7 Analog/O4, Defender20 and Nazgul DC5 O4 held because receiver/VTX/GPS selectors did not confirm the exact catalogue package.
- Dashboard status message: `Drones — 20-product research batch 07: 11 verified UK GBP observations added to LIVE`. Reviewed UUIDs saved in metadata.

## Batch 06 follow-up — H109 / H111D

Two additional exact UK New references were found for products held in Batch 06: Hubsan H109 X4 Brushless £79.99 and Hubsan H111D Nano Q4 FPV £59.99 from the official Hubsan UK/GBP category listing. Both were read back from LIVE; stock status was not exposed, so availability is unknown. Dashboard follow-up: `Drone research follow-up — exact Hubsan H109 and H111D UK prices added to LIVE`.

LIVE after Batch 07 and the Batch 06 follow-up: 4,908 evidence rows total / 4,846 active / 62 inactive; 2,371 active UK New and 2,475 active UK Used. Drones remain 541 active products; 339 without active UK New and 361 without active UK Used.



## Batch 08 — 20 products reviewed (13 November 2026)

- 6 exact products received 6 verified GBP observations (2 UK New, 4 UK Used):
  - Parrot ANAFI Ai — Enterprise UAV UK £4,200.00, available on back-order.
  - Parrot ANAFI Extended — LambdaTek UK £629.50 inc VAT, MPN PF728020; stock field unknown.
  - Parrot AR.Drone 2.0 — eBay UK completed Used sale £12.50 item price (excluding £0.81 Buyer Protection fee), sold 4 October 2026.
  - Parrot Bebop Skycontroller Bundle — eBay UK completed Used sale £150 item price (excluding £6.70 Buyer Protection fee), sold 14 May 2026.
  - Parrot Bebop 2 Adventurer — eBay UK completed Used sale £150 item price (excluding £5.58 Buyer Protection fee), sold 13 August 2026.
  - Parrot Hydrofoil Orak — Gumtree UK private listing £40, Brand New, Plaistow, London.
- 14 held: iFlight Nazgul Evoque F5, Evoque F7, XL5 ECO, Specter 7 and Taurus X8 (source prices are “From” or receiver/GPS options prevent exact package price); Parrot ANAFI FPV (goggles not confirmed as official Cockpitglasses 3); ANAFI UKR, UKR GOV, UKR XLR, USA GOV and USA MIL (no public UK GBP retail price); Bebop-Pro Thermal (no exact model source); Jumping Night Marshall (condition not confirmed); Jumping Race Max (only old 2020 auction).
- Dashboard status message: `Drones — 20-product research batch 08: 6 verified products added to LIVE`. All reviewed UUIDs saved in metadata.
- LIVE after Batch 08: 4,914 evidence rows total / 4,852 active / 62 inactive; 2,373 active UK New and 2,479 active UK Used. Drones remain 541 active products; 337 without active UK New and 357 without active UK Used.



## Batch 09 — 20 products reviewed (13 November 2026)

- 9 verified GBP observations inserted and read back across 7 exact LIVE products (5 UK New, 4 UK Used):
  - Parrot Airborne Cargo Travis — Menkind UK £29.97 New/in stock; eBay UK Used listing £19.12 (Guildford); Gumtree UK Used listing £35 (Newton Mearns, Glasgow).
  - Potensic ATOM 2 Expansion Kit + Remote Controller — Clifton Cameras £289 New, more than five in stock, exact MPN APM2530911.
  - Potensic ATOM 3 Standard Kit — PhotoSpecialist via Idealo £329, dated 12 October 2026.
  - Potensic ATOM 3 Standard Kit + PTD 2 Screen Remote — PriceSpy UK £339.99.
  - Potensic ATOM 3 Fly More Combo (RC PTD 2) — Amazon UK via Kelkoo £579.99, offer updated 12 November 2026.
  - Potensic D80 — Gumtree UK Used listing £65, Milton Keynes, good working condition.
  - Potensic D85 — Gumtree UK Used listing £80, Matlock, as good as new, contents itemised.
- 13 held: Parrot Mambo Fly (used listing lacked standard battery/controller and seller feedback was poor); Bebop Pro 3D Modeling (only stale 2025 forum price); Hydrofoil New Z (no exact UK listing); Jumping Night Buzz (seller location not confirmed); Potensic A20, A20 Mini, A30, A30W (no reliable exact UK retail price); ATOM SE Fly More Kit 2 (only third-party aggregator snapshot); D18 (package completeness not verified); D50 (search results conflated with Deerc D50); D60 (refurbished page lacked price/stock); D68 (available listing seller located in Ireland, excluded).
- Dashboard status message: `Drones — 20-product research batch 09: 9 verified UK GBP observations added to LIVE`. All 20 reviewed UUIDs saved in metadata.
- LIVE after Batch 09: 4,923 evidence rows total / 4,861 active / 62 inactive; 2,378 active UK New and 2,483 active UK Used. Drones remain 541 active products; 332 without active UK New and 354 without active UK Used.
