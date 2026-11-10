# TradeFlow Cloud AI Research Manager — Developer Diagnostic Roadmap

Updated: 10 November 2026
Status: Cloud AI Manager source is merged to production; LIVE backend and scheduler are deployed. Public Worker asset deployment is pending retry after correcting Wrangler config detection. Do not use TEST as the target.

## Purpose
Provide a Platform Owner Dashboard control centre that can use multiple independently configured cloud AI providers to research UK catalogue products and submit structured findings. Providers are interchangeable adapters, not hard-coded workers. The system must pause/resume on free-tier limits and must never silently incur paid usage.

## Existing verified foundations
- Owner dashboard: `platform-owner-dashboard.html`, `platform-owner-dashboard.js`, `platform-owner-dashboard.css`.
- Owner access: `tradeflow_platform_owner_session`, Supabase Auth, active `platform_memberships`; owner RPCs must independently enforce membership.
- LIVE catalogue: `catalogue_master_products`; evidence: `shared_market_evidence`.
- Existing candidate/review queue: `platform_catalogue_research_queue` with product_candidate, release_candidate and evidence_candidate records and explicit review statuses.
- Approved research-source registry: `platform_research_sources` (54 rows in LIVE at inspection).
- Structured report inbox: `platform_research_reports`, with private `tradeflow-research-inbox` Storage bucket; submissions are staged for review and do not write catalogue/evidence rows.
- Retired runtime: `platform_ai_agent_tasks`, local Gemma worker and related runtime permissions were retired. Do not re-enable or reuse them.
- Existing `tradeflow-research-mcp` LIVE deployment is report-oriented and has a deployed/GitHub source divergence. Do not redeploy it until reconciled.

## Intended flow
1. Owner configures providers and confirms the provider's API plan is free-only.
2. A scheduler/dispatcher creates bounded research jobs from active catalogue products and approved source assignments.
3. Provider adapters claim jobs with leases, apply per-provider rate limits/cooldowns and rotate only to eligible free providers.
4. Research returns a strict JSON report with product identity, UK GBP price, condition/evidence type, source name, canonical direct URL, observed timestamp, availability and quoted page excerpt.
5. Validate schema, URL/domain, UK/GBP scope, product identity and source policy before accepting a submission.
6. Persist immutable raw report plus normalized candidates in the existing review queue/report inbox. Deduplicate by stable keys.
7. ChatGPT/owner reviews, corrects and approves candidates. Only a separate approved import action may insert into `shared_market_evidence` or create products.
8. Persist job state, provider cooldowns, retry counters and audit history so work resumes after rate limits or service interruption.

## Security and billing invariants
- Provider credentials must never be written to browser storage, public tables, logs, report payloads or Git.
- No service-role key or research bearer token in browser code.
- Provider configuration stores provider/model, free-plan verification, enabled flag and non-secret status only.
- Secret storage mechanism must be selected only after verifying the deployed Supabase Vault/secret capabilities or an existing server-side secret manager. Do not store plaintext keys in ordinary Postgres tables.
- Only explicitly free/free-tier-confirmed models may be scheduled. Trial credits, promotional balance and unknown billing status are not considered free.
- HTTP 402, quota exhaustion, rate limit, billing warning or uncertain provider response pauses that provider; no paid fallback.
- No automatic evidence approval/import. Preserve source URL, observation time and raw response provenance.

## LIVE/TEST boundaries
- LIVE project: `gxsrajtqzdjvmceqcpgv`.
- TEST project: `nnsshnfkjcflucjrftzi`.
- Build and schema tests must use TEST first. Do not copy TEST queue, provider settings, tenant data or research findings into LIVE.
- LIVE catalogue/evidence and billing remain untouched until a reviewed deployment gate.

## Next implementation steps
1. Inspect the current TEST and LIVE dashboard deployment/source parity, owner RPCs, RLS, source registry and evidence schema.
2. Design provider credential storage and owner-only RPC/Edge Function boundary; fail closed if no safe secret store is available.
3. Implement provider adapter registry and free-tier eligibility/quota/cooldown state.
4. Implement job queue and scheduler using an already-supported cloud runtime; do not revive local Gemma.
5. Add Owner Dashboard panels: provider connections, free-tier status, research schedule/queue, report inbox and review/import controls.
6. Implement structured report submission to the existing inbox/queue.
7. Test with synthetic submissions and one manually triggered low-risk research job in TEST.
8. Verify no direct evidence writes before approval; add deployment and rollback checkpoint before LIVE release.

## Known failure points / constraints
- Current owner dashboard production HTML does not expose the former Gemma control centre, despite the existing database RPCs and prior roadmap. Reconcile deployed page source and branch history before adding UI.
- The existing report inbox accepts full reports, not a generic multi-provider job queue.
- The existing LIVE research MCP has five deployed tools while the GitHub production copy has only three registrations. Do not redeploy until this drift is resolved.
- No provider quota guarantees should be inferred from marketing pages; free tier and API access must be verified per provider/model and may change.
- No evidence schema or import RPC is to be guessed. Inspect exact LIVE/TEST table definitions and import functions before implementing approval/import.

## Verification checklist
- Active platform owner can access the manager; non-owner is denied.
- Provider keys are never returned to the browser after save.
- Free-only gate rejects paid/unknown models and blocks paid fallback.
- Provider exhaustion moves provider to cooldown and work remains queued.
- Duplicate research reports do not create duplicate evidence candidates.
- Invalid source, non-UK currency, wrong model and unsupported condition are rejected or flagged.
- Report submission creates inbox records only.
- Explicit approval/import is the only path that changes catalogue/evidence.
- LIVE and TEST stay separate; retired Gemma settings remain disabled.


