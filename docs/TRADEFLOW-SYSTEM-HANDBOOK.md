# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 2.0  
**Date:** 16 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose and authority
This handbook records TradeFlow architecture, security boundaries, workflow rules, implementation decisions, faults, lessons and exact build position.

Authority order: **current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour**. A Git commit is implementation evidence, not proof of live behaviour.

## 2. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant boundary.

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level boundary and is never a tenant role. GearCashOut is reference material only and must never be modified during TradeFlow work.

## 3. Security checkpoints
- Customer isolation/security: **34/34 passed**.
- Customer subscription tests: **Buying 17/17; Selling 17/17 passed**.
- Staff security lab: **19/19 passed**.
- Recorded RLS checkpoint: **60/60 public tables enabled**.
- Platform Owner foundation: 044–045.
- Platform-admin privileged paths: 046–048; final browser regression remains open.
- Buying hardening: 049–051.
- Valuation/Offer hardening: 052–055.
- Acquisition hardening: 056–057.
- Inventory hardening: 058.
- Finance permission/workflow hardening: 059–060.

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, buying request submission, offer Accept/Refuse, subscriber Buying, Acquisition, Inventory, Finance and now Selling/Listings workspaces.

These are implementation milestones. They are not GREEN until authenticated browser journeys are persistently tested.

## 7. Buying → Valuation → Offer
049–051 harden dynamic options and Buying workflow. 052–055 harden valuation/offer RLS, same-item valuation binding and state entry. Published offers require an approved valuation for the same tenant and buying item.

## 8. Acquisition
056–057 harden acquisition access and status entry. Lifecycle authority is:
`accepted → awaiting_item → received → inspection → finalised → paid → completed`, with cancellation branches as supported.

Inventory creation from an acquisition item is an explicit operation; it is not inferred from acquisition status.

## 9. Inventory
058 removes broad legacy access and protects inventory status entry. `inventory-dashboard.html` / `.js` lists tenant assets, filters status, edits non-status details and routes lifecycle changes through `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 10. Finance
059 applies permission-bound access to `payment_records` and `ledger_entries`. 060 extends the central workflow authority to payment and ledger status transitions and adds status-entry guards.

Finance workspace creates payment/ledger records in `pending` and routes status changes through the central workflow RPC. No automatic payment or ledger creation is inferred from acquisition status.

## 11. Selling / Listings — NEW IMPLEMENTATION
The dedicated `selling-dashboard.html` / `selling-dashboard.js` workspace is now implemented.

It:
- lists tenant-scoped listings and filters by status;
- loads active tenant sales channels;
- loads active tenant categories where `selling_enabled=true`;
- offers only tenant inventory currently at `ready_for_sale` when creating a listing;
- creates listings in `draft`, then advances them to `ready` through `transition_workflow_entity()`;
- supports `ready → published`, `published → reserved/sold/delisted`, and `reserved → published/sold/delisted` through the same authoritative RPC;
- displays listing detail and linked inventory/channel/category information.

The live database confirms subscription/permission-aware RLS for `listings`, `listing_events` and `sales_channels`, plus the `listing` transitions in the central workflow authority.

Direct listing status PATCH is deliberately not used.

## 12. Selling → Orders → Fulfilment → Returns
The next operational build is retail orders/customer checkout using the existing `retail_orders`, `retail_order_items`, `retail_order_trade_ins`, fulfilment and returns schema. Do not invent automatic handoffs not established by the live database.

## 13. Diagnostic and verification standard
Trace every domain as:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states are **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 14. Manual testing
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 15. Documentation/change control
After each material change record what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 16. Current stopping point — 16 September 2026
Operational path now reaches:
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing.**

Selling/Listings is **BLUE / Implemented, browser verification open**. Production onboarding and persistent browser verification remain tracked open items.

**Next build action:** retail orders/customer checkout, followed by fulfilment and returns.