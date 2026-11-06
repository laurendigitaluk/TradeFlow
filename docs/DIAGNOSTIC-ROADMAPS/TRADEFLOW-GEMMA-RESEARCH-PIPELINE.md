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


Merged-branch verification: GitHub Actions run `42143345106` completed successfully on merged commit `e31d974b0b513e1d5101fa6678d798ac1555a2df`. The remaining verification is the Research PC pull, dry-run timing and responsiveness check.


## GBP prefilter regression (6 November 2026)

- The pre-Gemma page gate `hasVisibleUkPrice` rejected a valid Unicode pound-sign price even though the isolated matcher accepted it. This is an application-side defect: Gemma's extraction instructions cannot compensate for a page rejected before inference.
- The repair builds the pound-symbol matcher from Unicode code point 163, supports GBP text, normalizes non-breaking spaces, and retains the positive numeric price requirement.
- Regression coverage includes pound prices, comma-separated amounts, non-breaking spaces, no-price pages and zero-price rejection.
- HTML price entities are normalized by the page extractor to a GBP marker before the prefilter.
- CI passed for the initial PR revision (run 42211820540); a further non-breaking-space test and normalization correction were pushed afterwards. The latest revision still requires its own CI confirmation.
- Do not merge or update the Research PC until the latest revision's CI is green. Local attempted edits were restored from the pre-repair backup; no `.env`, GearCashOut config, TEST/LIVE data or deployments were changed.


## Research PC dry-run finding — Amazon search-page false positive (6 November 2026)

- Controlled dry-run completed with 8 search results, 4 eligible URLs, 3 fetched price-bearing pages, 1 Gemma batch call and 1 accepted candidate.
- The accepted candidate's Amazon UK URL was a search route (`/creality-k1-3d-printer/s?k=...`), not a direct product detail page. Its excerpt was dominated by site navigation. It is not approved evidence and must not be imported.
- Root cause: generic URL filtering rejected query keys `q`, `query`, `_nkw`, `search`, but did not reject Amazon's `k` search parameter or require an Amazon ASIN product-detail route. The HTML text extraction also includes navigation chrome, so a price in page chrome can pass the visible-price gate.
- PR #245 adds Amazon-specific prefetch and validation guards: reject `/s` and `k` search routes; require a direct ASIN under `/dp/`, `/gp/product/` or `/gp/aw/d/`; regression tests cover rejection and direct-detail acceptance.
- PR #245 is open and awaiting CI. Do not update Research PC or repeat research until CI passes and the PR is merged.
- Performance finding: one consolidated Gemma call completed for three pages. The candidate-quality gate still needs work: product-page content extraction should isolate product detail content and avoid navigation text before inference/validation.
- No catalogue, review queue, TEST/LIVE product/evidence rows, schema or deployment changes were made by the dry-run.


## Second Research PC dry-run — storefront homepage false positive (6 November 2026)

- Second controlled Creality K1 dry-run after Amazon URL filtering: 8 search results, 2 eligible URLs, 1 fetched price-bearing page, 1 Gemma batch call, 1 accepted candidate.
- The accepted candidate URL was `https://waustore.creality.com/uk/`, a locale storefront homepage rather than a K1 product-detail page. Its excerpt contained broad catalogue/navigation content and unrelated products. Candidate is explicitly NOT approved and must not be imported.
- Root cause: generic URL filtering excluded known collection/search/category routes and Amazon search routes but allowed locale-only homepage paths. PR #246 now rejects root and locale-only landing paths both before fetching and again during evidence validation. Specific product routes such as `/uk/products/k1` remain eligible. PR #246 merged as `4825b894b09faed2bc76467eeb5c5c8312018411`; CI run 42213976962 passed.
- Performance: still one Gemma call per product. The current issue is evidence quality, not extraction-call count.
- Remaining known quality weakness: fetched HTML is flattened into text with navigation, footer and unrelated product listings retained. A visible GBP price and product identity terms can therefore occur in unrelated page chrome. Next improvement should isolate product-detail content (JSON-LD Product/Offer, product-specific main content, title/H1 and canonical URL) and require corroborating product identity and price within the same product block before Gemma extraction/acceptance. Do not weaken strict UK/GBP/new-used rules.
- No catalogue products/evidence or review queue rows were written by the dry-run. No TEST/LIVE schema, RLS, RPC, Edge Function, tenant/customer/Stripe/domain data or deployment changed.