## Implementation progress — 10 November 2026
- Created the dashboard section in `platform-owner-dashboard.html` and owner-side controls in `platform-owner-dashboard.js`: provider configuration, provider connection test, research-job enqueue and queue list.
- Added TEST migrations for `platform_cloud_ai_providers` and `platform_cloud_ai_research_jobs`, plus owner-only RPCs to save/list providers and enqueue/list jobs.
- Provider API keys are written through a security-definer owner RPC into Supabase Vault. The dashboard receives only a has-key boolean and never reads the secret back.
- Added a service-role-only secret lookup RPC and deployed `tradeflow-cloud-ai-manager` Edge Function to TEST (ACTIVE, verify_jwt=true, version 2). It verifies the owner JWT and active platform membership, then checks provider model-list endpoints. Gemini key is sent in an HTTP header, not the URL.
- Enforced that enabled OpenRouter models must end in `:free`. Provider activation also requires explicit free-tier confirmation. HTTP 402/403/429 during provider test pauses that provider for one hour; no paid model fallback exists.
- TEST schema inspection confirms both new tables and four owner RPCs exist; queue currently has zero jobs. No provider credentials have been entered and no provider inference/research has been run.

## Remaining implementation gates
1. Complete authenticated owner UI smoke test: list provider rows, save one key to Vault, confirm no secret is returned, run connection test and verify provider state.
2. Implement a bounded research runner: lease queued job, fetch allowed UK source pages, call an eligible free model, validate structured findings, submit to review queue/report inbox, persist cooldown and resume state.
3. Add approved-source selection, scheduled cadence, retry/backoff and evidence review/import workflow. Do not write directly to shared evidence.
4. Deploy owner dashboard files and migrations to TEST hosting only after source-level checks; test all owner-only flows.
5. Keep LIVE untouched until acceptance and explicit release decision.

## Research runner implementation — LIVE
- Added service-role-only lease/claim, finish and provider-pause RPCs. Jobs have a five-minute lease; expired running jobs return to the queue.
- Expanded adapter registry to Gemini, Groq, OpenRouter, Cerebras, SambaNova, NVIDIA NIM, Mistral, Hugging Face Router and GitHub Models. The provider endpoints are fixed server-side by provider key; no user-supplied arbitrary API base URL is accepted.
- Provider API keys remain in Vault. The Edge Function now supports a manually invoked `process_next_job` action, checks only enabled providers with explicit free-tier confirmation and remaining daily request cap, and rotates to the next eligible provider after provider failures. 402/403/429 responses trigger cooldown; no paid fallback exists.
- Each job fetches up to three HTTPS pages from enabled, category-matched, GB research sources. Redirects are not followed; source hostname must match the approved registry domain. HTML is reduced to text before model submission.
- Model output is constrained to JSON. Candidate findings must cite one of the exact fetched URLs, have positive GBP price, supported evidence type, exact/likely product match and an excerpt present in fetched page text. Accepted candidates are inserted into existing `platform_catalogue_research_queue` as `evidence_candidate` / `pending_review`, with raw provider/model provenance. They are not inserted into `shared_market_evidence`.
- Owner Dashboard now has a manual “Run next job” control and a pending evidence list with approve / needs-research / reject decisions using the existing owner RPC.
- Enabled providers require a daily request cap (default 20, configurable) with UTC daily reset. This is an application-level ceiling, not a guarantee of provider-side billing; owner must still confirm that API billing is disabled or free tier is in effect.
- TEST Edge Function `tradeflow-cloud-ai-manager` is ACTIVE, JWT verification enabled, version 4. No API keys have been entered and no inference request has been sent.
- Source retrieval limitation: many existing source records only have a homepage URL and no product-search template. Those pages may not contain the target product; in that case the job will yield no price candidates. Do not claim comprehensive web search until a proper search adapter or verified per-source search URL templates are added.
- Evidence “approve” only marks a queue candidate approved; it does not import it. The exact product/evidence import process must be inspected and implemented separately before automated database insertion.


## Scheduler and recovery implementation (10 November 2026)
- TEST has an active pg_cron job `tradeflow-cloud-ai-runner` scheduled every 10 minutes. It invokes the TEST Edge Function and processes at most one queued job per tick.
- Scheduler authentication uses a random credential generated inside Supabase Vault. The Edge Function deployment has JWT gateway verification disabled only because it accepts both owner JWT requests and a separate Vault-verified scheduler token; requests without either credential are rejected. The token is never exposed to the dashboard.
- A direct scheduler-path smoke test returned HTTP 200 in Supabase function logs (deployment version 7). No provider credentials or research jobs exist, so no AI inference was performed.
- Claim/recovery logic now reclaims expired leases, restores providers after cooldown expiry, resets daily counters on UTC date change and requeues paused work when an eligible free provider has quota again.
- This scheduled runner is active in LIVE. No cron job or Edge Function was created in LIVE.


## Deployment correction — 10 November 2026
The owner has clarified that this Cloud AI Research Manager is to be built directly into TradeFlow LIVE. The LIVE project is `gxsrajtqzdjvmceqcpgv`. Its provider/job tables, secure Vault lookup, service-role-only secret access, job lease/cooldown/quota RPCs and provider adapters have now been applied to LIVE. The LIVE Edge Function `tradeflow-cloud-ai-manager` is deployed as version 1 with gateway JWT verification disabled solely to support the Vault-verified scheduler credential; owner actions still require a valid owner JWT and active platform membership. The Owner Dashboard source remains to be merged into `production` and deployed by the production website pipeline. The LIVE scheduler migration is staged and will be enabled after the dashboard production rollout. TEST is not the target environment for this feature.


