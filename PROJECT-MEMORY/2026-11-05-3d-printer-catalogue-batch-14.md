# TradeFlow 3D Printer Catalogue — Batch 14 Project Memory

Date: 5 November 2026.

Applied to both TEST (Supabase project `nnsshnfkjcflucjrftzi`, GitHub `main`) and LIVE (Supabase project `gxsrajtqzdjvmceqcpgv`, GitHub `production`).

## Product expansion

Added two exact Original Prusa XL+ configurations in both environments:
- XL+ / Two-Toolhead — £2,675 GBP, EDS3D.
- XL+ / Five-Toolhead — £3,530 GBP, EDS3D.

Sources:
- https://eds3d.co.uk/products/original-prusa-xl-two-toolhead-3d-printer
- https://eds3d.co.uk/products/original-prusa-xl-five-toolhead-3d-printer

LIVE product/evidence UUIDs:
- Two-toolhead: fb964376-c098-4723-a22a-fb5ee12587e5 / 98206eac-d425-47a8-89eb-0ff2b49b5ec4.
- Five-toolhead: bc3b2121-57af-41ca-a165-02895627cdb9 / 39609ff5-3aab-43ac-9b86-73ef4c076950.

TEST product/evidence UUIDs:
- Two-toolhead: d6b95041-45b3-46c4-9cc2-97828fdab7af / 387d8e7e-5942-43c6-bd9a-f85c99a175ca.
- Five-toolhead: 2fda6830-8d17-4047-bfd8-e8797337859a / 4578e7bd-c890-4904-8cb3-1a5960fcf337.

The EDS3D pages show Add to cart, but configuration-specific stock/dispatch is not confirmed. Evidence is qualified accordingly.

## Additional UK-new evidence attached to existing products

- Bambu Lab P1P — £399; official page availability conflict (lead-time says in stock; purchase CTA says sold out).
- QIDI Plus4 — £569; selector says in stock but embedded variant availability reports unavailable.
- Anycubic Photon Mono M5s — £549; official page says sold out; product remains active because explicit discontinuation was not confirmed.
- Bambu Lab X1 Carbon Standard Printer — £919; official page says sold out; UK reseller confirms no longer manufactured.
- QIDI Q1 Pro — £299; QIDI UK confirms discontinued/no longer in production.
- QIDI X-Max 3 — £499; QIDI UK confirms discontinued/no longer in production; variant unavailable.

Source pages:
- https://bambu-lab-uk.myshopify.com/products/p1p
- https://uk.qidi3d.com/products/plus4-3d-printer
- https://uk.anycubic.com/products/anycubic-photon-mono-m5s
- https://bambu-lab-uk.myshopify.com/products/x1-carbon
- https://uk.qidi3d.com/products/q1-pro-3d-printer
- https://uk.qidi3d.com/products/qidi-x-max-3

All records are UK GBP evidence and include explicit stock qualifications. No listed price with uncertain/sold-out status should be treated as confirmed stock.

## Discontinued / hidden records

Set inactive and customer_visible=false for QIDI Q1 Pro, QIDI X-Max 3 and both Bambu X1 Carbon packages (Standard Printer and AMS Combo). Historic evidence is retained. Anycubic Photon Mono M5s remains active because only sold-out status was confirmed. QIDI X-Plus 3 remains active because explicit discontinuation was not confirmed.

## Final database verification

| Environment | Product rows | Active visible | Inactive | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 162 | 155 | 7 | 179 | 164 | 15 |
| TEST | 163 | 155 | 8 | 179 | 164 | 15 |

Both environments have zero active visible products without active evidence, zero duplicate active evidence source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). Evidence covers 159 products.

The only product-row count difference is one extra inactive/hidden Creality Ender-3 V3 Neo / Printer only duplicate in TEST. Active product and evidence totals match. Keep this duplicate hidden; do not delete/reactivate it without a separate investigation.

UK-used evidence remains reference-only and does not affect automatic valuation. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes were made.
