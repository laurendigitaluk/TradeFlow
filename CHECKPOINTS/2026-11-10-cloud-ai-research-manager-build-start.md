# Checkpoint — Cloud AI Research Manager build start

Date: 10 November 2026
Branch: `feature/cloud-ai-research-manager-20261110`
Base: `production`
Status: preflight complete; implementation not deployed.

## User requirement
Build the multi-provider cloud AI research manager into the TradeFlow Platform Owner Dashboard. Multiple AI apps/providers should research catalogue products, record evidence with source links and dates, and submit findings for ChatGPT/owner review before database import. Use as many genuinely free API providers as can be supported. No paid fallback or surprise charges.

## Preflight findings
- Current production owner dashboard files are `platform-owner-dashboard.html/js/css`; active platform membership is the owner authorization boundary.
- LIVE has 47,028 master products at the schema snapshot, 75 rows in `platform_catalogue_research_queue`, 54 `platform_research_sources`, and the report inbox table `platform_research_reports`.
- Existing research queue supports product/release/evidence candidates and review states; use it rather than inventing a competing candidate workflow.
- Existing report inbox migration creates private report storage and service-role-only table access; report submission stages data and does not import evidence.
- Retired Gemma runtime and its task system must remain retired.
- LIVE `tradeflow-research-mcp` deployed version has source drift from GitHub production. Do not redeploy it as part of this feature.
- TEST and LIVE are separate projects. TEST is the validation target; no TEST data is to be copied to LIVE.
- Previous standalone Windows AI Manager prototype is isolated on `feature/tradeflow-ai-manager-desktop-20261110`; it is not the target product and is not merged.

## Changes made
- Created isolated branch `feature/cloud-ai-research-manager-20261110` from production.
- No production code, Supabase schema/data, Cloudflare deployment, Stripe settings, provider secrets or AI runtime settings changed.
- Added the diagnostic roadmap at `docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-CLOUD-AI-RESEARCH-MANAGER.md`.

## Next gate
Inspect provider secret-storage capability and current evidence import schema/RPCs, then implement on this branch and LIVE. Do not deploy to LIVE until owner authorization, no-paid-fallback, cooldown/resume, report provenance, dedupe and approval-only import are verified.


## Follow-on progress (10 November 2026)
- Added owner dashboard panel for provider setup, connection tests, manual research enqueue and queue visibility.
- Applied TEST-only migrations creating provider settings and research jobs tables, with RLS enabled and direct anon/authenticated table privileges revoked.
- Added owner-only RPCs; provider secrets stored in Supabase Vault, with secret retrieval restricted to service_role.
- Deployed TEST Edge Function `tradeflow-cloud-ai-manager` version 2, JWT verification enabled. It checks owner membership and provider model-list connectivity only.
- OpenRouter enabled model IDs are restricted to `:free`; provider enablement requires owner confirmation of free-tier API access. No paid fallback implemented.
- No provider key has been supplied, no AI research has been run, and no product/evidence records have been inserted.
- The dashboard code remains on the isolated feature branch; it has not been deployed to the live owner dashboard. The next build phase is the research runner and evidence-review pipeline.


## Research runner and provider adapter update (10 November 2026)
The TEST implementation now supports nine cloud AI adapters (Gemini, Groq, OpenRouter, Cerebras, SambaNova, NVIDIA NIM, Mistral, Hugging Face Router and GitHub Models). Only providers explicitly confirmed free by the owner, enabled, connected and below their configured daily request cap can be used. Provider errors and quota responses pause or disable that provider; the runner tries another eligible provider and never falls back to paid models. Jobs are leased and resumable. The runner fetches a maximum of three approved UK source pages, passes their extracted text to the model, and stages only validated evidence candidates with direct source provenance for owner review. This is not yet broad web search: many source-registry rows have no product search URL template. The dashboard's “Run next job” action is manual; no scheduler is configured. Approving a candidate does not import it into approved evidence. No keys or research requests have been used. Keep all work on TEST until full acceptance.


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
