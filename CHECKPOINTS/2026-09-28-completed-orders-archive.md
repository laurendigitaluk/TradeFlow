# TradeFlow checkpoint — 2026-09-28 — Completed Orders Archive

## Scope
Added a subscriber-facing Completed Orders archive to the Orders workspace.

## Current behaviour
- Orders workspace now separates **Active orders** from **Completed orders**.
- Completed orders are retained in the archive and remain viewable after they leave the active workflow.
- The archive uses the existing display-completion logic: an order is displayed as completed when its canonical retail order status is `completed`, or when its linked fulfilment is `dispatched` or `delivered`.
- The two current Camerashack orders that were previously showing as active but have dispatched fulfilment therefore remain available in the Completed Orders archive.
- The underlying retail order records were not manually overwritten by this UI change.
- Completed orders have no active workflow transition buttons in the archive; they can still be opened with **View order details**.
- Completed status is visually separated as a completed/archive state.

## Confirmation safeguards
Before the Orders workspace performs an order cancellation, partial refund, or full refund, the subscriber is now asked for confirmation.
- Completing an order does not require the destructive-action confirmation.
- Payment capture continues through the existing payment RPC.
- No return/refund database workflow was changed in this repair; confirmation is applied to the existing cancellation/refund transitions.

## Files changed
- `orders-dashboard.js`
  - Added `allOrders` so the archive can be rendered independently of the active/status filter.
  - Added completed archive rendering.
  - Updated order lookup so archived orders can still be opened.
  - Added confirmation before cancellation, partial refund, and refund transitions.
- `orders-dashboard.html`
  - Added Completed Orders archive section and count.
  - Added cache-busting version `orders-dashboard.js?v=10`.
  - Styled completed status as an archive/completed state.

## Commits
- JS: `bafb19cd15bc6884143f3614acb446f03a698857`
- HTML: `cf789224636370bb413d65783f78fea670069ede`

## Verification state
Live Supabase was checked before the change. Camerashack currently has:
- `ORD-20260926-DCCBB973`: retail order status `fulfilment`, payment `paid`, linked fulfilment `dispatched`.
- `ORD-20260926-71DCBDEC`: retail order status `fulfilment`, payment `paid`, linked fulfilment `dispatched`.
- The other current test orders are cancelled/unpaid.

No Supabase schema or transaction data was changed for this archive repair.

## Next test
Refresh the Orders workspace and confirm:
1. Active orders no longer contain the two completed/dispatched orders.
2. A **Completed orders** archive appears underneath Active orders.
3. The two completed test orders appear in that archive.
4. **View order details** works from the archive.
5. Starting Cancel, Partial refund, or Refund asks for confirmation before changing anything.
6. No order is removed from the archive after completion.

## Follow-up repair — fulfilment permissions — 2026-09-28

The next test showed **permission denied for table fulfilments** and the Orders page could not load. Root cause: the new archive logic queried `public.fulfilments` directly through REST, while the table is intentionally protected from direct subscriber table access.

Repair: Orders now uses the existing SECURITY DEFINER `subscriber_get_fulfilments(p_tenant_id)` RPC, which performs tenant membership validation and returns the fulfilment data required by the Orders workspace. No RLS/table permissions were weakened.

Follow-up commits:
- Orders JS: `8f8196c12a5b31e5c60d5b2afbdcaa79d7808ce3`
- Orders HTML/cache: `37471f13e349a9f70fa1c8ec9bbbff2ec265f55d`

The Business Dashboard also contains the dedicated **Completed Orders** link added in commit `851aa11728dc9c9e07f4a2e557cb5b2d7986a5b2`.
