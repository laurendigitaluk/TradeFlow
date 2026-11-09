# TradeFlow Research Control Centre (Windows)

The Control Centre is a Windows desktop application for the existing TradeFlow Gemma Research PC installation. It is designed to be installed alongside the current worker, not as a replacement for the Research PC environment.

## What it controls

Seven product-research specialists are available as independent switches:

- 3D Printers & Equipment
- Gaming Consoles & Accessories
- Drones
- Metal Detectors
- Mobile Phones
- Laptops & Computers
- Cameras & Lenses

The historic `3d-printers` and `gaming-consoles` agent identities are treated as aliases of their canonical specialist switches. The Catalogue Importer remains owner-approval-gated. The Release Monitor is a separate capability and is not yet connected to the product-research queue; neither is exposed as an executable product-research switch.

## Runtime design

There is one persistent local queue supervisor and one Gemma/Ollama execution lane. Each specialist has its own enabled/disabled setting, but the app does not start seven competing Node processes. This avoids multiple workers racing for the same queue and avoids uncontrolled concurrent Ollama requests.

- Windows Task Scheduler starts the supervisor at user sign-in.
- The supervisor connects to TradeFlow LIVE only.
- The worker reads the local enabled-agent configuration before each queue claim.
- The new service-role-only `platform_ai_agent_claim_task_for_agents` RPC claims a task only when every subtask belongs to an enabled specialist.
- A disabled specialist cannot claim new work. If it is disabled during a running task, that task is allowed to finish before the worker stops claiming it.
- If no specialists are enabled, the worker remains idle and claims nothing.
- Desktop shortcuts use Windows Script Host (`wscript.exe`) to run a small hidden launcher, which starts PowerShell with no visible console. The launcher enables its corresponding specialist and opens the single Control Centre; it does not create another research worker.
- Closing the Control Centre window does not stop the background service.
- Stopping the global service lets the current task finish, then stops the worker.
- A missing agent-scoped RPC is a hard stop. The worker does not fall back to the old unscoped queue claim.

## Website research configuration

The existing LIVE source registry is retained; this change does not duplicate source rows. At the 9 November 2026 audit it contained 119 records in total: 116 GB-coded and 3 US-coded; all 119 were enabled. UK category coverage (including shared universal sources) was:

| Category | Enabled sources |
|---|---:|
| 3D Printers & Equipment | 15 |
| Gaming Consoles & Accessories | 17 |
| Drones | 21 |
| Metal Detectors | 13 |
| Mobile Phones | 23 |
| Laptops | 12 |
| Cameras | 24 |

Counts overlap because some sources serve multiple categories and universal sources are shared.

The 3D-printer playbook and extraction path are unchanged. Gaming retains its capture-only handoff and console-branch identity rules; its UK retailer and console-manufacturer discovery routes have been completed. Dedicated website navigation and exact-product rules are included for drones, metal detectors, mobile phones, laptops and cameras. Routes are discovery only: Gemma must follow matching product links to individual pages and capture the raw page evidence for ChatGPT review. No autonomous approval or catalogue/evidence import is introduced.

## Installation gate

The agent-scoped claim RPC is now present in TradeFlow LIVE and has been verified as service-role executable and unavailable to authenticated users. TEST remains separate and does not have this RPC. If the LIVE RPC is ever missing, the worker stops with a `requires_migration` status and does not use the legacy unscoped claim.

The PR is merged and the LIVE scoped-claim RPC is present. The Research PC has not yet been installed or restarted. The existing private `.env` remains in its original location and is never copied, printed or overwritten by the installer.

## Install from production

Open PowerShell in the existing Gemma installation folder (the folder containing `src\task-worker.mjs`) and run:

```powershell
$Installer = Join-Path $env:TEMP 'Install-TradeFlow-Research-Control-Centre.ps1'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/laurendigitaluk/TradeFlow/production/tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1' -OutFile $Installer
powershell -ExecutionPolicy Bypass -File $Installer
```

The installer detects the current folder and adjacent `.env` where possible. If the private `.env` is stored elsewhere, it asks for its existing path. It first runs the reviewed Gemma updater and tests, then installs the desktop app under `%LOCALAPPDATA%\TradeFlow\ResearchControlCentre`, including the hidden `Launch-TradeFlow-Control-Centre.vbs` launcher, registers the logon task, and creates one Control Centre shortcut plus seven specialist shortcuts targeting `wscript.exe` rather than PowerShell directly.

If an old manual `task-worker.mjs` process is already running, the installer refuses to overwrite the active worker. Stop that process cleanly with Ctrl+C and rerun the installer. It never terminates an active research task.

## Local files

- `config.json`: service enabled flag and specialist switches; contains no credentials.
- `service.json`: existing Gemma install path, private environment-file path and LIVE environment name; contains no credentials.
- `status.json`: local runtime status for the desktop UI.
- `logs\`: supervisor and worker stdout/stderr logs.


### Control Centre display and specialist status

The current desktop UI displays the seven canonical specialists in a single vertical, scrollable list. Each row shows the specialist name, its live local state, and an individual Enabled checkbox. The toolbar shows the enabled-specialist count and active research-task count. States are explicit: RUNNING, WAITING, DISABLED, SERVICE STOPPED, BACKEND UPDATE REQUIRED, or ERROR. Enabled means eligible to claim matching new work; it does not mean a task is currently running. One supervisor and one worker serve all seven switches.

If updating an existing PC that already has the hidden VBS launcher and corrected shortcuts, update only TradeFlow-Research-Control-Centre.ps1; do not rerun the full installer merely to update the UI, because the full installer also invokes the Gemma worker updater. Close the visible Control Centre window (this does not stop the background service), replace the local UI script from the production branch, then reopen the existing Control Centre shortcut. Verify seven named rows and statuses. Keep the Windows default terminal preference on Windows Console Host on machines where Windows Terminal captures hidden PowerShell sessions.
