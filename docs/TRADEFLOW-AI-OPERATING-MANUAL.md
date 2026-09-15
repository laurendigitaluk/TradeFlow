# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 1.2  
**Date:** 16 September 2026  
**Project:** TradeFlow

## 1. Purpose
This is the AI continuity companion to `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`. It records current architectural truth, decisions, faults, lessons, limitations, verification state and the exact stopping point so a future AI session can resume safely without guessing.

## 2. Mandatory procedure
For significant TradeFlow work:

**Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → capture checkpoint.**

Never treat chat history or a remembered summary as sufficient when current code/database state can be inspected.

## 3. Non-negotiable TradeFlow rules
- Never modify GearCashOut production when working on TradeFlow.
- `tenant_id` is the primary tenant security boundary.
- Never infer tenant identity merely from `auth.uid()` when a user can belong to multiple tenants.
- Tenant staff access is through `tenant_memberships` and role permissions.
- Current tenant roles are exactly `owner`, `admin`, `staff`.
- Platform Owner is above tenant roles and uses a separate platform-level identity boundary.
- Never create a `platform_owner` tenant role.
- Never allow a user to self-claim Platform Owner access.
- Subscription capabilities belong to the tenant.
- Customer data must remain tenant-isolated.
- Dynamic fields are data-driven; arbitrary browser JSON must not become valuation or workflow authority.
- Database validation is authoritative for dynamic select/multiselect values.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory creation are separate lifecycle steps.
- Inventory and listings are separate domains.
- Public storefront access must resolve to a tenant and expose only published records.
- Business status changes must use authoritative workflow services/RPCs where provided.
- Do not mark a feature complete solely because code was committed.
- Do not expose temporary test-lab onboarding mechanisms as production onboarding.
- Do not store credentials, tokens or secrets in documentation or project memory.

## 4. Verification states
Use independently:

- **Proposed** — design/decision only.
- **Implemented** — code/database change exists.
- **Tested** — a controlled test has exercised it.
- **Verified Live** — the deployed/live environment has been confirmed to behave as expected.

A commit is implementation evidence, not live verification. A transactional rollback test proves database behaviour but does not by itself prove a complete persistent UI journey.

## 5. Current environment checkpoint — 16 September 2026
- GitHub repository: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase project: TradeFlow, ref `twfbmjwwqzxdxvclxbun`.
- Supabase region: `eu-west-2`.
- Recorded Supabase health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- Customer Test Lab: **34/34 passed** at the recorded checkpoint.
- Customer subscription tests: **Buying 17/17; Selling 17/17 passed**.
- Staff security lab: **19/19 passed**.
- Customer subscription guard hardening completed through migration 043.
- Platform-owner security boundary implemented through migrations 044–045.
- Platform-admin privileged provisioning/read guards implemented through migrations 046–048.
- Buying-domain hardening implemented through migrations 049–051.
- Master roadmap: `TRADEFLOW-MASTER-ROADMAP.md`.

## 6. Platform Owner / tenant-role architecture
Correct hierarchy:

```text
TradeFlow Platform
└── Platform Owner
    ├── Subscriber Tenant A
    │   ├── Owner
    │   ├── Admin
    │   ├── Staff
    │   └── Customers
    ├── Subscriber Tenant B
    │   └── ...
    └── ...
```

Tenant memberships remain tenant-scoped. Platform membership is separate.

Migration 044 created `public.platform_memberships` with controlled status, unique authenticated `user_id`, RLS and no client write policy. `private.is_platform_owner()` checks explicit active platform membership.

Migration 045 created restricted `private.require_platform_owner()` and `private.has_platform_owner_access()` guards. These bind access to the current authenticated identity and do not accept tenant ownership as a substitute.

The Platform Owner has now been provisioned through the trusted administrative path. Platform administration tenant creation has been exercised through the privileged path.

## 7. Platform Administration UI finding and repair
Platform Administration is implemented in:
- `platform-admin.html`
- `platform-admin.js`

