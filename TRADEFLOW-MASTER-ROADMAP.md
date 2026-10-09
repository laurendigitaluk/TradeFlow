# TradeFlow Master Build Roadmap & Verification Register

> **LIVE FULL SYSTEM AUDIT — 9 OCTOBER 2026**
>
> - Correct LIVE Supabase project reference: `gxsrajtqzdjvmceqcpgv` (the previously repeated `...v5` reference is invalid). TEST remains `twfbmjwwqzxdxvclxbun`.
> - LIVE Adventure Outpost tenant `b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52` is active. LIVE has 2 non-deleted Auth users: 1 platform-owner membership and 1 active Adventure Outpost subscriber membership. The `public.customers` table contains 0 records, including 0 customer-login links for Adventure Outpost. No SceneSource website customer has been confirmed or created.
> - `www.scenesource.co.uk` is the active primary domain and has published-site revision 1. Do not alter DNS, SSL, Cloudflare routing, the published site, or account credentials as part of this audit.
> - **Worker configuration discrepancy and isolated candidate fix:** production `wrangler.jsonc` declares `LIVE_SUPABASE_URL` as `https://gxsrajtqzdjvmceqcpgv2.supabase.co`, which does not match the verified LIVE project URL. The correction is committed only to isolated branch `audit/fix-live-supabase-url-20261009` at `04fc24cad71aaf6efe5e7472022bfd5bc6b8d939`. A static Worker-source transformation check confirms the malformed URL is absent from the candidate config and the correct LIVE URL remains in the transformed public-site source. This is **not deployed or merged**; controlled non-production runtime and browser route/session tests are still required before promotion.
> - **Open retired-code discrepancy / elevated risk:** five old LIVE domain-purchase/registration Edge Functions remain ACTIVE (`porkbun-domain-availability`, `create-domain-checkout-session`, `reconcile-domain-payment`, `save-domain-registrant`, `porkbun-domain-registration`). The current subscriber domain-settings frontend does not call them. LIVE has two legacy domain orders (`pending_payment` and `registrant_details_saved`) and one registrant record; both order rows have sandbox flags false or absent. The `registrant_details_saved` order is therefore not marked as sandbox, and the old registration function may proceed if production Porkbun credentials are configured. Do not invoke it. Do not delete records or disable functions until status, credentials and callers are reviewed. The current subscriber domain model remains customer-owned domains plus Platform Owner connection/verification.
> - LIVE Supabase reports RLS enabled on all 98 public tables. Advisors also report 14 RLS-enabled tables with no policies, 14 anon-callable SECURITY DEFINER functions, 160 authenticated-callable SECURITY DEFINER functions, disabled leaked-password protection, and performance findings (64 unindexed foreign keys, 166 RLS init-plan findings, 105 unused indexes, 14 multiple-permissive-policy findings and 3 duplicate indexes). These are review queues, not permission to bulk-change policies or indexes; review each against intended access and current code before repair.
> - The `production` and `main` branches have diverged substantially. Do not merge or force-sync them as part of cleanup.
> - The customer registration code and tenant-registration RPC exist, but the three-role Chrome session test and live clean-route acceptance tests remain **PENDING**. The external site could not be independently fetched by the audit tools; the latest recorded browser screenshot in the continuation checkpoint showed the homepage rendering.
>
> This snapshot supersedes older conflicting environment/status notes. Audit queries were read-only. No LIVE runtime code, database rows, authentication accounts, subscriptions, DNS, Cloudflare settings or published content were changed.

**Version:** 5.12  
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



## CURRENT PROJECT STATE — 7 OCTOBER 2026

### Current architecture
TradeFlow is being completed against LIVE while the product is being finished. The permanent future release model remains TEST → verify → promote to LIVE once the known-good LIVE baseline is captured.

LIVE:
- GitHub branch: `production`
- Supabase: `gxsrajtqzdjvmceqcpgv`
- Cloudflare Worker → LIVE Supabase
- Website Builder has a locked standard baseline from 5 October 2026.

### Website Builder
The approved reusable Website Builder is locked. Do not redesign, reposition, resize, restructure or replace the locked arrangement without an explicit reopen decision. The draft/publish revision workflow remains authoritative and must not be confused with application deployment.

### Domain architecture
TradeFlow's old automatic subscriber domain-purchase workflow is retired.

Current subscriber model:
**Subscriber buys/owns domain → enters hostname in TradeFlow → Platform Owner prepares connection → exact DNS instructions → subscriber applies DNS → DNS/SSL/routing verification → active domain.**

No registrar password is requested. No DNS target is invented. No unverified domain is activated.

Platform infrastructure domain:
- `laurendigital.co.uk` was purchased directly through Porkbun and is active in Cloudflare on the Free plan.
- The existing LIVE `tradeflow` Worker is connected through Cloudflare Custom Domain at `tradeflow.laurendigital.co.uk`.
- The branded TradeFlow URL has been browser-verified over HTTPS; public homepage and authenticated subscriber workspace both load.
- Customer-owned subscriber domains remain a separate connection workflow.
- Future Cloudflare for SaaS/custom-hostname automation remains relevant for subscriber-owned domains, but the TradeFlow platform itself does not need another Worker.

### Shipping
Manual subscriber-managed shipping is authoritative. Parcel2Go API/checkout/payment-link shipping is retired.

### Code/documentation cleanup — 6 October 2026
Retired domain-purchase/registrant frontend, old domain-purchase Edge Function source, Parcel2Go source, ResellerClub source and unused duplicate dashboard runtimes have been removed from the production repository. Historical checkpoints remain as audit evidence.


## 2026-10-07 — URL architecture milestone

### LIVE platform
**Verified Live:** `https://tradeflow.laurendigital.co.uk`

The existing `tradeflow` Worker is connected to the active `laurendigital.co.uk` zone through a Cloudflare Custom Domain. The public site and authenticated subscriber workspace have been browser-tested on the branded URL.

### Subscriber URL hygiene
`tenant_id` remains the internal tenant/security identifier. It must not be removed from internal database/RLS/authentication use.

Normal subscriber-facing browser URLs should use a stable business slug rather than exposing a raw tenant UUID. Current example:

`Adventure Outpost` → `adventure-outpost`

The current subscriber workspace removes the legacy `tenant_id` query parameter from the visible URL after tenant context is established.

