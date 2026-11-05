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

## Bambu Lab H3C addition — 5 November 2026

Added Bambu Lab H3C with AMS H3 Combo as a distinct package in both LIVE and TEST. Bambu Lab's official launch post dated 3 November 2026 explicitly lists the UK H3C + AMS H3 price at £2,199 including tax. Source: https://blog.bambulab.com/tool-changer-game-changer-bambu-lab-presents-h3c-the-defining-new-generation-of-3d-printers/. This is a bundled configuration; no standalone printer price is inferred. Availability and dispatch timing are recorded as requiring confirmation on the UK store.

LIVE product e33286e7-1083-41e5-8677-ce147bf754cd; evidence bf9e3cba-d469-43d3-a0b2-5bf75b9f2bf3. TEST product 9149695d-2cd7-428c-bf52-b22ac3d85245; evidence aeb43102-77aa-4934-bfd3-42ea0463bd65.

Verified 3D Printers totals after this addition: LIVE 187 products / 180 active visible / 207 active evidence / 192 UK-new; TEST 188 products / 180 active visible / 207 active evidence / 192 UK-new. Both environments have zero active visible products missing active evidence. Other recently released models in the catalogue were checked (Bambu A2L and X2D, Anycubic Kobra S1 Max and Kobra X, Flashforge Creator 5 and Creator 5 Pro, Prusa CORE One L+ and XL+); existing product records and current UK-new evidence were present, so no duplicates were created. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.

## Further 3D printer catalogue continuation — 5 November 2026

Added Flashforge Adventurer 5X independently to LIVE and TEST. The official Flashforge UK store lists £279.00 GBP, reduced from £449.00, as its entry-level multicolour printer. Source: https://uk.flashforge.com/ (official UK store homepage). Price observed 5 November 2026; delivery and final checkout availability to be confirmed in checkout.
- LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874; evidence 219b6262-fd23-4329-b22c-904387ea8e80.
- TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220; evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Also completed the prior Creality Ender-3 V4 CFS Combo addition at £289.00, sourced from GM Crafts UK (https://www.gmcrafts.co.uk/product/creality-ender-3-v4-combo/), with Add to Basket and free UK delivery shown. LIVE product bbf4ef13-c073-4fe2-a1ed-54975e9151a8 / evidence 401c9eaf-6153-45ab-add1-2f7bdcbbed30; TEST product 2bcf22b1-a2fa-412c-81d8-6e074e95fd81 / evidence 9a9177a2-e720-4e8a-8caa-f50771be7029.

Verified recent-model coverage: Creality HALOT-X1 Neo and HALOT-X1 Max already have current UK-new evidence in both environments (Neo £199; Max £1,599); Flashforge CJ270 already exists with UK-new evidence; Anycubic Kobra 3 Max V2 standard and combo and Photon P1 Max already exist with active UK-new evidence; no duplicates were added. Existing Bambu Lab A2L/X2D, Anycubic Kobra S1 Max/Kobra X, Flashforge Creator 5/Creator 5 Pro, and Prusa CORE One L+/XL+ were also confirmed present with active UK-new evidence in the previous check. UK-new evidence remains the price source; UK-used stays reference-only.

Verified 3D Printers totals after this continuation:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Visible products missing evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 189 | 182 | 209 | 194 | 15 | 0 |
| TEST | 190 | 182 | 209 | 194 | 15 | 0 |

Both environments: zero duplicate product keys. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required. TEST and LIVE were updated independently.

## Additional 3D printer catalogue additions — 5 November 2026

Added Flashforge Adventurer 5X standard multicolour printer at £279.00 GBP (official UK store price reduced from £449.00): https://uk.flashforge.com/. LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874 / evidence 219b6262-fd23-4329-b22c-904387ea8e80; TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220 / evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Added distinct Anycubic Kobra X Combo (base 7-colour package, expandable to 19 colours) at £429.00 GBP: https://uk.anycubic.com/products/kobra-x-combo-3d-printer. Official product page states ships in 24 hours and free express shipping. LIVE product 634078d8-39d8-4bf1-b01a-c391f481d4ec / evidence 14e0207a-f4d0-4d17-bd1b-9bc52078a976; TEST product 834e5612-67da-4ad2-be67-1bf4b638ea7d / evidence da4e3863-e612-4654-b706-69fe76cf3e20.

Also completed the previous Ender-3 V4 CFS Combo addition at £289.00 from GM Crafts UK; product/evidence IDs and source are recorded in the immediately preceding continuation section. Verified that HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) already have current UK-new evidence in both environments; no duplicates were created. Flashforge CJ270 and Anycubic Kobra 3 Max V2 / Photon P1 Max already have active UK-new evidence in both environments.

Verified 3D Printers totals after this batch:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Missing visible evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 190 | 183 | 210 | 195 | 15 | 0 |
| TEST | 191 | 183 | 210 | 195 | 15 | 0 |

Both environments have zero duplicate product keys and zero active visible products missing evidence. UK-used remains reference-only and excluded from automatic valuation. LIVE and TEST were updated independently. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant/customer/order/payment changes. No Worker deployment required.