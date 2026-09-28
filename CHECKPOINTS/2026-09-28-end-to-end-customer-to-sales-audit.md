# TradeFlow — End-to-end customer valuation → sales audit — 2026-09-28

## Audit scope
Full trace of the current customer selling journey through subscriber Buying, valuation, offer, shipping, receipt, inspection, payment/acquisition, Inventory, Selling, published storefront, retail order/fulfilment boundary, using:
- current GitHub code;
- live Supabase state;
- current System Handbook;
- Human User Manual;
- AI Operating Manual;
- Subscriber Dashboard Diagnostic Roadmap;
- Master Roadmap;
- recent checkpoints and recent commits.

Test One remains frozen.

## Documentation finding
The documentation set is useful but contains historical sections that must not be treated as current instructions. The System Handbook explicitly states that current GitHub + live Supabase + checkpoints + verified behaviour take precedence. The current manual also contains older Parcel2Go/integrated-shipping history; the current shipping architecture at the top of the handbook/manual is subscriber-managed manual handoff.

## Stage-by-stage result

### 1. Customer valuation submission — PASS at live DB boundary
The current public valuation journey was traced through `public-site.js` → `customer-selling-submit` Edge Function → `customer_submit_buying_request`.

A fresh request created during this audit is live:
- Request: `BR-9FBCBE5008`
- Buying item: `BI-63F5AAA6AB`
- Item: Nikon Nikkormat EL Standard
- Customer: `CUS-8A7207206F56`
- Source: `customer_portal`
- Submitted: 2026-09-28 14:05:08 UTC
- One customer photograph is linked.
- Buying request and item both have authoritative `draft → submitted` workflow events.

Therefore the user's recent redirect to Customer Account occurred after successful submission; it is the intended post-submit handoff, not evidence that the request was lost.

### 2. Subscriber Buying intake — PASS at code/DB boundary
`subscriber_get_business_workflow` includes submitted requests when request status is submitted/under_review/valued/offer_ready, even when purchase_stage is `none`. The new request therefore has a valid path into Buying.

### 3. Valuation — BLOCKER / architectural gap
The new buying item has `buying_product_id = NULL`. The customer selling submission stores the customer's category/model/package as text in the buying item description but does not map the selected catalogue product to `tenant_buying_products`.

The live valuation function `calculate_buying_item_valuation` explicitly returns:
`mode='manual', reason='product_not_selected'`
when `buying_product_id` is null.

Therefore the new customer journey cannot automatically use the selected catalogue product for valuation. It falls into the subscriber's manual valuation path.

This is the first substantive business-workflow gap after the successful customer submission.

### 4. Condition-value mismatch — BLOCKER for some automatic valuations
The public selling wizard currently submits condition values including:
- `factory-sealed`
- `opened-unused`
- `excellent`
- `good`
- `fair`
- `damaged`
- `not-working`

The live valuation function expects:
- `sealed`
- `opened_never_used`
- `excellent`
- `good`
- `poor`

Thus only some customer condition values map to the valuation engine. Good/excellent work; sealed/opened/poor/fair/damaged/not-working are not consistently compatible with the current valuation rules. This needs one authoritative condition vocabulary rather than another UI-only translation layer.

### 5. Initial offer — IMPLEMENTED, browser verification still required
Subscriber Buying uses the existing trading_values/offers workflow and `transition_workflow_entity` to move valuation draft → approved and offer draft → published. Customer acceptance uses `customer_accept_offer_choice`, which correctly selects cash or trade-in amount from the linked trading value and moves the buying item to `awaiting_item`.

### 6. Shipping handoff — IMPLEMENTED, browser verification required
Current architecture is manual subscriber-managed shipping. Buying uses `subscriber_publish_buying_item_shipping_handoff`; customer uses `customer_mark_buying_item_posted`; subscriber receipt uses `subscriber_mark_buying_item_received`.

Recent shipping UI repairs are present. The latest end-to-end audit did not browser-test a fresh new valuation through this stage.

### 7. Receipt → inspection — IMPLEMENTED at live DB boundary
The live inspection RPC requires:
- buying.manage;
- purchase_stage = inspection;
- explicit customer-description confirmation;
- explicit condition confirmation.

