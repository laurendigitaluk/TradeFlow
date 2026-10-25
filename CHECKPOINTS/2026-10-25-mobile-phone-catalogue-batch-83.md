# TradeFlow Mobile Phone Catalogue — Batch 83
Date: 25 October 2026

## Summary
Added one UK eBay new-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Black, listed as boxed, new and unlocked. Exact active master match and exact URL/stable-key preflight were clear in TEST and LIVE. Inserted and read back TEST before LIVE insertion/read-back. No master products created and no existing evidence overwritten.

## Record added
- URL: https://www.ebay.co.uk/itm/178516971817
- Sold: 22 September 2026 at 20:43 BST / 19:43 UTC.
- Condition: New.
- Original eBay item page displayed £656.73 including £16.26 Buyer Protection.
- Seller location: Luton, United Kingdom.
- No Best Offer option or accepted-offer notice appeared on the captured original page.
- Seller proceeds not independently confirmed; buyer-facing total is not seller net proceeds.
- Stable key: `mobile-new-sold-pixel10proxl-256gb-black-ebay-178516971817-20260922`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `4e0f3332-7bc3-467a-9dc6-18a2845da52a`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `a32bb8b5-0b1f-45da-be8d-b8c48571a242`

## Counts verified after Batch 83
- TEST: 255 active Mobile Phones evidence rows; 158 active `uk_used` + sold; 3 active `uk_new` + sold.
- LIVE: 253 active Mobile Phones evidence rows; 156 active `uk_used` + sold; 3 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Existing audit flags
- Batch 78 item 128026023099 recorded at £399.99 while later search result displayed £479.99 incl Buyer Protection; preserve history pending source audit.
- Batch 81 item 257522963688 original item page showed £578.85 incl £17.77 fee while search index showed £576.01 incl £14.93 fee.
- Batch 82 item 178468385751 original item page showed £649.14 incl £19.14 fee while search index showed £646.08 incl £16.08 fee.
- These source discrepancies remain documented and have not been silently corrected.

## Next
Continue distinct UK completed-sale research. Verify exact active master in both environments; preflight exact source URL and stable key; insert/read back TEST first, then LIVE. Exclude listings where Best Offer acceptance is explicit but accepted price is hidden. Keep source-price discrepancies explicit.
