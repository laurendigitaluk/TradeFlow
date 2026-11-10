# 3D Printer Gemma — website navigation and desktop alignment roadmap

Status: 2026-11-09. Scope: LIVE category `3d-printers-equipment`, branch `3d-printers`. This document is an investigation/navigation map, not a new desktop architecture or a replacement worker.

## Boundaries
- Do not rewrite Gemma Desktop, the shared `task-worker.mjs`, desktop launcher, environment files, control plane, other category agents or their source lists.
- The 3D Printer agent must use its own category-scoped instructions and only LIVE-approved sources. Never enable other categories or copy TEST state to LIVE.
- Preserve all existing evidence and failed-task logs. No catalogue auto-import or price approval.
- The running Node process does not automatically reload changed source files. An installed-file update and a runtime reload are separate events. Restart only when safe, after verifying no active task.

## Verified system path
- User starts/controls Gemma Desktop on Research PC.
- Existing launcher: `tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1`.
- Existing queue process: `tools/tradeflow-gemma-agent/src/task-worker.mjs`.
- Worker receives LIVE queued `catalogue_research` task, resolves category identity, then calls `runTask` in `src/agent.mjs`.
- `agent.mjs` reads category/site instructions and search routes from `src/source-playbooks.mjs` using `getWebsiteInstructions` and `buildWebsiteSearchRoutes`.
- LIVE approved sites are in `platform_research_sources`; activity in `platform_ai_agent_activity`, task queue in `platform_ai_agent_tasks`, telemetry in `platform_ai_agent_status`.
- Agent-specific configuration/desktop switch must be checked against the installed Research PC configuration before changing it. Do not assume the local installation contains the latest production code merely because updater succeeded.
- Research PC process observed: `node.exe ...\tools\tradeflow-gemma-agent\src\task-worker.mjs`, PID 130972 at 2026-11-09 22:19 UK. PID is not permanent.

## 3D Printer agent instructions
1. Read category, branch, manufacturer, exact model, package_key and research_type from the assigned task.
2. Select only approved LIVE sources for this category and appropriate new/used lane.
3. For each site use its specified search/collection route, inspect pagination and model/product cards, then follow individual product/listing URLs.
4. Where model-specific verified direct routes are configured, try those even when a collection or search page returns no matching links.
5. Keep standalone, Combo/ACE/AMS, and other bundles separate. Never assign a price from a nonselected variant or accessory.
6. Record direct URL, page text, exact identity/package, selected GBP price, stock/availability, condition, UK delivery/seller, capture time, and uncertainty.
7. Category/search snippets are discovery, not evidence. Preserve borderline raw captures for ChatGPT review; do not fabricate values.
8. Record blocked/403/empty routes and move on. Do not repeatedly retry blocked sites or bypass restrictions.

## LIVE enabled source routes (2026-11-09)
The paths below are site-specific discovery routes, not verified evidence pages.

| Approved host | Routes and lane | Instructions |
| --- | --- | --- |
| `bambu-lab-uk.myshopify.com` | `/search?q={query}`, `/collections/3d-printers` | Exact model page, selected standalone/AMS Combo |
| `store.creality.com` | `/uk/search?q={query}`, `/uk/collections/fdm-3d-printer`; Ender-3 V3 only: `/uk/collections/ender-3-v3-series` | Follow printer products, not accessories |
| `uk.anycubic3d.com` | `/collections/3d-printers`, `/search?type=product&q={query}`; model-specific routes below | Inspect selected standard/Combo option |
| `uk.elegoo.com` | New `/collections/fdm-printers`; used `/collections/pre-owned-3d-printer` | Separate new and pre-owned pages; reject sold-out |
| `uni3dverse.co.uk` | `/used-3d-printers?search={query}` | Individual used/refurbished listings |
| `3dgbire.com` | `/collections/reconditioned-3d-printers` | Individual reconditioned/ex-demo products |
| `3dprima.co.uk` | `/search?query={query}` | Exact SKU, GBP/VAT, stock |
| `123-3d.co.uk` | New `/collections/3d-printers`; used `/collections/refurbished-printers` | Paginate and inspect exact individual pages |
| `idig3dprinting.co.uk` | `/product-category/3d-printers/` | WooCommerce category pagination |
| `3dflo.com` | `/product-category/3d-printers/` | Printer-only category; no general shop |
| `3djake.uk` | `/search?query={query}` | Exact UK product, GBP and stock |
| `gumtree.com` | `/uk/srpsearch%2B{slug}` | Active individual UK adverts only |
| `secondhand.org.uk` | `/second-hand-3d-printers?search={query}` | Individual active used listings |

