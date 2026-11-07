# Project memory — AI Agent Common Room — 7 November 2026

The user wants a shared workspace for Gemma specialist agents and ChatGPT supervisory workflows to communicate, learn from one another, inspect work and receive owner instructions. The owner must be able to view the same persistent message history.

Branch: `feature/ai-agent-common-room-20261107`.

Implemented: LIVE message-table migration; owner-authenticated list/post RPCs; service-role-only agent list/post RPCs; owner dashboard room with thread/category/message filters and compose; Gemma worker room read/post integration; manuals/roadmap/checkpoint updates.

LIVE migration applied to `gxsrajtqzdjvmceqcpgv`. Verified table exists, RLS on, no direct anon/authenticated table policies, owner RPC authenticated access, agent RPC service-role-only. No messages were seeded.

Worker change preserves `TRADEFLOW_GEMMA_ENV_FILE` and loads its separate `.env`. Do not overwrite that PC environment file or expose its service-role credentials.

Not yet deployed: branch is not merged; dashboard not yet verified in Cloudflare LIVE; Research PC not yet updated/restarted. Full instruction-read → handover-post → owner-visible round-trip remains pending. No claims that the Common Room is live/operational until this test succeeds.

Messages are not tasks, evidence approval, catalogue imports or valuation inputs. Owner instructions are separate from the Gemma queue. Candidate evidence remains subject to owner/ChatGPT review.

Documentation updated in branch: System Handbook, Human User Manual, Backend User Manual, AI Operating Manual, Subscriber Website Manual, Backend Operations Manual and Gemma Research Pipeline Diagnostic Roadmap. How It Works stays source-managed in `how-it-works.html` / `how-it-works.css`; Examples remains CMS-editable.

 
## Follow-up implementation — 7 November 2026
The Gemma worker now passes up to ten bounded Common Room instruction/handover/finding/question/learning notes into the Ollama extraction prompt. The prompt treats them as untrusted operational guidance and preserves all hard-coded product identity, approved source, evidence validation and review constraints. This closes the previous gap where the worker read and logged notes without supplying them to Gemma.

The Owner Dashboard has nine consistent native collapsible sections, including the Common Room and Gemma Control Centre; overview metrics remain visible and sidebar anchors expand the matching section. Owner Dashboard diagnostic roadmap added at docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-OWNER-DASHBOARD.md.

The Subscriber Website Manual now reflects the central TradeFlow AI model: subscribers do not add their own AI provider. The System, Human, Backend User, AI Operating and Backend Operations manuals have current-position sections at the top. How It Works remains source-managed; Examples remains CMS-editable.

Still pending: PR #267 merge/release, Cloudflare LIVE deployment/browser acceptance, Research PC code update/restart and an end-to-end Common Room message round-trip. Preserve the local .env and TRADEFLOW_GEMMA_ENV_FILE path.

 
## Recipient and thread routing correction — 7 November 2026
A code review identified and corrected two delivery gaps before release: Gemma was reading only the General thread, and dashboard recipients gemma-task-worker/research-agents did not match the worker's agent identity. The worker now reads across all threads; the list RPC includes global category-null messages plus matching category messages; recipient routing supports all/*, exact agent key, worker ID, gemma-task-worker and research-agents. ChatGPT-only messages are not sent to Gemma.

LIVE migrations 20261107160000_fix_common_room_agent_routing and 20261107161000_fix_common_room_research_group_routing applied. The final agent-list RPC uses an empty search_path and checks the service_role JWT role claim; verified anon and authenticated cannot execute it, service_role can, and no temporary test messages persisted. PC update/restart and round-trip test are still pending.

 
## Owner feed loading and refresh — 7 November 2026
- The Common Room feed now loads after an existing owner session is validated and after a new owner sign-in.
- The feed refreshes alongside the Gemma Control Centre while the dashboard tab is visible, and can also be refreshed manually.
- Gemma reads across threads and receives instructions, handovers, findings, questions and learning notes; status-only chatter is not injected into the research extraction prompt.
- ChatGPT supervisor messages are a session-driven capability, not an always-running background ChatGPT process. The schema reserves the supervisor sender type, but a persistent ChatGPT worker/integration is not deployed.


## Public How It Works content refresh — 7 November 2026
- Updated the source-managed public page in how-it-works.html (ten native accordion sections; the separate Catalogue & AI Research navigation menu is not counted as a content accordion).
- Rewrote the catalogue research explanation to describe the central TradeFlow AI Research Centre, specialist Gemma agents, category-approved UK websites, exact product matching, UK-new/UK-used evidence and ChatGPT/Platform Owner review before import.
- Clarified that subscribers use TradeFlow's centrally operated research capability and do not connect their own AI provider.
- Clarified the manual shipping model: the customer pays the selected carrier directly; TradeFlow does not collect shipping charges or book courier services.
- Replaced the obsolete GearCashOut public example panel with a link to TradeFlow Examples. The published page remains source-managed; no legacy How It Works CMS record is used.


## Shipping responsibility documentation correction — 7 November 2026
- Corrected the current shipping architecture in the System Handbook, Human User Manual, AI Operating Manual, Backend User Manual, Backend Operations Manual, Subscriber Website Manual and public How It Works page.
- The customer pays the selected carrier directly. TradeFlow does not collect shipping charges, add postage to the accepted buying offer, pay the carrier or book courier services. The subscriber configures supported services and manages the handoff; subscriber or customer may upload label/QR as the handoff requires; the customer adds tracking and confirms dispatch; the subscriber confirms physical receipt.
- The earlier 21 September 2026 statement that the subscriber paid shipping is now explicitly marked superseded in the Human User Manual.