The page signs the Platform Owner into Supabase Auth and calls privileged platform-admin RPCs. Migrations 046–048 established the privileged provisioning/read path and hardened its read guards.

A browser failure was traced to an HTTP-method mismatch: the relevant PL/pgSQL functions are VOLATILE under PostgREST semantics, so read-style GET/HEAD invocation is not permitted. The controller was repaired to use **POST** for the affected RPCs.

The UI deliberately treats authentication/authorisation failures as a controlled `Platform Owner access required` state rather than exposing privileged data.

**Verification status:** the database privileged path has been exercised and the client repair is implemented. A final browser regression capture after the POST repair remains an open verification item.

## 8. Production onboarding — still open
The original tenant foundation still contains an authenticated tenant insertion path using `with check (true)`, and temporary test-lab onboarding functions exist. These must not become production onboarding.

Required production sequence:

**Platform Owner / approved onboarding → tenant creation → initial tenant owner provisioning → subscription assignment → tenant owner/admin/staff management.**

Before public SaaS onboarding:
- remove or replace the unrestricted authenticated tenant-insert route;
- keep test-lab registration mechanisms development-only;
- ensure initial owner provisioning is trusted and authoritative;
- ensure subscription assignment is authoritative;
- verify tenant owner/admin/staff management end to end.

## 9. Subscription capability architecture
The subscription capability model uses:
- plans;
- `plan_features`;
- `tenant_subscriptions`;
- `private.has_tenant_feature()`;
- `private.require_tenant_feature()`.

Customer RPCs are subscription-gated. The recorded Buying and Selling subscription tests both achieved 17/17.

Future modules must use the tenant capability layer rather than relying on browser-only plan checks.

## 10. Dynamic Categories / Fields / Options
Categories, fields and options are data-driven. Client-side validation is useful for UX but is never sufficient authority.

Migration 049 hardened `customer_submit_buying_request` so:
- `select` values must be strings matching active `category_field_options`;
- `multiselect` values must be arrays;
- every multiselect member must match an active allowed option.

A transactional pre-repair test proved that an invalid select value could previously be accepted. Post-repair testing rejected the invalid value and accepted a valid submission. Tests were rolled back and left no persistent audit records.

Full category management, option lifecycle, customer visibility and UI workflow remain **Not yet fully audited**.

## 11. Buying domain — migrations 049–051
### 11.1 Migration 049 — `harden_buying_dynamic_option_validation`
Purpose: make dynamic select/multiselect option validation authoritative inside the database submission function.

Result: invalid option values are rejected; valid values continue to submit.

### 11.2 Migration 050 — `harden_buying_workflow_transitions`
`transition_workflow_entity` now supports `buying_request` and `buying_item` using the `buying.manage` permission and `module.buying` capability.

Authoritative status progression:

```text
Buying Request: draft → submitted → under_review → valued → offer_ready → closed
Buying Item:    draft → submitted → under_review → valued → offer_ready → closed
```

The function updates the business record and records the workflow transition.

### 11.3 Migration 051 — `record_buying_submission_workflow_events`
`customer_submit_buying_request` now records the initial `draft → submitted` workflow event for the request and each submitted item, with metadata identifying `source: customer_portal`.

Transactional verification proved:
- submission events are recorded;
- request transitions can move from `submitted → under_review → valued` through the authoritative workflow function;
- item transitions can move through the same controlled progression.

Tests were rolled back.

### 11.4 Buying status
**BLUE / partial.** Database validation and workflow authority are tested transactionally. A persistent real-data browser journey from customer submission through review, valuation and offer readiness has not yet been completed.

## 12. Workflow audit rule
For each business workflow, inspect:

1. all allowed states;
2. all forbidden states;
3. role/permission requirements;
4. subscription/module capability requirements;
5. tenant ownership/boundary;
6. authoritative record update;
7. workflow/event record;
8. triggers and side effects;
9. rollback/failure behaviour;
10. visible UI result;
11. external integrations;
12. audit trail.

