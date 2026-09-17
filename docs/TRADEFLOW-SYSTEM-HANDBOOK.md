# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 3.8  
**Date:** 17 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose and authority
This handbook records TradeFlow architecture, security boundaries, workflow rules, implementation decisions, faults, lessons, verification state and exact build position.

Authority order: **current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour**. A Git commit is implementation evidence, not proof of live behaviour.

## 2. Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant boundary.

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level boundary and is never a tenant role. GearCashOut is reference material only and must never be modified during TradeFlow work.

## 3. Security checkpoints
- Customer isolation/security: **34/34 passed**.
- Customer subscription tests: **Buying 17/17; Selling 17/17 passed**.
- Staff security lab: **19/19 passed**.
- Recorded RLS checkpoint: **60/60 public tables enabled**.
- Platform Owner foundation: 044–045.
- Platform-admin privileged paths: 046–048; final browser regression remains open.
- Buying hardening: 049–051.
- Valuation/Offer hardening: 052–055.
- Acquisition hardening: 056–057.
- Inventory hardening: 058.
- Finance permission/workflow hardening: 059–060.
- Selling/listing hardening: 061.
- Retail order hardening: 062.
- Fulfilment/returns hardening: current live migration.
- Category/inventory media foundation: tenant-scoped media links, private storage bucket and retention metadata/triggers.
- External payment boundary: provider/event idempotency plus deployed Stripe Checkout and webhook Edge Functions.

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage`, `orders.view/manage`, `fulfilment.view/manage`, `returns.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing and subscriber build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, Buying, Offers, Acquisitions, Inventory, Finance, Selling/Listings, Orders, Fulfilment and Returns.

Category/property management is independent of Buying. Subscribers can create categories for Buying, Selling or both and define category-specific properties/options. Inventory supports direct product creation, category assignment, dynamic property values and photographs. Selling carries inventory photographs into new listings.

These remain BLUE until authenticated browser journeys are persistently tested.

## 7. Buying → Valuation → Offer
049–051 harden dynamic options and Buying workflow. 052–055 harden valuation/offer RLS, same-item valuation binding and state entry. Published offers require an approved valuation for the same tenant and buying item.

## 8. Acquisition
056–057 harden acquisition access and status entry. Inventory creation from an acquisition item is an explicit operation and is not inferred from acquisition status.

## 9. Categories, product properties and inventory media
`categories`, `category_fields` and `category_field_options` are the database-authoritative model. `category-management.html` / `.js` exposes category creation plus property and option creation. `inventory_assets.dynamic_values` stores category-specific product values.

Media foundation:
- private Storage bucket: `tradeflow-media`;
- `media_assets` retention metadata;
- `inventory_asset_media` tenant-scoped inventory links;
- `listing_media` tenant-scoped listing links;
- inventory/listing sold-status triggers setting a **90-day post-sale retention expiry**.

Private images use authenticated Storage and signed URLs. Physical object deletion must use the Storage API. Automatic cleanup scheduling is not configured.

## 10. Common subscriber category tenant-context repair — 17 September 2026
The category selector failure was not a missing database category. Test Business A contains active Buying/Selling `Drones`. The common front-end problem was that subscriber workspace controllers expected `tenant_id` in the URL while workspace navigation used plain page URLs.

A shared `subscriber-tenant-context.js` preloader now runs before subscriber workspace controllers. In the temporary test-lab environment it establishes tenant context from the existing URL/local tenant context or the authenticated test-lab session mapping, writes the selected tenant into the URL and stores it for subsequent subscriber navigation.

The preloader is now loaded before the Category, Inventory, Selling and Buying controllers. Inventory and Selling also route their Categories navigation through the fresh `categories.html` entry. This is test-lab subscriber infrastructure, not the production tenant-selection model.

## 11. Second category runtime repair — 17 September 2026
The live browser symptom remained `Loading categories…` after the shared tenant-context change. The Category controller was therefore hardened independently instead of making another database or subscription change.

`category-management.js` now safely parses the stored test-lab session, accepts tenant context from the URL/shared document dataset/stored test tenant/known test-lab user mapping, and reports controller/runtime failures visibly. `categories.html` cache-busts the context to `v3` and controller to `v9`.

Commits: `92bed1ba6319ce3a7ae1c6d8901ae7939d74c71d` and `7872d4bd06a1a53eb150c2fac89481ac6dbd9e74`.

