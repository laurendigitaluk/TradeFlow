# Mobile Phone Catalogue Checkpoint — Batch 38
Date: 2026-10-24

## Why this batch matters
The earlier apparent database blocking was intermittent. Simple reads and writes were subsequently accepted, and direct row-level verification succeeded. The tool's earlier "blocked by safety checks" message was generated before a database result was returned; it was not a PostgreSQL permission error. A separate attempted insert using `ON CONFLICT (source_record_key)` did return a genuine PostgreSQL error: no unique/exclusion constraint exists on that key. The insert was retried without that clause only after checking the exact source key was absent.

## Evidence added in TEST, then promoted to LIVE
1. **Samsung Galaxy S24 128GB, Onyx Black — UK used completed sale**
   - Displayed total: £243.31; includes £8.41 eBay Buyer Protection fee.
   - Sold 14 October 2026 at 09:59 UK time.
   - Source: https://www.ebay.co.uk/itm/147622053576
   - Stable key: `mobile-used-sold-galaxy-s24-128gb-ebay-147622053576-20261014`
   - Described as excellent condition and boxed. Buyer-facing total, not seller proceeds.

2. **Google Pixel 9 128GB, Obsidian, unlocked — UK used completed sale**
   - Displayed total: £279.58; includes £9.58 eBay Buyer Protection fee.
   - Sold 29 September 2026 at 08:29 UK time.
   - Source: https://www.ebay.co.uk/itm/820179580133
   - Stable key: `mobile-used-sold-pixel9-128gb-ebay-820179580133-20260929`
   - Buyer-facing total, not seller proceeds.

3. **Apple iPhone 16 128GB, Teal, unlocked — UK used completed sale**
   - Displayed total: £386.83; includes £11.83 eBay Buyer Protection fee.
   - Sold 29 September 2026 at 13:40 UK time.
   - Source: https://www.ebay.co.uk/itm/366694404412
   - Stable key: `mobile-used-sold-iphone16-128gb-ebay-366694404412-20260929`
   - Listing states 88% battery health and great condition. Buyer-facing total, not seller proceeds.

All three keys were absent before insertion in both environments. Each row was inserted and then independently queried back from TEST and LIVE, joined to the exact 128GB product variant, with active status confirmed.

## Verified mobile-catalogue database snapshot
Counts are restricted to phone-category evidence joined to the phone catalogue, not the whole platform-wide evidence table.

| Measure | TEST | LIVE |
|---|---:|---:|
| Active customer-visible phone variants | 130 | 128 |
| Total phone evidence rows | 175 | 170 |
| Active phone evidence rows | 164 | 162 |
| Inactive phone evidence rows | 11 | 8 |
| Active UK used completed-sale rows | 70 | 68 |
| Visible active variants missing active evidence | 0 | 0 |
| Active evidence rows missing URL | 0 | 0 |
| Active evidence rows missing stable key | 0 | 0 |
| Active non-positive prices | 0 | 0 |
| Active non-GBP values | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

These checks establish database integrity for the checked fields, not that every source remains live or every price is current.

## Source recheck caveat
Existing records for eBay item 377500378163 (Galaxy S24 128GB) and 800749991087 (iPhone 16 128GB) now display different totals on the live pages than the values captured in Batch 37. Preserve the original observation history rather than silently overwriting it. Investigate whether the display changed after observation, the listing was revised/relisted, or the prior observation captured a different displayed fee.

## Carry-forward controls
- Keep TEST-first validation and promote validated evidence to LIVE promptly.
- Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden until exact storage capacity evidence is confirmed.
- Recheck Xiaomi 17T / 17T Pro promotional prices on or after 27 October 2026.
- Recheck OPPO Find X10 pre-order/launch state after 28 October 2026.
- OnePlus 15 256GB £849 remains a price reference only, not confirmed stock.
- Keep asking prices, completed-sale totals, Best Offer caveats, and Buyer Protection fees distinct.
