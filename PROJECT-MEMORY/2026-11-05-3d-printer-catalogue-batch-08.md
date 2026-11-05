# Project Memory — 3D Printer Catalogue Batch 8

Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi | LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Batch 8 completed
Added two ELEGOO printer-only products and UK-new evidence independently in TEST and LIVE:
- Neptune 3 Pro — £127.00, official ELEGOO UK; standard new printer-only offer.
- Saturn 2 (8K) — £350.00, 123-3D UK; explicitly backordered/available to order, estimated 10–14 days.

Neptune 3 Plus excluded because sold out; Neptune 3 Max excluded from new pricing because sold out/new and pre-owned only; Mars 3 Pro excluded because current new UK availability evidence was insufficiently reliable.

Exact environment-specific UUIDs and source URLs: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-08.md.

## Verified category state — TEST and LIVE
- 138 active, customer-visible products in 3D Printers.
- 152 active evidence rows: 137 uk_new / 15 uk_used.
- 13 manufacturers represented.
- Zero visible products missing evidence or branch.
- Zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches.

## Operating rules
- Inspect existing TEST/LIVE rows and prior checkpoint before every batch.
- TEST first, then mirror the same catalogue/evidence data independently to LIVE; never reuse UUIDs between environments.
- UK GBP only. Record explicit availability accurately; do not call backordered or sold-out stock in stock.
- Keep printer-only models separate from accessories and bundles.
- Retail asking prices are not completed-sale used prices. Used evidence is reference-only and must not affect automatic valuations.
- Database-only catalogue changes do not require Cloudflare Worker deployment.
- Preserve TEST/LIVE tenant, customer, website, custom-domain, ownership and payment data separation.
- After material changes update both manuals, the batch checkpoint and project-memory records.
