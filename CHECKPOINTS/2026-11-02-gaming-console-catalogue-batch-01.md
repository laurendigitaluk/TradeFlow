# TradeFlow Gaming Console Catalogue — Batch 1
Date: 2 November 2026
Repository: laurendigitaluk/TradeFlow
Branches: main (TEST), production (LIVE)
Supabase TEST: nnsshnfkjcflucjrftzi
Supabase LIVE: gxsrajtqzdjvmceqcpgv

## Objective
Continue the gaming console and accessories master catalogue without duplicating existing PlayStation/Xbox records. Keep UK new and UK used evidence separate, use GBP only, and retain exact source URLs and stable evidence keys.

## Preflight
- Existing category: Gaming Consoles & Accessories.
- Before this batch: 57 master products in each environment; 49 customer-visible; 15 active UK-new and 103 active UK-used evidence rows.
- Existing PlayStation and Xbox records were retained.
- Existing PlayStation products included ten Sony records with null branch assignment; their correct existing branch mapping was identified and repaired.
- Nintendo manufacturer and Nintendo-specific branches did not previously exist.
- TEST and LIVE were checked separately. No product or evidence IDs were reused across environments.

## Changes
- Added Nintendo manufacturer and branches: Nintendo Consoles, Nintendo Handheld Consoles, Nintendo Controllers, Nintendo Accessories.
- Added five master products and seven active evidence records in each environment.
- Corrected an initial unverified generic Harvey Norman category-page capture: it was deactivated and replaced by an exact Smyths Toys UK Switch 2 product page at £389.99.
- Assigned ten Sony records to existing PlayStation branches. No evidence or valuation data was modified for those records.

## Exact Nintendo product and evidence mapping

### LIVE
- Nintendo Switch 2 256GB: product d57ffab5-40a5-4a8b-b6e0-c30959ab9830
  - New £389.99 Smyths Toys UK: evidence 86080d91-58ed-4296-8533-2d8aa2eb9808; key smyths-switch2-256gb-2026-11-02
  - Used £309.00 PathAu median of 153 eBay UK sales: evidence a9ed13ac-0146-494d-8062-c098fa86c6dd; key pathau-switch2-ebay-sold-30d-2026-10-25
- Nintendo Switch OLED 64GB: product efb0e13a-e7df-4e2d-a5af-f89416a154c0
  - Used £145.00 eBay item 307194468463: evidence dcc94bf8-1026-4b0c-bcec-b000591254b6; key ebay-307194468463
- Nintendo Switch V2 32GB: product e3216d76-4842-4d71-a144-9a751c63d05d
  - Used £62.99 eBay item 318506459251: evidence c5def118-69f7-4773-aca9-a82b2c072c3a; key ebay-318506459251
- Nintendo Switch Lite 32GB: product 77186b23-bf47-4e7a-bec8-e2ee1ed12baa
  - Used £72.00 eBay item 287545083895: evidence 588eff6f-ec4c-41a1-b34f-a9a1b27d88f3; key ebay-287545083895
- Nintendo Switch 2 Pro Controller: product 4961b2cb-3fcf-46c6-a39c-5944d94faa5e
  - New £74.99 Nintendo Store UK: evidence 9707d33c-e9b2-40eb-a363-9f7833f6a873; key nintendo-store-switch2-pro-controller-2026-11-02
  - Used £47.08 eBay item 257762800651: evidence 881160fb-a1d6-4012-a4fa-465df421e411; key ebay-257762800651

### TEST
- Nintendo Switch 2 256GB: product 991d36ec-809c-40e5-bc11-3247904269f8
  - New £389.99 Smyths Toys UK: evidence 9c211c5d-0fd1-41ca-85bb-5e6e2413c22f; key smyths-switch2-256gb-2026-11-02
  - Used £309.00 PathAu median of 153 eBay UK sales: evidence 2037c705-c892-4322-9de9-4f68fbe771be; key pathau-switch2-ebay-sold-30d-2026-10-25
