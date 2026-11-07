# TradeFlow Gemma Research PC worker

The Research PC worker polls the approved TradeFlow LIVE AI task queue and uses the existing local private environment file and Ollama installation.

## Update or install the worker

Open PowerShell. Download the updater from the production branch:

```powershell
$Updater = Join-Path $env:TEMP 'Update-TradeFlow-Gemma.ps1'
Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/laurendigitaluk/TradeFlow/production/tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1' -OutFile $Updater
```

The current Research PC TradeFlow installation is already in its dedicated folder. Update it in place using the existing TradeFlow `.env` in that same folder. Do not point this at the separate GearCashOut configuration or source folders. The paths in the command below are the current confirmed TradeFlow paths; do not use `C:\GearCashOut-Config\.env`.

```powershell
powershell -ExecutionPolicy Bypass -File $Updater -InstallPath 'C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent' -EnvFile 'C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent\.env' -StartWorker
```

The existing private TradeFlow environment file is `C:\\CTFGemma2\\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\\tools\\tradeflow-gemma-agent\\.env`. The separate `C:\\GearCashOut-Config\\.env` belongs to the old GearCashOut setup and must not be used or changed.

The updater validates the existing TradeFlow .env without printing its values. Do not create a replacement .env file, move it, rename it or paste its contents into ChatGPT/GitHub.

## Start the worker after the update

After the updater reports that syntax checks and tests have passed:

```powershell
$env:TRADEFLOW_GEMMA_ENV_FILE = 'D:\PATH\TO\YOUR\EXISTING\PRIVATE.env'
node 'C:\TradeFlowGemmaAgent\src\task-worker.mjs'
```

Use the same existing folder and .env path. Stop any older TradeFlow queue-worker process cleanly before starting this one so two workers do not poll the same queue. Do not interrupt an active research task. The worker window stays open while it polls the LIVE queue. Press Ctrl+C to stop it cleanly.

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


## First category rollout: 3D Printers & Equipment

The first category-specific website playbook is `src/source-playbooks.mjs`. It gives the 3D-printer agent per-site search routes and navigation rules for manufacturer stores, new retailers, used/refurbished dealers, Gumtree, SecondHand, eBay and Amazon. Search/category/collection pages are discovery only; the worker follows exact-model product links and validates each individual listing before evidence can enter the LIVE owner review queue. The worker now rotates through every approved source for the category rather than stopping after twelve, and tries the configured site-specific routes (up to five per site). A historical direct product URL in `search_url_template` is ignored as a search route.

The first Common Room inbox rollout is deliberately limited to the `3d-printers-equipment` agent. It checks the LIVE AI Common Room at worker startup, before that agent's research tasks, and during idle queue polling. It replies in a thread to the owner's welcome message, acknowledges owner instructions, and uses local Ollama to answer unanswered questions; replies are linked with `parent_message_id` to prevent repeats. Other category agents are not enabled until this first agent has been tested. Message content is treated as untrusted context and cannot override exact-model checks, approved-source rules, privacy constraints or the owner review gate.

After this change is merged, update the Research PC using the reviewed updater. It retains the existing TradeFlow `.env` path and never reads or changes the separate GearCashOut configuration. Stop the old worker cleanly before replacing source files, then restart and verify the 3D Printer Gemma greeting appears as a reply to the owner's Welcome message in AI Common Room. Cloud/PC deployment is not complete until that round-trip is visible.


## Gemma 3D-printer lane and extraction improvements — PR #278 pending review

The LIVE worker review identified two separate capture bottlenecks and an observability gap:

- Research tasks now need lane-aware source selection: uk_new uses manufacturer/new-retailer sources; uk_used uses marketplace/used/refurbished sources; uk_both uses both. Category, manufacturer and UK restrictions still apply.
- 3D-printer web-search retention defaults to 30 results per task (existing hard maximum 30), configurable downward with GEMMA_3D_PRINTER_SEARCH_RESULTS_PER_TASK. Other categories keep their existing default.
- The visible-price extractor recognises £ and GBP, including pound HTML entities normalised from page markup.
- Known bot/captcha challenge routes are reported and skipped as blocked discovery results, not treated as product pages or bypassed.
- Gemma JSON parsing accepts the required findings array and common recognised wrappers. Unknown response shapes report their top-level keys; all fetched pages remain in raw fallback captures. The model prompt is bounded for the existing 4k context and receives the latest Common Room notes, while full page text remains stored for ChatGPT.
- Ollama extraction reports each batch start/completion/failure. The worker also refreshes LIVE heartbeat telemetry while a subtask is active, including during a long model call. Telemetry and Common Room handovers expose search, source-route, page-fetch, price, extraction and capture counts plus failure details.

LIVE diagnostic: the first Anycubic Kobra S1 subtask staged 9 individual pages. Every raw capture retained visible GBP price mentions, but Gemma returned JSON without a recognised findings array, leaving structured price/evidence fields empty. The first measured loss point was extraction-envelope parsing after page fetch. The raw capture fallback worked and preserved the page content/prices.

PR #278: https://github.com/laurendigitaluk/TradeFlow/pull/278. GitHub Actions Gemma Research Tests runs 42411454578, 42411512585, 42411518602, 42411597295, 42411603001, 42411615477, 42411650325, 42411660316, 42411686018, 42411719991, 42411824125 and 42411844905 all passed. This is not in production and has not been installed on the Research PC. After review/merge, use the existing updater in place, preserve the existing private .env and TRADEFLOW_GEMMA_ENV_FILE path, and run a controlled LIVE test. Do not merge/deploy or approve/import evidence without the owner's review.
