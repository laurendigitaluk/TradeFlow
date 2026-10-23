# Mobile Phone Catalogue — Batch 27 Checkpoint
Date: 2026-10-23

## Scope
Expanded the active catalogue by six exact UK phone variants and added matching evidence in TEST and LIVE.

## Products/evidence added

| Variant | UK price | Source | Classification / caveat |
|---|---:|---|---|
| Apple iPhone Duo 256 GB | £1,999 | https://www.apple.com/uk/shop/buy-iphone/iphone-duo | Official Apple UK new price. Available from 23 Oct 2026; page still says pre-order / available starting 10.23, so availability recorded as listed, not confirmed in stock. |
| Apple iPhone Duo 512 GB | £2,199 | https://www.apple.com/uk/shop/buy-iphone/iphone-duo | Official Apple UK new price, same availability caveat. |
| Apple iPhone Duo 1 TB | £2,599 | https://www.apple.com/uk/shop/buy-iphone/iphone-duo | Official Apple UK new price, same availability caveat. |
| Apple iPhone Duo 2 TB | £3,199 | https://www.apple.com/uk/shop/buy-iphone/iphone-duo | Official Apple UK new price, same availability caveat. |
| Samsung Galaxy A18 4G 128 GB | £249 | https://www.currys.co.uk/products/samsung-galaxy-a18-128-gb-light-blue-10311352.html | Currys exact variant listing; stock and postcode delivery to be rechecked at checkout. |
| Motorola Edge 70 Plus 8 GB / 256 GB | £499 | https://www.currys.co.uk/products/motorola-edge-70-plus-256-gb-pantone-mountain-view-10310979.html | Currys exact variant listing; stock/delivery postcode-dependent. |

Apple's UK buy page lists iPhone Duo prices for Star White and Night Sky, with storage tiers 256GB/512GB/1TB/2TB. Apple's newsroom says availability begins 23 Oct 2026, but the buy page retains “pre-order / available starting 10.23”; therefore evidence availability is `listed`, not `in_stock`.

## Verified database snapshot after Batch 27
- TEST: 129 active customer-visible variants; 130 evidence rows total (127 active, 3 inactive retained for audit); zero active customer-visible variants missing active evidence.
- LIVE: 125 active customer-visible variants; 125 active evidence rows, all active; 59 UK used completed-sale rows.
- LIVE missing-evidence check: 0.
- LIVE integrity check: 0 active evidence rows with missing URL/key, non-positive price, or non-GBP currency.

## Next action
Continue expanding the catalogue with new UK-available models and exact storage variants. Check whether other recently released models are already present before insertion. Keep listed vs in-stock separate and continue prompt TEST → LIVE promotion. Recheck Xiaomi 17T/17T Pro promotion after 27 Oct 2026.