`{query}` means encoded manufacturer and model; `{slug}` means the hyphenated manufacturer and model. eBay UK and Amazon UK have playbook entries but were not returned as enabled LIVE 3D Printer sources in the 2026-11-09 check; do not assume they are active.

### Anycubic direct model routes already in production
- Kobra 3 Max V2: `https://uk.anycubic3d.com/products/kobra-3-max-v2-3d-printer`
- Kobra 3 Max V2 ACE 2 Pro Combo: `https://uk.anycubic3d.com/products/kobra-3-max-v2-ace-2-pro-combo`
- Kobra 4: `https://uk.anycubic3d.com/products/kobra-4-3d-printer` (selected variant required)
- Kobra S1: `https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo` and `https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo-3d-printer`

## First-failure investigation and known fix history
- PR #339 merged Anycubic direct route mapping into production, commit `7b7f166ad29fe4507a95fb8e6fc19652b72ee30f`; Gemma CI passed.
- A LIVE Anycubic repeat task on 2026-11-09 did not log attempts for these direct routes; it logged only generic collection/search routes. That proves a runtime/route-selection discrepancy, not that the websites lack product pages.
- Research PC updater reported production source updated, but existing Node process may still have pre-update module code in memory. Do not infer a failed source update from a command-not-found error run in the user's home directory.
- First establish whether the installed agent playbook is loaded by the running process. Then test a single Kobra 3 Max V2 Combo task and inspect `approved_source_route_attempt` for both direct URLs.
- If direct URLs are attempted but fail, investigate HTTP response, model matching, selected package, page fetch and raw capture in that order. Only change the first failing 3D Printer-specific layer.
- Do not repeat broad worker/desktop rewrites, indiscriminate source additions, or repeated failed searches.

## Verification gate
Before a wider batch: one controlled 3D Printer LIVE task must show direct-route attempts, individual product page inspection and raw capture or a specific logged failure. Verify no unrelated category settings, workers or queues were modified. Update this roadmap and the project's canonical manuals/memory checkpoint when a material runtime fix is made.


## 9 November 2026 — 3D Printer batch-completion hardening

The 3D Printer worker previously sent the full `outputs` array to `platform_ai_agent_complete_task`. For block-sized jobs, those outputs include full raw page captures and long excerpts that are already separately persisted in the review queue. The 8-product LIVE task failed at the completion RPC with PostgREST `PGRST102 Empty or invalid json` after its product research work. The exact parser failure cause was not proven, but the oversized/redundant completion payload was a credible risk and has been removed from the 3D Printer branch.

The 3D Printer worker now uses `src/task-result-summary.mjs` to submit a compact task result: product identity, candidate count, direct capture URLs, review classification, observed GBP amount/currency, review-queue write references, route metrics and bounded route failures. Raw page bodies and long excerpts remain in the review queue and are not duplicated into the task completion JSON. It logs the compact JSON byte count before submitting. Regression tests verify raw page capture text is excluded and the task result remains small.

Anycubic route regression coverage now verifies the UK collection/search routes and direct Kobra 3 Max V2 machine-only and ACE 2 Pro Combo URLs, plus Kobra 4 and Kobra S1 model-specific routes. Gemma Research Tests run `42720630028` passed on 9 November 2026. Changes are isolated to branch `gemma/3d-printers`; do not merge them into other category branches.

This code is committed to GitHub but has not yet been installed on the Research PC. The running 3D Printer worker must be stopped cleanly before running its folder-local `Update-Gemma-Agent.ps1`, then restarted from the same Gemma 3D Printers shortcut. Only after the updated worker completes a controlled block task without a completion RPC error can the 3D Printer branch be locked as accepted.


## 10 November 2026 — post-merge runtime and review-queue verification

### 10 November 2026 — 3D Printers post-merge LIVE verification

