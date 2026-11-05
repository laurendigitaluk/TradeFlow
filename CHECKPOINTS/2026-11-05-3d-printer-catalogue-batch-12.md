# 3D Printer Catalogue — Batch 12 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

| Model | UK new price | Availability | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID |
|---|---:|---|---|---|---|---|
| Ender-3 V3 Neo | £199 | In stock (standard printer option) | a1b2c3d4-5e6f-4789-9012-000000000101 | b2c3d4e5-6f70-489a-8123-000000000101 | a1b2c3d4-5e6f-4789-9012-000000000111 | b2c3d4e5-6f70-489a-8123-000000000111 |
| Ender-3 V3 Mega | £519 | Available to order; dispatch timing unconfirmed | a1b2c3d4-5e6f-4789-9012-000000000102 | b2c3d4e5-6f70-489a-8123-000000000102 | a1b2c3d4-5e6f-4789-9012-000000000112 | b2c3d4e5-6f70-489a-8123-000000000112 |

Sources: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer (Neo; standard option £199, in stock; Combo excluded); https://store.creality.com/uk/collections/ender-series-3d-printer (Mega; £519; standard printer only, CFS nano combo excluded; dispatch timing not confirmed).

TEST and LIVE verification: 149 active customer-visible products, 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers; zero missing evidence/branch, duplicate active keys, missing URLs/keys, invalid/non-GBP prices or UK-new condition mismatches. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required. Used evidence remains reference-only.
