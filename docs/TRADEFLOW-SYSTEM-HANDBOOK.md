# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 3.3  
**Date:** 17 September 2026  
**Audience:** Platform owner, tenant owners, administrators, staff and future developers

## 1. Purpose and authority
This handbook records TradeFlow architecture, security boundaries, workflow rules, implementation decisions, faults, lessons and exact build position.

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
- Category/inventory media foundation: current live migration adds tenant-scoped inventory/listing media links, private storage bucket and retention metadata/triggers.
- External payment boundary: `add_external_payment_webhook_authority` plus correction migration; Edge Functions deployed for Stripe Checkout and webhook handling.

## 4. Production onboarding — OPEN
Development tenant insertion/test-lab paths are not the production SaaS onboarding model.

Required sequence: **Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.** Never permit self-claimed Platform Owner access or create a `platform_owner` tenant role.

## 5. Subscription and permission architecture
Capabilities use plans, `plan_features`, `tenant_subscriptions`, `private.has_tenant_feature()` and `private.require_tenant_feature()`.

Relevant permissions include `buying.view/manage`, `valuation.view/manage`, `offers.view/manage`, `acquisitions.view/manage`, `inventory.view/manage`, `selling.view/manage`, `orders.view/manage`, `fulfilment.view/manage`, `returns.view/manage` and `finance.view/manage`. No `module.finance` feature is assumed or invented.

## 6. Customer-facing and subscriber build
Implemented UI paths include Website Builder, public storefront renderer, customer authentication/dashboard, buying request submission, offer Accept/Refuse, subscriber Buying, Acquisition, Inventory, Finance, Selling/Listings, Orders, Fulfilment and Returns workspaces.

Category/property management is now independent of Buying. Subscribers can create a category for Buying, Selling or both and define category-specific product properties/options.

Inventory now supports direct product creation, category assignment, dynamic property values and photographs. Selling carries inventory photographs into a new listing.

These are implementation milestones. They are not GREEN until the new authenticated browser journey is persistently tested.

## 7. Buying → Valuation → Offer
049–051 harden dynamic options and Buying workflow. 052–055 harden valuation/offer RLS, same-item valuation binding and state entry. Published offers require an approved valuation for the same tenant and buying item.

## 8. Acquisition
056–057 harden acquisition access and status entry. Lifecycle authority is `accepted → awaiting_item → received → inspection → finalised → paid → completed`, with cancellation branches as supported.

Inventory creation from an acquisition item is an explicit operation; it is not inferred from acquisition status.

## 9. Categories, product properties and inventory media
`categories`, `category_fields` and `category_field_options` already provide the database-authoritative category/property model. The new subscriber workspace exposes that model directly instead of forcing products through Buying first.

`inventory_assets.dynamic_values` stores category-specific product values. `category_fields` controls field type, Buying/Selling requirements, customer/staff visibility and valuation relevance. Select/multiselect properties use `category_field_options`.

The live media foundation now includes:
- private Storage bucket: `tradeflow-media`;
- `media_assets` retention metadata;
- `inventory_asset_media` tenant-scoped inventory links;
- `listing_media` tenant-scoped listing links;
- inventory/listing sold-status triggers setting a **90-day post-sale retention expiry**.

The browser uses tenant-authenticated Storage access and time-limited signed URLs for private images. Physical object deletion is intentionally separate from SQL metadata deletion: the Storage API must remove the object to reclaim storage space.

The automatic cleanup scheduler is **not yet configured**. Supabase supports scheduled Edge Function calls using Cron/pg_net, with secrets kept outside source code; this will be added after the browser media journey is verified.

## 10. Inventory
058 protects inventory status entry. `inventory-dashboard.html` now loads the repaired `inventory-dashboard-fixed.js` runtime. The workspace lists tenant assets, filters status, edits non-status details, creates new products, captures category-specific dynamic values, uploads photographs and routes lifecycle changes through `transition_workflow_entity()`.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 11. Finance
059 applies permission-bound access to `payment_records` and `ledger_entries`. 060 extends `transition_workflow_entity()` to payment and ledger status transitions and adds status-entry guards.

Finance workspace creates payment/ledger records and routes status changes through the workflow RPC. No automatic payment or ledger creation is inferred from acquisition status.

