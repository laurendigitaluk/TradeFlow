# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 2.1  
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

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage`, `orders.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing and subscriber build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, buying request submission, offer Accept/Refuse, subscriber Buying, Acquisition, Inventory, Finance, Selling/Listings and Orders workspaces.

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
059 applies permission-bound access to `payment_records` and `ledger_entries`. 060 extends the central workflow authority to payment and ledger status transitions and adds status-entry guards.

Finance workspace creates payment/ledger records in `pending` and routes status changes through the central workflow RPC. No automatic payment or ledger creation is inferred from acquisition status.

## 11. Selling / Listings
061 hardens `listings`, `listing_events` and `sales_channels` to subscription/permission-aware policies and protects listing status entry with `guard_listing_status_entry()`.

`selling-dashboard.html` / `.js` loads active channels, selling-enabled categories and tenant inventory at `ready_for_sale`; it creates draft listings and advances them to `ready`, then exposes the authoritative listing lifecycle: `draft → ready → published → reserved/sold/delisted`, with reserved → published/sold/delisted.

Direct listing status PATCH is deliberately not used.

## 12. Retail Orders
062 hardens `retail_orders` and `retail_order_items` to `orders.view/manage` plus `module.orders`. Retail order trade-in rows additionally require `module.trade_in`. Direct retail-order status changes are blocked by `guard_retail_order_status_entry()`.

`orders-dashboard.html` / `.js` creates an `initiated` order from a published listing, creates its linked order item and advances the order to `pending_payment`. It does not automatically reserve or sell the listing because the live schema does not establish that handoff.

Order authority is `initiated → pending_payment → paid → fulfilment → completed`, with the supported cancellation/refund branches.

The current order UI is a subscriber operational layer. A complete customer checkout/payment integration remains open.

## 13. Fulfilment and returns
The existing fulfilment and returns model remains the next operational build. Use the existing central workflow authority and do not invent automatic handoffs not established by the live database.

## 14. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states are **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 15. Manual testing
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 16. Documentation/change control
After each material change record what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 17. Current stopping point — 16 September 2026
Operational path now reaches **Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order.**

Selling/Listings and Retail Orders are **BLUE / Implemented, browser verification open**. Production onboarding, customer checkout completion, fulfilment/returns and persistent browser verification remain tracked open items.

**Next build action:** fulfilment and returns, then complete customer checkout/payment integration.