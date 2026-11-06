# TradeFlow Gemma Research PC — Developer Diagnostic Roadmap

## Purpose
Map the actual Windows-to-research data path. Use this before changing the Research PC launcher, local search providers, Ollama, background worker, or review queue. This is a diagnostic map, not a copy of implementation code.

## User actions
- One-off task: run Start-TradeFlow-Gemma.ps1 with a task JSON.
- Background service: install Install-TradeFlow-Gemma-Service.ps1; Windows logon starts Start-TradeFlow-Gemma-Service.ps1, which restarts src/task-worker.mjs.
- Explicit owner-review staging: one-off launcher -Enqueue or background queue task. Default one-off mode is dry-run.

## Windows / local entry points
- tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1
  - checks local TradeFlow .env, expected TEST/LIVE project hosts, Ollama CLI/model, then runs npm test and npm start -- <task>;
  - does not load or modify C:\GearCashOut-Config\.env.
- tools/tradeflow-gemma-agent/Install-TradeFlow-Gemma-Service.ps1
  - validates the task worker and tests, registers a per-user logon scheduled task.
- tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma-Service.ps1
  - persistent PowerShell restart loop; writes logs/gemma-supervisor.log.
- tools/tradeflow-gemma-agent/src/index.mjs
  - loads the exact TradeFlow .env path, parses task JSON and runs bounded task concurrency.
- tools/tradeflow-gemma-agent/src/task-worker.mjs
  - persistent queue poller against TEST control-plane RPCs.

## Research execution path
Start-TradeFlow-Gemma.ps1 → npm start → src/index.mjs → src/agent.mjs::runTask

1. Task JSON provides category, manufacturer, exact model/package identity, search query and research type (uk_new / uk_used).
2. searchWebResults queries DuckDuckGo, Bing and Mojeek independently in parallel. Provider failures are isolated; results are deduplicated and capped by SEARCH_RESULTS_PER_TASK.
3. Direct source pages are fetched by page(); redirect host and UK eligibility are checked.
4. Ollama /api/chat extracts visible facts only. Calls are serialized, CPU-only by default (OLLAMA_NUM_GPU=0), with bounded configurable timeout.
5. validate() enforces UK source, GBP, visible exact price, evidence type/condition and exact product identity.
6. Exact category, branch, manufacturer and product identity are independently resolved in TEST and LIVE.
7. Default dry-run returns candidates without queue writes. Explicit enqueue stages only into TEST platform_catalogue_research_queue as pending_review.
8. Owner-approved importer is separate; Gemma does not directly write master catalogue or shared evidence rows.

## External dependencies and data stores
- Local Ollama API: default http://127.0.0.1:11434; configured model from TradeFlow .env.
- Public web search: DuckDuckGo HTML, Bing HTML, Mojeek HTML. No Docker/SearXNG service or paid search API is required for the current search implementation.
- Direct source pages: HTTP(S) fetch with UK storefront restrictions.
- Supabase TEST: project nnsshnfkjcflucjrftzi; control-plane task queue and review queue.
- Supabase LIVE: project gxsrajtqzdjvmceqcpgv; exact product resolution and agent telemetry. No queue insert to LIVE.
- Credentials: TradeFlow agent folder .env only. Keep old GearCashOut C:\GearCashOut-Config\.env untouched.

## First failure points
1. Wrong local folder or stale launcher file; confirm the file is the latest feature-branch revision.
2. Missing TradeFlow .env or wrong TEST/LIVE URL host; never print secret values.
3. Ollama service/model unavailable or model runner failure; inspect extraction-specific error after search succeeds.
4. All public search providers unavailable/rate-limited; one provider failing alone must not stop the other two.
5. Direct source blocks or redirects outside eligible UK storefront; reject that source, continue with remaining candidates.
6. Missing/ambiguous exact product in either environment; fail closed, do not create products automatically in this research path.
7. Review queue duplicate or TEST queue permission/schema error; do not bypass by writing directly to catalogue evidence.
8. Background service not installed; the one-off launcher is not the persistent worker.

## GearCashOut comparison and known correction — 6 November 2026
The working GearCashOut implementation in laurendigitaluk/Action-Buyer-UK uses:
- Start-GearCashOut-AI.ps1 → npm start → supervisor.mjs → agent.mjs;
- an external config folder loaded first;
- independent DuckDuckGo, Bing and Mojeek search, with optional configured Google;
- a persistent supervisor that restarts the worker and keeps remote lifecycle control available.

TradeFlow initially diverged by making SearXNG/Docker a mandatory search provider and a blocking launcher preflight. This created the repeated Research PC failure. The correction on this feature branch:
- replaced SearXNG-only search in src/agent.mjs with independent DuckDuckGo/Bing/Mojeek providers;
- changed src/release-monitor.mjs to reuse that shared search;
- removed SearXNG preflight from Start-TradeFlow-Gemma.ps1;
- removed SEARXNG_BASE_URL from .env.example;
- updated README and both manuals.

This is the confirmed root cause of the repeated SearXNG startup block. It does not establish that the full TradeFlow service lifecycle is yet at GearCashOut parity. TradeFlow has a persistent task-worker supervisor script and scheduled-task installer, but these have not been installed/verified on the Research PC.

## Verification sequence
1. Update only TradeFlow agent code files from the feature branch; do not replace either .env.
2. Run local npm test; revised tests must prove that one unavailable provider does not prevent results from the others.
3. Run one-off launcher in default dry-run mode.
4. Confirm provider discovery, page fetch, Ollama extraction, validation and exact TEST/LIVE product resolution.
5. Confirm no review queue or catalogue writes in dry-run.
6. Only after owner review, explicitly stage candidates; verify they appear in TEST review queue only.
7. Separately install and verify the background service before claiming unattended operation.
8. Verify both manuals and Supabase project memory/checkpoint. Supabase memory update is currently blocked by connector permission; do not claim it was updated.

## Relevant implementation files
- tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1
- tools/tradeflow-gemma-agent/src/index.mjs
- tools/tradeflow-gemma-agent/src/agent.mjs
- tools/tradeflow-gemma-agent/src/release-monitor.mjs
- tools/tradeflow-gemma-agent/src/task-worker.mjs
- tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma-Service.ps1
- tools/tradeflow-gemma-agent/Install-TradeFlow-Gemma-Service.ps1
- tools/tradeflow-gemma-agent/test/agent.test.mjs
- tools/tradeflow-gemma-agent/.env.example
- tools/tradeflow-gemma-agent/README.md
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
