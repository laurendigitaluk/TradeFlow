# Project Memory — Mobile Phone Catalogue Batch 51
Date: 24 October 2026

Added two eBay UK completed-sale observations for Apple iPhone 15 128GB to TEST, then promoted to LIVE:
- Black, unlocked, sold 15 Aug 2026: £281.50 displayed buyer total including £11.50 Buyer Protection; Best Offer accepted; battery health/grade not confirmed. Item 307125916358. Key `mobile-used-sold-iphone15-128gb-ebay-307125916358-20260815`.
- Black, explicitly “For parts or not working”, sold 5 Oct 2026: £49.56 displayed buyer total including £2.16 Buyer Protection; Best Offer acceptance not confirmed. Exclude from working-phone benchmarks. Item 278434257815. Key `mobile-used-sold-iphone15-128gb-parts-ebay-278434257815-20261005`.

Post-batch phone-category checks:
- TEST: 202 active phone evidence rows, 108 active UK used sold rows, zero basic integrity failures, zero duplicate active keys; both batch keys active.
- LIVE: 200 active phone evidence rows, 106 active UK used sold rows, zero basic integrity failures, zero duplicate active keys; both batch keys active.

Buyer Protection totals are buyer-facing, not seller proceeds. Preserve non-working and accepted-offer caveats. Continue checking stable keys in both environments, inserting TEST first, promoting to LIVE promptly, and verifying exact batch rows and aggregate integrity after every batch.
