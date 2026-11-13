# Project Memory — LIVE Market Evidence Import, 2026-11-12

TradeFlow LIVE only. Supabase project gxsrajtqzdjvmceqcpgv.

## Current verified state
- Scheduled research batches 04–13 initial import pass: 107 GBP evidence rows, read back from public.shared_market_evidence.
- Batch counts: 04=14, 05=9, 06=9, 07=10, 08=8, 09=11, 10=12, 11=10, 12=12, 13=12.
- All imported rows are GBP. No foreign currency conversions.
- Idempotent privileged SQL migrations used; see checkpoint CHECKPOINTS/2026-11-12-live-market-evidence-import-04-to-13.md.
- Dashboard notice posted to existing platform_ai_agent_messages thread tradeflow-research, message be90a3ea-1aa7-4ea1-9d07-1c8472bfcb47.

## Import rules
- Keep using established direct SQL migration insertion into shared_market_evidence; do not create a second importer, queue, workflow, API key, provider or Edge Function.
- Dedupe by source name and source record key using ON CONFLICT (source_name,source_record_key) DO NOTHING.
- Verify exact master product UUID, model suffix and package before insertion.
- Keep uk_new and uk_used separate. Used evidence is reference only and must not affect automatic valuation.
- Preserve condition, availability, seller, package, VAT/cashback/fee caveats and direct URL in notes.
- Do not convert non-GBP currencies. Do not fabricate amounts for no-price sources.
- Sold/sold-out/backorder observations may be stored only when the direct source has a visible GBP amount and availability is clearly labelled.
- Unresolved model/package mismatches and foreign-currency-only/no-price sources remain in batch checkpoints with RED VERIFY notes.

## Scope and safety
- LIVE only. TEST and Stripe untouched.
- No master product, schema or valuation logic changes.
- No owner impersonation, RLS bypass or direct research-queue staging.
- Initial import pass does not mean every research lead is resolved. Continue reviewing RED VERIFY leads and add further qualifying UK GBP source records.

## Documentation path note
The expected handbook paths docs/GEARCASHOUT-SYSTEM-HANDBOOK.md and docs/GEARCASHOUT-AI-OPERATING-MANUAL.md returned 404 on production during this update. Do not create guessed duplicate manuals. Locate the actual paths before updating both manuals.


## 12 November 2026 — current verified import state

The initial import of batches 04–13 was 107 GBP rows. Twenty additional observations have since been imported from RED VERIFY reviews in batches 04–07. Direct LIVE read-back now confirms 127 total rows, 126 active, 1 inactive; all GBP. Active totals are 72 UK New and 54 UK Used. One inactive record is BuzzFlyer DEVO-10 + RX1002 £149.95, because the current page shows Notify Me/no stock; it remains in the table for audit but is excluded from active evidence.

Verified per-batch totals:
| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 8 | 8 | 7 | 1 | 0 |
| 09 | 11 | 11 | 5 | 6 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

The initial overall total of 107 was correct, but the earlier message misallocated the per-batch counts for Batches 10–12. The correct database totals are Batch 10=12, Batch 11=10, Batch 12=12. Follow-up additions were Batch 04 +4, Batch 05 +9, Batch 06 +3, Batch 07 +4.

LIVE valuation uses the latest active GBP uk_new observation by observed_at then created_at, and does not filter availability. UK Used is reference-only. Sold-out/backorder UK New evidence remains active with status/notes under current behaviour; a Notify Me/no-stock row was made inactive. No schema or valuation logic changes. Actual manuals are docs/TRADEFLOW-SYSTEM-HANDBOOK.md and docs/TRADEFLOW-AI-OPERATING-MANUAL.md; both updated. TEST and Stripe untouched.


## 12 November 2026 — current verified import state after Batch 08