- Nintendo Switch OLED 64GB: product f42a7fc8-2738-48fb-bf92-cc69c7da0309
  - Used £145.00 eBay item 307194468463: evidence 7f8e4556-f79d-4960-a934-675914d5716d; key ebay-307194468463
- Nintendo Switch V2 32GB: product 49962413-b7f5-4984-a996-01aef0b1553f
  - Used £62.99 eBay item 318506459251: evidence 42bd4c97-db86-4bd0-b2e6-9e764d825860; key ebay-318506459251
- Nintendo Switch Lite 32GB: product 3d21881b-a7a3-43ec-bf8f-1e54672fec92
  - Used £72.00 eBay item 287545083895: evidence 61179fdc-c5ce-4f9e-836b-56f4f5a49c0a; key ebay-287545083895
- Nintendo Switch 2 Pro Controller: product 1dfff06d-b1cc-423e-b536-84cfaa33f1e6
  - New £74.99 Nintendo Store UK: evidence e79bb440-1581-4489-abe7-98db294cc288; key nintendo-store-switch2-pro-controller-2026-11-02
  - Used £47.08 eBay item 257762800651: evidence d7bf18fb-41a2-4f6c-9fbe-46f954ae6a02; key ebay-257762800651

## Verification — TEST and LIVE independently
Both environments returned identical counts:
- 62 total gaming master products.
- 54 active customer-visible products.
- 125 active evidence rows: 17 UK new, 108 UK used.
- 0 active visible products missing evidence.
- 0 active evidence integrity failures.
- 0 product records with null branch assignment.
- All five Nintendo products have active evidence; all five product masters and seven evidence rows exist in each environment.

Evidence integrity checked: source URL present, stable source key present, positive price, GBP currency, and availability set. New retail records use availability listed; completed used observations use sold. Evidence rows retain their exact source URLs and environment-specific master IDs.

## Important caveats
- Switch 2 used £309 is a PathAu aggregate median from 153 eBay UK sales in the 30 days to 25 Oct 2026, not one item sale.
- eBay buyer-facing displayed totals can include Buyer Protection; this is recorded in evidence notes where the page supplied the fee.
- Switch V2 evidence is a console-only sale and postage was separately shown.
- No new retail evidence was found/added for Switch V2, OLED or Lite in this batch; do not infer current new prices.
- The initial Harvey Norman generic category-page row is inactive and retained for audit; the exact Smyths Toys row is the active replacement.

## Scope not changed
No code, schema, valuation logic, RLS/grants, tenants, customers, transactions, payment or Stripe data changed. No evidence was allowed to alter automatic buying prices.

## Next
Continue with exact Switch 2 and Switch accessories (Joy-Con 2, camera, charging grip, cases, microSD Express), original Switch controllers and older Nintendo hardware. Then complete Xbox controllers/headsets/storage and PlayStation accessories. Research and verify exact UK evidence before insertion; avoid generic source pages, active/relisted eBay listings, hidden Best Offers, and international postage anomalies.

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

## Nintendo accessory batch 3 — 2 November 2026
Four visible master products were added independently in TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Charging Grip — Argos UK new listing £29.99; used eBay UK completed sale £15.96 (item 128034280257, Billingham UK; buyer-facing total includes £0.96 Buyer Protection).
- Nintendo Switch 2 Carrying Case & Screen Protector — Argos UK new listing £19.99.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2 — Argos UK new listing £44.99. Switch 2 requires microSD Express for expansion; ordinary microSD is not interchangeable.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair — Argos UK new listing £16.99; controllers not included.
No used price was invented for the other three accessories.

