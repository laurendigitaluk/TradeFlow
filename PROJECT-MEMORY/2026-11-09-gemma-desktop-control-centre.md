# Project memory — Windows Gemma Research Control Centre

Date: 9 November 2026 (UTC)
PR: #325 — https://github.com/laurendigitaluk/TradeFlow/pull/325
Branch: feature/gemma-desktop-control-centre-20261109
Production base: e81ede671bfc03e73dc16169638011372b5b6117
Code/test head: 14da7fa38fec9a75cf95137985a49d20a2208abb
Latest code CI: GitHub Actions run #472 — passed, 92 tests, 0 failures.

## User requirement
The owner wants a Windows desktop application to control each Gemma product-research specialist independently. The background supervisor starts at Windows sign-in, remains available while idle, and processes only work arriving through TradeFlow LIVE or when the owner activates the relevant specialist from its desktop shortcut.

## LIVE source registry and website routes
- LIVE UK source registry: 119 records total, 116 enabled.
- Enabled category coverage including shared universal sources: 3D Printers 15; Gaming 17; Drones 21; Metal Detectors 13; Mobile Phones 23; Laptops 12; Cameras 24. Counts overlap because some sources serve multiple categories and universal sources are shared.
- No LIVE or TEST source registry rows were added, removed or changed by this PR.
- 3D-printer website playbook and extraction path remain unchanged.
- Gaming remains capture-only and retains PlayStation/Xbox/Nintendo branch identity rules. Its UK discovery routes now include verified category/product catalogue paths for Argos, Currys, Smyths, Very, Cash Converters, Cash Express, Xbox, PlayStation and Nintendo; Gumtree uses its UK slug search; Amazon/eBay use dedicated marketplace routes. Remaining mapped retailers use homepage discovery instead of guessed generic /search?q endpoints.
- Drones playbook now explicitly covers the registered UK dealer/distributor sources including HobbyRC, Heliguy, DJI Retail, DMTL, Leicester Drones and Quadcopters. MPB uses /en-uk; Aetha is homepage discovery; store.dji.com is skipped because it redirects to sign-in.
- Metal Detectors playbook includes dedicated Amazon/eBay routes, Regton's /metal-detectors category and homepage discovery for Spin A Disc, UK History Finders, Unearthed UK, Wolds Detecting and LP Metal Detecting.
- Mobile Phones and Cameras playbooks include the registered retailer/manufacturer domains and exact-product/variant guidance. Laptops retains the existing UK manufacturer/retailer routes.
- For approved international source domains, UK storefront validation recognises locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en. Host allowlisting still requires a registered approved source.
- Discovery pages are not evidence. Workers must follow exact product/listing links and preserve raw individual-page evidence for ChatGPT/owner review. Website blocks/403/429/redirects remain visible failure outcomes; do not bypass them or invent search endpoints.

## Desktop implementation
- Seven canonical product-research switches: 3d-printers-equipment, gaming-consoles-accessories, drones, metal-detectors, mobile-phones, laptops, cameras.
- Historic 3d-printers and gaming-consoles identities are aliases of their canonical switches. Gaming is one switch covering its console branches, not separate Xbox/PlayStation/Nintendo switches.
- Catalogue Importer remains owner-approval-gated. Release Monitor is not yet connected to the catalogue product-research queue and is not exposed as an executable switch.
- One local supervisor and one Node queue worker are used to avoid queue races and uncontrolled concurrent Ollama execution.
- Local config contains enabled keys and service state only. Existing private .env remains in its existing location.
- Per-agent queue isolation uses service-role-only RPC platform_ai_agent_claim_task_for_agents(text,text[],integer). A task is claimable only when every subtask resolves to an enabled specialist. Mixed-agent tasks remain queued until all included specialists are enabled.
- Desktop mode never falls back to the legacy generic claim RPC. If the scoped RPC is missing, worker writes requires_migration and exits safely.
- Disabling a specialist prevents new claims; a task already running is allowed to finish. Global stop is also graceful.
- Windows installer updates the existing Gemma worker via its reviewed updater, preserves .env, creates the Control Centre and seven shortcuts, and registers the supervisor at user sign-in. It refuses to overwrite an already running legacy worker.

## Preservation and deployment boundary
- PR #325 remains open and unmerged.
- Scoped-claim migration is included in the PR but is not applied to LIVE or TEST.
- No LIVE or TEST source rows, tasks, queue/review rows, catalogue/evidence rows, approvals or imports were changed by this preparation.
- No research task was queued and no Research PC install, worker restart or worker start was performed.
- No TEST data was copied to LIVE; no tenant, subscriber, Stripe or website data was changed.
- Desktop supervisor targets LIVE only. Do not point it at TEST.
- Current LIVE schema inspection found no dedicated project-memory/checkpoint table; durable project memory/checkpoints are maintained in repository files.

## Pending gates
1. Owner approval to merge PR #325.
2. After merge/approval, apply the additive scoped-claim migration to LIVE only.
3. Install from production on the Research PC. Preserve the existing .env and stop any old worker cleanly first.
4. Verify one supervisor/one worker, all enabled specialists waiting, disabled specialists not claiming tasks.
5. Run one bounded LIVE review-only acceptance task and verify the raw capture reaches the existing LIVE review queue. Do not start a broad research batch as an installation test.
6. Keep TEST separate; do not copy TEST records into LIVE.
