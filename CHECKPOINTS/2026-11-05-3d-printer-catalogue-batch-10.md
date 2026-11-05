# 3D Printer Catalogue — Batch 10 Checkpoint

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main | **LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi | **LIVE Supabase:** gxsrajtqzdjvmceqcpgv

## New Prusa Research products and evidence

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | UK price | Availability |
|---|---|---|---|---|---:|---|
| CORE One+ (Gen 2) | 3a7c7b10-8f01-4d3e-a101-000000000101 | 5b7c7b10-8f01-4d3e-a101-000000000101 | 4a7c7b10-8f01-4d3e-a101-000000000204 | 5b7c7b10-8f01-4d3e-a101-000000000204 | £919.00 from | In stock; two purchase options, from price |
| CORE One L+ | 3a7c7b10-8f01-4d3e-a101-000000000102 | 5b7c7b10-8f01-4d3e-a101-000000000102 | 4a7c7b10-8f01-4d3e-a101-000000000205 | 5b7c7b10-8f01-4d3e-a101-000000000205 | £1,829.00 | In stock |
| XL+ Single-Tool | 3a7c7b10-8f01-4d3e-a101-000000000103 | 5b7c7b10-8f01-4d3e-a101-000000000103 | 4a7c7b10-8f01-4d3e-a101-000000000206 | 5b7c7b10-8f01-4d3e-a101-000000000206 | £2,109.00 | Ships in 4–5 weeks |

Prusa Research manufacturer IDs: TEST 97419947-01c4-40f6-aa2a-487686a0e1dd; LIVE 87611b06-50b7-444c-8137-35ea962f227b.

Sources:
- CORE One+ (Gen 2): https://www.fabinity.com/product/prusa-core-one
- CORE One L+: https://www.fabinity.com/product/prusa-core-one-l
- XL+ Single-Tool: https://www.fabinity.com/product/original-prusa-xl-single-toolhead-3d-printer

## Refreshed Flashforge evidence

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | Price |
|---|---|---|---|---|---:|
| AD5X | 3ed8ec66-1780-4bbc-8a3e-a171ed409b23 | 3d30038d-85d7-49f5-9298-301964e9b260 | 4a7c7b10-8f01-4d3e-a101-000000000201 | 5b7c7b10-8f01-4d3e-a101-000000000201 | £359.00 |
| Adventurer 5M | 117851ae-6c87-4d7e-9d46-133f18d01618 | 307088b9-de33-44ac-939a-e117901e1338 | 4a7c7b10-8f01-4d3e-a101-000000000202 | 5b7c7b10-8f01-4d3e-a101-000000000202 | £259.00 |
| Adventurer 5M Pro | 315796e6-a2f5-4478-9458-e3be1b1d16a0 | 03f9518d-ed17-4c53-b8ef-2776021468b0 | 4a7c7b10-8f01-4d3e-a101-000000000203 | 5b7c7b10-8f01-4d3e-a101-000000000203 | £399.00 |

Source: https://uk.flashforge.com/collections/3d-printers  
Flashforge product pages state printer fulfilment is from international local warehouses, typically 2–5 working days. Do not represent this as UK warehouse stock; checkout promotions may apply.

## Final independent verification — 3D Printers category only

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 144 | 144 |
| Active customer-visible products | 144 | 144 |
| Active evidence rows | 161 | 161 |
| Active uk_new evidence | 146 | 146 |
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
