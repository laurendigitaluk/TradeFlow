# Retail customer shipment workflow separation — 26 September 2026

## Rule
For a paid retail sale being shipped to the customer, a shipping label or QR code is not required. The customer needs the carrier/service and tracking number so they can follow delivery.

## Repair
- Added dedicated `subscriber_complete_retail_fulfilment_shipping` RPC for the retail fulfilment completion boundary.
- It requires a carrier/service and tracking number for subscriber-managed shipping.
- Label and QR fields remain optional and are preserved if supplied.
- Completion moves the fulfilment and parcel to `dispatched` and queues the customer `order_dispatched` notification.
- Fulfilment dashboard now calls the dedicated retail RPC.
- Dashboard JavaScript cache version bumped to v13.

## Separation
Older acquisition/buying-item shipping handoff functions retain their label/QR requirements because those workflows concern a different direction of shipment. They are not used to complete a paid retail customer delivery.

## Commit
`f504472ba9cd719d42550f9096582014d98cc922`
