# TradeFlow Checkpoint — 2026-09-26 Retail Basket → Payment → My Orders Lifecycle Repair

## Scope

Test Two / Camerashack retail purchasing only. Test One remains frozen.

Tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`  
Customer: `valley-discounts@outlook.com`  
Customer ID: `7b5d034f-519d-4edb-bfff-5aa920649163`

## Root cause

The audit found that the visible Nikon COOLPIX P1100 in **My Sale** is backed by the customer's existing Test Two selling/trade-in record. It is not the retail order created by the current retail purchase test.

The actual retail test created a separate pending retail order for **EOS R1 Body Only**:

- retail order: `ORD-20260926-70BB2C42`
- status: `pending_payment`
- payment status: `unpaid`
- total: £49.91
- listing status: `reserved`

The retail and selling records are therefore separate in the database. The separation bug was in the retail payment lifecycle, not a need to hide selling records.

## First failing boundary

The Basket correctly creates a `pending_payment` order only when the customer presses Proceed to payment.

The existing `create-stripe-checkout-session` Edge Function then attempted to validate that pending order through `customer_get_orders()`.

That RPC intentionally exposes only paid/fulfilled/completed retail history, so a legitimate pending order could not be found by Stripe Checkout. This explains the failure after Pay Now.

## Repairs

### Database

Migration `20260926140000_retail_checkout_lifecycle_separation`:

- added `customer_get_retail_order_for_checkout()`;
- restricted it to the authenticated customer and pending retail order;
- hardened `customer_cancel_retail_order()`;
- cancellation now releases linked reserved listings;
- cancellation returns linked reserved inventory assets to `listed`;
- cancellation cancels active payment attempts;
- customer credit is not modified.

Migration `20260926143000_retail_stripe_cancel_release`:

- successful external retail payment now moves the linked listing to `sold`;
- successful external retail payment now moves the linked inventory asset to `sold`;
- Stripe Checkout expiration/cancellation can cancel an unpaid retail order and release its reservation.

### Front end

Changed:

- `customer-basket.js`
- `customer-basket.html`

The Basket now:

- persists the pending retail order ID in `tradeflow_customer_pending_retail_order`;
- validates that a resumed pending order belongs to the current Basket listing;
- supports **Cancel purchase** for a pending order;
- returns a cancelled Stripe payment to the Basket;
- allows retry against the same valid pending order rather than silently creating a second order;
- keeps unpaid purchases out of My Orders and My Sale.

Cache version: `customer-basket.js?v=2`.

### Stripe

Existing functions retained:

- `create-stripe-checkout-session` — version 11
- `stripe-payment-webhook` — version 5

No new payment architecture was introduced.

The Stripe checkout function now validates pending orders with the dedicated checkout RPC and sends Stripe cancellation back to the Basket.

## Required lifecycle

Shop → Product → Buy this item → Basket → Proceed to payment → pending retail order → Stripe/customer credit → successful server-side payment → paid retail order → listing sold → inventory sold → My Orders.

Cancellation:

Basket → Cancel purchase / Stripe cancelled → retail order cancelled → listing reservation released → inventory reservation released if applicable → no credit deduction → product available again.

My Sale remains exclusively the customer selling-to-business workflow.

My Orders remains exclusively paid retail purchase history.

## Verification state

- Database lifecycle test: passed for pending-order lookup, payment-attempt creation, cancellation, listing release and payment cancellation; customer credit remained unchanged.
- GitHub: implemented.
- Supabase database: live verified.
- Edge Functions: live versions verified.
- Browser: **not yet verified**.
- Test One: frozen and not altered.

## Browser test

Use Camerashack → What We Sell → EOS R1 Body Only.

1. Open product.
2. Click Buy this item.
3. Confirm Basket opens.
4. Confirm £55 customer credit remains visible.
5. Confirm payment options.
6. Proceed to payment.
7. Confirm Stripe Checkout now opens.
8. Cancel Stripe payment.
9. Confirm return is to Basket, not My Sale.
10. Confirm Cancel purchase releases the product.
11. Confirm the pending order becomes cancelled and listing returns to published.
12. Confirm credit remains £55.
13. Re-add the product and retry payment.
14. Complete a genuine successful payment.
15. Confirm My Orders shows the paid order.
16. Confirm My Sale does not contain the retail order.
17. Confirm the product leaves the shop after successful payment.

Do not claim browser verification until these steps have actually been exercised.


## Follow-up browser finding — customer credit payment

The first browser verification reached the Basket payment screen successfully, confirming the earlier checkout-boundary repair. Selecting **Use customer credit** then produced:
`new row for relation "payment_records" violates check constraint "payment_records_payment_type_check"`.

Root cause: `customer_pay_retail_order_with_credit()` used `payment_type='customer_credit'`, but the live `payment_records_payment_type_check` allows `customer_payment` and the payment method is represented separately.

Repair: migration `20260926160000_fix_retail_credit_payment_type` changed the function to use:
- `payment_type = 'customer_payment'`
- `payment_method = 'customer_credit'`

No payment was consumed while repairing this fault. The existing £55 credit remains available for the next browser test.

**Next browser test:** return to the Basket, select **Use customer credit**, click **Proceed to payment**, and verify that the order completes to My Orders and the credit reduces by the purchase amount. If this succeeds, continue with the Stripe cancellation/retry test separately.


## Browser finding — unpaid checkout was reserving stock

The browser test confirmed the product reached Basket/payment, but the live database showed the EOS R1 listing had been changed to reserved as soon as the pending retail order was created. This was not acceptable: a customer could leave the purchase incomplete while preventing another customer from buying the product.

Repair applied:

- customer_create_retail_order() no longer reserves the listing.
- customer_create_retail_order_from_basket() no longer reserves listings.
- A pending retail order does not remove the product from the live shop.
- Customer-credit payment locks and validates the published listing immediately before deducting credit.
- External payment completion checks listing availability before accepting the sale. A conflicting paid Stripe checkout is refunded and its unpaid retail order is cancelled.

The current unpaid EOS R1 test order was cancelled. Live verification after reset:

- listing: published
- reserved_at: null
- pending retail orders for the test customer: 0
- customer credit: £55
- no payment consumed.

The Nikon COOLPIX P1100 card visible under My Sale is a separate trade-in/selling workflow record (purchase_stage=purchased). It was not deleted or altered as part of the retail-stock reset. The retail purchase lifecycle is now being tested separately.

Next test: return to the EOS R1 product on the live shop, add it to Basket, proceed to payment, and confirm that the product remains visible/purchasable while the payment is still incomplete. Then complete customer credit payment and verify the listing changes to sold only after payment.


## Browser finding — customer credit path required subscriber membership

The next browser test exposed a separate defect after the payment-type repair: selecting **Use customer credit** returned **Tenant membership required**.

Root cause: `customer_pay_retail_order_with_credit()` called `transition_workflow_entity()`. That helper is intentionally subscriber/operator-only and requires tenant membership. A customer is correctly authenticated to their tenant through the `customers.auth_user_id` relationship but is not a subscriber tenant member.

Repair: migration `20260926180000_customer_credit_checkout_transition` records the `pending_payment → paid` retail-order workflow transition directly inside the customer SECURITY DEFINER RPC instead of calling the subscriber-only helper. No tenant membership was granted to the customer and no security boundary was weakened.

The first post-repair rollback-only authenticated SQL test then exposed a second PL/pgSQL issue: the RPC return column is also named `status`, so unqualified `status` references in the listing/inventory UPDATE predicates were ambiguous.

Repair: migration `20260926181000_fix_customer_credit_checkout_update_ambiguity` qualifies those UPDATE targets and predicates.

Rollback-only authenticated verification now returns the expected result for the current EOS R1 pending order:
- status: `paid`
- amount: £49.91
- remaining credit: £5.09

The test was rolled back. Live state remains:
- retail order: `pending_payment`
- payment status: `unpaid`
- amount due: £49.91
- EOS R1 listing: `published`
- customer credit: £55.00

No live credit was consumed by the verification.

**Next browser action:** on the existing Basket payment screen, select **Use customer credit** and click **Proceed to payment**. The previous Tenant membership error and SQL status ambiguity have both been repaired and rollback-tested. Browser verification is still required before declaring the genuine payment complete.


## Follow-up — paid order detail and subscriber dispatch workflow

The successful customer-credit payment was confirmed for the Test Two EOS R1 purchase. The order is paid for £49.91 and customer credit is now £5.09. The paid order remains separate from the customer's trade-in/My Sale workflow.

A new retail fulfilment lifecycle is now in place. Paid retail orders create a `fulfilments` record in `awaiting` state. The current Test Two order `ORD-20260926-71DCBDEC` has fulfilment `FUL-17C5EB082D09` in `awaiting` state.

Customer My Orders has been expanded to show:
- order reference and paid status;
- every purchased item and line value;
- order total;
- fulfilment state;
- carrier/tracking details when dispatched.

Subscriber Selling now has a separate **Sold** section. Paid listings appear there rather than being treated as available stock. The Sold section provides a **CREATE SHIPPING LABEL** link into the Fulfilment workspace and a **MARK AS SENT** action once the fulfilment has reached `label` status.

The Fulfilment workspace now accepts a shipping label URL and can move `awaiting → label`. Marking the parcel as sent moves `label → dispatched`; the customer portal then displays **Shipped** and the tracking number/link.

Migration `20260926200000_retail_order_fulfilment_and_multi_item_payment` also hardened payment for multi-item orders: all retail order items must still be published/available before customer credit is deducted or an external payment is accepted. No partial basket payment is permitted.

GitHub browser code updates were committed for the customer order view, Selling Sold section, and Fulfilment workflow. Frontend cache versions were bumped. Browser verification of the new Sold/Shipping UI is still required; database state has been verified for the current paid order and fulfilment.


## Follow-up browser finding — Selling Sold section RLS

Browser verification showed the customer My Orders detail is loading correctly, with the Test Two order displayed as **Preparing shipment**. The new Selling Sold section initially failed with permission denied for table retail_order_items, and the sold EOS R1 also remained visible in the general listings table.

Root cause: the first Sold implementation queried retail_order_items, retail_orders and fulfilments directly through the subscriber REST session. Those tables are not intended to be exposed through the direct browser query used by this workspace.

Repair: migration 20260926203000_subscriber_sold_retail_items_rpc adds subscriber_get_sold_retail_items(p_tenant_id), a SECURITY DEFINER subscriber-only RPC that checks tenant membership and returns the sold listing/order/fulfilment data needed by the Selling page. The Selling page now uses that RPC. The general Available listings query also explicitly excludes sold and delisted, and the status filter no longer offers sold; sold products belong only in the separate Sold section.

Frontend cache version was bumped to selling-dashboard-fixed.js?v=32. JavaScript syntax was verified after the repair. Browser verification of the repaired Sold section is still required.


## Follow-up — Sold section field-shape repair

Browser verification then exposed a second frontend issue: the subscriber Sold RPC returns flat columns (`fulfilment_id`, `fulfilment_status`, `order_id`, `order_reference`, etc.), while the renderer was treating each row as nested `order` and `fulfilment` objects. This caused `Cannot read properties of undefined (reading 'id')`.

The renderer and dispatch handler have been corrected to use the actual flat RPC response shape. Selling cache version is now `selling-dashboard-fixed.js?v=34`. JavaScript syntax verified OK.

## Follow-up — shipping provider handoff and fulfilment RLS

Browser verification showed two further issues: the green action-required styling did not match the customer dashboard's standard green shade, and the Selling shipping link opened the generic Fulfilment page without the saved shipping providers. The Fulfilment page also queried `retail_orders` directly and returned `permission denied for table retail_orders`.

Repair: the customer preparing-shipment card now uses the same `#f1f8f3` green background used by the subscriber action-required shipping UI. Fulfilment now loads saved services from `subscriber_get_shipping_service_settings()` and presents the selected provider links before the fulfilment form, so the subscriber can open the configured provider, create/buy the label there, then return to TradeFlow to record the label/tracking details. A new subscriber-only SECURITY DEFINER RPC, `subscriber_get_fulfilment_orders(p_tenant_id)`, replaces the direct browser query against `retail_orders` and enforces tenant membership.

