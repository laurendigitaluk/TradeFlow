## 8 November 2026 — Launcher/test-suite mismatch corrected in PR #300

After the Research PC accepted the strict JSON schema and returned populated Bambu Lab A1 Standard fields (source TEST02, £289.00, Brand new, In stock), starting the worker failed safely: the locally retained legacy launcher ran stale `test/agent.test.mjs` and `test/collection-discovery.test.mjs`, which import the removed `combineProductResearchTasks` export. The PR updater had only replaced `src` files and did not replace the root launcher, so its own 55 source tests passed while the stale launcher gate failed. Corrected PR #300 by adding a version-controlled `Start-TradeFlow-Gemma.ps1` that runs exactly the four current source test files before starting `src/task-worker.mjs`, and updating `Update-TradeFlow-Gemma.ps1` to download, back up and install this matching launcher alongside source files, with PowerShell parser validation. GitHub Actions now syntax-checks both updater and launcher. This correction is still in PR #300 and has not been installed or deployed. Next: wait for CI on the latest PR head; if green, ask owner to run updater once (worker remains stopped), verify updated launcher is installed, then start worker and run one controlled review-only task. Do not manually delete legacy tests or bypass tests. No database, approvals, imports, or LIVE catalogue data changed.

## 8 November 2026 — Gemma output population failure and fix

Failure observed on Research PC: Ollama 0.4.14 / `gemma3:4b` accepted the strict JSON schema, returned valid JSON and one finding, but left page title and price empty although both were explicit in prompt input. Thus schema compatibility is proven but useful extraction is not. PR #300 updates schema `minLength: 1` for `page_title`, `product_identity_text`, `match_observation`; 3D printer prompt now explicitly requires page title copy, identity statement, match observation and exact copy of all supplied visible GBP price strings into `price_mentions`. Unit tests assert prompt and schema constraints. Run #251 passed all CI steps. Next gate is installing latest PR head and repeating a controlled single-page extraction; no worker restart or new queue task before output fields are populated.

## 8 November 2026 — Extraction failure recovery path

`extractBatch()` now retains the existing two-page fast path. If a 3D-printer batch fails JSON parsing, hits the output limit, or fails exact source-ID validation, it retries each page separately with a compact 1,600-character selected excerpt, strict one-page schema and 1,024-token output cap. Structured successes are retained per page; failed individual retries fall back to deterministic raw capture. The original batch error remains in diagnostics. Run #244 passed CI. Research PC install and local Ollama structured-output compatibility remain unverified; no worker restart or new task authorized.

## 8 November 2026 — Research PC path handling correction

The PowerShell prompt loop was unnecessary: screenshot shows current working directory is the existing Gemma installation and `.env` is in that same directory. Updater now uses current directory automatically when `src/agent.mjs` exists, defaults private env to adjacent `.env`, and trims surrounding quotes from explicit paths. This removes manual path entry from the normal Research PC flow. Latest CI must validate parser syntax before requesting a single launch command.

## 8 November 2026 — Research PC updater parser fault

Failure point: downloaded `Update-TradeFlow-Gemma.ps1` failed PowerShell parsing before prompting for install paths. Root cause in the PR branch was a truncated `SourceBranch` validation statement and duplicated updater body. Repair: rebuild from production updater, add a single `-SourceBranch` parameter (default production), validate the branch string, and add a PowerShell AST parser step to `.github/workflows/gemma-research-tests.yml`. The failed attempt did not install source or modify `.env`. Next gate: CI success on latest PR head, then owner runs corrected updater without `-StartWorker`; verify installed source/tests and Ollama schema acceptance before any worker restart or research task.

## 8 November 2026 — PR #300 CI and Research PC validation route

- PR #300 head `f8fe6f78ebf77c971526d650293a7f0d22951207` passed GitHub Actions run #219; source syntax, Gemma task/playbook tests and Owner Dashboard JavaScript syntax passed.
- PR remains draft/open, not merged/deployed.
- Updater `Update-TradeFlow-Gemma.ps1` in the PR branch now accepts `-SourceBranch` (default `production`) to install a specific branch. It preserves the existing dedicated install folder, backups, Node test gates, TEST/LIVE Supabase URL validation and private .env file. This enables draft-branch local validation without merging.
- Controlled next step: on Research PC, run updater with `-SourceBranch fix/gemma-3d-printer-json-reliability-20261108`, using the existing install folder and private .env path; do not use `-StartWorker`. Verify tests and Ollama schema acceptance, then report installed commit/worker heartbeat before any research task is queued.

## 8 November 2026 — LIVE benchmark and structured-output failure point