## LIVE rollout status — 10 November 2026 (20:54 UTC)
- The Cloud AI Research Manager source was merged into `production` via PR #354 (merge commit `c2e642b5986185a8cbcfee67e4f6f82e3e76c237`). The production Owner Dashboard HTML/JS now includes the manager, nine provider forms, queue, manual runner and review inbox.
- LIVE Supabase project `gxsrajtqzdjvmceqcpgv` now has the provider and job tables, Vault-backed secret access, service-role-only secret RPC, job lease/finish/cooldown functions, provider adapter configuration and daily quota reset. Current LIVE provider rows: 0; research jobs: 0; staged AI candidates: 0. No provider credentials have been supplied and no AI inference has been run.
- LIVE Edge Function `tradeflow-cloud-ai-manager` is ACTIVE, version 1, with owner JWT and active-membership checks for dashboard calls plus Vault-verified scheduler authentication. LIVE pg_cron job `tradeflow-cloud-ai-runner` is active every 10 minutes. A direct scheduled invocation returned HTTP 200 in the LIVE function logs.
- The production Worker uses `wrangler.jsonc` with static assets served through the Cloudflare Worker. A GitHub Actions deployment workflow was added, but no successful Cloudflare Worker deployment has yet been verified from this session. Therefore the code is merged to production and the LIVE backend is deployed, but availability of the new panel at the public Owner Dashboard URL still needs a deployment/asset verification. Do not claim the panel is live until confirmed.
- No existing catalogue, approved evidence, tenant, subscriber, Stripe or other LIVE business records were modified. The research queue is empty. Research only runs once the owner connects and explicitly enables a provider with a free-tier confirmation and daily cap.


## Deployment verification update — 10 November 2026 (21:05 UTC)
- Rechecked the production branch and LIVE Supabase project only. wrangler.jsonc defines Worker entry point ./worker/index.js and static assets directory . .assetsignore excludes source-only folders while leaving the owner dashboard HTML/JS/CSS available as static assets.
- The first GitHub Actions deployment attempt (run 42899742226, commit db81d031cbc2a2e4f8693202938f400a88f1ecf3) failed because the workflow installed Wrangler 3.90.0 and invoked wrangler deploy without an explicit JSONC config; Wrangler reported “Missing entry-point”. This was a configuration-discovery failure, not evidence of bad Cloudflare credentials.
- Corrected .github/workflows/deploy-tradeflow-production.yml in production (commit 6c7692576244af86b044cf89dbd37402b6ffcc57) to pin Wrangler 4.160.0 and run deploy --config wrangler.jsonc. A new deployment run (42901328618) was queued at 21:03 UTC; completion and Worker asset visibility have not yet been verified. Do not claim the panel is publicly deployed until the run succeeds and the live page is checked.
- LIVE project gxsrajtqzdjvmceqcpgv remains ACTIVE_HEALTHY. Confirmed current counts: 0 provider rows, 0 cloud AI jobs, 0 staged cloud AI candidates. LIVE pg_cron job tradeflow-cloud-ai-runner is active on */10 * * * *. No provider keys have been entered and no AI inference has run.
- No TEST project was used or modified during this verification. No catalogue, approved evidence, subscriber, tenant, domain or Stripe data was changed.


## Follow-up deployment attempt — 10 November 2026 (21:04 UTC)
The corrected Wrangler 4.160.0 command successfully loaded wrangler.jsonc and built the static asset manifest, but the second deployment run (42901328618) stopped before upload because Wrangler had installed a transient node_modules/workerd binary (152 MiB) inside the configured root asset directory. This exceeded Cloudflare's 25 MiB per-asset limit. The production .assetsignore has now been amended to exclude node_modules/ and **/node_modules/** (commit 564af6d005a6640088b2f77cf754cd504004e3f7). A third deployment run (42901458206) was queued at 21:04 UTC. Its result and public asset visibility remain to be checked.


## LIVE Worker deployment succeeded — 10 November 2026 (21:05 UTC)
- Final production deployment workflow run 42901559233 completed successfully from production commit d6f7dde43a31b539037729c30595f98073ea136a. Wrangler 4.160.0 loaded wrangler.jsonc, built the root static asset manifest, and deployed Worker tradeflow.
- Cloudflare reported Worker version ID c1bccf0f-d55c-43f4-ae60-0e6843562870 and workers.dev URL https://tradeflow.leannelaurenlowe.workers.dev. The deployment log confirms successful upload/deployment. The final .assetsignore excludes node_modules/, .git/, package.json and package-lock.json, preventing transient Wrangler tooling and repository metadata from being part of the static asset manifest.
- The public owner domain owner.laurendigital.co.uk could not be fetched from this execution environment, so custom-domain routing and a browser-level check that the signed-in owner dashboard displays the Cloud AI Research Manager remain unverified. The production Worker deployment itself is successful; do not conflate this with proof of the owner-domain route.
- LIVE backend remains active; 0 provider rows, 0 jobs, 0 AI candidates. No keys or inference. No TEST project used or modified. No catalogue, evidence, subscriber, tenant, domain or Stripe records changed.


