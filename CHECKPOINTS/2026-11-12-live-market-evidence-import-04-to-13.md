# LIVE Market Evidence Import — Batches 04–13
Date: 2026-11-12
Repository: laurendigitaluk/TradeFlow
Branch: production
LIVE Supabase project: gxsrajtqzdjvmceqcpgv
Import target: public.shared_market_evidence

## Outcome
Initial import pass completed for scheduled research batches 04–13. 107 GBP-denominated evidence rows were inserted and read back from LIVE.

| Batch | Rows | Distinct products |
|---|---:|---:|
| 04 | 14 | 11 |
| 05 | 9 | 8 |
| 06 | 9 | 9 |
| 07 | 10 | 6 |
| 08 | 8 | 8 |
| 09 | 11 | 9 |
| 10 | 12 | 11 |
| 11 | 10 | 10 |
| 12 | 12 | 12 |
| 13 | 12 | 12 |
| **Total** | **107** | **96 batch/product pairs** |

LIVE read-back query confirmed all 10 batch prefixes and price_currency = GBP for every imported row.

## Established import path
Used the previously proven privileged SQL migration route directly into public.shared_market_evidence; no new importer, queue, workflow, API key, provider or Edge Function was created.

Migrations applied:
- batch04_verified_camera_audio_evidence_20261112
- batch04_verified_evidence_followup_20261112
- batch05_verified_uk_market_evidence_20261112
- batch06_verified_uk_market_evidence_20261112
- batch07_verified_uk_market_evidence_20261112
- batch08_verified_uk_market_evidence_20261112
- batch09_verified_uk_market_evidence_20261112
- batch10_verified_uk_market_evidence_20261112
- batch11_verified_uk_market_evidence_20261112
- batch12_verified_uk_market_evidence_20261112
- batch13_verified_uk_market_evidence_20261112

All inserts use ON CONFLICT (source_name, source_record_key) DO NOTHING and unique batch source keys. Source URLs, GBP amount, condition, sales channel, availability, observed date and package/verification notes were preserved.

## Evidence rules applied
- Only source-displayed GBP amounts were imported; no currency conversion.
- Exact product identity and package were checked before matching.
- Used evidence remains uk_used; new evidence remains uk_new.
- Used-market observations are reference-only and must not affect automatic buying valuations.
- Sold, sold-out, backorder and limited-stock observations are explicitly labelled in availability and notes.
- Cashback, buyer-protection fees, shipping, VAT basis, seller location and package contents are recorded in notes where relevant.
- Model/package mismatches, foreign-currency-only references and unpriced sources were not promoted to GBP catalogue evidence.
- RED VERIFY uncertainties remain in the original scheduled batch checkpoints. This is an initial qualifying import pass, not a claim that every raw lead is resolved or imported.
- Cross-batch duplicate evidence, including the repeated Sony FE 85mm F1.4 GM II in batch 13, was not duplicated.

## Dashboard notification
Posted to existing platform_ai_agent_messages thread tradeflow-research:
- Message ID: be90a3ea-1aa7-4ea1-9d07-1c8472bfcb47
- Title: Batches 04–13 — 107 GBP evidence rows imported and verified
- Timestamp: 2026-11-12 13:14:27+00

## Safety boundaries
- LIVE only.
- TEST untouched.
- Stripe untouched.
- No master catalogue product, schema or valuation-logic changes.
- No manual research queue staging, owner impersonation or RLS bypass.
- No new importer or workflow.

## Remaining work
1. Revisit every RED VERIFY checkpoint record and verify exact model/package, source availability and GBP price.
2. Add any remaining qualifying direct UK GBP source observations idempotently.
3. Keep non-GBP, no-price and unresolved package leads in research references; do not fabricate a GBP amount.
4. Continue read-back verification and dashboard progress notifications.
5. Update the existing System Handbook and AI Operating Manual once their actual repository paths are located. The previously expected paths docs/GEARCASHOUT-SYSTEM-HANDBOOK.md and docs/GEARCASHOUT-AI-OPERATING-MANUAL.md returned 404 on production and were not recreated under guessed paths.


## 12 November 2026 — LIVE database reconciliation after RED VERIFY follow-ups

