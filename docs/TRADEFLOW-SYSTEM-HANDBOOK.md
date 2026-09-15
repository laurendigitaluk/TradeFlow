# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 1.2  
**Date:** 16 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose
This is the human-readable technical and operational handbook for TradeFlow. It records verified architecture, security boundaries, workflow rules, implementation decisions, faults, lessons and the exact build position so development can continue without guessing.

## 2. Authority
**Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour.**
A Git commit is implementation evidence, not proof that a feature works live.

## 3. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

```text
TradeFlow Platform
└── Platform Owner
    ├── Subscriber Tenant
    │   ├── Owner
    │   ├── Admin
    │   ├── Staff
    │   └── Customers
    └── ...
```

The tenant role catalogue is exactly `owner`, `admin`, `staff`. **Platform Owner is a separate platform-level boundary and is not a tenant role.**

Each tenant must have its own customers and business records. Cross-tenant access must be prevented by database authority, not merely by hiding records in the UI.

## 4. Current environment checkpoint
- GitHub repository: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase project: `TradeFlow`, ref `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded Supabase health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- TradeFlow is a clean generic SaaS build. GearCashOut is reference material only and must never be modified as part of TradeFlow work.

## 5. Verified security checkpoint
- Customer tenant/isolation test: **34/34 passed** at the recorded checkpoint.
- Customer subscription tests: **Buying 17/17 passed; Selling 17/17 passed**.
- Staff security test: **19/19 passed**.
- Customer subscription guard hardening completed through migration 043.
- Platform-owner security boundary implemented through migrations 044/045.
- Platform-admin privileged provisioning/read guards implemented through migrations 046–048.

These results are retained as verification evidence; future changes must not assume that an old test remains valid after modifying the affected path.

## 6. Tenant-role boundary
`public.tenant_memberships` contains `tenant_id`, `user_id`, `role_code` and `status`; `role_code` is constrained to `owner`, `admin` or `staff`.

`public.roles` and `public.role_permissions` provide the permission model. `private.has_tenant_permission()` resolves active tenant-role permissions. `private.is_tenant_member()` checks active membership and `private.is_tenant_admin()` treats active owners/admins as tenant administrators.

Current inspected role mapping:
- Owner has the full current permission catalogue.
- Admin does not have `staff.manage`, `tenant.manage` or `audit.view`.
- Staff does not have `staff.manage`, `tenant.manage`, `website.manage`, `website.publish`, `finance.manage` or `audit.view`.

This is database evidence. UI routes and management workflows must still be traced before being marked complete.

## 7. Platform Owner boundary
Migration 044 adds `public.platform_memberships`, deliberately separate from `tenant_memberships`, with controlled membership status and unique authenticated `user_id`. RLS is enabled and no client insert/update/delete path is exposed.

Migration 044 adds `private.is_platform_owner()`. Migration 045 adds restricted `private.require_platform_owner()` and `private.has_platform_owner_access()` guards. These bind the check to the current authenticated identity and do not accept tenant ownership as a substitute.

The Platform Owner has now been provisioned through the trusted administrative path. The platform-admin privileged path has been exercised, including tenant creation. Platform ownership must never be self-claimed and must never be represented by a tenant role.

## 8. Platform Administration page
The current administration page is:
- `platform-admin.html`
- `platform-admin.js`

The client signs the Platform Owner into Supabase Auth and calls privileged platform-admin RPCs. The affected RPCs are invoked with **POST** because the underlying PL/pgSQL functions are VOLATILE under PostgREST semantics. An earlier browser failure was traced to attempting a read-style GET against a volatile function; the controller was repaired to use POST.

The UI deliberately opens the administration surface only after platform-owner access is accepted and surfaces a controlled `Platform Owner access required` message when the boundary rejects the session.

Final browser regression verification after the POST repair remains an open verification item even though the underlying privileged database path has been exercised.

## 9. Production tenant onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)`, and temporary test-lab onboarding functions exist. These are **not** the final production SaaS onboarding mechanism.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial tenant owner provisioning → subscription assignment → tenant owner/admin/staff management.**

Before public SaaS onboarding, the unrestricted tenant-insert route must be removed or replaced by an authoritative trusted onboarding service. Test-lab registration functions must not be exposed as production onboarding.

## 10. Subscription capability architecture
Subscription capabilities belong to the tenant. The capability layer uses plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Customer RPCs are subscription-gated. The recorded Buying and Selling customer subscription tests both achieved 17/17. Future modules must use the same capability architecture rather than creating unrelated browser-only plan checks.

## 11. Dynamic Categories / Fields / Options
Categories and their dynamic fields/options are data-driven. Browser-supplied JSON is not authoritative merely because it passed client-side validation.

The current audit has specifically hardened Buying submission so dynamic select and multiselect values are checked against active `category_field_options` for the relevant category field.

Full category management, option lifecycle, customer visibility and UI workflow are **Not yet fully audited**.

## 12. Buying domain — current implementation checkpoint
The Buying domain has been materially hardened through migrations 049–051.