## LIVE provider diagnostic and batch research update — 10 November 2026
- Re-queried LIVE `platform_cloud_ai_providers`: Groq row exists with `enabled=true`, model `llama-3.3-70b-versatile`, daily cap 5, free-tier confirmation true, a non-null Vault `secret_id`, and status `ready`. No key value was retrieved or exposed.
- Re-deployed `tradeflow-cloud-ai-manager` to LIVE as version 2. Provider lookup errors are now distinguished from a genuinely missing provider row, returning a safe diagnostic message and database error code where applicable instead of the generic “Provider is not configured”. This is diagnostic hardening; it does not rotate or expose the key.
- Owner Dashboard research enqueue now accepts up to 100 products per submission, one per line in `Manufacturer | Model | Package (optional)` format, with shared category and research type. Each product is enqueued through the existing owner-protected RPC; failures are reported per product. Jobs remain separate queue records and are processed individually by the existing scheduler. No catalogue/evidence import occurs at enqueue time.
- Owner dashboard JS cache version bumped from v35 to v36. Public Worker deployment must be triggered/verified after these production commits before expecting the browser to load the new batch form.
- No TEST changes. No API key re-entry, provider key rotation, paid provider use, catalogue mutation, evidence approval/import, tenant or Stripe changes.


## Master catalogue picker added — 10 November 2026
- LIVE-only owner RPC `platform_owner_search_cloud_ai_catalogue(p_search,p_category_slug,p_limit)` was added by migration `cloud_ai_owner_catalogue_picker`. It checks active `platform_memberships` through `platform_cloud_ai_owner_check`, searches active master products by manufacturer/model/package, optionally filters category slug, and caps results at 100. Execute is granted only to authenticated; anon/public are revoked.
- Cloud AI queue form now includes a master-catalogue search and multi-select. Selected catalogue products populate the batch input as Manufacturer | Model | Package. Existing batch enqueue continues to create separate owner-authorized research jobs; no catalogue/evidence records are changed.
- Dashboard JS cache query bumped to v37. Production Worker auto-deploy should run from the production commits; verify the Actions run and browser behaviour before claiming the picker is live.
- The search is a selector over `catalogue_master_products`; it does not yet store the master product UUID on the research job. Job identity is retained by manufacturer/model/package. A future schema enhancement can add the explicit master_product_id link if needed.


## LIVE permission and multi-term search repair — 10 November 2026
- Diagnosed Groq test failure precisely: `service_role` had no table privileges on `platform_cloud_ai_providers` or `platform_cloud_ai_research_jobs`, despite Edge Function using the service-role client. Applied LIVE migration `cloud_ai_service_role_table_grants`: service_role now has SELECT/INSERT/UPDATE on those two tables, SELECT on `platform_research_sources`, plus sequence usage/select. No anon/authenticated table grants added. Verified `has_table_privilege` returns true for provider SELECT/UPDATE and jobs SELECT/UPDATE. Groq record remains enabled and its Vault secret_id remains present; no key was read or changed.
- Master catalogue picker now supports multiple search terms at once: paste one or more model/manufacturer searches on separate lines; up to 50 terms per search action. Results are deduplicated by master product UUID and can be multi-selected. This is distinct from the subsequent batch queue, which accepts up to 100 selected products.
- LIVE dashboard HTML/JS updated and cache bumped to v38. Cloudflare deployment workflow run 42908635942 from production commit 831531946e0cec300b39be02edb14cd7c94b90b4 is currently running; do not claim the latest multi-term picker is live until it succeeds. Provider grants are already applied LIVE.


## LIVE catalogue picker and Groq model correction — 10 November 2026
- Root cause of the multi-product picker failure was twofold. In `platform-owner-dashboard.js`, three line parsers used double-escaped CR/LF patterns, so multiline input was treated as one term; the selected-product join also inserted a literal backslash-n instead of a newline. Corrected all three split sites to `/\r?\n/` and the join to `'\n'`. The research queue parser now correctly reads one product per line as well.
- The LIVE catalogue RPC `platform_owner_search_cloud_ai_catalogue` also searched manufacturer, model and package fields separately. Full terms such as `Bambu Lab P1S` could not match either individual field even when the product existed. Updated the owner-protected function to additionally search the combined manufacturer + model + package text. The change was applied to LIVE and recorded in `supabase/migrations/20261111000100_fix_cloud_ai_catalogue_combined_product_search.sql`.
- LIVE RPC verification passed for category slug `3d-printers-equipment`: `Bambu Lab P1S` returned 3 packages, `Creality K1 Max` returned 1, and `Anycubic Kobra 3` returned 2. The active 3D category contains 201 products (27 Bambu Lab, 35 Creality, 24 Anycubic). The category hint in the dashboard now uses the real slug `3d-printers-equipment`.
- Dashboard JS fixes were committed to `production`; asset cache version is now v41. GitHub Actions production Worker deployment was triggered by the latest dashboard HTML commit; verify the newest workflow run and public asset before declaring the UI rollout complete. No browser-side signed-in owner smoke test has been performed in this session.
- Groq LIVE record was found enabled with model `llama-3.3-70b-versatile`, Vault secret present, daily cap 5, zero requests used. Service-role table privileges are now confirmed. Groq's official deprecation page says this model was decommissioned for Free/Developer tier on 2026-08-16. The API model-list test therefore reports 11 models checked but does not list the configured model. The LIVE row was marked `error` (not deleted or disabled) so the scheduler will not use a retired model. No key was read, rotated or changed, and no inference request was sent.
- The Edge Function `tradeflow-cloud-ai-manager` is ACTIVE at version 3. Its model test now marks a configured model unavailable when it is absent from the active model list instead of incorrectly leaving its status as `ready`. Dashboard status wording now distinguishes API reachability from model availability.
- Do not automatically replace Groq's model: official current alternatives include `openai/gpt-oss-120b` and `qwen/qwen3.8-27b`, but Groq publishes token prices for these models. The user's free/no-paid-billing requirement means a replacement must be confirmed as usable without paid billing on this account before enabling it. No paid fallback is permitted.
- LIVE catalogue count: 47,410 total master products / 28,394 active. LIVE cloud AI research jobs remain empty; no product catalogue, shared evidence, tenant, subscriber, Stripe, TEST or other business data was modified. TEST remains untouched.