No Supabase schema, category records, subscriptions or RLS policies were changed.

## 12. Deep category transport/runtime check — 17 September 2026
Backend verification confirms the Supabase project is `ACTIVE_HEALTHY`, Test Business A contains active Buying/Selling `Drones`, and the exact category SELECT returns `Drones` under the `authenticated` role with the known owner identity. The owner/admin test identities have `categories.view/manage`; staff has `categories.view`.

The subscriber REST helper was then traced. It added `Content-Type: application/json` to every request, including GET category reads. That header is unnecessary for Supabase REST GETs and can introduce a CORS preflight. The helper also had no timeout, allowing a stalled browser request to remain visibly stuck on `Loading categories…`. The previous page error listener was registered after the controller, so an early controller exception could escape the visible diagnostic.

Repairs:
- `category-management.js`: omit JSON `Content-Type` on GET/HEAD, add a 10-second request timeout, and show request-phase/concrete errors.
- `categories.html`: install `error`/`unhandledrejection` listeners before subscriber scripts; cache-bust controller `v10` and shared context `v4`.
- `subscriber-tenant-context.js`: safely establish tenant context and normalise subscriber GET/HEAD requests before workspace controllers run.
- Subscriber Dashboard, Inventory, Selling and Buying HTML now cache-bust the shared context to `v4`.

No subscription, RLS or category-data workaround was introduced.

## 13. Inventory
058 protects inventory status entry. The repaired Inventory runtime supports product creation, category-specific dynamic values, multiple photographs and workflow-controlled lifecycle changes.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 14. Finance and payment
059 applies permission-bound access to payment/ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards. No automatic payment or ledger creation is inferred from acquisition status.

`record_retail_order_payment()` is the internal subscriber payment path. `customer_create_order_payment()` provides the customer-side idempotent pending-payment boundary.

External Stripe architecture is server-side: `create-stripe-checkout-session` requires a customer JWT; `stripe-payment-webhook` verifies `stripe-signature` and calls protected `process_external_payment_event()`. `payment_provider_events` provides provider/event idempotency. Stripe test configuration is complete, but persistent browser payment verification remains open.

## 15. Selling / Listings
061 hardens listings and related access. Selling creates listings from ready-for-sale inventory and uses workflow authority. New listings inherit inventory media.

## 16. Retail Orders
062 hardens retail order access/status entry. Subscriber Orders creates orders from published listings. Customer checkout creates a pending-payment order, reserves the listing and uses the Stripe boundary for payment.

## 17. Fulfilment
Fulfilment has subscription-aware access and controlled lifecycle progression: `awaiting → label → dispatched → delivered`, with returned branches. No carrier API or automatic fulfilment creation is assumed.

## 18. Returns
Legacy broad returns policies were removed and direct status edits are blocked. `customer_request_return()` validates customer ownership and eligible order states; customer visibility uses secure `customer_get_returns()`.

## 19. Customer dashboard browser repair — VERIFIED LIVE
Customer sign-in/controller timing and navigation interception faults were repaired. The controller `esc()` parse fault was corrected and cache-busted to `v11`. Customer Buying category loading was isolated from optional modules because Test Business A lacks `module.orders`; `customer-dashboard-nav.js` independently loads `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## 20. Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared a malformed `esc()` quote mapping, causing JavaScript parse failure before Supabase requests. Category was repaired in place; clean repaired Inventory and Selling runtimes were created. Inventory signed-URL requests also explicitly send JSON content type.

## 21. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 22. Manual testing and change control
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

After each material change record what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 23. Current stopping point — 17 September 2026
The database and RLS path are verified. The shared tenant-context repair did not resolve the live browser symptom. The latest repair targets the subscriber REST transport/bootstrap layer: GET requests no longer carry unnecessary JSON Content-Type, category reads now have a visible 10-second timeout, and runtime diagnostics load before the controller.

**Next action:** hard refresh the current Categories page. It should now either show `Drones` or a concrete runtime/API/timeout error rather than silently remaining on `Loading categories…`. Do not change subscriptions or Supabase category data as a workaround. Once Categories passes, verify Inventory and Selling selectors and continue Product → Property → Photograph → Ready for Sale → Listing → Customer Shop → Stripe Sandbox.
