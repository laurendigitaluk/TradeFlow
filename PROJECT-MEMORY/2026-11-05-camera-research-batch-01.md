# TradeFlow Cameras — LIVE research batch 01

Date: 5 November 2026
Environment: LIVE Supabase gxsrajtqzdjvmceqcpgv; GitHub production.

## Baseline and progress
- Active products in Cameras: 722.
- At baseline: 353 had qualifying active UK GBP evidence with a non-empty source URL; 369 required research.
- Four records added and verified in this batch.
- After insertion: 357 covered; 365 still require qualifying evidence.

## Evidence added
| Product | Price | Source | Availability |
|---|---:|---|---|
| Blackmagic Design Cinema Camera 6K | £1,219.00 | https://www.blackmagicdesign.com/uk/products/blackmagiccinemacamera | Unknown |
| Canon Cinema EOS C70 Camera Body | £3,599.99 | https://www.canon.co.uk/store/cinema-eos-cameras/ | In stock at check |
| Canon EOS R50 V Camera Body | £529.00 | https://www.parkcameras.com/cameras/mirrorless-cameras/canon/?pi=2 | In stock at check |
| Brinno TLC300 Long Term Time Lapse Camera | £269.99 starting price | https://www.brinnouk.com/collections/1080p-cameras | Collection showed in-stock range; confirm exact package |

## Rules carried forward
- Exact master product matching; do not create duplicates or infer package equivalence.
- UK GBP only. Record exact source URL, price, condition and availability qualification.
- Check existing source name/key before insert; unique key is (source_name, source_record_key).
- UK-used market observations are reference-only and must not feed automatic valuation.
- Do not delete, deactivate, or change customer visibility based solely on missing evidence.
- Keep TEST and LIVE data separate. This batch changed LIVE only.

## Verification
Read-back query confirmed 722 active Cameras products, 357 with at least one qualifying active evidence record and 365 still requiring evidence. No product master rows or lifecycle flags were changed. No application code, schema, valuation, RLS, Edge Function, tenant/customer/order/payment data or Worker deployment was changed.
