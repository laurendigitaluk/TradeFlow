# TradeFlow LIVE — Consolidated Market Research Backlog

**Research window:** 12 November 2026  
**Branch:** production  
**Scope:** Scheduled research batches 03–13  
**Environment:** LIVE only  
**State:** Preserved in GitHub; database import outstanding.

## Consolidated totals
- 11 batches
- 220 product research records (20 per batch)
- 711 raw URL occurrences in checkpoint text
- 697 distinct non-Google-search source URLs after filtering search-query URLs and de-duplicating
- Every batch includes product-level source notes and RED VERIFY qualifications.

## Batch register

| Batch | Products | Raw URL occurrences | Non-search source URL occurrences | Checkpoint |
|---|---:|---:|---:|---|
| 03 | 20 | 45 | 45 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md) |
| 04 | 20 | 59 | 59 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md) |
| 05 | 20 | 74 | 74 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md) |
| 06 | 20 | 57 | 57 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-06.md) |
| 07 | 20 | 52 | 52 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-07.md) |
| 08 | 20 | 75 | 55 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-08.md) |
| 09 | 20 | 103 | 82 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-09.md) |
| 10 | 20 | 95 | 75 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-10.md) |
| 11 | 20 | 100 | 100 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-11.md) |
| 12 | 20 | 53 | 53 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-12.md) |
| 13 | 20 | 59 | 59 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-13.md) |
| **Total** | **220** | **772** | **711** | |

**Correction note:** Raw URL occurrences were recalculated from the complete production checkpoint files during consolidation. The per-batch figures above sum to 772 raw URL occurrences. After excluding 61 Google Shopping/search-query URL occurrences, 711 non-search URL occurrences remain. De-duplicated non-search URL count: 697.

## Database reconciliation (LIVE)
- `shared_market_evidence`: 4,542 rows at the last inspected baseline; latest recorded timestamp 8 November 2026.
- `platform_catalogue_research_queue`: 28 imported, 10 needs_research and 43 rejected at the last inspected baseline.
- `platform_research_reports`: 0 rows at the last inspected baseline.
- None of scheduled batches 03–13 has been staged or imported.
- The six AKASO candidates created by a separate manual prompt were subsequently rejected. Rejection notes show duplicate existing evidence and page/model/price mismatches. Do not re-import those six blindly.
- One further manual AI research batch is in progress with its prompt still ready and no response submitted.

## Import requirements
1. Import all source observations and notes idempotently using product UUID + source URL + evidence role/type + price/currency as applicable.
2. Preserve RED VERIFY, source excerpts, source currency/amount, condition, availability, package match and no-price cases.
3. Keep non-GBP values in notes/raw payload; do not convert currencies.
4. Keep uncertain, comparison-only, ended, sold-out and inaccessible-page leads visible for review, but not valuation eligible.
5. Only exact-match, verified UK GBP new-price evidence may be considered for automatic valuation. Used-market observations are reference-only.
6. Do not alter catalogue master products, valuation rules, TEST, Stripe or tenant/customer records during evidence import.
7. Use authenticated platform-owner context and the supported review queue. Do not use postgres SQL session writes, impersonate JWT claims or bypass RLS.

## Known import blocker
The SQL connector session has no authenticated user context (`auth.uid() = NULL`, `auth.role() = NULL`) and `platform_cloud_ai_owner_check() = false`. The existing manual submission RPC is prompt-bound and cannot accept these scheduled checkpoint batches. A supported authenticated checkpoint-import path is required before database insertion.

## Project memory
Batch 03 project memory was missing and has now been restored at `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-03.md`. Batch 04–13 project-memory files already exist.
