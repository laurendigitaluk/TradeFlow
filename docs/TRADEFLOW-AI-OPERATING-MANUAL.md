# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 3.8  
**Date:** 17 September 2026  
**Project:** TradeFlow

## 1. Purpose
AI continuity companion for TradeFlow. It records architectural truth, decisions, faults, verification state and exact stopping point so future sessions resume without guessing.

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
- Do not invent `module.finance`; finance uses the live permission/capability model actually present.

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

Separate direct product path: **Category → Product → Properties → Photographs → Inventory lifecycle → Listing → Customer Shop**. It does not require Buying first.

## 8. Category/product foundation
`categories`, `category_fields` and `category_field_options` are the authoritative category/property model. `category-management.html` / `.js` exposes category creation plus product property and option creation.

`inventory_assets.dynamic_values` stores product-specific values for category fields. Properties can be marked required for Buying/Selling, customer/staff visible and valuation relevant.

Test Business A contains the active Buying/Selling `Drones` category. This is test data, not a production seed requirement.

## 9. Common subscriber category tenant-context repair — 17 September 2026
The same blank-category failure appeared across subscriber category selectors. The database was verified to contain active Buying/Selling `Drones`; the failure was front-end tenant context. Subscriber controllers expected `tenant_id` in the URL while workspace navigation used plain page URLs.

A shared `subscriber-tenant-context.js` preloader now executes before the Category, Inventory, Selling and Buying controllers. In the temporary test-lab environment it establishes the tenant from the current URL/local test tenant context or authenticated test-lab session mapping, writes it into the URL and stores it for subsequent subscriber navigation.

## 10. Second category runtime repair — 17 September 2026
The live symptom remained `Loading categories…` after the shared tenant-context repair. The Category controller was hardened independently rather than changing subscriptions or Supabase data.

`category-management.js` now safely parses the stored test-lab session, accepts tenant context from the URL/shared document dataset/stored test tenant/known test-lab user mapping, and reports controller/runtime failures visibly. `categories.html` cache-busts the context to `v3` and controller to `v9`.

Commits: `92bed1ba6319ce3a7ae1c6d8901ae7939d74c71d` and `7872d4bd06a1a53eb150c2fac89481ac6dbd9e74`.

No Supabase schema, category records, subscriptions or RLS policies were changed.

## 11. Deep category transport/runtime check — 17 September 2026
The backend is now verified separately from the browser: Supabase reports `ACTIVE_HEALTHY`; Test Business A contains active Buying/Selling `Drones`; the exact category SELECT returns `Drones` under the authenticated owner identity; and the relevant category permissions are present.

The subscriber REST helper was then traced. It added `Content-Type: application/json` to every request, including GET category reads. That header is unnecessary for Supabase REST GETs and can introduce a CORS preflight. The helper also had no timeout, allowing a stalled request to remain on `Loading categories…` indefinitely. The previous error listener was registered after the controller, so an early bootstrap exception could escape visible diagnostics.

Repairs now applied:
- `category-management.js`: omit JSON `Content-Type` on GET/HEAD, add a 10-second timeout, and display request-phase/concrete errors.
- `categories.html`: install `error` and `unhandledrejection` listeners before subscriber scripts; cache-bust controller `v10` and shared context `v4`.
- `subscriber-tenant-context.js`: safely establish tenant context and normalise subscriber GET/HEAD requests before controllers run.
- Subscriber Dashboard, Inventory, Selling and Buying HTML now cache-bust the shared context to `v4`.

This is a front-end transport/bootstrap repair. No database, subscription or RLS workaround was introduced.

## 12. Inventory/media foundation
Inventory remains protected by `guard_inventory_asset_status_entry()` and `transition_workflow_entity()`.

New product creation is exposed in `inventory-dashboard.html`. It creates a `received` inventory asset, assigns a category, stores dynamic property values and can upload multiple photographs.

Media architecture:
- private Storage bucket: `tradeflow-media`;
- `media_assets` stores object metadata and retention fields;
- `inventory_asset_media` links photographs to products;
- `listing_media` links photographs to listings;
- Selling carries inventory media links into a newly created listing.

When an inventory asset or listing enters `sold`, attached media receives a 90-day retention expiry; leaving `sold` clears the expiry. This is a retention timer, not yet the physical deletion job. Physical deletion must use Supabase Storage. Scheduled cleanup via Cron/pg_net is not yet configured.

## 13. Finance / external payment checkpoint
059–060 harden payment/ledger access and workflow authority. No `module.finance` feature is to be invented.

`record_retail_order_payment()` is the internal subscriber capture path. `customer_create_order_payment()` is the customer-side idempotency boundary.

External Stripe boundary:
- `create-stripe-checkout-session`: JWT-protected server-side Checkout creation;
- `stripe-payment-webhook`: signed Stripe event verification and reconciliation;
- `process_external_payment_event()`: protected database reconciliation;
- `payment_provider_events`: provider/event idempotency.

Stripe test configuration is complete server-side, but persistent browser payment verification remains open.

## 14. Selling/Listings and Orders
Selling uses ready-for-sale inventory, active selling channels/categories and central workflow authority. New listings inherit inventory media.

Retail Orders hardening is 062. Customer checkout requires an authenticated active customer, accepts a published listing, creates a pending-payment order, reserves the listing and enters the Stripe boundary. Subscriber internal payment capture advances paid orders and creates finance records.

## 15. Fulfilment and Returns
Fulfilment lifecycle authority: `awaiting → label → dispatched → delivered`, with return branches. Direct status edits are guarded.

Returns require authenticated customer ownership and eligible order state. Lifecycle authority is `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

## 16. Customer dashboard browser repair — VERIFIED LIVE
Customer browser faults were traced to navigation interception, session handoff timing and an invalid `esc()` quote mapping. The controller was repaired and cache-busted to `v11`.

Customer Buying category loading was separately isolated because Test Business A lacks `module.orders`; the aggregate customer data `Promise.all()` can reject before categories load. `customer-dashboard-nav.js` independently calls `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## 17. Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling all showed `Loading…`. The shared malformed `esc()` mapping was a JavaScript parse fault. Category was repaired in place; clean repaired Inventory and Selling runtimes were deployed. Inventory signed-URL requests also explicitly send JSON content type.

## 18. Diagnostic standard
Always record:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Record actual filenames and database objects. If not inspected, write **Not yet audited**.

## 19. Manual UI testing
One manual test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 20. Change-control and memory
After each material change record what/why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Update the Master Roadmap, System Handbook, this AI manual and structured project memory/checkpoint where available.

TradeFlow's live database must not be assumed to contain a project-memory table unless its actual schema is inspected. Do not invent memory tables, columns or records.

## 21. Current stopping point — 17 September 2026
The database/RLS path is verified but the browser symptom had persisted. The latest repair targets the subscriber REST transport/bootstrap path: GET requests no longer carry unnecessary JSON Content-Type, category reads now time out visibly after 10 seconds, and runtime diagnostics load before the controller. **Browser verification remains open.**

**Next safe action:** hard refresh the current Categories page. It should now either show `Drones` or a concrete runtime/API/timeout error rather than silently remaining on `Loading categories…`. Do not change subscriptions or category data as a workaround. Once Categories passes, verify Inventory and Selling selectors and continue one verified stage at a time through Product → Property → Photograph → Ready for Sale → Listing → Customer Shop → Stripe Sandbox.
