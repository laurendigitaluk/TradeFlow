# Project Memory — Mobile Phone Catalogue Batch 53
Date: 24 October 2026

Added two fresh UK eBay completed-sale observations for Google Pixel 9 128GB to TEST and then LIVE:
- Obsidian Black unlocked, sold 15 Jun 2026, displayed £299.99, Best Offer available but acceptance/Buyer Protection breakdown not confirmed, UK business seller. Item 336605085498. Key `mobile-used-sold-pixel9-128gb-ebay-336605085498-20260615`.
- Obsidian unlocked, sold 24 Jul 2026, displayed £269.95, listing title says 99% battery health and very good condition; Best Offer acceptance/Buyer Protection amount not confirmed, UK business seller. Item 800383181227. Key `mobile-used-sold-pixel9-128gb-ebay-800383181227-20260724`.

Also verified the existing Galaxy S24 128GB Onyx Black completed sale, item 257702271643 (£237.75 including £8.23 Buyer Protection, six bids), already active in both TEST and LIVE. Do not duplicate it.

Post-batch:
- TEST: 206 active phone evidence, 112 active UK used sold, zero basic integrity failures, zero duplicate active source-key groups; all three batch keys active.
- LIVE: 204 active phone evidence, 110 active UK used sold, zero basic integrity failures, zero duplicate active source-key groups; all three batch keys active.

A unique-key conflict during the attempted combined LIVE insert was handled safely by querying the existing record; the two new Pixel rows were then inserted separately. Future preflight must check source_record_key globally and not rely only on URL filtered by category. Preserve buyer-facing price/fee distinctions and caveats.
