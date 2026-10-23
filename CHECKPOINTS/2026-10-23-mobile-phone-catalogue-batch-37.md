# Mobile Phone Catalogue Checkpoint — Batch 37
Date: 2026-10-23

## Scope
Added four exact-variant UK market-evidence records in TEST first, verified inserted rows and stable source keys, then promoted the same evidence to LIVE and verified both environments.

## Evidence added
1. **Samsung Galaxy S25 128GB — UK used completed sale**
   - Displayed price: £339.99. Source: https://www.ebay.co.uk/itm/206633174515
   - Source key: `mobile-used-sold-galaxy-s25-128gb-ebay-206633174515-20261019`
   - Sold 19 October 2026; used blue handset; listing title states 100% battery.
   - Displayed price includes Buyer Protection; it is not seller proceeds.

2. **Samsung Galaxy A37 5G 128GB / 6GB RAM — UK new-price listing**
   - £399.00. Source: https://www.argos.co.uk/product/9566136
   - Source key: `mobile-new-galaxy-a37-5g-128gb-argos-9566136-20261023`
   - Argos SIM-free product page. Postcode-dependent stock; recorded as `listed`, not confirmed in stock. Corroborates Samsung UK's £419 list-price reference.

3. **Apple iPhone 16 128GB — UK used completed sale**
   - Displayed price: £369.03. Source: https://www.ebay.co.uk/itm/800749991087
   - Source key: `mobile-used-sold-iphone16-128gb-ebay-800749991087-20261003`
   - Sold 3 October 2026; exact 128GB black handset, used, without contract; seller located in Castletown, UK.
   - Displayed price includes £14.03 Buyer Protection fee; it is not seller proceeds.

4. **Samsung Galaxy S24 128GB — UK used completed sale**
   - Displayed price: £271.19. Source: https://www.ebay.co.uk/itm/377500378163
   - Source key: `mobile-used-sold-galaxy-s24-128gb-ebay-377500378163-20260917`
   - Sold 17 September 2026; exact 128GB black, unlocked, used, seller describes excellent condition; seller located in Bristol, UK.
   - Displayed price includes £11.19 Buyer Protection fee; it is not seller proceeds.

All four records are active, GBP-denominated, have positive prices and stable keys, and are linked to the exact variant. No duplicate active source keys were found.

## Verified database snapshot after Batch 37
| Measure | TEST | LIVE |
|---|---:|---:|
| Active customer-visible variants | 130 | 128 |
| Total evidence rows | 172 | 167 |
| Active evidence rows | 161 | 159 |
| Inactive evidence rows | 11 | 8 |
| Active UK used completed-sale rows | 67 | 65 |
| Active visible variants missing active evidence | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

Integrity checks cover missing/blank source URLs, missing/blank stable keys, non-positive prices and non-GBP currency. They do not prove every source remains live or every price remains current.

## Carry-forward controls
- Continue TEST-first validation and prompt LIVE promotion.
- Keep used asking prices distinct from completed sales; preserve Buyer Protection / Best Offer caveats.
- Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden until exact storage evidence is confirmed.
- Recheck Xiaomi 17T / 17T Pro campaign prices on or after 27 October 2026, or earlier if stock ends.
- OnePlus 15 256GB price reference is not confirmation of stock.
- Recheck OPPO Find X10 pre-order/launch state after 28 October 2026.