## Final Common Room RPC hardening — 7 November 2026
- Applied four additive LIVE routing/security migrations after the base Common Room schema: two for thread/recipient routing, one for agent-post RPC hardening, and one for owner RPC hardening.
- Verified all four SECURITY DEFINER RPCs now use an empty search_path.
- Owner list/post RPCs: anon=false, authenticated=true, service_role=false; each checks auth.uid() against an active platform_memberships row.
- Agent list/post RPCs: anon=false, authenticated=false, service_role=true; each validates the service_role JWT claim.
- RLS remains enabled on platform_ai_agent_messages; anon/authenticated direct table SELECT remains denied; no Common Room messages are seeded.


## Subscriber manual publication cleanup — 7 November 2026
- The subscriber-website-manual.html had internal historical/test notes appended after the main subscriber guide, including Adventure Outpost sign-in and payment test details and a TEST/LIVE runtime implementation note. These were not appropriate subscriber-facing instructions.
- Removed the internal/test-only appendages from the published subscriber manual, retained the useful SEO instructions as a properly styled section 14 inside the manual, and added the current customer-paid shipping section 13.
- The subscriber manual now ends cleanly at </body></html> with no trailing internal text and has an explicit 7 November 2026 last-updated marker.

 
## Production merge and Research PC updater — 7 November 2026
PR #267 merged to production as 45049f5c4a1b131d95b701b2603fe0a351c392bd. Post-merge review found task-worker.mjs referenced a missing task-groups.mjs module. Fixed the worker import and added task-groups.mjs plus task-groups.test.mjs. Four Node built-in tests passed for non-array inputs, malformed entries, deduplication and preserving distinct product/package/category/branch/agent/research-type tasks.

Added tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1 and README.md. The updater downloads only reviewed source/test files, validates the supplied private .env against approved TEST/LIVE project URLs, runs syntax checks and tests before installation, backs up existing source files and replaces only the dedicated src folder. It never prints, copies, backs up or overwrites the .env and sets TRADEFLOW_GEMMA_ENV_FILE to the exact supplied path. It supports first install into a separate dedicated TradeFlow folder.

The updater has not been run on the Research PC. Its real path, Ollama service, worker startup and Common Room round-trip remain unverified. No Cloudflare deployment was made; this repo has no GitHub Actions deployment workflow and no Cloudflare connector is available in the current tool connections.

 
## Queue task validation refinement — 7 November 2026
The task normaliser now rejects incomplete payload rows before calling runTask. It requires category_slug, manufacturer, model, package_key, package_name, search_query and a research_type of uk_new, uk_used or uk_both. The Owner Dashboard's production task builder supplies these fields. Tests cover incomplete payload rejection as well as valid rows, malformed rows, duplicate removal and preservation of distinct task definitions. Four tests pass.

 
## Confirmed Research PC local paths — 7 November 2026
- Existing TradeFlow worker folder: `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent`.
- Existing TradeFlow private environment file: `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent\.env`.
- The existing folder contains the TradeFlow .env; the updater should run in-place and explicitly pass that same .env path.
- Do not use, modify or overwrite the separate legacy `C:\GearCashOut-Config\.env`, GearCashOut source folders or old launcher.
- The current update command is documented in tools/tradeflow-gemma-agent/README.md. Local update/restart has not yet been performed.


## Research Again repair — 7 November 2026
LIVE verification showed the background worker is functioning: task `owner-3d-printers-equipment-1794069178464` completed once and posted task-start, handover and completion messages. The Creality K1 candidate remains unapproved in the LIVE research queue. The Research Again click changed its status to `needs_research` but did not create a task. Root cause: production `reviewGemmaCandidate()` called only the review RPC. Repair branch `fix/gemma-research-again-enqueue-20261107` now enqueues a new exact-product `uk_both` task through the existing owner enqueue RPC before updating review status. PR #268 merged to production as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`. The change also corrects the misleading `TEST_REVIEW_QUEUE` result label on the LIVE insert path. No DB schema/data or PC secrets changed. PR #269 also merged the dashboard HTML cache-bust to `platform-owner-dashboard.js?v=27` as `fa14ebaad62039b413962a09a466bc7d36b92912`. Cloudflare deployment and browser acceptance are pending.


## LIVE source registry update — 7 November 2026
Added seven UK 3D-printer sources to LIVE only, all scoped exclusively to `3d-printers-equipment`: Gumtree UK and SecondHand.org.uk as used marketplaces; Uni3Dverse and 3DGBIRE as used/refurbished dealers; 123-3D, iDig3DPrinting and 3DFLO as new-price retailers. Existing universal Amazon UK and eBay UK remain in place. These are registry records only; the worker's ability to discover/fetch/extract valid exact-model pages from each site remains to be tested. Agreed strategic pattern for all category agents: manufacturer-specific official sources matched to product manufacturer (Canon→Canon, DJI→DJI), category-designated new and used specialist sites, universal Amazon/eBay and bounded social-marketplace discovery. Do not classify a social post as price evidence unless a public direct listing supplies exact model, UK GBP price, condition, availability and URL. No TEST source rows changed.


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
