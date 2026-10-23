# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23 after batch 28

## Catalogue workflow
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and stable source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Current verified position after batch 28
See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-28.md` and `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-28.md`.

- TEST: 131 active customer-visible variants; 132 evidence rows total (129 active, 3 inactive retained for audit). Zero active customer-visible variants are missing active evidence.
- LIVE: 127 active customer-visible variants and 127 active evidence rows, all active. This includes 59 active UK completed-sale rows (`uk_used` with availability `sold`).
- LIVE integrity check after Batch 28: zero evidence integrity failures and zero active customer-visible variants missing active evidence.
- Batch 28 added Motorola Edge 70 Plus 8GB/256GB (£499 Currys); OPPO Find X10 12GB/256GB (£1,099 EE pre-order, launch expected 28 Oct); and OPPO Find X10 Pro Max 12GB/512GB (£1,499 EE pre-order, launch expected 28 Oct). The OPPO rows use `coming_soon` availability, not in-stock.
- Batch 27 added Apple iPhone Duo 256GB (£1,999), 512GB (£2,199), 1TB (£2,599), 2TB (£3,199) from the official Apple UK buy page; Samsung Galaxy A18 4G 128GB (£249) from Currys; and Motorola Edge 70 Plus 8GB/256GB (£499) from Currys. Note: the Motorola Edge 70 Plus was added in Batch 27, then batch 28 confirmed the current listing; check stable source keys to avoid duplicate evidence.
- Batch 26 resolved the final visible TEST evidence gap: OnePlus 15 5G 12GB/256GB Black SIM-free at £849, sourced from MyMobiles' October 2026 deal page which identifies OnePlus as seller. The official linked page still shows Notify me/early-bird material; availability is recorded as `listed`, not `in_stock`.
- A purported realme GT 7 Pro 512GB sold listing was rejected because its item specifics identify 256GB/12GB RAM. Another 512GB listing from a Frankfurt, Germany seller remains rejected as non-UK-local evidence.
- Batch 25 added realme GT 7 Pro 5G 12GB/512GB, opened – never used, £986.25 from a London-based UK eBay seller. The seller has 83.3% positive feedback and low listing volume; this is an unusually high asking price, not a completed sale or typical market value.
- Batch 24 added seven exact-variant UK evidence records: HMD Skyline 8/256GB £334.69 PriceSpy UK offer; Motorola Edge 70 Pro 8/256GB £499 GSMSpecs/Amazon UK price reference dated 11 Oct (secondary source, recheck checkout); moto g37 128GB £189.99 Argos; Nothing Phone (3a) Pro 256GB £342.99 excellent-refurbished UK listing; OPPO Reno13 5G 256GB £254.27 excellent-refurbished listing out of stock with 21 historical sales; realme 14 Pro+ 5G 12/512GB £745 new UK seller listing with delivery/import caveats; REDMI Note 15 Pro+ 5G 12/512GB sold UK listing with displayed £179.56 (Buyer Protection and Best Offer caveats).
- Motorola Edge 70 256GB was hidden from TEST customer visibility because exact UK 256GB SKU was not verified; retailer listings found were 512GB. It remains active and is not marked discontinued.
- Batch 21 added seven UK new-price/listing records: HONOR 600 256 GB (£599.99 HONOR UK store list price); HONOR 600 Smart 128 GB (£249.99 Argos); Xiaomi 17T 256 GB (£549 campaign price vs £649 original); Xiaomi 17T Pro 512 GB (£699 campaign price vs £849 original); HONOR Magic8 Lite 256 GB (£349.99 after-coupon); Samsung Galaxy S26+ 256 GB (£1,179 Samsung UK in-stock listing); and Samsung Galaxy A27 5G 256 GB (£209.99 current eBay listing, condition “Opened – never used”; not sealed-new or completed-sale evidence).
- Batch 22 added Samsung Galaxy S25+ 256 GB at £770 from an active sealed/boxed UK eBay business-seller listing. It is an asking price, not completed-sale evidence.
- Batch 23 added official Xiaomi UK listed prices: REDMI Note 15 6 GB/128 GB £179 and REDMI Note 15 Pro 5G 8 GB/256 GB £349. Both official product entries are marked “Coming soon”; the evidence availability is `coming_soon`, not in stock.
- Two unverified TEST seeds—Apple iPhone 18 256 GB and Nothing Phone (4b) 128 GB—were hidden from customer visibility pending official model/release confirmation. They remain active and were not marked discontinued or deleted.
- Xiaomi 17T/17T Pro campaign prices are temporary and expire 27 Oct 2026 or earlier if stock runs out. Recheck after expiry.
- Buyer Protection fees and Best Offer caveats are retained. Bundle extras and “opened – never used” condition must not be treated as ordinary used comparables. Keep UK new/RRP evidence separate from completed-sale evidence.

## Latest batch 04
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-04.md`.
- Added and promoted iPhone 17e 256 GB (£699), iPhone 17e 512 GB (£899), and Pixel 10a 128 GB (£599) with current UK new-price evidence.
- Pixel 10a 256 GB is present in TEST only, with no evidence row until exact price is verified.
- LIVE-wide evidence integrity check returned zero missing URLs, keys, product links, non-positive prices, non-GBP values or inactive evidence rows.
- No used-market evidence was added in batch 04.

