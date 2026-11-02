# Project Memory — Gaming Console and Accessories Catalogue
Date: 2 November 2026
Repository: laurendigitaluk/TradeFlow

This is the aggregate continuity record for the TradeFlow gaming hardware catalogue. The detailed first batch checkpoint is CHECKPOINTS/2026-11-02-gaming-console-catalogue-batch-01.md.

## Current verified position
- Category: Gaming Consoles & Accessories.
- TEST and LIVE both contain 62 master products, 54 active customer-visible products and 125 active evidence rows (17 UK new / 108 UK used).
- Both environments have 0 visible active products without evidence, 0 evidence integrity failures and 0 products with null branch assignments.
- Existing PlayStation and Xbox catalogue records were retained. Ten Sony products previously lacking a branch were mapped to the existing PlayStation branches.
- Nintendo is now a master manufacturer with four branches: Nintendo Consoles, Nintendo Handheld Consoles, Nintendo Controllers and Nintendo Accessories.
- Five Nintendo products and seven active UK evidence rows were added independently in each environment. Product/evidence UUIDs differ between TEST and LIVE.

## Current Nintendo coverage
- Switch 2 256GB: UK new £389.99 Smyths Toys UK (current listing; RRP £419.99) and UK used £309 median across 153 eBay UK sales to 25 Oct 2026.
- Switch OLED 64GB: UK used £145 eBay completed sale.
- Switch V2 32GB: UK used £62.99 eBay completed sale.
- Switch Lite 32GB: UK used £72 eBay completed sale.
- Switch 2 Pro Controller: UK new £74.99 Nintendo Store UK and UK used £47.08 eBay completed sale.

Older Switch models have no new-price evidence in this batch. Keep them active for used valuation and do not infer new prices or lifecycle state.

## Data rules
- New and used evidence remain distinct: evidence_type uk_new / uk_used.
- Currency is GBP only.
- Use availability listed for active retailer listings and sold for completed-sale observations.
- Exact product variant, URL, source_record_key, price and date must match.
- Buyer Protection amounts and accepted-offer ambiguity must be noted; never imply the buyer-facing total is seller proceeds.
- Trade-in/buyback quotes, marketplace asking prices and overseas sales are not equivalent to completed UK used sales.
- Research evidence is reference material only and does not automatically alter buying/valuation prices.

## Environment and architecture notes
- TEST Supabase: nnsshnfkjcflucjrftzi.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- GitHub TEST branch: main.
- GitHub LIVE branch: production.
- No project-memory/checkpoint table was found in non-system schemas of LIVE; do not invent a structured Supabase memory layer. Repository project-memory and checkpoint files are the continuity record for this workstream.

## Open work
1. Expand Nintendo Switch 2 and original Switch accessories with exact UK new and used evidence.
2. Add older Nintendo hardware where supported: 3DS/2DS, Wii, GameCube and relevant controllers.
3. Complete Xbox controllers, headsets, batteries, storage expansion and accessories.
4. Complete PlayStation controllers, VR, headsets, charging docks, cameras and other accessories.
5. Continue reconciling product and evidence coverage across TEST and LIVE without copying environment-specific IDs or business data.

## Source audit correction — 2 November 2026
The original eBay V2 item 318506459251 was sold to a Berlin destination with £50 international postage, so it is not UK-local evidence. The original eBay Switch Lite item 287545083895 was routed via eBay International Shipping to a non-UK destination. Both evidence rows were set inactive in TEST and LIVE, with the reason retained in notes.

Replacements (both current UK used retailer listings, not completed-sale prices):
- Switch V2 32GB with dock and charger, Loughborough Cash Converters listing 017900197278: £110, availability listed. LIVE evidence ID 6706d7d5-c111-4793-bcf0-9f1ba7349c8c; TEST evidence ID fcb57258-55fa-4fc9-a42b-949199ada2d8. Stable key: cashconverters-switch-v2-017900197278-2026-11-02.
- Switch Lite 32GB grey, Jarrow Cash Converters listing 048800234693: £84.99, availability listed. LIVE evidence ID cca866f3-1589-4437-b928-399363e8264c; TEST evidence ID 03e470e5-dfa8-44cb-98f4-602db0823404. Stable key: cashconverters-switch-lite-048800234693-2026-11-02.

