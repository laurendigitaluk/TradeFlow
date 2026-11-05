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


## Follow-up batch — accessories branch population, 5 November 2026

Seven accessory products and seven UK-new evidence rows were added independently to LIVE and TEST:

| Manufacturer | Product / package | UK price | Evidence source |
|---|---|---:|---|
| Bambu Lab | AMS 2 Pro — Single Unit | £266.04 | 3DJake UK |
| Bambu Lab | Hotend Heating Assembly — A1 / A1 mini | £23.00 | 3DJake UK |
| Creality | CFS — Single Unit | £289.00 | Creality UK |
| Creality | SpacePi X4 Filament Dryer — Single Unit | £150.00 | Creality UK |
| Creality | Space Pi Filament Dryer Plus — Two-Roll Unit | £85.00 | Creality UK |
| Creality | Unicorn Quick-Swap Nozzle Kit — 4-piece | £45.00 | Creality UK |
| Creality | Unicorn K2P Quick-Swap Nozzle Kit — 4-piece | £45.00 | Creality UK |

Evidence source URLs are stored on each record:
- https://www.3djake.uk/bambu-lab/ams-2-pro
- https://www.3djake.uk/bambu-lab/hotend-heating-assembly
- https://store.creality.com/uk/products/creality-filament-system-cfs
- https://store.creality.com/uk/products/creality-spacepi-x4
- https://store.creality.com/uk/products/creality-space-pi-filament-dryer-plus
- https://store.creality.com/uk/products/unicorn-quick-swap-nozzle-kit
- https://store.creality.com/uk/products/unicorn-k2p-quick-swap-nozzle-kit

### Latest independent verification

| Branch | LIVE | TEST |
|---|---:|---:|
| 3D Printers active products | 183 | 183 |
| 3D Printers active evidence | 207 | 207 |
| Accessories active products | 7 | 7 |
| Accessories active UK-new evidence | 7 | 7 |
| Accessory products missing UK evidence | 0 | 0 |
| Malformed accessory evidence rows | 0 | 0 |

Both accessory branches contain two manufacturers (Bambu Lab and Creality). All 190 active products across both branches are customer-visible and have UK evidence. Product manufacturer/model/package-key parity is exact between environments. Product UUIDs remain environment-specific.

No application code, schema, valuation logic, RLS, RPC, Edge Function, tenant/customer/order/payment/Stripe data or Cloudflare Worker deployment changed. Database-only catalogue work requires no Worker deployment.

SUNLU has not yet been imported because it is not present in the manufacturer master. Add the manufacturer master record first, then continue with exact accessory identities and UK GBP evidence.


## Follow-up batch — SUNLU manufacturer and filament dryers, 5 November 2026

Added the SUNLU manufacturer master row independently in LIVE and TEST, then added four accessory product/package records and UK-new evidence rows:

| Product | UK price | Availability | Source |
|---|---:|---|---|
| SUNLU FilaDryer S4 | £94.80 | Restock pending | https://www.3djake.uk/sunlu/filadryer-s4 |
| SUNLU FilaDryer S4 Pro | £129.00 | In stock | https://www.3djake.uk/sunlu/filadryer-s4-pro |
| SUNLU Fila Dryer S2 | £59.82 | In stock | https://www.3djake.uk/sunlu/fila-dryer-s2 |
| SUNLU FilaDryer SP2 | £72.15 | In stock | https://www.3djake.uk/sunlu/filadryer-sp2 |

Prices include 20% VAT according to 3DJake UK. S4 availability is explicitly marked restock pending.

### Latest independent LIVE / TEST verification

| Branch | LIVE products | TEST products | LIVE evidence | TEST evidence |
|---|---:|---:|---:|---:|
| 3D Printers | 183 | 183 | 207 | 207 |
| Equipment & Accessories | 11 | 11 | 11 | 11 |

Accessories branch: 3 manufacturers, all 11 products customer-visible, all 11 with UK evidence, zero malformed rows. Main printer branch remains 17 manufacturers, 183 products, 207 active evidence rows (195 UK-new / 12 UK-used), zero missing evidence. Product manufacturer/model/package keys match exactly between environments. No Worker deployment is required.


## 5 November 2026 — LIVE / TEST category metadata reconciliation

A fresh cross-environment audit found two existing Creality printer products in TEST (HALOT-X1 Neo and HALOT-X1 Max, package `printer-only`) had active product rows and active UK-new evidence, but their `product_type`, `main_category` and `catalogue_category` metadata were null. The matching LIVE records were correctly classified. TEST was corrected in place using its own category/manufacturer/branch identifiers; no product or evidence UUIDs were copied and no duplicate rows were created.

Both environments now independently verify the same 189 active customer-visible 3D-printer-related product/package identities, with matching natural-key hash `7765a67becf07cbff191b429b6a02623`:

| Main category | Catalogue category | LIVE | TEST |
|---|---|---:|---:|
| 3D Printers | 3D Printers | 5 | 5 |
| 3D Printers | 3D Printers & Equipment | 27 | 27 |
| 3D Printers & Equipment | 3D Printers | 146 | 146 |
| 3D Printers & Equipment | 3D Printer Equipment & Accessories | 11 | 11 |

Each environment has 213 active evidence rows across these products; all 213 are GBP. All 189 products have active UK-new or UK-used evidence and are customer-visible. No product-key parity difference remains. No application code, schema, valuation logic, RLS, RPC, Edge Function, tenant/customer/order/payment/Stripe data or Cloudflare Worker deployment changed. Database-only metadata correction requires no Worker deployment.

**Important count interpretation:** the earlier checkpoint's 183 printer products / 207 evidence rows described an earlier grouped snapshot and is superseded by the current category-level totals above. Always report category counts by both `main_category` and `catalogue_category`; do not collapse similarly named branches or assume the old 183 total remains current.
