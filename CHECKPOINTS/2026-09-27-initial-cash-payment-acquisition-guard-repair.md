# TradeFlow Checkpoint — 2026-09-27 — Initial Cash Offer Payment Acquisition Guard Repair

## Issue
The C70 customer transaction was correctly at `final_offer_required` with an accepted initial cash offer of £60 and customer bank details present. The payment confirmation reached the backend, but acquisition creation failed with:

`Cash acquisitions require an accepted final offer and payment`

This was caused by a stale acquisition creation trigger that still required every cash acquisition to reference an accepted `final` offer, even though the current buying workflow intentionally permits an unchanged accepted initial cash offer to be paid after inspection.

## Root cause
`public.guard_acquisition_creation_boundary()` rejected cash acquisitions unless `v_offer.offer_type = 'final'`. It also looked only for a payment whose metadata contained `final_offer_id`.

The current `public.subscriber_complete_purchase()` workflow correctly permits:
- `final_offer_required` + accepted initial cash offer + payment
- `final_offer_accepted` + accepted final cash offer + payment

and records the payment metadata using `offer_id`.

## Repair
Updated `public.guard_acquisition_creation_boundary()` so that:
- accepted cash offers can create paid acquisitions whether the accepted offer is initial or final;
- a paid outbound bank payment must exist for the same customer and amount;
- the payment may identify the accepted offer through either `metadata.offer_id` or `metadata.final_offer_id`;
- trade-in credit acquisition rules remain unchanged;
- other acquisition completion safeguards remain unchanged.

Live Supabase migration:
`20260927230000_allow_initial_cash_offer_payment_acquisition`

Repository migration:
`supabase/migrations/20260927230000_allow_initial_cash_offer_payment_acquisition.sql`

GitHub commit:
`308248335ab0faf042b3666d4cb5d76c5afd36c6`

## Expected result
For the C70 test:
1. Subscriber enters the bank payment reference.
2. Subscriber clicks the single **Confirm payment sent** CTA.
3. `subscriber_complete_purchase()` records the outbound payment.
4. The acquisition creation guard accepts the paid accepted initial cash offer.
5. Acquisition, acquisition item and inventory asset are created.
6. Buying item moves to `purchased`.
7. The item becomes available in Inventory for the next Buy → Inventory → Selling stage.

## Protected behaviour
No shipping, customer authentication, customer portal, offer acceptance or trade-in credit logic was changed by this repair.
