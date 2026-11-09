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


## Root-cause layout repair — explicit scrollbar geometry — 9 November 2026

The owner supplied another screenshot after installing the prior dedicated-scrollbar build; it still showed only Drones, Metal Detectors, Mobile Phones, Laptops and Cameras, with no visible scrollbar. The previous correction was therefore not accepted. Production source inspection identified a concrete layout weakness: the card canvas used DockStyle.Fill while the scrollbar used DockStyle.Right in the same parent; forcing scrollbar.Visible=true did not reserve a guaranteed on-screen rectangle or prevent the fill canvas from occupying/covering its area. The startup reset also depended on deferred form display/layout timing.

Production commit c0b9f980b164f7eacc76f0974e921562d9ccfe32 replaces docking for these two sibling controls with explicit bounds on every list-host resize: card canvas occupies host width minus 24 px; scrollbar is positioned in the reserved 24 px strip at the right and brought to front; both controls use the full list-host height. The scroll range is computed from the seven-card content height and actual card viewport, offset is clamped and reset to zero on form display, and layout/value-change recursion is guarded. Card positions remain based on canonical agent index. This is a UI-only correction.

The screenshot confirms the PC still displays the old broken result; the new commit has not yet been installed or visually verified on the Research PC. Do not ask for another close/reopen of the same local script. The next PC update must replace only TradeFlow-Research-Control-Centre.ps1 from production after closing the visible Control Centre. Do not rerun the installer, stop/restart the supervisor, edit config/.env, or change LIVE database/queue/evidence. Verify first card is 3D Printers, second is Gaming, all seven appear by dragging the visible scrollbar, and the last card is Cameras. Supabase TradeFlow LIVE project gxsrajtqzdjvmceqcpgv remains ACTIVE_HEALTHY; no database writes were made for this desktop UI repair.


### CI verification for explicit-bounds repair — 9 November 2026

GitHub Actions workflow `Gemma Research Tests`, run 42624656405, completed successfully for UI commit c0b9f980b164f7eacc76f0974e921562d9ccfe32. This verifies the repository's automated checks for that commit; it does not constitute visual acceptance on the owner's Windows PC. Local PC deployment and screenshot verification remain outstanding.


## Correct WinForms docking order — 9 November 2026

The latest owner screenshot showed only the last three specialists. The prior correction was wrong: Fill host SetChildIndex to the last control index makes it lay out before Top-docked controls. Correct value is index 0. A PowerShell validation error in the owner's terminal was followed by later copy commands, so output text alone did not prove validation gating. New branch `fix/gemma-control-centre-fill-dock-order-20261109` makes the one-line change; CI then merge, followed by one guarded deployment block to the PC. No worker or LIVE data changes.


## Final Research PC acceptance — 9 November 2026

The owner has now installed the merged production Control Centre script and supplied a confirming screenshot. The screenshot shows all seven canonical specialists simultaneously in a two-column grid: 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, and Cameras & Lenses. Each has its own visible Enabled checkbox and WAITING status. The toolbar reports Specialists enabled: 7 / 7 and Active research tasks: 0. The header reports the background service connected / waiting for website tasks. The separate PowerShell window shows the final guarded deployment completed with CORRECTED CONTROL CENTRE INSTALLED and a SHA256 hash.

Final production UI source was rechecked after merge: it renders cards by iterating the canonical seven-agent $Agents list, uses the two-column grid ($columns = 2), contains the correct WinForms docking order ($form.Controls.SetChildIndex($listHost, 0)), and contains neither VScrollBar nor AutoScroll. This confirms the final layout no longer depends on a scrollbar. The local backup TradeFlow-Research-Control-Centre.ps1.backup-verified was created by the final deployment block.

Root cause was the WinForms docking order: the Fill-docked list host had been moved to the wrong z-order, allowing it to claim the full client area and be overlaid by the Top-docked header/toolbar/note. The correct fix is to put the Fill host at control index 0 so the top-docked controls reserve their area first. Previous scrollbar/AutoScroll implementations and the reversed dock-order change are failed approaches and must not be reintroduced.

