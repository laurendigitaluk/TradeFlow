# Checkpoint — TradeFlow 3D Printer Catalogue Batch 22

Date: 5 November 2026
Status: Complete and verified in LIVE and TEST.

Added Geeetech M1S (£185, official GBP store) and Artillery M1 Pro (£299 sale, £349 regular) plus M1 Pro S1 (£319 sale, £349 regular). Artillery official UK pages show out of stock; availability is not claimed. Geeetech page includes ship-from selector; verify UK warehouse and checkout total.

LIVE product/evidence pairs:
- Geeetech M1S: 16387858-242f-4ed3-962a-4262250e0af6 / dec25b70-c9c5-4d5c-8d7a-ddab4c74e63e
- Artillery M1 Pro: 03f5d9f9-cf09-4ffc-85d8-87eb81972402 / bddeb903-6c0c-4586-875b-0f0ad6b68fda
- Artillery M1 Pro S1: 9a2cec2d-b2f2-4dcf-b9f3-7f82b23b5c6f / 4fe5e6bf-ab50-463e-b1a1-be0058584db1

TEST product/evidence pairs:
- Geeetech M1S: d2c6a15b-3e58-4ff0-8342-3605457f7462 / 38f855d6-4d22-4893-af4e-772e30558a9f
- Artillery M1 Pro: 8ca46de2-cc0d-495f-8b78-bd14a7397a7f / 41c13355-eddc-40eb-a4a3-d435ac347bc7
- Artillery M1 Pro S1: e85b8a23-6862-4439-863c-fddf1ed75d78 / 214de6e3-84af-46b6-91ac-4c19c63ff874

Branch totals:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 181 | 174 | 7 | 200 | 185 | 15 |
| TEST | 182 | 174 | 8 | 200 | 185 | 15 |

Integrity checks: zero visible products missing active evidence, zero duplicate product keys, zero duplicate active evidence source keys, zero invalid/missing evidence. UK-used remains reference-only. Geeetech M1 was deferred due conflicting GBP price evidence; Sidewinder X4/X3 deferred due sold-out state and no reliable current UK price. No Worker deployment or application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes.


## 3D printer catalogue continuation — ELEGOO and FLSUN batch (5 November 2026)

Added and evidenced three previously missing ELEGOO configurations independently in LIVE and TEST:
- Centauri Carbon 2 standard (without CANVAS): £259.00 GBP; https://uk.elegoo.com/products/centauri-carbon-2
- Centauri 2 standard (without CANVAS): £179.00 GBP; https://uk.elegoo.com/products/centauri-2
- Centauri 2 CANVAS 4-colour Combo: £219.00 GBP; https://uk.elegoo.com/products/centauri-2-combo
The existing Centauri Carbon 2 CANVAS combo was already present in both environments and was not duplicated. Official ELEGOO UK pages show the UK shipping territory and pricing; checkout shipping is calculated separately. Source prices observed 5 November 2026.

Product/evidence IDs — LIVE:
- Centauri Carbon 2 standard: product 5063b4eb-0300-4fdc-9845-2f90c4d42764; evidence c35bab99-2ec6-4d43-b76e-ef093e1f2724.
- Centauri 2 standard: product 6d562965-b9a7-4f89-a495-24b32993a26c; evidence e50b55df-65ee-4db8-818f-47b7c3222d58.
- Centauri 2 CANVAS combo: product 9b3dc3cb-9e64-4253-b389-9f27bbaa61ee; evidence b5312394-0f51-4815-8c0b-cc727f6e6f12.

Product/evidence IDs — TEST:
- Centauri Carbon 2 standard: product f5b16bc4-23ed-4406-b1cc-1c26ef57aefe; evidence fe2eeabd-5d76-4f4c-a44b-7a3e97860af8.
- Centauri 2 standard: product 9c1be54d-8251-432a-96f3-77dc428d11cf; evidence f004ef0f-47e1-4eee-9ecc-2e4c5cb85bb4.
- Centauri 2 CANVAS combo: product 39cce755-195f-48a9-ab45-06106460bbba; evidence e03010e5-ebd4-4725-9189-b9702aaa388c.

Resolved the incomplete FLSUN T1 MAX record from the previous continuation. The official FLSUN UK collection lists £459.00 sale / £599.00 regular and marks it in stock: https://uk.store.flsun3d.com/collections/3d-printer-new. Evidence is now present in both environments. LIVE product a22e38a9-8de5-4bdf-a3ab-4b5e110ee101 / evidence 2f51f375-8931-4b1e-aa43-49bf6809217c. TEST product 5d1797a2-0f28-4efb-8d31-e318ee2da3bf / evidence 7d21abe5-21b2-4b59-ac75-52150d52050e. Product notes were corrected to match the current official collection's in-stock status.

Verified 3D Printers branch totals after inserts:
| Environment | Products | Active visible | Active evidence | UK-new | Missing visible evidence |
|---|---:|---:|---:|---:|---:|
| LIVE | 185 | 178 | 204 | 189 | 0 |
| TEST | 186 | 178 | 204 | 189 | 0 |

Both environments: zero duplicate active product keys and zero duplicate active evidence source keys. Previous hidden/inactive counts remain 7 LIVE and 8 TEST. UK-used evidence remains reference-only and excluded from automatic valuation. TEST and LIVE were updated independently. No application code, schema, valuation logic, RLS, Edge Functions, Worker, Stripe, tenant/customer/order/payment data changed. No Worker deployment required.

## Creality Ender-3 V3 Neo evidence and CFS nano combo — 5 November 2026

The existing Ender-3 V3 Neo standard printer record was confirmed in both environments and refreshed with the current official UK printer-only price £199.00. Added a distinct CFS nano four-colour Combo configuration at £289.00; official product page labels the combo as pre-order and includes a 2 kg filament promotion. Source: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer. The official Creality UK comparison article (20 October 2026) distinguishes the Neo and Mega specifications and quotes Neo £199 / Mega £519: https://store.creality.com/uk/blogs/buying-guides/ender-3-v3-neo-vs-mega. Ender-3 V3 Mega was not added in this batch because current UK listing presents it as a promotional filament bundle from £519 and a clean printer-only / combo split was not sufficiently confirmed.

LIVE: existing Neo standard product b2c3d4e5-6f70-489a-8123-000000000101 refreshed evidence 4c43d533-c79d-48b0-ae4f-096bec842734 (£199); new CFS nano combo product 2c3eaeea-7828-4289-9e3b-5fb0eefd65c6 / evidence 2b52ae5c-d138-47b7-bade-9a8fe5c0d171 (£289).
TEST: existing Neo standard product a1b2c3d4-5e6f-4789-9012-000000000101 refreshed evidence 20fda591-e7d9-4102-8a3a-e8fbc141ad41 (£199); new CFS nano combo product e26954ad-9225-4195-9a18-757163eb8e64 / evidence 1fb1de2e-410e-4806-8311-e22c0a227dd7 (£289).

Verified totals after this addition: LIVE 186 products / 179 active visible / 206 active evidence / 191 UK-new; TEST 187 products / 179 active visible / 206 active evidence / 191 UK-new. Both environments have zero active visible products missing active evidence. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.