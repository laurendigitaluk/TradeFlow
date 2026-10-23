# Project Memory — Mobile Phone Catalogue
Updated: 2026-10-23 after batch 04

## Current position
The phone catalogue is being expanded in TradeFlow using a controlled TEST → LIVE process. Validate product identity, exact storage variant, source URL, price type, observed date, availability, currency, and unique source key before promotion. Do not import unvalidated GearCashOut/Action Buyer UK evidence.

## Latest verified batch
See `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-01.md`.

- Latest TEST position after batch 04: 116 Mobile Phones product variants, 44 linked evidence records.
- Latest LIVE position after batch 04: 27 Mobile Phones product variants, 28 linked evidence records. LIVE contains only batches explicitly promoted; it is not a full copy of TEST.
- Batch: Samsung Galaxy A37 5G 128/256 GB and Galaxy A57 5G 128/256/512 GB.
- Evidence is from official Samsung UK product pages; list prices were stored separately from code-based promotional prices.
- No used-market evidence was included in this batch.
- LIVE's missing phone category/branch/manufacturer structure was a genuine promotion blocker. Category and branch IDs differ between TEST and LIVE; never assume cross-environment IDs match. Map by natural keys (slug/name and manufacturer name).

## Latest batch 04
See `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-04.md`.
- Added and promoted iPhone 17e 256 GB (£699), iPhone 17e 512 GB (£899), and Pixel 10a 128 GB (£599) with current UK new-price evidence.
- Pixel 10a 256 GB is present in TEST only, with no evidence row until exact price is verified.
- LIVE-wide evidence integrity check returned zero missing URLs, keys, product links, non-positive prices, non-GBP values or inactive evidence rows.
- No used-market evidence was added in batch 04.

## Operating rules
1. Add products and evidence to TEST first.
2. Evidence must link to the exact product/storage variant and have a meaningful source URL and stable unique key.
3. Distinguish UK new list prices, promotional prices, used asking prices, and completed/sold prices. Do not combine these as equivalent evidence.
4. For current new prices, prefer manufacturer or authorised UK retailer product pages; record availability conservatively.
5. Keep discontinued models in the catalogue for used valuation, but mark lifecycle and do not treat old launch prices as current new prices.
6. Promote each validated batch to LIVE rather than accumulating a large backlog; verify LIVE counts and links after every promotion.
7. Do not bulk-copy the 95 legacy TEST phone seeds without verifying them and their evidence first.
