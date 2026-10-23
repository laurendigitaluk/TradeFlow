# Mobile Phone Catalogue Checkpoint — Batch 37
Date: 2026-10-23

## Scope
Added two exact-variant UK market-evidence records in TEST first, verified the inserted rows and stable source keys, then promoted the same evidence to LIVE and verified both environments.

## Evidence added
1. **Samsung Galaxy S25 128GB — UK used completed sale**
   - Displayed price: £339.99.
   - Source: https://www.ebay.co.uk/itm/206633174515
   - Source key: `mobile-used-sold-galaxy-s25-128gb-ebay-206633174515-20261019`
   - Listing sold on 19 October 2026; used, blue, listing title states 100% battery.
   - Important caveat: displayed £339.99 explicitly includes eBay Buyer Protection. It is a buyer-facing displayed total, not seller proceeds and should not be compared to seller proceeds without adjustment.

2. **Samsung Galaxy A37 5G 128GB / 6GB RAM — UK new-price listing**
   - Listed price: £399.00.
   - Source: https://www.argos.co.uk/product/9566136
   - Source key: `mobile-new-galaxy-a37-5g-128gb-argos-9566136-20261023`
   - Argos SIM-free product page; postcode-dependent stock. Recorded as `listed`, not confirmed in stock.
   - This is a retailer corroboration; it does not replace Samsung UK's own £419 list-price reference.

Both rows are `GBP`, active, linked to the exact storage variant, and have stable source keys. No duplicate active source keys were found.

## Verified database snapshot after Batch 37
Counts were queried directly after both TEST and LIVE writes.

| Measure | TEST | LIVE |
|---|---:|---:|
| Active customer-visible variants | 130 | 128 |
| Total evidence rows | 170 | 165 |
| Active evidence rows | 159 | 157 |
| Inactive evidence rows | 11 | 8 |
| Active UK used completed-sale rows | 65 | 63 |
| Active visible variants missing active evidence | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

The integrity query checked missing/blank source URLs, missing/blank stable keys, non-positive prices and non-GBP currency. These checks do not establish that every source remains live or every price remains current.

## Carry-forward controls
- Keep TEST-first validation and prompt LIVE promotion.
- Keep used asking prices separate from completed sales, and retain Buyer Protection / Best Offer caveats.
- Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden until exact storage evidence is confirmed.
- Recheck Xiaomi 17T / 17T Pro campaign prices on or after 27 October 2026, or earlier if stock ends.
- OnePlus 15 256GB price reference remains not confirmed in stock.
- Recheck OPPO Find X10 pre-order/launch state after 28 October 2026.
