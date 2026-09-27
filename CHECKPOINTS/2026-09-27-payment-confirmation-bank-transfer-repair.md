# Checkpoint — 2026-09-27 — Payment Confirmation and Bank Transfer Repair

## Scope
Test Two only: Camerashack tenant. Test One remains frozen.

## Finding
The subscriber Buying screen reached the payment stage after inspection, and the customer had supplied bank details. The **Confirm payment sent** button appeared but the payment did not complete.

Live Supabase state showed the affected Canon Cinema EOS C70 item was at:
- `purchase_stage=final_offer_required`
- customer: `info@scenesource.co.uk`
- accepted offer: the original `initial` cash offer for £60
- no accepted `final` offer existed.

The existing `subscriber_complete_purchase` RPC only allowed payment when:
- `purchase_stage=final_offer_accepted`, and
- an accepted `final` offer existed.

That was inconsistent with the Buying UI's documented path for an unchanged accepted original offer: after inspection, the subscriber can pay the original accepted amount without sending a revised final offer.

This caused the button to enter Working state and return without changing the workflow. Because payment did not complete, the customer portal did not move to Purchased.

## Live database repair
Updated `public.subscriber_complete_purchase` so:
- `final_offer_required` may be paid when the original `initial` offer is still the accepted offer.
- `final_offer_accepted` continues to require an accepted `final` offer.
- Customer bank details remain mandatory.
- Payment reference remains mandatory.
- Existing payment, acquisition, acquisition item, inventory and notification creation remains unchanged.
- Successful payment still moves the buying item to `purchased`.

Migration:
`supabase/migrations/20260927210000_fix_unchanged_offer_payment.sql`

The same repair was applied live to Supabase before committing the migration.

## Subscriber UI repair
The payment panel now displays the bank transfer details returned by the existing payment-details RPC:
- Account holder
- Bank name
- Sort code
- Account number

The existing payment method and payment reference fields remain.

The duplicate direct click handler on the **Confirm payment sent** button was also removed. The global `data-act` handler is now the single payment action handler, avoiding two payment calls from one click.

Buying dashboard cache was bumped from v43 to v44.

Commits:
- `5031e1031d548acd03791a6ba8bc2856f3075088` — payment UI/bank details/duplicate handler repair
- `e2c46d66ddcec3ba7f21c6e4867d84db2000413a` — Buying dashboard cache v44
- `8e4d73fe01ede8d83e54a5902314b143cb0402e6` — live-equivalent payment RPC migration

## Expected Test Two result
After GitHub Pages publishes v44:
1. Hard refresh the Buying dashboard.
2. Open the Canon Cinema EOS C70 payment stage.
3. Bank transfer details are displayed.
4. Enter the bank transfer/payment reference.
5. Click **Confirm payment sent** once.
6. The payment RPC accepts the unchanged £60 original offer.
7. Buying item changes to `purchased`.
8. Acquisition, payment record and Inventory asset are created.
9. Customer portal should show the purchased/paid state after its next refresh.
10. The item should then be available from Inventory → Selling.

Do not reset Test Two data before this verification. Do not change shipping.
