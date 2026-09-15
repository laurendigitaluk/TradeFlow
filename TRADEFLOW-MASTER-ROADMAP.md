# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.2  
**Date:** 15 September 2026  
**Purpose:** Reconcile the original clean SaaS build plan with the current TradeFlow implementation and verified testing.

## Authority
This register is based on the project build plan, the Buy/Sell SaaS Extraction Register v1.6, retained decisions, and current GitHub/Supabase/test-lab state. Uninspected connections are marked AMBER.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partial; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → tenant customers**

Tenant roles remain exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level boundary.

## Master roadmap

| # | Domain | Status | Current evidence / next audit |
|---|---|---|---|
| 1 | Tenant & identity foundation | AMBER at onboarding boundary | Tenant-first model, memberships, roles, permissions and RLS implemented. Tenant role boundary audited. Authenticated tenant INSERT remains unsuitable as final production onboarding. |
| 2 | Subscription plans & capability gating | GREEN | Plans, plan_features, tenant_subscriptions and capability guards implemented; Buying and Selling customer subscription tests recorded 17/17. |
| 3 | Dynamic categories, fields & options | AMBER | Domain defined; full live workflow audit required. |
| 4 | Customers & addresses | GREEN | Customer model and guarded RPCs; Customer Test Lab 34/34 at checkpoint. |
| 5 | Buying requests/items & dynamic values | AMBER | Core architecture exists; end-to-end workflow audit remains. |
| 6 | Media metadata & storage access | AMBER | Exact live implementation/storage path requires audit. |
| 7 | Trading Value & valuation rules | AMBER | Domain/guard exists; complete workflow requires audit. |
| 8 | Offers & offer events | AMBER | Guarded customer actions exist; lifecycle audit remains. |
| 9 | Acquisition & acquisition items | AMBER | Domain present; receipt/inspection/payment lifecycle audit remains. |
| 10 | Fulfilment | AMBER | Boundary tested; operational workflow audit remains. |
| 11 | Inventory | AMBER | Full live trace not completed. |
| 12 | Selling/listings | AMBER | Channel/listing lifecycle audit remains. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete workflow audit remains. |
| 14 | Returns | AMBER | Full lifecycle audit remains. |
| 15 | Finance/payment | AMBER | Provider-neutral architecture; live implementation audit remains. |
| 16 | Notifications/email | AMBER | Exact implementation/provider integration audit remains. |
| 17 | Staff roles/permissions/audit | GREEN for tested boundary; AMBER for complete workflow | Staff security lab 19/19; database mapping inspected; management workflow remains. |
| 18 | Premium staff messenger | RED / future module | No verified core implementation. |
| 19 | Public storefront | AMBER | Published read model requires audit. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Several guards/RPCs verified; system-wide audit remains. |

## Security checkpoints
- Customer A subscription guard: 17/17 PASS.
- Customer B subscription guard: 17/17 PASS.
- Customer tenant-isolation lab: 34/34 PASS.
- Staff security lab: 19/19 PASS.
- RLS enabled across the recorded public-table checkpoint.
- Subscription guard hardening through migration 043.

## Platform Owner boundary — 15 September 2026
Migrations **044** and **045** now implement the platform-owner security foundation:
- `public.platform_memberships` is separate from tenant memberships.
- RLS is enabled; no client write policy is exposed.
- `private.is_platform_owner()` checks explicit active platform membership.
- `private.require_platform_owner()` and `private.has_platform_owner_access()` are restricted guards bound to the current authenticated identity.

Live verification shows the new platform membership table currently has **zero rows**. Therefore the foundation is **Implemented**, but platform-owner provisioning and live UI verification remain outstanding.

## Production onboarding finding
The original tenant foundation still exposes authenticated tenant insertion with `with check (true)`, and temporary test-lab onboarding functions exist. These must not become public SaaS onboarding.

Required production sequence:
**Platform Owner / approved onboarding → tenant creation → initial tenant owner → subscription assignment → tenant owner/admin/staff management.**

Do not create a `platform_owner` tenant role and do not permit self-claiming platform ownership.

## Deliberately outside the generic core
GearCashOut specialist catalogue, evidence/research, AI research queue and specialist pricing structures remain outside the generic TradeFlow core unless later added as explicit modules.

## Documentation
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md` — Human/Developer handbook, version 1.1.
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md` — AI continuity base, version 1.1.

Required traceability:
**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification state.**

Every material change updates the relevant documentation and checkpoint.

## Current stopping point
The customer security/subscription layer remains verified and untouched. Tenant role permissions are inspected. Platform-owner foundation is implemented but unprovisioned. The next technical step is trusted provisioning of the platform-owner identity, followed by authoritative production tenant onboarding and full tenant owner/admin/staff management verification. Only then continue to the next AMBER business domain.
