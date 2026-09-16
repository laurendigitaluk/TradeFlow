# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 2.2  
**Date:** 16 September 2026  
**Project:** TradeFlow

## 1. Purpose
AI continuity companion for TradeFlow. It records architectural truth, decisions, faults, lessons, verification state and exact stopping point so future sessions resume without guessing.

## 2. Mandatory procedure
For significant work: **Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → checkpoint.**

Never rely on chat memory when current code/database state can be inspected. Never modify GearCashOut while working on TradeFlow.

## 3. Non-negotiable rules
- `tenant_id` is the primary security boundary.
- Tenant roles are exactly `owner`, `admin`, `staff`.
- Platform Owner is separate from tenant roles and cannot be self-claimed.
- Subscription capabilities belong to the tenant.
- Customer data remains tenant-isolated.
- Dynamic fields/options are database-authoritative.
- Business status changes use authoritative workflow services/RPCs where provided.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory are separate steps.
- Do not assume a schema FK means an operational workflow exists.
- Do not mark a feature complete solely because code is committed.
- Do not expose test-lab onboarding as production onboarding.
- Never store secrets in docs or project memory.

## 4. Verification states
**Proposed → Implemented → Tested → Verified Live** are separate states. A commit is not live verification. A transactional rollback test proves database behaviour, not a persistent browser journey.

## 5. Current environment checkpoint
- GitHub: `laurendigitaluk/TradeFlow`, `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, `eu-west-2`.
- Recorded health: ACTIVE_HEALTHY.
- Recorded RLS checkpoint: 60/60 public tables.
- Customer security: 34/34.
- Customer subscription tests: Buying 17/17; Selling 17/17.
- Staff security lab: 19/19.
- Hardening sequence through Retail Orders: 044–062.

## 6. Production onboarding remains OPEN
Development tenant insertion/test-lab onboarding remains separate from the required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Current operational chain
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer checkout.**

The acquisition-to-finance/inventory handoff is deliberately explicit because live inspection did not establish automatic status-driven creation of payment, ledger or inventory records.

## 8. Inventory checkpoint — 058
Inventory status entry is protected by `guard_inventory_asset_status_entry()` and must use `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

The Inventory workspace is implemented but not yet browser-verified live.

## 9. Finance checkpoint — 059–060
059 applies permission-bound access to payment and ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards.

Finance UI creates pending payment/ledger records and uses the workflow authority for status changes. No `module.finance` feature is to be invented.

## 10. Selling/Listings checkpoint — 061
The dedicated `selling-dashboard.html` / `selling-dashboard.js` workspace is implemented against the live schema.

It loads tenant listings, active sales channels, selling-enabled active categories and `ready_for_sale` inventory. It creates listings in `draft`, advances them to `ready`, and exposes the existing authoritative listing lifecycle:
`draft → ready → published → reserved/sold/delisted`.

All status changes use `transition_workflow_entity()` with entity type `listing`; direct status PATCH is not used.

## 11. Retail Orders checkpoint — 062
Migration 062 hardens `retail_orders` and `retail_order_items` to `orders.view/manage` plus `module.orders`; retail order trade-in rows additionally require `module.trade_in`. Direct retail-order status changes are blocked by `guard_retail_order_status_entry()`.

`orders-dashboard.html` / `.js` is the subscriber operational layer. Customer checkout is now also implemented through `customer_get_store_listings()` and `customer_create_retail_order()`.

Customer checkout requires an authenticated active customer for the tenant, accepts only a published listing, creates a `pending_payment` order and linked order item, reserves the listing, and records workflow transitions for the order and listing. A database trigger synchronises retail-order `payment_status` for paid/refunded terminal order states. Payment collection itself is not yet integrated.

The customer dashboard exposes Shop and My Orders. These paths are **Implemented / browser verification open**.

## 12. Next build
Continue into **fulfilment and returns**, then payment integration. Use the existing schema and central workflow authority. Do not invent automatic handoffs.

## 13. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**.

## 14. Manual UI testing
One manual test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 15. Change-control and memory
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. Do not invent memory tables, columns or records.

## 16. Current stopping point — 16 September 2026
Retail Orders now has both subscriber operational controls and an authenticated customer checkout path. Customer checkout reserves the selected published listing and creates a pending-payment order. **Browser verification remains open.** Payment integration, fulfilment/returns and production onboarding remain open.

**Next safe action:** build fulfilment and returns, then payment integration and persistent browser verification.