# 2026-09-25 Retail Checkout Payment Fix

## Scope
Test Two retail purchase flow from Camerashack public product page into customer checkout.

## Findings
- The public product page's Buy this item link was using customerUrl('listing_id=...').
- The customer URL helper returned customer-dashboard.html&listing_id=... when an extra parameter was supplied.
- On GitHub Pages that is interpreted as a filename, producing the observed 404.
- TradeFlow already contains retail-order/payment infrastructure:
  - customer_create_retail_order
  - customer_create_order_payment
  - retail_orders
  - payment_records
  - customer credit accounts
- Camerashack currently has no payment_provider_connections row, so there is no connected online payment provider available to actually capture an internet payment.
- Customer credit infrastructure already exists and the Test Two customer currently has £55 credit.

## Changes
- Added customer-checkout.html.
- Added customer-checkout.js.
- Public product Buy this item now routes to the checkout page.
- Fixed the customer URL helper so extra query parameters use ? rather than & without a query string.
- Added secure database RPC customer_pay_retail_order_with_credit(uuid,uuid).
- Credit payment deducts the customer's credit balance, records a paid payment and ledger entry, marks the retail order paid, and moves the reserved listing/inventory asset to sold.
- Internet payment option is represented on checkout and uses the existing payment-attempt RPC. It must not be represented as paid until an actual payment provider confirms the transaction.

## Required live verification
1. Open Camerashack public shop.
2. Open the Nikon COOLPIX P1100 listing.
3. Click Buy this item.
4. Confirm checkout page loads rather than 404.
5. Confirm customer sign-in/account flow works.
6. Confirm payment address and delivery address are shown.
7. Confirm Internet payment and Use customer credit options appear.
8. Confirm the £55 credit is shown for the current Test Two customer.
9. Do not treat internet payment as completed until a real provider connection/webhook exists.
10. Test credit payment only when the customer's available credit covers the order total, or use a test product/order with sufficient credit.

## Restore boundary
Do not alter Test One. Do not remove existing buying, inspection, trade-in credit, inventory or selling workflow transitions.
