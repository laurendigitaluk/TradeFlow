# 3D Printer Catalogue — Batch 16 Checkpoint

Date: 5 November 2026. TEST branch `main`; LIVE branch `production`.

## Original Prusa XL+ configurations

Added and verified in both databases:
- XL+ / Two-Toolhead — £2,675 GBP, EDS3D.
- XL+ / Five-Toolhead — £3,530 GBP, EDS3D.

Sources:
- https://eds3d.co.uk/products/original-prusa-xl-two-toolhead-3d-printer
- https://eds3d.co.uk/products/original-prusa-xl-five-toolhead-3d-printer

LIVE:
- Two-toolhead product `fb964376-c098-4723-a22a-fb5ee12587e5`, evidence `98206eac-d425-47a8-89eb-0ff2b49b5ec4`.
- Five-toolhead product `bc3b2121-57af-41ca-a165-02895627cdb9`, evidence `39609ff5-3aab-43ac-9b86-73ef4c076950`.

TEST:
- Two-toolhead product `d6b95041-45b3-46c4-9cc2-97828fdab7af`, evidence `387d8e7e-5942-43c6-bd9a-f85c99a175ca`.
- Five-toolhead product `2fda6830-8d17-4047-bfd8-e8797337859a`, evidence `4578e7bd-c890-4904-8cb3-1a5960fcf337`.

The EDS3D listings show Add to cart but do not confirm configuration-specific stock/dispatch. This qualification is stored in evidence.

## Additional UK-new price evidence

Added in both environments:
- Bambu Lab P1P £399 — availability conflict; CTA says sold out.
- QIDI Plus4 £569 — stock selector and embedded variant status conflict.
- Anycubic Photon Mono M5s £549 — sold out; remains active.
- Bambu Lab X1 Carbon Standard £919 — sold out; model discontinued.
- QIDI Q1 Pro £299 — discontinued.
- QIDI X-Max 3 £499 — discontinued and variant unavailable.

All are evidence records only; uncertain/sold-out prices are not confirmed stock.

## Discontinued catalogue state

Inactive/hidden: QIDI Q1 Pro, QIDI X-Max 3, Bambu X1 Carbon Standard Printer and Bambu X1 Carbon AMS Combo. Historical evidence is retained. Anycubic Photon Mono M5s and QIDI X-Plus 3 remain active for the reasons recorded in project memory.

## Independent verification

| Environment | Product rows | Active visible | Inactive | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| TEST | 163 | 155 | 8 | 179 | 164 | 15 |
| LIVE | 162 | 155 | 7 | 179 | 164 | 15 |

Both environments have zero active visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). Evidence covers 159 products.

TEST has one additional inactive/hidden Creality Ender-3 V3 Neo / Printer only duplicate row absent from LIVE. Active catalogue and evidence totals are aligned. Leave this duplicate hidden pending separate review; do not delete or reactivate it blindly.

Used-market evidence remains reference-only. No Worker deployment or code/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes.
