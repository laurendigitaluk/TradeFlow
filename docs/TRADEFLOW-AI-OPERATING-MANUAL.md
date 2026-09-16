# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 2.6  
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
- Do not invent `module.finance`; finance uses permission checks and the live capability model actually present.

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
- Hardening sequence through Retail Orders: 044–062, followed by fulfilment/returns hardening and external payment boundary migrations.

## 6. Production onboarding remains OPEN
Development tenant insertion/test-lab onboarding remains separate from the required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Current operational chain
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer checkout → External Payment → Fulfilment → Returns.**

The acquisition-to-finance/inventory handoff remains deliberately explicit because live inspection did not establish automatic status-driven creation of payment, ledger or inventory records.

## 8. Inventory checkpoint — 058
Inventory status entry is protected by `guard_inventory_asset_status_entry()` and must use `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 9. Finance checkpoint — 059–060 plus external payment boundary
059 applies permission-bound access to payment and ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards.

Finance UI creates payment/ledger records and uses the workflow authority for status changes. No `module.finance` feature is to be invented.

`record_retail_order_payment()` provides the internal subscriber-controlled payment capture path. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`; locks a `pending_payment` retail order; requires payment equal to current `amount_due`; creates an inbound paid payment record and matching posted ledger credit; clears amount due and advances the order to `paid`. This is not an external gateway.

`customer_create_order_payment()` provides the customer-side pending payment-record/idempotency boundary. It validates the authenticated customer owns the pending order, reuses an active pending/processing attempt, and permits a fresh payment record after a failed attempt.

The external payment boundary is implemented with two deployed Supabase Edge Functions:
- `create-stripe-checkout-session`: JWT-protected; validates the authenticated customer's order access, creates/reuses the pending payment record, generates an attempt-specific Stripe idempotency key, reuses an already-open Stripe Checkout Session where possible, otherwise creates a new Stripe Checkout Session server-side, and stores the Stripe session ID against the payment record. It requires the server-side `STRIPE_SECRET_KEY`.
- `stripe-payment-webhook`: JWT verification is deliberately disabled because Stripe webhooks do not carry a TradeFlow user JWT. The function verifies the `stripe-signature` using `STRIPE_WEBHOOK_SECRET` and then calls the protected `process_external_payment_event()` database function.

The database contains `payment_provider_events` for provider/event idempotency and `process_external_payment_event()` for provider-to-TradeFlow state reconciliation. The reconciliation function validates tenant/payment identity, provider payment ID, amount and currency, records payment workflow history, updates payment status and, for a confirmed paid retail order, marks the order paid and creates the matching posted ledger credit.

### Stripe test configuration checkpoint — 16 September 2026
TradeFlow now has a dedicated Stripe Sandbox within the existing Stripe account. The active **TradeFlow Payment Webhook** listens for `checkout.session.completed`, `checkout.session.async_payment_succeeded`, `payment_intent.succeeded` and `payment_intent.payment_failed`.

The TradeFlow Supabase Edge Function environment has both Stripe test credentials configured: the server-side Stripe test secret and the webhook signing secret. Secret values are not stored in browser code, GitHub, documentation or project memory.

The retry hardening was added after inspection showed the previous checkout function reused one order-wide idempotency key. The database RPC now reuses active pending/processing attempts but does not let a failed attempt block a new attempt. The checkout Edge Function version 5 generates a fresh attempt-specific Stripe idempotency key and reuses an already-open checkout session when possible. This is intended to prevent both failed-attempt lockout and duplicate active checkout sessions.

Configuration is complete for the Stripe test environment, but no persistent customer browser payment has yet been verified. External payment therefore remains **BLUE / Implemented, verification open**.

## 10. Selling/Listings checkpoint — 061
Selling workspace is implemented against the live schema. It loads active channels, selling-enabled categories and `ready_for_sale` inventory, creates draft listings, advances them to ready and uses the central workflow for subsequent listing lifecycle changes.

## 11. Retail Orders checkpoint — 062
Subscriber Orders and customer checkout are implemented. Customer checkout requires an authenticated active customer, accepts only a published listing, creates a pending-payment order and linked item, reserves the published listing and records workflow transitions. Subscriber-recorded payment advances an order to paid and creates its finance records transactionally. External customer payment now has a server-side Stripe Checkout boundary and signed webhook reconciliation path.

## 12. Fulfilment checkpoint
Live inspection confirmed fulfilment has subscription-aware `fulfilment.view/manage` access and an existing central workflow. `fulfilment-dashboard.html` / `.js` provides subscriber creation and lifecycle controls.

Lifecycle authority: `awaiting → label → dispatched → delivered`, with dispatched/delivered → returned.

`guard_fulfilment_status_entry()` prevents direct client status edits. No carrier API, shipping-label provider or automatic fulfilment creation is assumed. Customer visibility uses `customer_get_fulfilments()`.

## 13. Returns checkpoint
Returns had overlapping legacy member/admin policies. These were removed so the subscription-aware returns policies are authoritative. `guard_return_status_entry()` prevents direct client status edits.

`customer_request_return()` requires an authenticated active customer belonging to the tenant, with an eligible order item and an order in `paid`, `fulfilment` or `completed`. The request enters `requested` and is recorded in workflow history. Customer visibility uses `customer_get_returns()` and the customer dashboard exposes return actions.

Return lifecycle authority: `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

## 14. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**.

## 15. Manual UI testing
One manual test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 16. Change-control and memory
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. Do not invent memory tables, columns or records.

## 17. Current stopping point — 16 September 2026
External payment architecture is **BLUE / Implemented, verification open**. The TradeFlow Stripe Sandbox, active webhook, two server-side Stripe test secrets, retry hardening and deployed Edge Functions are in place. Persistent browser payment verification remains open. Shipping-provider integration and production onboarding remain open.

**Next safe action:** run one persistent customer checkout/payment journey using a Stripe Sandbox test payment, verify the signed webhook updates the payment/order/ledger state, then continue into fulfilment and returns browser verification.