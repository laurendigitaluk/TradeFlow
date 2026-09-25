# Checkpoint — 2026-09-25 — Shipping Architecture Retirement and Current Test Two Flow

## Current architecture

TradeFlow no longer uses the Parcel2Go API/connected-provider shipping route for the current Buying workflow.

The authoritative current shipping flow is:

1. Subscriber opens **Settings → Shipping Settings**.
2. Subscriber selects the shipping services they use from the TradeFlow shipping service catalogue.
3. Selected services are saved in `tenant_shipping_services` and are available to the Buying shipping handoff.
4. Subscriber uses the selected provider's own website/service and pays the provider directly.
5. Subscriber returns to TradeFlow and uploads the shipping label and, where applicable, QR code.
6. Subscriber records carrier/service, tracking number and customer instructions.
7. TradeFlow publishes the shipping handoff against the existing acquisition/buying item.
8. Customer receives the label/QR and confirms when the item has been sent.
9. Subscriber sees **Item on its way** and confirms **item received**.
10. Next stage is **Inspection**.

TradeFlow does not create Parcel2Go quotes/orders, process shipping payments, or require Parcel2Go API credentials in this current flow.

## Audit findings

### GitHub current code
- `shipping-settings.js` is already on the new service-catalogue model and contains no Parcel2Go integration logic.
- `buying-dashboard.js` reads `tenant_shipping_services` and publishes the subscriber shipping handoff through the existing workflow.
- Customer shipping-file access uses the existing private storage paths and signed URLs.
- Legacy Parcel2Go Edge Function source still exists in the repository:
  - `supabase/functions/parcel2go-subscriber-shipping/index.ts`
  - `supabase/functions/parcel2go-customer-shipping/index.ts`
  - `supabase/functions/shipping-provider-test/index.ts`
- Historical Parcel2Go migrations remain in the repository. They are migration history and should not be deleted simply to rewrite history.
- No current Shipping Settings frontend code was found that calls the legacy Parcel2Go functions.

### Live Supabase state
At the time of this checkpoint:
- `shipping_provider_connections`: 1 row, the Camerashack tenant's legacy Parcel2Go Live connection.
- `tenant_shipping_services`: 4 rows.
- `shipping_service_catalog`: 20 rows.
- `buying_item_shipping` automated rows: 0.
- `buying_item_shipping` subscriber_override rows: 1.

The single Parcel2Go connection is legacy state and is not used by the current manual shipping flow. Do not create new provider connections or automated shipping rows under the current architecture.

## Documentation updated
The current shipping architecture was added as the authoritative section to:
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`

Older dated Parcel2Go sections remain only as historical audit records and are explicitly superseded by the current architecture section.

## Test Two workflow state
The current Test Two item is using the subscriber-managed shipping handoff. Customer has confirmed dispatch. Subscriber UI should show:
- green **Item on its way** state;
- **Confirm item received** CTA;
- **Next step: Inspection**;
- Accepted Offer card next action: **Confirm item received — inspection next**.

## Cleanup rule
As Test Two continues, inspect each shipping-related screen/controller/RPC before changing it. Remove stale Parcel2Go-specific UI, hard-coded labels, branches and calls when encountered. Do not remove historical migrations or shared database structures without verifying that no current workflow depends on them.

## Important continuity rule
Current GitHub, current Supabase state, and this checkpoint are authoritative over older Parcel2Go instructions in prior checkpoints.


## Test Two shipping status display repair — 25 September 2026
The Buying detail panel's shipping-stage block was corrected to use the current subscriber-managed shipping data. It now renders as a green **Awaiting item** section and displays the shipping information already supplied to the customer: **Date shipped**, **Shipping service**, **Tracking number**, and **Carrier**. The date uses the customer's dispatch timestamp when available, with the recorded shipping handoff timestamp as fallback. The existing **Confirm item received** action remains available, followed by Inspection.

The Buying dashboard now loads the current `buying_item_shipping` row for each active buying item rather than relying only on the workflow RPC, which does not expose the shipping detail fields. Cache version was bumped from 118 to 119.

Commits:
- `0d2cec30fd3df822c27e0cb229ce4e0eba5ea853` — shipping details/status block
- `71407d183ce6055b149668fd58f03402a5349ff5` — Buying dashboard cache refresh


## Confirm item received — live RPC repair
The **Confirm item received** action was still remaining on **Working…**. Inspection of the live function showed the previous `subscriber_mark_buying_item_received` implementation used a joined `SELECT ... FOR UPDATE` before performing the state transition. The function has been replaced with a simpler validated transition: authorise the subscriber, verify the buying item is in `shipping/received`, verify `buying_item_shipping.shipping_status` is `in_transit/received`, then update the buying item and shipping rows. The live Supabase function was updated and the equivalent migration was committed as `20260925210000_fix_subscriber_mark_buying_item_received.sql`.

The current Test Two database state immediately before the repair was still `purchase_stage=shipping`, `shipping_status=in_transit`, with the customer dispatch timestamp present, confirming the item is eligible for receipt.


## Received-state UI repair — 25 September 2026
Live Supabase verification confirmed the receive action **did succeed**: the Test Two item is now `purchase_stage=received`, `item_received_at` is populated, `shipping_status=received`, and the original Evri service, carrier, tracking number and dispatch timestamp remain stored.

The apparent failure was a subscriber UI bug. The `received` render branch was incorrectly displaying the old **Confirm item received** button and did not render the shipping details. It has been changed to a green **Item received** state with the existing shipping details retained and **Next step: Inspection**, with no repeat receive button. Customer Portal already derives its stage/message from `customer_get_selling_status`, whose live result for `received` is **The business has received your item. It is waiting for inspection.**

Buying dashboard cache version is now 123.


## Follow-up UI audit — 25 September 2026
A regression was found while correcting the received-state display: the subscriber dashboard's `renderActions()` function had been removed from `buying-dashboard.js`, leaving the Actions panel permanently at **Loading current stage actions…** even though the database state was correct. The function has now been restored. The received state is green, shows retained shipping details and points to Inspection; the Inspection state is green and provides the inspection controls.

The Customer Portal also contained stale accepted-offer copy stating that the business would now create the shipping label and instructions. That sentence belonged to the retired shipping flow and has been removed. The live customer stage/message remains authoritative for the current next step.


## Runtime regression repair — 25 September 2026
The Buying dashboard became frozen after the inspection CTA work because the newly restored `renderActions()` implementation contained a JavaScript syntax error. The live page consequently remained on Loading states. The script was rebuilt from the last known-good parent revision, with a clean renderActions implementation restored for Received → Inspection → Final Offer → Payment, while retaining the green live-item cards and Start inspection CTA. Syntax was verified before commit. Buying dashboard script cache is now v128.
