# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 3.3  
**Date:** 17 September 2026  
**Project:** TradeFlow

## 1. Purpose
AI continuity companion for TradeFlow. It records architectural truth, decisions, faults, lessons, verification state and exact stopping point so future sessions resume without guessing.

## 2. Mandatory procedure
For significant work: **Retrieve → inspect current GitHub → inspect current Supabase → identify the first actual failure/boundary → change minimally → test → verify live → document → checkpoint.**

Never rely on chat memory when current code/database state can be inspected. Never modify GearCashOut while working on TradeFlow.

## 3. Non-negotiable rules
- `tenant_id` is the primary security boundary.
- Tenant roles are exactly `owner`, `admin`, `staff`.
- Platform Owner is separate from tenant roles and cannot be self-claimed.
- Subscription capabilities belong to the tenant.
- Customer data remains tenant-isolated.
- Dynamic fields/options are database-authoritative.
- Business status changes use authoritative workflow services/RPCs where provided.
- Accepting an offer is not possession; acquisition, receipt, inspection, payment and inventory are separate steps.
- Do not assume a schema FK means an operational workflow exists.
- Do not mark a feature complete solely because code is committed.
- Do not expose test-lab onboarding as production onboarding.
- Never store secrets in docs or project memory.
- Do not invent `module.finance`; finance uses permission checks and the live capability model actually present.

## 4. Verification states
**Proposed → Implemented → Tested → Verified Live** are separate states. A commit is not live verification. A transactional rollback test proves database behaviour, not a persistent browser journey.

## 5. Current environment checkpoint
- GitHub: `laurendigitaluk/TradeFlow`, `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, `eu-west-2`.
- Recorded health: ACTIVE_HEALTHY.
- Recorded RLS checkpoint: 60/60 public tables.
- Customer security: 34/34.
- Customer subscription tests: Buying 17/17; Selling 17/17.
- Staff security lab: 19/19.
- Hardening sequence through Retail Orders: 044–062, followed by fulfilment/returns hardening and external payment boundary migrations.

## 6. Production onboarding remains OPEN
Development tenant insertion/test-lab onboarding remains separate from the required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## 7. Current operational chain
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer checkout → External Payment → Fulfilment → Returns.**

A separate direct product path now also exists for subscriber inventory: **Category → Product → Properties → Photographs → Inventory lifecycle → Listing → Customer Shop**. This does not require the product to pass through Buying first.

## 8. Category/product foundation
`categories`, `category_fields` and `category_field_options` are the authoritative category/property model. `category-management.html` / `.js` exposes category creation plus product property and option creation.

`inventory_assets.dynamic_values` stores product-specific values for the category fields. Properties can be marked required for Buying or Selling, customer/staff visible and valuation relevant.

Test Business A now contains the active, Buying-enabled and Selling-enabled `Drones` category. This is test data, not a production seed requirement.

## 9. Inventory/media foundation
Inventory remains protected by `guard_inventory_asset_status_entry()` and `transition_workflow_entity()`.

New product creation is exposed in `inventory-dashboard.html`. It creates a `received` inventory asset, assigns a category, stores dynamic property values and can upload multiple photographs.

Media architecture:
- private Storage bucket: `tradeflow-media`;
- `media_assets` stores object metadata and retention fields;
- `inventory_asset_media` links photographs to products;
- `listing_media` links photographs to listings;
- Selling carries inventory media links into a newly created listing.

When an inventory asset or listing enters `sold`, attached media receives `retention_expires_at = sale time + 90 days`. If the item leaves `sold`, the expiry is cleared. This is a retention timer, not yet the physical deletion job.

Physical object deletion must be performed through Supabase Storage. Removing only the `media_assets` row does not reliably reclaim the stored object. The production design is to use a scheduled Edge Function with Supabase Cron/pg_net and a server-side secret; the scheduler is not yet configured.

This means the user's proposed retention strategy is technically sound: after the sale/return period has elapsed, deleting the stored image object will release that storage allocation. Retention must still respect any legitimate operational, accounting, legal or dispute requirements before deletion.

## 10. Finance checkpoint — 059–060 plus external payment boundary
059 applies permission-bound access to payment and ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards.

Finance UI creates payment/ledger records and uses the workflow authority for status changes. No `module.finance` feature is to be invented.

`record_retail_order_payment()` provides the internal subscriber-controlled payment capture path. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`; locks a `pending_payment` retail order; requires payment equal to current `amount_due`; creates an inbound paid payment record and matching posted ledger credit; clears amount due and advances the order to `paid`. This is not an external gateway.

`customer_create_order_payment()` provides the customer-side pending payment-record/idempotency boundary. It validates the authenticated customer owns the pending order, reuses an active pending/processing attempt, and permits a fresh payment record after a failed attempt.

The external payment boundary is implemented with two deployed Supabase Edge Functions: `create-stripe-checkout-session` for JWT-protected server-side checkout creation and `stripe-payment-webhook` for signed Stripe event reconciliation through `process_external_payment_event()`.

### Stripe test configuration checkpoint — 16 September 2026
TradeFlow has a dedicated Stripe Sandbox within the existing Stripe account. The active TradeFlow Payment Webhook listens for the required checkout/payment events. The two Stripe test secrets are configured server-side and are not stored in browser code, GitHub, documentation or project memory.

