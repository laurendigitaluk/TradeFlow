# Mobile Phone Catalogue — Batch 51
Date: 24 October 2026
Environment flow: TEST first, then LIVE.
Scope: two new UK eBay completed-sale observations for Apple iPhone 15 128GB.

## Evidence added

1. **Apple iPhone 15 128GB Black, unlocked** — eBay UK item 307125916358; sold 15 August 2026. Displayed buyer total £281.50 including £11.50 Buyer Protection. Best Offer accepted; accepted item price/seller proceeds are not confirmed. Battery health and cosmetic grade not established. URL: https://www.ebay.co.uk/itm/307125916358. Stable key: `mobile-used-sold-iphone15-128gb-ebay-307125916358-20260815`.
2. **Apple iPhone 15 128GB Black, parts-only** — eBay UK item 278434257815; sold 5 October 2026. Displayed buyer total £49.56 including £2.16 Buyer Protection. Listing explicitly says “For parts or not working”; Best Offer was available but acceptance was not confirmed. Exclude from working-phone valuation benchmarks. URL: https://www.ebay.co.uk/itm/278434257815. Stable key: `mobile-used-sold-iphone15-128gb-parts-ebay-278434257815-20261005`.

## Verification

Stable item URLs/keys were checked in both environments before insertion. Both records were inserted into TEST first and then inserted into LIVE with matching keys and notes.

- TEST: 202 active phone evidence rows; 108 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; both Batch 51 keys active.
- LIVE: 200 active phone evidence rows; 106 active UK used completed-sale rows; 0 basic phone-scoped URL/key/positive GBP price/currency failures; 0 duplicate active source-key groups; both Batch 51 keys active.

Buyer Protection totals are buyer-facing totals, not seller proceeds. Preserve condition and Best Offer caveats. Keep historical listing observations distinct and continue TEST-first validation followed by prompt LIVE promotion.