## Search coverage and condition-classification corrections (6 November 2026)

- PR #249 merged as `153426a6dfa1ef72869a46f26f8847f900c4389c`; CI run 42214714558 passed. Search coverage now runs complementary product searches across DuckDuckGo, Bing and Mojeek. Search-provider query coverage is separate from evidence eligibility: all candidate pages still pass direct product/listing URL filters and strict source/product/price/condition validation.
- PR #250 merged as `94d3fbf84497622acb8e6afd7585db3076d7c04a`; CI run 42215131080 passed. `Opened - never used` is valid UK-used evidence, not UK-new. The exact condition phrase is preserved. Factory-new/sealed items remain UK-new; used, pre-owned, refurbished and opened-never-used items may be UK-used when explicitly stated.
- The previous test that rejected opened-never-used UK-used evidence has been replaced with acceptance coverage plus a regression test preventing it being classified as UK-new.
- Do not discard opened-never-used prices or relabel them as ordinary used condition. Keep their source condition text in the evidence record.
- Current feature branch includes PR #249 and PR #250. PR #250 CI is green.
- The Research PC's last controlled run still exposed a quality issue: navigation/storefront content can be mistaken for a product detail page. The next substantive engineering task is product-content extraction and corroboration (Product/Offer JSON-LD, canonical URL, title/H1 and product-specific main content), not another search-rule tweak.
- The most recent local Research PC dry-run showed 8 search results, 2 eligible URLs, 1 fetched price-bearing page, 1 Gemma call, and 0 candidates after the content-extraction change; do not infer that this is resolved without a verified direct product detail candidate.
- No catalogue/evidence imports, review queue inserts, schema/RLS/RPC/Edge Function changes, TEST/LIVE tenant/customer/payment/domain changes, secrets, or deployments were made by PRs #249 or #250.


## Verified opened-never-used condition correction — 6 November 2026

- PR #251 merged to the Gemma feature branch as `c31b856cb561099b730753d7de195c914e08c3bd`.
- CI run #50 (`42215870318`) completed successfully; the Gemma agent test job passed.
- Source audit caught that the earlier claimed correction had not actually changed the feature-branch source. This PR changes the real validator, Gemma prompt and regression tests.
- `Opened - never used` is accepted as UK-used evidence; the exact condition is preserved. It remains invalid as UK-new evidence.
- The prior local 25/25 test result was not proof of the correction because the local test still asserted that the condition should be rejected. Research PC must receive the merged source and test files before this rule is considered verified locally.
- The latest controlled run remains blocked before Gemma: 8 search results, 1 eligible URL, 0 fetched price-bearing pages, 0 Gemma calls, 0 accepted candidates. The sole eligible eBay listing returned HTTP 403.
- Next technical priority is source discovery/fetch resilience and genuine product-page coverage. Do not treat zero candidates as a model extraction failure. Do not enqueue or import until a direct product page and evidence are independently verified.
- No TEST/LIVE catalogue or evidence writes, schema/RLS/RPC/Edge Function changes, tenant/customer/Stripe/domain changes, secrets or deployments were made.


## Balanced search coverage correction — 6 November 2026

