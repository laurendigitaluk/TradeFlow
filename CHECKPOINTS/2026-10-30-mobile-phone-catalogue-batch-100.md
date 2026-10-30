# Mobile Phone Catalogue — Batch 100 Exact-Variant UK Listing Sweep

Date: 30 October 2026
Status: Search and database recheck complete. No qualifying new used/refurbished evidence; no database writes.

## Scope
Five distinct missing products remain (nine environment-specific gaps):
- TEST: Apple iPhone 18 256GB (hidden); Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.
- LIVE: Motorola Edge 70 Plus 256GB; OPPO Find X10 256GB (hidden); OPPO Find X10 Pro Max 512GB; OPPO Reno16 F 5G 256GB.

## Search findings
- OPPO Find X10 Pro Max 512GB: eBay UK continues to surface nanovault listing “OPPO Find X10 Pro Max 512GB Luna White 5G Hasselblad Mint Condition Boxed UK”, marked Pre-owned at £1,244.82 plus £13 postage; seller feedback shown as 100% (254). However, a direct listing URL and UK item location could not be verified from the search result. Keep as a lead only; do not insert. Other surfaced exact-model listings are new or opened-never-used.
- OPPO Find X10 256GB: exact eBay result remains £920.88 new retail; no qualifying used/refurbished result. MoneySavingExpert exact model page reports 256GB and £999 new retail, not used.
- OPPO Reno16 F 5G 256GB: eBay exact 256GB listings remain explicitly NEW & SEALED, including £439.99; no used/refurbished exact variant found.
- Motorola Edge 70 Plus 256GB: eBay exact 256GB offer remains Brand New Sealed at £430. The surfaced pre-owned Motorola Edge 70 listing is a different model (not Edge 70 Plus), so excluded.
- Apple iPhone 18 256GB: base model expected spring 2027; iPhone 18 Pro listings are not the same model and must not be used.

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

Both environments' exact missing-product queries returned the same lists as Batch 99. No rows inserted, updated or deactivated. No master product, valuation, visibility, lifecycle, tenant/customer data or schema changed.

## Next action
Verify the nanovault direct item URL and UK item location before considering it. Continue searching exact UK pre-owned/refurbished stock; reject new, sealed, opened-never-used, wrong-model, overseas or unverifiable offers.
