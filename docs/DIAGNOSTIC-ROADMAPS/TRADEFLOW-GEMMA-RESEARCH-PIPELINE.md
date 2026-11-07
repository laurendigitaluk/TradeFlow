# TradeFlow Gemma Research Pipeline — Diagnostic Roadmap

Updated: 7 November 2026

## Operating boundary
- LIVE project gxsrajtqzdjvmceqcpgv is the only authoritative research task and evidence-review queue.
- TEST project nnsshnfkjcflucjrftzi remains for software development, migrations and regression fixtures. Existing TEST data remains untouched.
- Gemma discovers candidate UK market evidence. Owner/ChatGPT verifies; no autonomous approval or master catalogue/evidence write is permitted.

## Dashboard entry points
- Platform Owner dashboard: platform-owner-dashboard.html.
- Category research team cards: platform-owner-dashboard.js → renderGemmaResearcherCards.
- Category source manager: loadGemmaSources / addGemmaResearchSource.
- Owner source RPCs: platform_owner_list_research_sources(text), platform_owner_add_research_source(text,text,text,text,text,text), platform_owner_set_research_source_category(uuid,text,boolean).
- How It Works / Examples editor: platform-public-pages-editor.js → node/render/save.
- Platform AI provider settings: platform-owner-dashboard.html / platform-owner-dashboard.js → platform_owner_get_ai_settings and platform_owner_update_ai_settings.

## Category and source model
- Canonical LIVE 3D category is 3d-printers-equipment / “3D Printers & Equipment”.
- Two existing telemetry agent keys (3d-printers, 3d-printers-equipment) are grouped into one UI team card. Both records and their history are preserved.
- Pokémon master category already exists as pokemon-trading-cards. It is displayed as a reserved category but has no source assignment or research agent linkage.
- Category sources live in platform_research_sources.category_slugs. * means universal; current Amazon UK and eBay UK remain universal.
- Owner source RPCs validate active platform membership and active category. Universal sources are read-only from category-specific toggles.
- Research worker continues to filter enabled sources by category slug and manufacturer; no matching approved sources means fail closed.

## How It Works editor
- Nested objects and arrays in public-page draft JSON are rendered as collapsed details sections, expanded individually by the owner.
- Save/publish RPCs and existing draft/published workflow remain unchanged.

## AI provider boundary
- Subscribers cannot supply their own AI provider.
- Owner dashboard no longer exposes a subscriber-provider option. Its save call always sends p_subscriber_provider_enabled=false.
- LIVE update RPC already rejects subscriber-supplied providers and persists false.

## Verification and known limitations
- LIVE category/source table and telemetry inspected before change.
- LIVE owner source RPC migration applied; verify RPC signatures and category source data after deployment.
- The browser owner dashboard must be refreshed after the Cloudflare static asset deployment.
- Pokémon has no category-specific sources and is not to be dispatched.
- LIVE laptops agent status exists but its master category was previously missing; don't attach laptop sources until master category reconciliation.
- Full browser acceptance for adding/toggling a source, collapsible editor interactions and public publish workflow remains required.


## 7 November 2026 — LIVE batch research controls and How It Works editor

