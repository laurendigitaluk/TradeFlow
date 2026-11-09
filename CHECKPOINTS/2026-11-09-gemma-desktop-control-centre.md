# Checkpoint — Gemma Desktop Control Centre (9 November 2026)

## Production baseline
- Production branch: production
- Merge commit: b20123fd8f832388011589ac8e7f9e602bb98f08
- PR #325: merged
- Production CI run #473: passed all steps, including 92 Gemma tests (0 failures), PowerShell syntax, Node syntax and Owner Dashboard JavaScript syntax.
- LIVE Supabase: gxsrajtqzdjvmceqcpgv
- TEST Supabase: nnsshnfkjcflucjrftzi

## Implementation
- Windows Control Centre and seven specialist shortcuts under tools/tradeflow-gemma-desktop.
- One sign-in background supervisor and one queue worker/Ollama execution lane.
- Seven switches: 3D Printers, Gaming Consoles, Drones, Metal Detectors, Mobile Phones, Laptops, Cameras. Gaming is one switch for PlayStation/Xbox/Nintendo branches; legacy agent keys are aliases.
- Desktop config is local and contains no credentials. Existing private .env path is reused and not copied, printed or overwritten.
- Worker claims through service-role-only platform_ai_agent_claim_task_for_agents(text,text[],integer). Every subtask must belong to an enabled agent. Desktop mode has no fallback to the legacy unscoped claim.
- Disable prevents new claims; active task finishes. Global stop is graceful. Missing RPC stops with requires_migration.
- Installer refuses to overwrite an active worker and creates the supervisor scheduled task plus Control Centre and seven specialist shortcuts.

## Website configuration
- LIVE registry: 119 source records total (116 GB-coded and 3 US-coded; all 119 enabled). Category coverage including universal sources: 3D Printers 15, Gaming 17, Drones 21, Metal Detectors 13, Mobile Phones 23, Laptops 12, Cameras 24.
- No LIVE or TEST source registry rows changed.
- 3D-printer playbook/extraction unchanged. Gaming capture-only handoff unchanged; verified UK retailer/console discovery routes are included.
- Drones, Metal Detectors, Mobile Phones and Cameras have complete source-domain playbooks; Laptops routes retained.
- Approved international source hosts recognise UK locale path segments uk, gb, en-uk, en_uk, en-gb, en_gb and gb-en while requiring an approved source host.
- store.dji.com is skipped because it redirects to sign-in. Discovery pages are not evidence.

## Database verification
- LIVE scoped RPC exists.
- service_role can execute; authenticated cannot execute.
- SECURITY DEFINER is enabled; search_path is public, private.
- TEST scoped RPC is absent and TEST remains separate.
- No LIVE/TEST queue, source, catalogue, evidence, approval or import rows were changed by this verification.

## Installation status
- Production installer is ready at tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1.
- Research PC installation has NOT occurred. No local worker was stopped, restarted or installed by this verification.
- Existing private .env remains untouched on the PC.
- No dedicated project-memory/checkpoint table was found in the LIVE schema; repository docs/checkpoints are the durable record.

## Next steps
1. On the Research PC, open PowerShell in the existing Gemma folder containing src\task-worker.mjs.
2. Run the production installer command in tools/tradeflow-gemma-desktop/README.md. If an old manual worker is active, stop it cleanly with Ctrl+C first.
3. Verify supervisor and seven switches; all seven are enabled by default and wait for matching LIVE work. Disable any specialist as required.
4. Run one bounded LIVE review-only acceptance task and confirm raw capture reaches the existing LIVE review queue. No automatic approval/import.
5. Keep TEST separate; desktop runtime is LIVE-only.

 
### Live worker snapshot before Research PC installation — 11:57 UTC
The LIVE `platform_ai_agent_status` and activity records show one generic TradeFlow Gemma task worker connected and idle, polling every 15 seconds. The queue currently contains 24 completed tasks and no queued/running tasks. This is the existing legacy worker, not the new desktop supervisor. The installer will refuse to overwrite it while active. When installing on the Research PC, stop the existing worker cleanly with Ctrl+C first; do not terminate an active task or force-kill the process.


## Shortcut correction — pending PC update

