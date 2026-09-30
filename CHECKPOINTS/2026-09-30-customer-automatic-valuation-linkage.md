# TradeFlow checkpoint — 2026-09-30 — Customer automatic valuation product linkage and research fallback

## Problem
A customer completed the public valuation journey for a product configured for automatic pricing, but the subscriber Buying workspace showed no product-specific research and no customer price was created.

## Root cause
The public Buying Catalogue RPC did not return the exact subscriber Buying Catalogue product ID. The public valuation wizard therefore submitted only category/manufacturer/model/package text. The customer submission boundary created the buying item without `buying_product_id`, so the valuation engine correctly returned `product_not_selected`.

Research is tenant-scoped and product-scoped. Research from another subscriber cannot be used for Camerashack.

## Repair
- `get_public_buying_catalogue` now returns `product_id`.
- `public-site.js` now resolves the exact selected catalogue product and submits `buying_product_id`.
- `customer-selling-submit` passes that product ID to the customer submission RPC.
- `customer_submit_buying_request` validates that the selected product belongs to the current tenant, is active, and belongs to the selected category.
- When a linked product has an applicable automatic rule and matching UK New/UK Used research, the customer submission now automatically creates and approves the trading value and publishes the initial offer.
- If no applicable research exists, no automatic valuation is created and the request remains in the normal manual valuation workflow.
- Subscriber Buying research display now says exactly `No research for this product.` when no product-specific evidence exists.
- The valuation fallback now says `No research for this product — manual valuation required.`
- Customer submission Edge Function deployed as version 5.
- Public-site cache bumped to v84.
- Buying dashboard cache bumped to v61.

## Current Camerashack verification
The Canon Cinema EOS C50 Camera Body is present in the Camerashack public Buying Catalogue with product ID `26733e54-b06b-4c76-abeb-550ff3f4fcfd`, but the existing failed test item `BI-FC9C2C8F26` is still unlinked and Camerashack currently has no automatic pricing rule or research row for that product.

The only current research row found in the database belongs to tenant `subscriber test 1`, not Camerashack. It must not be copied across tenants.

## Test procedure
1. In Camerashack Buying Catalogue, open the exact Canon Cinema EOS C50 Camera Body.
2. Save a complete Automatic Pricing rule for the desired condition, including its research basis.
3. Confirm research exists for the same Camerashack tenant and exact product.
4. Submit a fresh customer valuation selecting that exact product.
5. Expected with research: buying item is linked to the product, automatic trading value is approved, initial offer is published, and the customer sees the price without staff clicking Check valuation.
6. Expected without research: subscriber workspace shows `No research for this product.`, no automatic price is created, and the item is available for manual valuation.
7. Verify tenant isolation: research from another subscriber is never used.

## Commits
- Database migration: `a4e2b20cda11e87cc388ff5660a12151d58b381f`
- Customer submission Edge Function source: `c4efe508d9527dbc688f4bdbc9341e8f81c0204d`
- Public valuation product linkage: `294aec9f1a0e449514a796645bb4de6a38af4965`
- Public-site cache refresh: `13c4babe5c512bccc96e063c8a6b6ac65fe7288b`
- Buying dashboard no-research fallback: `d9b8e657c3773069991be1f37505cc75de798785`
- Buying dashboard cache refresh: `05bcd7dd1438f8e81971ccb17b003e66b8d80f8f`


## Follow-up failure found during end-to-end retest
After the first repair, a fresh customer submission reached the final step but failed with: selected buying product is not active for this subscriber.

The exact cause was an ID mismatch:
- get_public_buying_catalogue was returning the master catalogue product ID.
- customer_submit_buying_request expects the subscriber's tenant_buying_products.id.
- Camerashack C50 master product ID: 26733e54-b06b-4c76-abeb-550ff3f4fcfd.
- Camerashack C50 tenant buying product ID: a10a230b-02fa-4a14-a545-39a2641aa592.

A second compatibility issue was also identified: the public wizard submits opened-unused, while the automatic pricing rules use the canonical key opened_never_used.