- Dashboard entry: `platform-owner-dashboard.html` → Gemma Control Centre → Build a category research batch.
- Front-end: `platform-owner-dashboard.js` functions `loadGemmaBatchCategories`, `loadGemmaBatchBranches`, `loadGemmaBatchProducts`, `submitGemmaBatch`; presentation styles in `platform-owner-dashboard.css`.
- LIVE data: `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_products`, `catalogue_master_manufacturers`, `shared_market_evidence`.
- LIVE RPCs: `platform_owner_list_gemma_research_categories()` returns active categories and branches; `platform_owner_list_gemma_research_products(text,text,text,integer)` returns category/branch products and active UK new/used evidence counts. Both validate active `platform_memberships`; anon execute is revoked.
- Batch enqueue uses existing `platform_owner_enqueue_ai_agent_task` and a payload with multiple `tasks`. The existing `task-worker.mjs` iterates the task array and calls `runTask` for each product.
- Coverage filters: all, missing new, missing used, missing both, missing either, has new, has used. Research type: `uk_new`, `uk_used`, `uk_both`. Batch size: 10, 20, 50, 100 or all selected (selection is limited to products currently displayed, up to 500).
- How It Works: public file `how-it-works.html` is already the accordion/text-only page. Owner editor `platform-public-pages-editor.js` suppresses legacy `screenshots` and `visual_layout` fields for `how-it-works`; `platform-public-pages-visual-editor.js` now exports a separate Examples editor loader and no longer overwrites `window.loadPublicPages`.
- Platform AI provider settings panel and nav entry removed from `platform-owner-dashboard.html`; its obsolete JS load/save handlers are no longer called. Subscriber-provided AI remains disabled by the existing server-side setting/RPC boundary.
- LIVE database function grants verified: anon=false, authenticated=true with active-owner validation in function body. Cloudflare/browser acceptance and an end-to-end Research PC batch remain outstanding.


## Batch selection safeguards
- The batch selector omits `pokemon-trading-cards` until its source/agent linkage is deliberately enabled. The master category remains intact.
- Batch enqueue submits the first N selected products according to the chosen batch size and retains the remaining selections for subsequent submissions.
- The 3D printer coverage query was checked against LIVE: 201 active products; 1 missing UK new evidence; 190 missing UK used evidence; 0 missing both; 191 missing either. These are a point-in-time count, not a permanent status.

## AI Agent Common Room — 7 November 2026

- Owner view: `platform-owner-dashboard.html` → `ai-agent-common-room`.
- Owner runtime: `loadAiAgentCommonRoom()` and `postAiAgentCommonRoom()` in `platform-owner-dashboard.js`.
- LIVE storage: `public.platform_ai_agent_messages`.
- Owner RPCs: `platform_owner_list_ai_agent_messages(...)`, `platform_owner_post_ai_agent_message(...)`; both enforce active `platform_memberships`.
- Agent RPCs: `platform_ai_agent_list_messages(...)`, `platform_ai_agent_post_message(...)`; only service_role can execute.
- Worker integration: `tools/tradeflow-gemma-agent/src/task-worker.mjs` → `roomRpc`, `roomRead`, `roomPost`. It posts startup/task status, completion/failure and handover, and reads shared notes/instructions.
- Owner-only instruction posts are separated from agent post types. Messages are not research jobs or approved evidence.
- Branch `feature/ai-agent-common-room-20261107`; migration, worker and owner UI not yet merged/applied/deployed. PC restart and round-trip acceptance are required.
- Never expose service-role credentials in browser/subscriber UI/GitHub. Preserve the PC `.env` and configured env-file path.

null

 
## Common Room prompt integration — 7 November 2026
The Research PC worker entry is tools/tradeflow-gemma-agent/src/task-worker.mjs. At task start it reads up to 100 relevant LIVE Common Room messages, filters instruction/handover/finding/question/learning_note types, maps at most ten into task.common_room_context, and passes them to runTask. The extraction function in tools/tradeflow-gemma-agent/src/agent.mjs includes the bounded notes in the Ollama prompt.

The prompt explicitly treats these notes as untrusted operational guidance. They cannot override the authoritative task definition, exact manufacturer/model/package identity, research_type, category source allow-list, UK/GBP constraints, direct product-page requirements, evidence validator, privacy or ChatGPT/owner review gate. If the Common Room read fails, the worker logs the error and proceeds without notes; it does not fail or block the research task.

The worker posts startup, task-start, handover, completion and failure messages to the LIVE Common Room. These are status/reporting messages only and do not approve candidates or import catalogue/evidence.

