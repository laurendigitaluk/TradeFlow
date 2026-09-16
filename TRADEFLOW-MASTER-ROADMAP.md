# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.6  
**Date:** 16 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. **Platform Owner is a separate platform-level security boundary and is never a tenant role.**

## Current environment
- GitHub: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap
| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding still must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | AMBER | Buying dynamic option validation hardened; complete category/UI audit remains. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | AMBER | Exact ownership, object paths and access workflow remain to be audited. |
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and subscriber valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; workspace supports lifecycle progression and explicit inventory hand-off. |
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and controls listing lifecycle. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout and subscriber Orders workspace. Internal payment capture and external Stripe checkout boundary are implemented; persistent browser verification remains. |
| 14 | Returns | BLUE | Return-request security hardened and subscriber Returns workspace implemented; customer visibility/actions implemented. Browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening, internal payment capture, provider-payment records and external Stripe checkout/webhook boundary implemented. Stripe test secrets/webhook are now configured; persistent payment verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Fulfilment and Returns checkpoint — 16 September 2026
Migration `harden_fulfilment_returns_workflow_v2` applied live. Fulfilment retains subscription-aware `fulfilment.view/manage` access and now has a status-entry guard preventing direct client status edits. Returns legacy broad member/admin policies were removed so the subscription-aware returns policies are authoritative. Returns also has a status-entry guard.

Customer return creation is hardened through `customer_request_return()`: an authenticated active customer may request a return only for their own tenant order item and only when the order is `paid`, `fulfilment` or `completed`. The return is created in `requested` status and recorded in workflow history. Customer dashboard visibility uses the existing secure `customer_get_returns()` and `customer_get_fulfilments()` functions.

## Retail payment capture checkpoint — 16 September 2026
`record_retail_order_payment()` remains the internal subscriber-controlled payment path. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`, locks the target `pending_payment` order, requires payment equal to current `amount_due`, creates a paid inbound payment record and matching posted ledger credit, clears amount due and advances the order to `paid`.

A customer payment-intent RPC, `customer_create_order_payment()`, provides the customer-side payment-record creation/idempotency boundary. It validates the authenticated customer owns the `pending_payment` order and creates or reuses an active pending/processing payment attempt. Failed attempts no longer block a later retry.

The external Stripe boundary is implemented in Supabase Edge Functions:
- `create-stripe-checkout-session` requires a customer JWT, validates customer order ownership through `customer_get_orders()`, creates/reuses the pending payment record and creates a Stripe Checkout Session using the server-side `STRIPE_SECRET_KEY` only.
- `stripe-payment-webhook` accepts Stripe webhooks without a user JWT, verifies the Stripe signature using `STRIPE_WEBHOOK_SECRET`, and delegates event processing to `process_external_payment_event()`.
- `payment_provider_events` provides provider/event idempotency.
- `process_external_payment_event()` validates tenant/payment identity, provider payment ID, amount and currency, records payment workflow history, marks the payment paid/failed and, for a paid retail order, moves the order to `paid` and creates the matching posted ledger credit.

The customer dashboard exposes **Pay now** for `pending_payment` orders and routes the customer to the server-created Stripe Checkout Session. Provider secrets are not placed in browser code.

### Stripe test configuration checkpoint — 16 September 2026
A dedicated **TradeFlow Stripe Sandbox** has been configured in the existing Stripe account. The sandbox webhook destination **TradeFlow Payment Webhook** is active and listens for the four required events:
- `checkout.session.completed`
- `checkout.session.async_payment_succeeded`
- `payment_intent.succeeded`
- `payment_intent.payment_failed`

The TradeFlow Supabase Edge Function environment now contains the Stripe test secret and webhook signing secret. The actual secret values are never stored in GitHub, documentation or project memory.

The payment retry boundary was hardened after inspection showed the previous checkout function reused a single order-wide idempotency key. `customer_create_order_payment()` now reuses an active pending/processing attempt but permits a new payment record after a failed attempt, and `create-stripe-checkout-session` version 5 generates a fresh attempt-specific Stripe idempotency key and reuses an already-open Stripe Checkout Session when appropriate. This prevents failed attempts from blocking legitimate retries while avoiding duplicate active checkout sessions from repeated clicks.

**Important:** Stripe configuration is now complete for the test environment, but no persistent browser payment has yet been verified. External payment therefore remains **BLUE / Implemented, verification open** until the customer checkout, Stripe test payment, signed webhook, payment record, order transition and ledger entry are observed end-to-end.

## Selling / fulfilment operational chain
Selling creates listings from `ready_for_sale` inventory. Customer checkout creates a `pending_payment` retail order and reserves the listing. Payment can now be captured internally or routed through the external Stripe boundary. A confirmed paid order can then enter Fulfilment, followed by dispatch/delivery and return handling.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. These are not the production SaaS onboarding model.

Required sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a feature complete solely because code is committed. A transactional rollback test proves database behaviour, not a persistent browser journey.

## Deliberately outside generic core
GearCashOut specialist catalogue, evidence/research, AI research queue and specialist pricing structures remain outside TradeFlow unless explicitly added as modules.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
External payment-provider architecture is **BLUE / Implemented**. The TradeFlow Stripe Sandbox, active webhook destination, Supabase Stripe secrets, retry hardening and deployed Edge Functions are in place. Persistent browser verification remains open. Shipping-provider integration, production onboarding and the full persistent Orders → Payment → Fulfilment → Returns browser journey also remain open.

**Next build action:** perform one persistent customer checkout through Stripe Sandbox using a Stripe test payment, verify the signed webhook updates the payment/order/ledger state, then continue into fulfilment and returns verification.