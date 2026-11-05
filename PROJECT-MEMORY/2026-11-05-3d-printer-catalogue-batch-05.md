# Project Memory — 3D Printer Catalogue Batch 5
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi
LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Current verified position in both environments
- 128 active 3D printer master products; all 128 customer-visible.
- 141 active UK GBP evidence rows: 126 uk_new / 15 uk_used.
- 12 active manufacturers.
- Zero visible products missing active evidence or branch.
- Zero duplicate active non-null source_record_key groups.
- Zero missing evidence URLs/keys, non-positive prices, non-GBP rows or uk_new condition mismatches.
- Manufacturer counts: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3, Ultimaker 8.

## Batch 5 additions
Added nine ELEGOO models and one QIDI legacy model independently in TEST and LIVE:
- Neptune 4 — £169 new UK retail.
- Neptune 4 Pro — £189 new UK retail.
- Neptune 4 Plus — £279 new UK retail.
- Neptune 4 Max — £377 new UK retail.
- Mars 5 — £154 new UK retail.
- Mars 5 Ultra — £231 selected printer-only variant, bundle excluded.
- Saturn 4 — £299 new UK retail.
- Jupiter 2 — £699 new UK retail.
- OrangeStorm Giga — £2,049 UK pre-order, not in-stock.
- QIDI X-Max 3 — discontinued legacy model; UK eBay used sold observation £361.42 on 30 July 2026 (item 406940086609; includes £11.42 Buyer Protection, not seller proceeds).

Exact environment-specific product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-05.md.

## Environment-specific category and branch IDs
| Record | TEST | LIVE |
|---|---|---|
| Category | cc35aadb-5c1e-439b-8cf9-70ac07e82044 | ab8b13b0-b070-4534-838b-3ebd4d7261e5 |
| 3D Printers branch | b716ae40-d711-4a0a-a72c-9cf19fee880a | 59873baa-da84-461c-a8c3-4b8fd4359bcb |

## Rules
- Continue TEST first, then mirror shared catalogue/evidence independently to LIVE.
- Never copy TEST product/evidence UUIDs into LIVE.
- UK GBP only; keep uk_new and uk_used separate.
- Keep printer-only models separate from packages/accessory bundles.
- Do not mark pre-order products as in-stock.
- Mark discontinued models as legacy in notes; retain for used-market research.
- Used evidence is reference-only and must not affect automatic valuations.
- No Worker deployment is required for database-only catalogue changes.
- Do not alter schema, valuation logic, RLS, Edge Functions, tenant/customer/payment data or Stripe as part of catalogue expansion.

## Next research queue
Continue filling gaps in existing brands (ELEGOO Mars 4/Saturn 3/Neptune legacy models; additional Prusa, Flashforge and QIDI variants), then assess FLSUN and UniFormation models. Verify current/discontinued status, exact model/package identity and UK GBP evidence before adding anything. Avoid aliases and duplicates.
