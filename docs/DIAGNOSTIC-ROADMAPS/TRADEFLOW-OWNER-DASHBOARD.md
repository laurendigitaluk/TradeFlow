# TradeFlow Platform Owner Dashboard — Developer Diagnostic Roadmap
Updated: 7 November 2026
Status: UI layout implemented on `feature/owner-dashboard-dropdown-sections-20261107` (PR [#266](https://github.com/laurendigitaluk/TradeFlow/pull/266)); browser acceptance and deployment pending.

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
- Check stale cached CSS/JS by confirming asset versions (`platform-owner-dashboard.css?v=10`, `platform-owner-dashboard.js?v=25`).
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
This increment changes only dashboard HTML/CSS/JS, documentation and repository checkpoint files. No Supabase schema/data, RLS, Edge Functions, tenants, customers, orders, payment records, Stripe configuration, domain ownership, Research PC secrets or Cloudflare deployment are changed.