Fulfilment frontend cache version is now `v4`. Browser verification of the provider cards and the complete external-label handoff remains the next test. The SQL tool cannot execute the subscriber RPC without an authenticated user context, so live RPC execution was not falsely reported as tested; the function was applied successfully and granted to authenticated users.

## Follow-up — Fulfilment page still showing legacy retail_orders RLS error

The next browser screenshot still showed the legacy `permission denied for table retail_orders` message and did not show the new Shipping Service provider section. This indicates the browser was loading the previous Fulfilment UI/script rather than the repaired version.

The repair has been hardened further: the Fulfilment page now uses subscriber-only SECURITY DEFINER RPCs for both orders and fulfilments, so the browser no longer needs direct access to either `retail_orders` or `fulfilments`. New RPC: `subscriber_get_fulfilments(p_tenant_id)`. Existing `subscriber_get_fulfilment_orders(p_tenant_id)` remains the order source. Fulfilment JavaScript cache version is now `v5`.

The Fulfilment HTML also contains the Shipping Service provider section sourced from the saved Shipping Settings services. Browser verification must confirm that the current deployed HTML shows those provider cards; the screenshot supplied after the previous repair was still the legacy page and therefore did not test the new code.

## Follow-up — Retail sale shipping handoff repaired — 26 September 2026