Initial scheduled import: 107 GBP rows. Additional RED VERIFY follow-up additions in Batches 04–08: 26 rows. Current LIVE state: 133 total GBP rows, 131 active (75 UK New, 56 UK Used), 2 inactive. The inactive rows are BuzzFlyer DEVO-10 (Notify Me/no stock) and NEEWER KM19 eBay (seller away until 19 Nov).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 11 | 11 | 5 | 6 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Actual database per-batch counts are Batch 10=12, Batch 11=10, Batch 12=12; the initial total 107 was correct, but the earlier status message misallocated these three batch counts. Follow-up additions: 04 +4, 05 +9, 06 +3, 07 +4, 08 +6. Batches 09–13 still need the RED VERIFY follow-up pass.

LIVE valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability. UK Used remains reference-only. Active sold-out/backorder new rows can still affect valuation under current behaviour; Notify Me and seller-away rows are retained but inactive. No schema/valuation logic change. TEST and Stripe untouched.


## 12 November 2026 — cumulative LIVE reconciliation after Batches 08–09 follow-ups

Current direct LIVE read-back confirms Batches 04–13 contain **138 total GBP evidence rows; 136 active and 2 inactive**. Active evidence is 76 UK New and 60 UK Used. The two inactive rows are BuzzFlyer DEVO-10 (Notify Me/no stock) in Batch 07 and NEEWER KM19 eBay (seller away until 19 November) in Batch 08.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

All rows are GBP. Follow-up additions since the prior 127-row reconciliation: Batch 08 +6 rows (5 active, 1 inactive); Batch 09 +5 active rows. Existing source observations in Batch 09 were also refreshed after direct rechecks. Used rows remain comparison-only; latest active GBP UK New observation remains the automatic shared-market reference under current valuation behaviour. No schema or valuation code was changed.

The two actual manuals are docs/TRADEFLOW-SYSTEM-HANDBOOK.md and docs/TRADEFLOW-AI-OPERATING-MANUAL.md. Both are updated with this continuation. TEST and Stripe remain untouched.


## 12 November 2026 — cumulative LIVE reconciliation after Batch 10 follow-up

Direct LIVE read-back now confirms Batches 04–13 contain **150 total GBP evidence rows, 148 active and 2 inactive**. Active evidence is 81 UK New and 67 UK Used. Inactive rows remain BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07) and NEEWER KM19 eBay seller away (Batch 08).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Batch 10 follow-up added 12 active rows (5 UK New, 7 UK Used), taking Batch 10 from 12 to 24. All rows remain GBP. Used evidence is reference-only. No valuation function/schema change; current automatic shared reference still selects latest active GBP UK New by observed_at/created_at. TEST and Stripe remain untouched.


## 12 November 2026 — cumulative LIVE reconciliation after Batch 11 follow-up

Direct LIVE read-back confirms Batches 04–13 now contain **162 total GBP evidence rows, 160 active and 2 inactive**. Active evidence comprises 86 UK New and 74 UK Used. The two inactive records remain BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07) and NEEWER KM19 eBay seller away (Batch 08).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Batch 11 follow-up added 12 active records (5 UK New, 7 UK Used), taking Batch 11 from 10 to 22. Used evidence remains reference-only. No schema or valuation function changed. TEST and Stripe remain untouched.


## 12 November 2026 — cumulative LIVE reconciliation after Batch 12 follow-up

Direct LIVE read-back confirms Batches 04–13 now contain **175 total GBP evidence rows, 172 active and 3 inactive**. Active evidence comprises **94 UK New and 78 UK Used**. Inactive rows are BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07), NEEWER KM19 eBay seller away (Batch 08), and Sony UK E 35mm F1.8 OSS £225 price conflict (Batch 12).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Batch 12 follow-up added 13 rows and deactivated one ambiguous price row; Batch 12 now has 25 total, 24 active (16 New, 8 Used). Used evidence remains reference-only. No schema or valuation function changed. TEST and Stripe remain untouched.


## 12 November 2026 — cumulative LIVE reconciliation after Batch 13 follow-up

