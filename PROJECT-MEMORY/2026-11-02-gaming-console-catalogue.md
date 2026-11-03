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

## Nintendo legacy handheld and home console batch 5 — 2 November 2026
Five visible Nintendo products and five UK used retailer listing evidence rows were added independently in TEST and LIVE:
- Nintendo 2DS £49.99, Cash Converters Lancaster, black, light wear, charger included.
- Nintendo DSi XL £69.99, Cash Converters Bethnal Green, charger included, light wear.
- Nintendo Wii £29.99, Cash Converters Kings Heath, white, Wii Remote, sensor bar, AC adapter and AV cable, tested.
- Nintendo Wii U £109.99, Cash Converters Dudley, black 8GB, leads and GamePad, tested.
- Nintendo GameCube £85.49, Cash Converters Birkenhead, black, controller, power lead and memory card.
These are current retailer asking/listing prices, not completed sales. Each is `uk_used` with `availability=listed`. A Nintendo Home Consoles branch was added for Wii, Wii U and GameCube. Wii U master is family-level pending 8GB/32GB and package-specific splits; the evidence is specifically the 8GB package.

### LIVE IDs
- Nintendo 2DS product 800a5100-39cb-4ac2-85cb-b730a2fc2bd4; evidence 76d0f929-26eb-4519-a122-06c5e850d3af; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 01bdbb45-c7db-41ce-a4ba-fca827435c52; evidence 1187732e-f618-4fd4-8ea6-f3ca440aaf37; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 314ab322-1a35-48df-a1e8-d5ca7d667449; evidence 112584ec-bd67-4ba7-95bd-2f52d37b5a12; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product 7b832fe8-383f-4c63-806b-3c746bcf0648; evidence 1ff54f93-26eb-4eec-9222-0bbe466bc377; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product d2ce564c-1c54-48f6-9a94-67ab2a33feb3; evidence 955adebf-ded9-47a0-b673-cb6fd8dd5d78; key cashconverters-gamecube-015700300057-2026-11-02.

### TEST IDs
- Nintendo 2DS product 6e65d675-ddf0-44c4-8b6f-ba6571ac0f7c; evidence 2cb6fec3-1469-4998-907d-e5e4e0b0d1e6; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 85c1ed19-64a9-44c2-b2a7-55024dd26550; evidence 5b67d4f3-566f-4664-ab1f-7ce4070d28da; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 65a8bf91-32e5-41be-9aca-97fe547a2f1d; evidence 19a89458-94ba-46d3-9817-436c450c8b2b; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product c5027e1f-1885-45db-b409-4f016c1bea42; evidence f863c536-d956-42a1-b8ab-c09c8569e07c; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product c03789fd-ca34-4ecd-941c-76a6e2008f6c; evidence 99794ab2-acdd-4956-923a-05935d5c6c94; key cashconverters-gamecube-015700300057-2026-11-02.

## Final verification after batch 5 — both TEST and LIVE
- 77 gaming master products; 69 active customer-visible.
- 143 active evidence rows: 24 UK new, 119 UK used.
- Zero visible active products without evidence.
- Zero active evidence integrity failures.
- Counts and catalogue content match between environments; UUIDs are environment-specific.
No code, valuation logic, tenant/customer/transaction/payment data or Stripe settings changed. Evidence remains reference material only and must not alter automatic buying prices.


## Retro Nintendo console reconciliation — 2 November 2026
Three distinct retro Nintendo master products and UK used evidence records were reconciled between LIVE and TEST. The products are Nintendo 64, original Super Nintendo Entertainment System, and Super Nintendo Classic Mini. They remain separate product variants; the Classic Mini is not an alias for the original SNES.

### LIVE (pre-existing records verified; no duplicate inserted)
- Nintendo 64 product `16128973-4f2e-40a1-899f-23eacd45a344`; evidence `61f335d2-ab7f-49ea-963f-a7c3872ddc48`; £79.99 Cash Converters UK used listing; source key `cashconverters-n64-053000248940-2026-11-02`.
- Super Nintendo Entertainment System product `4174d041-8598-471b-9a49-4aad544c4da3`; evidence `7ce8132e-4be3-4d7a-82cc-b396a51fac2f`; £89.99 Cash Converters UK used listing; source key `cashconverters-snes-034700311366-2026-11-02`.
- Super Nintendo Classic Mini product `c4a1ce64-69c9-4036-aeae-a4eb82697617`; evidence `9ae07e8c-6c6f-4c88-9a40-bd035aa0aa90`; £79.99 Cash Converters UK used listing; source key `cashconverters-snes-classic-mini-053400237398-2026-11-02`.