The initial scheduled import pass inserted 107 GBP rows. Follow-up reviews of Batches 04–07 have inserted 20 additional evidence rows. Current direct LIVE database read-back shows **127 total rows, 126 active rows, one inactive row; all 127 are GBP**. The one inactive row is BuzzFlyer UK DEVO-10 + RX1002 (£149.95) because the current page says Notify Me and no stock; it remains stored for audit but is excluded from active evidence.

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

Totals: **127 total rows; 126 active (72 UK New, 54 UK Used); 1 inactive**. The original 107 total was correct, but the earlier per-batch breakdown in the summary message had Batches 10–12 misallocated. The actual LIVE database counts are Batch 10 = 12, Batch 11 = 10, Batch 12 = 12. All counts above are from source_record_key prefixes and direct LIVE read-back.

Follow-up additions: Batch 04 +4, Batch 05 +9, Batch 06 +3, Batch 07 +4 = 20 additional rows. Existing price/status corrections are documented in each batch checkpoint. Batches 08–13 have not yet received the RED VERIFY follow-up pass in this continuation; their initial verified rows remain unchanged.

The LIVE valuation function selects the latest active GBP uk_new observation by observed_at then created_at; it does not filter availability. UK Used is not selected. Sold-out/backorder UK New rows remain active with their explicit availability and notes, consistent with the current evidence policy; a Notify Me/no-stock row was made inactive. No valuation function or schema change was made.

The actual documentation paths have now been located and updated on production: docs/TRADEFLOW-SYSTEM-HANDBOOK.md and docs/TRADEFLOW-AI-OPERATING-MANUAL.md. Dashboard progress notifications are posted in platform_ai_agent_messages on thread tradeflow-research. TEST and Stripe remain untouched.


## 12 November 2026 — LIVE reconciliation after Batch 08 follow-up

The initial scheduled import pass contained 107 GBP rows. Follow-up reviews of Batches 04–08 have added 26 more rows. Direct LIVE read-back now confirms **133 total rows, 131 active, 2 inactive; all 133 are GBP**. Active evidence comprises **75 UK New and 56 UK Used**. The two inactive records are BuzzFlyer DEVO-10 + RX1002 (Notify Me/no stock) and NEEWER KM19 eBay (seller away until 19 Nov).

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

Totals: **133 total, 131 active (75 UK New, 56 UK Used), 2 inactive**. The original 107 total was correct; earlier per-batch summary values for Batches 10–12 were misallocated. Current database counts are Batch 10=12, Batch 11=10, Batch 12=12. Follow-up additions were Batch 04 +4, Batch 05 +9, Batch 06 +3, Batch 07 +4, Batch 08 +6 = 26.

Batches 09–13 have not yet received the RED VERIFY follow-up pass in this continuation; their initial verified rows remain unchanged. The presence of imported rows does not mean every product or every source URL in the research checkpoints has been resolved.

LIVE calculate_buying_item_valuation(uuid,uuid) selects the latest active GBP uk_new observation by observed_at then created_at; it does not filter availability. UK Used is not selected. Active sold-out/backorder UK New observations retain their explicit status and can still affect automatic valuation under the existing function. No-stock Notify Me and seller-away records are retained but inactive until availability returns. No valuation code or schema change was made.

The actual manuals remain docs/TRADEFLOW-SYSTEM-HANDBOOK.md and docs/TRADEFLOW-AI-OPERATING-MANUAL.md, both updated. Dashboard progress is posted to platform_ai_agent_messages on thread tradeflow-research. TEST and Stripe remain untouched.


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


## 12 November 2026 — LIVE reconciliation after Batch 09 follow-up

Direct LIVE read-back now confirms **208 total evidence rows across Batches 04–13; 204 active and 4 inactive; all 208 are GBP**. Active evidence comprises **111 UK New and 93 UK Used**. Batch 09 increased from 16 to 20 active rows after four additional observations.

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

The four inactive records are one each in Batch 07 (BuzzFlyer DEVO-10 Notify Me/no stock), Batch 08 (NEEWER KM19 seller away), Batch 12 and Batch 13. UK Used remains reference-only. Current LIVE valuation selects the latest active GBP uk_new row by observed_at then created_at and does not filter availability; sold-out/backorder UK New rows can still influence automatic valuation. No-stock/seller-away rows are kept inactive. No schema or valuation logic changed.

