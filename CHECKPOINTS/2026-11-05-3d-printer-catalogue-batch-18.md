# 3D Printer Catalogue — Batch 18 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

## Work completed
- Added Anycubic Photon P1 / Dual-Color / Dual-Material Platform Bundle as a distinct package configuration. Official UK evidence £469; product page says sold out. Added fresh standard Photon P1 UK-new observation £449 and marked sold out; prior 4 November observation retained.
- Added Sovol as a master manufacturer in both environments.
- Added six Sovol UK-priced configurations: SV08 Max Standard £809; SV08 Max Enclosure Combo £968; SV08 Standard £389; SV08 Enclosure Combo £519; M1D Essential £1,100; M1D Advanced £1,320.
- Official Sovol UK sources: https://sovol.uk/products/sovol-sv08-max-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-sv08-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-m1d-3d-printer.
- SV08 Max and SV08 pages show sold-out/notify status. SV08 dispatch estimate mid-October is past. M1D is a pre-order with estimated late-November to mid-December 2026 dispatch but page also shows sold-out/notify; none of these are to be described as confirmed in-stock.

## IDs
LIVE Sovol manufacturer: `867ae77a-7528-4461-87f9-b5e8c2f1ca39`.
LIVE products/evidence:
- SV08 Max Standard: `0b80dcb8-efd4-4776-843b-1c2cfed2bf2c` / `cdff2b71-2c94-4341-8a4a-3ebdbcace7f5`.
- SV08 Max Enclosure: `8c208df4-3e2a-4982-924b-06f483351074` / `0cff3a98-bb3d-4b12-b41a-bfa5d3453bf0`.
- SV08 Standard: `49f463b4-4cac-4ef7-8428-6276a2282e6c` / `67d0f18c-95f0-4b52-a9ac-5ef2d2e43bbc`.
- SV08 Enclosure: `c470e454-d30f-49ea-b772-433624558ba4` / `13abf7fb-b574-4005-96a1-18bb36889e75`.
- M1D Essential: `625ba4a5-ccbc-4366-a6ef-424f909f9a36` / `12c734b3-3a60-41d8-a0c6-05693cd0a279`.
- M1D Advanced: `1855eaf2-9bd1-4217-b27a-4ea1056fc2d1` / `85d9a3e0-d6d2-4373-867a-7ae7a76b35a5`.
- Photon P1 dual-platform: `d9cb1620-f884-44c7-b4dc-425bd08af7be` / `801bdece-a6c1-4253-b90f-51130dde4ea2`; standard P1 refresh evidence `62bd11df-2f6f-4f1c-9462-3d0b8a56bc3b`.

TEST Sovol manufacturer: `19417a98-1504-4914-a5b1-b86923ad115c`.
TEST products/evidence:
- SV08 Max Standard: `d20c9546-08f2-4701-8bb9-30a7384a0ed4` / `ef17ced3-0455-4310-aa48-9ebbc9d76897`.
- SV08 Max Enclosure: `e7987f50-b507-4cd8-b4aa-58982b7d1322` / `43fe472a-99ea-4f7e-a93e-79767a8b7978`.
- SV08 Standard: `186812b1-94c8-41ab-b794-f5bcff3816b7` / `318655a0-2fc2-4b63-9bbe-5ca3306c51dd`.
- SV08 Enclosure: `43e53cd5-a1fa-47f2-a468-1129a715b39f` / `5f3db8a8-4214-45c5-9449-0635f144efe4`.
- M1D Essential: `a5b43286-bec6-4123-a614-822f97a633a5` / `6288a0d2-a8b2-4952-bd09-d19748e0f247`.
- M1D Advanced: `e03a9a42-050a-4944-b9d6-ba6a52103a48` / `cdad2733-6b4d-45c7-a674-ec31b27c0f01`.
- Photon P1 dual-platform: `a810f2e3-d607-45bd-9540-f9d39d8efc31` / `80a345ab-5f43-4e3d-81f7-976c3c5a6adf`; standard P1 refresh evidence `934add84-e2ac-4510-aeb8-9d9986e3c1c6`.

## Verification
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 171 | 164 | 7 | 190 | 175 | 15 |
| TEST | 172 | 164 | 8 | 190 | 175 | 15 |

Both environments have zero missing active visible evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid active evidence. Both have 14 manufacturers. UK-used evidence is reference-only and never affects automatic valuation. No Worker deployment, code/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes.
