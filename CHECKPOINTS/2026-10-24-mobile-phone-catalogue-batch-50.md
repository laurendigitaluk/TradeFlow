# Mobile Phone Catalogue — Batch 50

Date: 24 October 2026
Repository: `laurendigitaluk/TradeFlow`

Added three fresh UK eBay iPhone 15 128GB completed-sale observations. Stable keys were checked absent in both environments before insertion; records were inserted into TEST first and then promoted to LIVE.

1. iPhone 15 128GB White, unlocked — £217.58 displayed buyer total including £7.58 Buyer Protection; sold 11 Sep 2026. Listing title says “Read Description”; underlying caveat is not fully established in the captured extract, so retain this caveat-bearing observation and do not assume typical working condition. https://www.ebay.co.uk/itm/278364248917. Key: `mobile-used-sold-iphone15-128gb-ebay-278364248917-20260911`.
2. iPhone 15 128GB Black with box — £258.92 displayed buyer total including £8.92 Buyer Protection; Best Offer accepted; sold 22 Sep 2026. Listing says seller relisted this item or one like it, so preserve this observation separately from other records. https://www.ebay.co.uk/itm/318900425831. Key: `mobile-used-sold-iphone15-128gb-ebay-318900425831-20260922`.
3. iPhone 15 128GB White — £207.25 displayed buyer total including £7.25 Buyer Protection; Best Offer accepted; sold 2 Aug 2026. Explicitly marked “For parts or not working”; do not use as a typical working-phone benchmark. https://www.ebay.co.uk/itm/366574722022. Key: `mobile-used-sold-iphone15-128gb-ebay-366574722022-20260802`.

Post-batch checks using each environment's own phone-category ID:
- TEST: 200 active phone evidence rows; 106 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.
- LIVE: 198 active phone evidence rows; 104 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.

Buyer Protection totals are buyer-facing totals, not seller proceeds. Keep “Read Description”, relisting and non-working caveats explicit. Continue TEST-first, promote validated evidence promptly, and avoid overwriting historical listing observations.
