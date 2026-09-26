# 2026-09-26 — Buying shipping label upload repair

## Finding
The current Buying workflow and the current retail-sale shipping workflow are separate.

- Buying customer trade-in/shipping uses `buying_item_shipping` and `subscriber_publish_buying_item_shipping_handoff`.
- Retail customer purchases use `fulfilments` and `subscriber_save_retail_fulfilment_shipping`.

The retail change correctly allows a retail customer shipment to be completed with carrier/service + tracking number and without a label/QR.

The Buying screen shown in Test 3 was failing for a different reason: the frontend uploads buying shipping files under `tradeflow-media/{tenant}/buying-items/{buying_item}/...`, but live Storage did not have a matching subscriber INSERT policy for that `buying-items` path. The existing INSERT policy only covered the older `acquisitions` path.

## Repair
Added live Storage INSERT policy:
`tradeflow_media_buying_item_shipping_subscriber_insert`

It permits authenticated tenant members to upload only:
- `shipping-label-*`
- `shipping-qr-*`

under the tenant's `buying-items` path in the private `tradeflow-media` bucket.

The existing Buying RPC still deliberately requires a shipping label or QR before the handoff can be published. This is correct for the customer selling an item to the business.

## Retail protection
The live retail RPC remains tracking-only for the retail-sale workflow:
- carrier or service required;
- tracking number required;
- label/QR optional;
- fulfilment is marked dispatched;
- customer notification is queued.

No retail fulfilment function, table, or validation was changed by this repair.

## Test 3
Current Buying item:
- BI-6DE411A0BE
- Canon Cinema EOS C70 Cinema EOS C70 Camera Body
- purchase stage: awaiting_item

It should now be possible to select the provider label in the Buying dashboard, upload it, enter carrier/service/tracking details, and send the shipping handoff to the customer.

After successful handoff the Buying customer flow should remain:
awaiting shipping label → label ready → customer sends item → shipping → received → inspection.

Do not apply the retail tracking-only rule to this Buying workflow.