The latest LIVE parent task `owner-3d-printers-equipment-1794272051590` completed normally with five product subtasks. It returned 48 search results, discovered 10 individual product pages, fetched 6 and retained/staged 6 page captures (three new records and three enrichments). Four of four Gemma extraction batches timed out under the pre-merge 45-second batching policy. The compact task-result helper submitted a 9,811-byte parent result; the earlier PGRST102 completion error did not recur on this five-product batch.

The 6 staged captures remain review-only. The pending queue currently has 8 `needs_research` records: 2 typed UK-new and 6 unclassified; there are no typed UK-used pending captures. The latest batch's six writes were 3 new and 3 enrichments; the Kobra 4 Standard enrichment retained its existing UK-new £159 observation, while the other raw captures remain unclassified. Active shared evidence is 239 UK-new and 21 UK-used. No catalogue evidence was approved or imported.

The first loss in this run was search-to-exact-page discovery (48 results to 10 individual pages), followed by page fetching (10 discovered to 6 fetched). The largest avoidable post-fetch loss was Gemma extraction: all four batches timed out, although all six raw captures were preserved. PR #348 merged to production at 01:17:10 UTC (merge commit `83ee9fdf533cac92bbf4bcc96384205ee31ea7f5`) and adds verified Anycubic/3DJake/123-3D/eBay routes plus one-page, 90-second 3D-printer extraction. The latest task predates that merge, so no post-merge Research PC runtime acceptance has yet occurred.

The LIVE status row reports the 3D-printer agent idle, with no current task and a heartbeat at 01:21:21 UTC from worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`. The local installed commit is not reported, so the heartbeat does not prove that PR #348's post-merge code is installed.

A second defect was confirmed in the actual review-queue write path: raw `item_condition_text` and `availability_text` snippets are copied into the normalized queue columns. Six pending rows have condition values over 100 characters and eight have availability values over 100 characters. The earlier PR #346 added and tested a normalization helper but did not call it from the final database row builder; its tests therefore did not prove the persisted row was corrected. The new 3D-only replacement PR centralizes the final row builder, calls the helper at the extraction/validation/persistence boundaries, and tests the actual persisted-row shape. Raw snippets and full page captures remain in `raw_payload.evidence` and `page_capture`.

The same 3D-only replacement also separates heartbeat event stage (`stage=heartbeat`) from the active research stage (`active_stage`). The latest task produced 8 heartbeat activity rows, 4 of which were incorrectly labelled `extraction_batch_started`, inflating stage counts. Installer and launcher preflight now include the telemetry and installer-manifest regression tests. No idle-worker restart, updater execution or post-merge research task was performed in this watch.

PR #348's own merge/checkpoint records say shared worker source/tests were synchronised across all seven isolated category branches. That cross-category synchronization occurred outside this 3D-only follow-up. No additional branch or code changes were made to other categories here. Keep subsequent work confined to `gemma/3d-printers`.

The LIVE schema has no dedicated project-memory/checkpoint table in any schema; the repository's `PROJECT-MEMORY` and `CHECKPOINTS` files remain the durable project record. The category-scoped Common Room is stored separately in `platform_ai_agent_messages`.

### Current review items
- PR #349 (3D-printer branch only) contains the corrected review-row mapping, heartbeat stage separation, updater/launcher manifest tests and CI coverage. Do not merge or install without explicit approval.
- PR #346 must not be merged as-is: its normalization helper was not wired into the final queue row builder. PR #347 is stale/diverged; PR #349 is the current replacement for those 3D-only corrections.
- PR #348 is merged to production; the Research PC has not yet completed a post-merge acceptance task. Do not queue a duplicate batch before the owner-approved update and version check.


## 10 November 2026 — post-merge runtime and review-queue verification

### 10 November 2026 — 3D Printers post-merge LIVE verification

The latest LIVE parent task `owner-3d-printers-equipment-1794272051590` completed normally with five product subtasks. It returned 48 search results, discovered 10 individual product pages, fetched 6 and retained/staged 6 page captures (three new records and three enrichments). Four of four Gemma extraction batches timed out under the pre-merge 45-second batching policy. The compact task-result helper submitted a 9,811-byte parent result; the earlier PGRST102 completion error did not recur on this five-product batch.

The 6 staged captures remain review-only. The pending queue currently has 8 `needs_research` records: 2 typed UK-new and 6 unclassified; there are no typed UK-used pending captures. The latest batch's six writes were 3 new and 3 enrichments; the Kobra 4 Standard enrichment retained its existing UK-new £159 observation, while the other raw captures remain unclassified. Active shared evidence is 239 UK-new and 21 UK-used. No catalogue evidence was approved or imported.

The first loss in this run was search-to-exact-page discovery (48 results to 10 individual pages), followed by page fetching (10 discovered to 6 fetched). The largest avoidable post-fetch loss was Gemma extraction: all four batches timed out, although all six raw captures were preserved. PR #348 merged to production at 01:17:10 UTC (merge commit `83ee9fdf533cac92bbf4bcc96384205ee31ea7f5`) and adds verified Anycubic/3DJake/123-3D/eBay routes plus one-page, 90-second 3D-printer extraction. The latest task predates that merge, so no post-merge Research PC runtime acceptance has yet occurred.

The LIVE status row reports the 3D-printer agent idle, with no current task and a heartbeat at 01:21:21 UTC from worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`. The local installed commit is not reported, so the heartbeat does not prove that PR #348's post-merge code is installed.

