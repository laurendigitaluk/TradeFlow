# Project Memory — 3D Printer Catalogue Batch 9

Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi | LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Batch 9 completed
Added three Flashforge printer-only products and UK-new evidence independently in TEST and LIVE:
- Creator 5 — £719.00, official Flashforge UK, in stock; £100 automatic cart discount advertised.
- Creator 5 Pro — £849.00, official Flashforge UK, in stock; £100 automatic cart discount advertised.
- Guider 3 Ultra — £2,999.00, official Flashforge UK; direct from China warehouse, shipping in 30 days.

Exact environment-specific UUIDs and source URLs: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-09.md.

## Verified category state — TEST and LIVE
- 141 active, customer-visible products in 3D Printers.
- 155 active evidence rows: 140 uk_new / 15 uk_used.
- 13 manufacturers represented.
- Zero visible products missing evidence or branch.
- Zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches.

## Operating rules
- Inspect existing TEST/LIVE rows and prior checkpoint before every batch.
- TEST first, then mirror catalogue/evidence independently to LIVE; never reuse UUIDs between environments.
- UK GBP only. Record explicit availability accurately; distinguish UK stock from overseas warehouse dispatch.
- Keep printer-only models separate from accessories and bundles.
- Retail asking prices are not completed-sale used prices. Used evidence is reference-only and must not affect automatic valuations.
- Database-only catalogue changes do not require Cloudflare Worker deployment.
- Preserve TEST/LIVE tenant, customer, website, custom-domain, ownership and payment data separation.
- After material changes update both manuals, the batch checkpoint and project-memory records.
