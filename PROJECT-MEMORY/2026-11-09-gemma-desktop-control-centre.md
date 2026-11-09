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

 
### Live worker snapshot before Research PC installation — 11:57 UTC
The LIVE `platform_ai_agent_status` and activity records show one generic TradeFlow Gemma task worker connected and idle, polling every 15 seconds. The queue currently contains 24 completed tasks and no queued/running tasks. This is the existing legacy worker, not the new desktop supervisor. The installer will refuse to overwrite it while active. When installing on the Research PC, stop the existing worker cleanly with Ctrl+C first; do not terminate an active task or force-kill the process.


## Owner-reported shortcut issue and correction — 9 November 2026

Owner tested Gemma Gaming and Gemma 3D Printers shortcuts. Each opened a separate visible PowerShell console and a duplicate Control Centre window. Root cause was confirmed in production code: shortcut arguments lacked `-WindowStyle Hidden`, and the Control Centre had no single-instance guard.

Fix committed to production:
- `af867edd067422adfd8a371cecb4f939ae231268`: named per-user mutex ensures only one dashboard form.
- `a1376bbefde726543b47606064f60486fbafea0d`: main and category shortcuts now use hidden PowerShell window style.
- Category launcher updates the shared config and starts the same supervisor; if a dashboard already exists, it exits and the existing dashboard picks up the config on its three-second refresh.
- New CI run had not appeared at time of update; validation pending.
- Research PC not yet updated. Stop the service after current task and rerun production installer before retesting.


## Second PowerShell console diagnosis and correction — 9 November 2026

Owner clarified that the extra tab title is the full executable path `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`. This confirms a second PowerShell console session, not a keyboard shortcut. The previous shortcut `-WindowStyle Hidden` flag was insufficient in the owner's Windows Terminal environment.

Production now includes `tools/tradeflow-gemma-desktop/Launch-TradeFlow-Control-Centre.vbs`. The installer downloads this file and creates the main dashboard and seven specialist shortcuts with `wscript.exe` as TargetPath. The hidden VBS launcher starts PowerShell using WScript.Run window style 0, passing the UI script and optional specialist arguments. The UI remains visible as a WinForms window; the PowerShell console should not. The single-instance mutex and one background supervisor remain unchanged.

The owner installed the prior build before this launcher correction. The Research PC still needs one more installer run after stopping the service safely. No LIVE/TEST research queue, source registry, evidence, approval/import, or .env changes are required.


## 9 November 2026 — LIVE 3D-printer capture and route-scope correction (PR #326)

Scope is limited to LIVE category `3d-printers-equipment`, branch `3d-printers`. Production base for this repair: `292fe9c4ae7cf896d9568abf5cab3267597f0713`.

### LIVE task and worker snapshot
- Exactly 19 registered tasks match the category/branch, containing 56 product subtasks: 19 completed, 0 running, 0 queued, 0 failed. Latest 3D-printer task completed at 2026-11-09 01:56:42 UTC. No later 3D-printer task or review capture is recorded.
- The category status remains idle with cumulative counters 85 completed / 122 candidates; its last update is 01:56:42 UTC and still carries worker ID `DESKTOP-LVASEUB-84452`.
- Generic worker status is idle, no current task, polling every 15 seconds. Latest worker ID is `DESKTOP-LVASEUB-78412`, last status update 12:39:53 UTC. Earlier worker starts were `DESKTOP-LVASEUB-114300` at 12:34:18 and `DESKTOP-LVASEUB-116344` at 12:35:53; neither has a matching `worker_stopped` event. The desktop supervisor waits for its child and retries after 15 seconds, so these may be sequential restarts after an unclean worker exit; telemetry alone does not prove concurrent processes. Research PC `supervisor.log` and worker stderr logs are needed to identify the exit cause.
- The generic status record does not prove that the current process is running with the new desktop agent-scoped config. The LIVE scoped-claim RPC exists and is service-role-only, but local `config.json` / `service.json` are not exposed by Supabase telemetry.

