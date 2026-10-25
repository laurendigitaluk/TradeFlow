# TradeFlow Mobile Phone Catalogue — Batch 82
Date: 25 October 2026

## Summary
Added one UK eBay completed-sale observation for Google Pixel 10 Pro XL 256GB Porcelain/white, condition “Opened – never used”. Exact active master match and exact URL/stable-key preflight were clear in TEST and LIVE. Inserted and read back TEST before LIVE insertion/read-back. No master products created and no existing evidence overwritten.

## Record added
- URL: https://www.ebay.co.uk/itm/178468385751
- Sold: 11 September 2026 at 21:06 BST / 20:06 UTC.
- Condition: Opened – never used; factory unlocked; no charger included.
- Original item page showed buyer-facing total £649.14 including £19.14 Buyer Protection.
- Search index showed £646.08 including £16.08 Buyer Protection. Original page used as source-of-record capture; discrepancy documented in row notes.
- Best Offer was available, but the captured original page did not show “Best offer accepted”. Displayed sold total is retained with this limitation noted; seller proceeds not independently confirmed.
- Stable key: `mobile-opened-sold-pixel10proxl-256gb-white-ebay-178468385751-20260911`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `0bc38469-6a22-4613-8554-0608991d0456`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `5594202c-993b-45fd-988a-98fdeb4beff6`
- Evidence type is `uk_used` to follow the established catalogue convention for opened-never-used condition; item_condition preserves the exact condition.

## Counts verified after Batch 82
- TEST: 254 active Mobile Phones evidence rows; 158 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 252 active Mobile Phones evidence rows; 156 active `uk_used` + sold; 2 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Existing audit flags
- Batch 78 item 128026023099 is recorded at £399.99 while a later search result displayed £479.99 incl Buyer Protection; preserve history pending source audit.
- Batch 81 item 257522963688 original item page showed £578.85 incl £17.77 fee while search index showed £576.01 incl £14.93 fee; discrepancy retained.
- Batch 82 item 178468385751 original item page showed £649.14 incl £19.14 fee while search index showed £646.08 incl £16.08 fee; discrepancy retained.

## Next
Continue distinct UK completed-sale research. Verify exact active master in both environments; preflight exact source URL and stable key; insert/read back TEST first, then LIVE. Exclude listings whose accepted Best Offer price is explicitly hidden. Keep page/index price discrepancies explicit and do not silently overwrite historical evidence.