Direct LIVE read-back confirms Batches 04–13 now contain **199 total GBP evidence rows, 195 active and 4 inactive**. Active evidence comprises **104 UK New and 91 UK Used**. Inactive rows are BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07), NEEWER KM19 eBay seller away (Batch 08), Sony UK E 35mm F1.8 price conflict (Batch 12), and PowerDolphin Wizard eBay new listing package-unverified (Batch 13).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 36 | 35 | 17 | 18 | 1 |

Batch 13 follow-up added 24 rows and deactivated one package-unverified new listing. Used observations remain reference-only. No schema or valuation function changed. TEST and Stripe remain untouched.


## 12 November 2026 — final LIVE reconciliation after second Batch 13 follow-up

Direct LIVE read-back confirms Batches 04–13 now contain **204 total GBP evidence rows, 200 active and 4 inactive**. Active evidence comprises **108 UK New and 92 UK Used**. Inactive rows: BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07); NEEWER KM19 eBay seller away (Batch 08); Sony UK E 35mm F1.8 price conflict (Batch 12); PowerDolphin Wizard new eBay package unverified (Batch 13).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Batch 13 now has 41 total rows, 40 active (21 New, 19 Used), one inactive. All 204 rows use GBP. UK Used remains reference-only. No schema or valuation function changed. TEST and Stripe remain untouched.


## 12 November 2026 — current LIVE evidence totals after Batch 09 follow-up

LIVE source_record_key reconciliation now confirms 208 total rows across Batches 04–13, 204 active (111 UK New, 93 UK Used), four inactive; all 208 GBP. Batch 09 now has 20 active rows (9 UK New, 11 UK Used), after four more direct-source observations.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 20 | 20 | 9 | 11 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Four inactive rows: BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, one Batch 12 and one Batch 13. UK Used remains reference-only. Valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability; sold-out/backorder UK New may still affect valuation. No-stock/seller-away inactive. This supersedes the previous 204 total / Batch 09 16 row snapshot. No schema or valuation change; TEST and Stripe untouched.


## 12 November 2026 — current LIVE evidence totals after Batch 10 follow-up

LIVE source_record_key reconciliation confirms 211 total GBP rows across Batches 04–13, 207 active (111 UK New, 96 UK Used), four inactive. Batch 10 now has 27 active rows (12 UK New, 15 UK Used), after three further observations.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 20 | 20 | 9 | 11 | 0 |
| 10 | 27 | 27 | 12 | 15 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Four inactive rows: BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, and one each in Batches 12 and 13. UK Used remains reference-only. Valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability; sold-out/backorder UK New can affect valuation. No-stock/seller-away inactive. This supersedes the prior 208 total/204 active snapshot. No schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — current LIVE evidence totals after Batch 11 follow-up

LIVE source_record_key reconciliation confirms 218 total GBP rows across Batches 04–13, 214 active (111 UK New, 103 UK Used), four inactive. Batch 11 now has 29 active rows (8 UK New, 21 UK Used), after seven further observations.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 20 | 20 | 9 | 11 | 0 |
| 10 | 27 | 27 | 12 | 15 | 0 |
| 11 | 29 | 29 | 8 | 21 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Four inactive rows: BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, and one each in Batches 12 and 13. UK Used remains reference-only. Valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability; sold-out/backorder UK New can affect valuation. No-stock/seller-away inactive. This supersedes the prior 211 total/207 active snapshot. No schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — current LIVE evidence totals after Batch 12 follow-up

LIVE source_record_key reconciliation confirms 220 total GBP rows across Batches 04–13, 216 active (112 UK New, 104 UK Used), four inactive. Batch 12 now has 27 total, 26 active (17 UK New, 9 UK Used), one inactive Sony UK E35 £225 price-conflict row.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 20 | 20 | 9 | 11 | 0 |
| 10 | 27 | 27 | 12 | 15 | 0 |
| 11 | 29 | 29 | 8 | 21 | 0 |
| 12 | 27 | 26 | 17 | 9 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Four inactive rows: BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, Sony UK E35 price-conflict, and one Batch 13 row. UK Used remains reference-only. Valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability; sold-out/backorder UK New can affect valuation. No-stock/seller-away inactive. This supersedes the prior 218 total/214 active snapshot. No schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — current LIVE evidence totals after Batch 13 follow-up

