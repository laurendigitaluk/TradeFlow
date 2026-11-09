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


## Seven-agent display correction — 9 November 2026

After the WScript shortcut correction, the owner confirmed the black console stopped appearing when Windows default terminal was changed to Windows Console Host. The Control Centre remained open and reported Background service connected / waiting for website tasks. The Gaming shortcut reached the existing Control Centre without creating a second dashboard.

Local diagnostics confirmed seven canonical definitions and all seven canonical keys enabled. The local active-agent list was empty at inspection, so none was actively processing at that moment. LIVE status contains historical alias rows; these are not additional desktop specialists. LIVE queue and evidence data were not changed.

Production UI script update: commit c720c245fed72174957a1a2d93fed5fc3e9668f8. It changes the agent cards to a single vertical scrollable list, uses explicit status wording, labels each checkbox Enabled within the named specialist card, and adds enabled/active counts. This preserves the one-instance mutex, three-second config/status refresh, shared config, single supervisor and single worker.

PC deployment is pending. Do not run the full installer for this UI-only update. Close the visible Control Centre only (background service remains running), replace the local TradeFlow-Research-Control-Centre.ps1 with the production file, then reopen the existing Control Centre shortcut. Acceptance checks: all seven named cards visible by scrolling; each checkbox toggles only its own canonical key; enabled count matches config; active count/status matches local status; no new console; scheduled supervisor remains the same.


## Owner screenshot: clipped first two cards and no scroll — 9 November 2026

Owner screenshot after the first UI update showed only five cards (Drones through Cameras); 3D Printers and Gaming were not reachable, and vertical scrolling did not work. The issue was isolated to the FlowLayoutPanel layout in the narrow side-by-side window. Production UI commit 55bba312db21fe1e0a667a4c38cd82d63cad2add replaces it with a standard AutoScroll Panel, explicit card Y positions, computed AutoScrollMinSize and responsive card widths. This is a UI-only change; no worker or LIVE data touched. PC update and screenshot acceptance are still pending. Replace only the local UI script; do not rerun the full installer or stop the service.


## Dedicated scrollbar correction — 9 November 2026

The owner reported no visible change after installing the Panel AutoScroll build and reopening the Control Centre. The second attempt is not accepted as fixed. Production now uses a dedicated vertical scrollbar and manual card positioning, with calculated scroll range and resize handling; a follow-up commit corrects VScrollBar range ordering and guards programmatic ValueChanged recursion. Commits: 1871ec0d062377ff5fff96fedbfa45eda9e828a7 and ab2df7866072b0e21d69db5fd4522e18613ba610. Local PC update and visual acceptance still pending. Do not ask for repeated close/reopen until the updated script has been copied. UI-only update; leave background worker and LIVE data untouched.
