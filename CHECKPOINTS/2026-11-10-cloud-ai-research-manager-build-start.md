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
Inspect provider secret-storage capability and current evidence import schema/RPCs, then implement on this branch and TEST only. Do not deploy to LIVE until owner authorization, no-paid-fallback, cooldown/resume, report provenance, dedupe and approval-only import are verified.


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
- This scheduled runner is active in TEST only. No cron job or Edge Function was created in LIVE.