A second defect was confirmed in the actual review-queue write path: raw `item_condition_text` and `availability_text` snippets are copied into the normalized queue columns. Six pending rows have condition values over 100 characters and eight have availability values over 100 characters. The earlier PR #346 added and tested a normalization helper but did not call it from the final database row builder; its tests therefore did not prove the persisted row was corrected. The new 3D-only branch centralizes the final row builder, calls the helper at extraction/validation/persistence boundaries, and tests the actual persisted-row shape. Raw snippets and full page captures remain in `raw_payload.evidence` and `page_capture`.

The same 3D-only branch separates heartbeat event stage (`stage=heartbeat`) from the active research stage (`active_stage`). The latest task produced 8 heartbeat activity rows, 4 of which were incorrectly labelled `extraction_batch_started`, inflating stage counts. The updater, launcher and CI already referenced the telemetry and installer-manifest tests, but the test files were absent from the branch; this branch supplies them and verifies the download/preflight contract.

PR #348's own merge/checkpoint records say shared worker source/tests were synchronised across all seven isolated category branches. That cross-category synchronization occurred outside this 3D-only follow-up. No additional branch or code changes were made to other categories here. Keep subsequent work confined to `gemma/3d-printers`.

The LIVE schema has no dedicated project-memory/checkpoint table in any schema; the repository's `PROJECT-MEMORY` and `CHECKPOINTS` files remain the durable project record. The category-scoped Common Room is stored separately in `platform_ai_agent_messages`.

### Current review gates
- New branch `fix/3d-printer-review-row-heartbeat-installer-20261110` is limited to `gemma/3d-printers`. It corrects the persisted review-row builder, separates heartbeat stage from active stage, and supplies the missing updater/launcher/CI test files.
- PR #346 must not be merged as-is: its normalization helper was not wired into the final queue row builder. PR #347 is stale/diverged; this new branch is the consolidated replacement for those 3D-only corrections.
- PR #348 is merged to production; the Research PC has not yet completed a post-merge acceptance task. Do not queue a duplicate batch before the owner-approved update and version check.



### Correction — worker lifecycle and exact-branch counts (10 November 2026, 01:30 UTC)

The earlier 01:21:21 status timestamp was the `worker_stopped` event for worker `DESKTOP-LVASEUB-3d-printers-equipment-132732`, not proof of an actively polling idle process. A later isolated process `DESKTOP-LVASEUB-3d-printers-equipment-133276` started at 01:29:56 and stopped cleanly at 01:30:43 without claiming a task. The category status row is `idle`, `current_task=null`, `last_error=null`; there is no active worker process at this check. Neither start nor stop was triggered by this watch. No post-PR #348 research task has run, and worker telemetry does not expose the installed commit SHA.

The exact category-and-branch task filter now returns 30 parent tasks: 29 completed and 1 failed, representing 86 product subtasks (78 in completed parents and 8 in the failed parent). Broader category-only payload filtering includes an additional non-exact-branch row and must not be used for branch-specific reporting.

