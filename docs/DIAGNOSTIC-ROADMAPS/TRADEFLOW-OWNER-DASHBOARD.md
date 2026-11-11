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


A dedicated GitHub Actions workflow `.github/workflows/gemma-research-tests.yml` has also been added on the repair branch. It runs Node 24 syntax checks across the Gemma source modules, both existing Gemma test suites (including the new Amazon/model/collection cases), and an Owner Dashboard JavaScript syntax check on relevant PRs and production pushes. This is test-only CI; it does not deploy the Research PC worker or change Cloudflare/Supabase.


## Production merge status — Gemma navigation repair
PR #272, `Fix Gemma research navigation and exact-model filtering`, was merged to `production` on 7 November 2026. Merge commit: `38c6872ccacfd56b8c59491964a86043b84feaf6`. Production now contains the canonical Amazon AAX unwrapping, query-string-safe exact-model matcher, website-declared Shopify collection fallback, Research Again source seeding, Owner Dashboard `v=28`, added tests and `.github/workflows/gemma-research-tests.yml`. GitHub Actions run details were not returned by the connected workflow-run lookup at the time of this checkpoint; do not claim CI passed. The Research PC updater must still run the Node syntax checks and both test suites before the updated worker is accepted. After that, confirm the live Owner Dashboard script version and run exactly one Creality K1 research-again task, then inspect its detailed `platform_ai_agent_activity` records. No further product research task has been submitted since the failure analysis.


## Deep category and website research — 7 November 2026 (PR #273; awaiting validation/merge)

- Scope is the first 3D Printers & Equipment agent only. Do not roll these rules to other category agents until the first agent has passed Research PC acceptance.
- The Owner Dashboard batch builder already resolves a selected master category/branch into individual master-catalogue product/package tasks. Each queued task is one exact product leaf, retaining its branch_slug; the worker must not treat a branch or category page as finished research. LIVE category structure was checked: 201 active products total, comprising 183 in branch 3d-printers and 18 in branch 3d-printer-equipment-accessories. The playbook now has separate machine-versus-accessory instructions so printer-only exclusions cannot incorrectly reject the accessories branch.
- probeApprovedResearchSources() now checks every configured website route in parallel per source and accumulates unique matches instead of returning after the first route succeeds. Search result pages can follow bounded same-host pagination (up to two further pages); collection discovery can inspect up to 12 hubs and follow up to three same-host pagination pages per hub. Individual direct product pages are inspected up to 30 per product task, with an explicit telemetry event when the bound is reached.
- Each page must still be an individual exact-model/product listing. Category/branch/collection/search pages remain discovery only. Manufacturer/category source allow-lists, UK/GBP checks, model/package matching and the ChatGPT/owner approval boundary remain authoritative. Do not bypass logins, robots, access controls or invent site endpoints.
- Exact-model direct pages without visible GBP price are no longer silently discarded before Gemma. They are passed to Gemma for a separate borderline assessment. Validation failures on an otherwise eligible exact-model product page are also retained as borderline. These are inserted into LIVE platform_catalogue_research_queue as record_type='evidence_candidate', status='needs_research', with null evidence type/price/currency/condition/availability, captured excerpt, original URL and explicit reason in research_notes/raw_payload.review_classification='borderline'. They are for ChatGPT inspection only, not verified evidence.
- Verified candidates remain pending_review. The Owner Dashboard displays borderline notes and hides the approval action for raw_payload.review_classification='borderline'; only Research Again or Reject is available. No automatic catalogue/evidence approval or import is introduced.
- Telemetry/metrics distinguish search results, eligible URLs, discovered product pages, inspected product pages, price-bearing pages, verified candidates and borderline candidates. Website route errors and pagination failures remain visible.
- Owner Dashboard cache reference bumped from platform-owner-dashboard.js?v=28 to ?v=29.
- Tests added for same-host search/collection pagination, category-to-product traversal, borderline instructions and separate printer/accessory branch rules. Existing Research PC updater already downloads the updated agent.mjs, playbook and playbook tests and runs syntax checks plus both test suites before installation.
- PR #273 is open against production. GitHub Actions workflow-run lookup returned no run at checkpoint time; do not claim tests have passed until a green run or equivalent Research PC updater output is observed.
- No Supabase schema/migration or LIVE/TEST catalogue data changed. The existing 201-product catalogue and all evidence approvals remain untouched. No Research PC .env, Ollama settings, legacy GearCashOut configuration, Stripe or Cloudflare setting was changed.
- After merge, update the existing Research PC using the reviewed updater, preserving the exact private .env path. Then verify Owner Dashboard v29, run one controlled Creality K1 task, and inspect activity for all-route completion, pagination, individual-page counts, verified candidates and borderline candidates. Do not start the wider branch/category batch until this acceptance is complete.


## Merge and CI verification — 7 November 2026

PR #273, “Deepen Gemma category research and capture borderline findings”, was merged into production as commit 7e8e2d4ba6e634fa788ec78b345ac6047e54aee7. GitHub Actions Gemma Research Tests run 42403829606 completed successfully: all Gemma source syntax checks passed, the task-group and website-playbook test suites passed (19 tests, 0 failures), and Owner Dashboard JavaScript syntax passed. The first test run exposed a collection-pagination fixture that dropped the Creality UK locale path; the fixture was corrected to retain /uk/, and the subsequent complete CI run passed.

Production now contains all-route probing, bounded search/collection pagination, branch-specific printer/accessory rules, direct-page borderline assessment, validation-failure borderline handoff, approval suppression for borderline queue rows, expanded research coverage metrics, and Owner Dashboard cache reference v29. This confirms GitHub source and CI only; it does not yet confirm Cloudflare's production deployment or Research PC installation. The Research PC must be updated with the production updater, then the owner dashboard must be checked for v29, and exactly one controlled Creality K1 task run before any wider batch is dispatched.


