# Project Memory — Xbox Console Catalogue Batch 1
Date: 30 October 2026

## Scope
Added Microsoft Xbox console catalogue records and verified UK used-market evidence in TradeFlow TEST first, then mirrored the same shared catalogue and evidence into TradeFlow LIVE. No tenant, customer, transaction, domain, storefront ownership, Stripe, or subscription records were changed.

## Catalogue records
Created Microsoft manufacturer record (reused existing if present), Xbox Consoles branch under Gaming Consoles & Accessories, and 13 active customer-visible product/package variants in each environment:
- Xbox 360: 4GB, 250GB, 500GB
- Xbox One: 500GB, 1TB
- Xbox One S: 500GB, 1TB
- Xbox One S All-Digital Edition: 1TB
- Xbox One X: 1TB
- Xbox Series S: 512GB, 1TB Carbon Black
- Xbox Series X: 1TB Disc
- Xbox Series X Digital Edition: 1TB

## UK market evidence
Added 11 unique UK eBay completed-sale evidence records in TEST and the same 11 in LIVE, each with GBP price, direct listing URL, sale date, condition, source key and notes. Product IDs were mapped independently by model/package between environments.

Research listing IDs and observed prices:
- Xbox 360 E 250GB: 147399338517 £34.17; Xbox 360 S 250GB with controller: 406983995633 £57.42.
- Xbox One S 500GB: 860075245338 £40.00; 227452025440 £49.99.
- Xbox One S 1TB: 157990623685 £41.92; 227584691449 £67.75.
- Xbox One X 1TB: 336746788067 £134.92; 168682015736 £59.50 (console only, no controller).
- Xbox Series S: 227560758629 £306.11. Listing title did not explicitly state storage; record notes this is provisional mapping to the standard 512GB variant pending item-specifics confirmation. Do not use this record as a firm 512GB valuation reference until confirmed.
- Xbox Series X 1TB: 318913964795 £336.00; 206599920276 £417.54.

## Verification
Read-after-write checks confirmed:
- TEST: 13 Xbox products; 11 active Xbox evidence records.
- LIVE: 13 Xbox products; 11 active Xbox evidence records.
Both environments use their own category, manufacturer, branch and product UUIDs. No valuation rules or automatic valuation inputs were changed.

## Outstanding
1. Confirm the storage capacity for eBay listing 227560758629; if not explicitly 512GB, move its evidence to the correct model/variant or deactivate it.
2. Continue exact UK listing research for missing Xbox 360 4GB/500GB, original Xbox One 500GB/1TB, Xbox One S All-Digital 1TB, Xbox Series S 1TB Carbon Black and Xbox Series X Digital Edition 1TB.
3. Reconcile full catalogue/evidence parity using stable keys; this batch alone does not resolve historical TEST/LIVE drift.
4. Keep TEST-first workflow: verify TEST, then mirror shared catalogue/evidence to LIVE using mapped environment-specific IDs. Keep all tenant/customer/business data separate.
