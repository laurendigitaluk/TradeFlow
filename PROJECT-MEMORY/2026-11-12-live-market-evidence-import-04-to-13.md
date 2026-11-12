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