Configuration is complete for the Stripe test environment, but persistent customer browser payment verification remains open.

## 11. Selling/Listings checkpoint — 061
Selling workspace is implemented against the live schema. It loads active channels, selling-enabled categories and `ready_for_sale` inventory, creates draft listings, advances them to ready and uses the central workflow for subsequent listing lifecycle changes. New listings inherit inventory media links.

## 12. Retail Orders checkpoint — 062
Subscriber Orders and customer checkout are implemented. Customer checkout requires an authenticated active customer, accepts only a published listing, creates a pending-payment order and linked item, reserves the listing and records workflow transitions. Subscriber-recorded payment advances an order to paid and creates its finance records transactionally. External customer payment has a server-side Stripe Checkout boundary and signed webhook reconciliation path.

## 13. Fulfilment checkpoint
Live inspection confirmed fulfilment has subscription-aware `fulfilment.view/manage` access and an existing central workflow. `fulfilment-dashboard.html` / `.js` provides subscriber creation and lifecycle controls.

Lifecycle authority: `awaiting → label → dispatched → delivered`, with dispatched/delivered → returned.

`guard_fulfilment_status_entry()` prevents direct client status edits. No carrier API, shipping-label provider or automatic fulfilment creation is assumed. Customer visibility uses `customer_get_fulfilments()`.

## 14. Returns checkpoint
Returns had overlapping legacy member/admin policies. These were removed so the subscription-aware returns policies are authoritative. `guard_return_status_entry()` prevents direct client status edits.

`customer_request_return()` requires an authenticated active customer belonging to the tenant, with an eligible order item and an order in `paid`, `fulfilment` or `completed`. The request enters `requested` and is recorded in workflow history. Customer visibility uses `customer_get_returns()` and the customer dashboard exposes return actions.

Return lifecycle authority: `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

## 15. Customer dashboard browser repair — VERIFIED LIVE
The browser-layer faults were traced to navigation interception, session handoff timing and finally an invalid quote mapping in the controller `esc()` helper. The helper was corrected and the controller cache-buster advanced to `customer-dashboard.js?v=11`.

A further live fault was isolated during the customer Buying test. `loadPortalData()` aggregates optional module calls with one `Promise.all()`. Test Business A does not currently have `module.orders`, so `customer_get_orders()` can reject before the controller reaches `loadCategories()`. The category itself was present in the live database, so the empty/loading UI was a frontend dependency failure rather than missing category data.

`customer-dashboard-nav.js` now independently calls the secure `customer_get_buying_categories()` RPC after authentication/portal reveal and observes the portal `hidden` state so it also works with the existing in-page authentication fallback. This isolates the category selector from unrelated optional customer modules.

Repair commits:
- `1aa84323f91ad8b5971d7cd4025e493ccf23f7ba`
- `38355ccfbe4258df39fd4dd5cb5b59b1daa5b469`

Browser verification remains open: hard refresh the Customer Dashboard, open **My Buying**, and confirm **Drones** appears in the Category selector.

## 16. Subscriber dashboard loading repair — 17 September 2026
The Categories, Inventory and Selling screenshots all showed their data controls stuck at `Loading…`. Inspection of the current GitHub source found the same malformed `esc()` quote mapping in the subscriber controllers. This is a JavaScript parse error, so the controllers never reached their Supabase requests.

Repair approach:
- `category-management.js` repaired in place.
- `inventory-dashboard-fixed.js` created as a clean runtime and `inventory-dashboard.html` switched to it.
- `selling-dashboard-fixed.js` created as a clean runtime and `selling-dashboard.html` switched to it.
- The Inventory signed-URL request also explicitly sends `Content-Type: application/json`.
- No subscription capability was enabled or changed to work around the fault.

Commits:
- Category: `11bcc0922f368918a26be6c7e8362109fde2ae4f`.
- Inventory runtime: `ccfb93a889903131f24c2a9769b04b095e611c22`.
- Inventory HTML: `22b17000105860bdadc03377b4828410d95f9e04`.
- Selling runtime: `1692b3f2d7c512fc528f91ead22e07b6ccac0eec`.
- Selling HTML: `693ef64cbba12540c9f32856224b0d20c831fb1d`.

The live `private` schema `USAGE` repair remains in force. Browser verification is now the next checkpoint.

## 17. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**.

## 18. Manual UI testing
One manual test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 19. Change-control and memory
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. Do not invent memory tables, columns or records.

## 20. Current stopping point — 17 September 2026
The shared subscriber JavaScript parse fault is repaired in Categories, Inventory and Selling. Browser verification remains open. Test Business A has the `Drones` category. Subscription capabilities have not been altered as part of this repair.

**Next safe action:** hard-refresh Categories and confirm `Drones`; then hard-refresh Inventory and confirm its Category dropdown loads; then hard-refresh Selling and confirm its Inventory asset, Sales channel and Category controls load. Only after these checks continue with Property → Product → Photograph → Ready for Sale → Listing → Customer Shop → Stripe Sandbox, verifying each stage before moving to the next.