# Checkpoint — 25 September 2026 — Post-inspection trade-in decision flow

## Test Two state
Test Two item: Nikon COOLPIX P1100, buying item BI-914B1450A2, tenant Camerashack (21fca2c5-5da2-4ff6-9f8e-318f9b6277f9).

The item has completed inspection and is now at final_offer_required.

## Correct business rule
A final offer is not required when the accepted trade-in value remains unchanged.

After a passed inspection:
1. Add accepted value to customer credits — use when the agreed trade-in value is unchanged. This creates the trade-in credit, acquisition/acquisition item and Inventory asset, then moves the buying item to purchased.
2. Send revised final offer — use only when inspection changes the value. The customer must accept or refuse the revised offer.
3. Refuse trade-in — closes the transaction as offer_refused.

A trade-in credit is an account credit, not a bank-transfer payment. Bank transfer remains the cash-purchase payment route.

## Database
Added server-side RPCs:
- subscriber_credit_trade_in
- subscriber_refuse_after_inspection

subscriber_credit_trade_in creates:
- trade_in_transactions with status credited
- a posted ledger_entries customer credit
- acquisition and acquisition item
- Inventory asset
- buying item stage purchased

Updated customer_get_selling_status wording so the customer portal reflects the new decision model.

## Frontend
buying-dashboard.js now renders final_offer_required as a decision stage:
- Add accepted amount to customer credits
- Refuse trade-in
- Revised trade-in value + Send revised final offer

The revised-offer action rejects an unchanged amount and directs the subscriber to use customer credits instead.

Cache version: buying-dashboard.js?v=131.

## Documentation
Updated:
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/TRADEFLOW-HUMAN-USER-MANUAL.md
- docs/TRADEFLOW-SUBSCRIBER-DASHBOARD-DIAGNOSTIC-ROADMAP.md

## Verification status
Implemented in GitHub and live Supabase database. Browser verification of the three new post-inspection actions is still required. Do not credit Test Two until the browser test explicitly confirms the intended action.
