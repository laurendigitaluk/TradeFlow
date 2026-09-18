# TradeFlow Master Build Roadmap & Verification Register

**Version:** 5.9  
**Date:** 18 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level security boundary and is never a tenant role.

## Current environment
- GitHub: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap
| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | BLUE | **Category loading is Verified Live** with Test Business A Admin; `Drones` appears. Property creation/options still require browser verification. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | BLUE | Private `tradeflow-media`, tenant-scoped inventory/listing media links and 90-day post-sale retention metadata/triggers implemented. Physical cleanup scheduler remains open. |
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; lifecycle and explicit inventory hand-off implemented. |
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; dedicated subscriber-auth repair is now live; browser verification remains. |
| 11 | Inventory | GREEN | Product creation, `model_number`, photographs and controlled lifecycle were browser-tested against live Supabase. Test asset reached `ready_for_sale` through the workflow authority. |
| 12 | Selling/listings | GREEN | Listing creation and publish were browser-tested from the ready-for-sale Test Business C asset. `LST-20260918-17216BDF` is published at £499 GBP on TradeFlow Storefront. |
| 13 | Retail orders | GREEN | Customer Shop → order → Stripe Sandbox → paid order and payment record were browser-tested and verified live for Test Business C. Fulfilment remains the next lifecycle boundary. |
| 14 | Returns | BLUE | Return-request security and subscriber/customer workflows implemented; browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 and external Stripe boundary implemented; persistent payment verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Tenant websites remain a downstream feature. The TradeFlow root page is now the SaaS marketing/onboarding entry point; tenant storefront remains separate. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains have explicit workflow authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Category / product / media foundation
Operational path:
**Categories & Properties → define genuine product-specific properties → Inventory → add product with one core Condition field → attach photographs → controlled lifecycle → Selling → create listing → Customer Shop.**

Implemented category/property management, direct inventory product creation, dynamic property values, private `tradeflow-media`, tenant-scoped media link tables, listing photo carryover and 90-day post-sale retention metadata/triggers. Physical Storage cleanup scheduling is not yet configured.

## Category investigation and subscriber authentication — 17 September 2026
Test Business A contains active Buying/Selling `Drones`. The exact category SELECT returns `Drones` under the authenticated database role. The browser initially failed because subscriber pages were using customer test-lab session storage rather than a dedicated subscriber session. A dedicated subscriber authentication layer was added for the test environment.

The live browser test is now **PASSED**: using the Test Business A **Admin** account, Categories loads successfully and `Drones` is visible. This proves the current chain:
**Subscriber Admin sign-in → active Test Business A membership → subscriber tenant context → authenticated category query → RLS → `Drones` rendered.**

Owner remains reserved for owner-specific testing; Admin is the primary subscriber workspace test account; Staff remains for permission/restriction testing.

## Current stopping point — 17 September 2026
**Categories loading: VERIFIED LIVE.** Do not change authentication, category RLS or subscriptions for this issue.

Next browser test is deliberately narrow: on Categories, select `Drones` in the Product Property Category selector and create the first product property (using the existing UI). Then verify Inventory's Category selector with the same Admin session. Do not move to Selling or Stripe until the Category → Property → Inventory selector chain is verified.

## Inventory → Selling verification — 18 September 2026

The Test Business C product `DJI Mini 4 Pro Test 3` was taken through the controlled inventory lifecycle from `received` → `inspection` → `testing` → `repair` → `ready_for_sale`. The final inventory row was verified as `ready_for_sale`, condition `Good`, with the expected listing action.

A selling listing was then created from that inventory asset and published successfully: `LST-20260918-17216BDF`, asking price £499.00 GBP, channel `TradeFlow Storefront`, category `Drones`. This verifies the live boundary:
**Inventory ready-for-sale → Selling listing → Published listing.**

The next boundary is deliberately customer-facing: **Published listing → Customer Shop → retail checkout → Stripe Sandbox → payment → order → fulfilment → returns.**

## Stripe payment return URL repair — 18 September 2026

The corrected Stripe return path was browser-tested successfully. The existing customer checkout for **ORD-20260918-DB2A42EF** completed in Stripe Sandbox and returned to the TradeFlow Customer Portal rather than the GitHub Pages 404. The portal displayed the order as **placed/paid**.

