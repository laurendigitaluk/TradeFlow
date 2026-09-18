# TradeFlow Human / Developer System Handbook

**Status:** Living document  
**Version:** 4.3  
**Date:** 18 September 2026  
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

## 10. Subscriber category tenant-context and REST repairs — 17 September 2026
The category database/RLS path was verified independently: Test Business A contains active Buying/Selling `Drones`, and the authenticated owner query returns it. Front-end repairs addressed missing tenant context, unnecessary GET `Content-Type`, missing request timeout and late runtime diagnostics.

A shared `subscriber-tenant-context.js` preloader establishes test-lab tenant context before subscriber controllers. GET/HEAD requests are normalised so they do not carry unnecessary JSON `Content-Type`.

## 11. Dedicated subscriber authentication — 17 September 2026
The screenshot showing `Sign in through the TradeFlow test environment before opening Categories.` identified the deeper issue: the subscriber workspace was trying to use the **customer test-lab session/storage keys**. Platform Owner authentication is deliberately separate too, so opening Platform Administration does not authenticate a subscriber workspace.

A dedicated `subscriber-auth.js` now provides test-environment subscriber authentication. It uses separate storage keys (`tradeflow_subscriber_publishable_key` and `tradeflow_subscriber_session`), signs in by email/password, verifies an active membership in the selected Test Business A/B tenant, and sets the subscriber tenant context. Passwords are not stored.

`subscriber-auth-bridge.js` is a compatibility layer for the existing Category, Inventory and Selling controllers. On those subscriber pages only, reads of the legacy test-lab key names resolve to the dedicated subscriber session. This prevents the Customer Test Lab session from being overwritten. After a new subscriber login, the bridge reloads the page so legacy controllers start with the authenticated subscriber context.

`subscriber-auth-controls.js` binds the existing page sign-out control to the dedicated subscriber session.

Current pages wired to dedicated subscriber authentication:
- `categories.html`
- `inventory-dashboard.html`
- `selling-dashboard.html`

This is test-environment infrastructure. It is not the final production onboarding/authentication model.

## 12. Inventory
058 protects inventory status entry. The repaired Inventory runtime supports product creation, category-specific dynamic values, multiple photographs and workflow-controlled lifecycle changes.

Lifecycle: `received → inspection → testing → repair → ready_for_sale → listed → reserved → sold`, with supported return/write-off/archive branches.

## 13. Finance and payment
059 applies permission-bound access to payment/ledger tables. 060 extends `transition_workflow_entity()` to payment and ledger entities and adds status-entry guards. No automatic payment or ledger creation is inferred from acquisition status.

`record_retail_order_payment()` is the internal subscriber payment path. `customer_create_order_payment()` provides the customer-side idempotent pending-payment boundary.

External Stripe architecture is server-side: `create-stripe-checkout-session` requires a customer JWT; `stripe-payment-webhook` verifies `stripe-signature` and calls protected `process_external_payment_event()`. `payment_provider_events` provides provider/event idempotency. Stripe test configuration is complete, but persistent browser payment verification remains open.

## 14. Selling / Listings
061 hardens listings and related access. Selling creates listings from ready-for-sale inventory and uses workflow authority. New listings inherit inventory media.

## 15. Retail Orders
062 hardens retail order access/status entry. Subscriber Orders creates orders from published listings. Customer checkout creates a pending-payment order, reserves the listing and uses the Stripe boundary for payment.

## 16. Fulfilment
Fulfilment has subscription-aware access and controlled lifecycle progression: `awaiting → label → dispatched → delivered`, with returned branches. No carrier API or automatic fulfilment creation is assumed.

## 17. Returns
Legacy broad returns policies were removed and direct status edits are blocked. `customer_request_return()` validates customer ownership and eligible order states; customer visibility uses secure `customer_get_returns()`.

