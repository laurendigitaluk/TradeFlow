# TradeFlow Platform Owner Dashboard — Developer Diagnostic Roadmap
Updated: 7 November 2026
Status: nine-section layout and Common Room implemented on `feature/ai-agent-common-room-20261107` (PR [#267](https://github.com/laurendigitaluk/TradeFlow/pull/267)); browser acceptance and deployment pending.

## Scope and boundaries
The Platform Owner dashboard is a platform-level control surface, not a subscriber tenant workspace. It uses the separate `platform_memberships` authorization boundary. The current UI has nine collapsible management sections; the overview metrics remain visible.

- Repository: `laurendigitaluk/TradeFlow`
- Dashboard entry: `platform-owner-dashboard.html`
- Runtime: `platform-owner-dashboard.js`
- Styling: `platform-owner-dashboard.css`
- Public-page text editor: `platform-public-pages-editor.js`
- Public-page visual editor: `platform-public-pages-visual-editor.js`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- LIVE branch/Worker: `production` / `tradeflow`
- TEST branch/Worker: `cloudflare-test` / `tradeflow-test`

## Authentication and owner authorization
1. Browser reads the owner session from localStorage key `tradeflow_platform_owner_session`.
2. `platform-owner-dashboard.js` calls Supabase Auth `/auth/v1/user`.
3. `establish()` checks `public.platform_memberships` for the authenticated `user_id` with `status='active'`.
4. Owner RPCs perform their own active platform-membership checks. Do not replace this with a tenant membership or subscriber role.
5. Domain preparation and complimentary subscriber creation use authenticated Edge Function requests with the Platform Owner JWT.

## Section map — user action to code and data

| Dashboard section | Front-end entry point | Data path |
|---|---|---|
| Product details | `loadProductPages()`, `saveProductPage()` | `platform_owner_get_product_pages()`, `platform_owner_update_product_page(...)` → `platform_product_pages` |
| Subscriber businesses | `loadTenants()`, `manageSubscription()` | `platform_admin_list_tenants()`, `platform_admin_list_subscriber_accounts()`, `platform_admin_manage_subscription(...)` → `tenants`, `tenant_memberships`, `tenant_subscriptions` and related plan data |
| Domain connection requests | `loadDomainActions()`, `prepareCloudflareConnection()` | `platform_owner_list_domain_actions()`, `platform_owner_update_domain_action(...)` → `platform_owner_domain_actions`, `tenant_domains`; Step 2 calls protected `platform-prepare-custom-domain` and Cloudflare |
| TradeFlow plan | `loadPlans()`, `savePlan()` | `platform_owner_get_plans()`, `platform_owner_update_plan(...)` → `plans`, `plan_features` and Stripe product/price identifiers |
| Public Website Pages | `platform-public-pages-editor.js` | `platform_owner_get_public_pages()`, `platform_owner_save_public_page(...)`, `platform_owner_publish_public_page(...)` → `platform_public_pages` |
| AI Agent Common Room | `loadAiAgentCommonRoom()`, `postAiAgentCommonRoom()` | Owner list/post RPCs; service-role-only agent read/post RPCs → `platform_ai_agent_messages` |
| Gemma Control Centre | `loadGemmaControlCentre()`, `loadGemmaSources()`, `loadGemmaBatchCategories()`, `loadGemmaBatchProducts()`, `submitGemmaBatch()`, `loadGemmaTasks()`, `loadGemmaQueue()`, `reviewGemmaCandidate()` | Owner RPCs for telemetry, source assignments, category/product coverage, task enqueue/list, candidate queue/review. Tables: `platform_ai_agent_status`, `platform_ai_agent_activity`, `platform_ai_agent_tasks`, `platform_catalogue_research_queue`, `platform_research_sources`, `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_products`, `shared_market_evidence` |
| Complimentary subscriber accounts | `createComplimentarySubscriber()` | Protected `platform-create-complimentary-subscriber` Edge Function → tenant, owner invitation and complimentary subscription workflow |
| Platform email settings | `loadPlatformEmail()`, `savePlatformEmail()` | `platform_owner_get_email()`, `platform_owner_save_email(...)` → `platform_email_settings` |

## Gemma research flow and safety
- LIVE is the authoritative research queue and evidence-review environment. TEST is for code, migration and regression work.
- Category selection and evidence coverage are read from LIVE master catalogue/evidence RPCs.
- Batch enqueue uses `platform_owner_enqueue_ai_agent_task(...)`; the owner dashboard does not write to TEST from a LIVE browser session.
- The Research PC worker is in `tools/tradeflow-gemma-agent/src/task-worker.mjs`; agent logic and telemetry are under `tools/tradeflow-gemma-agent/src/`.
- Approved websites are assigned through `platform_research_sources.category_slugs`. Amazon UK and eBay UK are the universal sources; category-specific sources must not bleed across unrelated categories.
- Candidate review is not catalogue import. ChatGPT/owner validation remains required before verified catalogue/evidence ingestion.
- Worker-only claim/heartbeat/complete/fail RPCs must remain server/service-role-only. Never expose service-role credentials to browser code or store them in the Research PC UI.

## Public How It Works page
- Published page source: `how-it-works.html`; styles: `how-it-works.css`.
- It is a source-managed, text-only page with ten native HTML accordion sections. It does not load the old JSON page renderer.
- The legacy `platform_public_pages` row for `how-it-works` remains in both environments but does not drive the published static guide. The legacy owner editor still exposes that row; changes there do not update the public guide. The Owner Dashboard now warns about this. Do not claim a CMS save/publish updated How It Works.
- `examples` remains database-backed and editable through the existing public-page editor.

## Collapsible dashboard navigation
The layout uses native `details.owner-section-accordion` wrappers in `platform-owner-dashboard.html`, styles in `platform-owner-dashboard.css`, and `initOwnerSectionAccordions()` in `platform-owner-dashboard.js`. Sidebar hash links open their corresponding section. Overview statistics remain visible. Existing section IDs and inner control IDs are preserved so existing event handlers and data loaders continue to work.

## Known failure points and verification
- A valid Supabase session without an active `platform_memberships` row must be denied Platform Owner access.
- Never assume a GitHub commit proves Cloudflare deployment or browser behaviour.
- Check stale cached CSS/JS by confirming asset versions (`platform-owner-dashboard.css?v=10`, `platform-owner-dashboard.js?v=27`).
- Verify sidebar links open the right section, direct hash links expand on load, buttons still work after their DOM nodes are moved inside `details`, and keyboard focus remains visible.
- Verify each owner section on desktop and mobile, including the Gemma batch form, queue review buttons, source manager, domain workflow, product-page forms and public-page editor.
- Verify the static How It Works page separately; do not test it through the legacy JSON CMS as a proxy.
- No database memory/checkpoint tables were found in the current LIVE public schema. Persistent project records for this increment are stored in repository `CHECKPOINTS/` and `PROJECT-MEMORY/`.

## AI Agent Common Room — 7 November 2026
- The Common Room is the ninth collapsible owner section, using the same native details/summary layout.
- HTML entry: `platform-owner-dashboard.html#ai-agent-common-room`; browser logic in `platform-owner-dashboard.js`; styles in `platform-owner-dashboard.css`.
- Owner list/post RPCs: `platform_owner_list_ai_agent_messages(...)`, `platform_owner_post_ai_agent_message(...)`.
- Agent read/post RPCs: `platform_ai_agent_list_messages(...)`, `platform_ai_agent_post_message(...)`; service-role-only.
- Storage: `platform_ai_agent_messages`; RLS enabled, direct table access denied to anon/authenticated; owner RPC checks active `platform_memberships`.
- Gemma worker reads bounded Common Room instructions/handovers/learning notes and passes them into its Ollama extraction prompt as operational guidance. Hard-coded task identity, approved source, evidence validation, privacy and review gates take precedence. Agent messages cannot approve evidence or trigger catalogue imports.
- The Research PC worker has not yet been updated/restarted; owner → worker → handover → owner browser round-trip remains a release gate.
- ChatGPT is a supervisory participant during active ChatGPT sessions, not a continuously running independent service. A persistent ChatGPT agent requires a separately deployed integration.

## Change state
This increment changes dashboard HTML/CSS/JS, Gemma worker prompt integration, documentation and repository checkpoint files. No Supabase schema/data, RLS, Edge Functions, tenants, customers, orders, payment records, Stripe configuration, domain ownership, Research PC secrets or Cloudflare deployment are changed.


## Research Again button — 7 November 2026
- User action: select **Research again** on a `pending_review` or `needs_research` candidate.
- Runtime: `platform-owner-dashboard.js` → `loadGemmaQueue()` caches returned rows in `window.gemmaQueueItems`; `reviewGemmaCandidate(id, 'needs_research')` builds the exact product task.
- Dispatch: `platform_owner_enqueue_ai_agent_task(...)` creates a new LIVE `platform_ai_agent_tasks` row. Payload must satisfy `normaliseProductResearchTasks()` in `tools/tradeflow-gemma-agent/src/task-groups.mjs`: category, manufacturer, model, package key/name, search query and `uk_new`/`uk_used`/`uk_both` research type.
- Review state: after successful enqueue, call `platform_owner_review_catalogue_research_item(...)` to set `needs_research`. Never change status first; failed enqueue must leave the candidate reviewable.
- Worker: existing LIVE `task-worker.mjs` polls every 15 seconds and claims the new task. Findings return to `platform_catalogue_research_queue` for owner review.
- Known production defect: old handler only called the review RPC, changing status without a task. Merged in PR #268 to `production` as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`. Cloudflare deployment and browser acceptance remain pending.


## Gemma research failure analysis and navigation correction — 7 November 2026

### Observed LIVE run
- Investigated LIVE `platform_ai_agent_activity` for task `owner-research-again-b94e2225-c07b-4001-8dfa-cd045bf962fd-1794075404013` (queue task UUID `9f6f79db-4085-4638-8415-e2b654c03893`). It completed in about 84 seconds with 15 search candidates (10 DuckDuckGo, 5 approved-source), 4 initially eligible URLs, 1 price-bearing page fetched, 1 Gemma extraction call, 0 accepted evidence and 0 queue writes. No worker/task exception occurred.
- Source-level activity showed: 123-3D direct refurbished K1 result returned HTTP 404; eBay item fetch returned HTTP 403; iDig3DPrinting and 3DFLO search routes returned HTTP 404/empty results; Gumtree returned no exact-model links; Uni3Dverse collection fallback returned HTTP 500; Creality collection pages had no server-rendered matching links and the generic Shopify `products.json` fallback returned HTTP 404; 3DGBIRE and 123-3D Shopify collection JSON returned zero matching K1 products.
- Amazon's result was an AAX tracking URL leading to a Creality extruder/filament accessory. The search query text `keywords=Creality+K1` was included in `matchesTaskModel()` identity, allowing the unrelated accessory through the prefilter. The final evidence validator correctly rejected it because the page did not identify the K1 printer or provide qualifying visible GBP price/direct listing evidence.
- The single fetched price-bearing page therefore did not contain acceptable K1 evidence. The earlier known official Creality K1 product URL was not being passed back into Research Again as a seed URL, so the worker could miss a known exact-model product page while relying on current search indexing.

### Minimal code corrections on branch `fix/gemma-research-page-navigation-20261107`
- `matchesTaskModel()` now checks result title plus canonical hostname/path only; it ignores query strings so search terms and tracking parameters cannot turn accessories into exact-model matches.
- Amazon AAX sponsored/tracking links are unwrapped to the canonical `www.amazon.co.uk/.../dp/<ASIN>` page before eligibility/model checks.
- Collection expansion now uses Shopify's `/products.json` endpoint only when that website's playbook explicitly declares `collectionApi: 'shopify'`. Creality and Uni3Dverse are no longer sent to an incompatible Shopify endpoint; 123-3D and 3DGBIRE retain the declared Shopify fallback.
- Owner Dashboard Research Again now passes the existing candidate's `source_url` in `seed_urls`. The worker rechecks this URL only if it still belongs to a category-approved UK source and passes direct-product and exact-model checks; it is not trusted evidence and must be fetched and validated again.
- Owner Dashboard cache reference bumped from `platform-owner-dashboard.js?v=27` to `?v=28` so the seed-URL change is loaded.
- Added tests for query-string false positives, Amazon AAX canonicalisation, and per-site Shopify collection capability. The Research PC updater already runs both task-group and website-playbook test suites before install. These new tests have not yet run on the Research PC; deployment and a fresh product test remain pending.

### Safety and next verification
- No catalogue candidate was approved/imported, no LIVE/TEST catalogue data was changed, no Supabase schema or RLS was changed, and no `.env`, legacy GearCashOut configuration, Stripe or Cloudflare setting was touched.
- Next step: run the reviewed Research PC updater against the existing TradeFlow install and `.env`; require syntax checks and all tests to pass. Then confirm Owner Dashboard serves `v=28`, rerun the same Creality candidate once, and inspect activity for a `seed_url_added` event, canonical Amazon product links, no accessory false-positive, no Shopify API request to Creality/Uni3Dverse, and any qualifying new/used evidence returned to owner review.
- Do not treat registered source count or general search-result count as source coverage. Track each approved source's route attempts, HTTP outcome, links discovered, direct pages fetched, price-bearing pages and accepted candidates separately. Add further website-specific navigation only from observed failures and verified routes.
