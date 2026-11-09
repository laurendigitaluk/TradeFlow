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


## 9 November 2026 — seven-specialist Control Centre display correction

The Research PC shortcut repair is now applied locally: all seven desktop specialist shortcuts target `wscript.exe` and preserve their canonical `-AgentKey` values. The Windows default terminal preference was changed by the owner from Windows Terminal/Let Windows decide to Windows Console Host; the recurring black terminal window then stopped appearing. The visible Control Centre remained open and reported the background service connected / waiting for website tasks.

Local read-only diagnostics confirmed:
- `agents.json` contains all seven canonical specialists: 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, Cameras & Lenses.
- `config.json` contains all seven canonical keys in `enabledAgentKeys`.
- `status.json` had no active agent keys at the time of inspection; this means no specialist was actively processing then, not that they were disabled.
- The local desktop supervisor action remains hidden PowerShell against `Run-TradeFlow-Gemma-Supervisor.ps1`; it was not modified.

The owner then reported that the visible Control Centre displayed only three generic “Agent enabled” checkboxes, without clear specialist names or individual running/waiting status. This is a desktop UI presentation defect. LIVE `platform_ai_agent_status` inspection shows canonical and historical alias rows (including legacy `3d-printers` and `gaming-consoles` keys); the seven local desktop switches remain the canonical set. Do not expose historic aliases as additional desktop switches.

Production UI correction committed as `c720c245fed72174957a1a2d93fed5fc3e9668f8` to `tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1`:
- Replace the multi-column wrapping card layout with a single vertical, scrollable list so all seven specialists can be found reliably on narrower or DPI-scaled displays.
- Give each card its specialist name, explicit status text, and an individual “Enabled” checkbox.
- Add an enabled-specialist and active-task count to the toolbar.
- Use explicit RUNNING, WAITING, DISABLED, SERVICE STOPPED, BACKEND UPDATE REQUIRED and ERROR states.
- Preserve the existing shared config, three-second refresh, one-instance mutex, one supervisor and one worker. No research queue, source registry, evidence, catalogue, approval/import, .env or Supabase data was changed by this UI commit.

Deployment note: the new UI script is in production but has not yet been copied to the Research PC. Do not rerun the full installer (it updates the Gemma worker). Close only the Control Centre window, download the single updated UI script to a temporary file, replace the local `TradeFlow-Research-Control-Centre.ps1`, and reopen the existing Control Centre shortcut. Closing the UI does not stop the background supervisor. Verify seven named cards, per-agent checkboxes, status labels, enabled count and active-task count before calling this complete.


## Owner screenshot: first two cards clipped; scroll correction — 9 November 2026

After installing the first vertical FlowLayoutPanel UI build, the owner showed a narrow side-by-side Control Centre window. Only Drones, Metal Detectors, Mobile Phones, Laptops and Cameras were visible; 3D Printers and Gaming were clipped above the visible card region, and the owner could not scroll. The header itself remained visible; the defect was the FlowLayoutPanel's sizing/scroll behaviour in the constrained window, not missing agent definitions or disabled configuration.

Production commit 55bba312db21fe1e0a667a4c38cd82d63cad2add replaces the FlowLayoutPanel with a standard WinForms Panel. Seven cards receive explicit vertical Y positions (108-pixel spacing); AutoScroll is enabled with AutoScrollMinSize derived from the agent count; each card anchors left/right and resizes to the viewport; initial scroll position is reset to the top. No queue, source, evidence, worker, .env, Supabase or tenant data was changed.

PC deployment is pending. Replace only the local TradeFlow-Research-Control-Centre.ps1 with the production version, after closing the visible Control Centre window. Do not run the full installer or stop/restart the background worker. Reopen the existing Control Centre shortcut and verify the first two cards are at the top, the last card is reachable at the bottom by scrolling, all seven checkboxes remain independent, and the background service stays connected.


## Second scrolling attempt failed; explicit scrollbar correction — 9 November 2026

Owner confirmed the standard Panel AutoScroll version did not change the display after closing/reopening; screenshot still showed only five cards (Drones, Metal Detectors, Mobile Phones, Laptops, Cameras). Do not ask owner to repeat the same close/reopen sequence against that build. Production UI has now moved to a dedicated VScrollBar plus a manually positioned, non-scrolling card canvas. Each card's Y coordinate is based on its canonical agent index and the scrollbar offset; the scrollbar range is derived from content overflow and viewport height; card widths recalculate on resize. Programmatic scrollbar updates are guarded against ValueChanged recursion, and LargeChange is set before Maximum. Production UI commits: 1871ec0d062377ff5fff96fedbfa45eda9e828a7 and follow-up range/guard correction ab2df7866072b0e21d69db5fd4522e18613ba610. PC deployment and screenshot verification remain pending. Replace only local TradeFlow-Research-Control-Centre.ps1. No worker, scheduled task, config, .env, LIVE queue or product/evidence data changed.


## Root-cause layout repair — explicit scrollbar geometry — 9 November 2026

The owner supplied another screenshot after installing the prior dedicated-scrollbar build; it still showed only Drones, Metal Detectors, Mobile Phones, Laptops and Cameras, with no visible scrollbar. The previous correction was therefore not accepted. Production source inspection identified a concrete layout weakness: the card canvas used DockStyle.Fill while the scrollbar used DockStyle.Right in the same parent; forcing scrollbar.Visible=true did not reserve a guaranteed on-screen rectangle or prevent the fill canvas from occupying/covering its area. The startup reset also depended on deferred form display/layout timing.

Production commit c0b9f980b164f7eacc76f0974e921562d9ccfe32 replaces docking for these two sibling controls with explicit bounds on every list-host resize: card canvas occupies host width minus 24 px; scrollbar is positioned in the reserved 24 px strip at the right and brought to front; both controls use the full list-host height. The scroll range is computed from the seven-card content height and actual card viewport, offset is clamped and reset to zero on form display, and layout/value-change recursion is guarded. Card positions remain based on canonical agent index. This is a UI-only correction.

The screenshot confirms the PC still displays the old broken result; the new commit has not yet been installed or visually verified on the Research PC. Do not ask for another close/reopen of the same local script. The next PC update must replace only TradeFlow-Research-Control-Centre.ps1 from production after closing the visible Control Centre. Do not rerun the installer, stop/restart the supervisor, edit config/.env, or change LIVE database/queue/evidence. Verify first card is 3D Printers, second is Gaming, all seven appear by dragging the visible scrollbar, and the last card is Cameras. Supabase TradeFlow LIVE project gxsrajtqzdjvmceqcpgv remains ACTIVE_HEALTHY; no database writes were made for this desktop UI repair.


### CI verification for explicit-bounds repair — 9 November 2026

GitHub Actions workflow `Gemma Research Tests`, run 42624656405, completed successfully for UI commit c0b9f980b164f7eacc76f0974e921562d9ccfe32. This verifies the repository's automated checks for that commit; it does not constitute visual acceptance on the owner's Windows PC. Local PC deployment and screenshot verification remain outstanding.
