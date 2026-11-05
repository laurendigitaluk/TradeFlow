# TradeFlow 3D Printer Catalogue — Batch 18 Project Memory

Date: 5 November 2026. Applied independently to TEST (Supabase nnsshnfkjcflucjrftzi / GitHub main) and LIVE (Supabase gxsrajtqzdjvmceqcpgv / production).

## Anycubic Photon P1
Added distinct package configuration:
- Model Photon P1; package key `dual-material-platform`; package name `Dual-Color / Dual-Material Platform Bundle`.
- Official UK page: https://uk.anycubic3d.com/products/photon-p1-dual-color-and-dual-material-printing
- UK-new evidence £469 GBP. Official product page says sold out; not in stock.
- Added fresh standard Photon P1 UK-new observation at £449 GBP, sold out, from https://uk.anycubic3d.com/products/photon-p1-resin-3d-printer. Previous 4 November evidence retained as historical; not overwritten.

LIVE: dual-platform product `d9cb1620-f884-44c7-b4dc-425bd08af7be`, evidence `801bdece-a6c1-4253-b90f-51130dde4ea2`; standard P1 refresh evidence `62bd11df-2f6f-4f1c-9462-3d0b8a56bc3b`.
TEST: dual-platform product `a810f2e3-d607-45bd-9540-f9d39d8efc31`, evidence `80a345ab-5f43-4e3d-81f7-976c3c5a6adf`; standard P1 refresh evidence `934add84-e2ac-4510-aeb8-9d9986e3c1c6`.

## New manufacturer: Sovol
Added master manufacturer Sovol independently:
- LIVE manufacturer ID `867ae77a-7528-4461-87f9-b5e8c2f1ca39`.
- TEST manufacturer ID `19417a98-1504-4914-a5b1-b86923ad115c`.

Added six UK GBP product configurations with official Sovol UK evidence:
1. SV08 Max / Standard Printer — £809, sold out / notify me.
2. SV08 Max / Enclosure Combo — £968, sold out / notify me.
3. SV08 / Standard Printer — £389; out of stock, mid-October dispatch estimate is past.
4. SV08 / Enclosure Combo — £519, sold out / notify me.
5. M1D / M1D Essential — £1,100; pre-order estimate late November to mid-December 2026, but page also shows sold out / notify me.
6. M1D / M1D Advanced — £1,320; pre-order estimate late November to mid-December 2026, but page also shows sold out / notify me.

Sources:
- SV08 Max: https://sovol.uk/products/sovol-sv08-max-3d-printer
- SV08: https://sovol.uk/collections/3d-printer/products/sovol-sv08-3d-printer
- M1D: https://sovol.uk/collections/3d-printer/products/sovol-m1d-3d-printer

LIVE product IDs:
- SV08 Max Standard `0b80dcb8-efd4-4776-843b-1c2cfed2bf2c`; evidence `cdff2b71-2c94-4341-8a4a-3ebdbcace7f5`.
- SV08 Max Enclosure `8c208df4-3e2a-4982-924b-06f483351074`; evidence `0cff3a98-bb3d-4b12-b41a-bfa5d3453bf0`.
- SV08 Standard `49f463b4-4cac-4ef7-8428-6276a2282e6c`; evidence `67d0f18c-95f0-4b52-a9ac-5ef2d2e43bbc`.
- SV08 Enclosure `c470e454-d30f-49ea-b772-433624558ba4`; evidence `13abf7fb-b574-4005-96a1-18bb36889e75`.
- M1D Essential `625ba4a5-ccbc-4366-a6ef-424f909f9a36`; evidence `12c734b3-3a60-41d8-a0c6-05693cd0a279`.
- M1D Advanced `1855eaf2-9bd1-4217-b27a-4ea1056fc2d1`; evidence `85d9a3e0-d6d2-4373-867a-7ae7a76b35a5`.

TEST product IDs:
- SV08 Max Standard `d20c9546-08f2-4701-8bb9-30a7384a0ed4`; evidence `ef17ced3-0455-4310-aa48-9ebbc9d76897`.
- SV08 Max Enclosure `e7987f50-b507-4cd8-b4aa-58982b7d1322`; evidence `43fe472a-99ea-4f7e-a93e-79767a8b7978`.
- SV08 Standard `186812b1-94c8-41ab-b794-f5bcff3816b7`; evidence `318655a0-2fc2-4b63-9bbe-5ca3306c51dd`.
- SV08 Enclosure `43e53cd5-a1fa-47f2-a468-1129a715b39f`; evidence `5f3db8a8-4214-45c5-9449-0635f144efe4`.
- M1D Essential `a5b43286-bec6-4123-a614-822f97a633a5`; evidence `6288a0d2-a8b2-4952-bd09-d19748e0f247`.
- M1D Advanced `e03a9a42-050a-4944-b9d6-ba6a52103a48`; evidence `cdad2733-6b4d-45c7-a674-ec31b27c0f01`.

## Verification
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 171 | 164 | 7 | 190 | 175 | 15 |
| TEST | 172 | 164 | 8 | 190 | 175 | 15 |

Both environments have 14 manufacturers, with 21 Anycubic products and 6 Sovol products. Both have zero active visible products missing active evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). UK-used evidence remains reference-only and does not affect automatic valuation. Preserve sold-out, pre-order and expired-delivery qualifications. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.
