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
