# TradeFlow Checkpoint — 2026-09-26 Retail Checkout Rebuild

## Scope

Test Two / Camerashack retail purchasing only. Test One remains frozen.

Tenant:
`21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`

Customer:
`valley-discounts@outlook.com`

Customer ID:
`7b5d034f-519d-4edb-bfff-5aa920649163`

## Audit findings

The previous retail checkout implementation had accumulated several incompatible approaches:

- direct Buy → Customer Portal purchase mode
- obsolete standalone `customer-checkout.html`
- obsolete `customer-checkout.js`
- dedicated checkout session experiments
- `tradeflow_checkout_session`
- purchase-context localStorage handoff
- integrated `customer-purchase.js`
- direct order creation from the purchase screen

These approaches were removed from the current route.

The previous integrated purchase screen also did not invoke the existing Stripe Checkout Edge Function. It called the payment-attempt RPC directly and therefore could not provide the intended Stripe checkout journey.

## Current retail architecture

The current intended customer retail flow is:

**Public Shop → Product → Buy this item → Basket → Sign in if required → Review basket → Proceed to payment → create retail order → Stripe Checkout or customer credit → successful payment → My Orders**

Important rules:

- Adding an item to the basket creates no database order.
- Removing an item removes it from the basket.
- An order is created only when the customer proceeds to payment.
- A listing is reserved only when the retail order is created.
- Pending/unpaid orders do not appear in My Orders.
- Successful payment is what moves the purchase into My Orders.
- Customer selling/trade-in and retail buying remain separate workflows.

## New browser files

- `customer-basket.html`
- `customer-basket.js`

The basket uses tenant-scoped localStorage only for the pre-order basket.

The authenticated customer session remains the single canonical:
`tradeflow_customer_session`

No separate checkout session exists.

## Payment

Stripe uses the existing live Edge Function:

`create-stripe-checkout-session`

The function creates/reuses the payment attempt and creates the Stripe Checkout session. Stripe confirmation is handled by the existing webhook chain.

Customer credit uses:

`customer_pay_retail_order_with_credit(uuid,uuid)`

The Test Two customer currently has **£55.00 GBP** credit in the live database.

The credit account was not lost. Live DB verification shows:

- balance: £55
- currency: GBP
- customer: `7b5d034f-519d-4edb-bfff-5aa920649163`

An authenticated RLS simulation also confirmed that direct table access is blocked while the security-definer `customer_get_credit_account` RPC correctly returns the £55 account.

## RLS/security repair

RLS was enabled on:

- `public.customer_credit_accounts`
- `public.payment_provider_events`

These tables intentionally have no broad customer-facing table policies. Access is through the existing secured RPC/service-role paths.

Relevant retail payment RPCs were also tightened so `anon`/PUBLIC cannot execute them:

- `customer_create_retail_order`
- `customer_create_order_payment`
- `customer_get_credit_account`
- `customer_pay_retail_order_with_credit`

They remain executable by `authenticated`.

## Old code removed

Removed:

- `customer-purchase.js`
- integrated purchase section from `customer-dashboard.html`
- purchase-mode routing from `customer-dashboard.js`
- old purchase-context localStorage handling

Repository search shows no current references to:

- `customer-checkout`
- `customer-purchase`
- `tradeflow_checkout_session`
- `tradeflow_purchase_listing_id`
- `tradeflow_purchase_tenant_id`
- `customerCheckoutUrl`
- `tradeflowPurchaseMode`

## Current public route

The product **Buy this item** button now routes to:

`customer-basket.html?tenant_id=...&listing_id=...&basket=1`

Public-site JavaScript cache is v79.

## Verification state

**Implemented in GitHub:** yes.

**Live DB verified:** yes for the credit account, RLS state, RPC grants and Stripe Edge Function presence.

**Browser verified:** not yet. The new basket route must now be tested in the browser.

## Test sequence

Use the Camerashack public retail shop and the existing Test Two customer.

1. Open EOS R1.
2. Click Buy this item.
3. Confirm Basket opens rather than Customer Account/My Sale.
4. Confirm the product is visible in the basket.
5. Confirm no retail order is created at this point.
6. If already signed in, confirm the basket immediately shows payment options.
7. Confirm the customer credit shows **£55.00**.
8. Confirm Stripe / internet payment is available.
9. Confirm customer addresses are shown or the page correctly asks for them.
10. Proceed to Stripe and verify the existing Stripe Checkout flow.
11. Test customer credit separately only with a product whose total is £55 or less.
12. Confirm paid purchases appear in My Orders and unpaid basket items do not.

Do not alter Test One.
