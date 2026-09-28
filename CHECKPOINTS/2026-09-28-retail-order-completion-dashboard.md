# 2026-09-28 — Retail Order Completion Dashboard Repair

## Scope
Correct the TradeFlow business dashboard and Orders workspace so retail orders whose fulfilment has reached dispatched or delivered are treated as complete for dashboard/workspace presentation.

## Root cause
The dashboard counted every `retail_orders` row whose order status was not `cancelled` or `completed`. The two current test orders are still stored as `status='fulfilment'`, but both have fulfilment records at `status='dispatched'`. They therefore appeared as active/action-required orders even though the business workflow had finished its active fulfilment work.

## Live evidence
For Camerashack tenant `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`:
- `ORD-20260926-DCCBB973`: retail order status `fulfilment`, payment `paid`; fulfilment status `dispatched`.
- `ORD-20260926-71DCBDEC`: retail order status `fulfilment`, payment `paid`; fulfilment status `dispatched`.
- The corrected active-order calculation returns 0.

## Changes
1. Updated `subscriber_get_business_workflow_counts` so orders with fulfilment status `dispatched` or `delivered` are excluded from active Orders counts.
2. Updated the Orders workspace to load fulfilment status and derive a display status of `completed` when the retail order is already completed OR its fulfilment is dispatched/delivered.
3. The Active filter now excludes these completed-by-fulfilment orders.
4. The Completed filter now includes them.
5. Completed-by-fulfilment orders use the existing completed/red/blue completed styling and no longer show active transition buttons.
6. Existing underlying retail-order status and fulfilment records were not manually overwritten. The system uses the fulfilment state as the authoritative completion signal for this dashboard presentation.
7. Cache/version bump: `orders-dashboard.js?v=8`.

## Commits
- Supabase migration: applied as `treat_dispatched_orders_as_complete_in_dashboard`.
- `orders-dashboard.js`: `a257de1c1edf7877ffc6fc0b869e4f822161c5c7`
- `orders-dashboard.html`: `1d44659264d4de132a11a2f5d4e9e18b70bad83e`

## Expected dashboard
- Orders: **0 — COMPLETE** when all current orders have dispatched/delivered fulfilment.
- The Orders card should use the red completed state.
- Inventory remains **2 — SEND TO SALES** because those two purchased inventory items still require the business to move them into Selling.
