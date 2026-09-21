# TradeFlow Checkpoint — 21 September 2026 — Accepted Offer → Shipping Label Handoff

## Live state
- Tenant: Camerashack
- Request: BR-744BA41BDC
- Item: BI-1D805A5FD3
- Offer: £100.00, status `accepted`
- Acquisition: ACQ-B11FB7341903, status `accepted`
- Shipping label fields: currently empty
- buying_request.status: `offer_ready`
- buying_item.status: `offer_ready`

## Important finding
The accepted offer and acquisition are authoritative for the post-acceptance handoff. The older request/item status values have not advanced, so the subscriber UI must not interpret `offer_ready` as meaning the customer is still waiting when an accepted offer/acquisition exists.

## Changes
- Buying dashboard now derives `offer_accepted` from the accepted offer or active linked acquisition.
- Subscriber status is **Offer accepted — send customer shipping label**.
- Accepted request detail includes the shipping handoff form using the existing acquisition shipping columns.
- Publishing the shipping handoff moves acquisition `accepted` → `awaiting_item` through `transition_workflow_entity()`.
- Customer Portal accepted-stage wording now says it is awaiting the subscriber's shipping label.
- Existing customer shipping section already displays the label/instructions and lets the customer mark the item posted.
- Cache-busters advanced: Buying v11, Customer Dashboard v29, Acquisition Dashboard v2.
- Database access and RLS policy repairs were applied after browser verification exposed two independent data-visibility issues.

## Next browser test
1. Hard refresh Subscriber Buying.
2. Open BR-744BA41BDC.
3. Confirm the old highlighted **Valuation approved — offer not yet sent** message is gone.
4. Confirm status reads **Offer accepted — send customer shipping label**.
5. Confirm £100.00 is shown as the accepted offer.
6. Confirm the shipping handoff form is visible.
7. Do not enter a fake label URL. Use a real test label URL when testing publication.
8. After publication, confirm acquisition changes to `awaiting_item` and Customer Portal shows the label/instructions.


## Follow-up browser-test finding — 21 September 2026

The first post-merge browser test still showed **Valuation approved — offer not yet sent**. The accepted-state code itself was present, but both Buying dashboard data-loading Promise calls omitted the actual `acquisitions` query while still destructuring and using `acquisitions`. Therefore the linked acquisition could not be mapped to the accepted offer in the browser.

Repair: restore the existing tenant-scoped `acquisitions` query to both `load()` and `refreshBuyingStatus()`. No database change was made. The live test data remains untouched.

Expected result after the repaired controller loads: the request is derived as `offer_accepted`, the old valuation/send-offer notice disappears, and the shipping handoff form is shown.


## Follow-up database access finding — 21 September 2026

The browser then reported **permission denied for table acquisitions**. Live database inspection confirmed the issue was table-level Data API privilege, not the tenant RLS policy: `authenticated` had no `SELECT` or `UPDATE` grant on `public.acquisitions`, while the existing restrictive `acquisitions_subscription_select/update` policies were already correctly present. The owner membership has both `acquisitions.view` and `acquisitions.manage`.

Repair applied live as migration `repair_acquisition_subscriber_data_api_grants`: `GRANT SELECT, UPDATE ON public.acquisitions TO authenticated;`. No row data, statuses, RLS policies, or workflow transitions were changed.


## Follow-up deep audit — duplicate lifecycle renderer — 21 September 2026

The live offer is confirmed as `accepted` (£100) and the acquisition is confirmed as `accepted`. A deep code audit found the remaining contradictory message in the same Buying page: `loadItemFinancials()` contained an older fallback that independently said **No offer has been sent yet** whenever its local offer result was empty. This was a second presentation path separate from the newer request-level accepted-offer logic.

Repair on branch `fix/accepted-offer-detail-override`:
- pass the authoritative request status into `loadItemFinancials()`;
- if the request is `offer_accepted`, never render the old pending-offer message;
- start the existing 10-second Buying status refresh after initial page load;
- advance `buying-dashboard.js` cache-buster from v11 to v12.

No live offer, acquisition, request or item data was changed.


## Follow-up RLS policy finding — 21 September 2026

