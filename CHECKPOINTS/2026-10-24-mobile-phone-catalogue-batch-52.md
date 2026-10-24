# Mobile Phone Catalogue — Batch 52
Date: 24 October 2026
Flow: TEST first, then LIVE.

## Evidence added

1. **Apple iPhone 15 128GB Pink, unlocked** — eBay UK item 406870328033; sold 19 October 2026. Displayed £309.99. Listing describes boxed, very good condition and 88% battery health. Best Offer was available but acceptance was not confirmed. The captured extract did not separately show a Buyer Protection amount; do not infer seller proceeds or a fee breakdown. URL: https://www.ebay.co.uk/itm/406870328033. Key: `mobile-used-sold-iphone15-128gb-pink-ebay-406870328033-20261019`.
2. **Samsung Galaxy S24 128GB, fingerprint sensor faulty** — eBay UK item 128043891213; sold 29 August 2026. Displayed £110.00 including Buyer Protection; fee amount not separately captured. Listing explicitly says fingerprint sensor not working and condition “For parts or not working”; exclude from typical working-phone benchmarks. URL: https://www.ebay.co.uk/itm/128043891213. Key: `mobile-used-sold-galaxy-s24-128gb-parts-ebay-128043891213-20260829`.

## Verification
The item URLs and stable keys were checked in both environments before insertion. Both records were inserted into TEST first and then LIVE.

- TEST: 204 active phone evidence rows; 110 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; both Batch 52 keys active.
- LIVE: 202 active phone evidence rows; 108 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; both Batch 52 keys active.

Keep condition and offer caveats explicit. Do not use the non-working Galaxy S24 as a typical working-phone comparable. Displayed buyer totals are not necessarily seller proceeds. Continue TEST-first validation and prompt LIVE promotion.
