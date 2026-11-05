# 3D Printer Catalogue — Batch 13 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

| Model | UK-new price | Configuration | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID |
|---|---:|---|---|---|---|---|
| SPARKX i7 | £239 | Single printer only | d51a8e10-7c21-4a91-9e01-000000000601 | e62b9f21-8d32-4ba2-8f12-000000000601 | d51a8e10-7c21-4a91-9e01-000000000611 | e62b9f21-8d32-4ba2-8f12-000000000611 |
| HALOT-MAGE S 14K | £439 | Standalone resin printer | d51a8e10-7c21-4a91-9e01-000000000602 | e62b9f21-8d32-4ba2-8f12-000000000602 | d51a8e10-7c21-4a91-9e01-000000000612 | e62b9f21-8d32-4ba2-8f12-000000000612 |
| HALOT-R6 | £119 | Standalone resin printer | d51a8e10-7c21-4a91-9e01-000000000603 | e62b9f21-8d32-4ba2-8f12-000000000603 | d51a8e10-7c21-4a91-9e01-000000000613 | e62b9f21-8d32-4ba2-8f12-000000000613 |



### Creality catalogue reconciliation — three models, 5 November 2026
A parallel catalogue agent had already added canonical standard-package records for SPARKX i7 (£239), HALOT-MAGE S 14K (£439) and HALOT-R6 (£119) in both environments while a separate insertion was being prepared. The second, duplicate printer-only rows were therefore soft-deactivated and hidden; no canonical records were deleted. Canonical TEST product IDs: d51a8e10-7c21-4a91-9e01-000000000601/602/603; TEST evidence IDs: d51a8e10-7c21-4a91-9e01-000000000611/612/613. Canonical LIVE product IDs: e62b9f21-8d32-4ba2-8f12-000000000601/602/603; LIVE evidence IDs: e62b9f21-8d32-4ba2-8f12-000000000611/612/613. Inactive duplicate TEST IDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603 and evidence c7e4a901-6b32-4d8f-9a21-000000000611/612/613. Inactive duplicate LIVE IDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603 and evidence d8f5b012-7c43-4e9a-a321-000000000611/612/613.

Sources: SPARKX i7 single printer option £239 — https://store.creality.com/uk/products/sparkx-i7-3d-printer (Autofill/CFS/colour bundles excluded; fulfilment unconfirmed because indexed delivery estimate is stale); HALOT-MAGE S 14K standalone £439 — https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer (official page stated in stock, estimated delivery 2–6 Nov 2026); HALOT-R6 standalone £119 — https://store.creality.com/uk/products/halot-r6-resin-3d-printer (indexed delivery estimate stale; current fulfilment unconfirmed). Resin, filament and wash/cure bundles are excluded.

Verified after duplicate deactivation: TEST and LIVE each have 154 active customer-visible 3D printer products and 168 active evidence rows (153 uk_new / 15 uk_used), 13 manufacturers. Both environments have zero visible products missing active evidence, zero duplicate active source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only and does not affect automatic valuation. Full record history: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-13.md.

Inactive duplicate TEST products/evidence: c7e4a901-6b32-4d8f-9a21-000000000601/602/603 and ...000000000611/612/613. Inactive duplicate LIVE products/evidence: d8f5b012-7c43-4e9a-a321-000000000601/602/603 and ...000000000611/612/613.