## 18. Customer dashboard browser repair — VERIFIED LIVE
Customer sign-in/controller timing and navigation interception faults were repaired. The controller `esc()` parse fault was corrected and cache-busted to `v11`. Customer Buying category loading was isolated from optional modules because Test Business A lacks `module.orders`; `customer-dashboard-nav.js` independently loads `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## 19. Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling shared a malformed `esc()` quote mapping, causing JavaScript parse failure before Supabase requests. Category was repaired in place; clean repaired Inventory and Selling runtimes were created. Inventory signed-URL requests also explicitly send JSON content type.

## 20. Diagnostic and verification standard
Trace every domain as: **User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Verification states: **Proposed → Implemented → Tested → Verified Live**. Commit success is not live verification. Transactional rollback testing proves database behaviour, not a persistent browser journey.

## 21. Manual testing and change control
One browser test at a time: exact URL → exact account → exact action → expected result → screenshot/result → PASS/FAIL → next test.

After each material change record what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Update this handbook, the Master Roadmap, the AI Operating Manual and structured project memory/checkpoint data where available.

## 22. Current stopping point — 17 September 2026
The category database/RLS path is verified. The browser failure was traced to subscriber pages using customer test-lab session storage instead of a subscriber session. Dedicated subscriber authentication plus a compatibility bridge is now deployed to Categories, Inventory and Selling. **Live browser verification of the new sign-in flow is open.**

**Next action:** hard refresh/open Categories. A Subscriber sign-in dialog should appear if no dedicated subscriber session exists. Sign in using an active Test Business A Owner/Admin/Staff account, select Test Business A, and verify `Drones` appears. Then use the same session to verify Inventory and Selling category selectors. Do not alter subscriptions, category data or RLS to work around this.


## Test Business C — Buy & Sell end-to-end test tenant — 18 September 2026

- Created dedicated test tenant Test Business C (50641519-2aa5-4093-95e5-7e92bea733a6) on the live TradeFlow test environment.
- Assigned the existing Test Business A Admin test identity as an Admin member; no Owner account is required for routine workflow testing.
- Assigned the buy_sell plan in trialing state so Inventory/Selling capability checks can be exercised without weakening RLS or changing Test Business A's Buying-only subscription.
- Seeded a Drones category with model_number (text) and condition (select) plus New/Excellent/Good/Fair/Poor options for end-to-end product testing.
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


## Subscription catalogue simplification — 18 September 2026

TradeFlow now has exactly two active customer-facing plans: **Basic** and **Enhanced**. Basic is the complete operational Buy & Sell core. Enhanced includes Basic plus every currently defined add-on capability (staff, staff messaging, audit, analytics, integrations and market intelligence). Legacy five-tier plan records remain inactive for historical traceability. The subscription capability layer remains unchanged as the enforcement boundary; code must continue to call the existing feature checks rather than hard-code plan names.


### Customer storefront and fulfilment checkpoint — 18 September 2026

The public website now includes a real customer-facing Shop section. It loads published subscriber site content and published listings through the controlled `public.get_published_store_listings(uuid)` SECURITY DEFINER function. The function is executable by `anon` and `authenticated` and exposes only storefront fields required for display. It requires a published website revision and filters listings to published status, active selling-enabled categories and active sales channels.

The public storefront remains separate from subscriber operational tables and does not expose customer, order, payment or internal workflow data. The existing paid Test Business C order has reserved the DJI test listing, so that item is intentionally not available in the public Shop.

The Fulfilment workspace has also been moved from the older test-lab session/key to the dedicated subscriber authentication layer. Test Business C has the fulfilment capability enabled and the current Admin test identity has `fulfilment.manage`. The next browser test is to create a fulfilment for `ORD-20260918-DB2A42EF` and then advance it one controlled transition at a time.

The current implementation is **Implemented Live** at the code/database boundary. Public storefront rendering, anonymous listing retrieval and fulfilment browser journeys remain **open for live browser verification**.


### Corrected TradeFlow product hierarchy — 18 September 2026

The top-level TradeFlow customer journey is the SaaS product journey, not a subscriber's public storefront. The intended hierarchy is:

**TradeFlow website → plan selection/subscriber signup → subscriber business account → Buy & Sell workspace → subscriber Website Builder → subscriber's separate customer-facing website.**

`index.html` is now the TradeFlow SaaS homepage. The former Customer Test Lab has been preserved at `test-lab.html` and is no longer the root product entry point. The tenant public renderer (`public-site.html`) remains a downstream customer-facing website for an individual subscriber and must not be treated as the TradeFlow SaaS homepage.

The SaaS homepage presents the two active plans, Basic and Enhanced, and routes into `subscriber-signup.html`. Subscriber onboarding uses Supabase Auth followed by the authenticated `subscriber_create_business()` RPC. That RPC creates the tenant, owner membership and trialing subscription for the selected active plan. Anonymous execution is explicitly revoked.

The live subscription records currently do not contain Stripe provider price IDs for the SaaS plans. Therefore recurring paid SaaS billing is not yet marked complete. The next billing build must add the production Stripe subscription boundary rather than pretending the existing retail checkout is the SaaS subscription checkout.

Subscriber authentication is now membership-driven: it obtains active tenant memberships from `subscriber_get_my_memberships()` rather than relying on a hard-coded list of Test Business A/B/C. This is necessary for newly onboarded subscribers and preserves the tenant boundary.


## 23. Stage 1 SaaS product layer — 18 September 2026

The first product layer is the TradeFlow SaaS itself. The public TradeFlow homepage markets the subscription and routes businesses into subscriber onboarding. It must not be confused with a subscriber's separate customer-facing website.

The platform hierarchy is:

TradeFlow SaaS homepage → subscriber plan/signup → subscriber private business dashboard → subscriber Website Builder → subscriber's own customer-facing website → that subscriber's customers.

The Platform Owner dashboard is a separate platform-level administration boundary. platform-owner-dashboard.html uses its own platform-owner session storage and verifies the signed-in Auth user against public.platform_memberships. Tenant membership is not treated as Platform Owner access.

The first owner dashboard implementation is intentionally platform-level: it reads subscriber tenant/subscription summaries through the existing platform_admin_list_tenants() privileged RPC. It does not replace or bypass tenant RLS and it does not expose subscriber customer/order records as a platform-wide browser dataset.

Verification state: Stage 1 owner dashboard is Implemented in GitHub. Live browser verification remains open.


## 24. Owner Dashboard Stage 1A — subscriber registration details — 18 September 2026

The Owner Dashboard first handles the SaaS intake boundary: businesses subscribe/sign up through the TradeFlow homepage and their business/owner registration details become visible to the Platform Owner. This is distinct from later subscription billing administration and from the subscriber's own customers.

`platform-owner-dashboard.html` and `platform-owner-dashboard.js` now use `public.platform_admin_list_subscriber_accounts()` for a platform-owner-only subscriber account table showing business, owner, email, slug, status and joined date. The RPC uses `private.require_platform_owner()` and anonymous execution is revoked. Tenant RLS is not bypassed.

**Verification:** Implemented in GitHub and live Supabase. Browser verification remains open.


## 25. Owner Dashboard subscriber directory boundary — 18 September 2026

The Owner Dashboard's Subscriber Businesses directory represents TradeFlow SaaS subscribers, not subscriber customers. Development/security test tenants are explicitly marked with `tenants.settings.test_lab=true` and are excluded from the commercial directory.

The directory exposes business registration details and a controlled **View website** link. It does not expose raw tenant customer, order, payment or operational records. Subscriber Website Builder remains a subscriber-side capability.

Categories and Website Builder are currently part of the Basic operational core under the live two-plan catalogue; they are not being invented as separate owner-side offers. Subscription billing and entitlement administration remain the next dedicated stage.

The subscriber-directory SECURITY DEFINER wrapper is restricted to authenticated callers and uses a schema-qualified empty `search_path`, consistent with Supabase's guidance for protected SECURITY DEFINER functions. citeturn0search1turn0search2


## Subscription model — Stage 1C

TradeFlow now has three active customer-facing subscription plans.

**Basic**
- Core Buy & Sell operational workspace.
- Subscriber-configured categories and subcategories.
- Website template and colour selection, logo upload and image content.
- Customer-facing website, customer portal, buying, inventory, selling, orders and fulfilment.

**Enhanced**
- Everything in Basic.
- Staff management and staff messaging.
- Audit, analytics, integrations and market intelligence.

**Catalogue**
- Everything in Enhanced.
- A TradeFlow-provided starting catalogue of categories, subcategories and products.
- The exact commercial quantity limits for the supplied catalogue are not yet set.

The plan capability model remains the authoritative subscription boundary. TradeFlow uses one application and changes tenant capability through plan entitlements; it does not maintain separate Basic/Enhanced/Catalogue applications.

### Platform Owner subscription controls

The Platform Owner layer now has a controlled subscription management RPC. It requires Platform Owner access.

Supported actions:
- upgrade: target plan must be active and have a higher plan sort order than the current plan.
- close: latest subscription is cancelled and the tenant is archived. Business data is retained; account closure is not data deletion.

The Owner Dashboard uses these controls without exposing tenant customer records.

### Billing boundary

The Owner Dashboard subscription controls currently update the internal TradeFlow subscription record. Production Stripe recurring billing, provider price IDs, webhook-driven subscription state changes and automatic non-payment enforcement remain separate work and must not be represented as complete until implemented and tested.

### Catalogue seeding boundary

The Catalogue plan currently records the catalogue.pre_filled entitlement. The actual mechanism that copies a controlled set of TradeFlow catalogue data into a new tenant has not yet been implemented. The number of categories, subcategories and products to seed remains a commercial configuration decision.


## Public TradeFlow marketing layer — 18 September 2026

The TradeFlow SaaS public layer is separate from subscriber workspaces and subscriber customer storefronts.

Current public front-end structure:
- `index.html` — TradeFlow SaaS marketing homepage.
- `facts.html` — platform facts/about page.
- `examples.html` — illustrative website examples.
- `terms.html` — Terms & Conditions draft page.
- `privacy.html` — Privacy Policy draft page.
- `subscriber-signup.html` — subscriber account onboarding.
- `subscriber-dashboard.html` — private subscriber workspace after authentication.

The public visual system uses `tradeflow-logo.svg` and the shared `platform.css` navy/orange branding. Example website visuals are illustrative until authorised real screenshots are supplied.

Public signup deliberately does not collect the subscriber's eventual customer-facing website slug. The existing backend onboarding RPC still receives an internally generated slug derived from the business name; the public website address is a later subscriber workspace configuration concern.

Legal pages currently contain structured draft copy and must not be treated as final legal advice or final production contractual wording until the correct legal entity, commercial terms, privacy details and final review have been completed.


## Public homepage hero presentation — 18 September 2026

The public TradeFlow SaaS homepage uses the GearCashOut website as a reference presentation inside the hero visual. The laptop frame is intentionally sized to a conventional computer display proportion rather than an ultra-wide panel, with a separate phone frame retained to demonstrate responsive customer websites.

This is illustrative marketing content only. It does not make GearCashOut a TradeFlow customer and does not alter the GearCashOut system.

**Current state:** Implemented in GitHub; visual browser verification remains required.


## Homepage hero visual hierarchy — 18 September 2026

The homepage hero visual is intentionally generic and TradeFlow-led. A neutral “Your Business” customer website is shown inside a browser frame, with a smaller mobile version demonstrating responsive presentation. Named reference businesses are kept out of the primary hero so they cannot visually compete with the TradeFlow brand.

The hero contains no floating white explanatory labels. Customer examples remain in the dedicated Examples section.

**Current state:** Implemented in GitHub; visual browser verification remains required.


## 24. Subscriber business application shell — 18 September 2026

Stage 1 of the subscriber product interface has now been implemented on the subscriber-shell-stage1 branch. This is a presentation/application shell over the existing TradeFlow backend and operational workspaces; it does not replace their controllers, RPCs, tables, RLS policies, workflow authority or subscription enforcement.

The subscriber dashboard entry point subscriber-dashboard.html now provides a structured business workspace with grouped navigation for Buy & Sell, Customers, Website and Business areas. Existing links to Buying, Acquisitions, Inventory, Selling, Orders, Fulfilment, Returns, Finance, Categories & Properties and Website Builder are preserved.

The dashboard now loads the dedicated subscriber-auth.js layer before subscriber-tenant-context.js and binds the existing Sign out control to tradeflowSubscriberSignOut. This corrects the dashboard entry-point loading order without changing the underlying authentication or tenant-selection architecture.

subscriber-dashboard.css was extended as the shared subscriber application stylesheet. Existing dashboard/workspace classes remain supported so the change acts as a visual shell rather than a rewrite of the operational pages.

Catalogue remains an active plan in the database, but it is deliberately not exposed as an operational subscriber option yet. Catalogue rollout is held open until Gemma is capable of maintaining/updating the TradeFlow product catalogue. Do not seed Catalogue data or remove the plan from the database in the meantime. The current plan/feature entitlement architecture remains authoritative.

Current state: Implemented on staging branch; not yet Verified Live. Before merging to main, browser-test the subscriber sign-in, tenant selection, dashboard navigation and representative existing workspaces. Do not alter backend security or workflow code merely to make the shell work.

Next safe action: verify the shell against Test Business C using the existing Admin test identity, then continue by integrating the common shell/navigation with the existing operational pages one meaningful area at a time.

## Subscriber reset and account-boundary checkpoint — 18 September 2026

The legacy subscriber test environment has been closed before the next onboarding test. All tenants marked `settings.test_lab=true` were archived and their subscriptions cancelled; their memberships were removed from active status. The Platform Owner Auth account `leannelaurenlowe@hotmail.com` was deliberately retained and was not deleted.

The separate orphaned test Auth users `tradeflow1@yahoo.com` and `info@gearcashout.co.uk` were deleted. No subscriber customer account was created by this cleanup.

Security boundary decision: Platform Owner is not a tenant role and does not receive automatic membership in subscriber businesses. Platform-level access must remain separate from tenant customer data. Any future subscriber-approved maintenance/support access will be an explicit, auditable capability and is not being added as a hidden backdoor.

The subscriber dashboard now displays the active business, signed-in email and tenant role, with an Account dialog showing the active tenant ID. Catalogue remains deliberately absent from the operational subscriber navigation until Gemma can maintain/update the product catalogue.

The Website Builder now offers six distinct starting layouts: Business, Buy & Sell, Services, Editorial, Minimal and Retail. The selected template is persisted in the existing website revision content and the public renderer applies the corresponding layout variant. No new tenant/RLS architecture was introduced.

**Verification state:** cleanup is database-verified; dashboard/template changes are Implemented on `subscriber-shell-stage1` and require browser verification before merge to `main`.

## Subscriber dashboard workflow separation — 18 September 2026

The subscriber business dashboard has been refocused as the day-to-day operational workspace. Its primary flow is Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns, with Finance and Customers as supporting business areas. Website building is no longer presented as part of that operational flow.

A separate `subscriber-website.html` website management area is now the entry point for website work. It links to the existing Website Builder and customer-facing preview. The intended UX is that a subscriber builds/publishes the website, then returns to the Business Dashboard for normal operations and only revisits the Website area when maintenance or content changes are needed.

Subscriber authentication was strengthened so protected subscriber pages are hidden until the dedicated subscriber session and active tenant membership have been verified. Unauthenticated visitors receive the subscriber sign-in overlay rather than seeing usable dashboard content.

**Verification state:** Implemented on staging; browser verification remains open before merge to main.

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


## Website Builder usability correction — 18 September 2026

The Website Builder has been revised after browser inspection showed that the template choices were not reliably usable and the editable page controls were not sufficiently discoverable.

- Template choices now use explicit buttons with delegated click handling, selected-state feedback and a clear “Use this design” instruction.
- A four-step builder index provides direct links to Template, Business Details, Website Pages and Preview/Publish.
- The Website Pages section now has a visible page index with an **Edit page** link for every page, so the subscriber does not need to discover the editors by scrolling.
- The editable page library now includes About us, Business Information, Contact, Terms & Conditions, Privacy Policy, Cookie Policy, Delivery & Returns, Sell to us, How it works, FAQ, Payments, Warranty & Guarantees and Complaints, plus the built-in Shop and Customer account pages.
- Recommended pages are enabled by default; optional pages remain available to edit but can be kept out of navigation.
- Each editable page has a clear explanation of what belongs there, editable title/body fields and optional SEO title/description fields.
- The live builder preview now exposes the enabled website pages in its navigation so the subscriber can see the page structure while building.
- The category explanation now explicitly distinguishes the database behaviour: Buying and Selling use the same category record with capability flags; TradeFlow does not create a duplicate selling category.
- Existing `category_manifest` content is preserved when the draft is saved rather than being overwritten with an empty array.

The category-management and inventory dashboard controllers were also corrected to use the authenticated subscriber tenant supplied by `subscriber-tenant-context.js`, rather than a hardcoded test-tenant allow-list. This is necessary for the normal new-subscriber flow to reach Categories and Inventory safely.

**State:** Implemented on main; browser verification remains required for template clicks, page jump links, category access and the new-subscriber Inventory path.


## Website Builder branded media, selling-page editing and domain entry — 18 September 2026

The Website Builder has been extended so subscribers can establish a visual brand rather than only editing text.

- Subscribers can upload a homepage image and images for editable website pages.
- Page image uploads are stored in the tenant-scoped tradeflow-site-media public asset bucket. Upload/delete/update operations are protected by authenticated tenant website-management policies; public read is intentional because these are published customer-facing website assets. Supabase documents that public buckets make objects publicly retrievable while upload/delete operations remain policy-controlled. citeturn0search0turn0search1
- Site image metadata is also recorded in the existing tenant-scoped media_assets table.
- The Buying / Sell to us page and the Retail Shop page can now carry their own text and branded image. The Retail Shop remains system-driven for live product data; the subscriber controls its introduction, title and presentation while products continue to come from Inventory/Selling.
- Template CSS was expanded so the ten starting designs have more distinct navigation, hero, card, spacing and background treatments.
- The subscriber Business Dashboard now contains a Website URL entry point. domain-settings.html stores a subscriber domain in the existing tenant_domains model as pending and displays its connection state.
- Existing publish_site_revision() already refreshes published_site_index for domains whose status is active, so the final hostname-to-tenant routing is preserved. The external DNS/hosting target and ownership verification mechanism are intentionally not invented yet; a multi-subscriber hosting layer must be selected before a domain can be automatically activated.
- publish_site_revision() was corrected to accept website content schema versions 1 and 2. The current builder uses schema version 2.

**State:** Implemented on main; browser verification required for image upload, page editing, template variety, domain entry and publishing.


## Stage 1N — Visual on-page Website Builder — 18 September 2026

The subscriber Website Builder has been reworked from a form-heavy editor into a visual, page-first editing experience. The subscriber now selects a website page from the left-hand page list and sees the complete page in the main browser-style canvas. Editable text is changed directly in place using click-to-edit contenteditable areas rather than separate title/body fields.

Implemented in the visual builder:
- Home page editing directly on the page: business name, homepage headline and introduction.
- Buying / Sell to us page editing directly on the page, including its own title, body and image.
- Retail Shop page editing directly on the page, including its own title, introduction/body and image.
- Other content pages use the same direct page editing pattern.
- Customer Account remains explicitly TradeFlow-managed because it is connected to the customer portal rather than being a normal content page.
- Image add/replace/remove controls appear on the page itself. Uploads remain tenant-scoped through the existing tradeflow-site-media bucket and media_assets metadata flow.
- Subscriber logo upload is now wired to site branding and the public website renderer can display it.
- Template selection now uses visual miniature previews rather than text-only template buttons. The ten existing templates remain starting designs; switching a design does not intentionally replace subscriber-entered page content.
- The sidebar is now for page navigation, design selection, connected operational links and save/publish actions. It is no longer the primary place where page copy is entered.

The visual editor continues to save the existing schema_version 2 website content through the existing tenant_site_state/site_revisions and publish_site_revision path. Product listings remain system-driven from Inventory → Selling; the visual editor does not create or duplicate product records.

**Status:** Implemented on main; browser verification is required for direct text editing, page switching, image upload, logo upload, draft save, publish and public-site rendering.

## Stage 1O — Premium two-sided homepage — 18 September 2026

The public subscriber homepage now uses a premium marketplace structure rather than the previous basic hero-plus-cards layout. The homepage is designed around the two distinct customer intents: people who want to sell items to the business and people who want to browse/buy from the business. The structure uses a strong hero, explicit buying/selling routes, visual buying-category tiles, retail showcase tiles and a trust/process strip. This follows established two-sided marketplace design patterns without changing the underlying TradeFlow transaction architecture.

Subscriber-editable homepage controls now include:
- Homepage headline and introduction directly on the visual canvas.
- Main homepage image directly on the canvas.
- Separate editable `What we buy` and `What we sell` headings/intros.
- 6, 8 or 10 visual homepage tiles.
- Separate buying and selling tile groups, balanced across the selected tile count.
- Each tile has directly editable title/body and its own image add/replace/remove control.
- Buying tiles route to the existing Sell to us / Buying page.
- Selling tiles route to the existing Retail Shop; actual retail product records remain controlled by Inventory → Selling.

The `premium` / Premium Marketplace template is now available as an additional starting design. Existing template architecture remains intact.

**Status:** Implemented on main; browser verification is still required.