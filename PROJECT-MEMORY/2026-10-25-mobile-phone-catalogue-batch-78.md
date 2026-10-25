# Project Memory — Mobile Phone Catalogue Batch 78
Date: 25 October 2026

Batch 78 added one UK eBay used completed-sale observation for Samsung Galaxy S25 Ultra 256GB Black, unlocked, with disclosed chipped corner and visible scratches. The exact active master and exact URL/stable-key preflight were clear in TEST and LIVE. TEST insert/read-back preceded LIVE insertion/read-back. No existing records or masters changed.

- URL: https://www.ebay.co.uk/itm/128026023099
- Sold 17 Aug 2026 at 08:44 BST; displayed buyer-facing total £399.99 with Buyer Protection included. Separate fee and seller proceeds not confirmed.
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-black-chipped-scratches-ebay-128026023099-20260817`
- TEST master `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence `8c2f73c1-a064-4c05-91df-5f38a0437e83`.
- LIVE master `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence `4a25dc41-af63-4b48-96de-093f9e314a2b`.

Counts after Batch 78: TEST 250 active phone evidence / 154 active `uk_used` + sold / 2 active `uk_new` + sold; LIVE 248 / 152 / 2. Two-row difference persists. Global active duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-78.md`.

Continue TEST-first, verify exact active master and URL/key, read back each insert. Do not create masters during evidence ingestion. Preserve damaged-condition context and do not imply seller proceeds when only buyer-facing totals are visible.