### Lauren Digital parent/product structure
- `laurendigital.co.uk` — Lauren Digital parent/company site.
- `tradeflow.laurendigital.co.uk` — TradeFlow platform.
- Future products may receive separate subdomains when ready.
- Customer-owned subscriber domains remain independent of the Lauren Digital product subdomains.

A future Lauren Digital homepage and separate owner-only login route are recorded as planned architecture, not current implementation scope.

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


## Stage 1G — Homepage hero device proportion refinement — 18 September 2026

The TradeFlow SaaS homepage hero device presentation has been refined after visual review. The GearCashOut reference website is now displayed inside a more realistic laptop-sized screen proportion rather than an overly wide display. The laptop includes a restrained lower base, with the existing mobile device retained as the secondary responsive example.

This is a presentation-only change. No subscriber, tenant, customer, buying, inventory, selling, payment or fulfilment behaviour was changed.

**Verification state:** Implemented in GitHub. Browser/live visual verification remains required.


## Stage 1I — Homepage hero copy simplification — 18 September 2026

The small eyebrow text **BUY & SELL BUSINESS PLATFORM** has been removed from the homepage hero because it repeated the message already communicated by the main headline **Your Buy & Sell Business. Built Your Way.** The hero now leads directly with the primary value proposition, keeping the above-the-fold message simpler and more focused.

This is a presentation-only copy change. No platform, subscriber, tenant, customer, buying, inventory, selling, payment or fulfilment behaviour was changed.

**Verification state:** Implemented in GitHub. Browser/live visual verification remains required.

## Stage 1H — Homepage hero website presentation refinement — 18 September 2026

Following visual review, the hero no longer uses the GearCashOut-branded laptop and phone as the primary homepage visual. Those reference visuals made the example business visually dominant and the previous device treatment looked like an artificial mockup.

The hero now presents a neutral, TradeFlow-branded **customer website preview** inside a clean browser-window frame, with a restrained secondary mobile preview. The sample content uses generic “Your Business” branding rather than a named reference business. The floating white labels identifying “Example customer website / GearCashOut” and “Your brand / Your website” have been removed.

This follows current SaaS/website-builder presentation patterns: product/website previews are shown in context, with a clear visual hierarchy and the product itself remaining the subject rather than a reference customer brand. Web research also supports using focused product visuals and browser/device framing to make the experience tangible. 

**Verification state:** Implemented in GitHub. Browser/live visual verification remains required.

## Stage 1J — Subscriber test reset, dashboard usability and website templates — 18 September 2026

The legacy test environment has been closed ahead of the next real subscriber onboarding test. Test-lab tenants were archived and their subscriptions cancelled. The Platform Owner Auth account `leannelaurenlowe@hotmail.com` was retained and remains a platform-level account, not a subscriber tenant member. Two orphaned test Auth users were deleted.

The subscriber dashboard shell was refined to make the active business, signed-in email, role and tenant identity visible without requiring the user to infer which account is active. An Account dialog provides the same identity information in one place. Existing operational workspaces remain the destination for their actual controllers and backend workflows.

Catalogue remains a planned capability but is deliberately not exposed in the subscriber operational rollout until Gemma can maintain/update the product catalogue.

Website Builder now provides six distinct starting layouts: Business, Buy & Sell, Services, Editorial, Minimal and Retail. The existing site revision/publishing architecture remains in place; the selected template is stored as part of the site's existing content and the public renderer applies the corresponding layout variation.

**Status:** database cleanup **Verified**; subscriber dashboard and template changes **Implemented on staging branch, browser verification required**. Next test is a fresh subscriber signup through the normal TradeFlow onboarding flow.

## Stage 1K — Business workflow and website separation — 18 September 2026

The subscriber Business Dashboard has been reorganised around the real operational chain: Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns. Customers and Finance remain supporting business areas. Website Builder has been removed from the daily operational dashboard.

A separate subscriber website-management page now provides Website Builder, public website preview and return to the Business Dashboard. The expected subscriber pattern is to build/publish the website, then return to the operational dashboard and only revisit Website management for later maintenance.

Subscriber authentication now hides protected page content until the dedicated subscriber session and active tenant membership are verified.

**Status:** Implemented on staging; browser verification required before merge.

## Sign-in entry correction — 18 September 2026

The public TradeFlow **Sign in** links now point to a dedicated `subscriber-login.html` page rather than sending a visitor directly to the protected subscriber dashboard. The login page provides an explicit subscriber sign-in form and a clear **Create account** path to `subscriber-signup.html`.

A separate auth-overlay visibility issue was also corrected: the protected-page guard hides dashboard content while authentication is unresolved, but it no longer hides the sign-in overlay itself.

**State:** Implemented on main; browser verification is required against the deployed GitHub Pages site.

## Verified-email subscriber onboarding correction — 18 September 2026

A signup could previously create the Auth user but stop before `subscriber_create_business()` when Supabase email confirmation was required, leaving a verified user with no tenant membership. The signup now stores the selected business name and plan code in the Auth user metadata so the setup details survive email confirmation. On the first successful subscriber sign-in, if the verified account has no active membership and those validated setup details are present, the authenticated session calls the existing `subscriber_create_business()` RPC and then continues to the subscriber dashboard.

The current verified test account `scenesource1@gmail.com` had no tenant membership, so its signup metadata was repaired to `subscriber test 1` / `basic`. No tenant was created directly by the repair; the normal authenticated RPC path will create it on the next sign-in.

**State:** Implemented on main. Browser verification required: sign in with the verified account and confirm the Business Dashboard opens with the new tenant membership.

## Customer preview and subscriber branding correction — 18 September 2026
- The Website Builder's `Preview customer dashboard` action now opens the dedicated `customer-dashboard-preview.html` read-only preview rather than the live `customer-dashboard.html` customer portal. The live customer portal requires customer authentication and its current test-lab tenant context, so it is not an appropriate subscriber preview target.
- The preview is tenant-scoped through the existing subscriber authentication/tenant context and reads the subscriber's draft website branding for the preview name and accent colour.
- The subscriber Business Dashboard header now displays the authenticated subscriber business name instead of the fixed `TradeFlow` label. This establishes tenant-specific branding without changing tenant security or customer authentication.
- An actual uploaded image logo is not yet stored by the current website-builder schema; the current change therefore uses the subscriber business name as the dashboard brand. Do not describe image-logo upload support as implemented until a tenant-scoped logo asset flow is added and tested.


