# Checkpoint — 2026-09-27 — Buying Inspection CTA Binding Repair

## Scope
Test Two only: Camerashack tenant. Test One remains frozen.

## Finding
The live Buying workflow already has the correct Received → Inspection database RPC:

- `subscriber_start_buying_item_inspection(p_tenant_id, p_buying_item_id)`
- It authorises `buying.manage`.
- It accepts only `received` or `inspection`.
- It changes the buying item to `inspection`.
- The inspection completion RPC remains responsible for completing the inspection and moving an accepted inspection to `final_offer_required`.

The Buying dashboard's list-level **Start inspection** CTA already had a click handler. The detail-panel **Start inspection** CTA rendered by `renderActions()` only used `data-inspect` and was not included in the detail-panel binding code. It therefore appeared as a CTA but did not execute the start-inspection RPC.

## Repair
Updated `buying-dashboard.js` so the `renderActions()` detail panel also binds its `data-inspect` button to the existing `subscriber_start_buying_item_inspection` RPC.

The repair:
1. Uses the existing tenant/session context.
2. Calls the existing start-inspection RPC.
3. Shows a success/error message.
4. Reloads the existing Buying workflow.
5. Reopens the same item.
6. Scrolls back to the detail panel so the inspection controls are immediately visible.
7. Does not change the inspection completion RPC or downstream payment/final-offer flow.

Buying dashboard cache version was bumped from v42 to v43.

## Shipping architecture preserved
No shipping architecture was changed.

The authoritative shipping model remains:
- Settings → Shipping Settings selects manual shipping services.
- Subscriber uses the provider directly and pays the provider.
- Subscriber returns to TradeFlow and uploads the shipping label and optional QR code.
- Subscriber records carrier/service/tracking/instructions.
- TradeFlow publishes the shipping handoff.
- Customer confirms dispatch.
- Subscriber confirms receipt.
- Inspection is the next stage.

The current shipping handoff RPC still requires a shipping label or QR code before publishing a subscriber-managed handoff. No Parcel2Go API/quote/order/payment route was reintroduced.

## Live verification
Current Camerashack database state was inspected before the repair:
- Canon Cinema EOS C70 item: `purchase_stage=inspection`, shipping status `received`.
- Pentax K-S2 Body item: `purchase_stage=awaiting_item`, with no shipping handoff yet.
- Nikon COOLPIX P1100 item: `purchase_stage=purchased`.

This confirms the database workflow remains intact and the repair is frontend binding only.

## Commits
- `4e52afe942662917ac5fe73c5217e77c089d88f4` — Buying dashboard detail Start inspection CTA binding.
- `e1fe8452638f755e2a94e01aa8def1608a0cf7ba` — Buying dashboard cache refresh v43.

## Next browser test
1. Hard refresh the Buying dashboard so `buying-dashboard.js?v=43` is loaded.
2. Open an item at **Item received**.
3. Click **Start inspection** in the detail-panel green block.
4. Confirm it changes to **Inspection required** and displays the inspection controls.
5. Complete inspection only after selecting the condition/outcome and confirming both inspection checks.
6. Verify the next stage is the existing payment/final-offer workflow.

Do not reset test data or change the shipping architecture while performing this test.