Live database verification confirms the complete payment boundary: the retail order is `paid`, payment status is `paid`, amount due is £0.00, a new Stripe payment record is linked with status `paid`, and the Stripe Checkout session is stored against that payment record. The listing remains `reserved` and the inventory asset remains `ready_for_sale`; those states are therefore the next fulfilment/sales-lifecycle boundary rather than part of payment completion.

**Status:** Verified Live. Customer checkout → Stripe Sandbox → successful payment → TradeFlow return → paid order is now working. Next boundary: **paid order → fulfilment / completed sale → listing and inventory final state → customer delivery/returns**.


Stripe Sandbox payment for the existing test order **ORD-20260918-DB2A42EF** completed successfully. Live database verification shows the payment record is **paid**, the retail order is **paid**, and the Stripe provider session is linked. The browser then returned to the GitHub Pages host root and displayed a 404 because the deployed TradeFlow site is served from the repository path **/TradeFlow/**; the checkout Edge Function was constructing the success/cancel URL without that project path.

Minimal repair applied to `create-stripe-checkout-session`, now live as version 10: GitHub Pages requests use `https://laurendigitaluk.github.io/TradeFlow` as the public application base while non-GitHub origins continue to use their origin. JWT verification remains enabled and no RLS, tenant, customer or payment-security boundary was changed.

**Status:** Implemented Live. The next test should confirm a fresh Stripe Sandbox checkout returns to `customer-dashboard.html` under the TradeFlow GitHub Pages path. Do not create another order unless the existing test order has been intentionally reset.

## Stripe payment-record linking repair — 18 September 2026

The Stripe Checkout session was successfully created, but the Edge Function returned `Payment session created but payment record could not be linked`. The live function had been corrected to read the payment RPC's `payment_id`, but two downstream Stripe metadata/PATCH references still used the old `payment.id` field. This caused the link/update request to use the wrong identifier.

Minimal repair applied to `create-stripe-checkout-session`, now live as version 9: all downstream payment-record references use the normalized `paymentId`. JWT verification remains enabled and no RLS, tenant, customer or Stripe security boundaries were changed.

Live verification shows the existing order `ORD-20260918-DB2A42EF` still has exactly one pending payment record (`99f624be-1113-44e5-9753-9d5dc4dec992`) with no provider session linked, so it remains the correct test order.

**Status:** Implemented Live. Next browser test: use **Pay now** on the existing order. Do not create another order.

## Stripe payment ID field mismatch — 18 September 2026

The customer portal continued to report `Unable to create payment record` after the previous repair. The live `customer_create_order_payment()` RPC returns its primary key as `payment_id`, while the Stripe checkout Edge Function was checking `payment.id`. The payment record itself was therefore valid, but the Edge Function rejected the RPC response as if no payment had been created.

Minimal repair applied in `create-stripe-checkout-session` Edge Function version 8: normalize the returned payment identifier as `payment.payment_id || payment.id` and use that identifier for subsequent payment-record lookup and response handling. JWT verification remains enabled and no database/RLS/security rules were changed.

**Status:** Implemented Live. Next browser test: click **Pay now** on the existing pending £499 order. Do not create another order.

## Payment record creation/response repair — 18 September 2026

The existing Test Business C order reached payment creation, and the live database contains a valid pending `payment_records` row for the £499 order. The customer-facing Edge Function was nevertheless returning `Unable to create payment record`, indicating the REST RPC response path was failing even though the payment record had been created.

Minimal repair applied to `create-stripe-checkout-session` Edge Function version 7: after the customer/order access check succeeds, if the payment RPC returns a non-2xx response, the function now safely looks for the already-created active payment record for that same tenant/order and continues when one exists. If no active record exists, it returns the underlying error. JWT verification remains enabled and the tenant/customer validation is unchanged.

**Status:** Implemented Live. Next browser test: refresh and click **Pay now** on the existing order. No new order should be created.

## Customer Pay Now field mismatch — 18 September 2026

The customer order was successfully created, but the **Pay now** action sent no `order_id` to the Stripe checkout function. Root cause: `customer_get_orders()` returns the order primary key as `order_id`, while the customer UI renderer was reading `id`, which does not exist in that RPC response. This produced the `tenant_id and order_id are required` error.

Minimal frontend repair applied: the Pay now button now uses `order_id` from the customer orders RPC. Customer dashboard cache bumped to v19. No database or security changes were required.

**Status:** Implemented. Next browser test: refresh the customer portal and click **Pay now** on the existing pending £499 order. Do not create another order.

## Stripe checkout customer-order lookup repair — 18 September 2026

The browser checkout successfully created the Test Business C customer order, but the Stripe checkout Edge Function then returned `Order not found for this customer`. Investigation of the live `create-stripe-checkout-session` function showed it called `customer_get_orders()`, whose return field is `order_id`, while the Edge Function searched for `o.id`.

Minimal Edge Function repair applied in version 6: customer-order validation now accepts the actual RPC field `order_id` (while retaining compatibility with `id`). JWT verification remains enabled. No customer access policy, RLS rule, tenant boundary or Stripe configuration was changed.

Current live state: the browser-created order remains `pending_payment` and the listing is reserved, so the existing order should be used for the next payment test rather than creating another order.

**Status:** Edge Function repair **Implemented Live**. Next browser test: use the existing **Pay now** action for the £499 Test Business C order and verify Stripe Sandbox opens.

## Customer checkout ambiguity repair — 18 September 2026

The first live Shop → Buy attempt reached the backend and exposed a PostgreSQL PL/pgSQL ambiguity in `customer_create_retail_order`: the function's output column names conflicted with unqualified `order_reference` and `status` references inside the function. The fault was reproduced directly under the authenticated role using the Test Business C customer identity.

Minimal repair applied: the `retail_orders` INSERT now uses a target alias for qualified `id`/`order_reference` RETURNING, and the listing reservation UPDATE qualifies the listing `status` and tenant/id columns. No customer permissions, RLS policies, subscription rules or payment architecture were changed.

The repaired function was then executed in a transaction using the authenticated Test Business C customer context and returned a valid test result: `pending_payment`, £499.00 GBP. The transaction was rolled back, so no test order or reservation was left behind.

**Status:** Backend repair **Implemented and database-tested**. Next browser test: click Buy once; expect a real `pending_payment` order to be created and the secure Stripe Sandbox checkout route to open.

## Customer portal simplification — 18 September 2026

The customer Overview was then simplified further: top-level summary cards now show **Selling requests, Orders and Returns** only. Offers and completed-sale/acquisition information remain within **Sell to us**, rather than being presented as separate customer-level concepts.

The customer portal UI was simplified so it does not mirror the subscriber workspace. Customer-facing navigation is now limited to **Overview, Shop, My Orders, Sell to us, Returns and My Details**. Delivery is grouped into My Orders; selling requests, offers and completed sales are grouped into Sell to us. Internal subscriber concepts such as standalone Acquisitions and separate Offers navigation are no longer exposed as top-level customer sections.

This is a presentation/workflow simplification only. Existing customer RPCs and underlying selling/order/return data remain available to the appropriate customer views and have not been removed from the backend.

## Customer registration repair — 18 September 2026

Test Business C uses a separate customer identity, `tradeflow1@yahoo.com`, rather than a subscriber/admin identity. The live database showed the Auth account had not been linked to a `public.customers` row after email-confirmed signup, while the customer portal's other RPCs correctly require an active customer account. The existing `customer_complete_test_registration()` RPC already provides the intended tenant-scoped registration path.

A minimal frontend repair was applied so an authenticated customer session first checks `customer_get_profile()` and, when no customer row exists, completes the tenant-scoped customer registration before loading the portal data. This also runs for restored sessions, preventing the previous `Active customer account required` state after email-confirmed signup. No RLS, subscription, or tenant-security rules were weakened.

**Status:** Implemented. Browser re-test required: refresh/sign in as `tradeflow1@yahoo.com`, confirm the Shop loads the published DJI listing, then continue to checkout.

## Retail payment / external Stripe
External payment architecture remains **BLUE / Implemented, verification open**. `create-stripe-checkout-session` is JWT-protected and server-side; `stripe-payment-webhook` verifies signed events and delegates reconciliation to `process_external_payment_event()`. Provider/event idempotency and retry handling are implemented.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. Required production sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Inventory photograph fault investigation — 18 September 2026

The first photograph implementation was traced before making another frontend change. Storage upload was confirmed to be succeeding: physical objects were being created under the Test Business C inventory asset path, but no corresponding `media_assets` rows or `inventory_asset_media` links were being created.

Live RLS/grant inspection identified the concrete fault: `public.media_assets` had the required authenticated INSERT/UPDATE/DELETE privileges and a permissive tenant-member RLS policy, but the `authenticated` role did **not** have SELECT privilege. The original browser code used `Prefer: return=representation` for the metadata INSERT, which requires the newly inserted row to be returned; the missing SELECT privilege prevented that path from completing correctly. Supabase's current documentation also confirms that INSERT/RETURNING behaviour can require SELECT access under RLS.

**Minimal backend repair applied:** `GRANT SELECT ON public.media_assets TO authenticated;`

No RLS policy was weakened, no tenant boundary was changed, and no Inventory permissions/subscriptions were changed. The existing tenant-member SELECT policy remains the data boundary.

The frontend was deliberately returned to the last known-good Inventory runtime while this backend fault was isolated. This prevents another photograph repair from being allowed to destabilise Inventory loading.

**Current verification state:** backend diagnosis and grant repair **Implemented and database-tested**; photograph upload is now **browser-tested successfully** with four complete Storage → media metadata → inventory-media link records confirmed for the test asset. The remaining issue is duplicate submission protection, not the media pipeline itself.

**Next narrow test:** after the duplicate-submission hardening is cache-busted, verify Inventory still loads and upload exactly one photograph once. The upload button now disables during an active upload, media links receive sequential sort_order, and metadata registration uses return=minimal followed by a tenant-filtered lookup. Verify one user action produces one Storage object, one media_assets row and one inventory_asset_media link. Then verify the photograph renders. Only after that move separately to lifecycle transitions. Do not change Selling until that chain passes.

## Inventory photograph fault investigation — 18 September 2026

The first photograph implementation was traced before making another frontend change. Storage upload was confirmed to be succeeding: physical objects were being created under the Test Business C inventory asset path, but no corresponding `media_assets` rows or `inventory_asset_media` links were being created.

Live RLS/grant inspection identified the concrete fault: `public.media_assets` had the required authenticated INSERT/UPDATE/DELETE privileges and a permissive tenant-member RLS policy, but the `authenticated` role did **not** have SELECT privilege. The original browser code used `Prefer: return=representation` for the metadata INSERT, which requires the newly inserted row to be returned; the missing SELECT privilege prevented that path from completing correctly. Supabase's current documentation also confirms that INSERT/RETURNING behaviour can require SELECT access under RLS.

**Minimal backend repair applied:** `GRANT SELECT ON public.media_assets TO authenticated;`

No RLS policy was weakened, no tenant boundary was changed, and no Inventory permissions/subscriptions were changed. The existing tenant-member SELECT policy remains the data boundary.

The frontend was deliberately returned to the last known-good Inventory runtime while this backend fault was isolated. This prevents another photograph repair from being allowed to destabilise Inventory loading.

**Current verification state:** backend diagnosis and grant repair **Implemented and database-tested**; persistent browser photograph upload remains **Not yet Verified Live**.

**Next narrow test:** with Inventory loading normally, upload exactly one photograph to the existing `DJI Mini 4 Pro Test 3` asset, then verify all three layers: Storage object → `media_assets` row → `inventory_asset_media` link. If successful, verify the photograph renders, then move separately to lifecycle transitions. Do not change Selling until that chain passes.

## Selling workspace null-reference repair — 18 September 2026

The first attempt to enter Selling after subscriber tenant switching exposed a frontend null-reference: the subscriber authentication layer replaces `#business-name` with the tenant switcher when multiple memberships are available, while the Selling controller still attempted to write to the removed `business-name` element during load. This stopped the Selling workspace before listings/lookups could load.

Minimal repair applied to `selling-dashboard-fixed.js`: the business-name update is now null-safe. `selling-dashboard.html` cache version was incremented from `v=5` to `v=6` so the repaired controller is loaded. No authentication, tenant context, RLS, subscription or workflow authority was changed.

Test Business C also required an active sales channel for the intended listing test. A single `TradeFlow Storefront` channel was created for that tenant (`channel_type=storefront`, active). Drones remains active and selling-enabled, and the existing `DJI Mini 4 Pro Test 3` asset is `ready_for_sale`.

Verification state: frontend repair **Implemented**, browser retest required. Next narrow test: refresh Selling with the new cache version and confirm the workspace loads and the three Create Listing selectors populate from Test Business C. Then create exactly one listing and verify inventory media carryover.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → DB object → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.


## Test Business C — Buy & Sell end-to-end test tenant — 18 September 2026

- Created dedicated test tenant Test Business C (50641519-2aa5-4093-95e5-7e92bea733a6) on the live TradeFlow test environment.
- Assigned the existing Test Business A Admin test identity as an Admin member; no Owner account is required for routine workflow testing.
- Assigned the buy_sell plan in trialing state so Inventory/Selling capability checks can be exercised without weakening RLS or changing Test Business A's Buying-only subscription.
- Drones uses `model_number` as its category-specific Product Property. The duplicate Drones `condition` Product Property and its options were removed; Inventory now uses one core Condition field.
- Added Test Business C to the subscriber authentication and tenant-context allowlists and cache-busted Categories, Inventory and Selling runtimes.
- Test Business A remains the Buying subscription test tenant; Test Business B remains the Selling subscription test tenant. This separation preserves subscription-boundary tests.


### Subscriber tenant switching repair — 18 September 2026

The Inventory RLS error was traced to the active browser workspace remaining on Test Business A, whose Buying-only subscription correctly rejects inventory_assets INSERT. Test Business C was verified separately: the Admin test identity is an active member, inventory.manage is true, and the Buy & Sell plan exposes module.inventory. The subscriber authentication layer previously had no visible tenant switch after an authenticated session was established, making the browser repeatedly remain on the stale tenant context. A tenant switcher has now been added to the subscriber top bar and cache-busted. It lists only tenants returned by the authenticated subscriber membership RPC and reloads the workspace with the selected tenant. No RLS policy was weakened.


## Subscriber tenant-context consolidation — 18 September 2026

- Deep inspection found multiple overlapping tenant/session layers: dedicated subscriber auth, a legacy compatibility bridge, and a test-lab tenant-context script. This could leave a subscriber workspace authenticated as one tenant while controllers read another tenant context.
- The subscriber authentication layer is now the single source of truth for the active tenant. The legacy subscriber-auth bridge was removed from Inventory and Selling page loads.
- subscriber-tenant-context.js no longer reads Customer/Test-Lab session storage or hard-coded user-to-tenant mappings; it waits for the dedicated subscriber auth promise and synchronises the URL tenant_id from that authenticated tenant.
- Categories controller now recognises Test Business C as well as A and B.
- Live verification: Test Business C has active Drones category; the Admin test user has inventory.view and inventory.manage; the Buy & Sell subscription has module.inventory enabled. Inventory RLS therefore remains unchanged.


## Subscription catalogue simplified to Basic and Enhanced — 18 September 2026

- The active customer-facing subscription catalogue is now deliberately reduced to **two plans**: `Basic` and `Enhanced`.
- `Basic` contains the complete operational Buy & Sell core: buying, customer portal, valuation, offers, inventory, selling, orders, fulfilment, storefront, trade-in and website editor/preview/publish capabilities.
- `Enhanced` contains the full Basic set plus all currently defined add-on capabilities: staff, staff messaging, audit, analytics, integrations and market intelligence.
- Legacy plan codes `buying`, `selling`, `buy_sell`, `business` and `advanced` are retained as inactive historical records rather than deleted, preserving auditability while preventing new subscriptions from selecting them.
- Existing active/trialing test subscriptions were reassigned to the two-plan model: Test Business C is the Enhanced end-to-end tenant; the other active test subscriptions are Basic.
- Platform Owner tenant creation UI now exposes only Basic and Enhanced.
- This is a replacement of the customer-facing plan structure, not a relaxation of subscription capability enforcement. `private.has_tenant_feature()` remains the capability authority.
- Live migration recorded as `064_simplify_subscription_catalog.sql`.


## New-chat continuation checkpoint — 18 September 2026

- The long-running Categories issue is now resolved and **Verified Live**. Subscriber Admin authentication works; Categories loads and the Drones category is selectable.
- Product property workflow is **Verified Live** for Drones → `model_number` (text). The separate Drones `condition` Product Property was removed to keep Inventory condition simple and avoid duplicate condition fields.
- Inventory correctly rejected product creation under Test Business A because its Buying-only subscription does not include `module.inventory`. Do not weaken RLS or alter Test Business A to bypass this.
- A dedicated **Test Business C** was created for end-to-end Buy & Sell testing: tenant ID `50641519-2aa5-4093-95e5-7e92bea733a6`, slug `test-business-c`, active Admin membership for `leannelauren07@gmail.com`, Buy & Sell plan in `trialing` state. It has a Drones category and the same model_number/condition properties/options for end-to-end testing.
- Subscriber authentication was updated to include Test Business C and to verify memberships through `subscriber_get_my_memberships()`. Inventory/Selling runtimes use the dedicated subscriber session. Relevant pages were cache-busted.
- **Immediate next action:** continue Inventory verification with photographs and private media storage for the successfully created Test Business C product. Then verify media links and lifecycle transitions before moving to Selling. Do not move to Selling or Stripe until the Inventory → media → lifecycle chain is verified.
- Keep Test Business A for Buying subscription tests, Test Business B for Selling subscription tests, and Test Business C for full Buy & Sell end-to-end workflow testing. Owner remains reserved for Owner-only tests; Admin is the routine workspace test account; Staff is for permission/restriction tests.
- Do not restart broad audits or repeat already-verified category work. Continue from this exact checkpoint and inspect current GitHub/live Supabase state before any material change.


## Inventory photograph duplicate-submission hardening — 18 September 2026

The first successful browser upload produced four copies of the same selected image in the live database. Inspection confirmed four complete records were created within approximately one second: each had a distinct Storage path, a corresponding media_assets record and a corresponding inventory_asset_media link. This establishes that the media pipeline itself is now functioning end-to-end; the remaining issue is duplicate submission during an active upload, not tenant/RLS failure.

Minimal frontend hardening applied to inventory-dashboard-fixed.js:
- the upload button is disabled for the duration of the active upload;
- repeated clicks while the operation is running are ignored;
- multiple deliberately selected files remain supported;
- sequential sort_order values are assigned rather than every new photograph being order 0;
- metadata registration uses return=minimal followed by a tenant-filtered SELECT;
- if a later stage fails, the newly uploaded Storage object is deleted to avoid an orphan.

The HTML cache version was incremented to ensure the browser receives the repaired runtime. No RLS, subscription, tenant, authentication, Inventory lifecycle or Selling code was changed.

Verification state: duplicate-production cause identified and frontend repair Implemented. The four existing duplicate test records are retained temporarily for traceability; do not treat them as four intended product photographs. Before lifecycle testing, confirm one fresh single-click upload creates exactly one new media chain and renders correctly.

## Customer storefront build — 18 September 2026

The public customer website has now moved beyond a static landing-page shell. The published storefront renders the subscriber's published site content and requests only listings that satisfy the public publication boundary: the tenant has a published website revision, the listing is published, its category is active and selling-enabled, and its sales channel is active.

A new `public.get_published_store_listings(uuid)` SECURITY DEFINER read function was added with execution granted to `anon` and `authenticated`. It returns only public listing fields needed by the storefront: listing reference, title, description, asking price, currency, quantity and category name. It does not expose operational tenant/customer/order/payment data.

The public site now has a real **Shop** section and links customers into the tenant-specific Customer Portal to view and purchase available products. The existing paid test order has reserved the DJI listing, so the current public Shop correctly has no available product from that test listing. A populated-storefront browser test should use a clean published listing rather than altering the paid order's state.

The Website Builder and public renderer remain separate from subscriber operational data. Website publication continues to use the published revision architecture.

**Status:** Implemented Live at the code/database boundary. Browser verification of the public storefront and anonymous listing read remains open.

## Fulfilment workspace auth repair — 18 September 2026

The existing fulfilment workspace was found to be using the older test-lab session/key and only contained Test Business A/B tenant mappings. It has now been switched to the dedicated subscriber authentication layer used by the current subscriber workspace and can resolve the active subscriber tenant from the authenticated session.

The existing fulfilment RLS boundary remains unchanged. Live checks confirm Test Business C has `module.fulfilment` enabled and the Admin test account has `fulfilment.manage` permission. No RLS or subscription rule was weakened.

**Status:** Implemented Live. Next browser test: open Fulfilment as Test Business C Admin and create the fulfilment for `ORD-20260918-DB2A42EF`. Then move the fulfilment through its controlled lifecycle one transition at a time.


## Corrected top-level customer flow — 18 September 2026

The intended TradeFlow product hierarchy is now explicit: **TradeFlow SaaS website → plan selection/subscriber signup → subscriber business account → subscriber Buy & Sell workspace → subscriber builds/publishes their own customer-facing website → that tenant website serves the subscriber's customers.**

The root `index.html` is now the TradeFlow SaaS website rather than the Customer Test Lab. The former test-lab page has been preserved as `test-lab.html` so test infrastructure is no longer the product homepage.

The SaaS homepage now presents the two active plans, Basic and Enhanced, and routes plan selection into subscriber onboarding. A secure authenticated `subscriber_create_business()` RPC creates the new tenant, owner membership and trialing subscription for the selected active plan. Anonymous execution is explicitly revoked. The current live database does not yet contain Stripe provider price IDs for these SaaS plans, so paid recurring subscription checkout is intentionally not represented as complete yet.

Subscriber authentication has also been changed from a hard-coded Test Business A/B/C allowlist to the authenticated `subscriber_get_my_memberships()` result. This is required for real subscriber businesses created through onboarding while retaining tenant isolation.

**Status:** Implemented Live at the product-entry/onboarding boundary. Browser verification of new subscriber signup and subsequent Buy & Sell dashboard entry is the next test.


## Stage 1 — TradeFlow SaaS homepage and Platform Owner dashboard — 18 September 2026

Stage 1 is explicitly the TradeFlow SaaS layer. The public root page is the TradeFlow commercial homepage where businesses learn about the platform, choose Basic or Enhanced and enter subscriber onboarding. It is not a subscriber's storefront and does not handle a subscriber's customer transactions.

Implemented:
- index.html is the TradeFlow SaaS homepage.
- subscriber-signup.html is the subscriber onboarding entry point.
- subscriber-dashboard.html is the private subscriber business workspace reached after authentication.
- platform-owner-dashboard.html is the separate private Platform Owner dashboard.
- platform-owner-dashboard.js authenticates through Supabase Auth, verifies an active platform_memberships record for the signed-in user, then reads subscriber businesses through the existing privileged platform_admin_list_tenants() RPC.
- platform-owner-dashboard.css provides the platform administration presentation.
- The Platform Owner dashboard is deliberately separate from tenant dashboards and does not expose tenant customer/order data directly.

The Platform Owner dashboard currently provides the platform-level foundation: subscriber business count, active business count, Basic/Enhanced counts and a tenant/subscription overview. Platform-level commercial administration can be extended without turning the dashboard into a tenant workspace.

Verification state: Implemented in GitHub. Browser verification of Platform Owner sign-in/dashboard rendering remains open.

Next Stage 1 test: open the SaaS homepage, verify the Basic/Enhanced routes, then open the Platform Owner dashboard and sign in with the existing platform-owner account. Separately verify the subscriber dashboard route with an authenticated subscriber account. Do not create another test tenant unless onboarding itself is the test.


## Stage 1A — Owner Dashboard subscriber registration details — 18 September 2026

The first Owner Dashboard step is now focused on businesses entering TradeFlow through the SaaS homepage. The Owner Dashboard receives platform-level subscriber account details: business name, owner name, owner email, business slug, business status and joined date.

A dedicated owner-only RPC, `public.platform_admin_list_subscriber_accounts()`, calls the existing platform-owner access check and returns the subscriber account summary. Anonymous execution is explicitly revoked; only authenticated callers can execute the public wrapper, and the underlying private function enforces Platform Owner access.

The existing tenant/subscription summary remains available for the platform overview, but subscription management is deliberately a later Stage 1 step. No retail/customer transaction data is exposed by this subscriber-registration view.

**Verification state:** Implemented Live at database/code boundary. Browser verification of the new subscriber details table is the next narrow test.


## Stage 1B — Owner Dashboard subscriber directory cleanup and website access — 18 September 2026

The Owner Dashboard subscriber directory has been separated from development/test tenants. Five current tenant records are explicitly marked `settings.test_lab=true`: Test Business A, Test Business B, Test Business C, TradeFlow Platform Test 01 and TradeFlow Security Test 03. These records are not real SaaS subscribers and are excluded from the commercial Subscriber Businesses directory.

The dedicated `public.platform_admin_list_subscriber_accounts()` RPC now filters out `test_lab` tenants and remains restricted to authenticated callers, with the underlying private function enforcing Platform Owner access. The function uses an empty search path with schema-qualified objects for the SECURITY DEFINER boundary.

The subscriber directory now includes a **View website** action. This opens the tenant public renderer for the selected subscriber. It is a viewing link, not an owner-side substitute for the subscriber's Website Builder.

Categories and Website Builder are not being made a separate owner-side product for each subscriber at this stage. The current active plan model already places the operational Buy & Sell core, categories and website editor/preview/publish capabilities in Basic; subscription entitlements will be handled in the dedicated subscription stage.

Raw subscriber customer records are not part of the Owner Dashboard subscriber directory. Subscriber customers remain tenant-scoped. If platform-level customer reporting is later required, it should be an explicitly designed aggregate/support capability rather than exposing tenant customer records by default.

**Verification state:** Implemented Live at database/code boundary. Browser verification of the filtered directory and View website action remains open.


## Stage 1C — Three-plan subscription catalogue and Owner controls — 18 September 2026

The commercial subscription model is now defined as three active plans:

- **Basic** — self-configured Buy & Sell core. The subscriber chooses from the configured website template/colour options, can add their logo and images, and creates their own categories and subcategories for the business.
- **Enhanced** — Basic plus staff management, staff messaging, audit, analytics, integrations and market intelligence.
- **Catalogue** — Enhanced plus a TradeFlow-provided starting catalogue of categories, subcategories and products.

The live plan catalogue now contains basic, enhanced and catalogue as the active customer-facing plan codes. The legacy buying, selling, buy_sell, business and advanced codes remain inactive for historical auditability.

The catalogue.pre_filled capability records the pre-filled catalogue entitlement. Its quantity configuration is intentionally left unset until the commercial limits for categories, subcategories and products are decided; no arbitrary quantities have been invented.

The existing website editor entitlement now records the Basic/Enhanced website capabilities for template selection, colour selection, logo upload, image content and custom categories/subcategories. Catalogue carries the same website editor capability.

A new platform-owner-only subscription management RPC provides two controlled platform actions:

- upgrade — moves a subscriber to a higher active plan only.
- close — cancels the latest subscription record and archives the tenant while retaining its stored business data.

The Owner Dashboard now displays plan and subscription status and provides an Upgrade action and Close account action. It does not expose subscriber customer records.

This is a platform subscription-management layer, not yet the final Stripe recurring billing implementation. Owner plan changes currently update the TradeFlow subscription record; provider price IDs and production Stripe subscription lifecycle remain a separate billing boundary.

**Verification state:** Database migration and entitlement/RPC boundary **Implemented and database-verified**. Owner Dashboard browser verification of the new three-plan display and controls remains required. No test subscriber has been upgraded or closed merely to test the controls.


## Stage 1D — SaaS homepage visual redesign — 18 September 2026

The TradeFlow SaaS homepage has been redesigned as a customer-facing marketing landing page. It now includes a branded TradeFlow SVG logo, navy/orange visual identity, hero section, workflow explanation, feature grid, three-plan presentation, example website previews, facts CTA, legal/support navigation and primary signup/sign-in CTAs.

The subscriber signup architecture remains separate from website configuration: the initial signup page should collect account/business identity and plan selection, while the subscriber dashboard will handle website URL/domain configuration. Do not add a customer-facing website slug field back to the public signup flow without an explicit architecture decision.

Example website previews on the homepage are illustrative UI compositions, not claims that the displayed businesses are live TradeFlow customers. Real GearCashOut screenshots should only be added from an authorised/verified source and must remain reference material; GearCashOut itself is not to be modified.

**Verification state:** Landing page/logo redesign **Implemented in GitHub; browser verification still required.**


## Stage 1E — Public front-end pages and signup presentation — 18 September 2026

The public TradeFlow front end has been extended beyond the landing page so the primary navigation now resolves to actual front-end pages rather than unfinished destinations.

Implemented:
- `facts.html` — TradeFlow platform facts and architecture overview.
- `examples.html` — illustrative camera/drone, technology and fashion resale website examples.
- `terms.html` — structured Terms & Conditions draft page, clearly marked as requiring final legal completion/review.
- `privacy.html` — structured Privacy Policy draft page, clearly marked as requiring final legal completion/review.
- The shared `platform.css` now supplies the branded information-page and example-page presentation.
- The subscriber signup page no longer asks the prospective subscriber to choose a public website URL/slug. The internal onboarding slug is generated from the business name so the existing `subscriber_create_business` RPC contract remains intact.
- Signup copy now explains that the customer-facing website address is configured later from the authenticated subscriber workspace.

The example website panels are front-end compositions for now. They provide the intended placement for later authorised screenshots or real website imagery without changing the page structure.

**Verification state:** Front-end files are implemented in GitHub. Browser verification remains required before marking the new pages Verified Live.


## Stage 1F — Homepage CTA and subscription-selection gate — 18 September 2026

The public homepage CTAs no longer open subscriber account creation directly. The header **Get started** and hero **Start your free trial** actions now take the visitor to the public plan-selection section. Each plan card then passes its selected plan into subscriber signup.

Subscriber signup now requires an explicit Basic, Enhanced or Catalogue selection before account creation. A direct visit to the signup page without a plan no longer silently defaults to Basic.

**Verification state:** Implemented in GitHub; browser verification of the CTA → plan → signup flow remains required.