This replaces the earlier 204-row cumulative total and 16-row Batch 09 count in the previous checkpoint snapshot. The actual per-batch source_record_key read-back is shown above. TEST and Stripe remain untouched.


## 12 November 2026 — LIVE reconciliation after Batch 10 follow-up

Direct LIVE read-back now confirms **211 total evidence rows across Batches 04–13; 207 active and 4 inactive; all 211 are GBP**. Active evidence comprises **111 UK New and 96 UK Used**. Batch 10 increased from 24 to 27 active rows after three additional observations.

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

The four inactive records are one each in Batch 07 (BuzzFlyer DEVO-10 Notify Me/no stock), Batch 08 (NEEWER KM19 seller away), Batch 12 and Batch 13. UK Used remains comparison-only and does not affect automatic valuation. LIVE valuation selects the latest active GBP uk_new by observed_at then created_at and does not filter availability. Sold-out/backorder UK New rows can still influence automatic valuation; no-stock/seller-away rows are kept inactive. No schema or valuation logic changed.

This supersedes the prior 208-row / 204-active cumulative snapshot. TEST and Stripe remain untouched.


## 12 November 2026 — LIVE reconciliation after Batch 11 follow-up

Direct LIVE read-back now confirms **218 total evidence rows across Batches 04–13; 214 active and 4 inactive; all 218 are GBP**. Active evidence comprises **111 UK New and 103 UK Used**. Batch 11 increased from 22 to 29 active rows after seven further observations.

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

The four inactive records are one each in Batch 07 (BuzzFlyer DEVO-10 Notify Me/no stock), Batch 08 (NEEWER KM19 seller away), Batch 12 and Batch 13. UK Used remains reference-only and does not affect automatic valuation. LIVE valuation selects latest active GBP uk_new by observed_at then created_at and does not filter availability. Sold-out/backorder UK New rows can still influence automatic valuation; no-stock/seller-away rows remain inactive. No schema or valuation logic changed.

This supersedes the prior 211-row / 207-active cumulative snapshot. TEST and Stripe remain untouched.


## 12 November 2026 — LIVE reconciliation after Batch 12 follow-up

Direct LIVE read-back now confirms **220 total evidence rows across Batches 04–13; 216 active and 4 inactive; all 220 are GBP**. Active evidence comprises **112 UK New and 104 UK Used**. Batch 12 increased from 25 to 27 total rows and from 24 to 26 active after two additional observations; one inactive price-conflict row remains.

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

The four inactive records are one each in Batch 07 (BuzzFlyer DEVO-10 Notify Me/no stock), Batch 08 (NEEWER KM19 seller away), Batch 12 (Sony UK E 35mm £225 price conflict) and Batch 13. UK Used remains reference-only. LIVE valuation selects latest active GBP uk_new by observed_at then created_at and does not filter availability. Sold-out/backorder UK New rows can still influence automatic valuation; no-stock/seller-away rows remain inactive. No schema or valuation logic changed.

This supersedes the prior 218-row / 214-active cumulative snapshot. TEST and Stripe remain untouched.


## 12 November 2026 — LIVE reconciliation after Batch 13 follow-up

Direct LIVE read-back now confirms **226 total evidence rows across Batches 04–13; 222 active and 4 inactive; all 226 are GBP**. Active evidence comprises **119 UK New and 103 UK Used**. Batch 13 increased from 41 to 47 total rows, with 46 active. The Walkera Furious F320 £369 row was corrected from uk_used to uk_new (new condition, sold out).

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

The four inactive records are one each in Batch 07 (BuzzFlyer DEVO-10 Notify Me/no stock), Batch 08 (NEEWER KM19 seller away), Batch 12 (Sony UK E 35mm £225 price conflict) and Batch 13 (PowerDolphin Wizard new package unverified). UK Used remains reference-only. LIVE valuation selects latest active GBP uk_new by observed_at then created_at and does not filter availability. Sold-out/backorder UK New rows can still influence automatic valuation; no-stock/seller-away rows remain inactive. No schema or valuation logic changed.

This supersedes the prior 220-row / 216-active cumulative snapshot. TEST and Stripe remain untouched.


## Reconciliation extension — Batches 01–13 — 12 November 2026

The earlier 04–13-only checkpoint is now extended to cover all 13 camera evidence batches. Current LIVE read-back by source_record_key:

| Batch | Total | Active | UK New | UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 01 | 5 | 5 | 3 | 2 | 0 |
| 02 | 2 | 2 | 0 | 2 | 0 |
| 03 | 5 | 5 | 4 | 1 | 0 |
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 15 | 15 | 11 | 4 | 0 |
| 07 | 15 | 14 | 10 | 4 | 1 |
| 08 | 17 | 16 | 13 | 3 | 1 |
| 09 | 23 | 23 | 10 | 13 | 0 |
| 10 | 29 | 29 | 14 | 15 | 0 |
| 11 | 32 | 32 | 8 | 24 | 0 |
| 12 | 27 | 26 | 17 | 9 | 1 |
| 13 | 49 | 49 | 29 | 20 | 0 |
| **Total** | **255** | **252** | **137** | **115** | **3** |

The Batch 01/02 imports and the additional Batch 03 V50 X With SD record are recorded in their individual checkpoints. Batch 03 is 5 active (4 new, 1 used); Batch 01 is 5 active (3 new, 2 used); Batch 02 is 2 active (0 new, 2 used). This supersedes all earlier cumulative counts in this file. These are batch-key-scoped evidence rows, not the full shared_market_evidence table count. Current global LIVE table count at reconciliation: 4,797 total, 4,742 active, 55 inactive.

All 255 batch-keyed rows are GBP; 252 active. UK Used remains reference-only. Three inactive rows remain retained for audit. No TEST, Stripe, schema, master catalogue or valuation changes were made during this extension.


## Latest LIVE reconciliation — Batches 01–13 — 12 November 2026

A fresh LIVE read-back after the additional Batch 02 CVP imports and parallel Batch 03 Caddx/V50X work gives:

| Batch | Total | Active | UK New | UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 01 | 5 | 5 | 3 | 2 | 0 |
| 02 | 4 | 4 | 0 | 4 | 0 |
| 03 | 8 | 8 | 7 | 1 | 0 |
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 15 | 15 | 11 | 4 | 0 |
| 07 | 15 | 14 | 10 | 4 | 1 |
| 08 | 17 | 16 | 13 | 3 | 1 |
| 09 | 23 | 23 | 10 | 13 | 0 |
| 10 | 29 | 29 | 14 | 15 | 0 |
| 11 | 32 | 32 | 8 | 24 | 0 |
| 12 | 27 | 26 | 17 | 9 | 1 |
| 13 | 49 | 49 | 29 | 20 | 0 |
| **Total** | **260** | **257** | **140** | **117** | **3** |

Current global LIVE shared_market_evidence count at this read: 4,802 total, 4,747 active, 55 inactive. These totals are batch-keyed rows for Batches 01–13, not the whole table. The latest per-batch totals supersede the earlier 255/252 snapshot. UK Used remains reference-only. Batch 03 contains three active UK New out-of-stock/backorder price references; current valuation does not filter active UK New by availability, so these may influence valuation. No schema or valuation logic was changed. TEST and Stripe untouched.


## Reconciliation correction — Shure currency row deactivated — 12 November 2026

A fresh read-back found one additional inactive Batch 10 row: DigiBroadcast Shure MoveMic Two Receiver Kit £496.80, source_record_key batch10-shure-movemic-two-receiver-digibroadcast-49680. It was deactivated because the direct page currently defaults to EUR and the earlier GBP amount is not supported. The row is retained inactive with availability currency_unverified. Batch 10 therefore has 30 total, 29 active (14 UK New, 15 UK Used), one inactive.

Latest Batches 01–13 totals: 261 rows, 257 active (140 UK New, 117 UK Used), four inactive. Per-batch counts: 01 5/5; 02 4/4; 03 8/8; 04 18/18; 05 18/18; 06 15/15; 07 15/14; 08 17/16; 09 23/23; 10 30/29; 11 32/32; 12 27/26; 13 49/49 (total/active). Current global LIVE shared_market_evidence: 4,803 total, 4,747 active, 56 inactive. This supersedes the previous 260/257 and 4,802/4,747/55 counts.


## Latest reconciliation — Batch 13 RM-BR300 import — 12 November 2026

A further Batch 13 UK Used row was added for exact Sony RM-BR300 (not RM-BR300H), N.I. Broadcast £499, stock 2, matched to the separate RM-BR300 master. Batch 13 is now 50 total/active (29 UK New, 21 UK Used).