- PR #252 merged to the Gemma feature branch as `360fa12755e043fac8de400fc732d11fcbb4ffed`.
- GitHub Actions run #54 (`42216410881`) passed; the test job completed successfully. Push run #53 (`42216389814`) also passed.
- Root cause from the Research PC dry-run: results were flattened in provider order, so DuckDuckGo could consume the entire eight-result cap before Bing and Mojeek contributed. Only one of eight results was an eligible direct listing, and that eBay page returned HTTP 403; Gemma was never called.
- Search now maintains independent DuckDuckGo, Bing and Mojeek lanes and merges them round-robin. Default search cap increased from 8 to 18; `SEARCH_RESULTS_PER_TASK` remains configurable and is clamped to 1–30.
- Regression test verifies a six-result cap receives two results from each provider. Existing direct-page URL filters, fetch validation, UK GBP, exact model, condition and availability checks remain unchanged.
- This improves discovery breadth but does not guarantee that any provider will return accessible product pages. The next Research PC dry-run must report provider mix, eligible URLs, HTTP failures, fetched price-bearing pages and Gemma calls. Do not enqueue/import until a genuine product detail page and all evidence fields are verified.
- No TEST/LIVE catalogue/evidence writes, database/schema/RLS/RPC/Edge Function changes, tenant/customer/payment/domain data, credentials or deployments were changed.


## Research PC follow-up — search result diagnostics, 6 November 2026

- The Research PC confirmed the balanced-search code and all 27 tests passed. The subsequent dry-run still returned 8 results, only 1 eligible URL, 0 fetched pages, 0 Gemma calls and 0 candidates. The only eligible URL was an eBay listing and returned HTTP 403.
- The local result cap remained 8 because the existing .env explicitly sets SEARCH_RESULTS_PER_TASK=8. The code default of 18 is only used when the setting is absent/empty. Never overwrite the existing .env; the owner should change that single setting to 18 manually.
- Follow-up PR #253 adds per-provider result counts to the search-complete event and logs provider, title and URL for every URL rejected by the pre-fetch direct-product filter. The example environment now uses 18. This is diagnostic visibility, not an assertion that provider search results are good or fetchable.
- Next run must show which providers are returning non-product pages, and the actual links/titles being rejected. If the next set remains low quality, adjust search queries/provider parsers based on those observed links, not by weakening UK/product-page/evidence validation. Keep dry-run; no queue or catalogue writes.
- The previous dry-run did not call Gemma and did not write catalogue or review-queue rows.


## GearCashOut research parity — discovery path (6 November 2026)

The local TradeFlow discovery layer must mirror the proven GearCashOut sequence rather than relying on generic web search alone:

1. Optional official Google Web Search Service or existing Google Programmable Search, using credentials configured only in the TradeFlow `.env`.
2. Parallel independent DuckDuckGo, Bing and Mojeek queries with provider-level failure isolation and balanced result lanes.
3. Explicit Amazon UK exact-model discovery queries. Amazon search URLs are discovery only; evidence requires a direct ASIN detail URL.
4. Read the approved TradeFlow source registry (`public.platform_research_sources`) from TEST as a read-only research control plane and probe enabled source domains using their known site-search routes.
5. Deduplicate discovered URLs, then retain the existing strict direct-product URL, UK storefront, GBP price, exact model, condition and availability checks before Gemma.

The registry is a new TradeFlow table, not a link to GearCashOut's `quote_catalog_ai_sources`. Its migration must be applied independently to TEST and LIVE, and approved source rows must be curated separately. Do not copy GearCashOut credentials, catalogue records, source IDs, customer data or evidence into TradeFlow. If Google credentials are absent, Google is skipped without blocking the other providers. If the registry table is not yet present, approved-source probing is skipped and public discovery continues.


### Source registry parity and probe scheduling

- TEST and LIVE both contain `platform_research_sources`, with the same curated 20-source public directory and GearCashOut-style operational metadata.
- Local research reads the TEST registry only. Keep the LIVE registry aligned as the deployment/configuration mirror; do not write research results to either registry.
- Probe UK new-retail, UK used-market and official-manufacturer lanes in round-robin order. Never let the first high-priority retail sources consume all slots.
- Probe in groups of four, with short per-route timeouts. This avoids serially spending several minutes on twelve source domains.
- Only UK sources may supply UK evidence; overseas rows remain excluded from this path.
- Support per-source search URL templates using `{query}`, `{model}` and `{manufacturer}`. Verify templates with a direct source probe before enabling them.
