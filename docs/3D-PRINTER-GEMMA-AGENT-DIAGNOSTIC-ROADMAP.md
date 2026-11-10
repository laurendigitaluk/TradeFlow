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

`{query}` means encoded manufacturer and model; `{slug}` means the hyphenated manufacturer and model. eBay UK and Amazon UK are enabled wildcard LIVE sources (`category_slugs=['*']`) and are therefore category-eligible when their `research_scope` matches the task lane. The current source selector explicitly includes the category slug or wildcard; do not infer their exclusion from a category-only query.

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


## 9 November 2026 — 3D Printer updater package and heartbeat-stage hardening

A review of the isolated `gemma/3d-printers` branch found that `task-worker.mjs` imports `task-result-summary.mjs`, but the category-local `Update-TradeFlow-Gemma.ps1` source manifest did not download that helper or its regression test. Its pre-install and post-install test lists also omitted the compact-result test. Running that updater from a clone with this manifest could therefore install a worker whose relative helper import is missing. The updater itself is not self-updating; the local clone must first be fast-forwarded to the current `gemma/3d-printers` branch before the folder-local updater is run.

The 22:42–22:46 LIVE eight-product task also recorded four worker heartbeat events with `details.stage='extraction_batch_started'`. The activity table consequently counted eight `extraction_batch_started` stage events even though only four extraction batches actually started; the other four were heartbeat telemetry. The proposed correction assigns heartbeat events their own `stage='heartbeat'` and preserves the in-progress stage as `active_stage`.

A category-only feature branch, `fix/3d-printer-updater-package-heartbeat-telemetry-20261109`, adds the missing updater files/tests, startup preflight coverage, a manifest regression test that checks every relative task-worker import is packaged, and the heartbeat-stage correction. This is pending review and CI. It has not been installed on the Research PC. No worker, source registry, queue, evidence, catalogue, migration, TEST data or secret was changed.

## Updater acceptance checklist
- Fast-forward the local `Gemma-3D-Printers` clone to `origin/gemma/3d-printers` before running the folder-local updater; the updater script itself is not downloaded by the updater.
- Verify `task-result-summary.mjs`, `task-result-summary.test.mjs`, `agent-telemetry.test.mjs` and `installer-manifest.test.mjs` are in the updater download manifest and both pre/post-install test commands.
- Verify the canonical launcher runs the same deployment-critical tests before starting `task-worker.mjs`.
- On the next bounded LIVE task, confirm heartbeat events have `details.stage='heartbeat'` and carry the real in-progress stage only in `details.active_stage`.
