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
