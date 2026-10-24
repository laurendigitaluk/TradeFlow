# Mobile Phone Catalogue Checkpoint — Batch 39
Date: 2026-10-24

## Scope
Added three further exact-variant UK used completed-sale records. Each source key was checked absent in TEST and LIVE before insertion. Rows were inserted TEST-first, promoted to LIVE, and queried back from both databases joined to the exact phone model/storage variant.

## Evidence added
1. **Samsung Galaxy S24 128GB, Graphite/Black, factory unlocked**
   - Displayed total: £206.99, including eBay Buyer Protection (fee amount not captured).
   - Sold 24 August 2026, 13:20 BST.
   - Source: https://www.ebay.co.uk/itm/407090445365
   - Stable key: `mobile-used-sold-galaxy-s24-128gb-ebay-407090445365-20260824`
   - 96% battery health, 8GB RAM. UK business seller located in Ilkeston. Buyer-facing total, not seller proceeds.

2. **Google Pixel 9 128GB, Obsidian, SIM-free/unlocked**
   - Displayed price: £269.25.
   - Sold 2 September 2026, 19:32 BST.
   - Source: https://www.ebay.co.uk/itm/397668056530
   - Stable key: `mobile-used-sold-pixel9-128gb-ebay-397668056530-20260902`
   - Listing notes chipped paint around the casing. Treat as used with cosmetic wear, not pristine. No Buyer Protection amount shown in the search result.

3. **Apple iPhone 16 128GB, White, boxed**
   - Displayed total: £412.24, including £12.25 eBay Buyer Protection.
   - Sold 29 September 2026, 20:59 BST; Best Offer accepted.
   - Source: https://www.ebay.co.uk/itm/128103996035
   - Stable key: `mobile-used-sold-iphone16-128gb-ebay-128103996035-20260929`
   - UK seller located in Bradford. Buyer-facing total, not seller proceeds; Best Offer caveat retained.

## Verified phone-category snapshot after Batch 39
| Measure | TEST | LIVE |
|---|---:|---:|
| Active customer-visible phone variants | 130 | 128 |
| Total phone evidence rows | 178 | 173 |
| Active phone evidence rows | 167 | 165 |
| Inactive phone evidence rows | 11 | 8 |
| Active UK used completed-sale rows | 73 | 71 |
| Visible active variants missing active evidence | 0 | 0 |
| Active evidence rows missing URL | 0 | 0 |
| Active evidence rows missing stable key | 0 | 0 |
| Active non-positive prices | 0 | 0 |
| Active non-GBP values | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

The integrity checks apply to phone-category evidence. They do not guarantee every source remains accessible or that displayed prices remain current.

## Ongoing investigation and controls
- Batch 37 eBay items 377500378163 (Galaxy S24) and 800749991087 (iPhone 16) now show different displayed totals from the captured historical values. Preserve original observations and investigate revisions/relisting; do not silently overwrite.
- Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden until exact storage capacity is confirmed.
- Recheck Xiaomi 17T / 17T Pro promotional prices on or after 27 October 2026.
- Recheck OPPO Find X10 pre-order/launch after 28 October 2026.
- Continue TEST-first and promote validated evidence to LIVE promptly. Distinguish used asking prices, completed sales, Best Offer, condition, and fee-inclusive buyer totals.
