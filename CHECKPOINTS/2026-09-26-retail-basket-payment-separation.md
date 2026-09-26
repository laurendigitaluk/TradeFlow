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


## Follow-up browser finding — customer credit payment

The first browser verification reached the Basket payment screen successfully, confirming the earlier checkout-boundary repair. Selecting **Use customer credit** then produced:
`new row for relation "payment_records" violates check constraint "payment_records_payment_type_check"`.

Root cause: `customer_pay_retail_order_with_credit()` used `payment_type='customer_credit'`, but the live `payment_records_payment_type_check` allows `customer_payment` and the payment method is represented separately.

Repair: migration `20260926160000_fix_retail_credit_payment_type` changed the function to use:
- `payment_type = 'customer_payment'`
- `payment_method = 'customer_credit'`

No payment was consumed while repairing this fault. The existing £55 credit remains available for the next browser test.

**Next browser test:** return to the Basket, select **Use customer credit**, click **Proceed to payment**, and verify that the order completes to My Orders and the credit reduces by the purchase amount. If this succeeds, continue with the Stripe cancellation/retry test separately.


## Browser finding — unpaid checkout was reserving stock

The browser test confirmed the product reached Basket/payment, but the live database showed the EOS R1 listing had been changed to reserved as soon as the pending retail order was created. This was not acceptable: a customer could leave the purchase incomplete while preventing another customer from buying the product.

Repair applied:

- customer_create_retail_order() no longer reserves the listing.
- customer_create_retail_order_from_basket() no longer reserves listings.
- A pending retail order does not remove the product from the live shop.
- Customer-credit payment locks and validates the published listing immediately before deducting credit.
- External payment completion checks listing availability before accepting the sale. A conflicting paid Stripe checkout is refunded and its unpaid retail order is cancelled.

The current unpaid EOS R1 test order was cancelled. Live verification after reset:

- listing: published
- reserved_at: null
- pending retail orders for the test customer: 0
- customer credit: £55
- no payment consumed.

The Nikon COOLPIX P1100 card visible under My Sale is a separate trade-in/selling workflow record (purchase_stage=purchased). It was not deleted or altered as part of the retail-stock reset. The retail purchase lifecycle is now being tested separately.

Next test: return to the EOS R1 product on the live shop, add it to Basket, proceed to payment, and confirm that the product remains visible/purchasable while the payment is still incomplete. Then complete customer credit payment and verify the listing changes to sold only after payment.


## Browser finding — customer credit path required subscriber membership

The next browser test exposed a separate defect after the payment-type repair: selecting **Use customer credit** returned **Tenant membership required**.

Root cause: `customer_pay_retail_order_with_credit()` called `transition_workflow_entity()`. That helper is intentionally subscriber/operator-only and requires tenant membership. A customer is correctly authenticated to their tenant through the `customers.auth_user_id` relationship but is not a subscriber tenant member.

Repair: migration `20260926180000_customer_credit_checkout_transition` records the `pending_payment → paid` retail-order workflow transition directly inside the customer SECURITY DEFINER RPC instead of calling the subscriber-only helper. No tenant membership was granted to the customer and no security boundary was weakened.

The first post-repair rollback-only authenticated SQL test then exposed a second PL/pgSQL issue: the RPC return column is also named `status`, so unqualified `status` references in the listing/inventory UPDATE predicates were ambiguous.

Repair: migration `20260926181000_fix_customer_credit_checkout_update_ambiguity` qualifies those UPDATE targets and predicates.

Rollback-only authenticated verification now returns the expected result for the current EOS R1 pending order:
- status: `paid`
- amount: £49.91
- remaining credit: £5.09

The test was rolled back. Live state remains:
- retail order: `pending_payment`
- payment status: `unpaid`
- amount due: £49.91
- EOS R1 listing: `published`
- customer credit: £55.00

No live credit was consumed by the verification.

**Next browser action:** on the existing Basket payment screen, select **Use customer credit** and click **Proceed to payment**. The previous Tenant membership error and SQL status ambiguity have both been repaired and rollback-tested. Browser verification is still required before declaring the genuine payment complete.


## Follow-up — paid order detail and subscriber dispatch workflow

The successful customer-credit payment was confirmed for the Test Two EOS R1 purchase. The order is paid for £49.91 and customer credit is now £5.09. The paid order remains separate from the customer's trade-in/My Sale workflow.

A new retail fulfilment lifecycle is now in place. Paid retail orders create a `fulfilments` record in `awaiting` state. The current Test Two order `ORD-20260926-71DCBDEC` has fulfilment `FUL-17C5EB082D09` in `awaiting` state.

Customer My Orders has been expanded to show:
- order reference and paid status;
- every purchased item and line value;
- order total;
- fulfilment state;
- carrier/tracking details when dispatched.

Subscriber Selling now has a separate **Sold** section. Paid listings appear there rather than being treated as available stock. The Sold section provides a **CREATE SHIPPING LABEL** link into the Fulfilment workspace and a **MARK AS SENT** action once the fulfilment has reached `label` status.

The Fulfilment workspace now accepts a shipping label URL and can move `awaiting → label`. Marking the parcel as sent moves `label → dispatched`; the customer portal then displays **Shipped** and the tracking number/link.

Migration `20260926200000_retail_order_fulfilment_and_multi_item_payment` also hardened payment for multi-item orders: all retail order items must still be published/available before customer credit is deducted or an external payment is accepted. No partial basket payment is permitted.

GitHub browser code updates were committed for the customer order view, Selling Sold section, and Fulfilment workflow. Frontend cache versions were bumped. Browser verification of the new Sold/Shipping UI is still required; database state has been verified for the current paid order and fulfilment.
