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
