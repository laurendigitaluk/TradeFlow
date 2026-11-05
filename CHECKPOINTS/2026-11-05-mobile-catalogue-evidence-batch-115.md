# TradeFlow Mobile Catalogue Evidence Expansion — Batch 115
Date: 5 November 2026

## Preflight
- Re-fetched batch 114 checkpoint and project memory from `laurendigitaluk/TradeFlow`.
- Queried LIVE project `gxsrajtqzdjvmceqcpgv` and TEST project `nnsshnfkjcflucjrftzi` before writes.
- Confirmed current mobile counts at 565 active evidence rows in each environment, and the same four common used-evidence gaps plus the hidden TEST-only iPhone 18 256GB.
- Confirmed the product/evidence table columns and exact product UUIDs separately in each environment.
- Retired TEST project `twfbmjwwqzxdxvclxbun` was not used.

## New UK retail evidence inserted in both environments

### OPPO Find X10 — 12GB RAM / 256GB
- Source: MoneySavingExpert / Amazon
- Source URL: https://www.moneysavingexpert.com/cheap-mobile-finder/sim-free/oppo/find-x10/
- Price: £999.00 GBP
- Condition: New
- Observed: 5 November 2026
- Availability: `listed`; retailer checkout/stock not independently confirmed
- Stable source key: `mobile-new-oppo-findx10-256gb-mse-amazon-999-20261105`
- LIVE master: `b4497d9b-e2ef-46f3-ad36-9d027cfb81f4`
- TEST master: `40b46ce3-efd4-48d9-9b87-1ba9947ca54c`
- LIVE evidence: `42058543-f8a2-4e8e-9d8b-67a6c689870a`
- TEST evidence: `3ea43a8c-2e59-4d1d-8912-85291fc8ae94`

The previous product note stated it was temporarily hidden pending exact UK storage-variant price verification. The comparison source verifies the exact 12GB/256GB UK variant at £999, so the existing product was made customer-visible in both environments. No new master product was created.

### OPPO Reno16 F 5G — 8GB RAM / 256GB
- Source: Which? / Amazon
- Source URL: https://www.which.co.uk/reviews/mobile-phones/oppo-reno16-f-5g-256gb-8gb
- Price: £366.99 GBP
- Condition: New
- Observed: 5 November 2026
- Availability: `in_stock` as reported by Which?; not independently checked at Amazon checkout
- Stable source key: `mobile-new-oppo-reno16f5g-256gb-which-amazon-36699-20261105`
- LIVE master: `7743d2a2-c0d7-428d-9451-17400d1587f7`
- TEST master: `c2de3ce1-f57a-4ffd-9557-5216fa574496`
- LIVE evidence: `771e1124-9f97-4233-aa17-5440e2f87fb9`
- TEST evidence: `14f0fa26-fd30-4f58-a4df-ae9137034f94`

Both are UK-new retail asking-price observations only, not used/refurbished evidence or completed sales.

## Used-market research
No new qualifying direct item-level UK used/refurbished evidence was imported for the four common gaps:
1. Motorola Edge 70 Plus 8GB/256GB — no exact used/refurb listing with a verified direct item page found.
2. OPPO Find X10 12GB/256GB — eBay surfaced exact-model listings at £821.20/£876.03, but they are explicitly opened-never-used, not used.
3. OPPO Find X10 Pro Max 12GB/512GB — eBay surfaced a pre-owned £1,073.08 result and other category results, but a direct item URL and seller/condition detail set could not be verified. Held, not imported.
4. OPPO Reno16 F 5G 8GB/256GB — eBay surfaced a £379.99 Certified - Refurbished result from fistech_uk (99.6% positive, 273 feedback), but only a category/search result was verifiable, not a direct item-level page with grade details. Held, not imported.

No variant substitution, estimated used prices or misclassification of new/opened-never-used listings.

## Post-write verification
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active mobile products | 157 | 157 |
| Active evidence rows | 567 | 567 |
| UK-new evidence | 271 | 271 |
| UK-used evidence | 296 | 296 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |
| Active evidence attached to inactive products | 0 | 0 |

The comparable evidence fingerprint is identical in LIVE and TEST (`99ee861ca68573f6e645a3d80dc1d597`) across model, package, evidence type, source URL, price, condition and sales channel. Both newly inserted source keys, prices and variant mappings were read back in both environments. The only active-product count difference remains the hidden/unverified TEST-only iPhone 18 256GB, which was not changed.

UK-used evidence remains reference-only and excluded from automatic valuation. No code/schema/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes and no deployment.
