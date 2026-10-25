# TradeFlow Mobile Phone Catalogue — Batch 85
Date: 25 October 2026

## Summary
Added one UK eBay used-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Green. Exact active master match and exact URL/stable-key preflight were clear in TEST and LIVE. TEST was inserted and returned the expected row before LIVE was inserted and returned. No master products were created.

## Record added
- Original listing: https://www.ebay.co.uk/itm/178236367409
- Sold: 29 June 2026 at 16:58 BST / 15:58 UTC.
- Condition: Used; colour Green; 256GB.
- Listing price displayed: £589.99.
- Postage shown separately: £9.99 (Other Courier, 3 days); not included in observed item price.
- No separate Buyer Protection fee or Best Offer accepted notice was displayed in the captured page.
- Seller: UK business seller in Tyne and Wear.
- Seller proceeds not independently confirmed; displayed item price is not seller net proceeds.
- Stable key: `mobile-used-sold-pixel10proxl-256gb-green-ebay-178236367409-20260629`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `d46b4081-09f0-4562-acf3-5b18d9a7ded3`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `9fe9a33e-9ab0-41df-bbc6-08c25d1607e6`

## Counts verified after Batch 85
- TEST: 257 active Mobile Phones evidence rows; 159 active `uk_used` + sold; 4 active `uk_new` + sold.
- LIVE: 255 active Mobile Phones evidence rows; 157 active `uk_used` + sold; 4 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Existing audit flags
- Batch 78 item 128026023099 recorded at £399.99 while later search result displayed £479.99 incl Buyer Protection.
- Batch 81 item 257522963688 original item page showed £578.85 incl £17.77 fee while search index showed £576.01 incl £14.93 fee.
- Batch 82 item 178468385751 original item page showed £649.14 incl £19.14 fee while search index showed £646.08 incl £16.08 fee.
- These discrepancies remain documented and historical rows have not been silently changed.

## Next
Continue distinct UK completed-sale research. Verify exact active master in both environments; preflight exact URL and stable key; insert/read back TEST first, then LIVE. Exclude listings where Best Offer acceptance is explicit but accepted price is hidden.
