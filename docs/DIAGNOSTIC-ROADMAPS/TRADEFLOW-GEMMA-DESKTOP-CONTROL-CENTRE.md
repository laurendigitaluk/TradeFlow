# Diagnostic Roadmap — Gemma Windows Desktop Control Centre

Date: 9 November 2026
Scope: Windows Research PC desktop launcher, seven specialist switches, visible Control Centre and background supervisor. This is a diagnostic map, not a copy of implementation code.

## Expected user flow

1. Owner double-clicks one specialist shortcut, e.g. Gemma - Gaming.lnk.
2. Shortcut target is %SystemRoot%\System32\wscript.exe; arguments call Launch-TradeFlow-Control-Centre.vbs, pass the local UI script and the canonical -AgentKey, plus -EnableAgent.
3. VBS starts Windows PowerShell with window style 0. The WinForms Control Centre is the only visible app window.
4. The UI writes the selected canonical key into local config.json, enables the shared service and starts the existing scheduled supervisor if needed.
5. Named mutex Local\TradeFlowResearchControlCentre enforces one visible dashboard. Existing dashboard refreshes config/status every three seconds.
6. Scheduled task TradeFlow Gemma Research Supervisor runs Run-TradeFlow-Gemma-Supervisor.ps1 hidden. It uses the existing local Gemma installation and private .env path.
7. One Node queue worker polls TradeFlow LIVE and claims only tasks whose complete agent scope is enabled through service-role RPC platform_ai_agent_claim_task_for_agents(text,text[],integer).
8. Worker updates local status JSON and LIVE agent status/activity records. It does not create one process per specialist.

## Real code entry points

- Desktop shortcut creation/update: tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1.
- Canonical specialist list: tools/tradeflow-gemma-desktop/agents.json (seven keys: 3d-printers-equipment, gaming-consoles-accessories, drones, metal-detectors, mobile-phones, laptops, cameras).
- Hidden launcher: tools/tradeflow-gemma-desktop/Launch-TradeFlow-Control-Centre.vbs.
- Visible UI and local state management: tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1.
- Supervisor: tools/tradeflow-gemma-desktop/Run-TradeFlow-Gemma-Supervisor.ps1.
- Existing worker startup/updater: tools/tradeflow-gemma-agent/Start-TradeFlow-Gemma.ps1 and Update-TradeFlow-Gemma.ps1.
- Desktop runtime docs: tools/tradeflow-gemma-desktop/README.md.

## Local files and settings

- %LOCALAPPDATA%\TradeFlow\ResearchControlCentre\agents.json: canonical UI definitions.
- config.json: global service flag and enabled canonical agent keys.
- status.json: local worker state, activeAgentKeys and activeTaskKey.
- service.json: existing Gemma install path, private .env path, LIVE environment marker. Do not print secrets or rewrite the private .env.
- logs\: supervisor/worker stdout and stderr.
- Windows Task Scheduler task: TradeFlow Gemma Research Supervisor.
- Windows default terminal setting: on this PC, System > Advanced > Terminal > Windows Console Host prevented Windows Terminal from showing the hidden PowerShell session. This is an OS presentation setting, not a backend dependency.

## Supabase / LIVE data flow

- Project: LIVE gxsrajtqzdjvmceqcpgv; TEST remains separate.
- Claim RPC: platform_ai_agent_claim_task_for_agents(text,text[],integer), service-role-only, SECURITY DEFINER, search_path public/private. Desktop mode must not fall back to the generic unscoped claim RPC.
- Queue: public.platform_ai_agent_tasks.
- Observability: public.platform_ai_agent_status and public.platform_ai_agent_activity.
- Canonical desktop specialist keys must be used for UI toggles. LIVE status currently contains historic alias rows including 3d-printers and gaming-consoles; do not count them as extra switches.
- LIVE status inspection on 9 November showed canonical specialist rows idle; local activeAgentKeys was empty during the owner's diagnostic. This is a point-in-time observation, not a permanent state.
- No dedicated project-memory/checkpoint table was found in the inspected LIVE public schema. Repository PROJECT-MEMORY and CHECKPOINTS are the durable project records.

## Failure points and known fixes

| Symptom | First place to inspect | Known cause/fix |
|---|---|---|
| Extra black console | Windows Terminal default terminal + shortcut target | VBS launcher exists; on this PC selecting Windows Console Host stopped the black window. |
| Duplicate Control Centre | UI named mutex | One-instance mutex is in the production UI script. |
| Specialist shortcut does not select category | Shortcut arguments and local config | Check canonical -AgentKey and config enabledAgentKeys; existing UI refreshes every three seconds. |
| Only three generic checkboxes visible | Installed UI script version and card layout | Local agents.json and config both contained seven; production UI changed to a vertical scrollable named-card list. PC deployment still pending. |
| Enabled but not running | local status.json activeAgentKeys and LIVE task status | Enabled means eligible; only RUNNING means an active task exists. One worker is intentional. |
| Backend update required | LIVE scoped RPC and worker logs | Do not fall back to generic unscoped claim; investigate migration gate. |

