# Mobile Catalogue UK Market Evidence Expansion — Batch 114
Date: 5 November 2026

## Preflight
Rechecked batch 113 checkpoint and current LIVE/TEST Supabase state. Confirmed exact active product master IDs and package keys for the two target variants. Confirmed no active duplicate source URL or stable source key before insert. No code or schema changes.

## New UK retail evidence inserted in both environments
### Motorola Edge 70 Plus 8GB/256GB
- Retailer: Argos
- Direct URL: https://www.argos.co.uk/product/9654763
- Price: £499.99 GBP
- Condition: New
- Observed: 5 November 2026
- Availability: listed (Add to trolley shown; local stock/delivery requires postcode check)
- Stable source key: mobile-new-motorola-edge70plus-256gb-argos-9654763-20261105
- LIVE master: 4da6cf8a-bc1d-4012-ae23-43214d32ee22
- TEST master: 018599e7-86a6-4b50-a267-5d2ccddb8076
- LIVE evidence: 4af13ff5-a357-4a9f-91c6-4c252c51fc19
- TEST evidence: 28e2260c-03b9-4f20-ac67-1e86995df5aa

### OPPO Find X10 Pro Max 12GB/512GB
- Retailer: Currys
- Direct URL: https://www.currys.co.uk/products/oppo-find-x10-pro-max-512-gb-luna-white-10312083.html
- Price: £1,499.00 GBP
- Condition: New
- Observed: 5 November 2026
- Availability: listed (captured page price/specs; stock not explicitly confirmed)
- Stable source key: mobile-new-oppo-findx10promax-512gb-currys-10312083-20261105
- LIVE master: 93cb19f9-8a90-4d9e-a02d-a1c70ab471a2
- TEST master: d026d651-5d8a-483a-8732-bec0efcba445
- LIVE evidence: fc8e9167-0cc1-4455-87f5-e23b01ee2f1e
- TEST evidence: acabf972-24c1-44e4-83b2-23af2ec59542

Both rows are UK-new retail asking-price evidence only, not used/refurbished or completed sales. No used price was imported.

## Used-market research
No direct item-level UK used/refurbished evidence verified for any of the four exact gaps:
1. Motorola Edge 70 Plus 8GB/256GB — no used/refurb offer; MoneySavingExpert refurb filter reports no Pristine refurb result. Argos offer is new.
2. OPPO Find X10 12GB/256GB — surfaced eBay exact-model results are opened-never-used/new or lack verified item-level used condition.
3. OPPO Find X10 Pro Max 12GB/512GB — eBay pre-owned category/search results lack direct verified listing details; direct Currys page is new.
4. OPPO Reno16 F 5G 8GB/256GB — £379.99 Certified - Refurbished eBay search result remains without direct item URL/grade details. Do not import.
No variant substitution or estimated prices.

## Post-write verification
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active mobile products | 156 | 156 |
| Active evidence rows | 565 | 565 |
| UK-new evidence | 269 | 269 |
| UK-used evidence | 296 | 296 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |
| Active evidence attached to inactive products | 0 | 0 |

All 565 active evidence rows match across environments by model, storage variant, evidence type, source URL, price, condition and sales channel. No differences or duplicate insertions. The one-product master count difference remains the hidden/unverified TEST-only iPhone 18 256GB; leave it untouched.

UK-used remains reference-only and excluded from automatic valuation. No code/schema/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes and no deployment.
