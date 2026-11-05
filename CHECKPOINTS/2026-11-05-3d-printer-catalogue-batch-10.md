# 3D Printer Catalogue — Batch 10 Checkpoint (Corrected Final State)

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main | **LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi | **LIVE Supabase:** gxsrajtqzdjvmceqcpgv

## New Prusa Research products

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | UK price | Availability |
|---|---|---|---|---|---:|---|
| CORE One+ (Gen 2) | 3a7c7b10-8f01-4d3e-a101-000000000101 | 5b7c7b10-8f01-4d3e-a101-000000000101 | 4a7c7b10-8f01-4d3e-a101-000000000204 | 5b7c7b10-8f01-4d3e-a101-000000000204 | £909.00 from | In stock; two purchase options |
| CORE One L+ | 3a7c7b10-8f01-4d3e-a101-000000000102 | 5b7c7b10-8f01-4d3e-a101-000000000102 | 4a7c7b10-8f01-4d3e-a101-000000000205 | 5b7c7b10-8f01-4d3e-a101-000000000205 | £1,829.00 | In stock |
| XL+ Single-Tool | 3a7c7b10-8f01-4d3e-a101-000000000103 | 5b7c7b10-8f01-4d3e-a101-000000000103 | 4a7c7b10-8f01-4d3e-a101-000000000206 | 5b7c7b10-8f01-4d3e-a101-000000000206 | £2,099.00 | Ships in 4–5 weeks |

Prusa Research manufacturer IDs: TEST 97419947-01c4-40f6-aa2a-487686a0e1dd; LIVE 87611b06-50b7-444c-8137-35ea962f227b. Current source: https://www.fabinity.com/brands/prusa. CORE One+ is an advertised from-price with two options; confirm exact assembly/configuration before quotation.

## New Flashforge model

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | UK price |
|---|---|---|---|---|---:|
| CJ270 | 6c7c7b10-8f01-4d3e-a101-000000000301 | 7c7c7b10-8f01-4d3e-a101-000000000301 | 6c7c7b10-8f01-4d3e-a101-000000000302 | 7c7c7b10-8f01-4d3e-a101-000000000302 | £3,499.00 |

Source: https://uk.flashforge.com/products/flashforge-cj270. The official page still includes pre-order timeline text (first 100 units scheduled to ship 15 October; subsequent orders in purchase order). Current fulfilment status is not independently confirmed; do not display as confirmed in-stock.

## Flashforge price-source correction

Current indexed official UK collection snapshot confirms:
- AD5X — £299.00
- Adventurer 5M — £209.00
- Adventurer 5M Pro — £339.00

Source: https://uk.flashforge.com/collections/3d-printers. These prices match the existing active 4 November evidence already stored. An intermediate Batch 10 observation based on an older cached page showed £359/£259/£399; those three rows were deactivated in both environments and retained as historical only:
- TEST evidence: 4a7c7b10-8f01-4d3e-a101-000000000201, 4a7c7b10-8f01-4d3e-a101-000000000202, 4a7c7b10-8f01-4d3e-a101-000000000203.
- LIVE evidence: 5b7c7b10-8f01-4d3e-a101-000000000201, 5b7c7b10-8f01-4d3e-a101-000000000202, 5b7c7b10-8f01-4d3e-a101-000000000203.

## Final independent verification — 3D Printers category only

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 145 | 145 |
| Active customer-visible products | 145 | 145 |
| Active evidence rows | 159 | 159 |
| Active uk_new evidence | 144 | 144 |
| Active uk_used evidence | 15 | 15 |
| Manufacturers represented | 13 | 13 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Duplicate active source keys | 0 | 0 |
| Missing evidence URLs or keys | 0 | 0 |
| Non-positive prices / non-GBP evidence | 0 | 0 |
| uk_new condition mismatches | 0 | 0 |

## Scope
No category or branch creation. No schema, application code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work; no Worker deployment required. TEST and LIVE use environment-specific UUIDs. Used evidence remains reference-only and must not affect automatic valuation.