Never assume a status transition is safe because a UI button exists.

## 13. Current business-domain roadmap
- Tenant & identity: **AMBER** — production onboarding still open.
- Subscriptions: **GREEN** — capability architecture and recorded 17/17 Buying + 17/17 Selling tests.
- Customers: **GREEN** — recorded 34/34 customer security/isolation test.
- Dynamic categories: **AMBER** — backend option validation hardened; complete domain/UI audit remains.
- Buying: **BLUE** — migrations 049–051 hardened validation, submission events and authoritative transitions; persistent UI journey remains.
- Trading Value / valuation rules: **AMBER — NEXT AUDIT**.
- Offers / offer events: **AMBER** — lifecycle authority not fully audited.
- Acquisition / acquisition items: **AMBER** — receipt/inspection/payment/inventory lifecycle not fully audited.
- Inventory: **AMBER**.
- Selling/listings: **AMBER**.
- Retail orders: **AMBER**.
- Fulfilment: **AMBER**.
- Returns: **AMBER**.
- Finance/payment: **AMBER**.
- Notifications/email: **AMBER**.
- Public storefront: **AMBER**.
- Media/storage: **AMBER**.
- Staff roles/permissions: **BLUE** — security lab 19/19 passed; complete management workflow remains.
- Premium staff messenger: **RED / future module**.
- System-wide RLS/grants/RPC/workflow: **BLUE** — several paths audited; final system-wide audit remains.

## 14. Diagnostic standard
For every major action record the complete trace:

**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames, handlers, RPCs/queries, tables/views, statuses, functions, triggers, constraints, RLS policies, grants, external services, failure modes and recovery. If not inspected, explicitly write **Roadmap status: Not yet audited**.

Do not invent a filename, function, table, policy or connection to fill a documentation gap.

## 15. Manual UI security-test procedure
When a manual browser security test is required, perform **one test at a time**:

1. provide the exact link;
2. provide the exact account to use;
3. provide the exact action;
4. state the expected result;
5. wait for the user's screenshot/result;
6. record PASS/FAIL and only then proceed.

Do not batch multiple manual UI tests when the user has requested one-at-a-time verification.

## 16. Database test procedure
Where persistent test records are undesirable, use a transaction and roll back after asserting the result. Record clearly that the result is **transactionally tested**, not a persistent UI verification.

Do not claim that a rollback test proves the complete customer/staff/browser workflow.

## 17. Documentation/change-control rule
After every material change capture:

- **What changed**
- **Why it changed**
- **Affected files/backend objects**
- **Architectural decision**
- **Fault found / lesson learned**
- **Test performed**
- **Live verification state**
- **Current stopping point**
- **Next safe action**

Update all three continuity documents when the material change affects project architecture or build position:
1. `TRADEFLOW-MASTER-ROADMAP.md`
2. `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
3. `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Where available, also update the structured Supabase project-memory/checkpoint layer.

## 18. Current stopping point — 16 September 2026
The verified customer security/subscription layer remains intact. Tenant role permissions are inspected. Platform Owner security and privileged administration foundations are implemented, and the Platform Owner has been provisioned. The final browser regression capture for the repaired Platform Administration POST flow remains open.

Production tenant onboarding is still not approved for public SaaS use because the development tenant-insert/test-lab paths have not yet been replaced by the authoritative production onboarding service.

The Buying domain has now been materially hardened through migrations **049, 050 and 051**. Dynamic option validation, Buying request/item workflow authority and customer submission workflow events have been transactionally verified. No persistent records were left by those audit tests.

**Next safe technical/business-domain audit:**

**Trading Value → valuation rules → authoritative valuation workflow → Offers → Acquisition.**

Do not skip the evidence trail. Do not mark an AMBER domain GREEN without the required database, UI and live verification evidence. Do not modify GearCashOut production as part of TradeFlow work.