## Website Builder guided template expansion — 18 September 2026
- Expanded the subscriber Website Builder from 6 starting templates to 10: Business, Buy & Sell, Services, Editorial, Minimal, Retail, Professional, Bold, Classic and Local Business.
- Added guided builder instructions explaining the build sequence, business identity, category setup, product setup, website pages, preview, save and publish.
- Added clear links from the builder to Categories & Properties, Inventory and Selling.
- Added category guidance: subscriber buying categories are the category structure used for the item through acquisition/inventory and, when selling is enabled, the same category can be used for the product/listing rather than requiring a duplicate selling category.
- Added editable page definitions for About, Contact, Terms & Conditions, Privacy Policy, FAQ, Delivery & Returns, Sell to us, Shop and Customer account. Each page can be enabled/hidden and given a title, body content and optional SEO fields. Shop and Customer account remain system-driven areas; product/category data comes from the existing operational workflow.
- Public subscriber websites now build navigation from enabled page definitions and can render the selected page through the existing published website content path.
- This is a frontend/content-schema expansion over the existing tenant website state and revision architecture; it does not bypass tenant security or replace the existing category/inventory/listing workflow.


## Stage 1L — Website Builder usability and page library correction — 18 September 2026

The Website Builder was corrected after browser inspection showed two usability problems: template choices were not reliably actionable, and the available editable pages were not obvious to a subscriber.

The builder now provides:
- explicit clickable template buttons with selected-state feedback;
- direct four-step navigation through the builder;
- a visible page index with an **Edit page** action for every page;
- editable Business Information, Contact, Terms & Conditions, Privacy Policy, Cookie Policy, Delivery & Returns, About, Sell to us, How it works, FAQ, Payments, Warranty & Guarantees and Complaints pages;
- built-in Shop and Customer account entries;
- optional pages that can be edited without being shown in navigation;
- page title/body/SEO editing and page-specific instructions;
- live preview navigation for the enabled pages;
- preservation of any existing website `category_manifest` content when saving a draft.

The category explanation was also tightened to match the actual database model: Buying and Selling are capability flags on the same category record, not two automatically generated duplicate categories.

The linked Categories and Inventory controllers were corrected to use the authenticated subscriber tenant context instead of hardcoded test tenant lists. This is required for newly created subscribers to use those linked operational areas without weakening tenant security.

**Status:** Implemented on main; browser verification required for template selection, page editing/navigation, category access and Inventory access for a newly provisioned subscriber.


## Stage 1M — Website Builder media, selling-page branding and domain entry — 18 September 2026

The Website Builder has moved beyond text/template selection into visual brand building. Subscribers can upload a homepage image and page-specific images, including separate branding for the Sell to us / Buying page and Retail Shop page. Images use the tenant-scoped tradeflow-site-media Storage bucket and existing media_assets metadata architecture.

The ten template starting points now have more visible differences in navigation, hero treatment, cards, spacing and colour application. They remain starting layouts rather than a full drag-and-drop page builder.

The Business Dashboard now exposes Website URL management. Domains are saved against the tenant in tenant_domains as pending. Automatic public routing already exists for active domains through published_site_index; however, the actual DNS/hosting target and ownership verification service must be selected before automatic domain activation is implemented.

The publish RPC was updated to accept website content schema versions 1 and 2, matching the current Website Builder.

**Status:** Implemented on main; browser verification required.


## Stage 1N — Visual Website Builder — 18 September 2026

The Website Builder is now being changed to a visual page-first editor rather than a form-heavy configuration screen. The subscriber selects a page in the sidebar and edits the actual page shown in the main canvas. This directly addresses usability for subscribers who do not understand website terminology or separate form fields.

Scope implemented:
- Full-page visual canvas with direct click-to-edit text.
- Home, Sell to us / Buying and Retail Shop pages are visibly editable in context.
- Page-specific image add/replace/remove controls.
- Subscriber logo upload wired into site branding and public rendering.
- Visual miniature template choices for the ten existing starting designs.
- Clear separation between editable website content and TradeFlow-managed operational data.
- Existing draft/revision/publish architecture retained.

Next verification: browser-test a newly provisioned subscriber through page switching, direct editing, image/logo upload, Save Draft, Publish and public website rendering. Do not mark Verified Live until those actions are observed working.

The custom Website URL entry remains a separate domain/hosting workstream; a saved pending domain is not the same as a fully routed custom domain.

## Stage 1O — Premium two-sided homepage — 18 September 2026

The subscriber website homepage has been expanded into a premium two-sided buying/selling presentation. It now supports a strong hero, separate buying and retail narratives, configurable 6/8/10 visual tiles, per-tile images and direct on-page editing. A Premium Marketplace starting template has been added.

The architecture deliberately separates website presentation from operational data: the homepage can visually promote products and buying categories, but actual retail listings remain controlled by Inventory → Selling and published through the existing storefront RPC.

Next verification: browser-test the premium homepage end-to-end and inspect it at desktop/mobile widths before marking Verified Live.

## Website Builder load entitlement repair — 18 September 2026

A newly registered subscriber reached the Website Builder but the canvas did not load. The live database contained the tenant, owner membership, website state and draft revision. The failure was the subscription capability window: signup created trialing with no trial_end, while private.has_tenant_feature() requires a future trial_end for trialing subscriptions.

Migration 065_repair_subscriber_trial_entitlement_window.sql now gives new subscriber onboarding the established 30-day trial window and backfills affected trialing subscriptions without a trial end. Live checks for the affected subscriber confirm tenant membership plus website.editor and website.publish capability.

**Status:** Implemented Live; final browser reload of Website Builder remains open. No RLS/security boundary was weakened.


## Website branding and business extras — 18 September 2026

The subscriber Website Builder now supports a broader professional website layer: custom brand colours across the page, text, header/navigation, buying section, selling section and footer; social profile links; optional website sharing; and up to four review-site links. These settings are stored within the existing published site JSON and do not create separate tenant data or weaken security boundaries.

**Status:** Implemented in GitHub. Browser verification remains open.


## Restore checkpoint — 18 September 2026

This document is part of the locked TradeFlow stopping point for 18 September 2026. GitHub restore branch: checkpoint-tradeflow-20260918-premium-builder-final. Current main checkpoint commit: 0acc8d7ecca0de368172bf4fec1d746f11279dbd. Live Supabase includes migration repair_subscriber_trial_entitlement_window. Continue tomorrow from this checkpoint; do not modify GearCashOut.


## Domain purchasing workstream — 19 September 2026

