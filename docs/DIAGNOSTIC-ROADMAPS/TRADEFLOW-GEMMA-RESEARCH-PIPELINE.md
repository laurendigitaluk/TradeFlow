# TradeFlow Gemma Research Pipeline — Diagnostic Roadmap

Updated: 6 November 2026
Status: Implemented in a feature branch; automated/local verification pending.

## Purpose and boundary

Gemma discovers and extracts candidate UK market evidence for an exact existing TradeFlow master product. ChatGPT/owner validates candidates. Gemma must not directly write master catalogue or evidence rows.

- TEST project: `nnsshnfkjcflucjrftzi`
- LIVE project: `gxsrajtqzdjvmceqcpgv`
- Research queue/control plane: TEST only, `platform_catalogue_research_queue`
- LIVE receives agent telemetry only; no TEST tenant/customer/domain/payment data is copied.

## User action and entry points

- Interactive run: `tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1`
- Node entry: `tools/tradeflow-gemma-agent/src/index.mjs`
- Persistent worker: `tools/tradeflow-gemma-agent/src/task-worker.mjs`
- Core research and evidence pipeline: `tools/tradeflow-gemma-agent/src/agent.mjs`
- Activity reporting: `tools/tradeflow-gemma-agent/src/agent-telemetry.mjs`
- Task definitions: `tools/tradeflow-gemma-agent/tasks/*.json`
- Tests: `tools/tradeflow-gemma-agent/test/agent.test.mjs`

## Current data flow

```text
Task JSON / TEST task queue
  -> index.mjs coordinator (separate uk_new / uk_used tasks)
  -> searchWebResults (DuckDuckGo + Bing + Mojeek)
  -> URL prefilter (direct product/listing URLs only)
  -> bounded page fetch (groups of four)
  -> visible GBP price prefilter
  -> one serialized Ollama batch request per research task
  -> source_id mapped back to exact fetched URL and excerpt
  -> validate (UK host, exact manufacturer/model, task evidence type,
     GBP, visible price, condition, sales channel, availability)
  -> exact category/branch/manufacturer/model/package lookup in TEST and LIVE
  -> dry-run output OR TEST-only owner-review queue
  -> ChatGPT/owner review
```

## Key code locations

- `searchWebResults`: independent provider calls and result de-duplication.
- `isEligibleProductPage`: rejects search/category/collection/forum paths before fetch.
- `page`: retrieves direct page content and title.
- `hasVisibleUkPrice`: requires a positive visible GBP amount before AI inference.
- `extractBatch`: one Ollama call for multiple source pages; source IDs bind responses.
- `validate`: strict evidence checks; source URL and evidence type are set by the agent, not trusted from model output.
- `product`: independently resolves exact master identity in each environment.
- `enqueueCandidate`: deduplicates and stages valid candidates in TEST review queue only.

## Database dependencies

- TEST and LIVE master catalogue lookups:
  - `catalogue_master_categories`
  - `catalogue_master_branches`
  - `catalogue_master_manufacturers`
  - `catalogue_master_products`
- TEST-only review queue:
  - `platform_catalogue_research_queue`
- Agent activity/status:
  - `platform_ai_agent_activity`
  - `platform_ai_agent_status`
- Persistent task control plane (TEST):
  - `platform_ai_agent_tasks`
  - `platform_ai_agent_claim_task`
  - `platform_ai_agent_heartbeat_task`
  - `platform_ai_agent_complete_task`
  - `platform_ai_agent_fail_task`

No schema, RLS, RPC, Edge Function, Worker, Stripe, tenant or customer changes are part of this pipeline repair.

## External/local services

- Ollama local API: `OLLAMA_BASE_URL`, default `http://127.0.0.1:11434`.
- Model: `OLLAMA_MODEL`, default `gemma3:4b`.
- GPU placement: `OLLAMA_NUM_GPU=0` remains the safe default after the earlier GTX 1650 4GB runner crash.
- Search: DuckDuckGo, Bing and Mojeek; no local SearXNG/Docker requirement.
- Local secrets: only `tools/tradeflow-gemma-agent/.env` or explicit `TRADEFLOW_GEMMA_ENV_FILE`. Never read, copy or overwrite `C:\\GearCashOut-Config\\.env`.

## Known failure points and history

1. Per-page Ollama extraction caused up to 16 serialized model calls for two eight-source tasks. This is replaced by one batch call per research task.
2. Search/category/collection/forum URLs reached Gemma unnecessarily. They are now rejected before page fetch.
3. Pages without visible GBP prices reached Gemma and produced invalid zero/missing-price records. They are now rejected before inference.
4. Some providers return HTTP 403/503 or dead URLs. These remain rejected; no evidence may be fabricated to compensate.
5. Gemma can return incomplete or malformed JSON. The batch is failed closed; candidates are not staged.
6. The earlier CPU-only fallback avoids repeating the prior Ollama model-runner crash. Do not enable arbitrary GPU layers without a controlled PC benchmark.
7. Timeout increases are not performance improvements; do not use a larger timeout as a substitute for reducing inference count.

## Verification plan

- Run `npm test` in the agent folder.
- Confirm tests cover source URL filtering, GBP price screening and one Ollama call for multiple pages.
- On the Research PC, pull this branch through the verified GitHub working copy; do not manually replace files.
- Confirm the running process is stopped before updating/restarting Node.
- Run a small dry-run only. Compare elapsed time, PC responsiveness, `gemma_calls`, fetched price pages and candidate quality against the 6 November baseline (9m31s, 16 page-level inference opportunities, zero candidates).
- Verify TEST/LIVE product lookups are still independent and no catalogue/evidence rows were written.
- Only use `-Enqueue` after a dry-run returns valid, reviewable candidates.
- After runtime verification, update this roadmap and the TradeFlow project-memory checkpoint.

## Restore point

Pre-change branch: `checkpoint-gemma-research-pipeline-pre-batch-20261106`.
Implementation branch: `fix/gemma-batched-extraction-20261106`.