## 8 November 2026 — Active queue/task list behavior and deployment verification

**Current production frontend**
- HTML: platform-owner-dashboard.html; current headings are “Outstanding research tasks” and “Research awaiting review”.
- JS: platform-owner-dashboard.js, loadGemmaTasks() calls platform_owner_list_ai_agent_tasks with p_status='active'; loadGemmaQueue() calls platform_owner_list_catalogue_research_queue with p_status='open'.
- RPCs: platform_owner_list_ai_agent_tasks(p_limit,p_status) maps active to queued/running/failed; platform_owner_list_catalogue_research_queue(p_status,p_limit) maps open to pending_review/needs_research/approved and completed to imported/rejected.
- Completed task/evidence history remains in the database; the default dashboard lists do not display it.
- worker/index.js sets Cache-Control: no-store on platform-owner-dashboard.html and JavaScript assets.

**Database status at 8 November 2026**
- LIVE: 65 3D-printer queue rows, 28 imported and 37 rejected; zero open queue rows across all categories; 20 completed agent tasks; zero active tasks.
- TEST: zero open queue rows; one queued 3D-printer smoke test (Creality Ender-3 V3 KE) and one completed task. Keep the queued test until it is deliberately processed or cancelled.

**Observed deployment mismatch**
The screenshot shows the old heading “Queued and completed tasks” and processed records. Current production HTML/JS and RPC definitions do not produce that view. The likely first failure is the Cloudflare Worker asset deployment. Worker name from wrangler.jsonc is tradeflow; repository has no GitHub Actions deploy workflow. Verify Cloudflare Workers & Pages > tradeflow > Deployments and deploy the latest production commit. Do not delete queue rows or rewrite statuses to compensate for stale frontend assets. After deployment, hard-refresh the owner dashboard and confirm empty states.

## Manual AI Research catalogue filter diagnostic map — 11 November 2026

**User action:** Owner Dashboard → AI Research Centre → select Category → optional Branch → optional Manufacturer → Evidence required → tick product(s) → Generate research prompts.

**Frontend:** platform-owner-dashboard.html loads platform-owner-dashboard.js?v=53. Picker controls: cloud-ai-category, cloud-ai-branch, cloud-ai-manufacturer, cloud-ai-evidence-filter. Controller functions: loadCloudAiCatalogueTree, loadCloudAiCatalogueCategories, loadCloudAiCatalogueManufacturers, loadCloudAiCatalogueProducts, onCloudAiCategoryChange, onCloudAiBranchChange, and createManualAiResearchBatch. Pagination and checkbox selection remain in the existing picker controller; selection remains keyed by master product_id.

**Database:** platform_owner_list_cloud_ai_catalogue_manufacturers(p_category_id,p_branch_id) returns active manufacturer IDs/names/counts scoped to the chosen category and optional branch. platform_owner_list_cloud_ai_catalogue_products_filtered(p_category_id,p_branch_id,p_manufacturer_id,p_evidence_filter,p_limit,p_offset) applies category, branch, manufacturer and evidence conditions before returning the filtered total and page. Evidence counts come from active public.shared_market_evidence records: uk_new and uk_used. Filter values: all, no_evidence/missing_both, missing_new, missing_used, complete.

**Security:** Both RPCs call public.platform_cloud_ai_owner_check() and revoke execution from public/anon; execution is granted to authenticated. The owner check requires an active platform_memberships row for auth.uid().

**Expected flow:** Category change clears the old product selection, loads branches, loads manufacturers for the category and refreshes products. Branch change clears the old selection, reloads manufacturer options scoped to that branch and refreshes products. Manufacturer/evidence changes reset the result offset and refresh the list while retaining the current product selection map. Previous/Next retains active filters. Manual batch generation still snapshots the selected master product IDs; evidence filters do not write evidence or change review state.

**Failure points:** Empty manufacturer list → inspect the manufacturer RPC and active catalogue_master_products.manufacturer_id links. Incorrect filter totals → inspect shared_market_evidence.is_active, evidence_type, and product linkage via master_product_id. Empty later pages → check p_offset/p_limit and filtered total_count. Permission error → verify owner JWT, active platform membership and RPC grants. Stale UI → verify Worker deployment and HTML JS query version v=53.

**Migration:** 20261111000300_cloud_ai_catalogue_manufacturer_evidence_filters.sql. Existing RPCs remain unchanged for compatibility. No product/evidence rows or TEST/commercial data changed.

## Evidence checkbox filter diagnostic notes — 11 November 2026

**UI:** cloud-ai-evidence-filter select removed. Three checkboxes use data-cloud-ai-evidence-filter values missing_used, missing_new, and no_evidence. Empty selection maps to all; no-evidence only maps to no_evidence; individual checkboxes map to their corresponding filters; selecting both missing-new and missing-used maps to missing_any (OR semantics). Multiple checked conditions show products matching any selected condition.

**Backend:** platform_owner_list_cloud_ai_catalogue_products_filtered accepts all, no_evidence, missing_new, missing_used, and missing_any. missing_any returns products with zero new OR zero used evidence. no_evidence returns products with zero new AND zero used evidence. Pagination and totals are calculated after the evidence predicate.

**Expected UI:** Three plain checkbox lines and one short explanatory note; no dropdown or “complete” option. Script cache reference is platform-owner-dashboard.js?v=55.

**Verification:** Cameras → Photography Cameras → Nikon counts: all 205; no evidence 109; missing new 189; missing used 111; missing either 191. Calls were rolled back. No evidence or catalogue rows changed.