## Follow-up repair
- get_public_buying_catalogue now resolves the public selection to the active subscriber tenant_buying_products.id.
- The public catalogue only exposes a selected product when a matching active tenant buying product exists.
- customer_submit_buying_request now normalizes current customer-facing condition values to the canonical automatic-pricing rule keys, including opened-unused to opened_never_used and factory-sealed to sealed.
- Current Camerashack C50 automatic rule is present:
  - opened/never used: 65%
  - reference: UK new
  - excellent: 60%, UK used
  - good: 50%, UK used
  - poor: 40%, UK used
  - sealed: 70%, UK new
- Current Camerashack C50 research is present:
  - UK new observed price: £2,549
- Therefore an opened/never-used fresh C50 submission should calculate £1,656.85 (65% of £2,549), approve the automatic trading value, publish the initial offer, and return the customer to the customer dashboard.

## New commits
- Public catalogue tenant-product linkage migration: 0676a39fae11955afee8d40541678f2cfeea830f
- Condition normalization migration: 5b68fbda4180f10b295d0771e0fc8ea51495c998


## Automatic pricing basis clarified — 30 September 2026
The intended pricing rule is now explicit: every automatic condition percentage is calculated against the latest **UK New** research price for the same subscriber and exact buying product.

- Sealed: percentage of UK New
- Opened / Never Used: percentage of UK New
- Excellent: percentage of UK New
- Good: percentage of UK New
- Poor: percentage of UK New
- UK Used research is view-only evidence and is never an automatic calculation basis.
- If UK New research is unavailable, automatic valuation falls back to manual valuation.
- Automatic pricing configuration now forces all condition reference fields to `uk_new` and the Buying Catalogue editor no longer allows a UK Used automatic basis.
- The subscriber-side `calculate_buying_item_valuation` function now uses UK New only, matching the customer-submission automatic path.

For the current Camerashack C50, UK New research is £2,549. The configured 60% Excellent rule therefore has an expected automatic price of £1,529.40. A fresh Excellent customer submission should now use that amount automatically.

## New commits
- Automatic pricing UK New-only database migration: c37bd475cf4eb72b17ce63f9c7b950ea7646244d
- UK New-only valuation calculator migration: 70bb6186a79e99a338bd1901b47756036753c772
- Buying Catalogue UI: 83fa1491a8896c021bc29141e5a984cd0732dbe7
- Buying Catalogue cache refresh: 80ae99a63e0355410ba0ad2bbe2313a14609eca4
- Human manual update: 0d1f23e6346ee82c106f4eee9692b9e98d12f1b2
- AI operating manual update: 3f38a9d823db3e9cbd7e095ce02193cb50de1316


## Buying valuation controls repaired — 30 September 2026
The Buying dashboard now supports the complete pre-acceptance valuation decision:
- Automatic valuation can be checked and published idempotently without creating duplicate initial offers.
- Manual override is available even when an automatic valuation exists; it replaces/supersedes the previous approved valuation and any published initial offer, then publishes the manual offer.
- Refuse valuation is available for both automatic and manual valuation paths before purchase/fulfilment. A published initial offer is marked refused and the buying item is moved to the refused section.
- Existing items created before the automatic valuation fix can be rechecked; if an approved valuation exists but no offer exists, the dashboard can now create the offer and mark the item offer-ready.

TEST commits:
- Buying valuation controls: d5a3539aa641f0d8e819314218430d4f5fa5562f
- Buying dashboard cache: 0bbd9cef5dd942ca25b86045c9df752833a861d3
- Valuation/refusal RPCs applied in TEST migrations 20260930170000_buying_valuation_override_refusal_flow and 20260930171000_manual_buying_valuation_override


## 2026-09-30 — Valuation refusal and customer notification repair

### Reported issue
- Buying dashboard showed **Use manual override** and **Refuse valuation**, but the buttons inserted after the valuation result were inactive.
- A business must be able to cancel/refuse an automatic valuation after it has been created, including while an offer is ready, a shipping label has been issued, or the item is in the shipping handoff stage.
- The customer must be told clearly that the business is no longer proceeding with the item.

### Root causes
1. `buying-dashboard.js` bound `data-act` buttons only when the stage action HTML was first rendered. The valuation result then replaced/inserted its own buttons asynchronously, so those new buttons had no click handler.
2. `subscriber_refuse_buying_item_valuation` did not send a customer notification and did not explicitly describe the refused state to the customer portal.
3. The refusal function did not restrict the refusal action to the pre-receipt stages where this cancellation path is appropriate.

