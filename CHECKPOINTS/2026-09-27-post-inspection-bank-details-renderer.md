# TradeFlow Checkpoint — 27 September 2026 — Post-inspection bank details display repair

## Root cause

The live customer bank details and the protected payment-details RPC were working. The missing bank name, sort code and account number were caused by the Buying dashboard using two different payment renderers.

The affected Test Two transaction is in `final_offer_required`, so it uses `loadPostInspectionPayment()`. That renderer previously displayed only the customer's account-holder name. The newer four-field hover implementation had been added to `loadPayment()`, which is used by the separate `final_offer_accepted` path.

Therefore the previous hover repair did not affect the screen shown during this test.

## Repair

`buying-dashboard.js` was changed so `loadPostInspectionPayment()` now uses a native HTML disclosure control:

- View customer bank details
- Account holder
- Bank name
- Sort code
- Account number

The existing authenticated `subscriber_get_buying_item_payment_details` RPC remains the source of the data.

No bank-detail table, RPC, RLS policy, permission, payment workflow, shipping workflow or Test One data was changed.

`buying-dashboard.html` cache-buster was advanced from v48 to v49.

## GitHub commits

- Buying controller repair: `dab4c97e246fac1eb3a423e0521240fd88806d48`
- Buying dashboard cache bump: `e5ae8e7c0514c947d5f9cd7fcf52218275e74504`

## Verification state

- Live DB bank-detail record: verified previously.
- Payment-details RPC: verified previously.
- Root cause: verified from current GitHub renderer selection and browser screenshot.
- GitHub repair: implemented.
- Browser verification of v49: pending.

## Browser test

Refresh the Buying dashboard so the page loads `buying-dashboard.js?v=49`.

Open the affected transaction and under Payment / final offer decision select:

**View customer bank details**

The four bank-detail fields should then be visible.

Do not move the transaction to another workflow stage merely to test the display.
