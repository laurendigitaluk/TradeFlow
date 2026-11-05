# TradeFlow Mobile Phone Catalogue — Batch 108 (5 November 2026)

## Scope and write boundary

This batch applied real catalogue/evidence writes independently to the two current TradeFlow Supabase projects. No TEST rows were copied wholesale into LIVE. Shared product/evidence rows were reconciled by manufacturer, model, package key and stable source record key; each environment retains its own UUIDs.

- TEST: `nnsshnfkjcflucjrftzi`
- LIVE: `gxsrajtqzdjvmceqcpgv`
- Retired TEST project `twfbmjwwqzxdxvclxbun` was not used.

## UK used/refurbished evidence inserted

Fourteen UK GBP observations were inserted in each environment for these exact packages:

| Product package | Research evidence added |
|---|---|
| Google Pixel 8 128GB | The Big Phone Store Good (Hazel £189.99; Obsidian £194.99), Very Good (Hazel £199.99); The iOutlet Good (Hazel £199.99), Excellent (Rose £229.99); CGX UK Grade C (Obsidian £179.99) |
| Apple iPhone 14 128GB | giffgaff Good £229; XTEC UK Pristine £299.99 |
| Samsung Galaxy S23 256GB | giffgaff Very Good £319; giffgaff Excellent £349; Laptops Direct Very Good £299 |
| Samsung Galaxy S23 128GB | The Tech Gadgets Very Good £225.99 |
| Motorola Edge 50 Neo 256GB | Currys Clearance eBay Excellent - Refurbished £207.60; exact 8GB/256GB listing |
| Apple iPhone 15 Pro 256GB | Cash Converters £399.99 used, 80% battery health and noticeable cosmetic wear; not Excellent |

The 14 current-batch source keys use the `mobile-...-20261105` namespace. Duplicate protection uses the unique `(source_name, source_record_key)` constraint. Conditions and stock caveats are retained in each evidence row's condition, availability and notes fields.

## LIVE catalogue reconciliation

Two valid active customer-visible package rows existed in TEST but were absent from LIVE. They were added to LIVE with LIVE-specific IDs:

| Product | TEST product ID | LIVE product ID |
|---|---|---|
| Samsung Galaxy S23 128GB | `f49a70ef-f4d6-402c-b2c9-befdb0cffde5` | `fe3dff9b-e83b-47af-b458-1315557cb448` |
| Google Pixel 10 128GB | `f2581bf9-eaca-4465-98b7-8c47dedcdb68` | `6c2cdae5-1184-4d0a-b31d-b85c2c123154` |

The Pixel 10 128GB product already had three active UK evidence rows in TEST (two `uk_new` observations: opened/never-used and sealed; one `uk_used` Good sold observation). Those three shared evidence observations were mirrored to LIVE using the LIVE product ID and the existing source keys.

The Samsung Galaxy S23 128GB row in TEST already existed; its missing LIVE package was added and the current UK-used retailer observation was inserted in both environments.

### Deliberately excluded products

- Apple iPhone 18 256GB remains a hidden unverified seed in TEST; it was not copied to LIVE.
- Google Pixel 11 128GB is marked inactive/hidden in TEST because it is an invalid storage variant (official UK base model starts at 256GB); it was not copied to LIVE.

## Verified post-write state

| Environment | Mobile products | Active products | Active customer-visible products | Mobile evidence rows | Active evidence rows | New batch evidence |
|---|---:|---:|---:|---:|---:|---:|
| TEST | 160 | 159 | 156 | 571 | 555 | 14 |
| LIVE | 158 | 158 | 156 | 565 | 552 | 14 current-batch rows + 3 mirrored Pixel 10 rows |

A business-key comparison confirmed exactly 156 active customer-visible product keys in each environment, with no missing keys in either direction. The total product-row difference is intentional: TEST retains the hidden iPhone 18 seed and retired Pixel 11 128GB audit row, while LIVE does not.

## Product IDs for the current batch

| Product | TEST ID | LIVE ID |
|---|---|---|
| Google Pixel 8 128GB | `ee8ec37f-b5d5-4c27-aa0c-f2fdab8df4fd` | `545e85a4-eb4d-42ef-a875-6676f66bab0d` |
| Apple iPhone 14 128GB | `10e0b1f3-dd19-45f5-bfd4-dfb1768e8505` | `c7505495-eca4-4a3f-ac8b-8379c1549a9f` |
| Samsung Galaxy S23 128GB | `f49a70ef-f4d6-402c-b2c9-befdb0cffde5` | `fe3dff9b-e83b-47af-b458-1315557cb448` |
| Samsung Galaxy S23 256GB | `04f53613-37f1-4585-abd6-4004d18ec221` | `0da578da-246d-496d-8969-b2378b58a624` |
| Motorola Edge 50 Neo 256GB | `92345890-6cc8-4641-8f06-e4995c15397e` | `530fef04-612f-436b-b338-2f01b096e9dc` |
| Apple iPhone 15 Pro 256GB | `4c5479a7-97c6-46ee-9f6f-c9e7e4cc31a0` | `496f925d-83d1-427d-ad15-fe1ca0cfa035` |
| Google Pixel 10 128GB | `f2581bf9-eaca-4465-98b7-8c47dedcdb68` | `6c2cdae5-1184-4d0a-b31d-b85c2c123154` |

## Safety and deployment

- Data-only catalogue/evidence changes.
- No schema, application code, valuation logic, RLS, Edge Function or Worker changes.
- No deployment performed or required.
- No tenant, customer, transaction, subscription, payment, domain, ownership or published website data was changed.
- No LIVE Stripe configuration was touched.

## Next work

Continue the next mobile research batch by checking current exact package rows and evidence in both environments first, then insert valid UK evidence independently into each environment. Add new catalogue product rows only where an exact verified UK model/package is absent. Keep TEST/LIVE active customer-visible product keys aligned.