### TEST (newly inserted independently)
- Nintendo 64 product `cbc227cb-938b-4ac5-8279-d6a02fae8d9d`; evidence `d69666e1-0d0b-4bc8-9f7d-664a08acfd9a`; £79.99; same source key as LIVE.
- Super Nintendo Entertainment System product `c02b2f45-d00a-4b76-95d0-e70561c4ea0f`; evidence `c8bf07e5-7294-46bd-907d-84d39e3f213a`; £89.99; same source key as LIVE.
- Super Nintendo Classic Mini product `2095a254-5792-4f60-9cd1-dc3ff3d6e913`; evidence `3f241c48-ad4e-4912-8185-6d9730103453`; £79.99; same source key as LIVE.

All three records use `uk_used`, GBP, condition Used, channel Retail, and availability `listed`. These are retailer asking prices, not completed sales. Evidence is reference-only and does not modify automatic buying valuations. No Worker deployment or application code change was required. LIVE records were checked first and deliberately not duplicated.


## Xbox storage catalogue correction — 2 November 2026
Four Xbox Series X|S storage products were inserted independently in TEST and LIVE: WD_BLACK C50 512GB and 1TB, Seagate 1TB, and SanDisk Optimus GX C50 2TB. The initial three new-price rows per environment were linked to a general Xbox accessories page that did not substantiate those exact card prices; all six rows were marked inactive. The WD_BLACK 512GB product remains without active price evidence pending a specific UK retailer listing. Replacement active evidence: Argos Seagate 1TB £149.99 https://www.argos.co.uk/product/9441031; Argos WD_BLACK C50 1TB £153.99 https://www.argos.co.uk/product/3115624; Idealo UK SanDisk Optimus GX C50 2TB offer £249.99 https://www.idealo.co.uk/compare/214035951/sandisk-optimus-gx-c50-storage-expansion-card-for-xbox-series-x-s-2tb.html. All are UK GBP, new, Retail, listed and research-reference only. No used price evidence, code, valuation logic, Stripe, tenant or customer data changed. No Worker deployment required. IDs LIVE: WD_BLACK 512GB dd718e4c-a491-40ff-82d8-70d1ba538195; WD_BLACK 1TB 00b25fe1-351f-433e-acf4-a4c6e6b13a1c; Seagate 1TB 5d653f60-93b4-4bee-95e6-e0cba8edecd6; SanDisk 2TB f4406a47-e624-43d5-97ee-16f9126ad0da. TEST: WD_BLACK 512GB d6a011b9-3f8f-40e9-b45d-d96a026548c4; WD_BLACK 1TB f2552c9a-03c0-44cf-b26f-541db344d34d; Seagate 1TB 00fb7c4a-0e25-4f0d-b30e-89a4edad36ff; SanDisk 2TB d2b522b0-3106-4f97-b2ee-c971231f44e0.


## Xbox official accessories batch — 2 November 2026
Three Microsoft Xbox accessories were added independently to TEST and LIVE after checking the existing Xbox catalogue: Xbox Nano Controller (£44.99, Microsoft UK pre-order with stated release date 4 November 2026), Xbox Adaptive Joystick (£24.99), and Xbox Elite Wireless Controller Series 2 Complete Component Pack (£54.99). All evidence is uk_new, GBP, New, Retail, listed, active and research-reference only. All three products are active and customer-visible in both environments. No used-market evidence, valuation logic, application code, Worker deployment, tenant/customer/transaction/payment data or Stripe settings changed.
LIVE product IDs: Nano 20d4c914-5233-41fb-8cff-dbaf8d612f6f; Adaptive d9d1d28c-481e-4f86-afa2-b465ef086624; Component Pack 7bad8b8a-527a-4393-82c0-5016a2431ad2. TEST product IDs: Nano 01dc1031-911d-4fcf-b0cd-f914a1e4564b; Adaptive e185779a-fbff-4fa9-a791-9b9d0123eae6; Component Pack 59c89dd9-f684-4318-b015-81c2da55642b.
Sources: Microsoft UK Nano Controller https://www.microsoft.com/en-gb/d/XBOX-Nano-Controller/8wg5vqp0x4g3 ; Adaptive Joystick https://www.microsoft.com/en-gb/d/XBOX-Adaptive-Joystick/8mzbmmcjzqs4 ; Complete Component Pack https://www.microsoft.com/en-gb/d/complete-component-pack/93t8nmcclss7.


