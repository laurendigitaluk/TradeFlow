# Mobile Phone Used-Evidence Research — Batch 110
Date: 5 November 2026

## Scope and preflight
Continued exact-variant UK used-price research for the four shared gaps in TradeFlow LIVE and TEST. Before research, current active master/evidence rows were inspected in both projects and compared against batch 109 checkpoint. Both environments still contain the same shared four used-evidence gaps:
1. Motorola Edge 70 Plus — 256GB
2. OPPO Find X10 — 256GB (12GB RAM variant)
3. OPPO Find X10 Pro Max — 512GB
4. OPPO Reno16 F 5G — 256GB (8GB RAM variant)
The TEST-only hidden, unverified iPhone 18 256GB remains a separate no-evidence record and is not to be copied, activated, published, deactivated or deleted without separate verification/decision.

## Research outcomes
### OPPO Reno16 F 5G 8GB/256GB
Current eBay UK search result: Certified - Refurbished, £379.99, seller fistech_uk (99.6% positive, 273 feedback), free delivery and free returns. Search result URL: https://www.ebay.co.uk/shop/oppo-reno-5g?_nkw=oppo+reno+5g
The result does not expose a direct item URL, seller dispatch location or full refurbishment grade/description. A separate direct listing for exact Reno16 F 5G 256GB at £439.99 is explicitly New: https://www.ebay.co.uk/itm/407078357250 . It is not used evidence. Hold the £379.99 candidate until direct item-level verification.

### OPPO Find X10 Pro Max 512GB
eBay UK search result surfaced a Pre-owned listing at £1,276.42 plus £11.50 postage. Search result: https://www.ebay.co.uk/b/bn_74874824
No direct item URL, seller identity/location or detailed condition could be verified. Do not import the category result.
Direct page found at £1,293.70 is explicitly New and located in Forest Row, UK: https://www.ebay.co.uk/itm/820280763288 . Another search result at £1,120.23 is Opened – never used. Both are excluded as used evidence.

### OPPO Find X10 12GB/256GB
An exact UK-model result at £876.03 is classified Opened – never used: https://www.ebay.co.uk/shop/find-x2?_nkw=find+x2 . An exact 256GB Global Version listing at £999.99 is dispatched from Baltana, India: https://www.ebay.co.uk/itm/840048864921 . Neither qualifies as UK used evidence. Do not use them as used comparables.

### Motorola Edge 70 Plus 256GB
Targeted eBay UK searches did not produce a verifiable exact used listing. Do not substitute Edge 70 base, Pro, Fusion, other model family members or other storage variants.

## Decision and database change status
No evidence rows were inserted, updated or deactivated in batch 110. No accepted direct item-level evidence met the required standard. No database changes were necessary; do not fabricate evidence to force catalogue counts.

## Evidence rules
Exact model/storage/RAM variant; UK market and seller/dispatch location; GBP price; verifiable used/refurbished condition and grading; direct item-level URL; observed date. Keep new, opened-never-used, overseas dispatch, category/search pages and adjacent variants excluded. Certified refurbished retail must remain separately classified from ordinary used and completed-sale evidence. UK-used is reference-only and does not feed automatic valuation.

## Change boundary
No code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. Existing TEST-only hidden/unverified iPhone 18 remains untouched.

## Next action
Continue targeted search for direct item links and full listing details for the four common gaps. Once a candidate passes, verify source-key uniqueness and matching product IDs independently in LIVE and TEST, write the same shared evidence to both, then read back both databases.
