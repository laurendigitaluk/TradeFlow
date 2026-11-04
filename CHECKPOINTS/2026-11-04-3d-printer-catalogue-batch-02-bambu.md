# TradeFlow 3D Printer Catalogue — Batch 2 Bambu Lab Expansion
Date: 4 November 2026
Supabase TEST: nnsshnfkjcflucjrftzi
Supabase LIVE: gxsrajtqzdjvmceqcpgv
Repository: laurendigitaluk/TradeFlow

## Verified snapshot
TEST and LIVE independently contain 39 active visible products across six manufacturers and 47 active UK GBP evidence rows (36 `uk_new`, 11 `uk_used`). Each environment has two existing branches, zero visible products without active evidence, zero null branch assignments and zero active evidence integrity failures.

## Batch 2 added
14 Bambu Lab products/packages: A2L standard and Combo; H2D standard, AMS 2 Pro Combo, Engineering Bundle, More Colour Bundle, 10W and 40W Laser Full Combos, H2D Pro; H2C Vortek AMS 2 Pro Combo; H2S standard, AMS 2 Pro Combo, 10W Laser Full Combo; and legacy P1P standard.

The A2L standard UK retailer listing is marked backorder because the page says “Ships When Available”. P1P has UK used evidence only. All bundle packages are separate master product records.

Full TEST/LIVE product UUIDs, evidence UUIDs, UK source URLs, prices and notes are appended to `PROJECT-MEMORY/2026-11-04-3d-printer-catalogue.md` under Batch 2.

## Evidence and valuation rules
UK GBP only. Keep new and used evidence separate. Used eBay totals include Buyer Protection where noted; that is the buyer-facing total, not seller proceeds. Used-market evidence remains reference-only and does not affect automatic buying valuations.

## Scope
No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/order/payment data or Cloudflare Worker deployment changed. Only master catalogue and market-evidence data were added independently to TEST and LIVE.
