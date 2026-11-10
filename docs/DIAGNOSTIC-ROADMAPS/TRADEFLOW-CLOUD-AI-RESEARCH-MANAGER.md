# TradeFlow Cloud AI Research Manager — Developer Diagnostic Roadmap

Updated: 10 November 2026
Status: architecture and repository preflight completed; implementation is isolated on `feature/cloud-ai-research-manager-20261110`. Not deployed.

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
