# QIDI 3D Printer Catalogue — Batch 4 Checkpoint
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Final verification — TEST and LIVE independently
| Metric | TEST | LIVE |
|---|---:|---:|
| Master products | 72 | 72 |
| Active customer-visible products | 72 | 72 |
| Active UK-new evidence | 74 | 74 |
| Active UK-used evidence | 11 | 11 |
| Total active evidence | 85 | 85 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Evidence integrity failures | 0 | 0 |

## Changes
- Added QIDI as manufacturer independently to TEST and LIVE.
- Added eight current model/package records: Q2C standard/BOX Combo, Q2 standard/BOX Combo, Plus5 standard/BOX Combo, Max4 standard/BOX Combo.
- Added eight UK GBP new-price evidence rows independently in both environments.
- All records assigned to the existing 3D Printers branch. No new category or branch was created.
- Product/evidence UUIDs are different in TEST and LIVE. Exact mapping is in PROJECT-MEMORY/2026-11-04-3d-printer-catalogue-batch-04.md.

## Evidence rules and caveats
- UK GBP only. Retailer listings are availability listed, not completed sales.
- Keep printer-only and QIDI BOX combo prices separate.
- Q2 Combo £559 is sourced from HobbySupermarket's UK comparison page, which reports the QIDI Tech direct-store price and date (6 October 2026). The source is named accordingly.
- Plus5 Combo £769 excludes the separate Polar Cooler.
- Max4 Combo £1,029 is the QIDI BOX combo offer.
- Do not infer used-market values from new retail prices.
- QIDI Plus4, Q1 Pro and X-Max 3 were not added in this batch; verify lifecycle and UK used-market evidence separately.

## Scope
No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only manufacturer/product/evidence data changed independently in TEST and LIVE.
