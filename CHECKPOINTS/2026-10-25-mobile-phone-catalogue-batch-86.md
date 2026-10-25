# TradeFlow Mobile Phone Catalogue — Batch 86
Date: 25 October 2026

## Summary
Added one UK eBay new-condition completed-sale observation for Samsung Galaxy S25 256GB Silver. Exact active master match and exact URL/stable-key preflight were clear in TEST and LIVE. TEST was inserted and returned the expected row before LIVE was inserted and returned. No master products were created.

## Record added
- Original listing: https://www.ebay.co.uk/itm/286331524320
- Sold: 15 August 2026 at 15:32 BST / 14:32 UTC.
- Condition: New, sealed; Silver; 256GB; factory unlocked UK model.
- Displayed price: £629.00 including Buyer Protection; separate fee amount not shown.
- Listing stated no charger included and showed out of stock / 4 sold.
- Seller: UK business in Warminster, Wiltshire.
- No explicit Best Offer accepted notice visible. Seller proceeds not independently confirmed.
- Stable key: `mobile-new-sold-galaxys25-256gb-silver-ebay-286331524320-20260815`
- TEST master: `a5730c3d-21c7-459d-91f6-b2fc49e9dcd1`; evidence: `861bb4af-4259-44be-9651-e73e4c69c898`
- LIVE master: `45854c43-9c3c-479c-9f35-714d9bb426f4`; evidence: `c04445ad-bbd0-4587-a055-371898e2b199`

## Coverage verified after Batch 86
- LIVE: 130 active Mobile Phones products; 70 with active new-price evidence; 66 with active second-hand evidence; 0 products missing both types; 60 missing new-price evidence; 64 missing second-hand evidence; 0 product notes explicitly say discontinued.
- TEST: 134 total Mobile Phones products (133 active); 70 with active new-price evidence; 68 with active second-hand evidence; 2 missing both types; 64 missing new-price evidence; 66 missing second-hand evidence; 10 product notes mention discontinued.
- TEST/LIVE master-product discrepancy and status-field limitations remain outstanding. LIVE master table has no dedicated discontinued field, so note-text count is not authoritative lifecycle status.
- Global active duplicate-key aggregation remains outstanding. Price discrepancies from batches 78, 81 and 82 remain open.

## Next
Continue distinct UK completed-sale research. Verify exact active master in both environments; preflight exact URL and stable key; insert/read back TEST first, then LIVE. Do not create master products during evidence ingestion.
