# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.3  
**Date:** 16 September 2026  
**Purpose:** Maintain a living record of the TradeFlow build, verified security boundaries, business-domain audit progress, implementation evidence and the exact stopping point for future work.

## Authority
This register is based on the original clean SaaS build plan, the Buy/Sell SaaS Extraction Register v1.6, retained project decisions, current GitHub code, current Supabase state and verified test-lab behaviour. Uninspected connections are marked **AMBER** or **Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → tenant customers**

Tenant roles remain exactly `owner`, `admin`, `staff`. **Platform Owner is a separate platform-level security boundary and is not a tenant role.**

## Current platform state
- GitHub repository: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase project: `TradeFlow`, ref `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Supabase recorded health checkpoint: ACTIVE_HEALTHY.
- Public-table checkpoint: RLS enabled across all 60/60 recorded public tables.
- Platform Owner account has been provisioned through the trusted administrative path and the platform-owner boundary is no longer an unprovisioned foundation.
- Test tenants remain development/test fixtures and must not be treated as the production onboarding model.

## Master roadmap

| # | Domain | Status | Current evidence / next audit |
|---|---|---|---|
| 1 | Tenant & identity foundation | AMBER at production onboarding boundary | Tenant-first model, memberships, roles, permissions and RLS implemented. Production onboarding must replace/harden the development authenticated tenant-insert/test-lab paths. |
| 2 | Subscription plans & capability gating | GREEN | Plans, `plan_features`, `tenant_subscriptions` and capability guards implemented. Buying and Selling customer subscription tests recorded 17/17. |
| 3 | Dynamic categories, fields & options | AMBER | Schema and dynamic validation inspected. Select/multiselect option enforcement is now authoritative inside Buying submission. Full category management/UI workflow remains to be audited. |
| 4 | Customers & addresses | GREEN | Customer model and guarded RPCs verified; Customer Test Lab 34/34 at the recorded checkpoint. |
| 5 | Buying requests/items & dynamic values | BLUE | Core customer submission, dynamic-value validation and request/item workflow authority have been hardened and transactionally tested through migrations 049–051. Persistent UI end-to-end workflow is not yet verified. |
| 6 | Media metadata & storage access | AMBER | Exact live implementation, object paths, ownership and published/private access require audit. |
| 7 | Trading Value & valuation rules | AMBER | Domain/schema and guards require complete authority, calculation, permissions and workflow audit. **Next business-domain audit.** |
| 8 | Offers & offer events | AMBER | Guarded customer actions exist; offer lifecycle, expiry, response and event authority remain to be audited. |
| 9 | Acquisition & acquisition items | AMBER | Domain present; acceptance-to-acquisition, receipt, inspection, payment and inventory creation lifecycle remains to be audited. |
| 10 | Fulfilment | AMBER | Boundary tested; operational workflow audit remains. |
| 11 | Inventory | AMBER | Full live trace not completed. |
| 12 | Selling/listings | AMBER | Channel/listing lifecycle audit remains. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete order workflow audit remains. |
| 14 | Returns | AMBER | Full lifecycle audit remains. |
| 15 | Finance/payment | AMBER | Provider-neutral architecture exists; live implementation, authority and reconciliation audit remains. |
| 16 | Notifications/email | AMBER | Exact implementation/provider integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Staff security lab 19/19 passed and role/permission mapping inspected. Complete management UI/workflow remains to be traced. |
| 18 | Premium staff messenger | RED / future module | No verified core implementation. |
| 19 | Public storefront | AMBER | Published read model, tenant resolution and publication workflow require audit. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple authoritative guards/RPCs verified. Buying workflow authority has now been hardened; system-wide RLS, grants, RPC and workflow audit remains. |
| 21 | Platform Owner & Platform Administration | BLUE | Separate platform membership boundary and guards implemented through migrations 044–048. Platform Owner provisioning and tenant-administration path have been exercised; final live UI regression and complete platform administration workflow still require verification. |

## Verified security checkpoints
- Customer A subscription guard: **17/17 PASS**.
- Customer B subscription guard: **17/17 PASS**.
- Customer tenant-isolation lab: **34/34 PASS**.
- Staff security lab: **19/19 PASS**.
- RLS enabled across the recorded 60/60 public-table checkpoint.
- Customer subscription guard hardening through migration 043.
- Platform-owner security foundation through migrations 044–045.
- Platform-admin privileged provisioning/read guards through migrations 046–048.

## Platform Owner boundary — updated 16 September 2026
Migrations **044** and **045** implement the platform-owner security boundary:
- `public.platform_memberships` is separate from tenant memberships.
- Platform membership has controlled status and a unique authenticated `user_id`.
- RLS is enabled and no client insert/update/delete path is exposed.
- `private.is_platform_owner()` checks explicit active platform membership.
- `private.require_platform_owner()` and `private.has_platform_owner_access()` are restricted guards bound to the current authenticated identity.

The Platform Owner has since been provisioned through the trusted administrative path. Platform administration RPCs and tenant creation were exercised using the platform-owner boundary. A later Platform Administration UI issue was traced to the HTTP method used for a volatile PostgREST function; the client was repaired to use **POST** for the affected RPCs. Final regression verification of the repaired browser flow remains part of the platform-admin verification queue.

## Platform Administration implementation notes
- Platform Administration page: `platform-admin.html`.
- Client controller: `platform-admin.js`.
- Current client uses the dedicated platform-admin publishable key/session storage and signs the Platform Owner into Supabase Auth.
- Privileged tenant listing and user/tenant provisioning calls use POST because the underlying PL/pgSQL functions are VOLATILE under PostgREST semantics.
- Access-denied responses are surfaced as `Platform Owner access required` rather than exposing privileged data.
- Platform-admin tenant creation was previously verified at database level and through the intended privileged path.

## Production onboarding finding — still open
The original tenant foundation still exposes an authenticated tenant insertion path with `with check (true)`, and temporary test-lab onboarding functions exist. These must not become public SaaS onboarding.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial tenant owner → subscription assignment → tenant owner/admin/staff management.**

Do not create a `platform_owner` tenant role and do not permit self-claiming platform ownership.

## Buying domain audit — migrations 049–051
### Migration 049 — `harden_buying_dynamic_option_validation`
`customer_submit_buying_request` now validates dynamic select/multiselect values against active `category_field_options` for the relevant category field. Invalid select values and invalid multiselect members are rejected inside the authoritative database function rather than relying on browser validation.

A transactional test demonstrated the previous defect: an invalid select value could be accepted before the repair. After migration 049, the invalid value is rejected and a valid submission succeeds. Tests were rolled back so no test data was left behind.

### Migration 050 — `harden_buying_workflow_transitions`
`transition_workflow_entity` now supports `buying_request` and `buying_item` with the `buying.manage` permission and `module.buying` capability. The supported progression is:

```text
Buying Request: draft → submitted → under_review → valued → offer_ready → closed
Buying Item:    draft → submitted → under_review → valued → offer_ready → closed
```

The function updates the authoritative business record and records the workflow transition.

### Migration 051 — `record_buying_submission_workflow_events`
`customer_submit_buying_request` now records the initial `draft → submitted` workflow event for the buying request and every submitted buying item, with metadata identifying `source: customer_portal`.

Transactional verification proved that submission events are recorded and that request/item transitions through `submitted → under_review → valued` work through the authoritative workflow function. Tests were rolled back.

## Business-domain audit method
For every domain, trace and record:
**User action → page → JavaScript/controller → Supabase call → RPC/query → database table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a domain GREEN merely because its tables or functions exist. Where persistent domain records do not exist in the test tenants, use transactional rollback tests for database authority and clearly mark UI/business-flow verification as outstanding.

## Deliberately outside the generic core
GearCashOut specialist catalogue, evidence/research, AI research queue and specialist pricing structures remain outside the generic TradeFlow core unless later added as explicit modules.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md` — master build and verification register.
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` — Human/Developer System Handbook.
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` — AI continuity and operating manual.

These documents are living records. A material change is not closed until implementation evidence, test result, live verification state and the stopping point are captured.

## Current stopping point — 16 September 2026
The verified customer security/subscription layer remains intact. Tenant role boundaries are inspected. Platform Owner security and privileged administration foundations are implemented and the Platform Owner has been provisioned. Production tenant onboarding remains open and must be hardened before public SaaS onboarding.

The Buying domain has now been materially hardened through migrations **049–051** and transactionally verified. No persistent test business data was created by these audit tests.

**Next technical/business-domain audit:**
**Trading Value → valuation rules → authoritative valuation workflow → Offers → Acquisition.**

Do not skip ahead to later domains until the current audit evidence is captured. Do not modify GearCashOut production as part of TradeFlow work.