## Latest batch 05
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-05.md`.
- Added/promoted iPhone 17 256 GB (£899), iPhone 17 512 GB (£1,099), and Pixel 10a 256 GB (£599).
- Retired one bad TEST evidence row for iPhone 17 256 GB: generic giffgaff error URL, unsupported £959. Marked inactive, retained for audit; active Apple UK replacement is £899.
- LIVE-wide active evidence integrity returned zero missing URLs, keys, product links, non-positive prices, non-GBP values or inactive rows.
- No used-market evidence was added in batch 05.

## Latest batch 06
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-06.md`.
- Added/promoted Pixel 11 256 GB (£879), Pixel 11 Pro 256 GB (£1,079), Pixel 11 Pro XL 256 GB (£1,279 UK RRP from a secondary source updated 14 Oct), and Pixel 11 Pro Fold 256 GB (£1,799).
- Retired invalid Pixel 11 128 GB seed and generic giffgaff error-page evidence; both inactive for audit.
- LIVE-wide evidence integrity returned zero missing URLs, keys, product links, non-positive prices or non-GBP values; all 35 evidence rows active.

## Latest batch 08
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-08.md`.
- Added six exact-variant UK completed/sold eBay records across iPhone 15 256 GB, Galaxy S23 256 GB, iPhone 14 256 GB, iPhone 15 Pro 256 GB, Galaxy S24 256 GB, and Pixel 9 256 GB in TEST and LIVE.
- TEST latest verified count: 124 total product rows (123 active), 64 evidence rows (61 active).
- LIVE changed concurrently during this pass; latest query showed 58 active products and 59 active evidence rows, including 17 active sold rows. Some additional legacy variants appeared concurrently and need a fresh inventory query before the next promotion.
- Integrity query: zero missing URLs/keys, non-positive prices, non-GBP values, or broken product links.
- Buyer protection fees are noted where included in displayed sold totals; these values are not seller proceeds or guaranteed buy-in values.

## Latest batch 07
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-07.md`.
- Added/promoted seven higher-storage Pixel 11 family variants with UK RRP references from Mobile Phones UK's Aug 2026 price table.
- TEST: 124 product rows (123 active), 58 evidence rows (56 active). LIVE: 41 active products, 42 evidence rows.
- LIVE evidence integrity returned zero missing URLs, keys, product links, non-positive prices, non-GBP values or inactive rows.
- No used-market evidence added in batch 07.

## Latest batch 09
See PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-09.md.
- Added 11 UK completed/sold evidence records for older phone variants, promoted from TEST to LIVE.
- Snapshot at that batch: TEST 124 product rows (123 active), 64 evidence rows (61 active); LIVE 58 active variants and 59 evidence rows (42 UK new/RRP, 17 UK used sold).
- Retired the invalid TEST Samsung Galaxy S26 256 GB evidence record sourced from a generic giffgaff error URL; retained inactive for audit.
- LIVE integrity returned zero missing URLs/keys, invalid prices/currencies, inactive evidence rows, or orphaned evidence.