### Latest completed product subtasks
- Ender-3 V3 KE, 01:55:49–01:56:09 UTC: 11 search results, 0 exact product pages discovered, 0 fetched, 0 Gemma calls, 0 captures. It attempted 28 approved-source routes: 11 route matches, 11 empty and 6 failed. Two Creality Shopify collection JSON attempts returned HTTP 404.
- K1 Max, 01:56:24–01:56:42 UTC: 11 search results, 1 page discovered/fetched, 0 Gemma calls because this task predated PR #320, 1 raw candidate, queue write `duplicate-skipped`. The existing K1 Max record already links to active LIVE UK-new evidence at £589 GBP; this was not a lost new record. It attempted 28 routes (11 matches, 11 empty, 6 failed) and one collection JSON route failed.
- The 3D-printer task history includes: 20:16 batch 123 search / 83 discovered / 51 fetched / 27 Gemma calls / 20 failures; 13:15 batch 123 / 30 / 18 / 18 / 10; 16:45 batch 104 / 21 / 11 / 7 / 5; 00:32 batch 85 / 15 / 6 / 4 / 2. The 16:45 benchmark took 25m17s versus 70m49s for the 13:15 six-product baseline, but discovery and extraction remained lossy.

### First loss point and route observations
- The first loss in the latest Ender-3 V3 KE task is search-to-exact-product-page discovery: 11 search results yielded no individual product page. Route matches are not the same as exact product pages.
- For K1 Max, the official product page was fetched successfully; its zero Gemma calls are explained by the pre-PR #320 task timing. PR #320 restored the 3D-printer `extractBatch()` path in production, but no post-merge 3D-printer runtime task exists.
- Repeated failures include Uni3Dverse HTTP 404, eBay UK HTTP 403/404, Amazon UK HTTP 404, SecondHand.org.uk HTTP 404, and Creality Shopify collection products JSON HTTP 404.
- The public Creality UK FDM collection page is accessible and currently renders 11 products, including K1 Max; the Ender-3 V3 collection renders three different models (SE, Mega, Neo). The worker's raw HTML parser found no product anchors, then its Shopify `/products.json?limit=50` fallback returned 404. The rendered web page does not prove the Research PC raw fetch can parse the same links. Do not invent an alternative endpoint; verify raw HTML and endpoint behaviour before changing it.

### PR #326 — current-production repair
- Branch: `fix/gemma-3d-capture-and-model-route-scope-20261109`.
- PR: https://github.com/laurendigitaluk/TradeFlow/pull/326
- Code/test commit: `a49413970c6576e5422688d9f8f847195cb40c75`; base is current production `292fe9c4ae7cf896d9568abf5cab3267597f0713`.
- CI run #474 (ID `42619554386`) passed all workflow steps: PowerShell updater syntax, Node source syntax, Gemma/website playbook tests and Owner Dashboard JavaScript syntax.
- Structured 3D-printer Gemma output and final review handoff now retain the full fetched page up to the existing 100,000-character fetch limit. Gaming keeps its existing full-page capture; other categories remain capped at 10,000 characters.
- Regression fixture: previous structured path retained 10,000 / 40,642 characters (24.6%); corrected path retains 40,642 / 40,642 (100%), recovering 30,642 characters.
- Creality Ender-3 V3 collection route is now model-specific: Ender-3 V3 tasks retain it; K1/K1 Max tasks no longer probe that unrelated family route.
- PR #324 contains the earlier version of the full-page fix but is based on the older `e81ede...` production base and is now stale/unmergeable. PR #326 is the current-production replacement. Do not merge/deploy without explicit owner approval.

### Review queue and source registry
- Exact branch review queue: 65 rows (28 imported, 37 rejected, 0 open). Linked active shared evidence: 23 `uk_new` and 5 `uk_used`; all 28 are GBP-priced.
- Audit exception: 27/28 imported rows lack `reviewed_by`; 8 imported rows also lack `reviewed_at`; all 37 rejected rows lack `reviewed_by`. Queue `evidence_type` is null on 64/65 rows, while the linked shared evidence retains the 23-new / 5-used classification. Do not backfill identities or alter review decisions without owner direction.
- LIVE has 13 category-specific 3D-printer sources (4 used_uk, 5 new_uk, 3 official, 1 all) plus two universal marketplaces (Amazon/eBay). ELEGOO remains `new_uk`; PR #323's proposed used-lane scope change is not merged. No source registry row changed.
- LIVE migration `20261109115602_gemma_agent_scoped_task_claim` is present; the scoped claim function is SECURITY DEFINER with service_role EXECUTE and authenticated EXECUTE denied. TEST does not have this RPC and remains separate.

### Safety and acceptance
- No task was queued or duplicated; no worker was restarted by this watch; no database row, source registry, review status, catalogue evidence, approval or import was changed.
- No TEST data was read/copied into LIVE. Private `.env` files and secrets were not accessed or changed.
- After review/explicit approval, install the approved production worker on the Research PC without overwriting the private `.env`; verify scoped desktop mode and inspect local supervisor/worker logs. Only then run one bounded 3D-printer review-only acceptance task. No automatic approval or catalogue import.
