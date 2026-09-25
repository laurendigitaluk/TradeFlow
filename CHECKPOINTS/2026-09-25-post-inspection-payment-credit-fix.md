# Checkpoint — 25 September 2026 — Post-inspection payment / trade-in credit guard fix

## Scope
Test Two unified buying workflow for Camerashack. Post-inspection must branch to:
- pay unchanged cash offer to customer bank;
- add unchanged trade-in offer to customer credit account;
- refuse/close;
- send revised final offer only when inspection changes value.

## Issue
The new subscriber UI reached the Payment / final offer decision stage, but clicking the accepted £55 trade-in credit action remained on “Working…”. The transaction remained at `final_offer_required`, credit balance remained £0, and no inventory item was created.

## Root cause
The existing acquisition and inventory creation boundary guards were written for bank-paid final offers only. `subscriber_credit_trade_in` creates a completed acquisition from an accepted initial trade-in offer and customer-credit ledger entry, but the acquisition guard rejected anything other than a paid accepted final offer. The inventory guard also required an outbound bank payment.

## Repair
Updated:
- `public.guard_acquisition_creation_boundary()` to explicitly permit `metadata.source='trade_in_credit'` acquisitions backed by an accepted initial trade-in offer.
- `public.guard_inventory_creation_boundary()` to permit trade-in-credit acquisitions when a posted `trade_in_transactions` credit exists, while retaining the bank-payment requirement for cash purchases.

## GitHub
- buying dashboard post-inspection decision flow: `05d07fc73e0e7a559fe727131da881de5fb15a`
- duplicate payment-handler cleanup: `f4454c78ff3fb45b932a954903754080096bdc46`

## Supabase
- migration: `fix_trade_in_credit_completion_guards`

## Current Test Two state
Buying item: `374a6789-72c7-4f01-a448-e97e54c13528`
Accepted offer: trade-in £55.00
Purchase stage: `final_offer_required`
Trade-in transaction: none
Customer credit balance: £0
Inventory asset: none

## Required live verification
1. Refresh the subscriber Buying page using the latest GitHub Pages deployment.
2. Open the Nikon COOLPIX P1100 item.
3. At Payment / final offer decision, click **Add £55.00 to customer credit**.
4. Verify the button completes rather than remaining on Working.
5. Verify customer credit balance becomes £55.00.
6. Verify the item moves to Purchased and appears in Inventory.
7. Verify the customer portal shows the £55.00 credit.
8. Do not alter Test One data.
