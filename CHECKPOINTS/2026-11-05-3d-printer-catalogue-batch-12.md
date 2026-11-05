# 3D Printer Catalogue — Batch 12 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

| Model | UK new price | Availability | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID |
|---|---:|---|---|---|---|---|
| Ender-3 V3 Neo | £199 | In stock (standard printer option) | a1b2c3d4-5e6f-4789-9012-000000000101 | b2c3d4e5-6f70-489a-8123-000000000101 | a1b2c3d4-5e6f-4789-9012-000000000111 | b2c3d4e5-6f70-489a-8123-000000000111 |
| Ender-3 V3 Mega | £519 | Available to order; dispatch timing unconfirmed | a1b2c3d4-5e6f-4789-9012-000000000102 | b2c3d4e5-6f70-489a-8123-000000000102 | a1b2c3d4-5e6f-4789-9012-000000000112 | b2c3d4e5-6f70-489a-8123-000000000112 |

Sources: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer (Neo; standard option £199, in stock; Combo excluded); https://store.creality.com/uk/collections/ender-series-3d-printer (Mega; £519; standard printer only, CFS nano combo excluded; dispatch timing not confirmed).

TEST and LIVE verification: 149 active customer-visible products, 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers; zero missing evidence/branch, duplicate active keys, missing URLs/keys, invalid/non-GBP prices or UK-new condition mismatches. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required. Used evidence remains reference-only.


### Post-Batch-12 reconciliation note — parallel Creality resin entries
A subsequent TEST read detected two additional active, customer-visible Creality resin products created by parallel catalogue work: HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599), each with one active UK-new evidence row. These were not part of Batch 12 and are not yet mirrored in LIVE. Current category totals at this read: TEST 151 visible active products / 165 active evidence rows (150 UK-new / 15 UK-used); LIVE 149 / 163 (148 UK-new / 15 UK-used). Do not add duplicate TEST records; audit the exact TEST product/evidence metadata and then mirror into LIVE with environment-specific UUIDs. A second Ender-3 V3 Neo row was also observed in TEST but is already inactive and hidden, retained for audit; the Batch 12 Neo record remains the active listing.


### Reconciliation completed — Creality HALOT resin models — 5 November 2026
The two parallel TEST resin products have now been mirrored to LIVE and independently verified. HALOT-X1 Neo £199 and HALOT-X1 Max £1,599, both standard printer-only records; resin/wash-cure bundles excluded. TEST IDs: products a17c7b10-8f01-4d3e-a101-000000000502/503; evidence a17c7b10-8f01-4d3e-a101-000000000512/513. LIVE IDs: products c3d4e5f6-7081-49ab-9234-000000000502/503; evidence c3d4e5f6-7081-49ab-9234-000000000512/513. Official UK source pages: https://store.creality.com/uk/products/halot-x1-neo-resin-3d-printer and https://store.creality.com/uk/products/halot-x1-max-resin-3d-printer. Current availability is not confirmed because delivery estimates on indexed pages are stale/past; prices are captured as UK GBP new evidence, not guaranteed live checkout quotes.

After mirroring, TEST and LIVE each report 151 active customer-visible 3D printer products and 165 active evidence rows (150 uk_new / 15 uk_used). LIVE read confirmed both product rows, both evidence rows, and counts. TEST read confirms the same totals and no visible products missing evidence, branches, duplicate active source keys, missing URLs/keys, invalid/non-GBP prices or uk_new condition mismatches. Previous statement that these two entries were pending in LIVE is superseded. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only.
