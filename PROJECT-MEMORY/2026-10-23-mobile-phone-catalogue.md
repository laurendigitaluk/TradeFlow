# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23 after batch 08

## Catalogue workflow
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and unique source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Current verified position after batch 08
See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-08.md`.

- TEST: 124 total phone product rows (123 active); 64 evidence rows total (61 active; inactive rows retained for audit).
- LIVE at the latest query: 58 active phone product rows and 59 active evidence rows. LIVE changed during this work window; some additional legacy variants/evidence appeared concurrently, so use fresh live queries before the next promotion and do not attribute all concurrent rows to batch 08.
- Batch 08 explicitly added completed/sold eBay UK evidence for iPhone 15 256 GB, Galaxy S23 256 GB, iPhone 14 256 GB, iPhone 15 Pro 256 GB, Galaxy S24 256 GB, and Pixel 9 256 GB.
- The evidence is marked `uk_used` with `availability=sold`. Buyer protection fees included in displayed totals are documented in notes; those totals are not seller proceeds or guaranteed buy-in values.
- Integrity query at the latest check: zero missing source URLs/keys, non-positive prices, non-GBP evidence, or broken product links.
- UK new/RRP evidence remains separate from used completed-sale evidence.
- LIVE's missing phone category/branch/manufacturer structure was a genuine promotion blocker. Category and branch IDs differ between TEST and LIVE; never assume cross-environment IDs match. Map by natural keys (slug/name and manufacturer name).

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

## Latest batch 08
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-08.md`.
- Promoted iPhone 13 128 GB (£150.00), iPhone 14 128 GB (£171.08), iPhone 15 128 GB (£310.58), iPhone 15 Pro 128 GB (£371.58), iPhone 16 128 GB (£366.50), Pixel 8 128 GB (£155.58), Pixel 9 128 GB (£279.58), Motorola Edge 50 Neo 256 GB (£199.00), Nothing Phone (3a) 128 GB (£208.70), Galaxy S22 128 GB (£139.99), and Galaxy S24 128 GB (£243.31) with UK completed-sale evidence.
- Values are used-sale observations; some displayed prices include Buyer Protection fees or Best Offer caveats. Do not treat them as current new prices or exact seller proceeds.
- TEST Galaxy S26 256 GB generic giffgaff evidence retired; kept inactive for audit.

## Operating rules
1. Add products and evidence to TEST first.
2. Evidence must link to the exact product/storage variant and have a meaningful source URL and stable unique key.
3. Distinguish UK new list prices, promotional prices, used asking prices, and completed/sold prices. Do not combine these as equivalent evidence.
4. For current new prices, prefer manufacturer or authorised UK retailer product pages; record availability conservatively.
5. Keep discontinued models in the catalogue for used valuation, but mark lifecycle and do not treat old launch prices as current new prices.
6. Promote each validated batch to LIVE rather than accumulating a large backlog; verify LIVE counts and links after every promotion.
7. Do not bulk-copy the 95 legacy TEST phone seeds without verifying them and their evidence first.