`record_retail_order_payment()` provides the internal subscriber-controlled payment capture path. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`, locks a `pending_payment` order, requires payment equal to current `amount_due`, creates a paid inbound payment record and matching posted ledger credit, clears amount due and advances the order to `paid`. This remains a manual/internal payment path.

`customer_create_order_payment()` provides the customer-side pending payment-record/idempotency boundary. It validates the authenticated customer owns the `pending_payment` order, reuses an active pending/processing attempt, and permits a fresh payment record after a failed attempt.

The external Stripe boundary is implemented in Supabase Edge Functions. `create-stripe-checkout-session` requires a customer JWT and creates the Stripe Checkout Session server-side using `STRIPE_SECRET_KEY`; browser code never receives the Stripe secret. `stripe-payment-webhook` has JWT verification disabled because Stripe webhooks do not carry a TradeFlow user JWT; it instead verifies the `stripe-signature` using `STRIPE_WEBHOOK_SECRET` before calling the protected `process_external_payment_event()` database function.

`payment_provider_events` provides provider/event idempotency. `process_external_payment_event()` validates tenant/payment identity, provider payment ID, amount and currency, records payment workflow history, updates the payment state and, on a confirmed paid retail order, updates the order to `paid` and creates the corresponding posted ledger credit.

### Stripe test configuration checkpoint — 16 September 2026
TradeFlow has a dedicated Stripe Sandbox within the existing Stripe account. The active TradeFlow Payment Webhook listens for the required checkout/payment events. The two Stripe test secrets are configured server-side and are not stored in browser code, GitHub, documentation or project memory.

Configuration is complete for the Stripe test environment, but persistent customer browser payment verification remains open.

## 12. Selling / Listings
061 hardens listings and related access; selling creates listings from ready-for-sale inventory and uses workflow authority for status changes. New listings inherit the inventory asset's media links. `selling-dashboard.html` now loads the repaired `selling-dashboard-fixed.js` runtime.

## 13. Retail Orders
062 hardens retail order access and status entry. Subscriber Orders creates an order from a published listing and advances it to pending payment. Customer checkout creates a pending-payment order, reserves the listing and uses the external Stripe boundary for payment.

## 14. Fulfilment
Fulfilment retains subscription-aware access and controlled lifecycle progression. No carrier API or automatic fulfilment creation is assumed. Customer visibility uses secure `customer_get_fulfilments()`.

## 15. Returns
Returns legacy broad policies have been removed and direct status edits are blocked. `customer_request_return()` validates customer ownership and eligible order states. Customer visibility uses secure `customer_get_returns()`.

## 16. Customer dashboard browser repair — VERIFIED LIVE
The persistent browser test exposed two browser-layer faults: Sign in initially produced no visible response, and the navigation controller intercepted hashes while the portal was hidden. Navigation was corrected to leave native hash navigation available until authentication succeeds.

The dashboard HTML contains an inline capture-phase Supabase Auth fallback using only the public publishable key. The earlier reload-based handoff failed because reload returned to the authentication panel. The later in-page handoff removed the reload and an unnecessary `/auth/v1/user` request from the successful-auth path.

The controller was loaded synchronously before the inline fallback. The remaining failure was then identified in live GitHub source: the `esc()` helper contained an incorrectly escaped quote key, producing invalid JavaScript. Correcting the helper and cache-busting the controller to `v11` resolved the fault.

A subsequent category-loading fault was traced to `loadPortalData()` using one `Promise.all()` across optional modules. Test Business A currently lacks `module.orders`, so `customer_get_orders()` can reject before the controller reaches its category-loading call. The category loader is now also present in `customer-dashboard-nav.js`, independent of the optional-module aggregate, and is triggered after the portal becomes visible.

Test Business A now has the live category `Drones` with Buying and Selling enabled. The browser verification step is **hard refresh → My Buying → Category → confirm `Drones` appears**.

## 17. Subscriber dashboard JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling all showed `Loading…` in their dependent controls. Inspection of the live GitHub sources found the same malformed `esc()` quote mapping in their JavaScript. Because the mapping was syntactically invalid, the controllers failed during parsing and never reached their Supabase requests.

The Category controller was repaired in place. Clean replacement runtimes were created for Inventory and Selling and their HTML pages were switched to those runtimes. The Inventory runtime also adds the required JSON content type to private signed-URL requests.

Commits:
- Category repair: `11bcc0922f368918a26be6c7e8362109fde2ae4f`.
- Inventory repaired runtime: `ccfb93a889903131f24c2a9769b04b095e611c22`.
- Inventory HTML switch: `22b17000105860bdadc03377b4828410d95f9e04`.
- Selling repaired runtime: `1692b3f2d7c512fc528f91ead22e07b6ccac0eec`.
- Selling HTML switch: `693ef64cbba12540c9f32856224b0d20c831fb1d`.

The earlier database repair granting `USAGE` on schema `private` to `authenticated` remains in place. No subscription capability was changed to work around the fault.

Browser verification is now the required next step: hard refresh Categories, Inventory and Selling, verify their initial data loads, then proceed one page at a time.

## 18. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states are **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 19. Manual testing
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

## 20. Documentation/change control
After each material change record what changed, why, affected files/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 21. Current stopping point — 17 September 2026
The shared subscriber JavaScript parse fault has been repaired for Categories, Inventory and Selling. Browser verification remains open. Test Business A has the `Drones` category and no subscription capability has been altered as part of this repair.

**Next action:** hard-refresh Categories and confirm `Drones`; then hard-refresh Inventory and confirm its Category dropdown loads; then hard-refresh Selling and confirm its Inventory asset, Sales channel and Category controls load. Only after these checks continue with Property → Product → Photograph → Ready for Sale → Listing → Customer Shop → Stripe Sandbox.