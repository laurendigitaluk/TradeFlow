# Project Memory — Gemma 3D Printer Extraction Performance

## 8 November 2026 — PR #298 merged

PR #298 is now merged into `production` (merge commit `3417c5dced183fedcf13a7af266c67c2dd697d0a`). GitHub Actions validation passed 53/53 tests. This is not yet installed on the Research PC and has not been runtime-benchmarked. Next: use the existing updater with the correct dedicated install folder, preserving the separate private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify installed commit/heartbeat before queuing a controlled 3D-printer batch. Do not change other agent branches or import/approval controls.


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
The merged production change batches two 3D-printer pages per Ollama call, changes the prompt contract to a findings array with one row per source_id, reduces model excerpts to 2,800 characters per page while retaining price strings and compact nearby contexts, and records per-stage durations. Full page text remains preserved for ChatGPT. Other categories are unchanged.

GitHub Actions run 42497005002 passed 53/53 tests and all syntax checks. This is code-level verification only; the change is not runtime-verified. Research PC Ollama acceptance is pending. PR #298 is merged and CI passed, but the Research PC source remains unverified. The worker `DESKTOP-LVASEUB-80488` started at 16:12:56 UTC and stopped cleanly at 16:15:29 UTC without claiming a task. Do not deploy or queue another LIVE task without explicit owner approval. Preserve the private .env and TRADEFLOW_GEMMA_ENV_FILE. No approval/import behaviour may change.


## 8 November 2026 — LIVE 3D-printer audit and HTTP 403 source backoff

### Run comparison

| LIVE task | Duration | Search results | Product pages discovered | Fetched | Ollama calls | Extraction failures |
|---|---:|---:|---:|---:|---:|---:|
| `owner-3d-printers-exact-identity-acceptance-20261108-0032` | 14m 35s | 85 | 15 | 6 | 4 | 2 |
| `owner-3d-printers-deep-extraction-acceptance-20261108-1235` | 36m 56s | 86 | 19 | 11 | 11 | 9 |
| `owner-3d-printers-chatgpt-evidence-batch-20261108-1315` | 70m 49s | 123 | 30 | 18 | 18 | 10 |

Search/discovery improved in volume, but the latest batch still used one-page Ollama calls. PR #298's two-page extraction and stage-duration telemetry are in production; no post-merge task has yet verified them on the Research PC.

### Latest LIVE batch and review queue

- The latest six-product task completed 6 sequential subtasks in 70m 49s. It used `uk_both` for all six products.
- The 18 fetched pages were retained as review captures: 12 new queue rows and 6 existing rows enriched. LIVE queue now contains 64 3D-printer rows; all are `needs_research`, with zero approved and zero imported.
- Raw task-lane metadata across the queue: 42 `uk_new`, 6 `uk_used`, 16 `uk_both`. The top-level `evidence_type` is null on 63/64 rows; the raw task lane and captured page context remain available for ChatGPT review. Do not infer approval or a final new/used classification from a raw capture.
- The first loss points are distinct: 12 of 30 discovered pages did not reach page capture (11 recorded direct-fetch errors); for pages successfully fetched, the first systematic loss of structured findings was Gemma extraction (10/18 failures: 4 timeouts, 4 unterminated JSON responses, 2 unrecognised findings-array shapes). Raw page text and price contexts were retained, so this is a structured-extraction loss, not deletion of source captures.

### Failed and blocked source routes

- The batch made 159 approved-source route attempts with 39 route errors.
- eBay's three configured routes returned HTTP 403, HTTP 403 and HTTP 404 for each product (18 repeated eBay route attempts); direct eBay listing fetches also returned HTTP 403. Do not bypass these blocks.
- Other repeated route errors included Amazon UK route 2 (404), Uni3Dverse route 3 (404), SecondHand route 3 (404), and Bambu Lab's old Shopify host route 2 (404). A 404 remains route-specific; verify the actual current source route before changing the allow-list.

### Review PR #299

- [PR #299 — stop 3D-printer source retries after HTTP 403](https://github.com/laurendigitaluk/TradeFlow/pull/299), branch `fix/gemma-3d-printer-403-domain-block-20261108`.
- It creates a blocked-host set per claimed queue batch, shares it across that batch's sequential product subtasks, probes eBay routes sequentially, stops after the first HTTP 403, and filters blocked-host web/seed results before page fetching. The set resets for the next queue task. HTTP 404 does not block. Other categories retain existing route behaviour; no anti-bot bypass is introduced.
- Regression test for six subtasks: eBay route attempts fall from 18 to 1 (17 skipped; 94.4% fewer) when the first route returns 403. GitHub Actions Gemma Research Tests run #209 (run ID `42499775075`) passed 57/57 tests on PR head `12ebe76260aa610ad3231bebb4c217958b93f9dd`. This is CI verification, not a LIVE runtime benchmark. PR #299 remains open, unmerged and undeployed.

### Research PC worker state and install reference

- Worker `DESKTOP-LVASEUB-80488` started at 16:12:56 UTC and stopped cleanly at 16:15:29 UTC. Two later worker processes registered as polling LIVE: `DESKTOP-LVASEUB-78948` at 16:16:03 UTC and `DESKTOP-LVASEUB-72580` at 16:16:47 UTC; neither has a recorded stop event as of 16:25:58 UTC. No queued or running 3D-printer tasks exist; all 14 recorded tasks are completed.
- The status row's last task heartbeat is 14:29:23 UTC. The worker sends task heartbeats while a task is claimed, not while idle; the two worker-start events show connection/polling starts but do not independently prove current process liveness. The claim RPC uses `FOR UPDATE SKIP LOCKED`, so two pollers cannot claim the same task row. Keep one poller unless parallel workers are intentional.
- The existing installation is `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent`; its private `.env` is in the same folder. Standard Windows PowerShell 5.1 runs the updater; PowerShell Core 7 is not required. Do not create a second installation or replace the private environment file.
- No research task was queued, no evidence approved/imported, and no source registry, TEST data, LIVE catalogue data, secret or private environment file was changed by this audit.

### Memory and checkpoint handling

- The System Handbook, AI Operating Manual, diagnostic roadmap, GitHub project-memory file and checkpoint are updated in this review branch.
- The LIVE public schema has no separate project-memory/checkpoint table. The Common Room learning-note write through the owner-only RPC was rejected with `Platform owner access required`; do not bypass that control or insert directly into the message table. The GitHub project-memory/checkpoint files are the versioned record until an owner-authorized Common Room write is available.
