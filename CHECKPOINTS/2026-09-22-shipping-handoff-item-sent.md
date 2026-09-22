# TradeFlow Checkpoint — 22 September 2026 — Shipping handoff, customer send confirmation and tracking

## Problem found
The customer-facing post-acceptance wording was incorrect for the agreed business process. The portal told the customer to arrange and pay shipping even though the subscriber is responsible for arranging and paying the shipping service.

The customer portal also did not present the supplied label/QR/link prominently enough in the status stage, and there was no clear **Item sent** action that moved the acquisition into an explicit on-the-way state.

## Correct workflow
1. Offer accepted.
2. Subscriber chooses manual label or integrated shipping.
3. Subscriber supplies/creates the label, QR code, link, service and instructions.
4. Subscriber publishes the shipping handoff.
5. Acquisition moves to **awaiting_item**.
6. Customer sees the shipping handoff, including available label/QR/tracking links and instructions.
7. Customer clicks **Item sent** after sending the item.
8. Existing customer RPC moves the acquisition to **shipping** and now also records `shipping_status = in_transit`.
9. Subscriber Buying/Acquisition dashboards show **Item on its way — awaiting receipt** and display tracking information where available.
10. Existing downstream workflow remains available for the actual receipt/inspection stages.

## Business boundary
The subscriber arranges and pays the shipping service. The customer does not arrange or pay shipping through TradeFlow. TradeFlow does not add shipping to the accepted purchase amount or collect/reimburse customer shipping.

## Live database repair
Migration: `correct_customer_shipping_handoff_state`

`customer_mark_acquisition_posted()` now sets posted_at, moves the acquisition to `shipping`, sets `shipping_status = in_transit`, and updates `shipping_status_updated_at`.

`customer_get_acquisition_shipping()` now exposes provider, provider order, shipping status, tracking URL, payment URL, label, QR, carrier/service/tracking, instructions and posted_at fields.

## Frontend changes
### Customer Portal
- Corrected shipping responsibility wording.
- Removed the customer-facing Parcel2Go payment/quote route from the accepted-sale shipping stage.
- Customer sees the subscriber-arranged shipping handoff.
- Label and QR links are opened from the customer stage when available.
- Tracking URL/number is shown when available.
- Added **Item sent** CTA.
- After confirmation, customer sees **Item sent — on its way to the subscriber**.

### Subscriber Buying Dashboard
- `shipping` acquisition state now renders as **Item on its way — awaiting receipt**.
- Live refresh preserves the shipping state instead of reverting to offer accepted.
- Tracking number and tracking URL are surfaced.
- Shipping handoff remains visible after publication.

### Acquisition Dashboard
- `shipping` state now has an **Item on its way** view.
- Tracking number and tracking URL are shown.
- Manual shipping wording now reflects subscriber-paid shipping.

## Cache versions
- buying-dashboard.js v28
- acquisition-dashboard.js v12
- customer-dashboard.js v43

All three JavaScript files pass syntax validation after the changes.

## Important provider boundary
The current Parcel2Go Edge Function remains an implementation component, but its previous customer-paid quote/order interface is no longer exposed in the Customer Portal. Future integrated provider work must create/use the shipment from the subscriber's connected shipping account and return the resulting label/tracking data to the existing acquisition handoff. It must not ask the customer to pay.

## Test record
The existing live Camerashack accepted-sale test record remains the authoritative test record. No acquisition, offer or customer records were deleted or recreated by this repair.

## Final boundary enforcement
The Customer Portal no longer contains the old customer-paid Parcel2Go quote/order UI. The `parcel2go-customer-shipping` Edge Function was also updated and redeployed so customer quote/order actions are rejected server-side. Future integrated provider shipment creation must be performed from the subscriber's connected shipping account and return the resulting label/tracking data to the acquisition handoff.
