# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 2.9  
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
- External payment boundary: `add_external_payment_webhook_authority` plus correction migration; Edge Functions deployed for Stripe Checkout and webhook handling.

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

Finance workspace creates payment/ledger records and routes status changes through the workflow RPC. No automatic payment or ledger creation is inferred from acquisition status.

`record_retail_order_payment()` provides the internal subscriber-controlled payment capture path. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`, locks a `pending_payment` order, requires payment equal to current `amount_due`, creates a paid inbound payment record and matching posted ledger credit, clears amount due and advances the order to `paid`. This remains a manual/internal payment path.

`customer_create_order_payment()` provides the customer-side pending payment-record/idempotency boundary. It validates the authenticated customer owns the `pending_payment` order, reuses an active pending/processing attempt, and permits a fresh payment record after a failed attempt.

The external Stripe boundary is implemented in Supabase Edge Functions. `create-stripe-checkout-session` requires a customer JWT and creates the Stripe Checkout Session server-side using `STRIPE_SECRET_KEY`; browser code never receives the Stripe secret. `stripe-payment-webhook` has JWT verification disabled because Stripe webhooks do not carry a TradeFlow user JWT; it instead verifies the `stripe-signature` using `STRIPE_WEBHOOK_SECRET` before calling the protected `process_external_payment_event()` database function.

`payment_provider_events` provides provider/event idempotency. `process_external_payment_event()` validates tenant/payment identity, provider payment ID, amount and currency, records payment workflow history, updates the payment state and, on a confirmed paid retail order, updates the order to `paid` and creates the corresponding posted ledger credit.

### Stripe test configuration checkpoint — 16 September 2026
TradeFlow has a dedicated Stripe Sandbox within the existing Stripe account. The active TradeFlow Payment Webhook listens for the required checkout/payment events. The two Stripe test secrets are configured server-side and are not stored in browser code, GitHub, documentation or project memory.

Configuration is complete for the Stripe test environment, but persistent customer browser payment verification remains open.

## 11. Selling / Listings
061 hardens listings and related access; selling creates listings from ready-for-sale inventory and uses workflow authority for status changes.

## 12. Retail Orders
062 hardens retail order access and status entry. Subscriber Orders creates an order from a published listing and advances it to pending payment. Customer checkout creates a pending-payment order, reserves the listing and uses the external Stripe boundary for payment.

## 13. Fulfilment
Fulfilment retains subscription-aware access and controlled lifecycle progression. No carrier API or automatic fulfilment creation is assumed. Customer visibility uses secure `customer_get_fulfilments()`.

## 14. Returns
Returns legacy broad policies have been removed and direct status edits are blocked. `customer_request_return()` validates customer ownership and eligible order states. Customer visibility uses secure `customer_get_returns()`.

## 15. Customer dashboard browser repair
The persistent browser test exposed two browser-layer faults: Sign in initially produced no visible response, and the navigation controller intercepted hashes while the portal was hidden. Navigation was corrected to leave native hash navigation available until authentication succeeds.

The dashboard HTML now contains an inline capture-phase Supabase Auth fallback using only the public publishable key. The earlier reload-based session handoff failed because reload returned to the authentication panel. The later in-page handoff removed the reload and then removed an unnecessary `/auth/v1/user` request from the successful-auth path.

The latest repair also changes the dashboard script cache-buster to `customer-dashboard.js?v=9` and makes the inline fallback immediately reveal `#portal` after a successful password-token exchange. It then hands the session to `window.tradeflowHandleCustomerAuthSuccess`. If the main controller is unavailable, the fallback now reports that explicitly rather than leaving the user indefinitely on “Signing in. Loading your customer portal…”.

Latest commits:
- dashboard HTML/auth fallback/cache repair: `bfda2436b9cbf1fdd96e313e3715cc07410553cc`
- main controller handoff: `b3fea037f6e9164e29f45171e6333c4318f8e78d`
- navigation repair: `8c84b2ae8c9c666f92e7dea51a92af9e170e03ad`

No service-role credential is exposed in browser code.

**Verification state:** Implemented in GitHub; persistent live browser confirmation remains open.

## 16. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states are **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 17. Manual testing
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 18. Documentation/change control
After each material change record what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 19. Current stopping point — 16 September 2026
The latest customer dashboard repair is deployed to GitHub. The HTML now forces a fresh `customer-dashboard.js?v=9` load and the inline successful-auth path immediately hides the authentication panel and reveals the portal. Persistent live browser confirmation is still required. External payment architecture is BLUE / Implemented, with Stripe Sandbox configuration complete and persistent payment verification still open. Shipping-provider integration and production onboarding remain open.

**Next build action:** hard-refresh the deployed customer dashboard, sign in with the existing Test Business A customer, confirm the authentication panel disappears and the portal loads. If it does, continue Shop → Buy → Stripe Sandbox payment and verify the signed webhook updates payment/order/ledger state.