### Database foundation completed

TradeFlow's existing custom-domain connection architecture has been extended to support a future built-in domain purchasing service.

Added:
- `domain_tld_catalog`
- `tenant_domain_orders`

Extended `tenant_domains` with:
- acquisition source;
- registrar/provider identifiers;
- registration and expiry timestamps;
- auto-renewal;
- provider metadata.

Security uses tenant-scoped RLS and the existing website-management/editor permission boundary. Registrar credentials are not stored in the database.

### Intended future flow

**Search → authoritative availability/price check → customer confirmation → payment → registrar registration → reconciliation → domain activation → DNS/hosting → SSL → published website.**

The current Website URL page remains a connect-an-existing-domain feature. Domain purchasing, payment checkout, registrar integration and automatic DNS/SSL activation remain separate implementation stages.

### Provider decision

No registrar has been hard-coded yet. Current research confirms that registrar APIs can expose real-time availability/pricing and registration, but support varies by TLD and provider. The production provider must be selected before provider-specific Edge Functions or checkout logic are implemented.

**State:** Database foundation implemented; end-to-end purchasing flow planned.



## Website Builder final refinement pass — 19 September 2026

The subscriber Website Builder has now received the agreed refinement pass before final browser review. Added: controlled typography options (font style, hero/section/body/navigation size levels), button styles, header styles, footer styles, optional homepage section visibility, optional second images for the homepage hero and content pages, and cleaner image controls with Add/Replace/Remove behavior. Homepage tiles remain unnumbered and directly editable.

Public rendering now consumes the saved typography, section visibility and multi-image settings. Asset cache versions are refreshed and both Builder and public runtime syntax have been checked. This is **Implemented in GitHub, not yet browser-verified**. Final verification should cover Builder preview, Save Draft, Publish, public site, responsive layout and the new controls.


## Draft preview and can_tenant permission repair — 19 September 2026

Browser verification exposed two separate issues. First, authenticated Website Builder operations were failing with `permission denied for function can_tenant`. The live database had the required RLS policies calling `private.can_tenant(uuid,text,text)`, but EXECUTE was only granted to postgres. Live migration `fix_authenticated_can_tenant_execute` restored EXECUTE to the authenticated role without changing the SECURITY DEFINER function or weakening tenant/feature checks. The migration is recorded in `supabase/migrations/066_fix_authenticated_can_tenant_execute.sql`.

Second, the Builder's previous `Open public website` link attempted to load the published-site path. A newly created subscriber may have a draft but no published revision, so that path correctly reports that no published website exists. The Builder link has therefore been renamed **Preview website** and now opens an authenticated draft-preview mode. The preview reads the signed-in subscriber's draft through existing RLS-protected `tenant_site_state` and `site_revisions` access; it does not expose drafts anonymously. The public site remains the published-site path and will work after the subscriber publishes a revision.

Validation: Builder and public-site JavaScript syntax checked OK; live EXECUTE grant confirmed for authenticated. Browser end-to-end preview verification remains the next user check.


## Website Builder / Subscriber Template Rebuild — 20 September 2026

The subscriber website system has been rebuilt on branch `website-template-unification` so the visual template selected in Website Builder is the same template family rendered by the public subscriber website.

### Customer-facing design rules
- Both sides of the business are first-class: **What We Buy** and **What We Sell**.
- The public header contains a prominent **What We Buy** menu, populated from the subscriber's connected Buying Catalogue.
- The public header contains a direct **What We Sell** link to the retail shop.
- The What We Buy menu expands as new catalogue categories are added; it is not a fixed list of categories.
- Buying category pages show the current connected products and provide a **Start selling this category** route into the customer account flow.
- Retail products are loaded from the subscriber's published Inventory → Selling data.
- A site with a small buying catalogue stays compact; the same layout can expand as categories and products are added.
- The template does not require subscribers to re-enter catalogue products, prices or inventory.

### Four-step subscriber setup
1. Add business name and logo.
2. Choose brand colours.
3. Choose one of the ten templates.
4. Save, preview and publish.

Content, buying categories and retail products remain connected to TradeFlow rather than being duplicated inside the website editor.

### Ten supported templates
Editorial, Classic, Grid, Studio, Horizon, Field, Business, Luxe, Commerce and Impact.

The public renderer now contains the same ten template layouts and responsive rules used by the builder. The previous public-site shell and legacy template styling were removed so an old static header cannot appear underneath the new template.

### Business-name handling
A blank subscriber business name is now displayed as **Your business** rather than the platform name. The old public fallback to **TradeFlow** was removed. TradeFlow remains only as the platform attribution in the footer.

### Preview / deployment
The public website assets were cache-bumped to version 40. This is intentional so browsers do not continue serving the previous public-site CSS/JavaScript after the template rebuild.

### Architecture
- `website-builder.js` remains responsible for editing and saving subscriber website content.
- `public-site.js` is now a clean public renderer for the same ten template IDs.
- `public-site.css` was replaced with a public-only stylesheet matching the ten fresh template designs rather than carrying the previous legacy template family.
- The public page shell is now only a loading container; the renderer owns the header, hero, buying section, selling section and footer.
- Custom-domain public links now retain the active tenant ID after hostname resolution.

### Important future rule
Do not add separate visual layouts to the public renderer. Any future template must be added to the shared ten-template system and tested in both Website Builder and public Preview before publication.


## Guided Customer Selling Journey — 20 September 2026

The public subscriber website now treats **selling to the subscriber** as a guided valuation/request journey rather than a catalogue list.

### Customer journey
1. **What do you have to sell?** — choose the subscriber's buying category.
2. **What type?** — choose the product type/branch derived from the connected buying catalogue.
3. **What make?** — manufacturer options are narrowed from the connected catalogue.
4. **What model?** — model options are narrowed from the previous selections; package/version is shown when available.
5. **What condition is it in?** — sealed, opened-unused, excellent, good, fair, damaged, or not working/spares.
6. **Final questions** — missing package items, legal right to sell, DJI serial number when applicable, and additional notes.
7. **Review** — the customer reviews the complete request before continuing to their customer account.

The completed answers are carried in browser session state into the customer portal so the customer does not have to enter the same information again. The customer portal pre-fills the category, item title and a structured notes summary before submission.

### Navigation behaviour
- The homepage now includes a prominent **What do you have to sell?** prompt.
- What We Buy category menu entries route into the guided selling journey with the selected category preselected.
- Start Selling links from buying categories route into the same journey.
- The old buying catalogue remains available as an information view, but it is no longer the primary selling path.