Acceptance is complete for the desktop display. No LIVE worker, supervisor, local agent configuration, private .env, research queue, sources, product catalogue, evidence or Supabase data was changed by this final UI repair. LIVE remains separate from TEST. The only observed runtime state at acceptance was all seven specialists enabled, zero currently active research tasks, and the background service connected/waiting; WAITING does not mean a research task is running.

Supabase LIVE schema inspection found no public project-memory/checkpoint table. The authoritative project record for this repair is maintained in the repository's PROJECT-MEMORY, CHECKPOINTS, both operating manuals, backend operations manual and diagnostic roadmap.


## Unified local control dashboard — 9 November 2026

The initial isolated-agent installer created only a text-mode Gemma Switchboard. That switchboard launches category workers but does not provide a dashboard, stop controls or updater controls. It is not a suitable ongoing management interface. The owner correctly reported that the former shared Research Control Centre does not control these independent installations; do not direct the owner back to that legacy dashboard.

A new Windows Forms dashboard is provided at `tools/gemma-agent-isolation/Gemma-Control-Centre.ps1`. The isolated-agent installer now downloads it into `C:\CTFGemma2\Gemma-Shared\Gemma-Control-Centre.ps1` and creates both `Gemma Control Centre.lnk` and a compatibility `Gemma Switchboard.lnk` that open the same single-instance dashboard. Seven rows show the independent agent, expected Git branch, local status, current task and last update. Each row has Start, Stop, Update and Logs actions. Refresh runs every 2.5 seconds.

The dashboard uses each isolated clone's own `agent.config.json`, `status.json`, `src\task-worker.mjs`, launcher and updater. Start launches only that category's local worker hidden and captures stdout/stderr in its own log folder. Stop sets only that agent's `serviceEnabled=false`; the worker checks the flag between queued tasks and finishes its active batch before stopping. It does not terminate Node or interrupt an active research task. Update is disabled while that agent's worker is running and invokes only its own `Update-Gemma-Agent.ps1` for its configured branch. Branch mismatch blocks start and update. No shared supervisor, global multi-category worker, or category-to-category code sync is introduced.

The dashboard is local Windows UI; it does not need to change Supabase schema, queue rows, source registry, evidence or credentials. The LIVE status table remains useful for remote verification, while per-agent local status files provide immediate process control. A one-instance mutex prevents duplicate dashboard windows. The installer skips existing clone folders and does not stop or overwrite running workers; it updates only the shared dashboard script/shortcuts and verifies the shared ENV pointer.

CI must parse the dashboard PowerShell script. PC installation and visible acceptance remain pending until the owner reruns the updated installer from the architecture branch after CI passes. The current independent 3D Printer worker must not be stopped merely to install the dashboard; installation is designed to leave existing workers alone.


## Installer correction — 9 November 2026

The first local run of the combined dashboard installer reached its dashboard-download step but failed because the script referenced an undefined `$RawBase` variable. This was a script defect, not a PC/network issue. Corrected production `tools/gemma-agent-isolation/Install-Gemma-Agents.ps1` to use the explicit raw GitHub URL for `Gemma-Control-Centre.ps1` (commit `54d1aee479364eb14c048e3911717f69befc16ec`). Re-running the installer is safe: the installer skips existing category clone folders, does not restart/stop workers, and refreshes the shared dashboard script and its two desktop shortcuts. The owner has not yet rerun the corrected installer; dashboard installation is still pending.


## 9 Nov 2026 — desktop dashboard header overlap recurrence

User screenshot showed top worker rows hidden behind header/toolbar in the new seven-agent WinForms dashboard. This is the known Windows Forms `DockStyle.Fill` and child z-order bug previously corrected in the legacy Research Control Centre; it is NOT missing agents or a worker process failure. Minimal production fix `ac293cd7e48bf0d334a0c3c0e14d37b32f40d4ae` adds `$form.Controls.SetChildIndex($grid, 0)` after all docked controls are added in `tools/gemma-agent-isolation/Gemma-Control-Centre.ps1`, ensuring header, toolbar and footer reserve layout space. No worker code, branches, ENV, Supabase or research queue changed. Installation of the updated dashboard script on the Research PC and visual verification of all seven rows remain pending.
