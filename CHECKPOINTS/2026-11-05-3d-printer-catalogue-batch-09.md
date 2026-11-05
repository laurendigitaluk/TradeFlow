# 3D Printer Catalogue — Batch 9 Checkpoint

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main | **LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi | **LIVE Supabase:** gxsrajtqzdjvmceqcpgv

## Products and UK new-market evidence

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | Price | Availability |
|---|---|---|---|---|---:|---|
| Flashforge Creator 5 | 1d3acbce-e60a-4131-9a6c-5dc9d43cdcbe | d820a81b-294e-45b4-9e2d-75a2ce76bc62 | 901e7b48-675e-4c0d-a526-5f8efffba137 | abde2596-1df8-4231-9a58-2d4299b685dd | £719.00 | In stock; £100 automatic cart discount advertised |
| Flashforge Creator 5 Pro | a2eb857f-29f8-44cc-a730-340b8a04bad4 | a87d3d4c-c4c6-49b6-90ac-250be356868e | 46c77b51-bd49-494a-92a6-bfea2db4af80 | a9ae8f85-05fe-4e79-bd92-b7d8d8c33b41 | £849.00 | In stock; £100 automatic cart discount advertised |
| Flashforge Guider 3 Ultra | 61bba8cf-2f84-4c02-8c94-d11a2557f034 | 312286a8-33cd-4aac-b15c-452f46f1d9d7 | 269c552e-754c-4afa-a167-b9257d9a7df6 | eb1c1bc5-9a94-49ab-968b-6cfe784d6918 | £2,999.00 | China warehouse; shipping in 30 days |

All three evidence rows are uk_new, New, GBP, Retailer, with source URLs and unique source keys.

## Sources and notes

- Creator 5: https://uk.flashforge.com/products/flashforge-creator-5 — official UK page, £719.00, In Stock; £100 automatic cart discount advertised.
- Creator 5 Pro: https://uk.flashforge.com/products/flashforge-creator-5-pro — official UK page, £849.00, In Stock; £100 automatic cart discount advertised.
- Guider 3 Ultra: https://uk.flashforge.com/products/guider-3-ultra-3d-printer — official UK page, £2,999.00; direct shipment from China warehouse with shipping in 30 days.
- Creator 5 and Creator 5 Pro are separate models; Pro adds enclosed frame, active chamber heating and HEPA/carbon filtration.
- Record advertised list prices, not speculative discounts; confirm checkout price before customer quotation.

## Final independent verification — 3D Printers category only

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 141 | 141 |
| Active customer-visible products | 141 | 141 |
| Active evidence rows | 155 | 155 |
| Active uk_new evidence | 140 | 140 |
| Active uk_used evidence | 15 | 15 |
| Manufacturers represented | 13 | 13 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Duplicate active source keys | 0 | 0 |
| Missing evidence URLs or keys | 0 | 0 |
| Non-positive prices / non-GBP evidence | 0 | 0 |
| uk_new condition mismatches | 0 | 0 |

## Scope
No category/branch creation. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue work; no Worker deployment required. Used evidence remains reference-only and must not affect automatic valuation.
