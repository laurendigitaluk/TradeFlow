# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23 after batch 37

## Catalogue workflow
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and stable source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Historical snapshot after batch 28 (superseded by the Batch 37 verification)
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


## Latest batch 32 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-32.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-32.md`.
- Added OPPO Reno16 F 5G 8GB/256GB £479 and OPPO Reno16 5G 8GB/512GB £699 using official OPPO UK pricing guidance. The current OPPO UK catalogue marks both out of stock, so evidence availability is `out_of_stock`.
- Current snapshot: TEST 132 active visible variants, 149 evidence rows (140 active, 9 inactive); LIVE 130 active visible variants, 144 evidence rows (138 active, 6 inactive), 62 active UK used completed-sale rows and 3 used/listed rows. No active visible variant lacks active evidence; LIVE integrity failures 0.
- Recheck OPPO Reno16 stock before changing availability and recheck Xiaomi 17T/17T Pro campaign after 27 October 2026.


## Latest batch 33 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-33.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-33.md`.
- Added UK new-price evidence for iPhone 18 Pro 256GB (£1,199), iPhone 18 Pro Max 256GB (£1,299), iPhone Duo 256GB (£1,999), Google Pixel 11 Pro 256GB (£1,079), and Motorola Edge 70 Plus 256GB (£497 comparison price, code/checkout caveat).
- OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB price rows were made inactive because exact storage was not explicit in the summary source; both variants are hidden from customer visibility until exact-capacity evidence is found.
- TEST snapshot: 130 active customer-visible variants; 156 evidence rows (145 active, 11 inactive); zero visible variants missing active evidence; zero integrity failures.
- LIVE snapshot: 128 active customer-visible variants; 151 evidence rows (143 active, 8 inactive); 62 active UK used completed-sale rows and 3 used/listed rows; zero visible variants missing active evidence; zero integrity failures.
- Recheck Xiaomi 17T / 17T Pro official campaign prices (£549 / £699) after 27 October 2026. OnePlus 15 £849 remains a price reference with availability unconfirmed.


## Latest batch 34 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-34.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-34.md`.
- Added official Apple UK price evidence for iPhone 18 Pro 512GB (£1,399), iPhone 18 Pro Max 512GB (£1,499), and iPhone Duo 512GB (£2,199), to TEST and LIVE.
- TEST: 130 active customer-visible variants; 159 evidence rows (148 active, 11 inactive); zero visible variants missing active evidence; zero integrity failures.
- LIVE: 128 active customer-visible variants; 154 evidence rows (146 active, 8 inactive); 62 UK used completed-sale rows and 3 used/listed rows; zero visible variants missing active evidence; zero integrity failures.
- OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB remain hidden pending exact storage evidence. Recheck Xiaomi 17T / 17T Pro campaign after 27 October 2026; OnePlus 15 £849 remains listed/uncertain for availability.


## Latest batch 35 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-35.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-35.md`.
- Added six exact official Apple UK new-price records: iPhone 18 Pro 1TB (£1,799) and 2TB (£2,399); iPhone 18 Pro Max 1TB (£1,899) and 2TB (£2,499); iPhone Duo 1TB (£2,599) and 2TB (£3,199).
- TEST: 130 active customer-visible variants; 165 evidence rows (154 active, 11 inactive); zero visible variants missing active evidence; zero integrity failures.
- LIVE: 128 active customer-visible variants; 160 evidence rows (152 active, 8 inactive); 62 UK used completed-sale rows and 3 used/listed rows; zero visible variants missing active evidence; zero integrity failures.
- OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB remain hidden pending exact capacity verification. Recheck Xiaomi 17T / 17T Pro after 27 October 2026; OnePlus 15 availability remains unconfirmed.


## Latest batch 36 — 23 October 2026
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-36.md` and `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-36.md`.
- Added official Google Store UK prices for Pixel 11 256GB (£879), Pixel 11 512GB (£999), and Pixel 11 Pro 512GB (£1,199), all exact storage/RAM variants, to TEST and LIVE.
- TEST: 130 active customer-visible variants; 168 evidence rows (157 active, 11 inactive); zero visible variants missing active evidence; zero integrity failures.
- LIVE: 128 active customer-visible variants; 163 evidence rows (155 active, 8 inactive); 62 UK used completed-sale rows and 3 used/listed rows; zero visible variants missing active evidence; zero integrity failures.
- OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB remain hidden pending exact-capacity evidence. Recheck Xiaomi 17T / 17T Pro campaign after 27 October; OnePlus 15 stock remains unconfirmed.


## Latest verified position — Batch 37 (23 October 2026)
See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-37.md` and `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-37.md`.

Batch 37 added four exact UK evidence records in TEST then LIVE: Samsung Galaxy S25 128GB used sold £339.99 (eBay UK, 19 Oct; Buyer Protection included); Samsung Galaxy A37 5G 128GB/6GB RAM listed new £399 (Argos, postcode-dependent stock); Apple iPhone 16 128GB used sold £369.03 (eBay UK, 3 Oct; £14.03 Buyer Protection included); Samsung Galaxy S24 128GB used sold £271.19 (eBay UK, 17 Sep; £11.19 Buyer Protection included). eBay displayed prices are buyer-facing totals, not seller proceeds.

Current verified snapshot: TEST 130 active customer-visible variants, 172 evidence rows (161 active, 11 inactive), 67 active UK used completed-sale rows; LIVE 128 active customer-visible variants, 167 evidence rows (159 active, 8 inactive), 65 active UK used completed-sale rows. Both environments have zero visible active variants missing active evidence, zero active evidence integrity failures, and zero duplicate active source keys. Continue TEST-first validation and regular LIVE promotion. Recheck Xiaomi 17T / 17T Pro after 27 Oct and OPPO Find X10 pre-order after 28 Oct 2026.


## Mobile phone catalogue evidence continuity — Batch 38 (24 October 2026)
Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-38.md`; batch memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-38.md`.

Three used completed-sale records were verified in TEST and promoted to LIVE: Galaxy S24 128GB Onyx Black £243.31 displayed total (includes £8.41 Buyer Protection), Pixel 9 128GB Obsidian unlocked £279.58 (includes £9.58 Buyer Protection), and iPhone 16 128GB Teal unlocked £386.83 (includes £11.83 Buyer Protection). These are buyer-facing totals, not seller proceeds. All source keys were checked absent before insert and the exact active product-linked rows were read back in both environments.

