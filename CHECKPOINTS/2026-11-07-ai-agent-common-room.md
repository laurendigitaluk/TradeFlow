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
