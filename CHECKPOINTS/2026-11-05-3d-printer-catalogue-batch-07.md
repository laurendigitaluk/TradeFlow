# 3D Printer Catalogue — Batch 7 Checkpoint

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main | **LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi | **LIVE Supabase:** gxsrajtqzdjvmceqcpgv

## Existing category and branch
No new category or branch created.

| Record | TEST | LIVE |
|---|---|---|
| 3D Printers category | cc35aadb-5c1e-439b-8cf9-70ac07e82044 | ab8b13b0-b070-4534-838b-3ebd4d7261e5 |
| 3D Printers branch | b716ae40-d711-4a0a-a72c-9cf19fee880a | 59873baa-da84-461c-a8c3-4b8fd4359bcb |
| ELEGOO manufacturer | a37f51db-9cb6-4efe-a1c3-db26b0e2e4ff | 19e1c180-8bd3-4e0c-a590-fb6459a96530 |

## Products and evidence

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | GBP |
|---|---|---|---|---|---:|
| Mars 4 | 276bdf83-a04a-4910-b434-c4848aea8aa9 | fef057b8-cc58-4b3e-8c46-c32d986de1e4 | b2485551-8216-4761-9e0a-234cdd8a0f64 | d166ef24-b577-44b7-aae9-df4bf1b097b8 | 149 |
| Mars 4 Ultra | 8e5ddb13-712f-437f-808b-538f270321d0 | fca38f6c-e721-4eca-abe8-688bda164c76 | 42e84d1e-95bc-49b5-b700-ee775736ee2a | ff24a946-a871-4b80-9ce1-d3f8afdaaf20 | 189 |
| Saturn 3 | 29f18141-d269-45a4-943c-2ef88ae09ca7 | 4aa0da75-b0f9-4e9b-81c3-cf1b40e665f0 | 05c24329-308c-4c0e-9487-3df5f4be0e18 | 10ecd9b7-77e3-4f21-ad07-e859080d4455 | 214 |
| Saturn 3 Ultra | 9f26c87c-aaa3-4a61-9597-b5816817ead5 | 8b7b6323-fd27-4bf3-8c51-60aef2a177d4 | 40155549-2455-45d3-b5fa-3ac5f74d9a8a | f8baf7fe-1a60-4ef1-a3a5-e84babedb041 | 239 |

All four evidence rows are uk_new, condition New, currency GBP.

## Sources and caveats
- Mars 4 official UK product page: https://uk.elegoo.com/products/elegoo-mars-4-msla-resin-3d-printer-with-9k-mono-lcd — standard Mars 4 option £149; bundles excluded.
- Mars 4 Ultra official UK product page: https://uk.elegoo.com/products/elegoo-mars-4-ultra-msla-resin-3d-printer-with-9k-mono-lcd — standard Mars 4 Ultra option £189; bundles excluded.
- Saturn 3 and Saturn 3 Ultra: https://uk.elegoo.com/collections/saturn-series — latest indexed collection capture about one month before review lists £214 and £239 respectively. Stock is unconfirmed; recheck current price before any valuation or customer quote.
- Keep printer-only products separate from Mercury wash/cure bundles.
- Retail asking prices are not completed used-market sales.

## Final independent verification — TEST and LIVE

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 136 | 136 |
| Active customer-visible products | 136 | 136 |
| Active evidence rows | 150 | 150 |
| Active uk_new evidence | 135 | 135 |
| Active uk_used evidence | 15 | 15 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Duplicate active source keys | 0 | 0 |
| Missing evidence URLs or keys | 0 | 0 |
| Non-positive prices | 0 | 0 |
| Non-GBP evidence | 0 | 0 |
| uk_new condition mismatches | 0 | 0 |

## Scope
No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only work; no Worker deployment required. Used evidence remains reference-only and must not affect automatic valuation.
