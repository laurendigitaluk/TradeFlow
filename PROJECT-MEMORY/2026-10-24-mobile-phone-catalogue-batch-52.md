# Project Memory — Mobile Phone Catalogue Batch 52
Date: 24 October 2026

Two UK eBay completed-sale observations added to TEST, then LIVE:
- iPhone 15 128GB Pink, unlocked, sold 19 Oct 2026, displayed £309.99; boxed, very good condition, 88% battery health per listing; Best Offer available, acceptance unconfirmed; Buyer Protection amount not separately shown. Item 406870328033. Key `mobile-used-sold-iphone15-128gb-pink-ebay-406870328033-20261019`.
- Galaxy S24 128GB with faulty fingerprint sensor, sold 29 Aug 2026, displayed £110 including Buyer Protection (fee amount not separately captured); explicitly “For parts or not working”, exclude from typical working-phone benchmarks. Item 128043891213. Key `mobile-used-sold-galaxy-s24-128gb-parts-ebay-128043891213-20260829`.

Post-batch phone-category checks:
- TEST: 204 active phone evidence rows, 110 active UK used sold rows; zero basic integrity failures and zero duplicate active source-key groups; both batch keys active.
- LIVE: 202 active phone evidence rows, 108 active UK used sold rows; zero basic integrity failures and zero duplicate active source-key groups; both batch keys active.

Buyer-facing totals are not necessarily seller proceeds. Preserve condition and Best Offer caveats. Continue TEST-first insertion, prompt LIVE promotion, and verify exact batch rows plus aggregate integrity.