## LIVE research picker rebuilt around the master catalogue hierarchy — 11 November 2026
- Supersedes the earlier free-text/multi-term search picker. The required interaction is now category dropdown → branch dropdown → individual product/model dropdown, with explicit **Add selected product** and **Add entire branch** actions. Product names are never typed by the user.
- LIVE schema source is `catalogue_master_categories` → `catalogue_master_branches` → `catalogue_master_products`, joined by category_id and branch_id. The 3D Printers & Equipment category has the branches 3D Printers (183 active products) and 3D Printer Equipment & Accessories (18 active products).
- Added owner-protected RPC `platform_owner_get_cloud_ai_catalogue_tree(p_category_id,p_branch_id)`, returning active categories, branches and products in the selected branch. Verified the LIVE RPC returns 38 categories and 183 products for the 3D Printers branch.
- Added owner-protected bulk RPC `platform_owner_enqueue_cloud_ai_catalogue_selection(p_product_ids,p_branch_id,p_task_type)`. It creates research jobs directly from selected master product UUIDs, supports branch-wide selection, and stores master_product_id and branch_slug on each job. It does not alter catalogue products or market evidence. A no-op validation with an unknown UUID returned selected=0 / queued_or_existing=0; no research jobs were created during validation.
- Added nullable `master_product_id` FK and `branch_slug` to `platform_cloud_ai_research_jobs`. Source migration: `supabase/migrations/20261111000200_cloud_ai_catalogue_hierarchical_dropdown_picker.sql`. Also applied a follow-up correction qualifying pgcrypto as `extensions.digest`; this is required in this LIVE database because pgcrypto is installed in the extensions schema.
- Replaced the text-search textarea and manually typed queue textarea in the owner dashboard with three cascading dropdowns, a selected-product staging list, add-single and add-entire-branch actions, and one bulk queue submission. Dashboard JS cache is v42. Production Cloudflare workflow run 42910837625 for HTML commit cf3bea245eb317447dab42c8a8b83dea733621f2 completed successfully.
- Remaining acceptance: sign in to the LIVE owner dashboard, refresh with Ctrl+F5, choose 3D Printers & Equipment → 3D Printers, confirm model dropdown loads 183 active catalogue products, test adding one model, test adding the entire branch (183 products), and verify the queue count. Do not click Queue selected products until the user chooses the intended items. TEST was not touched.


## Evidence-aware catalogue research checklist and bulk scope selection — 10 November 2026
- User correction: a single product dropdown is not an adequate research selector. The required screen is a checkbox checklist of every active catalogue product in the chosen category or branch, with evidence counts visible beside each product before queuing.
- LIVE owner dashboard now uses category dropdown → optional branch dropdown → scrollable product checklist. Each row has a checkbox, manufacturer/model/package, active UK New evidence count, active UK Used evidence count, and active total evidence count. Users can tick arbitrary combinations and retain selections while paging through products.
- Quick-select controls select the first 1, 2, 3, 5, 10, 100 or 500 products on the currently loaded page. The list loads up to 500 products per page and supports Previous 500 / Next 500. Individual selection is capped at 500 per submission.
- Separate confirmed actions queue the entire selected branch or entire category. These submit a category/branch scope to the database directly; they do not need to load every product UUID into the browser. A confirmation prompt states the intended scope and count. Queueing only creates research jobs; it does not edit master catalogue products or evidence.
- Evidence counts come from shared_market_evidence, joined by master_product_id, filtered to is_active=true, and split by exact evidence_type values uk_new and uk_used. LIVE evidence audit: 4,542 records total, 4,490 active, zero active records without a master product link; therefore per-product counts cover all active shared evidence currently in this table.
- Verified LIVE RPC platform_owner_list_cloud_ai_catalogue_products(p_category_id,p_branch_id,p_limit,p_offset): Action Cameras returned 182 products; 3D Printers & Equipment → 3D Printers returned 183 products. Example 3D printer row Anycubic Kobra 3 Max V2 / 4-Color Combo shows 2 New, 0 Used, 2 Total. The accessories branch contains 18 active products; the 3D Printers branch contains 183.
- Added owner-protected scope queue RPC platform_owner_enqueue_cloud_ai_catalogue_scope(p_product_ids,p_category_id,p_branch_id,p_task_type). It accepts individual product UUIDs, a whole branch, or a whole category. Execute granted to authenticated only; anon/public revoked. No-op validation returned zero selected/queued; LIVE cloud AI research jobs remain empty (0) and no research has been started.
- Source migration: supabase/migrations/20261110000300_cloud_ai_research_evidence_checklist_and_scope_queue.sql. Dashboard JS cache is v43. Production Worker deployment run 42911874332 deployed the evidence-aware HTML successfully; final JS commit 0abe9265182ad4766493726048620560eda9674b was also deployed successfully by run 42912166077.
- TEST remains untouched. No provider credentials, Groq settings, catalogue records, evidence records, tenant data, Stripe settings or research jobs were modified by this UI/schema work.


