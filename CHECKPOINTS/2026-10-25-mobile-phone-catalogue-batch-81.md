# TradeFlow Mobile Phone Catalogue — Batch 81
Date: 25 October 2026

## Summary
Added one UK eBay used completed-sale observation for Google Pixel 10 Pro XL 256GB Obsidian, factory unlocked. Exact active master match and exact URL/stable-key preflight were clear in TEST and LIVE. Inserted and read back TEST before LIVE insertion/read-back. No master products created and no existing evidence overwritten.

## Record added
- URL: https://www.ebay.co.uk/itm/257522963688
- Sold: 20 July 2026 at 15:55 BST / 14:55 UTC
- Condition: Used
- Displayed buyer-facing total on original item page: £578.85 including £17.77 Buyer Protection.
- No charger included.
- Search index showed a conflicting total of £576.01 including £14.93 Buyer Protection. Original item page was used as the source-of-record capture; the discrepancy is explicitly recorded in notes. Seller proceeds not independently confirmed.
- Stable key: `mobile-used-sold-pixel10proxl-256gb-obsidian-ebay-257522963688-20260720`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `743ca969-f948-4f4a-b7eb-345c4ba8fb4a`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `cb456f2b-635b-44e2-882f-fb7a1623ea1c`

## Counts verified after Batch 81
- TEST: 253 active phone evidence; 157 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 251 active phone evidence; 155 active `uk_used` + sold; 2 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Existing audit flags
- Batch 78 item 128026023099 is recorded at £399.99 while later search result displayed £479.99 incl Buyer Protection; preserve history pending source audit.
- Batch 81 item 257522963688 original item page displayed £578.85 incl £17.77 fee while search index showed £576.01 incl £14.93 fee; page capture used as source of record and discrepancy retained in notes.

## Next
Continue UK completed-sale research. Match active master in both environments; exact URL and stable-key preflight; insert/read back TEST first, then LIVE. Keep price capture differences explicit and do not silently overwrite evidence.
