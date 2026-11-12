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