## Xbox accessory catalogue batch — 3 November 2026
Added and independently verified four visible master products with active UK new/listed GBP retail evidence in both TEST and LIVE. No UUIDs were copied between environments.

| Product | Evidence source | Listed price |
|---|---|---:|
| Venom Twin Rechargeable Battery Packs | Argos UK | £12.99 |
| Venom Twin Docking & Charging Station | Argos UK | £17.99 |
| PowerA Wired Controller - Core Black | Argos UK | £19.99 |
| Turtle Beach Recon 70 Wired Multiplatform Gaming Headset - Black | Smyths Toys UK | £22.99 |

LIVE product IDs: Venom batteries 11d069a8-2ef8-4a4d-a0de-e3d24868f717; Venom dock 77700115-b738-4a61-92f5-9e0d738db1c3; PowerA controller 8c0895c6-9655-4e66-a671-d4b524444893; Turtle Beach headset 28862143-4594-4c13-82b4-43efaeab4d29.
LIVE evidence IDs: Venom batteries bbdb9a79-e0de-4cd2-879f-64cb123b1a2e; Venom dock 81880662-9524-4e62-a1a9-c71cd4449c2b; PowerA 0770f8ca-d2fc-4b25-8dd5-7c7b637f9a1f; Turtle Beach 4547fcfa-9882-4b52-8a42-e2bd22444bbe.

TEST product IDs: Venom batteries ca4634d2-653d-4777-afa2-a87cb6f566b3; Venom dock 0aa86377-52d8-4692-83b5-77d093f6dd4d; PowerA controller 71a159be-56ad-40fe-aa55-cc2fe8eba908; Turtle Beach headset 74052356-9e15-4829-b609-f6f580efc706.
TEST evidence IDs: Venom batteries 452ba9d6-961f-46f3-a25c-2fcfdf47bd80; Venom dock fe7c1117-9055-4972-a106-0394a1687dc9; PowerA c6500d2c-bcb3-4673-8a90-05681b77150c; Turtle Beach 3b5efa33-ba1d-46d1-9cee-0f62e259bfd9.

Source URLs: Argos product 3635678 https://www.argos.co.uk/product/3635678 ; Argos Xbox accessories category for Venom products https://www.argos.co.uk/browse/technology/video-games-and-consoles/xbox/xbox-accessories/c%3A812428/ ; Smyths Recon 70 Black https://www.smythstoys.com/uk/en-gb/gaming-and-tech/gaming-headsets/turtle-beach-recon-70-wired-multiplatform-gaming-headset-black/p/237774 . The Smyths page reported stock available when researched. All evidence rows are `uk_new`, GBP, New, Retail, `listed`; these are retailer asking/listed prices, not completed sales. No used-market evidence was added.

Verification in both environments returned all four products active and customer-visible, each joined to its active evidence row with matching GBP price and listed availability. No valuation logic, application code, deployment, tenant/customer/transaction/payment data or Stripe settings changed. Evidence remains reference-only. Continue with other verified Xbox accessories, then PlayStation accessories; inspect duplicates before each insertion.



