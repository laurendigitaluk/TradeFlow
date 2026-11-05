# Checkpoint — ENTINA / WEEFUN Model-Key Review (Batch 21)

Date: 5 November 2026
Status: Research completed; no lasting database addition.

ENTINA's official lineup includes Tina2C, Tina2S and Tina2 Plus. A UK Amazon tracker showed ENTINA Tina2C at £208.00, new condition, last seen around 31 October 2026. Official product: https://www.entina3d.com/products/entina-3d-printer-tina2c. Tracker: https://www.3dprinterdeals.co.uk/item/entina-tina2c-3d-printer-friendly-for-beginners-ready-to-print-in-5/B0GQSR943V.

A trial ENTINA Tina2C product/evidence record was inserted and then reverted in both environments because its normalized model/package key collided with the existing WEEFUN TINA2C. The temporary ENTINA manufacturer record was also removed. The WEEFUN TINA2C remains the only Tina2C product key in both environments. This conservative action preserves the no-duplicate-key invariant. Do not re-add ENTINA Tina2C unless key strategy explicitly supports same-model brand variants or independent configuration is proven.

Verified after reversion:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|
| LIVE | 178 | 171 | 197 | 182 | 15 |
| TEST | 179 | 171 | 197 | 182 | 15 |

Both environments: zero missing active visible evidence and zero duplicate product keys. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.
