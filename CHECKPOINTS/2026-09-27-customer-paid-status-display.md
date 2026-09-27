# TradeFlow Checkpoint — 2026-09-27 — Customer Paid Status Display

## Issue
After the C70 cash purchase completed successfully, the customer portal moved the sale to `purchased`, but the sale summary still displayed the old accepted-offer status:
`Accepted: Cash offer — £60.00`

The customer portal therefore did not clearly tell the customer that payment had been made.

## Repair
Updated `customer-dashboard.js` so that when the selling status is `purchased`:
- the stage is displayed as `Complete`;
- the status displays `Paid £60.00` using the recorded accepted amount;
- the expanded sale card displays a clear `Payment paid` notice;
- the notice states that the payment has been paid into the customer's bank account and that the sale is complete.

The old accepted-offer status is no longer used for the completed/purchased state.

## Cache
`customer-dashboard.html` cache bumped from v133 to v134.

## GitHub
JS commit: `e7af0800300e501b5d6bdcfb30193e497e8d21a0`
HTML/cache commit: `7575f6b9eb1d465d62bc250d3ada780c50293c1a`

## Protected
No payment, acquisition, inventory, shipping or authentication logic was changed.