Current phone-category snapshot: TEST 130 active visible variants, 175 evidence rows (164 active, 11 inactive), 70 active UK used completed-sale rows. LIVE 128 active visible variants, 170 evidence rows (162 active, 8 inactive), 68 active UK used completed-sale rows. Both: zero visible active variants missing active evidence; zero active missing URLs/keys, non-positive prices, non-GBP values, or duplicate active source keys.

The database safety-check blocks observed earlier were intermittent tool-layer blocks, not returned PostgreSQL errors. A separate `ON CONFLICT (source_record_key)` attempt did return a genuine PostgreSQL error because no unique/exclusion constraint exists on that field; subsequent inserts were plain INSERTs after checking keys absent. Preserve the Batch 37 historical observations for eBay items 377500378163 and 800749991087; their pages now show different totals, which requires investigation rather than silent overwriting.


## Mobile phone catalogue evidence continuity — Batch 39 (24 October 2026)
Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-39.md`; batch memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-39.md`.

Three used completed-sale records were added TEST-first then promoted to LIVE: Galaxy S24 128GB £206.99 displayed total (includes Buyer Protection; fee amount not captured), Pixel 9 128GB £269.25 (listing notes chipped paint; do not call pristine), and iPhone 16 128GB White £412.24 displayed total (includes £12.25 Buyer Protection; Best Offer accepted). Source keys were absent before insertion and exact active rows were read back in both environments.

Current phone-category snapshot: TEST 130 active visible variants, 178 evidence rows (167 active, 11 inactive), 73 active UK used completed-sale rows. LIVE 128 active visible variants, 173 evidence rows (165 active, 8 inactive), 71 active UK used completed-sale rows. Both: zero active visible variants missing active evidence; zero active evidence missing URLs/keys, non-positive prices, non-GBP currency, or duplicate active source keys.

Preserve Batch 37 historical observations for eBay items 377500378163 and 800749991087; current page totals differ and require investigation rather than silent overwrite. Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden pending exact-capacity evidence. Recheck Xiaomi campaign prices after 27 Oct and OPPO launch after 28 Oct.


## Mobile phone catalogue evidence continuity — Batch 40 (24 October 2026)
Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-40.md`; batch memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-40.md`.

Three more completed-sale rows were added and verified in TEST and LIVE: Galaxy S24 128GB £237.75 (includes £8.23 Buyer Protection), iPhone 16 128GB White £432.48 (includes £12.58 Buyer Protection; Best Offer accepted), and Pixel 9 256GB Porcelain £292.20 (includes £9.99 Buyer Protection). Exact product variants and active status were read back from both databases.

Current phone-category snapshot: TEST 130 active visible variants, 181 evidence rows (170 active, 11 inactive), 76 active UK used completed-sale rows. LIVE 128 active visible variants, 176 evidence rows (168 active, 8 inactive), 74 active UK used completed-sale rows. Both environments have zero visible active variants missing active evidence; zero active rows missing URLs/keys, non-positive prices, non-GBP currency, or duplicate active source keys. All fee-inclusive prices are buyer-facing totals, not seller proceeds. Preserve older observations if listing totals later change.


## Batch 41 — 24 October 2026
Added three further completed UK eBay sale observations TEST-first, then promoted and read-back verified in LIVE:
- Samsung Galaxy S24 128GB Marble Grey, unlocked, dual SIM: £249.99, sold 17 Sep 2026, https://www.ebay.co.uk/itm/800671014611. The source snippet did not separately identify a Buyer Protection fee.
- Google Pixel 9 128GB Porcelain, unlocked: £315.67 including £10.67 Buyer Protection, sold 5 Oct 2026; Best Offer accepted, https://www.ebay.co.uk/itm/128115577878.
- Apple iPhone 16 128GB Ultramarine: £381.75 including £11.75 Buyer Protection, sold 16 Sep 2026; Best Offer accepted, https://www.ebay.co.uk/itm/318875321713.
Stable keys: `mobile-used-sold-galaxy-s24-128gb-ebay-800671014611-20260917`, `mobile-used-sold-pixel9-128gb-ebay-128115577878-20261005`, `mobile-used-sold-iphone16-128gb-ebay-318875321713-20260916`.
Post-batch counts: TEST 130 active visible phone variants, 173 active phone evidence rows, 79 active UK used completed-sale observations. LIVE 128 active visible variants, 171 active phone evidence rows, 77 active UK used completed-sale observations. Both have zero visible active phone variants missing active evidence, zero phone evidence integrity failures, and zero duplicate active source keys. Whole-table integrity scan surfaces unrelated overseas USD evidence (TEST 1 row, LIVE 2 rows); do not conflate that with phone catalogue health or change those records as part of this batch.
Continue preserving historical observations when current listings show changed prices; buyer-facing totals including Buyer Protection are not seller proceeds. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-41.md`.


## Batch 41 — 24 October 2026
Added three further completed UK eBay sale observations TEST-first, then promoted and read-back verified in LIVE:
- Samsung Galaxy S24 128GB Marble Grey, unlocked, dual SIM: £249.99, sold 17 Sep 2026, https://www.ebay.co.uk/itm/800671014611. The source snippet did not separately identify a Buyer Protection fee.
- Google Pixel 9 128GB Porcelain, unlocked: £315.67 including £10.67 Buyer Protection, sold 5 Oct 2026; Best Offer accepted, https://www.ebay.co.uk/itm/128115577878.
- Apple iPhone 16 128GB Ultramarine: £381.75 including £11.75 Buyer Protection, sold 16 Sep 2026; Best Offer accepted, https://www.ebay.co.uk/itm/318875321713.
Stable keys: `mobile-used-sold-galaxy-s24-128gb-ebay-800671014611-20260917`, `mobile-used-sold-pixel9-128gb-ebay-128115577878-20261005`, `mobile-used-sold-iphone16-128gb-ebay-318875321713-20260916`.
Post-batch counts: TEST 130 active visible phone variants, 173 active phone evidence rows, 79 active UK used completed-sale observations. LIVE 128 active visible variants, 171 active phone evidence rows, 77 active UK used completed-sale observations. Both have zero visible active phone variants missing active evidence, zero phone evidence integrity failures, and zero duplicate active source keys. Whole-table integrity scan surfaces unrelated overseas USD evidence (TEST 1 row, LIVE 2 rows); do not conflate that with phone catalogue health or change those records as part of this batch.
Continue preserving historical observations when current listings show changed prices; buyer-facing totals including Buyer Protection are not seller proceeds. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-41.md`.


