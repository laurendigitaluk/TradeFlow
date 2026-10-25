# Project Memory — Mobile Phone Catalogue Batch 77
Date: 25 October 2026

Batch 77 added two UK eBay new/sealed completed-sale observations for Google Pixel 10 Pro 256GB Obsidian to TEST and LIVE using the exact active master. Exact URL/key preflight was clear. TEST inserts/read-backs preceded LIVE insertion/read-backs; no existing records changed.

- Item 117212924862 sold 5 Jul 2026 14:55 BST; displayed buyer-facing total £691.83 including £16.83 Buyer Protection. TEST evidence 54138811-eb8c-43c9-9989-c145d2015625; LIVE evidence 54503726-50cb-4569-88b6-e57770b6052b. Stable key `mobile-new-sold-pixel10pro-256gb-obsidian-ebay-117212924862-20260705`.
- Item 236875676375 sold 25 Jun 2026 09:46 BST; displayed buyer-facing total £605.42 including £15.42 Buyer Protection. TEST evidence 1c89897b-4ea4-478c-afa0-ca8b531a4223; LIVE evidence 8440e8a6-b4b5-4de9-bc80-f5db5a5874f9. Stable key `mobile-new-sold-pixel10pro-256gb-obsidian-ebay-236875676375-20260625`.
Both are recorded as `evidence_type='uk_new'`, `availability='sold'`, `item_condition='New - sealed'`; seller proceeds not independently confirmed.

Verified counts after Batch 77: TEST 249 active phone evidence / 153 active `uk_used` + sold / 2 active `uk_new` + sold; LIVE 247 / 151 / 2. The two-row difference persists. Global active duplicate-key aggregation remains outstanding.

Candidates with relisted/current-price conflicts or undisclosed accepted Best Offer prices were excluded. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-77.md`.

Continue TEST-first with exact active master, URL/key preflight and read-back. Do not create master products during evidence ingestion; keep new/sealed distinct from used and Buyer Protection amounts explicit.
