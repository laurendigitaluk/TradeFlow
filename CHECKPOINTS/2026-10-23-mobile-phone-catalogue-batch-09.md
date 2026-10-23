# Mobile Phone Catalogue — Batch 09
Date: 2026-10-23
Status: Promoted to LIVE; snapshot later superseded by Batch 10

## Completed-sale evidence added
Promoted 11 existing TEST phone variants and their UK completed-sale evidence to LIVE. These are used-market observations, not current new prices or guaranteed buy-in values.

| Product variant | Observed UK completed-sale price | Source record key | Source |
|---|---:|---|---|
| Apple iPhone 13 128 GB | £150.00 | mobile-used-ebay-iphone13-128gb-188929213094 | https://www.ebay.co.uk/itm/188929213094 |
| Apple iPhone 14 128 GB | £171.08 | mobile-used-ebay-iphone14-128gb-800739946361 | https://www.ebay.co.uk/itm/800739946361 |
| Apple iPhone 15 128 GB | £310.58 | mobile-used-ebay-iphone15-128gb-287624850376 | https://www.ebay.co.uk/itm/287624850376 |
| Apple iPhone 15 Pro 128 GB | £371.58 | mobile-used-ebay-iphone15pro-128gb-287631839314 | https://www.ebay.co.uk/itm/287631839314 |
| Apple iPhone 16 128 GB | £366.50 | mobile-used-ebay-iphone16-128gb-800749991087 | https://www.ebay.co.uk/itm/800749991087 |
| Google Pixel 8 128 GB | £155.58 | mobile-used-ebay-pixel8-128gb-168769339127 | https://www.ebay.co.uk/itm/168769339127 |
| Google Pixel 9 128 GB | £279.58 | mobile-used-ebay-pixel9-128gb-820179580133 | https://www.ebay.co.uk/itm/820179580133 |
| Motorola Edge 50 Neo 256 GB | £199.00 | mobile-used-ebay-moto-edge50neo-256gb-146840796138 | https://www.ebay.co.uk/itm/146840796138 |
| Nothing Phone (3a) 128 GB | £208.70 | mobile-used-ebay-nothing-phone3a-128gb-168514226972 | https://www.ebay.co.uk/itm/168514226972 |
| Samsung Galaxy S22 128 GB | £139.99 | mobile-used-ebay-galaxys22-128gb-336535542333 | https://www.ebay.co.uk/itm/336535542333 |
| Samsung Galaxy S24 128 GB | £243.31 | mobile-used-ebay-galaxys24-128gb-147622053576 | https://www.ebay.co.uk/itm/147622053576 |

## Caveats
All records are UK used completed sales, GBP, exact storage variants and stable source keys. Some displayed eBay totals include Buyer Protection; Best Offer may mean displayed price differs from accepted seller proceeds. Condition, battery health and lock status are not fully confirmed for every listing. iPhone 15 was listed as pristine with 90% battery health; Galaxy S22 as Good; Galaxy S24 as excellent and boxed.

## Data-quality correction
Retired TEST Samsung Galaxy S26 256 GB evidence for £749 because its giffgaff URL (https://www.giffgaff.com/mobile-phones?error=pdp_phone_load_error) is a generic error page rather than a product-specific listing. Evidence is inactive and retained for audit; do not use until re-verified.

## Snapshot after Batch 09
- TEST: 124 phone products (123 active); 64 evidence rows (61 active).
- LIVE: 58 active/customer-visible phone variants; 59 active phone evidence rows, including 17 used-sale rows.
- LIVE integrity: no missing source URLs/keys, non-positive prices, non-GBP values, inactive phone evidence rows or orphaned evidence; duplicate check passed.
- Batch 10 later added four more iPhone variants; current count is documented in `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-10.md`.