- LIVE task `owner-3d-printers-speed-benchmark-20261108-1645`: 25m 17s versus 70m 49s baseline (64.3% faster); 11 pages fetched; 7 Gemma calls; 5 JSON extraction failures. Gemma inference totalled about 1,395 seconds of 1,513 seconds aggregate subtask runtime.
- First failure is at `extractBatch()`: Ollama response content is parsed with `JSON.parse`; malformed/truncated output is caught and immediately replaced with `fallbackPageCapture()`. Current request uses `format: 'json'`, `num_ctx: 4096`, and `num_predict: 1536`; the model prompt requests many descriptive fields for two pages.
- Proposed follow-up branch `fix/gemma-3d-printer-json-reliability-20261108`: strict bounded JSON schema for printer calls; bounded field lengths and arrays; exact one-row-per-source_id validation; explicit `done_reason === 'length'` diagnostics; regression test for schema bounds.
- GitHub Actions run 42505764030 (#215) passed 54/54 tests. Next: inspect Ollama response metadata and verify schema compatibility on the installed local model, then controlled 3D-only LIVE acceptance. Do not increase output token budget blindly. Keep raw captures and deterministic GBP mentions. No approval/import. Investigate Anycubic Kobra S1 Max Combo zero eligible pages separately after extraction reliability is resolved.

# TradeFlow Gemma Research Pipeline — Diagnostic Roadmap

## 8 November 2026 — PR #298 merged

PR #298 is now merged into `production` (merge commit `3417c5dced183fedcf13a7af266c67c2dd697d0a`). GitHub Actions validation passed 53/53 tests. This is not yet installed on the Research PC and has not been runtime-benchmarked. Next: use the existing updater with the correct dedicated install folder, preserving the separate private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify installed commit/heartbeat before queuing a controlled 3D-printer batch. Do not change other agent branches or import/approval controls.


## 8 November 2026 — 3D-printer extraction performance investigation

- Baseline task `owner-3d-printers-chatgpt-evidence-batch-20261108-1315`: six product subtasks executed sequentially by `task-worker.mjs`; wall time 70m 49s; 30 individual pages discovered, 18 fetched, 18 Ollama calls, 10 extraction failures. Product-page HTTP fetches already run in groups of four. `extractBatch()` serialises Ollama calls through `ollamaExtractionQueue`; 3D extraction was one page per call.
- Search stage: `searchWebResults()` fans five query variants out to four providers concurrently (up to 20 requests per product). Approved-source probing separately executes the configured website routes in groups of four per source. These request counts are not additive wall-clock timings; stage timings are now being added to distinguish slow search/probe/fetch/model work.
- PR branch `perf/gemma-3d-printer-two-page-extraction-20261108` changes 3D extraction to two pages per Ollama call, requires a `findings` array with one result for every supplied `source_id`, limits model excerpts to 2,800 characters per page while retaining GBP amounts and compact price contexts, and adds per-stage duration metrics. Full page captures remain stored unchanged for ChatGPT.
- Files: `tools/tradeflow-gemma-agent/src/agent.mjs`; new `agent-speed.test.mjs`; `.github/workflows/gemma-research-tests.yml`; `tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1`.
- Verification gate: CI regression tests first; then explicit owner approval for the existing updater; preserve private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify worker version/heartbeat; run a small 3D-only LIVE batch and compare stage timings, structured rows, extraction failures and raw fallback retention. Do not merge/deploy or enqueue a new task before this gate.


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
- Changes: research-type-aware source lane filtering in the category web-search allow-list, host validator and approved-source probe for the 3D Printers branch only; other categories keep their existing source selection. Explicitly all-scope sources (such as Amazon UK) are available to both lanes, while 123-3D remains new_uk in LIVE and will require an owner-approved source-scope change before its refurbished pages are searched in uk_used; 3D Printers branch search-result default increased from 18 to 30 (hard maximum 30, configurable downward; other categories/branches unchanged); GBP/HTML-entity price extraction; explicit challenge-page skip/report; recognised JSON-envelope parser with top-level shape diagnostics; per-batch Ollama progress; periodic worker heartbeat telemetry during long model calls; route/page/extraction metrics in task results, telemetry and Common Room handovers.
- Regression tests cover new/used/both lane routing, explicitly all-scope dual-lane sources, category-scoped search and host validation, 3D-only search limit, HTML pound entities, challenge routes, common Gemma JSON wrappers and bounded prompt/recent-note selection.
- Gemma Research Tests run 42412711661 passed; the all-scope lane regression fixture was corrected and the subsequent lane, extraction, heartbeat and bounded-prompt checks are green.
- No Supabase schema, source registry, catalogue or evidence changes are included. The Research PC has not been updated from this branch. Do not merge or deploy without explicit owner approval and a successful controlled acceptance test.

### Post-merge acceptance plan (3D branch only)
1. Merge PR #278 only after CI and owner review.
2. Stop the current worker cleanly only after its active queue task finishes. Run the existing updater in place against the existing TradeFlow installation; preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. Do not point it at GearCashOut configuration.
3. Verify a fresh worker heartbeat and Common Room round-trip.
4. Run one small controlled new/used pair for a known printer. Confirm the new task probes only official/new retailers and the used task probes only approved used marketplaces/dealers; verify no other category is affected.
5. Confirm search result limit, source route outcomes, page discovery/fetch counts, Ollama batch progress, JSON parser success/fallback counts, GBP mentions and staged captures appear in LIVE telemetry/Common Room.
6. ChatGPT inspects source pages and all package/condition/price context. Keep every candidate at needs_research until manually reviewed. No automatic catalogue/evidence import.


## 7 November 2026 — short model identity collision guard (PR #279)

LIVE review found that the short model identifier `A1` allowed Audi A1 car pages to match Bambu Lab A1 printer research. The 3D-printer branch now requires manufacturer tokens or explicit 3D-printer context for model identifiers of two characters or fewer and rejects clearly automotive routes. Genuine generic A1 3D-printer listings remain eligible for ChatGPT review. Other categories and longer model IDs retain their existing matching behaviour. Regression tests cover the false-positive car page, genuine Bambu Lab A1 Combo, generic A1 printer page and cross-category non-interference. This is a discovery guard only: all captured evidence remains in `needs_research` until ChatGPT/owner review; no automatic approval or import.


## 7 November 2026 — 3D printer retailer route correction

- Scope: TradeFlow LIVE Gemma only, category 3d-printers-equipment, branch 3d-printers.
- The current LIVE controlled task owner-3d-printers-controlled-rerun-20261107-2225 is still running on worker DESKTOP-LVASEUB-42580. At 22:42 UTC its first Anycubic Kobra S1 / uk_new subtask had discovered and fetched seven individual pages from the Anycubic printer collection. Extraction batches 1 and 2 each returned two structured observations and zero raw fallback captures; batch 3 was still in progress. No queue writes from this active task had yet been committed.
- The same active pass exposed stale approved-source routes: 3DFLO /search?q= returned HTTP 404 and /?s= returned no matching links; iDig3DPrinting /search?search= and /search?q= returned HTTP 404 while /?s= returned no matching links; 123-3D generic /search?q= and /?s= routes returned no matching links. These failures occur before individual product-page fetching.
- Direct public-site inspection verified the correct routes: 3DFLO https://www.3dflo.com/product-category/3d-printers/; iDig3DPrinting https://www.idig3dprinting.co.uk/product-category/3d-printers/; 123-3D new collection https://www.123-3d.co.uk/collections/3d-printers; 123-3D refurbished collection https://www.123-3d.co.uk/collections/refurbished-printers.
- A second discovery-stage issue was confirmed in production code: isCollectionDiscoveryPage() recognised Shopify /collections/ and generic /categories/ paths but not WordPress /product-category/; isEligibleProductPage() also did not explicitly exclude that WordPress category path. A correct category URL could therefore be misclassified and not traversed.
- LIVE source registry was updated under the user's standing permission: 3DFLO and iDig3DPrinting now have their verified category URLs in search_url_template; 123-3D notes record both verified routes while its scope remains all. The 123-3D routes are selected by research_type in the playbook: new uses the all-printers collection, used uses the refurbished collection. This avoids deliberately probing refurbished inventory in the new lane.
- No schema change, catalogue mutation, evidence approval/import, TEST data change, secret change, Research PC update or worker restart was made. The active task had already loaded its source rows before the source-registry update, so this running task is not expected to use the new routes.
- PR #278 was merged to production at 22:13 UTC (merge commit fece19063a4101b449fa3cc120a652c9acd66d15). PR #279 remains open and unmerged, but the short-model identity guard is present in production commit 6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4; do not merge the divergent PR branch blindly.
- Proposed fix on feature branch feature/gemma-3d-printer-source-routes-20261107: lane-aware 123-3D collection routing; verified WordPress category routes for 3DFLO/iDig; explicit WordPress category discovery classification; regression tests for route isolation and following product links. CI and PR review are required before merge. No deployment or Research PC update is authorised by this checkpoint.


## Verification update — 7 November 2026, 22:46 UTC

- PR #281 is open and mergeable: https://github.com/laurendigitaluk/TradeFlow/pull/281.
- Gemma Research Tests run 42422054014 completed successfully: 35 tests passed, 0 failed, 0 skipped. The syntax checks also passed.
- Cloudflare Workers preview builds for the tradeflow and tradeflow-test services both completed successfully. The tradeflow check returned a feature-branch preview URL; these are PR previews, not a production merge/deployment.
- No merge, production deployment, Research PC update or worker restart was performed.
- The LIVE worker remains on the existing active task. At 22:46 UTC it was still in the fourth extraction batch of the first Anycubic Kobra S1 / uk_new subtask, with a renewing heartbeat/lease. Batch 3 had failed JSON parsing and its two pages were retained as raw fallback captures. No completed subtask handover or queue rows from this active task had yet been committed.
- All review captures remain unapproved and unimported. No TEST/LIVE crossover or secret changes occurred.


## 7 November 2026 — canonical source URL de-duplication

The LIVE source registry and site playbook both carry the verified 3DFLO/iDig category URLs. To avoid probing the same page twice through bare-host and www redirects, the playbook now stores the verified canonical www URLs and buildWebsiteSearchRoutes accepts absolute routes as well as relative paths. The same canonical-host treatment is used for 123-3D's new/refurbished collections. Regression coverage verifies that a configured search_url_template and its playbook route collapse to one URL. This remains confined to the 3D-printer source playbook; no other category route logic is changed.


## 7 November 2026 — ELEGOO UK new/pre-owned route coverage

- LIVE already contains the enabled ELEGOO UK manufacturer source for category `3d-printers-equipment`. ChatGPT verified the official UK FDM collection `https://uk.elegoo.com/collections/fdm-printers`: it exposes 60 products and lists the Neptune 4 Pro with GBP pricing. The official pre-owned collection `https://uk.elegoo.com/collections/pre-owned-3d-printer` exposes 27 products and includes a Neptune 4 Pro entry, but that entry is currently marked sold out. Both URLs are discovery routes only; Gemma must follow individual product pages and verify current availability.
- LIVE source notes now record both URLs. The source's current `research_scope` remains `new_uk` until the lane-specific playbook is reviewed and deployed; do not let the pre-owned route enter the used lane before that coordinated change.
- This feature branch adds `uk.elegoo.com` to the 3D-printer playbook with Shopify collection discovery and strict routes: `uk_new` → `/collections/fdm-printers`; `uk_used` → `/collections/pre-owned-3d-printer`; `uk_both` → both. Generic search fallback is disabled for this site. Sold-out individual listings must not be accepted as current used evidence.
- Regression tests verify the three lane route sets and confirm both collection pages are discovery pages, not direct product evidence.
- This is confined to the 3D Printers source playbook. No catalogue/evidence import, approval, task enqueue, TEST/LIVE data copy or secret change is included.
- PR #281 remains open and unmerged. Do not merge/deploy or widen the LIVE source scope until owner review and the Research PC/runtime route acceptance test.


## 7 November 2026 — ELEGOO UK host eligibility guard

- The official storefront is hosted on `uk.elegoo.com`, which is not covered by the generic `.co.uk`/UK-path check. Without an explicit allow-list entry, the verified FDM and pre-owned collection pages and direct product pages would be rejected by `ukHost()` even though the site displays GBP and explicitly ships to the United Kingdom.
- The 3D-printer UK source-host allow-list now includes `uk.elegoo.com`. Regression coverage includes an individual Neptune 4 Pro product URL, plus the new/used collection discovery routes; collections remain ineligible as direct product evidence.
- The source registry remains `new_uk` until the lane-specific playbook is reviewed/deployed. No used-lane activation, catalogue approval/import, TEST/LIVE crossover or secret change is included.


## Verification update — 7 November 2026

- Added `uk.elegoo.com` to the explicit UK 3D-printer source-host allow-list; without this, the .com subdomain would fail the UK host check despite its GBP/UK storefront.
- Added ELEGOO lane-specific collection routing and tests for new, used and combined tasks, collection discovery-only classification, and direct Neptune 4 Pro product-page eligibility.
- Focused Node.js checks for the eight route/host assertions passed: 8 passed, 0 failed. The last available GitHub Actions run for PR #281 (42422365717) passed 35/35 before the ELEGOO additions; a new CI run covering these additions has not yet been observed. PR remains open and unmerged.
- LIVE ELEGOO source scope remains `new_uk`; the used collection is recorded but intentionally not enabled for used-lane research until after reviewed/deployed route code.

## 7 November 2026 — post-PR #281 LIVE review and schema-safe follow-up

### Current release and source routing
- Production head at the start of the follow-up: bae3c4145bc0fd78de9ac803e81cd9077ba0c930. PR #278 and #281 are merged. Production source playbooks include dedicated 3DFLO and iDig WordPress printer-category routes, 123-3D new/refurbished collections, and ELEGOO FDM/pre-owned collections.
- LIVE source registry: 3DFLO and iDig are new_uk; 123-3D is all; ELEGOO remains new_uk. The ELEGOO used collection is present in code but not eligible while the source scope is new_uk. Do not widen it before the Research PC has the reviewed route-aware worker.

### Latest genuine 3D research and loss point
- No active/pending 3D printer task exists. Latest genuine task owner-3d-printers-controlled-rerun-20261107-2225 completed 8/8 at 22:54:46 UTC: 31 search results, 13 product pages discovered, 8 fetched, 5 Gemma calls, 2 extraction failures, 8 captures and 8 duplicate skips; 0 new review rows.
- Previous run owner-3d-printers-new-used-capture-20261107-2016 completed 8/8: 123 search results, 83 pages discovered, 51 fetched, 27 Gemma calls, 20 extraction failures, 51 captures, 15 duplicate skips and 36 unique rows staged.
- Latest source errors include eBay HTTP 403 on used item pages, 404s on Amazon and old retailer routes, and 3DFLO timeouts. The new route definitions were merged after the controlled task had loaded its source rows; the Research PC has not yet been updated, so these routes remain unverified on the local runtime.
- LIVE queue: 40 rows (30 uk_new, 6 uk_used, 4 uk_both); 3 top-level prices, 1 evidence type, 1 reviewer marker, 0 approved, 0 imported, 0 enriched. The first confirmed post-extraction loss remains duplicate handling: five structured Anycubic observations and three other captures were duplicate-skipped.

### LIVE schema correction to the enrichment proposal
- Actual queue review columns are reviewed_by, reviewed_at, approved_at and imported_at. There are no approved_by or imported_by columns. The original PR #282 SELECT and PATCH filters referenced both nonexistent columns and would fail against LIVE PostgREST.
- PR #284 replaces the stale enrichment proposal on the current production base. It uses only verified columns; exact category/branch/product/package/source identity; status needs_research; raw_payload.review_classification=unverified_capture; null actual review markers; and updated_at optimistic concurrency.
- Only raw_payload.enrichment_history, research_notes and updated_at are patched. Top-level observed_price, evidence_type, condition, availability, status, reviewer notes, approval/import fields and catalogue records remain unchanged. Enriched records count as staged for ChatGPT review; evidence_queued still counts only new unique rows.
- Regression tests cover append-only enrichment, reviewer/approval/import safeguards, exact identity mismatch, repeated history, actual LIVE schema columns and new/enriched staged counts.

### Telemetry identity and heartbeat interpretation
- Sigma lens task owner-sigma-105-dg-dn-macro-art-new-used-20261107-2332 carried category_slug=lenses and branch_slug=photography-lenses but supplied agent_key=3d-printers-equipment. The previous worker trusted the supplied key and attributed two lens subtasks to the 3D status counter (49 to 51). PR #284 resolves only this mismatch to the explicit category.
- The 3D status row is idle with current_task null and last_error null. Its 23:31:38 UTC heartbeat was refreshed by the misattributed lens task. The worker emits status heartbeat during active claims, not idle polling; the stale idle timestamp cannot establish whether the Research PC process is online.
- PR #284 includes five identity tests and adds that test file to the explicit GitHub Actions workflow.

### Safety and next action
- No queue/source/catalogue data, approval/import state, task queue, TEST data, secrets, local .env, Research PC installation or runtime was changed. No duplicate task was queued.
- PR #284 is open and unmerged. After CI/review and explicit owner approval, install the reviewed worker in place, preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE, verify the PC process/Ollama, then run one small 3D-only acceptance batch. Do not start another task before that acceptance step.
- PR #279 was also closed as redundant after verifying that its short-model-ID guard and Audi A1/Bambu A1 regression test are already present in the current production branch.


## 8 November 2026 — exact 3D-printer model and package matching

- LIVE queue inspection found Creality K1 task captures from K1 Max pages and K1 accessory/upgrade URLs. The previous discovery matcher deliberately accepted sibling model names and package/accessory references for broad ChatGPT review, but those pages were being written under the requested Standard Printer task identity.
- The 3D-printer matcher now rejects sibling model suffixes (Max, Plus, Pro, Ultra, Neo, Mini, SE, MK2/MK3 and V2/V3) when they are not part of the requested model; rejects printer accessories, replacement parts and upgrades; and enforces Standard versus Combo/AMS/ACE/CFS/multicolour package matching. A task for the exact sibling model or Combo package remains eligible.
- This is limited to category `3d-printers-equipment`, branch `3d-printers`. Other catalogue categories retain their existing matching behaviour. Short-model manufacturer/3D-printer disambiguation remains in place.
- Regression tests cover K1 versus K1 Max, standard versus Combo, valid exact K1, accessory/upgrade rejection and exact K1 Max task acceptance.
- No LIVE queue rows, source registry, catalogue data, approvals/imports, task queue or TEST data were changed. No Research PC update, worker restart or deployment has occurred. Run CI and then deploy the reviewed agent to the Research PC before the next controlled task.


## 8 November 2026 — Research PC updater compatibility

- The current production `task-worker.mjs` imports `agent-identity.mjs` and the identity resolver has a dedicated regression test. The previous PowerShell updater source-file allow-list did not include either file; running that updater against the current worker would leave the new import missing locally and omit its tests.
- The updater is corrected to download, back up and install `agent-identity.mjs` and `agent-identity.test.mjs`, and to run the identity test suite both before installation and after installation.
- Existing safeguards remain: validate the private .env targets without printing values; preserve the .env file; install only reviewed src files; back up existing source; run syntax/tests before replacing files; no Supabase schema/data changes.
- This updater correction must be merged before asking the Research PC to update. Then run the production updater in place, verify the worker heartbeat, and only then queue the next controlled 3D-printer search task.


## 8 November 2026 — concatenated Combo URL identity correction

- Controlled LIVE acceptance task `owner-3d-printers-exact-identity-acceptance-20261108-0032` showed the official Creality UK URL `/products/essential-combok1-max-hyper-pla-2` was captured under the K1 Max Standard task. Its title identified `K1 Max + PLA*2(White+Red)` and the page showed £599.00; this is a bundle, not the standalone Standard Printer.
- Root cause: URL tokenisation split punctuation but did not restore the missing boundary between `combo` and the following model token in concatenated Shopify slugs (`combok1`). The package detector therefore failed to see the Combo marker even though the title/path contained the model identity.
- Minimal fix: restore a token boundary after `combo` (and concatenated AMS/ACE/CFS labels) before exact model/package matching. Keep sibling-model rejection and standard-vs-combo enforcement unchanged. Add a regression fixture for the exact Creality URL/title so it is rejected from the K1 Max Standard task; the matching Combo task remains eligible.
- This is limited to the 3D-printer branch. It changes no source allow-list, task dispatch, queue row, approval/import state, catalogue data, TEST data, credentials or Research PC runtime. Existing updater already includes `agent.mjs` and `source-playbooks.test.mjs`.
- Validation required: run the Gemma research workflow and full Research PC updater tests, merge only after green CI, then rerun a small K1/K1 Max Standard-vs-Combo acceptance test. Review captured page text and exact package labels; no automatic approval/import.



## 8 November 2026 — post-update LIVE acceptance and regression-fixture correction

- The latest completed 3D-only LIVE task was `owner-3d-printers-exact-identity-acceptance-20261108-0032` (00:32:26–00:47:00 UTC), with eight subtasks: 85 search results, 15 individual product pages discovered, 6 fetched, 6 captured, 4 Gemma extraction calls and 2 extraction-batch failures. It staged 4 new unverified queue rows and enriched 2 existing unreviewed rows; no evidence was approved or imported.
- The short-model guard is working: Bambu Lab A1 / Combo used research found 9 search results, but all 9 were Audi A1 car URLs rejected at `model_variant_skipped`; 0 product pages, captures or queue writes resulted. The Bambu A1 Standard used pass found one page but it was blocked at fetch (HTTP 403).
- Exact K1 Max new research exposed the still-open Combo-slug fault: `/products/essential-combok1-max-hyper-pla-2` was captured under K1 Max / Standard Printer with title `K1 Max + PLA*2(White+Red)`, visible £599.00. The same URL now exists in two unreviewed queue rows, one incorrectly attached to K1 Standard and one to K1 Max Standard. Both remain `needs_research`; no queue correction or approval was made.
- The first PR #287 regression assertion used the base K1 task. The existing sibling-model guard rejected K1 Max before package matching, so that assertion did not isolate the reported Combo-vs-Standard defect. The test has been corrected to use the exact K1 Max Standard task (must reject) and the exact K1 Max Combo task (must accept) against the same captured URL/title. This directly exercises the concatenated `combok1` boundary and package decision.
- Latest worker status is idle with no active/pending 3D task. Its last heartbeat is 00:47:00 UTC (65 minutes old at inspection); Supabase does not prove the Research PC process is currently online while idle. Do not queue another task until the PR is reviewed/merged and the local worker's current state is verified.
- Source routing still records 32 approved-route errors across 114 route attempts, plus 9 direct product-page fetch errors. Main blockers include Bambu official Shopify and Amazon route 404s, 3DFLO timeout, eBay HTTP 403, Uni3Dverse and SecondHand HTTP 404, and 123-3D direct listing 404/redirects. Do not bypass access controls.
- Queue now contains 44 3D-branch rows: 3 top-level prices, 2 enrichment histories, 1 reviewed marker, 0 approved and 0 imported. All new captures remain unverified review material.


### Verification note — exact package matcher smoke test
- Ran six focused assertions against the current PR branch matcher: K1 rejects K1 Max sibling; K1 Max Standard rejects the exact `essential-combok1-max-hyper-pla-2` bundle; K1 Max Combo accepts that same URL/title; standalone K1 Max remains accepted; Audi A1 car is rejected; genuine Bambu A1 Combo printer listing is accepted. Result: **6/6 passed**.
- This is a focused matcher smoke test, not the full repository suite. GitHub Actions run 42433260646 passed before the strengthened K1 Max Standard/Combo fixture was committed. A new CI run for the corrected test commit has not yet been observed; do not merge until it passes.


### Legacy false-positive queue items — manual review required
- LIVE still contains two older Bambu Lab A1 / Standard / Used rows sourced from Audi A1 car adverts: Gumtree Stratford at £2,150 (row `86cdd9e5-4b1d-47e9-9aaa-3d2ae4b57f74`) and Narberth at £11,300 (row `a4ca1777-3887-4b4e-bfa5-9ef76e27400c`). Their page titles and `/cars-vans-motorbikes/cars/audi/a1/` URLs confirm they are not 3D-printer evidence. Both remain `needs_research`, unreviewed, unapproved and unimported. The updated A1 guard rejected all 9 Audi URLs in the latest controlled run, but it does not retroactively clean these older rows. Leave them for explicit ChatGPT/owner review; do not auto-delete, approve or import them.


## 8 November 2026 — scheduled LIVE verification at 02:00 UTC

- Current LIVE status for category `3d-printers-equipment`, branch `3d-printers`: idle, no active or pending task. Latest task `owner-3d-printers-exact-identity-acceptance-20261108-0032` completed 8/8 subtasks from 00:32:26 to 00:47:00 UTC.
- Aggregate metrics: 85 search results; 15 product pages discovered; 6 fetched and captured; 4 Gemma extraction calls; 2 extraction failures; 114 approved-source route attempts; 32 route errors; 55 empty routes; 27 routes with matches; 40 opposite-lane source skips. Four new review rows were queued and two existing unreviewed rows enriched.
- New lane: 32 searches, 7 discovered, 5 fetched/captured. Used lane: 53 searches, 8 discovered, 1 fetched/captured. The used-page loss remains at fetch: eBay listing requests returned HTTP 403 and other configured routes returned 404. No access-control bypass was attempted.
- New-lane failures include Bambu Lab UK Shopify and Amazon HTTP 404, 3DFLO timeout, 123-3D redirect to an ineligible page and 3D Prima HTTP 404. The two Gemma extraction failures occurred after page fetch; raw captures were retained.
- LIVE review queue now has 44 rows: 34 `uk_new`, 6 `uk_used`, 4 `uk_both`; 3 top-level observed prices, 2 append-only enrichment histories, 1 reviewer marker, 0 approvals and 0 imports. All rows remain `needs_research`.
- The concatenated Creality slug `/products/essential-combok1-max-hyper-pla-2` is still incorrectly present as K1 Max Standard at £599.00. A second legacy K1 Standard row also references the same Combo URL. No queue rows were modified.
- Worker status row is idle, with no error. Its last heartbeat is 00:47:00 UTC; the task-worker source only sends its heartbeat timer during an active claim, so an old idle heartbeat does not prove the PC is offline or online. The current Research PC process/Ollama state remains unverified.
- PR #287 head `4c9c220fcb01066a56b2735db77c8aa0040ab9af` is still open and mergeable. GitHub Actions run **42436325135** completed successfully at 01:55 UTC: **45 tests passed, 0 failed**, including task-group, source-playbook and agent-identity suites plus syntax checks. No review submissions or review threads are present. The strengthened fixture tests the exact K1 Max Standard rejection and K1 Max Combo acceptance against the same captured URL/title.
- This green CI result supersedes the earlier checkpoint statement that a run for the corrected fixture had not yet been observed. It verifies the PR branch only; it does not verify the Research PC installation or LIVE runtime. Do not merge, deploy, update the PC or queue another task without explicit owner approval and the required local updater/worker verification.
- No task, queue, source registry, catalogue, TEST data, approval/import state, secret, private .env or Research PC runtime was changed during this scheduled check. No new research task was queued.


## 8 November 2026 — 3D Printer deep-page extraction repair (PR #292)

### Confirmed first failure point
- LIVE platform_catalogue_research_queue, category 3d-printers-equipment: 44 needs_research evidence-candidate rows.
- 1 row had a top-level observed_price; 43 had evidence_type = null.
- raw_payload.evidence.uncertainty_and_conflicts counts: 21 Gemma returned JSON without a findings array; 14 The operation was aborted due to timeout; 2 malformed/truncated JSON outputs; 4 non-product/miscategorised observations; 3 rows with no extraction issue string.
- Search and fetch were not the only issue: the fetched page text was preserved, but buildExtractionPrompt() supplied only item.text.slice(0, 2200) to Gemma. Relevant prices and package options later in the product page were not in the model input.

### Proposed 3D-only repair
- buildDeepPageExcerpt(text, task, maxChars=6200) composes bounded excerpts from the page opening, all visible GBP price contexts (up to 12), task identity/package terms, condition/availability phrases and the page tail.
- extractionBatchSizeForTask(task) returns 1 only for 3d-printers-equipment / 3d-printers; other agents retain batches of 2.
- 3D prompt requests one compact JSON observation object for the one supplied page, rather than a findings array for multiple pages. It instructs Gemma to capture machine-only, Combo, colour-count and bundle prices separately and never choose a package price.
- If Gemma fails, fallbackPageCapture() records deterministic 3D observations: visible GBP prices and context, package/variant snippets, condition wording, availability wording, UK/location clues, plus the complete fetched page. A single top-level price is retained only when unique; multiple prices remain contextual observations and are not guessed.
- All output remains needs_research / unverified. No approval/import path changed. Other categories keep existing prompts and batching.

### Validation and deployment
- Regression tests cover deep-page excerpt selection, one-page 3D calls, unchanged non-3D two-page batching, factual single-object prompt, structured fallback and multiple-price preservation.
- GitHub Actions run 42477880080: 50 passed, 0 failed.
- PR #292: https://github.com/laurendigitaluk/TradeFlow/pull/292, branch fix/gemma-3d-deep-page-extraction-20261108, base production; open, not merged.
- No LIVE/TEST database rows, source registry, catalogue, local secrets, Research PC files/process or Cloudflare deployment changed.
- Post-merge acceptance: use existing updater in place; preserve the dedicated TradeFlow .env and TRADEFLOW_GEMMA_ENV_FILE; verify worker version/heartbeat; run one controlled new and one used multi-model 3D-printer batch; inspect structured observations and raw page captures; ChatGPT manually validates all candidates. Do not import automatically.


Post-merge status (8 November 2026): Owner approved PR #292. Merged to production as `65730838d5f32cbf923973d5a32a87f8454a0c07`. Pull-request CI passed 50/50 tests. Production push CI run `42478484235` was queued/in progress at checkpoint update. Research PC source has not yet been updated; no LIVE worker restart has occurred.

## 2026-11-08 — Explicit Gemma price-observation contract (PR #302)

The 3D-printer extraction contract now represents every visible GBP amount as a separate `price_observations` item. Each item contains the exact displayed price, nearby source context, product/variant association, price role, condition and availability. Gemma must not associate a price with the requested product based only on proximity; uncertain associations remain `ambiguous` for ChatGPT review. The JSON schema and downstream consumer now agree on the allowed fields. The worker cross-checks every reported amount against deterministic GBP observations extracted from the fetched page. It only sets `observed_price` when exactly one source-verified observation is explicitly associated with the requested product; otherwise it leaves the price unset. This remains an unverified review capture, never an approval/import decision.

Scope is limited to category `3d-printers-equipment`, branch `3d-printers`. PR #302 is draft and not merged or deployed. No Research PC installation, worker restart, LIVE task, TEST/LIVE data mutation, source registry change, approval or import has occurred. CI and historical-capture replay remain required before installation.


## 8 November 2026 — PR #302 CI finding and context-verification correction

The first PR #302 CI run (#272) failed one legacy assertion in `agent-speed.test.mjs`: it still expected the retired `price_mentions` prompt field. The other 55 tests passed, including the new observation-schema checks and PowerShell/source syntax checks. Updated that assertion to the new contract. During review of the actual downstream consumer, found that price verification matched only the numeric amount against the page, not the observation's nearby context. Tightened the prompt to require exact copying of the supplied context and changed the consumer to require both the exact extracted GBP amount and an exact normalised match to the deterministic page-context excerpt before setting `source_context_verified` or selecting `observed_price`. Also corrected the GBP parser to accept both £ and GBP values. Latest branch head: `31963483347c3287f5d770831ad324af1712a1cd`; latest CI result not yet available. PR remains draft and unmerged. No Research PC, Ollama runtime, LIVE/TEST database, task queue, approvals or imports changed. Historical capture replay remains the next acceptance gate after CI passes.
