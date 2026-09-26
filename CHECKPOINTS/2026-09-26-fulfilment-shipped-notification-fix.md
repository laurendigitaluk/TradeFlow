# Fulfilment shipped notification fix — 26 September 2026

## Requested workflow
The subscriber wants Save & send shipping details to complete the shipping action: save the label/QR and tracking details, mark the paid order as shipped/dispatched, and tell the customer that the item is on its way.

## Repair
- `subscriber_save_retail_fulfilment_shipping` now moves fulfilment from `awaiting` or `label` to `dispatched` when the shipping handoff is saved.
- The parcel record is also marked `dispatched`.
- A workflow transition is recorded.
- The customer notification uses the existing `order_dispatched` event and `system_order_dispatched` template, with the subject changed to **Your order is on its way**.
- The notification includes the item, carrier/service, tracking information, shipping instructions and customer portal link.
- The Fulfilment dashboard no longer presents a separate `Mark as sent` action after saving the handoff; delivered/returned actions remain available after shipment.

## Important
The notification is queued by the database workflow. Actual email delivery still depends on the existing notification processor/email configuration.

## Scope
Only the paid retail fulfilment shipping boundary and its customer-facing notification wording were changed. Buying, inventory and customer payment workflows were not modified.

## Commit
`dc38f2ea25183f6ea52d8b54dbf62f30095f22ae`