## Groq model replacement and free-tier verification gate — 10 November 2026
- LIVE Groq provider previously configured with retired `llama-3.3-70b-versatile`. Groq's official deprecation record states this model was decommissioned for Free/Developer usage on 2026-08-16; recommended replacements include `openai/gpt-oss-120b` and Qwen variants.
- Replaced the LIVE provider model ID with `openai/gpt-oss-120b` using the owner-protected `platform_owner_save_cloud_ai_provider` RPC. Groq API base URL remains `https://api.groq.com/openai/v1`; API protocol unchanged. The existing Vault secret was preserved (not read, exposed, rotated, or replaced). Provider remains enabled, existing no-paid-billing confirmation preserved, and internal daily request cap remains 5 (daily usage still 0).
- Groq's current model catalogue lists `openai/gpt-oss-120b` as the supported production model and the deprecation page explicitly recommends it as the replacement for Llama 3.3 70B. Groq Free Plan rate-limit documentation includes GPT-OSS 120B; Groq explains Free Plan usage stays free within its limits and over-limit requests are rate-limited rather than billed. The dashboard's internal cap of five requests/day is intentionally more restrictive than the published Free Plan ceiling. The organisation must remain on Groq Free tier for zero-cost operation; Developer tier is usage-billed and requires a payment method.
- No inference/completion was sent. No paid calls, research processing, provider key changes, or queued jobs. LIVE `platform_cloud_ai_research_jobs` count remains zero.
- Provider status deliberately held at `error` with a verification-pending note after saving the new model, so the scheduler will not use it before the model list check. This is intentional: the Edge Function's Test Connection reads only `GET /models`, compares the configured model ID with the models returned to this API key, and updates status to `ready` only when found. It does not submit a chat completion or spend generation tokens.
- Owner dashboard provider cards now show the stored last_error / verification note. The test result message distinguishes API reachability from configured-model availability. Dashboard JS cache advanced to v44. Production Worker deployment run 42913477543 for HTML commit `372eb2f0d0af7e08857abfee5f63617c16481e1e` completed successfully; the diagnostic detail is deployed.
- Remaining acceptance step: on the LIVE Owner Dashboard, Ctrl+F5, confirm Groq model field reads `openai/gpt-oss-120b`, then press **Test connection**. Expected result: `Connected · model confirmed · N models checked` if this model appears in the API key's list. Research must remain paused until that exact result is shown. If unavailable, retain status error and investigate Groq account model permissions; do not switch to a billed model.
- Reference URLs: https://console.groq.com/docs/deprecations ; https://console.groq.com/docs/models ; https://console.groq.com/docs/rate-limits ; https://console.groq.com/docs/billing-faqs


## Groq Free-plan HTTP 413 repair — 10 November 2026
- Screenshot at 22:24 showed Groq test succeeded for `openai/gpt-oss-120b`, then a research attempt returned HTTP 413. LIVE DB confirmed Groq still had 4/5 internal daily attempts available (daily_requests_used=1), but the old worker set provider status to error. The following queued job was then paused with the misleading message “No enabled free provider has remaining configured daily request allowance.” This was a status/diagnostic side-effect, not exhaustion of the daily cap.
- Root cause: research prompt included up to three complete cleaned source pages of up to 18,000 characters each. Groq Free GPT-OSS 120B has an 8,000 tokens/minute limit; one oversized request can be rejected with HTTP 413 before completion. Official Groq docs: https://console.groq.com/docs/rate-limits (token limits and GPT-OSS 120B Free/Developer limits), https://console.groq.com/docs/model/openai/gpt-oss-120b (model context and completion capabilities), https://console.groq.com/docs/api-reference (chat completion request schema).
- Edge Function `tradeflow-cloud-ai-manager` now compacts source context before inference: extracts windows around the selected manufacturer/model/package; sends no more than 3 source pages, 4,000 characters per page and 12,000 characters total; skips the inference request entirely if none of the fetched pages mention the selected product/model. GPT-OSS request uses `reasoning_effort: "low"` and `max_completion_tokens: 1200`, keeping prompt plus output comfortably below the Free-plan 8K TPM request ceiling.
- Groq request failures now preserve the provider's JSON error message/code/type. A genuine 413 token-rate error (HTTP 413 with `rate_limit_exceeded` / token-limit message) is treated as a temporary cooldown rather than a permanent provider error. Future diagnostics retain whether the provider is cooling down, actually at its daily cap, or marked error.
- Internal daily request usage is now incremented only after a successful inference completion, not before an attempt. The single prior 413 attempt did not return a completion; its internal usage counter was restored from 1 to 0. No retry/completion tokens were used during repair.
- Deployed LIVE Edge Function version 5. Provider row is ready with `openai/gpt-oss-120b`, enabled/free-confirmed, Vault key unchanged, internal cap 5/day, usage 0. Three screenshot jobs are queued: Atomos StudioSonic Shotgun Microphone (0 attempts), StudioSonic PRO (1 attempt, requeued after 413), StudioSonic AIR (1 attempt, requeued after the prior provider-status side effect). The two paused jobs were returned to queued; no job was run by this repair.
- LIVE cloud AI research queue remains 3 queued / 0 running / no new AI evidence candidates created in this repair. Existing catalogue products/evidence are unchanged; TEST remains untouched. The next deliberate **Run next job** action uses the compact request path. Verify Groq's returned error body/response and successful result before allowing larger batches.


## Manual AI Research Centre — catalogue prompts and pasted-response workflow — 10 November 2026

