# Project Memory — Scheduled Market Evidence Batch 03

**Date:** 12 November 2026  
**Environment:** TradeFlow LIVE only  
**Source checkpoint:** [CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md)  
**Status:** Research preserved; not staged to LIVE review queue.

## Scope and preservation
- 20 active LIVE catalogue master products researched.
- Product UUIDs, source links, source observations, original currencies, condition/availability notes and RED VERIFY warnings are preserved in the checkpoint.
- Research checkpoint contains 45 source URL occurrences (before deduplication).
- All uncertain, international, unavailable, comparison-only and no-price findings must be retained as research references; do not discard them.

## Selection / duplicate controls
- Excluded prior scheduled checkpoint product IDs, manual AI prompt product IDs, outstanding queue candidates and the 20 AKASO IDs already reported in the preceding work.
- Immediately before research, all selected products had zero active evidence, zero outstanding queue candidates and zero outstanding prompts.
- Selection was dynamic; no fixed SQL OFFSET.

## Import blocker
- At research time auth.uid() and auth.role() were NULL and platform_cloud_ai_owner_check() returned false.
- No queue candidate or shared_market_evidence row was written from this batch.
- No direct table insert, impersonated JWT, service-role bypass or RLS bypass was attempted.
- Existing manual prompt submission RPC is not suitable: it requires a pre-existing prompt and strict prompt-bound findings.

## Data handling rules
- Preserve source URL, source name, source excerpt, model/package match, observed currency/amount, condition, availability and RED VERIFY notes.
- Do not convert foreign currencies into GBP.
- Do not treat generic search/category pages, sold-out pages, historical listings, or uncertain package matches as verified live offers.
- Only verified UK GBP evidence with a defensible exact model/package match may become valuation-eligible.
- Used-market observations remain reference-only and must not affect automatic valuation.

## Reconciliation
- This batch is one of the 11 scheduled batches (03–13) dated 12 November 2026: 220 researched products total.
- Do not re-research these 20 products unless the source needs re-verification.
- Do not start new scheduled research until the stored backlog has been imported/reconciled.
- Keep TEST, LIVE tenant/customer data, Stripe and valuation logic isolated and unchanged.

## Next action
Implement and use a secure authenticated import path that accepts checkpoint source records, preserves all findings (including RED VERIFY and non-GBP/no-price leads), performs idempotent duplicate detection, and stages candidates for human review. Do not bypass RLS or write as postgres without authenticated owner context.
