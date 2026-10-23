# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23 after batch 13

## Catalogue workflow
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and unique source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Current verified position after batch 13
See CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-13.md.

- TEST: 124 total phone products (123 active); 81 evidence rows total (78 active, 3 inactive retained for audit). 46 visible variants still have no active evidence.
- LIVE: 75 active/customer-visible phone variants and 76 active evidence rows, including 34 active sold rows. No active visible LIVE variants were found without active evidence.
- Integrity at final query: zero missing source URLs/keys, non-positive prices, non-GBP evidence, or broken product links.
- Batch 08: six completed-sale records for iPhone 15 256 GB, Galaxy S23 256 GB, iPhone 14 256 GB, iPhone 15 Pro 256 GB, Galaxy S24 256 GB, and Pixel 9 256 GB.
- Batch 09: eleven completed-sale records for iPhone 13 128 GB, iPhone 14 128 GB, iPhone 15 128 GB, iPhone 15 Pro 128 GB, iPhone 16 128 GB, Pixel 8 128 GB, Pixel 9 128 GB, Motorola Edge 50 Neo 256 GB, Nothing Phone (3a) 128 GB, Galaxy S22 128 GB, and Galaxy S24 128 GB.
- Batch 10: four completed-sale records for iPhone 13 256 GB, iPhone 15 Plus 128 GB, iPhone 15 Pro Max 256 GB, and iPhone 16 256 GB.
- Batch 11: four completed-sale records for iPhone 15 512 GB, iPhone 16 Plus 128 GB, iPhone 16 Pro 256 GB, and iPhone 16 Pro Max 256 GB.
- Batch 12: five completed-sale records for Galaxy S25 128 GB, Galaxy S25 256 GB, Galaxy S25 Ultra 256 GB, Nothing Phone (3) 256 GB, and Xiaomi 14T 256 GB.
- Batch 13: four completed-sale records for HONOR 200 256 GB, HONOR 400 256 GB, Motorola Razr 50 Ultra 512 GB, and OPPO Find X9 Pro 512 GB.
- Buyer Protection fees are noted where included in displayed totals; these are buyer-facing totals, not seller proceeds or guaranteed buy-in values.
- Keep UK new/RRP evidence separate from completed-sale evidence.

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

## Operating rules
1. Add products and evidence to TEST first.
2. Evidence must link to the exact product/storage variant and have a meaningful source URL and stable unique key.
3. Distinguish UK new list prices, promotional prices, used asking prices, and completed/sold prices. Do not combine these as equivalent evidence.
4. For current new prices, prefer manufacturer or authorised UK retailer product pages; record availability conservatively.
5. Keep discontinued models in the catalogue for used valuation, but mark lifecycle and do not treat old launch prices as current new prices.
6. Promote each validated batch to LIVE rather than accumulating a large backlog; verify LIVE counts and links after every promotion.
7. Do not bulk-copy the 95 legacy TEST phone seeds without verifying them and their evidence first.
