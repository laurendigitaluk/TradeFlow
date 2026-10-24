# Mobile Phone Catalogue — Batch 53
Date: 24 October 2026
Flow: TEST-first, then LIVE.

## Evidence and reconciliation

1. **Google Pixel 9 128GB Obsidian Black, unlocked** — eBay UK item 336605085498; sold 15 June 2026. Displayed £299.99. Best Offer was available but acceptance and any Buyer Protection fee breakdown were not confirmed in the captured source. UK business seller. URL: https://www.ebay.co.uk/itm/336605085498. Key: `mobile-used-sold-pixel9-128gb-ebay-336605085498-20260615`.
2. **Google Pixel 9 128GB Obsidian, unlocked** — eBay UK item 800383181227; sold 24 July 2026. Displayed £269.95. Listing title states 99% battery health and very good condition. Best Offer acceptance and Buyer Protection amount were not confirmed. UK business seller. URL: https://www.ebay.co.uk/itm/800383181227. Key: `mobile-used-sold-pixel9-128gb-ebay-800383181227-20260724`.
3. **Samsung Galaxy S24 128GB Onyx Black, 8GB RAM** — eBay UK item 257702271643; sold 1 September 2026. Displayed £237.75 including £8.23 Buyer Protection; six bids. This row already existed in TEST and LIVE, so it was reconciled/read-verified rather than duplicated. URL: https://www.ebay.co.uk/itm/257702271643. Key: `mobile-used-sold-galaxy-s24-128gb-ebay-257702271643-20260901`.

## Verification

Two new Pixel 9 records were inserted into TEST first and then LIVE. The Galaxy S24 entry was already present in both; a LIVE unique-key conflict was safely resolved by reading the existing record, not by altering it or creating a duplicate.

- TEST: 206 active phone evidence rows; 112 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; all three keys active.
- LIVE: 204 active phone evidence rows; 110 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; all three keys active.

Buyer Protection totals are buyer-facing, not seller proceeds. Keep Best Offer and battery/condition caveats. Continue TEST-first insertion and prompt LIVE promotion, with a pre-insert check of stable keys and source name because the source key is globally unique.
