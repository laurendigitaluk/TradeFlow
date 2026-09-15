# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.0  
**Date:** 15 September 2026  
**Purpose:** Reconcile the original clean SaaS build plan with the current TradeFlow implementation and verified testing.

## Authority

This register is based on the project build plan, the Buy/Sell SaaS Extraction Register v1.6 (14 September 2026), retained project decisions, and the current GitHub/Supabase/test-lab checkpoint. It does not invent implementation details. Where a connection has not yet been inspected, it is marked **AMBER — audit required**.

**Status meanings**
- **GREEN — Verified:** implemented and live-tested.
- **AMBER — Audit required:** known/planned or partly present, but the complete live implementation is not yet traced and verified.
- **BLUE — Partial:** some implementation exists but the complete planned system is not finished.
- **RED — Not yet built:** planned but no verified implementation recorded.
- **OUTSIDE CORE:** deliberately excluded from the generic TradeFlow core.

## Architecture baseline

TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary. Subscriber businesses are tenants; tenant staff are authorised through tenant memberships and roles; tenant customers are separate customer identities/data belonging to that tenant. Subscription capabilities belong to the tenant. Public storefront access must resolve to a tenant and expose only published records.

### Role hierarchy to preserve

**TradeFlow platform → subscriber tenant → tenant owner/admin/staff → tenant customers**

The current database role catalogue contains `owner`, `admin`, and `staff`. A separate TradeFlow platform-owner implementation must be verified against the original plan before being assumed complete.

## Master roadmap

| # | Domain | Status | Current evidence / next audit |
|---|---|---|---|
| 1 | Tenant & identity foundation | GREEN | Tenant-first model, memberships, roles, permissions and RLS implemented. Security labs verify tenant isolation. |
| 2 | Subscription plans & capability gating | GREEN | Plans, plan_features, tenant_subscriptions and capability guards implemented. Buying and Selling customer subscription tests both pass 17/17. |
| 3 | Dynamic categories, fields & options | AMBER | Domain model is defined; full live workflow audit still required. |
| 4 | Customers & addresses | GREEN | Customer model and guarded RPCs implemented. Customer Test Lab passes 34/34 for the tested tenant/isolation boundary. |
| 5 | Buying requests/items & dynamic values | AMBER | Core architecture and guarded RPCs exist; full end-to-end buying workflow audit remains. |
| 6 | Media metadata & storage access | AMBER | Media architecture is defined; exact live implementation and storage path still require audit. |
| 7 | Trading Value & valuation rules | AMBER | Trading Value domain and subscription guard exist; complete valuation workflow requires end-to-end audit. |
| 8 | Offers & offer events | AMBER | Guarded customer actions exist; complete offer lifecycle requires audit. |
| 9 | Acquisition & acquisition items | AMBER | Domain is present in the security model; receipt/inspection/payment lifecycle requires audit. |
| 10 | Fulfilment | AMBER | Customer subscription boundary tested; complete operational fulfilment workflow requires audit. |
| 11 | Inventory, movements, costs & inspections | AMBER | Planned core domain; full live trace not yet completed. |
| 12 | Selling channels & listings | AMBER | Planned core domain; storefront/channel lifecycle requires audit. |
| 13 | Retail orders & order items | AMBER | Customer security boundary tested; complete selling/order workflow requires audit. |
| 14 | Returns & resolutions | AMBER | Buying-side and retail-side distinction is established; full lifecycle requires audit. |
| 15 | Finance, ledger & payment records | AMBER | Finance domain is planned; payment architecture is provider-neutral. Full live implementation requires audit. |
| 16 | Notifications & email | AMBER | Notification abstraction is planned; exact TradeFlow implementation and provider integration require audit. |
| 17 | Staff roles, permissions & audit | GREEN for tested boundary; AMBER for complete workflow | Staff security lab previously passed 19/19. Full management/audit workflow still needs tracing. |
| 18 | Premium staff messenger | RED / future module | Planned for Business tier; no verified core implementation recorded. |
| 19 | Public storefront read model | AMBER | Architecture is defined; live published-read implementation requires audit. |
| 20 | Authoritative workflow RPCs/services + final RLS/grant verification | BLUE | Several authoritative RPCs and guards are implemented and verified; complete system-wide verification remains. |

## Security checkpoints already verified

- Customer A / Buying subscription guard: **17/17 PASS**.
- Customer B / Selling subscription guard: **17/17 PASS**.
- Customer tenant-isolation/security lab: **34/34 PASS** at the current checkpoint.
- Staff security lab: **19/19 PASS** at the current checkpoint.
- RLS is enabled across the recorded public-table checkpoint.
- Subscription guard hardening was completed through migration 043.

## Deliberately outside the generic core

The following GearCashOut-specific machinery is not to be copied into the TradeFlow core merely because it exists in the reference system:

- specialist Quote Catalogue structures;
- retailer/evidence research tables;
- AI research queues/candidates;
- specialist catalogue pricing structures;
- GearCashOut-specific product/condition structures.

These may later return as optional TradeFlow modules such as Market Intelligence or AI-assisted services, behind separate service/module boundaries.

## Required next audit sequence

1. Platform owner / platform administration boundary.
2. Tenant owner/admin/staff permissions and management workflow.
3. Dynamic categories and fields.
4. Complete Buying workflow.
5. Trading Value and valuation workflow.
6. Offers and customer response.
7. Acquisition, receipt, inspection, payment and inventory creation.
8. Inventory and Selling/listings.
9. Retail orders, fulfilment and returns.
10. Finance/payment records.
11. Notifications/email.
12. Public storefront and published read model.
13. Media/storage implementation.
14. Final system-wide RLS, grants, RPC and integration audit.

## Documentation rule

For each audited system record:

**User action → page → front-end controller → Supabase call → database object → trigger/function/RLS → status transition → external integration → visible result → verification state.**

Every material change must update the relevant human/developer documentation, AI continuity documentation, structured project-memory/checkpoint record where available, and verification status.

## Current stopping point

The customer subscription boundary is verified in both directions. Do not alter that layer without a new defect. The next technical audit is the platform-owner and tenant-role boundary, followed by the first AMBER business workflow in the sequence above.
