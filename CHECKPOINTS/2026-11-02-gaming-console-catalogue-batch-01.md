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
