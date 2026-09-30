# TradeFlow Checkpoint — 2026-09-30 Return Status on Sales

## Purpose
Keep the retail sale visibly linked to its customer return decision so a denied return is retained as historical evidence and an accepted return remains open until the return is completed.

## Behaviour
- A rejected/denied customer retail return is displayed on the Selling > Sold record as CLOSED — RETURN REFUSED.
- The return reference is shown with the closed/refused state.
- An authorised return is displayed as RETURN ACCEPTED — AWAITING RETURN and explicitly states that the sale remains open until the returned item is received and the return is completed.
- A requested return is displayed as RETURN REQUEST — AWAITING DECISION.
- The underlying listing remains sold; the return state is additional transaction history and does not reopen or close the sale by itself.
- The Returns workspace continues to retain historical rejected returns.
- Customer My Orders continues to show the denied return.

## Current Test Five evidence
- Return: RET-20260928-82AF74DD
- Status: rejected
- Order: ORD-20260928-5149936D
- Listing: LST-20260928-73E232C1
- Listing status: sold
- Order payment: paid
- Fulfilment: dispatched

## Code
- Added selling-return-status.js.
- Selling page loads the helper with cache-busted ?v=2.
- The helper reads subscriber return history and decorates the matching Sold row without changing the underlying sale or return records.

## Commits
- 309a5e234dc3c1f3a80be42700fab3748b7972ea — helper added
- 316e40b044c41247c7ced2371018f58205dd2902 — state wording clarified
- 4d005b8b91e4af52beb321feb55ed71d1da7cad7 — selling page cache/version updated

## Do not change
Do not reintroduce Parcel2Go API shipping. Manual shipping remains the definitive architecture.