LIVE source_record_key reconciliation confirms 226 total GBP rows across Batches 04–13, 222 active (119 UK New, 103 UK Used), four inactive. Batch 13 now has 47 total rows, 46 active (28 UK New, 18 UK Used), one inactive package-unverified PowerDolphin Wizard row. The BuzzFlyer Walkera Furious F320 £369 new/sold-out observation was corrected from uk_used to uk_new.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 20 | 20 | 9 | 11 | 0 |
| 10 | 27 | 27 | 12 | 15 | 0 |
| 11 | 29 | 29 | 8 | 21 | 0 |
| 12 | 27 | 26 | 17 | 9 | 1 |
| 13 | 47 | 46 | 28 | 18 | 1 |

Four inactive rows: BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, Sony UK E35 £225 price-conflict, PowerDolphin Wizard new package unverified. UK Used remains reference-only. Valuation selects latest active GBP uk_new by observed_at/created_at and does not filter availability; sold-out/backorder UK New can affect valuation. No-stock/seller-away and package-unverified row remain inactive. This supersedes the prior 220 total/216 active snapshot. No schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — all 13 batches reconciled

Current LIVE source_record_key counts for Batches 01–13: 255 total observations, 252 active (137 UK New, 115 UK Used), three inactive. Per-batch breakdown is in CHECKPOINTS/2026-11-12-live-market-evidence-import-04-to-13.md, which now extends to Batches 01–13. Batch 01: 5 active (3 new, 2 used); Batch 02: 2 active (0 new, 2 used); Batch 03: 5 active (4 new, 1 used); Batches 04–13 retain their current verified counts. Current global LIVE shared_market_evidence table: 4,797 total, 4,742 active, 55 inactive.

This supersedes earlier 220-row/216-active and 246-row/243-active cumulative snapshots. UK Used remains reference-only; three inactive rows remain audit-retained. No TEST, Stripe, schema or valuation changes.


## 12 November 2026 — latest Batches 01–13 reconciliation

Fresh LIVE read-back after Batch 02 CVP and Batch 03 parallel additions: 260 batch-keyed observations across Batches 01–13, 257 active (140 UK New, 117 UK Used), three inactive. Current global shared_market_evidence: 4,802 total, 4,747 active, 55 inactive. Latest per-batch breakdown is in CHECKPOINTS/2026-11-12-live-market-evidence-import-04-to-13.md. Batch 02 now 4 active (all UK Used); Batch 03 now 8 active (7 UK New, 1 UK Used).

Batch 03 includes three UK New out-of-stock/backorder Caddx price references; current valuation does not filter active UK New by availability, so they may influence automatic valuation. This is existing behaviour and no valuation logic was changed. UK Used remains reference-only. TEST and Stripe untouched.


## 12 November 2026 — final count correction

DigiBroadcast Shure MoveMic Two Receiver Kit row dee5cf7a-27cb-4097-84a1-a918764c0cf2 was deactivated because the direct page currently displays EUR and the earlier £496.80 GBP amount is unsupported. It remains retained inactive with currency_unverified. Batch 10 now 30 total, 29 active, one inactive.

Latest Batches 01–13: 261 total, 257 active (140 UK New, 117 UK Used), four inactive. Global LIVE shared_market_evidence: 4,803 total, 4,747 active, 56 inactive. This supersedes 260/257 and prior global count. UK Used remains reference-only; no TEST, Stripe, schema or valuation changes.


## 12 November 2026 — Batch 13 RM-BR300 and latest totals

Added exact Sony RM-BR300 N.I. Broadcast £499 used source against separate RM-BR300 master, not RM-BR300H. Evidence row 48d36782-0c1b-42ff-8fd0-938e73779c31. Batch 13 now 50 active (29 new, 21 used).