### Future-proofing
The hierarchy is generated from the subscriber's connected buying catalogue rather than hard-coded DJI/drone choices. New categories, product types, manufacturers, models and packages therefore become available to the customer as the subscriber expands the catalogue.

The TradeFlow `category_fields` system remains the intended extension point for category-specific questions beyond the common selling questions. Those fields can later be surfaced dynamically in this journey without creating a separate page for each category.

### Current scope limitation
Photos are not falsely represented as uploaded by this public wizard. The current journey captures the structured information and hands it into the authenticated customer portal. Photo upload should be added as an authenticated evidence step when the existing media/storage workflow is connected to customer buying requests.



## Stage 1P — Sales Channels / Marketplace Management foundation — 23 September 2026

Implemented the first dedicated multi-channel management layer.

### Implemented
- Added sales-channels.html and sales-channels.js.
- Added Sales Channels navigation to the subscriber dashboard and Selling workspace.
- Sales Channels reads tenant-scoped sales_channels and listings and reports active listing counts.
- Current storefront is displayed to staff as **Website** rather than the internal TradeFlow Website (storefront) label.
- eBay, Amazon and Other are displayed as unconnected marketplace destinations only. No marketplace credentials, fake connection state or external listing was created.
- Selling focused-product mode now loads all active listings for the physical Inventory asset rather than limiting the asset to one active listing.
- Added a per-product channel matrix showing each configured channel's listing status, price and direct EDIT LISTING action.

### Live database verification
The current Camerashack tenant has exactly one active sales channel: TradeFlow Website (storefront), with one active published Canon listing. No database channel records were added for eBay/Amazon/Other.

### Architecture decision preserved
The physical inventory_assets row remains the stock master record. Each marketplace/storefront listing remains a separate listings row linked by asset_id and channel_id. The existing per-asset/per-channel active-listing protection remains the basis for preventing duplicate active listings on the same channel.

### Not yet implemented
Automatic sale propagation is deliberately still open. The next lifecycle boundary is: sale on one channel → authoritative sold transition for the physical asset → other active channel listings become DELIST REQUIRED → staff/system closes those listings. This must be implemented against the authoritative order/sale workflow rather than as a browser-only status change.

**Status:** Implemented in GitHub; database-tested; browser verification required. The multi-channel automatic delisting boundary remains AMBER.

## Stage 1P.1 — Editable Sales Channels and connection setup — 23 September 2026

Implemented the next layer of Sales Channels / Marketplace Management on top of the existing physical-inventory master architecture.

### Implemented
- eBay, Amazon and Other now exist as real tenant-scoped sales_channels records rather than virtual UI-only rows.
- Added editable channel configuration: name, type, slug, description, enabled state and connection/setup instructions.
- Added **+ ADD SALES CHANNEL** for custom channels.
- Added **EDIT** and guarded **REMOVE** actions.
- Channels with active listings are disabled rather than deleted; channels with no active listings may be deleted. The core TradeFlow Website channel is protected from removal in this page.
- Added setup guidance for eBay and Amazon based on their current developer documentation. No marketplace credentials or false connection state are stored.
- Existing per-product channel matrix remains the place to see the same physical Inventory asset across channels.

### Live database state
The Camerashack tenant now has four channel records: TradeFlow Website, eBay, Amazon and Other. TradeFlow Website is the only connected/active storefront. The three marketplace channels are currently not connected.

### External connection prerequisites
For eBay, the eventual integration will require an eBay Developers Program application, OAuth/RuName configuration and the scopes required by the intended Sell APIs. eBay's Inventory API also requires seller business policies and an inventory location before offers can be published.

For Amazon, the eventual integration will require an SP-API developer/application setup, approved roles and the applicable seller authorization flow. Listing synchronization will use the SP-API listing/catalog/product-type capabilities.

### Still not implemented
- Real eBay OAuth connection callback/token exchange and secure credential storage.
- Real Amazon SP-API authorization/token exchange and secure credential storage.
- Channel-specific listing publish/update/delist APIs.
- Authoritative sale propagation and automatic DELIST REQUIRED handling across other active listings.

### Verification
GitHub implementation was syntax-checked for sales-channels.js. Live Supabase verification confirms the four tenant channel records and existing tenant-scoped RLS policies. Browser end-to-end verification of the new editable/add/remove modals is still required.

Status: **Implemented in GitHub + live DB, browser verification pending.**


## Restore checkpoint — Test One complete — 23 September 2026

Test One is now locked as the known-good end-to-end baseline.

- Restore branch: `checkpoint-test-one-20260923`
- Functional baseline commit: `80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1`
- Restore checkpoint documentation commit: `ea00d6ae238f6e47c4798b73ec6340ade2c2d5fd`
- Supabase project: `twfbmjwwqzxdvclxbun`

Test One successfully carried a new subscriber and new subscriber customer through customer selling/request, valuation/offer, inspection, purchase completion, Inventory, Selling, Sales Channels and published retail website listing.

The remaining identified subscriber-facing website feature is payment processing for the subscriber's own website Subscribe/receive-payment journey.

Test Two must be treated as a new validation run against the known-good Test One baseline. Do not overwrite working Test One behaviour merely to accommodate a Test Two failure; diagnose the first failure boundary against the checkpoint.



## Stage 1Q — Inventory catalogue and manual stock-entry architecture — 25 September 2026

The Inventory Add Product implementation was corrected after tracing the full path through current code, Supabase schema, project manuals and previous catalogue work. The previous implementation had been built against tenant_buying_products and Buying-oriented category loading. This contradicted the documented direct product path, which is intended to work independently of a Buying transaction.

The corrected architecture uses the tenant's selected master catalogue through get_inventory_product_catalogue(). The operator selects Manufacturer → Category → Product; product type/branch and the tenant category/branch mapping are derived from the selected catalogue record. inventory_assets now records catalogue_product_id for directly catalogued stock.

Inventory creation now has two explicit authoritative paths:
- completed acquisition → Inventory, retaining the existing payment/trade-in guard;
- authorised manual_inventory creation → Inventory, requiring an authenticated subscriber user with inventory.manage and a catalogue product.

The change preserves RLS and does not weaken the completed-purchase boundary. Live verification for Camerashack found 261 active selected catalogue products across 3 manufacturers. Authenticated rollback tests confirmed manual creation is accepted only through the explicit manual path and unmarked direct creation remains blocked.

