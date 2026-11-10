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


## 9 November 2026 — separate Gemma installation boundary

The owner has specified one independent Gemma per category. The 3D Printer implementation now has its own branch `gemma/3d-printers` and its own future local clone `C:\CTFGemma2\Gemma-3D-Printers`. It must not be developed or updated from a shared multi-category Control Centre worker. The isolated worker config enables only `3d-printers-equipment`; its queue claim and in-process guard reject tasks from other categories. The common private ENV is referenced by path only; source, instructions, tests and Git history are local to this Gemma folder/branch.

The shared existing Research PC worker has not yet been replaced. Do not run both old and new 3D Printer instances against the same LIVE queue. The existing eight-product batch `owner-3d-printers-equipment-1794264123497` failed at the final task-completion RPC (HTTP 400, empty/invalid JSON) after 8 product-page fetches and 7 extraction batches; review-queue captures must be checked before switching. The isolated-agent CI passed in run `42716626875`; local PC installation and runtime acceptance remain pending. See `docs/GEMMA-ISOLATED-AGENT-ARCHITECTURE.md`.


## 10 November 2026 — Seven-agent compact completion and one-click update repair

A startup failure on the Research PC showed that the 3D Printer worker imported `src/task-result-summary.mjs`, but the local installed folder did not contain that file. Root cause confirmed in the category updater: `Update-TradeFlow-Gemma.ps1` did not include `task-result-summary.mjs` or its regression test in `$SourceFiles`, so the updater could never install the helper even when the Git branch contained it. The installer also deliberately skipped any existing clone folder, which is not an update operation and left stale installations untouched.

The shared compact completion behaviour is now present on all seven isolated branches: `gemma/3d-printers`, `gemma/gaming`, `gemma/cameras`, `gemma/drones`, `gemma/metal-detectors`, `gemma/mobile-phones`, and `gemma/laptops`. Each worker submits only product identity, evidence references, classification, observed GBP price/currency, review-write references, bounded route failures and metrics to `platform_ai_agent_complete_task`. Raw captures remain in the LIVE review queue; no raw page bodies or long excerpts are duplicated in the completion JSON. Each branch contains the helper and a regression test, and its updater now downloads and runs that test.

The production Gemma Control Centre now has an **Update all workers** action backed by `tools/gemma-agent-isolation/Update-All-Gemma-Agents.ps1`. The orchestrator preflights all seven branch identities, configs, updaters and the shared private ENV pointer before changing any service setting. It requests graceful stop (finish current task), waits up to 60 minutes without force-killing Node, updates each category sequentially using its own branch updater, and restarts only workers that were running before the operation and whose update succeeded. Workers previously stopped remain stopped. It never prints, copies or changes the private ENV file, and it does not write Supabase data, queues, catalogue, tenants, customers, Stripe or Cloudflare settings.

**Deployment status:** GitHub branch sources and production dashboard/orchestrator have been updated. The Research PC has NOT yet run the new all-worker update operation. Do not claim runtime repair complete until the owner installs the updated dashboard and runs Update all workers, then the seven local logs and worker status are checked. A failed individual update must remain stopped and be reported with its log path; do not retry by rerunning the full installer or overwriting private configuration.


Validation addendum — 10 November 2026: after correcting the CI parser to tolerate sparse category-branch checkouts, the full Gemma Research Tests workflow passed on all seven category branches (3D Printers, Gaming, Cameras, Drones, Metal Detectors, Mobile Phones and Laptops). Production run 42730089144 also passed PowerShell syntax checks for the all-worker updater and dashboard, Node syntax checks, compact task-result regression tests and dashboard JavaScript syntax. The earlier category-branch CI failures were caused by the workflow attempting to parse production-only desktop scripts absent from sparse branch checkouts; the workflow now skips only files not present in that checkout. This is a CI path correction, not a runtime worker change. Research PC deployment remains pending.
