# 3D Printer Gemma — website navigation and desktop alignment roadmap

Status: 2026-11-09. Scope: LIVE category `3d-printers-equipment`, branch `3d-printers`. This document is an investigation/navigation map, not a new desktop architecture or a replacement worker.

## 9 November 2026 23:32 UTC — isolated 3D correction set and release ordering

- PR #344 now combines two isolated-branch corrections: raw fallback snippets remain out of normalized condition/availability fields, and 3DJake product matching ignores unrelated parent-category taxonomy. It changes agent.mjs, agent-speed.test.mjs and source-playbooks.test.mjs only on gemma/3d-printers.
- GitHub Actions run #42721156282 passed 110/110 tests with zero failures. PR #344 is open/mergeable, unmerged and undeployed.
- Production counterparts: PR #343 (queue-field mapping) and PR #341 (3DJake matcher) remain open. Draft PR #345 promotes gemma/3d-printers to production and contains compact task-result summary/direct-route tests, but does not yet include PR #344. Review/merge order must ensure PR #344 lands on gemma/3d-printers before the promotion PR is merged.
- PR #345's compact summary test reduces a fixture with 100,000-character raw pages to a parent result below 5,000 characters. Run #42720715939 passed 106/106. This is not a LIVE completion retest.
- Isolated 3D worker started 23:20:07 UTC, before compact-summary commits at 23:26 UTC. Do not assume the running process has loaded the new task-worker code. Verify local source SHA after explicit approval.
- Generic worker and isolated 3D worker remain idle; generic scope is not visible. Do not queue another task until process/config scope is reconciled.

## 9 November 2026 23:28 UTC — compact parent completion summary on isolated branch

- The isolated gemma/3d-printers branch advanced to ca38a0d2fbc706e1e48b259d992d83975c91537d. It adds src/task-result-summary.mjs and its regression test, and updates task-worker.mjs to submit a compact summary rather than the full outputs array.
- The summary retains product identity, source/capture URLs, review classification, price observations, queue-write references, research/route metrics and bounded failures. It excludes raw page captures and long excerpts already persisted in the review queue, and logs the serialized result byte count before the completion RPC.
- The fixture includes 100,000-character raw captures and asserts a summary below 5,000 characters. This is a targeted mitigation for the previous parent PGRST102, not a LIVE runtime retest.
- PR #345 (draft/open, base production, head gemma/3d-printers) promotes the isolated branch. GitHub Actions run #42720715939 was in progress at this checkpoint. No merge/deployment.
- The isolated 3D worker started at 23:20:07 UTC, before the compact-summary commits at 23:26 UTC. It must not be assumed to have loaded the new task-worker code until the approved updater/restart is completed.
- The branch also adds direct Anycubic UK route regression tests and includes task-result-summary.test.mjs in its workflow.
- Generic worker and isolated 3D worker both report idle; generic enabled scope is not visible. No new task until the local process list/configuration is reconciled.

## 9 November 2026 23:23 UTC — isolated and generic poller state

- Generic worker_started at 23:16:18 UTC: DESKTOP-LVASEUB-129276.
- Isolated 3D worker_started at 23:20:07 UTC: DESKTOP-LVASEUB-3d-printers-equipment-128700, isolated_agent_key=3d-printers-equipment.
- A second generic worker_started event appeared at 23:23:00 UTC: DESKTOP-LVASEUB-108588. No worker_stopped event is recorded for 129276.
- Current parent-task query: 0 queued/running exact-branch tasks; 28 completed parents, 1 failed parent. Both latest status rows report idle/current_task null.
- These are startup/status timestamps, not periodic idle heartbeats. Generic enabledAgentKeys are not exposed in LIVE telemetry, so overlap with the isolated 3D poller cannot be ruled out. Do not queue another 3D task until the Research PC process list and both local configurations are checked. Do not stop/restart workers from this watch.


## 9 November 2026 — latest eight-product Anycubic batch and fallback field mapping

