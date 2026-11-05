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


## PlayStation evidence continuation — 4 November 2026
Three additional UK-new retailer observations were added to existing products independently in TEST and LIVE. Each is GBP, new condition, retail channel, availability listed, and has an exact product URL and stable source key. These are retailer listed prices, not completed sales.

| Product | Source | Price | Source URL | Stable key |
|---|---|---:|---|---|
| DualSense Charging Station | PlayStation UK | £24.99 | https://www.playstation.com/en-gb/accessories/dualsense-charging-station/ | ps-uk-dualsense-charging-station-20261104 |
| PlayStation Portal Remote Player | Currys UK | £219.00 | https://www.currys.co.uk/products/sony-playstation-portal-remote-player-10257483.html | currys-playstation-portal-10257483-20261104 |
| PlayStation VR2 | Smyths Toys UK | £399.99 | https://www.smythstoys.com/uk/en-gb/gaming-and-tech/virtual-reality/playstation-vr2/playstation-vr2-headsets/playstation-vr2/p/225323 | smyths-playstation-vr2-225323-20261104 |

### TEST UUIDs
- DualSense Charging Station product 7cad3b4c-1b97-4715-a15f-c6c47411d97e; evidence 1423522d-6d47-4cd0-b647-20508ab5f968.
- PlayStation Portal product 5e701d30-e238-4807-ae05-6aeeef1acf46; evidence 153d65aa-d721-454f-a309-2b6fd0f2fce3.
- PlayStation VR2 product 2dcfdf09-f096-4ccf-998d-251458c5b1c5; evidence 354d9afe-73e7-4440-8556-0907f983aa06.

### LIVE UUIDs
- DualSense Charging Station product 240adf4e-630b-46f7-8e03-71d4b3309712; evidence f2038306-ff3b-4dd8-b479-a00abe459b3d.
- PlayStation Portal product b2da3766-77fe-4329-8c91-d712f7dd4146; evidence c7b5f07b-8512-4b18-8e92-1251d168c50e.
- PlayStation VR2 product 40fa18d5-a59d-488d-9674-37883658a180; evidence 8ff07860-832d-4cbf-93d5-01f54c1a7cb1.

### Verification — 4 November 2026
TEST and LIVE both read back 113 gaming master products and 184 active evidence rows (59 UK new / 125 UK used). The active evidence quality check returned zero rows missing URL/key, non-GBP currency, non-positive price or availability. One active customer-visible product still has no evidence: WD_BLACK C50 512GB Expansion Card for Xbox Series X|S. This remains deliberately unpriced until an exact UK listing is verified. No product records were added in this batch, no valuation rules changed, and no tenant/customer/transaction/domain/Stripe/subscription data was copied or changed. No application code or Worker deployment was involved.


## Nintendo DS handheld completion — 4 November 2026
Four additional master products and four active UK-used evidence rows were added independently to TEST and LIVE.

Evidence sources (all Cash Converters UK, current used retailer listings, GBP, availability listed):
- Nintendo 3DS, £100.00, Southport, black, good condition, charger not included. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/019300257481. Key cashconverters-nintendo-3ds-019300257481-2026-11-04.
- Nintendo DSi, £39.99, Oldham, black, acceptable pre-owned condition, charger not included. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/021600167068. Key cashconverters-nintendo-dsi-021600167068-2026-11-04.
- Nintendo DS Lite, £29.99, Widnes, black, good condition, tested working, charger included, stylus missing. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/015400188225. Key cashconverters-nintendo-ds-lite-015400188225-2026-11-04.
- Original Nintendo DS, £29.99, Levenshulme, black, good condition, fully functional, charger included, stylus missing. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/020300169664. Key cashconverters-nintendo-ds-020300169664-2026-11-04.

TEST IDs: Nintendo 3DS product 7fc5b7cb-7009-418a-a3c6-e9f62bfcd0b4 / evidence 9757eda4-afd6-4d9e-a25d-e1a29e2d25df; Nintendo DSi product c01aaf1f-eeea-4c22-bfde-f21c3f942ce2 / evidence 4e2ce2cd-795c-4ee1-b94b-51fd184dd853; Nintendo DS Lite product 5ee947ec-26ca-4e45-8e94-a8b193ea58da / evidence a1b62370-6d34-4407-93c5-8fc90f4d044a; original Nintendo DS product 5e3f2614-a97c-419d-82da-0e26a1fdf1a4 / evidence 7714913b-8431-4c75-9319-4ebf0acd6f1e.