Latest Batches 01–13: 262 total, 258 active (140 UK New, 118 UK Used), four inactive. Global LIVE shared_market_evidence: 4,804 total, 4,748 active, 56 inactive. This supersedes prior 261/257 snapshot. UK Used remains reference-only; TEST and Stripe untouched.


## 12 November 2026 — HDC-3100 and latest count correction

Added exact Visual Impact Sony HDC-3100 camera-head offer £25,066.80 inc VAT, Available to Order, matched to HDC-3100 Standard master. Evidence row 52a8170b-9521-41f0-9f64-6d172408377e; no CCU, lens or viewfinder included. Batch 10 now 31 total, 30 active (15 new, 15 used), one inactive.

Latest Batches 01–13: 263 total, 259 active (141 UK New, 118 UK Used), four inactive. Global LIVE shared_market_evidence: 4,805 total, 4,749 active, 56 inactive. This supersedes 262/258 snapshot. UK Used remains reference-only; TEST and Stripe untouched.


## 12 November 2026 — latest duplicate and count correction

Two duplicate captures in Batch 13 were deactivated and retained for audit: Sony FE 12-24mm earlier Sony UK row 0c023277-93cd-47bb-8677-4f005693e738 (later active duplicate fa2cbd78-e707-481c-be3f-e46aa3cf18d5) and Sony ECM-B10 earlier Wex row 9d7a7b65-8a2a-4a28-90b7-2a1c64e38564 (later active duplicate f9bb53b9-c1a1-4983-b0bd-77bdb4f6ccba). Batch 13 now 50 total, 48 active (27 new, 21 used), two inactive.

Latest Batches 01–13: 263 total, 257 active (139 UK New, 118 UK Used), six inactive. Global LIVE shared_market_evidence: 4,805 total, 4,747 active, 58 inactive. This supersedes the prior 263/259 count. UK Used remains reference-only; TEST and Stripe untouched.


## 12 November 2026 — Established import route and latest counts

Historical context confirms the established ChatGPT evidence import route is a privileged server-side Supabase SQL migration (used since 23 October), not the manual AI queue RPC. It is user-directed, runs through the trusted server-side integration, uses unique source_record_key + `ON CONFLICT DO NOTHING`, exact LIVE master/package, GBP, direct source and complete condition/availability/provenance notes, then verifies the row by direct LIVE read-back. It is not a browser/client RLS bypass and must never expose service-role credentials to the browser. The manual AI queue submit/review/verify RPCs do not import shared evidence and their statuses are not changed by this path; the dedicated app-level queue importer remains a separate missing feature.

Latest LIVE read-back: numbered Batches 01–13 = 263 total, 257 active (139 UK New, 118 UK Used), six inactive. Global shared_market_evidence = 4,808 total, 4,750 active, 58 inactive (one non-GBP/null). Three queue-linked Anycubic imports are outside numbered batch prefixes: Kobra 4 Standard £159, Kobra 3 Max V2 + ACE2Pro Combo £499, Kobra S1 + ACE2Pro 4-Color Combo £409. Bambu A1 existing 3D Prima row refreshed in place at £215, in stock 50+. Queue remains 81 total / 28 imported / 43 rejected / 10 needs_research. TEST and Stripe untouched.


## 12 November 2026 — HDC1500R follow-up and latest totals

Added KitPlus/N.I. Broadcast exact HDC1500R used camera channel £8,650, with HDC1500R head, HDCU-1000 CCU, HDVF20A and RCP750; RCP1500/7-inch viewfinder extra, lens excluded. Existing LIVE HDC1500R Standard Package master; evidence row afd9e40d-fabb-4e28-b797-2e2b8f877948. Batch 10: 32 total, 31 active (15 new, 16 used), one inactive.

