# Mobile Phone Catalogue Batch 43 — 24 October 2026

Three distinct UK eBay completed-sale observations were inserted in TEST, then promoted to LIVE. The source keys were checked absent before insertion and all three rows were returned by the insert calls.

- Apple iPhone 16 128GB Teal, working/excellent description: £429.70 including £12.54 Buyer Protection; source mentions seller relisted this item or one like it. Preserve as a separate historical observation; do not assume it is the same physical device as another listing. https://www.ebay.co.uk/itm/287579080965. Key: `mobile-used-sold-iphone16-128gb-ebay-287579080965-20260914`.
- Apple iPhone 16 128GB Ultramarine: £440.00, sold 14 Sep 2026. Title says “NO FLAWS”, while description text also refers to professionally refurbished/moderate wear. Condition inconsistency is retained; do not classify as confirmed pristine. Buyer Protection fee not separately captured. https://www.ebay.co.uk/itm/366668186600. Key: `mobile-used-sold-iphone16-128gb-ebay-366668186600-20260914`.
- Samsung Galaxy S24 128GB Purple (SM-S921B/DS): £269.25 including £9.25 Buyer Protection; Best Offer accepted, sold 1 Aug 2026. Treat as buyer-facing displayed total, not seller proceeds. https://www.ebay.co.uk/itm/198530912410. Key: `mobile-used-sold-galaxy-s24-128gb-ebay-198530912410-20260801`.

Fresh post-batch aggregate checks:
- TEST: 179 active phone evidence rows; 85 active UK used completed-sale rows; 0 phone-scoped URL/key/positive-GBP/currency integrity failures; 0 duplicate active source keys.
- LIVE: 177 active phone evidence rows; 83 active UK used completed-sale rows; 0 phone-scoped URL/key/positive-GBP/currency integrity failures; 0 duplicate active source keys.

TEST-first then LIVE promotion completed. Continue to preserve historical price observations, distinguish buyer-facing totals from seller proceeds, and record condition/listing caveats instead of silently normalising them.
