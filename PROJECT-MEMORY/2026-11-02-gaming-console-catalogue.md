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
