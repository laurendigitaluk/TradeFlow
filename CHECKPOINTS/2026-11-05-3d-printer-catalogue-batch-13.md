# 3D Printer Catalogue — Batch 13 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

## Creality additions already committed by parallel catalogue work

| Model | UK-new price | Configuration | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID |
|---|---:|---|---|---|---|---|
| SPARKX i7 | £239 | Single printer only | d51a8e10-7c21-4a91-9e01-000000000601 | e62b9f21-8d32-4ba2-8f12-000000000601 | d51a8e10-7c21-4a91-9e01-000000000611 | e62b9f21-8d32-4ba2-8f12-000000000611 |
| HALOT-MAGE S 14K | £439 | Standalone resin printer | d51a8e10-7c21-4a91-9e01-000000000602 | e62b9f21-8d32-4ba2-8f12-000000000602 | d51a8e10-7c21-4a91-9e01-000000000612 | e62b9f21-8d32-4ba2-8f12-000000000612 |
| HALOT-R6 | £119 | Standalone resin printer | d51a8e10-7c21-4a91-9e01-000000000603 | e62b9f21-8d32-4ba2-8f12-000000000603 | d51a8e10-7c21-4a91-9e01-000000000613 | e62b9f21-8d32-4ba2-8f12-000000000613 |

## Source and evidence notes

- SPARKX i7: https://store.creality.com/uk/products/sparkx-i7-3d-printer — i7 Single £239; Autofill, Nano Combo and Color Combo excluded. Indexed delivery dates were stale; current fulfilment unconfirmed.
- HALOT-MAGE S 14K: https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer — standalone printer £439; official page stated In Stock, estimated delivery 2–6 Nov 2026. Resin and UW-03 wash/cure bundles excluded.
- HALOT-R6: https://store.creality.com/uk/products/halot-r6-resin-3d-printer — standalone printer £119; indexed delivery estimate 14–18 Sept is stale; current fulfilment unconfirmed.

## Parallel-write collision and resolution

A separate insertion created a second printer-only product/evidence row for each of the same three models while the canonical standard-package rows were already being added by parallel work. The duplicate second rows were soft-deactivated and hidden, retaining audit history; the canonical standard-package records and their evidence were kept active.

Inactive duplicate TEST product IDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603; evidence IDs c7e4a901-6b32-4d8f-9a21-000000000611/612/613.

Inactive duplicate LIVE product IDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603; evidence IDs d8f5b012-7c43-4e9a-a321-000000000611/612/613.

## Final independent verification

| Environment | Active visible products | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|
| TEST | 154 | 168 | 153 | 15 |
| LIVE | 154 | 168 | 153 | 15 |

Both environments: zero visible products missing active evidence; zero duplicate active source keys; zero active evidence with missing URL/key, non-positive price or non-GBP currency. TEST and LIVE totals match.

No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required. Used evidence remains reference-only and does not affect automatic valuation.
