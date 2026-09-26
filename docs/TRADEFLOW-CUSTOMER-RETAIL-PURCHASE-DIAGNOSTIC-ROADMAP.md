# TradeFlow Customer Retail Purchase — Developer Diagnostic Roadmap

**Status:** Living roadmap  
**Date:** 26 September 2026  
**Scope:** Test Two / Camerashack customer retail purchase flow.

## 1. User action

Customer visits the tenant's public **What We Sell** shop and selects **Buy this item**.

## 2. Front-end entry points

Public product page  
→ `customer-basket.html?tenant_id=...&listing_id=...`  
→ `customer-basket.js`  
→ canonical customer session `tradeflow_customer_session`.

The Basket is pre-order browser state. Adding an item must not create a database retail order.

## 3. Retail data path

Basket  
→ authenticated customer addresses/credit  
→ `customer_create_retail_order()`  
→ `public.retail_orders` with `pending_payment`  
→ `public.retail_order_items`  
→ `public.listings.status=reserved`  
→ payment attempt  
→ Stripe Checkout or customer credit  
→ server-side payment confirmation  
→ `retail_orders.status=paid`  
→ `listings.status=sold`  
→ `inventory_assets.status=sold`  
→ `customer_get_orders()`  
→ **My Orders**.

## 4. Pending-payment boundary

Authoritative pending-order lookup:

`customer_get_retail_order_for_checkout(p_tenant_id,p_order_id)`

Do not use `customer_get_orders()` for pending checkout validation. `customer_get_orders()` is intentionally purchase-history oriented and returns paid/fulfilment/completed retail history.

## 5. Cancellation path

Customer Basket **Cancel purchase**  
→ `customer_cancel_retail_order()`  
→ order `cancelled`  
→ listing reservation released to `published`  
→ linked reserved inventory asset released to `listed`  
→ active payment attempts cancelled  
→ no customer credit deduction.

Stripe Checkout cancellation returns to the Basket. Stripe `checkout.session.expired` is also handled server-side and releases an unpaid reservation.

## 6. Payment path

Stripe:

`create-stripe-checkout-session` version 11  
→ Stripe Checkout  
→ `stripe-payment-webhook` version 5  
→ `process_external_payment_event()`.

Customer credit:

`customer_pay_retail_order_with_credit()`

Both paths must only move a retail order to paid after actual payment confirmation.

## 7. My Sale boundary

**My Sale** is not a retail order view.

Current source:

`customer-dashboard.js` → `customer_get_selling_status()`

It reads the customer's selling-to-business `buying_requests` / `buying_items` workflow.

The Test Two Nikon COOLPIX P1100 shown in My Sale is an existing selling/trade-in record. It is not evidence that the retail order leaked into My Sale.

Do not hide or filter selling records merely to conceal this distinction.

## 8. My Orders boundary

Current source:

`customer-dashboard.js` → `customer_get_orders()`

The RPC intentionally exposes only paid/fulfilment/completed retail purchase history. Pending/unpaid retail orders must remain outside My Orders.

## 9. Supabase objects to inspect first

Tables:

- `public.retail_orders`
- `public.retail_order_items`
- `public.listings`
- `public.inventory_assets`
- `public.payment_records`
- `public.payment_provider_events`
- `public.workflow_transitions`
- `public.customer_credit_accounts`

RPCs:

- `customer_create_retail_order()`
- `customer_create_retail_order_from_basket()`
- `customer_get_retail_order_for_checkout()`
- `customer_cancel_retail_order()`
- `customer_create_order_payment()`
- `customer_pay_retail_order_with_credit()`
- `customer_get_orders()`
- `customer_get_selling_status()`
- `process_external_payment_event()`

Edge Functions:

- `create-stripe-checkout-session`
- `stripe-payment-webhook`

## 10. Known failure history

### 26 September 2026 — Pay Now failure

Root cause: Stripe checkout validation used `customer_get_orders()`, which excludes pending orders.

Repair: dedicated authenticated pending-order RPC and Edge Function update.

### 26 September 2026 — cancellation did not release product

Root cause: `customer_cancel_retail_order()` changed order state but did not release the linked listing reservation.

Repair: cancellation now restores listing availability and linked reserved inventory.

### 26 September 2026 — external payment did not complete stock lifecycle

Root cause: `process_external_payment_event()` changed the retail order to paid but did not move linked listing/inventory records to sold.

Repair: successful payment now completes both stock transitions.

## 11. Verification rule

Verification states:

**Proposed → Implemented → Live DB verified → Browser verified → Checkpointed**

Never call the retail purchase flow browser-verified until the real Camerashack browser sequence has been completed.

Test One is frozen.

## 26 September 2026 — Stock reservation rule changed

The checkout boundary is now explicitly:

**Shop → Basket → pending checkout/payment attempt → successful payment → sold**

Creating a pending retail order must not change listing status. The listing remains published while payment is pending. This prevents abandoned carts/checkouts from blocking another customer.

At payment time:
- customer credit locks and validates the listing before deducting credit;
- external payment processing validates the listing before marking the order paid;
- if another customer has already bought the item, the conflicting external payment is refunded and its retail order is cancelled.

A pending retail order may still exist as an internal checkout record, but it is not customer purchase history and must not appear in My Orders. My Orders is populated only after successful payment.



## 2026-09-26 — Mixed customer credit + card checkout

- Retail checkout now supports applying available customer credit first and charging the remaining balance by card. Example: a £75 purchase with £5.09 available credit presents £5.09 customer credit and a £69.91 card payment.
- Customer-facing payment wording is provider-neutral: **Credit or debit card**. The customer does not need to see the Stripe provider name.
- Customer credit is held against the retail order while the card payment is open. The hold is released if the card payment fails/expires or the customer cancels; it is actually deducted and posted to the ledger when the card payment succeeds. This prevents losing credit when a card checkout is abandoned.
- If available customer credit covers the entire purchase, the order is completed using customer credit alone without opening card checkout.
- The customer credit account display now reports available credit after active checkout holds.
- Current customer checkout supports customer credit plus card payment. Other payment methods can be added later behind the same provider-neutral customer-facing approach, but they are not currently wired into this retail checkout.


### 2026-09-26 mixed-payment stale card-attempt recovery
- Root cause found in live logs: the mixed-payment credit RPC correctly refused to apply credit when the pending retail order already had an active card payment attempt. This was the previous single-payment checkout attempt, not a credit-balance problem.
- Customer checkout now detects that specific stale active-card condition, cancels the old pending purchase through the normal customer cancellation RPC, creates a fresh pending checkout order, and reapplies customer credit before starting the new card payment.
- The external payment event handler now returns a conflict result when a locally cancelled Stripe payment later reports paid, allowing the Stripe webhook conflict path to refund rather than silently accepting the payment.
- The customer basket cache was bumped to customer-basket.js?v=4.
- Do not treat an active Stripe attempt as reusable after the customer has changed the payment mix; the order must be restarted so the card amount is recalculated from the remaining balance.
