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
