# TradeFlow Project Memory — ENTINA / WEEFUN Model-Key Review (Batch 21)

Date: 5 November 2026

ENTINA official site confirms its own Tina2C, Tina2S and Tina2 Plus product family. WEEFUN official site independently markets WEEFUN-branded Tina2C and Tina2S. A UK Amazon price tracker recorded an ENTINA Tina2C new offer at £208.00, last seen approximately 31 October 2026:
https://www.3dprinterdeals.co.uk/item/entina-tina2c-3d-printer-friendly-for-beginners-ready-to-print-in-5/B0GQSR943V
Official ENTINA Tina2C page: https://www.entina3d.com/products/entina-3d-printer-tina2c

A trial ENTINA Tina2C product/evidence insertion was immediately reverted in LIVE and TEST because the branch-wide product key check found a duplicate with the existing WEEFUN TINA2C (same normalized model and package key). The ENTINA trial row, evidence and manufacturer record were removed. The existing WEEFUN row and evidence remain untouched. No ENTINA records remain from this attempt. Do not add the same model/package key under a second brand until product key design supports brand variants or the exact model/configuration is shown to be distinct.

Post-revert verified 3D Printer branch totals:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|
| LIVE | 178 | 171 | 197 | 182 | 15 |
| TEST | 179 | 171 | 197 | 182 | 15 |

Both environments have zero missing active visible evidence and zero duplicate product keys. UK-used remains reference-only. No Worker deployment, app/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.
