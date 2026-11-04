# Project Memory — 3D Printer Catalogue Foundation
Date: 4 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main
LIVE branch: production
Supabase TEST: nnsshnfkjcflucjrftzi
Supabase LIVE: gxsrajtqzdjvmceqcpgv

## Verified state

The 3D printer catalogue foundation is present independently in TEST and LIVE.

- Category: **3D Printers & Equipment**.
- Branches: **3D Printers** and **3D Printer Equipment & Accessories**.
- 25 active customer-visible master products.
- 6 manufacturers: Bambu Lab, Creality, Anycubic, Elegoo, Flashforge and Prusa Research.
- 33 active UK GBP evidence rows: 23 `uk_new`, 10 `uk_used`.
- TEST and LIVE have identical product/package coverage but separate UUIDs.
- Both environments: 0 active visible products without active evidence; 0 visible products without a branch; 0 active evidence integrity failures.
- The equipment/accessories branch is present but empty; no accessories were added in this batch.

## Preflight findings and actions

- TEST already contained category `3D Printers & Equipment`, the two branches and eight initial printer products, but those eight products had no market evidence.
- LIVE did not contain the 3D printer category, branches or those initial products.
- The existing TEST category/branches/products were retained. LIVE was populated independently with a matching category, matching branches and matching baseline products.
- No TEST product/evidence UUID was copied to LIVE.
- No application code, valuation logic, RLS, Edge Function, Stripe configuration or Cloudflare Worker was changed.

## Product and package coverage

| Manufacturer | Product / package |
|---|---|
| Bambu Lab | A1 standard; A1 AMS Lite Combo |
| Bambu Lab | A1 Mini standard; A1 Mini AMS Lite Combo |
| Bambu Lab | P1S standard; P1S AMS Combo; P1S AMS 2 Pro + Upgrade Kit |
| Bambu Lab | P2S standard |
| Bambu Lab | X1 Carbon standard; X1 Carbon AMS Combo |
| Bambu Lab | X2D standard; X2D AMS 2 Pro Combo |
| Creality | Ender-3 V3 KE; K1C |
| Anycubic | Kobra X; Kobra 4 ACE 2 Pro Combo; Photon Mono M5s; Photon P1 |
| Elegoo | Centauri Carbon 2 CANVAS Combo; Saturn 4 Ultra 12K; Saturn 4 Ultra 16K |
| Flashforge | AD5X; Adventurer 5M; Adventurer 5M Pro |
| Prusa Research | MK4S |

The category/branch names and product/package model must remain consistent. AMS/AMS Lite/AMS 2 Pro bundles and other package variants are separate master product records; do not combine their prices with the standard printer.

## Product UUIDs — TEST / LIVE

| Product/package | TEST product UUID | LIVE product UUID |
|---|---|---|
| Bambu A1 — standard | 96ac62bf-258a-40c5-9030-24121c6628b3 | 6c70c94c-279f-4b46-931f-e99c421c9473 |
| Bambu A1 — AMS Lite Combo | 721a6b10-a28a-4ab7-a51b-faf4d92fee16 | d29efc60-2f84-4d9f-afe3-f2bc632df2a7 |
| Bambu A1 Mini — standard | 0ecdfd71-ecf7-42ee-ac4b-9daed5a44f7e | 374e66a2-61aa-47fb-a9ea-ebb1ca48669d |
| Bambu A1 Mini — AMS Lite Combo | 6ec54666-27df-4f88-87e3-362e2f0cdc5b | 8a7e77ca-7b03-4f2e-a8f6-00f1afa9b160 |
| Bambu P1S — standard | c1b19bad-e394-4c1d-aa4c-7a0d0c42acc4 | 5e802d1a-b42f-4df5-8335-6597648ec248 |
| Bambu P1S — AMS Combo | 4ef5b330-eee6-4329-b7d1-29fdda609bb8 | e31f42ad-1b74-4282-8ba3-02eed54ba5f3 |
| Bambu P1S — AMS 2 Pro + Upgrade Kit | ded78502-162c-4583-a100-955182472d88 | 4040ea5d-6a6f-47bc-b50a-d58a453da414 |
| Bambu P2S — standard | 36ea3fbd-c9c0-4a7f-9dc1-a8ca41c837af | 4e6a0fff-c003-4568-9afe-86584892e3d1 |
| Bambu X1 Carbon — standard | 367c179e-3e80-4921-90af-cbc1fc0a3b1d | d0670463-6396-40bc-bb02-8f7f1c083ea9 |
| Bambu X1 Carbon — AMS Combo | aef6fd2f-b2b4-4025-823b-fbf5538226cd | a80064d5-7b45-4c3c-81f9-86eb26d7d8ff |
| Bambu X2D — standard | c8697e70-db92-4b03-ac18-f6dc6b6179f2 | 540f129f-9e0a-4fbb-84c3-96f3f6dd7168 |
| Bambu X2D — AMS 2 Pro Combo | 6d874759-5423-4c80-b500-37678aa29ce8 | d46ca34c-981c-4f6b-8639-f72ab12fc7d8 |
| Creality Ender-3 V3 KE | 70f45a79-ea90-4c02-80bb-1e4743533801 | baddc1cc-891c-43d1-8538-6e270a0f1776 |
| Creality K1C | 5d4f1ba2-c6f6-4c6a-af57-89058b041f00 | 8e9aaad8-8f2e-4b59-b095-7448dc1cdd7d |
| Anycubic Kobra X | ba77e1a4-f75b-4e09-8ca4-e52debcd0a08 | 95fc3151-35ac-44e4-8717-f6d06e458f6d |
| Anycubic Kobra 4 — ACE 2 Pro Combo | 80e77b9e-0064-4a4d-a835-9e3cbfc7431e | 27067c2f-cbbd-442f-8912-222f0edfd05a |
| Anycubic Photon Mono M5s | 1b180514-f284-4a78-9ebd-e1dbe1e16b11 | 826ccafd-ff74-42c4-a1f1-128fc3a8969e |
| Anycubic Photon P1 | 21bd7bea-1980-4da2-9a6f-4588e51865ca | dd8ed62a-e900-4f52-9ba9-41cc1894fcff |
| Elegoo Centauri Carbon 2 — CANVAS Combo | b4b941f1-97e6-42cd-880d-9a04db07daf0 | 67d82d75-cf0a-40e5-a391-1f52367b277d |
| Elegoo Saturn 4 Ultra 12K | 740ce64e-b4f0-4f46-8b0b-a7cf552942a3 | c619d106-fcf2-4e3f-890d-152ba21825c8 |
| Elegoo Saturn 4 Ultra 16K | b7870d56-f3e4-4444-8dcf-44fcbaa46c30 | bb2cb25d-62f3-4a46-902c-edf083651d81 |
| Flashforge AD5X | 3ed8ec66-1780-4bbc-8a3e-a171ed409b23 | 3d30038d-85d7-49f5-9298-301964e9b260 |
| Flashforge Adventurer 5M | 117851ae-6c87-4d7e-9d46-133f18d01618 | 307088b9-de33-44ac-939a-e117901e1338 |
| Flashforge Adventurer 5M Pro | 315796e6-a2f5-4478-9458-e3be1b1d16a0 | 03f9518d-ed17-4c53-b8ef-2776021468b0 |
| Prusa Research MK4S | 4384971d-29ee-46c5-a029-0f388f81e4d1 | c1e673ba-0d42-4806-8b8f-905148ef6407 |

## Evidence mapping — TEST / LIVE

All prices below are GBP. Each evidence row has its own exact source URL and stable source_record_key in both environments. Evidence UUIDs differ between TEST and LIVE.

| Product/package | Type | Price | Source URL | TEST evidence UUID | LIVE evidence UUID |
|---|---:|---:|---|---|---|
| A1 standard | uk_new | £209.00 | https://www.additive-x.com/shop/bambu-lab-a1-3d-printer.html | 9db04e6f-ae06-4653-bd93-cdc2fc20b6cf | 054e117b-088e-4b16-a72f-0cdf0eaf50ed |
| A1 standard | uk_used | £165.92 | https://www.ebay.co.uk/itm/257795333603 | e0daaad8-67c7-4903-913d-99f48a6c0762 | 9a12c4db-5c94-400b-a48f-10f92961643e |
| A1 AMS Lite Combo | uk_new | £319.00 | https://www.additive-x.com/shop/bambu-lab-a1-combo-3d-printer.html | 2563065a-5571-4ca3-bba3-a00d0d3a615b | 57fbbaca-c840-478f-a4cf-3c39cbcc260c |
| A1 Mini standard | uk_new | £149.00 | https://www.additive-x.com/shop/bambu-lab-a1-mini-3d-printer.html | 11085604-350f-4ddf-b2c2-cf41566bcf1b | 7a5c58d2-f8f0-4fd4-8198-634c07b26110 |
| A1 Mini AMS Lite Combo | uk_new | £259.00 | https://www.additive-x.com/shop/bambu-lab-a1-mini-combo-3d-printer.html | d9aa0a83-d072-4148-910b-630529aef355 | 537eae5f-f561-4268-bee2-240bd85f4be9 |
| AD5X | uk_new | £299.00 | https://uk.flashforge.com/products/ad5x-3d-printer | c850e8f9-be63-4053-943e-78b28e586f8e | e20c2815-1f36-40ee-882e-d6dcd2241b33 |
| AD5X | uk_used | £191.35 | https://www.ebay.co.uk/itm/237093687972 | 880f4713-d7a7-4027-8908-39e305fe0830 | 9f5c20fc-5ed2-4023-9fb4-11f20f03e011 |
| Adventurer 5M | uk_new | £209.00 | https://uk.flashforge.com/collections/3d-printers | 0cc95165-0db5-4203-a678-67e4616a297f | bd897a0b-dc67-4a5f-8dd8-67e7ed0bec3e |
| Adventurer 5M Pro | uk_new | £339.00 | https://uk.flashforge.com/products/adventurer-5m-pro-3d-printer | f9d51be5-0d1c-42e7-b794-1b4c3b5fb060 | f714c1f4-813e-47fd-b348-10810cee1b51 |
| Centauri Carbon 2 CANVAS Combo | uk_new | £329.00 | https://uk.elegoo.com/products/centauri-carbon-2-combo | 4e12edc8-1e54-430d-830c-b08e0e54650e | 61ccdf24-8d28-46ff-ba36-2daef6f77d80 |
| Centauri Carbon 2 CANVAS Combo | uk_new | £320.75 | https://www.ebay.co.uk/itm/227489528168 | 7323fd34-4a8e-4b34-b8e7-65ceb7ed1ec7 | 585a00f2-935f-4924-9dee-6e0512ce375e |
| Ender-3 V3 KE | uk_new | £219.00 | https://store.creality.com/uk/products/ender-3-v3-ke-3d-printer | 0fa2a42e-14da-4688-a4e7-e565a19bcdc5 | 8e34ee30-171a-47b5-9435-e04a48af1674 |
| Ender-3 V3 KE | uk_used | £210.00 | https://www.ebay.co.uk/itm/158118926606 | 660a4def-9713-4bb9-87b0-a2a2d4543a9c | ab95f656-521c-443c-82c7-4d8b54d1e2e3 |
| K1C | uk_new | £379.00 | https://store.creality.com/uk/products/k1c-3d-printer-2025 | ed644f54-6151-41e6-a72c-e16078262036 | bdbdc2cb-ff78-4a96-be2f-a2fd033cc6af |
| K1C | uk_used | £237.35 | https://www.ebay.co.uk/itm/336610541529 | 49c72ec2-d9c0-4034-9090-fd57337aaa13 | ab256783-7b8a-41e9-8564-1f3c58616f72 |
| Kobra 4 ACE 2 Pro Combo | uk_new | £289.00 | https://uk.anycubic3d.com/products/kobra-4-combo-3d-printer | e2e97ee1-d63f-486a-b97e-ab4254be9287 | 5d603046-abf4-4621-8b32-457dba8d816b |
| Kobra X | uk_new | £279.00 | https://uk.anycubic3d.com/products/kobra-x-3d-printer | d4eeefac-4105-401b-b9a6-534592834886 | 53f73913-63c8-46fc-9902-f457741c761a |
| MK4S | uk_new | £649.00 | https://www.fabinity.com/brands/prusa | 207b4724-fc71-456d-b3ff-93461bcac01d | 5c07dbf4-b787-4dd8-8f85-f13eb32633c8 |
| MK4S | uk_used | £498.37 | https://www.ebay.co.uk/itm/257534318788 | f687a33b-8b82-4b67-ae46-3a46df3aeb64 | 18d7fe5f-27fe-4299-a852-b792822a393b |
| P1S AMS 2 Pro + Upgrade Kit | uk_new | £559.00 | https://www.additive-x.com/shop/bambu-lab-p1s-3d-printer-with-ams-2-pro-and-upgrade-kit.html | 14aae8cd-d0d7-4744-879d-50846488b421 | e412c59f-121e-464f-8f94-8f558a1d1150 |
| P1S AMS Combo | uk_new | £469.00 | https://www.additive-x.com/shop/bambu-lab-p1s-combo.html | 3a06dec9-e465-47f9-8ac7-fd39ee953f3d | b767bc12-cb2c-4b48-922b-3a7ef967a0d7 |
| P1S standard | uk_new | £329.00 | https://www.additive-x.com/shop/bambu-lab-p1s.html | 7dce1b71-e80f-461f-b887-3fd28f145ae2 | 9d000e68-2bc3-4b68-be41-6a0308ae5043 |
| P1S standard | uk_used | £279.58 | https://www.ebay.co.uk/itm/237068207808 | c6dead9c-f4c4-4d32-a7c4-ce32d5808429 | e80c7194-658f-4e36-adbe-7dcb631e6107 |
| P2S standard | uk_new | £449.00 | https://www.additive-x.com/shop/bambulab-p2s-3d-printer.html | c9e722fa-b00a-499c-9c3c-cdf0ecdb5845 | 333a12af-0ffc-427a-a3d8-771462d00bb2 |
| Photon Mono M5s | uk_used | £224.04 | https://www.ebay.co.uk/itm/205412303845 | 321ad8a8-7428-4e07-b6ee-643fa181494d | ec8f7a27-d60f-478e-b68a-944ca66dc48b |
| Photon P1 | uk_new | £449.00 | https://uk.anycubic3d.com/products/photon-p1-resin-3d-printer | 7504d12b-d51a-4663-9f7d-c786e4c64b3d | 8d63eb19-6dd8-46e2-a5d3-93fde6367e79 |
| Photon P1 | uk_used | £372.68 | https://www.ebay.co.uk/itm/377193358673 | a6dd5107-1f6c-4b64-a244-b976fa6ad2a4 | 64340e62-c7af-44ce-836e-2c0cd4c3adc9 |
| Saturn 4 Ultra 12K | uk_new | £349.00 | https://uk.elegoo.com/products/saturn-4-ultra-12k-10inch-monochrome-lcd-resin-3d-printer | b3e6c5b6-a45f-49de-a731-ae175a098031 | c8b569b8-ffa8-4cfa-a775-3013e8962bc2 |
| Saturn 4 Ultra 16K | uk_new | £399.00 | https://uk.elegoo.com/products/saturn-4-ultra-16k-10inch-monochrome-lcd-resin-3d-printer | 83b9c6af-9e5e-45de-9809-96e131abe04b | 0225cc62-849f-47d3-8a45-21c18566d322 |
| X1 Carbon AMS Combo | uk_used | £460.00 | https://www.ebay.co.uk/itm/820126498565 | dd18e4de-2b27-42e3-9625-d9200e6fb54b | b9847cef-d802-48b2-8e28-11cc40c3f096 |
| X1 Carbon standard | uk_used | £544.82 | https://www.ebay.co.uk/itm/267781788291 | c494a35e-5b33-44b7-83e6-fc925da3fec4 | a8136a44-caa4-4e55-bc02-5cdeba544bf2 |
| X2D standard | uk_new | £569.00 | https://www.additive-x.com/shop/bambu-lab-x2d-3d-printer.html | 3c8f81b5-2669-46ad-aa8b-21cff7b0c41a | e72ae557-cfe9-48ad-abea-2b0ada3c3670 |
| X2D AMS 2 Pro Combo | uk_new | £669.00 | https://www.additive-x.com/shop/bambu-lab-x2d-combo-3d-printer.html | 0d4960e8-88ac-4d2c-a719-988545ffd396 | 7b2b5711-13ca-4919-8fe2-75082d6bf617 |

## Evidence caveats

- eBay buyer-facing totals include Buyer Protection on several sold items. The recorded notes preserve the fee and clarify that the displayed total is not seller proceeds.
- Photon Mono M5s £224.04 is a currently listed used asking price, not a completed sale. Its official UK new listing was sold out; no current new-price evidence was added.
- Flashforge Adventurer 5M £209 is the current official UK collection offer; the product page separately shows £259 with a £50 checkout discount. The captured evidence note records this discrepancy.
- Saturn 4 Ultra 12K: £349 is the explicit Brand New option; the page headline also shows a separate £279 promotional figure.
- Saturn 4 Ultra 16K: £399 is the explicit Brand New option; the page headline also shows £359.
- X1 Carbon AMS Combo used evidence is £460; the listing says the printer works but the AMS is untested.
- X1 Carbon standard used evidence £544.82 is a UK-local sold listing; the title identifies X1 Carbon while item specifics use the broader Bambu Lab X1 label.
- MK4S new £649 is captured from the Fabinity UK Prusa brand listing, where the MK4S kit is listed in stock.
- eBay UK completed sale prices are not equivalent to seller proceeds and do not include assumptions about condition beyond the recorded listing.

## Category and branch UUIDs

- TEST category: cc35aadb-5c1e-439b-8cf9-70ac07e82044
- TEST 3D Printers branch: b716ae40-d711-4a0a-a72c-9cf19fee880a
- TEST Equipment & Accessories branch: 1e45de21-2100-4d1b-8839-319a38a01397
- LIVE category: ab8b13b0-b070-4534-838b-3ebd4d7261e5
- LIVE 3D Printers branch: 59873baa-da84-461c-a8c3-4b8fd4359bcb
- LIVE Equipment & Accessories branch: 8437a905-c72b-4cfb-9d6c-af0dec00f222

## Documentation and code state

- Human/Developer System Handbook updated to v4.5 in main; commit feda1c7a16b7c585faefb6ccc12d2be2288053bd.
- AI Operating Manual updated to v4.4 in main; commit 6d19386a0469c9aa155885931ee180c5239fb027.
- No schema, application code, valuation logic, RLS, Edge Functions, Stripe or Worker changes.
- No non-system structured Supabase project-memory/checkpoint table exists in this project; repository project-memory and checkpoint files are the authoritative continuity record.

## Next work

1. Continue comprehensive model coverage for Creality, Bambu Lab legacy/current, Anycubic, Elegoo, Flashforge, Prusa, QIDI, Phrozen, Formlabs, UltiMaker, Snapmaker, Raise3D and industrial/specialist brands.
2. Add older/discontinued models where they have a UK second-hand market, marking lifecycle accurately rather than inventing new prices.
3. Add exact UK used sold evidence and UK new listings per exact product/package; keep package variants separate.
4. Populate the Equipment & Accessories branch only with actual accessories (enclosures, build plates, AMS systems, wash/cure stations, hotends, etc.) when researched as separate products.
5. Re-run TEST/LIVE parity and evidence integrity checks after every batch.
6. Never let market evidence update automatic buying valuations.
