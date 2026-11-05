# Nintendo Controllers — Racing Wheel Expansion — Batch 5
Date: 5 November 2026

## Scope
Database-only continuation of the TradeFlow Nintendo Controllers master catalogue. Work was applied independently to TEST and LIVE; no TEST records were copied into LIVE.

## Products added
| Product | EAN-13 | UK-new source observations (GBP, New) |
|---|---|---|
| HORI Mario Kart Racing Wheel Pro Mini for Nintendo Switch 2 — Red | 4961818042445 | Smyths Toys UK £69.99; Argos £74.99 |
| HORI Mario Kart Racing Wheel Pro Deluxe for Nintendo Switch 2 — Red & Black | 4961818042469 | Very £104.99; Argos £119.99 |

All four evidence observations were recorded with observed_at 2026-11-05 14:25:00 UTC, retailer names, direct product URLs, GBP, New condition, and stable source_record_key values:
- uk-new:argos:9661811:2026-11-05
- uk-new:smyths:259402:2026-11-05
- uk-new:argos:9575646:2026-11-05
- uk-new:very:1601312358:2026-11-05

Both products are active and customer-visible, assigned to the existing Nintendo Controllers branch, with product-specific package keys and verified EAN-13 identifiers.

## Verified TEST and LIVE position
| Measure | TEST | LIVE |
|---|---:|---:|
| Active products | 99 | 99 |
| Customer-visible products | 99 | 99 |
| Active UK-new evidence rows | 102 | 102 |
| Products covered by UK-new evidence | 99 | 99 |
| Active UK-used evidence rows | 2 | 2 |
| Products covered by UK-used evidence | 2 | 2 |
| Active visible products missing any active evidence | 0 | 0 |
| Active visible products missing UK-new evidence | 0 | 0 |

The previous Batch 4 checkpoint reported 43 products and 46 evidence rows. The current verified database state supersedes that historical snapshot.

## Environment identifiers
- TEST Supabase: nnsshnfkjcflucjrftzi; Nintendo Controllers branch: 68db2680-d353-4108-985c-6fcd81a21821.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv; Nintendo Controllers branch: c3f0a8e4-4172-4c27-982c-7916d66f1f12.
- Product category and manufacturer were resolved from each environment's own existing records.

## Known issue retained
Two existing records in each environment's Nintendo Controllers branch share the generic package_key `single-controller`. This predates Batch 5. It is not proven to be duplicate products, so it was not changed. Review exact model/package identity and insertion history before altering either record. Batch 5's two new products use distinct product-specific package keys.

## Change boundary
No Worker deployment, application-code change, schema migration, valuation-rule change, RLS/Edge Function change, tenant/customer/order/payment data change, or cross-environment data copy. UK-used evidence remains reference-only and excluded from automatic valuation.

## Next work
Continue the Nintendo controller completeness audit for remaining UK-sold Switch 2 controllers and racing-wheel/controller variants. Check current product identity, model/package keys and UK-new source evidence before every insertion. Then continue PlayStation controllers, followed by Xbox controllers.
