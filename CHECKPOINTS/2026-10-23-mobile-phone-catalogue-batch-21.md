# Mobile Phone Catalogue — Batch 21 Checkpoint
Date: 2026-10-23

## Scope
Added seven UK new-price/listing evidence records, keeping new-price evidence separate from completed-sale evidence. Promoted the validated batch to TradeFlow LIVE without copying customer or transaction data.

## Evidence added
| Product variant | Observed price | Source type | Notes |
|---|---:|---|---|
| HONOR 600 256 GB | £599.99 | HONOR UK online store | Manufacturer-store listed price. Which? price comparison currently shows lower marketplace offers; do not describe £599.99 as the lowest UK market price. |
| HONOR 600 Smart 128 GB | £249.99 | Argos | Exact 128 GB product listing; stock is postcode-dependent. |
| Xiaomi 17T 256 GB | £549.00 | Xiaomi UK | Temporary autumn campaign price vs £649 original price; terms run 11–27 Oct 2026 or while stock lasts. |
| Xiaomi 17T Pro 512 GB | £699.00 | Xiaomi UK | Temporary autumn campaign price vs £849 original price; terms run 11–27 Oct 2026 or while stock lasts. |
| HONOR Magic8 Lite 256 GB | £349.99 | HONOR UK | After-coupon shop price; HONOR buying guide lists £399.99 standard price. Coupon eligibility may apply. |
| Samsung Galaxy S26+ 256 GB | £1,179.00 | Samsung UK | Official UK buy page displayed 256 GB/12 GB as in stock. |
| Samsung Galaxy A27 5G 256 GB | £209.99 | eBay UK business seller | Current new listing with 20 available at observation. This is an asking/listing price, not completed-sale evidence. |

## Source URLs
- HONOR 600 official store: https://www.honor.com/uk/shop/
- HONOR 600 256 GB variant reference: https://www.which.co.uk/reviews/mobile-phones/honor-600-256gb-8gb
- HONOR 600 Smart 128 GB Argos: https://www.argos.co.uk/product/8920821
- Xiaomi autumn campaign terms: https://www.mi.com/uk/support/terms/xiaomi-autumn-sales-campaign-tc/
- HONOR Magic8 Lite store: https://www.honor.com/uk/shop/
- HONOR Magic8 Lite buying guide: https://www.honor.com/uk/shop/buying-guide/introducing-honor-magic8-lite/
- Samsung Galaxy S26+ buy page: https://www.samsung.com/uk/smartphones/galaxy-s26/buy/?modelCode=SM-S947BZKDEUB
- Samsung Galaxy A27 5G listing: https://www.ebay.co.uk/itm/287456740841

## TEST snapshot after batch 21
- 126 active customer-visible phone variants.
- 112 evidence rows total; 109 active, 3 inactive retained for audit.
- 15 active customer-visible variants remain without active evidence.
- The TEST product count has moved from the 123 active count in the Batch 20 checkpoint to 126; use this fresh database query as authoritative and investigate the extra rows when auditing remaining gaps.

## LIVE snapshot after batch 21
- 107 active customer-visible phone variants.
- 107 evidence rows total, all 107 active.
- 58 active UK used completed-sale rows.
- Zero active visible variants missing active evidence.
- Zero active evidence integrity failures (missing URL/key, non-positive price, or non-GBP currency).

## Validation and exclusions
- The seven evidence rows use exact product/storage variants and stable source keys.
- New listing prices and promotional prices are not completed-sale comparables and must not be used as such.
- Xiaomi 17T/17T Pro promotion expires 27 October 2026 or earlier if stock runs out; recheck and update/retire the promotional evidence after expiry rather than treating it as permanent RRP.
- Do not use the misleading OnePlus 15 eBay listing whose item specifics identify OnePlus 10 Pro.
- A search result purporting to be Nothing Phone (4b) redirected to earbud content; it was rejected as invalid phone evidence.
- The live promotion added the seven validated variants to LIVE. No customer, order, payment or other TEST transaction data was copied.

## Next action
Continue the remaining 15 active TEST variants without evidence. Prioritise exact UK official/authorised current price evidence where available; use exact-variant completed UK sales for used valuation. Verify model identity/lifecycle before marking discontinued. Re-query TEST and LIVE after each batch and promote validated records promptly.