### Repair
- Added dynamic action binding for buttons inserted by the valuation result.
- Added refusal controls to:
  - automatic/manual valuation result
  - offer-ready stage
  - awaiting-customer shipping-label stage
  - customer-dispatched shipping stage
  - manual offer stage
- Refusal is allowed only before physical receipt: `none`, `submitted`, `under_review`, `valued`, `offer_ready`, `awaiting_item`, `shipping`.
- Once the item is physically received, the existing inspection/refusal/return workflow remains the correct path.
- Refusal sets `buying_items.purchase_stage = offer_refused`, records workflow transitions, refuses a still-published initial offer, and creates a `valuation_refused` customer notification event.
- Added a system notification template explaining that the business has decided not to proceed and giving return instructions if the customer has already sent the item.
- Customer selling status now displays **Business not proceeding** with a clear explanation.
- Customer dashboard cache bumped to v144.
- Buying dashboard cache bumped to v64.

### TEST commits
- Buying controller: `c5ebf7b7e2e12e8602ef2b30d10954b1bf824c2d`
- Buying dashboard cache: `56dfe5af6043432a59681da6c9547d48b6a51eda`
- Customer dashboard message: `2dd5d82f01dd11da10640793dc6e05508b028101`
- Customer dashboard cache: `2d059fddde91f2421690f941cc32b6f12c3ac6e3`
- Database migration: `valuation_refusal_customer_notification_and_stage_message`

### Required browser test
1. Hard refresh Buying dashboard so v64 loads.
2. Open an automatic valuation.
3. Click **Use manual override**; the manual fields must open.
4. Cancel the override and click **Refuse valuation**; the transaction must move to Refused Transactions.
5. Customer Portal must show **Business not proceeding** and the refusal message.
6. Repeat with an offer-ready/label-ready test item and confirm the refusal button is active.
7. For a shipping-stage test where the customer has confirmed dispatch, confirm the refusal button is active and the customer sees the refusal state.
8. Do not use an already-refused transaction for the acceptance/decline test.



## 2026-09-30 — Dynamic valuation actions and cancelled/refused customer section

### Additional findings
- The valuation buttons were still inactive because the first repair relied on dynamic per-button binding. The safer repair is delegated `data-act` handling at document level, so buttons created after the initial render are always actionable.
- Existing refused transaction `BI-FC9C2C8F26` had `purchase_stage='none'` and an initial offer with `status='refused'`. The customer status RPC therefore fell through to the approved trading value and reported **valuation completed**. This was the reason it remained in the active valuation list.

### Repair
- Buying dashboard now uses delegated action handling for dynamic valuation controls.
- Customer selling status now recognises a refused initial offer even when the older transaction has no `purchase_stage='offer_refused'`.
- Customer dashboard splits `offer_refused` transactions from active sales.
- Active sales remain under **My Sales**.
- A new **Cancelled / Refused** section appears below **My Orders**, using the same expandable sale-card format.
- Refused cards show:
  - item
  - refused/cancelled stage
  - reason/status
  - request reference
  - clear explanation that the purchase will not proceed
  - return-contact instruction if the item has already been sent.
- Customer dashboard cache is now v145.

### TEST commits
- Delegated Buying actions: `a655b3f4957cab7a1466b3ff9d327524b7ddc20c`
- Customer refused/cancelled rendering: `ac40adf61abf5c8c770d715f988e1fad9eb7f616`
- Customer dashboard section: `11a820013a71326b021166dc12fdb4c98a9da9c1`
- Customer dashboard cache v145: `6511519c81d1dcb9c647d842f9149ad499a6d4f8`
- Customer refused-status migration: `2c25a0d359dc0e62ffbe5096ef25131526fe350b`

### Required browser test
1. Hard refresh both Subscriber Buying and Customer Portal.
2. Automatic valuation: click **Use manual override** and verify the manual fields open.
3. Enter a different cash/trade-in value and click **Approve manual valuation & send offer**.
4. Test **Refuse valuation** and verify the item disappears from active My Sales/Buying and appears in Refused Transactions / Cancelled & Refused.
5. Open the customer portal and confirm the refused item is no longer in the active valuation list.
6. Confirm it appears below My Orders under **Cancelled / Refused**, with the same expandable card style and clear refusal explanation.
7. Confirm an older refused transaction such as `BI-FC9C2C8F26` is also correctly classified as refused even though its legacy `purchase_stage` is `none`.