## Safe repair procedure

1. Inspect local shortcut target/arguments, agents.json, config.json, status.json, scheduled-task action and installed UI script before editing.
2. Compare local desktop files with current production branch; do not assume the full installer is needed.
3. For a UI-only change, close the visible Control Centre (this does not stop the supervisor), replace only the local UI PowerShell script, then reopen the existing main shortcut.
4. Never rerun the full installer for a UI-only fix: it invokes the Gemma worker updater and has active-worker safety gates.
5. Do not terminate the Node worker, edit .env, alter the LIVE queue, change source registry, or write to product/evidence tables for a desktop presentation defect.
6. Verify all seven named rows, per-specialist enable/disable, enabled/active counts, state labels, one visible dashboard, no extra console and unchanged scheduled supervisor.

## Current checkpoint

- Shortcut/VBS correction applied locally and verified for Gaming.
- Windows Console Host selected by owner; black window stopped returning.
- All seven canonical keys enabled locally; no active agent keys at the diagnostic instant.
- Production UI display correction committed as c720c245fed72174957a1a2d93fed5fc3e9668f8.
- Updated UI script has not yet been copied to the Research PC; PC acceptance remains pending.


## Follow-up UI failure — first two cards clipped / no scroll

Observed in the owner's screenshot after the FlowLayoutPanel implementation: only the last five canonical cards were visible in a narrow side-by-side Control Centre window. The first two (3D Printers and Gaming) were clipped and vertical scrolling was unavailable. Agent definitions/config were already verified to contain all seven keys; this is a WinForms layout/container failure, not a task-claim or Supabase problem.

Corrected production file: tools/tradeflow-gemma-desktop/TradeFlow-Research-Control-Centre.ps1, commit 55bba312db21fe1e0a667a4c38cd82d63cad2add. It now uses a standard Panel with AutoScroll=true, explicit vertical card positions spaced 108 pixels apart, AutoScrollMinSize calculated from the seven-agent count, responsive card widths and a reset to the top scroll position. Deployment remains pending on the Research PC. Close only the visible dashboard, replace only the UI script, reopen the existing shortcut, and verify all seven cards by scrolling. Do not rerun the full installer, stop the supervisor, alter config, or touch LIVE queue/evidence/source data for this UI defect.


## Second scroll attempt failed; dedicated scrollbar implementation

Owner screenshot after installing the Panel AutoScroll version still showed only five cards and no usable scroll. Treat that build as failed; do not repeat close/reopen without replacing the script. Production now uses a dedicated VScrollBar adjacent to a non-scrolling card panel. Card coordinates are explicitly derived from index and scroll offset; content height and viewport determine the scroll range; widths adapt to resize. Set LargeChange before Maximum, clamp Value to Maximum - LargeChange + 1, and guard programmatic ValueChanged events. Commits: 1871ec0d062377ff5fff96fedbfa45eda9e828a7 and ab2df7866072b0e21d69db5fd4522e18613ba610. PC deployment/verification pending. Replace only local UI script; do not reinstall, restart worker or modify LIVE queue/evidence.


## Root-cause layout repair — explicit scrollbar geometry — 9 November 2026

The owner supplied another screenshot after installing the prior dedicated-scrollbar build; it still showed only Drones, Metal Detectors, Mobile Phones, Laptops and Cameras, with no visible scrollbar. The previous correction was therefore not accepted. Production source inspection identified a concrete layout weakness: the card canvas used DockStyle.Fill while the scrollbar used DockStyle.Right in the same parent; forcing scrollbar.Visible=true did not reserve a guaranteed on-screen rectangle or prevent the fill canvas from occupying/covering its area. The startup reset also depended on deferred form display/layout timing.

Production commit c0b9f980b164f7eacc76f0974e921562d9ccfe32 replaces docking for these two sibling controls with explicit bounds on every list-host resize: card canvas occupies host width minus 24 px; scrollbar is positioned in the reserved 24 px strip at the right and brought to front; both controls use the full list-host height. The scroll range is computed from the seven-card content height and actual card viewport, offset is clamped and reset to zero on form display, and layout/value-change recursion is guarded. Card positions remain based on canonical agent index. This is a UI-only correction.

The screenshot confirms the PC still displays the old broken result; the new commit has not yet been installed or visually verified on the Research PC. Do not ask for another close/reopen of the same local script. The next PC update must replace only TradeFlow-Research-Control-Centre.ps1 from production after closing the visible Control Centre. Do not rerun the installer, stop/restart the supervisor, edit config/.env, or change LIVE database/queue/evidence. Verify first card is 3D Printers, second is Gaming, all seven appear by dragging the visible scrollbar, and the last card is Cameras. Supabase TradeFlow LIVE project gxsrajtqzdjvmceqcpgv remains ACTIVE_HEALTHY; no database writes were made for this desktop UI repair.


