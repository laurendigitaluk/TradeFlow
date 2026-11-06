# Gemma single-pass research checkpoint

Date: 2026-11-06
Branch: fix/gemma-single-pass-research-handoff-20261106

- UK-new and UK-used tasks for the same product/package are consolidated into one product task.
- One search and one batched Gemma extraction now classify sources as uk_new or uk_used. Ambiguous condition is excluded.
- UK source, visible GBP price, exact model and condition validation remain in place.
- Research handoff remains TEST-only for owner review when explicitly enqueued.
- Research no longer queries the TEST/LIVE master catalogue. Exact product checks and evidence insertion remain downstream in the approved importer.
- No catalogue/database data, schema, RLS, RPCs, tenants, customers, Stripe or deployments were changed.
- GitHub Actions passed: https://github.com/laurendigitaluk/TradeFlow/actions/runs/42210738184
- Research PC dry-run and elapsed-time comparison are still required. CPU-only inference remains unchanged.

Next: pull the branch after checking local uncommitted changes; run npm test; perform one dry-run and confirm one Gemma call per product; only approved evidence proceeds to the separate importer.

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


## Follow-on fixes — search coverage and condition handling (6 November 2026)

- PR #249 merged: `153426a6dfa1ef72869a46f26f8847f900c4389c`. CI run 42214714558 passed. Complementary searches now run across DuckDuckGo, Bing and Mojeek, while evidence URL and validation gates remain strict.
- PR #250 merged: `94d3fbf84497622acb8e6afd7585db3076d7c04a`. CI run 42215131080 passed.
- Corrected condition rule: `Opened - never used` is eligible as UK-used evidence when explicitly stated; preserve the exact condition wording. It must not be classified as factory-new/sealed or rejected merely because it has never been used.
- Regression tests now accept opened-never-used as UK used and reject it as UK new.
- Research PC update and a new controlled dry-run remain outstanding. The last run still needs a valid direct product-detail candidate; no evidence should be imported until the source URL, product identity, price and condition are verified.
- No TEST/LIVE catalogue/evidence rows, review queue rows, schema, RLS, RPC, Edge Functions, tenant/customer/Stripe/domain data, credentials or deployments were changed.


## Verified opened-never-used condition correction — 6 November 2026

- PR #251 merged to the Gemma feature branch as `c31b856cb561099b730753d7de195c914e08c3bd`.
- CI run #50 (`42215870318`) completed successfully; the Gemma agent test job passed.
- Source audit caught that the earlier claimed correction had not actually changed the feature-branch source. This PR changes the real validator, Gemma prompt and regression tests.
- `Opened - never used` is accepted as UK-used evidence; the exact condition is preserved. It remains invalid as UK-new evidence.
- The prior local 25/25 test result was not proof of the correction because the local test still asserted that the condition should be rejected. Research PC must receive the merged source and test files before this rule is considered verified locally.
- The latest controlled run remains blocked before Gemma: 8 search results, 1 eligible URL, 0 fetched price-bearing pages, 0 Gemma calls, 0 accepted candidates. The sole eligible eBay listing returned HTTP 403.
- Next technical priority is source discovery/fetch resilience and genuine product-page coverage. Do not treat zero candidates as a model extraction failure. Do not enqueue or import until a direct product page and evidence are independently verified.
- No TEST/LIVE catalogue or evidence writes, schema/RLS/RPC/Edge Function changes, tenant/customer/Stripe/domain changes, secrets or deployments were made.