Status: Implemented in GitHub + live DB verified; browser verification of the rebuilt Add Product UI remains the next test.


## 2026-09-28 — End-to-end customer valuation → sales audit
A fresh customer valuation submission is live and correctly creates a submitted Buying Request/Item. The first substantive gap is catalogue binding: the public customer selling submission does not populate `buying_items.buying_product_id`, so `calculate_buying_item_valuation` correctly falls back to manual/product_not_selected. The public condition vocabulary also needs reconciliation with valuation rules. Later server-side workflow boundaries (offer acceptance, shipping, receipt, inspection, payment, acquisition and Inventory creation) have live evidence, but a fresh browser walk through every stage remains open. Subscriber localStorage session fallbacks remain a multi-tab isolation risk, and notification delivery remains queued/unverified.

Audit checkpoint: `CHECKPOINTS/2026-09-28-end-to-end-customer-to-sales-audit.md`.

## 2026-10-02 — Chatbot completion before final domain/launch phase

The TradeFlow chatbot remains a pre-launch workstream and must be completed and tested before public launch. The agreed staged design is: (1) Subscriber read-only assistant using the finalized manuals and permitted tenant context; (2) Customer read-only assistant for the customer's own workflow/order/status information; (3) controlled messaging/enquiries; (4) controlled actions only after earlier phases are proven, with explicit permissions and auditability. The chatbot must never have unrestricted SQL/database access or cross tenant boundaries.

The domain work has also established an important TEST boundary. `camerashack.co.uk` is a Porkbun sandbox registration and cannot prove real public DNS or Cloudflare custom-domain routing. The TEST Cloudflare Worker `tradeflow-test` is deployed from `cloudflare-test` and serves TEST Supabase, but currently has no custom domain attached. After chatbot completion, the next domain phase is to choose the permanent Lauren Digital company domain and, if needed, one inexpensive genuine test domain to prove real DNS → Cloudflare → TEST Worker → TEST Supabase → published subscriber website. Production remains isolated until TEST is verified.


## 2026-10-02 — Subscriber AI architecture locked

The pre-launch AI work now has a defined commercial and security architecture. Gemma remains a separate personal Quote System research tool and is not connected to subscriber/customer chatbots or websites. TradeFlow will use a provider-neutral AI layer for the Subscriber Assistant, with read-only documentation knowledge and narrowly scoped tenant retrieval. Product Research will be a separate evidence workflow requiring subscriber approval before research affects buying calculations. The architecture will support an optional subscriber-owned AI/API connection so the subscriber can bear their own provider usage costs; a centrally funded TradeFlow AI option is optional and requires explicit usage controls. AI must never receive unrestricted Supabase access. Subscriber AI rules, privacy, usage and cost responsibilities are documented in the Human User Manual, Backend User Manual and AI Operating Manual. Implementation now proceeds with the secure assistant backend before UI and research features.


## 2026-10-02 — Subscriber Assistant verified milestone

The TEST Subscriber Assistant has passed browser verification for subscriber sign-in, tenant context and read-only approved knowledge retrieval with no external AI provider enabled. The current Cloudflare TEST branch is cloudflare-test. The next work is to verify the expanded knowledge set and implement Product Research as an evidence-and-approval workflow before introducing an external provider or customer-facing assistant.


## 2026-10-02 — Final launch direction

The TEST customer-facing Camera Shack URL experiment is now frozen. Do not continue adding TEST-only customer-domain aliases or tenant-ID URL work merely to imitate the eventual LIVE domain.

The remaining pre-launch AI work is the final customer-facing TradeFlow chatbot/assistant, alongside the existing subscriber Assistant boundary. Once that is complete, proceed to LIVE: configure the real TradeFlow/Lauren Digital production domain, create/register the first real subscriber, publish that subscriber website, and register real customer accounts against the LIVE subscriber. Final customer and subscriber acceptance testing will then be performed on the real LIVE domain.

Engineering rule remains unchanged: defects discovered in LIVE are reproduced/fixed in TEST and only the approved commit is promoted to LIVE. Do not make ad-hoc development changes directly in LIVE.


# CURRENT OVERRIDE — 2 OCTOBER 2026 — PRE-LAUNCH TO LIVE

The current environment is **TEST branch `cloudflare-test` / TEST Supabase `twfbmjwwqzxdxvclxbun`**. LIVE Supabase `gxsrajtqzdjvmceqcpgv` remains untouched.

### Completed/verified direction
- Domain registration TEST workflow completed in the Porkbun sandbox for `camerashack.co.uk`; this does not prove public DNS or Cloudflare routing.
- Subscriber Assistant Phase 1 exists and is tenant-scoped/read-only.
- Product Research approval workflow is implemented and uses existing `tenant_buying_research` evidence; AI must not silently change buying prices.
- Customer portal authentication is being moved to hostname-based tenant resolution; tenant UUIDs are internal, not customer-facing.
- Clean TEST customer routes exist in the Worker, including `/login`, `/basket`, and `/assistant`.
- Customer Assistant Phase 2 is implemented as a tenant/customer-scoped read-only gateway/UI boundary.

### Immediate release sequence
1. Complete the remaining TEST verification of the customer assistant.
2. Do not spend additional effort proving public DNS with the Porkbun sandbox domain.
3. Purchase/configure the genuine production domain.
4. Create the real LIVE subscriber.
5. Configure the subscriber's real custom website/domain.
6. Create LIVE customer account(s) for that subscriber.
7. Perform final acceptance in LIVE.
8. Fix any defects in TEST and promote them; do not patch LIVE directly.

### AI provider status
The TEST AI provider remains `none`. No external AI charges are generated by the gateway. The provider-neutral architecture remains in place for a future server-side TradeFlow-managed or subscriber-owned provider.


## 2026-10-03 — Master Catalogue Restoration

The TradeFlow Master Catalogue restoration was completed through the controlled TEST → Production path.

### Verified source state
- TEST Supabase contains the TradeFlow-owned master catalogue: 32 categories, 177 branches, 73 manufacturers, 3,845 master products and 108 product identifiers.
- 3,822 master products are currently active and customer-visible.
- The catalogue is system-owned data only. No TEST customers, subscribers, orders, inventory, returns or transactions were copied.

