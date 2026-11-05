# Gaming Catalogue Continuation — Batch 02
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
Database write order: TEST first, verify, then LIVE.

## Scope
Nintendo Switch 2 controllers/accessories and retailer evidence for PlayStation/Xbox limited-edition controllers. Database-only. No tenant, customer, order, payment, ownership, application, valuation, schema, RLS, RPC, Edge Function, Stripe or Cloudflare Worker changes. No deployment.

## Six new product masters and Smyths UK-new evidence

| Product | Price | TEST product / evidence | LIVE product / evidence |
|---|---:|---|---|
| PowerA Advantage Wireless Controller — Pokémon: Mega Evolutions | £39.99 | 4b7c6129-3f8f-40e9-b45d-d96a026548c4 / a7393116-353c-450d-b87b-e713190f1c4f | fe4606b4-8ff5-4130-956c-f51e636a67a8 / b6390d9e-d2f9-462c-9398-3efbb26ec91c |
| Venom 10-in-1 Sports Accessory Pack for Nintendo Switch 2 | £29.99 | d6753e14-db24-4db2-8f6a-45bba152405f / 4b9050c2-8773-42ed-9550-285cf10783e7 | 59836e1e-865d-4ec7-b011-18247ad4353d / 7b04ee66-9ea5-4deb-9462-38d95a1da90e |
| PowerA Advantage Wireless Controller — Mario & Yoshi | £39.99 | c2dfe6f8-57b0-4f27-b539-fa60ea09e141 / 2c51b144-18b4-47b9-a882-452c996731be | 7e7d9338-9c2e-4abc-8534-c52561aa7b27 / d5dcfc8f-744d-4b89-9a05-2daa25bae96d |
| PowerA Slim Case — Dark Heather Grey | £14.99 | 102afe8c-ebb6-4866-9093-caaf33fc99cf / e1848cb4-a2f1-4de4-90ca-608c0f3099ad | 271f7ac4-3fe3-4d65-bd26-5f53b1c7adae / ebb56bb5-2b5f-457e-b98f-639ace698855 |
| PowerA Protection Case — Mario & Yoshi | £14.99 promotional (was £19.99) | 2d1570d9-d2ee-48ac-8e60-f07a7a849895 / f24c670c-7d40-45f0-9f2c-e23820a4d917 | d3f29b88-522a-4158-b7bf-eb562260a012 / eb50c097-ecb5-4886-8de5-1249df2a8268 |
| SanDisk 256GB microSD Express Card — Mario Edition | £44.99 | f135b874-e6f5-4bd0-b4af-f967bf6a0b04 / acf40d83-c655-4e02-b5d7-3dbe9c8b1651 | 7724e83e-6e7e-410e-a76d-1366691bd8a5 / a4294033-1aa9-49f8-a087-3a55e6e6d8ca |

Sources:
- PowerA Pokémon Mega Evolutions controller: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/powera-advantage-wireless-controller-for-nintendo-switch-2-pokemon-mega-evolutions/p/252731
- Venom sports pack: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/venom-10-in-1-sports-accessory-pack-for-nintendo-switch-2/p/252048
- PowerA Mario & Yoshi controller: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203 (category listing)
- PowerA Dark Heather Grey Slim Case: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/powera-slim-case-for-nintendo-switch-2-dark-heather-grey/p/250982
- PowerA Mario & Yoshi Protection Case: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/powera-protection-case-for-nintendo-switch-2-mario-and-yoshi/p/259457
- SanDisk Mario 256GB microSD Express: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/sandisk-256gb-microsd-express-card-for-nintendo-switch-2-mario/p/249598

The Mario-themed SanDisk card is maintained as a distinct package variant from the generic 256GB SanDisk card. The Venom sports pack includes Joy-Con inserts, not Joy-Con controllers.

## Five further retailer observations added to existing products

| Product | Added source and price | TEST evidence | LIVE evidence |
|---|---|---|---|
| Switch 2 Joy-Con 2 Pair — Light Purple/Light Green | Smyths £64.99 (Argos £64.95 retained) | fe49c8ac-92cf-49d7-bb2b-bca4f7ec5ab0 | b998367f-4c3b-4733-b284-58755aa249f4 |
| Gioteck WX5+ — Dark Camo | Argos £21.99 (Smyths £24.99 retained) | 3a7831bb-4467-4914-82bd-6846b4ae9f7d | 9e8dcdcb-a13c-49eb-942e-e61032b334f2 |
| DualSense 007 First Light Limited Edition | Smyths £69.99 (PlayStation UK £74.99 retained) | fa914a45-434c-43d1-9af0-33277178bf78 | e23939b4-af2e-4ab4-ba44-bdc493c67afe |
| DualSense GTA VI White Limited Edition | Smyths £74.99 (PlayStation Direct £74.99 retained) | 2718b866-7cae-445d-a3c2-58489f3cc6de | 7bed8ae3-4090-43c2-81a0-b2dcda48b8e1 |
| Xbox Forza Horizon 6 Limited Edition controller | Smyths £69.99 (Argos £69.99 and Currys £84.99 retained) | a1d8e16b-fda7-4787-a76f-3256a291b314 | d5e11be5-2cf1-4841-8eb0-df4dc13d999b |

Sources:
- Joy-Con pair: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-joy-con-controller-pair-light-purple-light-green/p/257137
- Gioteck WX5+ Argos: https://www.argos.co.uk/product/7572775
- 007 First Light category: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/games/007-first-light/c/007-first-light
- GTA VI category: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/games/grand-theft-auto-vi/c/grand-theft-auto
- Xbox Forza Horizon 6 controller: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/xbox-series-x-s/xbox-series-x-s-accessories/xbox-wireless-controller-forza-horizon-6-limited-edition/p/259862

## Independent verification — LIVE and TEST match

| Metric | LIVE | TEST |
|---|---:|---:|
| Active gaming products | 283 | 283 |
| Active customer-visible products | 275 | 275 |
| Active market evidence | 388 | 388 |
| UK-new evidence | 223 | 223 |
| UK-used evidence | 165 | 165 |
| Visible products missing all evidence | 0 | 0 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

Branch-level product, visible-product and evidence counts match across all 20 gaming branches. Nintendo Accessories: 9 products / 10 evidence. Nintendo Controllers: 105 / 117. PlayStation Controllers: 22 / 36. Xbox Controllers: 29 / 38. Remaining branch counts also match.

## Rules and next steps
- Keep UK GBP, exact product/variant matching, direct source URLs and stable source_record_key.
- Keep UK-new and UK-used separate. UK-used remains reference-only and does not affect automatic buying valuation.
- Preserve special edition, colour and bundle differences; don't duplicate existing masters.
- No TEST tenant/customer/order/payment/ownership data copied into LIVE.
- Continue adding new models and more retailer observations across Nintendo, PlayStation and Xbox. Prioritise masters with one evidence source; add to TEST, verify, then LIVE.