### Migration 049 — dynamic option validation
`customer_submit_buying_request` now:
- requires a `select` value to be a string matching an active allowed option;
- requires a `multiselect` value to be an array;
- rejects any multiselect member not matching an active allowed option.

A transactional test proved the former defect: an invalid select value could be accepted before the repair. After migration 049 the invalid value is rejected and a valid submission succeeds. The tests were rolled back, so no test records remained.

### Migration 050 — authoritative Buying transitions
`transition_workflow_entity` now supports `buying_request` and `buying_item` under the `buying.manage` permission and `module.buying` capability.

Authoritative progression:

```text
Buying Request: draft → submitted → under_review → valued → offer_ready → closed
Buying Item:    draft → submitted → under_review → valued → offer_ready → closed
```

The authoritative function updates the business record and records the workflow transition.

### Migration 051 — submission events
`customer_submit_buying_request` now records `draft → submitted` workflow events for the request and each submitted item, with metadata identifying `source: customer_portal`.

Transactional verification proved submission events are recorded and that request/item transitions through `submitted → under_review → valued` work through the authoritative workflow function. These tests were rolled back.

### Buying status
**BLUE / partial.** Database authority and key validation are tested transactionally. A persistent real-data UI journey from customer submission through valuation/offer readiness has not yet been completed and must not be marked GREEN.

## 13. Workflow authority rule
Business status changes must use an authoritative transactional service/RPC where one exists. A browser must not be treated as the source of truth for lifecycle transitions.

For every workflow audit, check:
1. allowed states;
2. forbidden states;
3. role/permission requirement;
4. subscription/module capability;
5. tenant boundary;
6. record update;
7. transition/event record;
8. trigger/side effects;
9. failure and rollback behaviour;
10. visible UI result.

## 14. Business-domain roadmap
Current domain position:

| Domain | Status | Position |
|---|---|---|
| Tenant & identity | AMBER | Production onboarding still open. |
| Subscriptions | GREEN | Capability architecture and 17/17 Buying + 17/17 Selling tests recorded. |
| Customers | GREEN | 34/34 customer isolation/security test recorded. |
| Dynamic categories | AMBER | Backend Buying option validation hardened; full domain/UI audit remains. |
| Buying | BLUE | Migrations 049–051 hardened validation, submission events and authoritative transitions; persistent UI flow remains. |
| Trading Value / valuation | AMBER | Next business-domain audit. |
| Offers | AMBER | Lifecycle and event authority not fully audited. |
| Acquisition | AMBER | Receipt/inspection/payment/inventory lifecycle not fully audited. |
| Inventory | AMBER | Full live trace not completed. |
| Selling/listings | AMBER | Lifecycle audit remains. |
| Retail orders | AMBER | Complete workflow audit remains. |
| Fulfilment | AMBER | Operational workflow audit remains. |
| Returns | AMBER | Full lifecycle audit remains. |
| Finance/payment | AMBER | Live authority and reconciliation audit remains. |
| Notifications/email | AMBER | Provider/integration audit remains. |
| Public storefront | AMBER | Published read model and publication workflow require audit. |
| Media/storage | AMBER | Storage ownership/access path requires audit. |
| Staff roles/permissions | BLUE | Security lab 19/19 passed; complete management workflow remains. |
| Premium messenger | RED | Future module. |
| System-wide RLS/grants/workflow | BLUE | Multiple paths audited; final system-wide pass remains. |

## 15. Diagnostic standard
For every major feature document the full chain:

**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record exact filenames, handlers, RPCs/queries, tables/views, statuses, functions, triggers, constraints, RLS policies, grants, external services, failure modes and recovery. If a connection has not been inspected, write **Roadmap status: Not yet audited** rather than guessing.

## 16. Testing standard
Security/UI tests requested for manual browser verification are performed **one test at a time** with:
- exact URL;
- exact account;
- exact action;
- expected result;
- screenshot/result before moving to the next test.

Database audit tests may use transactions and rollback where persistent test records are not desirable. A rollback test proves database behaviour, not a complete persistent UI journey.

## 17. Documentation/change-control rule
Every material change should capture:
- what changed;
- why it changed;
- affected files/backend objects;
- architectural decision;
- fault found and lesson learned;
- test performed;
- live verification state;
- current stopping point;
- next safe action.

The Human/Developer Handbook, AI Operating Manual and Master Roadmap are the continuity record. Structured Supabase project-memory/checkpoint data should also be updated where available.

## 18. Current stopping point — 16 September 2026
The customer security/subscription layer remains verified and must not be disturbed without a specific reason. Tenant role boundaries are inspected. Platform Owner security and privileged administration foundations are implemented, and the Platform Owner has been provisioned. Production onboarding is still not finalised for public SaaS use.

The Buying audit has progressed through migrations **049, 050 and 051**. Dynamic select/multiselect validation, Buying request/item workflow authority and customer submission workflow events have been transactionally verified. No persistent records were left by those audit tests.

**Next technical/business-domain audit:**
**Trading Value → valuation rules → authoritative valuation workflow → Offers → Acquisition.**

Do not mark later domains complete by assumption. Continue the trace from the current verified state and update this handbook and the AI manual after each material change.