The Fulfilment screenshot exposed two separate defects in the first retail dispatch implementation: the page was still attempting direct browser access to fulfilments, producing permission denied for table fulfilments; and the form did not expose the information required to actually purchase a parcel service: the sold item, recipient/delivery address, weight, parcel dimensions, printable label, printable QR code, carrier/service, tracking and customer instructions.

The repair now mirrors the existing subscriber-managed Buying shipping handoff rather than introducing a second shipping model.

Live database changes:
- fulfilments now stores the retail shipping method/provider/service URL, instructions, label storage path, QR URL/storage path and customer-sent timestamp.
- Existing fulfilment_parcels is used for the packed parcel's weight and L/W/H measurements.
- subscriber_save_retail_fulfilment_shipping() is the server-side write boundary. It requires subscriber fulfilment permission, validates the paid retail order, persists the label/QR and parcel details, and moves awaiting → label.
- subscriber_transition_retail_fulfilment() is the server-side status transition boundary for dispatch/delivery/return.
- subscriber_get_retail_fulfilment_shipping() returns the complete subscriber fulfilment view, including order items, inventory references/condition, recipient, address, shipping data and parcel measurements.
- customer_get_retail_fulfilment_shipping() returns the customer-visible retail shipping handoff.
- Customer access to fulfilment label/QR files is restricted to the exact customer's paid retail order in the tradeflow-media bucket.
- A new order_shipping_ready notification template is queued when the shipping handoff is first completed. It includes the order, item(s), service, carrier, tracking, parcel information, instructions and Customer Portal link. Dispatch continues to queue the expanded order_dispatched notification.

