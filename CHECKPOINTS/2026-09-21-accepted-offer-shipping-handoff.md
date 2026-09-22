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


## Customer-Paid Shipping Boundary — 21 September 2026

The shipping handoff has been clarified so that TradeFlow does not handle customer shipping costs. The customer selling the item is responsible for arranging and paying for shipment.

### Rules
- The accepted offer remains the agreed purchase amount; shipping is not added to it.
- TradeFlow does not collect shipping money from the customer.
- TradeFlow does not pay or reimburse the customer's shipping.
- TradeFlow does not create a shipping expense or shipping margin.
- Labels, URLs, QR codes, courier/service details, tracking and instructions remain operational handoff data.
- The existing subscriber override remains available.
- The future Voila integration must sit behind the same boundary and must not create a TradeFlow shipping-payment flow.

### UI change
Subscriber Buying/Acquisition handoff text now states that the customer is responsible for arranging and paying for shipping. Customer Portal shipping cards display the same responsibility before the label/QR handoff.

## Customer Portal sign-in handoff repair — 22 September 2026

The customer account authentication itself was verified live: the test customer successfully created a Supabase Auth sign-in at 17:57 UTC on 22 September 2026. The remaining browser problem was presentation/session handoff: the page could retain the Customer account form even though the authenticated session existed, which also prevented the portal navigation handler from activating because the portal container remained hidden.

Repair merged in PR #94:
- customer-auth.js now validates an existing saved customer session on page load;
- successful sign-in/sign-up immediately hides the auth panel and exposes the existing portal;
- the authenticated session is handed directly to the existing customer dashboard controller instead of forcing a page reload;
- customer-dashboard.html cache-buster advanced from customer-auth.js v1 to v2;
- no Supabase schema, customer records, offers, acquisitions or workflow state were changed.

Expected browser result:
- after sign-in, the Customer account form disappears;
- the Welcome back customer portal is visible;
- Overview, Shop, My Orders, Sell to us, Returns and My Details navigation can switch sections normally.


## Live browser regression repair — 22 September 2026

The customer login itself was successful, but the first post-login portal screenshot showed an empty Overview with zero counts. Live database verification confirmed the customer's existing data was still present: 1 buying request, 1 offer and 1 acquisition. The issue was therefore presentation/loading, not lost data.

The customer portal controller used one all-or-nothing Promise.all for all customer data sources. A failure in any one source prevented all subsequent rendering, leaving the authenticated portal shell visible with its default zero values. This was changed to independent Promise.allSettled loading so available customer data continues to render and any failed source is reported rather than discarding the valid session.

A second independent audit of the subscriber Buying dashboard found duplicate legacy declarations of:
- publishShippingHandoff()
- uploadShippingLabel()
- openShippingLabel()

The later legacy declarations overrode the newer shipping-service/QR-aware implementations. This could cause a QR-only handoff to be rejected and could prevent the intended final publish/save-and-resend flow from using the newer shipping method fields.

PR #95 removed the duplicate legacy shipping functions and retained the current shipping-service/QR-aware implementation. Buying cache-buster advanced to v17; Customer auth to v3 and customer dashboard to v35.

No customer, offer, acquisition, valuation or shipping database records were changed by this repair.

Expected live result:
- customer login opens the populated existing portal;
- selling request, offer and accepted acquisition remain visible;
- subscriber can upload a shipping label and/or QR code;
- uploaded sources show as stored/available;
- the same shipping handoff can be saved and sent/resend to the customer;
- accepted acquisition workflow remains authoritative and no duplicate acquisition/offer is created.


## 22 September 2026 — deep customer authentication and shipping settings repair

