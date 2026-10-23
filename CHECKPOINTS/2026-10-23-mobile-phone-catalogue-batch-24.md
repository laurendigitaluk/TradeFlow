# Mobile Phone Catalogue — Batch 24 Checkpoint
Date: 2026-10-23

## Scope
Added seven exact-variant UK price/listing evidence records to TEST and promoted the same checked records to LIVE. Hid the Motorola Edge 70 256 GB seed from customer visibility because the UK retailer listings found in this pass were for the 512 GB model, not a verified 256 GB SKU.

## Evidence added

| Product variant | Price | Evidence type/status | Source and caveats |
|---|---:|---|---|
| HMD Skyline 8 GB / 256 GB | £334.69 | UK new listing, listed | PriceSpy exact-variant page shows one UK retailer offer in stock at £334.69. The “from £229” lowest-price indicator has no direct offer link; £334.69 is the explicit in-stock offer captured. https://pricespy.co.uk/product.php?p=13704611 |
| Motorola Edge 70 Pro 8 GB / 256 GB | £499.00 | UK new listing reference, listed | GSMSpecs price page reports Amazon UK listing at £499 on 11 Oct 2026. Secondary price-reference page, not a direct Amazon product page; reverify direct checkout price before treating as current. https://www.gsmspecs.com/motorola/motorola-edge-70-pro/price-in-uk |
| Motorola moto g37 5G 128 GB | £189.99 | UK new listing, listed | Exact Argos product page, reduced from £199.99. Stock is postcode-dependent. https://www.argos.co.uk/product/8547376 |
| Nothing Phone (3a) Pro 256 GB | £342.99 | UK used/refurbished listing, listed | Excellent-refurbished eBay Live listing; seller location Stockport, UK. Asking price only, not completed-sale evidence. https://www.ebay.co.uk/itm/306825338007 |
| OPPO Reno13 5G 256 GB | £254.27 | UK used/refurbished listing, out of stock | Currys Clearance listing; page shows Excellent - Refurbished, out of stock and 21 sold historically. £254.27 is seller-displayed recent-sales/listing information, not a verified price for an individual completed transaction. https://www.ebay.co.uk/itm/357863172681 |
| realme 14 Pro+ 5G 12 GB / 512 GB | £745.00 | UK new listing, listed | KICKmobiles eBay listing; seller address Kensington, London. Listing has a long dispatch window and mentions import-fee rules, so verify UK checkout delivery/fees. Asking price only. https://www.ebay.co.uk/itm/297091357141 |
| REDMI Note 15 Pro+ 5G 12 GB / 512 GB | £179.56 | UK used completed-sale indicator, sold | Sold 23 Sep 2026, seller located Swadlincote, UK. Displayed price includes £6.36 Buyer Protection; “or Best Offer” means accepted amount may differ. https://www.ebay.co.uk/itm/318904561579 |

Stable source keys are in the evidence rows and begin `mobile-new-` or `mobile-used-` with the exact variant and source ID.

## Product identity correction
- Motorola Edge 70 256 GB: set `customer_visible=false` in TEST pending exact UK SKU confirmation. Currys and Argos UK listings found for the standard Edge 70 are 512 GB; do not infer a 256 GB model or reuse the 512 GB price. Product remains active and is not marked discontinued.
- Motorola Edge 70 Pro 256 GB remains visible with a price-reference evidence row, but that source is secondary and points to Amazon UK as of 11 Oct. Direct retailer verification remains desirable.

## Rejected / pending
- OnePlus 15 256 GB remains without evidence. Official UK early-bird terms state the final price is displayed at the final payment stage; the £849 figure found in a OnePlus community post was not treated as a currently verified checkout price.
- realme GT 7 Pro 512 GB remains without UK-local evidence. Search results found a sold listing from a Germany-based seller and other listings shipping from China; these were rejected as UK-local comparables.
- The misleading OnePlus 15 listing whose item specifics identify OnePlus 10 Pro remains rejected.

## Verified database snapshot after Batch 24
- TEST: 123 active customer-visible variants; 122 evidence rows total (119 active, 3 inactive retained for audit); 2 active customer-visible variants remain without active evidence.
- LIVE: 117 active customer-visible variants; 117 evidence rows, all active. 59 UK used completed-sale rows (`uk_used` + availability `sold`) and 2 UK secondary-market listing rows with availability `listed`; additional out-of-stock refurbished listing evidence remains separately classified.
- LIVE missing-evidence check: 0.
- LIVE integrity check: 0 active evidence rows with missing URL/key, non-positive price, or non-GBP currency.

## Next action
Continue resolving only the two remaining visible TEST gaps—OnePlus 15 256 GB and realme GT 7 Pro 512 GB—without forcing non-UK or misleading evidence. Recheck Xiaomi 17T/17T Pro campaign prices after 27 Oct 2026. Continue prompt TEST → LIVE promotion and integrity checks.
