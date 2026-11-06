# TradeFlow Gemma research pipeline repair — 6 November 2026

## Status
Implemented on feature branch; automated test execution and Research PC verification remain pending. No production deployment or catalogue data writes.

## Baseline evidence
Supabase activity for the K1 dry run on 6 November 2026:
- First worker started: 01:05:10 UTC.
- UK-new worker completed: 01:14:05 UTC (8m55s).
- UK-used worker completed: 01:14:41 UTC (9m31s).
- Two separate research tasks each searched eight sources.
- The previous code called Ollama once for each successfully fetched page; up to 16 serialized model calls were possible across the two tasks.
- Collection pages, forum threads and search/category URLs reached the model.
- 403/503/404 sources were rejected; extracted outputs repeatedly failed evidence-type/price validation.
- Zero accepted evidence candidates and zero queue writes. Run mode was DRY RUN.

## Root cause
`src/agent.mjs` called `extract()` inside the per-source loop. Ollama requests were serialized by `ollamaExtractionQueue`, so the two research workers did not infer concurrently, but they kept the CPU occupied through repeated sequential model calls. URL and page filtering happened too late.

## Implemented changes
- Direct-product URL prefilter rejects category, collection, search, forum and other non-product pages before fetch.
- Page fetching is bounded to groups of four.
- A page must contain a visible positive GBP price before it is sent to Gemma.
- One consolidated Ollama batch request handles the remaining pages per research task.
- The agent maps model output back through source IDs and supplies authoritative source URL, GBP currency and task evidence type.
- Existing strict evidence validation, exact TEST/LIVE product matching, dry-run default and TEST-only review queue are preserved.
- Added regression tests for URL filtering, GBP price screening and one-call multi-page extraction.
- Added GitHub Actions test workflow.
- Added diagnostic roadmap and updated agent README.

## Branches
- Restore branch: `checkpoint-gemma-research-pipeline-pre-batch-20261106`.
- Implementation branch: `fix/gemma-batched-extraction-20261106`.

## Database / deployment impact
- TEST and LIVE catalogue/evidence tables unchanged.
- TEST review queue unchanged.
- No tenant, customer, domain, payment, Stripe, RLS, schema, RPC, Edge Function, Cloudflare Worker or deployment changes.
- No environment files or secrets changed.
- GearCashOut config remains separate and untouched.

## Verification still required
1. Confirm GitHub Actions test workflow passes.
2. Pull implementation branch into the verified TradeFlow Gemma working copy on the Research PC.
3. Confirm no previous Gemma process remains active before restart.
4. Run one small dry-run and measure elapsed time and PC responsiveness.
5. Confirm `research_metrics.gemma_calls` is no more than one per research task and inspect any candidates.
6. Do not enqueue until valid candidates pass manual review.


## Automated verification update — 6 November 2026

GitHub Actions regression suite passed on latest implementation commit `53ced5c47674a13e1f92d4f6ce4b4106af0ede52` (workflow run `42143240473`, conclusion `success`). The Research PC has not yet pulled or executed the change; runtime and responsiveness verification remain pending.