Live Supabase verification confirmed the customer authentication request itself is succeeding: \`valley-discounts@outlook.com\` has \`last_sign_in_at = 2026-09-22 18:10:28 UTC\`, remains linked to customer \`9032f5d2-bad9-4e51-9e89-3f3c654488d0\` and tenant \`21fca2c5-5da2-4ff6-9f8e-318f9b6277f9\`. The apparent infinite “Signing in…” state was caused by the customer dashboard JavaScript failing to parse, so the authentication success handler was never registered.

Root cause: the previous portal-data repair introduced a literal \`\\n\` token between function declarations in \`customer-dashboard.js\`, producing a JavaScript syntax error. The portal HTML therefore loaded, but the dashboard controller did not execute. PR #96 restored the last known valid customer data controller, repaired the syntax, ensured the sign-in button is released in all cases, and opens the portal immediately after a valid authentication response.

Tenant branding is also now loaded after authentication. Live \`tenant_public_profiles.business_name\` is \`Camerashack\`, so the customer-facing header should display **Camerashack**, not the generic Customer Portal fallback.

Subscriber shipping Settings audit:
- \`subscriber_connect_shipping_provider(...)\` is executable by the authenticated role.
- \`shipping-provider-test\` Edge Function is deployed ACTIVE with JWT verification.
- The Settings UI previously had a test function but no visible Test connection control. PR #96 adds the control to the Parcel2Go connection card.
- No shipping provider connection currently exists for Camerashack; therefore there is no connected Parcel2Go account to test yet.
- Existing manual label/QR shipping data for acquisition \`ACQ-B11FB7341903\` remains unchanged and is still \`subscriber_override\` with no label/QR published.


## 22 September 2026 — shipping handoff UI separation and upload policy

PR #97 separates the subscriber shipping handoff into two explicit methods:
1. **Use your own shipping service**
   - separate Shipping label section
   - separate Shipping QR code section
   - each supports its own URL/file and open action
   - carrier, service and tracking fields remain available
2. **Use connected shipping service**
   - separate provider section
   - link to Settings → Shipping provider connections
   - Parcel2Go is the first live automated adapter
   - Sendcloud and Shippo are shown as future adapters rather than being falsely enabled

The method selector now switches the two sections dynamically.

A live storage-policy audit found the reason subscriber QR/label uploads were failing: tradeflow-media had the customer SELECT policy but no authenticated subscriber INSERT policy for acquisition shipping files. PR #97 added the tenant-member INSERT policy and recorded it in supabase/migrations/20260922190000_shipping_label_subscriber_upload_policy.sql.

No acquisition, offer, customer or shipping workflow records were changed.


## 22 September 2026 — connection-first shipping setup and provider selection

The shipping handoff was revised so the subscriber's shipping account is a business setup step, not something configured ad hoc on each accepted sale.

Current intended flow:
1. Before the subscriber's website goes live, they open **Settings → Shipping provider connections** and connect/test their own shipping provider account.
2. After a provider is connected, it is stored as the tenant's provider connection and is available to the Buying and Acquisition workspaces.
3. When an offer is accepted, the shipping handoff shows **Shipping setup** and a **Shipping method** selector.
4. **Use connected shipping service** shows only the subscriber's actually connected providers. It no longer presents hard-coded Parcel2Go/Sendcloud/Shippo choices as if they were connected.
5. If no provider is connected, the connected-shipping section explicitly says **Shipping service not connected** and links directly to Settings to connect one.
6. **Use your own shipping service** is a separate manual route. Its shipping-label and QR-code controls remain hidden while connected shipping is selected.
7. Connected-provider selection is carried into the acquisition shipping fields so the provider account can be used by the provider adapter for quote/order/label/tracking workflows.
8. The customer remains responsible for paying the shipping provider directly. TradeFlow does not collect, pay or reimburse shipping costs.

Parcel2Go remains the first operational connected provider adapter. The provider list is now data-driven from `shipping_provider_connections`, so additional provider adapters can appear automatically once their secure connection and shipping adapter are implemented.

Frontend cache-busters advanced:
- Buying dashboard JS: v20
- Acquisition dashboard JS: v9

No customer, offer, acquisition, valuation or shipping workflow records were changed by this UI/flow repair.


## 22 September 2026 — corrected shipping-label method flow

The previous shipping UI was corrected after review. The accepted-offer step is specifically a **Send shipping label** step with exactly two choices:
1. **Send a manual label**
2. **Use integrated shipping**

Manual mode displays the manual shipping controls:
- shipping label URL/file upload;
- separate shipping QR code URL/file upload;
- carrier;
- service;
- tracking number;
- customer shipping instructions.

Integrated mode hides the manual label/QR/tracking controls and instead displays **only the subscriber's connected shipping services** from `shipping_provider_connections`, plus an **Add a shipping service** link to `Settings → Shipping services`.

Shipping Settings is now an actual provider setup area rather than a simple provider list. It shows provider-specific setup instructions and connection status. Parcel2Go has the live secure connection/test path. Sendcloud and Shippo are listed with their setup guidance but are clearly marked as connection adapters not yet enabled in TradeFlow; they are not falsely presented as connected options.

The connected-service selector is therefore data-driven: a provider appears in the accepted-sale integrated-shipping dropdown only after the subscriber has actually connected and tested that provider.

The subscriber remains responsible for their own provider account. Customers pay shipping providers directly; TradeFlow does not collect, pay or reimburse shipping costs.

Frontend cache-busters:
- Buying dashboard JS v21
- Acquisition dashboard JS v10
- Shipping Settings JS v7

No acquisition, offer, customer, valuation or shipping workflow records were changed.


## 22 September 2026 — customer shipping handoff and retail-shop scope correction

- Customer and subscriber shipping states now distinguish the subscriber publishing the shipping handoff from the customer actually confirming that the item has been sent.
- `acquisitions.customer_sent_at` is authoritative for the customer-confirmed sent event. Publishing a label/handoff must not make the subscriber dashboard say the item is in transit.
- Customer Portal shipping handoff is consolidated into the selling-request status card. It separates:
  - shipping service/provider link;
  - physical uploaded shipping label with Download your label / Print your label;
  - physical uploaded QR code with Download your QR code / Print your QR code;
  - tracking number and tracking link;
  - customer instructions;
  - full-width Item sent action.
- Provider/service links are not treated as physical labels or QR codes. Physical download/print controls use private uploaded storage assets only.
- The customer is explicitly told that the subscriber has arranged and paid for the shipping service. The customer is not asked to pay shipping.
- After the customer clicks Item sent, `customer_mark_acquisition_posted` sets `customer_sent_at`, moves the acquisition to `shipping`, and sets `shipping_status=in_transit`. Subscriber Buying and Acquisition workspaces then show Item on its way / awaiting receipt and tracking information.
- Added `acquisitions.shipping_service_url` for the provider/service website or operational link, separate from label and QR assets.
- Test acquisition `ACQ-B11FB7341903` was corrected: its previous Yodel website value was removed from the label/QR fields and moved to `shipping_service_url`; `customer_sent_at` remains null and status remains `awaiting_item`.
- Shipping Settings is business-wide and is explicitly shared by the Buying/acquisition workflow and Retail Shop sales/fulfilment workflow. Provider connections are configured once at tenant level rather than separately per workflow.
- Current supported-provider catalogue remains broad (multi-carrier platforms plus direct carriers); Parcel2Go is active, other adapters remain planned until their secure self-service adapter is implemented.
- Customer dashboard cache buster: v42. Buying dashboard cache buster: v30. Acquisition dashboard cache buster: v13. Settings cache buster: v9.


## 22 September 2026 — customer shipping handoff repair

- Corrected the customer item-sent workflow so clicking **Item sent** no longer attempts an invalid acquisition status of `shipping`. The acquisition remains `awaiting_item` until the subscriber actually receives the item; `shipping_status=in_transit` and `posted_at` now represent that the customer has handed the parcel to the carrier/dropped it off.
- Customer shipping RPC now exposes `source_offer_id`, `shipping_service_url`, `shipping_status`, tracking URL, label/QR storage paths and `posted_at` so the portal can render the same handoff state consistently.
- Subscriber Buying Dashboard now recognises `shipping_status=in_transit` as **Item on its way — awaiting receipt** instead of reverting to offer accepted/awaiting item.
- Customer Portal shipping section now distinguishes the carrier/service website from the physical shipping label and physical QR asset. Physical assets have separate **Download your label / Print your label** and **Download your QR code / Print your QR code** actions.
- Added subscriber storage SELECT access for shipping assets so uploaded private label/QR files can be signed and opened by the subscriber as well as the customer.
- Shipping uploads now verify that the private storage object can be signed before saving its storage path to the acquisition, preventing stale database paths for missing files.
- The test acquisition had a stale shipping-label storage path with no corresponding storage object; that invalid path was cleared. A real physical label must be uploaded again. The test carrier website is stored separately from the physical label.