The Switch 2 Pro Controller eBay UK sold record 257762800651 was corrected to £56.97 (includes £2.52 Buyer Protection), not £47.08. LIVE evidence ID 881160fb-a1d6-4012-a4fa-465df421e411; TEST evidence ID d7bf18fb-41a2-4f6c-9fbe-46f954ae6a02. The OLED £145 sale was opened and confirmed. The £309 Switch 2 used figure is still a 153-sale PathAu eBay UK median, not a single sold listing.

Corrected TEST and LIVE snapshots remain: 62 master products; 54 active customer-visible; 125 active evidence (17 UK new, 108 UK used); zero visible products missing evidence; zero integrity failures; zero null branch assignments. Two unsuitable eBay rows were deactivated and two UK retailer listings inserted, so active evidence totals remain unchanged. This correction supersedes the earlier V2 £62.99, Switch Lite £72.00 and Pro Controller £47.08 figures in the first-batch record.

## Nintendo accessory batch 2 — 2 November 2026
Three additional master products and five active evidence rows were inserted separately in TEST and LIVE.

### LIVE IDs
- Nintendo Switch 2 Joy-Con 2 Pair: product 62da903d-56df-4701-b781-a718f213ddc9
  - Nintendo Store UK listed £74.99: evidence 821c4940-f9e7-46c9-a8ec-1e6b8dbf2b8c; key nintendo-store-joycon2-pair-2026-11-02.
  - New-condition eBay UK sale £63.22, item 188848813395, London seller; includes £2.72 Buyer Protection: evidence b826663c-aae7-4121-8e57-ec3a7aefa2a1; key ebay-188848813395.
- Nintendo Switch Pro Controller (original Switch generation): product ef90ad04-a002-4b45-870d-9049f6072901
  - Currys UK new listing £49.97: evidence 754cd5e4-8a96-4f08-82ba-2d2778cd5dad; key currys-switch-pro-controller-10160719-2026-11-02.
  - Used eBay UK sale £41.94, item 147630967217, Birmingham seller; includes £2.03 Buyer Protection: evidence 18eb4bae-818a-4ce6-9b33-304a9eb17a71; key ebay-147630967217.
- Nintendo Switch 2 Camera: product 7da146b1-bd07-483f-a295-36ee1784a99e
  - Cash Converters UK pre-owned listing £19.99, Kilburn, fully functional: evidence f2a70a48-4433-4f68-8dce-9708f16c1065; key cashconverters-switch2-camera-044500064522-2026-11-02.

### TEST IDs
- Nintendo Switch 2 Joy-Con 2 Pair: product 20a1aa6b-1617-415b-9682-7be5183b99dd
  - Nintendo Store UK listed £74.99: evidence 8ee0dc6d-6d3d-4dad-8589-98b84783ff0d; key nintendo-store-joycon2-pair-2026-11-02.
  - New-condition eBay UK sale £63.22: evidence c8a7e760-7187-4d77-80a7-a35f3288bdf6; key ebay-188848813395.
- Nintendo Switch Pro Controller (original Switch generation): product cec50b8f-24b2-42fd-8c58-549d55ab8bcb
  - Currys UK new listing £49.97: evidence acf7fee5-514b-4726-bbec-a9414b815300; key currys-switch-pro-controller-10160719-2026-11-02.
  - Used eBay UK sale £41.94: evidence 8ebfaefe-5199-40bf-8f11-9e08dd62cfbf; key ebay-147630967217.
- Nintendo Switch 2 Camera: product ca682dcc-7424-43c9-af92-5daf49a39617
  - Cash Converters UK pre-owned listing £19.99: evidence 8ba98546-d02f-4f75-b1b1-3caa91f909bf; key cashconverters-switch2-camera-044500064522-2026-11-02.

## Batch 2 verification
TEST and LIVE independently return identical totals:
- 65 master products; 57 active customer-visible.
- 130 active evidence rows: 20 UK new, 110 UK used.
- Zero visible active products missing evidence.
- Zero evidence integrity failures.
- Product and evidence UUIDs remain environment-specific. No tenant, customer, transaction or payment data was copied.

