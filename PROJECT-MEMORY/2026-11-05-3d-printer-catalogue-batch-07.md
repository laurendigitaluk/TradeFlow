# Project Memory — 3D Printer Catalogue Batch 7
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow
TEST branch: main | LIVE branch: production
TEST Supabase: nnsshnfkjcflucjrftzi | LIVE Supabase: gxsrajtqzdjvmceqcpgv

## Verified position in both environments
- 136 active customer-visible products.
- 150 active UK GBP evidence rows: 135 uk_new / 15 uk_used.
- 13 manufacturers.
- Zero visible products missing evidence or branch.
- Zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches.

## Batch 7
Added four ELEGOO resin printer models in TEST and LIVE:
- Mars 4 — £149 UK new.
- Mars 4 Ultra — £189 UK new.
- Saturn 3 — £214 UK new; collection capture about one month old, stock unconfirmed, recheck before quote/valuation.
- Saturn 3 Ultra — £239 UK new; collection capture about one month old, stock unconfirmed, recheck before quote/valuation.

Exact product/evidence UUIDs and sources are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-07.md.

## Rules
- TEST first, then mirror catalogue and evidence independently to LIVE; never copy UUIDs across environments.
- UK GBP only; separate uk_new and uk_used.
- Keep printer-only products separate from accessories and bundles.
- Retail asking prices are not completed used sales.
- Used evidence is reference-only and must not affect automatic valuation.
- Database-only catalogue changes do not require Worker deployment.
- Preserve separate TEST/LIVE tenant, customer, website, custom-domain and payment data.