Latest Batches 01–13: 264 total, 258 active (139 UK New, 119 UK Used), six inactive. Global LIVE: 4,809 total, 4,751 active, 58 inactive (one non-GBP/null). Queue: 81 total, 28 imported, 43 rejected, 10 needs_research. TEST and Stripe untouched.


## 12 November 2026 — MoveMic standard package and latest counts

Added Shure MoveMic Two standard (no receiver) sources: Shure UK £221 sale, Canford £305 ex VAT on demand, Clifton £335 awaiting stock. Exact IDs, sources and package details in Batch 10 checkpoint. Previous Shure UK £258.30 row deactivated as superseded. Keep standard package distinct from Receiver Kit.

Latest Batches 01–13: 267 total, 260 active (141 UK New, 119 UK Used), seven inactive. Global LIVE: 4,812 total, 4,753 active, 59 inactive. TEST and Stripe untouched.


## 12 November 2026 — Batch 04 Camix follow-up and latest counts

Imported Camix exact Sony FE 85mm F1.4 GM II Lens Only £1,325 (ex VAT £1,104.17), new/in stock, with full lens/cap/hood/case contents; evidence row e1d4ebb0-ccb2-4a27-b4c7-06b3f9ab32af. Cotswold £1,049 page redirected and was not imported. Batch 04: 19 active (9 new, 10 used).

Latest Batches 01–13: 268 total, 261 active (142 UK New, 119 UK Used), seven inactive. Global LIVE: 4,813 total, 4,754 active, 59 inactive. TEST and Stripe untouched.


## 13 November 2026 — Nikon UK retailer evidence additions

Three exact UK New observations were added to LIVE shared market evidence and read back: Nikon MB-N12 Standard Item from Clifton Cameras £349 in stock (one available) and London Camera Exchange £349 in stock; Nikon NIKKOR Z 50mm f/1.4 from Wilkinson Cameras £459 in stock. Exact master/package matches, direct product pages, GBP amounts, condition and availability are retained. Nikon UK's existing 50mm £449 direct offer remains unchanged after recheck; a lower search snippet conflicted with the opened retailer page. Carmarthen MB-N12 was excluded because the direct page says sold out.

Batch 09: 25/25 active (12 New, 13 Used). Batch 11: 33/33 active (9 New, 24 Used). Batches 01–13: 278 total, 270 active (145 New, 125 Used), eight inactive. Global LIVE shared_market_evidence: 4,823 total, 4,761 active, 62 inactive. UK Used remains reference-only. No schema/master/valuation changes; TEST and Stripe untouched.


## 13 November 2026 — latest Batch 09 follow-up

Added Wex Photo Video SmallRig RC100B Pro Version UK 5143 at £242.90, new, limited stock (evidence 9c451b25-6d50-48fe-b433-b9a6d0f6b36b), and Park Cameras HD PENTAX-FA 31mm f/1.8 Limited black at £1,099, new, listed but not stock-confirmed (evidence 9cfa3efe-4363-4269-8062-a0a3e7527ead). Exact master matches and source links are in the Batch 09 checkpoint. Batch 09 now 27 active (14 UK New, 13 UK Used). Batches 09–13: 172 total, 167 active (84 New, 83 Used), five inactive. Batches 01–13: 280 total, 272 active (147 New, 125 Used), eight inactive. Global LIVE: 4,825 total, 4,763 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 11 used-market comparison expanded

Nikon COOLPIX S7000 now has an additional CameraWorld used Excellent observation at £179.10, one unique item in stock, SKU C-911912; accessories and warranty are retained. Evidence ID 9d74d5d1-992b-4864-9b95-175bb9303081. The direct URL is recorded, with a note that the page open returned cache miss although the search result exposed the exact listing details. Batch 11 now 34 active (9 New, 25 Used). Batches 09–13 now 173 total, 168 active (84 New, 84 Used), five inactive. Batches 01–13 now 281 total, 273 active (147 New, 126 Used), eight inactive. Global LIVE 4,826 total, 4,764 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 13 HVR-V1E source coverage