Shipping research confirms why the parcel fields are required: Parcel2Go requires accurate weight and dimensions, including packaging, and warns that under-declared measurements can lead to surcharges. Royal Mail Click & Drop likewise requires shipment weight and packaging information before a label is generated. QR/print-in-store services are supported by Parcel2Go and selected courier services.

Current Test Two live state remains unchanged:
- order ORD-20260926-71DCBDEC
- fulfilment FUL-17C5EB082D09
- fulfilment status awaiting
- no label/QR has been uploaded
- no parcel measurements have been recorded.

GitHub frontend changes:
- Fulfilment now has the saved shipping-service cards, full sold-item details, recipient/address, parcel measurement fields, label/QR upload and view/print controls, tracking and instructions, plus status controls.
- Customer My Orders now consumes the retail fulfilment shipping RPC and can display the shipping handoff, parcel details, tracking, label and QR controls.
- Fulfilment JS syntax and Customer Dashboard JS syntax were checked after the changes.

Verification state: Implemented in GitHub; Live DB verified; browser verification still required; checkpoint updated.


## Follow-up — Selling Sold section blank — 26 September 2026

Browser verification showed the Sold section remaining on “Loading sold items…”. Investigation found this was a frontend JavaScript syntax error introduced in the cache-busting change to the Create Shipping Label link. Because the script failed to parse, the entire Selling dashboard stopped executing, so neither Available listings nor Sold listings could populate.