## Switch 2 retail source correction — 2 November 2026
The Smyths Toys exact-product URL could not be independently fetched (403), so the £389.99 Smyths evidence row was deactivated. The generic Harvey Norman row also remains inactive. Replaced with the directly opened Argos UK product page, which lists Nintendo Switch 2 Console - Black, 256GB, at £419.99 and confirms included Joy-Con 2 pair, dock, grip, AC adapter and HDMI cable.
- Active source: https://www.argos.co.uk/product/7624867
- Active key: argos-switch2-7624867-2026-11-02
- LIVE evidence ID: b8541ee9-fcdc-4a46-98c0-6a8242d4b099
- TEST evidence ID: 2f7f9991-2941-4760-abcf-898588eb1c35
- Price: £419.99, GBP, UK new, availability listed.
This supersedes the earlier £389.99 Smyths figure. The £309 used figure remains a PathAu median across 153 eBay UK used sales in the 30 days to 25 Oct 2026.

Final verified TEST and LIVE totals for this session: 65 gaming master products; 57 active customer-visible products; 130 active evidence rows (20 UK new / 110 UK used); zero visible active products without evidence; zero active evidence integrity failures. The product/evidence UUIDs are environment-specific and all rows were independently inserted/verified.

## Nintendo Switch 2 accessory batch 3 — 2 November 2026
Added four independently keyed visible master products in TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Charging Grip — Argos UK new listing £29.99; used eBay UK completed sale £15.96 (item 128034280257, Billingham UK; buyer-facing total includes £0.96 Buyer Protection).
- Nintendo Switch 2 Carrying Case & Screen Protector — Argos UK new listing £19.99; official case and film protector bundle, up to six game cards and two Joy-Con 2 straps.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2 — Argos UK new listing £44.99. This is microSD Express; ordinary microSD is not a substitute for Switch 2 expanded game storage.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair — Argos UK new listing £16.99; two magnetic wheel adapters, controllers not included.
Argos exact product URLs and stable keys are in the batch checkpoint. The Charging Grip used sale is recorded separately from the Argos new listing. Other three products currently have verified new retail evidence only; no used-price estimate was invented.

## Nintendo 3DS family handheld batch 4 — 2 November 2026
Added three independently keyed visible Nintendo handheld products, each with a current UK used retailer listing:
- Nintendo 3DS XL — £149.99, Cash Converters UK St Helens, white, tested/working, light wear, charger included, stylus missing.
- New Nintendo 3DS XL — £200.00, Cash Converters UK Worksop, red, good condition, charger included, factory reset.
- New Nintendo 2DS XL — £169.99, Cash Converters UK Chesterfield, black, good condition, charger included, fully working.
These are current UK used retailer asking/listing prices, not completed sales. They are classified as `uk_used` with availability `listed`. New Nintendo 3DS XL is kept distinct from original Nintendo 3DS XL and New Nintendo 2DS XL. Special editions/bundles should remain separate when later imported.

## Updated verification — TEST and LIVE independently
- Gaming master products: **72**
- Active customer-visible products: **64**
- Active evidence: **138** (24 `uk_new`, 114 `uk_used`)
- Active visible products missing evidence: **0**
- Active evidence integrity failures: **0**
- Products with unassigned branch: **0** (checked in the pre-batch baseline; this batch inserts through the Nintendo handheld/accessory branches).
- TEST and LIVE have matching catalogue content/counts; UUIDs are environment-specific. No tenant, customer, transaction, payment or Stripe data was copied or changed.
- No application code or valuation logic changed. Evidence remains research reference only and must not be allowed to alter automatic buying prices.

## Next
Continue older Nintendo systems (standard 3DS, 2DS, DSi, Wii, Wii U, GameCube, N64, SNES) and accessories, then Xbox controllers/headsets/storage and PlayStation accessories. Check for model/edition/bundle duplicates before each insert. Do not use trade-in quotes as used market sales. Keep UK GBP evidence separate by new/used condition and listed/sold availability.


## Accessory batch 3 — exact records

### LIVE
- Nintendo Switch 2 Joy-Con 2 Charging Grip: product 8d5adc75-5e59-4c0e-8189-2045c4855793
  - New Argos £29.99: evidence acc4264b-59f1-4c9b-908d-0c90925a0c7e; key argos-switch2-charging-grip-7624692-2026-11-02.
  - Used eBay sold £15.96: evidence 19f2947a-fa5a-4c25-b205-69fe985c92a1; key ebay-128034280257.