- Replaced the primary Cloud AI Research Manager screen with a catalogue-led AI Research Centre manual web-research workspace. The prior catalogue checklist remains the single product selector: category, optional branch, then checkbox product selection with existing active UK new/used evidence counts. This avoids a duplicate picker and preserves product selections and evidence history.
- Manual assistant selector supports ChatGPT, Google Gemini, Grok, Claude, Perplexity, Mistral Vibe, DeepSeek, Qwen Chat, Microsoft Copilot and Meta AI. Each saved batch stores the direct chat URL. Each prompt card places Copy research prompt alongside Open assistant website. No API key is needed for manual research.
- Product batch size selector offers 5, 10, 15 or 20 catalogue products per prompt (10 default). A batch supports up to 500 selected products. TradeFlow chunks the selection automatically and stores every generated prompt. Each prompt is tied to exact master product UUIDs and a snapshot of manufacturer/model/package/category/branch plus active UK new/used evidence counts and up to six existing evidence references per product.
- Prompt authoring requires live web search and direct-page inspection, not model memory, AI overviews or search-result snippets. Per product it requests at least five search variations: exact manufacturer+model+package, model+UK price, model+retailer, model+used/second-hand, and model+refurbished/pre-owned. It separates UK new retailers/official pages from live UK used-dealer and marketplace listings; checks bundle, revision, model suffix, condition, GBP price, availability and current date; excludes foreign prices, generic pages, ended listings and near-match models; requires direct HTTPS product/listing URLs and a verbatim page excerpt containing the exact model and GBP price. If browsing is unavailable or exact evidence is absent, the assistant must return a structured not_found explanation and must never invent evidence.
- Output contract is JSON-only schema_version tradeflow_manual_research_v1, with findings and not_found arrays. Each finding includes the supplied master product_id, exact manufacturer/model/package, uk_new or uk_used, retailer/listing name, direct URL, GBP price, condition, availability, observed date, match classification, verbatim quote, search queries and research notes. Each not_found row identifies its exact product and records queries attempted, sources checked and reason.
- New protected LIVE Supabase tables platform_manual_ai_research_batches and platform_manual_ai_research_prompts store batch metadata, selected product IDs, generated prompts, draft responses, final responses, status and candidate/rejection counts. Direct table access is revoked; owner-authenticated SECURITY DEFINER RPCs control create/list/save/submit. RPCs: platform_owner_create_manual_ai_research_batch, platform_owner_list_manual_ai_research_batches, platform_owner_save_manual_ai_research_draft, platform_owner_submit_manual_ai_research_response.
- Response workflow: paste full assistant response into the prompt's response box; optionally save a draft; validate and submit. Backend checks schema version, prompt ownership, that product IDs belong to the exact prompt snapshot, manufacturer/model/package identity, GBP amount, direct HTTPS non-search URL, verbatim excerpt containing model + GBP price, evidence type and source match. Every prompt product must be accounted for by at least one validated finding or a not_found entry with reason, searches_attempted and sources_checked; an omitted product blocks submission.
- Valid findings become pending_review candidates in the existing platform_catalogue_research_queue with agent_name prefix Manual AI Research · and live_master_product_id set to the exact catalogue product. The existing Evidence Awaiting Review UI now includes manual AI submissions. Duplicate source/product/price/type combinations are skipped. Candidate approval/review remains human-controlled; nothing is imported into shared_market_evidence automatically. TradeFlow validates structure and internal evidence consistency but does not itself browse/re-fetch external URLs during paste submission; the human reviewer must open and verify each source page before approval/import.
- The former automatic API provider settings, automatic job enqueue/run controls and queue are preserved inside a collapsed optional section. Manual research does not require or consume API credits; paid API fallback remains disabled.
- Disposable end-to-end checks created a prompt from real Action Cameras catalogue products, saved a response draft, submitted a test finding and a second test consisting of a valid not_found explanation, and confirmed the response path. Both disposable batches/candidates were deleted afterwards. Two separate Gemini batches (five products each, unsubmitted) were already present in LIVE and were deliberately preserved. Last observed manual state: 2 existing Gemini batches / 2 prompts / 0 manual review candidates; automatic API research queue remains separate with 3 jobs. No TEST changes, master catalogue changes, existing evidence changes or automatic research runs were made.
- Source migrations: supabase/migrations/20261110000400_manual_ai_research_workspace.sql and supabase/migrations/20261110000500_manual_ai_response_requires_each_product_accounted_for.sql. Dashboard HTML asset reference advanced to v45; manual workflow JS and the manual evidence-review filter are in platform-owner-dashboard.js.


## LIVE acceptance snapshot after manual research workspace deployment — 10 November 2026, 23:xx UTC
- Production Worker deployment runs 42917562307 (HTML), 42917697564 (selection button wiring), 42917822840 (manual batch/prompt/draft/response code) and 42917981048 (manual candidate review filter) all completed successfully. Dashboard HTML loads JS cache v45.
- LIVE now contains four unsubmitted manual batches created through the new workspace: Google Gemini x2 (five products each), ChatGPT x1 (two products), Claude x1 (one product), four prompts total. All are status in_progress / prompt ready. Preserve these user-created batches and their prompt text. Manual review candidates = 0.
- Both manual tables have RLS enabled and direct SELECT revoked from authenticated users; owner-only RPCs are executable by authenticated owners and not executable by anon.
- Automatic API research jobs remain a separate queue: three Atomos StudioSonic jobs are currently paused. Latest stored reasons say no fetched approved UK source page contained the exact selected product/model, so no inference request was sent. This manual-workspace deployment did not modify their status or process them.
- Final manual response coverage safeguard is deployed and source-controlled in migration 20261110000500: every selected product must appear in a validated finding or a not_found entry with a reason, searches_attempted array and sources_checked array. A one-product not_found-only response passed validation and was removed as a disposable test; no candidate remained.
- The manual UI does not fetch external pages itself on response submission. It validates product identity and response structure/source quote/URL consistency, then routes candidates to human Evidence Awaiting Review. Human reviewer must open direct source pages before approval/import.


