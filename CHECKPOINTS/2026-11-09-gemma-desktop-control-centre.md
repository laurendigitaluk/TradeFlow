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
