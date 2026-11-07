# Checkpoint — AI Agent Common Room — 7 November 2026

## Branch
`feature/ai-agent-common-room-20261107`, based on current `production`.

## User intent
Provide a shared persistent workspace for Platform Owner, ChatGPT supervisory work and Gemma specialist research agents to exchange instructions, handovers, findings, questions, learning notes and status messages. Owner must be able to inspect the same conversation/history and post instructions.

## Implemented in this branch
- Added `public.platform_ai_agent_messages` migration with RLS enabled and direct anon/authenticated table grants revoked.
- Added owner-authenticated list/post RPCs protected by active `platform_memberships`.
- Added service-role-only agent list/post RPCs. Agents cannot post the `instruction` type; instructions are owner-authored.
- Added Owner Dashboard Common Room section with thread/category/recipient filters, message history and owner compose.
- Added Research PC worker integration: startup status, task status, handover, completion/failure posts and shared message/instruction reads.
- Updated System, Human, Backend User, AI Operating and Subscriber manuals; Backend Operations Manual; Gemma research diagnostic roadmap.
- Added documentation that How It Works is source-managed rather than edited via the dashboard CMS. Examples remains dashboard-editable.
- Updated Owner Dashboard manual links and Common Room navigation.

## LIVE migration
Migration `20261107190000_platform_ai_agent_common_room.sql` applied successfully to LIVE project `gxsrajtqzdjvmceqcpgv`.

Read-only checks:
- messages table exists.
- RLS enabled and no direct anon/authenticated policies.
- anonymous cannot execute owner or agent RPCs.
- authenticated can execute owner list RPC, which validates active platform membership.
- authenticated cannot execute agent RPCs.
- service_role can execute agent list/post RPCs.
- No message rows were seeded; no TEST business data copied.

## Safety boundaries
- Common Room messages are not research queue tasks, product evidence, evidence approvals, imports, valuation inputs or subscriber/customer messages.
- Research findings remain staged for owner/ChatGPT validation; no automatic catalogue/evidence write is introduced.
- Service-role key is used only by the Research PC/server process and must never be exposed to dashboard/browser code.
- Preserve the Research PC's dedicated `.env` and original `TRADEFLOW_GEMMA_ENV_FILE` path during its update.
- TEST Supabase is `nnsshnfkjcflucjrftzi`; LIVE is `gxsrajtqzdjvmceqcpgv`. Retired TEST project `twfbmjwwqzxdxvclxbun` is forbidden.

## Not yet completed / release gates
- PR not yet merged/released.
- Cloudflare production dashboard asset deployment not yet verified.
- Research PC has not been updated or restarted with the new worker code.
- Owner instruction → worker read → worker handover → owner-visible message round-trip not yet tested.
- No desktop/mobile authenticated browser acceptance.
- Do not describe Common Room as fully operational until the round-trip passes.