### CI verification for explicit-bounds repair — 9 November 2026

GitHub Actions workflow `Gemma Research Tests`, run 42624656405, completed successfully for UI commit c0b9f980b164f7eacc76f0974e921562d9ccfe32. This verifies the repository's automated checks for that commit; it does not constitute visual acceptance on the owner's Windows PC. Local PC deployment and screenshot verification remain outstanding.


## Scrollbar failure closed out with fixed seven-agent grid — 9 November 2026

The owner confirmed that the installed explicit-bounds VScrollBar build still displayed only five specialists and no usable scrollbar. Local diagnostics showed the installed UI source contained the dedicated VScrollBar/SetBounds implementation, while the visible dashboard remained clipped. Repeatedly replacing scrollbar variants is not an acceptable repair. The UI has therefore been redesigned as a fixed two-column, four-row grid of compact named specialist cards. All seven specialists are rendered from the canonical agents.json list; each retains its independent checkbox and status. The grid recalculates card positions and widths on resize and does not use AutoScroll, VScrollBar, or scrollbar z-order. This is a desktop presentation-only change. It preserves config.json, status.json, the scheduled supervisor, worker, private .env, LIVE queue, source registry, and product/evidence data. Verify all seven names at once in the owner's side-by-side window, test each switch independently, and confirm enabled/active counts and background service status. Do not rerun the full installer.


## Fixed-grid dock-order correction — 9 November 2026

The first fixed-grid deployment showed only three cards in the visible area, with earlier cards hidden behind the header. Root cause: Windows Forms processes docked controls in z-order. The Fill-docked listHost was added after the Top-docked header, button panel and note, so it was laid out first and claimed the full client area; subsequent Top controls overlaid its upper card rows. The correction explicitly sends listHost to the back of the form's control z-order with SetChildIndex(listHost, Controls.Count - 1), so Top-docked controls reserve their height before the Fill host receives the remaining client area. The seven-card two-column/four-row grid remains; no scrollbar is reintroduced. UI-only change; preserve all LIVE research components and configuration.


## Correction: Fill panel must be first in WinForms z-order — 9 November 2026

The 9 November 2026 SetChildIndex correction was reversed. It sent the Fill-docked listHost to the last control index, which causes it to be laid out before the Top-docked controls and allows the header/toolbar/note to overlay the first grid rows. Microsoft WinForms layout documentation confirms that dock layout is z-order dependent and a Fill control must be ordered so edge-docked controls reserve their space before the Fill area is calculated. The correct code is `$form.Controls.SetChildIndex($listHost, 0)`, not `$form.Controls.Count - 1`. The owner screenshot showed only the last three grid entries, matching the first grid rows being covered. New repair branch `fix/gemma-control-centre-fill-dock-order-20261109` contains this one-line correction. The fixed two-column grid remains; no scrollbar is used. Await CI, merge, then update only the local UI script with a guarded one-block PowerShell deployment. Do not change the worker, config, .env, LIVE queue or Supabase data.


## Final Research PC acceptance — 9 November 2026

The owner has now installed the merged production Control Centre script and supplied a confirming screenshot. The screenshot shows all seven canonical specialists simultaneously in a two-column grid: 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, and Cameras & Lenses. Each has its own visible Enabled checkbox and WAITING status. The toolbar reports Specialists enabled: 7 / 7 and Active research tasks: 0. The header reports the background service connected / waiting for website tasks. The separate PowerShell window shows the final guarded deployment completed with CORRECTED CONTROL CENTRE INSTALLED and a SHA256 hash.

Final production UI source was rechecked after merge: it renders cards by iterating the canonical seven-agent $Agents list, uses the two-column grid ($columns = 2), contains the correct WinForms docking order ($form.Controls.SetChildIndex($listHost, 0)), and contains neither VScrollBar nor AutoScroll. This confirms the final layout no longer depends on a scrollbar. The local backup TradeFlow-Research-Control-Centre.ps1.backup-verified was created by the final deployment block.

Root cause was the WinForms docking order: the Fill-docked list host had been moved to the wrong z-order, allowing it to claim the full client area and be overlaid by the Top-docked header/toolbar/note. The correct fix is to put the Fill host at control index 0 so the top-docked controls reserve their area first. Previous scrollbar/AutoScroll implementations and the reversed dock-order change are failed approaches and must not be reintroduced.

Acceptance is complete for the desktop display. No LIVE worker, supervisor, local agent configuration, private .env, research queue, sources, product catalogue, evidence or Supabase data was changed by this final UI repair. LIVE remains separate from TEST. The only observed runtime state at acceptance was all seven specialists enabled, zero currently active research tasks, and the background service connected/waiting; WAITING does not mean a research task is running.

