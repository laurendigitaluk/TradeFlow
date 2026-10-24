# Mobile Phone Catalogue Batch 44 — 24 October 2026

Three additional distinct UK eBay completed-sale observations were added to TEST, promoted to LIVE, and included in fresh phone-scoped integrity checks.

- Google Pixel 9 128GB Obsidian Black, unlocked: £347.76 including £11.19 Buyer Protection; Best Offer accepted; sold 20 Jun 2026. https://www.ebay.co.uk/itm/298415131329. Key: `mobile-used-sold-pixel9-128gb-ebay-298415131329-20260620`.
- Apple iPhone 16 128GB Ultramarine, unlocked, 90% battery health: £374.67 including £11.63 Buyer Protection; sold 12 Jul 2026. https://www.ebay.co.uk/itm/327147326675. Key: `mobile-used-sold-iphone16-128gb-ebay-327147326675-20260712`.
- Samsung Galaxy S24 128GB Marble Grey, listing title indicates excellent condition: £368.00; sold 19 Jul 2026. Buyer Protection fee was not separately captured in the available source excerpt. https://www.ebay.co.uk/itm/376877291140. Key: `mobile-used-sold-galaxy-s24-128gb-ebay-376877291140-20260719`.

Post-batch aggregate counts:
- TEST: 182 active phone evidence rows; 88 active UK used completed-sale rows; zero phone-scoped URL/key/positive GBP price/currency integrity failures; zero duplicate active source keys.
- LIVE: 180 active phone evidence rows; 86 active UK used completed-sale rows; zero phone-scoped URL/key/positive GBP price/currency integrity failures; zero duplicate active source keys.

The three stable keys were checked absent from both environments before insertion. TEST inserts and LIVE promotions returned the expected keys. Continue TEST-first then LIVE; preserve historical observations and distinguish buyer-facing totals including Buyer Protection from seller proceeds.
