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