- Nintendo Switch 2 Carrying Case & Screen Protector: product 9821a5f2-d0d2-4aec-a957-c388db2a0e48
  - New Argos £19.99: evidence f2baf047-fb93-466c-8b49-9c2c1306543a; key argos-switch2-case-screen-protector-7623868-2026-11-02.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2: product a438b9ae-3f25-41ba-bc70-96d418849c76
  - New Argos £44.99: evidence 6a8c54f2-16b4-4d55-9b94-32faae200829; key argos-sandisk-switch2-microsd-7624537-2026-11-02.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair: product 4c1dcc45-135e-4583-90f4-faa84566d2c1
  - New Argos £16.99: evidence 794c6031-2d8e-491a-b74d-17fe53413377; key argos-switch2-joycon-wheel-pair-7624661-2026-11-02.

### TEST
- Nintendo Switch 2 Joy-Con 2 Charging Grip: product 824abde3-63e1-43c6-89d9-9e26c8f9fd55
  - New Argos £29.99: evidence 4aeb13f9-fc1a-4a44-b7b0-823db556e439; key argos-switch2-charging-grip-7624692-2026-11-02.
  - Used eBay sold £15.96: evidence 38af2cb2-413d-4998-8246-0c9a55dbfa71; key ebay-128034280257.
- Nintendo Switch 2 Carrying Case & Screen Protector: product 20513301-553a-4863-8f72-f9bd42ca6909
  - New Argos £19.99: evidence de72a4b9-07a5-4412-9e4e-ba77985a0bac; key argos-switch2-case-screen-protector-7623868-2026-11-02.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2: product 588ccc1f-c893-405f-b3f8-59491fa240e4
  - New Argos £44.99: evidence 1997a3d7-6663-473c-b389-457ef2bb333a; key argos-sandisk-switch2-microsd-7624537-2026-11-02.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair: product 9d0a1eb7-362a-40fb-8a29-19a09eda8c71
  - New Argos £16.99: evidence b4bc0e9c-12fd-4efd-8150-334ffa7a58d9; key argos-switch2-joycon-wheel-pair-7624661-2026-11-02.

## Handheld batch 4 — exact records

### LIVE
- Nintendo 3DS XL: product 3f7e8893-3027-4f12-a423-4b1fe981f3be; Cash Converters UK £149.99; evidence 5d978043-2407-41e0-aa45-55f796f38b10; key cashconverters-3ds-xl-016200291556-2026-11-02.
- New Nintendo 3DS XL: product 6c2e6776-ba5e-47b8-9ae6-a2ff36b1e5ba; Cash Converters UK £200.00; evidence d270f147-f138-4f5a-9078-71ebac501664; key cashconverters-new-3ds-xl-018000227499-2026-11-02.
- New Nintendo 2DS XL: product 1908f953-12f5-44d2-ac91-7fd5097301f6; Cash Converters UK £169.99; evidence 51ff2b1e-2e36-41da-9be5-306cd412cb76; key cashconverters-new-2ds-xl-059600008755-2026-11-02.

### TEST
- Nintendo 3DS XL: product 6f3b8f2b-4500-4cd2-b878-7cb83ca40f3a; Cash Converters UK £149.99; evidence 460f6c6c-8545-4543-8614-98b8d86719d7; key cashconverters-3ds-xl-016200291556-2026-11-02.
- New Nintendo 3DS XL: product 27465f05-df1f-4cc8-abae-503647293045; Cash Converters UK £200.00; evidence 48f72d34-03e9-4cf1-826a-d3205093b99b; key cashconverters-new-3ds-xl-018000227499-2026-11-02.
- New Nintendo 2DS XL: product a7d24699-fdcf-4157-a945-7f41994cc117; Cash Converters UK £169.99; evidence e7a7e9d6-8bb8-4d70-a629-0000cb4ee030; key cashconverters-new-2ds-xl-059600008755-2026-11-02.

All batch 3/4 Cash Converters entries are used-condition retailer listings, not completed sales. Argos records are new-condition retail listings. eBay grip is a completed used sale, buyer-facing total includes fee. All source URLs, GBP prices, availability values and stable keys are populated.
