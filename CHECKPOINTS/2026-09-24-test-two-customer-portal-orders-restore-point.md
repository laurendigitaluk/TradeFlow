# Test Two customer portal/orders restore point — 24 September 2026

## Purpose

Restore point created immediately after the customer-portal separation and retail-order cancellation changes, before browser verification of this specific change set.

## Current baseline

- Repository: laurendigitaluk/TradeFlow
- Supabase project: twfbmjwwqzxdvclxbun
- Main code/documentation head: bc193374b7041a7f295ea35bd82524e96054b9c7
- Restore branch: checkpoint-test-two-customer-portal-orders-20260924
- Existing Test Two preflight restore branch remains: checkpoint-test-two-preflight-buying-flow-20260924

## Changes protected by this checkpoint

### Customer portal selling history

- Active selling requests exclude closed requests.
- Purchased/completed selling work is separated from active requests.
- Paid/completed acquisitions are displayed in a dedicated **Completed sales to Camera Shack** section.
- Accepted but unpaid/in-progress acquisitions remain under **Accepted sales & payment**.
- The selling-request counter uses the active request set rather than all historical requests.

### Customer retail orders

- Customers can now cancel their own retail orders while the order is initiated or pending_payment.
- Cancellation is performed through the authenticated customer_cancel_retail_order RPC.
- The RPC verifies the customer owns the order, records cancelled_at, changes status to cancelled, and writes a workflow transition audit row.
- Paid, fulfilment, completed, refunded and already-cancelled orders are not cancellable through this customer action.
- The customer portal now shows **Cancel order** alongside **Pay now** for pending-payment orders.

## Test context

The supplied customer-portal screenshot showed:

- A closed/test selling request still visible as a selling request.
- A retail order in pending_payment for £125 with only a **Pay now** action.

The intended result is:

- The closed/test selling request is no longer counted or displayed as an active selling request.
- A completed/paid sale appears in the completed-sales history section.
- The £125 pending-payment retail order has a **Cancel order** action.
- Cancelling it changes the order to cancelled and removes the payment action.

## Verification status

- GitHub code: implemented.
- Supabase migration: applied as 20260924134609_customer_cancel_retail_order.
- Live browser verification: not yet performed.
- Do not mark browser verified until the customer portal has been exercised in the browser.

## Existing workflow rules preserved

- The earlier Test One restore point remains untouched.
- The Test Two preflight buying-flow checkpoint remains available.
- Do not overwrite completed purchase history merely to remove it from an active customer list.


## Follow-up correction — completed offer/history separation

The first customer-portal separation still allowed historical offers for a paid acquisition to render because the existing customer_get_offers RPC returns all customer offers. A dedicated customer_get_completed_sales RPC was therefore added. The portal now uses the completed sale's buying_item_id and request_reference to exclude that purchase from:

- Active selling requests
- Active offers
- The live selling-status panel

The completed sale remains in **Completed sales to Camera Shack**, with its request reference, item, paid amount and completion date.


## Follow-up — editable customer bank details

The customer portal My Details section now contains editable payment bank details. Customers can view and update account holder name, bank name, UK sort code and UK account number at any time. The portal uses the existing authenticated customer_get_bank_details and customer_save_bank_details RPCs, so the same bank details remain available to the subscriber payment workflow.
