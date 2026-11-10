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
