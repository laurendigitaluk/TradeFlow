# Gaming Console Catalogue — Continuation Batch 01
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
Branches: main (TEST documentation) and production (LIVE documentation)

## Scope
Continue the Gaming Consoles & Accessories master catalogue, add newly verified console/retail variants and evidence, and restore TEST/LIVE parity without touching tenant or transaction data.

Supabase environments:
- LIVE: gxsrajtqzdjvmceqcpgv
- TEST: nnsshnfkjcflucjrftzi

## Products and evidence added

### Nintendo Switch 2 — The Legend of Zelda 40th Anniversary console
Added a separate active/customer-visible master product in both environments. This is a distinct console package, not a duplicate of the standard Switch 2 and not the separate Zelda 40th Anniversary Pro Controller.
- UK new price: £429.99 GBP, Smyths Toys UK.
- Source: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-consoles/nintendo-switch-2-the-legend-of-zelda-40th-anniversary-edition-console/p/266502
- Availability shown as pre-order / expected in stock 5 November 2026.
- Package key: zelda-40th-anniversary-256gb.
- Stable evidence key: smyths-switch2-zelda-40th-console-266502-uk-new-20261105.
- LIVE product 916a5fda-15f4-42e8-9a35-5b28c484c9e2; evidence 14f07bfe-08cb-4e3b-9787-4db4b346152a.
- TEST product e8dc9421-8b85-43e0-87de-71ebf26bb67f; evidence 5f0f2069-a442-4189-bbda-51bca51016f0.

### Nintendo Switch 2 Pro Controller — The Legend of Zelda 40th Anniversary Edition
Added two further UK-new retailer observations to the existing exact controller master. Existing Currys evidence was retained.
- Argos: £64.99; https://www.argos.co.uk/product/9630952
  - Stable key: argos-switch2-zelda40-pro-9630952-uk-new-20261105.
  - LIVE evidence 338dda77-94f3-4426-8a6b-a858f4339037.
  - TEST evidence aecd6462-d98f-40d1-9d73-11b92f6c0e69.
- Smyths Toys UK: £79.99; https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-the-legend-of-zelda-40th-anniversary-edition-pro-controller/p/266456
  - Stable key: smyths-switch2-zelda40-pro-266456-uk-new-20261105.
  - LIVE evidence c823a00e-ae08-423b-acad-3dccc88cc9e9.
  - TEST evidence d63a057f-6d61-444c-870a-8191f6d26a19.
- Existing Currys UK evidence remains £74.99 (LIVE 7139cb37-c834-4471-be75-82ded2c07256; TEST 7cb30e70-bd8f-4d45-887c-ce998d32387a).
- The three-source spread is £64.99–£79.99. Keep each retailer observation separate; do not collapse them into one price.

## TEST/LIVE parity repair

### Xbox controller
The TEST catalogue contained an additional verified product that was absent from LIVE:
- Xbox Wireless Controller — Shock Blue, package key xbox-wireless-controller-shock-blue.
- Argos UK new: £59.99; https://www.argos.co.uk/product/8399139/GM-Variant
- Stable key: argos-xbox-shock-blue-2026-11-05.
- LIVE product ae034a43-c388-49bf-b1da-11a136ddeb13; evidence 9f690f7e-6bd8-435a-ab78-3f346b2fc0de.
- TEST product b7efaed8-d9e9-4af5-ae78-ada86a365363; evidence 14a7c6fb-1284-4343-9514-29ac24680440.
The product and evidence are now present in both environments. No TEST record was deleted.

### PlayStation handheld evidence parity
Three already-verified TEST observations were missing from LIVE. Matching evidence rows were inserted against the exact corresponding LIVE product masters:
- PSP-2000, eBay UK completed sale £69.43, item 860086510676, key ebayuk-860086510676-psp2000-20261027.
  - LIVE evidence 57198479-79ee-4202-857b-1878ed3a74af.
  - TEST evidence 2751e821-2eee-43fa-aa41-07195141d7ab.
- PSP Go (PSP-N1000), eBay UK active used listing £140.00, item 277314993924, key ebayuk-277314993924-pspgo-black-20261030.
  - LIVE evidence e6439fed-8aee-463e-92d5-ea2b010c7e64.
  - TEST evidence eefe9d8a-5100-4bd0-babb-a940876f2ec6.
- PlayStation Vita OLED (PCH-1000), eBay UK completed sale £138.98, item 267796509409, key ebayuk-267796509409-vita1000-oled-20261011.
  - LIVE evidence 20e7f652-4bd3-4036-b19a-d30b3fb836cc.
  - TEST evidence 461f0daf-0d66-43e7-92aa-350a216d86e2.
Historical listing/sale distinctions and conditions were retained. No product master was duplicated or overwritten.

## Evidence URL repairs
Populated previously-null source URLs without changing prices or evidence classification:
- LIVE Nintendo Switch 2 Joy-Con 2 Charging Grip / John Lewis £25.99: https://www.johnlewis.com/nintendo-joy-con-2-charging-grip-black/p113587848
- TEST DualSense Starlight Blue / Argos £59.99: https://www.argos.co.uk/product/1256028/
- TEST DualSense Nova Pink / Argos £59.99: https://www.argos.co.uk/product/1256035/

## Verification — independent LIVE and TEST queries
Both environments now match:
| Metric | LIVE | TEST |
|---|---:|---:|
| Active gaming master products | 277 | 277 |
| Active customer-visible products | 269 | 269 |
| Active evidence rows | 376 | 376 |
| Active UK-new evidence | 211 | 211 |
| Active UK-used evidence | 165 | 165 |
| Visible active products missing all active evidence | 1 | 1 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

The one visible product with no active evidence in either environment is WD_BLACK C50 Expansion Card, 512GB, under Xbox Accessories. Do not invent a price; continue researching a direct, exact UK source.

A further 85 visible products currently lack UK-new evidence; many are older/used-only models and must not be given stale launch prices. Continue sourcing exact current UK-new evidence where available and keep UK-used reference evidence separate.

## Data and valuation rules
- Evidence remains UK-only, GBP, exact product/variant matched, with stable source_record_key and source URL.
- uk_new and uk_used remain separate.
- Active retailer asking prices/pre-orders are not completed sales.
- eBay sold observations remain sold; active listings remain listed/active as recorded.
- UK-used evidence is reference-only and must not change automatic buying valuations.
- Preserve separate package/edition variants and existing historical evidence.
- TEST and LIVE product/evidence UUIDs are environment-specific. Never copy TEST business, tenant, customer, order, payment or ownership data into LIVE.

## Change boundary
Database-only catalogue/evidence changes. No application code, schema, valuation logic, RLS, RPC, Edge Function, Cloudflare Worker, Stripe, tenant, customer, order, payment or custom-domain changes. No Worker deployment required.

## Structured memory check
No TradeFlow project-memory/checkpoint table or application function was found in the Supabase database schemas. The repository PROJECT-MEMORY and CHECKPOINTS files remain the verified continuity layer for this workstream.

## Next action
Continue with the remaining exact gaming-console models and accessories, prioritising the WD_BLACK C50 512GB UK-new evidence gap and new/used evidence coverage. Run duplicate/model/branch preflight independently in TEST and LIVE, add TEST first, verify, then add and verify LIVE. Update this checkpoint and aggregate project memory after each material batch.
