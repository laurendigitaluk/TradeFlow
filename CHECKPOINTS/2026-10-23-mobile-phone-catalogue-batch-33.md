# Mobile Phone Catalogue Checkpoint — Batch 33
Date: 2026-10-23

## Work completed
Added UK new-price evidence to TEST first and promoted the same evidence to LIVE for the following existing phone variants:

- Apple iPhone 18 Pro 256GB — £1,199, official Apple UK buy page: https://www.apple.com/uk/shop/buy-iphone/iphone-18-pro
- Apple iPhone 18 Pro Max 256GB — £1,299, official Apple UK 6.9-inch/256GB/Black variant page: https://www.apple.com/uk-business/shop/buy-iphone/iphone-18-pro/6.9-inch-display-256gb-black
- Apple iPhone Duo 256GB — £1,999, official Apple UK buy page. Available from 23 October 2026: https://www.apple.com/uk/shop/buy-iphone/iphone-duo
- Google Pixel 11 Pro 256GB / 12GB RAM — £1,079, official Google Store UK configuration page: https://store.google.com/gb/config/pixel_11_pro?hl=en-GB
- Motorola Edge 70 Plus 256GB — £497 comparison price, SmartphoneChecker lists £499 at Mobiles.co.uk less £2 with code CASH2; last updated 21 October 2026: https://www.smartphonechecker.co.uk/phones/motorola/edge-5g-70-plus. Secondary source; retailer checkout and code eligibility should be confirmed.

## Evidence quality controls
- All evidence is stored with GBP, positive observed price, source URL, stable unique source key, date observed, and explicit source/availability notes.
- Prices are new/list prices, not used-market values or buying offers.
- Two less precise price comparison rows were made inactive in both TEST and LIVE because the summary source did not confirm exact storage capacity:
  - OPPO Find X10 256GB, £1,097 comparison price.
  - Samsung Galaxy A18 4G 128GB, £247 comparison price.
- Those two variants were hidden from customer visibility in TEST and LIVE pending exact-capacity confirmation. Their evidence rows remain inactive for audit. Do not reactivate until a source confirms the storage variant.
- Earlier secondary Xiaomi 17T and Xiaomi 17T Pro comparison rows remain inactive; the exact official Xiaomi UK campaign evidence is primary. Campaign prices £549 and £699 expire 27 October 2026 or while stock lasts and must be rechecked.
- OnePlus 15 256GB remains supported by a £849 UK price reference, but availability is only listed/uncertain; do not claim in-stock until direct checkout is confirmed.

## Verified database snapshot after Batch 33
Counts are from direct TEST and LIVE queries, counting distinct products and distinct evidence records.

- TEST: 130 active customer-visible variants; 156 evidence rows total (145 active, 11 inactive); 0 active customer-visible variants missing active evidence; 0 evidence integrity failures.
- LIVE: 128 active customer-visible variants; 151 evidence rows total (143 active, 8 inactive); 62 active UK used completed-sale rows; 3 UK used/listed rows; 0 active customer-visible variants missing active evidence; 0 active evidence integrity failures.

## Next actions
1. Continue adding evidence in small validated batches and promote to LIVE promptly.
2. Recheck Xiaomi 17T / 17T Pro campaign after 27 October 2026.
3. Confirm exact UK retail storage variants before activating the OPPO Find X10 256GB or Galaxy A18 4G 128GB records.
4. Keep OnePlus 15 availability as listed/uncertain until checkout can be verified.
