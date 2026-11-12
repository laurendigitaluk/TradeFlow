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
