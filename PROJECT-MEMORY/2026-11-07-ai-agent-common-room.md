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