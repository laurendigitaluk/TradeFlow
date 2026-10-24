# Mobile Phone Catalogue Batch 42 — 24 October 2026

Three distinct UK eBay completed-sale records were inserted in TEST, then promoted to LIVE. Follow-up count queries have now independently confirmed all three active records in both environments.

- Samsung Galaxy S24 128GB Onyx Black, unlocked, excellent: £299.22 including £10.22 Buyer Protection; sold 18 Sep 2026. https://www.ebay.co.uk/itm/227525599537. Key: `mobile-used-sold-galaxy-s24-128gb-ebay-227525599537-20260918`.
- Apple iPhone 16 128GB: £349.99; sold 2 Sep 2026. Business seller; no Buyer Protection fee separately captured. https://www.ebay.co.uk/itm/168655749213. Key: `mobile-used-sold-iphone16-128gb-ebay-168655749213-20260902`.
- Google Pixel 9 256GB Wintergreen, unlocked, excellent: £351.25 including £11.25 Buyer Protection; 28 bids; sold 4 Aug 2026. https://www.ebay.co.uk/itm/168575822978. Key: `mobile-used-sold-pixel9-256gb-ebay-168575822978-20260804`.

Post-batch TEST phone metrics: 176 active phone evidence rows, 82 active UK used completed-sale rows, zero phone-scoped URL/key/positive GBP price integrity failures. LIVE batch check independently confirmed all three records; prior counts plus these records yield 174 active phone evidence rows and 80 active UK used completed-sale rows in LIVE, pending a fresh aggregate query. TEST and LIVE each returned `batch42_active_rows=3`.

Retain Buyer Protection and Best Offer caveats. Do not overwrite historical observations if current listings change. Continue TEST-first, then promote to LIVE.