# 3D Printer Catalogue — Batch 17 Checkpoint

Date: 5 November 2026. TEST branch main; LIVE branch production.

## Anycubic additions
Added in both databases:
- Kobra 4 / Standard Printer — £279 GBP, separate from existing ACE 2 Pro Combo. UK official page https://uk.anycubic.com/products/kobra-4-3d-printer lists standalone £279 and 4-colour Combo £329. Page shows Add to cart and 24-hour shipping but says Early Bird Pre-sale; fulfilment must be reconfirmed.
- Photon Mono 4 Ultra / Standard Resin Printer — £279 GBP, standalone, excludes wash/cure and resin add-ons. UK official page https://uk.anycubic.com/products/photon-mono-4-ultra shows Add to cart and 24-hour shipping; current stock not independently reconfirmed.

Added Photon P1 Max UK-new evidence at £849 GBP from https://uk.anycubic.com/products/photon-p1-max-best-large-resin-3d-printer. Page says Pre Order NEW and Add to cart, but delivery estimate 1–10 October 2026 has passed. Current fulfilment unconfirmed. Previous £799 evidence retained.

LIVE IDs: Kobra 4 product/evidence c673eabf-716d-4ca9-b6eb-9acba6e593a3 / ffde1cd2-3f0b-474d-a8dd-b31f2af2018e; Photon Mono 4 Ultra product/evidence ad5604a6-4975-427b-9771-8235b3313de6 / c834fe6b-37b1-4bbb-8c67-db7d66d14d04; Photon P1 Max evidence 3397619c-e98c-40a2-b60c-51c333cc7e80.

TEST IDs: Kobra 4 product/evidence 882f59eb-3e38-4507-b172-04024bcae686 / 1f1af134-51dd-4d01-b371-623ddb224a5d; Photon Mono 4 Ultra product/evidence 8eb8d867-acb2-476c-8bc0-3e76c804ce5f / ba598ebf-bb11-423b-a4ae-2ae0788a556b; Photon P1 Max evidence e1a3b749-508e-425a-b4f7-a3ff9546ffc4.

## Independent verification

| Environment | Product rows | Active visible | Inactive | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| TEST | 165 | 157 | 8 | 182 | 167 | 15 |
| LIVE | 164 | 157 | 7 | 182 | 167 | 15 |

Both have zero active visible products missing active evidence, zero duplicate active product keys, zero duplicate active evidence keys and zero invalid active evidence. Active totals match. TEST has one additional inactive/hidden Creality Ender-3 V3 Neo duplicate; leave it hidden pending separate investigation. All evidence is UK GBP. UK-used evidence is reference-only and does not affect automatic valuation. No Worker deployment or application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes.