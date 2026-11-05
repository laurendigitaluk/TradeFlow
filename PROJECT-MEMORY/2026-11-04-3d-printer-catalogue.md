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


## Batch 2 — Bambu Lab expansion (4 November 2026)

Updated verified snapshot in TEST and LIVE: **39 products, 6 manufacturers, 47 active UK GBP evidence rows (36 new, 11 used)**. Both environments pass the same checks: zero visible products without active evidence, zero null branch assignments and zero evidence integrity failures. The two established branches remain unchanged.

Batch 2 added 14 Bambu Lab products/packages:
- A2L standard and AMS Combo.
- H2D standard, AMS 2 Pro Combo, Engineering Bundle, More Colour Bundle, 10W and 40W Laser Full Combos, and H2D Pro.
- H2C Vortek AMS 2 Pro Combo.
- H2S standard, AMS 2 Pro Combo and 10W Laser Full Combo.
- Legacy P1P standard.

A2L standard is recorded as backorder because the UK retailer page says “Ships When Available”. P1P has used-only UK evidence. All bundle variants remain separate master products.

### Batch 2 product IDs — TEST / LIVE

| Product/package | TEST UUID | LIVE UUID |
|---|---|---|
| A2L standard | 326ce741-c669-4604-abd2-afccaf0b4b0d | 38347f9c-1066-4469-9449-127a8d28b965 |
| A2L AMS Combo | 5cb5a0de-6f9c-4b7b-a682-9572f493f0ed | 4ccaa072-7bd5-4409-8d7a-feb7b1dec0ed |
| H2D standard | aa7a5588-0ee7-4900-ae09-d41d8230f7e8 | 3e77287d-506e-4f6b-aecd-b098533e7262 |
| H2D AMS 2 Pro Combo | 240eea57-ef94-4a98-9bce-caeac9ba114a | 3b6c898d-bdd4-4565-af32-f05d058f591d |
| H2D Engineering Bundle | 03a09949-dd50-4341-8fdb-becad05c6abb | 8ce10368-437e-444c-a841-3704fa509868 |
| H2D More Colour Bundle | 35072006-f48b-43bf-b4cf-22e2b5fb5eca | 92aa480f-f194-4e40-9161-4199eaf1e99d |
| H2D 10W Laser Full Combo | c41c098f-b882-4ead-bb0c-840958889bf7 | 0fea6f10-bc84-403c-b789-040f4cfaefea |
| H2D 40W Laser Full Combo | 62b48032-1db1-44cb-a32b-b7eaaaac55c6 | d141e550-67ba-4072-86ac-b7448ed4e306 |
| H2D Pro | 3e7e26f4-1949-45a9-bb90-e7ea1bb17866 | 41131459-9762-4389-a17c-7f97727e85cb |
| H2C Vortek Combo | e8ae7ea5-58fe-4c03-8398-e4c027f33ed9 | dc69207a-b476-45ff-82b4-e9e52f65df13 |
| H2S standard | 88eb1b09-c12a-42c8-a59a-0e40618a1a9f | fea520db-9c7b-4f97-b221-7da18e459392 |
| H2S AMS 2 Pro Combo | b5308296-88c0-48e2-b0f9-0c27787d7a85 | 50ab9b2b-d782-412e-8a6f-7f2a5205dc4c |
| H2S 10W Laser Full Combo | 34feabc7-9c22-4ea3-a44e-d5033ace59b6 | c1e6d39c-eade-4567-9b96-c03bb0c038ab |
| P1P standard | 48dde6d2-dbe4-40ae-ae77-f7dcbd236244 | eefb6287-7de8-4940-9d64-5d597b856c07 |

### Batch 2 evidence IDs — TEST / LIVE

| Product/package | Type | GBP | TEST evidence UUID | LIVE evidence UUID |
|---|---|---:|---|---|
| A2L standard | uk_new/backorder | 319 | f59cdf94-f14d-4d57-9aa0-f5f943893e61 | da0e08ec-2d5a-4a1c-9148-e78e8a9412b4 |
| A2L Combo | uk_new | 429 | 11a1fb45-a63b-45e2-9ee9-0852dd6b0351 | 3f9996a9-99ec-43d4-bd60-480abab53528 |
| H2D standard | uk_new | 1289 | 5c51bce4-6281-487e-ac4b-e3e2d26e4033 | 3ff2c360-df82-4dad-a970-ae12aa328301 |
| H2D AMS 2 Pro Combo | uk_new | 1449 | 3424f88c-9a8f-4779-9d3f-94051e4c6595 | 361fc688-9622-4c95-8048-1e0da1c9dfa4 |
| H2D Engineering Bundle | uk_new | 1539 | 39b57234-8e05-4690-8469-584f91099504 | 268efa1c-deec-4222-9391-0e32ad2fdd92 |
| H2D More Colour Bundle | uk_new | 1889 | 3c4f11d1-4f28-4b32-81ee-7007419d7fdb | a6b20747-17e2-4332-83af-03bb59469f23 |
| H2D 10W Laser Combo | uk_new | 1749 | 111c8ee6-2a6e-4c8d-85f9-46a27e866290 | 574e15b8-1d44-4d3b-8547-e445f551409e |
| H2D 40W Laser Combo | uk_new | 2149 | 4a5ed8cb-4c2c-4849-bc3c-574990f42642 | cba78ccc-43f5-43c2-80d3-bc1acb10709d |
| H2D Pro | uk_new | 2499 | 2e62358d-0b96-4246-b2fe-5a64da76c95b | b3085e5a-5f74-4c09-ae92-9bb71e6068a2 |
| H2C Vortek Combo | uk_new | 1899 | 935303cb-1c48-4b53-8669-80ac4bc33cb8 | 1473f190-d8b7-4373-8161-2b5523c8d893 |
| H2S standard | uk_new | 949 | ef47f85a-bd85-4104-a6f6-61734664be58 | 24ec2e1b-4c8b-449f-bee5-3650bf65b78a |
| H2S AMS 2 Pro Combo | uk_new | 1099 | 540d9309-53b4-419e-b892-45bea0431958 | e0289f7e-c104-4f4e-b5df-636a8ea3ad70 |
| H2S 10W Laser Combo | uk_new | 1399 | 648aeb65-5081-4e4f-9623-193dd31969f1 | 5e909119-8153-4077-b15d-d8f1591166f2 |
| P1P standard | uk_used | 197.61 | ec1f6e57-a3c3-4436-b9f9-04ade141dda2 | bc8e76fd-53a5-43d6-80b9-9cc2bad8d90b |

No code/schema/valuation/RLS/Edge Function/Stripe/Worker changes were made. The full source URLs and evidence notes are recorded in the database rows and Batch 2 checkpoint.


## Batch 3 — multi-manufacturer expansion (4 November 2026)

Current verified TEST and LIVE snapshot: **72 active customer-visible products across seven manufacturers**, with **85 active UK GBP evidence rows** (74 `uk_new`, 11 `uk_used`). Both environments have zero visible products without active evidence, zero visible products without a branch, zero missing evidence URLs/keys, zero non-GBP evidence and zero non-positive prices. The category and two established branches are unchanged.

The catalogue has been expanded across Creality, Anycubic and one additional printer manufacturer. Standard models and multi-material bundle variants remain separate product records. The latest model/package IDs, evidence IDs, prices and source references are recorded in the Batch 3 checkpoint.

Evidence caveats: one current resin printer listing is marked sold out; the legacy Plus4 record is used-only and is supported by a completed UK eBay sale; the £559 Q2 multi-material bundle price is from a UK comparison page reporting the manufacturer direct-store price. Used evidence remains reference-only and never changes automatic valuations.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or Cloudflare Worker changed.


## Batch 5 — 5 November 2026

# Project Memory — 3D Printer Catalogue Batch 5
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Current verified position in both environments
- 128 active 3D printer master products; all 128 customer-visible.
- 141 active UK GBP evidence rows: 126 uk_new / 15 uk_used.
- 12 active manufacturers.
- Zero visible products missing active evidence or branch.
- Zero duplicate active non-null source_record_key groups.
- Zero missing evidence URLs/keys, non-positive prices, non-GBP rows or uk_new condition mismatches.
- Manufacturer counts: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3, Ultimaker 8.

## Batch 5 additions
Added nine ELEGOO models and one QIDI legacy model independently in TEST and LIVE:
- Neptune 4 — £169 new UK retail.
- Neptune 4 Pro — £189 new UK retail.
- Neptune 4 Plus — £279 new UK retail.
- Neptune 4 Max — £377 new UK retail.
- Mars 5 — £154 new UK retail.
- Mars 5 Ultra — £231 selected printer-only variant, bundle excluded.
- Saturn 4 — £299 new UK retail.
- Jupiter 2 — £699 new UK retail.
- OrangeStorm Giga — £2,049 UK pre-order, not in-stock.
- QIDI X-Max 3 — discontinued legacy model; UK eBay used sold observation £361.42 on 30 July 2026 (item 406940086609; includes £11.42 Buyer Protection, not seller proceeds).

Exact environment-specific product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-05.md.

## Environment-specific category and branch IDs
| Record | TEST | LIVE |
|---|---|---|
| Category | cc35aadb-5c1e-439b-8cf9-70ac07e82044 | ab8b13b0-b070-4534-838b-3ebd4d7261e5 |
| 3D Printers branch | b716ae40-d711-4a0a-a72c-9cf19fee880a | 59873baa-da84-461c-a8c3-4b8fd4359bcb |

## Rules
- Continue TEST first, then mirror shared catalogue/evidence independently to LIVE.
- Never copy TEST product/evidence UUIDs into LIVE.
- UK GBP only; keep uk_new and uk_used separate.
- Keep printer-only models separate from packages/accessory bundles.
- Do not mark pre-order products as in-stock.
- Mark discontinued models as legacy in notes; retain for used-market research.
- Used evidence is reference-only and must not affect automatic valuations.
- No Worker deployment is required for database-only catalogue changes.
- Do not alter schema, valuation logic, RLS, Edge Functions, tenant/customer/payment data or Stripe as part of catalogue expansion.

## Next research queue
Continue filling gaps in existing brands (ELEGOO Mars 4/Saturn 3/Neptune legacy models; additional Prusa, Flashforge and QIDI variants), then assess FLSUN and UniFormation models. Verify current/discontinued status, exact model/package identity and UK GBP evidence before adding anything. Avoid aliases and duplicates.


## Batch 6 — 5 November 2026

# Project Memory — 3D Printer Catalogue Batch 6
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production

## Verified state in both environments
- 132 active 3D printer products; all 132 customer-visible.
- 145 active UK GBP evidence rows: 130 uk_new / 15 uk_used.
- 13 manufacturers; FLSUN now has 4 active products.
- Zero visible products missing evidence or branch.
- Zero duplicate active source keys.
- Zero missing evidence URLs/keys, non-positive prices, non-GBP rows or uk_new condition mismatches.
- Manufacturer counts: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, FLSUN 4, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3, Ultimaker 8.

## Batch 6 additions
Added manufacturer FLSUN and four products independently in TEST and LIVE:
- S1 — £499, 3D Prima UK, in stock.
- T1 — £500, 123-3D UK, backordered / available to order.
- S1 Pro — £1,299, FLSUN UK Store, out of stock.
- T1-PRO — £509, FLSUN UK Store, out of stock.

All four have UK GBP new-market evidence. Do not describe backordered or out-of-stock products as currently available. Exact product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-06.md.

## Environment-specific IDs
- TEST category: cc35aadb-5c1e-439b-8cf9-70ac07e82044
- TEST 3D Printers branch: b716ae40-d711-4a0a-a72c-9cf19fee880a
- TEST FLSUN manufacturer: 9fa0aba4-a134-4fbe-93a9-48fdab8e7c95
- LIVE category: ab8b13b0-b070-4534-838b-3ebd4d7261e5
- LIVE 3D Printers branch: 59873baa-da84-461c-a8c3-4b8fd4359bcb
- LIVE FLSUN manufacturer: a89f5624-73f6-411d-bc02-3869792737a0

## Rules and next work
- Continue TEST first, then mirror shared catalogue/evidence independently to LIVE.
- Never copy TEST UUIDs into LIVE.
- UK GBP only; keep uk_new and uk_used distinct.
- Record actual source stock status; do not label backorder or out-of-stock items as available.
- Keep standard printer-only products separate from accessories and bundles.
- Used evidence is reference-only and must not affect automatic valuations.
- Database-only catalogue changes do not require Worker deployment.
- No accessible Supabase project-memory/checkpoint table exists. Do not repurpose platform_ai_settings (provider configuration); update versioned GitHub checkpoint and project-memory files instead.
- Next research: expand FLSUN with verified T1 Max/V400 and assess UniFormation, Prusa and additional Flashforge models. Verify live UK evidence and exact variant identity before inserting.


### FLSUN evidence freshness correction — 5 November 2026

Final source review found that the official FLSUN UK Store S1 Pro and T1-PRO pages were last crawled about five months before this review. Their £1,299 and £509 observations are retained as historical price references only: observed_at is NULL, availability is “Historical listing; current availability unconfirmed”, and their source keys are marked historical. Do not present either as a current available offer. The S1 Pro direct page could not be fetched during review.

A newer UK T1-PRO retailer observation was added separately: 3DShop UK £365.00, marked in stock and ready for dispatch (page last crawled about four weeks before review), https://3dshop.uk/shop/flsun-t1pro/. TEST evidence UUID b7fb29b9-4d1c-4928-9f10-b9cb90dbf862; LIVE evidence UUID a35fd5f9-72ad-4314-9230-b01a08756517. The older FLSUN UK £509 record remains historical and is not merged with the 3DShop offer.

Latest independent TEST/LIVE snapshot supersedes the earlier Batch 6 total: 132 active customer-visible products; 146 active evidence rows (131 uk_new / 15 uk_used); zero missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, invalid prices, non-GBP evidence or uk_new condition mismatches.


## Batch 7 — 5 November 2026

# Project Memory — 3D Printer Catalogue Batch 7
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi | LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Verified position in both environments
- 136 active customer-visible products.
- 150 active UK GBP evidence rows: 135 uk_new / 15 uk_used.
- 13 manufacturers.
- Zero visible products missing evidence or branch.
- Zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches.

## Batch 7
Added four ELEGOO resin printer models in TEST and LIVE:
- Mars 4 — £149 UK new.
- Mars 4 Ultra — £189 UK new.
- Saturn 3 — £214 UK new; collection capture about one month old, stock unconfirmed, recheck before quote/valuation.
- Saturn 3 Ultra — £239 UK new; collection capture about one month old, stock unconfirmed, recheck before quote/valuation.

Exact product/evidence UUIDs and sources are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-07.md.

## Rules
- TEST first, then mirror catalogue and evidence independently to LIVE; never copy UUIDs across environments.
- UK GBP only; separate uk_new and uk_used.
- Keep printer-only products separate from accessories and bundles.
- Retail asking prices are not completed used sales.
- Used evidence is reference-only and must not affect automatic valuation.
- Database-only catalogue changes do not require Worker deployment.
- Preserve separate TEST/LIVE tenant, customer, website, custom-domain and payment data.


## Batch 8 — 5 November 2026
Added ELEGOO Neptune 3 Pro (£127.00, official UK) and Saturn 2 (8K) (£350.00, 123-3D UK; backordered, available to order, 10–14 day estimate) in TEST and LIVE. Neptune 3 Plus and Neptune 3 Max were excluded from new-price imports due to sold-out status; Mars 3 Pro excluded due to weak current availability evidence. The 3D Printers category now has 138 active visible products, 152 active evidence rows (137 uk_new / 15 uk_used), and 13 represented manufacturers in each environment. Zero missing evidence/branch, duplicate keys, missing URLs/keys, non-positive prices, non-GBP evidence or new-condition mismatches. Exact UUIDs and source links: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-08.md. No Worker deployment required.


## Batch 9 — 5 November 2026
Added Flashforge Creator 5 (£719.00; In Stock, £100 automatic cart discount advertised), Creator 5 Pro (£849.00; In Stock, £100 automatic cart discount advertised) and Guider 3 Ultra (£2,999.00; China warehouse dispatch in 30 days) in TEST and LIVE. The 3D Printers category now has 141 active visible products, 155 active evidence rows (140 uk_new / 15 uk_used), and 13 represented manufacturers in each environment. Zero missing evidence/branch, duplicate keys, missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Exact UUIDs and sources: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-09.md. No Worker deployment required.


## Batch 10 — 5 November 2026
Added three Prusa Research printer-only products independently in TEST and LIVE: CORE One+ (Gen 2) (£919 from Fabinity UK; two options, advertised from price), CORE One L+ (£1,829, in stock), and XL+ Single-Tool (£2,109, ships in 4–5 weeks). Exact source URLs and product/evidence UUIDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-10.md.

Refreshed current UK-new Flashforge observations in both environments for existing models: AD5X £359, Adventurer 5M £259, Adventurer 5M Pro £399. Official UK collection says six models available and the product pages describe international local-warehouse fulfilment, typical 2–5 working days; do not claim UK warehouse stock. Checkout promotions may apply.

Verified category totals in TEST and LIVE: 144 active customer-visible products; 161 active evidence rows (146 uk_new / 15 uk_used); 13 manufacturers. Zero missing evidence/branch, duplicate active source keys, missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Used evidence remains reference-only and does not affect automatic valuation. Database-only change; no Worker deployment.


### Batch 10 final correction — 5 November 2026
## Batch 10 — 5 November 2026 (corrected final state)

Added Prusa Research CORE One+ (Gen 2) (£909 from-price; two options), CORE One L+ (£1,829, in stock), and XL+ Single-Tool (£2,099, ships in 4–5 weeks) in TEST and LIVE. Source: https://www.fabinity.com/brands/prusa. Prices are VAT-inclusive; the CORE One+ entry is a from-price and exact assembly/configuration must be checked before quotation.

Added Flashforge CJ270 (£3,499) in TEST and LIVE. Source: https://uk.flashforge.com/products/flashforge-cj270. The official product page retains pre-order timeline language (first 100 units scheduled to ship 15 October, subsequent orders in purchase order), so current fulfilment is not independently confirmed and must not be labelled in stock.

Current indexed Flashforge UK collection confirms AD5X £299, Adventurer 5M £209 and Adventurer 5M Pro £339: https://uk.flashforge.com/collections/3d-printers. These match existing active 4 November evidence. Three temporary Batch 10 evidence rows based on an older cached page (£359/£259/£399) were deactivated and retained as historical only in both environments.

Final verified TEST/LIVE category totals: 145 active customer-visible products; 159 active evidence rows (144 uk_new / 15 uk_used); 13 manufacturers. Zero missing evidence/branch, duplicate active source keys, missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Exact UUIDs and deactivated evidence IDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-10.md. Used evidence remains reference-only and does not affect automatic valuation. Database-only change; no Worker deployment.


## Batch 12 — 5 November 2026
Creality Ender-3 V3 Neo (£199, standard option in stock) and Ender-3 V3 Mega (£519, dispatch timing unconfirmed) added with UK-new evidence in TEST and LIVE. Both environments independently verified at 149 active visible products, 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers, zero integrity exceptions. Exact IDs: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-12.md. No Worker deployment. Used evidence remains reference-only.