## 2026-09-30 — Root cause found for inactive refusal/manual approval controls

The remaining button problem was a database constraint, not the browser event binding.

### Root cause
`public.buying_items.purchase_stage` had a CHECK constraint that allowed `none`, `awaiting_item`, `shipping`, `received`, `inspection`, `testing`, `repair`, final-offer/payment stages, and `purchased`, but did **not** allow:
- `offer_ready`
- `offer_refused`

Both the manual valuation RPC and refusal RPC update `purchase_stage` to those values. PostgreSQL therefore rejected the update. The refusal transaction rolled back and the customer remained on the old valuation state.

### Repair
- Added `offer_ready` and `offer_refused` to the authoritative purchase-stage CHECK constraint.
- Reclassified the existing legacy refused C50 transaction `BI-FC9C2C8F26` to `purchase_stage='offer_refused'` because its initial offer was already refused.
- Buying dashboard now exposes refusal even in the waiting-for-label shipping branch.
- Initial valuation stage now also offers **Enter manual valuation** and **Refuse valuation**.
- Buying dashboard cache bumped to v65.
- Customer dashboard cache remains v146 and now displays a count beside **Cancelled / Refused**.

### Verification
Current TEST legacy refused item:
- `BI-FC9C2C8F26`
- purchase_stage `offer_refused`
- initial offer status `refused`

### TEST commits
- Buying controls: `368309828990573045fa94bd6690b8a8f7d10826`
- Buying cache v65: `1e46e9ea4ba6a29de6b8d4c964174d1f6aad2a40`
- Customer HTML cache v146: `866b6dab1c1bd5d57e3cbf22f45d48c5fccdc9e3`
- Customer cancelled count: `62434fd8eeb0135ccc37d23cdcf1ef04260cae79`
- Database stage constraint: `1d9e410a1c8493f6bc7614a08e8b33ce2fd8e78d`


## 2026-09-30 — Refused transaction incorrectly counted as active Buying work

### Reported issue
The subscriber Dashboard showed 4 Buying items even though one of them had been refused. That refused item also displayed a £100 valuation, making it appear as a new/random active offer. Clicking **OPEN BUYING** from the dashboard did not reliably take the user into the requested transaction.

### Root causes
1. `subscriber_get_business_workflow` treated every non-`none` purchase stage as active, so `offer_refused` was included in the main Buying workflow.
2. `subscriber_get_business_workflow_counts` counted every non-purchased, non-closed buying item, so `offer_refused` inflated the Dashboard Buying count.
3. The legacy refused C50 transaction `BI-FC9C2C8F26` legitimately still has its historical manual approved valuation of £100 and its initial offer is refused. The £100 was not a new random valuation; it was the old test valuation retained on the refused transaction.
4. The dashboard's OPEN BUYING link supplied a request ID, but `buying-dashboard.js` did not use that request ID to open the corresponding item.

### Repair
- `subscriber_get_business_workflow` now excludes `purchase_stage='offer_refused'` from active workflow results.
- `subscriber_get_business_workflow_counts` now excludes both `purchased` and `offer_refused` from active Buying counts.
- `buying-dashboard.js` now reads the `request` query parameter and opens/scrolls directly to the requested buying item after loading.
- Buying dashboard cache bumped from v65 to v66.
- The historical £100 valuation remains attached to `BI-FC9C2C8F26` as audit/reference data and is no longer part of active Buying workflow counts or active item rendering.

### TEST verification
For Camerashack:
- active Buying items: 3
- refused Buying items: 1
- refused item: `BI-FC9C2C8F26`
- refused stage: `offer_refused`
- refused initial offer: `refused`

### TEST commits
- Database repair migration: `exclude_refused_buying_items_from_active_workflow`
- Buying controller/request navigation: `ad82c67184d3beeb14c366c4f0e5bdcd20c37b5d`
- Buying dashboard cache v66: `84789e865769bfe93377b753dabe7b2debc03ee2`
- Database migration file: `30ffaf2ec161889be0492daca2af7058b1c11e89`


## 2026-09-30 — Buying dashboard direct navigation still failed to load

### Additional root cause
The Buying page still had a legacy fallback to the old `tradeflow_testlab_session` storage key and could begin loading before the authoritative subscriber tenant context had completed. The Dashboard itself uses the subscriber authentication layer, so Buying must use the same source of truth.

