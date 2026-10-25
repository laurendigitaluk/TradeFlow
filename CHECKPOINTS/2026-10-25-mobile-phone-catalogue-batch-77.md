# TradeFlow Mobile Phone Catalogue — Batch 77
Date: 25 October 2026

## Summary
Added two UK eBay new/sealed completed-sale observations for the active Google Pixel 10 Pro 256GB master product. Exact source URL and stable-key preflight was clear in TEST and LIVE. Both rows were inserted in TEST and read back before LIVE insertion; LIVE rows were then read back and verified. No existing evidence or master rows were changed.

## Records added

### Google Pixel 10 Pro 256GB Obsidian — new/sealed
- eBay item: https://www.ebay.co.uk/itm/117212924862
- Sold: 5 July 2026 at 14:55 BST (13:55 UTC)
- Displayed buyer-facing total: £691.83 including £16.83 Buyer Protection; seller proceeds not independently confirmed.
- Stable key: `mobile-new-sold-pixel10pro-256gb-obsidian-ebay-117212924862-20260705`
- TEST master: `a20d14bc-aaab-4b82-9e5f-214dfb048547`; evidence: `54138811-eb8c-43c9-9989-c145d2015625`
- LIVE master: `4a2d71c3-0bb2-4633-8c86-56f401ee5a9d`; evidence: `54503726-50cb-4569-88b6-e57770b6052b`

### Google Pixel 10 Pro 256GB Obsidian — new/sealed
- eBay item: https://www.ebay.co.uk/itm/236875676375
- Sold: 25 June 2026 at 09:46 BST (08:46 UTC)
- Displayed buyer-facing total: £605.42 including £15.42 Buyer Protection; seller proceeds not independently confirmed.
- Stable key: `mobile-new-sold-pixel10pro-256gb-obsidian-ebay-236875676375-20260625`
- TEST master: `a20d14bc-aaab-4b82-9e5f-214dfb048547`; evidence: `1c89897b-4ea4-478c-afa0-ca8b531a4223`
- LIVE master: `4a2d71c3-0bb2-4633-8c86-56f401ee5a9d`; evidence: `8440e8a6-b4b5-4de9-bc80-f5db5a5874f9`

## Counts verified after Batch 77
Direct Mobile Phones category counts:
- TEST: 249 active phone evidence rows; 153 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 247 active phone evidence rows; 151 active `uk_used` + sold; 2 active `uk_new` + sold.
- The two-row TEST/LIVE difference persists.
- Global active duplicate-key aggregation remains outstanding; do not claim a complete global duplicate audit.

## Candidate safeguards
- Pixel 10 Pro 256GB used item 307091345876 was already active in both environments and was not duplicated.
- Pixel 10 Pro 256GB used item 406957270591 has Best Offer accepted, so the actual accepted price is not displayed; not added in this batch.
- Galaxy S25 Ultra item 278194017129 currently resolves to a relisted page with a different current asking price, so it was not used as historical sold-price evidence.
- Galaxy S25 Ultra item 168204541224 also showed a changed/relisted page and conflicting current price context; it remains excluded.

## Next
Continue UK completed-sale research. Match exact active master in TEST and LIVE; preflight exact URL and stable key; insert/read back TEST first, then LIVE. Preserve condition class (new vs used), Buyer Protection, and accepted-offer uncertainty. Do not create master products as part of evidence ingestion.
