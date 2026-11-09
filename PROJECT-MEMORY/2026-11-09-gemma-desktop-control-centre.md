# Project memory — Windows Gemma Research Control Centre

Date: 9 November 2026 (UTC)
PR: #325 — https://github.com/laurendigitaluk/TradeFlow/pull/325
Production merge commit: b20123fd8f832388011589ac8e7f9e602bb98f08
Production CI run: #473 — passed (92 Gemma tests, 0 failures; PowerShell/Node syntax; Owner Dashboard JS syntax).

## User requirement
The owner wants a Windows desktop application to control each Gemma product-research specialist independently. The background supervisor starts at Windows sign-in, remains available while idle, and processes only work arriving through TradeFlow LIVE or when the owner activates the relevant specialist from its desktop shortcut.

## LIVE source registry and website routes
- LIVE UK source registry: 119 records total, 116 enabled.
- Enabled category coverage including shared universal sources: 3D Printers 15; Gaming 17; Drones 21; Metal Detectors 13; Mobile Phones 23; Laptops 12; Cameras 24. Counts overlap because some sources serve multiple categories and universal sources are shared.
- No LIVE or TEST source registry rows were added, removed or changed by this work.
- 3D-printer website playbook and extraction path remain unchanged.
- Gaming remains capture-only and retains PlayStation/Xbox/Nintendo branch identity rules. UK discovery routes cover Argos, Currys, Smyths, Very, Cash Converters, Cash Express, Xbox, PlayStation and Nintendo; Gumtree uses its UK slug search; Amazon/eBay use dedicated marketplace routes. Other mapped retailers use homepage discovery rather than guessed generic /search?q endpoints.
- Drones includes HobbyRC, Heliguy, DJI Retail, DMTL, Leicester Drones and Quadcopters alongside existing sources. MPB uses /en-uk; Aetha is homepage discovery; store.dji.com is skipped because it redirects to sign-in.
- Metal Detectors includes Amazon/eBay marketplace definitions, Regton's /metal-detectors category and homepage discovery for Spin A Disc, UK History Finders, Unearthed UK, Wolds Detecting and LP Metal Detecting.
- Mobile Phones and Cameras include the registered UK retailer/manufacturer domains and exact product/variant guidance. Laptops retains its UK manufacturer/retailer routes.
- Approved international source domains recognise locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en, while the host must still match an approved source.
- Discovery pages are not evidence. Workers must follow exact product/listing links and preserve raw individual-page evidence for ChatGPT/owner review. 403/429 blocks, redirects and sign-in pages remain failure outcomes; do not bypass them or infer evidence.

## Desktop implementation
- Seven canonical product-research switches: 3d-printers-equipment, gaming-consoles-accessories, drones, metal-detectors, mobile-phones, laptops, cameras.
- Historic 3d-printers and gaming-consoles identities are aliases of their canonical switches. Gaming is one switch covering its console branches, not separate Xbox/PlayStation/Nintendo switches.
- Catalogue Importer remains owner-approval-gated. Release Monitor is not yet connected to the catalogue product-research queue and is not exposed as an executable switch.
- One local supervisor and one Node queue worker are used to avoid queue races and uncontrolled concurrent Ollama execution.
- Local config contains enabled keys and service state only. Existing private .env remains in its existing location.
- Per-agent queue isolation uses service-role-only RPC platform_ai_agent_claim_task_for_agents(text,text[],integer). A task is claimable only when every subtask resolves to an enabled specialist. Mixed-agent tasks remain queued until all included specialists are enabled.
- Desktop mode never falls back to the generic claim RPC. If the scoped RPC is missing, worker writes requires_migration and exits safely.
- Disabling a specialist prevents new claims; a task already running is allowed to finish. Global stop is graceful.
- Windows installer updates the existing Gemma worker via the reviewed updater, preserves .env, creates the Control Centre and seven shortcuts, and registers the supervisor at user sign-in. It refuses to overwrite an already running legacy worker.

## Deployment state
- PR #325 is merged into production at b20123fd8f832388011589ac8e7f9e602bb98f08.
- LIVE RPC permission audit: function exists; service_role EXECUTE true; authenticated EXECUTE false; SECURITY DEFINER true; search_path public, private.
- TEST does not have the scoped RPC. TEST remains separate.
- No Research PC installation, worker restart or worker start has occurred. The installer is ready in production but the PC step remains for the owner.
- No LIVE/TEST tasks, queue/review rows, catalogue/evidence, approvals or imports were changed by this verification.
- No TEST data was copied to LIVE; no tenant, subscriber, Stripe or website data was changed.
- LIVE schema inspection found no dedicated project-memory/checkpoint table; durable project memory/checkpoints are maintained in repository files.

## Next steps
1. On the Research PC, open PowerShell in the existing Gemma installation folder (containing src\task-worker.mjs) and run the production installer from tools/tradeflow-gemma-desktop/README.md.
2. Stop any old manual worker cleanly with Ctrl+C before installation. Reuse the existing private .env path; never paste or disclose its contents.
3. Verify one supervisor/one worker, all seven enabled specialists waiting, and disabled specialists not claiming tasks.
4. Run one bounded LIVE review-only acceptance task and verify raw capture reaches the existing LIVE review queue. Do not start a broad research batch as an installation test.
5. Keep TEST separate; desktop supervisor is LIVE-only.
