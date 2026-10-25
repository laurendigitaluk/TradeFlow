# Project Memory — Mobile Phone Catalogue Batch 87
Date: 25 October 2026

Batch 87 added two UK eBay new-condition completed-sale observations to existing exact product masters in TEST and LIVE. Both source URLs and stable keys were preflighted clear; TEST insert/read-back preceded LIVE insert/read-back. No master products were created or changed.

1. Apple iPhone 17 Pro 256GB Orange, item 820214209970, sold 8 Oct 2026 at 14:35 BST. Original page displayed £890.00 including Buyer Protection (fee amount not shown); brand new/sealed, unlocked, London business seller. Stable key `mobile-new-sold-iphone17pro-256gb-orange-ebay-820214209970-20261008`. TEST evidence `0163611d-87fc-43fc-be59-da26c924edcb`; LIVE `b2db7455-c13d-4cf7-ba58-349d86575333`.
2. Apple iPhone 17 Pro Max 512GB Orange, item 407282798006, sold 12 Oct 2026 at 12:59 BST. Original page displayed £1,006.52 including £26.52 Buyer Protection; brand new, factory unlocked, Windsor private seller. Stable key `mobile-new-sold-iphone17promax-512gb-orange-ebay-407282798006-20261012`. TEST evidence `29465532-c8b2-4cf6-b225-c561a2286ef7`; LIVE `afd58902-207a-48ba-9e46-81f5dc858042`.

Both values are buyer-facing totals, not seller proceeds. No Best Offer acceptance notice appeared on either captured page.
Coverage after batch: LIVE 130 active phone products / 72 with new evidence / 66 with used evidence / 0 missing both / 258 active evidence rows / 7 new-sold / 157 used-sold. TEST 133 active products / 72 with new / 68 with used / 1 missing both / 260 active evidence rows / 7 new-sold / 159 used-sold.
Outstanding: TEST/LIVE master discrepancy, global active duplicate-key audit, historical source-price audit. LIVE has no dedicated discontinued field; lifecycle should be verified from official/manufacturer sources and documented in notes, keeping products active for second-hand valuation.
See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-87.md`.