## Nintendo 3DS family handheld batch 4 — 2 November 2026
Three visible Nintendo handheld products added with current UK used retailer listings:
- Nintendo 3DS XL — £149.99, Cash Converters UK St Helens; white, tested/working, light wear, charger included, stylus missing.
- New Nintendo 3DS XL — £200.00, Cash Converters UK Worksop; red, good condition, charger included, factory reset.
- New Nintendo 2DS XL — £169.99, Cash Converters UK Chesterfield; black, good condition, charger included, fully working.
These are retailer asking/listing prices, not completed sales. Exact source URLs and stable keys: cashconverters-3ds-xl-016200291556-2026-11-02; cashconverters-new-3ds-xl-018000227499-2026-11-02; cashconverters-new-2ds-xl-059600008755-2026-11-02.

## Verified totals in both environments
- 72 gaming master products; 64 active customer-visible.
- 138 active evidence rows: 24 UK new, 114 UK used.
- Zero visible active products without evidence.
- Zero active evidence integrity failures.
TEST and LIVE counts and catalogue content match; environment UUIDs remain separate. No customer, tenant, transaction, payment or Stripe data was copied or changed. No application code or valuation logic changed. Evidence remains market research only and must not alter automatic buying prices.

### Exact TEST/LIVE UUIDs
Batch 3 LIVE:
- Charging Grip product 8d5adc75-5e59-4c0e-8189-2045c4855793; new evidence acc4264b-59f1-4c9b-908d-0c90925a0c7e; used evidence 19f2947a-fa5a-4c25-b205-69fe985c92a1.
- Case bundle product 9821a5f2-d0d2-4aec-a957-c388db2a0e48; evidence f2baf047-fb93-466c-8b49-9c2c1306543a.
- SanDisk card product a438b9ae-3f25-41ba-bc70-96d418849c76; evidence 6a8c54f2-16b4-4d55-9b94-32faae200829.
- Wheel pair product 4c1dcc45-135e-4583-90f4-faa84566d2c1; evidence 794c6031-2d8e-491a-b74d-17fe53413377.
Batch 3 TEST:
- Charging Grip product 824abde3-63e1-43c6-89d9-9e26c8f9fd55; new evidence 4aeb13f9-fc1a-4a44-b7b0-823db556e439; used evidence 38af2cb2-413d-4998-8246-0c9a55dbfa71.
- Case bundle product 20513301-553a-4863-8f72-f9bd42ca6909; evidence de72a4b9-07a5-4412-9e4e-ba77985a0bac.
- SanDisk card product 588ccc1f-c893-405f-b3f8-59491fa240e4; evidence 1997a3d7-6663-473c-b389-457ef2bb333a.
- Wheel pair product 9d0a1eb7-362a-40fb-8a29-19a09eda8c71; evidence b4bc0e9c-12fd-4efd-8150-334ffa7a58d9.

Batch 4 LIVE:
- Nintendo 3DS XL product 3f7e8893-3027-4f12-a423-4b1fe981f3be; evidence 5d978043-2407-41e0-aa45-55f796f38b10.
- New Nintendo 3DS XL product 6c2e6776-ba5e-47b8-9ae6-a2ff36b1e5ba; evidence d270f147-f138-4f5a-9078-71ebac501664.
- New Nintendo 2DS XL product 1908f953-12f5-44d2-ac91-7fd5097301f6; evidence 51ff2b1e-2e36-41da-9be5-306cd412cb76.
Batch 4 TEST:
- Nintendo 3DS XL product 6f3b8f2b-4500-4cd2-b878-7cb83ca40f3a; evidence 460f6c6c-8545-4543-8614-98b8d86719d7.
- New Nintendo 3DS XL product 27465f05-df1f-4cc8-abae-503647293045; evidence 48f72d34-03e9-4cf1-826a-d3205093b99b.
- New Nintendo 2DS XL product a7d24699-fdcf-4157-a945-7f41994cc117; evidence e7a7e9d6-8bb8-4d70-a629-0000cb4ee030.

Next: standard 3DS, 2DS, DSi, Wii, Wii U, GameCube, N64 and SNES; then Xbox controllers/headsets/storage and PlayStation accessories. Do not use trade-in quotes as used-market sales; keep UK new/used evidence separate and distinguish listing from sold.

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