## Xbox controller and charging batch — 3 November 2026
Four additional products were inserted independently into TEST and LIVE after exact-name duplicate checks in both environments. All are active, customer-visible and have active UK-new GBP retail evidence with `availability=listed`:
- PowerA Hall Effect Advantage+ Xbox Wired Controller - Green — Argos £32.99, https://www.argos.co.uk/product/7637713.
- PowerA Hall Effect Advantage+ Xbox Wired Controller - Ruby — Argos £32.99, https://www.argos.co.uk/product/7537112.
- PowerA Dual Charging Station For Xbox Controllers - Black — Argos £9.99, https://www.argos.co.uk/product/7618055. Includes two rechargeable battery packs and four charge-through battery doors.
- Turtle Beach Rematch Core Xbox & PC Wired Hall-Effect Controller - Black — Argos £19.99, https://www.argos.co.uk/product/8213112.

LIVE product IDs: Green f7ce0314-cc55-42fe-966f-bfdf304a10b2; Ruby ee0571b1-4730-4a5f-b911-cb5806ab771a; Dual Charging Station fafe72e1-bd71-43cc-88c9-8c66b86c8dfe; Rematch Core Black 78d46f08-d626-4830-8c4a-e5ba3516c81f.
LIVE evidence IDs: Green cd9fe4cf-133b-47c7-a8ac-923aafc6a409; Ruby b0c20b78-3b94-4238-ba3d-3dc6a13f85a0; Charging Station 198db089-9c22-49bc-8a57-805abc815211; Rematch Core 89e8b877-52c2-4a71-b887-b75ddf6ec39d.

TEST product IDs: Green f124fce7-4b37-45be-a4bc-bd5e3e680706; Ruby 1c02e080-e312-4e50-afa8-3f70e8e4ba6b; Dual Charging Station deb4fae0-5042-419f-a71b-faefce0f9944; Rematch Core Black bbb3c178-db23-480f-8259-fd3de9a981d2.
TEST evidence IDs: Green 59840f81-bb92-46cd-b7ba-82b783a7185e; Ruby a387129d-b86c-4faa-a2aa-f9b96d76606d; Charging Station 37c94101-fa6e-425c-bd4e-7535caef631c; Rematch Core 78a652c1-d341-4b2b-ad5a-d856249014e2.

Both environments were re-queried after insertion and returned all four active/customer-visible products with active evidence, matching prices, GBP currency, `uk_new` classification and listed availability. Product and evidence UUIDs are environment-specific. These are retailer listing prices, not completed sales. No used evidence, valuation logic, application code, deployment, tenant/customer/transaction/payment data or Stripe settings changed. Evidence remains reference-only. Continue with other verified Xbox controllers, headsets and charging accessories, then PlayStation accessories.


## Xbox controller variant batch — 3 November 2026 (partial LIVE promotion)
Three additional variants were researched and checked for exact model duplicates. TEST contains all three as active, customer-visible products with active UK-new GBP listed evidence:
- Turtle Beach Rematch Core Xbox & PC Wired Hall-Effect Controller - Camo Green — Argos £24.99, https://www.argos.co.uk/product/9566837. TEST product 523dde59-4946-491c-832d-311d9e126d3a; evidence a8816450-fbb3-49cd-8e43-ba7267d20ad5.
- PowerA Advantage Xbox Series X|S Wired Controller - Fire Red — Argos £32.99, https://www.argos.co.uk/product/7788727/. TEST product 747b3462-4c9a-4a54-9554-97ef77739401; evidence 0588cb5b-b4d9-4ee5-9ad3-6877d21019ee.
- Hyperkin The Competitor Xbox & PC Wired Controller - Silver — Argos £39.99, https://www.argos.co.uk/product/9785388. TEST product 5eea453e-b527-4914-8369-e24f95786271; evidence 30d93a7a-4264-4634-8dec-31f2fa013d65.

LIVE promotion status: only the Turtle Beach Camo Green product and evidence were successfully added and verified. LIVE product 3300986e-9861-414e-a915-9a63af01da45; LIVE evidence b4cc24c1-d246-48c8-bf76-ca3366eb54f3. LIVE inserts for PowerA Fire Red and Hyperkin Competitor Silver were blocked by the tool safety layer and were not completed. The Hyperkin manufacturer was created independently in both environments (TEST 68f451cf-9250-415e-aed6-bab147ad7de7; LIVE 511a0454-331b-426e-990c-bae89ccd2432). Do not claim this batch is fully mirrored until LIVE product/evidence rows are added and verified. No deployment, code, valuation, tenant/customer/transaction/payment or Stripe changes.