## Batch 42 and Batch 43 refresh — 24 October 2026
Batch 42's three records were independently verified active in both TEST and LIVE. Batch 43 then added three further completed-sale observations in TEST and promoted them to LIVE:
- iPhone 16 128GB Teal, eBay 287579080965, £429.70 including £12.54 Buyer Protection; relisting caveat retained. Key `mobile-used-sold-iphone16-128gb-ebay-287579080965-20260914`.
- iPhone 16 128GB Ultramarine, eBay 366668186600, £440.00; listing title says “NO FLAWS” while description mentions refurbishment/moderate wear. Fee not separately captured. Key `mobile-used-sold-iphone16-128gb-ebay-366668186600-20260914`.
- Galaxy S24 128GB Purple, eBay 198530912410, £269.25 including £9.25 Buyer Protection; Best Offer accepted. Key `mobile-used-sold-galaxy-s24-128gb-ebay-198530912410-20260801`.

Fresh verified counts after Batch 43: TEST 179 active phone evidence rows and 85 active UK used completed-sale rows; LIVE 177 active phone evidence rows and 83 active UK used completed-sale rows. Both have zero phone-scoped URL/key/positive GBP price/currency integrity failures and zero duplicate active source keys. Continue to treat Buyer Protection amounts as buyer-facing totals, preserve relisting/history, and retain condition contradictions as caveats.


## Batch 44 — 24 October 2026
Added and promoted three completed-sale observations: Pixel 9 128GB Obsidian £347.76 including £11.19 Buyer Protection, Best Offer accepted (eBay 298415131329); iPhone 16 128GB Ultramarine £374.67 including £11.63 Buyer Protection, 90% battery health (eBay 327147326675); Galaxy S24 128GB Marble Grey £368.00 (eBay 376877291140; Buyer Protection fee not separately captured). Full notes and stable keys are in `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-44.md`.

Fresh verified post-batch counts: TEST 182 active phone evidence rows / 88 active UK used completed-sale rows; LIVE 180 / 86. Both environments have zero phone-scoped integrity failures and zero duplicate active source keys. Preserve buyer-facing fee distinctions and historical evidence.


## Batch 45 — 24 October 2026
Added and promoted three UK eBay completed-sale observations: iPhone 15 128GB Light Blue £327.83 including £10.87 Buyer Protection (item 168659039520, 7 bids); iPhone 15 128GB Black unlocked, described as excellent with good battery health, £330.92 including £10.92 Buyer Protection (item 377366853347); Galaxy S24 256GB Black £268.15 including £9.21 Buyer Protection (item 128000546242; Best Offer acceptance not confirmed). See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-45.md` for stable keys.

Fresh verified counts: TEST 185 active phone evidence rows / 91 active UK used completed-sale rows; LIVE 183 / 89. Both have zero phone-scoped integrity failures and zero duplicate active source keys.


## Batch 46 — 24 October 2026
Added and promoted three completed-sale observations: iPhone 15 128GB Black £253.75 including £8.75 Buyer Protection, Best Offer accepted (item 800710234384); iPhone 15 128GB Black £258.92 including £8.92 Buyer Protection, Best Offer accepted (item 377436509526); Galaxy S24 256GB Grey unlocked £309.55 including £10.55 Buyer Protection, Best Offer accepted (item 336549983134). See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-46.md` for stable keys.

Fresh verified counts: TEST 188 active phone evidence rows / 94 active UK used completed-sale rows; LIVE 186 / 92. Both have zero phone-scoped integrity failures and zero duplicate active source keys.


## Batch 47 — 24 October 2026
Added and promoted three completed-sale observations: iPhone 15 128GB Black, 93% battery health, £322.84 including £10.78 Buyer Protection (item 377552504716; Best Offer acceptance not confirmed); iPhone 15 128GB unlocked, title states 100% battery health/excellent, £291.90 including £11.90 Buyer Protection (item 366731563762); Galaxy S24 128GB Purple unlocked dual SIM, £258.92 including £8.92 Buyer Protection (item 227389511234). See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-47.md` for stable keys.

Fresh verified counts: TEST 191 active phone evidence rows / 97 active UK used completed-sale rows; LIVE 189 / 95. Both have zero phone-scoped integrity failures and zero duplicate active source keys.


## Batch 48 — 24 October 2026
Added and promoted three UK eBay completed-sale observations: iPhone 16 128GB White, cracked back/damaged, £295.08 including £10.08 Buyer Protection; Best Offer accepted (item 398370939162); Galaxy S24 256GB White £186.58 including £6.58 Buyer Protection (item 366534598634; retain as a low-price observation and review condition before using as typical benchmark); iPhone 15 128GB White A3090 £248.58 including £8.58 Buyer Protection (item 178513141590; accepted-offer status not confirmed). See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-48.md` for stable keys.

Fresh verified counts: TEST 194 active phone evidence rows / 100 active UK used completed-sale rows; LIVE 192 / 98. Both have zero phone-scoped integrity failures and zero duplicate active source keys.

Added three fresh UK eBay used-phone completed-sale observations, checked the stable source keys absent in TEST and LIVE before insertion, inserted to TEST first, then promoted the same observations to LIVE.