Owner screenshot confirmed duplicate dashboard windows and visible PowerShell consoles from specialist shortcuts. Production fix committed:
- `af867edd067422adfd8a371cecb4f939ae231268`: single-instance named mutex in the Control Centre UI.
- `a1376bbefde726543b47606064f60486fbafea0d`: hidden PowerShell window style on main and specialist shortcuts.
- Existing dashboard refreshes shared agent config every three seconds, so a shortcut can enable a specialist without opening another dashboard.
- New CI run was not yet visible at checkpoint time; do not claim the fix has passed CI.
- Research PC has not yet received these updated files/shortcuts. Stop the service after current task, rerun production installer from the existing Gemma folder, then verify one dashboard/no console.


## Final launcher correction — 9 November 2026

The extra tab was identified by the owner as `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`, confirming a second PowerShell console session. The earlier `-WindowStyle Hidden` shortcut option was not sufficient in the owner's Windows Terminal environment.

Production installer now downloads `Launch-TradeFlow-Control-Centre.vbs`; all eight shortcuts target `wscript.exe`, which launches the PowerShell WinForms UI invisibly (WScript.Run window style 0). Specialist arguments are forwarded to the same script. The named mutex continues to enforce one dashboard, and the single scheduled supervisor/worker is unchanged.

The Research PC installation shown by the owner was performed before this WScript-host correction. It must be rerun after safely stopping the background service. CI has not yet reported a workflow run for this latest launcher change; do not describe it as CI-verified.


## 9 November 2026 — LIVE 3D-printer capture and route-scope correction (PR #327)

Scope is limited to LIVE category `3d-printers-equipment`, branch `3d-printers`. Production base for this repair: `1b76e6e4dfb56c32049171741cb00499ab6946a1`.

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

### PR #327 — current-production repair
- Branch: `fix/gemma-3d-capture-and-model-route-scope-20261109-current-base`.
- PR: https://github.com/laurendigitaluk/TradeFlow/pull/327
- Code/test commit: `ef2de8dd825b995c28bfe02a4ee4243fb321cc26`; base is current production `1b76e6e4dfb56c32049171741cb00499ab6946a1`.
- CI run #484 (ID `42620594593`) passed all workflow steps: PowerShell updater syntax, Node source syntax, Gemma/website playbook tests and Owner Dashboard JavaScript syntax.
- Structured 3D-printer Gemma output and final review handoff now retain the full fetched page up to the existing 100,000-character fetch limit. Gaming keeps its existing full-page capture; other categories remain capped at 10,000 characters.
- Regression fixture: previous structured path retained 10,000 / 40,642 characters (24.6%); corrected path retains 40,642 / 40,642 (100%), recovering 30,642 characters.
- Creality Ender-3 V3 collection route is now model-specific: Ender-3 V3 tasks retain it; K1/K1 Max tasks no longer probe that unrelated family route.
- PR #324 contains the earlier version of the full-page fix but is based on the older `e81ede...` production base and is now stale/unmergeable. PR #327 is the current-production replacement. Do not merge/deploy without explicit owner approval.

### Review queue and source registry
- Exact branch review queue: 65 rows (28 imported, 37 rejected, 0 open). Linked active shared evidence: 23 `uk_new` and 5 `uk_used`; all 28 are GBP-priced.
- Audit exception: 27/28 imported rows lack `reviewed_by`; 8 imported rows also lack `reviewed_at`; all 37 rejected rows lack `reviewed_by`. Queue `evidence_type` is null on 64/65 rows, while the linked shared evidence retains the 23-new / 5-used classification. Do not backfill identities or alter review decisions without owner direction.
- LIVE has 13 category-specific 3D-printer sources (4 used_uk, 5 new_uk, 3 official, 1 all) plus two universal marketplaces (Amazon/eBay). ELEGOO remains `new_uk`; PR #323's proposed used-lane scope change is not merged. No source registry row changed.
- LIVE migration `20261109115602_gemma_agent_scoped_task_claim` is present; the scoped claim function is SECURITY DEFINER with service_role EXECUTE and authenticated EXECUTE denied. TEST does not have this RPC and remains separate.

### Safety and acceptance
- No task was queued or duplicated; no worker was restarted by this watch; no database row, source registry, review status, catalogue evidence, approval or import was changed.
- No TEST data was read/copied into LIVE. Private `.env` files and secrets were not accessed or changed.
- After review/explicit approval, install the approved production worker on the Research PC without overwriting the private `.env`; verify scoped desktop mode and inspect local supervisor/worker logs. Only then run one bounded 3D-printer review-only acceptance task. No automatic approval or catalogue import.
