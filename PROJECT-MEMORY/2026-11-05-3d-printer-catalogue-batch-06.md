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