### LIVE task/worker state
- Exact branch parent tasks: 29 total; 28 completed, 1 failed; 0 queued/running.
- Failed parent: owner-3d-printers-equipment-1794264123497. All 8 product subtasks emitted task_completed events and their queue writes persisted, then platform_ai_agent_complete_task returned HTTP 400 / PGRST102. The parent result is absent. Do not treat the parent as completed or queue a duplicate automatically.
- Isolated 3D worker event: 23:20:07 UTC, worker DESKTOP-LVASEUB-3d-printers-equipment-128700, status idle, no active task.
- Generic worker event: 23:16:18 UTC, worker DESKTOP-LVASEUB-129276, status idle, no active task. The category row reflects the isolated worker; the generic worker's enabled scope is not present in telemetry. Both pollers are currently idle, but verify local legacy config.json / enabledAgentKeys before another 3D task. Production shared worker can use the unscoped claim RPC when no desktop config path is set; otherwise it uses the configured category list.
- The new isolated worker ID and isolated_agent_key match the isolation implementation in PR #342. The exact installed source SHA is not exposed, and PR #342 remains a draft; do not assume its branch commit without checking the Research PC.

### Latest eight-product task metrics
- 44 search results; 112 approved-source route attempts; 24 route matches; 80 empty routes; 8 failed routes (one eBay UK HTTP 403 per subtask); 12 approved sources probed per subtask; 24 pagination pages followed; no collection or product-page HTTP fetch errors.
- 9 exact product pages discovered; 5 inspected/fetched; 5 raw captures retained; 4 Gemma extraction batches, all 4 timed out at the 45-second bound. Raw fallbacks were retained.
- Four subtasks returned zero search results. Kobra 3 Max V2 Standard found one page but the exact-model guard rejected the Anycubic page before price extraction. 3DJake Kobra 3 Max V2 Combo pages were rejected because the retailer's parent URL path contains the word accessories; PR #341 addresses that separate matcher defect and remains open.
- Compared with the prior five-product repeat (18 search results, 3 pages discovered, 1 fetched/captured), this eight-product batch improved to 44 search results, 9 discovered, 5 fetched and 5 captured.

### Review queue and first post-capture defect
- Queue: 70 rows; 28 imported, 37 rejected, 5 needs_research. Of the five pending rows, 2 are labelled uk_new (Kobra 4 Standard £159 and Bambu Lab A1 £215) and 3 are unclassified raw Kobra 3 Max V2 Combo captures. No pending uk_used capture from this batch.
- The three unclassified raw captures have full page lengths 19,514 / 16,120 / 16,285 characters, but their top-level item_condition lengths are 1,282 / 1,281 / 1,282 and availability lengths 780 / 1,040 / 1,040. They remain needs_research, with no review, approval or import timestamps.
- Root cause confirmed in production agent.mjs: fallbackPageCapture() stores up to ten context snippets in item_condition_text and availability_text; the queue row builder copied those raw snippets into normalized item_condition and availability fields.
- PR #343 adds a 3D-only mapper that accepts only concise explicit normalized values up to 100 characters. Raw snippets and full page stay in raw_payload.evidence / page_capture. Non-3D category mapping remains unchanged. Three regression tests cover the boundary. PR #343 is open; no LIVE rows were modified.
- Earliest losses remain at search for four product/package subtasks (zero results), then exact-model matching for Kobra 3 Max V2 Standard and the 3DJake Combo parent-category false positive. Gemma timeouts occur later; raw capture is retained. The parent PGRST102 is a separate post-subtask completion failure and remains unexplained without local request-body/log evidence.

### Open review items
- PR #341: 3DJake retailer parent-path matcher correction, open/mergeable.
- PR #342: independent category-agent architecture, draft; CI passed. It is broader than this 3D-only diagnostic and has not been merged. Runtime now shows an isolated 3D worker, so update the PR's stale statement that no isolated clone is installed only after the owner confirms the Research PC install.
- PR #343: 3D-printer fallback field separation, open; CI pending at checkpoint creation.
- Do not stop either worker, enqueue another task, change source registry, or alter other categories as part of this repair. No approvals/imports or TEST/LIVE data transfers.

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
