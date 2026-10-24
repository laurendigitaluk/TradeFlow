# Mobile Phone Catalogue — Batch 49

Date: 24 October 2026
Repository: `laurendigitaluk/TradeFlow`

Added three fresh UK eBay used-phone completed-sale observations, checked the stable source keys absent in TEST and LIVE before insertion, inserted to TEST first, then promoted the same observations to LIVE.

1. Apple iPhone 15 128GB Blue, factory unlocked — £269.25 displayed buyer total, including £9.25 Buyer Protection; sold 23 Sep 2026. The item price/seller proceeds are not separately captured. https://www.ebay.co.uk/itm/398420637687. Key: `mobile-used-sold-iphone15-128gb-ebay-398420637687-20260923`.
2. Apple iPhone 15 128GB Black — £265.99 displayed buyer total, including £10.99 Buyer Protection; Best Offer accepted; sold 27 Sep 2026. The accepted item price/seller proceeds are not separately shown. https://www.ebay.co.uk/itm/188991253809. Key: `mobile-used-sold-iphone15-128gb-ebay-188991253809-20260927`.
3. Apple iPhone 16 128GB Green, locked to Sky Mobile — £391.92 displayed buyer total, including £11.92 Buyer Protection; sold 22 Aug 2026. Keep the network-lock caveat; this is not directly comparable with unlocked devices. https://www.ebay.co.uk/itm/800546931991. Key: `mobile-used-sold-iphone16-128gb-ebay-800546931991-20260822`.

Post-batch integrity checks (phone category joined through each environment's own category ID):
- TEST: 197 active phone evidence rows; 103 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.
- LIVE: 195 active phone evidence rows; 101 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.

The integrity check intentionally tests URL presence/HTTP format rather than restricting all existing evidence to eBay URLs, since the phone catalogue includes other valid source types. Preserve Buyer Protection totals as buyer-facing totals, not seller proceeds. Continue TEST-first and promote validated evidence promptly.