The Research PC has not yet been updated/restarted with this code. Verify the controlled owner-instruction → worker read → Gemma extraction prompt → handover → owner-visible feed round-trip before describing this as operational. Preserve the separate local .env and TRADEFLOW_GEMMA_ENV_FILE path.

 
## Common Room delivery routing correction — 7 November 2026
The worker reads across all threads (p_thread_key = null), not just General. It supplies its category slug so the RPC returns global messages with category_slug null plus messages for the matching category. Recipient matching supports null/all/*, the exact p_agent_key, p_worker_id, gemma-task-worker and research-agents. Messages addressed only to chatgpt-supervisor or engineering-agents are not delivered to the Gemma worker.

The final LIVE platform_ai_agent_list_messages and platform_ai_agent_post_message functions use an empty search_path, validate auth.jwt()->>'role' = 'service_role', revoke execution from public/anon/authenticated and grant only service_role. The owner list/post RPCs also use an empty search_path, require an active platform_memberships row and are executable only by authenticated owners. The additive routing/security migrations were applied and verified. No test messages remain. This is source/database verification only; the Research PC still needs code update/restart and an end-to-end owner instruction → worker read → handover → owner feed test.

 
## Post-merge worker bootstrap fix and PC updater — 7 November 2026
- PR #267 merged to production as 45049f5c4a1b131d95b701b2603fe0a351c392bd.
- A production-source check found task-worker.mjs imported ./task-groups.mjs, but that module was absent from the production tree. The worker would fail at module resolution before it could poll the queue.
- Fixed the worker to import src/task-groups.mjs and added normaliseProductResearchTasks(), which filters malformed queue entries and deduplicates identical product/category/branch/agent/package/research-type tasks while retaining distinct products and research types.
- Added src/task-groups.test.mjs using Node's built-in test runner. Four local tests passed for invalid inputs, malformed rows, duplicate removal and distinct task preservation.
- Added tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1 and README.md. The updater downloads only the reviewed source/test files, checks Node 18+, validates approved TEST/LIVE URLs in the supplied private .env, runs node --check and node --test before installation, backs up old source files, and replaces only src files.
- The updater never prints, copies, backs up or overwrites the private .env. It accepts the existing path and sets TRADEFLOW_GEMMA_ENV_FILE before starting the worker. For first install it supports a new dedicated TradeFlow folder, separate from the retired GearCashOut source.
- The updater has not been run on the Research PC. Local path, Ollama availability, worker start and Common Room round-trip remain unverified.

 
## Queue task validation refinement — 7 November 2026
The task normaliser now rejects incomplete payload rows before calling runTask. It requires category_slug, manufacturer, model, package_key, package_name, search_query and a research_type of uk_new, uk_used or uk_both. The Owner Dashboard's production task builder supplies these fields. Tests cover incomplete payload rejection as well as valid rows, malformed rows, duplicate removal and preservation of distinct task definitions. Four tests pass.


## Research Again retry path — 7 November 2026

### User action and front-end
- Entry: Owner Dashboard → Gemma Control Centre → Research queue → **Research again**.
- Front end: `platform-owner-dashboard.js` → `loadGemmaQueue()` stores the loaded LIVE candidate rows in `window.gemmaQueueItems`; `reviewGemmaCandidate(id, 'needs_research')` resolves the exact candidate and builds one product-level task.
- Task fields: `category_slug`, optional `branch_slug`, `agent_key`, `manufacturer`, `model`, `package_key`, `package_name`, `research_type: uk_both`, `search_query`.

### Dispatch and data flow
`Research again` → authenticated `platform_owner_enqueue_ai_agent_task(p_task_key, p_payload, p_priority)` → `platform_ai_agent_tasks` (LIVE) → `platform_ai_agent_claim_task(p_worker_id, p_lease_seconds)` → Research PC `task-worker.mjs` → `normaliseProductResearchTasks()` → `runTask()` → `platform_catalogue_research_queue` (LIVE) → owner/ChatGPT review.

The UI must enqueue first. Only after enqueue succeeds does it call `platform_owner_review_catalogue_research_item(p_id, 'needs_research', p_notes)`. If enqueue fails, the candidate status is left unchanged. The new task key is unique per retry; the existing candidate and prior evidence are retained. No direct browser writes to task tables and no service-role key in the dashboard.

### Failure found and repair
- LIVE candidate `b94e2225-c07b-4001-8dfa-cd045bf962fd` (Creality K1) was changed to `needs_research` at 16:38:30 UTC.
- The old production handler called only `platform_owner_review_catalogue_research_item`; the task queue had no new task row. The brief button flash was therefore consistent with the handler's actual behaviour.
- The correction was merged to `production` in PR #268 as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`. It also retains the owner review gate and requests `uk_both` so both new and used evidence can be sought.
- Production worker remains unchanged; it already polls LIVE and claims tasks. One controlled task was claimed/completed and a handover/completion message was confirmed in `platform_ai_agent_messages`.
- Cloudflare LIVE deployment and browser acceptance of the corrected button remain pending. Do not claim the fix is live until the dashboard asset is deployed and a new task appears after clicking Research again.


## Category source expansion — 7 November 2026
LIVE source registry change: seven sources added exclusively to `3d-printers-equipment`: Gumtree UK (marketplace, used_uk), Uni3Dverse (used_dealer, used_uk), 3DGBIRE (used_dealer, used_uk), SecondHand.org.uk (marketplace, used_uk), 123-3D UK (retailer, new_uk), iDig3DPrinting UK (retailer, new_uk), 3DFLO UK (retailer, new_uk). Existing universal Amazon UK and eBay UK remain shared sources. Verified site evidence supports Gumtree's live used printer ads, SecondHand's 3D printer listings, Uni3Dverse's dedicated used/refurbished page, 3DGBIRE's reconditioned listings, and the three new retailer catalogues. Current worker source probing selects at most 12 approved sources, round-robins new/used/official buckets, and probes at most three URL patterns per source; social platforms are not yet a proven direct-evidence path. Before broad rollout, test each source's actual search route, exact-model discovery, product-page fetch, and extraction. Correct Creality's fixed K1 detail-page search template so it does not repeatedly revisit one product. Manufacturer matching is already constrained by `isRelevantApprovedSource()`; keep Canon camera tasks mapped to Canon sources and DJI drone tasks mapped to DJI sources.

Follow-up LIVE source additions, 7 November 2026: added Bambu Lab UK Official Store (`bambu-lab-uk.myshopify.com`) and Anycubic UK Official Store (`uk.anycubic.com`) as `manufacturer`/`official`, each assigned only to `3d-printers-equipment`. The category now resolves to 14 enabled UK sources when the two existing universal sources are included: 3 manufacturer official sources, 5 specialist new retailers, 2 used/refurbished dealers, 3 used marketplaces (including eBay), and 1 universal Amazon retailer. Important implementation constraint discovered in production worker: `probeApprovedResearchSources()` currently selects at most 12 sources and tries at most three URL patterns per source. The 3D-printer category now has 14 sources, so the worker cap can silently prevent some designated sites from being probed. Increase/replace this cap with a fair, observable source sweep before claiming all 14 are searched. Also correct Creality's K1-only `search_url_template`. Social sources (e.g. Facebook Marketplace) remain a separate discovery capability; do not treat login-gated/social post snippets as validated price evidence.

## First-agent rollout: 3D Printers & Equipment website playbooks and Common Room inbox — 7 November 2026
- A first category-specific website playbook has been added at `tools/tradeflow-gemma-agent/src/source-playbooks.mjs`, exclusively for `3d-printers-equipment`. It defines manufacturer, new-retailer, used/refurbished dealer and marketplace routes/navigation for Creality, Bambu Lab, Anycubic, Uni3Dverse, 3DGBIRE, 3D Prima, 123-3D, iDig3DPrinting, 3DFLO, 3DJake, Gumtree, SecondHand.org.uk, eBay UK and Amazon UK.
- Rule: search/category/collection pages are discovery only. Gemma must extract exact-model links, open individual product/listing pages, and validate model/package, UK GBP price, condition and availability before returning evidence. Accessories, consumables, upgrades, mismatched variants, sold/completed listings and unverified social snippets are not evidence.
- `probeApprovedResearchSources()` now uses website-specific routes, ignores a stale configured direct `/products/...` URL as a search route, and no longer caps the balanced category source sweep at 12. The 3D-printer source count can exceed 12; all category-approved sources are now included in the balanced new/used/official rotation. Up to five site-specific routes are attempted per source. Source attempts and route failures are reported through progress telemetry.
- The first Common Room inbox/reply behaviour is scoped only to `3d-printers-equipment`. The Research PC worker checks the LIVE Common Room at startup, before this agent's tasks, and while idle between queue polls. It replies to the owner's first-visit welcome message, acknowledges unanswered owner instructions, and drafts concise answers to unanswered questions with local Ollama. Replies are linked by `parent_message_id`, and existing replies are checked to avoid duplication. The existing worker still passes relevant owner/agent instructions into the extraction context; hard-coded evidence rules and owner approval gates remain authoritative.
- This does not yet enable automatic Common Room replies for other categories. Roll out one agent at a time after acceptance testing the 3D-printer agent.
- Updater now downloads/tests `source-playbooks.mjs` and `source-playbooks.test.mjs` alongside the existing worker files. No private `.env`, legacy GearCashOut config, Supabase schema, TEST tenant data, LIVE catalogue/evidence approval, Stripe or Cloudflare configuration was changed by this code branch.
- Deployment remains pending: merge the reviewed branch, run the updater on the Research PC using the existing TradeFlow install and exact existing TradeFlow `.env` path, stop the old worker cleanly, restart, then verify the 3D Printer Gemma greeting is posted as a threaded reply to the owner's Welcome message. Do not claim the behaviour is live until that round-trip is visible in AI Common Room.
- Known follow-up after acceptance: verify each website route against live pages, record per-site success/failure, improve pagination/load-more handling where needed, then enable the next category agent. Social-platform discovery remains a separate capability and must not be represented as implemented by this first rollout.


## 3D printer playbook route verification correction — 7 November 2026
- Live web inspection confirmed Gumtree UK uses the `gumtree.com/uk/srpsearch%2B...` route and its individual advert pages use `/p/...`; its `.com` host therefore needs an explicit UK-source allowlist entry, while evidence still must show GBP and a direct active UK advert.
- Confirmed the official Anycubic UK store has moved to `uk.anycubic3d.com`; the old `uk.anycubic.com` site stated its transition ended 15 October 2026. LIVE `platform_research_sources` now points to the current domain and product-search route, and the worker allowlist/playbook/tests match it.
- Confirmed Bambu Lab UK uses `bambu-lab-uk.myshopify.com`, 3DFLO is a UK retailer, Uni3Dverse has a dedicated used/refurbished catalogue, SecondHand has a dedicated second-hand 3D-printer category, and 3DGBIRE has an active reconditioned-printer collection. These routes are encoded in the first category playbook. Their actual Research PC extraction success remains pending acceptance testing.
- LIVE Creality `search_url_template` was corrected from the fixed K1 detail page to the UK search route `https://store.creality.com/uk/search?q={query}`. This prevents repeatedly treating the same K1 page as the category's search route.


## Research PC updater syntax-check failure — 7 November 2026
The first-agent updater downloaded the new source but stopped before backup/install because Node reported `SyntaxError: Invalid regular expression flags` in `src/agent.mjs` at the source-domain normalisation line inside `probeApprovedResearchSources()`. The committed line contained over-escaped slash sequences in a regex literal. Minimal correction: parse the approved source domain with `new URL()` and then normalise `hostname` with the existing `www.` removal; also correct an over-escaped whitespace regex in the nearby quoted-query normalisation. No source files were installed by the failed updater because all downloaded `.mjs` syntax checks run before backup/copy. Supabase task queue remained unchanged; no research task was created or rerun by the updater. Corrective fix is on branch `fix/gemma-3d-printer-regex-syntax-20261107` and must be merged before rerunning the Research PC updater. Preserve the user's existing TradeFlow `.env` and legacy GearCashOut configuration. Acceptance remains pending until the updater reports both test suites pass, then the worker is restarted and the 3D Printer Gemma Common Room welcome reply is observed.


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


## 7 November 2026 — Gemma 3D printer evidence extraction prompt refinement

- PR #274 merged to `production` as `7a906f696d0e25f4d977efd755234eed67e8ee6d`.
- Updated `tools/tradeflow-gemma-agent/src/agent.mjs` with an explicit evidence-extraction brief for the first 3D-printer agent. It reinforces exact manufacturer/model/package matching, printer-only versus Combo/bundle separation, UK GBP-only evidence, precise new/used/refurbished/open-box condition wording, and conflict reporting.
- Removed the contradictory instruction to omit a source when condition is ambiguous. Direct exact-model product/listing pages with missing or conflicting fields must be returned as borderline for ChatGPT inspection.
- Extraction now sends no more than three page excerpts per Ollama call (up to 2,600 characters per page), retains the existing 4,096-token context window, and raises the output allowance to 1,024 tokens. This is intended to reduce oversized prompts and truncated multi-result JSON without increasing the context setting.
- Fail-safe retention: if Gemma does not classify a fetched direct page whose title/URL matches the exact task model, the worker stages it as a borderline lead with an explicit reason rather than silently dropping it.
- Added regression tests for prompt content, package identity, source ID retention and Ollama context/output settings. GitHub Actions run 42407437564 completed successfully on the PR head; syntax checks and the Gemma task/website-playbook tests passed.
- Scope remains one agent only: category `3d-printers-equipment`, branch `3d-printers`. Existing category-specific approved-source filtering, direct-page checks and downstream evidence validation remain in place.
- No Supabase schema or catalogue data was changed. A read-only LIVE check found one existing 3D-printer branch candidate in `needs_research`; no new research task was dispatched as part of this code change.
- **Deployment/test status:** merged source code is not proof that the Research PC has been updated. The Research PC worker has not yet been updated/restarted with this merge, and no post-merge Gemma extraction run has been performed. Preserve the existing `.env`, secrets and `TRADEFLOW_GEMMA_ENV_FILE` path. Next step is update the worker, then run a small controlled set across different manufacturers and printer/package variants. Inspect verified and borderline results in the LIVE review queue; do not approve/import automatically or start another category.


## 7 November 2026 — Capture-first Gemma research handoff

- PR #277 merged to `production` as `6b5f8cd514efade38062ae34f5cee5cc25fee5ff`; CI run 42409174813 passed syntax checks and the Gemma task/website-playbook regression tests.
- The user has explicitly set the evidence ownership rule: **Gemma reports what it finds; ChatGPT decides what is relevant, accurate and usable.** Gemma must not act as an evidence-quality gatekeeper.
- `tools/tradeflow-gemma-agent/src/agent.mjs` now asks Gemma for factual observations on every supplied fetched product/listing page. The extraction response is no longer a verified-versus-borderline decision.
- The crawler's model match is deliberately broader: Combo, Max/Plus/Pro, bundles, accessories and upgrade pages containing the requested model can be retained for ChatGPT to classify. Search/category pages remain discovery-only; approved UK source/category restrictions remain unchanged.
- Every fetched page is staged in LIVE `platform_catalogue_research_queue` as an `evidence_candidate` with status `needs_research`. Observed fields are retained but are not approval-ready. No catalogue or shared evidence import is authorised by the worker.
- Captures retain up to 10,000 characters of extracted page text, exact source URL/title, Gemma observations, and every visible GBP price mention with nearby context. Multiple package prices are retained rather than silently selecting one.
- If Gemma returns malformed JSON, omits a source, or fails a batch, the worker preserves the original fetched page as a raw capture. Extraction failure must not erase research already collected.
- Ollama extraction uses two-page batches with 3,500-character excerpts; the full page capture is stored independently. Worker handovers report page captures rather than approved candidates.
- Existing queue schema supports this without migration: `evidence_type`, `observed_price`, `item_condition` and `availability` remain nullable; `needs_research` is an allowed status. No Supabase schema change was made.
- Scope: only the 3D-printer agent/category `3d-printers-equipment`, branch `3d-printers`. Do not start other category agents until the controlled test passes.
- Next: update/restart the Research PC using the existing updater (preserve its private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`), then run a small controlled batch and confirm every fetched page is staged, including multi-price bundles and extraction failures. ChatGPT will inspect the full captures and open source pages as needed before any catalogue decision.


## 7 November 2026 — LIVE 3D-printer research diagnosis and PR #278

### Current LIVE state observed
- LIVE project: gxsrajtqzdjvmceqcpgv. No TEST/LIVE data copy, source-registry edit, schema migration, catalogue mutation or evidence approval/import was performed during this diagnosis.
- Controlled task: owner-3d-printers-new-used-capture-20261107-2016. Payload contains eight product/lane subtasks: Anycubic Kobra S1, Bambu Lab A1, Creality K1 and Elegoo Neptune 4 Pro, each split into uk_new and uk_used.
- The worker claimed the task on the Research PC and renewed its task lease. During the first Anycubic subtask, page discovery/fetch reached an extraction stage with 9 pages. The worker remained alive; the earlier apparently stale status timestamp was a telemetry/progress visibility gap, not proof of a dead worker.
- Nine Anycubic Kobra S1 raw captures were staged in LIVE platform_catalogue_research_queue with status needs_research. All nine had visible GBP price mentions in raw page_capture data; zero had structured observed_price or evidence_type. They remain review-only and include standard, Combo and Max/package variants that ChatGPT must distinguish.
- The second Anycubic Kobra S1 uk_used subtask completed with 8 page candidates and 3 new staged queue records. Two of the three staged records were actually new official Anycubic pages (Kobra S1 and Kobra S1 Max bundle); the third was a refurbished Grade A Kobra S1 Combo listing from 123-3D at £370, marked backordered. This is direct LIVE evidence of new/used lane contamination. The 123-3D extraction timed out; the two official-page extractions returned JSON without a findings array. All three were retained as raw captures with visible GBP price mentions.
- At 20:40 UTC, the controlled task had 12 new captures from the batch, 0 structured observed_price, 0 structured evidence_type, and 16 total 3D-printer needs_research captures. The next subtask (Bambu Lab A1 / uk_new by payload order) was active in extraction with 14 pages; its current progress metadata showed an eBay /itm URL. Confirm against its final staged rows before counting this as another lane-leak sample.
- The raw payload on all nine records records: “Gemma returned JSON without a findings array”. Therefore the first measured loss point in this batch is after direct page fetch, at Ollama JSON-envelope parsing. The capture-first fallback preserved the pages and price mentions. Do not treat the nine as nine valid comparable prices or map them automatically to the Standard Printer package.
- The earlier task/status metadata showed an eBay challenge URL; subsequent progress showed an individual eBay /itm URL. Treat the challenge URL as a blocked discovery result, not evidence that the individual listing itself was blocked.
- Before this run, the 3D-printer review queue contained four needs_research captures (one with a structured price and three without); after the first Anycubic subtask it contained thirteen, including the nine new raw captures. These are queue counts, not accepted evidence counts.

### Confirmed production-code causes
1. Source lane leak: isApprovedSourceForTask() checked category and manufacturer, but not research_type. The category-scoped web-search domain list and direct host allow-list therefore admitted both new and used sources to either task. The approved-source probe also rotated through all lane buckets regardless of the task type.
2. Price entity mismatch: extractRelevantPageText() normalises &pound;/&#163;/&#xA3; to the text label GBP, while extractVisibleGbpPriceMentions() only matched the pound sign. Encoded prices could be absent from the structured price list.
3. Bot-challenge ambiguity: isEligibleProductPage() did not explicitly exclude known challenge/captcha routes.
4. Monitoring gap: extractBatch() emitted no progress between Ollama batches; task-worker Common Room handovers omitted the available search/page metrics and source-route failure details.
5. Extraction schema mismatch: extractBatch() accepted arrays, findings, evidence and borderline only. The first live Anycubic batch returned a valid JSON object with none of those recognised arrays. The worker correctly preserved all pages as raw fallback captures but did not produce structured observations.
6. Prompt/context budget and note ordering: the Common Room RPC selects the newest messages but returns them in ascending order. task-worker.mjs then used slice(0,10), selecting the oldest notes in that returned window; the extraction prompt also allowed up to ten notes of 1,800 characters each plus two 3,500-character page excerpts. This can crowd the existing 4k context and omit the latest owner instruction. PR #278 now selects the latest four notes, passes only the latest three into a bounded prompt, limits each page excerpt to 2,200 characters, and includes visible GBP mentions with short contexts. The complete page remains stored separately for ChatGPT. The second Anycubic used pass also recorded one Ollama request timeout and two malformed JSON-envelope fallbacks, reinforcing the need to reduce prompt size and keep per-batch progress visible. The context-budget risk is confirmed; its contribution to malformed responses/timeouts is plausible but not yet isolated as the sole cause.

### PR #278 — open, unmerged, no deployment
- Branch: feature/gemma-3d-printer-lanes-metrics-20261107.
- Changes: research-type-aware source lane filtering in the category web-search allow-list, host validator and approved-source probe; 3D-printer search-result default increased from 18 to 30 (hard maximum 30, configurable downward); GBP/HTML-entity price extraction; explicit challenge-page skip/report; recognised JSON-envelope parser with top-level shape diagnostics; per-batch Ollama progress; periodic worker heartbeat telemetry during long model calls; route/page/extraction metrics in task results, telemetry and Common Room handovers.
- Regression tests cover new/used/both lane routing, category-scoped search and host validation, 3D-only search limit, HTML pound entities, challenge routes and common Gemma JSON wrappers.
- All Gemma Research Tests runs through 42412370161 passed syntax and regression tests, including lane routing, extraction parsing, heartbeat telemetry and bounded prompt/recent-note selection.
- No Supabase schema, source registry, catalogue or evidence changes are included. The Research PC has not been updated from this branch. Do not merge or deploy without explicit owner approval and a successful controlled acceptance test.

### Post-merge acceptance plan (3D branch only)
1. Merge PR #278 only after CI and owner review.
2. Stop the current worker cleanly only after its active queue task finishes. Run the existing updater in place against the existing TradeFlow installation; preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. Do not point it at GearCashOut configuration.
3. Verify a fresh worker heartbeat and Common Room round-trip.
4. Run one small controlled new/used pair for a known printer. Confirm the new task probes only official/new retailers and the used task probes only approved used marketplaces/dealers; verify no other category is affected.
5. Confirm search result limit, source route outcomes, page discovery/fetch counts, Ollama batch progress, JSON parser success/fallback counts, GBP mentions and staged captures appear in LIVE telemetry/Common Room.
6. ChatGPT inspects source pages and all package/condition/price context. Keep every candidate at needs_research until manually reviewed. No automatic catalogue/evidence import.