Latest Batches 01–13 totals: **262 total, 258 active (140 UK New, 118 UK Used), four inactive**. Per-batch counts: 01 5/5; 02 4/4; 03 8/8; 04 18/18; 05 18/18; 06 15/15; 07 15/14; 08 17/16; 09 23/23; 10 30/29; 11 32/32; 12 27/26; 13 50/50 (total/active). Global LIVE shared_market_evidence: 4,804 total, 4,748 active, 56 inactive. This supersedes 261/257 and global 4,803/4,747/56. UK Used remains reference-only; TEST and Stripe untouched.


## Latest reconciliation — HDC-3100 source added — 12 November 2026

A further exact Batch 10 UK New observation was verified from Visual Impact: Sony HDC-3100 camera head, £25,066.80 inc VAT, Available to Order (not held in stock), matched to HDC-3100 Standard master. Batch 10 is now 31 total, 30 active (15 UK New, 15 UK Used), one inactive.

Latest Batches 01–13: **263 total, 259 active (141 UK New, 118 UK Used), four inactive**. Batch 13 remains 50 active (29 new, 21 used). Global LIVE shared_market_evidence: **4,805 total, 4,749 active, 56 inactive**. This supersedes 262/258 and global 4,804/4,748/56. Source and camera-head-only package notes are in the Batch 10 checkpoint.


## Latest reconciliation correction — Batch 13 duplicate deactivations — 12 November 2026

Two duplicate captures were deactivated in Batch 13 and retained for audit: earlier Sony FE 12-24mm F2.8 GM Sony UK row 0c023277-93cd-47bb-8677-4f005693e738 (later active same-source row fa2cbd78-e707-481c-be3f-e46aa3cf18d5) and earlier Sony ECM-B10 Wex row 9d7a7b65-8a2a-4a28-90b7-2a1c64e38564 (later active same-source row f9bb53b9-c1a1-4983-b0bd-77bdb4f6ccba). Batch 13: 50 total, 48 active (27 new, 21 used), two inactive.

Latest Batches 01–13: **263 total, 257 active (139 UK New, 118 UK Used), six inactive**. Per-batch totals/active: 01 5/5; 02 4/4; 03 8/8; 04 18/18; 05 18/18; 06 15/15; 07 15/14; 08 17/16; 09 23/23; 10 31/30; 11 32/32; 12 27/26; 13 50/48. Global LIVE shared_market_evidence: **4,805 total, 4,747 active, 58 inactive**. This supersedes 263/259 and global 4,805/4,749/56. UK Used remains reference-only; TEST and Stripe untouched.


## Historical import route clarification and latest LIVE snapshot — 12 November 2026

The established ChatGPT evidence-import route is the privileged server-side Supabase SQL migration path, recovered from the historical 23 October ingestion work and reused for these LIVE batches. This is a supervised administrative integration, not a browser/client RLS bypass. Each write uses a unique source_record_key, `ON CONFLICT (source_name, source_record_key) DO NOTHING`, exact existing LIVE master/package mapping, GBP amount, opened direct source URL, condition, availability and package/provenance notes, followed by direct LIVE read-back. The manual AI queue's owner RPCs remain separate: submit stages pending_review, review changes status, and verify records source verification; none imports to shared_market_evidence. Queue statuses are not changed by the privileged evidence migration path.

Latest database read-back: Batches 01–13 = 263 total, 257 active (139 UK New, 118 UK Used), six inactive. Global LIVE shared_market_evidence = 4,808 total, 4,750 active, 58 inactive (one non-GBP/null row). Three additional Anycubic evidence rows from manual queue candidates are outside numbered batch prefixes: Kobra 4 Standard £159, Kobra 3 Max V2 ACE 2 Pro Combo £499, and Kobra S1 ACE 2 Pro 4-Color Combo £409. Bambu Lab A1 / Standard Printer existing 3D Prima row was refreshed in place to confirm £215, VAT-inclusive, 50+ in stock, SKU/EAN/MPN; no new row. Original queue statuses remain needs_research until authenticated owner workflow updates them. Queue summary: 81 total, 28 imported, 43 rejected, 10 needs_research. TEST and Stripe untouched.