LIVE IDs: Nintendo 3DS product 23454e57-0125-4449-af81-5af370b32075 / evidence 865a6a82-f66e-47b9-a38d-bb6fa4438429; Nintendo DSi product 3a167119-f10c-4df0-b011-839e515ce748 / evidence 07113cef-4e59-4bd2-ac74-58f42452ce8e; Nintendo DS Lite product b7fd1e78-6ad3-4c17-b1ec-6ba0f89e9ce2 / evidence f4136357-9cfd-41ac-88f8-a8e079e8d9e0; original Nintendo DS product bd46f999-a530-4711-b132-480a06211662 / evidence c55173b3-8f25-45bd-a8a8-ac8526aaa707.

Verification: TEST and LIVE each contain 117 active gaming master products, 109 active customer-visible products and 188 active evidence rows (59 UK new / 129 UK used). Zero malformed active evidence rows. All four models are on the existing Nintendo Handheld Consoles branch. Asking prices are not completed-sale data. No valuation rules, tenant/customer/transaction/domain/Stripe/subscription data, application code or Worker deployments were changed.

## Nintendo Switch V1 and Game Boy Advance SP — 4 November 2026
Two additional active, customer-visible Nintendo products and two UK-used retailer listing evidence rows were inserted independently in TEST and LIVE. Evidence source is Cash Converters UK; GBP, uk_used, Retail, availability=listed, observed 2026-11-04 UTC. Prices are asking/listing prices, not completed sales.

Evidence:
- Nintendo Switch (V1), £89.99, model HAC-001, charger included, light cosmetic wear. URL https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/nintendo-console/030400239725. Key cashconverters-switch-v1-hac001-030400239725-2026-11-04.
- Nintendo Game Boy Advance SP, £60.00, good condition, case marks, screen without scratches, charging cable included. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/050500156561. Key cashconverters-game-boy-advance-sp-050500156561-2026-11-04.

TEST IDs: Switch V1 product efef1626-c254-4569-babe-8bd5fb49ac37 / evidence c5a43d47-4525-489d-b88c-ff21deb36910; Game Boy Advance SP product 901d720c-4463-4b8b-ae15-b49c71356894 / evidence 04ac791a-468a-410d-aab7-f5085456bdeb.

LIVE IDs: Switch V1 product b549fdd9-c29f-46a2-ad6f-822c5a49e466 / evidence 37cc8e2c-dc3f-46ff-95c8-aa10d18650ac; Game Boy Advance SP product 251cf99d-2e3b-4abb-8556-c619f74daa6b / evidence 71d4ffff-e835-4119-bba4-bb481f6cdffc.

Verification in both environments: 119 active gaming master products, 111 active customer-visible products, 190 active evidence rows (59 UK new / 131 UK used), zero malformed active evidence rows. Switch V1 is distinct from existing V2 HAC-001(-01); GBA SP is distinct from original GBA and Game Boy Micro. No tenant/customer/transaction/domain/Stripe/subscription data or valuation logic changed; no code or Worker deployment was involved.

