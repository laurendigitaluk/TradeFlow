# Diagnostic Roadmap — Gemma Windows Desktop Control Centre

Date: 9 November 2026
Scope: Windows Research PC desktop launcher, seven specialist switches, visible Control Centre and background supervisor. This is a diagnostic map, not a copy of implementation code.

## Expected user flow

1. Owner double-clicks one specialist shortcut, e.g. Gemma - Gaming.lnk.
2. Shortcut target is %SystemRoot%\System32\wscript.exe; arguments call Launch-TradeFlow-Control-Centre.vbs, pass the local UI script and the canonical -AgentKey, plus -EnableAgent.
3. VBS starts Windows PowerShell with window style 0. The WinForms Control Centre is the only visible app window.
4. The UI writes the selected canonical key into local config.json, enables the shared service and starts the existing scheduled supervisor if needed.
5. Named mutex Local\TradeFlowResearchControlCentre enforces one visible dashboard. Existing dashboard refreshes config/status every three seconds.
6. Scheduled task TradeFlow Gemma Research Supervisor runs Run-TradeFlow-Gemma-Supervisor.ps1 hidden. It uses the existing local Gemma installation and private .env path.
7. One Node queue worker polls TradeFlow LIVE and claims only tasks whose complete agent scope is enabled through service-role RPC platform_ai_agent_claim_task_for_agents(text,text[],integer).
8. Worker updates local status JSON and LIVE agent status/activity records. It does not create one process per specialist.

## Real code entry points

- Desktop shortcut creation/update: tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1.
- Canonical specialist list: tools/tradeflow-gemma-desktop/agents.json (seven keys: 3d-printers-equipment, gaming-consoles-accessories, drones, metal-detectors, mobile-phones, laptops, cameras).
- Hidden launcher: tools/tradeflow-gemma-desktop/Launch-TradeFlow-Control-Centre.vbs.
- Visible UI and local state management: tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1.
- Supervisor: tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1.
- Existing worker startup/updater: tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1 and Update-TradeFlow-Gemma.ps1.
- Desktop runtime docs: tools/tradeflow-gemma-desktop/README.md.

## Local files and settings

- %LOCALAPPDATA%\TradeFlow\ResearchControlCentre\agents.json: canonical UI definitions.
- config.json: global service flag and enabled canonical agent keys.
- status.json: local worker state, activeAgentKeys and activeTaskKey.
- service.json: existing Gemma install path, private .env path, LIVE environment marker. Do not print secrets or rewrite the private .env.
- logs\: supervisor/worker stdout and stderr.
- Windows Task Scheduler task: TradeFlow Gemma Research Supervisor.
- Windows default terminal setting: on this PC, System > Advanced > Terminal > Windows Console Host prevented Windows Terminal from showing the hidden PowerShell session. This is an OS presentation setting, not a backend dependency.

## Supabase / LIVE data flow

- Project: LIVE gxsrajtqzdjvmceqcpgv; TEST remains separate.
- Claim RPC: platform_ai_agent_claim_task_for_agents(text,text[],integer), service-role-only, SECURITY DEFINER, search_path public/private. Desktop mode must not fall back to the generic unscoped claim RPC.
- Queue: public.platform_ai_agent_tasks.
- Observability: public.platform_ai_agent_status and public.platform_ai_agent_activity.
- Canonical desktop specialist keys must be used for UI toggles. LIVE status currently contains historic alias rows including 3d-printers and gaming-consoles; do not count them as extra switches.
- LIVE status inspection on 9 November showed canonical specialist rows idle; local activeAgentKeys was empty during the owner's diagnostic. This is a point-in-time observation, not a permanent state.
- No dedicated project-memory/checkpoint table was found in the inspected LIVE public schema. Repository PROJECT-MEMORY and CHECKPOINTS are the durable project records.

## Failure points and known fixes

| Symptom | First place to inspect | Known cause/fix |
|---|---|---|
| Extra black console | Windows Terminal default terminal + shortcut target | VBS launcher exists; on this PC selecting Windows Console Host stopped the black window. |
| Duplicate Control Centre | UI named mutex | One-instance mutex is in the production UI script. |
| Specialist shortcut does not select category | Shortcut arguments and local config | Check canonical -AgentKey and config enabledAgentKeys; existing UI refreshes every three seconds. |
| Only three generic checkboxes visible | Installed UI script version and card layout | Local agents.json and config both contained seven; production UI changed to a vertical scrollable named-card list. PC deployment still pending. |
| Enabled but not running | local status.json activeAgentKeys and LIVE task status | Enabled means eligible; only RUNNING means an active task exists. One worker is intentional. |
| Backend update required | LIVE scoped RPC and worker logs | Do not fall back to generic unscoped claim; investigate migration gate. |

## Safe repair procedure

1. Inspect local shortcut target/arguments, agents.json, config.json, status.json, scheduled-task action and installed UI script before editing.
2. Compare local desktop files with current production branch; do not assume the full installer is needed.
3. For a UI-only change, close the visible Control Centre (this does not stop the supervisor), replace only the local UI PowerShell script, then reopen the existing main shortcut.
4. Never rerun the full installer for a UI-only fix: it invokes the Gemma worker updater and has active-worker safety gates.
5. Do not terminate the Node worker, edit .env, alter the LIVE queue, change source registry, or write to product/evidence tables for a desktop presentation defect.
6. Verify all seven named rows, per-specialist enable/disable, enabled/active counts, state labels, one visible dashboard, no extra console and unchanged scheduled supervisor.

## Current checkpoint

- Shortcut/VBS correction applied locally and verified for Gaming.
- Windows Console Host selected by owner; black window stopped returning.
- All seven canonical keys enabled locally; no active agent keys at the diagnostic instant.
- Production UI display correction committed as c720c245fed72174957a1a2d93fed5fc3e9668f8.
- Updated UI script has not yet been copied to the Research PC; PC acceptance remains pending.


## Follow-up UI failure — first two cards clipped / no scroll

Observed in the owner's screenshot after the FlowLayoutPanel implementation: only the last five canonical cards were visible in a narrow side-by-side Control Centre window. The first two (3D Printers and Gaming) were clipped and vertical scrolling was unavailable. Agent definitions/config were already verified to contain all seven keys; this is a WinForms layout/container failure, not a task-claim or Supabase problem.

Corrected production file: tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1, commit 55bba312db21fe1e0a667a4c38cd82d63cad2add. It now uses a standard Panel with AutoScroll=true, explicit vertical card positions spaced 108 pixels apart, AutoScrollMinSize calculated from the seven-agent count, responsive card widths and a reset to the top scroll position. Deployment remains pending on the Research PC. Close only the visible dashboard, replace only the UI script, reopen the existing shortcut, and verify all seven cards by scrolling. Do not rerun the full installer, stop the supervisor, alter config, or touch LIVE queue/evidence/source data for this UI defect.


## Second scroll attempt failed; dedicated scrollbar implementation

Owner screenshot after installing the Panel AutoScroll version still showed only five cards and no usable scroll. Treat that build as failed; do not repeat close/reopen without replacing the script. Production now uses a dedicated VScrollBar adjacent to a non-scrolling card panel. Card coordinates are explicitly derived from index and scroll offset; content height and viewport determine the scroll range; widths adapt to resize. Set LargeChange before Maximum, clamp Value to Maximum - LargeChange + 1, and guard programmatic ValueChanged events. Commits: 1871ec0d062377ff5fff96fedbfa45eda9e828a7 and ab2df7866072b0e21d69db5fd4522e18613ba610. PC deployment/verification pending. Replace only local UI script; do not reinstall, restart worker or modify LIVE queue/evidence.