Supabase LIVE schema inspection found no public project-memory/checkpoint table. The authoritative project record for this repair is maintained in the repository's PROJECT-MEMORY, CHECKPOINTS, both operating manuals, backend operations manual and diagnostic roadmap.


## 2026-11-09 LIVE 3D-printer worker latency, raw-capture and evidence-multiplicity repair

### Observed LIVE failure and first failure point
- Controlled task: \`owner-live-3d-printers-worker-check-neptune4pro-20261109-1445\`, task ID \`2d5f202f-d37e-4180-ba54-7274d99f4c98\`, Elegoo Neptune 4 Pro / Standard Printer / \`uk_both\`.
- LIVE worker: \`DESKTOP-LVASEUB-78412\`; one task attempt, completed, no queue exception.
- End-to-end elapsed: 1,156.5 seconds (19 minutes 16.5 seconds).
- Discovery was functioning: 29 search results, 12 approved source domains probed, six exact product-page candidates found; three direct product pages fetched successfully. Three eBay product fetches returned HTTP 403. The route stage recorded 26 attempts (11 found, 9 empty, 6 errors).
- First failure point was local Ollama/Gemma extraction, not queue claim or source search. The two-page first batch timed out at the 300,000 ms request timeout. The old recovery path then tried each page individually, sequentially, with the same five-minute timeout; one retry hit the output-token limit and another timed out. The final one-page batch returned a structured observation.
- Full raw pages were in the task result. All three review writes were correctly duplicate-skipped against existing imported captures for the same source URL. Therefore this run found evidence, but added zero new review rows; that is not proof that the search returned nothing.
- LIVE status/index checks: the review queue is unique on \`dedupe_key\`; shared market evidence is unique on \`(source_name, source_record_key)\`, not on product/evidence_type. It has a non-unique \`(master_product_id, evidence_type, observed_at DESC) WHERE is_active\` index. A LIVE aggregate showed maximum active same-type records per product of 10 UK-new and 20 UK-used. Do not add a product/type uniqueness constraint or collapse records.

### Repair in this branch (not yet deployed)
- Preserve the 3D-printer Gemma/Ollama path. Do not change \`isCaptureOnlyResearchTask\`: Gaming is capture-only; 3D printers continue to use Gemma as in the restored PR #320 behaviour.
- New \`getGemmaExtractionTimeoutMs(task, env)\`: 3D printer calls default to 45,000 ms and are capped at 45,000 ms; an optional \`GEMMA_3D_EXTRACTION_TIMEOUT_MS\` can only reduce or retain the bounded maximum. Non-3D categories retain their existing \`OLLAMA_TIMEOUT_MS\` handling.
- Remove sequential per-page retry after a 3D batch timeout/invalid response. Each batch receives one bounded attempt; every input page immediately becomes a full raw fallback capture on failure, then extraction proceeds to the next batch and the shared task can hand off.
- Keep the existing two-page 3D batch size. Model output budget is reduced to 768 tokens, the prompt page excerpt to 1,800 characters, and Gemma's structured \`price_observations\` to at most eight compact distinct observations. The supplied visible-price preview is limited to 12 items to reduce prompt size. The complete fetched page, all deterministic visible GBP amounts and their contexts remain in the raw ChatGPT capture; the compact Gemma pass is supplementary, not authoritative.
- The full source text must remain in both \`source_excerpt\` and \`page_capture.captured_text\` for 3D printers, whether Gemma succeeds or fails. ChatGPT must receive the raw page even when local extraction fails.
- Gemma is the local fetched-page reader, not the web crawler. The single worker performs deterministic approved-source discovery using \`source-playbooks.mjs\`; each fetched page now carries that site's approved navigation note into the Gemma prompt. Gemma must not browse, invent URLs, decide suitability or reject a page. ChatGPT decides evidence relevance and product/package allocation.

### 3D-printer website routes and page-reading instructions
- Creality UK (\`store.creality.com\`): UK search plus verified FDM 3D-printer collection. Only the Ender-3 V3 model family gets the Ender-3 V3 collection route; K1/K1 Max/K2 must not probe it. Use Shopify collection JSON only for discovery and fetch exact individual machine pages.
- Bambu Lab UK (\`bambu-lab-uk.myshopify.com\`): UK storefront search and 3D-printer collection; direct exact product page is evidence. Read selected standalone versus Combo/AMS options and their prices separately.
- Anycubic UK (\`uk.anycubic3d.com\`): UK 3D-printer collection first, exact product search second; read the selected standalone versus Combo/ACE configuration, GBP amount and stock separately.
- ELEGOO UK (\`uk.elegoo.com\`): new tasks use \`/collections/fdm-printers\`; used tasks use \`/collections/pre-owned-3d-printer\`. Both are discovery pages only; follow direct product pages and preserve stock/condition. The LIVE source row remains \`research_scope=new_uk\`; migration \`20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql\` is included in this PR but remains unapplied. Apply only through the approved release sequence.
- Uni3Dverse (\`uni3dverse.co.uk\`): one curated used/refurbished printer search route; capture asking price, grade, stock, accessories, repair history, UK location/delivery and warranty. No generic fallback.
- 3DGBIRE (\`3dgbire.com\`): dedicated \`/collections/reconditioned-3d-printers\`; retain reconditioned/refurbished/ex-demo condition, GBP price, stock and warranty. Exclude scanner stations, parts and consumables.
- 3D Prima (\`3dprima.co.uk\`): one exact manufacturer/model retailer search route; follow the direct product path and inspect price, VAT, stock, selected package and SKU/EAN. Do not treat crossed-out/30-day reference values as current asking price.
- 123-3D UK (\`123-3d.co.uk\`): lane-specific printer or refurbished-printer collection only, with collection pagination, exact brand/model matching and direct product-page verification.
- iDig3DPrinting (\`idig3dprinting.co.uk\`): WordPress/WooCommerce 3D-printer product category only; paginate and follow exact printer product pages. Do not use broad shop/search results.
- 3DFLO (\`3dflo.com\`): dedicated 3D-printer product category only; avoid broad shop pages that mix printers with filament, STL files, spare parts and upgrades.
- 3DJake UK (\`3djake.uk\`): one UK search route then the direct product page; verify UK GBP, selected package, stock and condition.
- Gumtree UK (\`gumtree.com\`): one exact-model UK advert search; use active individual adverts only and retain price, condition, location, date and included accessories. Exclude wanted, sold/expired, parts and consumables.
- SecondHand.org.uk (\`secondhand.org.uk\`): dedicated second-hand 3D-printer category/search and direct live listings; capture asking price, condition, seller/location and availability.
- eBay UK (\`ebay.co.uk\`): one exact-model listing search; only current active individual listings, not sold/completed comps. A 403 means unavailable; do not spend time on duplicate route variants.
- Amazon UK (\`amazon.co.uk\`): one exact-model search; evidence only from direct ASIN page with selected seller/offer, configuration, GBP price, condition and stock. Do not use result-card prices.
- Duplicate generic \`/search?q=\` fallback routes have been disabled for these explicit 3D-printer website playbooks. Route failures should not be retried through a list of equivalent generic paths.

### Evidence multiplicity and deduplication contract
- Keep the established capture key formula: SHA-256 over manufacturer, model, package key and exact source URL. Same page/product/package is idempotent on repeat; another retailer, marketplace or listing URL generates a separate review capture for that same product.
- Do not dedupe on product ID + evidence type. Distinct source pages must be allowed to create multiple UK-new or multiple UK-used observations for one catalogue product.
- One fetched page may itself contain multiple price options (machine-only, Combo, crossed-out, open-box, accessory, shipping, etc.). Preserve the entire page, all raw GBP mentions and price contexts together; Gemma's compact output is supplementary and ChatGPT allocates the valid option to the exact package/condition.
- Review rows remain unverified raw captures until ChatGPT review. No research job may approve or import catalogue evidence automatically.

### Test and deployment gate
- Regression coverage adds bounded timeout calculation, one-call/no-retry timeout behaviour, full raw page fallback for every page, page-specific website navigation in the prompt, route-count/no-generic-fallback tests, and distinct source URL keys for the same product.
- PR #332 remains an open repair branch. Its CI must pass before merge. No LIVE source row, migration, review queue, catalogue or shared evidence was changed by this code work.
- Deployment remains a separate step: merge only after CI/review; apply the ordered ELEGOO scope migration through the approved release process; install/update the single Research Control Centre worker while preserving its existing private \`.env\`; then run one bounded LIVE 3D-printer smoke test and verify it hands off raw captures, frees the shared queue and shows multiple independent source records in Research awaiting review.


## Release update — 9 November 2026 (PR #332 merged to LIVE production)

- PR #332 was reopened at the owner's request and squash-merged into \`production\`.
- Merge commit: \`5887f8fadae09a51cdb0048eaef67d8a23dcf0ca\`.
- Production GitHub Actions run \`42684047133\` (“Gemma Research Tests”) completed successfully on the merge commit.
- LIVE Supabase migration \`20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql\` was applied via the approved Supabase migration path and recorded as migration version \`20261109193254\` / name \`enable_elegoo_uk_3d_printer_used_lane_20261109\`.
- The existing LIVE ELEGOO UK source row is enabled with \`research_scope='all'\`; there is still only the existing source row, no duplicate.
- The production repository now contains the bounded 45-second 3D-printer Gemma batch timeout, no sequential single-page timeout retries, full raw-page fallback, the compact extraction prompt and website-specific 3D-printer routes.
- **Research PC installation remains pending.** Merging to GitHub and applying the LIVE database migration do not update the local Node worker already running on the PC. The connected Control Centre must be stopped after the current task, then the current production \`Update-TradeFlow-Gemma.ps1\` run against the existing paths in \`%LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre\\service.json\`. This updater validates both LIVE/TEST targets in the existing private \`.env\`, backs up installed source, downloads production code, runs Node syntax and test suites, and does not edit the private \`.env\` or specialist selection in \`config.json\`.
- After local update, restart the existing Control Centre background service and confirm it connects to LIVE. Then run a single bounded 3D-printer acceptance task. Acceptance requires a short extraction stage, full page captures whether Gemma succeeds or times out, evidence records from distinct qualifying source pages, preservation of multiple UK-new/UK-used records for one product, and completion/release of the shared queue so it can claim the next category task.
- No TEST project schema, data, queue, sources or customer/tenant rows were changed by the production migration.


## 9 November 2026 — Post-restart LIVE 3D-printer acceptance

- Research PC worker restarted successfully as `DESKTOP-LVASEUB-126848`; the LIVE worker claimed and completed bounded tasks. No TEST worker or TEST data was used in this acceptance batch.
- 3DJake UK Bambu Lab A1 Standard direct page fetched and fully retained (13 GBP mentions and the full page). One Gemma call timed out; the raw capture fallback ran. The capture was duplicate-skipped because the same URL already had an imported active UK-new £215.61 record. No duplicate evidence was created.
- A second independent retailer page, 3D Prima UK Bambu Lab A1 Standard, fetched and staged successfully. Task `owner-live-3d-printers-independent-source-3dprima-bambu-a1-20261109-2040` completed in about 60 seconds; one page captured; one Gemma call timed out; raw page preserved. LIVE review row `8c18a064-c2e3-4bfd-a1a9-5660254acec7` remains `needs_research` and unimported. ChatGPT classified the page as UK-new £215.00 GBP, New, In Stock (50+), VAT included / delivery excluded; £239.00 is the previous/reference price. The same URL already has active shared evidence at £215.00, so this is a refreshed stock-confirmation candidate, not a new duplicate price record.
- Anycubic Kobra 3 Max V2 official product page was discovered but rejected by `matchesTaskModel`: its exact product title includes the feature phrase “Full-Metal Hotend”, and the generic accessory matcher treated the word `hotend` as an accessory. PR #337 removes that over-broad single-word rejection while retaining explicit replacement/accessory checks; regression test added. GitHub Actions run #42697121803 passed 103/103 tests. PR #337 is open, mergeable, unmerged and not deployed.
- Creality Ender-3 V3 KE official product URL was fetched but the Research PC received a redirect to the unrelated SparkX i7 page; the exact-model guard correctly rejected it. Creality collection discovery also returned Shopify products JSON HTTP 404 for both configured collection routes. Do not weaken the exact-model guard. Re-verify the canonical product/collection route and the locale-aware Shopify API behaviour before changing the Creality playbook.
- Gemma extraction still times out at roughly 45–50 seconds on these product pages. Full raw-page fallback and ChatGPT review hand-off are working. Do not change the model, context window or timeout defaults without a separate measured test.
- No product catalogue or shared-market-evidence rows were imported or modified in this acceptance batch. The only review-queue change was ChatGPT enrichment of the new 3D Prima capture; its status remains `needs_research`. No source registry, RLS, migration, tenant, customer, TEST or Stripe data was changed.
- Keep all other research categories waiting. Next steps: (1) complete and deploy the Anycubic matcher fix through the approved worker update process; (2) investigate Creality's redirect and Shopify collection 404 separately; (3) run one post-update Anycubic acceptance task and one Creality task; (4) only after those pass, repeat the established 3D-printer method for the next category.


## Unified local control dashboard — 9 November 2026

The initial isolated-agent installer created only a text-mode Gemma Switchboard. That switchboard launches category workers but does not provide a dashboard, stop controls or updater controls. It is not a suitable ongoing management interface. The owner correctly reported that the former shared Research Control Centre does not control these independent installations; do not direct the owner back to that legacy dashboard.

A new Windows Forms dashboard is provided at `tools/gemma-agent-isolation/Gemma-Control-Centre.ps1`. The isolated-agent installer now downloads it into `C:\CTFGemma2\Gemma-Shared\Gemma-Control-Centre.ps1` and creates both `Gemma Control Centre.lnk` and a compatibility `Gemma Switchboard.lnk` that open the same single-instance dashboard. Seven rows show the independent agent, expected Git branch, local status, current task and last update. Each row has Start, Stop, Update and Logs actions. Refresh runs every 2.5 seconds.

The dashboard uses each isolated clone's own `agent.config.json`, `status.json`, `src\task-worker.mjs`, launcher and updater. Start launches only that category's local worker hidden and captures stdout/stderr in its own log folder. Stop sets only that agent's `serviceEnabled=false`; the worker checks the flag between queued tasks and finishes its active batch before stopping. It does not terminate Node or interrupt an active research task. Update is disabled while that agent's worker is running and invokes only its own `Update-Gemma-Agent.ps1` for its configured branch. Branch mismatch blocks start and update. No shared supervisor, global multi-category worker, or category-to-category code sync is introduced.

The dashboard is local Windows UI; it does not need to change Supabase schema, queue rows, source registry, evidence or credentials. The LIVE status table remains useful for remote verification, while per-agent local status files provide immediate process control. A one-instance mutex prevents duplicate dashboard windows. The installer skips existing clone folders and does not stop or overwrite running workers; it updates only the shared dashboard script/shortcuts and verifies the shared ENV pointer.

CI must parse the dashboard PowerShell script. PC installation and visible acceptance remain pending until the owner reruns the updated installer from the architecture branch after CI passes. The current independent 3D Printer worker must not be stopped merely to install the dashboard; installation is designed to leave existing workers alone.


## Installer correction — 9 November 2026

The first local run of the combined dashboard installer reached its dashboard-download step but failed because the script referenced an undefined `$RawBase` variable. This was a script defect, not a PC/network issue. Corrected production `tools/gemma-agent-isolation/Install-Gemma-Agents.ps1` to use the explicit raw GitHub URL for `Gemma-Control-Centre.ps1` (commit `54d1aee479364eb14c048e3911717f69befc16ec`). Re-running the installer is safe: the installer skips existing category clone folders, does not restart/stop workers, and refreshes the shared dashboard script and its two desktop shortcuts. The owner has not yet rerun the corrected installer; dashboard installation is still pending.


## 9 Nov 2026 — desktop dashboard header overlap recurrence

User screenshot showed top worker rows hidden behind header/toolbar in the new seven-agent WinForms dashboard. This is the known Windows Forms `DockStyle.Fill` and child z-order bug previously corrected in the legacy Research Control Centre; it is NOT missing agents or a worker process failure. Minimal production fix `ac293cd7e48bf0d334a0c3c0e14d37b32f40d4ae` adds `$form.Controls.SetChildIndex($grid, 0)` after all docked controls are added in `tools/gemma-agent-isolation/Gemma-Control-Centre.ps1`, ensuring header, toolbar and footer reserve layout space. No worker code, branches, ENV, Supabase or research queue changed. Installation of the updated dashboard script on the Research PC and visual verification of all seven rows remain pending.


## 9 Nov 2026 — dashboard freeze and second layout correction

Owner reported the first dashboard remained unresponsive and the previous dock-order adjustment did not resolve the hidden rows. Root cause in the dashboard implementation: a WinForms UI timer refreshed every 2.5 seconds, while each refresh ran a WMI process query and Git branch query once per agent, then repeated runtime checks for summary counts. All of this ran synchronously on the UI thread, starving paint/input and freezing the desktop. Corrected production dashboard in commits `69a889106000ab020e7c1048f2801c70458318fa`, `3a27be55076fd63707bd486c3fbc467c376ca924`, `03c9d3531b05ce0c795ed341e9c432b9c5fa4397`, `deee5845422c1f504e084be5bcdbfab2f7a16847`, and CI workflow trigger commit `f513f7eabeb9889eb11e12f430c0b6c41537a6ff`. New design removes automatic polling entirely (manual Refresh button only), performs one process snapshot per refresh rather than per row, checks Git branch only on Start/Update actions, and replaces WinForms Dock Top/Fill/Bottom with explicit anchored bounds so toolbar/header/grid/footer cannot overlap. GitHub Actions run `42724574718` passed. The new script has been deployed to production but is NOT yet installed on the owner's PC. No worker code, category branch, private ENV, Supabase data, queues or running Gemma processes were changed by this dashboard-only correction. Next step: owner closes dashboard and downloads only `Gemma-Control-Centre.ps1` from raw production into `C:\CTFGemma2\Gemma-Shared\Gemma-Control-Centre.ps1`, then reopens it and verifies all seven rows and buttons. Do not rerun full installer.


## 10 Nov 2026 — Start-button event correction

After installing the responsive dashboard, owner reported Start appeared inert. Drone status was correctly interpreted as IDLE — CONNECTED: its worker process exists and is waiting, not actively researching; other agents show ENABLED — NOT RUNNING because their serviceEnabled setting is true but no matching worker process exists. Updated `tools/gemma-agent-isolation/Gemma-Control-Centre.ps1` at production commit `c67b562e43ad31e990263f49d2d9832357d6e03b`: use DataGridView `CellClick` instead of `CellContentClick` for action columns, validate the selected agent launcher exists, launch with `-PassThru`, log start requests/failures per agent, and show an explicit launch-request confirmation including launcher PID. CI run `42725432275` passed. This remains dashboard-only: no worker source, category branch, private ENV, task queues, research data or other agents were changed. Owner must replace only `C:\CTFGemma2\Gemma-Shared\Gemma-Control-Centre.ps1` with the production file and reopen the dashboard before testing Start on 3D Printers. If the request is rejected, the dashboard now surfaces the error; if launched, check the per-agent Logs button for `worker-*.err.log` and `control-centre-actions.log`.


## 10 November 2026 — Seven-agent compact completion and one-click update repair

A startup failure on the Research PC showed that the 3D Printer worker imported `src/task-result-summary.mjs`, but the local installed folder did not contain that file. Root cause confirmed in the category updater: `Update-TradeFlow-Gemma.ps1` did not include `task-result-summary.mjs` or its regression test in `$SourceFiles`, so the updater could never install the helper even when the Git branch contained it. The installer also deliberately skipped any existing clone folder, which is not an update operation and left stale installations untouched.

The shared compact completion behaviour is now present on all seven isolated branches: `gemma/3d-printers`, `gemma/gaming`, `gemma/cameras`, `gemma/drones`, `gemma/metal-detectors`, `gemma/mobile-phones`, and `gemma/laptops`. Each worker submits only product identity, evidence references, classification, observed GBP price/currency, review-write references, bounded route failures and metrics to `platform_ai_agent_complete_task`. Raw captures remain in the LIVE review queue; no raw page bodies or long excerpts are duplicated in the completion JSON. Each branch contains the helper and a regression test, and its updater now downloads and runs that test.

The production Gemma Control Centre now has an **Update all workers** action backed by `tools/gemma-agent-isolation/Update-All-Gemma-Agents.ps1`. The orchestrator preflights all seven branch identities, configs, updaters and the shared private ENV pointer before changing any service setting. It requests graceful stop (finish current task), waits up to 60 minutes without force-killing Node, updates each category sequentially using its own branch updater, and restarts only workers that were running before the operation and whose update succeeded. Workers previously stopped remain stopped. It never prints, copies or changes the private ENV file, and it does not write Supabase data, queues, catalogue, tenants, customers, Stripe or Cloudflare settings.

**Deployment status:** GitHub branch sources and production dashboard/orchestrator have been updated. The Research PC has NOT yet run the new all-worker update operation. Do not claim runtime repair complete until the owner installs the updated dashboard and runs Update all workers, then the seven local logs and worker status are checked. A failed individual update must remain stopped and be reported with its log path; do not retry by rerunning the full installer or overwriting private configuration.


Validation addendum — 10 November 2026: after correcting the CI parser to tolerate sparse category-branch checkouts, the full Gemma Research Tests workflow passed on all seven category branches (3D Printers, Gaming, Cameras, Drones, Metal Detectors, Mobile Phones and Laptops). Production run 42730089144 also passed PowerShell syntax checks for the all-worker updater and dashboard, Node syntax checks, compact task-result regression tests and dashboard JavaScript syntax. The earlier category-branch CI failures were caused by the workflow attempting to parse production-only desktop scripts absent from sparse branch checkouts; the workflow now skips only files not present in that checkout. This is a CI path correction, not a runtime worker change. Research PC deployment remains pending.


## 10 November 2026 — Retirement of the local research-agent system

The owner authorised retirement of the local category research workers and their owner-dashboard controls. The retirement is being performed in stages. The owner dashboard no longer exposes the worker control centre or shared agent room in the retirement branch. The corresponding JavaScript polling, queueing, source-management and message-feed UI code has been removed from that dashboard branch.

Preservation boundary: do not delete catalogue products, categories, existing product/evidence records, or the historical research review queue. The LIVE database snapshot before retirement contained 35 task rows, 12 status rows, 14,808 activity rows, 451 agent-message rows, 75 catalogue research queue rows and 119 research-source rows. These are historical records and must remain available unless a separately authorised retention policy is agreed. Worker-specific functions and tables must not be dropped until all remaining callers, triggers, grants and RPC dependencies have been audited. Do not change Stripe, tenant data, customer data or published subscriber content.

The PC installation still requires owner-side removal because this environment cannot directly operate the Windows desktop. The identified local roots are C:\\CTFGemma2, C:\\TFGemma and %LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre. Before removal, disable the scheduled tasks and startup shortcut, preserve an encrypted/local backup including private environment pointers, remove desktop shortcuts and the model, and verify no worker processes remain.

The production branch has not yet been merged or deployed. The retirement branch is subject to syntax, dashboard regression and database dependency checks before production promotion. Keep this retirement record and historical checkpoints; removing the runtime does not mean erasing the audit trail.
