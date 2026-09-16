# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 2.3  
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
- Selling/listing hardening: 061.
- Retail order hardening: 062.
- Fulfilment/returns hardening: current live migration.

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage`, `orders.view/manage`, `fulfilment.view/manage`, `returns.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing and subscriber build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, buying request submission, offer Accept/Refuse, subscriber Buying, Acquisition, Inventory, Finance, Selling/Listings, Orders, Fulfilment and Returns workspaces.

These are implementation milestones. They are not GREEN until authenticated browser journeys are persistently tested.

## 7. Buying → Valuation → Offer
049–051 harden dynamic options and Buying workflow. 052–055 harden valuation/offer RLS, same-item valuation binding and state entry. Published offers require an approved valuation for the same tenant and buying item.

## 8. Acquisition
056–057 harden acquisition access and status entry. Lifecycle authority is `accepted → awaiting_item → received → inspection → finalised → paid → completed`, with cancellation branches as supported.

Inventory creation from an acquisition item is an explicit operation; it is not inferred from acquisition status.

## 9. Inventory
058 removes broad legacy access and protects inventory status entry. `inventory-dashboard.html` / `.js` lists tenant assets, filters status, edits non-status details and routes lifecycle changes through `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 10. Finance
059 applies permission-bound access to `payment_records` and `ledger_entries`. 060 extends `transition_workflow_entity()` to payment and ledger status transitions and adds status-entry guards.

Finance workspace creates payment/ledger records in `pending` and routes status changes through the workflow RPC. No automatic payment or ledger creation is inferred from acquisition status.

## 11. Selling / Listings
061 hardens `listings`, `listing_events` and `sales_channels` to subscription/permission-aware policies and protects listing status entry with `guard_listing_status_entry()`.

`selling-dashboard.html` / `.js` loads active channels, selling-enabled categories and tenant inventory at `ready_for_sale`; it creates listings in `draft`, advances them to `ready`, and exposes the authoritative listing lifecycle.

Direct listing status PATCH is deliberately not used.

## 12. Retail Orders
062 hardens `retail_orders` and `retail_order_items` to `orders.view/manage` plus `module.orders`. Retail order trade-in rows additionally require `module.trade_in`. Direct retail-order status changes are blocked by `guard_retail_order_status_entry()`.

Subscriber Orders creates an `initiated` order from a published listing, creates its linked order item and advances it to `pending_payment`.

Customer checkout is backed by `customer_get_store_listings()` and `customer_create_retail_order()`. An authenticated active customer may buy only a currently published listing; checkout creates a `pending_payment` order and linked item, reserves the listing and records workflow transitions. Payment collection remains open.

## 13. Fulfilment
Fulfilment retains subscription-aware access through `fulfilment.view/manage` plus `module.fulfilment`. The new `fulfilment-dashboard.html` / `.js` creates fulfilment records for paid/fulfilment orders and exposes controlled status progression through `transition_workflow_entity()`.

Lifecycle authority:
**awaiting → label → dispatched → delivered**, with dispatched/delivered → returned.

Direct fulfilment status edits are blocked by `guard_fulfilment_status_entry()`. No carrier API, shipping-label provider or automatic fulfilment creation is assumed.

## 14. Returns
Returns legacy broad member/admin policies have been removed. Subscription-aware returns policies are now authoritative, requiring `returns.view/manage` and either the buying or orders capability as defined by the live policies. Direct return status edits are blocked by `guard_return_status_entry()`.

`customer_request_return()` now validates the authenticated active customer against the tenant and order item, and permits retail return requests only where the customer's order is `paid`, `fulfilment` or `completed`. Requests enter `requested` and are recorded in workflow history.

Return lifecycle authority:
**requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed**.

`returns-dashboard.html` / `.js` provides the subscriber operational review and status controls. Customer-facing return display/actions remain a UI follow-up item.

## 15. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states are **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 16. Manual testing
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 17. Documentation/change control
After each material change record what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 18. Current stopping point — 16 September 2026
Operational path now reaches **Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer checkout → Fulfilment → Returns**.

Fulfilment and Returns are **BLUE / Implemented, browser verification open**. Customer-facing return actions/display, payment integration, carrier integration, production onboarding and persistent browser verification remain tracked open items.

**Next build action:** finish customer return visibility/actions, then payment integration and persistent browser verification.