The browser still showed the request as **Valuation approved — offer not yet sent** even though the live offer was accepted. The database was then tested under the subscriber's authenticated role. The offers_subscription_select and acquisitions_subscription_select policies were both marked **RESTRICTIVE**, but neither table had a corresponding permissive SELECT policy. PostgreSQL therefore returned zero rows to the subscriber despite the owner having the required offers.view / acquisitions.view permissions. This is why the frontend's accepted-offer query looked empty rather than throwing an error.

Repair applied live as migration repair_offer_and_acquisition_select_policies:
- added permissive offers_select_members for authenticated tenant members;
- added permissive acquisitions_select_members for authenticated tenant members;
- retained the existing restrictive subscription permission/feature policies as the controlling boundary.

Authenticated-role SQL verification now returns the live accepted £100 offer and the linked accepted acquisition for BR-744BA41BDC.

## Follow-up customer-field RPC finding — 21 September 2026

The same browser view also showed **Customer supplied fields could not be loaded: CASE types jsonb and text cannot be matched**. The existing subscriber_get_buying_item_customer_details() function returned text directly for text-like fields while the other CASE branches returned jsonb, which PostgreSQL rejects as a mixed CASE type.

Repair applied live as migration repair_subscriber_customer_field_json_types: text-like values are now converted with to_jsonb(vfv.value_text) before being returned. The authenticated-role RPC was retested successfully for the live Canon EOS R7 item and returned the customer/request data without the CASE-type error.

## Current verified database state

- Request BR-744BA41BDC: offer_ready (legacy request status)
- Item BI-1D805A5FD3: offer_ready (legacy item status)
- Trading value: approved, £100.00, manual
- Offer OFF-9E44199AB6F3: accepted, £100.00
- Acquisition: accepted and linked to the accepted offer
- Shipping label: not yet published
- Authenticated subscriber SELECT now sees both the accepted offer and acquisition.

## Shipping Label File Upload and Resend — 21 September 2026

The accepted-offer shipping handoff now supports two label sources:

- **Shipping label URL** — paste the label URL supplied by the carrier.
- **Uploaded shipping label** — upload a PDF, PNG or JPEG directly to TradeFlow.

Uploaded labels are stored in the existing private `tradeflow-media` bucket under the tenant/acquisition path. The customer can access only the label belonging to their own acquisition. The subscriber can open/print the label from the Buying or Acquisition workspace.

The shipping handoff action is now **Send shipping label to customer** initially, then **Save & resend shipping label** when a label already exists. This republishes the current label/instructions to the customer portal without creating a duplicate acquisition or offer.

The Customer Portal shows **Open / print shipping label** and **Download shipping label** when an uploaded label exists. Signed links are generated on demand rather than permanently exposing the private storage object.


## Shipping Service Override — 21 September 2026

### User requirement
The subscriber must be able to override the future automated Voila courier route and use their own shipping service for an individual acquisition.

### Implemented
Live acquisition records now have:
- shipping_method (subscriber_override / automated);
- shipping_qr_url;
- shipping_qr_storage_path.

The Buying and Acquisition workspaces now allow the subscriber to:
- choose **Use my own shipping service**;
- paste a shipping label URL;
- upload a PDF/PNG/JPEG label;
- paste a QR code URL;
- upload a PNG/JPEG QR code;
- enter courier/service/tracking information;
- add customer instructions;
- open/print the label or QR code;
- publish/update the same acquisition handoff.

The Customer Portal displays the shipping method, courier/service, label and QR code where supplied.

### Workflow rule
This remains the existing acquisition workflow. No duplicate acquisition, offer, fulfilment or shipping state is created.

A subscriber override can provide:
- label only;
- QR code only;
- both label and QR code.

Publishing an accepted acquisition continues through transition_workflow_entity() to awaiting_item.

### Automated route status
The UI reserves the automated Voila route but it is currently disabled. The Voila integration itself has not yet been connected. The next implementation phase can add the secure server-side Voila API connection without changing the subscriber override path.

### Live database verification
The migration add_shipping_service_override added the acquisition fields. The migration extend_customer_shipping_override_data extended customer_get_acquisition_shipping() so the authenticated customer portal receives the method and QR sources.

The existing private storage policy continues to restrict customer access by exact tenant/acquisition/customer relationship.
