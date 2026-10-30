# Mobile Phone Catalogue — Batch 98 UK Pre-owned Source Sweep

Date: 30 October 2026
Status: Additional source sweep complete. No new evidence met the acceptance criteria; no database writes.

## Scope
Rechecked the exact active mobile catalogue gaps from Batch 97 across TEST and LIVE:
- Apple iPhone 18 256GB — TEST only, hidden.
- Motorola Edge 70 Plus 256GB — TEST and LIVE.
- OPPO Find X10 256GB — TEST and LIVE, hidden.
- OPPO Find X10 Pro Max 512GB — TEST and LIVE.
- OPPO Reno16 F 5G 256GB — TEST and LIVE.

This remains five distinct products and nine environment-specific gaps; no artificial tenth target was added.

## Additional sources checked
- MoneySavingExpert Motorola Edge 70 Plus SIM-free/refurbished page: exact 256GB model, but no refurbished grades were available. New price/deal information is not used as used evidence.
- eBay UK OPPO catalogue: used/refurbished inventory exists for other OPPO models, but the surfaced exact Find X10 Pro Max 512GB listing at £1,073.08 is explicitly “Opened – never used”; not accepted.
- eBay UK OPPO Find category and 256GB listings: results include older Find models and different current-generation variants; no direct qualifying listing for the exact Find X10 256GB or Reno16 F 5G 256GB.
- eBay UK 256GB results for OPPO Reno16 F 5G surfaced new/sealed offers, not used/refurbished.
- Motorola Edge 70 Plus exact variant results remained new retail listings or no refurbished grade; not accepted.
- iPhone 18 base 256GB remains unreleased per the prior Batch 97 source check; no pre-owned market evidence can yet exist.

## Decision
No rows inserted or modified. No master products, valuation rules, visibility, lifecycle, tenant/customer data or schema changed. No candidate met exact model/storage + UK source/seller + GBP + explicit used/refurbished condition + working direct URL.

## Fresh Supabase verification
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

TEST gaps: iPhone 18 256GB (hidden), Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB (hidden), OPPO Find X10 Pro Max 512GB, OPPO Reno16 F 5G 256GB.
LIVE gaps: Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB (hidden), OPPO Find X10 Pro Max 512GB, OPPO Reno16 F 5G 256GB.

## Next action
Continue checking direct UK retailer/refurbisher and marketplace listings for these exact variants. Re-run the gap query before every insert. Do not use new, sealed, opened-never-used, buyback/trade-in, wrong-variant or overseas evidence to reduce the gap count.
