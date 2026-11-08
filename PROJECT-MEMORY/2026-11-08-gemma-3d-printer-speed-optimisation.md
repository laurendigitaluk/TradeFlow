# Project Memory — Gemma 3D Printer Extraction Performance

Date: 8 November 2026
Scope: TradeFlow LIVE 3D Printers research pipeline only.

The six-product LIVE batch owner-3d-printers-chatgpt-evidence-batch-20261108-1315 took 70m 49s. The worker processed the six subtasks sequentially. Across the task, 30 product pages were discovered, 18 fetched, 18 one-page Ollama extraction calls were made and 10 extraction failures were recorded. Fetched pages remained preserved in the LIVE review queue; none was approved or imported.

Code inspection established:
- task-worker.mjs iterates product subtasks sequentially.
- Product-page fetching is already concurrent in groups of four.
- Ollama extraction is serialised by ollamaExtractionQueue.
- The 3D-printer branch used one page per model call and a single-object prompt.
- Search fans five query variants across four providers concurrently; approved source routes are probed separately in groups of four per source. Request counts alone do not establish wall-clock cost.

Performance branch: perf/gemma-3d-printer-two-page-extraction-20261108.
The proposed change batches two 3D-printer pages per Ollama call, changes the prompt contract to a findings array with one row per source_id, reduces model excerpts to 2,800 characters per page while retaining price strings and compact nearby contexts, and records per-stage durations. Full page text remains preserved for ChatGPT. Other categories are unchanged.

This is not yet runtime-verified. CI and Research PC Ollama acceptance are pending. Do not merge/deploy, update the Research PC, or queue another LIVE task until CI passes and the owner explicitly approves use of the existing updater. Preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. No approval/import behaviour may change.
