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

### 2026-10-22 — Agent B follow-up: public website access hardening
- Scope remains LIVE website/deployment security only. No product catalogue, master-product, pricing, or evidence-ingestion writes were made.
- Applied LIVE Supabase migration name `public_published_content_active_tenant_guard_20261022`, remote migration version `20261022143445`. Source migration is committed on `production` at `supabase/migrations/20261022160000_public_published_content_active_tenant_guard.sql`.
- Added active-tenant checks to public published-site, published-store-listing, listing-media metadata and media-eligibility SECURITY DEFINER RPCs; set their `search_path` to empty.
- Updated public RLS policies on `tenant_public_profiles` and `published_site_index` to use `private.is_active_tenant(uuid)`. Granted `anon` EXECUTE on that helper for policy evaluation only; `anon` still has no USAGE on schema `private` and cannot call the helper directly.
- Updated source `supabase/functions/public-listing-media/index.ts` on `production` (commit `af84e2d0dde74aba76d07fae4230ca3cc865840b`) and deployed LIVE Edge Function version 11, SHA256 `7ef3943dc0d7a8f0c51ca103b3b0b5dbbb5b0b5d7db08fa61310bd2db7073996`; it now checks tenant active status before signing media URLs.
- Verified as SQL role `anon`: the current public profile, published-site index, and `get_published_sites()` each return the active site's single row. Schema `private` remains inaccessible directly. Snapshot: one active tenant with a published site, no inactive-tenant index rows.
- Documentation updated on production: AI operating manual, system handbook, human user manual, backend user manual, backend operations manual, LIVE launch runbook, master roadmap, and LIVE multitenant audit checkpoint.
- Still open: request-level/browser smoke tests, full tenant-isolation verification, and Stripe/payment end-to-end verification. Do not blanket-revoke the eight advisor-flagged public SECURITY DEFINER RPCs; review intended public access individually.

- Additional finding: the existing public-read policy on `tenant_public_profiles` referenced `private.is_active_tenant(uuid)`, but the earlier hardening migration had revoked `anon` EXECUTE on that helper. A role-`anon` SQL test reproduced `permission denied for function is_active_tenant`, which could suppress public business contact/profile data. The new migration restores EXECUTE for policy evaluation while leaving `USAGE` on schema `private` denied; the role-`anon` profile read now succeeds. This is a confirmed access regression fixed by the migration, separate from the preventive inactive-tenant filtering.

### 2026-10-22 — Agent B: authenticated SECURITY DEFINER review (open items)
- Initial review of high-risk LIVE RPCs: `process_external_payment_event(...)` is not executable by `anon` or `authenticated` and explicitly requires the service-role JWT claim; amount/currency/provider-payment ID checks and idempotency handling are present in the inspected body.
- `subscriber_get_buying_item_payment_details(uuid,uuid)` requires an authenticated actor plus both `buying.view` and `finance.manage` before returning customer bank details.
- Four test-registration RPCs remain executable by `authenticated`: `admin_complete_test_registration(text)`, `staff_complete_test_registration(text)`, `customer_complete_test_registration(text,text,text)`, and `customer_test_registration_status()`. LIVE currently has no active tenants with slugs `test-business-a` / `test-business-b` and no `test_lab=true` tenants, so the registration paths have no eligible target at this snapshot. However, admin/staff registration checks the hard-coded slug and active status but does not check the `test_lab` flag. This is a latent privilege-escalation risk if a matching active tenant is ever created. Do not add those slugs to LIVE; next review should either revoke the admin/staff RPC grants on LIVE or add a strict test-lab guard after checking intended test-lab usage.
- `customer_complete_test_registration` is referenced by production `app.js`, so do not revoke it without deciding whether the customer test-lab page remains intentionally available. This item remains open; no test-registration RPC grants were changed.
- The broad authenticated SECURITY DEFINER inventory (165 advisor notices) is not fully reviewed yet. Continue by inspecting tenant/owner authorization guards on privileged platform, subscription, domain, and payment RPCs; avoid blanket revokes.

