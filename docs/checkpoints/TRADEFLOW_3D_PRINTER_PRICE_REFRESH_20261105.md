# TradeFlow 3D Printer Catalogue — UK Price Refresh

**Date:** 5 November 2026  
**Scope:** Database-only market-evidence update in TradeFlow LIVE and TEST.

## Verified environments

| Measure | LIVE | TEST |
|---|---:|---:|
| Active products/packages in 3D Printers branch | 183 | 183 |
| Manufacturers | 17 | 17 |
| Active UK-new evidence | 195 | 195 |
| Active UK-used evidence | 12 | 12 |
| Total active evidence | 207 | 207 |
| Active products with UK evidence | 183 | 183 |
| Active products without UK evidence | 0 | 0 |
| Active overseas evidence | 0 | 0 |

**Project refs:** LIVE `gxsrajtqzdjvmceqcpgv`; TEST `nnsshnfkjcflucjrftzi`.

Product identity parity was checked by manufacturer + model + package key. The 183 active product/package keys match between environments. Product UUIDs are environment-specific and were not copied between projects.

## Evidence added independently to each environment

| Manufacturer | Model | Package | UK price | Source |
|---|---|---|---:|---|
| Flashforge | Creator 5 | Standard Printer | £619.00 | https://uk.flashforge.com/products/flashforge-creator-5 |
| Flashforge | Creator 5 Pro | Standard Printer | £749.00 | https://uk.flashforge.com/products/flashforge-creator-5-pro |
| Anycubic | Kobra X | Standard Printer | £259.00 | https://uk.anycubic3d.com/products/kobra-x-3d-printer |

Flashforge reference prices at observation: £719 and £849. Anycubic reference price: £359. These are point-in-time UK retail observations, not permanent catalogue prices. Earlier observations were retained.

## Integrity and boundaries

- All prices are UK GBP and attached to the exact standard-printer package.
- Evidence uses distinct `source_name + source_record_key` pairs for repeat-safe imports.
- UK-new and UK-used evidence remain separate.
- Used listing observations are reference-only and must not affect automatic valuations.
- The 3D Printer Equipment & Accessories branch remains active but empty.
- No product records were created or renamed in this refresh.
- No schema, application code, RLS, RPC, Edge Function, tenant/customer/order/payment/Stripe data or Cloudflare Worker deployment changed.
- No Worker deployment is required for database-only catalogue/evidence changes.

## Next steps

1. Continue exact-model UK-new research for additional printer models and package variants.
2. Expand the separate accessories branch only when exact product identity and UK GBP evidence are verified.
3. Add UK-used reference evidence where listing condition and model match are clear.
4. Re-run independent LIVE/TEST parity and evidence-integrity checks after each batch.


## Follow-up: UK-used reference evidence added 5 November 2026

Added in both environments for Bambu Lab P1S, Standard Printer:
- Evidence type: `uk_used`
- Price: £295.08
- Condition: Used
- Seller location: Manchester, United Kingdom
- Source: https://www.ebay.co.uk/itm/880040550398
- Source key: `ebay-uk:p1s-standard:880040550398:2026-11-05`

This is a live listing asking price, not a completed-sale result. It is reference-only and must not feed automatic valuations.

Updated verified totals in each environment: 183 active products/packages, 17 manufacturers, 207 active evidence rows (195 UK-new / 12 UK-used), 183 products with UK evidence, zero products without UK evidence, and zero active overseas evidence. Product identity parity remains exact.
