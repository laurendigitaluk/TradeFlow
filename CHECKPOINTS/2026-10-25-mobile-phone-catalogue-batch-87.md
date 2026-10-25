# TradeFlow Mobile Phone Catalogue — Batch 87 Checkpoint
Date: 25 October 2026

## Scope
Added two UK eBay new-condition completed-sale observations to existing exact active product masters. No master products were created or modified. For each observation, exact master match plus URL/stable-key preflight were clear in TEST and LIVE; TEST was inserted and read back before LIVE insertion/read-back.

## Observation 1 — iPhone 17 Pro 256GB Orange
- Original listing: https://www.ebay.co.uk/itm/820214209970
- Sold: 8 October 2026 at 14:35 BST / 13:35 UTC.
- Listing: Apple iPhone 17 Pro, Orange, 256GB, unlocked, brand new and sealed; business seller in London, UK.
- Original page displayed £890.00 including Buyer Protection; fee amount not separately shown. Buyer-facing total only, not seller proceeds.
- No Best Offer acceptance notice shown.
- Stable key: `mobile-new-sold-iphone17pro-256gb-orange-ebay-820214209970-20261008`
- TEST master: `040971e8-3dbb-4188-a091-1d34dd09cbc9`; evidence: `0163611d-87fc-43fc-be59-da26c924edcb`.
- LIVE master: `24ca2a6a-7f03-4a3f-8828-d4d7d9f3b9c7`; evidence: `b2db7455-c13d-4cf7-ba58-349d86575333`.

## Observation 2 — iPhone 17 Pro Max 512GB Orange
- Original listing: https://www.ebay.co.uk/itm/407282798006
- Sold: 12 October 2026 at 12:59 BST / 11:59 UTC.
- Listing: Apple iPhone 17 Pro Max, Orange, 512GB, factory unlocked, brand new; private seller in Windsor, UK.
- Original page displayed £1,006.52 including £26.52 Buyer Protection. Buyer-facing total only, not seller proceeds.
- No Best Offer acceptance notice shown.
- Stable key: `mobile-new-sold-iphone17promax-512gb-orange-ebay-407282798006-20261012`
- TEST master: `a3e7c1a5-8e78-4256-8432-ba83b58315e9`; evidence: `29465532-c8b2-4cf6-b225-c561a2286ef7`.
- LIVE master: `4c172af6-403e-4184-bbd6-51ca423e0351`; evidence: `afd58902-207a-48ba-9e46-81f5dc858042`.

## Verified coverage after Batch 87
Coverage counts are product-level active evidence flags, not evidence-row counts.
- LIVE: 130 active phone products; 72 have active `uk_new` evidence; 66 have active `uk_used` evidence; none are missing both types. Active phone evidence rows: 258; active new/sold rows: 7; active used/sold rows: 157.
- TEST: 133 active phone products; 72 have active `uk_new` evidence; 68 have active `uk_used` evidence; 1 is missing both types. Active phone evidence rows: 260; active new/sold rows: 7; active used/sold rows: 159.
- TEST/LIVE product-master discrepancy remains. Global active duplicate-key aggregation and historical source-price discrepancy audits remain open.
- LIVE has no dedicated lifecycle/discontinued column. Do not mark a model discontinued solely because no current new listing was found. Verify manufacturer/official support or retailer lifecycle evidence, record the source and date in notes where the schema has no lifecycle field, keep the master active for valuation, and prioritise UK second-hand completed-sale evidence. Do not use historical launch price as current new-price evidence.

## Next
Continue filling current new-price evidence gaps first. Where the model is verified discontinued, record lifecycle status with supporting source/date and then prioritise UK second-hand completed-sale observations. Keep condition tiers distinct (sealed-new, opened-never-used, used/refurbished/parts) and preserve Buyer Protection/Best Offer caveats. Always preflight and insert TEST-first, then LIVE; never create master products during evidence ingestion.