It records the inspection and moves accepted inspections to `final_offer_required`, testing to `testing`, repair to `repair`, and refusal to `return_pending`.

### 8. Post-inspection decision/payment — IMPLEMENTED at live DB boundary
The current payment repair allows the original accepted initial offer to be paid when the item remains at `final_offer_required`, while revised final offers use `final_offer_accepted` and an accepted final offer.

The live Camerashack C70 and Pentax test records prove this path has created payment/acquisition/inventory records:
- C70: acquisition `paid`, payment £60, inventory `ready_for_sale`.
- Pentax: acquisition `paid`, payment £85, inventory `ready_for_sale`.

The payment path is therefore not currently blocked at the database boundary.

### 9. Purchase → Inventory — PASS at live DB boundary
`subscriber_complete_purchase` atomically creates:
- payment record;
- acquisition;
- acquisition item;
- inventory asset;
- customer payment notification event;
- purchased buying-item state.

The resulting inventory asset is `ready_for_sale`.

### 10. Inventory → Selling — IMPLEMENTED, browser verification required for a fresh item
Selling correctly loads the purchased Inventory asset, original Buying information, customer details, inspection information and media, and creates a listing tied to the physical Inventory asset.

A current code-risk remains: the Selling controller directly PATCHes `inventory_assets.status` to `listed` after publishing rather than using the central `transition_workflow_entity` for that status synchronization. Existing lifecycle guards/RLS still protect the table, but this is a weaker boundary than the documented central workflow authority and should be verified before changing it.

### 11. Selling → public website — PASS historically / fresh browser verification required
The current storefront only exposes actually published listings through the controlled public listing RPC. The live Nikon test proves a listing can reach `published` and then `sold`; the public renderer uses published listings rather than Inventory status alone.

### 12. Retail order → fulfilment — IMPLEMENTED with existing Test Two evidence
Current paid orders and dispatched fulfilments exist for Camerashack. The Orders workspace was recently repaired to use the authorised `subscriber_get_fulfilments` RPC rather than direct fulfilment table access.

The current two dispatched orders are being presented as completed in the archive without falsifying their underlying retail-order status.

### 13. Completed Orders archive — IMPLEMENTED, browser verification required after latest repair
The archive is now separate from Active Orders and has a Business Dashboard link. The first archive build had a renderer syntax error and then a direct fulfilment-table permission error; both have been repaired.

### 14. Email/notification boundary — BLOCKED
Live `notification_queue` still contains queued `order_shipping_ready` and `order_dispatched` events with `sent_at = null`. Current platform email settings show Resend enabled but sender verification remains pending. The previously observed notification processor auth failure remains an unresolved delivery boundary.

This does not prevent portal/database state transitions, but it means email delivery cannot be treated as working end-to-end.

## Authentication architecture risk
The customer authentication repair is correctly tenant-scoped in sessionStorage.

However, the subscriber authentication runtime still persists `tradeflow_subscriber_session` and `tradeflow_subscriber_tenant_id` in localStorage, while the project testing rules call for independent tab-local sessions. Buying/Selling also retain legacy localStorage fallbacks. This is a latent multi-account/session isolation risk and should be consolidated before broad multi-account testing.

## Code repair made during this audit
The public valuation handoff helper in `public-site.js` was updated to read the tenant-scoped customer session from sessionStorage, matching the current customer-auth architecture. The public-site script cache was bumped.

Commits:
- `2604761360f223c21059ce5e1312e30ace2dc2aa`
- `193dddfa1290d947a39a020bb98afa87453b3099`

## Overall audit conclusion
The customer-to-subscriber submission boundary is now working in live data. The first real business-flow blocker is **catalogue product binding/valuation authority**, followed by the **condition vocabulary mismatch**.

The later stages have working server-side workflow authority and existing completed test evidence, but a fresh customer valuation has not yet been walked through every stage in the browser.

## Next controlled test
Do not patch Inventory/Selling yet.

First resolve or deliberately define the catalogue-binding/valuation boundary, then run one fresh item through:
Customer submission → Subscriber Buying → valuation → offer → customer acceptance → shipping → customer dispatch → subscriber receipt → inspection → payment/final-offer decision → purchased → Inventory → Selling → published website.

Record each stage as:
**Implemented in GitHub / Live DB verified / Browser verified**.