### Root causes found in Production
1. Production buying-catalogue.js contained an incomplete Supabase endpoint instead of the full LIVE API URL.
2. LIVE Supabase contained the catalogue schema and RPCs but the catalogue_master_* tables were empty.

### Controlled repair
A version-controlled master-catalogue data restoration was created from the verified TEST master catalogue using natural-key joins rather than tenant/test-record IDs. The restoration consists of 20261003210000_restore_master_catalogue_metadata.sql, 20261003210001 through 20261003210008 product snapshot migrations, and 20261003210009_restore_master_catalogue_identifiers.sql.

These migrations were applied successfully to TEST first, where the catalogue counts remained correct, and were then applied to LIVE.

The LIVE buying-catalogue.js endpoint was corrected to the full LIVE Supabase URL.

### Architectural rule confirmed
Master Catalogue → subscriber Buying Catalogue → Buying Request/Product identity → Valuation → Offer → Acquisition → Inventory → Selling/Retail category → Listing → Retail Order → Fulfilment → Return.

The Master Catalogue remains the controlled source for the initial product/category structure. When a subscriber activates a master product for Buying/Selling, TradeFlow creates the subscriber-facing category/branch/product structures; the same category structure can therefore carry the purchased product into Retail Selling without inventing a second unrelated category system.

### Verification state
Database restoration: Verified.
Frontend LIVE browser verification of Master Catalogue filters/product loading: pending user/browser confirmation.

Do not mark the browser step Verified Live until the LIVE Master Catalogue page successfully loads categories/manufacturers/products and a product can be selected without Failed to fetch.


## 2026-10-03 — LIVE Catalogue Authorisation Repair

The first LIVE Master Catalogue request reached Supabase but returned `400: Tenant user is not authorised to view catalogue`. Investigation traced this to missing platform authorization seed data in LIVE, not to the Master Catalogue data itself.

TEST contained 3 roles, 35 permissions and 91 role-permission mappings. LIVE had 0 roles, 0 permissions and 0 mappings. LIVE also had 0 plan_features; the active Enhanced subscription therefore had no recorded `module.buying` or `catalogue.pre_filled` entitlement even though the subscription itself existed.

The controlled repair `20261003213000_restore_platform_authorization_entitlements.sql` was created from verified TEST configuration using natural keys. It was applied to TEST first and verified at 3 roles / 35 permissions / 91 mappings, with 20 Enhanced plan features. It was then promoted and applied to LIVE.

LIVE verification now confirms the Adventure Outpost owner has the active `categories.view` permission and the Enhanced subscription has both `module.buying` and `catalogue.pre_filled` enabled.

No tenant memberships, customers, orders or transaction records were copied. Only platform role/permission/entitlement configuration was restored.

Next verification: refresh the LIVE Master Catalogue page and select a manufacturer. The expected result is that the catalogue request proceeds beyond the previous authorization error and the manufacturer/product results load.


## 2026-10-03 — Master Catalogue Duplicate Branch Sweep

A full sweep of the 32 Master Catalogue categories and 177 branches was performed in LIVE. Exact duplicate branch names and same-category near-duplicate branch names were reviewed rather than blindly merged. The clear semantic duplicate was `Drone Accessories → Drone Remote Controllers`, which contained one FIMI TX10A product, while `Drone Accessories → Drone Controllers` contained the other 39 controller products. The duplicate branch was consolidated into `Drone Controllers`, leaving 40 controller products in that branch.

Other same-category overlaps found (such as Continuous Lighting / Continuous Lighting Kit, COB Video Light / COB Video Light Kit, Tripods / Video Tripods, Camera Sliders / Camera Sliders & Dollies, Underwater Drones / Water Drones) were deliberately left separate because they represent distinct product scopes rather than true duplicates.

Cross-category repeated branch names such as Light Stands, Camera Supports, Tripod Heads and Flash Accessories were also left intact because their parent categories differ; they are not automatically safe to merge without changing taxonomy semantics.

The merge was applied to TEST first and verified, then promoted to LIVE via `20261003220000_merge_duplicate_drone_controller_branch.sql`.

# 2026-10-05 — STANDARD WEBSITE BUILDER LOCKED BASELINE

The current LIVE/production Website Builder is now the approved standard reusable website template and is locked as the design/reference point for future company/service websites and new subscribers.

## Lock rule
Do not redesign, reposition, resize, restructure, or replace the locked Website Builder arrangement unless the user explicitly reopens the baseline. Future work must build around this baseline rather than silently changing it.

## Locked scope
- Home page structure and page composition.
- Shared top/banner section and its current arrangement.
- Text-box, image-box and CTA/button positions and proportions.
- Homepage body layout and tiles.
- What We Buy and What We Sell sections.
- Buying Catalogue / Buying page structure.
- Retail Shop page and tile structure.
- About, Contact and Customer Account pages.
- Shared top-section editor and Top-of-page editor.
- Text, font, size, colour, line spacing, letter spacing, border and background controls.
- Current light editor toolbar treatment and orange-accented control borders.
- Subscriber-specific branding remains tenant-specific; the template does not hard-code a subscriber's identity.
- Edit → Save Draft → Preview → Publish → LIVE workflow remains authoritative.

## New-subscriber starter layout
`resetToFreshWebsite()` is the source of the standard fresh-subscriber arrangement. `template_reset_version: 2` protects established drafts from being reset on reload.

Approved starter elements:
- Left text box: x 6, y 7.131578947809846, width 47.093378607809846, height 32.868421052190154.
- Right image box: x 56, y 8.236842105263158, width 38, height 34.
- Lower text box: x 0, y 53.68421052631579, width 70.44991511035653, height 28.

Starter text boxes are blank by design. Do not restore placeholder copy such as “Your Text Here” or “Edit this text” into the fresh starter content.

## Reuse objective
This locked arrangement is the standard starting template that can later be transferred/reused for other company/service websites. Do not build a separate style-system-dependent replacement unless explicitly requested. Preserve the existing page/content-box architecture.

## Reference restore point
Immutable restore branch: `LOCKED-standard-website-builder-2026-10-05`.
Production code state captured before documentation-only updates: `f3ff7f9d34030dbcde3440e21c097726ddef4f1d`.

## Next stage
The next chat will decide the next development stage. Do not infer or start that stage automatically. First read this lock and the continuation prompt, inspect current production state, and wait for the user's next instruction.

## 2026-10-06 — Full LIVE website/code/documentation audit

