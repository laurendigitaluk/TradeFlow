# Mobile Phone Catalogue — Batch 103 Direct Listing and Variant Audit

Date: 30 October 2026
Status: Direct listing checks completed. No qualifying used/refurbished evidence; no database writes.

## Scope
Rechecked the five distinct active product gaps (nine environment-specific rows):
- TEST: Apple iPhone 18 256GB (hidden); Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.
- LIVE: Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.

## New source findings
- OPPO Find X10 256GB: direct eBay item 840048864921 is £999.99, explicitly New, seller located Baltana, India; excluded as new and overseas. Direct eBay item 128158680772 is £1,020.61, explicitly New, seller location Unknown IN, India; excluded.
- OPPO Reno16 F 5G 256GB: direct eBay item 407078357250 is £439.99, explicitly New, seller Tech Wizz Ltd located London, UK; excluded as new. This confirms UK seller but not used condition.
- Motorola Edge 70 Plus 256GB: Very lists exact variant at £499, standard retail offer; not used/refurbished. MoneySavingExpert continues to show no refurbished grade available.
- OPPO Find X10 Pro Max 512GB: nanovault result remains marked Pre-owned at £1,244.82 + £13 postage, 100% positive feedback (254), but no direct item ID or seller item location could be verified. Other direct results remain new/sealed or non-UK; not accepted.
- Apple iPhone 18 256GB: no base model used listing surfaced. Current used iPhone 18 results are Pro/Pro Max variants and cannot be substituted.

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

No evidence inserted, updated or deactivated. No master product, valuation, visibility, lifecycle, tenant/customer data or schema changed.

## Next action
Continue to verify the nanovault direct listing and UK item location. Continue monitoring exact-variant used/refurbished supply. Do not use direct new offers, overseas sellers, wrong iPhone model variants, or unverified marketplace snippets as evidence.
