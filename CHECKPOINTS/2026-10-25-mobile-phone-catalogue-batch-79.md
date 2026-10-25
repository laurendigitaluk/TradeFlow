# TradeFlow Mobile Phone Catalogue — Batch 79
Date: 25 October 2026

## Summary
Added one UK eBay used completed-sale observation for Google Pixel 10 Pro XL 256GB unlocked. Exact active master match and exact source URL/stable-key preflight were clear in TEST and LIVE. Inserted into TEST and read back before inserting LIVE and reading it back. No master products created and no existing evidence overwritten.

## Record added
- Product: Google Pixel 10 Pro XL 256GB unlocked
- URL: https://www.ebay.co.uk/itm/227413880546
- Sold: 8 July 2026 at 19:00 BST / 18:00 UTC
- Displayed buyer-facing total: £507.44 including £13.81 Buyer Protection fee; seller proceeds not independently confirmed.
- Condition: Used. Listing states no charger included. Auction ended with 12 bids and no Best Offer ambiguity visible.
- Stable key: `mobile-used-sold-pixel10proxl-256gb-unlocked-ebay-227413880546-20260708`
- TEST master: `5fdf6d3e-3c5e-4fda-b6a8-f245a0c7923f`; evidence: `753183e6-5091-4186-90ca-a85e3c188488`
- LIVE master: `8755fe3c-dd5a-4282-bcef-5775f4200c3a`; evidence: `53d8d266-7ce4-40d4-ab8a-7be66131a644`

## Counts verified after Batch 79
- TEST: 251 active phone evidence; 155 active `uk_used` + sold; 2 active `uk_new` + sold.
- LIVE: 249 active phone evidence; 153 active `uk_used` + sold; 2 active `uk_new` + sold.
- Two-row TEST/LIVE difference persists. Global active duplicate-key aggregation remains outstanding.

## Source-price discrepancy flagged for audit
Batch 78 evidence for eBay item 128026023099 was inserted at £399.99 based on the source value recorded during that ingestion. A later search result/current crawl now shows £479.99 incl Buyer Protection. This may be a changed/relisted page or prior capture discrepancy. Do not silently overwrite historical evidence. Keep the existing row intact pending a dedicated source-discrepancy audit; establish whether a historical price snapshot can be independently verified before any correction or superseding record.

## Candidates excluded / deferred
- Google Pixel 10 Pro Fold 256GB items 257739236306 and 188875352899: no active exact Pixel 10 Pro Fold 256GB master exists in either environment. Do not create masters during evidence ingestion; defer until catalogue-master workflow approves it.
- Galaxy S25 Ultra items already recorded in the catalogue were not duplicated.
- Listings where Best Offer was accepted but actual accepted amount was hidden were excluded.

## Next
Continue UK completed-sale research. Check active exact master in TEST and LIVE, then exact URL and stable key in both. Insert TEST and verify before LIVE. Keep source-price discrepancies visible and never overwrite prior observations without a documented audit.