## Latest batch 10
See CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-10.md.
- Added four UK completed/sold eBay records for iPhone 13 256 GB (£238.25), iPhone 15 Plus 128 GB (£300.25), iPhone 15 Pro Max 256 GB (£447.44), and iPhone 16 256 GB (£483.41).
- Each displayed total includes Buyer Protection; notes record these as buyer-facing totals, not seller proceeds or guaranteed buy-in prices.
- Current database after this batch: TEST 124 products (123 active), 68 evidence rows (65 active); LIVE 62 active visible variants, 63 active evidence rows including 21 used-sale rows.
- TEST has 59 visible variants without active evidence; LIVE has zero active visible variants missing active evidence.
- Integrity check returned zero failures.


## Latest batch 11
See PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-11.md.
- Added four UK completed/sold eBay records for iPhone 15 512 GB (£391.92), iPhone 16 Plus 128 GB (£417.54), iPhone 16 Pro 256 GB (£447.44), and iPhone 16 Pro Max 256 GB (£600.33).
- TEST: 124 phone product rows (123 active), 72 evidence rows (69 active); 55 visible variants still lack active evidence.
- LIVE: 66 active phone variants, 67 active evidence rows, 25 active sold rows; zero visible active variants missing evidence.
- Integrity: zero missing URLs/keys, non-positive prices, non-GBP values, or broken product links.
- eBay totals include buyer protection fees; do not interpret as seller proceeds or guaranteed buy-in values.

## Latest batch 12
See PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-12.md.
- Added five UK completed/sold eBay records for Galaxy S25 128 GB (£359.99), Galaxy S25 256 GB (£419.99), Galaxy S25 Ultra 256 GB (£513.92), Nothing Phone (3) 256 GB (£397.60), and Xiaomi 14T 256 GB (£320.75).
- TEST: 124 phone product rows (123 active), 77 evidence rows (74 active); 50 visible variants still lack active evidence.
- LIVE: 71 active phone variants, 72 active evidence rows, 30 active sold rows; zero visible active variants missing evidence.
- Integrity: zero missing URLs/keys, non-positive prices, non-GBP values, or broken product links.
- Buyer Protection is noted where included; observed totals are not seller proceeds or guaranteed buy-in values.

## Latest batch 13
See PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-13.md.
- Added four UK completed/sold eBay records for HONOR 200 256 GB (£172.03), HONOR 400 256 GB (£186.58), Motorola Razr 50 Ultra 512 GB (£229.58), and OPPO Find X9 Pro 512 GB (£690.00).
- TEST: 124 phone product rows (123 active), 81 evidence rows (78 active); 46 visible variants still lack active evidence.
- LIVE: 75 active phone variants, 76 active evidence rows, 34 active sold rows; zero visible active variants missing evidence.
- Integrity: zero missing URLs/keys, non-positive prices, non-GBP values, or broken product links.
- Buyer Protection is noted where included; observed totals are not seller proceeds or guaranteed buy-in values.

## Latest batch 14
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-14.md`.
- Added five UK completed-sale records for Pixel 10, Pixel 10 Pro, Galaxy S26, OnePlus 13 and HONOR Magic8 Pro.
- Batch-end snapshot: TEST 86 evidence rows (81 active); LIVE 80 active visible variants and 81 active evidence rows.

## Latest batch 15
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-15.md`.
- Added OPPO Find X9 512 GB, Nothing Phone (4a) 256 GB, and Galaxy A27 5G 128 GB completed-sale evidence.
- Current TEST/LIVE counts are in the Current verified position above.

