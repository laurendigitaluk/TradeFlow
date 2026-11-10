## 8 November 2026 — Launcher/test-suite mismatch corrected in PR #300

After the Research PC accepted the strict JSON schema and returned populated Bambu Lab A1 Standard fields (source TEST02, £289.00, Brand new, In stock), starting the worker failed safely: the locally retained legacy launcher ran stale `test/agent.test.mjs` and `test/collection-discovery.test.mjs`, which import the removed `combineProductResearchTasks` export. The PR updater had only replaced `src` files and did not replace the root launcher, so its own 55 source tests passed while the stale launcher gate failed. Corrected PR #300 by adding a version-controlled `Start-TradeFlow-Gemma.ps1` that runs exactly the four current source test files before starting `src/task-worker.mjs`, and updating `Update-TradeFlow-Gemma.ps1` to download, back up and install this matching launcher alongside source files, with PowerShell parser validation. GitHub Actions now syntax-checks both updater and launcher. This correction is still in PR #300 and has not been installed or deployed. Next: wait for CI on the latest PR head; if green, ask owner to run updater once (worker remains stopped), verify updated launcher is installed, then start worker and run one controlled review-only task. Do not manually delete legacy tests or bypass tests. No database, approvals, imports, or LIVE catalogue data changed.

## 8 November 2026 — Required-field extraction correction validated

The owner-side Ollama 0.4.14 / `gemma3:4b` schema smoke test accepted the strict JSON schema and returned parseable JSON, but the model left `page_title`, `price_mentions` and other useful fields empty despite the prompt supplying title and GBP price. This confirms schema acceptance alone is insufficient. PR #300 now makes `page_title`, `product_identity_text` and `match_observation` non-empty at schema level and explicitly requires copying supplied title and visible GBP price values into the finding. Tests assert these prompt and schema requirements. GitHub Actions run #251 passed all steps, including PowerShell updater parser, Node syntax, Gemma tests and Owner Dashboard syntax. Still draft/unmerged. Next: install latest branch source on Research PC, repeat a single-page schema smoke test with realistic content and inspect populated fields; do not restart worker or queue research until that succeeds.

## 8 November 2026 — Isolated-page recovery after malformed batch output

PR #300 now retries each page individually when a multi-page 3D-printer Gemma batch fails JSON parsing, returns a truncated response, or fails source-ID validation. Each retry uses a shortened 1,600-character selected page excerpt, the strict one-finding schema, and a 1,024-token output budget. Successful page retries are retained as structured findings; only pages whose individual retry also fails use the existing raw-page fallback. Initial batch failure remains recorded for diagnostics. GitHub Actions run #244 passed PowerShell parser, Node syntax, Gemma tests and Owner Dashboard syntax. This remains draft PR code, not merged or installed on the Research PC.

## 8 November 2026 — Updater now auto-detects the current Gemma installation

To avoid repeated path-entry errors on the Research PC, the PR #300 updater now detects the current directory when it contains `src/agent.mjs`, automatically selects the adjacent `.env` when present, and strips surrounding quotes from manually supplied paths. This matches the Research PC screenshot: PowerShell is already open in the existing Gemma installation directory and that directory visibly contains `.env`. Next owner step should be a single launch command from that directory; no path prompts should appear. This is still an unmerged draft-branch update and must pass the latest CI before use.

## 8 November 2026 — PR #300 updater repair and PowerShell CI gate

The first Research PC updater attempt was stopped before installation: PowerShell reported parser errors. Investigation found the branch updater had a truncated `SourceBranch` validation line and duplicated script body. It has been rebuilt from the known production updater, adding only the validated `-SourceBranch` selector (default `production`). The existing `.env` remains untouched; no files were installed by the failed attempt. GitHub Actions now parses the updater with PowerShell before running Node checks. Latest validation is tracked on PR #300; Research PC install and local Ollama schema acceptance remain pending. Do not restart worker or queue research until those checks pass.

## 8 November 2026 — PR #300 CI and controlled install path

PR #300 latest head `f8fe6f78ebf77c971526d650293a7f0d22951207` passed Gemma Research Tests run #219: source syntax, Gemma task/playbook tests and Owner Dashboard JavaScript syntax all succeeded. PR remains draft/open and is not deployed.

The PR now also adjusts `Update-TradeFlow-Gemma.ps1` to accept an explicit `-SourceBranch` parameter (default remains `production`). This allows a controlled install of the draft branch for local Ollama compatibility testing without merging it. The updater retains its existing folder checks, backup, Node tests, TEST/LIVE URL validation and private .env preservation. Do not use `-StartWorker` for the first installation test; first verify installed source and run local tests. Do not run the updater until the PR branch head has passed CI.

## 8 November 2026 — LIVE 3D-printer benchmark and extraction reliability follow-up

LIVE task `owner-3d-printers-speed-benchmark-20261108-1645` completed in 25m 17s versus the previous six-product baseline of 70m 49s (64.3% faster). It made 7 Gemma calls for 11 fetched pages; 5 calls returned truncated/malformed JSON. All 11 page captures and deterministic GBP observations remained in the review queue; no evidence was approved or imported. Gemma inference consumed approximately 1,395 seconds of the 1,513-second aggregate subtask runtime.

The production agent now has a proposed follow-up on branch `fix/gemma-3d-printer-json-reliability-20261108`: use a bounded JSON schema for 3D-printer output, cap free-text and price-context lengths, reject incomplete/mismatched source_id sets, and report Ollama output-token-limit termination explicitly. GitHub Actions run 42505764030 (#215) passed 54/54 tests. This is code-level verification only; local Research PC Ollama/schema compatibility is still unverified, and the change is not deployed or accepted until a controlled Research PC run passes. Keep raw capture retention, UK/GBP checks, exact package review and owner/ChatGPT approval/import gates unchanged.

# CURRENT AUTHORITATIVE SYSTEM POSITION — 7 NOVEMBER 2026

## 8 November 2026 — PR #298 merged

PR #298 is now merged into `production` (merge commit `3417c5dced183fedcf13a7af266c67c2dd697d0a`). GitHub Actions validation passed 53/53 tests. This is not yet installed on the Research PC and has not been runtime-benchmarked. Next: use the existing updater with the correct dedicated install folder, preserving the separate private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`; verify installed commit/heartbeat before queuing a controlled 3D-printer batch. Do not change other agent branches or import/approval controls.


## 8 November 2026 — 3D-printer Gemma extraction speed work (PR pending)

- Baseline LIVE batch `owner-3d-printers-chatgpt-evidence-batch-20261108-1315` ran for 70m 49s across six sequential product subtasks. It discovered 30 product pages, fetched 18, made 18 one-page Ollama extraction calls and recorded 10 extraction failures. All fetched pages remained in the LIVE review queue; no approval or import occurred.
- Confirmed execution path: `task-worker.mjs` processes product subtasks sequentially; each `runTask` performs web discovery, approved-source route probing, collection discovery, page fetch, Ollama extraction and LIVE queue writes. Product-page fetching is already concurrent in groups of four. Ollama calls are serialised by `ollamaExtractionQueue`.
- Proposed 3D-only optimisation in PR branch `perf/gemma-3d-printer-two-page-extraction-20261108`: process two fetched pages per Ollama call, change the 3D prompt to require a `findings` array with one result per `source_id`, reduce each model excerpt to 2,800 characters while retaining visible price strings and compact nearby contexts, and retain the complete fetched page in the raw review capture.
- Added per-subtask elapsed-time metrics for web search, approved-source probing, collection discovery, product-page fetching, Gemma extraction, LIVE queue writes and total duration. These metrics are required to establish the next real bottleneck rather than guessing.
- Regression tests and the Research PC updater/CI test lists include the new two-page prompt contract. GitHub Actions run `42497005002` passed 53/53 tests and syntax checks. Local Ollama acceptance remains pending. This is not yet merged, deployed or installed on the Research PC; do not queue another LIVE run until the PR passes review and the existing updater is explicitly approved and run.
- No source registry, task queue, review rows, catalogue, TEST data, approval/import state, credentials, private `.env`, Research PC installation or runtime was changed. The review gate remains unchanged.



## 8 November 2026 — scheduled LIVE verification at 02:00 UTC

- Current LIVE status for category `3d-printers-equipment`, branch `3d-printers`: idle, no active or pending task. Latest task `owner-3d-printers-exact-identity-acceptance-20261108-0032` completed 8/8 subtasks from 00:32:26 to 00:47:00 UTC.
- Aggregate metrics: 85 search results; 15 product pages discovered; 6 fetched and captured; 4 Gemma extraction calls; 2 extraction failures; 114 approved-source route attempts; 32 route errors; 55 empty routes; 27 routes with matches; 40 opposite-lane source skips. Four new review rows were queued and two existing unreviewed rows enriched.
- New lane: 32 searches, 7 discovered, 5 fetched/captured. Used lane: 53 searches, 8 discovered, 1 fetched/captured. The used-page loss remains at fetch: eBay listing requests returned HTTP 403 and other configured routes returned 404. No access-control bypass was attempted.
- New-lane failures include Bambu Lab UK Shopify and Amazon HTTP 404, 3DFLO timeout, 123-3D redirect to an ineligible page and 3D Prima HTTP 404. The two Gemma extraction failures occurred after page fetch; raw captures were retained.
- LIVE review queue now has 44 rows: 34 `uk_new`, 6 `uk_used`, 4 `uk_both`; 3 top-level observed prices, 2 append-only enrichment histories, 1 reviewer marker, 0 approvals and 0 imports. All rows remain `needs_research`.
- The concatenated Creality slug `/products/essential-combok1-max-hyper-pla-2` is still incorrectly present as K1 Max Standard at £599.00. A second legacy K1 Standard row also references the same Combo URL. No queue rows were modified.
- Worker status row is idle, with no error. Its last heartbeat is 00:47:00 UTC; the task-worker source only sends its heartbeat timer during an active claim, so an old idle heartbeat does not prove the PC is offline or online. The current Research PC process/Ollama state remains unverified.
- PR #287 head `4c9c220fcb01066a56b2735db77c8aa0040ab9af` is still open and mergeable. GitHub Actions run **42436325135** completed successfully at 01:55 UTC: **45 tests passed, 0 failed**, including task-group, source-playbook and agent-identity suites plus syntax checks. No review submissions or review threads are present. The strengthened fixture tests the exact K1 Max Standard rejection and K1 Max Combo acceptance against the same captured URL/title.
- This green CI result supersedes the earlier checkpoint statement that a run for the corrected fixture had not yet been observed. It verifies the PR branch only; it does not verify the Research PC installation or LIVE runtime. Do not merge, deploy, update the PC or queue another task without explicit owner approval and the required local updater/worker verification.
- No task, queue, source registry, catalogue, TEST data, approval/import state, secret, private .env or Research PC runtime was changed during this scheduled check. No new research task was queued.

This front section supersedes older descriptions below where they conflict. Older dated material is retained as implementation history, not current operating instructions.


## 8 November 2026 — post-update Gemma acceptance and K1 Max Combo regression correction

- The latest 3D-only LIVE task completed eight subtasks: 85 search results, 15 individual pages discovered, 6 fetched/captured, 4 Gemma extraction calls, 2 extraction failures, 4 new unverified review rows and 2 existing rows enriched. No evidence was approved or imported.
- Bambu Lab A1 short-model disambiguation now rejects the 9 Audi A1 car URLs before product-page fetching. The used A1 Standard pass found one candidate but eBay returned HTTP 403.
- The exact Creality K1 Max bundle URL `/products/essential-combok1-max-hyper-pla-2` was still captured as K1 Max Standard, with title `K1 Max + PLA*2(White+Red)` and visible £599.00. The same page also remains in an older K1 Standard review row. Both are unreviewed and untouched.
- PR #287 corrects the concatenated Combo URL token boundary. Its first regression assertion was too weak because it used the base K1 task and could pass via sibling-model rejection. The feature branch now tests the same URL/title against K1 Max Standard (reject) and K1 Max Combo (accept), proving the package rule itself.
- Worker is idle with no active/pending 3D task. Last heartbeat 00:47 UTC is stale by about 65 minutes; idle status alone cannot verify that the Research PC process is still online. Do not queue another task until PR review/merge, updater verification and an explicit worker check.
- The LIVE review queue has 44 3D-branch rows, 2 enrichment histories, 1 reviewer marker, 0 approved and 0 imported. All captures remain subject to ChatGPT/owner review.

## 8 November 2026 — concatenated Combo URL identity correction

- Controlled LIVE acceptance task `owner-3d-printers-exact-identity-acceptance-20261108-0032` showed the official Creality UK URL `/products/essential-combok1-max-hyper-pla-2` was captured under the K1 Max Standard task. Its title identified `K1 Max + PLA*2(White+Red)` and the page showed £599.00; this is a bundle, not the standalone Standard Printer.
- Root cause: URL tokenisation split punctuation but did not restore the missing boundary between `combo` and the following model token in concatenated Shopify slugs (`combok1`). The package detector therefore failed to see the Combo marker even though the title/path contained the model identity.
- Minimal fix: restore a token boundary after `combo` (and concatenated AMS/ACE/CFS labels) before exact model/package matching. Keep sibling-model rejection and standard-vs-combo enforcement unchanged. Add a regression fixture for the exact Creality URL/title so it is rejected from the K1 Max Standard task; the matching Combo task remains eligible.
- This is limited to the 3D-printer branch. It changes no source allow-list, task dispatch, queue row, approval/import state, catalogue data, TEST data, credentials or Research PC runtime. Existing updater already includes `agent.mjs` and `source-playbooks.test.mjs`.
- Validation required: run the Gemma research workflow and full Research PC updater tests, merge only after green CI, then rerun a small K1/K1 Max Standard-vs-Combo acceptance test. Review captured page text and exact package labels; no automatic approval/import.

## Product and site architecture
- Lauren Digital is the parent brand. TradeFlow is the SaaS platform.
- The public **How It Works** guide is source-managed in how-it-works.html and how-it-works.css. It is a ten-section, text-only native accordion page; its AI Research Centre explanation, customer-paid shipping guidance and TradeFlow Examples link were refreshed on 7 November 2026. The legacy platform_public_pages How It Works draft is retained but does not drive the published page. Request source changes when its wording/process needs updating.
- **Examples** remains editable through the Owner Dashboard Public Website Pages editor.
- Subscriber websites are tenant-specific. Website Builder controls design, branding, page text and visibility; Buying Catalogue and published Selling listings supply connected product data. Public TradeFlow marketing pages are separate from subscriber websites.
- The Platform Owner Dashboard has nine consistent collapsible management sections: Product details; Subscriber businesses; Complimentary subscriber accounts; Domain connection requests; TradeFlow plan/pricing; Public Website Pages; Platform email; AI Agent Common Room; Gemma Control Centre. Overview metrics remain visible. Sidebar anchors open the matching section.
- The Owner Dashboard has no Platform Configuration or subscriber AI-provider setup. AI research is a centrally operated TradeFlow capability; do not reintroduce subscriber-supplied AI configuration as a default.

## AI Research Centre and agents
- Gemma runs on the dedicated Research PC using the local Ollama model and the separate local environment file selected by TRADEFLOW_GEMMA_ENV_FILE.
- Research tasks use the LIVE master catalogue and LIVE research queue. Category-scoped approved websites are applied before discovery; evidence candidates must be direct UK product/listing pages with exact product identity, visible GBP price, condition and availability.
- The worker stages candidates for ChatGPT/Platform Owner review. It does not approve or import product/evidence records simply because a candidate was found.
- Owner review → **Research again** must enqueue a fresh `catalogue_research` task through `platform_owner_enqueue_ai_agent_task` before changing the candidate to `needs_research`. The task carries the candidate's exact category, branch, manufacturer, model and package, with `research_type: uk_both`; the persistent LIVE worker claims it automatically. This is separate from candidate review and never approves/imports evidence.
- The AI Agent Common Room is a persistent message workspace for owner instructions, handovers, findings, questions, learning notes and status updates. It is separate from task dispatch, evidence approval and catalogue imports.
- Gemma receives bounded Common Room notes in its extraction prompt as guidance only. Exact task definition, approved-source restrictions, product identity checks, evidence validation, privacy and review gates take precedence.
- ChatGPT can participate as a supervisor during an active ChatGPT session. There is no always-running ChatGPT process unless a separate persistent integration is built.

## 3D Printer Gemma research improvement — PR #278 pending review (7 November 2026)
- LIVE inspection found that the uk_new and uk_used task types were not separating their approved source sets: category/manufacturer restrictions were applied, but both lanes could still probe new retailers, used marketplaces and dealers together. PR #278 adds lane-aware filtering to the web-search domain list, host validation and approved-source probing for the 3D Printers branch only; other categories keep their existing source selection. uk_both continues to use both lanes, and a source explicitly configured with research_scope=all is available in both. The LIVE 123-3D UK source remains configured new_uk; its refurbished listing will not be included in uk_used until the owner approves a source-scope change. No source-registry change is included.
- The 3D-printer branch now defaults to retaining up to 30 search results per task (previous default 18; existing maximum 30). The optional GEMMA_3D_PRINTER_SEARCH_RESULTS_PER_TASK setting can lower that limit; other categories keep their previous default/configuration.
- Page text normalisation converts HTML pound entities to GBP labels. PR #278 updates the deterministic price extractor to recognise both £ and GBP labels, preserving those visible amounts and nearby context.
- Known anti-bot/captcha challenge routes are explicitly excluded from direct product-page eligibility and counted as blocked discovery results; they are not bypassed.
- Ollama extraction now emits per-batch progress. Task telemetry and Common Room handovers include search limits/results, approved-source route attempts/outcomes, pagination and page-fetch failures, pages discovered/fetched/priced, extraction batches/failures and retained review captures. A separate periodic worker heartbeat keeps LIVE status current even while an Ollama batch is waiting for a response.
- Gemma extraction accepts the documented findings array plus recognised common JSON envelopes (results/items/pages/observations/records, nested data/result/output/response, and a single source_id object). If the response still has an unknown shape, the top-level keys are recorded in the failure detail; every fetched page remains preserved as a raw fallback capture.
- The 4k-context prompt is bounded: the model receives a 2,200-character page excerpt plus visible GBP mentions and short price contexts, up to four branch/category rules, and only the three most recent Common Room notes. The worker selects the latest four notes from the Common Room's ascending message order. Full page text is still retained in LIVE for ChatGPT inspection.
- LIVE test observation: the first Anycubic Kobra S1 subtask fetched and staged 9 pages. Each raw capture retained visible GBP price mentions, but Gemma returned JSON without a recognised findings array, so all 9 structured observed_price/evidence_type fields were null. The first measured loss point was extraction-envelope parsing, after discovery and page fetch; the capture-first fallback prevented the source text/prices from being lost. PR #278 adds compatibility parsing and diagnostics.
- The following Anycubic Kobra S1 uk_used pass found 8 page candidates and staged 3 new records; two were actually new official Anycubic pages and only one was a refurbished Grade A listing from 123-3D. This confirms the LIVE source-lane leak. The refurbished page's Ollama call timed out and the two official pages returned JSON without findings arrays; all three raw captures retained visible GBP price mentions.
- PR #278: https://github.com/laurendigitaluk/TradeFlow/pull/278. GitHub Actions Gemma Research Tests run 42412711661 passed; the all-scope lane regression fixture was corrected and the subsequent code, prompt-budget and documentation checks are green. The PR is open and unmerged; the Research PC has not been updated from it. Do not describe these improvements as live until the PR is reviewed/merged, the existing updater is run in place, and a controlled LIVE acceptance test succeeds. Preserve the current private .env and TRADEFLOW_GEMMA_ENV_FILE path.

## Release and environment status
- TEST Supabase: nnsshnfkjcflucjrftzi. LIVE Supabase: gxsrajtqzdjvmceqcpgv. Retired project twfbmjwwqzxdxvclxbun must never be used.
- The Common Room schema plus four additive routing/security migrations are installed on LIVE. All four owner/agent SECURITY DEFINER RPCs use an empty search_path with role-specific grants and the appropriate owner-membership or service-role check. PR #267 merged to `production` as `45049f5c4a1b131d95b701b2603fe0a351c392bd`. The Research PC updater was run and the LIVE task worker was verified running; one controlled LIVE catalogue task completed and its Common Room handover is visible. The Research Again correction from PR #268 is merged to `production` as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`. PR #269 also merged the required JavaScript cache-bust (`platform-owner-dashboard.js?v=27`) as `fa14ebaad62039b413962a09a466bc7d36b92912`. Cloudflare dashboard deployment and authenticated browser acceptance are still pending; a Git merge or local PC process does not prove deployment.
- The Research PC worker has claimed and completed a controlled LIVE research task and posted task-start, handover and completion messages to the Common Room. A separate owner-authored `instruction` delivery test and Cloudflare browser deployment/acceptance remain outstanding.
- Preserve the Research PC's existing dedicated .env, secrets and TRADEFLOW_GEMMA_ENV_FILE path during any update. Never commit or replace local credentials.

---



## Platform owner-editable public pages — 3 November 2026
The platform owner dashboard now includes a separate **Public Website Pages** editor for TradeFlow's public **How It Works** and **Examples** pages, including the homepage Examples preview. This is not the tenant-scoped subscriber Website Builder.

- Owner entry: `platform-owner-dashboard.html` → Public Website Pages.
- Editor: `platform-public-pages-editor.js`; public renderer: `platform-public-pages.js`.
- Owner can edit page copy, descriptions, repeatable lists/cards, order, screenshot titles/captions/alt text and image URLs. Four How It Works screenshot slots remain fixed; blank image URLs preserve embedded high-resolution screenshots. Image-file uploads are not implemented yet.
- Save draft, Preview draft and Publish are separate actions. Public visitors receive only published JSON.
- Storage: `public.platform_public_pages`; RLS enabled; explicit deny policies for anon/authenticated direct table access. Owner RPCs require an active `platform_memberships` row; public RPC returns published JSON only for the two allow-listed slugs.
- TEST code uses `nnsshnfkjcflucjrftzi`; LIVE code uses `gxsrajtqzdjvmceqcpgv`. Public renderer and editor use environment-specific API URL/key; never copy TEST API credentials into production.
- TEST branch: `cloudflare-test` → Worker `tradeflow-test`. LIVE branch: `production` → Worker `tradeflow`. Feature is maintained in both; database content and owner sessions remain separate.
- Diagnostic roadmap: `docs/TRADEFLOW-PLATFORM-PUBLIC-PAGES-ROADMAP.md`. Checkpoint: `CHECKPOINTS/2026-11-03-owner-editable-public-pages.md`.
- Browser sign-in/editor/publish acceptance and Cloudflare deployment verification remain outstanding in each environment. GitHub merge is not proof of Worker deployment.
> **AUTHORITATIVE ENVIRONMENT CORRECTION — 30 OCTOBER 2026**
>
> This block supersedes any older environment IDs or deployment notes retained below for historical audit purposes.
>
> - Repository: `laurendigitaluk/TradeFlow`
> - TEST branch: `cloudflare-test`; TEST Cloudflare Worker: `tradeflow-test`; TEST Supabase project: `nnsshnfkjcflucjrftzi`.
> - LIVE branch: `production`; LIVE Cloudflare Worker: `tradeflow`; LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
> - Retired TEST Supabase project: `twfbmjwwqzxdxvclxbun`. **Never connect to, query, write to, deploy against, or use this retired project.**
> - TEST and LIVE are separate. Complete and verify shared catalogue/evidence work in TEST first, then mirror shared catalogue/evidence to LIVE using each environment's own product IDs. Never copy tenant, customer, transaction, domain ownership, storefront, Stripe or subscription data between environments.
> - A Git commit is not proof of Cloudflare deployment. Verify the configured Worker, deployed commit and runtime behaviour independently.
>
> Older occurrences of the retired project ID below are historical records only and are not valid connection instructions.

---

# TradeFlow Human / Developer System Handbook

> **LIVE FULL SYSTEM AUDIT — 9 OCTOBER 2026**
>
> - Correct LIVE Supabase project reference: `gxsrajtqzdjvmceqcpgv` (the previously repeated `...v5` reference is invalid). TEST remains `twfbmjwwqzxdxvclxbun`.
> - LIVE Adventure Outpost tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52` is active. Read-only LIVE audit on 9 October confirms 2 non-deleted, email-confirmed Auth users: 1 platform-owner membership and 1 active Adventure Outpost subscriber-owner membership. `public.customers` has 0 rows and 0 customer-to-auth links; no SceneSource website customer account exists yet. Do not create a LIVE customer until the user explicitly approves the registration test.
> - `www.scenesource.co.uk` is the active primary domain and has published-site revision 1. Do not alter DNS, SSL, Cloudflare routing, the published site, or account credentials as part of this audit.
> - **Worker configuration discrepancy and isolated candidate fix:** production `wrangler.jsonc` declares `LIVE_SUPABASE_URL` as `https://gxsrajtqzdjvmceqcpgv2.supabase.co`, which does not match the verified LIVE project URL. The current production-based correction is committed only to isolated branch `audit/fix-live-supabase-url-current-prod-20261009` at `b6d838ae45d3c9830fd6bdd2c25d5eaee7dcfa2c`, based directly on current production and changing only `wrangler.jsonc`. Older Worker URL candidate branches are stale/diverged; do not merge them. The refreshed candidate has no reported CI statuses and is not deployed or merged. Controlled non-production runtime and browser route/session tests remain mandatory before promotion.
> - **Open retired-code discrepancy / elevated risk:** six old LIVE domain-purchase/registration Edge Functions remain ACTIVE: `porkbun-domain-availability`, `create-domain-checkout-session`, `reconcile-domain-payment`, `save-domain-registrant`, `porkbun-domain-registration`, and `index` (version 5). The deployed `index` source contains the same legacy Stripe/Porkbun domain-checkout flow; its callers have not been independently established. LIVE has two legacy domain orders (`adventureoutpost.co.uk` / `pending_payment`, and `laurendigital.co.uk` / `registrant_details_saved`) and one registrant record; neither order is positively marked as sandbox (`false` / absent). The `laurendigital.co.uk` order is in a state accepted by the legacy registration function, which can reach production Porkbun preflight/registration if the required production credentials are configured and its checks pass. Do not invoke these legacy endpoints. Do not delete records or disable functions until all callers and provider-secret configuration have been verified. The current domain model remains customer-owned domains plus Platform Owner connection/verification.
> - **TEST retired-shipping/domain code still present:** TEST Supabase (`twfbmjwwqzxdxvclxbun`) has active `parcel2go-customer-shipping` v7, `parcel2go-subscriber-shipping` v11 and `shipping-provider-test` v8, although manual subscriber-managed shipping is the current architecture. The active `cloudflare-test` branch also still contains directly addressable `domain-purchase.html` / `domain-purchase.js` and `domain-registrant.html` / `domain-registrant.js`, which call the retired TEST Stripe/Porkbun registration endpoints. These pages are not linked from the current `domain-settings.js` or subscriber dashboard files inspected, but direct URLs can still reach them. They were not removed or disabled in this audit: finish the repo-wide caller/checkpoint review, then remove or retire them in an isolated cleanup branch and run a TEST regression pass before promotion.
> - LIVE Supabase reports RLS enabled on all 98 public tables. Advisors also report 14 RLS-enabled tables with no policies, 14 anon-callable SECURITY DEFINER functions, 160 authenticated-callable SECURITY DEFINER functions, disabled leaked-password protection, and performance findings (64 unindexed foreign keys, 166 RLS init-plan findings, 105 unused indexes, 14 multiple-permissive-policy findings and 3 duplicate indexes). These are review queues, not permission to bulk-change policies or indexes; review each against intended access and current code before repair.
> - The `production` and `main` branches have diverged substantially. Do not merge or force-sync them as part of cleanup.
> - The customer registration code and tenant-registration RPC exist, but the three-role Chrome session test and live clean-route acceptance tests remain **PENDING**. The external site could not be independently fetched by the audit tools; the latest recorded browser screenshot in the continuation checkpoint showed the homepage rendering.
>
> This snapshot supersedes older conflicting environment/status notes. Audit queries were read-only. No LIVE runtime code, database rows, authentication accounts, subscriptions, DNS, Cloudflare settings or published content were changed.


> **CURRENT SHIPPING ARCHITECTURE — 7 November 2026**
>
> The current TradeFlow shipping architecture is **subscriber-managed shipping services with manual handoff**. The former Parcel2Go API/connected-provider route is **retired and must not be used or reintroduced from the older sections of this document**.
>
> **Current flow:** Subscriber opens **Settings → Shipping Settings**, selects the shipping services they use from the TradeFlow service catalogue, and saves them. Those services appear in the Buying shipping handoff. The customer pays the chosen provider directly outside TradeFlow; TradeFlow does not collect shipping charges. The subscriber selects the services it supports and supplies the shipping instructions and, where needed, a label or QR code. The subscriber or customer can upload the label/QR through the manual handoff, and the customer adds the tracking number and confirms when the item has been sent. The subscriber confirms physical receipt and proceeds to **Inspection**.
>
> TradeFlow **does not create Parcel2Go quotes, book Parcel2Go shipments, process shipping payments, or require Parcel2Go API credentials** in this current flow. Do not add direct courier credentials or an automated shipping-payment path unless the architecture is deliberately changed, tested and checkpointed.
>
> **Documentation rule:** Sections below dated before this architecture change may describe earlier experiments or implementation history. They are retained for audit continuity, but they are **historical records, not current operating instructions**. Current code, current Supabase state and this section take precedence.

**Status:** Living document  
**Version:** 4.5  
**Date:** 7 November 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose and authority
This handbook records TradeFlow architecture, security boundaries, workflow rules, implementation decisions, faults, lessons, verification state and exact build position.

Authority order: **current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour**. A Git commit is implementation evidence, not proof of live behaviour.



## CURRENT PROJECT STATE — 7 OCTOBER 2026

This is the current operational baseline for the LIVE website and infrastructure.

### Environment
- GitHub repository: `laurendigitaluk/TradeFlow`.
- LIVE release branch: `production`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- LIVE application path: GitHub → Cloudflare Worker → LIVE Supabase.
- Website publication remains separate: Website Builder draft → Save Draft → Preview → Publish → published revision → new draft.

### Website Builder
The 5 October 2026 Website Builder baseline is locked. Preserve the approved page structures, hero/top section, text/image/button positions, image proportions, typography, colours, backgrounds, borders, rounded corners, What We Buy/What We Sell sections, tiles and starter template. Do not redesign or restructure it unless the user explicitly reopens the baseline.

### Domain architecture
## CURRENT DOMAIN MODEL — 6 OCTOBER 2026

TradeFlow no longer sells, registers, renews or pays for subscriber domains.

The current subscriber workflow is:

1. Subscriber buys and owns a domain with the registrar of their choice.
2. Subscriber opens **Website URL** and enters the hostname.
3. TradeFlow creates a connection request for the Platform Owner.
4. The Platform Owner prepares the approved hosting connection and exact DNS instructions.
5. The subscriber applies those exact DNS instructions at their registrar.
6. TradeFlow verifies DNS, SSL/HTTPS and tenant routing.
7. Only after all required checks pass is the domain activated and connected to the subscriber's published website.

TradeFlow must never request the registrar password and must never invent DNS targets.

The old TradeFlow/Porkbun purchase, Stripe domain checkout and registrant-registration journey is retired. Old dated domain-registration notes are historical evidence only and are not current operating instructions.

For the current platform infrastructure, `laurendigital.co.uk` has been purchased directly through Porkbun and is now active in Cloudflare. The existing LIVE `tradeflow` Worker is connected to `tradeflow.laurendigital.co.uk` as a Cloudflare Custom Domain, and the branded URL has been browser-verified over HTTPS.


### Shipping
Manual subscriber-managed shipping is authoritative. Parcel2Go API/checkout/payment-link shipping and old connected-provider experiments are retired.

### Cloudflare/domain connection
The Platform Owner domain workflow is phased and uses the protected `platform-prepare-custom-domain` Edge Function for automatic Cloudflare custom-hostname preparation. The function source is now versioned in the repository. DNS, SSL/HTTPS and tenant-routing verification remain mandatory before activation.

### Cleanup rule
Historical checkpoints remain available for audit/restore purposes, but they must not be used as current implementation instructions. Obsolete source for the retired domain-purchase/registrant flow, Parcel2Go, ResellerClub and unused duplicate dashboard runtimes has been removed from the LIVE production repository.


## 2026-10-07 — Branded LIVE platform and URL architecture

Lauren Digital is the parent/company brand. TradeFlow is a product of Lauren Digital.

The active LIVE platform URL is:

`https://tradeflow.laurendigital.co.uk`

It is the existing `tradeflow` Cloudflare Worker connected through a Worker Custom Domain. No second Worker is required.

### Tenant ID exposure rule

`tenant_id` remains the authoritative internal tenant boundary and must remain available internally for authentication, RLS, database queries and API operations.

Normal subscriber-facing browser URLs should not expose the raw tenant UUID when a stable business slug can be used. The subscriber workspace resolves a URL-safe business slug and removes the legacy `tenant_id` query parameter from the visible browser URL.

Example:

`Adventure Outpost` → `adventure-outpost`

This is a presentation/routing change only; it does not replace the internal tenant security boundary.

### Future Lauren Digital site structure

The intended future parent/product structure is:

- `laurendigital.co.uk` — Lauren Digital parent/company site.
- `tradeflow.laurendigital.co.uk` — TradeFlow.
- Future products may use their own subdomains when ready.

A future parent homepage and separate owner-only login route are planned architecture only. Do not implement them as part of the current TradeFlow work without an explicit instruction.

## 2. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant boundary.

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level boundary and is never a tenant role. GearCashOut is reference material only and must never be modified during TradeFlow work.

## 3. Security checkpoints
- Customer isolation/security: **34/34 passed**.
- Customer subscription tests: **Buying 17/17; Selling 17/17 passed**.
- Staff security lab: **19/19 passed**.
- Recorded RLS checkpoint: **60/60 public tables enabled**.
- Platform Owner foundation: 044–045.
- Platform-admin privileged paths: 046–048; final browser regression remains open.
- Buying hardening: 049–051.
- Valuation/Offer hardening: 052–055.
- Acquisition hardening: 056–057.
- Inventory hardening: 058.
- Finance permission/workflow hardening: 059–060.
- Selling/listing hardening: 061.
- Retail order hardening: 062.
- Fulfilment/returns hardening: current live migration.
- Category/inventory media foundation: tenant-scoped media links, private storage bucket and retention metadata/triggers.
- External payment boundary: provider/event idempotency plus deployed Stripe Checkout and webhook Edge Functions.

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage`, `orders.view/manage`, `fulfilment.view/manage`, `returns.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing and subscriber build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, Buying, Offers, Acquisitions, Inventory, Finance, Selling/Listings, Orders, Fulfilment and Returns.

Category/property management is independent of Buying. Subscribers can create categories for Buying, Selling or both and define category-specific properties/options. Inventory supports direct product creation, category assignment, dynamic property values and photographs. Selling carries inventory photographs into new listings.

These remain BLUE until authenticated browser journeys are persistently tested.

## 7. Buying → Valuation → Offer
049–051 harden dynamic options and Buying workflow. 052–055 harden valuation/offer RLS, same-item valuation binding and state entry. Published offers require an approved valuation for the same tenant and buying item.

## 8. Acquisition
056–057 harden acquisition access and status entry. Inventory creation from an acquisition item is an explicit operation and is not inferred from acquisition status.

## 9. Categories, product properties and inventory media
`categories`, `category_fields` and `category_field_options` are the database-authoritative model. `category-management.html` / `.js` exposes category creation plus property and option creation. `inventory_assets.dynamic_values` stores category-specific product values.

Media foundation:
- private Storage bucket: `tradeflow-media`;
- `media_assets` retention metadata;
- `inventory_asset_media` tenant-scoped inventory links;
- `listing_media` tenant-scoped listing links;
- inventory/listing sold-status triggers setting a **90-day post-sale retention expiry**.

Private images use authenticated Storage and signed URLs. Physical object deletion must use the Storage API. Automatic cleanup scheduling is not configured.

## 10. Subscriber category tenant-context and REST repairs — 17 September 2026
The category database/RLS path was verified independently: Test Business A contains active Buying/Selling `Drones`, and the authenticated owner query returns it. Front-end repairs addressed missing tenant context, unnecessary GET `Content-Type`, missing request timeout and late runtime diagnostics.

A shared `subscriber-tenant-context.js` preloader establishes test-lab tenant context before subscriber controllers. GET/HEAD requests are normalised so they do not carry unnecessary JSON `Content-Type`.

## 11. Dedicated subscriber authentication — 17 September 2026
The screenshot showing `Sign in through the TradeFlow test environment before opening Categories.` identified the deeper issue: the subscriber workspace was trying to use the **customer test-lab session/storage keys**. Platform Owner authentication is deliberately separate too, so opening Platform Administration does not authenticate a subscriber workspace.

A dedicated `subscriber-auth.js` now provides test-environment subscriber authentication. It uses separate storage keys (`tradeflow_subscriber_publishable_key` and `tradeflow_subscriber_session`), signs in by email/password, verifies an active membership in the selected Test Business A/B tenant, and sets the subscriber tenant context. Passwords are not stored.

`subscriber-auth-bridge.js` is a compatibility layer for the existing Category, Inventory and Selling controllers. On those subscriber pages only, reads of the legacy test-lab key names resolve to the dedicated subscriber session. This prevents the Customer Test Lab session from being overwritten. After a new subscriber login, the bridge reloads the page so legacy controllers start with the authenticated subscriber context.

`subscriber-auth-controls.js` binds the existing page sign-out control to the dedicated subscriber session.

Current pages wired to dedicated subscriber authentication:
- `categories.html`
- `inventory-dashboard.html`
- `selling-dashboard.html`

This is test-environment infrastructure. It is not the final production onboarding/authentication model.

## 12. Inventory
058 protects inventory status entry. The repaired Inventory runtime supports product creation, category-specific dynamic values, multiple photographs and workflow-controlled lifecycle changes.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 13. Finance and payment
059 applies permission-bound access to payment/ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards. No automatic payment or ledger creation is inferred from acquisition status.

`record_retail_order_payment()` is the internal subscriber payment path. `customer_create_order_payment()` provides the customer-side idempotent pending-payment boundary.

External Stripe architecture is server-side: `create-stripe-checkout-session` requires a customer JWT; `stripe-payment-webhook` verifies `stripe-signature` and calls protected `process_external_payment_event()`. `payment_provider_events` provides provider/event idempotency. Stripe test configuration is complete, but persistent browser payment verification remains open.

## 14. Selling / Listings
061 hardens listings and related access. Selling creates listings from ready-for-sale inventory and uses workflow authority. New listings inherit inventory media.

## 15. Retail Orders
062 hardens retail order access/status entry. Subscriber Orders creates orders from published listings. Customer checkout creates a pending-payment order, reserves the listing and uses the Stripe boundary for payment.

## 16. Fulfilment
Fulfilment has subscription-aware access and controlled lifecycle progression: `awaiting → label → dispatched → delivered`, with returned branches. No carrier API or automatic fulfilment creation is assumed.

## 17. Returns
Legacy broad returns policies were removed and direct status edits are blocked. `customer_request_return()` validates customer ownership and eligible order states; customer visibility uses secure `customer_get_returns()`.

## 18. Customer dashboard browser repair — VERIFIED LIVE
Customer sign-in/controller timing and navigation interception faults were repaired. The controller `esc()` parse fault was corrected and cache-busted to `v11`. Customer Buying category loading was isolated from optional modules because Test Business A lacks `module.orders`; `customer-dashboard-nav.js` independently loads `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## 19. Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared a malformed `esc()` quote mapping, causing JavaScript parse failure before Supabase requests. Category was repaired in place; clean repaired Inventory and Selling runtimes were created. Inventory signed-URL requests also explicitly send JSON content type.

## 20. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 21. Manual testing and change control
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

After each material change record what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 22. Current stopping point — 17 September 2026
The category database/RLS path is verified. The browser failure was traced to subscriber pages using customer test-lab session storage instead of a subscriber session. Dedicated subscriber authentication plus a compatibility bridge is now deployed to Categories, Inventory and Selling. **Live browser verification of the new sign-in flow is open.**

**Next action:** hard refresh/open Categories. A Subscriber sign-in dialog should appear if no dedicated subscriber session exists. Sign in using an active Test Business A Owner/Admin/Staff account, select Test Business A, and verify `Drones` appears. Then use the same session to verify Inventory and Selling category selectors. Do not alter subscriptions, category data or RLS to work around this.


## Test Business C — Buy & Sell end-to-end test tenant — 18 September 2026

- Created dedicated test tenant Test Business C (50641519-2aa5-4093-95e5-7e92bea733a6) on the live TradeFlow test environment.
- Assigned the existing Test Business A Admin test identity as an Admin member; no Owner account is required for routine workflow testing.
- Assigned the buy_sell plan in trialing state so Inventory/Selling capability checks can be exercised without weakening RLS or changing Test Business A's Buying-only subscription.
- Seeded a Drones category with model_number (text) and condition (select) plus New/Excellent/Good/Fair/Poor options for end-to-end product testing.
- Added Test Business C to the subscriber authentication and tenant-context allowlists and cache-busted Categories, Inventory and Selling runtimes.
- Test Business A remains the Buying subscription test tenant; Test Business B remains the Selling subscription test tenant. This separation preserves subscription-boundary tests.


### Subscriber tenant switching repair — 18 September 2026

The Inventory RLS error was traced to the active browser workspace remaining on Test Business A, whose Buying-only subscription correctly rejects inventory_assets INSERT. Test Business C was verified separately: the Admin test identity is an active member, inventory.manage is true, and the Buy & Sell plan exposes module.inventory. The subscriber authentication layer previously had no visible tenant switch after an authenticated session was established, making the browser repeatedly remain on the stale tenant context. A tenant switcher has now been added to the subscriber top bar and cache-busted. It lists only tenants returned by the authenticated subscriber membership RPC and reloads the workspace with the selected tenant. No RLS policy was weakened.


## Subscriber tenant-context consolidation — 18 September 2026

- Deep inspection found multiple overlapping tenant/session layers: dedicated subscriber auth, a legacy compatibility bridge, and a test-lab tenant-context script. This could leave a subscriber workspace authenticated as one tenant while controllers read another tenant context.
- The subscriber authentication layer is now the single source of truth for the active tenant. The legacy subscriber-auth bridge was removed from Inventory and Selling page loads.
- subscriber-tenant-context.js no longer reads Customer/Test-Lab session storage or hard-coded user-to-tenant mappings; it waits for the dedicated subscriber auth promise and synchronises the URL tenant_id from that authenticated tenant.
- Categories controller now recognises Test Business C as well as A and B.
- Live verification: Test Business C has active Drones category; the Admin test user has inventory.view and inventory.manage; the Buy & Sell subscription has module.inventory enabled. Inventory RLS therefore remains unchanged.


## Subscription catalogue simplification — 18 September 2026

TradeFlow now has exactly two active customer-facing plans: **Basic** and **Enhanced**. Basic is the complete operational Buy & Sell core. Enhanced includes Basic plus every currently defined add-on capability (staff, staff messaging, audit, analytics, integrations and market intelligence). Legacy five-tier plan records remain inactive for historical traceability. The subscription capability layer remains unchanged as the enforcement boundary; code must continue to call the existing feature checks rather than hard-code plan names.


### Customer storefront and fulfilment checkpoint — 18 September 2026

The public website now includes a real customer-facing Shop section. It loads published subscriber site content and published listings through the controlled `public.get_published_store_listings(uuid)` SECURITY DEFINER function. The function is executable by `anon` and `authenticated` and exposes only storefront fields required for display. It requires a published website revision and filters listings to published status, active selling-enabled categories and active sales channels.

The public storefront remains separate from subscriber operational tables and does not expose customer, order, payment or internal workflow data. The existing paid Test Business C order has reserved the DJI test listing, so that item is intentionally not available in the public Shop.

The Fulfilment workspace has also been moved from the older test-lab session/key to the dedicated subscriber authentication layer. Test Business C has the fulfilment capability enabled and the current Admin test identity has `fulfilment.manage`. The next browser test is to create a fulfilment for `ORD-20260918-DB2A42EF` and then advance it one controlled transition at a time.

The current implementation is **Implemented Live** at the code/database boundary. Public storefront rendering, anonymous listing retrieval and fulfilment browser journeys remain **open for live browser verification**.


### Corrected TradeFlow product hierarchy — 18 September 2026

The top-level TradeFlow customer journey is the SaaS product journey, not a subscriber's public storefront. The intended hierarchy is:

**TradeFlow website → plan selection/subscriber signup → subscriber business account → Buy & Sell workspace → subscriber Website Builder → subscriber's separate customer-facing website.**

`index.html` is now the TradeFlow SaaS homepage. The former Customer Test Lab has been preserved at `test-lab.html` and is no longer the root product entry point. The tenant public renderer (`public-site.html`) remains a downstream customer-facing website for an individual subscriber and must not be treated as the TradeFlow SaaS homepage.

The SaaS homepage presents the two active plans, Basic and Enhanced, and routes into `subscriber-signup.html`. Subscriber onboarding uses Supabase Auth followed by the authenticated `subscriber_create_business()` RPC. That RPC creates the tenant, owner membership and trialing subscription for the selected active plan. Anonymous execution is explicitly revoked.

The live subscription records currently do not contain Stripe provider price IDs for the SaaS plans. Therefore recurring paid SaaS billing is not yet marked complete. The next billing build must add the production Stripe subscription boundary rather than pretending the existing retail checkout is the SaaS subscription checkout.

Subscriber authentication is now membership-driven: it obtains active tenant memberships from `subscriber_get_my_memberships()` rather than relying on a hard-coded list of Test Business A/B/C. This is necessary for newly onboarded subscribers and preserves the tenant boundary.


## 23. Stage 1 SaaS product layer — 18 September 2026

The first product layer is the TradeFlow SaaS itself. The public TradeFlow homepage markets the subscription and routes businesses into subscriber onboarding. It must not be confused with a subscriber's separate customer-facing website.

The platform hierarchy is:

TradeFlow SaaS homepage → subscriber plan/signup → subscriber private business dashboard → subscriber Website Builder → subscriber's own customer-facing website → that subscriber's customers.
The Platform Owner dashboard is a separate platform-level administration boundary. platform-owner-dashboard.html uses its own platform-owner session storage and verifies the signed-in Auth user against public.platform_memberships. Tenant membership is not treated as Platform Owner access.

The first owner dashboard implementation is intentionally platform-level: it reads subscriber tenant/subscription summaries through the existing platform_admin_list_tenants() privileged RPC. It does not replace or bypass tenant RLS and it does not expose subscriber customer/order records as a platform-wide browser dataset.

Verification state: Stage 1 owner dashboard is Implemented in GitHub. Live browser verification remains open.


## 24. Owner Dashboard Stage 1A — subscriber registration details — 18 September 2026

The Owner Dashboard first handles the SaaS intake boundary: businesses subscribe/sign up through the TradeFlow homepage and their business/owner registration details become visible to the Platform Owner. This is distinct from later subscription billing administration and from the subscriber's own customers.

`platform-owner-dashboard.html` and `platform-owner-dashboard.js` now use `public.platform_admin_list_subscriber_accounts()` for a platform-owner-only subscriber account table showing business, owner, email, slug, status and joined date. The RPC uses `private.require_platform_owner()` and anonymous execution is revoked. Tenant RLS is not bypassed.

**Verification:** Implemented in GitHub and live Supabase. Browser verification remains open.


## 25. Owner Dashboard subscriber directory boundary — 18 September 2026

The Owner Dashboard's Subscriber Businesses directory represents TradeFlow SaaS subscribers, not subscriber customers. Development/security test tenants are explicitly marked with `tenants.settings.test_lab=true` and are excluded from the commercial directory.

The directory exposes business registration details and a controlled **View website** link. It does not expose raw tenant customer, order, payment or operational records. Subscriber Website Builder remains a subscriber-side capability.

Categories and Website Builder are currently part of the Basic operational core under the live two-plan catalogue; they are not being invented as separate owner-side offers. Subscription billing and entitlement administration remain the next dedicated stage.

The subscriber-directory SECURITY DEFINER wrapper is restricted to authenticated callers and uses a schema-qualified empty `search_path`, consistent with Supabase's guidance for protected SECURITY DEFINER functions. citeturn0search1turn0search2


## Subscription model — Stage 1C

TradeFlow now has three active customer-facing subscription plans.

**Basic**
- Core Buy & Sell operational workspace.
- Subscriber-configured categories and subcategories.
- Website template and colour selection, logo upload and image content.
- Customer-facing website, customer portal, buying, inventory, selling, orders and fulfilment.

**Enhanced**
- Everything in Basic.
- Staff management and staff messaging.
- Audit, analytics, integrations and market intelligence.

**Catalogue**
- Everything in Enhanced.
- A TradeFlow-provided starting catalogue of categories, subcategories and products.
- The exact commercial quantity limits for the supplied catalogue are not yet set.

The plan capability model remains the authoritative subscription boundary. TradeFlow uses one application and changes tenant capability through plan entitlements; it does not maintain separate Basic/Enhanced/Catalogue applications.

### Platform Owner subscription controls

The Platform Owner layer now has a controlled subscription management RPC. It requires Platform Owner access.

Supported actions:
- upgrade: target plan must be active and have a higher plan sort order than the current plan.
- close: latest subscription is cancelled and the tenant is archived. Business data is retained; account closure is not data deletion.

The Owner Dashboard uses these controls without exposing tenant customer records.

### Billing boundary

The Owner Dashboard subscription controls currently update the internal TradeFlow subscription record. Production Stripe recurring billing, provider price IDs, webhook-driven subscription state changes and automatic non-payment enforcement remain separate work and must not be represented as complete until implemented and tested.

### Catalogue seeding boundary

The Catalogue plan currently records the catalogue.pre_filled entitlement. The actual mechanism that copies a controlled set of TradeFlow catalogue data into a new tenant has not yet been implemented. The number of categories, subcategories and products to seed remains a commercial configuration decision.


## Public TradeFlow marketing layer — 18 September 2026

The TradeFlow SaaS public layer is separate from subscriber workspaces and subscriber customer storefronts.

Current public front-end structure:
- `index.html` — TradeFlow SaaS marketing homepage.
- `facts.html` — platform facts/about page.
- `examples.html` — illustrative website examples.
- `terms.html` — Terms & Conditions draft page.
- `privacy.html` — Privacy Policy draft page.
- `subscriber-signup.html` — subscriber account onboarding.
- `subscriber-dashboard.html` — private subscriber workspace after authentication.

The public visual system uses `tradeflow-logo.svg` and the shared `platform.css` navy/orange branding. Example website visuals are illustrative until authorised real screenshots are supplied.

Public signup deliberately does not collect the subscriber's eventual customer-facing website slug. The existing backend onboarding RPC still receives an internally generated slug derived from the business name; the public website address is a later subscriber workspace configuration concern.

Legal pages currently contain structured draft copy and must not be treated as final legal advice or final production contractual wording until the correct legal entity, commercial terms, privacy details and final review have been completed.


## Public homepage hero presentation — 18 September 2026

The public TradeFlow SaaS homepage uses the GearCashOut website as a reference presentation inside the hero visual. The laptop frame is intentionally sized to a conventional computer display proportion rather than an ultra-wide panel, with a separate phone frame retained to demonstrate responsive customer websites.

This is illustrative marketing content only. It does not make GearCashOut a TradeFlow customer and does not alter the GearCashOut system.

**Current state:** Implemented in GitHub; visual browser verification remains required.


## Homepage hero visual hierarchy — 18 September 2026

The homepage hero visual is intentionally generic and TradeFlow-led. A neutral “Your Business” customer website is shown inside a browser frame, with a smaller mobile version demonstrating responsive presentation. Named reference businesses are kept out of the primary hero so they cannot visually compete with the TradeFlow brand.

The hero contains no floating white explanatory labels. Customer examples remain in the dedicated Examples section.

**Current state:** Implemented in GitHub; visual browser verification remains required.


## 24. Subscriber business application shell — 18 September 2026

Stage 1 of the subscriber product interface has now been implemented on the subscriber-shell-stage1 branch. This is a presentation/application shell over the existing TradeFlow backend and operational workspaces; it does not replace their controllers, RPCs, tables, RLS policies, workflow authority or subscription enforcement.

The subscriber dashboard entry point subscriber-dashboard.html now provides a structured business workspace with grouped navigation for Buy & Sell, Customers, Website and Business areas. Existing links to Buying, Acquisitions, Inventory, Selling, Orders, Fulfilment, Returns, Finance, Categories & Properties and Website Builder are preserved.

The dashboard now loads the dedicated subscriber-auth.js layer before subscriber-tenant-context.js and binds the existing Sign out control to tradeflowSubscriberSignOut. This corrects the dashboard entry-point loading order without changing the underlying authentication or tenant-selection architecture.

subscriber-dashboard.css was extended as the shared subscriber application stylesheet. Existing dashboard/workspace classes remain supported so the change acts as a visual shell rather than a rewrite of the operational pages.

Catalogue remains an active plan in the database, but it is deliberately not exposed as an operational subscriber option yet. Catalogue rollout is held open until Gemma is capable of maintaining/updating the TradeFlow product catalogue. Do not seed Catalogue data or remove the plan from the database in the meantime. The current plan/feature entitlement architecture remains authoritative.

Current state: Implemented on staging branch; not yet Verified Live. Before merging to main, browser-test the subscriber sign-in, tenant selection, dashboard navigation and representative existing workspaces. Do not alter backend security or workflow code merely to make the shell work.

Next safe action: verify the shell against Test Business C using the existing Admin test identity, then continue by integrating the common shell/navigation with the existing operational pages one meaningful area at a time.

## Subscriber reset and account-boundary checkpoint — 18 September 2026

The legacy subscriber test environment has been closed before the next onboarding test. All tenants marked `settings.test_lab=true` were archived and their subscriptions cancelled; their memberships were removed from active status. The Platform Owner Auth account `leannelaurenlowe@hotmail.com` was deliberately retained and was not deleted.

The separate orphaned test Auth users `tradeflow1@yahoo.com` and `info@gearcashout.co.uk` were deleted. No subscriber customer account was created by this cleanup.

Security boundary decision: Platform Owner is not a tenant role and does not receive automatic membership in subscriber businesses. Platform-level access must remain separate from tenant customer data. Any future subscriber-approved maintenance/support access will be an explicit, auditable capability and is not being added as a hidden backdoor.

The subscriber dashboard now displays the active business, signed-in email and tenant role, with an Account dialog showing the active tenant ID. Catalogue remains deliberately absent from the operational subscriber navigation until Gemma can maintain/update the product catalogue.

The Website Builder now offers six distinct starting layouts: Business, Buy & Sell, Services, Editorial, Minimal and Retail. The selected template is persisted in the existing website revision content and the public renderer applies the corresponding layout variant. No new tenant/RLS architecture was introduced.

**Verification state:** cleanup is database-verified; dashboard/template changes are Implemented on `subscriber-shell-stage1` and require browser verification before merge to `main`.

## Subscriber dashboard workflow separation — 18 September 2026

The subscriber business dashboard has been refocused as the day-to-day operational workspace. Its primary flow is Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns, with Finance and Customers as supporting business areas. Website building is no longer presented as part of that operational flow.

A separate `subscriber-website.html` website management area is now the entry point for website work. It links to the existing Website Builder and customer-facing preview. The intended UX is that a subscriber builds/publishes the website, then returns to the Business Dashboard for normal operations and only revisits the Website area when maintenance or content changes are needed.

Subscriber authentication was strengthened so protected subscriber pages are hidden until the dedicated subscriber session and active tenant membership have been verified. Unauthenticated visitors receive the subscriber sign-in overlay rather than seeing usable dashboard content.

**Verification state:** Implemented on staging; browser verification remains open before merge to main.

## Sign-in entry correction — 18 September 2026

The public TradeFlow **Sign in** links now point to a dedicated `subscriber-login.html` page rather than sending a visitor directly to the protected subscriber dashboard. The login page provides an explicit subscriber sign-in form and a clear **Create account** path to `subscriber-signup.html`.

A separate auth-overlay visibility issue was also corrected: the protected-page guard hides dashboard content while authentication is unresolved, but it no longer hides the sign-in overlay itself.

**State:** Implemented on main; browser verification is required against the deployed GitHub Pages site.

## Verified-email subscriber onboarding correction — 18 September 2026

A signup could previously create the Auth user but stop before `subscriber_create_business()` when Supabase email confirmation was required, leaving a verified user with no tenant membership. The signup now stores the selected business name and plan code in the Auth user metadata so the setup details survive email confirmation. On the first successful subscriber sign-in, if the verified account has no active membership and those validated setup details are present, the authenticated session calls the existing `subscriber_create_business()` RPC and then continues to the subscriber dashboard.

The current verified test account `scenesource1@gmail.com` had no tenant membership, so its signup metadata was repaired to `subscriber test 1` / `basic`. No tenant was created directly by the repair; the normal authenticated RPC path will create it on the next sign-in.

**State:** Implemented on main. Browser verification required: sign in with the verified account and confirm the Business Dashboard opens with the new tenant membership.

## Customer preview and subscriber branding correction — 18 September 2026
- The Website Builder's `Preview customer dashboard` action now opens the dedicated `customer-dashboard-preview.html` read-only preview rather than the live `customer-dashboard.html` customer portal. The live customer portal requires customer authentication and its current test-lab tenant context, so it is not an appropriate subscriber preview target.
- The preview is tenant-scoped through the existing subscriber authentication/tenant context and reads the subscriber's draft website branding for the preview name and accent colour.
- The subscriber Business Dashboard header now displays the authenticated subscriber business name instead of the fixed `TradeFlow` label. This establishes tenant-specific branding without changing tenant security or customer authentication.
- An actual uploaded image logo is not yet stored by the current website-builder schema; the current change therefore uses the subscriber business name as the dashboard brand. Do not describe image-logo upload support as implemented until a tenant-scoped logo asset flow is added and tested.


## Website Builder guided template expansion — 18 September 2026
- Expanded the subscriber Website Builder from 6 starting templates to 10: Business, Buy & Sell, Services, Editorial, Minimal, Retail, Professional, Bold, Classic and Local Business.
- Added guided builder instructions explaining the build sequence, business identity, category setup, product setup, website pages, preview, save and publish.
- Added clear links from the builder to Categories & Properties, Inventory and Selling.
- Added category guidance: subscriber buying categories are the category structure used for the item through acquisition/inventory and, when selling is enabled, the same category can be used for the product/listing rather than requiring a duplicate selling category.
- Added editable page definitions for About, Contact, Terms & Conditions, Privacy Policy, FAQ, Delivery & Returns, Sell to us, Shop and Customer account. Each page can be enabled/hidden and given a title, body content and optional SEO fields. Shop and Customer account remain system-driven areas; product/category data comes from the existing operational workflow.
- Public subscriber websites now build navigation from enabled page definitions and can render the selected page through the existing published website content path.
- This is a frontend/content-schema expansion over the existing tenant website state and revision architecture; it does not bypass tenant security or replace the existing category/inventory/listing workflow.


## Website Builder usability correction — 18 September 2026

The Website Builder has been revised after browser inspection showed that the template choices were not reliably usable and the editable page controls were not sufficiently discoverable.

- Template choices now use explicit buttons with delegated click handling, selected-state feedback and a clear “Use this design” instruction.
- A four-step builder index provides direct links to Template, Business Details, Website Pages and Preview/Publish.
- The Website Pages section now has a visible page index with an **Edit page** link for every page, so the subscriber does not need to discover the editors by scrolling.
- The editable page library now includes About us, Business Information, Contact, Terms & Conditions, Privacy Policy, Cookie Policy, Delivery & Returns, Sell to us, How it works, FAQ, Payments, Warranty & Guarantees and Complaints, plus the built-in Shop and Customer account pages.
- Recommended pages are enabled by default; optional pages remain available to edit but can be kept out of navigation.
- Each editable page has a clear explanation of what belongs there, editable title/body fields and optional SEO title/description fields.
- The live builder preview now exposes the enabled website pages in its navigation so the subscriber can see the page structure while building.
- The category explanation now explicitly distinguishes the database behaviour: Buying and Selling use the same category record with capability flags; TradeFlow does not create a duplicate selling category.
- Existing `category_manifest` content is preserved when the draft is saved rather than being overwritten with an empty array.

The category-management and inventory dashboard controllers were also corrected to use the authenticated subscriber tenant supplied by `subscriber-tenant-context.js`, rather than a hardcoded test-tenant allow-list. This is necessary for the normal new-subscriber flow to reach Categories and Inventory safely.

**State:** Implemented on main; browser verification remains required for template clicks, page jump links, category access and the new-subscriber Inventory path.


## Website Builder branded media, selling-page editing and domain entry — 18 September 2026
The Website Builder has been extended so subscribers can establish a visual brand rather than only editing text.

- Subscribers can upload a homepage image and images for editable website pages.
- Page image uploads are stored in the tenant-scoped tradeflow-site-media public asset bucket. Upload/delete/update operations are protected by authenticated tenant website-management policies; public read is intentional because these are published customer-facing website assets. Supabase documents that public buckets make objects publicly retrievable while upload/delete operations remain policy-controlled. citeturn0search0turn0search1
- Site image metadata is also recorded in the existing tenant-scoped media_assets table.
- The Buying / Sell to us page and the Retail Shop page can now carry their own text and branded image. The Retail Shop remains system-driven for live product data; the subscriber controls its introduction, title and presentation while products continue to come from Inventory/Selling.
- Template CSS was expanded so the ten starting designs have more distinct navigation, hero, card, spacing and background treatments.
- The subscriber Business Dashboard now contains a Website URL entry point. domain-settings.html stores a subscriber domain in the existing tenant_domains model as pending and displays its connection state.
- Existing publish_site_revision() already refreshes published_site_index for domains whose status is active, so the final hostname-to-tenant routing is preserved. The external DNS/hosting target and ownership verification mechanism are intentionally not invented yet; a multi-subscriber hosting layer must be selected before a domain can be automatically activated.
- publish_site_revision() was corrected to accept website content schema versions 1 and 2. The current builder uses schema version 2.

**State:** Implemented on main; browser verification required for image upload, page editing, template variety, domain entry and publishing.


## Stage 1N — Visual on-page Website Builder — 18 September 2026

The subscriber Website Builder has been reworked from a form-heavy editor into a visual, page-first editing experience. The subscriber now selects a website page from the left-hand page list and sees the complete page in the main browser-style canvas. Editable text is changed directly in place using click-to-edit contenteditable areas rather than separate title/body fields.

Implemented in the visual builder:
- Home page editing directly on the page: business name, homepage headline and introduction.
- Buying / Sell to us page editing directly on the page, including its own title, body and image.
- Retail Shop page editing directly on the page, including its own title, introduction/body and image.
- Other content pages use the same direct page editing pattern.
- Customer Account remains explicitly TradeFlow-managed because it is connected to the customer portal rather than being a normal content page.
- Image add/replace/remove controls appear on the page itself. Uploads remain tenant-scoped through the existing tradeflow-site-media bucket and media_assets metadata flow.
- Subscriber logo upload is now wired to site branding and the public website renderer can display it.
- Template selection now uses visual miniature previews rather than text-only template buttons. The ten existing templates remain starting designs; switching a design does not intentionally replace subscriber-entered page content.
- The sidebar is now for page navigation, design selection, connected operational links and save/publish actions. It is no longer the primary place where page copy is entered.

The visual editor continues to save the existing schema_version 2 website content through the existing tenant_site_state/site_revisions and publish_site_revision path. Product listings remain system-driven from Inventory → Selling; the visual editor does not create or duplicate product records.

**Status:** Implemented on main; browser verification is required for direct text editing, page switching, image upload, logo upload, draft save, publish and public-site rendering.

## Stage 1O — Premium two-sided homepage — 18 September 2026

The public subscriber homepage now uses a premium marketplace structure rather than the previous basic hero-plus-cards layout. The homepage is designed around the two distinct customer intents: people who want to sell items to the business and people who want to browse/buy from the business. The structure uses a strong hero, explicit buying/selling routes, visual buying-category tiles, retail showcase tiles and a trust/process strip. This follows established two-sided marketplace design patterns without changing the underlying TradeFlow transaction architecture.

Subscriber-editable homepage controls now include:
- Homepage headline and introduction directly on the visual canvas.
- Main homepage image directly on the canvas.
- Separate editable `What we buy` and `What we sell` headings/intros.
- 6, 8 or 10 visual homepage tiles.
- Separate buying and selling tile groups, balanced across the selected tile count.
- Each tile has directly editable title/body and its own image add/replace/remove control.
- Buying tiles route to the existing Sell to us / Buying page.
- Selling tiles route to the existing Retail Shop; actual retail product records remain controlled by Inventory → Selling.

The `premium` / Premium Marketplace template is now available as an additional starting design. Existing template architecture remains intact.

**Status:** Implemented on main; browser verification is still required.

## 20. Subscriber Website Builder entitlement repair — 18 September 2026

The new subscriber account subscriber test 1 could authenticate and had a tenant, membership and Website Builder draft, but the Builder reported **Website could not be loaded**. The live root cause was the subscription capability gate: the onboarding RPC created a trialing subscription with trial_end = null, while private.has_tenant_feature() requires a non-null future trial_end for trialing subscriptions.

Migration 065_repair_subscriber_trial_entitlement_window.sql updates subscriber_create_business() to establish the existing 30-day trial pattern (trial_end and current_period_end) and backfills any current trialing subscription that has no trial end.

Live verification with the subscriber owner identity and tenant f3435be3-242e-4086-ad81-c4c6e8045aea confirms is_tenant_member=true, website.editor=true and website.publish=true. No RLS policy or tenant boundary was weakened.

**Status:** Implemented Live and database entitlement path verified. Browser reload of the Website Builder remains the final UI verification step.


## 21. Subscriber website branding and business extras — 18 September 2026

The Website Builder now includes subscriber-controlled brand colours for accent, text, page background, header/navigation, buying section, selling section and footer. These values are stored inside the existing website content JSON under site.theme and do not alter the application shell or tenant security model.

The Builder also stores subscriber social profile links (Facebook, Instagram, LinkedIn, YouTube, TikTok and X), an optional website share-button setting, and up to four review-site links. The published customer-facing website renders valid subscriber-supplied external links and provides native sharing where the browser supports it, with Facebook and LinkedIn sharing fallbacks.

These are presentation/business-profile settings only. TradeFlow does not create or verify third-party social or review accounts. Subscriber-entered URLs are restricted at render time to HTTP/HTTPS links.

**Status:** Implemented in GitHub; browser verification remains open for colour preview, Save Draft, Publish and public rendering.


## Restore checkpoint — 18 September 2026

This document is part of the locked TradeFlow stopping point for 18 September 2026. GitHub restore branch: checkpoint-tradeflow-20260918-premium-builder-final. Current main checkpoint commit: 0acc8d7ecca0de368172bf4fec1d746f11279dbd. Live Supabase includes migration repair_subscriber_trial_entitlement_window. Continue tomorrow from this checkpoint; do not modify GearCashOut.


## Domain purchasing foundation — 19 September 2026

The existing `tenant_domains` table already provides the tenant-scoped custom-domain connection/routing layer. This change extends that model so TradeFlow can later offer Shopify-style domain purchasing without replacing the existing website publication architecture.

Database foundation added live:
- `domain_tld_catalog` — platform TLD catalogue, registration/renewal/transfer pricing fields, currency, registration-term limits and provider-neutral product metadata.
- `tenant_domain_orders` — tenant-scoped registration, renewal and transfer order ledger with retail amount, registrar cost, payment references, provider references, lifecycle status, expiry and auto-renew state.
- `tenant_domains.acquisition_source` — `connected`, `purchased` or `transferred`.
- `tenant_domains.registrar_provider`, `registrar_domain_id`, `registered_at`, `expires_at`, `auto_renew` and `provider_metadata`.

Security:
- Both new tables have RLS enabled.
- TLD catalogue is read-only to public/authenticated clients and only active rows are exposed.
- Domain orders are tenant-isolated and writable only through existing tenant website-management/editor permission boundaries.
- Registrar credentials/secrets are not stored in the database.

The TLD catalogue is a pricing/configuration foundation, not an availability cache. Real-time availability and final pricing must come from the selected registrar/provider immediately before purchase.

Current domain UI remains a **connection** screen only: `domain-settings.html` saves a pending custom domain. The purchase UI, payment flow, registrar API integration, automatic DNS/hosting activation and renewal automation are separate implementation work.

Current commercial plan pricing/entitlement for domain purchasing is intentionally not decided and must not be invented.

**Status:** Database foundation implemented and schema-verified. Full purchase journey remains Proposed/Planned.



## Website Builder final refinement pass — 19 September 2026

The subscriber Website Builder has now received the agreed refinement pass before final browser review. Added: controlled typography options (font style, hero/section/body/navigation size levels), button styles, header styles, footer styles, optional homepage section visibility, optional second images for the homepage hero and content pages, and cleaner image controls with Add/Replace/Remove behavior. Homepage tiles remain unnumbered and directly editable.

Public rendering now consumes the saved typography, section visibility and multi-image settings. Asset cache versions are refreshed and both Builder and public runtime syntax have been checked. This is **Implemented in GitHub, not yet browser-verified**. Final verification should cover Builder preview, Save Draft, Publish, public site, responsive layout and the new controls.


## Draft preview and can_tenant permission repair — 19 September 2026

Browser verification exposed two separate issues. First, authenticated Website Builder operations were failing with `permission denied for function can_tenant`. The live database had the required RLS policies calling `private.can_tenant(uuid,text,text)`, but EXECUTE was only granted to postgres. Live migration `fix_authenticated_can_tenant_execute` restored EXECUTE to the authenticated role without changing the SECURITY DEFINER function or weakening tenant/feature checks. The migration is recorded in `supabase/migrations/066_fix_authenticated_can_tenant_execute.sql`.

Second, the Builder's previous `Open public website` link attempted to load the published-site path. A newly created subscriber may have a draft but no published revision, so that path correctly reports that no published website exists. The Builder link has therefore been renamed **Preview website** and now opens an authenticated draft-preview mode. The preview reads the signed-in subscriber's draft through existing RLS-protected `tenant_site_state` and `site_revisions` access; it does not expose drafts anonymously. The public site remains the published-site path and will work after the subscriber publishes a revision.

Validation: Builder and public-site JavaScript syntax checked OK; live EXECUTE grant confirmed for authenticated. Browser end-to-end preview verification remains the next user check.


## 19 September 2026 — Shared Buying & Selling category tree

The subscriber Categories & Properties workspace has been rebuilt around a shared hierarchy: **Category → Branch → Product Properties**. Categories and branches have independent Buying and Selling live controls. Individual properties now also have independent Buying/Selling visibility controls, separate from whether a live property is required.

Database migration 067_category_branch_buy_sell_tree added public.category_branches and branch references on category_fields, buying_items, inventory_assets and listings. Existing category/property/workflow records were backfilled to a default branch. Migration 068_enforce_category_branch_consistency ensures a branch belongs to the same category and supplies the category's active branch when an older workflow insert does not specify one.

The inventory workspace now selects a category branch and loads the branch's dynamic properties. Selling listings inherit category and branch from the selected inventory asset rather than allowing an independent sales category that could diverge from the acquired product. This establishes the shared category identity across Buying → Acquisition → Inventory → Selling; the customer-facing Buying submission UI still needs to be updated to present the same branch tree before this workstream is complete.

Validation: live migrations applied successfully; existing category data was preserved and assigned to default branches. Browser verification of the new Categories, Inventory and Selling screens remains required.


## 19 September 2026 — Subscriber navigation and Website Builder loading state

The Business Dashboard navigation now includes **Categories & Products**, linking to the shared Category → Branch → Product Properties workspace. The separate Website area also exposes the same link so category configuration is reachable without leaving the subscriber shell.

The Website Builder's top status was remaining on its initial `Loading website…` label, which did not clearly distinguish an active load from a failed/stalled draft load. The builder now reports `Connecting to your website…`, `Loading website draft…`, `Website loaded`, or `Website could not be loaded`, with explicit 15-second authentication and 20-second draft-load timeouts. The Builder script cache version was raised to v15.


## 19 September 2026 — Subscriber navigation and business settings

Buying workspace navigation was corrected so Selling, Finance & Payments, Inventory, Categories & Products, Website URL and Settings link to their actual subscriber pages rather than dashboard anchors. Selling and Finance navigation were also corrected to use the real Settings/Selling/Inventory pages.

A dedicated `settings.html` / `settings.js` subscriber settings workspace was added. It links to the existing Website URL/domain management page and provides tenant-scoped accepted payment-method settings. New table `public.tenant_payment_methods` stores enabled methods and customer instructions; RLS permits tenant members to read and tenant admins to manage them. This is accepted-payment configuration only; it does not claim that an online payment provider such as Stripe is connected. Provider connection remains a separate integration boundary.


## 19 September 2026 — Draft preview navigation repair

Draft Website Builder preview was loading the subscriber's draft correctly on the home page, but the generated internal navigation links did not preserve `preview=draft`. Clicking Home/About/Contact/etc. therefore left authenticated draft-preview mode and attempted to load the unpublished public site, producing `Website unavailable` when no published revision existed.

`public-site.js` now preserves `preview=draft` in `pageUrl()` whenever the current page is a draft preview. `public-site.html` cache-bust was raised to v9. This keeps all internal website-page navigation inside the authenticated draft preview until the subscriber publishes the site.


## 19 September 2026 — Homepage image independence and header branding

Homepage hero images are explicitly independent: `homepage.image_url` is the main image and `homepage.image_url2` is the optional second image. The builder now labels these controls accordingly and does not reuse the first image automatically. Homepage tile images remain independently stored per tile. Uploaded images are displayed with contain behaviour so the complete photograph remains visible.

Header branding was refined so an uploaded logo is shown instead of also displaying the editable business-name text beside it. Logo dimensions now preserve the complete image proportion and allow a larger natural width/height within the responsive header. If no logo is uploaded, the business name remains editable text.


## 19 September 2026 — Draft preview no longer blocked by shop listings

The subscriber draft preview could remain on the initial `Loading website…` screen because `loadDraftPreview()` waited for the retail product-listings RPC before completing the page load. The website content itself was already available, but a slow/stalled listings request could prevent the preview from rendering.

The preview now applies the draft content first and treats shop listings as a separate, non-blocking step with an 8-second timeout. If listings do not load, the rest of the website remains available and the shop area reports that products are temporarily unavailable. Public-site cache-bust is now v11.


## 19 September 2026 — Public website startup syntax error repaired

The public subscriber website reported 'Uncaught SyntaxError: Identifier \'brandText\' has already been declared' during startup. The error was caused by two const brandText declarations in public-site.js within applyContent(). The duplicate declaration was removed so the existing branding logic uses the single brandText reference. This was a JavaScript startup error, so the browser could not execute the public-site loader at all and remained on the static loading screen.

Fix commit: 26e698c5fdac77a0618a402ecd2b26da5a3582ba.


## 19 September 2026 — Homepage hero image editing made explicit

The premium homepage already stored two independent hero image fields (`homepage.image_url` and `homepage.image_url2`) and the visual editor rendered both. The builder UI was made more explicit so subscribers now have a dedicated Homepage hero photos control showing separate Main hero image and Second hero image actions, in addition to the direct Replace/Add controls on the page preview. Builder asset cache-busting was advanced to v17.

The two hero images remain independent and are not reused automatically by the builder or public website.


## 19 September 2026 — Hero image duplication clarification

The premium homepage renderer intentionally supports separate hero images and homepage tile images. Investigation of the subscriber test draft showed the same lens photograph was stored independently in the hero image field and in the `buy-2` homepage tile, so the public site correctly rendered the photograph twice. This was a content/configuration duplication, not an image rendering bug.

The homepage builder now exposes a `Hero image` visibility control separately from the `Hero section`. The current subscriber test draft has hero-image display disabled, leaving the lens photograph in its intended buying tile. Tile images remain independent from hero images. The public renderer now respects `homepage.sections.hero_image`.


## 19 September 2026 — Template family split into structural layouts

The ten website templates are now intentionally divided into two families. The first five remain the existing layouts: Business, Premium Marketplace, Buy & Sell, Services and Editorial. The second five now use structural layout differences rather than primarily colour/font differences: Retail Sidebar (left navigation), Professional Sidebar (right utility navigation), Bold Rail (dark left navigation rail), Classic Masthead (centred masthead with separate navigation band), and Local Business (compact grouped navigation). The 6/8/10 homepage tile control remains independent of template selection.

Builder CSS cache was advanced to v18 and public-site CSS to v9. Responsive rules collapse the sidebar layouts back to a mobile navigation arrangement on narrow screens.


## 19 September 2026 — Buying catalogue and research foundation

The existing Categories & Properties screen was too abstract for the actual Buying workflow. A separate subscriber workspace, `buying-catalogue.html` / `buying-catalogue.js`, now provides a clearer path: **Category → Buying Branch → Products We Buy → Research & Pricing**. This keeps the shared category/branch structure but gives each buying branch a practical product list.

New tenant-scoped tables:
- `tenant_buying_products`: exact manufacturer/model/package records that a subscriber buys, with active status, automatic percentage of researched UK New price, optional manual offer price, and pricing notes.- `tenant_buying_research`: product-level research evidence with UK New, UK Used/Other and Overseas evidence types, source, URL, observed price, currency, condition, availability, notes and checked timestamp.

Pricing rule is deliberately simple at this stage: **automatic percentage populated = automatic valuation basis; percentage blank = manual offer required**. Automatic percentage and manual price cannot be entered together. Existing GearCashOut remains reference-only.

The protected quote bridge adds `buying_items.buying_product_id` and `calculate_buying_item_valuation(tenant_id,buying_item_id)`. It calculates an automatic amount from the latest qualifying GBP UK New evidence and the configured percentage, otherwise returns a manual-review reason. It does not publish an offer or bypass the existing valuation approval workflow.

Live verification: the new tables currently contain 0 products and 0 research records; the current subscriber test tenant has 4 existing categories and 4 branches. Existing category data was not deleted or rewritten.


## 19 September 2026 — Buying reference price clarification and Website Builder repair

The Buying workspace has been simplified further around a branch-level rule. category_branches.default_buying_percentage now stores an optional default percentage for the branch. A subscriber can open a branch such as Cameras and set, for example, 60% of the researched UK New reference price. Products can still carry an explicit percentage override; if neither branch nor product has a percentage, the valuation remains manual. The reference price is the latest qualifying GBP UK New research record for the selected buying product.

The protected calculate_buying_item_valuation() RPC now resolves the percentage as product override first, otherwise branch default, and uses the latest qualifying UK New evidence as the reference price. It does not bypass existing valuation/offer controls.

Website Builder issue diagnosed and repaired: website-builder.js contained a JavaScript syntax error in the premium homepage hero expression. This prevented the builder script from executing, which is why the page could remain at Loading website with a blank editor. The hero expression was rewritten and verified with a JavaScript parser (new Function) as syntactically valid. website-builder.html now cache-busts the script to v19 and includes startup error diagnostics so future script failures are visible instead of leaving a blank editor.


## 19 September 2026 — Buying condition price matrix

The subscriber What We Buy experience has been redesigned as a full-width buying price matrix rather than a narrow product editor. The workflow is Category → Branch → Manufacturer/Model list. Each product row shows the latest qualifying UK New reference price and UK Used reference price as read-only research outputs, with source/date links where available. The subscriber enters six condition percentages in the same row: New Sealed, Never Used, Opened (based on UK New reference), Excellent, Good, Poor (based on UK Used reference). Calculated buying prices are shown immediately and all percentages can be saved together.

Research evidence remains non-editable from this subscriber pricing screen. Manual offer price has been removed from the What We Buy configuration UI; the existing database field is retained for compatibility but is no longer used by this setup. If an automatic condition rule or reference price is unavailable, the buying workflow reports that an automatic price cannot be calculated and the normal manual offer process remains available.

Buying items now carry an optional item_condition using the six configured condition values. calculate_buying_item_valuation() uses the selected condition, the corresponding condition percentage, and the latest qualifying GBP UK New or UK Used research reference. The Buying dashboard now asks for the condition before calculating the automatic price.

External market research reviewed for terminology only: UK camera dealers commonly distinguish condition grades such as Mint/Like New, Excellent, Good and heavier-use grades, while MPB describes five cosmetic conditions and uses condition as an input to its pricing process. TradeFlow's six subscriber-configurable labels are intentionally kept as the business's own pricing matrix rather than copied from a third party. citeturn0search6turn0search4


## Buying Catalogue Management & Research — 19 September 2026
- What We Buy is the full-width subscriber buying catalogue.
- Subscribers can add and edit Buying categories, add and edit branches, and manage reusable manufacturers from the catalogue management panel. Existing category/branch RLS remains authoritative.
- Five buying conditions are now used: **Sealed**, **Opened, Never Used**, **Excellent**, **Good**, **Poor**. Sealed and Opened, Never Used use UK New research; Excellent, Good and Poor use UK Used research.
- `buying_items.item_condition` uses `sealed`, `opened_never_used`, `excellent`, `good`, `poor`.
- `tenant_buying_condition_rules` stores `sealed_percentage`, `opened_never_used_percentage`, `excellent_percentage`, `good_percentage`, `poor_percentage`.
- `tenant_buying_manufacturers` provides a tenant-scoped reusable manufacturer list with buying-management RLS.
- Research Centre (`buying-research.html/js`) writes subscriber-entered UK New/UK Used evidence to `tenant_buying_research`. What We Buy reads the latest checked GBP evidence as read-only reference prices.
- Gemma/other research automation can use the same `tenant_buying_research` table later; no external automated research source is claimed as live by this change.
- Manual offer remains the fallback when a condition rule or appropriate research is unavailable.


## Buying Price Basis & Manual Override — 19 September 2026
- Each of the five buying conditions can independently choose its automatic research basis: **UK New** or **UK Used**.
- Each condition has an automatic percentage against that selected reference price.
- Each condition also has an optional exact **manual override** price. A manual override takes precedence over the automatic calculation.
- If no suitable research exists for the selected basis, the subscriber can still enter a manual price; automatic calculation remains unavailable until research is available or the manual override is removed.
- The valuation RPC returns `automatic`, `manual_override`, or manual-fallback states and identifies the selected reference type.


## Buying Catalogue Hierarchy — 19 September 2026
- The subscriber catalogue is intentionally structured **Category → Branch / Type → Manufacturer → Model**.
- Example: **Cameras → Digital → Canon → EOS 750D**; **Cameras → Lenses → Canon → EF 50mm**; **Cameras → Tripods → Manfrotto → [model]**.
- Category management now shows each category with its branch count. Selecting a category loads and displays all branches belonging to that category.
- Selecting a branch makes the working context explicit and shows manufacturers used within that branch. Manufacturers remain tenant-shared because the same manufacturer can legitimately appear across multiple branches.
- Products remain assigned to the selected category and branch, preventing the catalogue from becoming an ambiguous flat list.


## Bulk Buying Pricing Profiles — 19 September 2026
- What We Buy now provides four ready-made pricing profiles that apply percentage rules across every product in the selected branch.
- Profiles are based on the Sealed percentage: **70%, 60%, 50%, 40%**. Current ladders are respectively 70/65/60/50/40, 60/55/50/40/30, 50/45/40/30/20, and 40/35/30/20/10 for Sealed / Opened Never Used / Excellent / Good / Poor.
- Applying a profile changes only automatic percentages. It does not change research evidence, reference selection, or manual override prices.
- Individual products can still be adjusted after a bulk profile is applied.


## Selectable Bulk Pricing — 19 September 2026
- What We Buy now supports product-level selection with a checkbox on every visible product.
- `Select all visible` respects the current manufacturer and model filters, so a subscriber can select an entire manufacturer, a filtered subset, or individual products.
- Bulk pricing lets the subscriber choose **UK New** or **UK Used** as the automatic reference for all five conditions and choose one of the four percentage profiles at the same time.
- `Apply pricing to selected` updates the selected products' condition reference types and automatic percentages. Research evidence and manual override prices are preserved.
- The purpose is to make a large catalogue manageable without forcing the subscriber to edit every condition cell individually.


## Universal Reference Selection — 19 September 2026
- The bulk reference choice is universal across the five conditions for each selected product. Choosing UK New means Sealed, Opened Never Used, Excellent, Good and Poor all calculate from that product's UK New research; choosing UK Used makes all five calculate from UK Used research.
- Condition does not select the research basis. Condition only selects the percentage rule.
- The UI previews the selected reference immediately for selected rows; `Apply pricing to selected` persists the reference type and percentage profile.
- TradeFlow does not silently substitute UK New for missing UK Used evidence or vice versa. If the chosen research basis has no evidence, the automatic price remains unavailable until research or a manual override exists.
- What We Buy now has clear CTAs for Main Dashboard, Buying Dashboard and Research Centre.


## Active Buying Price / Manual Override — 19 September 2026
- The catalogue now labels the price that TradeFlow will actually use as **ACTIVE BUYING PRICE**.
- If a condition has a manual override, that exact price is the active price and takes precedence over its automatic percentage calculation.
- The automatic calculation remains visible as `Automatic would be £X` for comparison, but it is not the active buying price while a manual override exists.
- To return a condition to automatic pricing, the subscriber clears the manual override field and leaves it blank, then saves the buying prices.
- The UI explicitly tells the subscriber that clearing the manual field returns the condition to automatic pricing.


## Reset Selected Buying Prices — 19 September 2026
- What We Buy now has a protected **Reset selected prices** action.
- First click arms the reset and displays a warning; a second click within five seconds confirms the destructive action.
- Reset deletes the selected products' condition-pricing rule rows and clears the legacy product-level automatic/manual base-price fields. The products then have no configured catalogue buying price and can fall back to manual quote/valuation handling.
- Selecting UK New or UK Used previews the selected basis immediately. If the selected basis has no research, automatic prices show unavailable/manual quote required rather than retaining a stale calculation from the other basis.


## Standalone TradeFlow Master Catalogue — 19 September 2026
- TradeFlow now has its own standalone master catalogue tables: `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_manufacturers`, `catalogue_master_products` and `catalogue_master_product_identifiers`.
- The initial seed was copied from the separate GearCashOut / Action Buyer UK catalogue as a one-time data import. TradeFlow does not query GearCashOut at runtime and there are no foreign keys or live catalogue dependencies back to GearCashOut.
- Imported catalogue scope is product metadata and identifiers: 34 top-level categories, 179 branches/types, 73 manufacturers, 3,845 products and 108 product identifiers.
- GearCashOut retailer-price evidence, research evidence and market-pricing fields were deliberately not copied into the TradeFlow master catalogue. Subscriber buying prices remain independently configured through TradeFlow research and condition rules.
- The live plan definition currently assigns `catalogue.pre_filled` to the **Catalogue** plan, not Enhanced. Enhanced remains the separate higher-tier feature set already defined in `plan_features`.
- Catalogue-plan seeding is performed by the protected `public.seed_tenant_master_catalogue(uuid)` RPC. It copies the master catalogue into the subscriber's own `categories`, `category_branches`, `tenant_buying_manufacturers` and `tenant_buying_products` records. Once seeded, the tenant operates on its own copy.
- `tenant_catalogue_state` records the seed version and counts so the operation is idempotent.
- The What We Buy page now attempts the protected catalogue seed during startup for eligible Catalogue-plan tenants. Non-Catalogue plans continue to use their existing tenant catalogue path.
- Buying-catalogue JavaScript cache-buster is now v15.
- A startup blocker was identified and repaired: the page referenced an undefined `armOrResetSelectedPrices` handler before authentication initialisation, which could stop the script before Category/Manufacturer/Branch loading. The handler is now defined and performs the intended two-step reset.


## 19 September 2026 — Master catalogue entitlement expanded

The independent TradeFlow master catalogue remains a separate snapshot from GearCashOut / Action Buyer UK. The catalogue.pre_filled entitlement has now been enabled for all three active customer-facing plans: **Basic, Enhanced and Catalogue**. Each plan receives the same unlimited category/product/subcategory entitlement configuration. This changes access entitlement only; it does not create a runtime dependency on GearCashOut and does not import GearCashOut research or pricing evidence into subscriber buying references.

Verification: live plan_features confirms catalogue.pre_filled enabled for Basic, Enhanced and Catalogue. The actual tenant catalogue seed/copy path remains tenant-owned and must continue to use the TradeFlow master snapshot.


## 19 September 2026 — Master Catalogue duplicate-category cleanup

The standalone TradeFlow master catalogue was inspected after the GearCashOut snapshot import. GearCashOut remains untouched and is not queried at runtime. Two clear duplicate category structures were found in the TradeFlow copy and cleaned up:

- Drone → Drones: the singular Drone category and its one product were moved into the canonical Drones category. Its Drone branch was moved under Drones and retained so the product/branch relationship was not lost.
- Tripod/Support → Tripods: the Tripod/Support category and its two products were moved into the canonical Tripods category. Its duplicate Tripods branch was merged into the existing canonical Tripods branch before the old branch/category were deleted.

The cleanup was applied only to catalogue_master_categories, catalogue_master_branches and catalogue_master_products in the TradeFlow Supabase project. No GearCashOut database objects or data were changed. The canonical categories now present are Drones and Tripods; the duplicate category records no longer exist.

Broader names such as Camera & Video, Cameras, Audio & Video, Audio, Camera Equipment and Video Equipment were not automatically merged because their names alone do not establish that they are duplicates. This avoids silently moving distinct product classes.

Verification: the merge migration completed successfully; the duplicate category names were re-queried and only Drones and Tripods remain from those pairs. The Drones category now contains 541 products across its retained branches, and Tripods contains 4 products in its single canonical Tripods branch. Browser verification of the subscriber selector remains open.


## 2026-09-19 — Buying Catalogue Master Copy & Cascading Selectors

- The subscriber Buying Catalogue uses the TradeFlow-local master catalogue tables (catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers, catalogue_master_products) as the seed source. The subscriber copy is tenant-owned in categories, category_branches, tenant_buying_manufacturers, and tenant_buying_products and does not query GearCashOut at runtime or use GearCashOut research/pricing for valuations.
- The current master snapshot contains 32 categories, 178 branches, 73 manufacturers and 3,837 active products. The test subscriber has its own tenant copy and can diverge independently.
- Buying Catalogue selectors are now cascading: Category → relevant Manufacturers → relevant Branches for the selected manufacturer → Models in the selected branch/manufacturer. Changing an upstream selection resets and reloads downstream selections rather than leaving unrelated values available.
- buying-catalogue.js commit ff575e5204f7cb3efc12284a5109be0610334a5b implements the selector dependency logic. buying-catalogue.html commit 34771b980131a4be683179ecf6f6f8b5a21ce2c9 changes Model to a dependent select and cache-busts the JS to v16.
- Syntax check passed with new Function() after the selector change. Live browser verification is still required after a hard refresh.

## 23. Buying catalogue master-copy architecture and selector repair — 19 September 2026

The Buying Catalogue now uses a **TradeFlow-owned master catalogue copy**. The source data was copied into these TradeFlow tables and is no longer queried from GearCashOut:

- `catalogue_master_categories`: 32 master categories
- `catalogue_master_branches`: 178 master branches
- `catalogue_master_manufacturers`: 73 manufacturers
- `catalogue_master_products`: 3,845 products

The live `seed_tenant_master_catalogue(uuid)` function reads only the TradeFlow `catalogue_master_*` tables. A direct function-definition check found no GearCashOut reference. Subscriber copies remain tenant-owned in `categories`, `category_branches`, `tenant_buying_manufacturers` and `tenant_buying_products`.

The pre-filled catalogue entitlement is now enabled for **Enhanced** and **Catalogue**, and disabled for **Basic**. This matches the intended package boundary. The active Catalogue plan remains in the database.

### Buying selector fault

The Buying Catalogue source was calling `loadCategoryScope()` during category initialisation, but the current `buying-catalogue.js` did not contain that function. That prevented the category → manufacturer → branch initialisation chain from completing. The repair added `loadCategoryScope()`, loads the selected category's tenant products first, then derives the manufacturer filter from those products before loading the selected category's branches.

The HTML cache-buster was advanced to `buying-catalogue.js?v=17` so the browser does not continue serving the previous controller.

The category selector also now de-duplicates category slugs in the rendered list.

### Legacy test-tenant cleanup

The existing subscriber test tenant had stale pre-master catalogue aliases left from earlier catalogue work. The known legacy `Drone` category was merged into the canonical `Drones` category and its product retained. The stale `Tripod/Support` category was merged into canonical `Tripods`. The empty legacy `Drones` branch was removed; the canonical `Drone` branch was restored under `Drones`.

The tenant still retains its unrelated custom `Accessories` category and its manually added Canon product. These were not deleted.

### Verification state

Database verification completed for the master-copy counts, package feature flags, test-tenant alias cleanup and absence of duplicate category slugs. The code change is committed. **Browser verification of the repaired selector is still OPEN**: hard-refresh the deployed Buying Catalogue and confirm Category → Manufacturer → Branch populate, then select Cameras → Canon → Digital and confirm the product matrix loads.


## 24. Buying Catalogue master-copy rollout and browser cache repair — 19 September 2026

The Buying Catalogue master-copy design is confirmed as the intended Enhanced/Catalogue feature. TradeFlow has its own master catalogue tables containing 32 categories, 178 branches, 73 manufacturers and 3,845 products. The tenant seed RPC reads only those TradeFlow master tables; it does not query GearCashOut at runtime and GearCashOut research/pricing is not used for tenant buying valuations.

Package entitlement is confirmed live: Basic = disabled, Enhanced = enabled, Catalogue = enabled for catalogue.pre_filled.

The current subscriber test tenant subscriber test 1 is on Basic, so it is not entitled to auto-seed the master catalogue. Its existing custom catalogue remains separate. An Enhanced/Catalogue tenant is the correct browser test for the pre-filled catalogue.

The Buying Catalogue page had a deployed-browser cache mismatch: the screenshot reported loadCategoryScope is not defined even though the current controller contains that function. The page script cache-buster has therefore been advanced from v17 to v18. The temporary on-page master-catalogue explanatory banner has also been removed so product pages do not carry development/prompt text.

Browser verification remains OPEN until the deployed page is hard-refreshed and tested against an Enhanced/Catalogue tenant.




## 19 September 2026 — Unified subscriber catalogue selection architecture

The subscriber category page is being consolidated with the master catalogue. The intended model is now:

**TradeFlow master catalogue → subscriber selects products → TradeFlow automatically creates the required tenant category/branch → product is enabled for Buying and/or the Selling Website.**

The subscriber does not have to manually create a live category before selecting a catalogue product. Categories and branches remain tenant-owned copies and can diverge from the master catalogue. Products can be enabled for Buying only, Selling Website only, or both.

A new tenant-scoped table, `tenant_catalogue_selections`, records the subscriber's relationship to each master product without making the master catalogue tenant-specific. A protected `activate_master_catalogue_products()` RPC creates any required tenant category/branch/manufacturer records and, when Buying is enabled, creates the corresponding `tenant_buying_products` record so the existing Buying/Valuation path remains intact.

The unified UI is `categories.html` / `category-management.js`. It reads the standalone TradeFlow master snapshot through `get_master_catalogue_for_selection()`. It does not query GearCashOut / Action Buyer UK.

The master snapshot currently verified in TradeFlow contains 32 categories, 178 branches, 73 manufacturers and 3,845 products. This is a TradeFlow-local snapshot. GearCashOut remains outside the runtime dependency graph and is not used as buying research or valuation evidence.

Subscription boundary remains explicit: `catalogue.pre_filled` is currently disabled for Basic and enabled for Enhanced/Catalogue. The current Basic test tenant therefore cannot be used to browser-test the master catalogue selection until an eligible tenant/plan is used.

State: **Implemented at database and GitHub boundary; browser verification remains open.**



### 19 September 2026 — Buying Prices no longer seeds the entire tenant catalogue

The separate Buying Prices workspace no longer calls `seed_tenant_master_catalogue()` when it opens. Catalogue activation is now an explicit subscriber action on Catalogue & Categories. Buying Prices works on products already selected for Buying and remains responsible for condition percentages, research basis and manual overrides. The legacy seed RPC remains available for controlled migration/maintenance but is no longer the normal subscriber page startup path.


## 2026-09-19 — Unified subscriber buying catalogue

The subscriber buying setup is now a single workflow rather than separate Catalogue & Categories and Buying Prices pages. 

- `catalogue_master_*` is TradeFlow's standalone master catalogue. It is not queried from GearCashOut / Action Buyer UK at runtime.
- The copied master data was verified against the source dataset: 3,845 products, 102 catalogue-category labels, 34 main categories, 155 product types and 73 manufacturers; 3,822 products are active/customer-visible in both datasets.
- The unified `buying-catalogue.html` page lets an Enhanced/Catalogue subscriber filter the master catalogue, select products and activate them for Buying (or Buying + Selling).
- Activation automatically creates the subscriber category, branch and manufacturer records and the tenant buying product. A product with no configured buying price remains eligible for manual valuation/quote rather than receiving an invented price.
- `categories.html` is now a legacy redirect to the unified buying catalogue.
- The master selection RPC now uses the copied product's `catalogue_category` label for subscriber-facing category creation.
- The test subscriber tenant `subscriber test 1` is on the Enhanced trial so the pre-filled catalogue entitlement can be exercised.


### Post-change verification — 2026-09-19
The authenticated RPC test returned 3,822 master products for the Enhanced test tenant. A transaction-scoped activation test for an Autel Alpha master product produced category "Drone", branch "Camera Drones", manufacturer "Autel Robotics", with both automatic_percentage and manual_offer_price null; the transaction was rolled back, so no test product was left behind.

## 19 September 2026 — Buying Pricing / Master Catalogue consolidation

The subscriber Buying Catalogue has been consolidated into a single **Buying Pricing & Master Catalogue** workflow. The master catalogue is now the source of the subscriber's Buying configuration rather than requiring the subscriber to create a category first and then return to a separate pricing screen.

For an eligible subscriber, the page reads only the TradeFlow-owned master catalogue:
- `catalogue_master_categories`
- `catalogue_master_branches`
- `catalogue_master_manufacturers`
- `catalogue_master_products`

The current live TradeFlow copy contains 32 master categories, 178 master branches, 73 manufacturers and 3,822 active/customer-visible products. This data is independent of GearCashOut and is not queried from GearCashOut at runtime.

User action is now:
**find product → choose Off / Manual / Automatic → save price/rule**.

Choosing Manual or Automatic calls `configure_master_catalogue_buying_product()`. That protected RPC creates or links the tenant category, branch and manufacturer and creates/activates the tenant `tenant_buying_products` record. The subscriber therefore does not have to build the category/product hierarchy separately.

Pricing states are visually distinguished:
- light red/pink = Inactive;
- light green = Active for Buying but no price configured;
- light yellow = Manual offer;
- light grey = Automatic pricing rule.

Manual pricing is stored in the tenant buying product's `manual_offer_price`. Automatic pricing is stored in `tenant_buying_condition_rules` with the existing five condition percentages and research-basis defaults. Turning a product Off/reset clears its buying price configuration and deactivates the tenant buying product without deleting the master catalogue product.

The valuation RPC `calculate_buying_item_valuation()` now checks a configured product-level manual buying price before condition-based automatic pricing, so a manual price selected from the master pricing page is actually honoured by the downstream Buying → Valuation workflow.

Implementation:
- `buying-catalogue.html` commit `cc0e228ebda87113d2a65dbb026f7ef634909dbb`
- `buying-catalogue.js` commit `900705eb3112284cbd21e16141ffafd252a3089d`
- Supabase migration `master_catalogue_pricing_control`
- Supabase migration `manual_product_price_in_buying_valuation`

Verification state: **Implemented / database boundary tested; authenticated browser verification remains OPEN.** The previous category/manufacturer/branch selector failure is no longer the intended workflow because the page no longer requires those tenant-owned selectors to be populated before pricing a master product.


## Website Builder / Subscriber Template Rebuild — 20 September 2026

The subscriber website system has been rebuilt on branch `website-template-unification` so the visual template selected in Website Builder is the same template family rendered by the public subscriber website.

### Customer-facing design rules
- Both sides of the business are first-class: **What We Buy** and **What We Sell**.
- The public header contains a prominent **What We Buy** menu, populated from the subscriber's connected Buying Catalogue.
- The public header contains a direct **What We Sell** link to the retail shop.
- The What We Buy menu expands as new catalogue categories are added; it is not a fixed list of categories.
- Buying category pages show the current connected products and provide a **Start selling this category** route into the customer account flow.
- Retail products are loaded from the subscriber's published Inventory → Selling data.
- A site with a small buying catalogue stays compact; the same layout can expand as categories and products are added.
- The template does not require subscribers to re-enter catalogue products, prices or inventory.

### Four-step subscriber setup
1. Add business name and logo.
2. Choose brand colours.
3. Choose one of the ten templates.
4. Save, preview and publish.

Content, buying categories and retail products remain connected to TradeFlow rather than being duplicated inside the website editor.

### Ten supported templates
Editorial, Classic, Grid, Studio, Horizon, Field, Business, Luxe, Commerce and Impact.

The public renderer now contains the same ten template layouts and responsive rules used by the builder. The previous public-site shell and legacy template styling were removed so an old static header cannot appear underneath the new template.

### Business-name handling
A blank subscriber business name is now displayed as **Your business** rather than the platform name. The old public fallback to **TradeFlow** was removed. TradeFlow remains only as the platform attribution in the footer.

### Preview / deployment
The public website assets were cache-bumped to version 40. This is intentional so browsers do not continue serving the previous public-site CSS/JavaScript after the template rebuild.

### Architecture
- `website-builder.js` remains responsible for editing and saving subscriber website content.
- `public-site.js` is now a clean public renderer for the same ten template IDs.
- `public-site.css` was replaced with a public-only stylesheet matching the ten fresh template designs rather than carrying the previous legacy template family.
- The public page shell is now only a loading container; the renderer owns the header, hero, buying section, selling section and footer.
- Custom-domain public links now retain the active tenant ID after hostname resolution.

### Important future rule
Do not add separate visual layouts to the public renderer. Any future template must be added to the shared ten-template system and tested in both Website Builder and public Preview before publication.


## Guided Customer Selling Journey — 20 September 2026

The public subscriber website now treats **selling to the subscriber** as a guided valuation/request journey rather than a catalogue list.

### Customer journey
1. **What do you have to sell?** — choose the subscriber's buying category.
2. **What type?** — choose the product type/branch derived from the connected buying catalogue.
3. **What make?** — manufacturer options are narrowed from the connected catalogue.
4. **What model?** — model options are narrowed from the previous selections; package/version is shown when available.
5. **What condition is it in?** — sealed, opened-unused, excellent, good, fair, damaged, or not working/spares.
6. **Final questions** — missing package items, legal right to sell, DJI serial number when applicable, and additional notes.
7. **Review** — the customer reviews the complete request before continuing to their customer account.

The completed answers are carried in browser session state into the customer portal so the customer does not have to enter the same information again. The customer portal pre-fills the category, item title and a structured notes summary before submission.

### Navigation behaviour
- The homepage now includes a prominent **What do you have to sell?** prompt.
- What We Buy category menu entries route into the guided selling journey with the selected category preselected.
- Start Selling links from buying categories route into the same journey.
- The old buying catalogue remains available as an information view, but it is no longer the primary selling path.

### Future-proofing
The hierarchy is generated from the subscriber's connected buying catalogue rather than hard-coded DJI/drone choices. New categories, product types, manufacturers, models and packages therefore become available to the customer as the subscriber expands the catalogue.

The TradeFlow `category_fields` system remains the intended extension point for category-specific questions beyond the common selling questions. Those fields can later be surfaced dynamically in this journey without creating a separate page for each category.

### Current scope limitation
Photos are not falsely represented as uploaded by this public wizard. The current journey captures the structured information and hands it into the authenticated customer portal. Photo upload should be added as an authenticated evidence step when the existing media/storage workflow is connected to customer buying requests.


## Subscriber Business + Customer Portal Completion — 20 September 2026

TradeFlow now has the first production-oriented connection between subscriber business identity, subscriber customer management, customer account registration and the public customer website.

### Subscriber Business Settings
The subscriber Settings area now provides customer-facing business details: business name, public email, telephone, address, postcode, country, business description and public-display controls. Website URL and payment settings remain separate.

### Subscriber Customer Backend
Customer Management is now a dedicated tenant-scoped area. Subscribers can search customers and edit first name, last name, email, phone and status. The active tenant remains the security boundary.

### Customer Portal
The existing customer portal has been converted away from the old test-lab tenant selector. Customer registration now receives the tenant from the subscriber website and creates the customer relationship against that tenant. Customer profile editing is available for first name, last name and phone; authenticated email remains authoritative.

### Customer Website
The public website reads the subscriber's public business profile and can show the business description, telephone, email and address. Customer Login, What We Buy and What We Sell remain platform-controlled routes so subscribers cannot accidentally remove the core customer journey.

### Semi-editable design rule
Subscribers control templates, colours, backgrounds, typography, copy, imagery, logo, optional pages and social/review links. TradeFlow retains the customer-critical routes, tenant connection, catalogue connection, retail inventory connection and customer account entry.

### Security
A tenant-scoped tenant_public_profiles table is protected with RLS. Anonymous visitors receive read-only access to active tenant profiles. Subscriber writes require tenant.manage. Customer registration/update RPCs are restricted to authenticated users and use a pinned search path. A partial unique index prevents duplicate Auth-user/customer relationships within a tenant.

### Remaining portal work
Customer address management, richer subscriber customer detail/history, logo/profile media synchronisation and a complete fresh-account browser test remain follow-up items. Existing unrelated Security Advisor findings remain separate hardening work.


## 2026-09-23 — Test One complete end-to-end restore checkpoint

Test One is now treated as the completed known-good baseline for TradeFlow.

The test followed a new subscriber business and a new subscriber customer through the operational chain from customer selling request, valuation and offer handling, through inspection and purchase completion, into Inventory, Selling, Sales Channels and the published retail website listing.

### Restore point

- GitHub repository: `laurendigitaluk/TradeFlow`
- Restore branch: `checkpoint-test-one-20260923`
- Functional baseline commit: `80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1`
- Checkpoint documentation commit on the restore branch: `ea00d6ae238f6e47c4798b73ec6340ade2c2d5fd`
- Supabase project: `twfbmjwwqzxdvclxbun`

The restore branch is the known-good code baseline for Test One. Test Two should start from the normal/default project state without deliberately altering the Test One baseline. If Test Two introduces a regression, compare the failure against this checkpoint before changing working behaviour.

### Test One completion boundary

The following are part of the Test One baseline:

- New subscriber/business setup.
- New subscriber customer account and customer relationship.
- Public customer selling journey.
- Buying and valuation workflow.
- Initial/final offer workflow.
- Customer acceptance and shipping/receipt handoff.
- Inspection and inspection outcome.
- Bank-detail/payment handoff.
- Payment-gated purchase completion.
- Acquisition and Inventory creation at purchase completion.
- Inventory to focused Selling workspace.
- Purchase/source information and photographs carried into Selling.
- Retail listing preparation and retail condition.
- Website listing publication.
- Public retail product page and product photography.
- Sales Channels / Marketplace Management foundation.
- One physical Inventory asset as the stock master record.
- Multiple channel-listing architecture without duplicate stock.
- Editable/add/remove Sales Channels.
- eBay/Amazon connection guidance without pretending marketplace accounts are connected.

### Remaining boundary

The subscriber-facing **Subscribe / receive payments on the subscriber's website** payment integration is the remaining identified step before the subscriber website payment journey is considered complete.

Real eBay OAuth/API connection, real Amazon SP-API connection, channel-specific marketplace publishing/delisting, and authoritative cross-channel sale propagation with automatic **DELIST REQUIRED** remain later stages and are not part of the Test One baseline.

### Documentation state labels

When continuing work, distinguish:
- **Implemented in GitHub** — code exists in the repository.
- **Live DB verified** — the corresponding Supabase state has been checked.
- **Browser verified** — the user-facing behaviour has been exercised in a browser.
- **Checkpointed** — the state is recorded as a named restore baseline.

Do not describe an item as browser verified when only GitHub or database verification has occurred.



## Initial offer workflow — 24 September 2026

TradeFlow now treats the initial customer offer as one workflow with two possible manual values: **Manual offer — Cash** and **Manual offer — Trade-in**. A manual initial offer may publish one or both values, and the customer can choose which published option to accept. Each option is stored as an offer with an explicit `offer_mode` of `cash` or `trade_in`.

Automatic catalogue pricing has priority over manual initial offers. When an automatic price is calculated, TradeFlow creates the automatic valuation and one initial offer record linked to it; that valuation carries the cash/trade-in option values. Previously published initial/revised offers and approved valuations for the item are superseded. Manual initial offer controls are disabled while an automatic valuation is active.

When the customer accepts one initial option, the selected cash/trade-in mode and amount are recorded on the single offer record and the buying item moves to `awaiting_item`. After receipt and a passed inspection, the authoritative inspection workflow moves the item to `final_offer_required`; the subscriber then creates and publishes the **final offer** through the existing post-inspection workflow. The final offer is separate from the initial cash/trade-in choice.


## Initial offer workflow clarification — 24 September 2026

Each manual initial offer is represented by one published `offers` record linked to one approved `trading_values` record. The linked valuation holds both `cash_price` and `trade_in_price`; the customer chooses one option from the same offer. The selected `offer_mode` and accepted `amount` are recorded on that offer. There is no second published initial offer record for the other choice.


## 24 September 2026 — Customer delivery-address type correction

The live `public.customer_addresses.address_type` contract permits `primary`, `billing`, `shipping` and `other`; it does not permit `delivery`. The customer-facing label remains **Delivery address**, but the stored internal value is `address_type=shipping`.

`customer-dashboard.js` was corrected so the Delivery option and Add delivery address action use `shipping`. The integrated Parcel2Go function was also corrected so its customer-address lookup uses `address_type=shipping`. The Parcel2Go Edge Function was redeployed as version 3 on 24 September 2026. No Supabase schema or Test One data was changed. Browser verification of the quote request remains the final test.


## 24 September 2026 — Test Two valuation display and shipping message clarification

The Test Two customer has an approved manual trading value with cash price £50 and trade-in price £55. The customer accepted the £55 trade-in offer. The customer dashboard previously labelled the £50 cash price simply as “Valuation”, which was misleading after the trade-in offer had been accepted. The dashboard now shows the accepted offer amount when an accepted offer exists, while retaining the underlying cash/trade-in values. The buying dashboard's Parcel2Go explanatory text was also changed so it no longer implies that the address is currently missing; it explains that Parcel2Go uses the saved Delivery address from My Details.
## 25 September 2026 — Buying dashboard regression-control repair

A Test Two browser failure showed the Buying dashboard permanently displaying its static loading placeholders. The first diagnosis incorrectly concentrated on asynchronous data loading. A full current-code audit identified the actual first failing boundary: buying-dashboard.js contained an unescaped ASCII apostrophe inside a single-quoted JavaScript string in the Parcel2Go shipping handoff text (customer's). The browser therefore could not parse the controller at all, so none of its Supabase loading code could run.

This is a critical regression lesson: a JavaScript parse error can make a page appear to have a database/loading problem while preventing every downstream request from starting. The repaired controller was compiled with new Function() after the correction and the dependent subscriber scripts were also syntax-checked.

New control rule for all TradeFlow browser-controller repairs:
1. Inspect the first failing boundary before changing data, RLS or workflow state.
2. Syntax-check every changed JavaScript controller before committing.
3. After a controller repair, syntax-check its directly loaded companion controllers as well.
4. Cache-bust the page when a browser may retain an earlier controller.
5. Do not delete/reseed Test Two data to compensate for a front-end runtime failure.
6. Do not alter the frozen Test One restore branch or its Canon transaction/data.
7. A loading placeholder is not evidence of a Supabase data failure until the controller has been proven to execute and its network calls have been observed.

The Buying dashboard now has a startup marker and an inline HTML watchdog so a future controller parse/load failure is displayed as an explicit script error instead of silently leaving the page on its static loading placeholders.

Relevant commits:
- 020af4b4654483aef6d55676d0c9943f1eb8bded — corrected the JavaScript parse error.
- 54b8022ffab4ca369ec0bc339ed4b8d7a847825b — added the controller startup marker.
- 3e488347ede1290a6dc8699d4995b23d3b676dfb — added startup diagnostics and cache-bumped the Buying dashboard controller to v57. A subsequent audit found that the Business Dashboard navigation still pointed to the Buying page with the previous HTML cache key `?v=58` after the Buying page itself had advanced to controller `v59`. This could cause navigation to restore a cached HTML document and make the user see the previous controller until a manual refresh. The navigation has now been synchronized to `?v=59`.

Current state: Implemented in GitHub and syntax-verified; browser verification remains required. The latest cache-key synchronization commit is `6207f0ca4b028351ebee149598898a563ccf1f58`.


## 25 September 2026 — Buying dashboard status/description rendering regression

The next browser test showed that the previous Buying-dashboard repairs were not sufficient. A fresh audit of the current GitHub source and live Test Two data identified two separate frontend defects still present in main:

1. Customer-supplied description parsing was still wrong. The Test Two buying_items.description stores literal \\n separators. The controller correctly converted those separators to real newline characters, but then incorrectly attempted to split the converted text using the literal \\n pattern again. The result was one long line, so the key/value parser treated the entire submission as a single field. The repair changes the second split to /\\n+/, after conversion, so Product type, Manufacturer, Model, Package, Condition, Missing items and Legal right to sell render as separate fields.
2. The green Submitted status class had no CSS definition. requestStatusClass('submitted') already returned status-approved, but no loaded stylesheet defined .status-pill.status-approved. The browser therefore used the neutral base status-pill styling. Explicit status-pill colour classes have now been added for approved, review, offer and refused states.

The live Test Two database was checked before the repair. The current Nikon request is BR-4C34C6F633, item BI-9D1C8F01FB, customer CUS-E82930637A58; both request and item are submitted, the item has quantity 1, the description contains the expected literal newline separators, and two media records are present. No database data, RLS policy, workflow transition or media record was changed.

The page/controller cache keys were also advanced so the browser cannot reuse the previous repaired asset combination:
- buying-dashboard.css v5 → v6
- buying-dashboard.js v59 → v60
- all three Business Dashboard Buying links v59 → v60

Relevant commits:
- 8e6dbea8964296afeccb2d0f378f8ee57aea8f25 — fix customer detail line parsing
- c76d730df2f8eb823cea44d586781b07385bc2df — add Buying status-pill colour classes
- 6a7af0a400996db0c1ff7ac7f9c2ff583621013b — cache-bust Buying page/controller assets to v6/v60
- ccbbbf136c59a50cea1700a2b4d328e24b5147ad — synchronize Business Dashboard Buying navigation to v60

Verification state: Implemented in GitHub; live DB verified; source-level logic verified. Browser verification is still required. Test One remains frozen.


## 25 September 2026 — Second Buying rendering correction

The next browser screenshot exposed two remaining source defects. First, the customer-detail key/value parser used `:\\s*` in a JavaScript regular-expression literal. That matches a literal backslash followed by `s`, not whitespace, so none of the `Product type: ...`, `Manufacturer: ...` etc. lines were parsed into separate fields. The parser has now been corrected to `:\s*`.

Second, the Submitted state was previously shown only as a green status pill. The requirement is that the entire Review customer submission stage is visually greyed when the item is still in the submitted state, rather than using green to imply an approved/completed review. The stage now receives `submitted-stage` styling and the Submitted pill is neutral grey within that stage.

The latest cache keys are buying-dashboard.css v7, buying-dashboard.js v61 and Business Dashboard Buying links v61. No Test Two data, RLS, schema or workflow state was changed. Test One remains frozen.

Relevant commits:
- 3ab98cbe927b0e2fc988728844601a7684bf8db7 — correct customer-field whitespace parsing and mark submitted review stage
- 1a09216ac77c656ab2636f81a94a6bace76fe6ef — grey submitted review stage
- 65cb2522f5b0fdd1a3a3ab9a28f165b88a45b34a — cache-bust Buying assets to v7/v61
- 13da412223385bdd73517ef9eebb07aab94b60bf — synchronize Buying navigation to v61

Verification state: Implemented in GitHub; source logic verified; browser verification pending.


## Test Two — Current Shipping Workflow State (25 September 2026)

The buying shipping workflow no longer uses Parcel2Go API integration. TradeFlow's current model is subscriber-managed shipping: the subscriber selects supported shipping services in Shipping Settings, obtains the label/service directly from the provider, then uploads the label/QR code, carrier, service, tracking number and dispatch information to TradeFlow. The customer receives those shipping files and instructions through the Customer Portal. TradeFlow does not purchase shipping or collect the customer's shipping cost.

After the customer confirms dispatch, the subscriber Buying workflow is **Awaiting item**. The subscriber view retains the dispatch date, shipping service, carrier and tracking number. After **Confirm item received**, the buying item moves to **received** and the next required step is **Inspection**. The received state must be green and must not show the receive button again. The Inspection state must be green and provide the inspection controls.

Do not restore the retired Parcel2Go API flow or the old post-acceptance message claiming that the business will create the shipping label after acceptance. The Customer Portal's accepted-offer block is informational only; the live stage/status message determines what the customer needs to do next.


## 25 September 2026 — Test Two inspection workflow correction
The current unified buying workflow is: customer confirms dispatch → subscriber confirms item received → subscriber explicitly starts inspection → inspection is completed → accepted inspection proceeds to final offer → customer accepts final offer → payment → Inventory. The Start inspection control must call the `subscriber_start_buying_item_inspection` RPC and change `buying_items.purchase_stage` from `received` to `inspection`; the inspection completion control then calls `subscriber_complete_buying_item_inspection`. Do not treat the inspection form as available while the database stage remains `received`. Parcel2Go API shipping remains retired; shipping services and the handoff are subscriber-managed, while customers pay the selected carrier directly.


## 25 September 2026 — Post-inspection trade-in decision model
After a passed inspection, TradeFlow must not automatically create or send a final offer when the accepted trade-in value remains unchanged. The subscriber decision is: **Add the accepted trade-in value to customer credits** when the value is unchanged; **Send revised final offer** only when inspection changes the value; or **Refuse trade-in** when the item is not acceptable. Adding credit records the customer credit, acquisition and Inventory asset and moves the buying item to `purchased`. A revised final offer moves the item to `final_offer_sent` and waits for the customer's response. A refusal closes the buying item as `offer_refused`. Bank-transfer payment remains the cash-purchase route; a trade-in at the accepted value is customer account credit, not a bank transfer.


## 25 September 2026 — Customer credit account
Trade-in customers now have a dedicated `customer_credit_accounts` account per subscriber business. Each existing customer was provisioned with a zero GBP balance and new customer registration provisions the account automatically. Accepted unchanged trade-in values increase the account balance through the server-side credit workflow. The customer portal displays the available credit and the selling journey presents an unchanged accepted trade-in as Payment rather than Final Offer.


### Post-inspection decision flow correction — 25 September 2026
Inspection is a decision point, not automatically a Final Offer stage. After an inspection, the subscriber must choose one of four paths: **pay the accepted cash offer to the customer's bank**, **credit the accepted trade-in value to the customer's Trade-in Credit Account**, **refuse/close the transaction**, or **send a revised final offer only when the value has changed**. The customer portal should remain on Payment for an unchanged accepted offer. It should move to Offer only when a revised final offer is actually published. Do not describe every post-inspection transaction as a final-offer step.


## 26 September 2026 — Retail sale shipping must mirror Buying shipping

Retail sales use the same subscriber-managed shipping handoff model as customer Buying. The subscriber selects saved shipping services in Shipping Settings, opens the provider, creates/pays for the shipment directly with that provider, then returns to TradeFlow and records the carrier, service, tracking, shipping instructions and the generated printable label and/or QR code.

The Fulfilment workspace must show the actual paid order before shipping is completed. It must show the purchased item(s), inventory reference/condition where available, customer name/email, delivery address, parcel weight and L/W/H measurements, and the shipping handoff files. The subscriber must not have to guess which item is being shipped.

Parcel weight and dimensions are packed-parcel data, not merely product-specification data. Current Parcel2Go guidance requires the declared weight/dimensions to include packaging and warns that under-declaration can produce surcharges. Royal Mail Click & Drop likewise requires order weight and packaging size when applying postage. TradeFlow therefore records the packed parcel measurements in fulfilment_parcels.

A completed retail shipping handoff moves fulfilment from awaiting to label. The customer portal then receives the label/QR, carrier/service, tracking and instructions. The handoff queues a customer email containing the same operational details and a link to the Customer Portal. Dispatch moves label to dispatched and queues the dispatch notification.

Do not reintroduce direct browser writes to fulfilments or direct browser reads of retail_orders. Retail fulfilment writes/reads must use the subscriber/customer RPC boundaries.



## 26 September 2026 — Retail fulfilment handoff UX clarification

The current retail Fulfilment UI separates **provider booking** from **TradeFlow handoff recording**. Shipping Settings defines the services the subscriber may use. The Fulfilment workspace lets the subscriber select one, open the provider, complete the booking there, then return to record the carrier/service/tracking and upload the label or QR code.

TradeFlow does not need to duplicate the provider's parcel-booking form. Weight and L/W/H remain valid packed-shipment data and may be stored in fulfilment_parcels, but the current handoff UI does not ask the subscriber to enter those values again. They must still be supplied accurately to the chosen courier/shipping provider when creating the shipment; current provider guidance requires packed shipment weight/dimensions for quoting or label generation.

The handoff completion boundary is subscriber_save_retail_fulfilment_shipping(). The latest reliability repair performs the authorised awaiting → label transition directly inside that RPC and preserves existing parcel measurements when the simplified handoff UI does not provide new measurements. This avoids coupling the save action to the generic workflow transition function.

The Selling workspace also uses cache-busted startup references and a guarded initialisation path so a stale/racing subscriber auth load cannot leave Available or Sold stuck on Loading until a manual refresh.



## 26 September 2026 — Retail customer shipping and returns boundary

For retail purchases, the customer is the recipient. The customer portal must not expose the business's printable outbound shipping label or courier QR code as part of the normal order view. My Orders shows the shipment status, carrier/service and tracking information.

The subscriber Fulfilment workspace retains label/QR access because the subscriber creates and manages the shipment. The subscriber uses Mark as sent only after the parcel has physically been handed to the courier. The existing subscriber transition queues the customer dispatch notification.

A retail return becomes available to the customer after fulfilment is marked delivered. The customer may select a delivered order item, choose a reason and add optional notes. customer_request_return() is the authoritative write boundary. It uses return_type='customer_retail', requires the customer's own order item, requires delivered fulfilment, and rejects duplicate active return requests.

Customer Portal authentication must complete before tenant/customer profile RPCs run. Do not perform an initial customer_get_profile call against a stored session until customer-auth.js has completed session restoration/validation.


## 2026-09-26 — Retail Mark as Sent / customer dispatch handoff repair

- Selling → Sold → **MARK AS SENT** is now one atomic server-side action.
- The action advances the paid retail order from `paid` to `fulfilment` and the fulfilment from `label` to `dispatched` in the same transaction. The browser no longer performs a second retail-order transition after the fulfilment RPC, preventing the previous post-success failure that could leave the button apparently non-responsive.
- On dispatch, TradeFlow retains the carrier/service and tracking number, derives an official carrier tracking-page URL when none was supplied for supported carriers, and queues the `order_dispatched` customer notification with the tracking information.
- Customer My Orders remains recipient-focused: no outbound label/QR controls. Once dispatched it shows the shipping service/carrier, tracking number, and an explicit **Track item →** link when a tracking URL is available.
- After **MARK AS SENT**, Selling → Sold should show the shipment as **Shipped** with no further outbound action. Return handling remains a separate customer-return workflow and should only become actionable when a return has actually been requested.
- Production migration: `20260926225000_retail_fulfilment_mark_sent_atomic`.


## 2026-09-26 — Customer order collapse and storefront image fit

- Customer Portal **My Orders** now renders each paid retail order as a native collapsible order card. The collapsed header retains order reference, status and total; opening the order reveals items, shipping service/carrier, tracking, fulfilment information and any eligible return action.
- Storefront product-card image boxes now use `object-fit: contain` so the complete product photograph is visible within the box rather than being cropped. Product-detail gallery behaviour remains unchanged.
- Cache versions were bumped: Customer Portal CSS/JS to `v9`/`v125`; public storefront CSS to `v66`.


## 2026-09-26 — Mixed customer credit + card checkout

- Retail checkout now supports applying available customer credit first and charging the remaining balance by card. Example: a £75 purchase with £5.09 available credit presents £5.09 customer credit and a £69.91 card payment.
- Customer-facing payment wording is provider-neutral: **Credit or debit card**. The customer does not need to see the Stripe provider name.
- Customer credit is held against the retail order while the card payment is open. The hold is released if the card payment fails/expires or the customer cancels; it is actually deducted and posted to the ledger when the card payment succeeds. This prevents losing credit when a card checkout is abandoned.
- If available customer credit covers the entire purchase, the order is completed using customer credit alone without opening card checkout.
- The customer credit account display now reports available credit after active checkout holds.
- Current customer checkout supports customer credit plus card payment. Other payment methods can be added later behind the same provider-neutral customer-facing approach, but they are not currently wired into this retail checkout.


### 2026-09-26 mixed-payment stale card-attempt recovery
- Root cause found in live logs: the mixed-payment credit RPC correctly refused to apply credit when the pending retail order already had an active card payment attempt. This was the previous single-payment checkout attempt, not a credit-balance problem.
- Customer checkout now detects that specific stale active-card condition, cancels the old pending purchase through the normal customer cancellation RPC, creates a fresh pending checkout order, and reapplies customer credit before starting the new card payment.
- The external payment event handler now returns a conflict result when a locally cancelled Stripe payment later reports paid, allowing the Stripe webhook conflict path to refund rather than silently accepting the payment.
- The customer basket cache was bumped to customer-basket.js?v=4.
- Do not treat an active Stripe attempt as reusable after the customer has changed the payment mix; the order must be restarted so the card amount is recalculated from the remaining balance.



## 2026-09-26 — Subscriber-controlled Stripe checkout payment methods
- Business Settings now exposes tenant-scoped Stripe checkout controls for **Credit or debit card**, **Link**, **Klarna**, and **Amazon Pay**.
- Card remains the required base online payment method. Subscribers can independently enable or disable Link, Klarna and Amazon Pay.
- The checkout Edge Function reads these settings and sends Stripe's dynamic-method filter using `allowed_payment_method_types[]`. Stripe remains the authority for method eligibility at checkout.
- Apple Pay is deliberately documented as Stripe-managed rather than represented as a false TradeFlow toggle. Stripe's API documentation lists Apple Pay as a wallet without an API enum, while Link and Amazon Pay have API enums. With card payments enabled, TradeFlow cannot independently suppress Apple Pay through the Checkout Session API.
- Do not reintroduce a second payment-method configuration system. Use `tenant_payment_methods` for subscriber-controlled Stripe method preferences and keep provider connectivity separate.


### 2026-09-26 — Business workflow retail sales count repair
- The subscriber Business Dashboard workflow counts were reading legacy `orders` and `fulfilment_orders` REST resources that are not the live retail sales tables. Because failed REST requests were converted to empty arrays, the dashboard incorrectly displayed **Orders 0** and **Fulfilment 0** even though live retail orders existed.
- Added `subscriber_get_business_workflow_counts(uuid)` as the tenant-scoped dashboard read boundary. It counts live `retail_orders`, `fulfilments`, listings, inventory, buying and returns.
- A paid retail order with no fulfilment yet, or a fulfilment in `awaiting` / `label`, is counted as **Fulfilment — SALE TO PROCESS**. Orders counts paid/fulfilment retail orders that are not cancelled/completed.
- The Selling card continues to represent active unsold listings, so it can correctly remain 0 when all listings are sold. Retail shipping work belongs in Fulfilment.
- Production migration: `20260926234000_business_workflow_retail_counts`.
- Dashboard fix commit: `a81d1829e0f9bb4651d26ac4a834e4b66643e447`.


### 2026-09-26 — Customer My Sale collapsible items
- Customer Portal **My Sale** now renders each sale/valuation as a native collapsible `details` item. The compact summary keeps the item, stage and status visible; the workflow timeline, offer information and shipping actions expand below it.
- Items are collapsed by default to keep the portal compact when a customer has multiple sale records. The existing green/current styling and actions are preserved.
- Customer dashboard cache bumped to `customer-dashboard.js?v=126`.
- GitHub commits: JS `d5678bf53e5639e158e2484fb783c246203cced8`, HTML `f19473237527180294bd35023b9adaba6866468b`.


### 2026-09-26 — Subscriber fulfilment label actions clarified
- In the **subscriber Fulfilment dashboard**, existing shipping-file actions now read **Add label** and **Add QR code**. They open the corresponding file chooser so the subscriber can add or replace the provider-supplied file.
- Subscriber Fulfilment no longer presents these actions as **View / print**. Printing/viewing is a customer-facing action after the shipping details have been sent to the customer.
- Fulfilment dashboard cache bumped to `fulfilment-dashboard.js?v=9`.
- GitHub commits: JS `a8413720cde6e0032b96463f145fa6386d94726c`, HTML `5b8696d4af4d46f09717cae5b0a3515b647b610b`.


### 2026-09-26 — Paid retail order fulfilment gap repaired
- Investigation of the £75 retail order found the payment had completed correctly, but no `public.fulfilments` row had been created. The previously working £49.91 path had created its fulfilment record during the older full-credit payment flow; the newer mixed/card settlement path did not.
- Live fix: `20260926240000_retail_order_fulfilment_auto_create` adds an `AFTER UPDATE OF status` trigger on `retail_orders` so every transition to `paid` creates an `awaiting` fulfilment record when one does not already exist. Existing fulfilments are preserved.
- The migration also backfilled paid retail orders that were missing a fulfilment. Camerashack `ORD-20260926-DCCBB973` now has fulfilment `FUL-E9EE0FA60C79` in `awaiting` status; the £49.91 order remains `dispatched`.
- GitHub migration commit: `4c8c2136d76afbdf05e50a0f88b00226609d02fd`.


### 2026-09-26 — Retail fulfilment handoff and Test Three JWT recovery
- The £75 paid retail order now has an `awaiting` fulfilment record. The subscriber must still return from the external shipping provider and **Add label** or **Add QR code**, enter carrier/service/tracking as applicable, then use **Save & send shipping details**. Only that handoff moves fulfilment from `awaiting` to `label`, at which point **Mark as sent** becomes available. Creating a label externally cannot be detected by TradeFlow until the provider-supplied file/details are recorded in TradeFlow.
- Customer Test Three exposed a stale customer access token: the selling wizard reached the submit stage but the `customer-selling-submit` Edge Function returned `Invalid JWT`. The public selling journey now validates the stored customer session, refreshes it when possible, and retries a JWT failure once with the refreshed token. Public-site cache is now `public-site.js?v=81`.
- GitHub commits: public selling journey auth recovery `c9102faaa5d8030623418f7abc9d071687511142`; cache `7ab324bfcfbfa9d97d939c2854ce45196bd76b1a`.


### 2026-09-26 — Customer valuation photograph access
- Subscriber Buying showed **“Photographs were supplied but could not be opened”** for multiple customer valuations. The stored media records and Storage objects exist under `tradeflow-media/{tenant}/customer-buying/{buying_item}/...`; the failure was in subscriber-side private storage access rather than missing photographs.
- Live migration `20260926250000_customer_buying_photo_subscriber_access` adds an explicit tenant-scoped Storage SELECT policy for authenticated subscriber members on the `customer-buying` folder. Customer photographs remain private and are not made public.
- Buying dashboard cache is now `buying-dashboard.js?v=41`. The photo loader also surfaces the secure-link error instead of silently swallowing it, making any future access failure diagnosable.
- GitHub commits: migration `e995d4ad74a6e4b2b2750c366f59d5abe3277409`; JS `df951448616a658c0b2fc2d6346c574ffb9b40df`; HTML `0df7280548b94c4bb77596a19d651395a7a2c851`.


## 26 September 2026 — Concurrent-session test and isolation rule

TradeFlow is currently being browser-tested with Platform Owner, Subscriber and multiple Customer sessions open concurrently. These are separate authentication boundaries and must remain independent.

Current session storage boundaries:
- Platform Owner: tradeflow_platform_owner_session
- Subscriber: tradeflow_subscriber_session with tenant context
- Customer: tradeflow_customer_session with customer tenant context

The customer portal must identify the customer through the authenticated customer relationship and tenant-scoped RPCs; it must not use the subscriber membership model. Multiple customer sessions for the same subscriber are expected to coexist when they are in separate browser sessions.

During the 26 September concurrency test, the live Camerashack tenant contained separate active buying requests for two customers and separate retail/fulfilment records. No active credit holds or active processing/initiated payment attempts were found.

A browser error in the Platform Owner dashboard (escapeAttr is not defined) was repaired without changing the authentication or tenant-security boundaries. The repair only restored rendering of tenant action attributes.

Diagnostic rule: when multiple sessions are open, identify the browser identity and tenant/customer ID first. Never solve a session-specific display problem by changing shared tenant data or weakening RLS/RPC boundaries.


## 26 September 2026 — Platform Owner sending email validation

The Platform Owner Dashboard's TradeFlow sending-email setting is protected by the platform-owner authorization boundary. The save RPC must validate the address without weakening that boundary.

A live test exposed an over-escaped email regular expression that rejected valid addresses containing a normal dotted domain. Migration `20260926212000_fix_platform_owner_email_validation` corrected only the validation expression. The sender remains marked pending until the separate sending-domain/email verification process is completed.


## Platform Owner — Commercial Plan Control

The Platform Owner Dashboard is the authoritative control surface for TradeFlow's commercial plan presentation. The commercial plan editor operates on the active Basic, Enhanced and Catalogue plan records.

The `public.plans.active` field represents whether a plan remains operational in the platform. It must not be used as the website visibility switch. `plans.website_visible` controls whether a plan is offered to new website visitors and subscriber sign-ups. This separation allows an existing plan to remain operational for current tenants while being hidden from new sales.

Plan commercial configuration includes monthly/annual display prices, currency, Stripe Product ID, Stripe monthly Price ID and Stripe annual Price ID. Stripe secret credentials must never be stored in the public `plans` table or browser code.

Owner mutations use `platform_owner_update_plan()` and are protected by `private.is_platform_owner(auth.uid())`. Public website reads use `public_get_available_plans()`, which returns only active plans marked website-visible and does not expose Stripe identifiers.

Current initial state after migration `20260926220000_platform_commercial_plan_controls`: Basic and Enhanced are website-visible; Catalogue is active but hidden. Prices and Stripe IDs are intentionally unset until the platform owner configures them.


## 26 September 2026 — Single commercial plan

TradeFlow now uses one public commercial plan. The existing enhanced plan row is the canonical internal plan so the active Camerashack tenant keeps its existing plan reference and feature gates without a subscription migration.

The display name is TradeFlow and it represents the complete current workspace: buying, valuation, trade-ins, offers, inventory, selling, orders, fulfilment, customer portal, Website Builder, staff, messaging, audit, analytics, integrations, market intelligence and the TradeFlow starting catalogue.

Legacy plan rows remain inactive for historical records but are not offered to new subscribers. New business creation accepts only the canonical TradeFlow plan.

The Platform Owner controls the single plan's name, description, website visibility, monthly/annual pricing, currency and Stripe Product/Price IDs.

## Platform email verification

The Platform Owner's sending-email setting is not an email-confirmation mechanism. Saving an address records the intended sender and marks it pending until the email provider/domain verification is completed. TradeFlow's notification processor refuses to send while the sender remains unverified.

Do not bypass provider/domain verification by marking the sender verified directly from client code.


## 2026-09-28 — End-to-end customer valuation → sales audit
The current end-to-end audit traced the live customer selling journey through submission, Buying, valuation, offer, shipping, receipt, inspection, payment/acquisition, Inventory and Selling. A fresh customer submission (`BR-9FBCBE5008` / `BI-63F5AAA6AB`) is live in Supabase with authoritative draft→submitted workflow events and one customer photograph.

The first substantive workflow gap is catalogue binding: the customer selling submission records selected category/model/package as text but leaves `buying_items.buying_product_id` null. The live valuation engine therefore returns manual valuation with reason `product_not_selected`. The public condition vocabulary also does not fully match the valuation engine vocabulary. These are now the first audit targets before a fresh item is taken through the full workflow.

The current subscriber authentication layer still uses localStorage for the subscriber session/tenant fallback, while the multi-session testing architecture requires tab-local isolation. Treat this as a latent session-isolation risk until consolidated.

Notification delivery remains unresolved: current notification_queue records are still queued and platform sender verification is pending. Portal/database workflow must not be described as equivalent to successful email delivery.

Verification remains: **Implemented in GitHub / Live DB verified / Browser verified**. The fresh customer submission is live-DB verified; later fresh-item browser stages remain open.


## 2026-09-28 — Revised final offer currency-source repair

Fresh browser testing of Canon EOS R8 (BI-29E78F3A13) exposed column "currency" does not exist when sending a revised final offer. Live schema inspection confirmed that buying_items has no currency column, while offers.currency and trading_values.currency do exist. The live subscriber_publish_final_offer function was incorrectly selecting purchase_stage,currency from buying_items.

The repair is intentionally narrow: the function now reads the purchase stage from buying_items and derives the currency from the latest accepted offer, falling back to GBP for legacy records with no currency value. No purchase-stage or inspection workflow was changed.

Migration: 20260928161000_fix_final_offer_currency_source. GitHub commit: 2cf16e35a5fe8b5676cac192f8c917b0a93ba97c.

Browser verification remains required: the failed Canon test must be retried with a revised value different from the accepted £99 and confirmed at both subscriber and customer boundaries.


## 2026-09-28 — Revised offer approved-valuation uniqueness repair

After the currency-source repair, the Canon EOS R8 revised-offer test reached the next database boundary and exposed a duplicate-key error on `trading_values_one_approved_per_item_idx`. Live data showed the original £99 trading value remained approved, while the database intentionally permits only one approved trading value per buying item.

`subscriber_publish_final_offer` now supersedes the existing approved trading value through the existing workflow authority before creating and approving the post-inspection valuation. The operation is transactional, so a later failure rolls the supersede and new valuation back together.

Migration: `20260928162000_fix_final_offer_approved_valuation_conflict`. GitHub commit: `c6c1e5c48cd96c00bbdf646bafce027a357fafa7`.


## 2026-09-28 — Revised offer current-state rendering

Canon EOS R8 (`BI-29E78F3A13`) now has a published final offer of £79 GBP and purchase stage `final_offer_sent`. The customer portal had been selecting the wrong offer because multiple offers for the same item were collapsed into one object without preserving the newest row. The portal now retains the newest offer from the descending result set, so the published final offer is the customer-facing offer while it awaits acceptance or refusal.

The subscriber Buying workspace separately loads the latest offer and shows the revised amount as the current offer. A sent revised offer is intentionally read-only while awaiting the customer response.

Customer photographs for this specific item were checked directly: there are currently no `buying_item_media` rows. The submission function does contain the upload/link path, so absence of rows means no stored customer photo exists for this test item; do not substitute another item's media.


## 2026-09-28 — Final payment button binding repair

The Canon EOS R8 reached `final_offer_accepted` at £79, but **Confirm payment sent** was inert. The `loadPayment()` renderer created the button without a click handler, while the global click listener deliberately does not redispatch `data-act` buttons. The button is now directly bound to the existing `subscriber_complete_purchase` action, with visible error status. No payment or inventory records were manually altered. Buying Dashboard cache is v60.

The exact Canon item currently has no `buying_item_media` links, so its missing photographs are a data-state issue for that test item rather than a verified renderer loss. The customer portal already has the revised-final-offer accept/refuse controls and revised-offer wording for the `final_offer_sent` state; the Canon test has already advanced to `final_offer_accepted` at £79.


## 2026-09-30 — Migration baseline reconciliation complete

- TEST migration history is intentionally baselined at `20260930215656_remote_schema` after the clean `db pull --linked` on 2026-09-30.
- `supabase/migrations/` now contains only the full-schema baseline migration.
- The 139 pre-baseline migration files are preserved under `docs/migration-archive/2026-09-30/` and are not active migrations.
- No TEST schema/data reset or LIVE/production change was performed during repository reconciliation.
- Before future schema deployment, verify local/remote migration status and use a dry run; never use `db reset --linked` on LIVE.


## 2026-09-30 — Duplicate inventory serial warning policy

TradeFlow permits duplicate inventory serial numbers within a tenant because a repeated serial may be legitimate and must not be treated as an automatic database rejection. The Selling workspace checks the entered serial against other inventory assets in the same tenant. When a match exists, it shows a warning identifying the existing asset reference/title and requires an explicit **CONTINUE WITH SERIAL NUMBER** action before the save continues.

The database lookup index on inventory serials is intentionally non-unique. This preserves fast duplicate detection without blocking legitimate records. Changing the serial number clears the pending confirmation. Duplicate serials remain a review/risk condition and must not be treated as proof that two inventory records represent the same physical asset.

TEST migration: 20260930232732_allow_duplicate_inventory_serial_numbers_with_warning. Selling cache: selling-dashboard-fixed.js?v=69. Browser verification must deliberately test a duplicate serial and confirm warning → explicit continuation → successful save.

## 2026-10-06 — Current environment and domain boundary

The LIVE release branch is `production` and LIVE Supabase is `gxsrajtqzdjvmceqcpgv`. The application path is GitHub → Cloudflare Worker → LIVE Supabase.

The Website Builder publication workflow remains separate from application deployment and the 5 October standard Website Builder baseline is locked.

Subscriber domains are customer-owned. TradeFlow no longer purchases, renews or registers subscriber domains. The current workflow is subscriber request → Platform Owner preparation → exact DNS → subscriber DNS change → DNS/SSL/routing verification → active.

The old TradeFlow/Porkbun subscriber domain-purchase and registrant workflow is retired. Historical implementation detail remains in checkpoints, not in the current operating handbook.

## 2026-10-06 — Domain launch continuity

The domain architecture is now subscriber-owned domains only. TradeFlow does not purchase, renew or register subscriber domains.

The platform infrastructure domain `laurendigital.co.uk` has been purchased directly through Porkbun and is active in Cloudflare. The LIVE TradeFlow Worker is connected at `tradeflow.laurendigital.co.uk`.

The LIVE subscriber domain workflow remains:
subscriber enters existing hostname → Platform Owner prepares connection automatically → exact DNS instructions → subscriber applies DNS → DNS/SSL/routing verification → activation.

The Cloudflare preparation function is version-controlled and must remain server-side. Do not invent DNS targets or activate unverified domains.

## 2026-10-02 — Current TEST Assistant milestone

The Cloudflare TEST Subscriber Assistant is browser-verified through authentication, tenant resolution and read-only approved knowledge retrieval with provider=none. The active TEST deployment branch for this Cloudflare workstream is cloudflare-test; older main=TEST references are historical. The next pre-launch AI stage is controlled Product Research evidence workflow, followed by the separate customer read-only assistant. LIVE remains untouched.


## 2026-10-02 — Final launch direction

The TEST Worker remains a development/staging environment. The Camera Shack sandbox domain and TEST-only customer URL routing are not being extended further. The next customer-facing validation target is the real LIVE subscriber domain.

The final sequence is: complete the customer-facing assistant/chatbot → configure the real production domain → create/register a real LIVE subscriber → publish the subscriber website → register real customer accounts → run the final customer/subscriber acceptance tests. If defects are found, reproduce and fix them in TEST, then promote the approved release to LIVE. LIVE must not become the place where source code is patched directly.


# CURRENT SYSTEM OVERRIDE — 2 OCTOBER 2026

## Environment and release boundary
The active Cloudflare TEST branch is `cloudflare-test`; TEST Supabase is `twfbmjwwqzxdxvclxbun`; LIVE Supabase is `gxsrajtqzdjvmceqcpgv`; LIVE remains untouched during current chatbot work. Older references to `main` as the current TEST branch are historical and must not override the current environment definition.

## Public customer routing
Customer-facing tenant context is resolved from the public hostname. Tenant UUIDs remain internal identifiers and must not be required in customer-facing URLs. TEST currently has a single published Camera Shack site, so the TEST Worker has a single-site fallback. LIVE must resolve the tenant from the genuine custom hostname through `published_site_index`.

## Chatbot boundary
TradeFlow has two read-only assistant audiences: subscriber and customer. Subscriber access is tenant-scoped through `tenant_memberships`. Customer access is tenant + customer scoped through `customers.auth_user_id`. The customer assistant can read only the authenticated customer's own workflow context and approved public/TradeFlow guidance. It cannot perform operational actions.

## Launch sequence
Complete the customer assistant boundary in TEST → purchase/configure the genuine production domain → create the LIVE subscriber → configure the LIVE subscriber website → create LIVE customer account(s) → run final real-domain acceptance. The Porkbun sandbox registration of `camerashack.co.uk` is not a substitute for a genuine public DNS/Cloudflare test.


## LIVE Release Audit — 2026-10-03

TradeFlow now has a separate LIVE Supabase project, `gxsrajtqzdjvmceqcpgv`, in `eu-west-2`. The LIVE release branch is `production`.

The current production code uses hostname-based environment separation and a production Worker configuration. TEST remains on `twfbmjwwqzxdxvclxbun`.

The TEST-only duplicate inventory serial warning migration is deliberately excluded from the LIVE release.

The provider-neutral Assistant architecture is included in the production code:
- owner-controlled provider selection;
- `none`, Gemma, OpenAI, Anthropic, Google and subscriber-provider options;
- Customer Assistant;
- customer-to-subscriber business messaging;
- subscriber Customer Questions/reply workflow.

The customer/subscriber messaging and AI-provider tables/RPCs have been added as version-controlled production migrations. The LIVE database and Edge Function deployment are not marked verified until the LIVE Supabase project can be directly inspected/deployed.

Manual shipping remains the current architecture. Parcel2Go API and ResellerClub are not to be reintroduced.

Verification status must remain explicit:
- GitHub release: **Implemented in GitHub**
- LIVE database: **not yet directly verified in the current tool session**
- Browser: **not yet verified**


## CURRENT OVERRIDE — 3 OCTOBER 2026 — LIVE OWNER DASHBOARD CACHE BOUNDARY

The LIVE release is now the active launch workstream. Do not return to CameraShack-specific TEST polishing unless a new defect is first reproduced in LIVE and the repair is deliberately promoted.

Verified current state:
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`, ACTIVE_HEALTHY, `eu-west-2`.
- LIVE platform owner membership exists and is active for the owner account.
- LIVE `platform_ai_settings` exists with safe default `active_provider=none` and `allowed_providers=["none"]`.
- LIVE Assistant messaging tables/RPCs exist.
- LIVE `tradeflow-assistant` Edge Function is ACTIVE with JWT verification enabled.
- LIVE inventory serial uniqueness has been restored; TEST duplicate-serial behaviour is not part of the production release.
- Cloudflare Worker `tradeflow` has a confirmed production deployment for the latest owner-dashboard refresh.

Latest browser evidence identified a serving/cache boundary issue: a clean Incognito browser was receiving `platform-owner-dashboard.js?v=4` with HTTP 304 even though the current production HTML in GitHub references `?v=6`. LIVE Supabase logs showed no `/auth/v1/token` request during the attempted owner sign-in. This points to stale Owner Dashboard HTML/asset selection, not a LIVE password or membership fault.

Targeted repair committed to production: `6c9b061e5a20210aa8b6f416a3f8b68fb6357329` (`Prevent stale production owner dashboard HTML caching`). The Worker now returns `platform-owner-dashboard.html` with `Cache-Control: no-store`, so the protected dashboard cannot retain an older HTML reference to a previous JavaScript asset.

Verification rule: Cloudflare deployment existence is not browser verification. After the new Worker version is served, the clean browser must show the current dashboard HTML selecting `platform-owner-dashboard.js?v=6` (or a newer cache-busted version), followed by a real LIVE `/auth/v1/token` request on sign-in and an active owner membership check.

Do not change LIVE credentials, delete tenants, recreate the owner, or alter Supabase auth solely because the old browser asset was observed. The three test-looking businesses previously displayed were stale dashboard content and are not LIVE tenant records.
\n\n## LIVE owner authentication continuity — 3 October 2026\n\nThe LIVE platform owner account is present and has an active \`public.platform_memberships\` row. The password-reset incident was traced to the LIVE Supabase Auth redirect configuration still resolving password recovery to \`http://localhost:3000\`. The production application also had no dedicated platform-owner recovery page; the existing reset page was customer-specific.\n\nProduction code now includes a dedicated \`/owner-reset-password\` flow, an Owner Dashboard “Forgot your password?” action, an explicit Supabase \`redirect_to\` target, active-owner membership verification before password update, and a Worker route for the recovery page. This code is committed on \`production\`; deployment still needs live-browser verification.\n\nThe permanent LIVE Supabase Auth Site URL must be set to the eventual production site URL. Until the permanent customer domain is chosen, the Worker production origin can be used as the temporary LIVE application origin, with \`/owner-reset-password\` added to Supabase Auth Redirect URLs. Do not reuse the expired localhost reset link.\n

## CURRENT OVERRIDE — 3 OCTOBER 2026 — LIVE OWNER LOGIN VERIFIED

The Cloudflare production branch configuration has now been corrected and the LIVE Owner Dashboard has been browser-verified.

- GitHub repository: `laurendigitaluk/TradeFlow`.
- Cloudflare Production branch is now `production`; `main` remains the TEST branch.
- Documentation-only trigger commit: `37b2d2133cf1f2e6d719c114f8d1e1c8fac25f84`.
- Cloudflare subsequently created the new production deployment for that commit.
- A fresh browser session successfully authenticated the LIVE platform owner and loaded the Owner Dashboard.
- The LIVE dashboard showed **0 Subscriber businesses** and **0 Active businesses**.
- The old TEST/Camerashack businesses were no longer displayed.

This is now verified LIVE browser behaviour. The screenshot does not independently expose the network request, so the underlying Supabase Auth request is not claimed as separately network-verified.

Do not change the owner password or modify LIVE tenant data as a response to the former TEST-data display. The former display was caused by the Cloudflare production branch being incorrectly set to `main`.

The project is now moving into the real LIVE launch sequence: customer/subscriber chatbot completion followed by genuine LIVE subscriber, domain and customer acceptance. Manual shipping remains authoritative; Parcel2Go API and ResellerClub remain retired.

Continuity checkpoint: `CHECKPOINTS/2026-10-03-live-owner-login-verified.md`, commit `36c18d2ad4a305d282c657f9f9a11d974132dad0`.


## DOCUMENTATION GOVERNANCE — LIVE OPERATING RULE — 3 OCTOBER 2026

TradeFlow documentation is part of the production record. The platform owner must be able to access the maintained manuals from the Owner Dashboard. The current Owner Dashboard provides direct links to the System Handbook, Human User Manual, Subscriber Manual, Backend Manual and AI Operating Manual.

The maintained documentation set is:
- System Handbook — architecture, environments, security boundaries, deployment rules and current system state.
- Human User Manual — operational instructions for platform owners and people operating TradeFlow.
- Subscriber Manual — subscriber-facing operation of the TradeFlow business workspace and website.
- Backend User Manual — Supabase schema/RPCs, Edge Functions, security, storage and deployment/backend operation.
- AI Operating Manual — AI provider controls, assistant boundaries, approved knowledge and AI continuity.
- Customer Documentation — separate customer-facing guidance maintained for the subscriber's customers; it must not expose platform-owner or backend material.

After every material LIVE change, update the relevant manual(s) and create or update a dated checkpoint. During periodic audits, compare the documentation against the production GitHub branch and LIVE Supabase state. Do not treat an old manual statement as current merely because it remains in the historical text; the latest dated continuity section is authoritative where an explicit override exists.

The Subscriber Dashboard now provides a Customer Documentation entry. The subscriber is responsible for maintaining the customer-facing business guidance; platform-owner/backend documentation remains internal.


## 2026-10-03 Customer–Subscriber Assistant Connection Hardening

The LIVE customer/subscriber Assistant messaging path is now hardened around dashboard-first communication.

- Customer Assistant can send an unanswered question to the subscriber through the tenant-isolated messaging RPCs.
- Subscriber TradeFlow Assistant exposes only open customer conversations that contain at least one message.
- Opening the Customer Assistant no longer creates an empty subscriber-visible conversation.
- Customer-side conversation refresh now polls for subscriber replies every 15 seconds.
- The dashboard remains the source of truth; email notification is optional and is not required for this messaging path.
- LIVE Supabase applied migration: 20261003004315_assistant_connection_hardening.
- Production frontend commit: 551559d8a1b7f74384cf4ac8d847852f4ebe9448.

Browser end-to-end customer-to-subscriber testing remains a launch verification step; this change is a code/database hardening release, not a claim of passed browser E2E.



## 2026-10-03 Production Boundary Audit

The LIVE release has undergone a targeted URL/environment boundary audit. Unconditional TEST Supabase references in production frontend assets were removed. Public plans and subscriber dashboard now use the LIVE Supabase project. Customer notification portal URLs no longer point to the retired GitHub Pages TEST site; LIVE database functions derive the portal from the tenant's active primary domain. Stripe checkout no longer falls back to GitHub Pages. TEST configuration retained inside explicit environment-selection logic is intentional. See the dated checkpoint for the verified file and database scope.


## 2026-10-03 LIVE Commercial Subscription Flow

The launch commercial model is now **£59.99 GBP/month with a 30-day free trial**. LIVE `plans` contains the active website-visible `enhanced` plan. Subscriber onboarding is subscription-first: authenticated checkout creates a Stripe Billing subscription Checkout Session, and successful Stripe subscription webhook processing creates the subscriber tenant, membership and linked tenant subscription. The old direct unpaid business-creation path is disabled. Owner Dashboard now exposes monthly price, trial days and Stripe Product/Price IDs and can create the LIVE Stripe Product and recurring monthly Price. See checkpoint `CHECKPOINTS/2026-10-03-live-commercial-subscription-flow.md`.


---

## 2026-10-03 — LIVE Subscriber Subscription Cancellation Control

TradeFlow LIVE now provides a small **Cancel subscription** control at the bottom of the subscriber dashboard navigation.

Cancellation is deliberately protected by password re-authentication before the cancellation request is accepted. The subscriber's password is verified through Supabase Auth; the password is not stored by TradeFlow.

The cancellation action schedules the connected Stripe subscription to cancel at the end of the current trial or billing period rather than creating a duplicate payment or immediately removing access.

The authenticated `subscriber-cancel-subscription` Edge Function validates:
- the signed-in subscriber identity;
- active membership of the selected tenant;
- the connected Stripe subscription;
- the Stripe customer ID match;
- the Stripe subscription metadata user ID when present.

It then sets Stripe `cancel_at_period_end=true` and synchronises the local TradeFlow subscription record.

The obsolete dashboard note stating that catalogue management will be added when Gemma is ready has been removed. Catalogue/product management remains available through the existing **What We Buy** and **Products & Categories** areas.


## 2026-10-03 — Customer Payment Provider Onboarding Boundary

TradeFlow now exposes a subscriber-facing customer-payment onboarding workspace in Settings. It is deliberately separate from the subscriber's own TradeFlow subscription billing.

The existing `payment_provider_connections` table is used for tenant-scoped customer-payment setup records. The subscriber may record non-secret account metadata and an optional payment link. The database connection record uses `connection_type='customer_payments'` and remains `onboarding` until an actual provider integration is implemented and verified.

Six onboarding providers are currently documented: Stripe, PayPal Business, SumUp, Square, Mollie and Revolut Business. The UI links only to official provider signup/help pages. No provider secret is stored in the subscriber setup fields.

The existing `tenant_payment_methods` controls remain separate. They control Stripe Checkout payment-method options such as card, Link, Klarna and Amazon Pay when the TradeFlow Stripe customer checkout is used; they are not the same thing as choosing the company that receives subscriber customer payments.

Current retail customer checkout still calls `create-stripe-checkout-session`. Therefore non-Stripe provider setup must not be represented as a completed technical checkout integration merely because the subscriber has filled in the onboarding form.


## 2026-10-03 — Shipping catalogue restoration

The LIVE `shipping_service_catalog` was empty even though the tenant selection table and RPCs already existed. The researched manual-service catalogue has been restored with 26 entries. `subscriber_get_shipping_service_settings` already returns active catalogue rows plus tenant selections, and `subscriber_save_shipping_services` persists subscriber choices. No new shipping architecture was introduced. The old Parcel2Go API workflow remains removed; Parcel2Go is a manual catalogue option/link.


## 2026-10-03 — Master Catalogue Restoration

The TradeFlow Master Catalogue restoration was completed through the controlled TEST → Production path.

### Verified source state
- TEST Supabase contains the TradeFlow-owned master catalogue: 32 categories, 177 branches, 73 manufacturers, 3,845 master products and 108 product identifiers.
- 3,822 master products are currently active and customer-visible.
- The catalogue is system-owned data only. No TEST customers, subscribers, orders, inventory, returns or transactions were copied.

### Root causes found in Production
1. Production buying-catalogue.js contained an incomplete Supabase endpoint instead of the full LIVE API URL.
2. LIVE Supabase contained the catalogue schema and RPCs but the catalogue_master_* tables were empty.

### Controlled repair
A version-controlled master-catalogue data restoration was created from the verified TEST master catalogue using natural-key joins rather than tenant/test-record IDs. The restoration consists of 20261003210000_restore_master_catalogue_metadata.sql, 20261003210001 through 20261003210008 product snapshot migrations, and 20261003210009_restore_master_catalogue_identifiers.sql.

These migrations were applied successfully to TEST first, where the catalogue counts remained correct, and were then applied to LIVE.

The LIVE buying-catalogue.js endpoint was corrected to the full LIVE Supabase URL.

### Architectural rule confirmed
Master Catalogue → subscriber Buying Catalogue → Buying Request/Product identity → Valuation → Offer → Acquisition → Inventory → Selling/Retail category → Listing → Retail Order → Fulfilment → Return.

The Master Catalogue remains the controlled source for the initial product/category structure. When a subscriber activates a master product for Buying/Selling, TradeFlow creates the subscriber-facing category/branch/product structures; the same category structure can therefore carry the purchased product into Retail Selling without inventing a second unrelated category system.

### Verification state
Database restoration: Verified.
Frontend LIVE browser verification of Master Catalogue filters/product loading: pending user/browser confirmation.

Do not mark the browser step Verified Live until the LIVE Master Catalogue page successfully loads categories/manufacturers/products and a product can be selected without Failed to fetch.


## 2026-10-03 — LIVE Catalogue Authorisation Repair

The first LIVE Master Catalogue request reached Supabase but returned `400: Tenant user is not authorised to view catalogue`. Investigation traced this to missing platform authorization seed data in LIVE, not to the Master Catalogue data itself.

TEST contained 3 roles, 35 permissions and 91 role-permission mappings. LIVE had 0 roles, 0 permissions and 0 mappings. LIVE also had 0 plan_features; the active Enhanced subscription therefore had no recorded `module.buying` or `catalogue.pre_filled` entitlement even though the subscription itself existed.

The controlled repair `20261003213000_restore_platform_authorization_entitlements.sql` was created from verified TEST configuration using natural keys. It was applied to TEST first and verified at 3 roles / 35 permissions / 91 mappings, with 20 Enhanced plan features. It was then promoted and applied to LIVE.

LIVE verification now confirms the Adventure Outpost owner has the active `categories.view` permission and the Enhanced subscription has both `module.buying` and `catalogue.pre_filled` enabled.

No tenant memberships, customers, orders or transaction records were copied. Only platform role/permission/entitlement configuration was restored.

Next verification: refresh the LIVE Master Catalogue page and select a manufacturer. The expected result is that the catalogue request proceeds beyond the previous authorization error and the manufacturer/product results load.


## 2026-10-03 — Master Catalogue Duplicate Branch Sweep

A full sweep of the 32 Master Catalogue categories and 177 branches was performed in LIVE. Exact duplicate branch names and same-category near-duplicate branch names were reviewed rather than blindly merged. The clear semantic duplicate was `Drone Accessories → Drone Remote Controllers`, which contained one FIMI TX10A product, while `Drone Accessories → Drone Controllers` contained the other 39 controller products. The duplicate branch was consolidated into `Drone Controllers`, leaving 40 controller products in that branch.

Other same-category overlaps found (such as Continuous Lighting / Continuous Lighting Kit, COB Video Light / COB Video Light Kit, Tripods / Video Tripods, Camera Sliders / Camera Sliders & Dollies, Underwater Drones / Water Drones) were deliberately left separate because they represent distinct product scopes rather than true duplicates.

Cross-category repeated branch names such as Light Stands, Camera Supports, Tripod Heads and Flash Accessories were also left intact because their parent categories differ; they are not automatically safe to merge without changing taxonomy semantics.

The merge was applied to TEST first and verified, then promoted to LIVE via `20261003220000_merge_duplicate_drone_controller_branch.sql`.


## 2026-10-03 — Website Builder Template Architecture Update

The Website Builder now treats the ten templates as distinct layout compositions rather than simple colour variants. The same subscriber-editable headline, intro and CTA content is retained when switching templates.

A new homepage banner preference is stored as `homepage.use_banner`. When enabled and a banner exists, the uploaded branding banner occupies the primary hero title position. When disabled, the editable text headline remains in that position. The underlying headline text is retained when the banner option is toggled, so subscribers can switch between text and banner without losing content.

The banner option is presented in Branding as a clear checkbox: “Use banner in the homepage hero”. The fallback homepage hero image remains available separately.

TEST/main and LIVE/production were updated for the same template engine and styling. Website Builder cache versions were advanced to JavaScript v69 and CSS v65.


## Website Builder starter layout — 4 October 2026
The new-subscriber website starter is generated by the Website Builder fresh-start path after tenant bootstrap. The approved LIVE content-block arrangement is now encoded in that fresh-start template: a left text box, a right image box, and a lower text box, using the positions established during the 4 October builder acceptance work. Starter text content is blank so subscribers do not inherit placeholder copy. Subscriber branding remains separate and tenant-specific; uploaded logo/banner assets are not copied into the generic starter template.

The Website Builder continues to use the draft lifecycle: **Edit → Save Draft → Preview → Publish → LIVE**. Removing a logo or banner changes the draft in browser state; the subscriber must use **Save Draft** for that deletion to survive a reload. Publish remains separate and is not triggered by deletion or saving.

## Website Builder border and rounded-corner controls — 4 October 2026

The LIVE Website Builder editable homepage elements now support user-controlled borders and corner rounding for text and image boxes.

- Border styles: None, Solid, Dashed, Dotted, Double.
- Border widths: 1px–4px.
- Border colour is selectable.
- Round corners: Square, 2px, 4px, 8px, 12px, 20px, Fully round.
- The selected setting is stored with the editable element in the draft content and therefore survives Save Draft / reload / Publish.
- The editor's visible selection outline remains separate from the user's actual border, so selecting an object does not force a border onto the published site.
- Existing elements without a saved corner-radius value default to square corners, preserving backward compatibility.

Implementation commits:
- website-builder.js: 816a02d85cc6194b1ff8e0cf4757c0d803d352fe
- website-builder.css: 8dba5889960c1413166f834e1eb830f4bf6b8f9a
- website-builder.html asset bump: b26f73238f84ad87eaa0b22126f5b0221558c147

## Website Builder shared top section parity — 4 October 2026

The Shared top section editor now uses the same border controls as the Top of page editable canvas for selected text, photo, banner and logo elements: Border style, Border width, Border colour and Round corners. The chosen values are stored on the shared header element and applied to both the editor element and image clipping where applicable.

## Website Builder toolbar consolidation — 4 October 2026

The Top of page editing toolbar is now rendered inside the Shared top section editor. This keeps the add-element and formatting controls together while the editable homepage top-page canvas remains below it. The existing element data model and draft/publish lifecycle are unchanged.


## 2026-10-04 Toolbar parity correction
Shared top section and Top of page toolbars must retain the same light neutral background and complete text formatting menu. Shared top section now renders Text, Font, Size, Text colour, Line spacing and Letter spacing controls even before a text box is selected; controls are disabled until a shared text box is selected. Do not revert either toolbar to the black background or remove the Shared text controls.

## 2026-10-04 — Final Website Builder Starter Template Lock
The approved Website Builder starter arrangement is now the reusable default for new subscribers. Fresh-start coordinates are locked to the approved left text, right image, and lower full-width text boxes. Starter text is blank; no placeholder copy is seeded. The layout is a starting template, not an immutable subscriber canvas. Production integrity and link checks are recorded in CHECKPOINTS/2026-10-04-website-builder-starter-template-lock-final.md.

## 2026-10-04 Tile Link Destination Control

Website Builder homepage tiles and custom-page tiles (including What We Buy / What We Sell) now provide an explicit destination control for the tile's link text/CTA.

- **Link type:** TradeFlow page or Custom URL.
- **Link to:** when TradeFlow page is selected, choose any enabled site page; when Custom URL is selected, enter the destination URL.
- The link text remains the editable **CTA / Add link text** field.
- Internal page links use the site's normal page routing. Custom HTTP/HTTPS links are validated by the public site before being rendered as links.
- The destination is saved as part of the tile configuration and is used by both the builder preview model and the published public site.
- A blank CTA/link text does not create a public link.

This is part of the reusable standard website template. New subscribers receive the control as part of the standard tile editor; existing tile layout/positioning is not changed by adding the destination fields.


## LOCKED STANDARD WEBSITE BUILDER — 2026-10-05
The Website Builder has reached the approved reusable standard company/service website baseline. Treat the current home/top-section layout, banner, text/image/button boxes, tiles, page structures, editor controls, and positioning as a locked point set. New subscribers must receive this arrangement through the existing `resetToFreshWebsite()` / `template_reset_version: 2` behaviour. Do not redesign or reposition the baseline without explicit user approval. The exact restore/reference checkpoint is `CHECKPOINTS/2026-10-05-standard-website-builder-locked.md` and the continuation prompt is `CONTINUATION-PROMPTS/2026-10-05-standard-website-builder-locked.md`.

# 2026-10-05 — STANDARD WEBSITE BUILDER LOCKED BASELINE

The current LIVE/production Website Builder is now the approved standard reusable website template and is locked as the design/reference point for future company/service websites and new subscribers.

## Lock rule
Do not redesign, reposition, resize, restructure, or replace the locked Website Builder arrangement unless the user explicitly reopens the baseline. Future work must build around this baseline rather than silently changing it.

## Locked scope
- Home page structure and page composition.
- Shared top/banner section and its current arrangement.
- Text-box, image-box and CTA/button positions and proportions.
- Homepage body layout and tiles.
- What We Buy and What We Sell sections.
- Buying Catalogue / Buying page structure.
- Retail Shop page and tile structure.
- About, Contact and Customer Account pages.
- Shared top-section editor and Top-of-page editor.
- Text, font, size, colour, line spacing, letter spacing, border and background controls.
- Current light editor toolbar treatment and orange-accented control borders.
- Subscriber-specific branding remains tenant-specific; the template does not hard-code a subscriber's identity.
- Edit → Save Draft → Preview → Publish → LIVE workflow remains authoritative.

## New-subscriber starter layout
`resetToFreshWebsite()` is the source of the standard fresh-subscriber arrangement. `template_reset_version: 2` protects established drafts from being reset on reload.

Approved starter elements:
- Left text box: x 6, y 7.131578947809846, width 47.093378607809846, height 32.868421052190154.
- Right image box: x 56, y 8.236842105263158, width 38, height 34.
- Lower text box: x 0, y 53.68421052631579, width 70.44991511035653, height 28.

Starter text boxes are blank by design. Do not restore placeholder copy such as “Your Text Here” or “Edit this text” into the fresh starter content.

## Reuse objective
This locked arrangement is the standard starting template that can later be transferred/reused for other company/service websites. Do not build a separate style-system-dependent replacement unless explicitly requested. Preserve the existing page/content-box architecture.

## Reference restore point
Immutable restore branch: `LOCKED-standard-website-builder-2026-10-05`.
Production code state captured before documentation-only updates: `f3ff7f9d34030dbcde3440e21c097726ddef4f1d`.

## Next stage
The next chat will decide the next development stage. Do not infer or start that stage automatically. First read this lock and the continuation prompt, inspect current production state, and wait for the user's next instruction.

## CURRENT OVERRIDE — 2026-10-08 — LIVE custom-domain acceptance VERIFIED

This section is the latest system truth for subscriber-owned domains and supersedes older domain statements that describe the workflow as unverified or still awaiting final LIVE setup.

### Verified architecture
Subscriber-owned domain → TradeFlow Website URL request → Platform Owner seven-phase workflow → Cloudflare custom hostname → subscriber DNS → DNS verification → SSL/HTTPS verification → tenant routing verification → activation → published subscriber website.

### Verified LIVE test
- Subscriber: **Adventure Outpost**
- Hostname: **www.scenesource.co.uk**
- Result: **Active · Primary**
- Subscriber Website URL page confirmed: **Domain active. Your published TradeFlow website is connected to this domain.**
- Owner Dashboard showed no open subscriber domain connection requests after activation.

### Cloudflare infrastructure now verified
The existing LIVE tradeflow Worker is used for customer-owned hostnames. The laurendigital.co.uk Cloudflare zone has a wildcard Worker route */* pointing to the existing tradeflow Worker. The route uses **Fail closed (block)**. This resolved the 522 routing boundary encountered during the SceneSource test.

The subscriber DNS record used for the verified test was:
www CNAME → customers.laurendigital.co.uk

The exact CNAME target for future domains must always come from the approved Cloudflare connection preparation. Never invent or substitute a target.

### Verified defect history
- c7f0914e9a8686ba5d6e45e360b765ce0e2662e5 — owner dashboard authentication header repair.
- 03fe258aea835a51e6f68924cc5e49cb09fb71cb — authenticated owner RPC domain-action lookup repair.
- Cloudflare */* route — fixed customer-owned hostname 522 routing boundary.
- 25bbc9c86a5778e5911850c2ad64234696c221f4 — activation JavaScript scope repair; deployed in Cloudflare Production deployment 244d6f94.

### Release/acceptance rule
A domain feature is not complete merely because source code exists. It is verified only after browser evidence confirms the real hostname, the owner workflow and the subscriber Website URL state. Future defects must be reproduced/fixed in the controlled development/release process and then promoted to LIVE.


## 2026-10-09 — LIVE clean public-route root cause and repair

The LIVE SceneSource anonymous routing audit identified a second defect after Worker-first root routing was introduced. The Worker rewrites subscriber clean paths to `public-site.html` through `env.ASSETS.fetch()`. Cloudflare default `html_handling: auto-trailing-slash` can redirect that internal HTML asset request to `/public-site`, causing the browser to leave the intended clean route and the public renderer to fall back to its home page.

LIVE Supabase was independently checked: the published hostname exists in `published_site_index`, the domain exists as active/primary in `tenant_domains`, and the published index has an anonymous SELECT policy. The database is not the current failure point.

Production repair: `wrangler.jsonc` now uses `html_handling: "none"` and `run_worker_first: true`; public-site JavaScript was also made tolerant of trailing slashes and cache-bumped. Browser verification is pending deployment. Preserve the existing Cloudflare SaaS `*/*` route and domain/SSL state.

## 2026-10-09 — Public-site controller parse failure

A LIVE anonymous request to the correct subscriber root URL remained on the static loading shell. Production public-site.js contained a malformed regex literal in trailing-slash normalisation, which is a parse-time error and prevents the whole script from running. Since loadByHostname() never starts, this symptom precedes all Supabase reads and is not explained by a missing published_site_index row.

Fixed by production commit c1e4952d7588e071dc5ce132030afbd0cca97b89; public-site.html now references public-site.js?v=26 from commit 19aedd3cb17626834c1674999950488c9025a802. Await deployment and verify in an anonymous browser. Keep DNS, SSL, domain state, Supabase records and authentication unchanged.

## 2026-10-09 — Explicit platform root routing

Disabling Cloudflare HTML handling resolved the internal public-site canonical redirect but also removed the automatic `/` to `/index.html` fallback for platform-owned hosts. The platform homepage then returned 404. Production Worker commit `adf0021c25a95fc39c46587dbde98a0af6ef654a` now maps platform-owned `/` explicitly to `/index.html`; subscriber vanity `/` remains mapped to `/public-site.html`. Browser verification is pending deployment.

## 2026-10-09 — LIVE multi-account session-isolation test is next

The latest user screenshot shows the Adventure Outpost subscriber dashboard, the Platform Owner Dashboard and the SceneSource public subscriber website open at the same time in Google Chrome. The public website at https://www.scenesource.co.uk/ is now rendering the Action Outfit/Adventure Outpost content after the public-site loading/routing repairs. Do not infer that all clean routes or all session-isolation cases have passed merely because the homepage renders.

Next acceptance task: perform a read-only audit of LIVE customer/account records to establish whether a SceneSource website customer already exists. Distinguish website customers from subscriber owner accounts, business customers, test records and abandoned registrations. Do not create duplicate users or subscribers. Adventure Outpost is already present as the subscriber tenant and is currently signed in; do not create a second subscriber account or new Stripe checkout. If no suitable website customer exists, use the normal public Customer Login/registration flow to create one, with the user's approval and a clearly identifiable test email they control.

Then prove that the Platform Owner, Adventure Outpost subscriber, and SceneSource website customer can each remain signed in simultaneously in the same Chrome browser without one role replacing, impersonating or logging out another. Refresh/navigate each surface and test sign-out isolation. Preserve the established design: subscriber/business owners log into TradeFlow; the public website's Customer Login is for the subscriber's own customers. Do not add a business-owner login link to the public site.

Use the continuation prompt/checkpoint CHECKPOINTS/2026-10-09-live-multi-account-session-isolation-next-test.md. Work step by step; use LIVE evidence, read-only inspection first, do not expose credentials, do not weaken auth/RLS/tenant isolation, and do not change DNS/SSL/Cloudflare/domain state for an account-session test. Record pass/fail evidence before marking acceptance complete.

## 2026-10-09 — Platform Owner only: LIVE domain and customer-session audit

**Audience boundary:** this section is for the Platform Owner / developer manuals only. Do not expose these operational details in the Subscriber Website Manual or public/customer-facing pages.

### LIVE domain connection — authoritative owner procedure

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`. TEST project: `twfbmjwwqzxdxvclxbun`. Verify the environment before every query or change.
- The Adventure Outpost tenant ID is `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`.
- LIVE `public.tenant_domains` confirms `www.scenesource.co.uk` is the primary custom domain with status `active`, and its verification/activation timestamps are populated. `public.published_site_index` has a published revision for the hostname.
- TradeFlow uses subscriber-owned domains only. The subscriber buys, owns, renews and manages their domain with their chosen registrar. TradeFlow does not buy or renew it, and must never request the registrar password.
- Owner sequence: review the tenant and hostname → prepare the approved Cloudflare custom-hostname connection → give the subscriber the exact DNS record returned by the connection setup → verify DNS → verify SSL/HTTPS → verify tenant routing → activate only after all three checks pass. Never guess DNS targets or manually activate an unverified hostname.
- Branded platform address: `https://tradeflow.laurendigital.co.uk`. A tenant slug is a presentation/routing identifier, not a substitute for the internal tenant ID and tenant authorization boundary.

### LIVE customer-account status — read-only audit

- Exactly 2 non-deleted, email-confirmed Auth users were present: the Platform Owner (`leannelaurenlowe@hotmail.com`) and the Adventure Outpost subscriber owner (`valley-discounts@outlook.com`).
- One active Platform Owner membership and one active Adventure Outpost owner membership were present.
- LIVE `public.customers` contained 0 rows and 0 customer-to-auth links at the time of the audit. No SceneSource website customer account had been registered yet.
- The user has explicitly said they will create the test customer themselves using the public customer registration flow. Do not create a customer, duplicate the subscriber, or initiate another subscription checkout on their behalf.
- After the user registers, re-query LIVE read-only to verify the new customer record belongs to Adventure Outpost and is linked to the correct Auth user. Then test owner, subscriber and customer sessions in the same Chrome browser: independent sign-in state, refresh/navigation persistence, correct role-specific routes, and signing out of one role without disrupting the others. Do not claim session isolation passes until browser evidence is recorded.

### Subscriber manual boundary

The Subscriber Website Manual must contain subscriber-facing instructions only. The platform domain verification workflow, internal tenant/security explanation, audit counts, and owner/customer three-role test belong in these owner/developer manuals and the audit checkpoint, not in the subscriber manual. The 9 October cleanup branch removes the appended owner-only material that had appeared after the subscriber manual's main closing section. Keep that material out of future subscriber-manual edits.

## 2026-10-09 — TEST environment drift discovered during cleanup

The `cloudflare-test` branch is not a current copy of LIVE production. GitHub branch comparison currently reports it diverged from `production` by 21 commits ahead and 756 commits behind; do not merge or fast-forward it as a whole. Direct file/schema inspection also confirms environment-specific architecture drift:

- TEST `domain-settings.html` contained a retired `Buy a new domain` CTA linking to `domain-purchase.html`; the current LIVE architecture is subscriber-owned domains only.
- TEST `domain-settings.js` directly inserts/patches `tenant_domains` and does not use the current subscriber domain-request/status RPCs.
- Read-only TEST schema inspection found none of `subscriber_request_custom_domain()`, `subscriber_get_custom_domain_status()`, `platform_owner_list_domain_actions()` or `platform_owner_update_domain_action()`.
- TEST `platform-owner-dashboard.html/js` still exposes old domain-pricing/FX controls and does not implement the current owner domain-action workflow.
- An isolated branch `cleanup/test-retired-domain-ui-20261009` removes the obsolete purchase CTA and four directly accessible legacy purchase/registrant UI files. It also contains a checkpoint explaining that this branch is **not safe to deploy yet** because TEST frontend/backend architecture is stale. No LIVE code or database was changed.
- Legacy TEST Edge Functions remain active; the connector does not expose function deletion. Do not invoke or disable them without a separate caller, secret and dependency review.
- Do not blindly copy production files into TEST: the environment-specific Supabase URL/publishable key and required migrations/RPCs must be handled explicitly. The next safe TEST task is a controlled refresh/alignment plan and regression test, not deployment of the UI-only cleanup branch.

## Static session-isolation code review — 9 October 2026

Production source review found distinct role/session storage keys:
- Platform Owner: `tradeflow_platform_owner_session` in localStorage.
- Subscriber: `tradeflow_subscriber_session` plus `tradeflow_subscriber_tenant_id` in localStorage.
- Customer: `tradeflow_customer_session:<tenant_id>` in sessionStorage, with pending registration stored separately per tenant.
- Customer auth cleanup removes known legacy shared customer/test keys; it does not explicitly remove the current Platform Owner or Subscriber keys.
- The public-site controller checks for the subscriber key and uses the tenant-scoped customer session key.

This is encouraging static evidence that role storage is separated, but it is **not a runtime pass**. Owner and subscriber may share an origin while using different keys; the SceneSource customer domain is a different origin with separate browser storage. After the user creates the customer, test each role in the actual Chrome setup, including sign-in, refresh, route navigation and role-specific sign-out. Record observed outcomes; do not infer success from code alone.



## 2026-10-13 — Customer password recovery origin repair (verification pending)

LIVE customer login continued to return Supabase `invalid_credentials`, so the existing account/password must not be recreated or altered directly. The recovery request logs showed that the reset request was initiated from the TradeFlow platform Worker origin, and the recovery email consequently returned to that platform origin instead of the subscriber's customer website. The customer reset page is tenant-site-relative and the customer login is tenant-scoped, so this origin mismatch can strand recovery outside the correct portal.

Candidate production repair in branch `fix-customer-password-reset-tenant-origin-20261013`: when Forgot password is used on a platform hostname, resolve the tenant's unique published hostname from LIVE `published_site_index` and set `redirect_to` to that tenant's `/reset-password` route. If the tenant hostname is missing or ambiguous, stop with an explicit error instead of sending a reset link to the wrong host. On an actual subscriber hostname, preserve that origin. No password, Auth user, customer row, membership, tenant data, DNS or Supabase Auth configuration is changed by this code repair.

**Status: not yet proven fixed.** PR review/merge, Cloudflare deployment, allowed-redirect configuration and a fresh recovery email → password update → sign-in → customer dashboard journey must be verified. Previous reset emails may already be expired and must not be treated as valid test evidence. The TEST Supabase project remains untouched.


## 2026-10-13 — LIVE customer portal sign-in restored and cross-browser check passed

The user confirmed that the existing Adventure Outpost customer account can now sign in in both the regular Chrome window and Chrome Incognito at `https://www.scenesource.co.uk/login`. Both windows show the same customer portal, accepted DJI Osmo Action 6 Adventure Combo offer (cash offer £70.00), and the same pending bank-details notice. This is a user-observed pass for sign-in and session restoration in two browser contexts; it is not proof that every customer account, every recovery path, or the valuation/messaging workflow has passed.

The recovery-origin repair was merged to `production` in commit `f676fb13198d78f997ef5cb017af303e83c97efa` (PR #124). When recovery starts on a platform hostname, customer-auth code resolves the tenant's unique published hostname and directs the recovery link to that tenant's `/reset-password` route; it fails closed when the hostname is missing/ambiguous. No customer/Auth accounts, passwords, bank details, customer records, tenant data, DNS, or Supabase Auth settings were changed during this repair. TEST Supabase remains untouched.

The optional trailing empty fragment in `https://www.scenesource.co.uk/login#` is equivalent to the same URL without the final `#` for this flow. It is not an authentication token or an error; no change is required.

**Remaining verification:** Cloudflare deployment of PR #124 and Supabase Auth allowed-redirect settings have not been independently confirmed by the available tools. The user has observed successful sign-in in both windows, but a fresh password-recovery email → reset page → password update → sign-in journey has not been recorded as passed. Do not claim that complete recovery journey or the separate valuation/messaging issue is resolved until tested. The current customer portal also correctly displays the prompt to add bank details before payment can proceed; do not edit or invent bank details.


## 2026-10-13 — Bank-details save failure: expired customer access token

### Confirmed root cause
LIVE Supabase logs show repeated `POST /rest/v1/rpc/customer_save_bank_details` requests returning HTTP 401 with PostgREST `PGRST303`. The log's JWT timestamps show the access token had expired before these save attempts. The LIVE customer row exists for the signed-in user, but the corresponding `customer_bank_details` row did not exist after the failed attempts. The save RPC itself validates the authenticated user and validates UK sort code/account number lengths; there is no evidence that the function or schema is the cause of this particular failure.

### Code repair prepared
The customer dashboard API helper now detects an HTTP 401, refreshes the existing Supabase session using its refresh token, stores the renewed session in the existing tenant-scoped session storage, and retries the original request once. Concurrent requests share one refresh operation to avoid racing token rotation. Dashboard script URL is bumped from `customer-dashboard.js?v=151` to `v152` to avoid stale browser caching.

### Safety and status
- No bank details have been written by an administrative query; no values have been invented or copied from the screenshot.
- No customer/account/tenant rows, auth users, schema, RLS, or RPC definitions were changed.
- LIVE only; TEST remains untouched.
- This repair is on branch `fix-customer-bank-save-expired-session-20261013` and is not yet verified in the deployed site. Merge/deploy is required, then a customer must save their own real bank details and confirm the saved values reload. Never treat the screenshot's example bank values as real data.


## LIVE PURCHASE COMPLETION / LEDGER REPAIR — 13 OCTOBER 2026 (APPLIED; FRESH-FLOW TEST PENDING)

Read-only audit found that LIVE `subscriber_complete_purchase` marked payment/acquisition/item paid and created inventory, but omitted the purchase ledger entry and left acquisition/item completion timestamps and inventory `ready_for_sale_at` unset. Existing transaction ACQ-10F8FFABBC12 (£70 GBP; manual reference `test`) was not modified; the reference is not independent evidence of a bank transfer.

PR #126 was merged to `production` (merge commit `708dba463a2aa67ac1d8acbf9c59fd8f8806b407`). LIVE Supabase migration `fix_purchase_completion_ledger_and_timestamps_20261013` was applied successfully (recorded migration version `20261013183319`). Read-only verification confirms the updated function includes a ledger entry, guarded completion transitions and placeholder-reference rejection. The four platform-owner-only domain RPCs now report `anon_execute=false` and `authenticated_execute=true`. No existing transaction rows were altered. A fresh controlled purchase-flow acceptance test is still required.

A second isolated branch `fix/restrict-subscriber-domain-rpcs-20261013` contains proposed migration `supabase/migrations/20261013200000_restrict_subscriber_domain_rpcs.sql` to remove PUBLIC/anon execute from two subscriber-only domain RPCs while preserving authenticated execute. This second migration is not yet applied. Remaining anonymous SECURITY DEFINER functions are reviewed separately; public catalogue/published-site/plan endpoints are intentionally exposed and must not be bulk-restricted. TEST project `twfbmjwwqzxdxvclxbun` remains untouched.


## LIVE purchase completion and security follow-up — 2026-10-13

- LIVE project: `gxsrajtqzdjvmceqcpgv`. TEST project `twfbmjwwqzxdxvclxbun` was not accessed for writes.
- Reconciled the LIVE `subscriber_complete_purchase` function into `supabase/migrations/20261013183319_fix_purchase_completion_ledger_and_timestamps_20261013.sql`. The function requires an authenticated tenant member with buying, finance, acquisitions and inventory permissions; only accepted cash offers are supported; placeholder payment references such as `test` are rejected; payment, acquisition, acquisition item, inventory, ledger and notification are created in one transaction; lifecycle timestamps are set; the acquisition and acquisition item are transitioned from paid to completed through the guarded workflow RPC.
- Hardened `public.customer_credit_accounts` by revoking direct table privileges from `anon` and `authenticated`. Its RLS has no direct-client policies and the table is intended to be accessed only through identity-/tenant-checked RPCs. No customer credit records were changed.
- Existing test transaction `ACQ-10F8FFABBC12` remains unchanged. It still contains payment reference `test`, has no ledger row, and its acquisition/item status remains `paid` with `completed_at` unset. Do not silently backfill this as a genuine payment or completed accounting event; reconcile it only as an explicitly labelled test record or after the subscriber confirms a real transfer/reference.
- Security advisor after the previous hardening still reports 14 RLS-enabled tables with no policies, 8 anonymous-executable SECURITY DEFINER functions and `pg_net` in `public`. The table warning is not by itself a leak: direct access is blocked by RLS, and direct grants on `customer_credit_accounts` are now revoked. The remaining anonymous-callable functions return public published/catalogue data or public plan data; review their returned columns and intended public use individually rather than bulk-revoking. `private` schema has no anon USAGE, so its anon execute ACL findings are not directly exposed through PostgREST.
- The migration source and security follow-up are being recorded in the production repository. No broad RLS policies were added and no payment/customer data was edited.
- Status: function-level correction is applied in LIVE and verified by reading its deployed definition. Existing transaction reconciliation and browser end-to-end verification remain pending. Do not mark the whole transaction test passed until a controlled follow-up confirms a non-placeholder reference, completion timestamps, linked ledger entry, inventory timestamp and customer-facing status agree.


## Additional LIVE ACL hardening — 2026-10-13

- Applied migration `20261013200946_revoke_anon_private_helper_function_execute_20261013` in LIVE Supabase. Removed `PUBLIC`/`anon` EXECUTE grants from `private.is_active_tenant`, `private.platform_admin_list_subscriber_accounts`, `private.platform_admin_manage_subscription`, and `private.queue_buying_request_received_notification` where direct client execution is not intended.
- Verified `anon` no longer has EXECUTE on these four functions. The `private` schema has no `USAGE` grant to `anon`; owner-context SECURITY DEFINER code can continue to call its helper functions.
- No records, table data, customer data or payment data were changed. TEST remains untouched.


## LIVE explicit deny policies for locked tables — 2026-10-13

- Applied LIVE migration `20261013201345_explicit_deny_policies_for_locked_tables_20261013` to the 14 previously policy-free RLS tables: `assistant_conversations`, `assistant_messages`, `catalogue_master_branches`, `catalogue_master_categories`, `catalogue_master_manufacturers`, `catalogue_master_product_identifiers`, `catalogue_master_products`, `customer_bank_details`, `customer_credit_accounts`, `customer_credit_holds`, `payment_provider_events`, `platform_ai_settings`, `platform_owner_domain_actions`, and `tenant_catalogue_state`.
- Each now has an explicit `FOR ALL TO anon, authenticated USING (false) WITH CHECK (false)` policy. This is deliberate deny-all, not a public-read or tenant-read policy. The tables remain RPC/service-role only; direct client table grants remain absent.
- Read-back verification confirms 14/14 policies exist, each has false USING and WITH CHECK, and there are zero direct anon/authenticated/PUBLIC table grants on these tables. Supabase security advisor no longer reports the `rls_enabled_no_policy` finding. TEST was not modified.
- This clears the misleading no-policy warning without opening customer bank data, credit data, payment-provider events, internal AI settings, domain-action history, or master catalogue tables to direct client queries. Existing controlled SECURITY DEFINER RPCs are unaffected because these tables are not FORCE RLS.


## Selling: inherited retail categories and Website channel (2026-10-14)

The Selling workflow must retain the inventory asset's original `category_id` and `branch_id` when publishing a listing. Do not ask subscribers to recreate the buying category or branch as a separate retail taxonomy. TEST evidence: Camerashack has published listings retaining the original `Camera` → `Photography Cameras` IDs; the branch's `selling_enabled` flag is false for some existing published listings, so do not assume that flag alone prevents publishing.

LIVE audit found Adventure Outpost had no rows in `sales_channels`, causing the Selling form to report “The Website sales channel is not configured for this business.” PR #139 was merged to `production` (commit `04486a98d188ad29c06196971d516259ef9c7035`) to reactivate an existing storefront channel or create a tenant-scoped Website channel during publishing when none exists. Script cache version is `v87`. This is code-merged, not proof of successful LIVE deployment or browser publication; verify after Cloudflare deployment. Do not write channel rows directly to LIVE as a substitute for testing the workflow.

## Retail shipping settings: current boundary

`shipping-settings.html` configures provider/service links for the Buying workflow (inbound customer shipments); it is not a store-wide retail delivery policy page. The Selling form stores per-listing postage method, price, and dispatch time in `listings.listing_data.shipping`; `public-site.js` displays the resulting P&P summary. As of this audit, no separate store-wide Retail Shipping Settings page was found. Do not direct users to Buying Shipping Settings as though it controls retail checkout. A dedicated retail shipping settings feature must be designed and connected to listing defaults/public storefront behavior before claiming it exists.


## 14 October 2026 — LIVE category inheritance and shipping-settings follow-up

- Environment boundary remains strict: work in LIVE only; TEST project `twfbmjwwqzxdxvclxbun` is a reference and must not be modified.
- LIVE Adventure Outpost currently has no `sales_channels` row, and its active buying categories/branches are marked `selling_enabled=false`. PR #139's Website-channel creation and original category/branch ID preservation therefore still need a real publish-path verification.
- Follow-up code change: when publishing an inventory asset to Website, reuse its original buying category and branch, enable their existing `selling_enabled` flags if needed, and verify the flags before creating the listing. Do not create duplicate shop categories or branches.
- Shipping Settings should be reachable from the Settings sidebar. Its selected courier links serve manual Buying and retail-order fulfilment workflows. Do not restore the retired Parcel2Go API or old TEST provider connection. Customers pay their shipping provider directly; TradeFlow must not collect or pay postage.
- The selling dashboard's Supabase URL fallback must point to LIVE. The shared subscriber-auth runtime remains responsible for selecting TEST versus LIVE from the environment; verify the deployed page on the LIVE domain before considering the change complete.
- No direct LIVE database rows were changed as part of this code audit. Category flags change only when a subscriber publishes an item to Website through the updated flow. After merge/deploy, verify with a controlled test item and inspect the resulting Website channel, category/branch flags, listing, and public shop visibility.


## 14 October 2026 — Selling publish permission error

- LIVE Selling showed `permission denied for table inventory_assets` when publishing the existing Adventure Outpost inventory item. The authenticated role has SELECT but no direct UPDATE grant on `public.inventory_assets`; do not restore broad table UPDATE access to work around this.
- Repair approach: route the Selling form's serial-number/location save through `public.subscriber_update_inventory_asset_sales_fields`, a narrowly scoped SECURITY DEFINER RPC. It must require an authenticated active tenant member with `inventory.manage` and the `module.inventory` feature, and update only the specified asset within that tenant.
- Apply the migration to LIVE through the version-controlled migration process before deploying the new Selling JavaScript. The client uses the RPC for both new listings and editing existing listings; direct `inventory_assets` PATCH calls for these fields are removed.
- Regression checks: publishing still creates the listing and transitions inventory state through the existing workflow RPC; editing still saves listing details; a user without tenant permission cannot update another tenant's asset. TEST remains untouched.


## 14 October 2026 — Selling inventory permission error

- LIVE Selling showed `permission denied for table inventory_assets` when publishing the existing Adventure Outpost inventory item. The authenticated role has SELECT but no direct UPDATE grant on `public.inventory_assets`; do not restore broad table UPDATE access to work around this.
- Repair approach: route the Selling form's serial-number/location save through `public.subscriber_update_inventory_asset_sales_fields`, a narrowly scoped SECURITY DEFINER RPC. It requires an authenticated user with `inventory.manage` and the `module.inventory` feature, and updates only the specified asset within that tenant.
- Apply migration `20261014180000_subscriber_update_inventory_asset_sales_fields.sql` to LIVE through the version-controlled migration process before deploying the new Selling JavaScript. The client uses the RPC for both new listings and editing existing listings; direct `inventory_assets` PATCH calls for these fields are removed.
- Regression checks: publishing still creates the listing and transitions inventory state through the existing workflow RPC; editing still saves listing details; a user without tenant permission cannot update another tenant's asset. TEST remains untouched.


## 14 October 2026 — Inventory status synchronisation follow-up

- LIVE logs confirmed the serial/location RPC returns HTTP 200, but Selling's listing-status synchronisation still attempted direct PATCH requests to `inventory_assets`, causing the same permission error after a listing status transition.
- Replace those remaining direct status PATCH requests with `subscriber_sync_inventory_asset_status`, a SECURITY DEFINER RPC restricted to the two expected transitions: `ready_for_sale → listed` and `listed → ready_for_sale`. It requires authenticated `inventory.manage` permission and the `module.inventory` feature, and scopes updates to the tenant and asset.
- The publish path now uses the resolved asset's ID rather than an out-of-scope `assetRow.id`. Script cache key advances to v91.
- Apply migration `20261014190000_subscriber_sync_inventory_asset_status.sql` to LIVE before deployment. Verify logs show RPC calls and no direct inventory_assets UPDATE, then check public published storefront (not only `template-preview=draft`). TEST remains untouched.


## 14 October 2026 — What We Sell page layout

- The subscriber's What We Sell / Retail Shop page should be driven by published retail listings. Do not show the generic six editable page tiles or the “Find a product” search field on this page.
- Website Builder's shop page now renders the page title/body and subscriber-linked product cards only; it no longer exposes the page-tile editor controls for the shop page. The What We Buy page and Home page retain their own category/tile controls.
- Public storefront rendering of the shop page no longer includes `renderPageTiles(site,p)` or the product-search filter. Published subscriber listings remain automatically rendered in the product grid, with the existing empty-state message when there are no published products.
- Cache keys advanced: Website Builder `v123`; public storefront `v27`. Verify the editor and public `/shop` page after deployment; confirm What We Buy and Home tiles are unchanged.


## 14 October 2026 — What We Sell page layout and catalogue search

- The What We Sell / Retail Shop page should not show the six blank template tiles. Tile selection is not part of this page; the product list must be populated automatically from the subscriber's published retail listings.
- Keep a `Find a product` search field and add a category selector based on categories present in the published listings, with product counts. Search filters the existing product cards by name, description and category without changing the underlying listing data.
- On the shop page only, suppress empty placeholder elements from the configurable global-header canvas so blank image/text placeholders do not render as six empty tiles. Preserve populated logo/banner/header elements and all other pages' template layout.
- Public site asset cache versions advance to `public-site.js?v=28` and `public-site.css?v=32`. Verify LIVE What We Sell with several published products, category filtering, text search, no-results state, and confirm other pages still show their configured tiles. TEST remains untouched.


## 14 October 2026 — What We Sell page layout

- The dedicated public `shop` route must show the subscriber's published product listings automatically. Do not render the generic editable page tiles/cards on this route; those remain available on ordinary content pages where appropriate.
- Keep the `Find a product` search input and category selector on What We Sell. The search matches product title, description, and category; the category dropdown is populated from the published listing categories and includes product counts. Product cards must come from published retail listings, not static subscriber-edited tiles.
- Production renderer `renderShopPage` already builds the title, search/category filters, product grid and empty state without calling `renderPageTiles`. Advance the public renderer script cache key from v28 to v29 so deployed browsers fetch that renderer instead of a stale cached version.
- Verify on the actual public `/shop` URL that the six placeholder tiles are gone, the search/category controls remain, and all published products are automatically listed. Do not change other website pages or TEST.


## 14 October 2026 — Working What We Sell template and next retail purchase test

### Accepted What We Sell / Retail Shop template
- The dedicated What We Sell page is an automatically populated catalogue of the subscriber's published retail listings. Subscribers do not manually select or fill six generic tiles on this page.
- Remove the six empty/template tile placeholders on the dedicated What We Sell / Retail Shop page only. Do not remove editable tiles or content blocks from Home, What We Buy, or other website pages.
- Keep the **Find a product** search field. Keep the **Category** dropdown, populated automatically from the categories present in the subscriber's published listings and showing per-category counts. Search text and selected category filter the product cards; result count updates and a helpful no-results message appears when nothing matches.
- Product cards are populated from published listings and should show the available product image, title, category, description, asking price, and View product link. The page must not depend on manual tile entry.
- Current public-shop screenshot on 14 October shows the DJI Osmo Action 6 Adventure Combo at £125.00 and the Find a product/search and Category controls. This confirms the intended layout is visible; it does not by itself prove checkout or fulfilment works.
- PR #146 is the latest documented implementation for this page. Public shop script cache key is v29. Keep this behaviour as the working template for future subscriber websites; do not regress to the six placeholders or remove search/category filtering.

### LIVE selling permission and category work
- PR #139 covers Website channel creation and preservation of original buying category/branch IDs. PR #141 adds category/branch sellability checks and makes Shipping Settings discoverable. PR #142 adds a permission-scoped RPC for serial number/location updates. PR #143 routes inventory status synchronisation through a narrowly scoped RPC and removes remaining direct inventory status PATCH calls.
- LIVE Supabase project remains `gxsrajtqzdjvmceqcpgv`; TEST project `twfbmjwwqzxdxvclxbun` is reference-only and must not be changed.
- No broad authenticated UPDATE grant is to be added to `inventory_assets`. Inventory mutations must remain tenant-scoped and permission-checked through approved RPCs.
- After PR #143, the LIVE database migration was applied. Production Selling script source uses cache key v91. The complete Selling-to-publication workflow has not yet been independently verified end-to-end; check logs for RPC calls rather than direct table updates.

### Next test — purchase the published DJI Osmo Action 6
- Product shown: **DJI Osmo Action 6 Adventure Combo**, asking price **£125.00**, on the public `/shop` page for Adventure Outpost.
- First establish the payment mode and whether checkout can be tested without a real charge. Do not initiate a live-money charge or invent/assume test credentials. Use a confirmed safe test route only.
- Follow the product link to product detail and checkout. Verify basket/checkout retains the correct tenant, listing, title, price and currency; customer authentication/registration works without looping; order is created once; payment status matches the actual payment outcome; and no record is marked paid before verified payment.
- After the controlled purchase, verify the order appears consistently in the customer portal, subscriber order/sales view, and finance/ledger records; check stock/inventory transitions to sold/reserved according to the intended workflow; and confirm the public listing is no longer purchasable if sold. Check shipping choice/tracking expectations separately and do not let TradeFlow collect postage fees.
- Do not reuse the earlier simulated purchase as proof of a real transaction. Keep LIVE/TEST clearly separated, record each observed status/reference, and stop at the first failure for diagnosis rather than repeatedly retrying checkout.

---

## Environment audit and handover — 21 October 2026 (LIVE / production)

This is an environment-specific status note. It records observed results and outstanding checks, not a claim that every feature has passed end-to-end testing.

### Verified / recorded
- The stray catalogue-tab CSS text was corrected in `buying-catalogue.html`; the user confirmed the LIVE Buying & Pricing page displays cleanly after the correction.
- The production catalogue page source was compared with TEST and `buying-catalogue.js` matched at the time of review. This does not prove the filtered product query returns results.
- Do not apply the TEST-only `site_revisions` privilege migration to LIVE without checking current grants and the RLS policy first. No LIVE database grant was made during this review.
- LIVE Stripe flows are reported by the owner as working; this audit did not run a live payment or alter Stripe configuration.
- Catalogue product-row verification remains open: a prior screenshot showed category filters populated but zero product rows. Test a known product and inspect the RPC response before declaring the catalogue fully verified.

### Quick audit results
- Supabase table listing reported row-level security enabled on the inspected public tables in both environments. This is a baseline check, not a proof that every RLS policy is correct.
- Supabase advisors showed matching categories of existing warnings in TEST and LIVE at review time: SECURITY DEFINER functions executable by anon/authenticated roles, `pg_net` in the public schema, and unindexed foreign keys. Review each finding in context; do not blanket-revoke access or move extensions without checking dependencies.
- Matching advisor counts and frontend source do not establish full schema, migration, function, data, or deployment parity between TEST and LIVE.
- TEST and LIVE intentionally contain separate business/customer/payment records. Shared catalogue behaviour must be verified at the product-data and query level; do not assume database rows are physically shared merely because the interface is the same.

### Release guardrails
- Keep LIVE production branch/project separate from TEST repair branch/project.
- No LIVE schema change, Stripe change, migration, or deployment was made as part of the TEST `site_revisions` grant.
- Do not merge or deploy the complimentary-subscriber release candidate until its LIVE origin/redirect configuration, migration compatibility, owner-only authorization, invitation flow, and paid Stripe signup regression checks are verified.
- The immediate remaining technical checks are: (1) verify product rows/search in both master catalogues; (2) verify TEST Website Builder Save draft; (3) finish TEST Stripe Sandbox monthly checkout and webhook/status confirmation; (4) review and prioritize the existing Supabase advisor findings.

### Update rule
Replace any item above only when a new browser observation, query result, webhook delivery, or controlled end-to-end test supports the change. Do not mark untested functionality as complete.

---

## Environment audit and handover — 21 October 2026 (LIVE / production)

### Verified observations and open checks
- Catalogue-tab CSS leakage was corrected in the environment's source. LIVE page cleanliness was confirmed by the owner; TEST category filters load, but a recent screenshot still showed zero product rows. Product retrieval/search is not yet verified.
- The owner confirmed the LIVE Buying & Pricing page displays cleanly after the catalogue-tab CSS correction. Do not apply the TEST-only site_revisions grant to LIVE without checking existing grants and RLS first. LIVE Stripe is owner-reported working; no live payment was run.
- Supabase advisors showed matching categories of existing warnings in TEST and LIVE: SECURITY DEFINER functions callable by anon/authenticated roles, pg_net in the public schema, and unindexed foreign keys. Investigate each finding in context; avoid blanket revocations or extension moves.
- Supabase table inspection reported RLS enabled on inspected public tables, but this does not prove every policy is correct. Matching source/advisor counts do not establish full schema, migration, function, data, or deployment parity.
- LIVE and TEST business/customer/payment records are separate. Do not copy tenant, customer, or payment records across environments. Verify shared master-catalogue behaviour at the query/data layer rather than assuming the interface means physical database sharing.

### Release guardrails and next steps
1. Verify product rows and known-product search in both master catalogues.
2. Confirm TEST Website Builder Save draft succeeds in the browser after the privilege grant.
3. Complete TEST Stripe Sandbox monthly checkout, webhook delivery, and subscription status in the owner dashboard; keep complimentary subscriptions free and isolated from Stripe.
4. Review and prioritize the Supabase advisor findings.
5. Do not merge/deploy the complimentary-subscriber release candidate until LIVE owner origin/redirect configuration, migration compatibility, owner-only access, invitation flow, and paid Stripe signup regression checks are verified.

Do not mark untested functionality complete. Update this note only when supported by a browser observation, query result, successful webhook delivery, or controlled end-to-end test.

## Audit note — 21 October 2026 — LIVE

- Owner confirmed the LIVE Buying & Pricing page is clean after the catalogue-tab CSS correction.
- Product retrieval remains unverified: a recent catalogue screenshot showed categories but zero product rows. Verify known-product search before calling this complete.
- The TEST-only site_revisions UPDATE grant was not applied to LIVE. Check existing table grants and RLS before any production change.
- LIVE Stripe is owner-reported working; no live payment was run in this audit.
- Supabase advisors show existing SECURITY DEFINER access warnings, pg_net in public schema, and unindexed foreign-key warnings. Review individually; do not blanket-revoke or change extension placement.
- RLS being enabled on inspected tables does not prove every policy is correct. Matching frontend code/advisor counts do not establish complete environment parity.
- Remaining checks: product rows in both catalogues, TEST Save draft browser confirmation, TEST Sandbox checkout/webhook/status, and advisor review. Keep TEST/LIVE data separate and do not mark untested flows complete.


## Complimentary subscription feature access — 21 October 2026

- LIVE migration `20261021210642_add_complimentary_subscription_feature_access_live_20261021.sql` updates `private.has_tenant_feature(uuid,text)` to recognise explicitly active manual complimentary subscriptions (`billing_provider = 'manual'`, `provider_status = 'complimentary'`).
- Access remains gated by an active plan, an enabled matching `plan_features` row, and `ended_at` being null or in the future. Trial and paid/past-due rules remain unchanged.
- Applied to LIVE and verified the function definition, `SECURITY DEFINER` status, and pinned `search_path` (`pg_catalog, public`). This confirms the database function update, not a full end-to-end complimentary tenant browser test.
- Do not route complimentary subscriptions through Stripe or alter Stripe price IDs for this change. Verify a designated complimentary tenant can access its enabled features and that ended/inactive subscriptions remain denied.

## Security and performance audit continuation — 21 October 2026

- Rechecked Supabase advisors for TEST and LIVE. Both report the same major categories: public-schema pg_net extension, 8 anon-executable SECURITY DEFINER functions, 164 authenticated-executable SECURITY DEFINER functions, and 65 unindexed foreign-key findings.
- Both environments have RLS enabled on all 99 ordinary tables in public (99/99; none disabled). This is a coverage check only, not proof that every policy expression is correct.
- Do not blanket-revoke SECURITY DEFINER execution grants: public published-site/catalogue and public-plan RPCs may intentionally need anon access, and authenticated RPCs require per-function authorization review.
- Do not add all 65 foreign-key indexes blindly. Review existing index coverage, query plans and write overhead first; prioritize tenant-scoped transactional tables and high-traffic lookups.
- Continue by comparing exact RLS policy expressions and security-sensitive RPC bodies across TEST and LIVE, then review advisor findings in batches. LIVE is the behavioural reference and must remain stable; TEST-only Stripe configuration must remain isolated.
- Complimentary subscription access was added to LIVE in migration 20261021210642_add_complimentary_subscription_feature_access_live_20261021.sql. Database function definition verified; an end-to-end browser test for an actual complimentary tenant is still outstanding.


## Platform owner dashboard and complimentary subscribers — 21 October 2026

- The LIVE platform owner portal is hosted at `https://owner.laurendigital.co.uk`; the complimentary-subscriber Edge Function accepts requests only from that origin and requires a valid JWT plus an active platform-owner membership.
- LIVE Edge Function `platform-create-complimentary-subscriber` is ACTIVE at version 1 with JWT verification enabled. It sends an invitation, then provisions an active tenant, active owner membership, and an `enhanced` complimentary subscription through `public.platform_owner_create_complimentary_subscriber`.
- The provisioning RPC is SECURITY DEFINER with an empty search path; execution is granted to authenticated and not anon. The RPC checks platform-owner access, verifies the invited user's email, rejects duplicate slugs and existing active owner membership, and does not create a Stripe checkout.
- TEST owner dashboard now includes the Lauren Digital product-page editor for TradeFlow, StudioFlow and BusinessFlow. The owner confirmed the section is visible and the Cloudflare deployment shows Ready. Database records currently show TradeFlow `published`, StudioFlow `coming_soon`, BusinessFlow `coming_soon`.
- Remaining verification: confirm a harmless product-page edit persists after save/refresh; run complimentary onboarding end-to-end using a dedicated approved test email; verify no duplicate invite/workspace on retry. No LIVE subscriber was created and no LIVE Stripe settings were changed during the dashboard-parity repair.


## Production/TEST release boundary update — 22 October 2026

The latest GitHub comparison confirms that `production` and `test/stripe-connect-test-mode-repair-20261020` have diverged (TEST 114 commits ahead, 38 behind). Do not merge the entire TEST branch into LIVE. It includes TEST-specific Stripe Connect, invite acceptance and resend code. LIVE is the production baseline; TEST project is `nnsshnfkjcflucjrftzi`; LIVE project is `gxsrajtqzdjvmceqcpgv`.

TEST browser verification: the owner dashboard displays TradeFlow (Published), StudioFlow (Coming soon) and BusinessFlow (Coming soon). The complimentary test subscriber successfully reached the subscriber dashboard and could sign out/in again when using the subscriber login page. The platform-owner sign-in error was a wrong-login-page test, not evidence of a broken subscriber password.

The resend setup-link button is still unverified and must not be pressed again until the next explicitly guided test. No LIVE records, schema, Stripe settings or deployments were changed by this verification. Do not delete old files in bulk: first prove they are unreferenced by runtime HTML/JS, Worker routes, Edge Functions, migrations, manuals or rollback checkpoints. Keep archived migration/checkpoint records.


## Audit continuation — 22 October 2026 (LIVE source reconciliation and Supabase advisors)

- Latest GitHub comparison for `production` against `test/stripe-connect-test-mode-repair-20261020`: TEST is 114 commits ahead and 42 behind. Earlier 38/33-behind figures in prior notes are stale. Do not bulk-merge.
- LIVE deployed Edge Functions are present: `stripe-connect-onboarding` version 13 (JWT verification enabled; deployed source SHA-256 `f4f4d6054e486901cab6ec488bcd6baa1e9f445485b558102603822771c3c7de`) and `stripe-connect-webhook` version 4 (JWT verification disabled as expected for a webhook; deployed source SHA-256 `ec13b5ff7d6ceda7a42c3bf00d046fd184759c4500687de9208eec4eed7ecdd7`). Both are ACTIVE in LIVE.
- The corresponding source files were absent from `production`. Exact source was retrieved from the deployed LIVE functions and committed to version control without redeploying or changing runtime behavior: onboarding source commit `421c7e66529b20f0542925a0c66a5c7b32238afd`; webhook source commit `6e83cfe28faec14fbfbb8e563c67ee38038f3609`. This repairs source traceability only; it is not a deployment or a functional test.
- LIVE onboarding source uses a LIVE-key guard, validates the Supabase user and active tenant owner/admin membership, and uses a Stripe idempotency key. TEST source is not interchangeable: it includes an explicit environment-mode guard and differs in implementation. Keep each deployed implementation environment-specific.
- Read-only SQL checks in LIVE and TEST each found 99 public tables, zero public tables without RLS, zero SECURITY DEFINER functions missing a configured search_path, and zero direct anon/PUBLIC grants on the inspected sensitive payment, membership, subscription and customer tables. These checks do not prove all RLS expressions, RPC authorization, storage policies, or tenant boundaries are correct.
- Supabase security advisors in both environments report: `pg_net` installed in `public`; 8 SECURITY DEFINER RPCs executable by `anon`; 165 such functions executable by `authenticated` in LIVE and 164 in TEST; and leaked-password protection disabled. Review the eight anon-callable functions individually because some public-site/catalogue RPCs may intentionally serve public pages. Do not blanket-revoke function grants. Enable leaked-password protection through a separately verified Auth settings change.
- Performance advisor snapshot: both environments report 65 unindexed foreign keys, 166 RLS init-plan warnings, and 14 multiple-permissive-policy warnings. LIVE reports 64 unused-index notices and 3 duplicate-index notices; TEST reports 112 unused-index notices. Do not drop indexes based only on a fresh/low-traffic usage snapshot. Review duplicate indexes against constraints and migrations before any change.
- Sensitive-table policy inspection showed tenant-membership/permission checks on customers, payment records, payment-provider connections, payment-provider customers and tenant subscriptions in both environments. This was a targeted inspection, not a complete cross-tenant penetration test.
- Outstanding: inspect all advisor-listed anon-callable SECURITY DEFINER functions and their grants/body authorization; audit full tenant isolation and payment/ledger writes; compare deployed LIVE/TEST checkout and payment-webhook source; verify the complimentary setup resend flow only under a deliberate test plan; run manual browser checks where specified. No SQL permissions, schemas, Stripe settings, data or Edge Function deployments were changed in this audit.

## 2026-10-22 Follow-up — public website access hardening

LIVE migration `public_published_content_active_tenant_guard_20261022` was applied (remote version `20261022143445`; source file `supabase/migrations/20261022160000_public_published_content_active_tenant_guard.sql`). Public published-site, listing, and media RPCs now require an active tenant and use `search_path=''`. RLS policies for `tenant_public_profiles` and `published_site_index` use the active-tenant predicate. EXECUTE on `private.is_active_tenant(uuid)` is granted to `anon` for policy evaluation only; the private schema remains inaccessible directly. LIVE Edge Function `public-listing-media` is version 11 and checks tenant status before generating signed URLs.

Verified as SQL role `anon`: current public profile, published-site index, and published-site RPC each return the current published row; direct access to schema `private` remains denied. At verification time there was one active tenant with a published website and no inactive-tenant index rows. No catalogue, pricing, or evidence-ingestion data was changed. Browser/API end-to-end tests and full tenant-isolation/payment verification remain outstanding.

## LIVE security continuation — 22 October 2026

- Applied LIVE migration version `20261022144655` (`secure_test_registration_and_scope_domain_rpcs_20261022`). Source file is aligned to the remote migration version at `supabase/migrations/20261022144655_secure_test_registration_and_scope_domain_rpcs_20261022.sql`.
- Reconciled the published-content guard source filename to LIVE migration version `20261022143445`; its source now lives at `supabase/migrations/20261022143445_public_published_content_active_tenant_guard_20261022.sql`. Do not reapply either migration.
- Hardened `admin_complete_test_registration` and `staff_complete_test_registration`: both now require the target tenant to be active and `settings.test_lab` to equal true, in addition to their existing authentication, email, and reserved-slug checks.
- Added tenant-explicit RPC signatures `subscriber_get_custom_domain_status(p_tenant_id uuid)` and `subscriber_request_custom_domain(p_tenant_id uuid, p_hostname text)`. Both require an authenticated active membership for that exact active tenant and `website.manage`; their execution is granted to `authenticated` only, not `anon`/PUBLIC.
- Kept legacy no-argument / hostname-only signatures for backwards compatibility, but changed them to fail closed if the user has multiple active tenant memberships rather than selecting an arbitrary tenant.
- Updated production `domain-settings.js` to pass its selected `tenantId` to both explicit RPCs (commit `727508bf1944bf914ee46072e6ae0f4927617746`).
- Verified with LIVE SQL that both new domain RPCs are SECURITY DEFINER with pinned search paths; `has_function_privilege` confirms `anon` cannot execute them and `authenticated` can. LIVE currently has zero active reserved test slugs and zero active `test_lab` tenants.
- Restored the previously missing source for `platform-create-complimentary-subscriber` at `supabase/functions/platform-create-complimentary-subscriber/index.ts` (commit `b9f97dda6584aadef1055a212571400389fff2aa`) and deployed LIVE version 2. Deployed source exactly matches the production-branch file; JWT verification remains enabled. Added explicit `POST, OPTIONS` CORS methods, corrected the stale TEST message to LIVE, stopped returning raw RPC error text or invited user IDs, and made unexpected errors generic while logging safe status-only diagnostics.
- No domain request, invitation, customer, transaction, catalogue, pricing, or valuation record was created by verification. No browser end-to-end domain or complimentary-subscriber flow test was performed; these remain required before calling those workflows fully verified.
- Still open: review remaining authenticated SECURITY DEFINER functions; enable leaked-password protection through supported Auth configuration; assess the `pg_net` advisor warning carefully. LIVE has an active `tradeflow-notification-queue` cron job running every minute via `net.http_post`, using Vault secrets named `tradeflow_project_url` and `tradeflow_notification_processor_secret` and the `x-tradeflow-cron-secret` header. The `process-notification-queue` function is version 10 with JWT verification disabled but checks that secret; do not move the extension or alter the cron job until the queue path is regression-tested. Complete browser/API tenant-isolation and payment tests, and run a controlled owner-portal test of complimentary subscriber provisioning.


### Post-change Supabase advisor snapshot — 22 October 2026, 14:50 UTC

- Security: 8 anonymous-executable SECURITY DEFINER RPCs (reviewed as intended public catalogue/published-content/plan endpoints); 167 authenticated-executable SECURITY DEFINER functions requiring continued individual review; `pg_net` extension reported in `public`; leaked-password protection disabled.
- Performance: 65 unindexed foreign keys, 166 RLS init-plan warnings, 64 unused-index notices, 14 multiple-permissive-policy warnings, 3 duplicate-index notices, and an informational Auth connection-allocation warning.
- These advisor findings are not proof of exploitable vulnerabilities on their own. Do not blanket-revoke RPCs or drop indexes. Prioritize authorization review of privileged functions and verify each index/policy against actual query plans and workload before changing it.


## 27 October 2026 — Separate automatic cash/trade-in and catalogue verification

The merged PR #186 at `ff68b656c1e523d1144ff6c02fcef8fd3239d178` adds per-condition trade-in percentage controls in the Buying Catalogue. The current `production` head inspected for this continuation was `3cbba7add8a406c7c03cd0660ba3a3c80ea50742`. The database has corresponding pricing RPC parameters in both LIVE (`gxsrajtqzdjvmceqcpgv`) and TEST (`nnsshnfkjcflucjrftzi`).

### Verified contract
- `configure_master_catalogue_buying_product_pricing` persists five cash percentages, five trade-in percentages, and the separate manual override columns.
- `get_tenant_buying_catalogue_page` exposes the saved trade-in percentage fields so the editor can reload them; `get_tenant_buying_catalogue_facets` filters My Buying Catalogue to configured products.
- `calculate_buying_item_valuation` uses UK-new GBP evidence for both calculations. Cash amount is based on its cash percentage and trade-in amount on its separate trade-in percentage. Missing evidence returns the existing manual valuation path.
- `customer_get_offers_v2` returns cash and trade-in prices, and `customer_accept_offer_choice` checks and records the customer's chosen mode and value.
- `subscriber_credit_trade_in` retains the accepted trade-in plus post-inspection `final_offer_required` checks. Do not loosen these gates.
- Pokémon master product counts are 23,780 in both environments. No all-products add/configuration should be run; selected cards require an explicit narrow product selection and verified tenant context.
- TEST has two tenants/52 tenant buying products and LIVE one tenant/243 buying products; these are environment-specific business records and must not be synced.

### Work performed on branch
Branch `fix/automatic-tradein-pokemon-condition-20261027` contains the dual-price/customer-offer fixes plus Pokémon-specific grade labels in the pricing editor (Buying Catalogue script v60; customer dashboard v153; buying dashboard v79). The five per-product condition rule slots are presented as Near Mint, Lightly Played, Moderately Played, Heavily Played and Damaged for Pokémon cards only. TEST-applied migrations map canonical Pokémon grades to those five slots for pricing while preserving the original grade in the valuation result and on the buying item. Another TEST-applied migration removes storefront visibility as a gate from subscriber configure/add and My Buying Catalogue queries; public storefront visibility remains a separate setting. Migration files are committed on this branch. See checkpoint `CHECKPOINTS/2026-10-26-pokemon-tcg-live-sync.md`.

### Open verification / not yet complete
- End-to-end browser acceptance of both prices with a fresh TEST-only item remains outstanding.
- Actual save/refresh verification of separate percentages remains outstanding.
- Specific-card add and My Buying Catalogue confirmation remains outstanding.
- Pokémon-specific condition choices and valuation-slot mapping are implemented in the branch and TEST. End-to-end persistence through inspection, inventory and sales still requires a signed-in TEST flow; standard electronics condition labels remain unchanged.
- Current Cloudflare deployments for latest production and TEST must be verified before saying this branch is live.


### Independent cash and trade-in calculation follow-up (2026-10-27)
TEST migration `20261027235942_independent_cash_tradein_condition_overrides` fixes the valuation early-return path: a per-condition cash manual override no longer suppresses a separately configured trade-in percentage when UK New GBP evidence exists. Cash and trade-in values are resolved independently, each using its own manual override when present; missing research still falls back to manual handling. Read-only TEST function checks passed for original Pokémon grade preservation, independent cash/trade-in calculations and manual fallback. Signed-in end-to-end TEST and Cloudflare runtime verification remain outstanding; do not promote to LIVE until those checks pass.

### Pokémon research prerequisite

- TEST evidence check: the active English Pokémon master catalogue has 23,780 cards, but there are currently zero active shared-market-evidence rows for Pokémon and zero Pokémon buying products configured for the selected TEST tenant. Therefore, percentage-based Pokémon valuation will correctly remain on manual fallback until valid UK New GBP evidence exists; do not insert guessed prices or treat collector metadata as pricing evidence.


## Multi-item valuation consolidation — 28 October 2026

### Product and workflow decision
A customer may submit multiple products within one buying request. The request is the grouping boundary; each product remains a separate `buying_items` record with its own item reference, valuation amounts, offer, stage, shipping/receipt/inspection lifecycle, and downstream acquisition/inventory record. Do not merge item records or infer that two items belong together solely because they share a customer.

### Customer portal
- Initial/revised offers for all items in a request are presented in one combined quote when every item in that request has a current published initial/revised offer.
- The quote displays item-level cash and trade-in values plus combined totals.
- Customers can accept cash or trade-in for an individual item, refuse an individual item, or use the whole-quote actions to accept all for cash, accept all for trade-in, or refuse the complete quote.
- Individual actions use the existing per-offer RPCs (`customer_accept_offer_choice` / `customer_refuse_offer`). Whole-quote actions use `customer_respond_to_combined_offer`.
- Final offers after inspection remain item-specific. Separate buying requests remain separate quotes. A mixed response may result in some items proceeding while others are refused; downstream state must be checked per item.

### Subscriber Buying workspace
- Items sharing a request are grouped under a combined valuation heading while retaining individual item cards and item workspaces.
- In a multi-item request, the item valuation panels are stacked before research evidence and photographs.
- One “Submit total valuations” action is shown for eligible multi-item requests. It collects each item's cash/trade-in inputs and submits each item through the existing manual-valuation RPC sequentially, preserving per-item values.
- **Important implementation limitation:** this subscriber-side multi-item submission is a sequence of per-item RPC calls, not one atomic database transaction. If a later call fails, an earlier item's offer may already have been created. Treat this as a known hardening item until an atomic batch RPC is implemented and tested.

### Database and separation rules
- The request-level RPC `customer_respond_to_combined_offer(p_tenant_id, p_buying_request_id, p_decision, p_offer_mode, p_response_notes)` is installed on TEST and LIVE. It validates ownership and offer eligibility and applies whole-request decisions in one database transaction.
- The per-item RPCs remain in use for mixed decisions. Do not change them to request-wide decisions.
- Keep TEST and LIVE tenant/customer/request data separate. Only promote code and documentation; do not copy test records into LIVE.
- Keep item-level workflow transitions and event logging. Receiving, inspection, final offers, payments and inventory remain per item.

### Changes and verification record
- Updated `customer-dashboard.js` and `buying-dashboard.js` on `cloudflare-test` and `production`.
- Syntax checks passed for the four dashboard JavaScript files after the latest changes.
- Screenshot/browser review confirmed the combined customer quote, item-level decision buttons, whole-quote buttons, grouped subscriber request, stacked item valuation panels and single submit control.
- Not yet verified end-to-end: accepting one item while refusing another through all downstream stages; whole-quote response under a real authenticated TEST session; shipping through payment for every mixed-state case; atomic rollback for multi-item manual valuation submission.
- Therefore status is **implemented and UI-reviewed; partial verification only**. Do not describe the entire workflow as fully end-to-end tested or launch-certified.

### Test checklist before closing the work
1. In TEST, submit a request with two items and enter different cash/trade-in values for each.
2. Confirm one subscriber submission creates an offer for each item and the customer sees correct per-item values and totals.
3. Accept one item and refuse the other; verify each item independently in customer and subscriber dashboards.
4. Test accept-all cash, accept-all trade-in and refuse-all on separate safe TEST requests.
5. Check per-item shipping, receipt, inspection, final offer, payment and inventory for accepted items; confirm refused items do not advance.
6. Test error handling if one per-item submission fails. Replace sequential submissions with an atomic batch RPC before treating bulk submission as transaction-safe.
7. Repeat visual and regression checks on TEST before confirming LIVE behavior. Do not use LIVE customer transactions as test fixtures.


## Subscriber website SEO settings — 30 October 2026

The subscriber Website Builder provides page-specific SEO settings in the Pages panel. Home page values are stored in `content.site.homepage.seo_title` and `seo_description`; internal page values are stored on their corresponding `content.site.pages[]` objects. These fields remain part of the existing `site_revisions.content` JSON document; no new table or migration is required.

The builder saves SEO values through the existing Save Draft and Publish lifecycle. The public website reads the active route's values and updates the document title, meta description, Open Graph title and Open Graph description. Empty SEO fields fall back to a sensible page title and omit an empty description rather than emitting stale metadata. Search engines may rewrite snippets; the description is a hint, not a guarantee.

Keep tenant website revisions isolated between LIVE and TEST. Do not copy subscriber content or SEO values between environments. Code and documentation are aligned across the two environment branches; subscriber data remains environment-specific.


### TEST/LIVE runtime endpoint correction — 30 October 2026
The Website Builder must use `window.TRADEFLOW_CONFIG.supabaseUrl` supplied by `subscriber-auth.js`; it must not hard-code the LIVE Supabase URL. The subscriber auth layer selects TEST (`nnsshnfkjcflucjrftzi`) on the TEST worker and LIVE (`gxsrajtqzdjvmceqcpgv`) on the production worker. A hard-coded LIVE URL caused the TEST builder to send TEST credentials to LIVE and prevented the TEST draft from loading. This is an environment-routing defect, not an SEO schema or tenant-data migration. Keep the two projects isolated and verify the TEST builder loads and saves against TEST only.


## Xbox evidence continuation — 30 October 2026

- Added and read back UK used sold evidence for Xbox Series X Digital Edition 1TB in both TEST and LIVE: eBay item 318636321021, sold 27 July 2026. Item specifics confirm Xbox Series X, white colour and 1TB storage; condition is Used. The listing displays £312.59 including a separate £12.59 Buyer Protection fee, so the evidence price stored is the underlying listing price of £300.00 GBP. Source key: `ebayuk-318636321021-xboxseriesx-digital-1tb-20260727`. TEST product: `5fc70dc3-5bf9-4e26-b888-abae5b12c8c8`; LIVE product: `bd71b9e9-50fb-4e2a-9226-92dc38fd21eb`. Both writes returned and read-after-write queries confirmed matching active rows and three active evidence rows per environment for this product.
- A second Xbox One 1TB candidate (eBay item 327264154460, £59.49, sold 1 August 2026) was already present in both databases under source key `ebayuk-327264154460-xboxone-1tb-20260801`; do not insert it again. TEST/LIVE readback confirmed two active Xbox One 1TB rows per environment: £52.54 (item 188496733818) and £59.49 (item 327264154460).
- No application code, valuation rules, tenant data or Worker deployments were changed. Shared market evidence only was updated. TEST/LIVE product UUIDs remain environment-specific.


## LIVE server-rendered subscriber SEO — 30 October 2026

- LIVE Worker source change: `worker/index.js`, commit `8c441953c69d6c1b73e4a9593ba82f10a7cddf62` (production branch).
- On subscriber custom-domain requests routed to `/public-site.html`, the Worker now looks up exactly one row in the environment-specific `published_site_index`, filtered by the incoming hostname. It reads only the published `content` JSON and selects homepage SEO or the matching enabled page's SEO fields.
- The Worker injects the title, meta description, Open Graph title and Open Graph description into the initial HTML response. Values are HTML-escaped. If the lookup fails, the original HTML response is returned; existing `public-site.js` metadata handling remains as a client-side fallback.
- The lookup uses the Worker environment's matching Supabase URL/key (TEST variables on TEST, LIVE variables on production). It does not query all tenants, alter published content, or copy data between projects. Responses remain no-store.
- LIVE read-only verification before the code change: `published_site_index` contained the active hostname `www.scenesource.co.uk`, tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`, revision 7, published at `2026-10-30 22:25:54.985446+00`; homepage SEO title and description were both the agreed temporary value `test`. These values were not changed.
- The Cloudflare Production deployment visible around 30 minutes before the user's screenshot corresponded to commit `05cc0ff71eee93647bffacea1d55c68b9500bd34`; that commit changed documentation only and explicitly recorded no Worker deployment/code changes. It did not include this SEO implementation.
- New SEO code was committed to LIVE `production` at `8c441953c69d6c1b73e4a9593ba82f10a7cddf62`. Cloudflare's post-commit deployment and raw HTTP response still require verification. Do not describe this as live until the deployed Worker version and returned HTML are checked.
- Next verification: confirm Cloudflare Production deployed the new commit; request `https://www.scenesource.co.uk/` and inspect the raw response source for the title, description and OG tags; inspect an internal published page; confirm an unknown hostname or missing index row falls back safely; check no TEST data is read by production.


## Website Status Preview CTA correction — 30 October 2026

- The subscriber reported that the dark Preview website CTA beside Open Website Builder did not navigate, while the sidebar Preview website link worked.
- In `subscriber-website.html`, the central `#preview-link-main` control is now a real `button type=button` rather than an anchor. Its click handler explicitly navigates to the same tenant-scoped draft preview URL (`public-site.html?preview=draft&business=<slug>`) generated after subscriber authentication and tenant slug resolution.
- The sidebar preview link and dashboard preview tile remain ordinary links and retain their existing behavior. The action styling is covered by the existing `.actions button` CSS rule.
- LIVE production commit: `72c2a521dd2d1834afb98094d0456d85b6aa875f`.
- Deployment and browser click verification are still required; do not claim the button is fixed on the deployed site until tested after the production Worker/static asset update.


## Complimentary testing account and Subscription & Billing dashboard — 1 November 2026

- Owner-approved LIVE change for tenant Adventure Outpost (`b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`): retain the existing business account and all tenant data indefinitely for testing, with no recurring subscription payment.
- Existing Stripe subscription was already set in Stripe to cancel at the end of its 30-day trial (2 November 2026 18:43:28 UTC; Stripe showed “No further invoice”). That Stripe cancellation was not reversed and no new Stripe checkout/subscription was created.
- The historical Stripe-linked `tenant_subscriptions` row was archived locally as cancelled. Original Stripe subscription/customer/price identifiers and cancellation timing remain in its metadata/provider metadata; live provider ID columns were cleared so subsequent Stripe webhook sync cannot overwrite the replacement complimentary entitlement.
- A separate current entitlement row was created for the same tenant and existing active TradeFlow plan: `billing_provider='manual'`, `provider_status='complimentary'`, `status='active'`, no Stripe identifiers, no period end, no cancellation. This uses the existing `private.has_tenant_feature` complimentary-access branch. Verified feature checks returned true for `module.buying` and `website.editor`.
- No tenant, membership, website, catalogue, customer, transaction, or published content records were deleted or copied. No TEST project data was changed.
- LIVE dashboard `subscriber-dashboard.html` now has a visible “Subscription & Billing” panel and a navigation link to it. It reads the current tenant subscription and displays complimentary status/no payments/indefinite access. The small cancellation link at the bottom of the sidebar has been removed. For normal paid/trial subscriptions it shows the plan/billing/next payment/access-end details and offers cancellation in the main panel; for already-cancelled subscriptions it shows that cancellation is scheduled; for complimentary accounts it hides cancellation.
- LIVE production commit for dashboard panel: `04701b992cf1b6248448ee28a34a0b648043ec87`. Browser deployment and UI verification remain required.


## LIVE subscriber checkout security — deployed 1 November 2026

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (EU West 2).
- `subscriber-create-checkout-session` is deployed and verified at Edge Function version **13** with JWT verification enabled.
- Migration `guard_subscriber_signup_subscription_collisions` is applied to LIVE and recorded as `20261101130118`.
- The database finalisation RPC now serialises signup finalisation per Auth user, accepts a retry only for the same existing Stripe subscription ID, and rejects a different subscription ID rather than replacing an existing subscription.
- LIVE checkout validates the exact platform HTTPS origin, uses origin-bound CORS, no longer trusts Referer, checks for an existing active business before creating checkout, and sends a stable per-user Stripe idempotency key.
- TEST Stripe is not required for this LIVE deployment and was not changed.
- No Stripe products, prices, API secrets, dashboard settings, customer records, payment records or existing subscription rows were changed.
- Deployment and database state are confirmed. Full real-browser checkout and webhook E2E verification have not yet been performed; do not mark the entire signup journey fully tested until that is complete.


## LIVE subscriber checkout — billing interval and verification status (1 November 2026)

The LIVE subscriber signup functions now store the correct monthly or annual interval from the exact configured Stripe Price ID. The finalisation RPC rejects an unrecognised Price ID before creating a tenant; the subscription-sync RPC updates the interval only for a recognised configured monthly/annual Price ID and otherwise preserves the stored value. The migration is `20261101131036_preserve_subscriber_billing_interval.sql`, applied to LIVE as registry version `20261101131036`.

The configured LIVE plan remains £59.99 monthly or £499.99 annually, GBP, with a 30-day trial. Existing subscription rows, Stripe products/prices, Stripe secrets, customer/payment records and Stripe dashboard settings were not changed. TEST Stripe is not required for this LIVE work.

Important verification boundary: checkout function version 13 and webhook version 16 are deployed, but a real browser signup through Stripe Checkout and webhook provisioning has not yet been completed. Do not describe signup as end-to-end verified. No live payment should be initiated without a controlled test plan.

The deployed LIVE webhook source has connected-account handling that is absent from both the production and hardening-branch GitHub copies. Do not redeploy either repository copy over LIVE. Reconcile the deployed source into version control and review its connected-account payment/refund paths before any webhook edit or redeployment.


## Email-confirmation checkout resume correction — 1 November 2026

- Production `subscriber-signup.js` now includes the selected `billing_interval` in Supabase Auth user metadata as well as the existing pending-signup browser record (commit `cc6b9e898a8f35f7ae5e6c24b2e9b2e5825136ce`).
- Production `subscriber-login.html` now resumes checkout with the saved monthly/annual choice when the pending signup email matches the authenticated account; it falls back to the Auth metadata interval and then monthly only when no saved selection exists (commit `92068c1ed9c9477141d6d1857273b7bdd9c74d63`).
- The pending signup record is cleared when the account already has an active membership and the user is sent to the subscriber dashboard.
- Static source inspection confirms the selected interval is passed into `subscriber-create-checkout-session`. Browser verification remains outstanding; do not claim the email-confirmation route has passed end-to-end testing.

## Subscriber TEST routing correction — 1 November 2026

The subscriber login and signup frontend files had stale references to retired TEST Supabase project `twfbmjwwqzxdxvclxbun`. They now use current TEST project `nnsshnfkjcflucjrftzi` and its publishable key. Signup explicitly recognises the TEST Worker hostname. Changes are committed on `production`; browser/Worker runtime verification and Cloudflare deployment remain unverified.


## Xbox One X 1TB evidence parity repair — 2 November 2026

- TEST already contained eBay UK item 178294853613 under source key `ebayuk-178294853613-xboxonex-1tb-20260708`: £57.02 GBP, Used, sold; TEST product `4b12312f-59e6-4d56-bf4b-c4fab935a9fa`.
- LIVE initially had no row for this key. It was added using the established privileged Supabase migration route, mapped to LIVE product `ce5e59d6-5ff8-4bd3-983f-63d1bf4b8e3a`.
- LIVE read-after-write verified active evidence ID `e3498deb-5606-4965-80ab-d9d5951467b3`, £57.02 GBP, Used, eBay UK, sold, observed 8 July 2026 22:08 UTC, source https://www.ebay.co.uk/itm/178294853613.
- Displayed total £59.50 included £2.48 Buyer Protection fee; stored item price excludes the fee.
- No application code, valuation rules, tenant/customer/payment data, RLS, grants, or Worker deployment changed. This was a shared evidence data-only parity repair.


## Xbox One X 1TB used-sale evidence batch — 2 November 2026

Two additional exact UK used completed sales were added to shared evidence in TEST first, then mirrored to LIVE using privileged Supabase migrations. Both environments were read back successfully by source key and active status:
- eBay item 397946718089: sold 2 August 2026; Used Very Good; black Xbox One X 1TB console only with box; displayed £73.94 included £2.95 Buyer Protection fee; stored underlying item price £70.99 GBP. Key `ebayuk-397946718089-xboxonex-1tb-20260802`. TEST evidence ID `2c0dd7c3-6873-49df-a78c-37400bff6666`; LIVE ID `ff030633-5649-435e-a3f9-35aa8a3088e5`.
- eBay item 178527813316: sold 5 October 2026; Used; black Xbox One X 1TB unit only, fully working; displayed £66.54 included £2.71 Buyer Protection fee; stored underlying item price £63.83 GBP. Key `ebayuk-178527813316-xboxonex-1tb-20261005`. TEST evidence ID `f753badd-83ec-4ed3-8b24-31386dcbfc4c`; LIVE ID `d76f6d1d-19f6-473e-be56-62f3bc6787f3`.
- TEST product `4b12312f-59e6-4d56-bf4b-c4fab935a9fa`; LIVE product `ce5e59d6-5ff8-4bd3-983f-63d1bf4b8e3a`. Each environment now has five active Xbox One X 1TB evidence rows. Existing 13 September row remains fee-inclusive at £59.50 and 16 September £134.92 row has not been altered; audit these separately before correction.
- An initial migration attempt using `ON CONFLICT(source_record_key)` failed because no matching unique constraint exists. It made no change; the successful migration used a `WHERE NOT EXISTS` duplicate-key guard. Do not use ON CONFLICT for this table unless a suitable unique constraint is first confirmed.
- No valuation logic, tenant data, RLS/grants, application code or Worker deployment changed.


## Xbox One X evidence quality corrections — 2 November 2026

- Rechecked eBay item 168682015736: sold 13 September 2026, 1TB black console only with power/HDMI leads and no controller. Display £59.50 included £2.48 Buyer Protection fee. Corrected active stored price from £59.50 to £57.02 GBP in TEST and LIVE; source key `ebayuk-168682015736-xboxonex-1tb-20260913`.
- Rechecked item 336746788067: sold 16 September 2026, but listing bundle includes Elite controller, free stand, PUBG, other games and play/charge kit. Retired it from the standard-console evidence set (`is_active=false`) in both environments; retained row for audit. Key `ebayuk-336746788067-xboxonex-1tb-20260916`.
- Read-after-write confirms both changes match across TEST and LIVE. The new 2 August and 5 October console-only sales remain active. Four active standard-console rows now remain from the five Xbox One X rows in each environment. No valuation logic or RLS/grants changed.


## Xbox 360 500GB fee correction and parity audit — 2 November 2026

- eBay UK item 147564021425 sold as a used, fully working black Xbox 360 E 500GB console. The displayed £64.46 included a £2.64 Buyer Protection fee; corrected the comparable item price to £61.82 GBP.
- Updated the existing evidence row in TEST and LIVE only when its source key, environment-specific master product ID, active status and old £64.46 value matched. TEST evidence ID: 6146fc0b-8f8c-4422-a153-070f896fe5cc; LIVE evidence ID: b68e7dbd-c3ac-48ac-827b-c85c597c1726. Both read-after-write checks confirm £61.82, active=true, with notes recording the excluded fee.
- Full Xbox catalogue readback shows matching TEST/LIVE evidence content for the 13 mapped variants. Current active counts: Xbox 360 4GB 2; 250GB 2; 500GB 1; Xbox One 500GB 2; 1TB 2; Xbox One S 500GB 2; 1TB 2; All-Digital 1TB 2; Xbox One X 1TB 4; Xbox Series S 512GB 3; 1TB Carbon Black 2; Xbox Series X Disc 1TB 2; Xbox Series X Digital 1TB 3. Total 27 active rows per environment. Retired historical rows remain retained and inactive.
- No new Xbox 360 500GB comp was found: the other surfaced 500GB sold candidates were bundles or special editions. No new evidence row was inserted.
- No application code, valuation logic, tenant/customer/payment data, RLS/grants or Worker deployment changed. This was a shared market-evidence price correction only.


## Xbox One S All-Digital evidence quality update — 2 November 2026

- Retired eBay item 278283038276 from active standard used-price evidence in TEST and LIVE. eBay confirms Best Offer accepted, but the accepted transaction price is not disclosed; displayed £41.92 (including £1.92 Buyer Protection fee) is not a verified sale price. Historical row retained inactive.
- Added verified UK used sale eBay item 178548159734: Xbox One S All-Digital Edition, white, MPN 1681, 1TB, console only, sold 5 October 2026. Displayed £36.75 included £1.75 Buyer Protection fee; stored item price £35.00 GBP. Active row read back in TEST (evidence ID cb1995e7-9511-462b-be20-cfb10585bd2d) and LIVE (542ed2ea-409e-4c74-84b7-1d23819040cf), each mapped to its own product UUID.
- No valuation logic, tenant/customer/payment data, RLS/grants, app code or Worker deployment changed. Shared market evidence only.


## Xbox Series S 512GB evidence expansion and provisional-record retirement — 2 November 2026

- Added four verified UK used completed sales to the Xbox Series S 512GB standard-console product in TEST and mirrored to LIVE using each environment's own product UUID. eBay item 147650120878 sold 25 Oct 2026, displayed £258.21 less £8.89 Buyer Protection fee = stored £249.32; item 327383217934 sold 10 Oct, displayed £238.25 less £8.25 = £230.00; item 137818359559 sold 13 Oct (auction, includes wireless controller), displayed £213.75 less £7.46 = £206.29; item 206610408847 sold 8 Oct, displayed £227.92 less £7.92 = £220.00. All four have explicit 512GB item/title confirmation, UK used condition and sold status. Source keys respectively: ebayuk-147650120878-xboxseriess-512gb-20261025; ebayuk-327383217934-xboxseriess-512gb-20261010; ebayuk-137818359559-xboxseriess-512gb-20261013; ebayuk-206610408847-xboxseriess-512gb-20261008.
- Retired item 227560758629 from active 512GB evidence in both environments. Its sold listing identifies Xbox Series S but does not specify storage capacity in the title or item specifics; retaining it as a 512GB benchmark would be an unsupported assumption. Historical rows retained inactive. TEST evidence ID fef1b21b-9aed-4aef-9456-e82cdcfad080; LIVE ID 9b698812-b6ae-4b92-86a2-afb80ab0350c.
- Read-after-write verified all four new active rows in both environments, and verified the provisional row inactive in both. No tenant/customer/transaction/Stripe data, valuation rules, application code, RLS/grants or Worker deployments changed.


## Xbox Series S Carbon Black and Series X Digital evidence additions — 2 November 2026

- Added two UK used completed sales for Xbox Series S 1TB Carbon Black in TEST and LIVE: eBay item 127189380281 sold 9 Sep 2026, displayed £208.47 less £7.29 Buyer Protection fee = £201.18; item 147607178323 sold 30 Sep 2026, displayed £258.92 less £8.92 = £250.00. Both listings specify 1TB Carbon Black and include a controller. TEST evidence IDs b21e12c1-6fa3-4e39-8b9a-9dfd98baa50c and 65d98b98-3e6e-4808-96af-35e7f779635a; LIVE IDs 87d1ff1b-4a34-418c-8177-cefa67e865d5 and f41b7c25-2a39-42cf-a89d-56675a15c3ed.
- Added one UK used completed sale for Xbox Series X Digital Edition 1TB: eBay item 137590211396, sold 12 Aug 2026. Displayed £347.75 included £11.19 Buyer Protection fee; stored underlying item price £336.56. TEST evidence ID 733e0e5a-752d-42f2-bc7f-8e119f885162; LIVE ID ac6082fa-9b4b-4ec8-a38e-3e935c324a20.
- All three new rows read back active in both environments, mapped to their own product UUIDs. Updated active Xbox evidence total is 35 in TEST and 35 in LIVE across 13 variants. Series S Carbon Black now 4 active; Series X Digital now 4 active. No tenant/customer/transaction/Stripe data, valuation logic, RLS/grants, application code or Worker deployments changed.

## 2 November 2026 — Selling listing editor repair

The Selling editor now saves title, description, asking price, currency and listing metadata through `public.subscriber_update_listing_details`, a tenant-scoped SECURITY DEFINER RPC. It requires authentication, `selling.manage`, and `module.selling`; it refuses sold/delisted records and never changes workflow status or ownership. Public/anon execution is revoked; authenticated execution is granted. Direct authenticated UPDATE on `public.listings` remains denied.

The editor normalises Manufacturer/Model/Package so identical Model and Package values are not repeated in the listing title. New public listing descriptions start blank instead of copying internal structured customer-submission fields. Script cache version: `selling-dashboard-fixed.js?v=92`.

The migration was applied independently to TEST (`nnsshnfkjcflucjrftzi`) and LIVE (`gxsrajtqzdjvmceqcpgv`). Function existence and execute privileges were verified in both. No business data was copied between environments; existing LIVE GoPro listing data was not changed. Browser save/reload and Cloudflare deployment verification remain outstanding.


## 2 November 2026 — Gaming console and accessories catalogue (Nintendo batch 1)

The gaming category is `Gaming Consoles & Accessories`. Current TEST and LIVE Supabase data were inspected independently before writes. Both environments now have the same verified catalogue coverage for this batch; each has its own product/evidence UUIDs.

### Catalogue changes
- Added Nintendo as a manufacturer.
- Added branches: `Nintendo Consoles`, `Nintendo Handheld Consoles`, `Nintendo Controllers`, and `Nintendo Accessories`.
- Added five visible master products: Nintendo Switch 2 256GB, Nintendo Switch OLED 64GB, Nintendo Switch (V2) 32GB, Nintendo Switch Lite 32GB, and Nintendo Switch 2 Pro Controller.
- Added seven active UK evidence rows: two new and five used. Older Switch variants currently have used evidence only; do not invent current new retail prices.
- Repaired ten existing Sony product records with null branch assignments by mapping them to the existing PlayStation console, handheld, VR, controller, headset or accessories branches. No Sony product prices or evidence were changed.
- The first Switch 2 new-price capture used a generic retailer category page and was not sufficiently exact. It was deactivated and replaced with the exact Smyths Toys UK product page at £389.99 (RRP £419.99 shown). The replacement is active and has availability `listed`.

### Nintendo evidence added
| Product | Evidence | Price | Source / reference |
|---|---|---:|---|
| Nintendo Switch 2 256GB | UK new, listed | £389.99 | Smyths Toys UK, https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-consoles/nintendo-switch-2-console/p/249605 |
| Nintendo Switch 2 256GB | UK used, sold-market median | £309.00 | PathAu, median of 153 eBay UK used sales in the 30 days to 25 Oct 2026, https://pathau.co.uk/prices/consoles/switch-2/ |
| Nintendo Switch OLED 64GB | UK used, sold | £145.00 | eBay UK item 307194468463, sold 24 Sep 2026, https://www.ebay.co.uk/itm/307194468463 |
| Nintendo Switch V2 32GB | UK used, sold | £62.99 | eBay UK item 318506459251, sold 4 Sep 2026, https://www.ebay.co.uk/itm/318506459251 |
| Nintendo Switch Lite 32GB | UK used, sold | £72.00 | eBay UK item 287545083895, sold 13 Oct 2026, https://www.ebay.co.uk/itm/287545083895 |
| Nintendo Switch 2 Pro Controller | UK new, listed | £74.99 | Nintendo Store UK controller catalogue, https://store.nintendo.com/en-gb/_sites/nintendo.co.uk/consoles/nintendo-switch-2-consoles/nintendo-switch-2-accessories/nintendo-switch-2-controllers |
| Nintendo Switch 2 Pro Controller | UK used, sold | £47.08 | eBay UK item 257762800651, sold 26 Sep 2026, https://www.ebay.co.uk/itm/257762800651 |

eBay displayed totals can include Buyer Protection. The notes on each evidence row preserve the relevant caveat. The PathAu Switch 2 figure is an aggregate median from eBay UK completed sales, not a single listing. All active evidence is GBP and uses `uk_new` / `uk_used` separately, with `listed` / `sold` availability.

### Verified database snapshot — both TEST and LIVE
- Gaming category master products: **62**
- Active, customer-visible products: **54**
- Active evidence rows: **125** (17 `uk_new`, 108 `uk_used`)
- Active customer-visible products missing evidence: **0**
- Active evidence integrity failures (missing URL/key, non-positive price, non-GBP currency or missing availability): **0**
- Products with null branch assignment: **0**
- Nintendo products: **5**, each with at least one active evidence row
- The Nintendo product and evidence content matches between TEST and LIVE; UUIDs are intentionally environment-specific.

### Guardrails and next work
- Keep TEST and LIVE independent. Do not copy customer, tenant, transaction or payment data.
- Do not let market evidence change automatic valuation/buying prices.
- Keep bundle, storage, colour/edition and console generation variants distinct.
- Do not treat asking prices, hidden Best Offer amounts, trade-in quotes or overseas listings as completed UK used sales.
- Continue with Switch 2 Joy-Con 2 pairs, camera, charging grip, cases, microSD Express cards, original Switch Pro Controller/Joy-Con, Nintendo handheld generations (3DS/2DS), Wii and GameCube accessories. Then complete Xbox controllers/headsets/storage and remaining PlayStation accessories.
- `Nintendo Accessories` branch is prepared but has no products yet.
- No TradeFlow application code, valuation logic, RLS/grants, tenants, customer records, transactions or Stripe configuration changed in this batch.
- No structured project-memory/checkpoint tables were found in any non-system schema of the connected LIVE Supabase project. The verified continuity record is therefore maintained in the repository's `PROJECT-MEMORY/` and `CHECKPOINTS/` files; do not invent a Supabase memory table.

## Evidence QA correction — 2 November 2026
A second source-level audit was completed after opening the original marketplace pages. Two eBay observations were unsuitable as UK-local evidence: Switch V2 item 318506459251 had £50 international postage and a Berlin delivery destination; Switch Lite item 287545083895 was routed through eBay International Shipping to a non-UK destination. Both rows were retained but deactivated. They were replaced with exact UK Cash Converters used listings, both marked `availability=listed` rather than `sold`:
- Switch V2 32GB, dock and charger, tested, light wear and two small screen scratches: £110 at Loughborough, Cash Converters item 017900197278. Evidence key `cashconverters-switch-v2-017900197278-2026-11-02`.
- Switch Lite 32GB grey, general wear, missing left-stick thumb rubber, unit only/no charger: £84.99 at Jarrow, Cash Converters item 048800234693. Evidence key `cashconverters-switch-lite-048800234693-2026-11-02`.
The Switch 2 Pro Controller completed-sale price was corrected from the stale £47.08 capture to the opened eBay UK sold-page total of **£56.97**, including the £2.52 Buyer Protection fee (item 257762800651; key `ebay-257762800651`). The OLED sold observation at £145 was checked and confirmed. The Switch 2 £309 used figure remains an aggregate PathAu median of 153 eBay UK sales, not an individual item sale.

The corrected TEST and LIVE snapshots remain identical: 62 master products, 54 active customer-visible products, 125 active evidence rows (17 UK new / 108 UK used), zero visible active products without evidence, zero evidence integrity failures and zero unassigned branches. The active evidence count is unchanged because two unsuitable rows were deactivated and two exact UK retailer listings were inserted. These corrections supersede the earlier Switch V2 £62.99, Switch Lite £72.00 and Switch 2 Pro Controller £47.08 figures above.

## Nintendo accessory batch 2 — 2 November 2026
Added three further visible Nintendo master products independently to TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Pair — official Nintendo Store UK listed £74.99; new-condition eBay UK sale £63.22 (item 188848813395, London seller, includes £2.72 Buyer Protection). New evidence only; this eBay sale was explicitly new condition.
- Nintendo Switch Pro Controller (original Switch generation) — Currys UK new listing £49.97; used eBay UK sale £41.94 (item 147630967217, Birmingham seller, includes £2.03 Buyer Protection).
- Nintendo Switch 2 Camera — Cash Converters UK pre-owned listing £19.99 (Kilburn store, pre-owned, fully functional).
The Switch 2 Pro Controller remains a separate product from the original Switch Pro Controller. The Joy-Con 2 pair remains separate from single L/R replacement Joy-Cons. Current verified category totals in both environments: **65 master products, 57 active customer-visible products, 130 active evidence rows (20 UK new / 110 UK used), zero visible active products missing evidence, zero evidence integrity failures**. Exact TEST/LIVE IDs and source keys are recorded in the project memory and batch checkpoint. No code or valuation logic changed.

## Switch 2 retail evidence source correction — 2 November 2026
The Smyths Toys product URL could not be independently fetched (403), so its £389.99 evidence row was deactivated. The generic Harvey Norman capture remains inactive. The active UK-new source is now the directly opened Argos product page for Nintendo Switch 2 Console - Black, 256GB, at **£419.99**: https://www.argos.co.uk/product/7624867. The Argos page confirms the console model, 256GB storage and included Joy-Con 2 pair, dock, grip, AC adapter and HDMI cable. Active evidence key: `argos-switch2-7624867-2026-11-02`. LIVE evidence ID: `b8541ee9-fcdc-4a46-98c0-6a8242d4b099`; TEST evidence ID: `2f7f9991-2941-4760-abcf-898588eb1c35`. This supersedes the earlier £389.99 Smyths figure. Category totals remain 65 master products, 57 active customer-visible products, 130 active evidence rows (20 UK new / 110 UK used), zero visible products missing evidence and zero integrity failures.

## Nintendo Switch 2 accessory batch 3 — 2 November 2026
Added four independently keyed visible master products in TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Charging Grip — Argos UK new listing £29.99; used eBay UK completed sale £15.96 (item 128034280257, Billingham UK; buyer-facing total includes £0.96 Buyer Protection).
- Nintendo Switch 2 Carrying Case & Screen Protector — Argos UK new listing £19.99; official case and film protector bundle, up to six game cards and two Joy-Con 2 straps.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2 — Argos UK new listing £44.99. This is microSD Express; ordinary microSD is not a substitute for Switch 2 expanded game storage.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair — Argos UK new listing £16.99; two magnetic wheel adapters, controllers not included.
Argos exact product URLs and stable keys are in the batch checkpoint. The Charging Grip used sale is recorded separately from the Argos new listing. Other three products currently have verified new retail evidence only; no used-price estimate was invented.

## Nintendo 3DS family handheld batch 4 — 2 November 2026
Added three independently keyed visible Nintendo handheld products, each with a current UK used retailer listing:
- Nintendo 3DS XL — £149.99, Cash Converters UK St Helens, white, tested/working, light wear, charger included, stylus missing.
- New Nintendo 3DS XL — £200.00, Cash Converters UK Worksop, red, good condition, charger included, factory reset.
- New Nintendo 2DS XL — £169.99, Cash Converters UK Chesterfield, black, good condition, charger included, fully working.
These are current UK used retailer asking/listing prices, not completed sales. They are classified as `uk_used` with availability `listed`. New Nintendo 3DS XL is kept distinct from original Nintendo 3DS XL and New Nintendo 2DS XL. Special editions/bundles should remain separate when later imported.

## Updated verification — TEST and LIVE independently
- Gaming master products: **72**
- Active customer-visible products: **64**
- Active evidence: **138** (24 `uk_new`, 114 `uk_used`)
- Active visible products missing evidence: **0**
- Active evidence integrity failures: **0**
- Products with unassigned branch: **0** (checked in the pre-batch baseline; this batch inserts through the Nintendo handheld/accessory branches).
- TEST and LIVE have matching catalogue content/counts; UUIDs are environment-specific. No tenant, customer, transaction, payment or Stripe data was copied or changed.
- No application code or valuation logic changed. Evidence remains research reference only and must not be allowed to alter automatic buying prices.

## Next
Continue older Nintendo systems (standard 3DS, 2DS, DSi, Wii, Wii U, GameCube, N64, SNES) and accessories, then Xbox controllers/headsets/storage and PlayStation accessories. Check for model/edition/bundle duplicates before each insert. Do not use trade-in quotes as used market sales. Keep UK GBP evidence separate by new/used condition and listed/sold availability.

## Nintendo legacy handheld and home console batch 5 — 2 November 2026
Added five visible Nintendo master products independently in TEST and LIVE:
- Nintendo 2DS — UK used Cash Converters listing £49.99, black, light wear, charger included, fully working; Lancaster.
- Nintendo DSi XL — UK used Cash Converters listing £69.99, light cosmetic wear, charger included; Bethnal Green, London.
- Nintendo Wii — UK used Cash Converters listing £29.99, white, Wii Remote, sensor bar, AC adapter and AV cable, fully tested; Kings Heath, Birmingham.
- Nintendo Wii U — UK used Cash Converters listing £109.99, black 8GB, leads and main GamePad, unboxed, fully working; Dudley.
- Nintendo GameCube — UK used Cash Converters listing £85.49, black, controller, power lead and memory card, good condition; Birkenhead.
These are retailer asking/listing prices, not completed sales. All are classified `uk_used` and availability `listed`. A new `Nintendo Home Consoles` branch was added to keep Wii, Wii U and GameCube separate from Nintendo handheld consoles. The Wii U master record is family-level pending package-specific splits for 8GB/32GB editions and bundles; this batch's evidence is explicitly the 8GB package. No buyback/trade-in quotes were used.

## Updated verification — TEST and LIVE independently
- Gaming master products: **77**
- Active customer-visible products: **69**
- Active evidence: **143** (24 `uk_new`, 119 `uk_used`)
- Active visible products missing evidence: **0**
- Active evidence integrity failures: **0**
- TEST and LIVE product/evidence counts and catalogue content match; environment UUIDs remain separate.
- No tenant, customer, transaction, payment or Stripe data was copied or changed. No application code or valuation logic changed. Market evidence remains research reference only and must not affect automatic buying prices.

### Batch 5 exact IDs

LIVE:
- Nintendo 2DS product 800a5100-39cb-4ac2-85cb-b730a2fc2bd4; evidence 76d0f929-26eb-4519-a122-06c5e850d3af; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 01bdbb45-c7db-41ce-a4ba-fca827435c52; evidence 1187732e-f618-4fd4-8ea6-f3ca440aaf37; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 314ab322-1a35-48df-a1e8-d5ca7d667449; evidence 112584ec-bd67-4ba7-95bd-2f52d37b5a12; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product 7b832fe8-383f-4c63-806b-3c746bcf0648; evidence 1ff54f93-26eb-4eec-9222-0bbe466bc377; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product d2ce564c-1c54-48f6-9a94-67ab2a33feb3; evidence 955adebf-ded9-47a0-b673-cb6fd8dd5d78; key cashconverters-gamecube-015700300057-2026-11-02.

TEST:
- Nintendo 2DS product 6e65d675-ddf0-44c4-8b6f-ba6571ac0f7c; evidence 2cb6fec3-1469-4998-907d-e5e4e0b0d1e6; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 85c1ed19-64a9-44c2-b2a7-55024dd26550; evidence 5b67d4f3-566f-4664-ab1f-7ce4070d28da; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 65a8bf91-32e5-41be-9aca-97fe547a2f1d; evidence 19a89458-94ba-46d3-9817-436c450c8b2b; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product c5027e1f-1885-45db-b409-4f016c1bea42; evidence f863c536-d956-42a1-b8ab-c09c8569e07c; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product c03789fd-ca34-4ecd-941c-76a6e2008f6c; evidence 99794ab2-acdd-4956-923a-05935d5c6c94; key cashconverters-gamecube-015700300057-2026-11-02.

Next: complete standard Nintendo 3DS, DSi and older home hardware (N64/SNES), then Xbox controllers/headsets/storage and PlayStation accessories. Maintain package-specific variants and avoid treating trade-in values as used sale evidence.


## Final LIVE merge/deployment status — 3 November 2026
- LIVE PR #205 merged into `production` with merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`.
- TEST PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- LIVE and TEST database migrations applied and access-control read-back verified; each database has its own two page records.
- JavaScript syntax checks passed for owner dashboard, editor and renderer in LIVE; environment URL/key checks passed.
- Direct Worker URL checks for LIVE and TEST were inaccessible through the available browser tool. Cloudflare deployment commit/runtime and owner browser flow remain unverified. Do not state deployment is complete until the Worker version and browser flow are confirmed.
- The user confirmed simultaneous LIVE and TEST development. Continue keeping code behaviour aligned and content/data isolated.


## Platform-owner visual public page designer — 3 November 2026

The owner-facing Public Website Pages editor is being upgraded from the rejected nested text form to a visual, free-position canvas. The subscriber Website Builder remains unchanged and its locked baseline is not reopened.

- Owner can add text boxes, image boxes and screenshot boxes; select a box and edit its text, image, alt text, background, layout and numeric position/size; drag boxes directly on the canvas; resize with the corner handle; duplicate and delete boxes; and upload/replace/remove images.
- The page canvas stores its composition in `draft_content.visual_layout` JSONB within the existing `public.platform_public_pages` records. Existing draft/publish owner RPCs remain the persistence boundary. Published How It Works and Examples pages render the saved visual layout; homepage Examples preview continues to use its existing card renderer.
- Original embedded How It Works screenshots remain the public fallback when a screenshot box has no uploaded replacement.
- New public bucket `platform-public-media` accepts PNG/JPEG/WebP up to 8 MB. Storage insert/update/delete policies require an authenticated user with an active `platform_memberships` row and restrict object paths to that user's UUID. Public read is via the public bucket. Existing subscriber bucket/policies are not weakened.
- TEST project `nnsshnfkjcflucjrftzi` and LIVE project `gxsrajtqzdjvmceqcpgv` each received migration `20261103210000_platform_public_media_owner_uploads`. No page content was copied between environments.
- Feature branches: `feature/platform-public-visual-builder-test-20261103` and `feature/platform-public-visual-builder-live-20261103`. PRs and Cloudflare deployment/browser acceptance remain pending. JavaScript syntax was checked in the connector runtime for the visual editor and public renderer in both branches. Database bucket and three owner-only write policies were read back in both projects.
- Known acceptance still required: open owner dashboard in both environments; test drag, resize, add/delete/duplicate, upload, save, draft preview, publish, mobile rendering, and verify original screenshots remain until replaced. A GitHub merge is not proof of Cloudflare deployment.


## Merge status — 3 November 2026
- LIVE PR #206 merged into `production` at `d08f4f156452d066cd39dad7943f8e39e38985d1`.
- TEST PR #207 merged into `cloudflare-test` at `04989110d3fd49ab0bcf152e34819cc38193ac5d`.
- Both branch heads were read back at their merge commits. GitHub reports no commit statuses and zero Actions workflow runs for either head. The Worker dashboard URLs could not be opened through the available browser check. Cloudflare deployment and browser acceptance therefore remain unverified; do not tell the user the feature is live until that is checked.


Final editor refinement: free-position text/image/screenshot boxes are independently draggable and resizable on the canvas (x/y/width/height are also editable in the inspector). Full-width image boxes are rendered as images rather than hidden, and the owner canvas stacks split layouts on narrow screens. TEST visual editor URL/key were checked against TEST's own existing owner editor configuration; LIVE remains on LIVE Supabase. These refinements are included in the merged branches.


## Independent text and media boxes; unnumbered page copy — 4 November 2026
The owner visual page editor now creates text-only boxes and image/screenshot-only boxes. They are independent objects with separate drag, resize, x/y/width/height controls; text boxes no longer contain empty image columns, and media boxes no longer carry heading/body fields. Existing screenshot captions/titles are imported as their own text boxes next to independent media boxes. Public rendering follows the same independent object model. Automatic sequence labels (01/02/03), ordered-list markers and leading PART/step number prefixes are removed from How It Works copy. This is a presentation/editor change only: no Supabase schema, public page data, subscriber builder, tenant/customer records, or LIVE/TEST content was migrated or copied.

## Duplicate public-page copy correction — 4 November 2026
The owner visual editor's first-time layout conversion previously imported the comparison heading/paragraph and then imported the first screenshot's identical heading/paragraph again, creating two text boxes above the same screenshot. `platform-public-pages-visual-editor.js` now de-duplicates text blocks by normalized heading while retaining the screenshot box. The conversion also strips leading numeric/Part/Step prefixes before creating text blocks. This does not split a heading from its paragraph: each text box remains one independently movable text element containing its optional heading and body, while image/screenshot boxes remain separate independent elements. No saved `visual_layout` existed in either environment at the time of diagnosis; legacy `draft_content` remains unchanged until the owner saves a draft. No database schema, published content, tenant/customer data, or subscriber Website Builder code is changed.


## Gaming catalogue continuation — 4 November 2026
A further PlayStation UK-new evidence batch was added and independently verified in TEST and LIVE for existing master products:
- DualSense Charging Station — PlayStation UK £24.99, listed, official product page https://www.playstation.com/en-gb/accessories/dualsense-charging-station/.
- PlayStation Portal Remote Player — Currys UK £219.00, listed, exact product page https://www.currys.co.uk/products/sony-playstation-portal-remote-player-10257483.html.
- PlayStation VR2 — Smyths Toys UK £399.99, listed/in stock, exact product page https://www.smythstoys.com/uk/en-gb/gaming-and-tech/virtual-reality/playstation-vr2/playstation-vr2-headsets/playstation-vr2/p/225323.
All are UK GBP retailer new/listed observations, not completed sales. Evidence is reference-only and must not alter automatic buying valuations. TEST and LIVE use their own product/evidence UUIDs; no tenant, customer, transaction, domain, Stripe, subscription, code or Worker deployment data changed.

Verified 4 November database snapshot in both environments: 113 Gaming Consoles & Accessories master products; 184 active evidence rows (59 UK new / 125 UK used); zero malformed active evidence rows under the current URL/key/GBP/positive-price/availability checks. One active customer-visible product remains without evidence: WD_BLACK C50 512GB Expansion Card for Xbox Series X|S. Keep it visible but do not invent a price; add evidence only when an exact UK listing is independently verified.


## Nintendo DS handheld completion — 4 November 2026
The master catalogue now includes Nintendo 3DS, Nintendo DSi, Nintendo DS Lite and original Nintendo DS as distinct active, customer-visible products in the existing Nintendo Handheld Consoles branch. Each has one exact Cash Converters UK used/listed GBP evidence record. TEST and LIVE were populated independently with environment-specific UUIDs. Verification in both environments: 117 active gaming master products, 109 active customer-visible products, 188 active evidence rows (59 UK new / 129 UK used), and zero malformed active evidence rows. Retail asking prices are not completed sales and evidence remains reference-only; do not alter automatic valuation logic.

## Public How It Works navigation correction — 4 November 2026
The LIVE homepage navigation and hero "See how it works" link must route to `how-it-works.html`, not the legacy `#how` workflow preview section. The updated accordion page is source-managed in `how-it-works.html` / `how-it-works.css`. TEST already used the correct destination; LIVE was corrected in PR #218 (merge `69ac4df6c171a767daee30777a576ad27a93c3ac`). Verify the actual Cloudflare Worker deployment and browser route separately; Git merge is not deployment proof. No database, tenant, customer, payment or subscription data was changed.


## Nintendo Switch V1 and Game Boy Advance SP batch — 4 November 2026
Two distinct Nintendo master products were added independently to TEST and LIVE: Nintendo Switch (V1), model HAC-001 (not HAC-001(-01)), and Nintendo Game Boy Advance SP. Each has one exact Cash Converters UK used/listed GBP evidence row. TEST and LIVE each now verify at 119 active gaming master products, 111 active customer-visible products and 190 active evidence rows (59 UK new / 131 UK used), with zero malformed active evidence rows. These are retailer asking prices, not completed-sale prices. No valuation logic, tenant/customer/transaction/domain/Stripe/subscription data, application code or Worker deployment was changed.

## Original Nintendo Game Boy Advance addition — 4 November 2026
Added Nintendo Game Boy Advance as a distinct active, customer-visible handheld product with two exact Cash Converters UK used/listed GBP evidence rows (£59.99 and £69.99). It remains distinct from the Game Boy Advance SP and Game Boy Micro. TEST and LIVE now each verify 120 active gaming master products, 112 active customer-visible products and 192 active evidence rows (59 UK new / 133 UK used), with zero malformed active evidence rows. Prices are retailer asking prices, not completed sales. No valuation logic, tenant/customer/transaction/domain/Stripe/subscription data, application code or Worker deployment changed.

## Sega Mega Drive catalogue addition — 4 November 2026
Added Sega as a manufacturer, a Sega Home Consoles branch and an active, customer-visible Sega Mega Drive master product independently in TEST and LIVE. One exact Cash Converters UK used/listed GBP evidence row was attached at £39.99; the listing specifies two controllers and a power supply. Keep this original hardware separate from Mega Drive Mini and third-party AtGames systems. Both environments verify 121 active gaming master products, 113 active customer-visible products and 193 active evidence rows, with zero malformed active evidence rows. Retail asking price, not completed sale. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, application code or Worker deployment changed.

## Sega Master System II catalogue addition — 4 November 2026
Added Sega Master System II as a separate active, customer-visible home-console product in TEST and LIVE, using the existing Sega manufacturer and Sega Home Consoles branch. One Cash Converters UK used/listed GBP evidence row was attached at £60.00. The listing describes the built-in Sonic variant, unboxed, with controller and cables, fully tested and working. TEST and LIVE now each verify 122 active gaming master products, 114 active customer-visible products and 194 active evidence rows (59 UK new / 135 UK used), with zero malformed active evidence rows. Asking price, not completed sale. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Game Boy Micro and Atari 2600 catalogue batch — 4 November 2026
Added Nintendo Game Boy Micro and Atari 2600 independently in TEST and LIVE, with separate environment-specific product/evidence UUIDs. Game Boy Micro has one Cash Converters UK used/listed GBP row at £109.99 (blue, USB charging cable and storage case, described as fully working). Atari 2600 has two UK used/listed eBay UK rows: £26.69 for a 6-switch Woody console-only listing described as seemingly working, and £98.00 for a 6-switch Woody bundle with paddles and two games, joystick and paddles tested. Price/description for these eBay records were surfaced by a UK second-hand listings aggregator; verify the source listings before reusing. Atari manufacturer and Atari Home Consoles branch are present in both environments. TEST and LIVE each verify 124 active gaming master products, 116 active customer-visible products and 197 active evidence rows (59 UK new / 138 UK used), with zero malformed active evidence rows. All prices are asking prices, not completed sales. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, application code or Worker deployment changed.

## Sega Saturn and Sega Dreamcast catalogue additions — 4 November 2026
TEST and LIVE were independently updated after duplicate checks in the Sega Home Consoles branch. Added separate active, customer-visible master products for original Sega Saturn and Sega Dreamcast. Saturn evidence: Cash Converters UK item 058400033267, £249.99, boxed MK2 with controller, RF unit, power cable and six games, light cosmetic wear; https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/058400033267. Second Saturn reference: Cash Generator Runcorn, £159.99, pre-owned Grade C, tested working, boxed with leads and one controller; https://cashgenerator.co.uk/products/sega-saturn-console. Dreamcast evidence: Gumtree listing 1514986787, £153, boxed, GDEMU 5.15 ODE/128GB SD card, controller, RF adapter, power cable, manuals and Dreamarena disc; seller says fully working, yellowing noted; https://www.gumtree.com/p/sega/sega-dreamcast-console-boxed-gdemu-128gb-sd-recapped-fully-working/1514986787. All three are UK GBP used/listed asking-price references, not completed sales. Dreamcast's GDEMU modification belongs in listing-specific evidence, not as a separate base product.
TEST: Saturn product ab5fb2fb-383c-492a-a849-8db2df2fb2ec; Dreamcast product c3ad1eb0-afcd-46c6-8c53-340f9ef58ce9. LIVE: Saturn product 935196e8-8c99-4e29-8b65-005612fe08eb; Dreamcast product f5b404a3-bff2-4379-8896-7d74652185fa. TEST and LIVE each verify 126 active gaming products, 118 customer-visible, 200 active evidence rows (59 UK new / 141 UK used), zero malformed active evidence rows. No valuation logic, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed. Game Gear and Jaguar remain unadded pending stronger live, item-specific evidence.

## Sega Game Gear addition — 4 November 2026
Added original Sega Game Gear as a distinct active, customer-visible handheld product in TEST and LIVE, creating a separate Sega Handheld Consoles branch in each environment. Evidence: active Gumtree UK listing 1802252316, £72.00, boxed with Columns cartridge and original manual/guarantee card; seller explicitly states it requires a recap, so condition is recorded as Poor and it must not be represented as fully working. URL https://www.gumtree.com/p/other-games-consoles/sega-game-gear-handheld-console-with-original-box-and-game/1802252316. GBP used/listed asking price, not completed sale. TEST branch 5b1277f1-c6b7-4b80-b080-0c036c918a37, product 90a1c2ce-e1e4-490b-83bf-47039131875e. LIVE branch b4d2f5ad-8b0b-4fde-b285-de95d81a0001, product 8aebcc2c-2052-4c65-a1a9-33f5a8dc2dec. TEST evidence count independently verifies at 201 after the insert; previous common baseline was 126 active products / 118 visible / 200 evidence. Expected resulting counts in each environment: 127 active products, 119 visible, 201 evidence rows, zero malformed. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed. Atari Jaguar remains held back until item-specific condition evidence is available.

Final post-Game-Gear verification: TEST and LIVE each show 127 active gaming products and 119 customer-visible products. TEST has 201 active evidence rows; LIVE product counts match. Evidence composition is 59 UK new and 142 UK used/listed. The Game Gear row is GBP, positive-priced, URL/key-backed and listed; no malformed evidence was introduced.

## Atari Jaguar and further Game Gear evidence — 4 November 2026
Added original Atari Jaguar as an active, customer-visible product in TEST and LIVE after finding an item-specific eBay UK listing with eight photographs. Listing 278163215741: £345.00, boxed, seller states fully tested and working, excellent condition; https://www.ebay.co.uk/itm/278163215741. Separately added a second Game Gear evidence row to the existing Game Gear product: Gumtree listing 1803718755, £125, seller says fully working and recently recommissioned with replacement capacitors and upgraded USB-C power board; original box (without inner packaging) and manual included, no games or power source; https://www.gumtree.com/p/other-video-games/vintage-original-sega-game-gear.-fully-working./1803718755. Both are UK GBP used/listed asking prices, not completed sales.
TEST: Atari Jaguar product a083fb85-f884-4436-8041-a19210c37894, evidence b5914c65-6263-4948-9573-438ba3a773fd; Game Gear second evidence 26d993b8-f6f8-416f-9785-5b9d2e462b45. LIVE: Jaguar product a84a8826-473a-4716-9444-7e5d19af9880, evidence ade597e7-8112-4557-8fce-86ebf2ec3dd9; Game Gear second evidence faf347db-e227-4b8d-86d7-6fc4844bea04. TEST and LIVE independently verify 128 active gaming products, 120 customer-visible products and 203 active evidence rows (59 UK new / 144 UK used), zero malformed evidence. No valuation logic, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Atari 7800 and Atari Lynx catalogue additions — 4 November 2026
Added two distinct Atari products independently to TEST and LIVE after duplicate checks: original Atari 7800 home console and Atari Lynx colour handheld. Created an Atari Handheld Consoles branch separately in each environment. Atari 7800 evidence: Gumtree UK item 1803253658, £80, original boxed console in good condition with original power lead, two controllers and two cartridges (Xevious and Pole Position); https://www.gumtree.com/p/atari/atari-7800-console-retro-vintage-/1803253658. Atari Lynx evidence: eBay UK item 278351043451, £199.95, boxed and described as 100% complete, fully tested and working; seller notes good condition with possible yellowing/sticker damage; https://www.ebay.co.uk/itm/278351043451. Both are UK GBP used/listed asking prices, not completed sales. Keep original Atari 7800 distinct from 7800+ modern re-release and Atari Lynx distinct from Atari Blaze/Super Pocket devices.
TEST: Atari 7800 product a6c756ef-1375-4fc7-828d-e0bbb7d42286 / evidence aa4be156-7356-4d3c-835b-ae30ba5271ae; Atari Lynx product 8884b0ea-cb93-43e9-9827-fc6fadddc69c / evidence 69345f78-d17b-4944-bd38-1f4dc48dcc4f; Atari Handheld branch 9fd5d903-ad72-404c-b3a3-76143673f6ad. LIVE: Atari 7800 product 92f40a7c-0cd3-4436-bf18-ffd337db63ca / evidence 14c0cb0a-2aa8-4a13-9176-918f06d2aed7; Atari Lynx product 4d4516b0-5982-4b14-9549-d27d01b19a14 / evidence b67cb548-7ca7-4559-ab31-27cdde80c7ca; Atari Handheld branch d48bf813-8146-477d-b65b-15052d68713f. TEST and LIVE independently verify 130 active gaming products, 122 customer-visible products, 205 active evidence rows (59 UK new / 146 UK used), zero malformed active evidence. No valuation logic, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## Public pages and examples — 4 November 2026
Public navigation now uses the dedicated `how-it-works.html` route; About/Facts is removed from menus and legacy `facts.html` redirects to How It Works. Contact Us is `contact-us.html`. Examples use four image-led storefronts: Pokémon Charizard card, Sony Alpha 7 IV, DJI Mini 4 Pro and PlayStation 5, each with its own palette and category products. `platform-public-pages.js` remains the renderer and must preserve the owner editor `visual_layout` path. Plans copy matches signup at £59.99 monthly / £499.99 annually after 30 days; Stripe unchanged. No Supabase page records or business data changed. Contact details remain unpublished pending verification. See `CHECKPOINTS/2026-11-04-public-pages-examples-contact.md`; Cloudflare/browser verification remains outstanding.


## Sega Mega-CD Model 1, Mega-CD II and 32X additions — 4 November 2026
Added three distinct Sega console add-on master products independently to TEST and LIVE, under a new Sega Console Add-ons branch. These are add-ons, not standalone Mega Drive consoles, and must remain distinct from Mega Drive bundles and games.
Evidence (all UK GBP used/listed asking prices, not completed sales):
- Mega-CD Model 1 £361.09, item 358455592974, listing describes excellent condition, tested/working, official power supply; Mega Drive and game shown only for demonstration are not included. URL https://www.ebay.co.uk/itm/358455592974.
- Mega-CD II £250.30, item 407114465670, boxed; box scuffs/pen markings, inner packaging damage; includes Sega Classics, Sol-Feace and Cobra Command games. URL https://www.ebay.co.uk/itm/407114465670.
- Sega 32X £487.36, item 278107327310, unboxed PAL add-on, listing describes fully functional/tested and includes cable/adapter/extension components. URL https://www.ebay.co.uk/itm/278107327310.
The direct eBay pages returned cache misses; details/prices were surfaced through UK second-hand aggregator pages. Validate active status/details before reusing the evidence. TEST branch b4540868-3cd2-4bcb-9c1b-86b2c4cb336d; products Mega-CD Model 1 39775282-9963-4df1-871e-e3b737c24390, Mega-CD II 70529f25-6581-4bb5-8c72-d9474a806f0a, 32X b4fa74a5-a93d-41d9-8ce3-d1bb64eb77c8; evidence c3abacf1-1aa5-4bf0-a500-d0bc6ab5f5f4, 08662946-49b8-4374-9b56-fd6e7dba18ec, da301915-82c5-423b-981c-88d6bde14c6e. LIVE branch 1f6a60ce-04a0-4745-aa4a-3b4b7450a789; products Mega-CD Model 1 c80a5028-72bc-489a-9448-cae248821094, Mega-CD II 35b8f051-a966-4e3b-89dd-73c0f5379346, 32X 29efb7d0-6254-42da-a2f5-dff8e3a940c4; evidence 20001991-a35d-4928-b76e-458636e1ad9c, 2ade5d6c-d422-4e3e-9289-114ab248ea98, f797a632-3d6d-4f94-8118-3c7192e3d78a. TEST and LIVE product counts independently verify at 133 active / 125 visible. TEST evidence count 208, zero malformed. LIVE product counts match; its evidence verification query was attempted but returned a tool execution block, although all three insert calls returned their inserted evidence IDs. No valuation, tenant/customer/transaction/domain/Stripe/subscription data, code or Worker deployment changed.

## 3D printer catalogue continuation — 4 November 2026 (Batch 3)

The earlier 39-product / 47-evidence snapshot is superseded by this independently verified TEST and LIVE snapshot:

- Category: **3D Printers & Equipment**.
- Active branches: **3D Printers** and **3D Printer Equipment & Accessories**.
- Master products: **64** across six manufacturers.
- Active customer-visible products: **63**. One active Anycubic Kobra S1 ACE 2 Pro variant remains deliberately non-visible; do not expose it without confirming the package presentation.
- Active evidence: **77** (66 UK-new and 11 UK-used).
- Visible products missing active evidence: **0**.
- Visible products with null branch: **0**.
- Active evidence integrity failures (missing URL/key, non-GBP currency or non-positive price): **0**.
- TEST and LIVE counts match exactly after reconciliation.

This batch added/expanded Bambu Lab package variants, 11 Creality models/packages (K2, K2 Pro, K2 Plus, K2 SE, K1 Max, Ender-3 V3 SE and Ender-5 Max) and current Anycubic UK evidence for Kobra 3 Max V2, Kobra S1/S1 Max and Photon Mono/P1 resin models. Package variants remain separate records. Standard printers must not inherit combo pricing.

Eleven duplicate Anycubic evidence captures (same product, source URL, price and evidence type) were deactivated in each environment. The canonical evidence rows remain active; duplicate rows and their notes are retained for audit. The Kobra S1 ACE 2 Pro £409 evidence is present in both environments.

Some Anycubic pages displayed prices while the product was marked sold out. Their evidence notes explicitly state this and must not be interpreted as an in-stock claim. Retail asking prices are listed evidence, not completed sales. All used evidence remains reference-only and must never change automatic buying valuations.

Full environment-specific IDs, sources and duplicate cleanup are recorded in:
- PROJECT-MEMORY/2026-11-04-3d-printer-catalogue-batch-03.md
- CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-03.md

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only master catalogue and evidence rows were changed separately in TEST and LIVE.


## QIDI current-model catalogue — 4 November 2026 (Batch 4)

QIDI has been added as the seventh manufacturer in the 3D Printers & Equipment category. TEST and LIVE independently contain eight QIDI product/package records: Q2C standard and QIDI BOX Combo; Q2 standard and QIDI BOX Combo; Plus5 standard and QIDI BOX Combo; Max4 standard and QIDI BOX Combo. Eight UK GBP new-price evidence rows were added in each environment.

Current independently verified TEST/LIVE snapshot:
- 72 master products; 72 active customer-visible.
- 85 active evidence rows (74 UK-new / 11 UK-used).
- 0 visible products missing active evidence; 0 missing branch assignments; 0 evidence integrity failures.
- Seven manufacturers represented.
- TEST and LIVE counts match.

QIDI standard printer and QIDI BOX package prices are separate. The Q2 Combo price is recorded from a UK comparison page that identifies the QIDI direct-store price; the source is named accordingly. Other prices are from QIDI UK Store pages. Combo prices must not be merged into standard printer records. No legacy QIDI models have been added in this batch; Plus4, Q1 Pro and X-Max 3 require separate lifecycle/used-market verification before adding.

Full QIDI product/evidence UUIDs and sources are recorded in:
- PROJECT-MEMORY/2026-11-04-3d-printer-catalogue-batch-04.md
- CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-04.md

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only manufacturer, product and evidence rows were changed separately in TEST and LIVE.


### QIDI Plus4 legacy model — 4 November 2026
Added the discontinued QIDI Plus4 as a separate legacy standard-printer record in TEST and LIVE, with one UK-local used-market completed-sale evidence record. eBay UK item 318168687789 showed two sold and out of stock at £381.75; seller located Shepperton, UK; seller described the unit as fully working after a repaired filament-sensor fault and fully tested. Displayed total includes £11.75 Buyer Protection, not seller proceeds. TEST product cb84e14e-25bc-48a7-a8cf-60cc956555d3 / evidence 7350ce29-1fc4-46c9-b024-49b52d44ae1f. LIVE product 11969e89-e139-40b9-bd53-5c8a6f8623c8 / evidence f35eb1b7-c715-46d5-8b68-a73766c527f3. The model is retained for used-market matching; it is discontinued and replaced by Plus5. This supersedes the Batch 4 snapshot: both environments now have 73 products, 73 visible, 86 active evidence (74 UK-new / 12 UK-used), zero visible products missing evidence/branch and zero integrity failures.


## Sega Mega Drive II and original Master System Model 1 — 4 November 2026
Added two distinct Sega home-console master products independently in TEST and LIVE after checking the existing Sega product catalogue for duplicates: Sega Mega Drive II and original Sega Master System (Model 1 / Mark I). Reused the existing Sega Home Consoles branch and Sega manufacturer in each environment. Do not merge Mega Drive II with the existing original Mega Drive product or Master System Model 1 with Master System II.
UK GBP used/listed asking-price evidence (not completed sales): Mega Drive II Cash Converters item 057000067593 £129.99, fully functioning, boxed with two controllers, manuals and Mega Games 1; item 054200288249 £49.99, black unit, fully functional with controllers and power/AV leads. URLs https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/057000067593 and https://www.cashconverters.co.uk/shop/gaming/consoles--equipment/gaming-consoles/sega-console/054200288249. Original Master System Model 1 eBay item 800307959836 £71.67, model 3005-05-B, AC adaptor, RF cable and Hang-On; seller describes it as tested and working. Price/details from UK second-hand aggregator; direct eBay page cache miss. URL https://www.ebay.co.uk/itm/800307959836.
TEST products: Mega Drive II 7886fa8c-f980-4227-9683-c31b4504c32a; Master System Model 1 29681c32-645d-4d26-a8f8-7c4b3329317d. Evidence: Mega Drive II 56f37aa3-6178-4d62-904e-2b72d94a19cb and bdb5ac16-3766-4cc7-8f88-0aa7419938f8; Master System I e91d68e3-567e-4706-8c92-44d595c74f6c. LIVE products: Mega Drive II 1c1b8b6f-f8f0-406e-b922-a69617341ee1; Master System Model 1 3ebdebbd-f806-4cfd-9c3b-3d8b77b0c33b. Evidence: Mega Drive II 01cbb214-7409-49e4-8863-db2e914a9a7e and 110545ed-3310-4eee-b70f-c0ed524b9bfb; Master System I b9cc0561-56cb-44d0-b842-fc78bb956a17. TEST and LIVE independently verify 135 active gaming products, 127 customer-visible, 211 active evidence rows (59 UK new / 152 UK used), zero malformed active evidence. Evidence is market reference only and does not affect automated valuations. No customer/tenant/transaction/domain/Stripe/subscription data, valuation logic, code or Worker deployment changed.

## Gaming console catalogue continuation — 4 November 2026

Added four distinct Sega hardware models independently to TEST and LIVE, each with one UK used-market asking-price evidence row. Products are customer-visible and active. These are reference asking prices, not completed-sale prices, and do not feed automated valuation calculations.

- Sega Mega Drive Mini — £59.99, eBay UK item 168787663741; listing says working, two controllers and built-in games. TEST product 7ec390dd-a038-4003-9f42-4211c9ccbc18, evidence 26e6e274-e642-431b-b0e2-8a97d5251164. LIVE product f9362cb3-6af7-48f5-a34e-4d8950c201de, evidence b0c8a9a9-9b08-439a-8511-45d2cc65a53f.
- Sega Mega Drive Mini 2 — £207.25, eBay UK item 137442379300; opened-never-used listing with two controllers. TEST product f085602d-17a9-4fc8-b642-83a142f5129b, evidence 2fc9b0c1-89a5-4fb0-9256-41d821f84ef1. LIVE product e6ec4039-b8aa-4f12-8efc-b954ac27805b, evidence 47f2cdb6-bce1-47fa-b9bf-c5eff74ecff6.
- Sega Genesis Nomad — £432.58, eBay UK item 147647456905; separate Sega cartridge-compatible handheld, not a Game Gear variant. TEST product d5f27b54-32c9-43a3-8654-cd86923fe4a2, evidence ed0a8740-09a5-49a3-8654-cd86923fe4a2. LIVE product c905d7e6-17dd-4e90-a3bc-57bf59f09497, evidence 98cb4304-9b31-4e90-a3bc-57bf59f09497.
- Sega Multi-Mega — £839.25, eBay UK item 318173017652; seller describes tested and working combined Mega Drive/Mega-CD hardware. TEST product df324bbb-4786-4412-b451-6c4af7c35af1, evidence 131a0959-3df6-44a8-b537-f49857d92f0c. LIVE product ac613d4f-453b-4a65-8f60-0966d3b81ee7, evidence afb57889-5e2b-4478-abdf-8e289a682806.

Both databases independently verified: 139 active gaming products, 131 customer-visible products, 215 active UK evidence rows (59 UK new, 156 UK used), zero malformed active evidence rows. The TEST and LIVE records have separate UUIDs. No tenant/customer/transaction/payment/Stripe data, valuation rules, application code or Worker deployments were changed. The first product-insert statement created product records; evidence was then inserted in a separate statement because PostgreSQL data-modifying CTEs share a statement snapshot and the subsequent base-table join cannot see rows inserted by a sibling CTE in that same statement. Both stages were completed and verified.


## Gaming catalogue checkpoint — 4 November 2026
Four Sega models were added to both environments: Mega Drive Mini (£59.99, eBay 168787663741), Mega Drive Mini 2 (£207.25, eBay 137442379300), Genesis Nomad handheld (£432.58, eBay 147647456905), and Multi-Mega combined Mega Drive/Mega-CD (£839.25, eBay 318173017652). All are UK used-market asking-price evidence, not completed sales; they do not affect automated valuations. TEST and LIVE each independently verify 139 active products, 131 customer-visible products, 215 active evidence rows (59 new / 156 used), and zero malformed evidence. Product and evidence UUIDs plus source details are recorded in `docs/checkpoints/TRADEFLOW_GAMING_CONSOLE_CATALOGUE_20261104.md`. No tenant/customer/payment/Stripe data, valuation logic, application code or Worker deployment changed.


## Examples cache correction — 4 November 2026
When updating public Examples, change both the database-driven renderer and the static fallback markup in `index.html` and `examples.html`. Always bump the script and stylesheet query versions when changing these assets (`platform-public-pages.js?v=2`, `platform.css?v=17` for this correction); otherwise cached old examples may remain visible even after source merge. Ensure header/footer visible labels say Contact Us, not About/Facts. The four static and dynamic storefronts are Card Vault (Pokémon Charizard card), Shutter House (Sony Alpha 7 IV), Altitude Drones (DJI Mini 4 Pro), and Next Level Gaming (PlayStation 5). PR #226 merged LIVE (`8690c5b8`); PR #227 merged TEST (`d40735bf`). Source checked in both branches; Cloudflare deployment and browser check are still required.


## Additional Sega historical systems — 4 November 2026
Added Sega SG-1000 (£449.00, UK eBay item 168355445875), Sega Mark III (£173.80, eBay UK item 318928337003; seller based in Japan, international delivery/import terms to be checked), and Sega Pico (£155.58, UK eBay item 307149542948) independently to TEST and LIVE. SG-1000, Mark III and Pico remain separate models; Pico is an edutainment system, not a standard Master System bundle. Their UUIDs and source details are in `docs/checkpoints/TRADEFLOW_GAMING_CONSOLE_CATALOGUE_20261104.md`. Latest independent TEST/LIVE verification: 142 active gaming products, 134 customer-visible, 221 active evidence rows (59 new / 162 used), zero malformed. Evidence remains UK GBP asking-price reference only, with no impact on automated valuations. No customer/tenant/payment/Stripe data, valuation logic, application code or Worker deployment changed.


### 3D printer catalogue expansion — Batch 5 — 5 November 2026

Expanded the existing 3D Printers branch independently in TEST and LIVE. Added nine ELEGOO models (Neptune 4, Neptune 4 Pro, Neptune 4 Plus, Neptune 4 Max, Mars 5, Mars 5 Ultra, Saturn 4, Jupiter 2 and OrangeStorm Giga) plus the discontinued QIDI X-Max 3 legacy model. Added nine UK-new GBP retailer observations and one UK-used completed-sale observation. Printer-only variants remain separate from wash/cure and other accessory bundles. OrangeStorm Giga is recorded as pre-order, not in-stock. QIDI X-Max 3 is marked discontinued according to QIDI UK.

Verified independently after both writes: 128 active customer-visible products in each environment; 141 active evidence rows (126 uk_new / 15 uk_used); zero visible products missing evidence or branch; zero duplicate active source_record_key groups; zero missing evidence URLs/keys, invalid prices, non-GBP prices or uk_new condition mismatches. The twelve manufacturers and their product counts are: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3 and Ultimaker 8.

The QIDI X-Max 3 UK eBay sale is £361.42, sold 30 July 2026 (item 406940086609); the displayed total includes £11.42 Buyer Protection and is not seller proceeds. Nine ELEGOO UK retail observations are £169, £189, £279, £377, £154, £231, £299, £699 and £2,049 respectively; exact product URLs and evidence IDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-05.md.

No new category or branch was created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. This was database-only catalogue and evidence work; no Worker deployment was required. TEST and LIVE use environment-specific manufacturer, product and evidence UUIDs. Continue TEST-first, then mirror to LIVE, and never infer used values from new retail prices.


### FLSUN 3D printer expansion — Batch 6 — 5 November 2026

Added FLSUN as a new active manufacturer and added four standard FDM printer models independently in TEST and LIVE: S1, T1, S1 Pro and T1-PRO. Each model has one UK GBP new-market evidence row with its observed stock state preserved: S1 £499 in stock at 3D Prima; T1 £500 backordered at 123-3D; S1 Pro £1,299 out of stock at the FLSUN UK Store; T1-PRO £509 out of stock at the FLSUN UK Store. Do not present the backordered or out-of-stock items as available now.

Post-write verification matches independently in TEST and LIVE: 132 active customer-visible products; 145 active evidence rows (130 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP rows or uk_new condition mismatches. FLSUN has four active products. Exact UUID mapping and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-06.md.

No new category or branch was created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work; no Worker deployment required. Preserve the stock-state notes and do not infer used prices from retail asking prices.


### FLSUN evidence freshness correction — 5 November 2026

Final source review found that the official FLSUN UK Store S1 Pro and T1-PRO pages were last crawled about five months before this review. Their £1,299 and £509 observations are retained as historical price references only: observed_at is NULL, availability is “Historical listing; current availability unconfirmed”, and their source keys are marked historical. Do not present either as a current available offer. The S1 Pro direct page could not be fetched during review.

A newer UK T1-PRO retailer observation was added separately: 3DShop UK £365.00, marked in stock and ready for dispatch (page last crawled about four weeks before review), https://3dshop.uk/shop/flsun-t1pro/. TEST evidence UUID b7fb29b9-4d1c-4928-9f10-b9cb90dbf862; LIVE evidence UUID a35fd5f9-72ad-4314-9230-b01a08756517. The older FLSUN UK £509 record remains historical and is not merged with the 3DShop offer.

Latest independent TEST/LIVE snapshot supersedes the earlier Batch 6 total: 132 active customer-visible products; 146 active evidence rows (131 uk_new / 15 uk_used); zero missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, invalid prices, non-GBP evidence or uk_new condition mismatches.


### ELEGOO resin printer catalogue expansion — Batch 7 — 5 November 2026

Added four previously missing ELEGOO resin printer models independently in TEST and LIVE: Mars 4, Mars 4 Ultra, Saturn 3 and Saturn 3 Ultra. Each has one active UK-new GBP price observation. Mars 4 £149 and Mars 4 Ultra £189 are from their official UK product pages. Saturn 3 £214 and Saturn 3 Ultra £239 are from the ELEGOO UK Saturn Series collection's latest indexed capture (about one month before review); stock is unconfirmed and those two prices must be rechecked before valuation or customer quotation. Printer-only prices; wash/cure bundles excluded.

Independent TEST/LIVE verification after Batch 7: 136 active customer-visible products; 150 active evidence rows (135 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Exact environment-specific product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-07.md.

No category or branch created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work; no Worker deployment required.


### 3D printer catalogue expansion — Batch 8 — 5 November 2026

Added two verified ELEGOO printer-only models independently in TEST and LIVE:
- Neptune 3 Pro — £127.00 UK new, ELEGOO UK. The official UK product page identifies the exact model and FDM specification, offers the standard new printer option and lists the UK delivery guidance for in-stock goods. Source: https://uk.elegoo.com/collections/elegoo-products-dc/products/elegoo-neptune-3-pro-fdm-3d-printer-225x225x280mm
- Saturn 2 (8K) — £350.00 UK new, 123-3D UK. Exact 8K model and SKU DKI00121; retailer explicitly says backordered/available to order with estimated 10–14 days, so do not describe as in stock. Source: https://www.123-3d.co.uk/collections/3d-printers/products/elegoo-saturn-2-8k-3d-printer

Neptune 3 Plus was not added because the official UK page is sold out. Neptune 3 Max was not added as a new-price item because only sold-out/new and pre-owned listings were found. Mars 3 Pro was not added because current UK retailer evidence is not dependable enough to treat as an available new offer; other retailer pages show sold out. No unsupported legacy models or bundles were introduced.

Post-insert independent category-scoped verification in both TEST and LIVE: 138 active and customer-visible 3D printer products; 152 active evidence rows (137 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Counts are for the 3D Printers category only, not the entire master catalogue.

Exact Batch 8 product/evidence UUIDs are recorded in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-08.md. TEST and LIVE use independent environment-specific UUIDs. UK GBP only; printer-only variants kept separate from bundles; used evidence remains reference-only and must not affect automatic valuation. Database-only change: no schema, code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. No Worker deployment required.


### 3D printer catalogue expansion — Batch 9 — 5 November 2026

Expanded Flashforge in TEST and LIVE with three verified printer-only models:
- Creator 5 — £719.00 UK new; official Flashforge UK page shows In Stock and advertises a £100 automatic cart discount. Source: https://uk.flashforge.com/products/flashforge-creator-5
- Creator 5 Pro — £849.00 UK new; official Flashforge UK page shows In Stock and advertises a £100 automatic cart discount. Source: https://uk.flashforge.com/products/flashforge-creator-5-pro
- Guider 3 Ultra — £2,999.00 UK new; official Flashforge UK page states shipment direct from China warehouse, shipping in 30 days. It is not represented as UK-stocked. Source: https://uk.flashforge.com/products/guider-3-ultra-3d-printer

Creator 5 and Creator 5 Pro are separate models, not package variants; the Pro includes an enclosed frame, active heated chamber and HEPA/carbon filtration. Guider 3 Ultra is a large-format dual-extruder CoreXY model. Advertised list prices were recorded; Creator 5 and Creator 5 Pro product pages separately advertise £100 automatically applied at checkout, so verify checkout price before quoting.

Post-insert independent category-scoped verification in both TEST and LIVE: 141 active customer-visible 3D printer products; 155 active evidence rows (140 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Counts are for the 3D Printers category only.

Exact Batch 9 product/evidence UUIDs are recorded in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-09.md. TEST and LIVE use independent environment-specific UUIDs. UK GBP only; used evidence remains reference-only and must not affect automatic valuation. Database-only change; no Worker deployment required.


### 3D printer catalogue expansion — Batch 10 — 5 November 2026 (corrected final state)

Expanded Prusa Research and Flashforge in TEST and LIVE. A final current-source cross-check was performed before locking the checkpoint.

New printer-only models:
- Prusa CORE One+ (Gen 2) — £909.00 advertised from-price, Fabinity UK; in stock, two purchase options, so confirm assembly/configuration before quotation. Source: https://www.fabinity.com/brands/prusa
- Prusa CORE One L+ — £1,829.00, Fabinity UK; in stock. Source: https://www.fabinity.com/brands/prusa
- Prusa XL+ Single-Tool — £2,099.00, Fabinity UK; ships in 4–5 weeks. Source: https://www.fabinity.com/brands/prusa
- Flashforge CJ270 — £3,499.00, official Flashforge UK. The product page still carries pre-order timeline language (first 100 units scheduled to ship 15 October, later orders in purchase order); current fulfilment is not independently confirmed. Record as listed with availability caveat, not as confirmed in-stock. Source: https://uk.flashforge.com/products/flashforge-cj270

Current Flashforge collection snapshot confirms AD5X £299, Adventurer 5M £209 and Adventurer 5M Pro £339. These match the prior 4 November evidence already stored for those models. An intermediate Batch 10 observation from an older cached collection page showed £359/£259/£399; those three evidence rows were deactivated and retained as historical only, not used as current prices. Latest collection source: https://uk.flashforge.com/collections/3d-printers

Post-correction independent category-scoped verification in both TEST and LIVE: 145 active customer-visible 3D printer products; 159 active evidence rows (144 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. TEST and LIVE counts match exactly.

Exact environment-specific product/evidence UUIDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-10.md. All active evidence is UK GBP, New and source-linked. Printer-only models remain separate from kits/accessories; used evidence remains reference-only and must not affect automatic valuation. Database-only catalogue/evidence change; no schema, application code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. No Worker deployment required.


### 3D printer catalogue update — Batch 12 — 5 November 2026
Creality Ender-3 V3 Neo (£199; standard option marked in stock) and Ender-3 V3 Mega (£519; dispatch timing not confirmed) were added to TEST and LIVE with UK GBP new-price evidence. Standard printer records exclude optional Neo Combo/CFS nano packages. Sources: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer and https://store.creality.com/uk/collections/ender-series-3d-printer. Both environments verified at 149 active visible products and 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers, with no integrity exceptions. UUIDs: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-12.md. No application/schema/valuation or Worker changes; used evidence remains reference-only.


### Catalogue reconciliation note — 5 November 2026
Following the Batch 12 Creality update, parallel TEST catalogue activity added active HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) entries with active UK-new evidence. These are not yet in LIVE. Current category read: TEST 151 active visible products / 165 active evidence; LIVE 149 / 163. Audit the existing TEST records and mirror them to LIVE with environment-specific IDs; do not duplicate them in TEST. An additional duplicate Ender-3 V3 Neo record is already inactive and hidden. See CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-12.md for the detailed status.


### Creality catalogue reconciliation — three models, 5 November 2026
A parallel catalogue agent had already added canonical standard-package records for SPARKX i7 (£239), HALOT-MAGE S 14K (£439) and HALOT-R6 (£119) in both environments while a separate insertion was being prepared. The second, duplicate printer-only rows were therefore soft-deactivated and hidden; no canonical records were deleted. Canonical TEST product IDs: d51a8e10-7c21-4a91-9e01-000000000601/602/603; TEST evidence IDs: d51a8e10-7c21-4a91-9e01-000000000611/612/613. Canonical LIVE product IDs: e62b9f21-8d32-4ba2-8f12-000000000601/602/603; LIVE evidence IDs: e62b9f21-8d32-4ba2-8f12-000000000611/612/613. Inactive duplicate TEST IDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603 and evidence c7e4a901-6b32-4d8f-9a21-000000000611/612/613. Inactive duplicate LIVE IDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603 and evidence d8f5b012-7c43-4e9a-a321-000000000611/612/613.

Sources: SPARKX i7 single printer option £239 — https://store.creality.com/uk/products/sparkx-i7-3d-printer (Autofill/CFS/colour bundles excluded; fulfilment unconfirmed because indexed delivery estimate is stale); HALOT-MAGE S 14K standalone £439 — https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer (official page stated in stock, estimated delivery 2–6 Nov 2026); HALOT-R6 standalone £119 — https://store.creality.com/uk/products/halot-r6-resin-3d-printer (indexed delivery estimate stale; current fulfilment unconfirmed). Resin, filament and wash/cure bundles are excluded.

Verified after duplicate deactivation: TEST and LIVE each have 154 active customer-visible 3D printer products and 168 active evidence rows (153 uk_new / 15 uk_used), 13 manufacturers. Both environments have zero visible products missing active evidence, zero duplicate active source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only and does not affect automatic valuation. Full record history: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-13.md.


### Creality K1 catalogue addition — 5 November 2026
Added standalone Creality K1 Speedy printer to both TEST and LIVE, recorded as model K1 / standard printer. UK official price observation £299.00; the product page and current UK collection show it sold out, so current availability is not claimed. It is not marked discontinued because the manufacturer has not explicitly stated that. Source: https://store.creality.com/uk/products/k1-speedy-3d-printer. TEST product f3a6c812-9d54-4eab-b432-000000000701, evidence f3a6c812-9d54-4eab-b432-000000000711; LIVE product a4b7d923-0e65-4fbc-c543-000000000701, evidence a4b7d923-0e65-4fbc-c543-000000000711. Independent TEST/LIVE totals now match at 155 active visible 3D printer products and 169 active evidence rows (154 UK-new / 15 UK-used). Detailed checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-14.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


### Creality printer-only additions and parallel-record reconciliation — 5 November 2026
Three additional Creality models were brought into the active catalogue in TEST and LIVE using the existing `printer-only` product records rather than creating duplicate standard-package rows:
- SPARKX i7 — £239 for the i7 Single variant only. Autofill (£269), Nano Combo (£299), Color Combo (£339) and CFS Lite accessories are excluded. Source: https://store.creality.com/uk/products/sparkx-i7-3d-printer. The indexed delivery estimate is stale; current stock/dispatch is unconfirmed.
- HALOT-MAGE S 14K — £439 standalone printer; resin and wash/cure bundles excluded. Source: https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer. The page crawl was six days old and showed in stock with estimated delivery 2–6 November 2026.
- HALOT-R6 — £119 standalone printer; resin/accessories excluded. Source: https://store.creality.com/uk/products/halot-r6-resin-3d-printer. Page crawl was about one month old; current fulfilment is unconfirmed.

TEST product UUIDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603. TEST active evidence UUIDs: f73c9d20-9e43-4cb4-9a23-000000000611/612/613. LIVE product UUIDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603. LIVE active evidence UUIDs: d8f5b012-7c43-4e9a-a321-000000000611/612/613. Both sets are printer-only records and were activated only after evidence was attached. Temporary duplicate `standard` package records created during the parallel write were deactivated/hidden and retained for audit; they are not customer-visible.

Post-change category verification: TEST has 154 active customer-visible products and 168 active evidence rows (153 UK-new / 15 UK-used); LIVE has 154 active customer-visible products and 169 active evidence rows (154 UK-new / 15 UK-used). Both environments returned no active customer-visible products without active evidence. The one-row active-evidence count difference remains to be reconciled; do not state that evidence totals are identical until that check is completed. Evidence remains UK-only and GBP-only; used-market evidence remains reference-only and must not affect automatic valuation. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required.


### Creality HALOT-X1 standalone addition — 5 November 2026
Added the standalone HALOT-X1 resin printer to TEST and LIVE at £579 GBP, separate from HALOT-X1 Neo/Max and separate from the X1 Combo (£599) and All-in-One (£699) options. Official source: https://store.creality.com/uk/products/halot-x1-combo-resin-3d-priner-for-miniatures-and-terrain?country=GB&currency=GBP. Page states In Stock / UK local warehouse, but the estimated delivery 19–23 Oct 2026 is past; current dispatch should be reconfirmed. TEST product a9c8d034-1f76-40cd-8e65-000000000801, evidence a9c8d034-1f76-40cd-8e65-000000000811; LIVE product b0d9e145-2087-41de-9f76-000000000801, evidence b0d9e145-2087-41de-9f76-000000000811. TEST and LIVE independently verified at 156 active visible 3D printer products and 170 active evidence rows (155 UK-new / 15 UK-used), with zero visible products missing evidence, zero duplicate active source keys and zero invalid active evidence. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-15.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


### Follow-on Creality K1 SE and final parity correction — 5 November 2026
Added Creality K1 SE as a legacy printer-only catalogue record in both environments. Official Creality UK collection lists £229 and marks it Sold Out; this is historical UK-new price evidence only, not a current purchase offer. Source: https://store.creality.com/uk/collections/creality-could-3d-printers. TEST product/evidence UUIDs aa83d910-2f44-4b7a-9c31-000000000701/711; LIVE UUIDs bb94ea21-3a55-4c8b-8d42-000000000701/711. K1 SE remains a visible model reference, with sold-out availability explicitly recorded.

Final independent category verification after this addition: TEST and LIVE each have 157 active customer-visible products and 171 active evidence rows (156 UK-new / 15 UK-used). Both environments return zero active visible products without active evidence. The previously noted one-row evidence difference is resolved; product/evidence totals now match. All evidence remains UK GBP. Used-market evidence remains reference-only and does not affect automatic valuation. No Worker deployment or code/schema/valuation/transactional changes.


## 3D printer catalogue evidence and package expansion — 5 November 2026 (batch 14)

This was a database-only catalogue update applied independently to TEST and LIVE. The canonical category remains `3d-printers-equipment`. No application code, schema, RLS, valuation logic, Edge Functions, tenants, customers, orders, payments or Worker deployments were changed.

### New products and UK evidence

Added two distinct Original Prusa XL+ printer configurations in both environments:
- XL+ / Two-Toolhead — £2,675 GBP, EDS3D: https://eds3d.co.uk/products/original-prusa-xl-two-toolhead-3d-printer
- XL+ / Five-Toolhead — £3,530 GBP, EDS3D: https://eds3d.co.uk/products/original-prusa-xl-five-toolhead-3d-printer

These are printer configurations, not accessory/upgrade-only records. Their product-specific stock and dispatch timing are not confirmed; the evidence records the reseller's listed prices and the qualification.

Additional UK-new price evidence was attached to existing exact product/package records:
- Bambu Lab P1P — £399; manufacturer page gives conflicting availability (lead-time text says in stock, purchase CTA says sold out).
- QIDI Plus4 — £569; selector says in stock but the embedded product variant reports unavailable.
- Anycubic Photon Mono M5s — £549; official page reports sold out. It remains active because the source did not explicitly confirm discontinuation.
- Bambu Lab X1 Carbon Standard Printer — £919; official page reports sold out and a UK reseller confirms the model is no longer manufactured.
- QIDI Q1 Pro — £299; official UK page confirms discontinued/no longer in production.
- QIDI X-Max 3 — £499; official UK page confirms discontinued/no longer in production and its variant reports unavailable.

All six additional prices are stored as observed UK-new market evidence with availability qualifiers; none is represented as confirmed current stock. QIDI Q1 Pro, QIDI X-Max 3 and both Bambu X1 Carbon packages (Standard Printer and AMS Combo) are inactive and hidden from the customer-facing catalogue. Their historic evidence is retained. QIDI X-Plus 3 remains active; do not mark it discontinued without explicit manufacturer confirmation.

### Stable identifiers

LIVE:
- XL+ Two-Toolhead product `fb964376-c098-4723-a22a-fb5ee12587e5`; evidence `98206eac-d425-47a8-89eb-0ff2b49b5ec4`.
- XL+ Five-Toolhead product `bc3b2121-57af-41ca-a165-02895627cdb9`; evidence `39609ff5-3aab-43ac-9b86-73ef4c076950`.

TEST:
- XL+ Two-Toolhead product `d6b95041-45b3-46c4-9cc2-97828fdab7af`; evidence `387d8e7e-5942-43c6-bd9a-f85c99a175ca`.
- XL+ Five-Toolhead product `2fda6830-8d17-4047-bfd8-e8797337859a`; evidence `4578e7bd-c890-4904-8cb3-1a5960fcf337`.

The six other UK-new evidence records use stable source keys dated 2026-11-05:
`uk-new:bambu-lab:p1p:standard:2026-11-05`,
`uk-new:qidi:plus4:standard:2026-11-05`,
`uk-new:anycubic:photon-mono-m5s:standard:2026-11-05`,
`uk-new:bambu-lab:x1-carbon:standard:2026-11-05`,
`uk-new:qidi:q1-pro:standard:2026-11-05`,
`uk-new:qidi:x-max-3:standard:2026-11-05`.

### Verification and operating rules

Final independent verification:
- LIVE: 162 product rows, 155 active/customer-visible, 7 inactive; 179 active evidence rows (164 UK-new / 15 UK-used), covering 159 products.
- TEST: 163 product rows, 155 active/customer-visible, 8 inactive; 179 active evidence rows (164 UK-new / 15 UK-used), covering 159 products.
- Both environments have zero active visible products without active evidence, zero duplicate active evidence source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency).
- Active catalogue and evidence totals are aligned. TEST has one additional inactive/hidden Creality Ender-3 V3 Neo / Printer only duplicate row with no LIVE counterpart. Retain it hidden; do not delete or reactivate it as part of routine parity work.

All evidence remains UK GBP. UK-used evidence is reference-only and must never feed automatic valuation. Sold-out, discontinued, stale-delivery and stock-conflict listings must retain their explicit availability qualification and must not be presented as confirmed available stock. No Worker deployment is required for these database-only changes.


### Batch 17 — Anycubic 3D printer catalogue
Added Kobra 4 Standard Printer and Photon Mono 4 Ultra Standard Resin Printer at £279 GBP in both TEST and LIVE; added a separate £849 UK-new Photon P1 Max pre-order observation. Stock and delivery qualifications are retained. Verification: LIVE 164 products / 157 active visible / 182 active evidence; TEST 165 / 157 / 182. No missing active evidence, duplicate active product/evidence keys or invalid active evidence. See PROJECT-MEMORY/2026-11-05-3d-printer-catalogue-batch-15.md and CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-17.md. No Worker deployment or valuation/application changes.


### Camera category research — initial LIVE batch (5 November 2026)

Scope: active LIVE products in the Cameras category only; Pokémon Trading Cards excluded. Starting coverage check showed 722 active camera products, 353 with at least one active GBP evidence record and source URL, and 369 requiring research.

Added four UK-new evidence observations to LIVE `public.shared_market_evidence`, matched to existing master product UUIDs:
- Blackmagic Design Cinema Camera 6K — £1,219.00; Blackmagic Design UK; availability recorded unknown.
- Canon Cinema EOS C70 Camera Body — £3,599.99; Canon UK Store; in stock at time checked.
- Canon EOS R50 V Camera Body — £529.00; Park Cameras; in stock at time checked.
- Brinno TLC300 Long Term Time Lapse Camera — £269.99 starting price; BrinnoUK; collection page showed in-stock range; selected package price must be reconfirmed.

Sources: https://www.blackmagicdesign.com/uk/products/blackmagiccinemacamera ; https://www.canon.co.uk/store/cinema-eos-cameras/ ; https://www.parkcameras.com/cameras/mirrorless-cameras/canon/?pi=2 ; https://www.brinnouk.com/collections/1080p-cameras .

Post-insert read-back: 722 active Cameras products; 357 have qualifying active GBP evidence with source URLs; 365 remain without qualifying evidence. This is an evidence-presence count, not a complete quality/freshness audit. Continue in small verified batches, check exact model/package, UK GBP price and availability, and duplicate source keys before inserting. UK-used evidence remains reference-only and excluded from automatic valuation. LIVE only was changed; TEST, catalogue products, lifecycle flags, valuation, application code and Worker deployments were not changed.


### 3D printer catalogue batch 18 — Sovol range and Anycubic Photon P1 configurations (5 November 2026)
Added Sovol as a new master manufacturer and six UK-priced product configurations to TEST and LIVE: SV08 Max Standard (£809), SV08 Max Enclosure Combo (£968), SV08 Standard (£389), SV08 Enclosure Combo (£519), M1D Essential (£1,100), and M1D Advanced (£1,320). All six have official Sovol UK GBP evidence. SV08 Max and SV08 pages show sold-out/notify status; the SV08 mid-October dispatch estimate has passed. M1D is a pre-order with estimated late-November to mid-December 2026 dispatch, but its page also shows sold-out/notify status; do not present as confirmed stock. Sources: https://sovol.uk/products/sovol-sv08-max-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-sv08-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-m1d-3d-printer.

Added Anycubic Photon P1 Dual-Color / Dual-Material Platform Bundle as a distinct package configuration (£469 UK-new evidence; official page shows sold out): https://uk.anycubic3d.com/products/photon-p1-dual-color-and-dual-material-printing. Added a fresh 5 November standard Photon P1 UK-new price observation (£449, sold out), retaining the previous 4 November observation rather than overwriting it: https://uk.anycubic3d.com/products/photon-p1-resin-3d-printer.

Verification after this batch: LIVE 171 product rows / 164 active visible / 190 active evidence (175 UK-new, 15 UK-used); TEST 172 / 164 / 190. Both have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid active evidence (missing source URL/key, non-positive price or non-GBP currency). Both contain 14 manufacturers; Sovol has 6 products and Anycubic 21. UK-used evidence remains reference-only and does not affect automatic valuation. Keep sold-out, pre-order and expired-delivery qualifications intact. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.


### Camera category research — batch 02 (LIVE, 5 November 2026)

Continued Blackmagic Design camera research. Added UK GBP observations to existing active camera products:
- Micro Studio Camera 4K G2 — £809 UK manufacturer list price; stock unknown.
- Pocket Cinema Camera 4K — £849 Park Cameras, marked in stock; separate MPB used-market reference from £669, reference-only.
- Studio Camera 4K Plus G2 — £1,065 UK manufacturer list price; stock unknown.
- Studio Camera 4K Pro G2 — £1,455 UK manufacturer list price; stock unknown.
- Studio Camera 6K Pro — £1,909 UK manufacturer list price; stock unknown.
- PYXIS 12K PL — £3,139 UK manufacturer promotional price (was £3,925); stock at retailer unknown.
- PYXIS 6K L Mount — £1,525 UK manufacturer list price; stock at retailer unknown.

Sources include https://www.blackmagicdesign.com/uk/products ; https://www.blackmagicdesign.com/uk/products/blackmagicpyxis/blackmagicraw ; https://www.parkcameras.com/video/blackmagic/ ; https://www.mpb.com/en-uk/product/blackmagic-design-pocket-cinema-camera-4k .

Read-back after batch: 722 active Cameras products; 364 have qualifying active GBP evidence with source URL; 358 still require qualifying evidence. Seven additional product records gained evidence coverage. UK-used MPB observation is reference-only and excluded from automatic valuation. No product master/lifecycle/valuation/application/schema/RLS/tenant/customer/order/payment changes; LIVE only; no Worker deployment.


### Sovol 3D printer catalogue — Batch 19 (5 November 2026)

Added three missing Sovol configurations independently to LIVE and TEST, with active UK-new GBP evidence:
- SV06 ACE / Standard Printer — £210; official UK page https://sovol.uk/products/sovol-sv06-ace. Page displays Sold Out / Notify me alongside conflicting limited-stock wording; availability unconfirmed.
- SV06 ACE / SH02 Filament Box Combo — £269; same official UK page. Page displays Sold Out / Notify me; availability unconfirmed.
- Zero / Standard Printer — £249 sale price; official UK page https://sovol.uk/products/sovol-zero-3d-printer. Page says only 8 left in the UK warehouse but also displays Sold Out / Notify me; availability unconfirmed. Product classified as enclosed CoreXY FDM printer.

LIVE product/evidence UUIDs:
- SV06 ACE Standard: 8453c386-45e0-413b-9f70-43fb428ae919 / 418a0008-2c75-4c2b-a3c8-2c82442794c4
- SV06 ACE SH02 combo: 49872fc8-73c9-43be-8784-c2e5fae98e36 / 48c985f9-531a-4f88-b478-2712a47e26f4
- Zero Standard: 479484f0-eb4b-40cb-ae86-3e0f16f3968c / a9794fb9-f81c-440f-89fe-72d607d7860c

TEST product/evidence UUIDs:
- SV06 ACE Standard: 5c823ba8-8707-4fe4-af76-d69f1d58eaab / 935a6d29-281a-4c16-b0aa-999cef5bb404
- SV06 ACE SH02 combo: 366983ef-d69b-4466-9941-e776934485da / c19f0335-a97a-4bb0-90bd-547a295eafae
- Zero Standard: 2f6670e9-aa1f-4cbf-b6e1-e49d6165724b / 476a0073-7b7f-46ea-a120-861c96ea4e4d

Post-insert read-back, scoped to the 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 174 | 167 | 7 | 193 | 178 | 15 |
| TEST | 175 | 167 | 8 | 193 | 178 | 15 |

Both environments have zero active visible products missing active evidence, zero duplicate active product keys, zero duplicate active evidence source keys, and zero invalid/missing evidence or invalid UK-new evidence. UK-used evidence remains reference-only and does not affect automatic valuation. TEST retains its pre-existing additional hidden product row; no deletion or reactivation was performed. No app code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-19.md.


## Camera research — batch 04 (LIVE, 5 November 2026)

Added three UK-new observations to existing active Blackmagic product records:
- URSA Cine 17K 65 — £18,235, official Blackmagic Design UK price; availability unknown.
- URSA Cine 17K 65 Body — £14,075, official Blackmagic Design UK price; availability unknown.
- URSA Cine Immersive — £20,529, official Blackmagic Design UK products listing; availability unknown. This is the standard Immersive configuration only, not the 100G or Body variants.

Source URLs: https://www.blackmagicdesign.com/uk/products/blackmagicursacine and https://www.blackmagicdesign.com/uk/products. All three records were inserted into LIVE `public.shared_market_evidence` and independently read back with GBP currency, source URL and active status confirmed. Existing master products only; no new product rows or lifecycle/valuation changes. LIVE only; TEST untouched. No schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. See PROJECT-MEMORY/2026-11-05-camera-research-batch-04.md and CHECKPOINTS/2026-11-05-camera-research-batch-04.md.


## Camera research — batch 05 (LIVE, 5 November 2026)

Added two further UK-new observations to existing active Blackmagic products after checking that neither product had qualifying active evidence:
- URSA Cine 12K LF — £11,779, official Blackmagic Design UK listing; availability unknown.
- URSA Cine 12K LF + EVF — £12,779, official Blackmagic Design UK listing; availability unknown. This is the EVF package, not the body-only product.

Source: https://www.blackmagicdesign.com/uk/products/blackmagicursacine. Both evidence inserts returned successfully. Existing product rows only; no product master, package, lifecycle or valuation changes. LIVE only; TEST untouched. No schema/RLS/application/Edge Function/Worker/tenant/customer/order/payment/Stripe changes. No Worker deployment. Category count reconciliation remains open; do not publish coverage totals until the camera inclusion rule is resolved. See PROJECT-MEMORY/2026-11-05-camera-research-batch-05.md and CHECKPOINTS/2026-11-05-camera-research-batch-05.md.


### WEEFUN 3D printer catalogue — Batch 20 (5 November 2026)

Added WEEFUN as a distinct manufacturer and four compact FDM printer configurations independently to LIVE and TEST, each with active UK-new GBP marketplace evidence:
- Tina2 / Standard Printer — £164.59; UK Amazon price-tracker listing: https://www.3dprinterdeals.co.uk/printers/brand/weefun
- TINA2C / Standard Printer — £179.99; UK offer tracker: https://www.3d-pioneer.com/en/printers/weefun-tina2c
- TINA2S / Standard Printer — £217.79; UK offer tracker: https://www.3d-pioneer.com/en/printers/weefun-tina2s
- Tina2 Plus / Standard Printer — £219.54; UK Amazon price-tracker listing: https://www.3dprinterdeals.co.uk/printers/brand/weefun

These are Amazon UK new-offer asking prices surfaced by third-party trackers, not manufacturer-direct prices. Evidence notes explicitly require seller, delivery and checkout-price verification. WEEFUN is recorded as the marketplace-listed brand. ENTINA Tina2C/Tina2 Plus listings were not merged into WEEFUN or added as duplicate models in this batch; brand identity and exact product equivalence remain to be reconciled before adding ENTINA.

LIVE manufacturer UUID: 1e398b32-e14f-4c96-b0dc-9f6fc2a74d32.
LIVE product/evidence UUIDs:
- Tina2: b36f86b5-0046-4fd8-8ee5-6898b0328264 / 96aab21d-3724-4c79-a124-d0f06a9cb457
- TINA2C: a13f221b-2af6-434d-a13d-a8ab9ba6ea7e / eacafdf5-4584-4894-a087-7c08bf6f46f8
- TINA2S: 101eb395-98d1-4cf7-9fd9-6af8359aeb76 / b0a5bf55-05f9-4957-8a00-bff649cbfd73
- Tina2 Plus: d3af1d04-f14e-4e5e-984c-625cbc317aa3 / 2ba35afa-4607-403b-9c62-a65b7d1d7623

TEST manufacturer UUID: 2ba8e6a5-490c-48b0-b8c4-035d171d5ed5.
TEST product/evidence UUIDs:
- Tina2: 666224ff-85b9-4f69-ac75-49bfbc967533 / d761a9eb-215f-4122-9ef1-0c01f8e3567e
- TINA2C: 9bfc345e-ffb9-4185-9f41-0b30cc06b4c4 / 5ebc4577-ca76-4402-b8ab-1ee4a5682954
- TINA2S: 879fe4c9-25ec-4f69-87b6-fb116b35686d / 747d14eb-13da-4df9-9918-5129ecfa9065
- Tina2 Plus: 0d46c5f0-4355-49ef-b338-8026d85fdb6d / 1a82fce8-8ffe-4828-bb6b-e39aabffa894

Post-insert read-back, scoped to the 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 178 | 171 | 7 | 197 | 182 | 15 |
| TEST | 179 | 171 | 8 | 197 | 182 | 15 |

Both environments have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid/missing evidence. UK-used evidence remains reference-only and does not affect automatic valuation. No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-20.md.


## Camera catalogue research updates — 5 November 2026 (batches 03, 05 and 06)

LIVE-only UK GBP evidence additions; TEST remains untouched. Batch 03 added evidence for URSA Broadcast G2 (£3,586.80, RCB Logic), URSA Mini Pro 12K (£5,039, Blackmagic Design UK), URSA Mini Pro 12K OLPF (£5,412.94, RCB Logic), URSA Cine 12K LF Body (£5,999.99, Scan), and two distinct URSA Cine 12K LF 100G Body observations (£13,868.10 VAT-inclusive equivalent from BPS-TV, converted from £11,556.75 ex VAT; and £8,238 VAT-inclusive from RCB Logic, marked backorder/3–5 days). Preserve both price observations rather than overwrite or average them.

Batch 05 added official manufacturer UK price observations for URSA Cine 12K LF (£11,779) and URSA Cine 12K LF + EVF (£12,779). Batch 06 added official manufacturer UK price observations for URSA Cine Immersive 100G (£21,275), URSA Cine Immersive 100G Body (£15,859), and URSA Cine Immersive Body (£15,245). All batch 05/06 observations use the official Blackmagic Design UK product page and availability is unknown; do not infer retailer stock from manufacturer list pricing.

Batch 06 insert rows were independently read back and verified active, GBP and source-linked. Product master rows already existed; no master catalogue or lifecycle changes. All work is LIVE only; TEST untouched. No valuation, schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. Used-market evidence remains reference-only and does not feed automatic valuation.

Camera coverage totals remain unpublished pending reconciliation of the earlier 722-product baseline with the later 720-row main_category=Cameras roll-up. Do not compare or report coverage until category scope is reconciled. See PROJECT-MEMORY/2026-11-05-camera-research-batch-05-06.md and CHECKPOINTS/2026-11-05-camera-research-batch-05-06.md.


### ENTINA / WEEFUN Tina2 naming and duplicate-key review — Batch 21 (5 November 2026)

Researched ENTINA's official Tina2C/Tina2 Plus/Tina2S lineup and WEEFUN's own Tina2C/Tina2S pages. ENTINA Tina2C has a UK Amazon tracker observation at £208.00 (new condition; last seen approximately 31 October 2026): https://www.3dprinterdeals.co.uk/item/entina-tina2c-3d-printer-friendly-for-beginners-ready-to-print-in-5/B0GQSR943V. ENTINA's official product page confirms the separate ENTINA brand and the Tina2C model: https://www.entina3d.com/products/entina-3d-printer-tina2c.

A trial ENTINA Tina2C master row and evidence record were inserted and immediately reverted in both environments after the global branch-level duplicate-key check identified the same model/package key as the already-catalogued WEEFUN TINA2C. No ENTINA product/evidence row remains, and no manufacturer row remains from that trial. This avoids leaving duplicate product keys or claiming the two brand listings are separate hardware without a confirmed model distinction. The existing WEEFUN TINA2C remains unchanged. Revisit only if the catalogue key strategy is deliberately extended to support same-model brand variants or reliable evidence proves a distinct configuration.

Post-revert verification remains unchanged from Batch 20: LIVE 178 products / 171 active visible / 197 active evidence (182 UK-new, 15 UK-used); TEST 179 / 171 / 197. Both have zero missing active visible evidence and zero duplicate product keys. No Worker deployment or app/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-21.md.


## Nintendo controller catalogue expansion — 5 November 2026

The Nintendo Controllers master-catalogue branch received two additional verified HORI products in both TEST and LIVE:

- HORI Mario Kart Racing Wheel Pro Mini for Nintendo Switch 2 — Red (EAN-13 4961818042445).
- HORI Mario Kart Racing Wheel Pro Deluxe for Nintendo Switch 2 — Red & Black (EAN-13 4961818042469).

Both are active and customer-visible, assigned to the existing Nintendo Controllers branch, and recorded as controller products. Each has two UK-new retail evidence observations dated 5 November 2026:

- Pro Mini: Smyths Toys UK £69.99; Argos £74.99.
- Pro Deluxe: Very £104.99; Argos £119.99.

Evidence is GBP, New condition, with retailer source URLs and source-record keys. Product identifiers are recorded against the master products. No UK-used evidence was added; existing UK-used evidence remains reference-only and must not affect automatic valuation.

Verified result in each environment after the update: 99 active/customer-visible Nintendo controller products; 102 active UK-new evidence rows covering all 99 products; 2 active UK-used evidence rows covering 2 products. There are zero active visible products missing any active evidence or UK-new evidence. TEST and LIVE counts and research rows match.

An existing package-key collision remains: two older records in this branch use the generic key `single-controller`. It predates this batch and was not changed because the records were not established as duplicate products. Do not delete or merge them without checking their actual model/package identity and prior history. The two HORI additions use distinct product-specific package keys.

This was a database-only catalogue/evidence update. No Worker deployment, application-code change, schema migration, tenant/customer/order/payment change, or valuation-rule change was made.


## Additional Nintendo controller products — 5 November 2026

Two further products were added independently to the TEST and LIVE Nintendo Controllers branches:

- Nintendo Switch 2 Pro Controller — Resident Evil Requiem Edition. EAN-13 0045496321840. UK-new observations: Argos £69.99, Currys £74.99, Very £83.99.
- Nintendo GameCube (GCN) Controller — Nintendo Classics. Nintendo Store UK £58.99. This is a Nintendo Switch 2 wireless controller, exclusive to Nintendo Switch Online members; the Nintendo Store item identifier is recorded as a non-GTIN identifier.

All four observations are dated 5 November 2026 and include source links. Both products are active/customer-visible and have active UK-new evidence. The GameCube membership restriction is retained in the product notes.

Post-update verified totals in each environment: 101 active/customer-visible Nintendo controller products; 106 active UK-new evidence rows covering all 101 products; 2 active UK-used reference rows covering 2 products. No active visible product is missing active evidence or UK-new evidence. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment change was made.


## Camera catalogue research — Brinno batch 07 (5 November 2026)

LIVE-only UK GBP evidence added to five existing active products: Brinno BCC2000 £544.99 (Timelapse Store; availability unknown); BCC2000 Plus £719.00 (BrinnoUK, No Solar Kit configuration; page showed Add to cart); BCC2020 £432.00 starting price (BrinnoUK homepage; exact variant/availability unknown); TLC2020 + ATH1000 £399.00 starting price (BrinnoUK homepage; availability unknown); TLC2020 + ATH2000 £519.00 starting price (BrinnoUK homepage; availability unknown). Sources: https://timelapse.store/collections/brinno, https://www.brinnouk.com/products/bcc2000-plus, https://www.brinnouk.com/. Preserve starting-price and availability qualifications; do not treat them as confirmed stock except the BCC2000 Plus listing that displayed Add to cart.

All five inserts were independently read back and verified active, GBP and source-linked. Existing product master records were used; no master or lifecycle changes. LIVE only; TEST untouched. No valuation, schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. Camera coverage totals remain unpublished pending the 722 versus 720 category-scope reconciliation.


### Geeetech and Artillery 3D printer additions — Batch 22 (5 November 2026)

Added three distinct printer configurations independently to LIVE and TEST, with active UK-new GBP evidence:
- Geeetech M1S / Standard Printer — £185.00, official Geeetech GBP store listing: https://www.geeetech.com/index.php?currency=GBP&main_page=product_info&products_id=1085. The page has a ship-from selector; verify UK warehouse selection and checkout total.
- Artillery M1 Pro / Standard Printer — £299.00 sale price (£349.00 regular), official UK page https://uk.artillery3d.com/products/m1-carbon. Page reports Out of stock.
- Artillery M1 Pro S1 / Standard Printer — £319.00 sale price (£349.00 regular), official UK page https://uk.artillery3d.com/products/m1-pro-s1. Page reports Out of stock.

Stock status for both Artillery models is explicitly recorded as out of stock; prices are current official UK observations, not claims of availability. Geeetech M1 (non-S1) was not added because the GBP price evidence varied between £128 and £150 in different captures; defer until price and source page are reconciled. Artillery Sidewinder X4/X3 variants were not added because the official product-series listing marks them sold out and no reliable current UK printer price was established in this batch.

LIVE IDs:
- Geeetech manufacturer dc71aafe-1eec-43d4-832e-2f37918455ee; M1S product 16387858-242f-4ed3-962a-4262250e0af6; evidence dec25b70-c9c5-4d5c-8d7a-ddab4c74e63e.
- Artillery manufacturer 6ade46dc-dd65-4b96-948c-050c5678ad97; M1 Pro product 03f5d9f9-cf09-4ffc-85d8-87eb81972402; evidence bddeb903-6c0c-4586-875b-0f0ad6b68fda.
- M1 Pro S1 product 9a2cec2d-b2f2-4dcf-b9f3-7f82b23b5c6f; evidence 4fe5e6bf-ab50-463e-b1a1-be0058584db1.

TEST IDs:
- Geeetech manufacturer 6bf26f3d-805a-44f2-9655-b36a84b40fdc; M1S product d2c6a15b-3e58-4ff0-8342-3605457f7462; evidence 38f855d6-4d22-4893-af4e-772e30558a9f.
- Artillery manufacturer 4f7a1362-534e-4ccd-9c32-0c61667a82f3; M1 Pro product 8ca46de2-cc0d-495f-8b78-bd14a7397a7f; evidence 41c13355-eddc-40eb-a4a3-d435ac347bc7.
- M1 Pro S1 product e85b8a23-6862-4439-863c-fddf1ed75d78; evidence 214de6e3-84af-46b6-91ac-4c19c63ff874.

Post-insert read-back, scoped to 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 181 | 174 | 7 | 200 | 185 | 15 |
| TEST | 182 | 174 | 8 | 200 | 185 | 15 |

Both environments have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid/missing evidence. UK-used evidence remains reference-only and does not affect automatic valuation. No app code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment data changed. No Worker deployment. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-22.md.


## Camera catalogue research — Brinno batch 08 (5 November 2026)

LIVE-only UK GBP evidence added to five existing active Brinno camera products: BCC300-C £429 (BrinnoUK construction kits collection); BCC300-M £329 (same collection); TLC2020 £349 starting price (BrinnoUK 1080p collection); TLC2020-C £545 (same collection); TLC2020-M £409 (same collection). Source pages: https://www.brinnouk.com/collections/construction-timelapse-kits and https://www.brinnouk.com/collections/1080p-cameras. Availability is recorded as unknown; TLC2020 price is a starting price. The collection listing also states the TLC300 range has replaced TLC200 Pro; do not add a current new-market price for TLC200Pro from obsolete stock listings.

All five insert statements returned the new product/evidence keys. Independent read-back was attempted but blocked by the query safety layer; therefore do not describe these five rows as independently read-back verified. Product master records were not modified. LIVE only; TEST untouched. No valuation, schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. Camera coverage totals remain unpublished pending reconciliation of 722 versus 720 category scope.


## Camera catalogue research — Brinno batch 09 (5 November 2026)

LIVE-only evidence added for the existing active Brinno BCC5000 Wi-Fi & 4K Construction Time Lapse Bundle: £1,899.00 GBP, official BrinnoUK construction kits collection, https://www.brinnouk.com/collections/construction-timelapse-kits. Availability is recorded as unknown because the page lists the product and price but does not independently confirm stock. The product had zero qualifying active GBP/source-linked evidence before this insert; insert returned the new evidence key. No product master or lifecycle changes.

Brinno's current support centre identifies BBT2000, TLC200, TLC200Pro and BCC200 BLE in its product/support lists, while the EOL FAQ explicitly lists BBT2000 and the TLC200Pro/BCC200 family as end-of-life. No unsupported current new-market price was added for those models. Brinno's homepage states TLC300 replaced TLC200Pro. LIVE only; TEST untouched. No valuation, schema, RLS, application, Edge Function, Worker, tenant, customer, order, payment or Stripe changes. No Worker deployment required. See PROJECT-MEMORY/2026-11-05-camera-research-batch-09.md and CHECKPOINTS/2026-11-05-camera-research-batch-09.md.


## PlayStation controller batch — 5 November 2026
Five DualSense models were added in TEST and LIVE: Midnight Black £59.99, Starlight Blue £59.99, Cosmic Red £59.99, Nova Pink £59.99 and Chroma Teal £64.99, each with UK-new Argos evidence. Both branches now have 16 active products and 15 UK-new evidence rows covering 15 products. One older DualShock 3 record has no UK-new evidence and is retained for legacy review. No deployment or code/schema/valuation changes.


## Camera catalogue research — Brinno batch 10 (5 November 2026)

LIVE-only evidence inserted and independently read back for existing product TLC300 Waterproof Bundle (TLC300 & Waterproof Case Timelapse Camera Bundle), product ee75b3d2-c298-4d36-9cd0-8121bac10fd2. Timelapse Store UK lists Brinno TLC300 & ATH120 Bundle at £299 GBP: https://timelapse.store/collections/brinno. Evidence c231daec-df62-468f-bb26-b1ebc01b9470, UK-new, active, availability unknown; stock not independently confirmed. The exact TLC300 plus ATH120 package was matched. No standalone TLC2000/TLC5000 prices or obsolete-model new prices were inferred. LIVE only, TEST untouched; no master product, lifecycle, valuation, schema, RLS, application, Worker, Stripe, customer or payment changes. No Worker deployment. See PROJECT-MEMORY/2026-11-05-camera-research-batch-10.md and CHECKPOINTS/2026-11-05-camera-research-batch-10.md.


## PlayStation Gran Turismo Limited Edition — 5 November 2026

Added independently to TEST and LIVE: DualSense Wireless Controller - Gran Turismo Limited Edition, model CFI-ZCT2WZMX, UK pre-order price £74.99, release date 10 December 2026. Three active UK-new GBP/New Retail pre-order evidence rows per environment:
- PlayStation Direct: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/gran-turismo-limited-edition/
- Argos: https://www.argos.co.uk/product/9906844 (EAN 711719072836 verified from retailer listing)
- Smyths Toys: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/playstation-5/playstation-5-accessories/playstation-5-dualsense-wireless-controller-gran-turismo-limited-edition/p/266465

Product active/customer-visible in both environments. Product IDs: TEST 777420ef-7ac3-4151-ae40-9691eeba3493; LIVE 3892048b-c072-421c-be1a-78181e7785ef. Verified branch totals in each environment: 20 active/customer-visible products, 22 active UK-new evidence rows covering 19 products. The legacy Sony DualShock 3 Wireless Controller - Black remains the one product without UK-new evidence and is retained for legacy/discontinued review. No Worker deployment, app code/schema/valuation/RLS/Edge Function, tenant/customer/order/payment/Stripe changes. TEST and LIVE updated independently.


## 3D printer catalogue continuation — ELEGOO and FLSUN batch (5 November 2026)

Added and evidenced three previously missing ELEGOO configurations independently in LIVE and TEST:
- Centauri Carbon 2 standard (without CANVAS): £259.00 GBP; https://uk.elegoo.com/products/centauri-carbon-2
- Centauri 2 standard (without CANVAS): £179.00 GBP; https://uk.elegoo.com/products/centauri-2
- Centauri 2 CANVAS 4-colour Combo: £219.00 GBP; https://uk.elegoo.com/products/centauri-2-combo
The existing Centauri Carbon 2 CANVAS combo was already present in both environments and was not duplicated. Official ELEGOO UK pages show the UK shipping territory and pricing; checkout shipping is calculated separately. Source prices observed 5 November 2026.

Product/evidence IDs — LIVE:
- Centauri Carbon 2 standard: product 5063b4eb-0300-4fdc-9845-2f90c4d42764; evidence c35bab99-2ec6-4d43-b76e-ef093e1f2724.
- Centauri 2 standard: product 6d562965-b9a7-4f89-a495-24b32993a26c; evidence e50b55df-65ee-4db8-818f-47b7c3222d58.
- Centauri 2 CANVAS combo: product 9b3dc3cb-9e64-4253-b389-9f27bbaa61ee; evidence b5312394-0f51-4815-8c0b-cc727f6e6f12.

Product/evidence IDs — TEST:
- Centauri Carbon 2 standard: product f5b16bc4-23ed-4406-b1cc-1c26ef57aefe; evidence fe2eeabd-5d76-4f4c-a44b-7a3e97860af8.
- Centauri 2 standard: product 9c1be54d-8251-432a-96f3-77dc428d11cf; evidence f004ef0f-47e1-4eee-9ecc-2e4c5cb85bb4.
- Centauri 2 CANVAS combo: product 39cce755-195f-48a9-ab45-06106460bbba; evidence e03010e5-ebd4-4725-9189-b9702aaa388c.

Resolved the incomplete FLSUN T1 MAX record from the previous continuation. The official FLSUN UK collection lists £459.00 sale / £599.00 regular and marks it in stock: https://uk.store.flsun3d.com/collections/3d-printer-new. Evidence is now present in both environments. LIVE product a22e38a9-8de5-4bdf-a3ab-4b5e110ee101 / evidence 2f51f375-8931-4b1e-aa43-49bf6809217c. TEST product 5d1797a2-0f28-4efb-8d31-e318ee2da3bf / evidence 7d21abe5-21b2-4b59-ac75-52150d52050e. Product notes were corrected to match the current official collection's in-stock status.

Verified 3D Printers branch totals after inserts:
| Environment | Products | Active visible | Active evidence | UK-new | Missing visible evidence |
|---|---:|---:|---:|---:|---:|
| LIVE | 185 | 178 | 204 | 189 | 0 |
| TEST | 186 | 178 | 204 | 189 | 0 |

Both environments: zero duplicate active product keys and zero duplicate active evidence source keys. Previous hidden/inactive counts remain 7 LIVE and 8 TEST. UK-used evidence remains reference-only and excluded from automatic valuation. TEST and LIVE were updated independently. No application code, schema, valuation logic, RLS, Edge Functions, Worker, Stripe, tenant/customer/order/payment data changed. No Worker deployment required.

## PlayStation additional special editions — 5 November 2026
Added independently in TEST and LIVE:
- DualSense Wireless Controller - Icon Blue Special Edition, model CFI-ZCT2WZBX, £74.99; two active UK-new GBP/New Retail evidence rows from PlayStation UK and PlayStation Direct.
- DualSense Wireless Controller - Marvel's Wolverine Adamantium Limited Edition, model CFI-ZCT2WZKX, £74.99; two active UK-new GBP/New Retail evidence rows from PlayStation UK and PlayStation Direct.

Direct evidence URLs:
- Icon Blue: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/icon-blue-special-edition/ and https://direct.playstation.com/en-gb/buy-accessories/dualsense-wireless-controller-icon-blue-special-edition-for-ps5-pc-mac-mobile
- Wolverine Adamantium: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/marvels-wolverine-adamantium-limited-edition/ and https://direct.playstation.com/en-gb/buy-accessories/dualsense-wireless-controller-marvels-wolverine-adamantium-limited-edition-for-ps5-pc-mac-mobile

Combined with the Gran Turismo Limited Edition batch, verified TEST and LIVE branch totals now match at 22 active/customer-visible products and 26 active UK-new evidence rows covering 21 products. The only uncovered product remains the pre-existing Sony DualShock 3 Wireless Controller - Black. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes.


## Xbox controller expansion — 5 November 2026

Added independently in TEST and LIVE under the existing Xbox Controllers branch:
- Xbox Wireless Controller - Ice Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Heart Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Storm Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Gears of War E-Day Limited Edition — Smyths £79.99; John Lewis £84.99; Microsoft Store £84.99.
- Xbox Wireless Controller - Forza Horizon 6 Limited Edition — Argos £69.99; Currys £84.99.

All 5 products are active/customer-visible. Each evidence row is active UK-new, GBP, New, Retail, dated 5 November 2026, with a direct retailer/product URL and stable source_record_key. Microsoft Breaker variants share the official Breaker-series product page, which exposes Ice Breaker, Heart Breaker and Storm Breaker as selectable configurations. Forza Horizon 6 release date 21 May 2026. Gears of War E-Day release date 29 September 2026; the Microsoft page still presents a pre-order CTA after that date, so availability is recorded as Listed rather than claiming in-stock.

Verified TEST and LIVE each: 20 active/customer-visible Xbox controller products; 23 active UK-new evidence rows covering all 20 products. No visible product in this branch is missing UK-new evidence. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes. TEST and LIVE updated independently.


## Creality Ender-3 V3 Neo evidence and CFS nano combo — 5 November 2026

The existing Ender-3 V3 Neo standard printer record was confirmed in both environments and refreshed with the current official UK printer-only price £199.00. Added a distinct CFS nano four-colour Combo configuration at £289.00; official product page labels the combo as pre-order and includes a 2 kg filament promotion. Source: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer. The official Creality UK comparison article (20 October 2026) distinguishes the Neo and Mega specifications and quotes Neo £199 / Mega £519: https://store.creality.com/uk/blogs/buying-guides/ender-3-v3-neo-vs-mega. Ender-3 V3 Mega was not added in this batch because current UK listing presents it as a promotional filament bundle from £519 and a clean printer-only / combo split was not sufficiently confirmed.

LIVE: existing Neo standard product b2c3d4e5-6f70-489a-8123-000000000101 refreshed evidence 4c43d533-c79d-48b0-ae4f-096bec842734 (£199); new CFS nano combo product 2c3eaeea-7828-4289-9e3b-5fb0eefd65c6 / evidence 2b52ae5c-d138-47b7-bade-9a8fe5c0d171 (£289).
TEST: existing Neo standard product a1b2c3d4-5e6f-4789-9012-000000000101 refreshed evidence 20fda591-e7d9-4102-8a3a-e8fbc141ad41 (£199); new CFS nano combo product e26954ad-9225-4195-9a18-757163eb8e64 / evidence 1fb1de2e-410e-4806-8311-e22c0a227dd7 (£289).

Verified totals after this addition: LIVE 186 products / 179 active visible / 206 active evidence / 191 UK-new; TEST 187 products / 179 active visible / 206 active evidence / 191 UK-new. Both environments have zero active visible products missing active evidence. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.

## Nikon used-market evidence — batch 11 (5 November 2026)

Added two active UK-used GBP reference observations to existing LIVE Nikon camera products, sourced from UsedLens UK live retailer index (prices updated 5 November 2026): Nikon D750 typical asking price £450 across 135 listings, product efea69a4-2861-4ce6-87e7-cc14e1e0f26d, evidence 694b727c-aa85-4e0e-b793-94a1e072ad55, https://usedlens.co.uk/product/nikon-d750; Nikon COOLPIX P1000 typical asking price £744 across 30 listings, product 46542fe9-05d7-4d3c-a94b-2d23218712e0, evidence 09ec7d81-1161-4079-91a3-d8e2b651bbf0, https://usedlens.co.uk/product/nikon-coolpix-p1000. These are market asking-price benchmarks, not dealer acquisition offers or automatic valuation inputs. Both rows independently read back active, GBP, used condition and source-linked.

Checked UK-used evidence before inserting: D750 and P1000 had none; D850, D7500, D780 and P1100 already had UK-used records, so no duplicate rows were added. LIVE only; TEST untouched. No product master, lifecycle, UK-new evidence, valuation, schema, RLS, application, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment.


## Bambu Lab H3C addition — 5 November 2026

Added Bambu Lab H3C with AMS H3 Combo as a distinct package in both LIVE and TEST. Bambu Lab's official launch post dated 3 November 2026 explicitly lists the UK H3C + AMS H3 price at £2,199 including tax. Source: https://blog.bambulab.com/tool-changer-game-changer-bambu-lab-presents-h3c-the-defining-new-generation-of-3d-printers/. This is a bundled configuration; no standalone printer price is inferred. Availability and dispatch timing are recorded as requiring confirmation on the UK store.

LIVE product e33286e7-1083-41e5-8677-ce147bf754cd; evidence bf9e3cba-d469-43d3-a0b2-5bf75b9f2bf3. TEST product 9149695d-2cd7-428c-bf52-b22ac3d85245; evidence aeb43102-77aa-4934-bfd3-42ea0463bd65.

Verified 3D Printers totals after this addition: LIVE 187 products / 180 active visible / 207 active evidence / 192 UK-new; TEST 188 products / 180 active visible / 207 active evidence / 192 UK-new. Both environments have zero active visible products missing active evidence. Other recently released models in the catalogue were checked (Bambu A2L and X2D, Anycubic Kobra S1 Max and Kobra X, Flashforge Creator 5 and Creator 5 Pro, Prusa CORE One L+ and XL+); existing product records and current UK-new evidence were present, so no duplicates were created. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.

## Nikon UK used-market batch 12 (5 November 2026)

Added 11 UK-used GBP observations to existing LIVE Nikon products, after confirming each target had no active uk_used evidence. Products and observations: COOLPIX A1000 £469 MPB (65c729b6-5687-412f-bd5e-77dae918bf32); COOLPIX A900 £314 typical asking price UsedLens (25d94af4-f980-4e3f-bbc9-02ff05a160d7); COOLPIX AW130 £136 Camera Price Buster (3ee1bf4e-60a7-4076-ae9f-4e7dd46f5a41); COOLPIX B600 £117 Camera Price Buster (4002a802-8c18-4c2b-aa77-ff33960510f8); COOLPIX B700 £149 MPB (fd57a326-f27c-4e5d-86aa-327577eec95c); D3300 £114 MPB (129b8360-c6bf-4f20-9ad2-68c3124eb8c4); D3500 £79 MPB (e9094cc1-c5a1-49bc-aca5-5ead51a3cb2d); D5500 £249 MPB (de3bc53e-557a-4968-a249-c885e8b05735); D610 £259 MPB (54ef7e4b-bcb3-4794-974b-58f04d330a9b); D700 £199 MPB (e202198b-e1da-40c9-a53c-4946a395669f); D7100 £279 MPB (4320609c-e5ce-4970-b398-2a0f80f554f1). Prices are observed low-end used retailer asks or typical asking price as noted, not sale prices or dealer acquisition offers. All 11 inserts returned evidence IDs; independent read-back is pending.

Research references: MPB Nikon DSLR category https://www.mpb.com/en-uk/category/used-cameras/dslr-cameras/nikon-dslr-cameras and page 2 https://www.mpb.com/en-uk/category/used-cameras/dslr-cameras/nikon-dslr-cameras?page=2; MPB compact category https://www.mpb.com/en-uk/category/used-cameras/premium-compact-cameras/nikon-compact-cameras; A1000 https://www.mpb.com/en-uk/product/nikon-coolpix-a1000; UsedLens A900 https://usedlens.co.uk/product/nikon-coolpix-a900; Camera Price Buster https://tempdns.camerapricebuster.co.uk/Nikon/Nikon-Compact-Cameras. LIVE only; TEST untouched. No master products, lifecycle flags, valuation logic, schemas, RLS, application, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment.


## Xbox controller follow-on note — 5 November 2026
The verified batch-2 state remains 28 active/customer-visible products and 34 active UK-new evidence rows covering all 28 products in both TEST and LIVE. A subsequent Shock Blue colour-variant insert succeeded in TEST only, but the corresponding LIVE write and verification were blocked by a connector/tool failure. Treat this one additional TEST record as an environment-parity exception; do not copy TEST data wholesale. Resolve by checking the exact TEST record and adding the equivalent LIVE record independently (or removing the TEST-only addition if product scope is reconsidered) before declaring the Xbox branches fully aligned. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes.


## Creality Ender-3 V4 Combo and Bambu Lab H3C — 5 November 2026

Added Bambu Lab H3C + AMS H3 Combo at the official UK launch price £2,199 including tax (official announcement 3 November 2026): https://blog.bambulab.com/tool-changer-game-changer-bambu-lab-presents-h3c-the-defining-new-generation-of-3d-printers/. LIVE product/evidence e33286e7-1083-41e5-8677-ce147bf754cd / bf9e3cba-d469-43d3-a0b2-5bf75b9f2bf3; TEST 9149695d-2cd7-428c-bf52-b22ac3d85245 / aeb43102-77aa-4934-bfd3-42ea0463bd65. This is the AMS H3 combo, not a standalone price.

Added Creality Ender-3 V4 CFS Combo using GM Crafts UK evidence £289 (was £349), Add to basket and free UK delivery: https://www.gmcrafts.co.uk/product/creality-ender-3-v4-combo/. LIVE product/evidence bbf4ef13-c073-4fe2-a1ed-54975e9151a8 / 401c9eaf-6153-45ab-add1-2f7bdcbbed30; TEST 2bcf22b1-a2fa-412c-81d8-6e074e95fd81 / 9a9177a2-e720-4e8a-8caa-f50771be7029.

Verified 3D Printers totals: LIVE 188 products / 181 active visible / 208 active evidence / 193 UK-new; TEST 189 / 181 / 208 / 193. Zero visible products missing active evidence in either environment. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment.

## Further 3D printer catalogue continuation — 5 November 2026

Added Flashforge Adventurer 5X independently to LIVE and TEST. The official Flashforge UK store lists £279.00 GBP, reduced from £449.00, as its entry-level multicolour printer. Source: https://uk.flashforge.com/ (official UK store homepage). Price observed 5 November 2026; delivery and final checkout availability to be confirmed in checkout.
- LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874; evidence 219b6262-fd23-4329-b22c-904387ea8e80.
- TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220; evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Also completed the prior Creality Ender-3 V4 CFS Combo addition at £289.00, sourced from GM Crafts UK (https://www.gmcrafts.co.uk/product/creality-ender-3-v4-combo/), with Add to Basket and free UK delivery shown. LIVE product bbf4ef13-c073-4fe2-a1ed-54975e9151a8 / evidence 401c9eaf-6153-45ab-add1-2f7bdcbbed30; TEST product 2bcf22b1-a2fa-412c-81d8-6e074e95fd81 / evidence 9a9177a2-e720-4e8a-8caa-f50771be7029.

Verified recent-model coverage: Creality HALOT-X1 Neo and HALOT-X1 Max already have current UK-new evidence in both environments (Neo £199; Max £1,599); Flashforge CJ270 already exists with UK-new evidence; Anycubic Kobra 3 Max V2 standard and combo and Photon P1 Max already exist with active UK-new evidence; no duplicates were added. Existing Bambu Lab A2L/X2D, Anycubic Kobra S1 Max/Kobra X, Flashforge Creator 5/Creator 5 Pro, and Prusa CORE One L+/XL+ were also confirmed present with active UK-new evidence in the previous check. UK-new evidence remains the price source; UK-used stays reference-only.

Verified 3D Printers totals after this continuation:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Visible products missing evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 189 | 182 | 209 | 194 | 15 | 0 |
| TEST | 190 | 182 | 209 | 194 | 15 | 0 |

Both environments: zero duplicate product keys. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required. TEST and LIVE were updated independently.

## TEST parity reconciliation — Nikon batches 11–12 (5 November 2026)

Correction to the earlier LIVE-only note: the Nikon used-market evidence from batches 11 and 12 has now been mirrored into TradeFlow TEST wherever the corresponding product exists. TEST product IDs differ from LIVE IDs; records were matched by exact model and package, not by copying database identifiers.

TEST verification: added matching evidence for D750 £450 (13255492-b7ce-4941-92db-d1679b2a9c03), COOLPIX P1000 £744 (8affa3f7-4344-40bb-89d6-e41d6079e887), COOLPIX A1000 £469 (5222d2ec-b40a-43ed-89c7-ee3f65b273da), A900 £314 (373add1f-68de-4b52-a5b6-e3943380dc9d), AW130 £136 (ec6f4c41-a803-4c6c-9598-20bc79d05006), B600 £117 (f0a5be26-46da-4f5e-967b-c8e419a7fc22), B700 £149 (10447eed-76fd-4cf7-b765-594787fd4d2a), D3300 £114 (cd171797-e940-4017-9b7c-a01b4b6c4abe), D3500 £79 (6f96661f-c2c6-445c-af37-51b692119f00), D5500 £249 (1f6cc769-30f1-441e-8991-e65e243e3aa9), D610 £259 (d7bb3d12-2abb-4f23-b47a-a3ead6cbb1a0), D700 £199 (daf3ea49-68f9-4876-9ce8-6e4bd7c928c3), and D7100 £279 (5f859dc4-930f-422f-b888-8ff6174dea09). All 13 rows were independently read back and confirmed active, GBP, used, with source URLs.

TEST already contained older D3300 and D7100 used observations at different prices (£99 and £209); these were retained, and matching current observations were added rather than overwriting history. The Nikon catalogue has aligned matching observations for all 13 LIVE batch-11/12 targets in both environments. TEST-only unrelated records were not copied. No deployment or application, schema, valuation, RLS, Stripe, tenant, customer, order or payment changes.


## Additional 3D printer catalogue additions — 5 November 2026

Added Flashforge Adventurer 5X standard multicolour printer at £279.00 GBP (official UK store price reduced from £449.00): https://uk.flashforge.com/. LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874 / evidence 219b6262-fd23-4329-b22c-904387ea8e80; TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220 / evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Added distinct Anycubic Kobra X Combo (base 7-colour package, expandable to 19 colours) at £429.00 GBP: https://uk.anycubic.com/products/kobra-x-combo-3d-printer. Official product page states ships in 24 hours and free express shipping. LIVE product 634078d8-39d8-4bf1-b01a-c391f481d4ec / evidence 14e0207a-f4d0-4d17-bd1b-9bc52078a976; TEST product 834e5612-67da-4ad2-be67-1bf4b638ea7d / evidence da4e3863-e612-4654-b706-69fe76cf3e20.

Also completed the previous Ender-3 V4 CFS Combo addition at £289.00 from GM Crafts UK; product/evidence IDs and source are recorded in the immediately preceding continuation section. Verified that HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) already have current UK-new evidence in both environments; no duplicates were created. Flashforge CJ270 and Anycubic Kobra 3 Max V2 / Photon P1 Max already have active UK-new evidence in both environments.

Verified 3D Printers totals after this batch:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Missing visible evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 190 | 183 | 210 | 195 | 15 | 0 |
| TEST | 191 | 183 | 210 | 195 | 15 | 0 |

Both environments have zero duplicate product keys and zero active visible products missing evidence. UK-used remains reference-only and excluded from automatic valuation. LIVE and TEST were updated independently. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant/customer/order/payment changes. No Worker deployment required.

## Gaming console catalogue continuation — 5 November 2026

The Gaming Consoles & Accessories catalogue was continued in both TEST and LIVE. A separate Nintendo Switch 2 The Legend of Zelda 40th Anniversary 256GB console master was added at £429.99 UK-new (Smyths Toys UK). The existing Zelda 40th Anniversary Pro Controller now has three independent retailer observations: Argos £64.99, Currys £74.99 and Smyths £79.99. Xbox Wireless Controller — Shock Blue was mirrored from TEST into LIVE with its £59.99 Argos UK-new evidence. Three exact PlayStation handheld observations (PSP-2000 £69.43 sold, PSP Go £140 listed, PS Vita OLED £138.98 sold) were mirrored into LIVE. Three existing evidence rows with null URLs were repaired using direct retailer URLs.

Final independent verification in both environments: 277 active master products, 269 active customer-visible products, 376 active evidence rows (211 UK-new / 165 UK-used), one visible product without any evidence, zero evidence integrity failures and zero duplicate active source keys. The single no-evidence product is WD_BLACK C50 Expansion Card 512GB (Xbox Accessories); continue sourcing an exact UK price rather than inventing one. A further 85 visible products lack UK-new evidence; do not infer new prices for older/used-only products.

All additions are separate environment-specific records. UK-used evidence remains reference-only and does not affect automatic buying valuation. Database-only work: no app code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment or Cloudflare Worker changes; no Worker deployment. Exact IDs and source keys are in `CHECKPOINTS/2026-11-05-gaming-console-catalogue-continuation-batch-01.md` and the aggregate gaming memory file.


### WD_BLACK C50 512GB evidence gap closed — 5 November 2026

Added the missing UK-new observation for the exact WD_BLACK C50 Expansion Card 512GB product in TEST and LIVE at £169.99. Source: disks.co.uk Amazon UK price tracker, https://www.disks.co.uk/drive/wd-black-c50-storage-expansion-card-for-xbox-series-x/B0C44B1VSH. Stable key: disksco-wd-black-c50-512gb-uk-new-20261105. LIVE evidence fbe726d0-7a02-4652-ae29-84468640d38c; TEST evidence 107c14fb-5c2a-4921-b858-a36a8a35a477. The tracker states its Amazon UK feed refreshed within minutes, but the Amazon detail page was not independently accessible during capture. The £169.99 observation is 55.4% above the displayed 30-day average (£109.37); retain the caveat and do not treat it as a representative market value or confirmed checkout price.

Final gaming catalogue verification now matches in both environments: 277 active products, 269 active visible products, 377 active evidence rows (212 UK-new / 165 UK-used), zero visible products missing all evidence, zero active evidence integrity failures and zero duplicate active source keys. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/Worker changes; no deployment. Updated checkpoint and aggregate memory record the exact IDs and caveat.


## Nikon used-market batch 13 — LIVE and TEST (5 November 2026)

Added and independently read back four new UK used-market evidence observations in each environment, matched by exact camera model:
- COOLPIX 3100 typical asking price £30 UsedLens UK: LIVE 10e4ff05-0710-462a-8c70-6cafd1de83c3; TEST f2c526fc-c0be-411a-9cb0-223467fe3e67. Source https://usedlens.co.uk/product/nikon-coolpix-3100 (62 tracked listings; typical £30, current low £15).
- Nikon D200 £70 UsedLens UK: LIVE fdc6aea3-844b-486d-b29f-4948975aa035; TEST 0082b667-78bd-4662-906e-8ef5f6f50673. Source https://usedlens.co.uk/product/nikon-d200 (low £70; typical across grades £123).
- Nikon D800 £194 UsedLens UK: LIVE a70ae87f-a68b-4033-818f-8b300f3c20cd; TEST e9c238e1-9b1b-434f-82e0-6cc842e18b90. Source https://usedlens.co.uk/product/nikon-d800 (low £194).
- Nikon D300 £32 MPB UK: LIVE 90113520-8ec8-4310-aab6-e8a9b914df11; TEST 5b507a8a-f49b-4148-9b30-3b8a32fc3b65. Source https://www.mpb.com/en-uk/category/used-cameras/dslr-cameras/nikon-dslr-cameras?page=2.

All eight new rows independently verified active, GBP, used, with source URLs. Existing TEST D200 £99 and D300 £76 observations retained; no overwrites. LIVE and TEST now contain the matching new observations for these four models. No Worker deployment, schema or valuation changes, and no unrelated TEST data copied.


## Nikon used-market batch 14 — LIVE and TEST (5 November 2026)

Added seven UK used-market asking-price benchmark observations in each environment (14 rows total), each attached to the exact existing COOLPIX model. Source: UsedLens UK Nikon guide, updated 5 November 2026 (https://usedlens.co.uk/guides/cameras/nikon). Values are the guide's typical asking prices, not verified completed-sale prices or dealer acquisition values:
- COOLPIX 4500 £67
- COOLPIX 5000 £55
- COOLPIX 8400 £62
- COOLPIX P300 £155
- COOLPIX P510 £116
- COOLPIX P530 £108
- COOLPIX P610 £209

All 14 records were independently read back from their respective LIVE and TEST databases as active GBP uk_used evidence with source URLs. The same seven models and values now match across environments. No existing evidence was overwritten. This batch only changes shared market evidence; no product catalogue, lifecycle, schema, valuation, RLS, application, Worker, Stripe, tenant/customer/order/payment data was changed and no deployment was made. These guide prices are indicative used asking-price benchmarks only.

 
## Gaming catalogue continuation — batch 02, 5 November 2026

Added six new active, customer-visible gaming master products across Nintendo Switch 2 controllers and accessories in both TEST and LIVE: PowerA Pokémon Mega Evolutions controller (£39.99), Venom 10-in-1 sports pack (£29.99), PowerA Mario & Yoshi wireless controller (£39.99), PowerA Dark Heather Grey Slim Case (£14.99), PowerA Mario & Yoshi Protection Case (£14.99 promotional price) and SanDisk Mario 256GB microSD Express card (£44.99). Each has a Smyths UK-new evidence row and an exact package key. Existing records were checked first; no duplicate product masters were created.

Added further Smyths/Argos UK-new evidence to existing masters: Joy-Con 2 Light Purple/Light Green pair (Smyths £64.99; Argos £64.95 retained), Gioteck WX5+ Dark Camo (Argos £21.99; Smyths £24.99 retained), DualSense 007 First Light Limited Edition (Smyths £69.99; PlayStation UK £74.99 retained), DualSense GTA VI White Limited Edition (Smyths £74.99; PlayStation Direct £74.99 retained), and Xbox Forza Horizon 6 Limited Edition controller (Smyths £69.99; Argos £69.99 and Currys £84.99 retained).

Final independently queried totals match in both environments: 283 active gaming products, 275 active visible products, 388 active evidence rows (223 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures and zero duplicate active source keys. Branch-level product/visible/evidence counts match across all 20 gaming branches. This batch added 6 product masters and 11 evidence rows to each environment.

UK-used remains reference-only and does not affect automatic buying valuation. No application code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment. Exact IDs, source keys, source URLs and variant notes are recorded in `CHECKPOINTS/2026-11-05-gaming-catalogue-continuation-batch-02.md`.


## Nikon used-market batch 15 — LIVE and TEST (5 November 2026)

Added three matched used-market evidence records in each environment (six total), all independently read back as active GBP uk_used rows with exact model links and source URLs:
- Nikon D300s £130 typical asking price, UsedLens UK, 70 listings across six retailers: https://usedlens.co.uk/product/nikon-d300s. LIVE 3254200a-91c3-4c65-b15d-65bf3564ad60; TEST 5ea5fca3-6ff7-4a76-85e3-ea3bef25cdeb.
- Nikon D800E £394 lowest available working MPB UK example; three used bodies listed £394–£434: https://www.mpb.com/en-uk/product/nikon-d800e. LIVE 9162dd66-f8a8-4dcb-b1a0-6a10d92c2b3c; TEST 54c659e9-5eab-4c31-8f44-5e6f8e27e833.
- Nikon D810 £472 typical asking price across grades; 66 listings, with lowest working listing £329: https://usedlens.co.uk/product/nikon-d810. LIVE 3ee3ac97-aa4f-4a47-9c7c-e5d853dc36ea; TEST acd776b0-6238-4406-bb35-a5e40a9baaf1.

All six rows were independently verified in their respective databases. Same models and evidence values now match across LIVE and TEST. No prior rows overwritten. Prices are used asking-price references, not dealer acquisition values. No schema, product-master, lifecycle, valuation, RLS, application, Worker, Stripe, tenant/customer/order/payment changes and no deployment.


## Gaming catalogue continuation — batch 03, 5 November 2026

TEST was updated and independently read back before the matching LIVE write. Added one active, customer-visible Nintendo Switch 2 AC Adapter master to Nintendo Accessories, exact package single-ac-adapter-black, with four active UK-new GBP retailer observations: Smyths £21.99, Currys £21.99, EE £19.99 and Argos £24.99. The official adapter is the black replacement power supply with detachable cable, compatible with the Switch 2 console and dock.

Added Smyths UK-new observations to the existing Switch 2 Joy-Con 2 Charging Grip (£29.99) and Joy-Con 2 Wheel Pair (£14.99) masters in both existing catalogue branches (Nintendo Accessories and Nintendo Controllers). No new masters were created for these already-catalogued products. The wheel pair is two magnetic wheel adapters; Joy-Con controllers are not included. The charging grip is sold separately from Joy-Con controllers. The existing used grip observation and all previous retailer evidence were retained.

Sources:
- Smyths AC Adapter £21.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-ac-adapter/p/249615
- Currys AC Adapter £21.99: https://www.currys.co.uk/products/nintendo-switch-2-ac-adapter-10281817.html
- EE AC Adapter £19.99: https://ee.co.uk/products/nintendo-switch-2-ac-adapter
- Argos AC Adapter £24.99: https://www.argos.co.uk/product/7624812/
- Smyths Joy-Con 2 grip and wheel listing: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203

Environment-specific IDs:
- AC Adapter product: TEST e54ae54b-1e58-4be5-9b0a-56142d941244; LIVE 26987446-1a04-4f2a-8970-72079a0a583f.
- AC Adapter evidence (Smyths, Currys, EE, Argos): TEST 4dd4eac2-de01-4d1f-82dc-2d42ae9678fa, 1b9462ae-807d-4e4a-81d6-5221d92b37ff, a334b8de-de3b-4350-8de4-d9231f536798, 5c20cf58-b9dd-482e-9329-a3ef1f89fee9; LIVE 1884d558-e2f7-4add-8ca3-088ed1bf9796, 41b8ab83-e760-49a9-a4f1-72dee2a14738, 101751bd-efb4-4d66-abb9-94c8650aec83, 31f2a943-8fa3-414d-8cf0-9a439b9b461f.
- Charging Grip Smyths evidence (Accessories branch): TEST d8669b3f-4552-4780-a6ba-ef2cd8b11604; LIVE 3d4156cf-edf7-4148-b10c-f17fcc92cc5a. Controllers branch: TEST f133249c-ab0d-4f20-9331-052271a61f83; LIVE f04cb182-882c-45d1-a712-a70119478300.
- Joy-Con 2 Wheel Pair Smyths evidence (Accessories branch): TEST 9239582f-f8ce-4c63-ba8f-61e045134884; LIVE c319a31e-0382-4397-9c2e-93a78c094690. Controllers branch: TEST 75b5641d-a89c-4f6d-880b-3e81f3afa745; LIVE 2381ed36-361c-4ef3-a2fa-88b48a533d7b.

Independent post-write verification in both databases: 284 active gaming products, 276 active customer-visible products, 396 active evidence rows (231 UK-new / 165 UK-used), zero visible products missing all evidence, zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branch counts match between LIVE and TEST. Nintendo Accessories now has 10 active products / 10 visible / 16 evidence; Nintendo Controllers has 105 / 105 / 119. The eight added evidence rows are all UK-new GBP; no existing UK-used evidence was changed. UK-used remains reference-only and does not feed automatic buying valuation.

No application code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment. No TEST business data copied to LIVE. Exact TEST/LIVE product and evidence IDs are environment-specific as listed above.


## Nikon used-market batch 16 — LIVE and TEST (5 November 2026)

Three matching used-market evidence observations were inserted and independently read back in both environments (six records total):
- Nikon D7000 £181 typical asking price, UsedLens UK, 105 listings across 11 retailers. LIVE 33ee8b28-73f5-4f9d-aa3f-0e2d10214634; TEST 79958913-99a3-4042-a4a4-bf4e559e8437. https://usedlens.co.uk/product/nikon-d7000
- Nikon D7200 £440 typical used asking price, CamCompare UK. LIVE 6de0370e-bd1b-4be7-bfe5-505ea17f6a2d; TEST 0f332083-80f0-413c-a4f9-bdac95ba7b37. https://www.camcompare.app/uk/cameras/nikon-d7200
- Nikon D5600 £370 typical asking price across grades, UsedLens UK, 90 listings across 10 retailers. LIVE 39740339-06d9-48ac-99ea-a2774a4ceb57; TEST 1d432186-57fc-4c41-bca5-a2f942c73d57. https://usedlens.co.uk/product/nikon-d5600

All six records independently verified active, GBP, uk_used and carrying the expected source URL. Same three models and values now match across LIVE and TEST. These are used asking-price benchmarks, not completed-sale prices or dealer acquisition offers. No previous evidence was overwritten. No schema, product-master, lifecycle, valuation, RLS, application, Worker, Stripe, tenant/customer/order/payment changes; no deployment.


## Gaming catalogue evidence continuation — batch 04, 5 November 2026

Added five active UK-new GBP retailer observations to the existing Nintendo Switch 2 Camera master in Nintendo Accessories; no duplicate product master was created. Captured prices: Smyths £34.99 promotional (was £44.99; Click & Collect in stock, delivery unavailable), Argos £49.99, Currys £44.99, John Lewis £44.99 and EE £45.00. The camera remains a separate Switch 2 USB-C camera product; its existing UK-used Cash Converters £19.99 observation was retained and remains classified as used/reference-only.

Sources:
- Smyths £34.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-camera/p/249607
- Argos £49.99: https://www.argos.co.uk/product/7624599
- Currys £44.99: https://www.currys.co.uk/products/nintendo-switch-2-camera-10281819.html
- John Lewis £44.99: https://www.johnlewis.com/nintendo-switch-2-camera-black/p113587836
- EE £45.00: https://ee.co.uk/products/nintendo-switch-2-camera

Evidence IDs: TEST b5e9070b-2065-4ce1-808f-c7c50f2a7678 (Smyths), 5f85d615-b670-4931-ae43-3f8998772a09 (Argos), a100d555-6e54-4a78-9fcc-0a684fc138e5 (Currys), c6637563-09c3-4bf2-ac03-a29f6aa588c2 (John Lewis), 97bc47e7-7811-48d2-9c3b-f1656bb97992 (EE). LIVE: f5d15edd-57a9-461c-9bc0-269b1b77a9df (Smyths), 1727641c-7c81-4669-b3f8-8480c942737f (Argos), 1780870e-ec5a-407b-9557-0555dbb6b4d2 (Currys), f67f0592-b4d0-4466-be75-dc260ff51804 (John Lewis), c4c82385-dbb6-4282-81ef-5e561215d3a9 (EE).

Post-write verification in both environments: 284 active gaming products, 276 active customer-visible products, 401 active evidence rows (236 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branch counts match; Nintendo Accessories now has 10 active products / 10 visible / 21 evidence. No product master, code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. UK-used remains reference-only and does not affect automatic buying valuation.


## Nikon used-market batch 17 — LIVE and TEST (5 November 2026)

Added a second, independently sourced UK used-price observation for the exact Nikon D7200 model in both environments: MPB UK currently lists 45 used units from £254 to £514. The £254 lowest-listing floor was added as active GBP uk_used evidence, explicitly labelled as a listing floor rather than typical value or completed sale price. LIVE evidence ID a0c9d41c-5504-44aa-ae52-62403c1b3ecc; TEST evidence ID efefd555-537e-4f6a-b4e0-9bbbf91b22f5. Source https://www.mpb.com/en-uk/product/nikon-d7200. Both rows independently read back with the exact D7200 product, GBP currency, source URL and active flag. Existing £440 typical asking-price evidence was retained. MPB's current UK Nikon DSLR category also shows D7500 10+ used units at £299–£594, but no active exact D7500 product exists in either database, so no mislinked evidence was created. No schema, product-master, lifecycle, valuation, RLS, application, Worker, Stripe, tenant/customer/order/payment changes and no deployment.


## Nikon used-market batch 18 — LIVE and TEST (5 November 2026)

Added a second UK used-market price observation for Nikon D5600 in both databases: MPB UK category snapshot shows 10+ D5600 bodies from £194 to £424. The £194 floor is explicitly a category-page listing floor, not a typical price or condition-normalised benchmark. LIVE evidence b252dba1-fc47-452e-afa2-c7728c163deb; TEST a55dc2c6-9390-4030-b7ee-1f363416e8ff. Source https://www.mpb.com/used-equipment/used-photo-and-video/used-digital-slr-cameras/. Both records independently read back active, GBP, uk_used, exact Nikon D5600 product and source URL. Existing £370 typical UsedLens benchmark retained. Current UsedLens D7500 index: 62 listings from six retailers, low £424, typical £529; MPB has 18 listings from £299 to £594. However no active exact Nikon D7500 product exists in either LIVE or TEST, so no evidence was attached to a different model. No product/schema/valuation/lifecycle/RLS/application/Worker/Stripe/tenant/customer/order/payment changes; no deployment.


## Gaming catalogue evidence continuation — batch 05, 5 November 2026

Added three active UK-new GBP observations in TEST, then the matching independent LIVE records, reusing existing masters only:
- Nintendo Switch 2 Carrying Case & Screen Protector bundle: Smyths £17.99 promotional (was £19.99; category listing) and Currys £20.99 (product code 539477). Existing Argos £19.99 observation retained. Sources: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203 and https://www.currys.co.uk/products/nintendo-switch-2-carrying-case-and-screen-protector-black-10281818.html
- HORI Wireless HORIPAD Turbo — Kirby & Waddle Dee: Smyths £39.99, in stock with delivery and Click & Collect shown. Existing Argos £64.99 listing retained as a separate retailer observation. Source: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/hori-wireless-horipad-turbo-for-nintendo-switch-2-kirby-and-waddle-dee/p/259385

IDs:
- Carry Case Smyths evidence: TEST 8b79c8ab-ba49-4f63-8820-330505ff31e9; LIVE 36d02bcf-2c54-4351-bffc-61af9f833b4d.
- Carry Case Currys evidence: TEST 4e27b24f-644d-4956-9e57-9c539f4889ff; LIVE ec8f5e06-5362-45de-aab7-934b064893d5.
- HORI Kirby Smyths evidence: TEST 26873d05-eea3-47cd-aa77-703dd61540b5; LIVE 85f80133-13c5-404a-ade1-f5ad25ac06a6.

Both environments independently verified: 284 active gaming products, 276 customer-visible products, 404 active evidence rows (239 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures, zero duplicate active source keys. All 20 gaming branches match. Nintendo Accessories: 10 products / 10 visible / 23 evidence; Nintendo Controllers: 105 / 105 / 120. Three UK-new observations added per environment; no new product masters or used-market rows in this batch. UK-used remains reference-only and does not affect automatic buying valuation.

No application code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. TEST and LIVE records were created independently; no business data copied between environments.


## Nikon used-market batch 19 — D7500 (5 November 2026)

Located the exact Nikon D7500 master product in both databases (LIVE b5e2b666-2972-471d-a65c-cfdb2cc72157; TEST d26560b8-6674-4048-8ed3-db84377fd393). The earlier statement that no D7500 master existed was incorrect: the model is stored as `D7500`, not `Nikon D7500`. Added two matching UK used observations per environment from the current UsedLens D7500 guide: £529 typical asking price across grades (62 listings, six retailers) and £424 lowest current listing (listing floor only). LIVE evidence IDs ae06f5a7-0066-4264-a17b-9a61ce4e9906 (£529) and 004ce679-c24d-46b9-a99e-b26be639c6b7 (£424); TEST IDs 13b05cc5-1f61-400a-8161-6325d5e551a4 (£529) and f6ec319e-733f-4501-936f-35bad0fc4431 (£424). All four independently read back active and GBP. Source https://usedlens.co.uk/product/nikon-d7500. Existing market evidence retained. MPB D5300 (26 used units, £174–£284) and D3400 (9 units, £209–£269) researched, but exact active master products were not found in either environment; no evidence was misattached and no product masters were created in this evidence-only batch. No app/schema/RLS/valuation/lifecycle/Stripe/tenant/customer/order/payment/Worker changes; no deployment.


## Gaming catalogue expansion — batch 06, 5 November 2026

Added a distinct HORI Piranha Plant Camera for Nintendo Switch 2 product master to Nintendo Accessories in TEST, verified, then independently added the matching master to LIVE. It is a different product from Nintendo's official Switch 2 Camera: the HORI model is the plant-shaped detachable camera with flexible neck, Warp Pipe base, adjustable clip, USB-C cable and 3.5mm adapter. Exact package key piranha-plant-camera-green.

Five active UK-new GBP observations per environment:
- John Lewis £22.95, product code 82685414, two-year guarantee: https://www.johnlewis.com/nintendo-hori-piranha-plant-camera-for-nintendo-switch-2/p113587839
- Argos £33.99, product 762/4609: https://www.argos.co.uk/product/7624609/
- Very £33.99, item WH6QM: https://www.very.co.uk/nintendo-switch-2-piranha-plant-camera-for-switch-2/1601136130.prd
- GAME £33.99, currently out of stock: https://www.game.co.uk/nintendo-nintendo-piranha-plant-camera-for-nintendo-switch-2-753575
- Selfridges £39.99: https://www.selfridges.com/GB/en/product/hori-piranha-plant-camera-for-nintendo-switch-2_R04473556/

IDs: product TEST d7e37ea0-1191-4e57-9693-3600b609da06; LIVE 0dede96e-8cb7-4dc6-82df-507999c5820c. Evidence TEST John Lewis 50615da5-c5b3-477e-bdcf-57ae77165e91; Argos 23bd205f-dc34-4eba-a822-fa9613e2106c; Very cc18c1b3-0016-4731-ab17-97b38224ca16; GAME 2df85e9b-6a60-4f97-8d37-92e387c05714; Selfridges c09b43c1-1947-46aa-b280-de134e7e8dc1. LIVE John Lewis 0a5dd84e-6156-4160-9057-6a6d7343ef4f; Argos 108da92a-af16-46a6-ba76-090b7920a77b; Very c16ab86b-e25d-463a-bae4-d43cae7ecb00; GAME 82878b4a-398f-4167-b9b1-f970d1ed1f4d; Selfridges 158e7cdf-3d58-4f4a-abda-4c5795ce976a.

Both environments independently verified: 285 active gaming products, 277 active customer-visible products, 409 active evidence rows (244 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures, zero duplicate active source keys. All 20 gaming branches match. Nintendo Accessories now has 11 active products / 11 visible / 28 evidence. Five new UK-new evidence rows and one product master added per environment. UK-used remains reference-only and does not affect automatic buying valuation.

No application code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. TEST and LIVE records created independently; no customer or tenant data copied.


## Nikon used-market batch 20 — D7500 condition-specific listings (5 November 2026)

Added two additional MPB UK D7500 asking-price observations in both databases, sourced from the current UsedLens retailer index: Good condition £424 and Excellent condition £494. These are live retailer asking prices for specific condition grades, not completed sales or dealer acquisition offers. Source https://usedlens.co.uk/product/nikon-d7500 (index lists 62 current listings across six retailers). LIVE evidence IDs: 6371cea1-4473-4863-9c6f-d2a7d95a209d (£424 Good), 8a98a13a-4af3-4842-a560-a6671cd7efdb (£494 Excellent). TEST IDs: 2db171d9-6f4d-48eb-81bd-baf1b56f5dc5 (£424 Good), b5289924-2c0c-4899-95b9-9db347fe3179 (£494 Excellent). All four independently read back active, GBP, used. Earlier typical £529 and low £424 evidence retained. MPB D5300 (26 listings £174–£284) and D3400 (9 listings £209–£269) researched but neither exact active product master was found in LIVE or TEST; no mislinked evidence or unrequested master creation. No schema, RLS, app, valuation, lifecycle, Stripe, tenant/customer/order/payment/Worker changes; no deployment.



## Gaming console catalogue continuation — batch 07 (5 November 2026)

TEST was written first and read back before the independent LIVE insert. Four UK-new GBP retailer observations were added to existing Xbox console masters; no product masters or package records were created or altered:
- Xbox Series S 512GB Standard Console: Argos UK £429.00, https://www.argos.co.uk/product/5812657; Currys UK £429.00, https://www.currys.co.uk/products/microsoft-xbox-series-s-512-gb-ssd-10205195.html.
- Xbox Series X 1TB Disc Edition Console: Argos UK £669.99, https://www.argos.co.uk/product/4881139; Smyths Toys UK £669.99, https://www.smythstoys.com/uk/en-gb/gaming-and-tech/xbox-series-x-s/xbox-series-x-s-consoles/xbox-series-x-1tb-console/p/192012.

All four records are uk_new, GBP, condition New, availability listed, with unique source_record_key values and observation date 5 November 2026. TEST evidence IDs: 9b48d535-fe7f-4fde-83fa-b3442c139202, 1398c15d-85f0-4661-9334-2e9ef52d4a8c, d375b578-8396-4135-85f8-e190f65f5f3b, 4e55d92b-3701-4620-bc21-da35836822f5. LIVE evidence IDs: 0085700e-20b1-423b-bc43-0d622cd31b60, 8c5eee05-af3b-464a-86af-5343618af7ae, ed8db4e0-8351-4a40-a3ad-a426178446a9, 805e0908-530a-4871-8541-b2800fd2b329. Product/evidence UUIDs are environment-specific; matching was performed by exact model/package keys within each environment.

Independent post-write verification: TEST and LIVE each have 285 active gaming products, 277 customer-visible products, and 413 active gaming evidence rows (248 UK-new / 165 UK-used). No visible product is missing all evidence; 81 visible products still lack UK-new evidence and 182 lack UK-used evidence. Zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branches have matching active and visible product counts between environments.

No schema, RLS, RPC, Edge Function, valuation, customer/tenant/order/payment/Stripe/subscription/domain data, application code, Worker or deployment changes. UK-used evidence remains reference-only and does not affect automatic buying valuations. Continue with product-specific UK retailer and UK second-hand research; do not invent or misattach evidence to a similar model or bundle.


## TradeFlow Deep Source Research architecture preflight — 5 November 2026

A dedicated TradeFlow research system is now the target; the old GearCashOut supervisor/configuration/desktop are not the foundation. Preserve the existing local Ollama and Gemma 3:4B installation. Ollama responds at 127.0.0.1:11434 and /api/tags/ returns gemma3:4b; the old Gemma Desktop UI at 127.0.0.1 is unavailable but is not required.

The new system must use one coordinator and configurable concurrent workers (start with two), share one local Gemma service, traverse every active category -> branch -> product in bounded pages, and explicitly process products without a branch. Exclude Pokémon Trading Cards (23,780 active products) from all task generation and writes. The current master schema has category_id and branch_id; it does not provide recursive parent_id levels on these category/branch tables. Do not assume parent search includes branches.

Use platform catalogue tables catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers and catalogue_master_products. Use shared_market_evidence only for trusted platform evidence ingestion; tenant_buying_research is subscriber-specific and is not the global evidence destination. Existing buying-research.js is a manual tenant UI; existing tradeflow-assistant research mode only performs tenant-scoped lookup/approval and does not perform external research. Do not repurpose either for platform-wide ingestion. Public catalogue browse RPC is read-only and paginated, and must not be used as an ingestion route.

Baseline read-only counts: LIVE 28,387 active master products / 28,363 visible; TEST 28,396 / 28,371. Excluding 23,780 Pokémon products in each environment leaves 4,607 LIVE and 4,616 TEST non-Pokémon active products. Qualifying active GBP/source-URL evidence counts: LIVE 2,136 UK-new and 2,320 UK-used; TEST 2,298 UK-new and 2,532 UK-used. Category/branch parity gaps exist and must be reconciled by exact product/category/branch keys before broad automated ingestion; never bulk-copy entire catalogue or tenant/customer/transaction/domain/Stripe data. Product UUIDs differ between environments.

shared_market_evidence requires server-side trusted writes; unique key is (source_name, source_record_key). New service must keep service-role credentials off the PC, use a dedicated authenticated server-side API, write each environment independently, and verify each write. Used evidence remains reference-only and cannot alter automatic buying valuations. UK evidence GBP only; preserve exact package/model, source URL, observed_at, availability, condition and price-basis notes. Ambiguous matches go to review.

A Developer Diagnostic Roadmap was created at docs/TRADEFLOW-DEEP-SOURCE-RESEARCH-ROADMAP.md (commit b523fc661e1fa6e07531a1a46795a325108f940a). This is architecture/preflight only: no schema, RLS, Edge Function, application, valuation, tenant, customer, order, payment, Stripe, Worker or deployment changes have been made.


## Gemma Control Centre — 7 November 2026
The Platform Owner dashboard has a proposed Gemma Control Centre section on branch `feature/gemma-owner-control-centre-20261107`.

- UI files: `platform-owner-dashboard.html`, `platform-owner-dashboard.js`, `platform-owner-dashboard.css`.
- It reads LIVE telemetry through `platform_owner_get_ai_agent_control_centre(integer)` and displays agents, heartbeat freshness, task/candidate/evidence totals and activity events.
- The RPC checks for an active `platform_memberships` record; authenticated can execute, anon cannot.
- This first increment is deliberately read-only. LIVE has agent status/activity tables and the owner telemetry RPC, but does not have the task queue table or worker queue RPCs. TEST has those objects and the current Research PC worker polls TEST. Do not add task submission/pause controls to the LIVE dashboard until the worker control plane is migrated and verified.
- No database or production deployment changes were made in this increment. Branch is pending review.



## Gemma LIVE supervisor control plane — 7 November 2026

- The authoritative product research control plane is LIVE (gxsrajtqzdjvmceqcpgv). TEST remains for software development, migrations and regression tests; existing TEST queue data is retained and is not copied or deleted.
- LIVE now has platform_ai_agent_tasks and platform_catalogue_research_queue, with RLS enabled and direct anon/authenticated table access revoked. Worker RPCs are service-role-only. Dashboard RPCs require an active platform_memberships row.
- Platform Owner dashboard section: Gemma Control Centre. It submits tasks through platform_owner_enqueue_ai_agent_task, lists tasks through platform_owner_list_ai_agent_tasks, and reads the LIVE research review queue through platform_owner_list_catalogue_research_queue.
- Research PC worker code has been changed to poll LIVE and report telemetry to LIVE only. Gemma reads the approved source registry from LIVE and stages validated candidate rows in LIVE platform_catalogue_research_queue. It does not approve candidates or write catalogue_master_products / shared_market_evidence.
- The Research PC has NOT yet been updated or restarted with this code. Do not claim an end-to-end run until a new worker heartbeat and a dashboard-submitted task are observed in LIVE.
- This branch is a feature build, not a production deployment. The dashboard UI, worker changes and LIVE migration must pass CI and browser acceptance before promotion.
- LIVE category source routing remains fail-closed: the source registry must contain a matching category scope (or explicit universal *); no matching approved sources means no research is dispatched to an unscoped source.
- Do not copy TEST tenant/customer/order/domain/ownership/Stripe data. Do not change LIVE Stripe settings as part of this work.


## Category research source manager and editor usability — 7 November 2026

- LIVE Platform Owner dashboard category cards now open a category-specific website manager. Owners can list current sources, add an HTTPS website to the selected category, and enable/disable a source's category assignment. Universal `*` sources (Amazon UK and eBay UK) are shown as universal and cannot be accidentally removed from one category through this control.
- Source management uses owner-authenticated RPCs: `platform_owner_list_research_sources(text)`, `platform_owner_add_research_source(text,text,text,text,text,text)`, and `platform_owner_set_research_source_category(uuid,text,boolean)`. Functions verify an active `platform_memberships` row and validate the category/source fields.
- LIVE `catalogue_master_categories` already has one canonical 3D category: `3d-printers-equipment` / “3D Printers & Equipment”. The apparent duplicate cards came from two agent status records (`3d-printers` and `3d-printers-equipment`). Dashboard groups both records into one category card without deleting either agent or its history.
- LIVE already contains `pokemon-trading-cards` / “Pokémon Trading Cards”. It remains unlinked to research sources and no Pokémon research agent is created. It is displayed as a reserved category in the research centre.
- Public page editor's nested groups and repeated items are now collapsed by default and can be expanded individually.
- Subscriber-supplied AI providers were already rejected by `platform_owner_update_ai_settings` and the LIVE setting was already false. The dashboard no longer offers a subscriber provider selection or toggle and always submits `p_subscriber_provider_enabled=false`.
- The LIVE migration `20261107150000_platform_owner_category_research_source_manager.sql` was applied and committed to production. Existing TEST catalogue, tenants and queues were not changed.


## 7 November 2026 — Gemma LIVE batch controls and How It Works editor correction

- The LIVE Platform Owner Gemma Control Centre now replaces the one-product form with category and branch selection, product evidence coverage filters, research operation selection (UK new, UK used, or both), specialist agent selection where registered, and batch sizes of 10, 20, 50, 100 or all selected products.
- Product coverage is read from LIVE `catalogue_master_products` joined to LIVE `shared_market_evidence`. Counts distinguish active UK new and UK used evidence. Filters include missing new, missing used, missing both, missing either, has new and has used.
- Selected products are sent as one `tasks[]` payload through the existing owner-authenticated LIVE enqueue RPC. The existing worker processes each subtask sequentially. Candidate findings remain in the LIVE review queue; no automatic approval or evidence write is introduced.
- Added owner-authenticated RPCs `platform_owner_list_gemma_research_categories()` and `platform_owner_list_gemma_research_products(text,text,text,integer)`. Anonymous execution is revoked; authenticated execution is granted but each function validates active `platform_memberships` before returning catalogue data.
- The old Platform AI provider settings panel and navigation link have been removed from the Platform Owner dashboard. Subscriber-supplied AI remains disabled; the product positioning is the centrally operated TradeFlow AI Research Centre.
- The public TradeFlow How It Works page remains the text-only accordion page. The owner page editor now hides legacy `screenshots` and `visual_layout` image-box data for How It Works. The Examples visual editor no longer overrides the How It Works page editor's loader.
- The database functions were applied directly to LIVE and verified in `pg_proc`; anon cannot execute and authenticated can execute subject to the in-function owner membership check. The versioned SQL migration was added to production GitHub. The authenticated browser flow and Cloudflare production deployment still require live browser verification.


Batch-control safety note (7 November 2026): Pokémon Trading Cards remains a reserved master category and is deliberately excluded from the Gemma batch category selector until the owner explicitly links research sources and agents. The selector preserves unqueued selections when a smaller batch is submitted, so a 50-product selection can be worked through in successive 10/20-product batches without losing the remainder.

## AI Agent Common Room — 7 November 2026

The Platform Owner dashboard now includes a LIVE **AI Agent Common Room** alongside the Gemma AI Research Centre. It is the shared communication, instruction and learning workspace for Platform Owner, ChatGPT supervisor workflows and Gemma specialist agents.

- Owner dashboard: `platform-owner-dashboard.html` → **AI Agent Common Room**.
- Owner UI: `platform-owner-dashboard.js` functions `loadAiAgentCommonRoom()` / `postAiAgentCommonRoom()`; styling in `platform-owner-dashboard.css`.
- LIVE storage: `public.platform_ai_agent_messages`.
- Owner RPCs: `platform_owner_list_ai_agent_messages(text,text,integer,timestamptz)` and `platform_owner_post_ai_agent_message(...)`. Both require authenticated `auth.uid()` and active `platform_memberships`.
- Agent RPCs: `platform_ai_agent_list_messages(...)` and `platform_ai_agent_post_message(...)`. Both are service-role-only; direct table grants to anon/authenticated are revoked.
- Message types: instruction, handover, finding, question, learning_note and status_update. Messages may be grouped by thread, recipient, category and task. They are coordination records, not product-market evidence.
- Worker: `tools/tradeflow-gemma-agent/src/task-worker.mjs`. Code posts startup/task status, completion/failure and handovers, and can read the common instruction/learning feed.
- Current status: migration, dashboard and worker changes are in `feature/ai-agent-common-room-20261107`. Not yet applied to LIVE, merged, deployed or confirmed on the Research PC. Preserve the PC's dedicated `.env` and configured env-file path; never put service-role keys in browser code.
- A Common Room post does not create a queue task, approve evidence, import catalogue data, or alter valuation rules. Instructions must be implemented via the approved task queue/code. Owner/ChatGPT evidence review remains mandatory.
- TEST and LIVE remain separate. Common Room collaboration is designed for LIVE; no TEST business data is copied.

The public How It Works page remains a source-managed, ten-section text-only accordion in `how-it-works.html` and `how-it-works.css`. It is not an owner CMS field. Ask for a source change when the wording needs updating. Examples remains dashboard-editable.

## AI Agent Common Room — LIVE integration checkpoint — 7 November 2026

The persistent Common Room schema has been applied to TradeFlow LIVE using migration `20261107190000_platform_ai_agent_common_room`. Read-only privilege checks confirm:
- `platform_ai_agent_messages` exists with RLS enabled and zero direct anon/authenticated policies.
- Anonymous cannot execute owner or agent message RPCs.
- Authenticated can execute the owner-list RPC, which checks active `platform_memberships`.
- Only `service_role` can execute the agent read/post RPCs; authenticated cannot.
- No messages were seeded and no customer/tenant data was copied.

The dashboard UI, worker integration and manuals remain on branch `feature/ai-agent-common-room-20261107`. The Common Room has not yet been merged or deployed, and the PC worker has not yet been updated/restarted. Do not describe the round-trip as working until the worker starts, reads an owner instruction, posts a handover, and the owner dashboard displays that response.

## Documentation index — owner dashboard

The five dashboard manual links point to:
- System Handbook: `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- Human User Manual: `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- Subscriber Manual: `subscriber-website-manual.html`
- Backend User Manual: `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- AI Operating Manual: `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Backend Operations Manual: `docs/TRADEFLOW-BACKEND-OPERATIONS-MANUAL.md`. Gemma diagnostic roadmap: `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-GEMMA-RESEARCH-PIPELINE.md`.

## AI Agent Common Room architecture — current release boundary

The LIVE Common Room table and security functions are installed. Dashboard/worker code is still on feature PR; deployment and PC round-trip tests remain pending. Do not treat message history as evidence approval or task dispatch.


## Category-specific Gemma research sources — 7 November 2026
LIVE `platform_research_sources` now includes seven additional 3D-printer sources, assigned only to `3d-printers-equipment`: Gumtree UK and SecondHand.org.uk (`used_uk` marketplaces); Uni3Dverse and 3DGBIRE (`used_uk` used/refurbished dealers); 123-3D, iDig3DPrinting and 3DFLO (`new_uk` retailers). Existing Creality UK, 3D Prima, 3DJake, Amazon UK and eBay UK assignments remain. This is a LIVE registry data change, not a schema change. Search coverage is not yet proven merely by enabling a source: worker route probing, exact-model matching, page extraction, GBP/condition/availability validation and review-queue handoff must be tested per source. Do not copy these category assignments into unrelated categories.

Follow-up LIVE source additions, 7 November 2026: added Bambu Lab UK Official Store (`bambu-lab-uk.myshopify.com`) and Anycubic UK Official Store (`uk.anycubic.com`) as `manufacturer`/`official`, each assigned only to `3d-printers-equipment`. The category now resolves to 14 enabled UK sources when the two existing universal sources are included: 3 manufacturer official sources, 5 specialist new retailers, 2 used/refurbished dealers, 3 used marketplaces (including eBay), and 1 universal Amazon retailer. Important implementation constraint discovered in production worker: `probeApprovedResearchSources()` currently selects at most 12 sources and tries at most three URL patterns per source. The 3D-printer category now has 14 sources, so the worker cap can silently prevent some designated sites from being probed. Increase/replace this cap with a fair, observable source sweep before claiming all 14 are searched. Also correct Creality's K1-only `search_url_template`. Social sources (e.g. Facebook Marketplace) remain a separate discovery capability; do not treat login-gated/social post snippets as validated price evidence.

## First-agent rollout: 3D Printers & Equipment website playbooks and Common Room inbox — 7 November 2026
- A first category-specific website playbook has been added at `tools/tradeflow-gemma-agent/src/source-playbooks.mjs`, exclusively for `3d-printers-equipment`. It defines manufacturer, new-retailer, used/refurbished dealer and marketplace routes/navigation for Creality, Bambu Lab, Anycubic, Uni3Dverse, 3DGBIRE, 3D Prima, 123-3D, iDig3DPrinting, 3DFLO, 3DJake, Gumtree, SecondHand.org.uk, eBay UK and Amazon UK.
- Rule: search/category/collection pages are discovery only. Gemma must extract exact-model links, open individual product/listing pages, and validate model/package, UK GBP price, condition and availability before returning evidence. Accessories, consumables, upgrades, mismatched variants, sold/completed listings and unverified social snippets are not evidence.
- `probeApprovedResearchSources()` now uses website-specific routes, ignores a stale configured direct `/products/...` URL as a search route, and no longer caps the balanced category source sweep at 12. The 3D-printer source count can exceed 12; all category-approved sources are now included in the balanced new/used/official rotation. Up to five site-specific routes are attempted per source. Source attempts and route failures are reported through progress telemetry.
- The first Common Room inbox/reply behaviour is scoped only to `3d-printers-equipment`. The Research PC worker checks the LIVE Common Room at startup, before this agent's tasks, and while idle between queue polls. It replies to the owner's first-visit welcome message, acknowledges unanswered owner instructions, and drafts concise answers to unanswered questions with local Ollama. Replies are linked by `parent_message_id`, and existing replies are checked to avoid duplication. The existing worker still passes relevant owner/agent instructions into the extraction context; hard-coded evidence rules and owner approval gates remain authoritative.
- This does not yet enable automatic Common Room replies for other categories. Roll out one agent at a time after acceptance testing the 3D-printer agent.
- Updater now downloads/tests `source-playbooks.mjs` and `source-playbooks.test.mjs` alongside the existing worker files. No private `.env`, legacy GearCashOut config, Supabase schema, TEST tenant data, LIVE catalogue/evidence approval, Stripe or Cloudflare configuration was changed by this code branch.
- Deployment remains pending: merge the reviewed branch, run the updater on the Research PC using the existing TradeFlow install and exact existing TradeFlow `.env` path, stop the old worker cleanly, restart, then verify the 3D Printer Gemma greeting is posted as a threaded reply to the owner's Welcome message. Do not claim the behaviour is live until that round-trip is visible in AI Common Room.
- Known follow-up after acceptance: verify each website route against live pages, record per-site success/failure, improve pagination/load-more handling where needed, then enable the next category agent. Social-platform discovery remains a separate capability and must not be represented as implemented by this first rollout.


## 3D printer playbook route verification correction — 7 November 2026
- Live web inspection confirmed Gumtree UK uses the `gumtree.com/uk/srpsearch%2B...` route and its individual advert pages use `/p/...`; its `.com` host therefore needs an explicit UK-source allowlist entry, while evidence still must show GBP and a direct active UK advert.
- Confirmed the official Anycubic UK store has moved to `uk.anycubic3d.com`; the old `uk.anycubic.com` site stated its transition ended 15 October 2026. LIVE `platform_research_sources` now points to the current domain and product-search route, and the worker allowlist/playbook/tests match it.
- Confirmed Bambu Lab UK uses `bambu-lab-uk.myshopify.com`, 3DFLO is a UK retailer, Uni3Dverse has a dedicated used/refurbished catalogue, SecondHand has a dedicated second-hand 3D-printer category, and 3DGBIRE has an active reconditioned-printer collection. These routes are encoded in the first category playbook. Their actual Research PC extraction success remains pending acceptance testing.
- LIVE Creality `search_url_template` was corrected from the fixed K1 detail page to the UK search route `https://store.creality.com/uk/search?q={query}`. This prevents repeatedly treating the same K1 page as the category's search route.


## Research PC updater syntax-check failure — 7 November 2026
The first-agent updater downloaded the new source but stopped before backup/install because Node reported `SyntaxError: Invalid regular expression flags` in `src/agent.mjs` at the source-domain normalisation line inside `probeApprovedResearchSources()`. The committed line contained over-escaped slash sequences in a regex literal. Minimal correction: parse the approved source domain with `new URL()` and then normalise `hostname` with the existing `www.` removal; also correct an over-escaped whitespace regex in the nearby quoted-query normalisation. No source files were installed by the failed updater because all downloaded `.mjs` syntax checks run before backup/copy. Supabase task queue remained unchanged; no research task was created or rerun by the updater. Corrective fix is on branch `fix/gemma-3d-printer-regex-syntax-20261107` and must be merged before rerunning the Research PC updater. Preserve the user's existing TradeFlow `.env` and legacy GearCashOut configuration. Acceptance remains pending until the updater reports both test suites pass, then the worker is restarted and the 3D Printer Gemma Common Room welcome reply is observed.


## Gemma research failure analysis and navigation correction — 7 November 2026

### Observed LIVE run
- Investigated LIVE `platform_ai_agent_activity` for task `owner-research-again-b94e2225-c07b-4001-8dfa-cd045bf962fd-1794075404013` (queue task UUID `9f6f79db-4085-4638-8415-e2b654c03893`). It completed in about 84 seconds with 15 search candidates (10 DuckDuckGo, 5 approved-source), 4 initially eligible URLs, 1 price-bearing page fetched, 1 Gemma extraction call, 0 accepted evidence and 0 queue writes. No worker/task exception occurred.
- Source-level activity showed: 123-3D direct refurbished K1 result returned HTTP 404; eBay item fetch returned HTTP 403; iDig3DPrinting and 3DFLO search routes returned HTTP 404/empty results; Gumtree returned no exact-model links; Uni3Dverse collection fallback returned HTTP 500; Creality collection pages had no server-rendered matching links and the generic Shopify `products.json` fallback returned HTTP 404; 3DGBIRE and 123-3D Shopify collection JSON returned zero matching K1 products.
- Amazon's result was an AAX tracking URL leading to a Creality extruder/filament accessory. The search query text `keywords=Creality+K1` was included in `matchesTaskModel()` identity, allowing the unrelated accessory through the prefilter. The final evidence validator correctly rejected it because the page did not identify the K1 printer or provide qualifying visible GBP price/direct listing evidence.
- The single fetched price-bearing page therefore did not contain acceptable K1 evidence. The earlier known official Creality K1 product URL was not being passed back into Research Again as a seed URL, so the worker could miss a known exact-model product page while relying on current search indexing.

### Minimal code corrections on branch `fix/gemma-research-page-navigation-20261107`
- `matchesTaskModel()` now checks result title plus canonical hostname/path only; it ignores query strings so search terms and tracking parameters cannot turn accessories into exact-model matches.
- Amazon AAX sponsored/tracking links are unwrapped to the canonical `www.amazon.co.uk/.../dp/<ASIN>` page before eligibility/model checks.
- Collection expansion now uses Shopify's `/products.json` endpoint only when that website's playbook explicitly declares `collectionApi: 'shopify'`. Creality and Uni3Dverse are no longer sent to an incompatible Shopify endpoint; 123-3D and 3DGBIRE retain the declared Shopify fallback.
- Owner Dashboard Research Again now passes the existing candidate's `source_url` in `seed_urls`. The worker rechecks this URL only if it still belongs to a category-approved UK source and passes direct-product and exact-model checks; it is not trusted evidence and must be fetched and validated again.
- Owner Dashboard cache reference bumped from `platform-owner-dashboard.js?v=27` to `?v=28` so the seed-URL change is loaded.
- Added tests for query-string false positives, Amazon AAX canonicalisation, and per-site Shopify collection capability. The Research PC updater already runs both task-group and website-playbook test suites before install. These new tests have not yet run on the Research PC; deployment and a fresh product test remain pending.

### Safety and next verification
- No catalogue candidate was approved/imported, no LIVE/TEST catalogue data was changed, no Supabase schema or RLS was changed, and no `.env`, legacy GearCashOut configuration, Stripe or Cloudflare setting was touched.
- Next step: run the reviewed Research PC updater against the existing TradeFlow install and `.env`; require syntax checks and all tests to pass. Then confirm Owner Dashboard serves `v=28`, rerun the same Creality candidate once, and inspect activity for a `seed_url_added` event, canonical Amazon product links, no accessory false-positive, no Shopify API request to Creality/Uni3Dverse, and any qualifying new/used evidence returned to owner review.
- Do not treat registered source count or general search-result count as source coverage. Track each approved source's route attempts, HTTP outcome, links discovered, direct pages fetched, price-bearing pages and accepted candidates separately. Add further website-specific navigation only from observed failures and verified routes.


A dedicated GitHub Actions workflow `.github/workflows/gemma-research-tests.yml` has also been added on the repair branch. It runs Node 24 syntax checks across the Gemma source modules, both existing Gemma test suites (including the new Amazon/model/collection cases), and an Owner Dashboard JavaScript syntax check on relevant PRs and production pushes. This is test-only CI; it does not deploy the Research PC worker or change Cloudflare/Supabase.


## Production merge status — Gemma navigation repair
PR #272, `Fix Gemma research navigation and exact-model filtering`, was merged to `production` on 7 November 2026. Merge commit: `38c6872ccacfd56b8c59491964a86043b84feaf6`. Production now contains the canonical Amazon AAX unwrapping, query-string-safe exact-model matcher, website-declared Shopify collection fallback, Research Again source seeding, Owner Dashboard `v=28`, added tests and `.github/workflows/gemma-research-tests.yml`. GitHub Actions run details were not returned by the connected workflow-run lookup at the time of this checkpoint; do not claim CI passed. The Research PC updater must still run the Node syntax checks and both test suites before the updated worker is accepted. After that, confirm the live Owner Dashboard script version and run exactly one Creality K1 research-again task, then inspect its detailed `platform_ai_agent_activity` records. No further product research task has been submitted since the failure analysis.


## Deep category and website research — 7 November 2026 (PR #273; awaiting validation/merge)

- Scope is the first 3D Printers & Equipment agent only. Do not roll these rules to other category agents until the first agent has passed Research PC acceptance.
- The Owner Dashboard batch builder already resolves a selected master category/branch into individual master-catalogue product/package tasks. Each queued task is one exact product leaf, retaining its branch_slug; the worker must not treat a branch or category page as finished research. LIVE category structure was checked: 201 active products total, comprising 183 in branch 3d-printers and 18 in branch 3d-printer-equipment-accessories. The playbook now has separate machine-versus-accessory instructions so printer-only exclusions cannot incorrectly reject the accessories branch.
- probeApprovedResearchSources() now checks every configured website route in parallel per source and accumulates unique matches instead of returning after the first route succeeds. Search result pages can follow bounded same-host pagination (up to two further pages); collection discovery can inspect up to 12 hubs and follow up to three same-host pagination pages per hub. Individual direct product pages are inspected up to 30 per product task, with an explicit telemetry event when the bound is reached.
- Each page must still be an individual exact-model/product listing. Category/branch/collection/search pages remain discovery only. Manufacturer/category source allow-lists, UK/GBP checks, model/package matching and the ChatGPT/owner approval boundary remain authoritative. Do not bypass logins, robots, access controls or invent site endpoints.
- Exact-model direct pages without visible GBP price are no longer silently discarded before Gemma. They are passed to Gemma for a separate borderline assessment. Validation failures on an otherwise eligible exact-model product page are also retained as borderline. These are inserted into LIVE platform_catalogue_research_queue as record_type='evidence_candidate', status='needs_research', with null evidence type/price/currency/condition/availability, captured excerpt, original URL and explicit reason in research_notes/raw_payload.review_classification='borderline'. They are for ChatGPT inspection only, not verified evidence.
- Verified candidates remain pending_review. The Owner Dashboard displays borderline notes and hides the approval action for raw_payload.review_classification='borderline'; only Research Again or Reject is available. No automatic catalogue/evidence approval or import is introduced.
- Telemetry/metrics distinguish search results, eligible URLs, discovered product pages, inspected product pages, price-bearing pages, verified candidates and borderline candidates. Website route errors and pagination failures remain visible.
- Owner Dashboard cache reference bumped from platform-owner-dashboard.js?v=28 to ?v=29.
- Tests added for same-host search/collection pagination, category-to-product traversal, borderline instructions and separate printer/accessory branch rules. Existing Research PC updater already downloads the updated agent.mjs, playbook and playbook tests and runs syntax checks plus both test suites before installation.
- PR #273 is open against production. GitHub Actions workflow-run lookup returned no run at checkpoint time; do not claim tests have passed until a green run or equivalent Research PC updater output is observed.
- No Supabase schema/migration or LIVE/TEST catalogue data changed. The existing 201-product catalogue and all evidence approvals remain untouched. No Research PC .env, Ollama settings, legacy GearCashOut configuration, Stripe or Cloudflare setting was changed.
- After merge, update the existing Research PC using the reviewed updater, preserving the exact private .env path. Then verify Owner Dashboard v29, run one controlled Creality K1 task, and inspect activity for all-route completion, pagination, individual-page counts, verified candidates and borderline candidates. Do not start the wider branch/category batch until this acceptance is complete.


## Merge and CI verification — 7 November 2026

PR #273, “Deepen Gemma category research and capture borderline findings”, was merged into production as commit 7e8e2d4ba6e634fa788ec78b345ac6047e54aee7. GitHub Actions Gemma Research Tests run 42403829606 completed successfully: all Gemma source syntax checks passed, the task-group and website-playbook test suites passed (19 tests, 0 failures), and Owner Dashboard JavaScript syntax passed. The first test run exposed a collection-pagination fixture that dropped the Creality UK locale path; the fixture was corrected to retain /uk/, and the subsequent complete CI run passed.

Production now contains all-route probing, bounded search/collection pagination, branch-specific printer/accessory rules, direct-page borderline assessment, validation-failure borderline handoff, approval suppression for borderline queue rows, expanded research coverage metrics, and Owner Dashboard cache reference v29. This confirms GitHub source and CI only; it does not yet confirm Cloudflare's production deployment or Research PC installation. The Research PC must be updated with the production updater, then the owner dashboard must be checked for v29, and exactly one controlled Creality K1 task run before any wider batch is dispatched.


## 7 November 2026 — Gemma 3D printer evidence extraction prompt refinement

- PR #274 merged to `production` as `7a906f696d0e25f4d977efd755234eed67e8ee6d`.
- Updated `tools/tradeflow-gemma-agent/src/agent.mjs` with an explicit evidence-extraction brief for the first 3D-printer agent. It reinforces exact manufacturer/model/package matching, printer-only versus Combo/bundle separation, UK GBP-only evidence, precise new/used/refurbished/open-box condition wording, and conflict reporting.
- Removed the contradictory instruction to omit a source when condition is ambiguous. Direct exact-model product/listing pages with missing or conflicting fields must be returned as borderline for ChatGPT inspection.
- Extraction now sends no more than three page excerpts per Ollama call (up to 2,600 characters per page), retains the existing 4,096-token context window, and raises the output allowance to 1,024 tokens. This is intended to reduce oversized prompts and truncated multi-result JSON without increasing the context setting.
- Fail-safe retention: if Gemma does not classify a fetched direct page whose title/URL matches the exact task model, the worker stages it as a borderline lead with an explicit reason rather than silently dropping it.
- Added regression tests for prompt content, package identity, source ID retention and Ollama context/output settings. GitHub Actions run 42407437564 completed successfully on the PR head; syntax checks and the Gemma task/website-playbook tests passed.
- Scope remains one agent only: category `3d-printers-equipment`, branch `3d-printers`. Existing category-specific approved-source filtering, direct-page checks and downstream evidence validation remain in place.
- No Supabase schema or catalogue data was changed. A read-only LIVE check found one existing 3D-printer branch candidate in `needs_research`; no new research task was dispatched as part of this code change.
- **Deployment/test status:** merged source code is not proof that the Research PC has been updated. The Research PC worker has not yet been updated/restarted with this merge, and no post-merge Gemma extraction run has been performed. Preserve the existing `.env`, secrets and `TRADEFLOW_GEMMA_ENV_FILE` path. Next step is update the worker, then run a small controlled set across different manufacturers and printer/package variants. Inspect verified and borderline results in the LIVE review queue; do not approve/import automatically or start another category.


## 7 November 2026 — Capture-first Gemma research handoff

- PR #277 merged to `production` as `6b5f8cd514efade38062ae34f5cee5cc25fee5ff`; CI run 42409174813 passed syntax checks and the Gemma task/website-playbook regression tests.
- The user has explicitly set the evidence ownership rule: **Gemma reports what it finds; ChatGPT decides what is relevant, accurate and usable.** Gemma must not act as an evidence-quality gatekeeper.
- `tools/tradeflow-gemma-agent/src/agent.mjs` now asks Gemma for factual observations on every supplied fetched product/listing page. The extraction response is no longer a verified-versus-borderline decision.
- The crawler's model match is deliberately broader: Combo, Max/Plus/Pro, bundles, accessories and upgrade pages containing the requested model can be retained for ChatGPT to classify. Search/category pages remain discovery-only; approved UK source/category restrictions remain unchanged.
- Every fetched page is staged in LIVE `platform_catalogue_research_queue` as an `evidence_candidate` with status `needs_research`. Observed fields are retained but are not approval-ready. No catalogue or shared evidence import is authorised by the worker.
- Captures retain up to 10,000 characters of extracted page text, exact source URL/title, Gemma observations, and every visible GBP price mention with nearby context. Multiple package prices are retained rather than silently selecting one.
- If Gemma returns malformed JSON, omits a source, or fails a batch, the worker preserves the original fetched page as a raw capture. Extraction failure must not erase research already collected.
- Ollama extraction uses two-page batches with 3,500-character excerpts; the full page capture is stored independently. Worker handovers report page captures rather than approved candidates.
- Existing queue schema supports this without migration: `evidence_type`, `observed_price`, `item_condition` and `availability` remain nullable; `needs_research` is an allowed status. No Supabase schema change was made.
- Scope: only the 3D-printer agent/category `3d-printers-equipment`, branch `3d-printers`. Do not start other category agents until the controlled test passes.
- Next: update/restart the Research PC using the existing updater (preserve its private `.env` and `TRADEFLOW_GEMMA_ENV_FILE`), then run a small controlled batch and confirm every fetched page is staged, including multi-price bundles and extraction failures. ChatGPT will inspect the full captures and open source pages as needed before any catalogue decision.


## 7 November 2026 — short model identity collision guard (PR #279)

LIVE review found that the short model identifier `A1` allowed Audi A1 car pages to match Bambu Lab A1 printer research. The 3D-printer branch now requires manufacturer tokens or explicit 3D-printer context for model identifiers of two characters or fewer and rejects clearly automotive routes. Genuine generic A1 3D-printer listings remain eligible for ChatGPT review. Other categories and longer model IDs retain their existing matching behaviour. Regression tests cover the false-positive car page, genuine Bambu Lab A1 Combo, generic A1 printer page and cross-category non-interference. This is a discovery guard only: all captured evidence remains in `needs_research` until ChatGPT/owner review; no automatic approval or import.


## 7 November 2026 — 3D printer retailer route correction

- Scope: TradeFlow LIVE Gemma only, category 3d-printers-equipment, branch 3d-printers.
- The current LIVE controlled task owner-3d-printers-controlled-rerun-20261107-2225 is still running on worker DESKTOP-LVASEUB-42580. At 22:42 UTC its first Anycubic Kobra S1 / uk_new subtask had discovered and fetched seven individual pages from the Anycubic printer collection. Extraction batches 1 and 2 each returned two structured observations and zero raw fallback captures; batch 3 was still in progress. No queue writes from this active task had yet been committed.
- The same active pass exposed stale approved-source routes: 3DFLO /search?q= returned HTTP 404 and /?s= returned no matching links; iDig3DPrinting /search?search= and /search?q= returned HTTP 404 while /?s= returned no matching links; 123-3D generic /search?q= and /?s= routes returned no matching links. These failures occur before individual product-page fetching.
- Direct public-site inspection verified the correct routes: 3DFLO https://www.3dflo.com/product-category/3d-printers/; iDig3DPrinting https://www.idig3dprinting.co.uk/product-category/3d-printers/; 123-3D new collection https://www.123-3d.co.uk/collections/3d-printers; 123-3D refurbished collection https://www.123-3d.co.uk/collections/refurbished-printers.
- A second discovery-stage issue was confirmed in production code: isCollectionDiscoveryPage() recognised Shopify /collections/ and generic /categories/ paths but not WordPress /product-category/; isEligibleProductPage() also did not explicitly exclude that WordPress category path. A correct category URL could therefore be misclassified and not traversed.
- LIVE source registry was updated under the user's standing permission: 3DFLO and iDig3DPrinting now have their verified category URLs in search_url_template; 123-3D notes record both verified routes while its scope remains all. The 123-3D routes are selected by research_type in the playbook: new uses the all-printers collection, used uses the refurbished collection. This avoids deliberately probing refurbished inventory in the new lane.
- No schema change, catalogue mutation, evidence approval/import, TEST data change, secret change, Research PC update or worker restart was made. The active task had already loaded its source rows before the source-registry update, so this running task is not expected to use the new routes.
- PR #278 was merged to production at 22:13 UTC (merge commit fece19063a4101b449fa3cc120a652c9acd66d15). PR #279 remains open and unmerged, but the short-model identity guard is present in production commit 6941fba5b7b74cf4f005cf0e6cbfca7905c8f4e4; do not merge the divergent PR branch blindly.
- Proposed fix on feature branch feature/gemma-3d-printer-source-routes-20261107: lane-aware 123-3D collection routing; verified WordPress category routes for 3DFLO/iDig; explicit WordPress category discovery classification; regression tests for route isolation and following product links. CI and PR review are required before merge. No deployment or Research PC update is authorised by this checkpoint.


## Verification update — 7 November 2026, 22:46 UTC

- PR #281 is open and mergeable: https://github.com/laurendigitaluk/TradeFlow/pull/281.
- Gemma Research Tests run 42422054014 completed successfully: 35 tests passed, 0 failed, 0 skipped. The syntax checks also passed.
- Cloudflare Workers preview builds for the tradeflow and tradeflow-test services both completed successfully. The tradeflow check returned a feature-branch preview URL; these are PR previews, not a production merge/deployment.
- No merge, production deployment, Research PC update or worker restart was performed.
- The LIVE worker remains on the existing active task. At 22:46 UTC it was still in the fourth extraction batch of the first Anycubic Kobra S1 / uk_new subtask, with a renewing heartbeat/lease. Batch 3 had failed JSON parsing and its two pages were retained as raw fallback captures. No completed subtask handover or queue rows from this active task had yet been committed.
- All review captures remain unapproved and unimported. No TEST/LIVE crossover or secret changes occurred.


## 7 November 2026 — canonical source URL de-duplication

The LIVE source registry and site playbook both carry the verified 3DFLO/iDig category URLs. To avoid probing the same page twice through bare-host and www redirects, the playbook now stores the verified canonical www URLs and buildWebsiteSearchRoutes accepts absolute routes as well as relative paths. The same canonical-host treatment is used for 123-3D's new/refurbished collections. Regression coverage verifies that a configured search_url_template and its playbook route collapse to one URL. This remains confined to the 3D-printer source playbook; no other category route logic is changed.


## 7 November 2026 — ELEGOO UK new/pre-owned route coverage

- LIVE already contains the enabled ELEGOO UK manufacturer source for category `3d-printers-equipment`. ChatGPT verified the official UK FDM collection `https://uk.elegoo.com/collections/fdm-printers`: it exposes 60 products and lists the Neptune 4 Pro with GBP pricing. The official pre-owned collection `https://uk.elegoo.com/collections/pre-owned-3d-printer` exposes 27 products and includes a Neptune 4 Pro entry, but that entry is currently marked sold out. Both URLs are discovery routes only; Gemma must follow individual product pages and verify current availability.
- LIVE source notes now record both URLs. The source's current `research_scope` remains `new_uk` until the lane-specific playbook is reviewed and deployed; do not let the pre-owned route enter the used lane before that coordinated change.
- This feature branch adds `uk.elegoo.com` to the 3D-printer playbook with Shopify collection discovery and strict routes: `uk_new` → `/collections/fdm-printers`; `uk_used` → `/collections/pre-owned-3d-printer`; `uk_both` → both. Generic search fallback is disabled for this site. Sold-out individual listings must not be accepted as current used evidence.
- Regression tests verify the three lane route sets and confirm both collection pages are discovery pages, not direct product evidence.
- This is confined to the 3D Printers source playbook. No catalogue/evidence import, approval, task enqueue, TEST/LIVE data copy or secret change is included.
- PR #281 remains open and unmerged. Do not merge/deploy or widen the LIVE source scope until owner review and the Research PC/runtime route acceptance test.


## 7 November 2026 — ELEGOO UK host eligibility guard

- The official storefront is hosted on `uk.elegoo.com`, which is not covered by the generic `.co.uk`/UK-path check. Without an explicit allow-list entry, the verified FDM and pre-owned collection pages and direct product pages would be rejected by `ukHost()` even though the site displays GBP and explicitly ships to the United Kingdom.
- The 3D-printer UK source-host allow-list now includes `uk.elegoo.com`. Regression coverage includes an individual Neptune 4 Pro product URL, plus the new/used collection discovery routes; collections remain ineligible as direct product evidence.
- The source registry remains `new_uk` until the lane-specific playbook is reviewed/deployed. No used-lane activation, catalogue approval/import, TEST/LIVE crossover or secret change is included.


## Verification update — 7 November 2026

- Added `uk.elegoo.com` to the explicit UK 3D-printer source-host allow-list; without this, the .com subdomain would fail the UK host check despite its GBP/UK storefront.
- Added ELEGOO lane-specific collection routing and tests for new, used and combined tasks, collection discovery-only classification, and direct Neptune 4 Pro product-page eligibility.
- Focused Node.js checks for the eight route/host assertions passed: 8 passed, 0 failed. The last available GitHub Actions run for PR #281 (42422365717) passed 35/35 before the ELEGOO additions; a new CI run covering these additions has not yet been observed. PR remains open and unmerged.
- LIVE ELEGOO source scope remains `new_uk`; the used collection is recorded but intentionally not enabled for used-lane research until after reviewed/deployed route code.

## 7 November 2026 — Gemma post-route-merge review and schema correction

- Production release state: PR #278 merged as fece19063a4101b449fa3cc120a652c9acd66d15; PR #281 merged as bae3c4145bc0fd78de9ac803e81cd9077ba0c930. The verified 3DFLO, iDig3DPrinting, 123-3D and ELEGOO UK route definitions are now in production source. The Research PC runtime still requires a reviewed in-place update and acceptance test.
- LIVE review queue schema has reviewed_by, reviewed_at, approved_at and imported_at; it has no approved_by or imported_by. The original PR #282 implementation referenced those nonexistent columns and must not be merged unchanged.
- PR #284 proposes 3D-branch-only, exact-identity, append-only enrichment of unreviewed needs_research raw captures. It writes only raw_payload.enrichment_history, research_notes and updated_at; preserves top-level price/evidence/status/reviewer fields; repeats the actual review-marker checks in the PATCH filter; and uses optimistic concurrency.
- PR #284 also corrects the observed telemetry identity mismatch where a Sigma lens task carried the 3D Printers agent key. The explicit non-3D category wins only for that mismatched 3D key; correctly assigned 3D and other agent identities remain unchanged.
- No LIVE data, approvals/imports, task queue, TEST data, secrets, local .env, Research PC installation or runtime was changed. PR #284 is open for CI/review only.
- PR #279 was also closed as redundant after verifying that its short-model-ID guard and Audi A1/Bambu A1 regression test are already present in the current production branch.


## 8 November 2026 — exact 3D-printer model and package matching

- LIVE queue inspection found Creality K1 task captures from K1 Max pages and K1 accessory/upgrade URLs. The previous discovery matcher deliberately accepted sibling model names and package/accessory references for broad ChatGPT review, but those pages were being written under the requested Standard Printer task identity.
- The 3D-printer matcher now rejects sibling model suffixes (Max, Plus, Pro, Ultra, Neo, Mini, SE, MK2/MK3 and V2/V3) when they are not part of the requested model; rejects printer accessories, replacement parts and upgrades; and enforces Standard versus Combo/AMS/ACE/CFS/multicolour package matching. A task for the exact sibling model or Combo package remains eligible.
- This is limited to category `3d-printers-equipment`, branch `3d-printers`. Other catalogue categories retain their existing matching behaviour. Short-model manufacturer/3D-printer disambiguation remains in place.
- Regression tests cover K1 versus K1 Max, standard versus Combo, valid exact K1, accessory/upgrade rejection and exact K1 Max task acceptance.
- No LIVE queue rows, source registry, catalogue data, approvals/imports, task queue or TEST data were changed. No Research PC update, worker restart or deployment has occurred. Run CI and then deploy the reviewed agent to the Research PC before the next controlled task.


## 8 November 2026 — Research PC updater compatibility

- The current production `task-worker.mjs` imports `agent-identity.mjs` and the identity resolver has a dedicated regression test. The previous PowerShell updater source-file allow-list did not include either file; running that updater against the current worker would leave the new import missing locally and omit its tests.
- The updater is corrected to download, back up and install `agent-identity.mjs` and `agent-identity.test.mjs`, and to run the identity test suite both before installation and after installation.
- Existing safeguards remain: validate the private .env targets without printing values; preserve the .env file; install only reviewed src files; back up existing source; run syntax/tests before replacing files; no Supabase schema/data changes.
- This updater correction must be merged before asking the Research PC to update. Then run the production updater in place, verify the worker heartbeat, and only then queue the next controlled 3D-printer search task.


### Verification note — exact package matcher smoke test
- Ran six focused assertions against the current PR branch matcher: K1 rejects K1 Max sibling; K1 Max Standard rejects the exact `essential-combok1-max-hyper-pla-2` bundle; K1 Max Combo accepts that same URL/title; standalone K1 Max remains accepted; Audi A1 car is rejected; genuine Bambu A1 Combo printer listing is accepted. Result: **6/6 passed**.
- This is a focused matcher smoke test, not the full repository suite. GitHub Actions run 42433260646 passed before the strengthened K1 Max Standard/Combo fixture was committed. A new CI run for the corrected test commit has not yet been observed; do not merge until it passes.


### Legacy false-positive queue items — manual review required
- LIVE still contains two older Bambu Lab A1 / Standard / Used rows sourced from Audi A1 car adverts: Gumtree Stratford at £2,150 (row `86cdd9e5-4b1d-47e9-9aaa-3d2ae4b57f74`) and Narberth at £11,300 (row `a4ca1777-3887-4b4e-bfa5-9ef76e27400c`). Their page titles and `/cars-vans-motorbikes/cars/audi/a1/` URLs confirm they are not 3D-printer evidence. Both remain `needs_research`, unreviewed, unapproved and unimported. The updated A1 guard rejected all 9 Audi URLs in the latest controlled run, but it does not retroactively clean these older rows. Leave them for explicit ChatGPT/owner review; do not auto-delete, approve or import them.


## 8 November 2026 — 3D Printer Gemma deep-page extraction repair (PR #292)

- LIVE review-queue inspection found 44 3D-printer captures: 1 row with a top-level price and 43 without structured evidence fields. Recorded failure reasons: 21 unrecognised Gemma JSON findings envelopes, 14 Ollama timeouts, 2 malformed/truncated JSON outputs, and 4 other/misclassified observations; 3 rows had no extraction error detail.
- Confirmed extraction-depth limitation: production passed only the first 2,200 characters of each fetched product page to Gemma, although the full fetched text was retained in the review capture. Product option prices, package details, condition and availability later in the page could therefore be missed.
- PR #292 changes only the 3d-printers-equipment / 3d-printers extraction path: one fetched page per Ollama call; a compact single-object JSON observation contract; selected excerpts from across the fetched page with all visible GBP price contexts and package/condition/availability/location clues; deterministic structured observations on model timeout or malformed output.
- Multiple package prices are retained with nearby context. The fallback does not guess a single printer price where multiple prices appear, does not classify evidence as approved, and leaves evidence_type unverified for ChatGPT review.
- Other categories retain the existing two-page extraction batch and opening-page excerpt. No other agent was changed.
- CI run 42477880080 passed: 50 tests, 0 failures. PR #292 was merged into production with squash commit 65730838d5f32cbf923973d5a32a87f8454a0c07 after explicit owner approval. No LIVE queue, source registry, catalogue, TEST data, local .env, Research PC process or Cloudflare deployment was changed. Do not update the Research PC until PR review/merge and then use the existing updater in place.


Post-merge status (8 November 2026): Owner approved PR #292. Merged to production as `65730838d5f32cbf923973d5a32a87f8454a0c07`. Pull-request CI passed 50/50 tests. Production push CI run `42478484235` was queued/in progress at checkpoint update. Research PC source has not yet been updated; no LIVE worker restart has occurred.

## 2026-11-08 — Explicit Gemma price-observation contract (PR #302)

The 3D-printer extraction contract now represents every visible GBP amount as a separate `price_observations` item. Each item contains the exact displayed price, nearby source context, product/variant association, price role, condition and availability. Gemma must not associate a price with the requested product based only on proximity; uncertain associations remain `ambiguous` for ChatGPT review. The JSON schema and downstream consumer now agree on the allowed fields. The worker cross-checks every reported amount against deterministic GBP observations extracted from the fetched page. It only sets `observed_price` when exactly one source-verified observation is explicitly associated with the requested product; otherwise it leaves the price unset. This remains an unverified review capture, never an approval/import decision.

Scope is limited to category `3d-printers-equipment`, branch `3d-printers`. PR #302 is draft and not merged or deployed. No Research PC installation, worker restart, LIVE task, TEST/LIVE data mutation, source registry change, approval or import has occurred. CI and historical-capture replay remain required before installation.


## 8 November 2026 — PR #302 CI finding and context-verification correction

The first PR #302 CI run (#272) failed one legacy assertion in `agent-speed.test.mjs`: it still expected the retired `price_mentions` prompt field. The other 55 tests passed, including the new observation-schema checks and PowerShell/source syntax checks. Updated that assertion to the new contract. During review of the actual downstream consumer, found that price verification matched only the numeric amount against the page, not the observation's nearby context. Tightened the prompt to require exact copying of the supplied context and changed the consumer to require both the exact extracted GBP amount and an exact normalised match to the deterministic page-context excerpt before setting `source_context_verified` or selecting `observed_price`. Also corrected the GBP parser to accept both £ and GBP values. Latest branch head: `734f184765dd9971f15334f5461af853fd798490`; latest CI result not yet available. PR remains draft and unmerged. No Research PC, Ollama runtime, LIVE/TEST database, task queue, approvals or imports changed. Historical capture replay remains the next acceptance gate after CI passes.


## 8 November 2026 — historical capture replay, price parsing and condition-lane gate

Historical LIVE capture review found the old parser was counting split-decimal renderings twice (for example £13.99 £ 13 . 99) and globally de-duplicating equal amounts even when they appeared in separate product/variant contexts. The parser now accepts split decimals, collapses only an adjacent duplicate rendering, and preserves the same amount when it occurs elsewhere with a distinct context.

The observation schema now constrains price_role and association to explicit values. The downstream selector only populates observed_price when the observation has exact source-context verification, requested_product association, current role, and a clear condition matching the task's research lane. Crossed-out, saving, other-variant, accessory, delivery, protection-plan and warranty amounts cannot be promoted. If more than one distinct current requested-product amount remains, the top-level price stays null.

Historical capture fixtures are based on retained LIVE pages:
- Anycubic Kobra S1 Max page: standard printer, crossed-out/regular, saving, 4-colour, 8-colour and 16-colour amounts remain separate.
- Amazon Bambu Lab A1 Combo page: printer price remains distinct from protection-plan and insurance amounts; split-decimal duplicate rendering is collapsed.
- LIVE ELEGOO Neptune 4 Pro smoke capture: one page fetched; Gemma extraction took 224,986 ms; the old extractor returned no structured price/evidence type and retained the page with 14 visible GBP amounts spanning Neptune 4 Pro, Neptune 4, Neptune 3 Pro, open-box and bundle options. The review row remained needs_research, with no observed_price, no evidence_type, no approval and no import. This is a historical runtime observation, not a test of the new schema.
- The YIBEICO A1 screw-set false positive remains a separate issue in draft PR #301; it must not be treated as a printer-price observation or folded into this PR.

GitHub Actions run #293 (42516334199) passed on code commit 13feb193c6cd7741c0fc50092b0ffb8189532dfb: 60 tests passed, 0 failed; PowerShell syntax, Gemma source syntax and Owner Dashboard JavaScript syntax passed. PR #302 remains draft and unmerged. production remains the PR base (a0cf801a809e9428f66254ec66fc43ba52a77647); compare reports the draft branch ahead 88, behind 0. No Research PC installation, Ollama runtime test, new task, LIVE/TEST queue mutation, approval or import has occurred. No 3D-printer tasks are currently non-terminal in platform_ai_agent_tasks; the last recorded agent status was idle at 19:01 UTC, so its heartbeat is historical rather than a current liveness claim.

Next gate: inspect the PR preview/source contract, then install the verified draft on the Research PC using the versioned updater without starting the worker. Test local Ollama schema output with one retained page before any controlled review-only task. Keep PR #301 accessory filtering separate and retain all review/import gates.


## 8 November 2026 — restore capture-first research architecture

Owner confirmed the intended division: Gemma should collect as much source information as possible in the shortest time; ChatGPT should interpret and decide evidence suitability. Review of the current implementation showed the 3D-printer worker still called extractBatch() and waited for local Ollama structured generation before it could use fallbackPageCapture(). A timeout therefore delayed the exact raw capture that was already available.

Changed the 3D-printer path so it bypasses Ollama/Gemma inference entirely after source discovery and page fetch. It now immediately retains each fetched page through deterministic capture: title, URL, extracted page text, all visible GBP observations and contexts, package/variant snippets, condition snippets, availability snippets and UK/location clues. It records capture_only_started, page_capture_retained and capture_only_completed; the 3D-printer gemma_extraction_ms metric is zero and no Ollama extraction is called. Other research categories retain their existing extraction path.

For 3D-printer captures, observed_price is always null and evidence_type remains null until ChatGPT review. A page containing only one price is not enough to promote that amount to a product price. The raw page and its price context are retained for ChatGPT to determine the correct product/package/condition. All detected price contexts are preserved rather than limiting the context array to the first 12. The queue remains needs_research / unverified_capture; no approval or import is authorised.

Added/updated tests to ensure a single visible printer price is never promoted before review, the page text and price observation remain available, and the prior fallback test now expects a null top-level price.

Important integration boundary: the inspected TradeFlow research worker stages raw captures in platform_catalogue_research_queue for ChatGPT review; no direct OpenAI/ChatGPT API call was found in this worker. ChatGPT analysis is therefore a downstream review/handoff, not an automatic API stage in this code path. Do not describe it as automatically analysed until a separate, explicitly configured analysis integration exists.

PR #302 remains draft and unmerged. The Research PC has the draft installed, but the worker has not been restarted. Do not start the worker until this capture-only change passes CI and the updated launcher/source is installed. No LIVE or TEST queue rows were changed by this code edit; no task was started, approved or imported. Current CI run #312 (42518986367) is pending at the time of this documentation update.

Next gate: complete CI, install the updated capture-only branch on the Research PC without starting the worker, then run one controlled 3D-printer capture-only task. Verify fast page capture, all visible prices/contexts in the LIVE review queue, null top-level price/evidence type, and no Ollama inference or timeout. ChatGPT then reviews the retained page.


## 8 November 2026 — capture-only implementation CI verification

The capture-first 3D-printer change passed GitHub Actions run #312 (run ID 42518986367) on implementation commit 48eec9d682aa0d8ff6ecdb5f3ee0463a98a46596. Result: 61 tests passed, 0 failed. PowerShell updater/launcher syntax, all Gemma source syntax checks and Owner Dashboard JavaScript syntax also passed. PR #302 remains draft and unmerged; current branch head after documentation commits is 6763e76dbce6ef37cbffaab74b3e5a6fdaff6904.

The Research PC still has the earlier draft version installed. It must be updated again to this capture-only branch before a controlled task is run. Do not start the worker until the user has installed the latest branch and we have verified the installed source. No research task or queue write has been performed by this code verification.


## 8 November 2026 — LIVE capture-only smoke result and complete-page retention

The first controlled LIVE capture-only smoke task owner-3d-printers-capture-only-smoke-20261108-2020 completed successfully on worker DESKTOP-LVASEUB-22608 in 20.796 seconds (started 20:18:35.877 UTC; completed 20:18:57.315 UTC). Task result: 10 search results, one exact product page discovered/fetched, one review capture retained/enriched, zero Gemma calls, zero Gemma extraction milliseconds, 781 ms product-page fetch, 124 ms LIVE queue write. No Ollama call or timeout occurred. The task completed with no task error.

The captured Anycubic Kobra S1 Max page preserved separate GBP observations for £549, £849, £300 saving, £749, £935 and £1,307. Top-level observed_price and evidence_type remained null; row status remained needs_research; review/approval/import fields were untouched. The capture was enriched into existing LIVE review row 2dd24f89-7165-4b1a-9f75-7a96cf40430c (dedupe match to earlier Kobra S1 Max capture), not inserted as a new duplicate row. Six observations in page_capture.gbp_price_mentions; no catalogue valuation was promoted.

Smoke review found an additional data-retention defect: the HTML-to-text extractor, fallback capture, and enrichment history imposed 10,000 / 4,000 character limits. The fetched page was therefore not being preserved completely. Updated 3D-printer capture path to allow up to 100,000 characters at HTML text extraction and to preserve the full extracted text in source_excerpt, page_capture.captured_text and raw_payload.enrichment_history.page_capture_excerpt. Existing 10,000-character defaults remain unchanged for non-printer categories. Added regression tests for full captures over 10,000 characters and configurable extraction limit.

GitHub Actions run #322 (42519658760) passed on commit f08259de763dfef0f1e4b75e3d7cfdeac6e22892: 63 tests passed, 0 failed; PowerShell updater syntax, Gemma source syntax and Owner Dashboard JavaScript syntax passed. PR #302 remains draft/unmerged. The Research PC currently has the earlier capture-only version installed; it must be stopped and updated to this full-capture build before another task. Do not run another task until updated source is installed. No new research task was created after the smoke run; no approvals/imports or TEST writes occurred.

Known remaining issue: only one product page was discovered/fetched from 10 search results. Approved-source probing attempted 27 routes across 12 approved sources; 10 found matches, 11 empty, 6 failed (eBay 403s and route 404s included). The capture-first latency is now good, but discovery/source coverage needs separate improvement after full-page retention is installed and verified.


## 8 November 2026 — TEST/LIVE control-plane isolation correction

A Research PC screenshot exposed a critical integration fault after the local source suite passed: the launcher printed that it was starting the LIVE Gemma queue worker, and the worker itself declared `control plane: LIVE only; TEST retained for software regression`. The updater's optional `-StartWorker` path and the installed launcher both hard-coded LIVE. Therefore the 63 passing tests did not validate a TEST worker, and the earlier instruction to proceed with a controlled TEST task was not safe.

Corrective work on PR #302 now adds `src/control-plane.mjs` with a strict allowlist for the two approved project IDs. Worker environment selection defaults to TEST; LIVE requires an explicit `TRADEFLOW_GEMMA_ENVIRONMENT=LIVE` selection. The selected URL is checked against its exact approved project ID and only that environment's service-role credentials are used. The queue worker, Common Room RPCs, research-source registry reads, review-queue writes and agent telemetry all use the selected control plane. The PowerShell launcher and updater default to TEST, accept only TEST or LIVE, and print the selected environment. The new control-plane tests cover TEST default, explicit LIVE, invalid environment names, mismatched project URLs and missing credentials. CI and full regression suite are pending for this correction; do not merge or restart the worker until they pass.

TEST project `nnsshnfkjcflucjrftzi` was inspected read-only: 51 approved research-source rows total, 3 enabled sources scoped to `3d-printers-equipment`, 0 queued tasks and 0 review-queue rows. Its 3D-printer agents were idle; the equipment agent's last heartbeat was historical (2026-11-07 12:12:55 UTC). No TEST task was created and no TEST queue rows were changed during this inspection. Do not use the owner dashboard. The next gate is CI, then a TEST-only worker start and a single bounded TEST task, followed by verification that all source reads, queue writes, Common Room traffic and telemetry remain in TEST. LIVE remains out of scope.


## 8 November 2026 — TEST Common Room schema gap found and repaired

After the Research PC was updated from production and started with the default TEST control plane, its console confirmed TEST-only operation. The first Common Room RPC calls failed with PostgREST HTTP 404 / PGRST202. Direct inspection of TEST project `nnsshnfkjcflucjrftzi` confirmed the root cause: the TEST database did not contain `public.platform_ai_agent_messages`, `platform_ai_agent_post_message`, or `platform_ai_agent_list_messages`. The task queue RPCs were present. This was a missing TEST schema migration, not an environment-routing error and not a LIVE connection.

Applied the repository's existing Common Room migrations to TEST only, using the exact production SQL files: `20261107190000_platform_ai_agent_common_room.sql` (table, indexes, RLS, grants and owner/agent RPCs), `20261107162000_harden_common_room_agent_post.sql`, and `20261107163000_harden_common_room_owner_rpcs.sql`. All three migration calls returned success. Post-migration verification confirms the messages table and both worker RPC signatures now exist. The TEST Common Room currently has zero messages; no task or review-queue rows were created by this repair. LIVE was not accessed or modified.

The running worker's idle loop retries the Common Room inbox read on its normal polling cycle. Confirm the repeated PGRST202 errors have stopped and that the worker remains on TEST before enqueueing a controlled task. If the old PostgREST schema cache continues to report PGRST202, stop and restart the worker once to reconnect; do not change its environment or use the dashboard. Keep the first research task bounded to one 3D-printer product and inspect all captured prices before any approval/import.


## 8 November 2026 — TEST task enqueue compatibility and first controlled task

The owner explicitly required TEST-only verification and reported that Gemma stopped producing results after the recent control-plane change. Investigation of TEST project `nnsshnfkjcflucjrftzi` found two separate gaps:

1. Common Room RPC schema was missing initially. The existing production Common Room migrations were applied to TEST and both worker RPC signatures plus the messages table were verified. A PostgREST schema-cache reload was requested. Common Room read/write failures are ancillary: the current worker catches these failures and continues without Common Room context; they do not block the research task loop.
2. TEST had the task table and worker claim/complete/fail RPCs, but it did not have `platform_owner_enqueue_ai_agent_task`. Consequently, no task could be submitted through the normal owner enqueue path. TEST contained zero tasks and zero review rows. This is the key reason the worker had nothing to research. The production source migration `20261107130000_gemma_live_supervisor_control_plane.sql` contains this owner enqueue RPC, but its LIVE-only scope comment meant it had not been installed in TEST.

Minimal TEST-only repair: installed `platform_owner_enqueue_ai_agent_task(text,jsonb,integer)` with the same owner-membership check, task-key idempotency, payload validation, priority bounds and authenticated grant as the existing production migration. No existing task, review queue, catalogue, source, customer, tenant or LIVE data was modified.

A single bounded TEST task was then enqueued through that RPC using the active platform owner membership: `owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-01`, for Creality Ender-3 V3 KE, Standard Printer, UK new-price research only. Queue task UUID: `b7b1463f-0f90-4f83-9b4b-d0e76780e587`. It is queued, not yet claimed; the Research PC worker was stopped by the owner before this task was enqueued. TEST currently has three enabled 3D-printer sources (Creality UK Official Store, 3D Prima UK, 3DJake UK). Next: restart the already-updated worker in its existing folder; it defaults to TEST and should claim this one task. Verify heartbeat, task claim, page captures and TEST review-queue rows. Do not use the dashboard, do not select LIVE, and do not approve/import any result.


## 8 November 2026 — Creality dynamic product discovery repair (TEST investigation)

### Reproduced failure

The controlled TEST task `owner-test-3d-printer-creality-ender-3-v3-ke-uk-new-20261108-01` completed in 6.9 seconds but produced zero captures. Activity showed 11 search results, one approved-source collection candidate, zero HTML product links, and the explicit fallback message `site HTML only; no API fallback configured`. No product page was fetched and Gemma/Ollama calls remained zero. This isolated the current blocker to source discovery, not price extraction.

### Evidence and minimal change

The public Creality UK storefront exposes the individual Ender-3 V3 KE page at `https://store.creality.com/uk/products/ender-3-v3-ke-3d-printer` and category collections including `/uk/collections/fdm-3d-printer` and `/uk/collections/ender-3-v3-series`. The current playbook had an obsolete `/uk/collections/3d-printers` route and did not declare a supported collection API, so dynamically rendered product cards could not be enumerated.

A focused code change is on branch `fix/creality-dynamic-printer-discovery-20261108`: enable the already-implemented Shopify collection JSON fallback for `store.creality.com`, replace the obsolete collection route with the two verified Creality UK collection routes, and add a regression test requiring the exact Ender-3 V3 KE product to be discovered while rejecting Ender-3 V3 SE and upgrade-kit results. No price extraction, task queue, review policy, or LIVE settings are changed.

### Validation status

Automated CI and the next single controlled TEST run are still required. Do not claim the repair is complete until CI passes and the TEST worker captures the individual product page. Do not approve/import the capture. LIVE remains untouched.


### 8 November 2026 validation update

- PR #305 merged into `production` after the first CI run exposed two stale/missing test assertions; both were corrected, and the rerun passed all 69 tests with zero failures.
- Merge commit: `5b967ee7bba50ac5319a097d2d3555cb6149aaf8`.
- The Research PC still needs the production-branch updater applied before runtime verification. The next controlled TEST task must confirm that the Creality collection API fallback discovers the individual Ender-3 V3 KE page, captures its full page, and stages an unverified review record. The current earlier test task is completed with zero captures and must not be counted as success.
- No LIVE research task, database write, catalogue import or production worker restart was performed as part of this change.


## 8 November 2026 — Gemma dashboard shows outstanding work only

The owner dashboard previously loaded historical rows into its live work lists:
- `loadGemmaQueue()` explicitly called `platform_owner_list_catalogue_research_queue` with `p_status: 'all'`, showing imported and rejected research captures beside items awaiting review.
- `loadGemmaTasks()` called `platform_owner_list_ai_agent_tasks` without a status filter; the RPC returned the latest 50 records regardless of status, including completed tasks.

The correction is in `platform-owner-dashboard.js` and migration `20261108223000_gemma_dashboard_active_only_lists.sql`:
- Research queue default view is `open`: pending_review, needs_research and approved. Imported/rejected records remain stored and can be retrieved with the `completed` or `all` filters, but are not rendered in the active dashboard list.
- Task default view is `active`: queued, running and failed. Completed/cancelled tasks remain in the task table but do not clutter the live task list. Failed tasks remain visible until resolved or cancelled.
- Dashboard section labels now read “Outstanding research tasks” and “Research awaiting review”. Empty states explain that completed records are retained in database history.
- No research queue rows or task rows are deleted or rewritten by this change.

LIVE state inspected on 8 November: all 65 3D-printer research rows are terminal (28 imported, 37 rejected); there are zero open research rows. All 20 AI agent tasks currently stored are completed. Therefore after this UI/RPC change is deployed, both lists should be empty until new outstanding work arrives.

The SQL migration was syntax-checked inside a transaction, then PR #309 passed the Gemma Research Tests workflow and was merged to production (merge commit c62bc4b47a64a2de1dadb50106ce4b6dae150e3d). The migration was applied to TradeFlow LIVE and both RPC signatures and authenticated execute grants were verified. LIVE still has 65 completed research records and 20 completed tasks, with zero open research rows and zero active tasks. The Cloudflare Worker/static asset deployment and browser refresh have not yet been independently verified. Verify the LIVE dashboard after deployment and confirm the two active lists show empty states while underlying history counts remain unchanged.


## 8 November 2026 — Gaming Consoles & Accessories LIVE/TEST reconciliation

Completed a direct comparison of the `gaming-consoles-accessories` master catalogue in TradeFlow LIVE and TEST. Both databases now contain the same 285 master products across 20 branches and 24 manufacturers. The product identity set and all compared master-product fields (model, package key/name, branch, catalogue/main category, product type, notes, active and customer-visible flags) now match exactly. No products were inserted or deleted during this reconciliation.

Reconciled the small set of metadata drift found in Xbox/Nintendo controller entries, preserving the more informative verified notes and using the same canonical category/product-type values in both environments. The earlier spelling/package variations for the Hyperkin Competitor Silver and Microsoft Carbon Black controller are retained as active package aliases in both databases (2 aliases per environment); aliases do not create duplicate products.

Evidence verification after reconciliation:
- Both environments have 413 active evidence rows: 248 UK new and 165 UK used.
- All 285 master products have at least one active evidence row in both environments.
- LIVE retains 12 inactive historical evidence rows; TEST retains 13. The extra TEST row is inactive historical data and was not deleted or copied. Active evidence counts align, but evidence records are not byte-for-byte identical: independently captured source keys, timestamps, URL variants and notes remain. Do not blindly overwrite source evidence merely to make raw row counts or hashes match; preserve source provenance and review record-level differences when evidence parity is specifically required.
- Both environments have 2 active product-package aliases for this category.

The initial dashboard-list repair is separate: PR #309 merged and its LIVE RPC migration was applied, but the Cloudflare dashboard asset deployment/browser refresh still needs independent confirmation. No Gemma workers were started or restarted as part of this catalogue reconciliation.

Next workflow: continue preparing the remaining product categories. Once the category catalogues are ready and reconciled between LIVE and TEST, perform the full Gemma worker/agent update and controlled research run, then gather results across the agents.


## 8 November 2026 — Mobile Phones LIVE/TEST reconciliation

The mobile-phones category was compared by manufacturer, model, storage/package, branch and all product metadata. LIVE contained 158 products; TEST contained 160. The 158 shared product records have now been aligned to LIVE as the canonical master catalogue. For those 158 records, product identity and all compared metadata fields now match exactly, including package key/name, catalogue/main category, product type, notes, active and customer-visible state. TEST product_type was standardized to `Smartphone` to match the LIVE taxonomy.

Two TEST-only records were retained as inactive, hidden audit/verification placeholders rather than copied to LIVE or deleted:
- Apple iPhone 18 standard 256 GB: no official standard iPhone 18 model is confirmed in Apple's UK lineup; Apple's official announcement lists iPhone 18 Pro and Pro Max. The TEST placeholder is now inactive and hidden until the standard model is officially confirmed. <https://www.apple.com/uk/newsroom/2026/09/apple-debuts-iphone-18-pro-and-iphone-18-pro-max/>
- Google Pixel 11 128 GB: already marked inactive in TEST because the 128 GB variant was invalid; retained for audit history.

Final verification:
- LIVE: 158 total/active products, 157 customer-visible, 0 active products without active evidence.
- TEST: 160 total products, 158 active, 2 inactive retained placeholders, 157 customer-visible, 0 active products without active evidence.
- Both environments: 567 active evidence rows (271 UK new, 296 UK used), with no active evidence attached to inactive products.
- Market-evidence records were not bulk-copied or overwritten. Counts match, but individual evidence provenance remains independent between environments.

The next full category reconciliation should account for remaining category-level drift observed in the database: 3D Printers & Equipment currently shows 208 LIVE vs 209 TEST products and 260 vs 232 active evidence rows; Laptops exists in TEST with 8 products and no active evidence but is not yet present in LIVE. Do not launch the full Gemma worker/agent sweep until all intended categories are reconciled and their source-selection configuration is verified.

## 8 November 2026 — 3D Printers & Equipment LIVE/TEST reconciliation

Rechecked the category against the 4–5 November catalogue checkpoints before changing data. The original Creality reconciliation checkpoint explicitly identifies the canonical records and the duplicate audit rows. A later parallel insertion had reversed the active/visible flags on three Creality duplicate rows. Restored the previously documented arrangement in both environments:
- SPARKX i7: canonical standard package active/visible; duplicate printer-only row inactive/hidden.
- HALOT-MAGE S 14K: canonical standard package active/visible; duplicate printer-only row inactive/hidden.
- HALOT-R6: canonical standard package active/visible; duplicate printer-only row inactive/hidden.
- Canonical evidence rows were reactivated; duplicate evidence rows, including later parallel duplicate captures in TEST, were set inactive. All rows remain stored.

The shared 208-product identity set now has exact matching product metadata in LIVE and TEST, including model, package key/name, category fields, product type, notes and active/customer-visible flags. TEST retains one additional inactive/hidden Ender-3 V3 Neo / Printer only duplicate for audit; it is not a customer-visible or active product.

Reconciled the active market-evidence set in TEST against LIVE by product identity, source name and source record key. Seven equivalent TEST observations were updated to the LIVE observation keys/values, 21 missing active observations were inserted, and seven additional older source-key observations present in LIVE were added. No LIVE evidence was changed and no evidence rows were deleted. Three existing notes remain slightly more descriptive in TEST; these are retained rather than shortened.

Final verification:
- LIVE: 208 products, 201 active/customer-visible, 7 inactive; 2 branches, 18 manufacturers.
- TEST: 209 products, 201 active/customer-visible, 8 inactive; 2 branches, 18 manufacturers. The sole extra product is the known inactive Ender-3 V3 Neo duplicate.
- Both: 260 active evidence rows (239 UK-new, 21 UK-used); zero active products missing evidence; zero invalid active evidence; zero duplicate active source-key groups.
- Inactive evidence history: LIVE 17, TEST 21. The four-row difference is retained audit history, not active catalogue drift.

Gemma remains gated. PR #300 is still draft/open and not merged; its CI passed 54/54, but installed Research PC/Ollama structured-output acceptance is not yet verified. No worker was started/restarted and no new research task was queued. Complete the remaining category reconciliation and source-selection checks first, then update all Gemma workers/agents and run the controlled full research cycle.

## 8 November 2026 — Laptops category created and aligned

The TEST-only Laptops category was reviewed before syncing. LIVE had no laptops category; TEST had 8 seed models with generic “Base Configuration” packages and no market evidence. The category and branch have now been established in both environments:
- Category: Laptops (slug laptops), sort order 92.
- Branch: Laptops & Notebooks (slug laptops-notebooks).
- 8 matching product records in each environment, with configuration-specific package keys/names and product_type Laptop.
- Products: Apple MacBook Air M1, M2 and M3; Dell Latitude 5440 and XPS 13 9315; HP EliteBook 840 G10; Lenovo ThinkPad T14 Gen 3 and Gen 4.
- Each product package identifies the CPU/RAM/SSD configuration evidenced. No broad model-level price is inferred across other configurations.

Added one active UK-used evidence record per product in both LIVE and TEST (8 each). Evidence links directly to eBay UK listings. Where the search result exposed a buyer-protection fee, that fee was excluded from observed_price; where it did not expose the fee breakdown, the recorded value is explicitly described as buyer-facing total, not seller proceeds. One M3 record is a current used asking listing, not a completed sale. Evidence types are all uk_used; no current UK-new prices were verified for these specific legacy configurations. Used evidence is reference-only and must not affect automatic valuation.

Final verification: 8 products, 8 active products, 8 visible products, 8 active used evidence rows, zero UK-new evidence, zero active products without evidence in each environment. Product metadata and evidence source keys match between LIVE and TEST.

Added official UK laptop manufacturer sources to both source registries:
- Dell UK — dell.com, official UK laptop catalogue.
- HP UK — hp.com, official UK laptop catalogue.
- Lenovo UK — lenovo.com, official UK laptop catalogue.
Apple UK and Samsung UK were already approved for laptops; eBay UK and CeX UK were already approved used-market sources. Retailer sources Argos, Currys, John Lewis and Very were already category-scoped.

Category-wide audit after this work: both databases have 38 categories. Remaining evidence-count drift exists in several older categories, notably Drones (542 LIVE vs 618 TEST), Lenses (538 vs 606), Cameras (573 vs 614), and Camera Accessories (210 vs 244). The 3D printer and Mobile Phones active evidence counts now match; product totals differ only by documented inactive TEST audit rows. Do not start the full Gemma sweep until the remaining intended categories and source-selection routes are checked.


## 8 November 2026 — 3D-printer structured GBP capture and category-scoped Gemma routing

For 3D-printer tasks only, the Gemma page extractor now places matching JSON-LD Product/Offer facts before long flattened page text. Manufacturer/model identity must match the task. GBP offers are emitted with an explicit GBP prefix so the deterministic price parser can recognise the amount; non-GBP currencies remain distinct and are never relabelled. Other categories retain their existing content-first page-text ordering.

The worker now loads approved sources using a server-side PostgREST array-overlap filter: task category plus explicitly universal UK sources, restricted to enabled rows with country_code GB. Only Amazon UK and eBay UK are universal. Missing/malformed category fails closed. Existing manufacturer filtering, 3D-printer new/used lane checks, URL validation and raw-capture hand-off remain.

The regression tests are included in GitHub CI and Update-TradeFlow-Gemma.ps1. Do not update/restart the Research PC until the combined PR passes CI and merges.

Gaming category parity is verified: 284 active products and 411 active evidence rows in each LIVE and TEST; zero product-field differences and zero active-evidence differences. Gaming has 12 category-specific sources plus 2 universal UK sources (14 loadable sources).

Current enabled UK source counts (category-specific plus universal): 3D printers LIVE 15 / TEST 5; cameras 16 both; drones 8 both; gaming 14 both; laptops 12 both; metal detectors 8 both; mobile phones 13 both. The 3D-printer source registry remains a separate LIVE/TEST parity gap; do not blindly copy source rows between environments.

## 8 November 2026 — LIVE drone category source coverage preparation

Followed the 7 November operating decision: LIVE is the sole authoritative product/research queue and evidence environment; TEST is retained for software development and regression. No further routine catalogue/evidence copying to TEST. Existing TEST records are preserved.

LIVE Drones audit:
- 541 active products across 18 manufacturers.
- 542 active evidence rows.
- 306 active products have no active evidence; 235 have at least one active evidence row.
- No outstanding Drones research queue items.
- Largest uncovered manufacturers: Skydio 46, Hubsan 44, Potensic 32, Walkera 24, Parrot 21, BetaFPV 20, Holy Stone 18, Autel 16, PowerVision 16, FIMI 15, iFlight 12, Freefly 11, Yuneec 11, GEPRC 5, EMAX 3. CaddxFPV has no uncovered active products.

Added category-scoped sources to LIVE only, for Drones and/or Drone Accessories:
- HOVERAir UK Official Store (uk.hoverair.com): official UK store, product and accessory prices in GBP.
- Holy Stone UK Distributor — DMTL (dmtl.co.uk): listed by Holy Stone Europe as its UK distributor; use only direct verifiable product pages and GBP prices.
- Flying Tech UK (flyingtech.co.uk): UK specialist retailer with BetaFPV, CaddxFPV, EMAX, GEPRC, iFlight and related FPV equipment. Retailer, not represented as manufacturer-authorised.
- Unmanned Tech UK (unmannedtechshop.co.uk): UK retailer with BetaFPV, Caddx, EMAX, GEPRC, Hubsan and iFlight products.
- IT Drone Services UK (itdroneservices.co.uk): UK FIMI store with GBP product listings.
- CameraWorld UK (cameraworld.co.uk): existing source assignment extended to Drones and Drone Accessories; listings include Potensic and DJI.
- Wilko UK (wilko.com): Potensic Atom 2 drone listings.
- Aetha UK (aetha.global): Skydio X10D UK exclusive drone solutions service provider; source kind recorded as other and notes prohibit inferring prices when quote-only.

Existing LIVE DJI UK, Heliguy, HobbyRC, DJI Retail UK, DJI Store and MPB UK assignments remain. Universal Amazon UK and eBay UK remain universal sources.

Manufacturer-source exclusions/gaps were deliberately retained rather than guessed:
- Autel UK website is for automotive diagnostic equipment, not Autel Robotics drones; no Autel UK drone source added.
- Parrot's official reseller finder currently shows Dronivo in Germany, not a UK reseller; no UK official Parrot source added.
- Yuneec UK says service has closed and web orders are open for spare parts; not treated as a new drone source.
- Freefly, PowerVision and Walkera have no verified UK public pricing source in this review. Skydio/Aetha may be quote-only.
- Potensic's official authorised-dealer page did not show a UK authorised dealer; CameraWorld and Wilko are recorded only as UK retailers, not authorised distributors.

Verified production agent source routing in tools/tradeflow-gemma-agent/src/agent.mjs: isCategoryAllowedSource and isResearchTypeAllowedSource are applied by isApprovedSourceForTask before source probing. Category-specific sources therefore remain scoped to their assigned category; universal Amazon/eBay remain available. The Research PC has not yet been updated, so do not start/restart a worker or enqueue tasks until the approved local updater and Ollama acceptance checks are completed.

Gemma gates remain:
- PR #312 is open/ready for review, not merged; CI 73/73 passed. It changes 3D-printer structured GBP extraction.
- PR #300 remains draft/open, not merged; CI 54/54 passed.
- Research PC installation, local Ollama structured-output acceptance and end-to-end LIVE batch verification remain outstanding.
No research task was queued and no worker was restarted by this source-coverage change.

## 8 November 2026 — LIVE lighting and production source coverage

Continued LIVE-only category preparation; TEST was not modified. The main Lighting category has 200 active products and 18 without active evidence. Before any Gemma task submission, expanded category-scoped UK sources in LIVE:
- NEEWER UK Official Store (uk.neewer.com): official UK GBP store for continuous lights, panels, ring lights, flashes, softboxes, stands, batteries, monitors and phone rigs. Assigned only to relevant lighting/rig/power/tripod categories.
- Elinchrom UK Official Store (elinchrom.co.uk): official UK store and service centre for studio flash, LED lighting and accessories.
- CVP UK (cvp.com): UK professional retailer for Aputure, amaran, Atomos, lighting, audio and production equipment. Retailer, not labelled as manufacturer-authorised.
- Atomos UK Official Store (atomos.com, country=GB): official UK-filtered store for monitors, recorders, wireless sync and accessories.
- Production Gear UK (productiongear.co.uk): UK retailer with Nanlite, Z CAM, SmallRig and production equipment; assigned to relevant lighting/video/camera categories.
- Wilkinson Cameras UK (wilkinson.co.uk): UK retailer for SmallRig camera rigging, tripods and lighting accessories.
- Essential Photo UK (essentialphoto.co.uk): UK retailer for SmallRig lighting, tripods and rigging.
Existing Wex Photo Video source assignments were retained. All new sources are category-scoped in LIVE; universal Amazon UK and eBay UK remain universal.

Verified LIVE source counts after update: Lighting 9; Continuous Lighting 6; Studio Lighting 9; Lighting Modifier 5; Lighting Support 5; Photography Lighting & Studio 5; Camera Flash 5; Video Production Equipment 8; Camera Accessories 21; Camera Rig 9; Tripods 6; Power & Batteries 8. Where UK retailers display ex-VAT and inc-VAT amounts, the agent must use the inc-VAT GBP consumer price for standard new-price evidence; never mistake ex-VAT as the retail total. Distinguish new, used, ex-demo and open-box condition.

No product or evidence rows were changed in this source update. No research tasks were queued and no worker was restarted. LIVE remains the authoritative catalogue; TEST remains software/regression only.


## 8 November 2026 — Owner dashboard active-list deployment gate

The LIVE research queue is fully processed: 65 3D-printer rows are terminal (28 imported, 37 rejected), with zero open research rows across all categories. LIVE has 20 completed AI-agent tasks and zero queued/running/failed tasks. TEST has zero open research rows and one queued 3D-printer smoke-test task (Creality Ender-3 V3 KE), plus one completed task; do not cancel the queued test without review.

The current production frontend is already configured to hide completed work:
- platform-owner-dashboard.html labels the panels “Outstanding research tasks” and “Research awaiting review”.
- platform-owner-dashboard.js calls platform_owner_list_ai_agent_tasks with p_status='active' (queued/running/failed only) and platform_owner_list_catalogue_research_queue with p_status='open' (pending_review/needs_research/approved only).
- The LIVE RPC definitions implement those filters correctly; completed tasks and imported/rejected research records remain in database history.
- worker/index.js serves the owner dashboard HTML and JavaScript with Cache-Control: no-store.

The user's screenshot still shows the older “Queued and completed tasks” panel and processed records. That is not the current production HTML/JS or RPC behavior; the deployed Cloudflare Worker named tradeflow has not been verified and is likely serving an older asset bundle. There is no GitHub Actions deployment workflow in the repository. Verify Cloudflare Workers & Pages > tradeflow > Deployments and deploy the latest production commit before changing database rows or queue statuses again. Do not delete completed history to make the dashboard look clear.

## 8 November 2026 — LIVE Audio and Professional Audio source coverage

Continued LIVE-only category preparation; TEST was not modified. Audio category contains 134 active products. Main uncovered groups are Shure (25), RØDE (19), Sennheiser (4), Atomos (4), Sony (6) and NEEWER (1); these figures are active products without active evidence, not manufacturer totals.

Added category-scoped official UK manufacturer/product sources in LIVE:
- RØDE UK (rode.com/en-gb): official UK product catalogue and authorised-dealer locator; use for exact model/specification/bundle/discontinued status, and obtain prices from UK dealers where no GBP price is shown.
- Shure UK (shure.com/en-GB): official UK product pages with GBP recommended retail prices.
- Sennheiser UK Pro Audio (sennheiser.com/en-gb): official professional audio product catalogue/specifications.
- Sennheiser UK Official Store (sennheiser-hearing.com): official UK consumer store with GBP prices; scope only to products actually listed there.
- Audio-Technica UK (audio-technica.com/en-gb): official product catalogue/specifications; use UK retailers for prices where none are shown.
- Audient (audient.com): official audio interface/preamp catalogue; UK retailers for prices.
- Zoom UK (zoomcorp.com/en/gb): official UK product catalogue for recorders, microphones and mixers.
- Yamaha UK (uk.yamaha.com): official UK professional audio catalogue.

Added UK retail sources in LIVE:
- Andertons UK (andertons.co.uk), Gear4music UK (gear4music.com), GuitarGuitar UK (guitarguitar.co.uk). Their direct product listings show GBP prices and stock status for RØDE, Shure, Sennheiser and other audio brands.
Existing Sony UK, Wex Photo Video and CVP UK sources remain. NEEWER UK and Atomos UK source assignments were extended to Audio/Audio & Video/Professional Audio where relevant. Amazon UK, eBay UK and CeX UK remain universal.

Verified source counts after update: Audio 20; Audio & Video 19; Professional Audio 17; Video Production Equipment 14; Camera Accessories 23; Phone Photography 4. Manufacturer pages without explicit GBP prices are identity/specification sources only; price evidence must come from UK GBP retailer listings. Where ex-VAT and inc-VAT are both shown, use inc-VAT for the consumer price. Distinguish new, used, nearly-new, B-stock and ex-demo.

No product/evidence rows changed, no research tasks queued and no worker restarted. LIVE remains authoritative; TEST remains software/regression only.


## 8 November 2026 — LIVE Cameras source coverage expansion

LIVE remains the authoritative shared product/evidence catalogue; TEST was not modified. Cameras contains 722 active products, of which 305 currently have no active market-evidence row. The enabled category-scoped source count is now 21.

Added seven official manufacturer sources to LIVE platform_research_sources, each explicitly scoped to cameras (not universal):
- Nikon UK Official — nikon.co.uk, https://www.nikon.co.uk/en_GB/product/cameras/mirrorless.
- Canon UK Store — canon.co.uk, https://www.canon.co.uk/store/cameras/.
- FUJIFILM UK Official eShop — eshop.fujifilm-x.com, https://eshop.fujifilm-x.com/uk/cameras.html.
- Panasonic UK Store — uk.store.eu.panasonic.com, https://uk.store.eu.panasonic.com/cameras-and-camcorders.
- OM SYSTEM UK Official — explore.omsystem.com, https://explore.omsystem.com/gb/en/cameras/om-d.
- Polaroid UK Official Store — polaroid.com, https://www.polaroid.com/en_gb/cameras.
- Z CAM Official — z-cam.com, https://www.z-cam.com/products/professional-cameras/.

Official manufacturer pages are authoritative for model identity, exact configuration, specifications and release/discontinuation status. Capture prices only when a visible UK GBP offer is present. Z CAM is a global specification source, not a UK price source. For retailer prices, use approved UK product pages and select the inc-VAT GBP consumer amount where both ex-VAT and inc-VAT are shown. Keep camera bodies, lens kits, instant-camera sets, film and accessories distinct; do not infer bundle contents or collapse package variants.

Existing Sony UK, Camera Price Buster (discovery only), Jessops, Park Cameras, Production Gear UK, Wex Photo Video, Clifton Cameras, Harrison Cameras, Castle Cameras, MPB UK, London Camera Exchange, Ffordes, Used Lens and CeX UK source assignments remain unchanged.

Post-write verification: 7 source rows inserted; 21 enabled sources scoped to Cameras; 722 active camera products; 305 active products still without active evidence. No product or evidence rows changed, no research task was queued, no worker was restarted, and TEST was not modified. Source coverage is not evidence coverage; this update does not claim that the 305 products now have prices.


## 8 November 2026 — Gemma runtime and capture-path review

A read-only review of LIVE telemetry and production code was completed. The latest controlled 3D-printer capture task was Anycubic Kobra S1 Max (`owner-3d-printers-capture-only-smoke-20261108-2020`). It found the official UK product page https://uk.anycubic3d.com/products/kobra-s1-max and retained one exact-model page. The page visibly contains separate UK GBP options: standard machine £549, 4-colour combo £749, 8-colour combo £935 and 16-colour combo £1,307. No new product was created. The existing queue record was enriched and subsequently appears in imported history; the linked active evidence row maps to the 16-colour combo at £1,307.

Important metric interpretation: the production 3D-printer path is intentionally capture-first. Its `gemma_calls = 0` is expected because local Ollama inference is bypassed for this category and ChatGPT reviews the raw capture. `eligible_urls = 0` counts direct eligible search-result URLs; it does not include collection-discovered product pages. The authoritative output counters are `discovered_product_pages` and `captured_pages`; both were 1 for this task. Do not label this smoke task an extraction failure solely because Gemma calls were zero.

A historical queue metadata inconsistency was identified on the enriched/imported Anycubic row: queue `package_key` is `standard` while queue `package_name` is `16-Color Combo`. The linked active market-evidence row is correctly attached to the existing `combo-16-color` master product at £1,307. The mismatch is confined to the historical queue metadata; it has not been edited. Other imported rows with combo names and a standard queue key were also found, while their linked active evidence maps to the correct combo product. Audit this metadata separately before changing any rows; preserve source provenance and do not delete history.

The production branch agent contains the capture-first 3D-printer path. The open PR #300 branch contains a different extraction path, so the installed Research PC source branch/commit must be verified before assuming it matches production. Supabase telemetry does not currently record a reliable installed commit fingerprint. PR #300 remains draft/open (54 tests passed); PR #312 remains open/ready for review (73 tests passed). A previous local Ollama structured-output smoke test is not equivalent to full acceptance of the installed branch, source discovery, category routing, capture handoff and queue write together.

Current worker state: no active task; the Gemma task worker is idle and its last recorded heartbeat is 2026-11-08 20:28 UTC. Do not restart it or launch a full run until the installed source commit is identified and one controlled exact-model test verifies source routing, page capture, package separation, UK GBP extraction and ChatGPT handoff. No product/evidence records were deleted, no TEST data was changed and no full research run was started.


## Camera source coverage follow-up — Blackmagic Design

A further manufacturer gap was closed in LIVE: added Blackmagic Design UK Official (blackmagicdesign.com, https://www.blackmagicdesign.com/uk/products) as a manufacturer/official GB source scoped only to cameras. Its UK product catalogue exposes camera product pages and GBP prices; use the Professional Cameras family and exact model pages, and keep camera bodies separate from viewfinders, recorders, mounts, grips and accessories.

Verification after this addition: 22 enabled Cameras-scoped sources; 722 active camera products; 305 active camera products still without active market evidence. The 305 gap is unchanged because only the source registry was changed. No product/evidence rows or TEST data were modified. Supabase activity record owner-live-camera-source-coverage-blackmagic-20261108 was inserted and verified.


## 8 November 2026 — LIVE drone UK source coverage expansion

Added five category-scoped UK sources to LIVE for the drones category:
- Modus Brands UK — Autel Robotics UK distributor reference, https://www.modusbrands.com/brands-trust-us/autel-robotics-drone-distributor/. Use for official distribution/model context; it is not automatically a consumer price source.
- Leicester Drones UK — https://www.leicesterdrones.com/. UK authorised retailer for DJI, Parrot and Yuneec; use exact product pages and visible GBP offers.
- Quadcopters UK — https://www.quadcopters.co.uk/. UK retailer and distributor for BetaFPV/Yuneec; distinguish complete drones from FPV parts and accessories.
- Whoop Store UK — https://www.whoopstore.uk/collections/drones-by-geprc. UK GEPRC listings with GBP prices; distinguish complete drones from components.
- Drone Authority UK — https://www.droneauthority.co.uk/collections/pre-built. UK pre-built FPV listings including BetaFPV, EMAX and iFlight; exclude zero-price placeholders and parts-only listings.

Post-change verification: 19 enabled sources scoped to drones; 541 active drone products; 306 active drone products without active market evidence. The evidence gap is unchanged because only the source registry was changed. Existing DJI, HOVERAir, Aetha/Skydio, Holy Stone/DMTL, FIMI/IT Drone Services, Flying Tech, Unmanned Tech, HobbyRC, CameraWorld, Wilko, MPB and DJI UK source rows remain unchanged. No product/evidence rows changed, no research task was queued, no worker restarted and TEST was not modified.


## 8 November 2026 — LIVE mobile-phone source coverage expansion

Added ten category-scoped UK sources to LIVE mobile-phones:
- HONOR UK Official — https://www.honor.com/uk/phones/.
- Xiaomi UK Official Store — https://www.mi.com/uk/product-list/phone/.
- TCL UK Official — https://www.tcl.com/uk/en/mobile.
- Doro UK Official — https://www.doro.com/en-gb/products/.
- HMD UK Official — https://www.hmd.com/en_gb/smartphones.
- realme UK Official — https://www.realme.com/uk/.
- Nothing UK Official — https://nothing.tech/collections/phones.
- OnePlus UK Official Store — https://www.oneplus.com/uk/store.
- Ballicom UK — Fairphone smartphone catalogue, https://www.ballicom.co.uk/manufacturers/fairphone/.
- Clove Technology UK — Fairphone smartphone catalogue, https://www.clove.co.uk/collections/smartphones-fairphone.

Manufacturer pages are for exact model identity, storage/RAM variants, specifications and current/discontinued status; capture prices only when a visible UK GBP offer exists. Ballicom and Clove are UK GBP retail sources for Fairphone; use inc-VAT consumer prices and exclude earbuds, cases, modules and cables. Fairphone's official global shop may display EUR, so do not treat it as UK GBP price evidence.

Post-change verification: 21 enabled sources scoped to mobile-phones; 158 active products; 0 active products without active market evidence. No product/evidence rows changed, no research tasks queued, no worker restarted and TEST was not modified. Existing Apple, Google, Motorola, OPPO, Samsung, Argos, Currys, John Lewis, EE, Very and CeX sources remain unchanged.


## 8 November 2026 — LIVE metal-detector source coverage expansion

Added five UK sources scoped only to metal-detectors:
- Nokta UK Store — https://www.noktauk.com/collections/metal-detectors; visible GBP prices and stock status.
- LP Metal Detecting UK — https://www.lpmetaldetecting.com/; UK distributor/retailer with Nokta, Minelab, XP, Garrett and Quest ranges and GBP product pages.
- Crawfords Metal Detectors UK — https://crawfordsmd.com/metal-detectors; UK retailer with XP, Nokta, Garrett, Quest, Teknetics and Minelab product pages and GBP prices.
- Detecnicks UK Used Detectors — https://www.detecnicks.co.uk/Second-hand_Metal_Detectors.html; used-only lane with dated listings, condition context and GBP prices.
- Detector Distribution UK — https://detector-distribution.co.uk/metal-detectors; UK authorised dealer with XP, Garrett and Nokta listings and GBP prices.

Official dealer validation: Nokta's UK dealer directory lists LP Metal Detecting, Unearthed, Spin a Disc, Regton, Detecnicks and Crawfords; XP's official reseller network lists UK dealers including Crawfords, Detecnicks, Regton, Spin a Disc and others. Garrett identifies Regton as its UK & Ireland distributor. Keep new and used evidence separate; use the Detecnicks second-hand page only for explicitly used/ex-demo listings and confirm availability/condition before approval.

Post-change verification: 11 enabled sources scoped to metal-detectors; 125 active products; 32 active products still without active market evidence. Evidence gap unchanged because only source registry rows changed. No product/evidence rows changed, no research task queued, no worker restarted and TEST was not modified. Existing Minelab UK, Regton, Spin a Disc, UK History Finders, Unearthed UK and Wolds Detecting source rows remain unchanged.


## 9 November 2026 — Gaming Consoles & Accessories Gemma rollout (first category after 3D printers)

The 3D-printer workflow remains the proven pilot. The next category is Gaming Consoles & Accessories, following the merged PR #314 rollout sequence. LIVE is authoritative; TEST is used only for controlled software/regression validation. No existing product, evidence, tenant or customer data is to be copied, deleted or overwritten.

LIVE baseline verified before this rollout: 284 active gaming products and 411 active linked market-evidence rows (246 UK-new, 165 UK-used). The evidence is already present and is not a target for re-import. Drones (541 products / 542 active evidence rows), Cameras (722 / 573), and Mobile Phones (158 / 567) were also verified as having existing linked evidence and must be preserved when their agents are rolled out.

The gaming implementation is being prepared on feature branch `feat/gemma-gaming-capture-rollout-20261109`. It extends the 3D-printer capture-first handoff to the gaming agent only: preserve full page captures, all visible GBP price mentions and contexts, exact console/accessory variant details, condition, availability and location; leave evidence type, price approval and master-product matching to ChatGPT. UK-new and UK-used source lanes are filtered separately. Category/branch playbooks cover consoles, handhelds, controllers, headsets, VR and accessories.

CI and code review are complete: PR #316 is merged to production and GitHub Actions passed 79/79 tests. A controlled Xbox Series S TEST task is queued (UK-new and UK-used). Next, update the Research PC from production and start the worker in TEST to run that task. An older queued TEST 3D-printer smoke task was marked cancelled (not deleted) to prevent it being claimed during the gaming rollout; the task row and history remain. No gaming task has yet been queued and no worker has been restarted.


## 9 November 2026 — LIVE-first Research PC launcher correction

The desktop shortcut launches `Start-TradeFlow-Gemma.ps1` without an environment argument. Production previously defaulted the launcher, updater and `resolveControlPlane()` to TEST. This caused the desktop launcher to display a LIVE startup label while the worker correctly reported `control plane: TEST only`. A gaming Xbox task was claimed and completed in TEST; the TEST task row records zero `platform_catalogue_research_queue` rows. No Gaming task was present in LIVE and no LIVE Gaming evidence was produced.

Correction: LIVE is now the default for the desktop launcher, updater and worker resolver. TEST remains available only when explicitly selected with `-Environment TEST` / `TRADEFLOW_GEMMA_ENVIRONMENT=TEST` for software-development work. The worker prints the verified Supabase project ID before polling. Keep the worker stopped until the Research PC is updated from production, local tests pass, and the startup log explicitly reports `VERIFIED control plane: LIVE (gxsrajtqzdjvmceqcpgv)`. Do not dispatch Gaming work until the LIVE Owner Dashboard shows the queued task. Preserve the existing `.env`; no secrets, TEST data or LIVE catalogue evidence are copied or altered by this code correction.


## 9 November 2026 — Repair legacy desktop shortcut target

The Research PC desktop shortcut is confirmed to target `Start-Gemma-Worker.ps1`, while the canonical production queue-worker launcher is `Start-TradeFlow-Gemma.ps1`. The legacy file was not included in the updater's installation set. Consequently, updating the canonical launcher did not change what the existing desktop shortcut executed; the shortcut continued running the old local research runner, whose output explicitly reported catalogue writes disabled. This explains why local JSON results appeared in PowerShell while no LIVE review-queue records were created.

Repair: the production updater now generates and installs a compatibility `Start-Gemma-Worker.ps1` shim at the exact legacy shortcut path. The shim delegates to `Start-TradeFlow-Gemma.ps1` and defaults to LIVE. The updater backs up the previous legacy launcher, validates the generated shim with the PowerShell parser before installation, and validates the installed shim afterwards. The canonical launcher and worker remain responsible for the approved project-ID check and persistent queue polling. The existing shortcut Target and Start in values need not be edited.

Deployment is not complete until the Research PC updater installs this latest production updater, the existing desktop shortcut is started, and its console reports `VERIFIED control plane: LIVE (gxsrajtqzdjvmceqcpgv)`. Then dispatch a small LIVE Gaming evidence task and verify its raw capture row appears in `platform_catalogue_research_queue` and the LIVE Owner Dashboard. No TEST website/database research or evidence writes are permitted. Do not claim the queue handover is repaired until that end-to-end LIVE capture is observed.


## 9 November 2026 — Gaming Gemma source setup and dashboard verification

Gaming is not starting from an empty source registry: the LIVE source manager RPC was verified against the active `gaming-consoles-accessories` master category and returns the category's enabled websites. The source playbook already contains Xbox/PlayStation/Nintendo branch rules and the 3D-printer-style capture-first handoff. The dashboard screenshot showed an "Unknown or inactive catalogue category" response despite the LIVE master category being active; a read-only owner-context RPC check against LIVE returned the expected source list, so the displayed error appears to be stale browser state or a transient dashboard/API mismatch rather than a missing category row. Hard-refresh and re-open the Gaming source manager after deployment/session refresh; do not recreate the category or alter existing category IDs.

Added three additional LIVE UK used-market sources for Gaming: Cash Converters UK (`cashconverters.co.uk`), Cash Express UK (`cashexp.co.uk`) and Gumtree UK (`gumtree.com`). They are enabled and scoped only to `gaming-consoles-accessories` (Gumtree retains its existing 3D-printer scope). New/official and used lanes remain separate. Current enabled Gaming source set: 17 websites total, 12 available to the UK-new lane and 6 to the UK-used lane, with Amazon UK shared across both; eBay UK remains used-lane only. Source manager read RPC returns these rows successfully when called in the active platform-owner context.

Updated the production gaming playbook with source-specific navigation and exclusion rules for Cash Converters, Cash Express and Gumtree. Added regression assertions for all three. GitHub Actions Gemma Research Tests run #412 passed on production commit `5a70cdbe978f0b45e5336436f5f0fbf89addfe0d`; all steps completed successfully, including PowerShell/source syntax, playbook tests and Owner Dashboard JavaScript syntax.

The Research PC worker is connected to LIVE Common Room, but the Gaming agent is idle and no Gaming task has been dispatched. The Common Room instruction for Xbox Series S 512GB new/used was posted earlier; this is not a queued task. Do not mark the agent Running until a queued task is claimed and a fresh gaming status heartbeat appears. Next step is to refresh the owner dashboard, verify Gaming agent linkage/source list, then dispatch the controlled Xbox Series S 512GB UK-new and UK-used batch through the authenticated owner task workflow. No TEST site/database research or evidence writes; no existing product/evidence records changed.

## 9 November 2026 — Restore the established 3D-printer Gemma extraction path

PR #316 unintentionally broadened `isCaptureOnlyResearchTask()` from the 3D-printer-specific fast-capture handling to include all 3D-printer tasks as capture-only. This bypassed `extractBatch()` and Ollama/Gemma for 3D-printer research. LIVE K1 Max task `0ce88391-e5c2-45c4-adf9-149d364c702c` explicitly logged `Capture-only mode ... local Ollama inference is intentionally skipped`; its page was retained as raw capture but not enriched by Gemma. This contradicted the pre-rollout 3D workflow, whose task metrics showed Gemma extraction calls and structured observations. Ender-3 V3 KE task `5b3e53b0-b857-4f0b-89a0-e255596afd3c` independently found no eligible page, so source discovery remains a separate issue and must not be conflated with the extraction regression.

Correction in PR #320 scopes `isCaptureOnlyResearchTask()` to Gaming only. 3D-printer tasks therefore return to the established `extractBatch()` / Ollama path, retaining the existing deterministic raw fallback when extraction fails. Gaming remains capture-only. A regression test explicitly asserts this separation. No Research PC installation, source registry, LIVE/TEST database records, queue records, approvals or imports are changed by the code correction. After CI passes and the fix is merged, verify a single small 3D-printer LIVE task reaches `extraction_batch_started` and records `gemma_calls > 0`; do not change the working 3D-printer source settings. Separately diagnose any model/source discovery failures using route telemetry.

## Gemma Windows Research Control Centre — 9 November 2026

The Windows desktop Control Centre is a separate local application for the existing Gemma Research PC. Its code lives in `tools/tradeflow-gemma-desktop/`; its worker integration lives in `tools/tradeflow-gemma-agent/src/desktop-control.mjs` and `task-worker.mjs`.

### Operating architecture
- One Windows Task Scheduler supervisor starts one persistent Node queue worker at user sign-in.
- The seven controllable product-research specialists are 3D Printers & Equipment, Gaming Consoles & Accessories, Drones, Metal Detectors, Mobile Phones, Laptops & Computers, and Cameras & Lenses.
- Legacy `3d-printers` and `gaming-consoles` status identities map to their canonical specialist switches.
- The Catalogue Importer remains owner-approval-gated. Release Monitor is not yet connected to the catalogue product-research queue and is not exposed as an executable product-research switch.
- The single worker polls the LIVE task queue and reads the local enabled-agent list before every claim. It does not start seven competing Node/Ollama processes.
- `platform_ai_agent_claim_task_for_agents(text,text[],integer)` is the new service-role-only claim RPC. A queue task is claimable only when it contains at least one subtask and every subtask resolves to an enabled specialist key. Mixed-agent tasks remain queued until every included specialist is enabled.
- The existing generic claim RPC is retained for backward compatibility. Desktop mode never falls back to it if the scoped RPC is missing.
- Disabling a specialist prevents future claims for that specialist. A task already running is allowed to finish. Global stop also waits for the current task to finish.
- The local config contains enabled agent keys and service state only; the existing private `.env` remains at its existing path and is not copied, printed or overwritten.

### Website research configuration
The LIVE `platform_research_sources` registry was audited, not rebuilt. On 9 November it held 119 source records total (116 GB-coded and 3 US-coded; all 119 enabled). Enabled category coverage including shared universal sources: 3D printers 15, gaming 17, drones 21, metal detectors 13, mobile phones 23, laptops 12, cameras 24. Counts overlap where one source serves several categories.

Existing 3D-printer and gaming playbooks were preserved. Dedicated website navigation and exact-model/variant rules were added for drones, metal detectors, mobile phones, laptops and cameras in `source-playbooks.mjs`. Discovery routes are not evidence: the worker must follow exact product/listing links and retain individual page captures for ChatGPT/owner review.

### Deployment boundary
The feature is developed on `feature/gemma-desktop-control-centre-20261109`, PR #325, based on production commit `e81ede671bfc03e73dc16169638011372b5b6117`. The SQL migration is part of the PR only. No LIVE/TEST migration, source-row change, queue write, research run, PC update or worker restart has been performed. Do not install or enable the desktop supervisor until PR review/merge and the agent-scoped RPC migration has been applied to LIVE. If the RPC is absent, the desktop worker must stop with `requires_migration` and must not use the generic claim path.

See `tools/tradeflow-gemma-desktop/README.md` for the install workflow and `docs/TRADEFLOW-DEEP-SOURCE-RESEARCH-ROADMAP.md` for the diagnostic path.


## Gemma specialist source-route audit — 9 November 2026

Follow-up to PR #325: the LIVE research-source registry was compared against the existing category-specific website playbooks. The earlier route-count comparison was based on an incorrect block boundary and falsely reported missing websites. Re-inspection of the complete category blocks confirmed the registered domains already had category-specific playbook entries except Aetha UK (aetha.global), whose entry had no discovery route. Added verified homepage discovery routes for Aetha UK (aetha.global) and six UK metal-detector retailers that previously had no routes: Regton, Spin A Disc, UK History Finders, Unearthed UK, Wolds Detecting and LP Metal Detecting. Existing UK source registry rows and all other playbook entries have been retained unchanged.

A regression test was added to protect the website coverage already configured for the additional specialist domains: HobbyRC, Heliguy, DJI Retail, DMTL, Leicester Drones, Quadcopters; Argos, Currys, John Lewis, EE, Very, OPPO, realme; Sony UK, Jessops, Park Cameras, Clifton Cameras, Harrison Cameras, Camera Price Buster, Castle Cameras, Production Gear; plus Amazon UK and eBay UK marketplace routes for metal detectors. The test checks category-specific instructions and homepage discovery routes, plus the dedicated Amazon ASIN and eBay active-listing search patterns. The first run exposed Aetha UK's missing route; that was fixed by adding its homepage route, and the test is being rerun against the corrected branch head.

The seven desktop switches remain one per product category: 3D Printers, Gaming Consoles, Drones, Metal Detectors, Mobile Phones, Laptops and Cameras. They share one queue supervisor and one Ollama execution lane; this is deliberately not seven competing Node workers.

Status: the regression-test change is committed to feature/gemma-desktop-control-centre-20261109 / PR #325. The latest post-change CI result must pass before merge. No LIVE/TEST source rows, queue rows, evidence, catalogue rows or approvals were changed. No SQL migration has been applied, and no Research PC worker has been installed, restarted or started. The scoped-claim migration remains a deployment gate before the Windows installer can start queue processing.


## Post-merge deployment verification — Gemma Control Centre (9 November 2026)

PR #325 was merged to `production` as commit `b20123fd8f832388011589ac8e7f9e602bb98f08`. Production GitHub Actions run #473 passed the Gemma research workflow, including PowerShell syntax, Node syntax, all 92 Gemma tests and Owner Dashboard JavaScript syntax.

The LIVE database now contains `public.platform_ai_agent_claim_task_for_agents(text,text[],integer)`. Read-only permission checks confirmed:
- `service_role` can execute it.
- `authenticated` cannot execute it.
- The function is SECURITY DEFINER with `search_path=public, private`.

The same RPC is absent from TradeFlow TEST. This is intentional: the desktop supervisor is LIVE-only and TEST remains separate. No TEST data has been copied to LIVE.

The Windows installer is available from the production branch at `tools/tradeflow-gemma-desktop/Install-TradeFlow-Research-Control-Centre.ps1`. The installer has not yet been run on the Research PC; no local worker was stopped, restarted or installed by this verification. Do not claim the desktop app is operational on the PC until the owner runs the installer and a bounded LIVE review-only acceptance task confirms raw capture in the existing review queue.

The LIVE source registry remains 119 records total (116 GB-coded and 3 US-coded; all 119 enabled). No source registry rows, tasks, review-queue rows, catalogue/evidence, approvals or imports were changed during the merge/migration verification. The existing private `.env` remains on the Research PC.

Current next step: owner installs from production on the Research PC. Open PowerShell in the existing Gemma folder, download the production installer, and run it. If the old manual worker is active, stop it cleanly with Ctrl+C first. Never paste or disclose the private `.env` contents.

 
### Live worker snapshot before Research PC installation — 11:57 UTC
The LIVE `platform_ai_agent_status` and activity records show one generic TradeFlow Gemma task worker connected and idle, polling every 15 seconds. The queue currently contains 24 completed tasks and no queued/running tasks. This is the existing legacy worker, not the new desktop supervisor. The installer will refuse to overwrite it while active. When installing on the Research PC, stop the existing worker cleanly with Ctrl+C first; do not terminate an active task or force-kill the process.


## Gemma shortcut window correction — 9 November 2026

The owner demonstrated that each new category shortcut opened both a new PowerShell console and another copy of the Research Control Centre. This was traced to the installer creating shortcuts without `-WindowStyle Hidden`, and the UI script having no single-instance guard.

Production was corrected:
- Both the main Control Centre shortcut and all seven specialist shortcuts now launch PowerShell with `-WindowStyle Hidden`.
- The Control Centre now acquires a per-user named mutex before creating its form. Only one dashboard instance can remain open.
- A specialist shortcut still writes its selected agent key to the shared config and starts the existing scheduled supervisor, then exits if the dashboard is already open. The existing dashboard refreshes from shared config every three seconds and displays the newly enabled specialist.
- The mutex is released when the dashboard closes.

The change is committed to production in commits `af867edd067422adfd8a371cecb4f939ae231268` and `a1376bbefde726543b47606064f60486fbafea0d`. The new code was inspected after commit. A new production CI run had not appeared at the time of this checkpoint, so do not describe the correction as CI-verified yet.

The Research PC still has the previous installed copies of these scripts and shortcut arguments. To apply the fix, stop the background service after any current task finishes, then rerun the production installer from the existing Gemma folder. The installer will refuse to overwrite an active supervisor or legacy worker. After installation, verify one Control Centre window and no PowerShell console when opening a specialist shortcut.


## Hidden shortcut launcher correction — 9 November 2026

The owner clarified that the second visible tab was titled with the executable path `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`. This is a second PowerShell console session, not a keyboard shortcut. The prior `-WindowStyle Hidden` shortcut setting did not prevent Windows Terminal/PowerShell from presenting the launcher console on the owner's PC.

The production installer now downloads `Launch-TradeFlow-Control-Centre.vbs` and creates the main Control Centre and seven specialist shortcuts with `wscript.exe` as the target. The VBScript starts the PowerShell WinForms UI with window style 0 (hidden) and passes through the optional specialist arguments. The WinForms Control Centre remains visible. The existing named mutex still enforces one dashboard instance, and the existing scheduled supervisor remains the only background research worker.

The owner installed the previous build before this WScript-host correction was added. The PC must be updated by rerunning the production installer once more after the background service has been stopped safely. This is a launcher-only correction; do not change the worker, .env, LIVE queue, or TEST configuration.


## 9 November 2026 — 3D-printer discovery, full-page capture and ELEGOO used-lane repair (review PR #332)

Scope is limited to LIVE category `3d-printers-equipment`, branch `3d-printers`. The feature branch is based on current production `de1b8d4e12edf0102cea28f935a763826ff1c06b`. It consolidates the stale PR #327 full-page/Creality-route correction and PR #323 ELEGOO used-lane correction onto current production; those earlier PRs are to be closed as superseded only after this replacement passes CI.

### LIVE evidence and first loss points
- Exact branch task history: 19 registered task rows, 56 product subtasks; 19 completed, 0 queued/running/failed. Latest task completed 01:56:42 UTC.
- Latest Ender-3 V3 KE: 11 search results, 0 exact individual product pages discovered/fetched, 0 Gemma calls; 28 approved-source route attempts (11 route candidates, 11 empty, 6 errors), plus two Creality collection JSON 404s.
- Latest K1 Max: 11 search results, 1 exact page discovered/fetched, 0 Gemma calls because the task predates PR #320's production merge, 1 raw candidate and queue write `duplicate-skipped` against the existing imported K1 Max record. It also probed the unrelated Ender-3 V3 family collection and received one 404.
- Repeated route failures include Uni3Dverse 404, eBay UK 403/404, Amazon UK 404 and SecondHand.org.uk 404. No direct individual-page fetch error occurred in the latest K1 Max task.
- The earliest measurable loss remains search-to-exact-product-page discovery. The subsequent successful-page loss is the 10,000-character truncation after Gemma extraction.

### Current category evidence and review audit
The correct master category is `3d-printers-equipment` (category ID `ab8b13b0-cc9e-45a6-8c8e-5a0d4f6bb0a1`). It contains 208 master products (201 active/customer-visible) and 277 linked shared-evidence rows: 260 active (239 UK-new, 21 UK-used) and 17 inactive. This is separate from the ChatGPT review queue:
- 65 historical queue rows: 28 imported, 37 rejected, 0 open.
- 28 queue rows link to active shared evidence: 23 `uk_new`, 5 `uk_used`, all GBP-priced.
- 62 queue records contain page captures; current stored `captured_text` and `source_excerpt` maximum is 10,000 characters, and none exceeds that boundary.
- Audit gap: 64/65 queue rows lack `reviewed_by`; 8 imported rows also lack `reviewed_at`; 64/65 queue rows lack top-level `evidence_type`. Linked shared evidence carries its new/used type. Do not infer reviewer identities or rewrite historical decisions.

### Code changes proposed
1. **Full-page retention after successful Gemma extraction.** Add `shouldRetainFullPageCapture(task)` so 3D-printer and existing Gaming paths retain the complete fetched page in both structured `source_excerpt` and `page_capture.captured_text`; other categories retain the existing 10,000-character cap. A 40,642-character regression fixture changes retention from 10,000/40,642 (24.6%) to 40,642/40,642 (100%), recovering 30,642 characters. The LIVE queue's 62 existing captures remain unchanged; this is not retroactive.
2. **Creality model-family routing.** Keep the general FDM collection for Creality printers, but probe `/uk/collections/ender-3-v3-series` only when the requested model contains `ender-3 v3`. K1 Max therefore avoids one unrelated collection probe/404; Ender-3 V3 KE retains the model-family route. This does not claim the collection JSON 404 is fixed.
3. **ELEGOO used-lane eligibility.** LIVE's exact existing ELEGOO UK manufacturer source is GB, enabled, assigned to this category and currently `research_scope='new_uk'`. Production already has the FDM new route and pre-owned used route, but the source scope excludes it from `uk_used` before route selection. Add the ordered update-only migration `20261109140000_enable_elegoo_uk_3d_printer_used_lane.sql`, changing only that exact existing row from `new_uk` to `all`. Its version `20261109140000` is later than LIVE's latest applied migration `20261109115602`; the earlier draft timestamp is not reused. The migration is not applied. TEST has no matching source row according to the existing checkpoint; the update is a no-op where no row matches and copies no data.

### Regression coverage and release gate
Four regression tests cover full-page retention by category, successful mocked Gemma extraction with a 40,642-character page, Creality model-specific collection selection, and ELEGOO new/used lane eligibility with manufacturer/category/route boundaries. No source route is promoted to evidence; collection pages remain discovery only. No evidence is approved or imported automatically.

Current production Gemma extraction restoration PR #320 is already merged. The worker's post-merge runtime remains unverified. The proposed capture/routing/source-scope changes are code and migration review only: do not apply the migration, modify LIVE source rows, queue a research task, approve/import evidence, or deploy without explicit owner approval. After review and approval, install the code preserving the private `.env`; apply the source migration only through the approved release process; then run one bounded 3D-printer check and verify exact page discovery, Gemma calls, full capture retention and new/used review separation.


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


### 2026-11-09 — Anycubic UK direct-route recovery (pending validation)
The 21:19 LIVE five-printer test completed in 2m10s but only Kobra 4 Standard queued a raw capture. The other four tasks had no captures; Kobra 4 extraction timed out after ~45s. A production-based fix branch adds independently verified Anycubic UK product routes for Kobra 3 Max V2 Standard/ACE 2 Pro Combo, Kobra 4 and Kobra S1 ACE 2 Pro Combo. This change is discovery-only; do not assume source pages or prices have been accepted. Verify the exact model/package, selected variant, stock and GBP price on the detail page, then rerun a controlled LIVE task after merge and Research PC update. Do not alter Gaming or other worker configuration.


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


## 10 November 2026 — Anycubic UK route and Gemma extraction correction (replacement PR in review)

LIVE task `owner-3d-printers-equipment-1794272051590` completed its parent task and returned the 3D Printer specialist to idle. It contained five product subtasks, not six: Kobra 3 Max V2 Combo, Kobra 3 Max V2 Standard, Kobra 4 Standard, Kobra 4 ACE 2 Pro Combo and Kobra S1 ACE 2 Pro Combo. Kobra S1 Standard was not included in the task payload. Across the five subtasks, six direct-page captures were retained/staged (three new and three enrichments), but all four Gemma extraction batches timed out. The captures remain `needs_research`; their top-level `observed_price` and `evidence_type` remain null. No evidence was approved or imported.

Independent research against the same approved UK websites identified these discovery-route gaps: 3DJake's generic `/search?query=` route returned no useful exact-model links; its Anycubic brand catalogue is `https://www.3djake.uk/anycubic-3d-printer-and-accessories/anycubic-3d-printer`. 123-3D's generic printer collection missed the manufacturer-specific Anycubic catalogue at `https://www.123-3d.co.uk/collections/anycubic-3d-printers`; the refurbished lane remains `/collections/refurbished-printers`. eBay's generic exact-model route returned HTTP 403; its approved ANYCUBIC FDM store category is `https://www.ebay.co.uk/str/anycubic/FDM-3D-Printers/_i.html?store_cat=39698507014`. The dedicated Anycubic Kobra 4 Combo page is `https://uk.anycubic3d.com/products/kobra-4-combo-3d-printer` and is now added alongside the Standard page.

The previous PR #341 contains the correct 3DJake matcher correction, but its branch had diverged from current production (22 commits ahead and 44 behind) and GitHub reported it as not mergeable. The replacement branch `fix/gemma-research-route-extraction-all-seven-20261110` is based on current production and carries the correction forward with route and extraction changes. Accessory rejection now checks the page title and terminal product slug, not unrelated parent taxonomy segments. Exact model, Standard/Combo and explicit accessory checks remain intact.

The 3D-printer extraction path now uses one direct product page per Ollama inference request and a bounded 90-second timeout (previously two pages per request and 45 seconds). Other categories retain their existing two-page batch and configured timeout behaviour. This is a measured response to LIVE calls taking about 47 seconds for a two-page batch; it is not permission for retries or unbounded model calls. On failure, the complete raw page remains in the ChatGPT review capture. No price is promoted from a search card or an ambiguous multi-variant page.

All seven isolated specialist branches must receive the same shared worker and regression-test files before the Research PC rollout: `gemma/3d-printers`, `gemma/gaming`, `gemma/cameras`, `gemma/drones`, `gemma/metal-detectors`, `gemma/mobile-phones` and `gemma/laptops`. The production **Update all workers** operation is `tools/gemma-agent-isolation/Update-All-Gemma-Agents.ps1`; it preflights all seven branch/config identities, disables new claims, waits for current work to finish without force-killing Node, updates each clone from its own branch, and restarts only workers that were running and updated successfully. Preserve the shared private ENV pointer and never copy, print or replace the private .env. Research PC rollout is not complete until the owner runs this operation and all seven update logs plus LIVE worker telemetry are checked.

TEST remains separate from LIVE. No LIVE source registry, queue, evidence, product catalogue, approval/import state, tenant/customer, Stripe or secret data was changed by this code preparation. The current PR must pass CI and be merged before the all-worker updater is run.


## Verification addendum — 10 November 2026 01:16 UTC

Replacement PR #348 (`fix/gemma-research-route-extraction-all-seven-20261110`) now passes Gemma Research Tests run 42734356593. The same four shared worker/test files (`agent.mjs`, `source-playbooks.mjs`, `source-playbooks.test.mjs`, `agent-speed.test.mjs`) have been synchronised to all seven isolated category branches. Each branch's GitHub Actions Gemma Research Tests run passed: 3D Printers 42734464746; Gaming 42734492721; Cameras 42734504715; Drones 42734526964; Metal Detectors 42734537996; Mobile Phones 42734558108; Laptops 42734571922. The category-specific `agent.config.json` files were not changed. PR #348 remains open pending merge. The Research PC's Update all workers operation has not yet been run; no local worker process was stopped or restarted.


## 10 November 2026 — Retirement of the local research-agent system

The owner authorised retirement of the local category research workers and their owner-dashboard controls. The retirement is being performed in stages. The owner dashboard no longer exposes the worker control centre or shared agent room in the retirement branch. The corresponding JavaScript polling, queueing, source-management and message-feed UI code has been removed from that dashboard branch.

Preservation boundary: do not delete catalogue products, categories, existing product/evidence records, or the historical research review queue. The LIVE database snapshot before retirement contained 35 task rows, 12 status rows, 14,808 activity rows, 451 agent-message rows, 75 catalogue research queue rows and 119 research-source rows. These are historical records and must remain available unless a separately authorised retention policy is agreed. Worker-specific functions and tables must not be dropped until all remaining callers, triggers, grants and RPC dependencies have been audited. Do not change Stripe, tenant data, customer data or published subscriber content.

The PC installation still requires owner-side removal because this environment cannot directly operate the Windows desktop. The identified local roots are C:\\CTFGemma2, C:\\TFGemma and %LOCALAPPDATA%\\TradeFlow\\ResearchControlCentre. Before removal, disable the scheduled tasks and startup shortcut, preserve an encrypted/local backup including private environment pointers, remove desktop shortcuts and the model, and verify no worker processes remain.

The production branch has not yet been merged or deployed. The retirement branch is subject to syntax, dashboard regression and database dependency checks before production promotion. Keep this retirement record and historical checkpoints; removing the runtime does not mean erasing the audit trail.


## Retirement progress — 10 November 2026, 17:35 UTC

PR #352 was merged to production as commit 78a62072e53f6ec121f218f2f16dbf8900df24ec. Its `gemma-research-tests` check completed successfully. A read-back of production `platform-owner-dashboard.html` and `platform-owner-dashboard.js` confirmed zero remaining occurrences of the retired system names, navigation IDs, common-room IDs or worker RPC namespace in those two dashboard files. This confirms source merge, not yet independent browser/CDN deployment verification.

A LIVE Supabase migration named `retire_research_agent_runtime_permissions_20261110` revoked EXECUTE from public, anon, authenticated and service_role for the worker claim/heartbeat/complete/fail/report functions and owner dashboard task enqueue, agent telemetry, agent message, category/product and research-source management RPCs. Read-back confirmed service_role and authenticated cannot execute the checked worker/task RPCs. No tables, rows, catalogue products, evidence, queue entries or source rows were deleted. Counts remain 35 tasks, 12 status rows, 14,808 activity rows, 451 messages, 75 research queue rows and 119 research sources.

Remaining work: remove/retire the local Windows installation, archive and remove specialist GitHub branches and runtime source, verify public website deployment in browser/CDN, and complete a final Supabase caller/dependency audit before considering any further backend object removal. Do not delete historical records.


## Runtime source retirement — 10 November 2026

After the owner-dashboard retirement merge and the LIVE RPC execution revocation, the production branch's dedicated local runtime assets were removed: `.github/workflows/gemma-research-tests.yml`, `tools/gemma-agent-isolation/`, `tools/tradeflow-gemma-agent/` and `tools/tradeflow-gemma-desktop/`. The seven specialist branch heads were preserved first as archive branches: `archive-gemma-3d-printers-20261110`, `archive-gemma-gaming-20261110`, `archive-gemma-cameras-20261110`, `archive-gemma-drones-20261110`, `archive-gemma-metal-detectors-20261110`, `archive-gemma-mobile-phones-20261110`, and `archive-gemma-laptops-20261110`. The original seven specialist branch refs still need deletion; the available GitHub connection does not expose a branch-delete action. Do not delete the archive branches or the production recovery branch.


## 10 November 2026 — Final retirement status: local category research-worker platform

The owner has retired the local category research-worker platform and its new-evidence lab-search/control-centre workflow. This is a completed retirement boundary, not a pause or an instruction to reinstall it.

### Current system state
- The TradeFlow LIVE owner dashboard no longer contains the AI research control-centre or shared agent-room navigation, HTML sections, polling, task-enqueue, source-management, review-queue or messaging UI. The remaining retired CSS selectors have also been removed from `platform-owner-dashboard.css`.
- The local worker source and updater files have been removed from the GitHub `main` branch. The production branch contains no worker runtime directory.
- LIVE execution permission for the worker and owner research RPC family has been revoked, including service-role execution. The migration source is recorded as `supabase/migrations/20261110173027_retire_research_agent_runtime_permissions_20261110.sql`.
- On the Research PC, the owner ran the no-backup removal script. The confirmed local roots, scheduled tasks and worker shortcuts were removed. Ollama itself remains installed; model removal was attempted and the Chrome web-app registration remains a separate local verification item.

### Preservation boundary — mandatory
Do not delete or alter catalogue products, product categories, manufacturer/model/package metadata, existing market evidence, customer/subscriber data, Stripe configuration, published subscriber websites, or historical research/audit rows as part of this retirement. Do not clear the historical research queue, source registry, activity log or message history. These records are retained as historical data and are not an active worker service.

LIVE read-only verification at retirement: master products 47,410; master categories 38; shared market evidence 4,542; tenant catalogue selections 23,993; historical worker tasks 35; status rows 12; activity rows 14,808; agent messages 451; catalogue research queue 75; research source registry 119. The worker RPC execution check returned false for service_role, authenticated and anon across the retired RPC family.

### Git and deployment boundaries
The production owner-dashboard HTML and JavaScript were checked for retired control-centre/common-room references and returned zero matches. The production stylesheet cleanup is committed. Worker runtime files are removed from the default `main` branch. Historical SQL migration files are retained because they are part of the applied database migration history; the retirement migration revokes runtime access without dropping tables or historical records. Existing historical checkpoints and migration records remain audit history, not executable worker installations.

No new research findings are to be auto-approved or imported. Any future market-research output presented for catalogue use must first be independently reviewed by the owner/ChatGPT, with exact product/package matching and source evidence. This retired worker platform must not be restarted or rebuilt as part of ordinary catalogue maintenance.


## 10 November 2026 — Gemma retirement reconciliation and preservation boundary

The retired component is the local category research-worker platform, its desktop supervisor/control-centre, its shared agent-room runtime and the associated new-evidence lab workflow. It is not the core TradeFlow Cloudflare request router, the subscriber's manual research form, or the separate TradeFlow Assistant.

### LIVE backend verification
- TradeFlow LIVE project: `gxsrajtqzdjvmceqcpgv`, status ACTIVE_HEALTHY.
- Migration `20261110173027_retire_research_agent_runtime_permissions_20261110` is present in LIVE migration history.
- All 12 rows in `platform_ai_agent_status` are `idle`.
- `platform_ai_agent_tasks`: 34 completed, 1 failed; no queued or running task rows in the current snapshot.
- No EXECUTE grants were returned for the retired `platform_ai_agent_*` / `platform_owner_*research*` RPC family to PUBLIC, anon, authenticated or service_role.
- No dedicated Gemma/research-worker Edge Function appears in the current LIVE Edge Function inventory. The separate `tradeflow-assistant` function remains; it is not the retired research worker.

### Protected LIVE data — unchanged
- Master catalogue products: 47,410.
- Master categories: 38.
- Shared market evidence: 4,542.
- Tenant catalogue selections: 23,993.
- Historical research tasks: 35.
- Historical agent status rows: 12.
- Historical agent activity: 14,808.
- Historical agent messages: 451.
- Historical catalogue research queue: 75.
- Approved research-source registry rows: 119.

No product, category, manufacturer/model/package record, evidence row, tenant selection, research history, customer/subscriber record, Stripe configuration, published website or transaction record was deleted or modified by this retirement reconciliation.

### Code and website boundaries
- `worker/index.js` and `wrangler.jsonc` are the core TradeFlow Cloudflare application router/environment configuration. The worker handles clean routes, subscriber login, runtime config and static asset delivery. They are not Gemma worker code and must remain.
- `buying-research.html` / `.js` are the separate tenant-scoped manual Research Centre. They write `tenant_buying_research`; they are not the global Gemma research worker or shared-evidence ingestion workflow and remain unchanged.
- The public catalogue browser remains available. Its public page copy and navigation have been changed from “Catalogue & AI Research” to “Product Catalogue”, and AI-assisted research promotion has been removed. Product browsing and source-evidence explanation remain.
- The production branch's five retired Gemma/deep-source diagnostic and architecture roadmaps have been deleted. Historical checkpoints and project-memory records are retained as audit history.
- Applied historical SQL migration files are retained to preserve the reproducible database migration chain. The retirement migration revokes the retired RPC execution surface without dropping tables or historical records.
- The separate TradeFlow Assistant/provider configuration is not the local research-worker platform and has not been removed.

### GitHub branch and deployment limitations
The seven specialist branches and seven dated archive branch heads were previously cleaned of worker runtime directories and the dedicated Gemma test workflow. Other older Gemma feature/fix/checkpoint branch refs and historical commits remain visible. The connected GitHub operations do not expose branch-ref deletion or Git-history purging, so no claim is made that those refs or historical commits have been erased. They are not the production website runtime.

The production catalogue page and stylesheet changes are committed to GitHub. Cloudflare-served browser verification remains pending; a production-branch commit alone is not proof that the public website has refreshed.

### Next verification
1. Verify the production catalogue page is served with “Product Catalogue” navigation and no AI-research promotion.
2. Confirm the public catalogue browser and clean TradeFlow routes still load.
3. Do not remove `worker/index.js`, `wrangler.jsonc`, the manual tenant Research Centre, historical migration files or protected catalogue/evidence data as part of this retirement.
4. Do not restart, reinstall or rebuild the retired Gemma worker platform.


### Separate TradeFlow Assistant provider state
LIVE `platform_ai_settings` was read independently: `active_provider='none'`, `allowed_providers=['none']`, `gemma_enabled=false`, and `subscriber_provider_enabled=false`. The TradeFlow Assistant remains present but no AI provider, including Gemma, is enabled for it. This is separate from the retired local research-worker platform.


### Open Gemma pull requests retired — 10 November 2026
A read-only search of open pull requests found 20 Gemma/research-worker implementation or documentation PRs. All 20 were closed unmerged: #353, #345, #343, #335, #336, #331, #315, #300, #301, #299, #296, #294, #297, #290, #289, #288, #264, #262, #258 and #250. A follow-up search returned no remaining open PRs matching “Gemma”. Unrelated catalogue-data, subscriber shared-evidence, Cloudflare Worker routing, BusinessFlow and other TradeFlow PRs were left open.


## 10 November 2026 — LM Studio Bionic Research Inbox connector

A new isolated research handoff has been added for the owner's existing LM Studio Bionic desktop application. This is not a revival of Gemma, the retired local worker supervisor, or the former Common Room.

### LIVE Supabase objects
- New table: `public.platform_research_reports`.
- New private Storage bucket: `tradeflow-research-inbox` (20 MiB object limit; Markdown, plain text and JSON only).
- Table has RLS enabled and no grants to `anon` or `authenticated`; only `service_role` receives table privileges.
- The table was empty at creation; no historical research, product, category, shared evidence, tenant or transaction rows were changed.
- Reports carry a title, original prompt, category, source app/model, Markdown report, structured JSON, finding/source counts, file paths and review status. Initial status is `submitted_for_review`.

### MCP Edge Function
- Function: `tradeflow-research-mcp`, deployed ACTIVE to LIVE.
- Source: `supabase/functions/tradeflow-research-mcp/index.ts`.
- Endpoint: `https://gxsrajtqzdjvmceqcpgv.supabase.co/functions/v1/tradeflow-research-mcp`.
- Gateway JWT verification is disabled because the function enforces its own bearer token check using the server-side secret `TRADEFLOW_RESEARCH_MCP_TOKEN`. The function returns 503 until this secret is set; missing/incorrect bearer token is rejected.
- Supabase's injected `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are used only inside the Edge Function; neither is sent to LM Studio or placed in browser code.
- Exposed tools: `search_catalogue` (read-only active master products), `get_existing_evidence` (read-only active evidence for one master product), `submit_research_report` (stores Markdown + JSON in private Storage and a report row).
- There is no MCP tool to create/update/delete products, approve evidence, or insert into `shared_market_evidence`.

### Connection still pending
- Set the production Edge Function secret `TRADEFLOW_RESEARCH_MCP_TOKEN` in Supabase Dashboard > Edge Function Secrets. Use a high-entropy token and do not put it in GitHub, chat, or any public frontend.
- Then add a remote MCP entry in LM Studio's `mcp.json` using the endpoint above and an `Authorization: Bearer <token>` header.
- LM Studio officially supports remote MCP entries in Cursor-style `mcpServers` configuration. Enable only this TradeFlow connector for the research model/chat.
- End-to-end tests (catalogue search, evidence lookup, report submission, private file readback) are pending until the secret is configured.

### Release and data boundaries
- This connector is LIVE-only for the first acceptance pass. Do not sync TEST data or TEST reports into LIVE.
- All submitted research remains `submitted_for_review`; ChatGPT/owner independently verifies source URLs, prices, package identity, condition and availability before any separate approved import process.
- Historical Gemma tables, RPCs and Common Room are not re-enabled. Do not restore their permissions or UI.


## Cloud AI Research Manager — build record (10 November 2026)

A new isolated implementation branch, `feature/cloud-ai-research-manager-20261110`, has been created from `production`. The target is the Platform Owner Dashboard, not a separate Windows application. The manager is intended to use interchangeable cloud AI provider adapters, strict free-tier eligibility, provider cooldown/rotation and resumable jobs. Research submissions must retain product identity, UK GBP price, condition, source name, direct source URL, observed timestamp and provenance. Submissions are staged in the existing `platform_catalogue_research_queue` / `platform_research_reports` review workflow; no AI provider may directly approve or import evidence. The retired Gemma runtime must remain disabled. Provider credentials must never be stored in browser storage or plaintext public tables; the secret-storage mechanism must be verified before implementation. LIVE catalogue, evidence, Stripe and settings remain unchanged until TEST acceptance and an explicit release gate. See `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-CLOUD-AI-RESEARCH-MANAGER.md` and `CHECKPOINTS/2026-11-10-cloud-ai-research-manager-build-start.md`.


## Cloud AI Research Manager implementation update (10 November 2026)

The isolated feature branch now contains the initial Owner Dashboard panel and TEST database foundation. Provider records are stored in `platform_cloud_ai_providers`; queued work is stored in `platform_cloud_ai_research_jobs`. Owner-only RPCs enforce active `platform_memberships`. Provider credentials are stored through Supabase Vault and are never returned to the browser. A service-role-only lookup is used by the protected Edge Function. The TEST Edge Function `tradeflow-cloud-ai-manager` is ACTIVE with JWT verification enabled and currently supports provider model-list connection checks only. The owner dashboard UI supports provider configuration, explicit free-tier confirmation, OpenRouter `:free` enforcement, connection tests, manual research-job enqueue and queue display. The research runner, source-page fetch, AI inference, scheduling and review/import workflow are not yet implemented. No provider key has been entered and no catalogue/evidence rows have been changed. Do not deploy these files or migrations to LIVE until TEST acceptance is complete.


## Research runner update (10 November 2026)
The TEST branch now includes a manually invoked cloud research runner. It leases queued jobs, fetches up to three category-matched UK source pages from the approved registry, calls an eligible free-confirmed AI adapter, validates structured findings and stages candidates in `platform_catalogue_research_queue`. It never writes directly to `shared_market_evidence`. Provider adapters currently cover Gemini, Groq, OpenRouter, Cerebras, SambaNova, NVIDIA NIM, Mistral, Hugging Face Router and GitHub Models. A conservative configurable daily request cap and UTC reset are implemented. Many registered sources still lack product-specific search templates; coverage is therefore limited until source search is improved. The dashboard exposes manual run and evidence review controls. Approval only marks a candidate approved; it does not import it. No provider keys have been entered and no inference has run. See the cloud AI manager roadmap.