The live subscriber_get_sold_retail_items() RPC was checked separately and the EOS R1 test sale is present:
- listing LST-20260925-FEBC02DC
- product EOS R1 Body Only
- order ORD-20260926-71DCBDEC
- payment status paid
- fulfilment FUL-17C5EB082D09
- fulfilment status awaiting

The broken Sold link expression was corrected and selling-dashboard-fixed.js was syntax-checked successfully with new Function(...).

GitHub cache was bumped:
- selling-dashboard-fixed.js?v=38

The Sold renderer remains based on subscriber_get_sold_retail_items() and therefore will show the paid EOS R1 sale once the deployed page loads the corrected JavaScript.

Verification state: GitHub source fixed and syntax verified; live RPC/data verified; browser deployment verification still required.



## Follow-up — Retail fulfilment handoff UX and save reliability — 26 September 2026

The live retail Fulfilment workspace was reviewed again after browser testing. Two frontend issues were addressed:
- the Selling menu could open into a stale/loading state until refresh; Selling now uses a cache-busted page/JS reference, subscriber auth v8, and a guarded single startup path;
- the retail Fulfilment save flow was too dense and the completion result was not prominent enough.

The Fulfilment workspace is now organised around the actual workflow:
1. choose one of the saved Shipping Settings services;
2. open the provider and create/pay for the shipment there;
3. select the paid order and verify the exact item/customer/address;
4. enter carrier/service/tracking and upload the printable label or QR code;
5. save and send the customer handoff;
6. only after the parcel is actually handed over, mark it sent/dispatched.

Parcel weight and dimensions have been removed from the TradeFlow handoff form. They remain valid packed-shipment data and are retained in the database when previously recorded, but they belong to the provider booking step rather than being duplicated in the final handoff screen. Parcel2Go and Royal Mail both require accurate packed shipment weight/size when generating postage, so those measurements must still be supplied to the chosen provider when booking.

The live subscriber_save_retail_fulfilment_shipping() function was hardened in migration retail_fulfilment_handoff_reliability. It now performs the awaiting → label update directly within the authorised subscriber RPC instead of calling the generic workflow transition function, preserves existing parcel measurements when the simplified UI sends no new measurements, and queues the customer shipping notification as before.

GitHub changes:
- fulfilment-dashboard.html redesigned with clearer provider/order/handoff sections;
- fulfilment-dashboard.js rebuilt with visible validation/error handling and a single reliable save path;
- selling-dashboard.html cache/auth references refreshed;
- selling-dashboard-fixed.js startup guarded against duplicate/race initialisation;
- migration source added as supabase/migrations/20260926223000_retail_fulfilment_handoff_reliability.sql.

Verification state: Live migration applied successfully; frontend syntax checked; browser verification still required for the deployed GitHub Pages version.