## Latest batch 16
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-16.md`.
- Added UK completed-sale evidence for Pixel 10 Pro XL 256 GB (£567.70), OnePlus 12 256 GB (£336.00), Xiaomi 14T Pro 512 GB (£330.92), and Motorola Razr 70 Ultra 512 GB (£732.50).
- TEST: 93 evidence rows (90 active, 3 inactive); 34 visible variants without active evidence.
- LIVE: 87 active visible variants, 88 active evidence rows, including 46 UK used-sale rows. Integrity passed.

## Operating rules
1. Add products and evidence to TEST first.
2. Evidence must link to the exact product/storage variant and have a meaningful source URL and stable unique key.
3. Distinguish UK new list prices, promotional prices, used asking prices, and completed/sold prices. Do not combine these as equivalent evidence.
4. For current new prices, prefer manufacturer or authorised UK retailer product pages; record availability conservatively.
5. Keep discontinued models in the catalogue for used valuation, but mark lifecycle and do not treat old launch prices as current new prices.
6. Promote each validated batch to LIVE rather than accumulating a large backlog; verify LIVE counts and links after every promotion.
7. Do not bulk-copy the 95 legacy TEST phone seeds without verifying them and their evidence first.


## Latest batch 26 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-26.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-26.md`.
- Added OnePlus 15 5G 12GB/256GB Black SIM-free UK new-price reference at £849 from MyMobiles, which lists OnePlus as the seller. Source https://www.mymobiles.com/phones/oneplus/15-deals. Availability recorded as listed, not in stock, because direct checkout was not confirmed.
- Official Xiaomi autumn campaign evidence lists 17T 12GB/256GB at £549 and 17T Pro 12GB/512GB at £699 until 27 Oct 2026 or while stock lasts. Recheck after expiry; do not treat these as evergreen RRPs.
- Weaker duplicate Xiaomi corroboration rows are inactive and retained for audit.
- Verified unique active visible product IDs: TEST 128; LIVE 126. TEST evidence: 134 total / 129 active / 5 inactive. LIVE evidence: 129 total / 127 active / 2 inactive. Zero active visible variants missing active evidence; LIVE integrity failures 0.


## Latest batch 29 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-29.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-29.md`.
- Added completed-sale evidence to TEST and LIVE for HONOR 600 256GB (£379.35 buyer total, new/sealed), Samsung Galaxy Z Flip8 256GB (£749.99 buyer total, opened–never used), and iPhone 17e 256GB (£450.87 buyer total, used auction).
- All sources confirm UK seller location and exact storage variant. Buyer Protection fees are included in displayed totals where indicated; these are not seller proceeds.
- Fresh database snapshot after batch 29: TEST 128 active visible variants, 137 evidence rows (132 active, 5 inactive), 64 active UK used completed-sale rows; LIVE 126 active visible variants, 132 evidence rows (130 active, 2 inactive), 62 active UK used completed-sale rows and 3 active UK used/listed rows. Zero visible variants missing active evidence; LIVE integrity failures 0.
- These fresh distinct-product counts supersede earlier snapshots; always re-query because visibility can change between batches.


## Latest batch 30 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-30.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-30.md`.
- Added current UK new-price evidence in TEST and LIVE for iPhone 18 Pro 256GB (£1,199, EE in stock), Google Pixel 11 256GB/12GB RAM (£879, EE in stock), and Pixel 11 Pro 256GB/12GB RAM (£1,079, EE in stock).
- EE Pixel voucher offers are time-limited through 31 October 2026; prices recorded before voucher value.
- Rejected eBay listing `257792354372` as OnePlus 15 evidence because its item specifics identify OnePlus 10 Pro.
- OnePlus 15 256GB remains supported by a £849 MyMobiles price reference with availability listed, not confirmed in stock.
- Current distinct active visible variants: TEST 128; LIVE 126. TEST evidence 140 total / 135 active / 5 inactive. LIVE evidence 135 total / 133 active / 2 inactive.
- LIVE active UK used completed-sale rows: 62; used/listed rows: 3. Zero visible variants missing active evidence; zero active evidence integrity failures.
- Recheck Xiaomi 17T / 17T Pro campaign after 27 October 2026 and EE Pixel voucher after 31 October 2026.


## Latest batch 31 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-31.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-31.md`.
- Added Nothing Phone (4b) 8GB/128GB at £299 from the official Nothing UK page, promoted to TEST and LIVE.
- Added/verified a OnePlus 15 12GB/256GB UK new-price reference at £849 from MyMobiles’ October 2026 page. Availability remains `listed`, not in stock, because direct official checkout was not confirmed.
- Official Xiaomi 17T £549 and 17T Pro 512GB £699 campaign evidence remains primary through 27 October 2026 or while stock lasts. Weaker secondary Xiaomi rows were made inactive and retained for audit.
- Duplicate iPhone Duo official price rows were made inactive; Batch 27’s original official price rows remain active. Rejected OnePlus 15 listing 257792354372 because its item specifics identify OnePlus 10 Pro.
- Current database snapshot: TEST 130 active visible variants, 147 evidence rows (138 active, 9 inactive); LIVE 128 active visible variants, 142 evidence rows (136 active, 6 inactive), 62 active UK used completed-sale rows and 3 used/listed rows. No visible active variant is missing active evidence; LIVE integrity failures 0.
