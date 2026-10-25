# TradeFlow Mobile Phone Catalogue — Batch 78
Date: 25 October 2026

## Summary
Added one UK eBay used completed-sale observation for Samsung Galaxy S25 Ultra 256GB Black, explicitly disclosing a chipped corner and visible scratches. Exact active master matching and exact URL/stable-key preflight were clean in TEST and LIVE. Inserted into TEST and read back before LIVE insertion; LIVE record then read back. No existing rows or master products were changed.

## Record added
- Product: Samsung Galaxy S25 Ultra 256GB Black, unlocked
- eBay URL: https://www.ebay.co.uk/itm/128026023099
- Sold: 17 August 2026 at 08:44 BST (07:44 UTC)
- Original listing page displayed £399.99 with Buyer Protection included. The separate fee and seller proceeds were not confirmed.
- Condition: Used; title explicitly states chipped corner / visible scratches.
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-black-chipped-scratches-ebay-128026023099-20260817`
- TEST master: `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence: `8c2f73c1-a064-4c05-91df-5f38a0437e83`
- LIVE master: `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence: `4a25dc41-af63-4b48-96de-093f9e314a2b`

## Counts verified after Batch 78
Direct Mobile Phones category counts:
- TEST: 250 active phone evidence rows; 154 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 248 active phone evidence rows; 152 active `uk_used` + sold; 2 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists.
- Global active duplicate-key aggregation remains outstanding.

## Candidate safeguards
- iPhone 16 Pro 256GB item 137835281735 was already active in both environments and was not duplicated.
- Samsung Galaxy S25 256GB Navy item 327123081209 had Best Offer available; accepted price is not confirmed, so excluded.
- Samsung Galaxy S25 256GB item 157995784914 was already active in both environments, so not duplicated.
- Several other results were opened-unused or multi-quantity listings without a clear individual completed-sale price; not ingested as used-sale observations.

## Next
Continue UK completed-sale research. Match exact active master in TEST and LIVE; preflight exact URL and stable key; insert/read back TEST first, then LIVE. Keep condition-specific damage notes, Buyer Protection and accepted-offer uncertainty explicit. Do not create master products during evidence ingestion.