## Follow-up — Customer retail shipping visibility and return flow — 26 September 2026

Browser review clarified the customer-side retail fulfilment experience. Customers are recipients of a purchase, not the sender. They do not need the business's printable shipping label or courier QR code in My Orders.

Customer My Orders now shows the retail shipment status, shipping service/carrier and tracking number. The existing subscriber dispatch transition already queues the order_dispatched customer notification containing the item, carrier/service, tracking and Customer Portal link. Customer label/QR view-and-print controls have therefore been removed from the retail customer order card.

The customer can request a retail return only after the subscriber marks the fulfilment as delivered. The Customer Portal provides a Create a return action for delivered order items, with a reason and optional notes. The server-side customer_request_return() boundary was corrected to use return_type='customer_retail' and now enforces delivered fulfilment status and prevents duplicate active return requests.

A separate startup race was found in Customer Portal authentication. customer-dashboard.js was calling customer_get_profile before customer-auth.js had finished restoring/validating the stored session. This could briefly show “This login is not registered for this business” and then disappear after refresh. The Customer Portal now loads customer-auth before customer-dashboard and waits for the authentication-ready promise before the initial profile check. The dashboard also guards against duplicate portal loads.

Verification state: live return RPC applied; frontend syntax checked; browser verification required.


## 2026-09-26 — Retail Mark as Sent / customer dispatch handoff repair

- Selling → Sold → **MARK AS SENT** is now one atomic server-side action.
- The action advances the paid retail order from `paid` to `fulfilment` and the fulfilment from `label` to `dispatched` in the same transaction. The browser no longer performs a second retail-order transition after the fulfilment RPC, preventing the previous post-success failure that could leave the button apparently non-responsive.
- On dispatch, TradeFlow retains the carrier/service and tracking number, derives an official carrier tracking-page URL when none was supplied for supported carriers, and queues the `order_dispatched` customer notification with the tracking information.
- Customer My Orders remains recipient-focused: no outbound label/QR controls. Once dispatched it shows the shipping service/carrier, tracking number, and an explicit **Track item →** link when a tracking URL is available.
- After **MARK AS SENT**, Selling → Sold should show the shipment as **Shipped** with no further outbound action. Return handling remains a separate customer-return workflow and should only become actionable when a return has actually been requested.
- Production migration: `20260926225000_retail_fulfilment_mark_sent_atomic`.


## 2026-09-26 — Customer order collapse and storefront image fit

- Customer Portal **My Orders** now renders each paid retail order as a native collapsible order card. The collapsed header retains order reference, status and total; opening the order reveals items, shipping service/carrier, tracking, fulfilment information and any eligible return action.
- Storefront product-card image boxes now use `object-fit: contain` so the complete product photograph is visible within the box rather than being cropped. Product-detail gallery behaviour remains unchanged.
- Cache versions were bumped: Customer Portal CSS/JS to `v9`/`v125`; public storefront CSS to `v66`.


## 2026-09-26 — Mixed customer credit + card checkout

- Retail checkout now supports applying available customer credit first and charging the remaining balance by card. Example: a £75 purchase with £5.09 available credit presents £5.09 customer credit and a £69.91 card payment.
- Customer-facing payment wording is provider-neutral: **Credit or debit card**. The customer does not need to see the Stripe provider name.
- Customer credit is held against the retail order while the card payment is open. The hold is released if the card payment fails/expires or the customer cancels; it is actually deducted and posted to the ledger when the card payment succeeds. This prevents losing credit when a card checkout is abandoned.
- If available customer credit covers the entire purchase, the order is completed using customer credit alone without opening card checkout.
- The customer credit account display now reports available credit after active checkout holds.
- Current customer checkout supports customer credit plus card payment. Other payment methods can be added later behind the same provider-neutral customer-facing approach, but they are not currently wired into this retail checkout.


