# Project Memory — Mobile Phone Catalogue Batch 09
Updated: 2026-10-23

## Completed
Promoted 11 UK completed-sale evidence records for phone variants from TEST to LIVE:
- iPhone 13 128 GB — £150.00
- iPhone 14 128 GB — £171.08
- iPhone 15 128 GB — £310.58
- iPhone 15 Pro 128 GB — £371.58
- iPhone 16 128 GB — £366.50
- Google Pixel 8 128 GB — £155.58
- Google Pixel 9 128 GB — £279.58
- Motorola Edge 50 Neo 256 GB — £199.00
- Nothing Phone (3a) 128 GB — £208.70
- Samsung Galaxy S22 128 GB — £139.99
- Samsung Galaxy S24 128 GB — £243.31

## Caveats
All evidence is UK used and sold status. Some eBay displayed totals include Buyer Protection fees; Best Offer may mean displayed totals differ from accepted seller proceeds. Notes retain condition, battery and lock-status uncertainty. These are not current new prices or guaranteed valuation amounts.

## Data-quality fix
Retired TEST Samsung Galaxy S26 256 GB evidence for £749 because its giffgaff URL resolves to a generic error page rather than a product-specific listing. It remains inactive for audit; the product remains in TEST pending valid evidence.

## Verified state after batch 09
- TEST: 124 phone product rows, 123 active; 64 evidence rows, 61 active and 3 inactive retained for audit.
- LIVE: 58 active/customer-visible phone variants; 59 active phone evidence rows (42 UK new-price/RRP and 17 UK used completed-sale).
- LIVE integrity: zero missing phone source URLs/keys, non-positive prices, non-GBP values, inactive phone evidence rows or orphaned evidence.
- Duplicate active phone-variant check: no duplicates.
- Batch 08 added six storage-specific completed-sale records; Batch 09 added 11 further completed-sale records, for 17 UK used sold rows in the current LIVE snapshot.

## Next
1. Continue large batches of UK completed/sold evidence for other storage variants and more than one normal-condition comparable where possible.
2. Keep damaged/“opened-never-used”/excellent-condition observations explicitly distinguished from ordinary used condition.
3. Fill new-price gaps only from product-specific UK manufacturer or authorised-retailer sources.
4. Re-query both environments before the next promotion and update manuals/memory/checkpoints after material changes.