Added Colins Cameras Sony HVR-V1E used Very Good £260, fully tested, supplied with NP-F960 battery, charger, cables and remote; direct listing is sold out. Evidence 20b25a7e-2959-4387-bfcd-cb3e9ca0c577. The direct page returned cache miss after the search result supplied exact details; source URL and limitation remain recorded. Batch 13 now 51 total, 49 active (27 New, 22 Used), two inactive. Batches 09–13 now 174 total, 169 active (84 New, 85 Used), five inactive. Batches 01–13 now 282 total, 274 active (147 New, 127 Used), eight inactive. Global LIVE 4,827 total, 4,765 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 10 source coverage expanded

Added ProAV first-generation Sony FE 100-400mm F4.5-5.6 GM OSS at £2,149 inc VAT (£1,790.83 ex), new, one in stock, exact SEL100400GM.SYX / EAN 4548736058422. Evidence 40d60e8f-0f40-44ff-baa5-e29121b4a916. Do not merge with newer SEL100400MCW constant-F4.5 model. Batch 10 now 36 total, 34 active (18 New, 16 Used), two inactive. Batches 09–13 now 175 total, 170 active (85 New, 85 Used), five inactive. Batches 01–13 now 283 total, 275 active (148 New, 127 Used), eight inactive. Global LIVE 4,828 total, 4,766 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 12 additional CVP evidence

Added CVP exact Sony HDCE-TX30 at £11,347.13 inc VAT (£9,455.94 ex VAT), new, available for backorder, normally 1–2 weeks, one-year warranty; evidence 0dc2b59c-fbc4-4eb8-9da5-cc1d2a5f7247. Direct source confirms exact product and independently matches Visual Impact's price. MKS-R3210 remains RED VERIFY because no exact UK GBP offer exists; the £61.75 eBay result is 2x BKS-R3210, not MKS-R3210. Batch 12 now 28 total, 27 active (18 New, 9 Used), one inactive. Batches 09–13 now 176 total, 171 active (86 New, 85 Used), five inactive. Batches 01–13 now 284 total, 276 active (149 New, 127 Used), eight inactive. Global LIVE 4,829 total, 4,767 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 09 Nikon F55 source coverage expanded

Added Bristol Cameras £24 Nikon F55 body-only, Used Good, in stock, 2x CR2 batteries and body cap, 3-month guarantee. Evidence 39529bb2-e229-4a4d-a739-4a198222bf82. The search result exposed the direct item details and UK stock, but direct page open returned HTTP 520; source URL and limitation remain recorded. Batch 09 now 28 active (14 New, 14 Used). Batches 09–13 now 177 total, 172 active (86 New, 86 Used), five inactive. Batches 01–13 now 285 total, 277 active (149 New, 128 Used), eight inactive. Global LIVE 4,830 total, 4,768 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 11 Panasonic used-market evidence expanded

Added two LCE Panasonic Lumix DC-FZ1000 II records at £699.99: Bristol item 145185 Excellent boxed, Bath item 139564 Good; both in store now with six-month warranty. Evidence IDs 48402a9e-16b9-4787-931b-592e0a4cb0ef and dfa96b33-7559-47df-8696-bac36f1b3fec. The direct page opens returned cache miss after search results supplied full listing details; preserve the limitation. Existing Kamerastore £709 zoom-lever fault observation remains distinct. Batch 11 now 36 active (9 New, 27 Used). Batches 09–13 now 179 total, 174 active (86 New, 88 Used), five inactive. Batches 01–13 now 287 total, 279 active (149 New, 130 Used), eight inactive. Global LIVE 4,832 total, 4,770 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 11 Pentax price comparison added

