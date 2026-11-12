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