The replacement PR is now open as [PR #349](https://github.com/laurendigitaluk/TradeFlow/pull/349), targeting only `gemma/3d-printers`. GitHub reports it mergeable; Gemma Research Tests run #698 passed. It contains the actual persisted-row mapping correction, heartbeat-stage separation, and the missing telemetry/installer regression files. It is not merged or deployed.



### 10 November 2026 — page-fetch funnel telemetry added

The latest task's activity log recorded 10 `fetching_page` events, 2 `source_error` events and 6 `page_capture_retained` events. It also recorded 16 `model_variant_skipped` events, but the older progress payload did not distinguish pre-fetch skips from post-fetch rejections. The parent result did not expose separate fetch-attempt, successful-HTTP-fetch, pre-filter rejection and post-fetch rejection counters; `fetched_price_pages` is not a substitute for successful HTTP fetches.

PR #349 now incorporates the 3D-printer-only page-flow telemetry correction previously proposed in PR #338: emit `product_page_fetched` after a successful HTTP fetch, label model/package skips with `phase=prefilter|postfetch`, report fetch attempts, successful fetches, pre/post validation rejections and pages eligible for capture, and include these metrics in the worker handover/parent result. The legacy `inspected_product_pages` field remains unchanged for compatibility. Regression coverage reproduces 2 attempts, 1 successful fetch, 1 prefilter rejection, 1 post-fetch rejection and 0 eligible pages.

GitHub Actions run #702 passed all workflow steps on code/test commit `5f3f77d2af3d94290e63b7a6c266e7a4555f2d14` (PowerShell syntax, Node syntax, Gemma task/website tests and Owner Dashboard JavaScript). The subsequent documentation-only commits do not change source or tests. PR #349 remains open and unmerged, targeting only `gemma/3d-printers`; it supersedes the stale PR #338.


## 10 November 2026 — parent task completion lifecycle and aggregate reporting

A read-only LIVE audit found that the worker emitted `event_type=task_completed` once per product subtask, from inside the `tasks[]` loop and before `platform_ai_agent_complete_task` was called. It also set the specialist status to idle and cleared `current_task` between subtasks. This made the activity feed and Common Room completion message describe only the final product subtask as if it were the whole parent batch.

Verified example — parent task `owner-3d-printers-equipment-1794272051590`:
- Five product subtasks emitted five `task_completed` activity events.
- The final event at 01:00:37.716 UTC reported only Kobra S1: 2 captures, 2 staged (2 new, 0 enriched), 2 search results, 2 pages discovered and 2 fetched.
- The parent queue row was not marked completed until 01:00:53.096 UTC, 15.38 seconds later.
- Actual aggregate across the five saved subtask results: 48 search results, 10 pages discovered, 6 fetched, 6 captures, 6 staged (3 new, 3 enriched), 78 route attempts (20 matching, 50 empty, 8 errors), and 4 Gemma batch timeouts.
- The Common Room parent-looking completion message repeated the final Kobra S1 subtask figures rather than the parent totals. The prior eight-subtask parent that later failed its completion RPC had already emitted eight `task_completed` events, demonstrating the same lifecycle ambiguity on failure.

Correction on feature branch `fix/3d-printer-parent-completion-lifecycle-20261110`, stacked on PR #349's 3D-printer-only branch:
- Per-product completion is now a `progress` event with `stage=subtask_completed`; the parent remains `running` with its current task key until the completion RPC succeeds.
- The per-subtask counter deltas are preserved, so existing cumulative product-subtask counters are not double-counted or reset.
- After `platform_ai_agent_complete_task` returns true, the worker emits one parent `task_completed` event and one aggregate Common Room completion message. If the RPC fails, no parent-completed event is emitted; the existing failure path remains authoritative.
- The compact parent result now carries aggregate search, page, capture, Gemma, route and review-write counts while retaining the individual compact subtask records and excluding raw page bodies.

Regression fixture reproduces the actual five-product LIVE totals: 48 searches, 10 discovered pages, 6 fetched/captured, 4 Gemma failures, 78 route attempts, 20 matches, 50 empty, 8 errors, and 6 review writes (3 new, 3 enriched). Local Node tests passed 5/5. GitHub Actions Gemma Research Tests run #708 (42763835025) passed PowerShell updater syntax, Node source syntax, Gemma task/playbook tests and Owner Dashboard JavaScript syntax. No Research PC update, worker restart, task enqueue, LIVE database mutation, evidence approval/import, or TEST/LIVE transfer was performed. PR #350 is review-only and must not be merged or deployed without explicit approval. The Supabase Common Room learning-note write was not attempted: the available SQL connection has no service-role JWT and the posting RPC requires service_role; repository memory/checkpoint files are updated on this branch.


## 10 November 2026 — category-scoped idle heartbeat correction (prepared, not deployed)

The current isolated specialist worker reports `worker_started` and processing heartbeats, but has no recurring heartbeat after a successful idle queue poll. Therefore an idle specialist's `last_heartbeat` becomes stale even when its process is healthy. LIVE inspection confirmed the status RPC updates `platform_ai_agent_status.last_heartbeat`, `updated_at`, status and activity rows through `platform_ai_agent_report_event`; no schema change is required.

LIVE baseline at this inspection:
- Project: `gxsrajtqzdjvmceqcpgv`; specialist: `3d-printers-equipment`; branch: `gemma/3d-printers`.
- Status: `idle`, `current_task=null`, `last_error=null`; last recorded worker ID: `DESKTOP-LVASEUB-3d-printers-equipment-10036`; last heartbeat/start: 13:43:44 UTC.
- Queue: 16 completed and 1 failed task in the last 48 hours; 0 queued/claimed/processing/running tasks.
- Three distinct `worker_started` events were recorded at 13:17:37, 13:24:46 and 13:43:44 UTC. The event log alone does not prove concurrent processes; local Research PC process/supervisor logs are required to establish whether earlier workers exited.
- The latest Anycubic task completed with two page captures retained for review; Gemma extraction timed out for the two-source batch. No candidate was accepted from that batch.

Correction prepared on `fix/gemma-specialist-idle-heartbeat-20261110`, stacked on the 3D Printer parent-lifecycle branch `fix/3d-printer-parent-completion-lifecycle-20261110` (PR #350):
- Add `specialist-idle-heartbeat.mjs` with a 60-second minimum / five-minute maximum cadence derived from the 15-second queue poll.
- Report the actual isolated specialist identity (agent key/name/category), worker ID, poll interval, `stage=idle_poll` and isolated key; do not mislabel a specialist as the generic `gemma-task-worker`.
- Emit only after a successful queue poll and only while idle. Suppress during task processing, queue polling, failed polls, shutdown, and overlapping heartbeat telemetry. A new queue poll waits for any in-flight idle heartbeat to finish, preventing an idle report from racing a task claim.
- Do not heartbeat when the specialist has no enabled agent assignment.
- Keep the existing 45-second active-task heartbeat and queue lease heartbeat unchanged.
- Package the helper and regression test through the updater; run the test in updater preflight/install verification, canonical launcher preflight and GitHub Actions.

Regression tests cover bounded cadence, invalid poll fallback, healthy-idle-only emission, suppression during processing/poll/shutdown/overlap, and preservation of the specialist identity. No Supabase migration, queue mutation, research task enqueue, source-registry change, evidence approval/import, TEST/LIVE transfer, private .env change or Research PC restart is part of this code change.

PR #331 is not a suitable substitute: it is open but GitHub reports it unmergeable, it targets the production generic queue worker and deliberately reports only `gemma-task-worker` / `Task control`. Do not merge it as the specialist fix.

Release gate:
1. CI must pass on this specialist-heartbeat branch.
2. Review/merge the stacked 3D Printer lifecycle work in its recorded order, then promote the heartbeat change to `gemma/3d-printers`.
3. Synchronise the same shared worker/helper/test/updater/launcher/CI files to all seven isolated specialist branches, preserving each branch's one-key `agent.config.json`.
4. Run the existing updater against LIVE only, preserving each private .env; verify each worker's same-ID idle heartbeats at least twice before declaring liveness fixed.
5. Do not enqueue a research task solely to test heartbeat. Once heartbeat acceptance passes, run a separately authorised bounded 3D Printer research acceptance and verify claim, active progress, parent completion and review-queue handover. Evidence remains unapproved pending owner/ChatGPT review.


### Verification update — 10 November 2026

PR #351 is open and ready for review, stacked on PR #350 (which is stacked on PR #349). GitHub Actions Gemma Research Tests run #712 passed all seven workflow steps, including PowerShell syntax, all Gemma Node syntax checks, the full task/website/heartbeat/installer regression test command, and Owner Dashboard JavaScript syntax. The PR remains unmerged and no Research PC installation or worker restart has been performed.

A read-only branch comparison confirmed all seven specialist branches currently have identical shared `task-worker.mjs`, updater and canonical launcher blobs. Their `agent.config.json` files are distinct and correctly retain exactly one category key each. This means the shared heartbeat implementation can be synchronised across the seven branches without replacing their category-specific configuration. The six non-3D branches have not yet been modified.


## 10 November 2026 — merge and branch promotion completed

Owner authorised the release. PR #349 (evidence/telemetry), PR #350 (3D Printer parent completion and aggregate reporting), and PR #351 (isolated specialist idle heartbeat) were merged in that order. Merge commits: `c63fbba74c24b9caac40230ac5f8f6549a611ff1`, `36bb6e452719bece5ded6d4c412a2af899a01a06`, and `24fa2713c3040798f82ecf63fc5ac7023a884acf`.

The merged 3D Printer worker, parent-result summary module and regression tests, specialist idle-heartbeat helper/test, updater, launcher preflight, GitHub Actions test list, manuals, diagnostic roadmaps, project memory and checkpoint have now been promoted onto `gemma/3d-printers`. The 3D Printer one-key `agent.config.json` was not modified. This is repository branch promotion only: the Research PC installation has not yet been updated or restarted, and LIVE runtime acceptance is still pending.


## 10 November 2026 — updater worktree safety and current 3D Printer diagnosis

Diagnostic path: Research PC local clone → `tools/tradeflow-gemma-agent/Update-Gemma-Agent.ps1` → lower-level `Update-TradeFlow-Gemma.ps1`. The category wrapper previously checked the one-key category config, branch name, shared ENV pointer and whether this folder's worker was running, but it did not check `git status`. A dirty clone could pass those checks and then have owner-local edits overwritten by the file updater.

PR #353 adds a fail-closed `git status --porcelain=v1 --untracked-files=all` preflight before the lower-level updater. It aborts if Git cannot inspect the worktree or if any staged, unstaged or untracked paths exist; it reports at most 12 paths and performs no cleanup, stash, reset, pull, fast-forward or deletion. `installer-manifest.test.mjs` now asserts the guard exists and precedes the updater invocation. PR #353 is confined to `gemma/3d-printers`; it is not merged.

Current LIVE baseline: 30 parent tasks (29 complete, 1 failed), 86 product subtasks, 0 queued/running. Latest parent metrics: 48 searches → 10 exact pages → 6 fetched/retained; 4/4 legacy Gemma batches timed out; 6 review writes (3 new, 3 enriched); 78 routes (20 found, 50 empty, 8 route errors). The two direct eBay item-page 403s are additional page-fetch errors, separate from the eight approved-route errors. Queue remains 8 pending (2 UK-new, 6 unclassified, 0 UK-used); active shared evidence 221 UK-new and 21 UK-used.

The first confirmed avoidable discovery defect was 3DJake parent taxonomy incorrectly triggering accessory rejection for genuine Kobra 3 Max V2 pages; the missing Kobra 4 Combo route was also added in PR #348. The 48-to-10 ratio cannot by itself be called 38 lost valid products. The first downstream hard loss in the latest batch was Gemma extraction (4/4 timeouts), while all six raw captures were retained. Current one-page/90-second extraction and page-flow telemetry are not yet runtime-verified on the Research PC.

Worker remains idle; the 13:43:44 status-row timestamp is a worker-start event, not an idle heartbeat. No `idle_poll` heartbeat has been observed after PR #351. The last local snapshot at 16:26 showed PID 10036 absent and only the Codex host Node process; no newer local process snapshot is available. The local clone is 78 commits behind current remote head and dirty, so do not run its updater until local changes are individually reconciled.


### PR #353 verification update — 10 November 2026, 17:39 UTC

PR #353 head `d3942767c7cc47192aa909329654b7d608ac30f5` is open, mergeable and targets only `gemma/3d-printers`; it remains unmerged. GitHub Actions Gemma Research Tests run #789 (`42867112565`) completed successfully: the PowerShell updater syntax check, Node source syntax check, Gemma task/website-playbook test step (including the new dirty-worktree regression), and Owner Dashboard JavaScript syntax check all passed. The check-runs list contains only the Gemma Research Tests job; no Cloudflare preview check was created for PR #353. This verifies repository code/tests, not the Research PC runtime. The dirty local clone has not been updated, and no worker/task/evidence/database action was taken.
