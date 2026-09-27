# Checkpoint — 2026-09-27 — Shipping Handoff Status Clarity

## Finding
Test Two Pentax K-S2 Body is correctly stored with:
- buying item `purchase_stage=awaiting_item`
- shipping status `ready_for_customer`
- shipping label and QR storage paths present
- carrier/service `Parcels 2 Go`
- tracking number present.

The database state means the subscriber has completed the shipping-label handoff and the system is now waiting for the customer to dispatch the item. The underlying purchase stage intentionally remains `awaiting_item` until the customer confirms dispatch.

## Problem
The subscriber Buying dashboard treated every `awaiting_item` record as if the subscriber still needed to create the shipping label. This made the UI continue showing the shipping-service selection and upload controls after the label had already been sent.

## Repair
The Buying dashboard now checks `buying_item_shipping.shipping_status`.

When status is `ready_for_customer`, the subscriber sees:
- **Shipping label sent — awaiting customer dispatch**
- shipping service
- tracking number
- label status
- next step: customer sends the item
- clear waiting message explaining that no further shipping setup is required.

The active-item stage label also changes from the ambiguous `Awaiting shipping handoff` to **Awaiting customer dispatch** for this state.

When the shipping status is not `ready_for_customer`, the existing label-creation/upload workflow remains available.

Buying dashboard cache bumped from v44 to v45.

Commits:
- `f7de6faeb1f8b8051874dea783bb79315c33ebfe` — shipping state UI repair
- `661261592876921661d9359e9abe34196b52c5df` — cache v45

## Expected next transition
Customer confirms the item has been handed to the courier. The buying item should then move from `awaiting_item` to the shipping/in-transit state. Subscriber dashboard should then show that the item is on its way and provide the **Confirm item received** action when appropriate.

Do not change shipping architecture or reset Test Two data.