### Repair
- Buying now waits for `tradeflowSubscriberTenantReady` before loading workflow data.
- It then explicitly takes the authenticated session, tenant ID and API key from `tradeflowSubscriberAuth`.
- The legacy test-lab session remains only as a harmless fallback inside the controller but is no longer relied on when the subscriber auth context is available.
- Buying dashboard cache bumped to v67.

### TEST commits
- Buying tenant-loading repair: `3c3211a18c3ee97a2b5ce6aeb1263439f8bf4a6f`
- Buying dashboard cache v67: `1b7bfe0b50bd4a65f1e59ce6930e1c99dbaafa5d`

### Browser test
Hard refresh the subscriber Dashboard and click **OPEN BUYING**. The Buying page should now wait for the subscriber tenant context and then load the three active Camerashack Buying items. Dashboard transaction-level **OPEN BUYING** links should additionally open the requested transaction directly.


## 2026-09-30 — Buying dashboard v67 did not execute because of JavaScript syntax error

### Root cause
The Buying dashboard JavaScript contained an unterminated HTML string in the valuation-action block. The line generating the **Check valuation / Enter manual valuation / Refuse valuation** controls ended without the closing single quote for the JavaScript string. Because the browser could not parse `buying-dashboard.js`, none of the Buying page load logic ran, leaving Active items, Completed purchases and Refused transactions permanently showing **Loading…**.

### Repair
- Closed the unterminated valuation-action HTML string.
- Verified the complete `buying-dashboard.js` source parses successfully with the JavaScript constructor parser before committing.
- Buying dashboard cache bumped from v67 to v68.

### TEST commits
- JavaScript syntax repair: `ad95f4c70d75f90959bb593b34e114f31ea53043`
- Buying dashboard cache v68: `4766c04e6b920175e46f6961b0f1e324395f1056`

### Browser test
Hard refresh the Buying page with Ctrl+F5. The page should now execute its load function and replace all three Loading… placeholders with the active/completed/refused transaction lists.


## 2026-09-30 — Inspection refusal now routes to return-to-customer

### Required workflow change
The inspection screen previously required both normal confirmation ticks even when the subscriber was refusing the purchase because the item was not as described. A refusal also went directly to `offer_refused`, which removed the item from the active Buying workflow instead of creating a return task.

### New workflow
- Inspection has a new **Condition not as described** checkbox.
- For normal inspection outcomes, the customer-description confirmation remains required.
- For a refusal, the subscriber must confirm the inspected condition and explicitly tick **Condition not as described**.
- Refusal now moves the item to **return_pending**, not `offer_refused`.
- A tenant-scoped `buying_item_return_shipping` record is created with the refusal reason.
- Buying dashboard shows a **Return item to customer** action.
- Subscriber can upload the return label, enter carrier/service/tracking/tracking URL and send the return tracking update to the customer.
- Return shipping is manual and does not reintroduce Parcel2Go/API shipping.
- Customer Selling status now exposes the return reason, return shipping status, carrier/service, tracking, tracking URL, label path and instructions.
- Customer portal displays the refusal reason and, once shipped, a clickable tracking link and return-label access.
- The current TEST C50 item `BI-9B99D90D5F` has been moved to `return_pending` with reason: **Condition not as described: customer declared Excellent; inspection found Poor.** No return tracking has been entered yet.

### TEST commits
- Buying return workflow: `2c3aec9e4a517d36eaf099eef6cd515992f0a930`
- Buying dashboard cache v69: `b093edc2823258c2d3065af26873432e832b99b4`
- Customer return display/tracking: `9d73de4f1931913ad8ff03b43862b4e77113591f`
- Customer dashboard cache v147: `96d0d46cdf8270d788fe309d5dd79b289f77a32e`
- Return database migration: `564d74a3ec045f5b19d56ed908f2454a9045ffc5`
- Customer return status migration: `c81c1b3900d663fa40634e9bc1e4665fdb79a737`
- Inspection refusal migration: `c59ae8d165057356818c1c9eddc548a9b6eb858a`

### TEST state
`BI-9B99D90D5F` is now at `return_pending`, ready for the subscriber to enter return shipping details. The next test is to upload a return label, enter tracking, send the return update, then verify the same item in the Customer Portal shows the refusal reason and clickable tracking.