1. Apple iPhone 15 128GB Blue, factory unlocked — £269.25 displayed buyer total, including £9.25 Buyer Protection; sold 23 Sep 2026. The item price/seller proceeds are not separately captured. https://www.ebay.co.uk/itm/398420637687. Key: `mobile-used-sold-iphone15-128gb-ebay-398420637687-20260923`.
2. Apple iPhone 15 128GB Black — £265.99 displayed buyer total, including £10.99 Buyer Protection; Best Offer accepted; sold 27 Sep 2026. The accepted item price/seller proceeds are not separately shown. https://www.ebay.co.uk/itm/188991253809. Key: `mobile-used-sold-iphone15-128gb-ebay-188991253809-20260927`.
3. Apple iPhone 16 128GB Green, locked to Sky Mobile — £391.92 displayed buyer total, including £11.92 Buyer Protection; sold 22 Aug 2026. Keep the network-lock caveat; this is not directly comparable with unlocked devices. https://www.ebay.co.uk/itm/800546931991. Key: `mobile-used-sold-iphone16-128gb-ebay-800546931991-20260822`.

Post-batch integrity checks (phone category joined through each environment's own category ID):
- TEST: 197 active phone evidence rows; 103 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.
- LIVE: 195 active phone evidence rows; 101 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.

The integrity check intentionally tests URL presence/HTTP format rather than restricting all existing evidence to eBay URLs, since the phone catalogue includes other valid source types. Preserve Buyer Protection totals as buyer-facing totals, not seller proceeds. Continue TEST-first and promote validated evidence promptly.

## Batch 50 — 24 October 2026

Added three fresh UK eBay iPhone 15 128GB completed-sale observations. Stable keys were checked absent in both environments before insertion; records were inserted into TEST first and then promoted to LIVE.

1. iPhone 15 128GB White, unlocked — £217.58 displayed buyer total including £7.58 Buyer Protection; sold 11 Sep 2026. Listing title says “Read Description”; underlying caveat is not fully established in the captured extract, so retain this caveat-bearing observation and do not assume typical working condition. https://www.ebay.co.uk/itm/278364248917. Key: `mobile-used-sold-iphone15-128gb-ebay-278364248917-20260911`.
2. iPhone 15 128GB Black with box — £258.92 displayed buyer total including £8.92 Buyer Protection; Best Offer accepted; sold 22 Sep 2026. Listing says seller relisted this item or one like it, so preserve this observation separately from other records. https://www.ebay.co.uk/itm/318900425831. Key: `mobile-used-sold-iphone15-128gb-ebay-318900425831-20260922`.
3. iPhone 15 128GB White — £207.25 displayed buyer total including £7.25 Buyer Protection; Best Offer accepted; sold 2 Aug 2026. Explicitly marked “For parts or not working”; do not use as a typical working-phone benchmark. https://www.ebay.co.uk/itm/366574722022. Key: `mobile-used-sold-iphone15-128gb-ebay-366574722022-20260802`.

Post-batch checks using each environment's own phone-category ID:
- TEST: 200 active phone evidence rows; 106 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.
- LIVE: 198 active phone evidence rows; 104 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.

Buyer Protection totals are buyer-facing totals, not seller proceeds. Keep “Read Description”, relisting and non-working caveats explicit. Continue TEST-first, promote validated evidence promptly, and avoid overwriting historical listing observations.


## Mobile phone catalogue — Batch 51 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-51.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-51.md`.
- Added two UK eBay iPhone 15 128GB completed-sale observations in TEST, then LIVE: unlocked Black sold 15 Aug (£281.50 displayed total incl. £11.50 Buyer Protection; Best Offer accepted; grade/battery health unconfirmed); Black parts-only sold 5 Oct (£49.56 displayed total incl. £2.16 Buyer Protection; explicitly non-working, exclude from typical working benchmarks).
- TEST: 202 active phone evidence rows / 108 active UK used completed-sale rows. LIVE: 200 / 106. Both environments have zero basic phone-scoped URL/key/positive GBP price/currency failures and zero duplicate active source-key groups; both Batch 51 keys are active.
- Buyer Protection totals are buyer-facing, not seller proceeds. Keep condition and Best Offer caveats; continue TEST-first promotion to LIVE promptly.


## Mobile phone catalogue — Batch 52 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-52.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-52.md`.
- Added two UK eBay completed-sale observations to TEST then LIVE: iPhone 15 128GB Pink unlocked (£309.99 displayed, sold 19 Oct; boxed, very good condition, 88% battery health; Best Offer acceptance unconfirmed); Galaxy S24 128GB with faulty fingerprint sensor (£110 displayed including Buyer Protection, sold 29 Aug; explicitly For parts or not working, exclude from typical working-phone benchmarks).
- TEST: 204 active phone evidence / 110 active UK used sold. LIVE: 202 / 108. Both have zero basic phone-scoped integrity failures and zero duplicate active source-key groups; both Batch 52 keys active.
- Preserve condition and offer caveats. Buyer-facing totals are not necessarily seller proceeds. Continue TEST-first promotion to LIVE promptly.


## Mobile phone catalogue — Batch 53 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-53.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-53.md`.
- Added two Pixel 9 128GB UK eBay completed-sale records to TEST then LIVE: Obsidian Black unlocked £299.99 (15 Jun; Best Offer acceptance/fee breakdown unconfirmed) and Obsidian unlocked £269.95 (24 Jul; listing title states 99% battery health and very good condition; Best Offer acceptance/fee unconfirmed).
- Reconciled existing Galaxy S24 128GB Onyx Black sale £237.75 incl £8.23 Buyer Protection (item 257702271643; six bids); it was already active in TEST and LIVE and was not duplicated.
- TEST: 206 active phone evidence / 112 active UK used sold. LIVE: 204 / 110. Zero basic phone-scoped integrity failures and zero duplicate active source-key groups in both; all three keys active.
- A LIVE unique-key conflict revealed the Galaxy row already existed. Queried and confirmed it; future preflight must check stable source keys globally, not just URL/category filters.


## Mobile phone catalogue — Batch 54 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-54.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-54.md`.
- Added two Pixel 9 128GB Porcelain UK eBay completed-sale observations to TEST then LIVE: ordinary Used £291.89 on 24 May (includes £11.90 Buyer Protection; Best Offer accepted; postage separate) and Opened - never used £349.99 on 14 August (Buyer Protection fee not captured; keep separate from used benchmarks).
- TEST: 208 active phone evidence / 114 active UK used sold. LIVE: 206 / 112. Both new stable keys read back active in both environments.
- A search result for item 267795640822 was rejected as a phone case and not inserted. Continue global source-key preflight, preserve Buyer Protection distinctions, and keep condition classes separate.


## Mobile phone catalogue — Batch 55 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-55.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-55.md`.
- Added four iPhone 14 128GB observations (£176.25, £199.99, £207.25 with 77% battery, £181.42 with 78% battery) and three Pixel 8 128GB observations (£165.92 Obsidian, £196.92 Hazel near-mint, £218.48 running GrapheneOS). Buyer Protection included in displayed totals; keep battery/custom-OS caveats.
- A separate iPhone 14 sale, item 800739946361, was already present in TEST and LIVE and was not duplicated. Galaxy A15/A16 candidates deferred because no corresponding master products exist yet.
- TEST: 215 active phone evidence / 121 active UK used sold. LIVE: 213 / 119. Zero basic integrity failures and zero duplicate active source-key groups in both. All seven new keys verified active in both.


## Mobile phone catalogue — Batch 56 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-56.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-56.md`.
- Resolved the previously unverified LIVE status for iPhone 14 128GB eBay item 366661027705: £188.66, active in both TEST and LIVE.
- Added two Pixel 8 128GB UK eBay sales, item 267790609007 at £159.95 (Buyer Protection included; fee detail not captured) and item 188937928681 at £179.99 (Good cosmetic condition, no accessories). Both new Pixel rows were read-after-write verified active in TEST and LIVE.
- iPhone 16 128GB candidates 366694404412 and 318875321713 were already present in both environments and were not duplicated.
- TEST: 218 active phone evidence / 124 active UK used sold. LIVE: 216 / 122. Duplicate active source-key groups: zero in both. A two-row difference remains between environments.
- A further multi-row insert was blocked; those additional candidates were not counted as inserted. Continue global source-key/URL preflight, TEST-first, then LIVE with read-after-write verification.


## Mobile phone catalogue — Batch 57 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-57.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-57.md`.
- Added iPhone 15 128GB Black with 82% battery health at displayed £238.25 (eBay item 407192517582) and Galaxy S22 128GB at displayed £80.00 (item 398437617494; Best Offer accepted, accepted seller proceeds not independently confirmed). Both were preflighted, inserted TEST-first, and read-back verified active in TEST and LIVE.
- Several other iPhone 15 candidates were already present in both environments and were not duplicated. Preserve battery and Buyer Protection caveats; treat the low Galaxy S22 observation as a potential outlier pending further details.
- TEST: 220 active phone evidence / 126 active UK used sold. LIVE: 218 / 124. Full duplicate-key aggregate audit was blocked this run, but new URLs/keys had clean preflight. Two-row environment difference remains.


## Mobile phone catalogue — Batch 58 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-58.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-58.md`.
- Added iPhone 15 Pro 128GB Natural Titanium, immaculate with original box, eBay item 227530529279, sold 21 September 2026. Displayed buyer-facing price £402.08 includes £12.08 Buyer Protection. Exact URL/key preflighted; inserted TEST-first then LIVE and read-after-write verified active in both.
- iPhone 15 Plus 128GB Blue item 800655157429 was already active in both and not duplicated.
- TEST: 221 active phone evidence; LIVE: 219. Last confirmed UK used/sold counts remain TEST 126 and LIVE 124 because recount was blocked. Full duplicate-key aggregate audit was not completed; two-row environment difference remains. Continue global URL/key preflight, TEST-first, then LIVE, with read-after-write verification.


## Mobile phone catalogue — Batch 59 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-59.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-59.md`.
- Added iPhone 15 Pro 128GB Black, eBay item 206515412317, sold 1 September 2026, displayed £302.94 including £10.34 Buyer Protection. Seller proceeds are not independently confirmed. TEST-first then LIVE; exact URL/key preflight and post-write read-back confirmed active in both.
- The iPhone 15 Plus Blue item 800655157429 was already present in both environments and was not duplicated.
- TEST: 222 active phone evidence; LIVE: 220. Last confirmed active UK used/sold counts remain TEST 126 and LIVE 124; not refreshed in this batch. Full duplicate-key aggregate audit remains outstanding and the two-row environment difference persists.


## Mobile phone catalogue — Batch 60 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-60.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-60.md`.
- Added working/fair-condition iPhone 15 Pro 128GB Black Titanium, item 206070231627, displayed £379.99 including Buyer Protection; 90% battery health, visible wear/scratches, charger included. Separate read-back confirmed active in both.
- Added separate parts/repair iPhone 15 Pro 128GB Black Titanium, item 206112400829, displayed £199.99 including Buyer Protection; shattered rear glass and faulty non-genuine replacement screen. TEST read-back succeeded; LIVE insert response confirmed row, but separate LIVE read-back was blocked by a tool safety check.
- TEST 224 active phone evidence; LIVE 222. Last confirmed UK used/sold subtotals remain TEST 126 and LIVE 124, not refreshed. Full duplicate-key aggregate audit remains outstanding; two-row environment difference persists.


## Mobile phone catalogue count refresh — 24 October 2026
After Batch 60, counts were refreshed: TEST 224 active phone evidence and 130 active rows with `evidence_type='uk_used'` and `availability='sold'`; LIVE 222 and 128 respectively. The latter count includes the explicitly labelled parts/repair observation, so it is not working-only. The two-row difference remains. Full aggregate duplicate-key audit is still outstanding.

Stable-key aggregate audit refreshed on 24 October 2026: zero duplicate active non-null source-record-key groups across `shared_market_evidence` in TEST and LIVE. URL uniqueness was not used as a global criterion because category/product pages may validly support multiple products.


## Mobile phone catalogue — Batch 61 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-61.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-61.md`.
- Added iPhone 15 Pro 128GB Black Titanium, eBay item 900018786339, sold 19 October 2026, displayed £404.50 including £14.50 Buyer Protection. Listing title says mint, 100% battery health, no charger; seller proceeds not independently confirmed. URL/key preflight clean, TEST-first then LIVE, read-back verified active in both.
- Pixel 9 128GB Obsidian item 820179580133 was already present in both and was not duplicated.
- TEST 225 active phone evidence; LIVE 223. Last refreshed active `uk_used` + `sold` counts remain TEST 130 / LIVE 128.


## Mobile phone catalogue — Batch 62 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-62.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-62.md`.
- Added Google Pixel 9 128GB Obsidian, item 147349812276, sold 28 June 2026, displayed £243.42 including £8.42 Buyer Protection. Listing title describes acceptable condition, 99% battery health and warranty to 27 November 2027. URL/key preflight, TEST-first insert, LIVE insert and read-back verification succeeded.
- TEST 226 active phone evidence; LIVE 224. Last refreshed active `uk_used` + `sold` counts remain TEST 130 / LIVE 128.


## Mobile phone catalogue — Batch 63 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-63.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-63.md`.
- Added Google Pixel 9 128GB GrapheneOS UK eBay sale item 267700928563, sold 15 July 2026, displayed £299.00. B-condition cosmetic marks/scratches; custom OS must remain distinct from stock Android comparisons. Buyer Protection and seller net proceeds were not confirmed.
- URL/key preflight, insertion, and stable-key read-back confirmed active in both TEST and LIVE.
- TEST 227 active phone evidence / 133 active `uk_used` + `sold`; LIVE 225 / 131. Parts/repair observations are included in the latter subtotal. Two-row difference remains.


## Mobile phone catalogue — Batch 64 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-64.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-64.md`.
- Added Google Pixel 9 128GB Obsidian, eBay item 407029495464, sold 29 June 2026 at displayed £272.00. Listing says unlocked and “Great” condition. Seller is London-based, but listing showed international postage, so this is UK eBay seller evidence rather than confirmed UK-destination evidence. Buyer Protection and net proceeds unconfirmed.
- Exact URL/key preflight, insertion, and stable-key read-back verified active in TEST and LIVE.
- TEST 228 active phone evidence / 134 active `uk_used` + `sold`; LIVE 226 / 132. Subtotals include parts/repair evidence. Two-row environment difference remains.


## Mobile phone catalogue — Batch 65 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-65.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-65.md`.
- Added iPhone 15 128GB Black parts/repair, item 267734454669, displayed £192.00 incl Buyer Protection, sold 26 July 2026; and iPhone 15 128GB Blue parts/repair, item 267749501196, displayed £157.00 incl Buyer Protection, sold 11 August 2026. Both explicitly classified For parts or not working. TEST-first then LIVE; both read-back verified active in both environments.
- Samsung Galaxy S24 128GB Onyx Black item 257702271643 was already present in both and not duplicated.
- Counts: TEST 230 active phone evidence / 136 active uk_used + sold; LIVE 228 / 134. Three intervening Pixel 9 rows plus these two new rows explain the five-row increase per environment since Batch 61. Two-row environment difference remains.


## Mobile phone catalogue — Batch 66 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-66.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-66.md`.
- Added iPhone 15 Pro 128GB Blue Titanium, eBay item 298501695479, sold 23 July 2026. Displayed £360.72 includes £11.41 Buyer Protection; listing says fully working, factory reset, original box included but accessories missing, seven bids. Seller net proceeds unconfirmed.
- Exact URL/key preflight was clear; TEST-first then LIVE; both active rows read-back verified.
- Counts: TEST 231 active phone evidence / 137 active uk_used + sold; LIVE 229 / 135. Used/sold includes parts/repair rows. Two-row environment difference persists.


## Mobile phone catalogue — Batch 68 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-68.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-68.md`.
- Added iPhone 15 Pro Max 256GB Natural Titanium, eBay item 128012606222, sold 8 August 2026, three bids. Displayed £399.88 includes £14.29 Buyer Protection. Listing title says Excellent condition; eBay condition field says Used. Seller proceeds unconfirmed.
- URL/key preflight clear; inserted TEST-first then LIVE and read-back verified in both.
- Counts: TEST 233 active phone evidence / 139 active uk_used + sold; LIVE 231 / 137. Used/sold includes parts/repair rows. Two-row environment difference persists.


## Mobile phone catalogue — Batch 69 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-69.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-69.md`.
- Added iPhone 15 Pro Max 256GB Grey with retail box, item 298621751352, sold 3 Sep at displayed £444.64 including £12.78 Buyer Protection; and Silver item 327278174330, sold 1 Aug at £439.66 including £12.70 Buyer Protection. Silver listing notes the seller relisted this item or one like it, so it may not represent a unique device. Seller proceeds unconfirmed.
- Both exact URLs/keys were preflighted, inserted TEST-first then LIVE, and read-back verified in both.
- Counts: TEST 235 active phone evidence / 141 active uk_used + sold; LIVE 233 / 139. Two-row difference persists.


## Mobile phone catalogue — Batch 70 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-70.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-70.md`.
- Added iPhone 15 Pro Max 256GB unlocked, eBay item 298539408905, sold 4 Aug 2026, two bids, displayed £463.08 including £13.08 Buyer Protection. Seller proceeds unconfirmed; no further condition details inferred.
- URL/key preflight clear; TEST-first then LIVE, with read-back verified in both.
- Counts: TEST 236 active phone evidence / 142 active uk_used + sold; LIVE 234 / 140. Two-row environment difference persists.


## Mobile phone catalogue — Batch 71 (24 October 2026)
See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-71.md` and `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-71.md`.
- Added Apple iPhone 16 Pro 256GB Desert Titanium unlocked, eBay item 820212891404, sold 8 Oct 2026. Displayed buyer-facing total £567.85 including £17.85 Buyer Protection; Best Offer was enabled and seller proceeds are unconfirmed.
- TEST evidence 35d17e45-0a47-43d1-b6ed-ce13ed58579a and LIVE evidence c0249903-0bdb-493d-a989-207fa2a6be57; both exact read-backs verified.
- Counts: TEST 237 active phone evidence / 143 active uk_used + sold; LIVE 235 / 141. Two-row difference persists. Zero duplicate active non-null stable-key groups in both environments.
- Previously recorded iPhone 16 128GB items and iPhone 16 Pro Black item were not duplicated. Historical price observation was preserved when current page display differed.


## Mobile phone catalogue — Batch 72 (25 October 2026)
Added iPhone 16 Pro Max 256GB Black UK eBay completed sale, item 128132786202, sold 19 October 2026. Displayed buyer-facing total £527.16 including £14.13 Buyer Protection; listing disclosed that the back had been replaced, and seller proceeds are unconfirmed. TEST evidence c58bffec-0820-4548-869c-93356aa261d2 and LIVE evidence 5df1e96b-f62f-410d-9bdd-5ad82e3bc4aa were inserted TEST-first and both read-backs verified. Exact URL/key preflight was clear in both environments. Prior baseline was TEST 237/143 and LIVE 235/141 (active phone evidence / active uk_used + sold); derived post-insert totals are TEST 238/144 and LIVE 236/142, pending full aggregate recheck. Broad duplicate-key audit remains outstanding because the query was blocked. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-72.md`.


## Mobile phone catalogue — Batch 73 (25 October 2026)
Added three Samsung Galaxy S25 UK eBay used/sold observations to TEST and LIVE after clean URL/key preflight and exact active master matching. Items: 158245363724 (128GB Grey, £345 displayed including Buyer Protection; 100% battery health stated), 206384194701 (256GB, £389.99 displayed; Best Offer accepted, accepted amount unconfirmed; 100% battery health stated), and 128101722692 (128GB, £347.18 including £11.18 Buyer Protection; Best Offer accepted). TEST inserts/read-backs preceded LIVE; all six records were verified. Direct Mobile Phones category counts: TEST 241 active evidence / 147 active uk_used+sold; LIVE 239 / 145. Two-row difference persists. Global duplicate-key aggregation remains outstanding. Two Galaxy S24 Ultra candidates were skipped because exact active master variants were absent. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-73.md`.


## Mobile phone catalogue — Batch 74 (25 October 2026)
Added Google Pixel 10 Pro 256GB Porcelain eBay item 336731607825, sold 19 Aug 2026. Displayed £498.67 including £13.67 Buyer Protection; seller proceeds unconfirmed. TEST evidence 68ff1138-bf1d-4895-9494-c8a498555cb4 and LIVE evidence 8b3fe4b5-a40f-4171-b4fe-d8558ca5b24c were inserted TEST-first and both read-backs verified after clean URL/key preflight. Direct Mobile Phones counts: TEST 242 active evidence / 148 active uk_used+sold; LIVE 240 / 146. Two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-74.md`.

## Mobile phone catalogue — Batch 75 (25 October 2026)
Added two Samsung Galaxy S25 Ultra 256GB UK eBay completed-sale observations to TEST and LIVE after exact master matching and clean URL/key preflight. Titanium Black item 137643944477 sold 21 Aug 2026 at displayed £572.95 including £17.95 Buyer Protection; TEST evidence 974e9083-f2e2-4d91-b8e4-a7d7cc3f21dd, LIVE evidence 6a720308-c47f-4dcb-8e6d-e7f5a39ce464. Titanium White item 168615919758 sold 16 Aug 2026 at displayed £516.84 including £16.84 Buyer Protection; no charger included; TEST evidence 54b6d3bd-53ff-4263-87b5-9eb4b583d4f0, LIVE evidence cca87524-34bf-4355-a4c1-d94f3e3b836a. Seller proceeds are unconfirmed for both. TEST insert/read-back preceded LIVE insertion/read-back. Direct Mobile Phones counts: TEST 244 active evidence / 150 active uk_used+sold; LIVE 242 / 148. Two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-75.md`.

## Mobile phone catalogue — Batch 76 (25 October 2026)
Added two Samsung Galaxy S25 Ultra 256GB UK eBay used/sold observations to TEST and LIVE after exact active master matching and clean URL/key preflight. Item 137804587290 (Silver SM-S938U1) sold 4 Oct 2026 at displayed £570.15 including £17.90 Buyer Protection; offer option means accepted sale amount/proceeds unconfirmed. Item 278429059814 (Titanium Blue, unlocked/excellent condition) sold 3 Oct 2026 at displayed £594.85 including £18.09 Buyer Protection. Original listing pages displayed different amounts from search-index snippets; current original-page display was recorded and discrepancy noted. TEST evidence: 68dfb55c-a351-4227-a8a0-af3128bc8dd9 and 8a5b3a09-e29a-420c-8c00-5d19120383df. LIVE evidence: 62b58127-e0e3-4427-a276-a04fc63f6590 and 226598aa-9f2d-4db1-9dd9-f2dfba0429de. Direct Mobile Phones counts: TEST 246 active evidence / 152 active uk_used+sold; LIVE 244 / 150. Two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Batch 76 follow-up — third observation
Added Samsung Galaxy S25 Ultra 256GB Titanium Silverblue, eBay item 227413483025, sold 4 July 2026 at 15:40 BST. The original listing page displays £589.15 including £18.27 Buyer Protection; Best Offer was enabled, so accepted sale amount and seller proceeds are unconfirmed. Seller located in Blackburn, UK. Search-index amount differed from the original page; the original page display was recorded and the discrepancy noted. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Verified counts after this addition: TEST 247 active phone evidence / 153 active uk_used+sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding.

## Batch 76 follow-up — 25 October 2026
Added a third Galaxy S25 Ultra 256GB UK eBay observation: item 227413483025, Titanium Silverblue, sold 4 Jul 2026 at 15:40 BST. Original listing page displays £589.15 including £18.27 Buyer Protection; Best Offer was enabled and accepted proceeds are unconfirmed. Seller in Blackburn, UK. Original page amount differed from search-index snippet and is documented as such. TEST evidence 55282454-4563-46ca-a53e-112078ff121f; LIVE evidence 670a4c5b-8bb0-4e87-8ec2-7948cf65e028. Counts now TEST 247 active evidence / 153 used-sold; LIVE 245 / 151. Global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-76.md`.

## Mobile phone catalogue — Batch 77 (25 October 2026)
Added two Google Pixel 10 Pro 256GB Obsidian UK eBay new/sealed completed-sale observations to TEST and LIVE after exact active master matching and clean URL/key preflight. Item 117212924862 sold 5 Jul 2026 at displayed £691.83 including £16.83 Buyer Protection; TEST evidence 54138811-eb8c-43c9-9989-c145d2015625, LIVE 54503726-50cb-4569-88b6-e57770b6052b. Item 236875676375 sold 25 Jun 2026 at displayed £605.42 including £15.42 Buyer Protection; TEST evidence 1c89897b-4ea4-478c-afa0-ca8b531a4223, LIVE 8440e8a6-b4b5-4de9-bc80-f5db5a5874f9. Seller proceeds not independently confirmed. Direct counts: TEST 249 active phone evidence / 153 uk_used+sold / 2 uk_new+sold; LIVE 247 / 151 / 2. Two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-77.md`.

## Mobile phone catalogue — Batch 78 (25 October 2026)
Added one Samsung Galaxy S25 Ultra 256GB Black used-sale observation, eBay item 128026023099, sold 17 Aug 2026 at 08:44 BST. Original listing displayed £399.99 with Buyer Protection included; separate fee and seller proceeds not confirmed. Listing explicitly disclosed chipped corner and visible scratches. TEST evidence 8c2f73c1-a064-4c05-91df-5f38a0437e83; LIVE evidence 4a25dc41-af63-4b48-96de-093f9e314a2b; stable key `mobile-used-sold-galaxys25ultra-256gb-black-chipped-scratches-ebay-128026023099-20260817`. Counts: TEST 250 active phone evidence / 154 uk_used+sold / 2 uk_new+sold; LIVE 248 / 152 / 2. Two-row difference and global duplicate-key aggregation audit remain outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-78.md`.

## Mobile phone catalogue — Batch 79 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB unlocked, eBay item 227413880546, sold 8 Jul 2026 at 19:00 BST. Displayed buyer-facing total £507.44 including £13.81 Buyer Protection; seller proceeds not independently confirmed. Listing states no charger included; 12 bids, no Best Offer ambiguity. TEST evidence 753183e6-5091-4186-90ca-a85e3c188488; LIVE evidence 53d8d266-7ce4-40d4-ab8a-7be66131a644; stable key `mobile-used-sold-pixel10proxl-256gb-unlocked-ebay-227413880546-20260708`. Counts: TEST 251 active phone evidence / 155 uk_used+sold / 2 uk_new+sold; LIVE 249 / 153 / 2. Two-row difference and global duplicate-key audit remain outstanding.

Audit flag: Batch 78 eBay item 128026023099 is recorded at £399.99, but a later search result currently displays £479.99 incl Buyer Protection. Preserve the existing row and investigate as a source-price/relisting discrepancy before any correction. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-79.md`.

## Mobile phone catalogue — Batch 80 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB Moonstone, eBay item 278176799541, sold 18 Jul 2026 at 17:50 BST. Search result showed £620.00 including Buyer Protection, fee amount not displayed. Used, no charger included. Original page showed a Best Offer option but no explicit “Best offer accepted” notice; price uncertainty recorded and seller proceeds not confirmed. TEST evidence abe2acc1-68f1-4a92-a471-30999fdf7710; LIVE evidence 2de6f8ea-8266-4950-a824-0ca342999cb6; stable key `mobile-used-sold-pixel10proxl-256gb-moonstone-ebay-278176799541-20260718`. Counts: TEST 252 active phone evidence / 156 used-sold / 2 new-sold; LIVE 250 / 154 / 2. Two-row environment difference and global duplicate-key audit remain outstanding. Batch 78 source discrepancy (item 128026023099, £399.99 recorded vs later £479.99 result) remains unresolved; preserve history pending audit. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-80.md`.

## Mobile phone catalogue — Batch 81 (25 October 2026)
Added Google Pixel 10 Pro XL 256GB Obsidian, eBay item 257522963688, sold 20 Jul 2026 at 15:55 BST. Original item page displayed £578.85 incl £17.77 Buyer Protection; no charger included. Search index displayed £576.01 incl £14.93 fee; original item page used as source-of-record capture and discrepancy noted. TEST evidence 743ca969-f948-4f4a-b7eb-345c4ba8fb4a; LIVE evidence cb456f2b-635b-44e2-882f-fb7a1623ea1c; stable key `mobile-used-sold-pixel10proxl-256gb-obsidian-ebay-257522963688-20260720`. Counts TEST 253 active phone evidence / 157 used-sold / 2 new-sold; LIVE 251 / 155 / 2. Two-row difference and global duplicate-key audit remain outstanding. Batch 78 item 128026023099 price discrepancy (£399.99 recorded vs later £479.99 search result) remains pending source audit. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-81.md`.


## Mobile phone catalogue — Batch 82 (25 October 2026)
One Google Pixel 10 Pro XL 256GB Porcelain/white “Opened – never used” completed-sale observation added and verified in TEST and LIVE. eBay item 178468385751 sold 11 Sep 2026 at 21:06 BST. Original page £649.14 incl £19.14 Buyer Protection; search index £646.08 incl £16.08, so discrepancy documented and original page retained as source-of-record capture. Best Offer was available but no accepted-offer notice appeared in the captured page; seller proceeds unconfirmed. TEST evidence 0bc38469-6a22-4613-8554-0608991d0456; LIVE evidence 5594202c-993b-45fd-988a-98fdeb4beff6. Counts: TEST 254 active phone evidence / 158 used-sold / 2 new-sold; LIVE 252 / 156 / 2. Two-row difference and global active duplicate-key audit remain outstanding. Batch 78 and 81 source-price discrepancies remain open. See CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-82.md.


## Mobile phone catalogue — Batch 83 (25 October 2026)
One Google Pixel 10 Pro XL 256GB Black new-condition UK eBay completed-sale observation added and verified in TEST and LIVE. Item 178516971817 sold 22 Sep 2026 at 20:43 BST; original page displayed £656.73 including £16.26 Buyer Protection. Seller was located in Luton, UK. No Best Offer option/acceptance notice appeared on the captured page; seller proceeds unconfirmed. TEST evidence 4e0f3332-7bc3-467a-9dc6-18a2845da52a; LIVE evidence a32bb8b5-0b1f-45da-be8d-b8c48571a242. Counts: TEST 255 active phone evidence / 158 used-sold / 3 new-sold; LIVE 253 / 156 / 3. Two-row difference and global active duplicate-key audit remain outstanding. Source-price discrepancies from Batches 78, 81 and 82 remain open. See CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-83.md.
