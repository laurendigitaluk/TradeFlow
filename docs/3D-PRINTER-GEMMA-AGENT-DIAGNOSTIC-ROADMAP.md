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


## 9 November 2026 — 3DJake retailer-taxonomy false positive

LIVE task owner-3d-printers-equipment-1794263685224 completed at 22:35:50 UTC for Anycubic Kobra 3 Max V2 / 4-Color Combo. It returned 6 search results, 14 approved-source route attempts (0 matching, 13 empty, 1 eBay HTTP 403), 1 exact product page discovered and fetched, 1 Gemma batch timeout at 48.4 seconds, and 1 full raw capture (16,285 characters) handed to the LIVE review queue. The new row remains needs_research, unverified_capture, with no evidence type, price, reviewer, approval or import.

The activity log also shows the exact 3DJake Kobra 3 Max V2 Combo page and its Standard sibling rejected as model_variant_skipped. The Combo URL is https://www.3djake.uk/anycubic-3d-printer-and-accessories/kobra-3-max-v2-combo; its title is an exact printer/Combo listing. The matcher applied the accessory keyword "accessories" to the entire URL path, so the retailer's parent taxonomy segment anycubic-3d-printer-and-accessories falsely disqualified a genuine printer product page. The page is discovery/capture only; its search-result price is not accepted as evidence.

PR #341 branch fix/3d-printer-retailer-taxonomy-matcher-20261109 changes accessory rejection to inspect the page title and terminal product slug, not unrelated parent taxonomy segments. Regression coverage verifies that the 3DJake Combo is accepted, its Standard sibling is rejected for a Combo task, and replacement/nozzle pages remain rejected. This is a 3D-printer-only matcher correction; no other category changes.

The two Kobra 3 Max V2 tasks (21:54 batch and 22:34 single-product task) each logged only the two generic Anycubic collection/search routes. Current production source-playbooks.mjs maps the Kobra 3 Max V2 model to two additional direct URLs, and that model-level mapping applies to both Standard and Combo packages. Neither task attempted either direct URL. The 21:54 Standard subtask (package_key standard) is especially diagnostic: it found the official Standard page via collection HTML, fetched it in 890 ms, then rejected it as model_variant_skipped; current production's matcher regression accepts the known Standard title/URL fixture. The activity record does not include the exact runtime title passed to the matcher, so this points to a stale/unreloaded local playbook and likely matcher, but does not prove the precise installed commit. Worker telemetry has no source SHA. After explicit approval for the existing updater, verify the installed source/tests, then run one bounded Standard and one Combo task and confirm both model-specific direct URLs are attempted and the Standard page is not falsely rejected.

No source registry, migration, review approval, shared evidence or catalogue import was changed. TEST remains untouched.


Verification follow-up: PR #341 final code/test head passed GitHub Actions run #594 (104/104 tests). The test specifically accepts the exact 3DJake Kobra 3 Max V2 Combo product page under the retailer's accessory taxonomy while preserving Standard/Combo mismatch and replacement/nozzle rejection. PR remains open and unmerged; Research PC runtime verification remains pending.

## 9 November 2026 — 22:42 Anycubic batch and parent completion failure

The next LIVE batch, owner-3d-printers-equipment-1794264123497, ran eight UK-new/UK-used product subtasks from 22:42:14 to 22:46:56 UTC. Activity-derived totals (the parent result was not persisted) were: 44 per-product search results; 112 approved-source route attempts; 24 matching route links, 80 empty routes and 8 failures (eBay UK HTTP 403); 37 collection-page inspections; 7 exact product links; 9 product-page fetch attempts; 12 model-variant skips; 8 Gemma extraction batches (4 completed, 4 timed out); and 5 retained page captures. The 45-second extraction fallback preserved raw captures.

Two new unclassified raw queue rows were created for Anycubic Kobra 3 Max V2 Combo pages: the Combo 3D Printer page and the ACE 2 Pro Combo page. A prior Kobra 3 Max V2 All-in-One Bundle capture remains pending. The ACE 2 Pro page title is not identical to the task's 4-Color Combo package label; keep it separate for ChatGPT package review. No price or evidence type was assigned. The existing Kobra 4 Standard UK-new review row was enriched; no UK-used capture was created.

The parent task then failed at the final platform_ai_agent_complete_task call with HTTP 400 / PGRST102 "Empty or invalid JSON". All eight product subtasks had emitted their per-subtask completion/handoff events before the parent completion call. The two new queue rows and the existing-row enrichment remain persisted, but the parent task result is empty and its status is failed. Category counters moved from 102 to 110 completed subtasks, 130 to 135 candidates and 68 to 70 queued records. The generic worker status is error with the failed task still in current_task; the category agent is idle. Do not manually mark the task complete or requeue it.

Current production task-worker.mjs serializes a non-empty completion RPC argument object and the LIVE RPC signature matches its p_task_id, p_worker_id and p_result parameters. PGRST102 is raised by PostgREST while parsing the request body, before the SQL function runs. The exact cause cannot be proven without the Research PC's installed source SHA and local request/log details. Because the same worker still omits model-specific Anycubic routes that exist in production, treat the local installation as unverified; do not create a speculative production RPC patch. After explicit approval, update through the existing updater and retest one bounded task, including completion persistence.

The latest 22:42 Standard and Combo Kobra 3 Max V2 subtasks still logged only the two generic Anycubic routes, while current production buildWebsiteSearchRoutes appends two model-specific routes for that model. The Standard page was fetched and then rejected as model_variant_skipped. This continues to indicate that the Research PC is not running the current production playbook/matcher, although its exact local commit remains unknown.

Queue snapshot after this batch: 70 records (28 imported, 37 rejected, 5 needs_research). The five pending rows comprise two typed UK-new records and three unclassified raw Kobra 3 Max V2 captures. Active shared market evidence remains 221 UK-new and 21 UK-used, with 17 inactive UK-new. No new shared evidence, approval or import occurred. TEST and LIVE remain separate.
