# Mobile Phone Catalogue Research and Aligned Evidence — Batch 112
Date: 5 November 2026

## Preflight and scope
Before research, rechecked batch 111 checkpoint and live database state in both TradeFlow projects. Shared mobile evidence counts were aligned at 562 rows (266 UK-new / 296 UK-used). The four shared UK-used gaps remain:
1. Motorola Edge 70 Plus 8GB/256GB
2. OPPO Find X10 12GB/256GB
3. OPPO Find X10 Pro Max 12GB/512GB
4. OPPO Reno16 F 5G 8GB/256GB
The hidden/unverified TEST-only iPhone 18 256GB remains untouched.

## Verified evidence added to both environments
Product: OPPO Reno16 F 5G 8GB RAM / 256GB, Purple Black, SIM-free.
- Source: Currys direct product page https://www.currys.co.uk/products/oppo-reno16-f-5g-256-gb-purple-black-10306159.html
- Observed price: £399.00 GBP
- Condition: New
- Availability: Available for delivery
- Source type: UK-new retail asking price (not a completed sale)
- Observed date: 5 November 2026
- Stable source key: `mobile-new-oppo-reno16f5g-256gb-currys-10306159-20261105`
- LIVE product ID: `7743d2a2-c0d7-428d-9451-17400d1587f7`; evidence ID: `db7f42a1-cd18-41d3-b4c3-c583a329cb6a`
- TEST product ID: `c2de3ce1-f57a-4ffd-9557-5216fa574496`; evidence ID: `189ce5b8-d2f4-4a55-a4a9-9fa7571df760`
The same source key and evidence attributes were inserted into both databases after confirming no existing matching source URL/price observation.

## Further used-market research and exclusions
- Reno16 F 5G 8GB/256GB: eBay UK search result remains Certified - Refurbished £379.99, seller fistech_uk (99.6%, 273 feedback), but no direct item URL, dispatch location or refurb grade details. Hold; no used evidence import.
- Find X10 12GB/256GB: exact UK-model listings surfaced at £821.20 / £876.03 and are classified Opened – never used. Exclude from used evidence.
- Find X10 Pro Max 12GB/512GB: eBay search result £1,073.08 + £11.95 marked Pre-owned, but direct item URL and seller/location/condition verification unavailable. Do not import category/search result.
- Motorola Edge 70 Plus 8GB/256GB: no exact UK used listing verified. Currys direct new listing at £499 confirms exact 8GB/256GB and availability, but is new evidence only: https://www.currys.co.uk/products/motorola-edge-70-plus-256-gb-pantone-mountain-view-10310979.html

## Verified post-write state
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active products | 156 | 156 |
| Active evidence rows | 563 | 563 |
| UK-new evidence rows | 267 | 267 |
| UK-used evidence rows | 296 | 296 |
| Products with UK-used evidence | 154 | 154 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |

The one product master difference is the hidden, unverified TEST-only iPhone 18 256GB. Do not copy, activate, publish, deactivate or delete it without separate verification and decision. Shared evidence rows are aligned.

## Rules and change boundary
UK-used remains reference-only and excluded from automatic valuation. Require exact variant, UK seller/market, GBP, verified condition, observed date and direct item-level URL. No opened-never-used, new, overseas or category-only records as used evidence.
No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment.
