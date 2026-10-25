# TradeFlow Mobile Phone Catalogue — Batch 84
Date: 25 October 2026

## Summary
Added one UK eBay new-condition completed-sale observation for Google Pixel 10 Pro XL 256GB Obsidian. Exact active master match and exact URL preflight were clear in TEST and LIVE. TEST insert returned the complete row; LIVE was then inserted and its row returned. No master products created and no existing evidence intentionally overwritten.

## Record added
- URL: https://www.ebay.co.uk/itm/278210429467
- Sold: 24 July 2026 at 14:36 BST / 13:36 UTC.
- Condition: New; factory unlocked; 2-year manufacturer warranty; no charger included.
- Original listing displayed £674.99 and indicated two sold. No separate Buyer Protection fee was displayed.
- Seller: UK business seller in London.
- No Best Offer option was displayed on the captured page.
- Seller proceeds not independently confirmed; displayed listing total is not seller net proceeds.
- Stable key: `mobile-new-sold-pixel10proxl-256gb-obsidian-ebay-278210429467-20260724`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `2cdf6b7f-fd39-4553-953f-812c44ccef5e`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `47292b1b-a783-47c1-bfdb-d6ecd59bd2e1`

## Counts verified after Batch 84
- TEST: 256 active Mobile Phones evidence rows; 158 active `uk_used` + sold; 4 active `uk_new` + sold.
- LIVE: 254 active Mobile Phones evidence rows; 156 active `uk_used` + sold; 4 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Existing audit flags
- Batch 78 item 128026023099 recorded at £399.99 while later search result displayed £479.99 incl Buyer Protection.
- Batch 81 item 257522963688 original item page showed £578.85 incl £17.77 fee while search index showed £576.01 incl £14.93 fee.
- Batch 82 item 178468385751 original item page showed £649.14 incl £19.14 fee while search index showed £646.08 incl £16.08 fee.
- These discrepancies remain documented and historical rows have not been silently changed.

## Next
Continue distinct UK completed-sale research. Verify exact active master in both environments; preflight exact URL and stable key; insert/read back TEST first, then LIVE. Exclude listings where Best Offer acceptance is explicit but accepted price is hidden.
