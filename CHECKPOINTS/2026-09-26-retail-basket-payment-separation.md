# TradeFlow Checkpoint — 2026-09-26 Retail Basket → Payment → My Orders Lifecycle Repair

## Scope
Test Two / Camerashack retail purchasing only. Test One remains frozen.

Tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`  
Customer: `valley-discounts@outlook.com`  
Customer ID: `7b5d034f-519d-4edb-bfff-5aa920649163`

## Root cause

The audit found that the visible Nikon COOLPIX P1100 in **My Sale** is backed by the customer's existing Test Two selling/trade-in record. It is not the retail order created by the current retail purchase test.

The actual retail test created a separate pending retail order for **EOS R1 Body Only**:

- retail order: `ORD-20260926-70BB2C42`
- status: `pending_payment`
- payment status: `unpaid`
- total: £49.91
- listing status: `reserved`

The retail and selling records are therefore separate in the database. The separation bug was in the retail payment lifecycle, not a need to hide selling records.

## First failing boundary

The Basket correctly creates a `pending_payment` order only when the customer presses Proceed to payment.

The existing `create-stripe-checkout-session` Edge Function then attempted to validate that pending order through `customer_get_orders()`.

That RPC intentionally exposes only paid/fulfilled/completed retail history, so a legitimate pending order could not be found by Stripe Checkout. This explains the failure after Pay Now.

## Repairs

### Database

Migration `20260926140000_retail_checkout_lifecycle_separation`:

- added `customer_get_retail_order_for_checkout()`;
- restricted it to the authenticated customer and pending retail order;
- hardened `customer_cancel_retail_order()`;
- cancellation now releases linked reserved listings;
- cancellation returns linked reserved inventory assets to `listed`;
- cancellation cancels active payment attempts;
- customer credit is not modified.

Migration `20260926143000_retail_stripe_cancel_release`:

- successful external retail payment now moves the linked listing to `sold`;
- successful external retail payment now moves the linked inventory asset to `sold`;
- Stripe Checkout expiration/cancellation can cancel an unpaid retail order and release its reservation.

### Front end

Changed:

- `customer-basket.js`
- `customer-basket.html`

The Basket now:

- persists the pending retail order ID in `tradeflow_customer_pending_retail_order`;
- validates that a resumed pending order belongs to the current Basket listing;
- supports **Cancel purchase** for a pending order;
- returns a cancelled Stripe payment to the Basket;
- allows retry against the same valid pending order rather than silently creating a second order;
- keeps unpaid purchases out of My Orders and My Sale.

Cache version: `customer-basket.js?v=2`.

### Stripe

Existing functions retained:

- `create-stripe-checkout-session` — version 11
- `stripe-payment-webhook` — version 5

No new payment architecture was introduced.

The Stripe checkout function now validates pending orders with the dedicated checkout RPC and sends Stripe cancellation back to the Basket.

## Required lifecycle

Shop → Product → Buy this item → Basket → Proceed to payment → pending retail order → Stripe/customer credit → successful server-side payment → paid retail order → listing sold → inventory sold → My Orders.

Cancellation:

Basket → Cancel purchase / Stripe cancelled → retail order cancelled → listing reservation released → inventory reservation released if applicable → no credit deduction → product available again.

My Sale remains exclusively the customer selling-to-business workflow.

My Orders remains exclusively paid retail purchase history.

## Verification state

- Database lifecycle test: passed for pending-order lookup, payment-attempt creation, cancellation, listing release and payment cancellation; customer credit remained unchanged.
- GitHub: implemented.
- Supabase database: live verified.
- Edge Functions: live versions verified.
- Browser: **not yet verified**.
- Test One: frozen and not altered.

## Browser test

Use Camerashack → What We Sell → EOS R1 Body Only.

1. Open product.
2. Click Buy this item.
3. Confirm Basket opens.
4. Confirm £55 customer credit remains visible.
5. Confirm payment options.
6. Proceed to payment.
7. Confirm Stripe Checkout now opens.
8. Cancel Stripe payment.
9. Confirm return is to Basket, not My Sale.
10. Confirm Cancel purchase releases the product.
11. Confirm the pending order becomes cancelled and listing returns to published.
12. Confirm credit remains £55.
13. Re-add the product and retry payment.
14. Complete a genuine successful payment.
15. Confirm My Orders shows the paid order.
16. Confirm My Sale does not contain the retail order.
17. Confirm the product leaves the shop after successful payment.

Do not claim browser verification until these steps have actually been exercised.