## Manual AI research-depth validation safeguard — 10 November 2026
- Final follow-up validator is deployed in migration supabase/migrations/20261110000600_manual_ai_enforce_research_depth_and_dates.sql. Each evidence finding now requires at least five non-empty search queries, a real observed_at date that is not in the future, non-empty condition and availability, and the existing exact product/model/GBP/direct-URL/quoted-price checks. Each not_found entry must list at least five non-empty searches, at least two sources checked, and a reason. Every prompt product must be represented by validated findings or a valid not_found entry.
- Negative coverage test: an incomplete two-product reply covering only one product was rejected. Positive not_found-only test with five searches and two sources passed. Disposable test batch removed afterwards; it created no review candidates.
- Four previously existing user-created manual batches remain preserved: two Google Gemini batches (five products each), one ChatGPT batch (two products) and one Claude batch (one product). All four contain one ready, unsubmitted prompt; no manual review candidates currently exist.

## Manual AI natural-language report intake and same-model catalogue matching — 10 November 2026

### User-reported failure and correction
- User reported that the manual AI response box rejected a useful assistant answer with: “No JSON object was found. Ask the assistant to return the JSON-only format included in the prompt.” The pasted research contained readable UK New/Used price tables and direct links, followed by an imperfect or absent JSON block. Requiring JSON-only discarded useful research.
- Corrected the frontend submission route: it first accepts a valid TradeFlow JSON object/code block (normalising curly smart quotes where possible). If JSON is absent or invalid, it parses readable Markdown New prices and Used prices tables instead of rejecting the answer.
- Table parser handles bold table headings, Markdown source links, UK GBP prices, a separate delivery amount, and price ranges. A single unambiguous item price is extracted; a range remains a range (no midpoint/guessing). Entire report and tables are saved once against the prompt; each extracted reference stores its own table row/link/package/price display, without duplicating the entire long report in every queue row.

### Same-model alternatives are retained, not wasted
- Research prompt explicitly searches the exact requested package first and then broadens to the same exact manufacturer/model in standard-camera and alternative bundles. It instructs the assistant to keep each actual package name, show separate new and used price tables, link sources, and distinguish exact package from other packages, aggregators, editorial and inaccessible results.
- Alternative package results are not rejected. Natural-language table entries are initially staged as unverified comparison references in platform_catalogue_research_queue with live_master_product_id=NULL, evidence_role=comparison_only, and needs_manual_verification=true. They cannot inflate any product's new/used evidence counts and cannot be approved/imported until manually mapped and verified.
- Evidence Awaiting Review now offers “Find matching catalogue packages” on unverified comparison rows. Owner-only RPC searches active catalogue records in the same category with identical manufacturer and model. User selects the right package (e.g. AKASO 360 Standard Combo, Creator Combo, Motorcycle Combo, Cycling Combo). RPC validates identical manufacturer/model/category, assigns live_master_product_id, marks catalogue_match_assigned, and keeps it pending human source/package verification. After mapping, the row offers Approve after verification.
- This is deliberately not automatic fuzzy linking: similar-but-different camera models must not be silently matched. The user/human reviewer decides which same-model package a result belongs to.

### New LIVE backend and frontend
- Added owner-only RPC platform_owner_stage_manual_ai_report(p_prompt_id,p_response_text,p_references) to save the full report and stage its table rows as unverified references.
- Added platform_owner_list_manual_ai_comparison_matches(p_queue_id) and platform_owner_match_manual_ai_comparison(p_queue_id,p_product_id) to discover/select the right same-model catalogue package.
- platform_owner_list_manual_ai_research_batches now returns products_snapshot so the report parser can associate rows to the selected product(s).
- When a structured JSON block is present, the original strict JSON validation path remains. When only report tables are present, extracted rows are explicitly unverified; a source URL may be absent, an aggregated range may have no numeric observed_price, and the original price display is preserved. No fabricated direct page quote or exact price is created.
- Full readable AI report remains accessible in the completed prompt card. Comparison rows display the actual reported package, price display, source URL when supplied and an explicit unverified comparison status.
- Source migrations: supabase/migrations/20261110000900_manual_ai_readable_report_intake_and_catalogue_matching.sql and supabase/migrations/20261110001000_manual_ai_stage_report_store_report_once.sql. Dashboard JS asset cache is v49. LIVE Worker deployment run 42922681838 completed successfully.
- Tests: parser test based on the supplied AKASO new/used table layout extracted five useful references; a GBP range remained nonnumeric and a price-plus-delivery row retained the item price with delivery visible separately. Backend staging test created two comparison references from a report; match lookup returned all seven active AKASO 360 catalogue packages; a Standard camera row was successfully matched to the distinct Standard Combo catalogue product. Disposable batch and rows removed afterwards (zero test rows remain).
- Existing user data preserved: four manual batches remain (two Gemini, one ChatGPT, one Claude); Claude's 2,798-character draft remains intact. No manual review rows currently exist. Automatic API queue remains separate with three paused jobs. TEST untouched, catalogue/evidence/tenant/Stripe data unchanged.
- Human verification remains required: these report-only references are not trusted as evidence until direct pages/packages/prices are checked. After correct catalogue matching, reviewer can approve; no automatic insertion into shared_market_evidence occurs on paste.