## Next actions
1. Review and merge the feature PR.
2. Confirm Cloudflare LIVE worker serves current dashboard HTML/CSS/JS.
3. Update Research PC code only, preserving local environment configuration.
4. Restart the persistent worker; confirm fresh LIVE telemetry.
5. Post a limited owner instruction and verify worker read and handover post.
6. Confirm owner dashboard can read the returned message.
7. Run one small research batch and confirm existing candidate review gate is unchanged.

 
## Follow-up implementation — 7 November 2026
- Gemma now passes up to ten bounded Common Room notes (instructions, handovers, findings, questions and learning notes) into the Ollama extraction prompt.
- The prompt labels Common Room notes as untrusted operational guidance and explicitly prevents them overriding exact task identity, research type, category-approved source restrictions, UK/GBP/direct-product-page rules, evidence validation, privacy and review gates.
- The owner dashboard now has nine consistent collapsible sections, including the new Common Room and Gemma Control Centre. Overview metrics remain visible; sidebar hash navigation opens the matching panel.
- Added the Owner Dashboard Developer Diagnostic Roadmap.
- Updated the five owner-linked manuals plus Backend Operations and Subscriber Website Manual. Removed the old statement that subscribers could connect their own AI provider; TradeFlow AI research is centrally operated.
- Worker code is committed but the Research PC has not been updated/restarted. The instruction → worker prompt → handover → owner-visible round-trip remains pending.
- Cloudflare deployment and authenticated browser acceptance remain pending. PR #267 is still the combined release candidate.

 
## Recipient and thread routing correction — 7 November 2026
A source review found that the first worker version only read the General thread and did not match the dashboard's research-group/gemma-worker recipient labels. This has been corrected before release:
- Worker reads across all Common Room threads, not just General.
- Category-specific reads include global messages with a null category as well as matching category messages.
- Recipient routing now supports all/*, the exact agent key, worker ID, gemma-task-worker and research-agents. ChatGPT-only messages are not delivered to Gemma.
- Additive LIVE migrations 20261107160000_fix_common_room_agent_routing and 20261107161000_fix_common_room_research_group_routing have both applied successfully.
- The agent-list RPC now pins an empty search_path, validates the service_role JWT claim, revokes public/anon/authenticated execution and grants execution only to service_role.
- Post-migration SQL verification confirmed anon=false, authenticated=false, service_role=true and search_path empty. No test messages remain in the LIVE table.
- This fixes the routing logic at source/database level; the PC worker still needs updating/restarting and the full end-to-end round-trip remains pending.

 
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


## Research Again defect and correction — 7 November 2026

### Verified LIVE findings
- Controlled LIVE task `owner-3d-printers-equipment-1794069178464` was claimed once and completed without a worker error.
- Common Room contains task-start, handover and task-completed messages for that task; the handover reports one candidate staged for owner review.
- Candidate `b94e2225-c07b-4001-8dfa-cd045bf962fd` is a Creality K1 UK-new candidate from the official Creality UK product page at £299. It remains `needs_research`; it was not approved/imported.
- At 16:38:30 UTC the owner clicked Research again. LIVE row changed to `needs_research`, but no new `platform_ai_agent_tasks` row appeared.

### Root cause
Production `platform-owner-dashboard.js` → `reviewGemmaCandidate()` called only `platform_owner_review_catalogue_research_item()`. It had no call to `platform_owner_enqueue_ai_agent_task()`. The status change worked; dispatch never occurred. The worker/polling path was not the failure.

### Repair branch
`fix/gemma-research-again-enqueue-20261107` (based directly on production).
- Research Again now resolves the candidate from the loaded LIVE queue.
- Builds one exact-product `uk_both` task using the existing worker payload contract.
- Enqueues through the existing authenticated owner RPC first.
- Only after enqueue succeeds, marks the candidate `needs_research` through the existing review RPC.
- Refreshes candidate and task lists. Existing candidate/evidence rows are retained; no schema migration or service-role browser access is added.
- Corrects the LIVE queue result label in `agent.mjs` from `TEST_REVIEW_QUEUE` to `LIVE_REVIEW_QUEUE` for the actual LIVE insert path; no data routing is changed.

### Release/verification state
- PR #268 merged to production as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`.
- PR #269 merged the dashboard asset cache-bust to `platform-owner-dashboard.js?v=27` as `fa14ebaad62039b413962a09a466bc7d36b92912`.
- Cloudflare deployment and browser acceptance remain pending.
- No Supabase schema or data changes were made for this repair.
- Next: source/static validation, review PR, deploy LIVE dashboard asset, click Research again once, confirm a new queued task and automatic worker completion, then verify new candidates remain pending review.


## LIVE source registry update — 7 November 2026
After the Gemma Research Again worker test, LIVE `platform_research_sources` was expanded with seven category-specific 3D-printer sources: Gumtree UK, Uni3Dverse, 3DGBIRE, SecondHand.org.uk, 123-3D UK, iDig3DPrinting UK and 3DFLO UK. New/used scopes are separated and all seven have only `3d-printers-equipment` in `category_slugs`. Amazon UK and eBay UK remain existing universal sources. No TEST rows were copied and no schema, worker code, secrets or evidence approvals were changed. Source presence is not yet proof of fetch/extraction success. Follow-up: validate each source route; correct Creality's K1-only search URL; design a reusable category/source matrix for all agents, with manufacturer-specific official sources (e.g. Canon→Canon, DJI→DJI), designated new/used retailers, shared Amazon/eBay, and carefully bounded social discovery.

Follow-up LIVE source additions, 7 November 2026: added Bambu Lab UK Official Store (`bambu-lab-uk.myshopify.com`) and Anycubic UK Official Store (`uk.anycubic.com`) as `manufacturer`/`official`, each assigned only to `3d-printers-equipment`. The category now resolves to 14 enabled UK sources when the two existing universal sources are included: 3 manufacturer official sources, 5 specialist new retailers, 2 used/refurbished dealers, 3 used marketplaces (including eBay), and 1 universal Amazon retailer. Important implementation constraint discovered in production worker: `probeApprovedResearchSources()` currently selects at most 12 sources and tries at most three URL patterns per source. The 3D-printer category now has 14 sources, so the worker cap can silently prevent some designated sites from being probed. Increase/replace this cap with a fair, observable source sweep before claiming all 14 are searched. Also correct Creality's K1-only `search_url_template`. Social sources (e.g. Facebook Marketplace) remain a separate discovery capability; do not treat login-gated/social post snippets as validated price evidence.