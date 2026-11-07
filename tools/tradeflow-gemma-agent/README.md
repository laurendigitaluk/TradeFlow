# TradeFlow Gemma Research PC worker

The Research PC worker polls the approved TradeFlow LIVE AI task queue and uses the existing local private environment file and Ollama installation.

## Update or install the worker

Open PowerShell. Download the updater from the production branch:

```powershell
$Updater = Join-Path $env:TEMP 'Update-TradeFlow-Gemma.ps1'
Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/laurendigitaluk/TradeFlow/production/tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1' -OutFile $Updater
```

The current Research PC TradeFlow installation is already in its dedicated folder. Update it in place using the existing TradeFlow `.env` in that same folder. Do not point this at the separate GearCashOut configuration or source folders.

```powershell
powershell -ExecutionPolicy Bypass -File $Updater -InstallPath 'C:\TradeFlowGemmaAgent' -EnvFile 'D:\PATH\TO\YOUR\EXISTING\PRIVATE.env' -NewInstall
```

The existing private TradeFlow environment file is `C:\\CTFGemma2\\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\\tools\\tradeflow-gemma-agent\\.env`. The separate `C:\\GearCashOut-Config\\.env` belongs to the old GearCashOut setup and must not be used or changed.

The updater validates the existing TradeFlow .env without printing its values. Do not create a replacement .env file, move it, rename it or paste its contents into ChatGPT/GitHub.

## Start the worker after the update

After the updater reports that syntax checks and tests have passed:

```powershell
$env:TRADEFLOW_GEMMA_ENV_FILE = 'D:\PATH\TO\YOUR\EXISTING\PRIVATE.env'
node 'C:\TradeFlowGemmaAgent\src\task-worker.mjs'
```

Use the same existing folder and .env path. The worker window stays open while it polls the LIVE queue. Press Ctrl+C to stop it cleanly.

Alternatively, add `-StartWorker` to the updater command to start the worker immediately after updating and testing.

## What the updater changes

- Downloads only the reviewed Gemma source and test files from the production branch.
- Checks Node.js 18+ and validates that the private .env points to the approved TEST and LIVE Supabase projects.
- Runs Node syntax checks and the built-in task-normalisation tests before installation.
- Backs up any existing source files under `backups\before-common-room-<timestamp>`.
- Replaces only files under the dedicated `src` folder.
- Does not print, copy, upload, back up or overwrite the private .env file; it does not change Ollama settings or other local configuration.
- Sets `TRADEFLOW_GEMMA_ENV_FILE` for the worker process so the exact supplied private .env path is used.

The worker requires the existing LIVE and TEST service-role credentials in that private .env file. It validates both project URLs and performs research/queue operations against LIVE. TEST remains available for regression only.

## Common Room behaviour

Gemma reads owner instructions and relevant agent handovers, findings, questions and learning notes across all threads, with category matching. These messages are bounded research guidance, not task overrides. Gemma posts task start, handover, completion and failure messages. A handover is not approval to import candidate evidence.
