# Mobile Phone Catalogue — Batch 102 Retailer and Seller Verification

Date: 30 October 2026
Status: Additional retailer and seller checks complete. No qualifying evidence accepted; no database writes.

## Scope
Current missing products rechecked from TEST and LIVE:
- TEST: Apple iPhone 18 256GB (hidden); Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.
- LIVE: Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.

## Findings
- eBay UK used-mobile search and OPPO Find-category search continue to show the nanovault OPPO Find X10 Pro Max 512GB Luna White listing as Pre-owned, £1,244.82 plus £13 postage, 100% positive feedback (254). Search results still do not expose its item ID/direct item URL or item location. A seller-profile search did not independently resolve nanovault's profile/location. Keep as a lead only; do not insert.
- eBay OPPO category results show exact Find X10 256GB at £994.64 but Brand New. Exact Find X10 Pro Max 512GB offers from dopetech, ishe7635, luwaaa and others are brand new/sealed. An exact 512GB Find X10 Pro Max listing marked Opened – never used is not acceptable used/refurbished evidence.
- Motorola Edge 70 Plus 256GB: MoneySavingExpert exact model page confirms 256GB but its refurbished grade filter says “none available”; listed £529.99 is new retail.
- OPPO Reno16 F 5G 256GB: no direct exact-variant used/refurbished listing surfaced from this additional retailer sweep.
- iPhone 18 base 256GB: results for iPhone 18 Pro are wrong model; no base iPhone 18 used listing surfaced.
- Additional targeted searches of UK retailer/refurbisher domains (Cash Converters, musicMagpie, Back Market, The iOutlet and Reebelo) returned no matching exact-variant pages in this sweep. Absence from these searches is not proof of no inventory.

## Fresh Supabase snapshot
| Measure | TEST | LIVE |
|---|---:|---:|
| Mobile master rows | 160 | 156 |
| Active masters | 159 | 156 |
| Customer-visible active masters | 156 | 154 |
| Active mobile evidence rows | 541 | 535 |
| Active uk_used rows | 274 | 272 |
| Active listed uk_used rows | 79 | 79 |
| Active products with active uk_used | 154/159 | 152/156 |
| Active gaps | 5 | 4 |

No evidence rows inserted, updated or deactivated. No product master, valuation, visibility, lifecycle, customer, tenant or schema changes.

## Next action
Continue to verify the nanovault listing via direct eBay item page or seller listing URL; only accept if exact model/storage, condition, GBP, UK item location and active listing are independently confirmed. Continue exact-variant UK used/refurbished checks for the other four models.
