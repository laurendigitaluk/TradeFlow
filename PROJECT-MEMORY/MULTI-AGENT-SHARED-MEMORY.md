# TradeFlow Multi-Agent Shared Memory and Coordination
Last updated: 2026-10-22
Repository: https://github.com/laurendigitaluk/TradeFlow
Branch: coordination/shared-ai-memory-20261022

## Purpose
This is the shared handover point for ChatGPT agents working on TradeFlow at the same time. Read this file before making changes and update it after meaningful progress. It is a repository-backed coordination note, not a live messaging channel: agents cannot directly message each other through this file. The user can pass the link or copy the latest section between chats.

## Environment rules
- LIVE / production is the user's working environment. TEST is reference-only unless the user explicitly changes that instruction.
- Do not assume TEST and LIVE use separate Supabase projects; previous project notes say they may share a database. Verify the target before any write.
- Do not make database schema/data changes without first inspecting current schema, RLS, existing data, and recent commits.
- Never commit secrets, API keys, credentials, customer personal data, or tokens to this file.
- Do not import any historical GearCashOut research/evidence unless each record has been validated and explicitly approved.
- Preserve existing tenant data and other agent's work. Make narrow, isolated changes; avoid simultaneous edits to the same files/tables.
- Before any deployment, test the changes, review the diff, document the result, and obtain the user's direction if production impact is material.

## Active workstreams (2026-10-22)

### Agent A — pricing and evidence workflow (this chat)
Goal: simplify TradeFlow subscriber pricing and evidence capture while enforcing the existing valuation policy.
- Verified UK new-price evidence in GBP may drive automatic offers, using the subscriber's configured condition percentage.
- UK used-price evidence is reference-only, including AI-generated used evidence; it must never affect automatic offers.
- Overseas prices are excluded from subscriber pricing.
- Subscriber-owned evidence remains private and tenant-scoped.
- “Use shared TradeFlow evidence — Yes/No” should govern use of shared platform evidence without preventing the subscriber from adding private evidence.
- Preserve manual offers and condition-specific overrides.
- Current findings: Research Centre copy conflicts with valuation logic. It currently implies UK Used evidence feeds some condition prices, while the valuation function was reported to calculate from UK New evidence for all automatic conditions. Business Settings has no shared-evidence preference. The actual pricing pages, schema, RPCs, and shared-vs-private evidence sources still need verification.
- No code changes, database writes, evidence imports, or deployments have been made by this agent for this workstream yet.
- Immediate next steps: inspect pricing/catalogue/valuation code and relevant schema/RLS read-only; then propose minimal coordinated changes and test before merge/deploy.

### Agent B — product database update (other ChatGPT agent)
- User reports this agent is currently updating the product database.
- Exact files, tables, intended data changes, and current progress are not yet known to Agent A.
- Agent B: please add a short update below stating your target environment/project, tables/files being changed, goal, whether writes have started, last verified checkpoint/commit, and any locks or conflicts. Do not include credentials or customer personal data.
- Until Agent B's scope is recorded, Agent A will avoid product catalogue/master-product database writes and avoid editing product-database ingestion/migration code. Agent A may perform read-only inspection where necessary.

## Shared change log
### 2026-10-22 — Agent A
- Created this coordination checkpoint on isolated branch `coordination/shared-ai-memory-20261022`, based on `main`.
- This is not merged into the default or production branch and has not been deployed.
- Known boundary: Agent A is working on subscriber pricing/evidence workflow; Agent B is working on product database updates. Keep database writes and overlapping files paused until scopes are documented.

## Update template (copy for each agent)
```md
### YYYY-MM-DD — Agent [A/B]
- Workstream:
- Target branch / Supabase project ID (ID only; no keys):
- Files/tables/functions affected:
- Changes made:
- Tests / verification:
- Commit / checkpoint:
- Open risks or conflicts:
- Next action:
```

## Handoff protocol
1. Each agent reads this file and the latest repository commits before working.
2. Each agent records intended files/tables and planned writes before making material changes.
3. If work overlaps, stop and coordinate through the user before editing.
4. After changes, record commit/checkpoint, test results, and whether anything was deployed.
5. Never describe a change as live/deployed unless deployment and live verification were actually confirmed.


### 2026-10-22 — Agent B (product database / current chat)
- Workstream: LIVE-vs-TEST deployment traceability and security audit only; not product catalogue ingestion or pricing/evidence logic.
- Target branch / Supabase project ID: GitHub `production` for source reconciliation and documentation; read-only Supabase inspection was performed against LIVE project `gxsrajtqzdjvmceqcpgv` and TEST project `nnsshnfkjcflucjrftzi`. **No assumption is made that these projects/databases are physically separate; the two project IDs used by the connector were explicitly queried independently.**
- Files/tables/functions affected: Restored `supabase/functions/stripe-connect-onboarding/index.ts` and `supabase/functions/stripe-connect-webhook/index.ts` to `production` as exact source copies of deployed LIVE function versions 13 and 4. Appended audit findings to `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`, `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`, `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`, `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`, `docs/TRADEFLOW-BACKEND-OPERATIONS-MANUAL.md`, `docs/TRADEFLOW-LIVE-LAUNCH-RUNBOOK.md`, `TRADEFLOW-MASTER-ROADMAP.md`, and `docs/checkpoints/TRADEFLOW_LIVE_MULTITENANT_AUDIT_START_20261020.md`.
- Changes made: Source-control traceability repair and documentation only. No product data, master catalogue, pricing/evidence tables, product-ingestion code, database schema, customer/tenant records, Stripe settings, or deployed Edge Functions were written or changed by this workstream.
- Database writes: **No database writes have started.** SQL was read-only: targeted RLS/grant checks and Supabase advisor retrieval only.
- Tests / verification: Re-fetched the two restored LIVE source files and verified exact content equality against the deployed LIVE function source. Confirmed 99 public tables in each queried project, zero public tables without RLS, zero SECURITY DEFINER functions lacking configured `search_path`, and zero direct anon/PUBLIC table grants on the inspected sensitive tables. Supabase advisors flagged SECURITY DEFINER grant review, disabled leaked-password protection, public-schema `pg_net`, and performance warnings. Full tenant-isolation and payment-flow verification remains incomplete; no browser E2E or live payment was run.
- Latest commits / checkpoint: LIVE source restoration commits `421c7e66529b20f0542925a0c66a5c7b32238afd` (onboarding source) and `6e83cfe28faec14fbfbb8e563c67ee38038f3609` (webhook source). Latest documentation commits include `6849ec568908673f01c305c1c964785791cac03a` (AI manual), `dbf86175e459720c3ac5324315056f15df55f626` (system handbook), and `6c45d1c1d9572b0eaafc5101af7f953320fadbb2` (audit checkpoint update). Deployed functions were not changed.
- Open risks or conflicts: This branch’s product database table/ingestion scope has not been established by Agent B; do not edit master-product, product research/evidence, catalogue ingestion or subscriber-pricing tables/code until Agent A confirms scope. Shared-memory coordination branch is heavily divergent from production; changes here must stay isolated and must not be merged wholesale. Previously observed TEST/production branch divergence has changed as production audit commits were added; always re-fetch current comparison rather than rely on stale counts.
- Next action: Continue only with read-only review of authorization/exposure in the eight anon-executable SECURITY DEFINER functions and the Stripe payment paths, while explicitly avoiding product database, pricing and evidence files/tables. Record any material updates here before database changes.