Added Camera Centre UK exact black Pentax HD PENTAX-D FA 100mm f/2.8 ED AW Macro Lens at £699, MPN 20320 / SKU YA1728:27003679. Evidence 6bd70951-d492-4512-b488-9ae6fe384bec. Its current deals page marks the product out of stock, so preserve availability out_of_stock; do not present it as available to buy. Existing Carmarthen £699.99 with two in stock remains active. Batch 11 now 37 total, 37 active (10 New, 27 Used). Batches 09–13 now 180 total, 175 active (87 New, 88 Used), five inactive. Batches 01–13 now 288 total, 280 active (150 New, 130 Used), eight inactive. Global LIVE 4,833 total, 4,771 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — HDC-3100 CVP source added with exact master mapping

Added CVP exact Sony HDC-3100 System Camera for Fiber Operation at £24,757.37 inc VAT (£20,631.14 ex), new, backorder, typical 1–2 weeks, 2 Years PrimeSupportPro warranty. Camera body only. Evidence b2e3898d-3df4-4332-817c-e9537fc64cf3. Mapped to exact Studio/Broadcast master 5882070e-3add-4bfa-b477-9a516f676333. The earlier Visual Impact evidence is on a separate HDC3100 Cinema Camera branch master; leave it untouched and do not merge automatically. Batch 10 now 37 total, 35 active (19 New, 16 Used), two inactive. Batches 09–13 now 181 total, 176 active (88 New, 88 Used), five inactive. Batches 01–13 now 289 total, 281 active (151 New, 130 Used), eight inactive. Global LIVE 4,834 total, 4,772 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — Batch 12 HDC-3200 variant detail preserved

Added Visual Impact's exact HDC-3200 base SKU at £35,588.72 inc VAT (£29,657.27 ex), new, available to order but not held in stock, camera head only. Evidence 0741e38c-7347-475a-8fea-21b0b99809d1. Existing HDC-3200/DF £37,651.84 inc VAT is a separate dual-filter SKU; preserve the distinction and do not treat it as duplicate. Direct page open returned cache miss; the search result contained the price and SKU. Batch 12 now 29 total, 28 active (19 New, 9 Used), one inactive. MKS-R3210 remains RED VERIFY; no exact UK GBP offer, and the BKS-R3210 listing is not a match. Batches 09–13 now 182 total, 177 active (89 New, 88 Used), five inactive. Batches 01–13 now 290 total, 282 active (152 New, 130 Used), eight inactive. Global LIVE 4,835 total, 4,773 active, 62 inactive. UK Used remains reference-only; TEST and Stripe untouched.


## 13 November 2026 — HVR-V1E false-positive source exclusion

Plan B Retro eBay item 117069480914 was rejected: title says HVR-V1E, item specifics say HVR-Z1E. Smart_With_Media £259.99 search result was not confirmed as a current listing in the seller's store. No rows imported; existing exact HVR-V1E evidence remains unchanged. Counts unchanged.


## 13 November 2026 — final continuation summary and unresolved research

15 additional evidence rows were inserted into LIVE and read back across Batches 09–13. Individual checkpoints record each product, retailer, GBP price, exact SKU/package, availability and source URL. No existing evidence rows were deactivated or overwritten in this continuation. Search-result-derived records retain an explicit note where opening the direct page returned cache miss or HTTP 520; never claim those pages were successfully opened.

Current counts: Batches 09–13 = 182 total, 177 active (89 UK New, 88 UK Used), five inactive. Batches 01–13 = 290 total, 282 active (152 UK New, 130 UK Used), eight inactive. Global LIVE shared_market_evidence = 4,835 total, 4,773 active, 62 inactive (2,310 active UK New GBP; 2,463 active UK Used GBP).

Only genuine outstanding RED VERIFY lead across 09–13: Sony MKS-R3210 exact 32-button routing panel, with no verified UK GBP retailer offer. Do not use £61.75 2x BKS-R3210. HDC-3000 is closed as invalid identity because Sony uses “HDC-3000 series” as a family label, not a separate sellable camera. Plan B Retro HVR-V1E title was rejected because item specifics identify HVR-Z1E. Smart_With_Media lead not confirmed current. UK Used remains reference-only. TEST, Stripe, schema, master catalogue and valuation logic untouched.
