# Mobile Phone Catalogue — Batch 09
Date: 2026-10-23
Status: Completed-sale evidence promoted from TEST to LIVE; integrity checked

## Evidence promoted
| Product variant | Observed UK completed-sale total | Notes |
|---|---:|---|
| Apple iPhone 13 128 GB | £150.00 | Condition, battery health and lock status not fully confirmed |
| Apple iPhone 14 128 GB | £171.08 | Includes £6.08 Buyer Protection |
| Apple iPhone 15 128 GB | £310.58 | Listing described pristine condition and 90% battery health; includes £10.58 Buyer Protection |
| Apple iPhone 15 Pro 128 GB | £371.58 | Used; includes £11.58 Buyer Protection |
| Apple iPhone 16 128 GB | £366.50 | Best Offer available; includes £11.50 Buyer Protection |
| Google Pixel 8 128 GB | £155.58 | Unlocked used phone; grade and battery not fully confirmed; includes £5.58 Buyer Protection |
| Google Pixel 9 128 GB | £279.58 | Used; Best Offer available; includes £9.58 Buyer Protection |
| Motorola Edge 50 Neo 256 GB | £199.00 | SIM-free listing mentioned warranty; fine-grained condition not confirmed |
| Nothing Phone (3a) 128 GB | £208.70 | Used, unlocked UK version; Best Offer available; includes £8.70 Buyer Protection |
| Samsung Galaxy S22 128 GB | £139.99 | Used, unlocked, described as Good |
| Samsung Galaxy S24 128 GB | £243.31 | Used, excellent condition, boxed; includes £8.41 Buyer Protection |

Source URLs, observed dates, stable source keys and condition notes are stored on each linked evidence row in Supabase. Buyer-facing totals that include Buyer Protection are not seller proceeds or guaranteed valuation amounts.

## Data-quality correction
Retired TEST Samsung Galaxy S26 256 GB evidence for £749 because its giffgaff URL resolved to a generic error page, not a product-specific listing. The product remains in TEST; the invalid evidence is inactive and retained for audit.

## Verification snapshot at batch 09
- TEST: 124 phone product rows, 123 active; 64 evidence rows, 61 active, 3 inactive retained for audit.
- LIVE: 58 active/customer-visible phone variants; 59 active phone evidence rows (42 UK new-price/RRP and 17 UK used completed-sale).
- LIVE integrity: zero missing phone source URLs/keys, non-positive prices, non-GBP values, inactive phone evidence rows or orphaned evidence.
- Duplicate active phone-variant check: no duplicates.

## Next
Continue large batches of UK completed/sold evidence for remaining storage variants. Keep condition differences explicit, fill new-price gaps only from product-specific UK manufacturer or authorised-retailer sources, and re-query both environments before each promotion.