The LIVE production repository and LIVE Supabase project were audited against the current working architecture. The 5 October Website Builder lock remains protected. The current subscriber-owned domain connection model is authoritative, and the obsolete automatic TradeFlow/Porkbun purchase path is retired.

Cleanup completed in the production repository:
- removed the retired domain purchase/search frontend;
- removed the retired registrant/registration frontend;
- removed source for the retired Porkbun registration, availability, dry-run, checkout, payment-reconciliation and registrant-save functions;
- removed retired Parcel2Go and ResellerClub function source;
- removed the unused shipping-provider test function source;
- removed unused duplicate Inventory/Selling/customer-auth repair runtimes that were no longer referenced by the active pages;
- added the deployed automatic Cloudflare custom-domain preparation function to version control at `supabase/functions/platform-prepare-custom-domain/index.ts`.

LIVE Supabase audit confirmed the current domain workflow objects remain in place: `tenant_domains`, `platform_owner_domain_actions`, `subscriber_request_custom_domain()`, `platform_owner_list_domain_actions()`, `platform_owner_update_domain_action()` and the automatic Cloudflare preparation Edge Function.

The old domain-pricing/order tables and historical domain-registration Edge Functions may still exist in LIVE Supabase for historical/schema compatibility. They are no longer part of the active subscriber Website URL workflow and their removal must be handled separately from the working website code, with dependency checks before any destructive database cleanup.

Supabase advisory findings were reviewed. Existing security/performance advisories are broader than this website cleanup and were not changed blindly as part of this audit.


## 2026-10-08 — Custom-domain LIVE acceptance milestone

### COMPLETE — first real subscriber-owned domain
The subscriber-owned custom-domain architecture has now completed its first full LIVE acceptance test.

**Subscriber:** Adventure Outpost  
**Hostname:** www.scenesource.co.uk  
**Result:** Active · Primary  
**LIVE platform:** https://tradeflow.laurendigital.co.uk

Verified sequence:
1. Review request
2. Prepare connection automatically
3. Give exact DNS instructions
4. Verify DNS
5. Verify SSL / HTTPS
6. Verify tenant routing
7. Activate domain

Cloudflare routing was corrected by adding the verified wildcard route */* for the laurendigital.co.uk zone to the existing tradeflow Worker. The previous customer-hostname 522 was thereby resolved. The verified test DNS record was www CNAME → customers.laurendigital.co.uk.

The final activation JavaScript defect (m is not defined) was fixed in production commit 25bbc9c86a5778e5911850c2ad64234696c221f4 and deployed in Cloudflare Production deployment 244d6f94.

### NEXT DOMAIN TEST
The next domain test is now a **reuse test**, not an infrastructure rebuild. Start with a new subscriber-owned domain request and prove that the existing architecture handles it without creating another Worker or another wildcard route. Verify each owner phase one at a time and record the result in a new dated checkpoint.

### Documentation lock
After every material domain change/test, update the AI Operating Manual, Backend/Owner Manual, Human/Subscriber Manual, System Handbook and this roadmap, and create a dated checkpoint. Do not mark a domain active manually and do not claim verification without evidence.


## 2026-10-09 — LIVE subscriber clean-URL routing repair

The first anonymous SceneSource routing repair exposed a second Cloudflare Static Assets interaction. The Worker correctly rewrites subscriber clean routes to `public-site.html`, but default HTML handling can redirect that internal asset request to `/public-site`. This made clean navigation appear to return to the homepage.

LIVE Supabase was audited and the SceneSource publication/domain records are present and publicly readable; no database repair was required. Production routing has been repaired with `html_handling: "none"` and Worker-first execution, with public-site JS trailing-slash normalisation and cache refresh.

Status: **source repair committed; browser acceptance pending.** The next acceptance test must prove the root URL and each enabled clean public page route without `/public-site` appearing in the browser address bar.

## 2026-10-09 — LIVE loading-screen parse failure repaired

The latest browser test remained at “Loading website…” on the correct subscriber root URL. Production public-site.js had an invalid regex literal in the trailing-slash normalisation code, preventing the entire public-site controller from parsing. Fixed in c1e4952d7588e071dc5ce132030afbd0cca97b89; script cache version advanced to public-site.js?v=26 in 19aedd3cb17626834c1674999950488c9025a802.

Status: source fix committed; browser acceptance still pending Cloudflare deployment. Verify root rendering and clean page navigation before declaring the domain/site acceptance complete.

## 2026-10-09 — Restore platform homepage routing

After `html_handling: "none"`, `tradeflow.laurendigital.co.uk/` returned 404 because the Worker had not explicitly mapped platform `/` to `/index.html`. Fixed in production Worker commit `adf0021c25a95fc39c46587dbde98a0af6ef654a`. Await deployment; test platform root and subscriber root separately before accepting the routing repair.

## 2026-10-09 — LIVE multi-account session-isolation test is next

The latest user screenshot shows the Adventure Outpost subscriber dashboard, the Platform Owner Dashboard and the SceneSource public subscriber website open at the same time in Google Chrome. The public website at https://www.scenesource.co.uk/ is now rendering the Action Outfit/Adventure Outpost content after the public-site loading/routing repairs. Do not infer that all clean routes or all session-isolation cases have passed merely because the homepage renders.

Next acceptance task: perform a read-only audit of LIVE customer/account records to establish whether a SceneSource website customer already exists. Distinguish website customers from subscriber owner accounts, business customers, test records and abandoned registrations. Do not create duplicate users or subscribers. Adventure Outpost is already present as the subscriber tenant and is currently signed in; do not create a second subscriber account or new Stripe checkout. If no suitable website customer exists, use the normal public Customer Login/registration flow to create one, with the user's approval and a clearly identifiable test email they control.

Then prove that the Platform Owner, Adventure Outpost subscriber, and SceneSource website customer can each remain signed in simultaneously in the same Chrome browser without one role replacing, impersonating or logging out another. Refresh/navigate each surface and test sign-out isolation. Preserve the established design: subscriber/business owners log into TradeFlow; the public website's Customer Login is for the subscriber's own customers. Do not add a business-owner login link to the public site.

Use the continuation prompt/checkpoint CHECKPOINTS/2026-10-09-live-multi-account-session-isolation-next-test.md. Work step by step; use LIVE evidence, read-only inspection first, do not expose credentials, do not weaken auth/RLS/tenant isolation, and do not change DNS/SSL/Cloudflare/domain state for an account-session test. Record pass/fail evidence before marking acceptance complete.