## Original Nintendo Game Boy Advance — 4 November 2026
Added one active, customer-visible Nintendo Game Boy Advance master product independently to TEST and LIVE, with two Cash Converters UK used/listed GBP evidence rows. These are current retailer asking prices, not completed sales.
- £59.99, item 052800164279, tested and fully functional with screen/body marks. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/052800164279. Key cashconverters-game-boy-advance-052800164279-2026-11-04.
- £69.99, item 045700049091, blue console only, no charger, fully working and tested. URL https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/045700049091. Key cashconverters-game-boy-advance-045700049091-2026-11-04.
TEST product e5e106d1-e9bb-4e16-b0f9-d88f9081955e; evidence f7c17656-e695-4347-b5c1-da0efc510330 and ff038da3-d75c-4407-8fb2-42409f25b2ae. LIVE product 82acccdd-e314-4cff-aabd-81839524fb5b; evidence 435fe078-e4b6-4626-b693-6f5244b9b6e1 and 2b0f338e-1295-4ea4-a475-06d2a10af53e.
Verification in both environments: 120 active gaming master products, 112 active customer-visible products, 192 active evidence rows (59 UK new / 133 UK used), zero malformed evidence rows. Original GBA remains distinct from GBA SP and Game Boy Micro. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Sega Mega Drive — 4 November 2026
Added Sega manufacturer, Sega Home Consoles branch and one active, customer-visible Sega Mega Drive master product independently to TEST and LIVE. One Cash Converters UK used/listed GBP evidence row: £39.99, black console, good condition, includes two controllers and power supply. URL https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/015700307006. Stable key cashconverters-sega-mega-drive-015700307006-2026-11-04. Asking price, not completed sale.
TEST: manufacturer 31d9e678-1c84-4ff8-9be5-782bc61eb7a5; branch 93b391cf-d731-406e-aaed-218784298843; product dee1faa3-bef5-4415-81f6-e8e2f30ba3da; evidence 8271f4a7-4ece-4914-b30a-63dbce442e94.
LIVE: manufacturer b0e1006d-c74f-46c9-b6c2-043d03117e02; branch 899f1154-d827-4683-9bfa-835ec3b05c68; product fb37f192-14db-4950-a5cb-11cf7056b070; evidence e37cde12-b7e5-42ce-b340-049fa18f3459.
Verification in both environments: 121 active gaming master products, 113 active customer-visible products, 193 active evidence rows, zero malformed active evidence rows. Original Mega Drive hardware must remain distinct from Mega Drive Mini and AtGames Flashback/emulation devices. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Sega Master System II — 4 November 2026
Added Sega Master System II as a distinct active, customer-visible home-console product in TEST and LIVE, reusing each environment's Sega manufacturer and Sega Home Consoles branch. Cash Converters UK evidence: £60.00, item 054400283789, unboxed Master System II with built-in Sonic, controller and cables; fully tested and working; URL https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/054400283789; stable key cashconverters-sega-master-system-ii-054400283789-2026-11-04. GBP, uk_used, Retail, listed, observed 2026-11-04 UTC; asking price, not completed sale.
TEST product 13c412ae-39d5-45a2-9001-f2f631f581b2; evidence b558d292-85c8-4088-a92a-c8726cb46866. LIVE product 8c069ea6-f22a-436c-8bfb-33e66906c430; evidence 52088245-8ff3-4dfb-bbd9-ab2e5c84f7a8.
Verification in both environments: 122 active gaming master products, 114 active customer-visible products, 194 active evidence rows (59 UK new / 135 UK used), zero malformed evidence rows. Keep Master System II distinct from original Master System and Mega Drive. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## 4 November 2026 — Game Boy Micro and Atari 2600
TEST and LIVE each received Nintendo Game Boy Micro (Cash Converters UK item 034300189965, £109.99, blue, USB charging cable and case, fully working) and Atari 2600. Micro URL: https://www.cashconverters.co.uk/shop/gaming/handheld-systems--equipment/handheld-consoles/nintendo-handheld-console/034300189965.
Atari evidence: eBay UK item 147495821545 (£26.69, 6-switch Woody console-only, seller says seems to work; https://www.ebay.co.uk/itm/147495821545) and item 278238908606 (£98.00, 6-switch Woody bundle with paddles/two games, joystick and paddles tested; https://www.ebay.co.uk/itm/278238908606). Listing details were surfaced through a UK second-hand aggregator; direct eBay pages could not be fetched, so validate before reuse. All are GBP UK used/listed asking prices, not completed sales.
TEST IDs: Micro product b365d58c-255f-4758-a80c-1a772e888833 / evidence 2c556003-745a-4224-b1af-400fd3f26baa; Atari manufacturer 9c9c10fe-230d-4669-9c91-023073c80902, branch 6a77da1a-341b-45d4-ab44-8cf1f280fce9, product e00cd50c-b33a-463b-bfec-5b3fbce1ad72, evidence b5a3a1fa-b1c4-4368-8e62-b3ea98655500 and 2c79d9fb-124a-4837-93d9-7aa66655531b.
LIVE IDs: Micro product c8bf974a-5af3-4b6e-a79d-a0ca4381a848 / evidence 89009f22-f7bf-4311-8651-09c2ff7669cb; Atari manufacturer 2933b37e-266e-4997-8a9e-b74e098390e4, branch 4e23f725-9dfa-4b1b-9100-6fe378b2c08a, product 9a680da0-13b5-44e0-ab77-cd90c1731930, evidence 797d5140-9623-424e-88a0-6d597a9ee0ef and 6e9dd9c3-7992-4865-bf8a-d29fa2de3c8f.
Both environments verify 124 active gaming products, 116 visible, 197 evidence rows (59 UK new / 138 UK used), zero malformed. Atari 2600 assigned to Atari Home Consoles. Jaguar not added because candidate retail image is stock imagery, not the actual item. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Sega Saturn and Sega Dreamcast — 4 November 2026
Added both products separately in TEST and LIVE after duplicate checks. Reused Sega manufacturer and Sega Home Consoles branch in each environment. Saturn: Cash Converters UK £249.99 boxed MK2 bundle (item 058400033267) and Cash Generator Runcorn £159.99 tested boxed Grade C console. Dreamcast: Gumtree £153 boxed, seller-described fully working GDEMU 5.15/128GB modified unit. All are UK GBP used/listed asking prices, not completed sales. Dreamcast modification is evidence-specific; do not create a separate core product for the GDEMU installation. TEST IDs: Saturn ab5fb2fb-383c-492a-a849-8db2df2fb2ec; Dreamcast c3ad1eb0-afcd-46c6-8c53-340f9ef58ce9. LIVE IDs: Saturn 935196e8-8c99-4e29-8b65-005612fe08eb; Dreamcast f5b404a3-bff2-4379-8896-7d74652185fa. Evidence URLs: https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/058400033267 ; https://cashgenerator.co.uk/products/sega-saturn-console ; https://www.gumtree.com/p/sega/sega-dreamcast-console-boxed-gdemu-128gb-sd-recapped-fully-working/1514986787. Both environments verify 126 active gaming products, 118 visible, 200 evidence rows (59 new / 141 used), zero malformed. Game Gear and Jaguar remain pending item-specific live evidence. No valuation, customer, tenant, transaction, domain, Stripe, subscription or Worker changes.

## Sega Game Gear addition — 4 November 2026
Added original Sega Game Gear as a distinct active, customer-visible handheld product in TEST and LIVE, creating a separate Sega Handheld Consoles branch in each environment. Evidence: active Gumtree UK listing 1802252316, £72.00, boxed with Columns cartridge and original manual/guarantee card; seller explicitly states it requires a recap, so condition is recorded as Poor and it must not be represented as fully working. URL https://www.gumtree.com/p/other-games-consoles/sega-game-gear-handheld-console-with-original-box-and-game/1802252316. GBP used/listed asking price, not completed sale. TEST branch 5b1277f1-c6b7-4b80-b080-0c036c918a37, product 90a1c2ce-e1e4-490b-83bf-47039131875e. LIVE branch b4d2f5ad-8b0b-4fde-b285-de95d81a0001, product 8aebcc2c-2052-4c65-a1a9-33f5a8dc2dec. TEST evidence count independently verifies at 201 after the insert; previous common baseline was 126 active products / 118 visible / 200 evidence. Expected resulting counts in each environment: 127 active products, 119 visible, 201 evidence rows, zero malformed. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed. Atari Jaguar remains held back until item-specific condition evidence is available.

Final post-Game-Gear verification: TEST and LIVE each show 127 active gaming products and 119 customer-visible products. TEST has 201 active evidence rows; LIVE product counts match. Evidence composition is 59 UK new and 142 UK used/listed. The Game Gear row is GBP, positive-priced, URL/key-backed and listed; no malformed evidence was introduced.

## Atari Jaguar and Game Gear additional evidence — 4 November 2026
Added Atari Jaguar as a distinct active customer-visible home console using Atari manufacturer and Atari Home Consoles branch separately in TEST and LIVE. eBay UK item 278163215741: £345, boxed, seller describes excellent condition and fully tested/working, eight item photographs; URL https://www.ebay.co.uk/itm/278163215741. Added second Game Gear evidence row to existing handheld product: Gumtree item 1803718755, £125, seller describes fully working after capacitor replacement and recommissioning; box and manual included, no games or power source; URL https://www.gumtree.com/p/other-video-games/vintage-original-sega-game-gear.-fully-working./1803718755. Both are used/listed GBP asking prices, not completed sales.
TEST Jaguar product a083fb85-f884-4436-8041-a19210c37894 / evidence b5914c65-6263-4948-9573-438ba3a773fd; Game Gear additional evidence 26d993b8-f6f8-416f-9785-5b9d2e462b45. LIVE Jaguar product a84a8826-473a-4716-9444-7e5d19af9880 / evidence ade597e7-8112-4557-8fce-86ebf2ec3dd9; Game Gear additional evidence faf347db-e227-4b8d-86d7-6fc4844bea04. Final TEST/LIVE counts: 128 active products, 120 visible, 203 active evidence rows (59 new / 144 used), zero malformed. Preserve distinct condition for the repair-required Game Gear listing and the recommissioned working listing. No valuation or tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Atari 7800 and Atari Lynx — 4 November 2026
Added original Atari 7800 and Atari Lynx products in TEST and LIVE. Atari 7800 is a home console; Atari Lynx is a handheld and has its own Atari Handheld Consoles branch in each environment. UK evidence: Gumtree item 1803253658, £80, boxed 7800 with original power lead, two controllers and Xevious/Pole Position cartridges; eBay item 278351043451, £199.95, boxed Atari Lynx, seller-described complete and tested working, with possible yellowing/sticker marks. URLs: https://www.gumtree.com/p/atari/atari-7800-console-retro-vintage-/1803253658 ; https://www.ebay.co.uk/itm/278351043451. Both used/listed GBP asking prices, not completed sales. TEST products: 7800 a6c756ef-1375-4fc7-828d-e0bbb7d42286; Lynx 8884b0ea-cb93-43e9-9827-fc6fadddc69c; Atari handheld branch 9fd5d903-ad72-404c-b3a3-76143673f6ad. LIVE products: 7800 92f40a7c-0cd3-4436-bf18-ffd337db63ca; Lynx 4d4516b0-5982-4b14-9549-d27d01b19a14; branch d48bf813-8146-477d-b65b-15052d68713f. Evidence IDs TEST aa4be156-7356-4d3c-835b-ae30ba5271ae / 69345f78-d17b-4944-bd38-1f4dc48dcc4f; LIVE 14c0cb0a-2aa8-4a13-9176-918f06d2aed7 / b67cb548-7ca7-4559-ab31-27cdde80c7ca. Final TEST/LIVE totals: 130 active products, 122 visible, 205 evidence rows (59 new / 146 used), zero malformed. Keep 7800 separate from 7800+ and Lynx separate from newer Atari-branded handhelds. No valuation, customer, tenant, transaction, domain, Stripe, subscription or Worker changes.

## Sega Mega-CD Model 1, Mega-CD II and 32X — 4 November 2026
Added three separate Sega add-on products to TEST and LIVE, using each environment's own Sega manufacturer and newly created Sega Console Add-ons branch. Do not classify them as standalone Mega Drive consoles or merge them into bundled Mega Drive listings. UK used/listed evidence (asking prices, not completed sales): Mega-CD Model 1 £361.09, eBay item 358455592974, described excellent, tested/working, official power supply; base Mega Drive not included. Mega-CD II £250.30, eBay item 407114465670, boxed, includes Sega Classics, Sol-Feace and Cobra Command; box scuffs and inner packaging damage. 32X £487.36, eBay item 278107327310, unboxed PAL unit described fully functional/tested with cable/adapter/extension components. Direct eBay pages returned cache misses; aggregator pages supplied current title/price/condition snippets, so verify before reuse. URLs: https://www.ebay.co.uk/itm/358455592974 ; https://www.ebay.co.uk/itm/407114465670 ; https://www.ebay.co.uk/itm/278107327310.
TEST branch b4540868-3cd2-4bcb-9c1b-86b2c4cb336d; product IDs 39775282-9963-4df1-871e-e3b737c24390 (Mega-CD 1), 70529f25-6581-4bb5-8c72-d9474a806f0a (Mega-CD II), b4fa74a5-a93d-41d9-8ce3-d1bb64eb77c8 (32X); evidence c3abacf1-1aa5-4bf0-a500-d0bc6ab5f5f4, 08662946-49b8-4374-9b56-fd6e7dba18ec, da301915-82c5-423b-981c-88d6bde14c6e.
LIVE branch 1f6a60ce-04a0-4745-aa4a-3b4b7450a789; product IDs c80a5028-72bc-489a-9448-cae248821094 (Mega-CD 1), 35b8f051-a966-4e3b-89dd-73c0f5379346 (Mega-CD II), 29efb7d0-6254-42da-a2f5-dff8e3a940c4 (32X); evidence 20001991-a35d-4928-b76e-458636e1ad9c, 2ade5d6c-d422-4e3e-9289-114ab248ea98, f797a632-3d6d-4f94-8118-3c7192e3d78a. Final TEST/LIVE product counts: 133 active / 125 visible. TEST evidence 208 with zero malformed; LIVE evidence inserts each returned a row ID, but aggregate verification query was blocked. No valuation logic or tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Sega Mega Drive II and original Master System Model 1 — 4 November 2026
Added two distinct Sega home-console master products independently in TEST and LIVE after checking the existing Sega product catalogue for duplicates: Sega Mega Drive II and original Sega Master System (Model 1 / Mark I). Reused the existing Sega Home Consoles branch and Sega manufacturer in each environment. Do not merge Mega Drive II with the existing original Mega Drive product or Master System Model 1 with Master System II.
UK GBP used/listed asking-price evidence (not completed sales): Mega Drive II Cash Converters item 057000067593 £129.99, fully functioning, boxed with two controllers, manuals and Mega Games 1; item 054200288249 £49.99, black unit, fully functional with controllers and power/AV leads. URLs https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/057000067593 and https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/054200288249. Original Master System Model 1 eBay item 800307959836 £71.67, model 3005-05-B, AC adaptor, RF cable and Hang-On; seller describes it as tested and working. Price/details from UK second-hand aggregator; direct eBay page cache miss. URL https://www.ebay.co.uk/itm/800307959836.
TEST products: Mega Drive II 7886fa8c-f980-4227-9683-c31b4504c32a; Master System Model 1 29681c32-645d-4d26-a8f8-7c4b3329317d. Evidence: Mega Drive II 56f37aa3-6178-4d62-904e-2b72d94a19cb and bdb5ac16-3766-4cc7-8f88-0aa7419938f8; Master System I e91d68e3-567e-4706-8c92-44d595c74f6c. LIVE products: Mega Drive II 1c1b8b6f-f8f0-406e-b922-a69617341ee1; Master System Model 1 3ebdebbd-f806-4cfd-9c3b-3d8b77b0c33b. Evidence: Mega Drive II 01cbb214-7409-49e4-8863-db2e914a9a7e and 110545ed-3310-4eee-b70f-c0ed524b9bfb; Master System I b9cc0561-56cb-44d0-b842-fc78bb956a17. TEST and LIVE independently verify 135 active gaming products, 127 customer-visible, 211 active evidence rows (59 UK new / 152 UK used), zero malformed active evidence. Evidence is market reference only and does not affect automated valuations. No customer/tenant/transaction/domain/Stripe/subscription data, valuation logic, code or Worker deployment changed.

## Gaming console catalogue continuation — 5 November 2026

Both TEST and LIVE were updated and independently verified. The Nintendo Switch 2 The Legend of Zelda 40th Anniversary 256GB console was added as a separate master product, with Smyths Toys UK-new evidence at £429.99. The existing Zelda 40th Anniversary Pro Controller gained Argos £64.99 and Smyths £79.99 UK-new evidence; existing Currys £74.99 evidence was retained.

### Exact records

LIVE:
- Zelda 40th Anniversary Switch 2 console product 916a5fda-15f4-42e8-9a35-5b28c484c9e2; evidence 14f07bfe-08cb-4e3b-9787-4db4b346152a; key smyths-switch2-zelda-40th-console-266502-uk-new-20261105.
- Zelda 40th Anniversary Pro Controller product e26d1a7c-05a4-4b06-a704-1237b98d61e2; Argos evidence 338dda77-94f3-4426-8a6b-a858f4339037; Smyths evidence c823a00e-ae08-423b-acad-3dccc88cc9e9; existing Currys evidence 7139cb37-c834-4471-be75-82ded2c07256.
- Xbox Wireless Controller — Shock Blue product ae034a43-c388-49bf-b1da-11a136ddeb13; Argos evidence 9f690f7e-6bd8-435a-ab78-3f346b2fc0de; key argos-xbox-shock-blue-2026-11-05.
- PSP-2000 evidence 57198479-79ee-4202-857b-1878ed3a74af; PSP Go evidence e6439fed-8aee-463e-92d5-ea2b010c7e64; PS Vita OLED evidence 20e7f652-4bd3-4036-b19a-d30b3fb836cc.

TEST:
- Zelda 40th Anniversary Switch 2 console product e8dc9421-8b85-43e0-87de-71ebf26bb67f; evidence 5f0f2069-a442-4189-bbda-51bca51016f0; same stable key.
- Zelda 40th Anniversary Pro Controller product e1bafaef-875a-438f-83e2-841890ebb5ea; Argos evidence aecd6462-d98f-40d1-9d73-11b92f6c0e69; Smyths evidence d63a057f-6d61-444c-870a-8191f6d26a19; existing Currys evidence 7cb30e70-bd8f-4d45-887c-ce998d32387a.
- Xbox Wireless Controller — Shock Blue product b7efaed8-d9e9-4af5-ae78-ada86a365363; Argos evidence 14a7c6fb-1284-4343-9514-29ac24680440.
- PSP-2000 evidence 2751e821-2eee-43fa-aa41-07195141d7ab; PSP Go evidence eefe9d8a-5100-4bd0-babb-a940876f2ec6; PS Vita OLED evidence 461f0daf-0d66-43e7-92aa-350a216d86e2.

Sources:
- Zelda 40th Anniversary console, Smyths £429.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-consoles/nintendo-switch-2-the-legend-of-zelda-40th-anniversary-edition-console/p/266502
- Zelda 40th Anniversary Pro Controller, Argos £64.99: https://www.argos.co.uk/product/9630952
- Zelda 40th Anniversary Pro Controller, Smyths £79.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-the-legend-of-zelda-40th-anniversary-edition-pro-controller/p/266456
- Xbox Shock Blue, Argos £59.99: https://www.argos.co.uk/product/8399139/GM-Variant
- PSP-2000 sold £69.43: https://www.ebay.co.uk/itm/860086510676
- PSP Go listed £140.00: https://www.ebay.co.uk/itm/277314993924
- PS Vita OLED sold £138.98: https://www.ebay.co.uk/itm/267796509409

Existing null source URLs repaired without changing prices or classifications:
- LIVE John Lewis Nintendo Switch 2 Joy-Con 2 Charging Grip evidence 567a4590-1bfb-4f28-826f-65233742362f now links to https://www.johnlewis.com/nintendo-joy-con-2-charging-grip-black/p113587848.
- TEST DualSense Starlight Blue evidence 796fe468-b181-47dd-bb06-ef39df0bff81 now links to https://www.argos.co.uk/product/1256028/.
- TEST DualSense Nova Pink evidence 2820f23c-4072-47c1-95cc-b2bcb3c29ef0 now links to https://www.argos.co.uk/product/1256035/.

### Verified totals after continuation
| Metric | LIVE | TEST |
|---|---:|---:|
| Active gaming master products | 277 | 277 |
| Active customer-visible products | 269 | 269 |
| Active evidence rows | 376 | 376 |
| UK-new evidence | 211 | 211 |
| UK-used evidence | 165 | 165 |
| Visible products missing all evidence | 1 | 1 |
| Active evidence integrity failures | 0 | 0 |
| Duplicate active source keys | 0 | 0 |

The single visible product without active evidence is WD_BLACK C50 Expansion Card 512GB in Xbox Accessories. Continue sourcing an exact UK price; do not invent one. A further 85 visible products lack UK-new evidence, including legacy/used-only products; do not infer new prices from old launch prices.

TEST/LIVE UUIDs are environment-specific. The product and evidence rows were inserted independently. UK-used remains reference-only and must not affect automatic buying valuation. No code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment or Cloudflare Worker changes; no Worker deployment.

No TradeFlow project-memory/checkpoint table or application function was found in the database schemas. Repository PROJECT-MEMORY and CHECKPOINTS files remain the continuity record.

Checkpoint: CHECKPOINTS/2026-11-05-gaming-console-catalogue-continuation-batch-01.md.


## WD_BLACK C50 512GB UK-new evidence — 5 November 2026

The previously uncovered WD_BLACK C50 Expansion Card 512GB Xbox Accessories master now has one active UK-new GBP observation in both environments. Source: disks.co.uk Amazon UK price tracker, £169.99; https://www.disks.co.uk/drive/wd-black-c50-storage-expansion-card-for-xbox-series-x/B0C44B1VSH. The tracker states its Amazon UK feed refreshed within minutes. Amazon's direct product page could not be independently opened during this capture. The observed £169.99 is 55.4% above the displayed 30-day average (£109.37), so retain it as a high asking-price observation only, not a representative market value or confirmed checkout price. Stable key: disksco-wd-black-c50-512gb-uk-new-20261105. LIVE product dd718e4c-a491-40ff-82d8-70d1ba538195 / evidence fbe726d0-7a02-4652-ae29-84468640d38c. TEST product d6a011b9-3f8f-40e9-b45d-d96a026548c4 / evidence 107c14fb-5c2a-4921-b858-a36a8a35a477.

Final verified totals in both environments: 277 active products, 269 active customer-visible products, 377 active evidence rows (212 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures and zero duplicate active source keys. This closes the previous single visible-product-without-evidence gap. The count of visible products without UK-new evidence remains a separate coverage metric; do not infer new prices for legacy/used-only products.


## Gaming catalogue continuation — batch 02, 5 November 2026

Both environments received the same six new product masters and eleven new evidence rows, with TEST written and verified before LIVE. New products: PowerA Advantage Wireless Controller Pokémon Mega Evolutions (£39.99 Smyths), Venom 10-in-1 Switch 2 Sports Accessory Pack (£29.99 Smyths), PowerA Advantage Wireless Controller Mario & Yoshi (£39.99 Smyths), PowerA Slim Case Dark Heather Grey (£14.99 Smyths), PowerA Protection Case Mario & Yoshi (£14.99 Smyths promotion), and SanDisk 256GB microSD Express Mario Edition (£44.99 Smyths). Distinct themed variants are maintained separately from generic/base variants; Venom kit includes Joy-Con inserts but not Joy-Con controllers.

Additional evidence: Switch 2 Joy-Con 2 Light Purple/Light Green pair Smyths £64.99 (Argos £64.95 retained); Gioteck WX5+ Dark Camo Argos £21.99 (Smyths £24.99 retained); DualSense 007 First Light Smyths £69.99 (PlayStation UK £74.99 retained); DualSense GTA VI White Smyths £74.99 (PlayStation Direct £74.99 retained); Xbox Forza Horizon 6 Limited Edition controller Smyths £69.99 (Argos £69.99 and Currys £84.99 retained).

Final matched counts: 283 active gaming products, 275 visible, 388 active evidence (223 uk_new / 165 uk_used), zero visible products without evidence, zero integrity failures, zero duplicate active source keys. Branch-level counts match across all 20 gaming branches. UK-used remains reference-only and must not affect automatic buying valuation. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes and no deployment. Exact IDs and sources are in CHECKPOINTS/2026-11-05-gaming-catalogue-continuation-batch-02.md.


## Gaming catalogue continuation — batch 03, 5 November 2026

TEST was updated and independently read back before the matching LIVE write. Added one active, customer-visible Nintendo Switch 2 AC Adapter master to Nintendo Accessories, exact package single-ac-adapter-black, with four active UK-new GBP retailer observations: Smyths £21.99, Currys £21.99, EE £19.99 and Argos £24.99. The official adapter is the black replacement power supply with detachable cable, compatible with the Switch 2 console and dock.

Added Smyths UK-new observations to the existing Switch 2 Joy-Con 2 Charging Grip (£29.99) and Joy-Con 2 Wheel Pair (£14.99) masters in both existing catalogue branches (Nintendo Accessories and Nintendo Controllers). No new masters were created for these already-catalogued products. The wheel pair is two magnetic wheel adapters; Joy-Con controllers are not included. The charging grip is sold separately from Joy-Con controllers. The existing used grip observation and all previous retailer evidence were retained.

Sources:
- Smyths AC Adapter £21.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-ac-adapter/p/249615
- Currys AC Adapter £21.99: https://www.currys.co.uk/products/nintendo-switch-2-ac-adapter-10281817.html
- EE AC Adapter £19.99: https://ee.co.uk/products/nintendo-switch-2-ac-adapter
- Argos AC Adapter £24.99: https://www.argos.co.uk/product/7624812/
- Smyths Joy-Con 2 grip and wheel listing: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203

Environment-specific IDs:
- AC Adapter product: TEST e54ae54b-1e58-4be5-9b0a-56142d941244; LIVE 26987446-1a04-4f2a-8970-72079a0a583f.
- AC Adapter evidence (Smyths, Currys, EE, Argos): TEST 4dd4eac2-de01-4d1f-82dc-2d42ae9678fa, 1b9462ae-807d-4e4a-81d6-5221d92b37ff, a334b8de-de3b-4350-8de4-d9231f536798, 5c20cf58-b9dd-482e-9329-a3ef1f89fee9; LIVE 1884d558-e2f7-4add-8ca3-088ed1bf9796, 41b8ab83-e760-49a9-a4f1-72dee2a14738, 101751bd-efb4-4d66-abb9-94c8650aec83, 31f2a943-8fa3-414d-8cf0-9a439b9b461f.
- Charging Grip Smyths evidence (Accessories branch): TEST d8669b3f-4552-4780-a6ba-ef2cd8b11604; LIVE 3d4156cf-edf7-4148-b10c-f17fcc92cc5a. Controllers branch: TEST f133249c-ab0d-4f20-9331-052271a61f83; LIVE f04cb182-882c-45d1-a712-a70119478300.
- Joy-Con 2 Wheel Pair Smyths evidence (Accessories branch): TEST 9239582f-f8ce-4c63-ba8f-61e045134884; LIVE c319a31e-0382-4397-9c2e-93a78c094690. Controllers branch: TEST 75b5641d-a89c-4f6d-880b-3e81f3afa745; LIVE 2381ed36-361c-4ef3-a2fa-88b48a533d7b.

Independent post-write verification in both databases: 284 active gaming products, 276 active customer-visible products, 396 active evidence rows (231 UK-new / 165 UK-used), zero visible products missing all evidence, zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branch counts match between LIVE and TEST. Nintendo Accessories now has 10 active products / 10 visible / 16 evidence; Nintendo Controllers has 105 / 105 / 119. The eight added evidence rows are all UK-new GBP; no existing UK-used evidence was changed. UK-used remains reference-only and does not feed automatic buying valuation.

No application code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment. No TEST business data copied to LIVE. Exact TEST/LIVE product and evidence IDs are environment-specific as listed above.