### 2026-09-26 mixed-payment stale card-attempt recovery
- Root cause found in live logs: the mixed-payment credit RPC correctly refused to apply credit when the pending retail order already had an active card payment attempt. This was the previous single-payment checkout attempt, not a credit-balance problem.
- Customer checkout now detects that specific stale active-card condition, cancels the old pending purchase through the normal customer cancellation RPC, creates a fresh pending checkout order, and reapplies customer credit before starting the new card payment.
- The external payment event handler now returns a conflict result when a locally cancelled Stripe payment later reports paid, allowing the Stripe webhook conflict path to refund rather than silently accepting the payment.
- The customer basket cache was bumped to customer-basket.js?v=4.
- Do not treat an active Stripe attempt as reusable after the customer has changed the payment mix; the order must be restarted so the card amount is recalculated from the remaining balance.



### 2026-09-26 subscriber-controlled Stripe payment methods
- Subscriber Business Settings now contains a **Stripe checkout payment methods** section.
- TradeFlow seeds four tenant-scoped Stripe checkout controls: **Credit or debit card**, **Link**, **Klarna**, and **Amazon Pay**. Card is the required base method; the other three can be enabled or disabled by the subscriber.
- The Stripe Checkout Edge Function now reads the tenant's enabled methods and sends Stripe's `allowed_payment_method_types[]` filter. Stripe still determines whether an enabled method is eligible for the particular customer, country, currency, device and transaction.
- **Apple Pay is not an independent toggle in this TradeFlow integration.** Stripe documents Apple Pay as a wallet with no API enum, while Link and Amazon Pay have API enums. Apple Pay therefore remains controlled by Stripe's wallet/card eligibility and cannot be independently hidden by the TradeFlow subscriber while card payments remain enabled.
- Production migration: `20260926233000_subscriber_stripe_payment_method_controls`.
- Edge Function deployment: `create-stripe-checkout-session` version 12.
- GitHub commits: settings UI `d78d47c382a3addcf1f7d67023b6aca9f9b1aab5`, settings logic `b7ab025c715a4ad95480b81333975a17ff1b6267`, Stripe checkout function `c173c05908d5699e82c0a0acb4002426efef248a`, migration source `9394bc3e29b7278ea59e7c53756fea46e0990557`.
- Camerashack currently has all four controllable methods enabled.


### 2026-09-26 — Business workflow retail sales count repair
- The subscriber Business Dashboard workflow counts were reading legacy `orders` and `fulfilment_orders` REST resources that are not the live retail sales tables. Because failed REST requests were converted to empty arrays, the dashboard incorrectly displayed **Orders 0** and **Fulfilment 0** even though live retail orders existed.
- Added `subscriber_get_business_workflow_counts(uuid)` as the tenant-scoped dashboard read boundary. It counts live `retail_orders`, `fulfilments`, listings, inventory, buying and returns.
- A paid retail order with no fulfilment yet, or a fulfilment in `awaiting` / `label`, is counted as **Fulfilment — SALE TO PROCESS**. Orders counts paid/fulfilment retail orders that are not cancelled/completed.
- The Selling card continues to represent active unsold listings, so it can correctly remain 0 when all listings are sold. Retail shipping work belongs in Fulfilment.
- Production migration: `20260926234000_business_workflow_retail_counts`.
- Dashboard fix commit: `a81d1829e0f9bb4651d26ac4a834e4b66643e447`.


### 2026-09-26 — Customer My Sale collapsible items
- Customer Portal **My Sale** now renders each sale/valuation as a native collapsible `details` item. The compact summary keeps the item, stage and status visible; the workflow timeline, offer information and shipping actions expand below it.
- Items are collapsed by default to keep the portal compact when a customer has multiple sale records. The existing green/current styling and actions are preserved.
- Customer dashboard cache bumped to `customer-dashboard.js?v=126`.
- GitHub commits: JS `d5678bf53e5639e158e2484fb783c246203cced8`, HTML `f19473237527180294bd35023b9adaba6866468b`.
