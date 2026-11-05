# 3D Printer Catalogue — Batch 8 Checkpoint

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main | **LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi | **LIVE Supabase:** gxsrajtqzdjvmceqcpgv

## Products and UK new-market evidence

| Model | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | Price | Availability |
|---|---|---|---|---|---:|---|
| ELEGOO Neptune 3 Pro | e935221d-7e64-440a-9047-3e3ca382da1a | c21e76c5-bcd1-461d-a56a-f0268308c285 | ebc33e40-ba3c-403f-849b-9119f897cfb9 | 0ca9f622-79c4-47ff-99a6-da1c2b56211f | £127.00 | Official retailer listing; Add to Cart, UK delivery guidance 3–7 business days |
| ELEGOO Saturn 2 (8K) | 552902e0-f7db-4061-807d-06072e72d31a | c5a960fe-a3f0-4de5-9b50-5d9fcbd8aee1 | c87b45bb-af68-4d9e-954d-60eb22b33089 | 33206863-14aa-4c8e-b454-0a4bc46e52bd | £350.00 | Backordered; available to order; estimated 10–14 days |

Both evidence rows are uk_new, New, GBP, Retailer, with stable unique source keys and source URLs.

## Sources and decisions

- Neptune 3 Pro official ELEGOO UK page: https://uk.elegoo.com/collections/elegoo-products-dc/products/elegoo-neptune-3-pro-fdm-3d-printer-225x225x280mm — standard new printer option £127.00; exact model and FDM specification confirmed.
- Saturn 2 (8K) 123-3D UK page: https://www.123-3d.co.uk/collections/3d-printers/products/elegoo-saturn-2-8k-3d-printer — £350.00 inc VAT; retailer states backordered, available to order and estimated 10–14 days. SKU DKI00121.
- Neptune 3 Plus excluded: official UK listing marked sold out.
- Neptune 3 Max excluded from new pricing: current new listing marked sold out; pre-owned listings are not new-market evidence.
- Mars 3 Pro excluded: current UK availability/pricing evidence was insufficiently reliable for a new-market record.
- Keep printer-only products separate from bundles and accessories. Retail asking prices are not completed used sales.

## Final independent verification — 3D Printers category only

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 138 | 138 |
| Active customer-visible products | 138 | 138 |
| Active evidence rows | 152 | 152 |
| Active uk_new evidence | 137 | 137 |
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
