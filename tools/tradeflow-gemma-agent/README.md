# TradeFlow Gemma Research PC worker

The Research PC worker polls the approved TradeFlow LIVE AI task queue. It uses the existing local private environment file and Ollama installation.

## Update the existing Research PC installation

Run PowerShell in a normal user session. Download the updater:

```powershell
$Updater = Join-Path $env:TEMP 'Update-TradeFlow-Gemma.ps1'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/laurendigitaluk/TradeFlow/production/tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1' -OutFile $Updater
```

Then run it, supplying the existing Gemma installation folder (the folder containing `src\agent.mjs`) and the exact existing private .env file path:

```powershell
powershell -ExecutionPolicy Bypass -File $Updater -InstallPath 'C:\PATH\TO\EXISTING\tradeflow-gemma-agent' -EnvFile 'D:\PATH\TO\PRIVATE\tradeflow.env'
```

After checking the update output, start the worker with:

```powershell
powershell -ExecutionPolicy Bypass -File $Updater -InstallPath 'C:\PATH\TO\EXISTING\tradeflow-gemma-agent' -EnvFile 'D:\PATH\TO\PRIVATE\tradeflow.env' -StartWorker
```

Replace the example paths with the actual existing paths on the Research PC. Do not create a new .env file and do not move or rename the existing one.

## What the updater does

- Downloads only the five reviewed source/test files from the production branch.
- Checks Node.js 18+ and validates that the private .env points to the approved TEST and LIVE Supabase projects.
- Runs Node syntax checks and the built-in task-normalisation tests before installation.
- Backs up the existing source files under `backups\before-common-room-<timestamp>`.
- Replaces only files under the existing `src` folder.
- Does not read out, print, upload, copy, or overwrite the private .env file; does not change Ollama settings or other local configuration.
- Sets `TRADEFLOW_GEMMA_ENV_FILE` for the worker process so the exact supplied private .env path is used.

The worker requires the existing LIVE and TEST service-role credentials in that private .env file. It validates both project URLs and performs research/queue operations against LIVE. TEST remains available for regression only.

## Common Room behaviour

Gemma reads owner instructions and relevant agent handovers/findings/questions/learning notes across all threads, with category matching. These messages are bounded research guidance, not task overrides. Gemma posts task start, handover, completion and failure messages. A handover is not approval to import candidate evidence.

## Stop the worker

Press Ctrl+C in the PowerShell window running the worker. Do not close the window while a task is being processed unless you intend to stop the worker.
