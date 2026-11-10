# TradeFlow Human / Developer System Handbook


> **CURRENT SHIPPING ARCHITECTURE — 25 September 2026**
>
> The current TradeFlow shipping architecture is **subscriber-managed shipping services with manual handoff**. The former Parcel2Go API/connected-provider route is **retired and must not be used or reintroduced from the older sections of this document**.
>
> **Current flow:** Subscriber opens **Settings → Shipping Settings**, selects the shipping services they use from the TradeFlow service catalogue, and saves them. Those services appear in the Buying shipping handoff. The subscriber uses the chosen provider's official website/service outside TradeFlow and pays the shipping provider directly. The subscriber then returns to TradeFlow and uploads the shipping label and, where applicable, QR code, plus carrier/service, tracking number and customer instructions. TradeFlow stores the handoff against the existing acquisition/buying item and sends the shipping information to the customer. The customer can open/print the label or QR code and confirms when the item has been sent. The subscriber then confirms receipt and proceeds to **Inspection**.
>
> TradeFlow **does not create Parcel2Go quotes, book Parcel2Go shipments, process shipping payments, or require Parcel2Go API credentials** in this current flow. Do not add direct courier credentials or an automated shipping-payment path unless the architecture is deliberately changed, tested and checkpointed.
>
> **Documentation rule:** Sections below dated before this architecture change may describe earlier experiments or implementation history. They are retained for audit continuity, but they are **historical records, not current operating instructions**. Current code, current Supabase state and this section take precedence.

**Status:** Living document  
**Version:** 4.7  
**Date:** 4 November 2026  
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

## 20. Subscriber Website Builder entitlement repair — 18 September 2026

The new subscriber account subscriber test 1 could authenticate and had a tenant, membership and Website Builder draft, but the Builder reported **Website could not be loaded**. The live root cause was the subscription capability gate: the onboarding RPC created a trialing subscription with trial_end = null, while private.has_tenant_feature() requires a non-null future trial_end for trialing subscriptions.

Migration 065_repair_subscriber_trial_entitlement_window.sql updates subscriber_create_business() to establish the existing 30-day trial pattern (trial_end and current_period_end) and backfills any current trialing subscription that has no trial end.

Live verification with the subscriber owner identity and tenant f3435be3-242e-4086-ad81-c4c6e8045aea confirms is_tenant_member=true, website.editor=true and website.publish=true. No RLS policy or tenant boundary was weakened.

**Status:** Implemented Live and database entitlement path verified. Browser reload of the Website Builder remains the final UI verification step.


## 21. Subscriber website branding and business extras — 18 September 2026

The Website Builder now includes subscriber-controlled brand colours for accent, text, page background, header/navigation, buying section, selling section and footer. These values are stored inside the existing website content JSON under site.theme and do not alter the application shell or tenant security model.

The Builder also stores subscriber social profile links (Facebook, Instagram, LinkedIn, YouTube, TikTok and X), an optional website share-button setting, and up to four review-site links. The published customer-facing website renders valid subscriber-supplied external links and provides native sharing where the browser supports it, with Facebook and LinkedIn sharing fallbacks.

These are presentation/business-profile settings only. TradeFlow does not create or verify third-party social or review accounts. Subscriber-entered URLs are restricted at render time to HTTP/HTTPS links.

**Status:** Implemented in GitHub; browser verification remains open for colour preview, Save Draft, Publish and public rendering.


## Restore checkpoint — 18 September 2026

This document is part of the locked TradeFlow stopping point for 18 September 2026. GitHub restore branch: checkpoint-tradeflow-20260918-premium-builder-final. Current main checkpoint commit: 0acc8d7ecca0de368172bf4fec1d746f11279dbd. Live Supabase includes migration repair_subscriber_trial_entitlement_window. Continue tomorrow from this checkpoint; do not modify GearCashOut.


## Domain purchasing foundation — 19 September 2026

The existing `tenant_domains` table already provides the tenant-scoped custom-domain connection/routing layer. This change extends that model so TradeFlow can later offer Shopify-style domain purchasing without replacing the existing website publication architecture.

Database foundation added live:
- `domain_tld_catalog` — platform TLD catalogue, registration/renewal/transfer pricing fields, currency, registration-term limits and provider-neutral product metadata.
- `tenant_domain_orders` — tenant-scoped registration, renewal and transfer order ledger with retail amount, registrar cost, payment references, provider references, lifecycle status, expiry and auto-renew state.
- `tenant_domains.acquisition_source` — `connected`, `purchased` or `transferred`.
- `tenant_domains.registrar_provider`, `registrar_domain_id`, `registered_at`, `expires_at`, `auto_renew` and `provider_metadata`.

Security:
- Both new tables have RLS enabled.
- TLD catalogue is read-only to public/authenticated clients and only active rows are exposed.
- Domain orders are tenant-isolated and writable only through existing tenant website-management/editor permission boundaries.
- Registrar credentials/secrets are not stored in the database.

The TLD catalogue is a pricing/configuration foundation, not an availability cache. Real-time availability and final pricing must come from the selected registrar/provider immediately before purchase.

Current domain UI remains a **connection** screen only: `domain-settings.html` saves a pending custom domain. The purchase UI, payment flow, registrar API integration, automatic DNS/hosting activation and renewal automation are separate implementation work.

Current commercial plan pricing/entitlement for domain purchasing is intentionally not decided and must not be invented.

**Status:** Database foundation implemented and schema-verified. Full purchase journey remains Proposed/Planned.



## Website Builder final refinement pass — 19 September 2026

The subscriber Website Builder has now received the agreed refinement pass before final browser review. Added: controlled typography options (font style, hero/section/body/navigation size levels), button styles, header styles, footer styles, optional homepage section visibility, optional second images for the homepage hero and content pages, and cleaner image controls with Add/Replace/Remove behavior. Homepage tiles remain unnumbered and directly editable.

Public rendering now consumes the saved typography, section visibility and multi-image settings. Asset cache versions are refreshed and both Builder and public runtime syntax have been checked. This is **Implemented in GitHub, not yet browser-verified**. Final verification should cover Builder preview, Save Draft, Publish, public site, responsive layout and the new controls.


## Draft preview and can_tenant permission repair — 19 September 2026

Browser verification exposed two separate issues. First, authenticated Website Builder operations were failing with `permission denied for function can_tenant`. The live database had the required RLS policies calling `private.can_tenant(uuid,text,text)`, but EXECUTE was only granted to postgres. Live migration `fix_authenticated_can_tenant_execute` restored EXECUTE to the authenticated role without changing the SECURITY DEFINER function or weakening tenant/feature checks. The migration is recorded in `supabase/migrations/066_fix_authenticated_can_tenant_execute.sql`.

Second, the Builder's previous `Open public website` link attempted to load the published-site path. A newly created subscriber may have a draft but no published revision, so that path correctly reports that no published website exists. The Builder link has therefore been renamed **Preview website** and now opens an authenticated draft-preview mode. The preview reads the signed-in subscriber's draft through existing RLS-protected `tenant_site_state` and `site_revisions` access; it does not expose drafts anonymously. The public site remains the published-site path and will work after the subscriber publishes a revision.

Validation: Builder and public-site JavaScript syntax checked OK; live EXECUTE grant confirmed for authenticated. Browser end-to-end preview verification remains the next user check.


## 19 September 2026 — Shared Buying & Selling category tree

The subscriber Categories & Properties workspace has been rebuilt around a shared hierarchy: **Category → Branch → Product Properties**. Categories and branches have independent Buying and Selling live controls. Individual properties now also have independent Buying/Selling visibility controls, separate from whether a live property is required.

Database migration 067_category_branch_buy_sell_tree added public.category_branches and branch references on category_fields, buying_items, inventory_assets and listings. Existing category/property/workflow records were backfilled to a default branch. Migration 068_enforce_category_branch_consistency ensures a branch belongs to the same category and supplies the category's active branch when an older workflow insert does not specify one.

The inventory workspace now selects a category branch and loads the branch's dynamic properties. Selling listings inherit category and branch from the selected inventory asset rather than allowing an independent sales category that could diverge from the acquired product. This establishes the shared category identity across Buying → Acquisition → Inventory → Selling; the customer-facing Buying submission UI still needs to be updated to present the same branch tree before this workstream is complete.

Validation: live migrations applied successfully; existing category data was preserved and assigned to default branches. Browser verification of the new Categories, Inventory and Selling screens remains required.


## 19 September 2026 — Subscriber navigation and Website Builder loading state

The Business Dashboard navigation now includes **Categories & Products**, linking to the shared Category → Branch → Product Properties workspace. The separate Website area also exposes the same link so category configuration is reachable without leaving the subscriber shell.

The Website Builder's top status was remaining on its initial `Loading website…` label, which did not clearly distinguish an active load from a failed/stalled draft load. The builder now reports `Connecting to your website…`, `Loading website draft…`, `Website loaded`, or `Website could not be loaded`, with explicit 15-second authentication and 20-second draft-load timeouts. The Builder script cache version was raised to v15.


## 19 September 2026 — Subscriber navigation and business settings

Buying workspace navigation was corrected so Selling, Finance & Payments, Inventory, Categories & Products, Website URL and Settings link to their actual subscriber pages rather than dashboard anchors. Selling and Finance navigation were also corrected to use the real Settings/Selling/Inventory pages.

A dedicated `settings.html` / `settings.js` subscriber settings workspace was added. It links to the existing Website URL/domain management page and provides tenant-scoped accepted payment-method settings. New table `public.tenant_payment_methods` stores enabled methods and customer instructions; RLS permits tenant members to read and tenant admins to manage them. This is accepted-payment configuration only; it does not claim that an online payment provider such as Stripe is connected. Provider connection remains a separate integration boundary.


## 19 September 2026 — Draft preview navigation repair

Draft Website Builder preview was loading the subscriber's draft correctly on the home page, but the generated internal navigation links did not preserve `preview=draft`. Clicking Home/About/Contact/etc. therefore left authenticated draft-preview mode and attempted to load the unpublished public site, producing `Website unavailable` when no published revision existed.

`public-site.js` now preserves `preview=draft` in `pageUrl()` whenever the current page is a draft preview. `public-site.html` cache-bust was raised to v9. This keeps all internal website-page navigation inside the authenticated draft preview until the subscriber publishes the site.


## 19 September 2026 — Homepage image independence and header branding

Homepage hero images are explicitly independent: `homepage.image_url` is the main image and `homepage.image_url2` is the optional second image. The builder now labels these controls accordingly and does not reuse the first image automatically. Homepage tile images remain independently stored per tile. Uploaded images are displayed with contain behaviour so the complete photograph remains visible.

Header branding was refined so an uploaded logo is shown instead of also displaying the editable business-name text beside it. Logo dimensions now preserve the complete image proportion and allow a larger natural width/height within the responsive header. If no logo is uploaded, the business name remains editable text.


## 19 September 2026 — Draft preview no longer blocked by shop listings

The subscriber draft preview could remain on the initial `Loading website…` screen because `loadDraftPreview()` waited for the retail product-listings RPC before completing the page load. The website content itself was already available, but a slow/stalled listings request could prevent the preview from rendering.

The preview now applies the draft content first and treats shop listings as a separate, non-blocking step with an 8-second timeout. If listings do not load, the rest of the website remains available and the shop area reports that products are temporarily unavailable. Public-site cache-bust is now v11.


## 19 September 2026 — Public website startup syntax error repaired

The public subscriber website reported 'Uncaught SyntaxError: Identifier \'brandText\' has already been declared' during startup. The error was caused by two const brandText declarations in public-site.js within applyContent(). The duplicate declaration was removed so the existing branding logic uses the single brandText reference. This was a JavaScript startup error, so the browser could not execute the public-site loader at all and remained on the static loading screen.

Fix commit: 26e698c5fdac77a0618a402ecd2b26da5a3582ba.


## 19 September 2026 — Homepage hero image editing made explicit

The premium homepage already stored two independent hero image fields (`homepage.image_url` and `homepage.image_url2`) and the visual editor rendered both. The builder UI was made more explicit so subscribers now have a dedicated Homepage hero photos control showing separate Main hero image and Second hero image actions, in addition to the direct Replace/Add controls on the page preview. Builder asset cache-busting was advanced to v17.

The two hero images remain independent and are not reused automatically by the builder or public website.


## 19 September 2026 — Hero image duplication clarification

The premium homepage renderer intentionally supports separate hero images and homepage tile images. Investigation of the subscriber test draft showed the same lens photograph was stored independently in the hero image field and in the `buy-2` homepage tile, so the public site correctly rendered the photograph twice. This was a content/configuration duplication, not an image rendering bug.

The homepage builder now exposes a `Hero image` visibility control separately from the `Hero section`. The current subscriber test draft has hero-image display disabled, leaving the lens photograph in its intended buying tile. Tile images remain independent from hero images. The public renderer now respects `homepage.sections.hero_image`.


## 19 September 2026 — Template family split into structural layouts

The ten website templates are now intentionally divided into two families. The first five remain the existing layouts: Business, Premium Marketplace, Buy & Sell, Services and Editorial. The second five now use structural layout differences rather than primarily colour/font differences: Retail Sidebar (left navigation), Professional Sidebar (right utility navigation), Bold Rail (dark left navigation rail), Classic Masthead (centred masthead with separate navigation band), and Local Business (compact grouped navigation). The 6/8/10 homepage tile control remains independent of template selection.

Builder CSS cache was advanced to v18 and public-site CSS to v9. Responsive rules collapse the sidebar layouts back to a mobile navigation arrangement on narrow screens.


## 19 September 2026 — Buying catalogue and research foundation

The existing Categories & Properties screen was too abstract for the actual Buying workflow. A separate subscriber workspace, `buying-catalogue.html` / `buying-catalogue.js`, now provides a clearer path: **Category → Buying Branch → Products We Buy → Research & Pricing**. This keeps the shared category/branch structure but gives each buying branch a practical product list.

New tenant-scoped tables:
- `tenant_buying_products`: exact manufacturer/model/package records that a subscriber buys, with active status, automatic percentage of researched UK New price, optional manual offer price, and pricing notes.- `tenant_buying_research`: product-level research evidence with UK New, UK Used/Other and Overseas evidence types, source, URL, observed price, currency, condition, availability, notes and checked timestamp.

Pricing rule is deliberately simple at this stage: **automatic percentage populated = automatic valuation basis; percentage blank = manual offer required**. Automatic percentage and manual price cannot be entered together. Existing GearCashOut remains reference-only.

The protected quote bridge adds `buying_items.buying_product_id` and `calculate_buying_item_valuation(tenant_id,buying_item_id)`. It calculates an automatic amount from the latest qualifying GBP UK New evidence and the configured percentage, otherwise returns a manual-review reason. It does not publish an offer or bypass the existing valuation approval workflow.

Live verification: the new tables currently contain 0 products and 0 research records; the current subscriber test tenant has 4 existing categories and 4 branches. Existing category data was not deleted or rewritten.


## 19 September 2026 — Buying reference price clarification and Website Builder repair

The Buying workspace has been simplified further around a branch-level rule. category_branches.default_buying_percentage now stores an optional default percentage for the branch. A subscriber can open a branch such as Cameras and set, for example, 60% of the researched UK New reference price. Products can still carry an explicit percentage override; if neither branch nor product has a percentage, the valuation remains manual. The reference price is the latest qualifying GBP UK New research record for the selected buying product.

The protected calculate_buying_item_valuation() RPC now resolves the percentage as product override first, otherwise branch default, and uses the latest qualifying UK New evidence as the reference price. It does not bypass existing valuation/offer controls.

Website Builder issue diagnosed and repaired: website-builder.js contained a JavaScript syntax error in the premium homepage hero expression. This prevented the builder script from executing, which is why the page could remain at Loading website with a blank editor. The hero expression was rewritten and verified with a JavaScript parser (new Function) as syntactically valid. website-builder.html now cache-busts the script to v19 and includes startup error diagnostics so future script failures are visible instead of leaving a blank editor.


## 19 September 2026 — Buying condition price matrix

The subscriber What We Buy experience has been redesigned as a full-width buying price matrix rather than a narrow product editor. The workflow is Category → Branch → Manufacturer/Model list. Each product row shows the latest qualifying UK New reference price and UK Used reference price as read-only research outputs, with source/date links where available. The subscriber enters six condition percentages in the same row: New Sealed, Never Used, Opened (based on UK New reference), Excellent, Good, Poor (based on UK Used reference). Calculated buying prices are shown immediately and all percentages can be saved together.

Research evidence remains non-editable from this subscriber pricing screen. Manual offer price has been removed from the What We Buy configuration UI; the existing database field is retained for compatibility but is no longer used by this setup. If an automatic condition rule or reference price is unavailable, the buying workflow reports that an automatic price cannot be calculated and the normal manual offer process remains available.

Buying items now carry an optional item_condition using the six configured condition values. calculate_buying_item_valuation() uses the selected condition, the corresponding condition percentage, and the latest qualifying GBP UK New or UK Used research reference. The Buying dashboard now asks for the condition before calculating the automatic price.

External market research reviewed for terminology only: UK camera dealers commonly distinguish condition grades such as Mint/Like New, Excellent, Good and heavier-use grades, while MPB describes five cosmetic conditions and uses condition as an input to its pricing process. TradeFlow's six subscriber-configurable labels are intentionally kept as the business's own pricing matrix rather than copied from a third party. citeturn0search6turn0search4


## Buying Catalogue Management & Research — 19 September 2026
- What We Buy is the full-width subscriber buying catalogue.
- Subscribers can add and edit Buying categories, add and edit branches, and manage reusable manufacturers from the catalogue management panel. Existing category/branch RLS remains authoritative.
- Five buying conditions are now used: **Sealed**, **Opened, Never Used**, **Excellent**, **Good**, **Poor**. Sealed and Opened, Never Used use UK New research; Excellent, Good and Poor use UK Used research.
- `buying_items.item_condition` uses `sealed`, `opened_never_used`, `excellent`, `good`, `poor`.
- `tenant_buying_condition_rules` stores `sealed_percentage`, `opened_never_used_percentage`, `excellent_percentage`, `good_percentage`, `poor_percentage`.
- `tenant_buying_manufacturers` provides a tenant-scoped reusable manufacturer list with buying-management RLS.
- Research Centre (`buying-research.html/js`) writes subscriber-entered UK New/UK Used evidence to `tenant_buying_research`. What We Buy reads the latest checked GBP evidence as read-only reference prices.
- Gemma/other research automation can use the same `tenant_buying_research` table later; no external automated research source is claimed as live by this change.
- Manual offer remains the fallback when a condition rule or appropriate research is unavailable.


## Buying Price Basis & Manual Override — 19 September 2026
- Each of the five buying conditions can independently choose its automatic research basis: **UK New** or **UK Used**.
- Each condition has an automatic percentage against that selected reference price.
- Each condition also has an optional exact **manual override** price. A manual override takes precedence over the automatic calculation.
- If no suitable research exists for the selected basis, the subscriber can still enter a manual price; automatic calculation remains unavailable until research is available or the manual override is removed.
- The valuation RPC returns `automatic`, `manual_override`, or manual-fallback states and identifies the selected reference type.


## Buying Catalogue Hierarchy — 19 September 2026
- The subscriber catalogue is intentionally structured **Category → Branch / Type → Manufacturer → Model**.
- Example: **Cameras → Digital → Canon → EOS 750D**; **Cameras → Lenses → Canon → EF 50mm**; **Cameras → Tripods → Manfrotto → [model]**.
- Category management now shows each category with its branch count. Selecting a category loads and displays all branches belonging to that category.
- Selecting a branch makes the working context explicit and shows manufacturers used within that branch. Manufacturers remain tenant-shared because the same manufacturer can legitimately appear across multiple branches.
- Products remain assigned to the selected category and branch, preventing the catalogue from becoming an ambiguous flat list.


## Bulk Buying Pricing Profiles — 19 September 2026
- What We Buy now provides four ready-made pricing profiles that apply percentage rules across every product in the selected branch.
- Profiles are based on the Sealed percentage: **70%, 60%, 50%, 40%**. Current ladders are respectively 70/65/60/50/40, 60/55/50/40/30, 50/45/40/30/20, and 40/35/30/20/10 for Sealed / Opened Never Used / Excellent / Good / Poor.
- Applying a profile changes only automatic percentages. It does not change research evidence, reference selection, or manual override prices.
- Individual products can still be adjusted after a bulk profile is applied.


## Selectable Bulk Pricing — 19 September 2026
- What We Buy now supports product-level selection with a checkbox on every visible product.
- `Select all visible` respects the current manufacturer and model filters, so a subscriber can select an entire manufacturer, a filtered subset, or individual products.
- Bulk pricing lets the subscriber choose **UK New** or **UK Used** as the automatic reference for all five conditions and choose one of the four percentage profiles at the same time.
- `Apply pricing to selected` updates the selected products' condition reference types and automatic percentages. Research evidence and manual override prices are preserved.
- The purpose is to make a large catalogue manageable without forcing the subscriber to edit every condition cell individually.


## Universal Reference Selection — 19 September 2026
- The bulk reference choice is universal across the five conditions for each selected product. Choosing UK New means Sealed, Opened Never Used, Excellent, Good and Poor all calculate from that product's UK New research; choosing UK Used makes all five calculate from UK Used research.
- Condition does not select the research basis. Condition only selects the percentage rule.
- The UI previews the selected reference immediately for selected rows; `Apply pricing to selected` persists the reference type and percentage profile.
- TradeFlow does not silently substitute UK New for missing UK Used evidence or vice versa. If the chosen research basis has no evidence, the automatic price remains unavailable until research or a manual override exists.
- What We Buy now has clear CTAs for Main Dashboard, Buying Dashboard and Research Centre.


## Active Buying Price / Manual Override — 19 September 2026
- The catalogue now labels the price that TradeFlow will actually use as **ACTIVE BUYING PRICE**.
- If a condition has a manual override, that exact price is the active price and takes precedence over its automatic percentage calculation.
- The automatic calculation remains visible as `Automatic would be £X` for comparison, but it is not the active buying price while a manual override exists.
- To return a condition to automatic pricing, the subscriber clears the manual override field and leaves it blank, then saves the buying prices.
- The UI explicitly tells the subscriber that clearing the manual field returns the condition to automatic pricing.


## Reset Selected Buying Prices — 19 September 2026
- What We Buy now has a protected **Reset selected prices** action.
- First click arms the reset and displays a warning; a second click within five seconds confirms the destructive action.
- Reset deletes the selected products' condition-pricing rule rows and clears the legacy product-level automatic/manual base-price fields. The products then have no configured catalogue buying price and can fall back to manual quote/valuation handling.
- Selecting UK New or UK Used previews the selected basis immediately. If the selected basis has no research, automatic prices show unavailable/manual quote required rather than retaining a stale calculation from the other basis.


## Standalone TradeFlow Master Catalogue — 19 September 2026
- TradeFlow now has its own standalone master catalogue tables: `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_manufacturers`, `catalogue_master_products` and `catalogue_master_product_identifiers`.
- The initial seed was copied from the separate GearCashOut / Action Buyer UK catalogue as a one-time data import. TradeFlow does not query GearCashOut at runtime and there are no foreign keys or live catalogue dependencies back to GearCashOut.
- Imported catalogue scope is product metadata and identifiers: 34 top-level categories, 179 branches/types, 73 manufacturers, 3,845 products and 108 product identifiers.
- GearCashOut retailer-price evidence, research evidence and market-pricing fields were deliberately not copied into the TradeFlow master catalogue. Subscriber buying prices remain independently configured through TradeFlow research and condition rules.
- The live plan definition currently assigns `catalogue.pre_filled` to the **Catalogue** plan, not Enhanced. Enhanced remains the separate higher-tier feature set already defined in `plan_features`.
- Catalogue-plan seeding is performed by the protected `public.seed_tenant_master_catalogue(uuid)` RPC. It copies the master catalogue into the subscriber's own `categories`, `category_branches`, `tenant_buying_manufacturers` and `tenant_buying_products` records. Once seeded, the tenant operates on its own copy.
- `tenant_catalogue_state` records the seed version and counts so the operation is idempotent.
- The What We Buy page now attempts the protected catalogue seed during startup for eligible Catalogue-plan tenants. Non-Catalogue plans continue to use their existing tenant catalogue path.
- Buying-catalogue JavaScript cache-buster is now v15.
- A startup blocker was identified and repaired: the page referenced an undefined `armOrResetSelectedPrices` handler before authentication initialisation, which could stop the script before Category/Manufacturer/Branch loading. The handler is now defined and performs the intended two-step reset.


## 19 September 2026 — Master catalogue entitlement expanded

The independent TradeFlow master catalogue remains a separate snapshot from GearCashOut / Action Buyer UK. The catalogue.pre_filled entitlement has now been enabled for all three active customer-facing plans: **Basic, Enhanced and Catalogue**. Each plan receives the same unlimited category/product/subcategory entitlement configuration. This changes access entitlement only; it does not create a runtime dependency on GearCashOut and does not import GearCashOut research or pricing evidence into subscriber buying references.

Verification: live plan_features confirms catalogue.pre_filled enabled for Basic, Enhanced and Catalogue. The actual tenant catalogue seed/copy path remains tenant-owned and must continue to use the TradeFlow master snapshot.


## 19 September 2026 — Master Catalogue duplicate-category cleanup

The standalone TradeFlow master catalogue was inspected after the GearCashOut snapshot import. GearCashOut remains untouched and is not queried at runtime. Two clear duplicate category structures were found in the TradeFlow copy and cleaned up:

- Drone → Drones: the singular Drone category and its one product were moved into the canonical Drones category. Its Drone branch was moved under Drones and retained so the product/branch relationship was not lost.
- Tripod/Support → Tripods: the Tripod/Support category and its two products were moved into the canonical Tripods category. Its duplicate Tripods branch was merged into the existing canonical Tripods branch before the old branch/category were deleted.

The cleanup was applied only to catalogue_master_categories, catalogue_master_branches and catalogue_master_products in the TradeFlow Supabase project. No GearCashOut database objects or data were changed. The canonical categories now present are Drones and Tripods; the duplicate category records no longer exist.

Broader names such as Camera & Video, Cameras, Audio & Video, Audio, Camera Equipment and Video Equipment were not automatically merged because their names alone do not establish that they are duplicates. This avoids silently moving distinct product classes.

Verification: the merge migration completed successfully; the duplicate category names were re-queried and only Drones and Tripods remain from those pairs. The Drones category now contains 541 products across its retained branches, and Tripods contains 4 products in its single canonical Tripods branch. Browser verification of the subscriber selector remains open.


## 2026-09-19 — Buying Catalogue Master Copy & Cascading Selectors

- The subscriber Buying Catalogue uses the TradeFlow-local master catalogue tables (catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers, catalogue_master_products) as the seed source. The subscriber copy is tenant-owned in categories, category_branches, tenant_buying_manufacturers, and tenant_buying_products and does not query GearCashOut at runtime or use GearCashOut research/pricing for valuations.
- The current master snapshot contains 32 categories, 178 branches, 73 manufacturers and 3,837 active products. The test subscriber has its own tenant copy and can diverge independently.
- Buying Catalogue selectors are now cascading: Category → relevant Manufacturers → relevant Branches for the selected manufacturer → Models in the selected branch/manufacturer. Changing an upstream selection resets and reloads downstream selections rather than leaving unrelated values available.
- buying-catalogue.js commit ff575e5204f7cb3efc12284a5109be0610334a5b implements the selector dependency logic. buying-catalogue.html commit 34771b980131a4be683179ecf6f6f8b5a21ce2c9 changes Model to a dependent select and cache-busts the JS to v16.
- Syntax check passed with new Function() after the selector change. Live browser verification is still required after a hard refresh.

## 23. Buying catalogue master-copy architecture and selector repair — 19 September 2026

The Buying Catalogue now uses a **TradeFlow-owned master catalogue copy**. The source data was copied into these TradeFlow tables and is no longer queried from GearCashOut:

- `catalogue_master_categories`: 32 master categories
- `catalogue_master_branches`: 178 master branches
- `catalogue_master_manufacturers`: 73 manufacturers
- `catalogue_master_products`: 3,845 products

The live `seed_tenant_master_catalogue(uuid)` function reads only the TradeFlow `catalogue_master_*` tables. A direct function-definition check found no GearCashOut reference. Subscriber copies remain tenant-owned in `categories`, `category_branches`, `tenant_buying_manufacturers` and `tenant_buying_products`.

The pre-filled catalogue entitlement is now enabled for **Enhanced** and **Catalogue**, and disabled for **Basic**. This matches the intended package boundary. The active Catalogue plan remains in the database.

### Buying selector fault

The Buying Catalogue source was calling `loadCategoryScope()` during category initialisation, but the current `buying-catalogue.js` did not contain that function. That prevented the category → manufacturer → branch initialisation chain from completing. The repair added `loadCategoryScope()`, loads the selected category's tenant products first, then derives the manufacturer filter from those products before loading the selected category's branches.

The HTML cache-buster was advanced to `buying-catalogue.js?v=17` so the browser does not continue serving the previous controller.

The category selector also now de-duplicates category slugs in the rendered list.

### Legacy test-tenant cleanup

The existing subscriber test tenant had stale pre-master catalogue aliases left from earlier catalogue work. The known legacy `Drone` category was merged into the canonical `Drones` category and its product retained. The stale `Tripod/Support` category was merged into canonical `Tripods`. The empty legacy `Drones` branch was removed; the canonical `Drone` branch was restored under `Drones`.

The tenant still retains its unrelated custom `Accessories` category and its manually added Canon product. These were not deleted.

### Verification state

Database verification completed for the master-copy counts, package feature flags, test-tenant alias cleanup and absence of duplicate category slugs. The code change is committed. **Browser verification of the repaired selector is still OPEN**: hard-refresh the deployed Buying Catalogue and confirm Category → Manufacturer → Branch populate, then select Cameras → Canon → Digital and confirm the product matrix loads.


## 24. Buying Catalogue master-copy rollout and browser cache repair — 19 September 2026

The Buying Catalogue master-copy design is confirmed as the intended Enhanced/Catalogue feature. TradeFlow has its own master catalogue tables containing 32 categories, 178 branches, 73 manufacturers and 3,845 products. The tenant seed RPC reads only those TradeFlow master tables; it does not query GearCashOut at runtime and GearCashOut research/pricing is not used for tenant buying valuations.

Package entitlement is confirmed live: Basic = disabled, Enhanced = enabled, Catalogue = enabled for catalogue.pre_filled.

The current subscriber test tenant subscriber test 1 is on Basic, so it is not entitled to auto-seed the master catalogue. Its existing custom catalogue remains separate. An Enhanced/Catalogue tenant is the correct browser test for the pre-filled catalogue.

The Buying Catalogue page had a deployed-browser cache mismatch: the screenshot reported loadCategoryScope is not defined even though the current controller contains that function. The page script cache-buster has therefore been advanced from v17 to v18. The temporary on-page master-catalogue explanatory banner has also been removed so product pages do not carry development/prompt text.

Browser verification remains OPEN until the deployed page is hard-refreshed and tested against an Enhanced/Catalogue tenant.




## 19 September 2026 — Unified subscriber catalogue selection architecture

The subscriber category page is being consolidated with the master catalogue. The intended model is now:

**TradeFlow master catalogue → subscriber selects products → TradeFlow automatically creates the required tenant category/branch → product is enabled for Buying and/or the Selling Website.**

The subscriber does not have to manually create a live category before selecting a catalogue product. Categories and branches remain tenant-owned copies and can diverge from the master catalogue. Products can be enabled for Buying only, Selling Website only, or both.

A new tenant-scoped table, `tenant_catalogue_selections`, records the subscriber's relationship to each master product without making the master catalogue tenant-specific. A protected `activate_master_catalogue_products()` RPC creates any required tenant category/branch/manufacturer records and, when Buying is enabled, creates the corresponding `tenant_buying_products` record so the existing Buying/Valuation path remains intact.

The unified UI is `categories.html` / `category-management.js`. It reads the standalone TradeFlow master snapshot through `get_master_catalogue_for_selection()`. It does not query GearCashOut / Action Buyer UK.

The master snapshot currently verified in TradeFlow contains 32 categories, 178 branches, 73 manufacturers and 3,845 products. This is a TradeFlow-local snapshot. GearCashOut remains outside the runtime dependency graph and is not used as buying research or valuation evidence.

Subscription boundary remains explicit: `catalogue.pre_filled` is currently disabled for Basic and enabled for Enhanced/Catalogue. The current Basic test tenant therefore cannot be used to browser-test the master catalogue selection until an eligible tenant/plan is used.

State: **Implemented at database and GitHub boundary; browser verification remains open.**



### 19 September 2026 — Buying Prices no longer seeds the entire tenant catalogue

The separate Buying Prices workspace no longer calls `seed_tenant_master_catalogue()` when it opens. Catalogue activation is now an explicit subscriber action on Catalogue & Categories. Buying Prices works on products already selected for Buying and remains responsible for condition percentages, research basis and manual overrides. The legacy seed RPC remains available for controlled migration/maintenance but is no longer the normal subscriber page startup path.


## 2026-09-19 — Unified subscriber buying catalogue

The subscriber buying setup is now a single workflow rather than separate Catalogue & Categories and Buying Prices pages. 

- `catalogue_master_*` is TradeFlow's standalone master catalogue. It is not queried from GearCashOut / Action Buyer UK at runtime.
- The copied master data was verified against the source dataset: 3,845 products, 102 catalogue-category labels, 34 main categories, 155 product types and 73 manufacturers; 3,822 products are active/customer-visible in both datasets.
- The unified `buying-catalogue.html` page lets an Enhanced/Catalogue subscriber filter the master catalogue, select products and activate them for Buying (or Buying + Selling).
- Activation automatically creates the subscriber category, branch and manufacturer records and the tenant buying product. A product with no configured buying price remains eligible for manual valuation/quote rather than receiving an invented price.
- `categories.html` is now a legacy redirect to the unified buying catalogue.
- The master selection RPC now uses the copied product's `catalogue_category` label for subscriber-facing category creation.
- The test subscriber tenant `subscriber test 1` is on the Enhanced trial so the pre-filled catalogue entitlement can be exercised.


### Post-change verification — 2026-09-19
The authenticated RPC test returned 3,822 master products for the Enhanced test tenant. A transaction-scoped activation test for an Autel Alpha master product produced category "Drone", branch "Camera Drones", manufacturer "Autel Robotics", with both automatic_percentage and manual_offer_price null; the transaction was rolled back, so no test product was left behind.

## 19 September 2026 — Buying Pricing / Master Catalogue consolidation

The subscriber Buying Catalogue has been consolidated into a single **Buying Pricing & Master Catalogue** workflow. The master catalogue is now the source of the subscriber's Buying configuration rather than requiring the subscriber to create a category first and then return to a separate pricing screen.

For an eligible subscriber, the page reads only the TradeFlow-owned master catalogue:
- `catalogue_master_categories`
- `catalogue_master_branches`
- `catalogue_master_manufacturers`
- `catalogue_master_products`

The current live TradeFlow copy contains 32 master categories, 178 master branches, 73 manufacturers and 3,822 active/customer-visible products. This data is independent of GearCashOut and is not queried from GearCashOut at runtime.

User action is now:
**find product → choose Off / Manual / Automatic → save price/rule**.

Choosing Manual or Automatic calls `configure_master_catalogue_buying_product()`. That protected RPC creates or links the tenant category, branch and manufacturer and creates/activates the tenant `tenant_buying_products` record. The subscriber therefore does not have to build the category/product hierarchy separately.

Pricing states are visually distinguished:
- light red/pink = Inactive;
- light green = Active for Buying but no price configured;
- light yellow = Manual offer;
- light grey = Automatic pricing rule.

Manual pricing is stored in the tenant buying product's `manual_offer_price`. Automatic pricing is stored in `tenant_buying_condition_rules` with the existing five condition percentages and research-basis defaults. Turning a product Off/reset clears its buying price configuration and deactivates the tenant buying product without deleting the master catalogue product.

The valuation RPC `calculate_buying_item_valuation()` now checks a configured product-level manual buying price before condition-based automatic pricing, so a manual price selected from the master pricing page is actually honoured by the downstream Buying → Valuation workflow.

Implementation:
- `buying-catalogue.html` commit `cc0e228ebda87113d2a65dbb026f7ef634909dbb`
- `buying-catalogue.js` commit `900705eb3112284cbd21e16141ffafd252a3089d`
- Supabase migration `master_catalogue_pricing_control`
- Supabase migration `manual_product_price_in_buying_valuation`

Verification state: **Implemented / database boundary tested; authenticated browser verification remains OPEN.** The previous category/manufacturer/branch selector failure is no longer the intended workflow because the page no longer requires those tenant-owned selectors to be populated before pricing a master product.


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


## Subscriber Business + Customer Portal Completion — 20 September 2026

TradeFlow now has the first production-oriented connection between subscriber business identity, subscriber customer management, customer account registration and the public customer website.

### Subscriber Business Settings
The subscriber Settings area now provides customer-facing business details: business name, public email, telephone, address, postcode, country, business description and public-display controls. Website URL and payment settings remain separate.

### Subscriber Customer Backend
Customer Management is now a dedicated tenant-scoped area. Subscribers can search customers and edit first name, last name, email, phone and status. The active tenant remains the security boundary.

### Customer Portal
The existing customer portal has been converted away from the old test-lab tenant selector. Customer registration now receives the tenant from the subscriber website and creates the customer relationship against that tenant. Customer profile editing is available for first name, last name and phone; authenticated email remains authoritative.

### Customer Website
The public website reads the subscriber's public business profile and can show the business description, telephone, email and address. Customer Login, What We Buy and What We Sell remain platform-controlled routes so subscribers cannot accidentally remove the core customer journey.

### Semi-editable design rule
Subscribers control templates, colours, backgrounds, typography, copy, imagery, logo, optional pages and social/review links. TradeFlow retains the customer-critical routes, tenant connection, catalogue connection, retail inventory connection and customer account entry.

### Security
A tenant-scoped tenant_public_profiles table is protected with RLS. Anonymous visitors receive read-only access to active tenant profiles. Subscriber writes require tenant.manage. Customer registration/update RPCs are restricted to authenticated users and use a pinned search path. A partial unique index prevents duplicate Auth-user/customer relationships within a tenant.

### Remaining portal work
Customer address management, richer subscriber customer detail/history, logo/profile media synchronisation and a complete fresh-account browser test remain follow-up items. Existing unrelated Security Advisor findings remain separate hardening work.


## 2026-09-23 — Test One complete end-to-end restore checkpoint

Test One is now treated as the completed known-good baseline for TradeFlow.

The test followed a new subscriber business and a new subscriber customer through the operational chain from customer selling request, valuation and offer handling, through inspection and purchase completion, into Inventory, Selling, Sales Channels and the published retail website listing.

### Restore point

- GitHub repository: `laurendigitaluk/TradeFlow`
- Restore branch: `checkpoint-test-one-20260923`
- Functional baseline commit: `80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1`
- Checkpoint documentation commit on the restore branch: `ea00d6ae238f6e47c4798b73ec6340ade2c2d5fd`
- Supabase project: `twfbmjwwqzxdvclxbun`

The restore branch is the known-good code baseline for Test One. Test Two should start from the normal/default project state without deliberately altering the Test One baseline. If Test Two introduces a regression, compare the failure against this checkpoint before changing working behaviour.

### Test One completion boundary

The following are part of the Test One baseline:

- New subscriber/business setup.
- New subscriber customer account and customer relationship.
- Public customer selling journey.
- Buying and valuation workflow.
- Initial/final offer workflow.
- Customer acceptance and shipping/receipt handoff.
- Inspection and inspection outcome.
- Bank-detail/payment handoff.
- Payment-gated purchase completion.
- Acquisition and Inventory creation at purchase completion.
- Inventory to focused Selling workspace.
- Purchase/source information and photographs carried into Selling.
- Retail listing preparation and retail condition.
- Website listing publication.
- Public retail product page and product photography.
- Sales Channels / Marketplace Management foundation.
- One physical Inventory asset as the stock master record.
- Multiple channel-listing architecture without duplicate stock.
- Editable/add/remove Sales Channels.
- eBay/Amazon connection guidance without pretending marketplace accounts are connected.

### Remaining boundary

The subscriber-facing **Subscribe / receive payments on the subscriber's website** payment integration is the remaining identified step before the subscriber website payment journey is considered complete.

Real eBay OAuth/API connection, real Amazon SP-API connection, channel-specific marketplace publishing/delisting, and authoritative cross-channel sale propagation with automatic **DELIST REQUIRED** remain later stages and are not part of the Test One baseline.

### Documentation state labels

When continuing work, distinguish:
- **Implemented in GitHub** — code exists in the repository.
- **Live DB verified** — the corresponding Supabase state has been checked.
- **Browser verified** — the user-facing behaviour has been exercised in a browser.
- **Checkpointed** — the state is recorded as a named restore baseline.

Do not describe an item as browser verified when only GitHub or database verification has occurred.



## 24 September 2026 — Parcel2Go subscriber shipping connection

TradeFlow uses Parcel2Go as the single integrated multi-carrier shipping provider. Subscribers do not configure individual courier credentials in TradeFlow.

Subscriber setup:
- Open Shipping Settings.
- Enter the subscriber's Parcel2Go API Client ID and API Client Secret.
- Select the appropriate Parcel2Go environment (Live for the subscriber's production account; Sandbox only when using separate sandbox credentials).
- Select Save and test connection.
- TradeFlow stores the secret in Supabase Vault and performs the Parcel2Go OAuth client-credentials test server-side.
- A successful test marks the tenant's Parcel2Go connection connected.

The browser never receives the stored Client Secret. The Buying workflow treats a connected Parcel2Go account as the integrated shipping connection; the subscriber does not select or maintain separate direct-carrier integrations in TradeFlow.

The connection test does not create, purchase or pay for a shipment. Parcel2Go's API supports live quoting, order creation, payment, labels and tracking; these remain separate operational stages and must not be conflated with credential testing. citeturn2view0turn3view0

Current verification: the Camerashack test subscriber successfully authenticated against Parcel2Go Live in the browser on 24 September 2026. No shipment was created.


## Initial offer workflow — 24 September 2026

TradeFlow now treats the initial customer offer as one workflow with two possible manual values: **Manual offer — Cash** and **Manual offer — Trade-in**. A manual initial offer may publish one or both values, and the customer can choose which published option to accept. Each option is stored as an offer with an explicit `offer_mode` of `cash` or `trade_in`.

Automatic catalogue pricing has priority over manual initial offers. When an automatic price is calculated, TradeFlow creates the automatic valuation and one initial offer record linked to it; that valuation carries the cash/trade-in option values. Previously published initial/revised offers and approved valuations for the item are superseded. Manual initial offer controls are disabled while an automatic valuation is active.

When the customer accepts one initial option, the selected cash/trade-in mode and amount are recorded on the single offer record and the buying item moves to `awaiting_item`. After receipt and a passed inspection, the authoritative inspection workflow moves the item to `final_offer_required`; the subscriber then creates and publishes the **final offer** through the existing post-inspection workflow. The final offer is separate from the initial cash/trade-in choice.


## Initial offer workflow clarification — 24 September 2026

Each manual initial offer is represented by one published `offers` record linked to one approved `trading_values` record. The linked valuation holds both `cash_price` and `trade_in_price`; the customer chooses one option from the same offer. The selected `offer_mode` and accepted `amount` are recorded on that offer. There is no second published initial offer record for the other choice.


## 24 September 2026 — Parcel2Go integrated pre-acquisition shipping UI

The Buying dashboard now exposes the connected Parcel2Go workflow directly in the shipping handoff. When an initial offer is accepted, the subscriber can enter parcel weight and dimensions, request live Parcel2Go courier quotes, compare returned services, and explicitly create a selected shipment. Shipment creation is performed server-side by the parcel2go-subscriber-shipping Edge Function; the subscriber's connected Parcel2Go account remains responsible for shipping payment. Manual label/QR shipping remains available as a fallback. The obsolete shipping-label-selector.js helper has been removed. This is Implemented in GitHub; live browser verification of the quote/order flow remains pending.


## 24 September 2026 — Customer delivery-address type correction

The live `public.customer_addresses.address_type` contract permits `primary`, `billing`, `shipping` and `other`; it does not permit `delivery`. The customer-facing label remains **Delivery address**, but the stored internal value is `address_type=shipping`.

`customer-dashboard.js` was corrected so the Delivery option and Add delivery address action use `shipping`. The integrated Parcel2Go function was also corrected so its customer-address lookup uses `address_type=shipping`. The Parcel2Go Edge Function was redeployed as version 3 on 24 September 2026. No Supabase schema or Test One data was changed. Browser verification of the quote request remains the final test.


## 24 September 2026 — Test Two valuation display and shipping message clarification

The Test Two customer has an approved manual trading value with cash price £50 and trade-in price £55. The customer accepted the £55 trade-in offer. The customer dashboard previously labelled the £50 cash price simply as “Valuation”, which was misleading after the trade-in offer had been accepted. The dashboard now shows the accepted offer amount when an accepted offer exists, while retaining the underlying cash/trade-in values. The buying dashboard's Parcel2Go explanatory text was also changed so it no longer implies that the address is currently missing; it explains that Parcel2Go uses the saved Delivery address from My Details.
## 25 September 2026 — Buying dashboard regression-control repair

A Test Two browser failure showed the Buying dashboard permanently displaying its static loading placeholders. The first diagnosis incorrectly concentrated on asynchronous data loading. A full current-code audit identified the actual first failing boundary: buying-dashboard.js contained an unescaped ASCII apostrophe inside a single-quoted JavaScript string in the Parcel2Go shipping handoff text (customer's). The browser therefore could not parse the controller at all, so none of its Supabase loading code could run.

This is a critical regression lesson: a JavaScript parse error can make a page appear to have a database/loading problem while preventing every downstream request from starting. The repaired controller was compiled with new Function() after the correction and the dependent subscriber scripts were also syntax-checked.

New control rule for all TradeFlow browser-controller repairs:
1. Inspect the first failing boundary before changing data, RLS or workflow state.
2. Syntax-check every changed JavaScript controller before committing.
3. After a controller repair, syntax-check its directly loaded companion controllers as well.
4. Cache-bust the page when a browser may retain an earlier controller.
5. Do not delete/reseed Test Two data to compensate for a front-end runtime failure.
6. Do not alter the frozen Test One restore branch or its Canon transaction/data.
7. A loading placeholder is not evidence of a Supabase data failure until the controller has been proven to execute and its network calls have been observed.

The Buying dashboard now has a startup marker and an inline HTML watchdog so a future controller parse/load failure is displayed as an explicit script error instead of silently leaving the page on its static loading placeholders.

Relevant commits:
- 020af4b4654483aef6d55676d0c9943f1eb8bded — corrected the JavaScript parse error.
- 54b8022ffab4ca369ec0bc339ed4b8d7a847825b — added the controller startup marker.
- 3e488347ede1290a6dc8699d4995b23d3b676dfb — added startup diagnostics and cache-bumped the Buying dashboard controller to v57. A subsequent audit found that the Business Dashboard navigation still pointed to the Buying page with the previous HTML cache key `?v=58` after the Buying page itself had advanced to controller `v59`. This could cause navigation to restore a cached HTML document and make the user see the previous controller until a manual refresh. The navigation has now been synchronized to `?v=59`.

Current state: Implemented in GitHub and syntax-verified; browser verification remains required. The latest cache-key synchronization commit is `6207f0ca4b028351ebee149598898a563ccf1f58`.


## 25 September 2026 — Buying dashboard status/description rendering regression

The next browser test showed that the previous Buying-dashboard repairs were not sufficient. A fresh audit of the current GitHub source and live Test Two data identified two separate frontend defects still present in main:

1. Customer-supplied description parsing was still wrong. The Test Two buying_items.description stores literal \\n separators. The controller correctly converted those separators to real newline characters, but then incorrectly attempted to split the converted text using the literal \\n pattern again. The result was one long line, so the key/value parser treated the entire submission as a single field. The repair changes the second split to /\\n+/, after conversion, so Product type, Manufacturer, Model, Package, Condition, Missing items and Legal right to sell render as separate fields.
2. The green Submitted status class had no CSS definition. requestStatusClass('submitted') already returned status-approved, but no loaded stylesheet defined .status-pill.status-approved. The browser therefore used the neutral base status-pill styling. Explicit status-pill colour classes have now been added for approved, review, offer and refused states.

The live Test Two database was checked before the repair. The current Nikon request is BR-4C34C6F633, item BI-9D1C8F01FB, customer CUS-E82930637A58; both request and item are submitted, the item has quantity 1, the description contains the expected literal newline separators, and two media records are present. No database data, RLS policy, workflow transition or media record was changed.

The page/controller cache keys were also advanced so the browser cannot reuse the previous repaired asset combination:
- buying-dashboard.css v5 → v6
- buying-dashboard.js v59 → v60
- all three Business Dashboard Buying links v59 → v60

Relevant commits:
- 8e6dbea8964296afeccb2d0f378f8ee57aea8f25 — fix customer detail line parsing
- c76d730df2f8eb823cea44d586781b07385bc2df — add Buying status-pill colour classes
- 6a7af0a400996db0c1ff7ac7f9c2ff583621013b — cache-bust Buying page/controller assets to v6/v60
- ccbbbf136c59a50cea1700a2b4d328e24b5147ad — synchronize Business Dashboard Buying navigation to v60

Verification state: Implemented in GitHub; live DB verified; source-level logic verified. Browser verification is still required. Test One remains frozen.


## 25 September 2026 — Second Buying rendering correction

The next browser screenshot exposed two remaining source defects. First, the customer-detail key/value parser used `:\\s*` in a JavaScript regular-expression literal. That matches a literal backslash followed by `s`, not whitespace, so none of the `Product type: ...`, `Manufacturer: ...` etc. lines were parsed into separate fields. The parser has now been corrected to `:\s*`.

Second, the Submitted state was previously shown only as a green status pill. The requirement is that the entire Review customer submission stage is visually greyed when the item is still in the submitted state, rather than using green to imply an approved/completed review. The stage now receives `submitted-stage` styling and the Submitted pill is neutral grey within that stage.

The latest cache keys are buying-dashboard.css v7, buying-dashboard.js v61 and Business Dashboard Buying links v61. No Test Two data, RLS, schema or workflow state was changed. Test One remains frozen.

Relevant commits:
- 3ab98cbe927b0e2fc988728844601a7684bf8db7 — correct customer-field whitespace parsing and mark submitted review stage
- 1a09216ac77c656ab2636f81a94a6bace76fe6ef — grey submitted review stage
- 65cb2522f5b0fdd1a3a3ab9a28f165b88a45b34a — cache-bust Buying assets to v7/v61
- 13da412223385bdd73517ef9eebb07aab94b60bf — synchronize Buying navigation to v61

Verification state: Implemented in GitHub; source logic verified; browser verification pending.


## Test Two — Current Shipping Workflow State (25 September 2026)

The buying shipping workflow no longer uses Parcel2Go API integration. TradeFlow's current model is subscriber-managed shipping: the subscriber selects supported shipping services in Shipping Settings, obtains the label/service directly from the provider, then uploads the label/QR code, carrier, service, tracking number and dispatch information to TradeFlow. The customer receives those shipping files and instructions through the Customer Portal. TradeFlow does not purchase shipping or collect the customer's shipping cost.

After the customer confirms dispatch, the subscriber Buying workflow is **Awaiting item**. The subscriber view retains the dispatch date, shipping service, carrier and tracking number. After **Confirm item received**, the buying item moves to **received** and the next required step is **Inspection**. The received state must be green and must not show the receive button again. The Inspection state must be green and provide the inspection controls.

Do not restore the retired Parcel2Go API flow or the old post-acceptance message claiming that the business will create the shipping label after acceptance. The Customer Portal's accepted-offer block is informational only; the live stage/status message determines what the customer needs to do next.


## 25 September 2026 — Test Two inspection workflow correction
The current unified buying workflow is: customer confirms dispatch → subscriber confirms item received → subscriber explicitly starts inspection → inspection is completed → accepted inspection proceeds to final offer → customer accepts final offer → payment → Inventory. The Start inspection control must call the `subscriber_start_buying_item_inspection` RPC and change `buying_items.purchase_stage` from `received` to `inspection`; the inspection completion control then calls `subscriber_complete_buying_item_inspection`. Do not treat the inspection form as available while the database stage remains `received`. Parcel2Go API shipping remains retired; shipping labels/services are subscriber-managed and paid directly to the selected carrier/service.


## 25 September 2026 — Post-inspection trade-in decision model
After a passed inspection, TradeFlow must not automatically create or send a final offer when the accepted trade-in value remains unchanged. The subscriber decision is: **Add the accepted trade-in value to customer credits** when the value is unchanged; **Send revised final offer** only when inspection changes the value; or **Refuse trade-in** when the item is not acceptable. Adding credit records the customer credit, acquisition and Inventory asset and moves the buying item to `purchased`. A revised final offer moves the item to `final_offer_sent` and waits for the customer's response. A refusal closes the buying item as `offer_refused`. Bank-transfer payment remains the cash-purchase route; a trade-in at the accepted value is customer account credit, not a bank transfer.


## 25 September 2026 — Customer credit account
Trade-in customers now have a dedicated `customer_credit_accounts` account per subscriber business. Each existing customer was provisioned with a zero GBP balance and new customer registration provisions the account automatically. Accepted unchanged trade-in values increase the account balance through the server-side credit workflow. The customer portal displays the available credit and the selling journey presents an unchanged accepted trade-in as Payment rather than Final Offer.


### Post-inspection decision flow correction — 25 September 2026
Inspection is a decision point, not automatically a Final Offer stage. After an inspection, the subscriber must choose one of four paths: **pay the accepted cash offer to the customer's bank**, **credit the accepted trade-in value to the customer's Trade-in Credit Account**, **refuse/close the transaction**, or **send a revised final offer only when the value has changed**. The customer portal should remain on Payment for an unchanged accepted offer. It should move to Offer only when a revised final offer is actually published. Do not describe every post-inspection transaction as a final-offer step.


## 26 September 2026 — Retail sale shipping must mirror Buying shipping

Retail sales use the same subscriber-managed shipping handoff model as customer Buying. The subscriber selects saved shipping services in Shipping Settings, opens the provider, creates/pays for the shipment directly with that provider, then returns to TradeFlow and records the carrier, service, tracking, shipping instructions and the generated printable label and/or QR code.

The Fulfilment workspace must show the actual paid order before shipping is completed. It must show the purchased item(s), inventory reference/condition where available, customer name/email, delivery address, parcel weight and L/W/H measurements, and the shipping handoff files. The subscriber must not have to guess which item is being shipped.

Parcel weight and dimensions are packed-parcel data, not merely product-specification data. Current Parcel2Go guidance requires the declared weight/dimensions to include packaging and warns that under-declaration can produce surcharges. Royal Mail Click & Drop likewise requires order weight and packaging size when applying postage. TradeFlow therefore records the packed parcel measurements in fulfilment_parcels.

A completed retail shipping handoff moves fulfilment from awaiting to label. The customer portal then receives the label/QR, carrier/service, tracking and instructions. The handoff queues a customer email containing the same operational details and a link to the Customer Portal. Dispatch moves label to dispatched and queues the dispatch notification.

Do not reintroduce direct browser writes to fulfilments or direct browser reads of retail_orders. Retail fulfilment writes/reads must use the subscriber/customer RPC boundaries.



## 26 September 2026 — Retail fulfilment handoff UX clarification

The current retail Fulfilment UI separates **provider booking** from **TradeFlow handoff recording**. Shipping Settings defines the services the subscriber may use. The Fulfilment workspace lets the subscriber select one, open the provider, complete the booking there, then return to record the carrier/service/tracking and upload the label or QR code.

TradeFlow does not need to duplicate the provider's parcel-booking form. Weight and L/W/H remain valid packed-shipment data and may be stored in fulfilment_parcels, but the current handoff UI does not ask the subscriber to enter those values again. They must still be supplied accurately to the chosen courier/shipping provider when creating the shipment; current provider guidance requires packed shipment weight/dimensions for quoting or label generation.

The handoff completion boundary is subscriber_save_retail_fulfilment_shipping(). The latest reliability repair performs the authorised awaiting → label transition directly inside that RPC and preserves existing parcel measurements when the simplified handoff UI does not provide new measurements. This avoids coupling the save action to the generic workflow transition function.

The Selling workspace also uses cache-busted startup references and a guarded initialisation path so a stale/racing subscriber auth load cannot leave Available or Sold stuck on Loading until a manual refresh.



## 26 September 2026 — Retail customer shipping and returns boundary

For retail purchases, the customer is the recipient. The customer portal must not expose the business's printable outbound shipping label or courier QR code as part of the normal order view. My Orders shows the shipment status, carrier/service and tracking information.

The subscriber Fulfilment workspace retains label/QR access because the subscriber creates and manages the shipment. The subscriber uses Mark as sent only after the parcel has physically been handed to the courier. The existing subscriber transition queues the customer dispatch notification.

A retail return becomes available to the customer after fulfilment is marked delivered. The customer may select a delivered order item, choose a reason and add optional notes. customer_request_return() is the authoritative write boundary. It uses return_type='customer_retail', requires the customer's own order item, requires delivered fulfilment, and rejects duplicate active return requests.

Customer Portal authentication must complete before tenant/customer profile RPCs run. Do not perform an initial customer_get_profile call against a stored session until customer-auth.js has completed session restoration/validation.


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



## 2026-09-26 — Subscriber-controlled Stripe checkout payment methods
- Business Settings now exposes tenant-scoped Stripe checkout controls for **Credit or debit card**, **Link**, **Klarna**, and **Amazon Pay**.
- Card remains the required base online payment method. Subscribers can independently enable or disable Link, Klarna and Amazon Pay.
- The checkout Edge Function reads these settings and sends Stripe's dynamic-method filter using `allowed_payment_method_types[]`. Stripe remains the authority for method eligibility at checkout.
- Apple Pay is deliberately documented as Stripe-managed rather than represented as a false TradeFlow toggle. Stripe's API documentation lists Apple Pay as a wallet without an API enum, while Link and Amazon Pay have API enums. With card payments enabled, TradeFlow cannot independently suppress Apple Pay through the Checkout Session API.
- Do not reintroduce a second payment-method configuration system. Use `tenant_payment_methods` for subscriber-controlled Stripe method preferences and keep provider connectivity separate.


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


### 2026-09-26 — Subscriber fulfilment label actions clarified
- In the **subscriber Fulfilment dashboard**, existing shipping-file actions now read **Add label** and **Add QR code**. They open the corresponding file chooser so the subscriber can add or replace the provider-supplied file.
- Subscriber Fulfilment no longer presents these actions as **View / print**. Printing/viewing is a customer-facing action after the shipping details have been sent to the customer.
- Fulfilment dashboard cache bumped to `fulfilment-dashboard.js?v=9`.
- GitHub commits: JS `a8413720cde6e0032b96463f145fa6386d94726c`, HTML `5b8696d4af4d46f09717cae5b0a3515b647b610b`.


### 2026-09-26 — Paid retail order fulfilment gap repaired
- Investigation of the £75 retail order found the payment had completed correctly, but no `public.fulfilments` row had been created. The previously working £49.91 path had created its fulfilment record during the older full-credit payment flow; the newer mixed/card settlement path did not.
- Live fix: `20260926240000_retail_order_fulfilment_auto_create` adds an `AFTER UPDATE OF status` trigger on `retail_orders` so every transition to `paid` creates an `awaiting` fulfilment record when one does not already exist. Existing fulfilments are preserved.
- The migration also backfilled paid retail orders that were missing a fulfilment. Camerashack `ORD-20260926-DCCBB973` now has fulfilment `FUL-E9EE0FA60C79` in `awaiting` status; the £49.91 order remains `dispatched`.
- GitHub migration commit: `4c8c2136d76afbdf05e50a0f88b00226609d02fd`.


### 2026-09-26 — Retail fulfilment handoff and Test Three JWT recovery
- The £75 paid retail order now has an `awaiting` fulfilment record. The subscriber must still return from the external shipping provider and **Add label** or **Add QR code**, enter carrier/service/tracking as applicable, then use **Save & send shipping details**. Only that handoff moves fulfilment from `awaiting` to `label`, at which point **Mark as sent** becomes available. Creating a label externally cannot be detected by TradeFlow until the provider-supplied file/details are recorded in TradeFlow.
- Customer Test Three exposed a stale customer access token: the selling wizard reached the submit stage but the `customer-selling-submit` Edge Function returned `Invalid JWT`. The public selling journey now validates the stored customer session, refreshes it when possible, and retries a JWT failure once with the refreshed token. Public-site cache is now `public-site.js?v=81`.
- GitHub commits: public selling journey auth recovery `c9102faaa5d8030623418f7abc9d071687511142`; cache `7ab324bfcfbfa9d97d939c2854ce45196bd76b1a`.


### 2026-09-26 — Customer valuation photograph access
- Subscriber Buying showed **“Photographs were supplied but could not be opened”** for multiple customer valuations. The stored media records and Storage objects exist under `tradeflow-media/{tenant}/customer-buying/{buying_item}/...`; the failure was in subscriber-side private storage access rather than missing photographs.
- Live migration `20260926250000_customer_buying_photo_subscriber_access` adds an explicit tenant-scoped Storage SELECT policy for authenticated subscriber members on the `customer-buying` folder. Customer photographs remain private and are not made public.
- Buying dashboard cache is now `buying-dashboard.js?v=41`. The photo loader also surfaces the secure-link error instead of silently swallowing it, making any future access failure diagnosable.
- GitHub commits: migration `e995d4ad74a6e4b2b2750c366f59d5abe3277409`; JS `df951448616a658c0b2fc2d6346c574ffb9b40df`; HTML `0df7280548b94c4bb77596a19d651395a7a2c851`.


## 26 September 2026 — Concurrent-session test and isolation rule

TradeFlow is currently being browser-tested with Platform Owner, Subscriber and multiple Customer sessions open concurrently. These are separate authentication boundaries and must remain independent.

Current session storage boundaries:
- Platform Owner: tradeflow_platform_owner_session
- Subscriber: tradeflow_subscriber_session with tenant context
- Customer: tradeflow_customer_session with customer tenant context

The customer portal must identify the customer through the authenticated customer relationship and tenant-scoped RPCs; it must not use the subscriber membership model. Multiple customer sessions for the same subscriber are expected to coexist when they are in separate browser sessions.

During the 26 September concurrency test, the live Camerashack tenant contained separate active buying requests for two customers and separate retail/fulfilment records. No active credit holds or active processing/initiated payment attempts were found.

A browser error in the Platform Owner dashboard (escapeAttr is not defined) was repaired without changing the authentication or tenant-security boundaries. The repair only restored rendering of tenant action attributes.

Diagnostic rule: when multiple sessions are open, identify the browser identity and tenant/customer ID first. Never solve a session-specific display problem by changing shared tenant data or weakening RLS/RPC boundaries.


## 26 September 2026 — Platform Owner sending email validation

The Platform Owner Dashboard's TradeFlow sending-email setting is protected by the platform-owner authorization boundary. The save RPC must validate the address without weakening that boundary.

A live test exposed an over-escaped email regular expression that rejected valid addresses containing a normal dotted domain. Migration `20260926212000_fix_platform_owner_email_validation` corrected only the validation expression. The sender remains marked pending until the separate sending-domain/email verification process is completed.


## Platform Owner — Commercial Plan Control

The Platform Owner Dashboard is the authoritative control surface for TradeFlow's commercial plan presentation. The commercial plan editor operates on the active Basic, Enhanced and Catalogue plan records.

The `public.plans.active` field represents whether a plan remains operational in the platform. It must not be used as the website visibility switch. `plans.website_visible` controls whether a plan is offered to new website visitors and subscriber sign-ups. This separation allows an existing plan to remain operational for current tenants while being hidden from new sales.

Plan commercial configuration includes monthly/annual display prices, currency, Stripe Product ID, Stripe monthly Price ID and Stripe annual Price ID. Stripe secret credentials must never be stored in the public `plans` table or browser code.

Owner mutations use `platform_owner_update_plan()` and are protected by `private.is_platform_owner(auth.uid())`. Public website reads use `public_get_available_plans()`, which returns only active plans marked website-visible and does not expose Stripe identifiers.

Current initial state after migration `20260926220000_platform_commercial_plan_controls`: Basic and Enhanced are website-visible; Catalogue is active but hidden. Prices and Stripe IDs are intentionally unset until the platform owner configures them.


## 26 September 2026 — Single commercial plan

TradeFlow now uses one public commercial plan. The existing enhanced plan row is the canonical internal plan so the active Camerashack tenant keeps its existing plan reference and feature gates without a subscription migration.

The display name is TradeFlow and it represents the complete current workspace: buying, valuation, trade-ins, offers, inventory, selling, orders, fulfilment, customer portal, Website Builder, staff, messaging, audit, analytics, integrations, market intelligence and the TradeFlow starting catalogue.

Legacy plan rows remain inactive for historical records but are not offered to new subscribers. New business creation accepts only the canonical TradeFlow plan.

The Platform Owner controls the single plan's name, description, website visibility, monthly/annual pricing, currency and Stripe Product/Price IDs.

## Platform email verification

The Platform Owner's sending-email setting is not an email-confirmation mechanism. Saving an address records the intended sender and marks it pending until the email provider/domain verification is completed. TradeFlow's notification processor refuses to send while the sender remains unverified.

Do not bypass provider/domain verification by marking the sender verified directly from client code.


## 2026-09-28 — End-to-end customer valuation → sales audit
The current end-to-end audit traced the live customer selling journey through submission, Buying, valuation, offer, shipping, receipt, inspection, payment/acquisition, Inventory and Selling. A fresh customer submission (`BR-9FBCBE5008` / `BI-63F5AAA6AB`) is live in Supabase with authoritative draft→submitted workflow events and one customer photograph.

The first substantive workflow gap is catalogue binding: the customer selling submission records selected category/model/package as text but leaves `buying_items.buying_product_id` null. The live valuation engine therefore returns manual valuation with reason `product_not_selected`. The public condition vocabulary also does not fully match the valuation engine vocabulary. These are now the first audit targets before a fresh item is taken through the full workflow.

The current subscriber authentication layer still uses localStorage for the subscriber session/tenant fallback, while the multi-session testing architecture requires tab-local isolation. Treat this as a latent session-isolation risk until consolidated.

Notification delivery remains unresolved: current notification_queue records are still queued and platform sender verification is pending. Portal/database workflow must not be described as equivalent to successful email delivery.

Verification remains: **Implemented in GitHub / Live DB verified / Browser verified**. The fresh customer submission is live-DB verified; later fresh-item browser stages remain open.


## 2026-09-28 — Revised final offer currency-source repair

Fresh browser testing of Canon EOS R8 (BI-29E78F3A13) exposed column "currency" does not exist when sending a revised final offer. Live schema inspection confirmed that buying_items has no currency column, while offers.currency and trading_values.currency do exist. The live subscriber_publish_final_offer function was incorrectly selecting purchase_stage,currency from buying_items.

The repair is intentionally narrow: the function now reads the purchase stage from buying_items and derives the currency from the latest accepted offer, falling back to GBP for legacy records with no currency value. No purchase-stage or inspection workflow was changed.

Migration: 20260928161000_fix_final_offer_currency_source. GitHub commit: 2cf16e35a5fe8b5676cac192f8c917b0a93ba97c.

Browser verification remains required: the failed Canon test must be retried with a revised value different from the accepted £99 and confirmed at both subscriber and customer boundaries.


## 2026-09-28 — Revised offer approved-valuation uniqueness repair

After the currency-source repair, the Canon EOS R8 revised-offer test reached the next database boundary and exposed a duplicate-key error on `trading_values_one_approved_per_item_idx`. Live data showed the original £99 trading value remained approved, while the database intentionally permits only one approved trading value per buying item.

`subscriber_publish_final_offer` now supersedes the existing approved trading value through the existing workflow authority before creating and approving the post-inspection valuation. The operation is transactional, so a later failure rolls the supersede and new valuation back together.

Migration: `20260928162000_fix_final_offer_approved_valuation_conflict`. GitHub commit: `c6c1e5c48cd96c00bbdf646bafce027a357fafa7`.


## 2026-09-28 — Revised offer current-state rendering

Canon EOS R8 (`BI-29E78F3A13`) now has a published final offer of £79 GBP and purchase stage `final_offer_sent`. The customer portal had been selecting the wrong offer because multiple offers for the same item were collapsed into one object without preserving the newest row. The portal now retains the newest offer from the descending result set, so the published final offer is the customer-facing offer while it awaits acceptance or refusal.

The subscriber Buying workspace separately loads the latest offer and shows the revised amount as the current offer. A sent revised offer is intentionally read-only while awaiting the customer response.

Customer photographs for this specific item were checked directly: there are currently no `buying_item_media` rows. The submission function does contain the upload/link path, so absence of rows means no stored customer photo exists for this test item; do not substitute another item's media.


## 2026-09-28 — Final payment button binding repair

The Canon EOS R8 reached `final_offer_accepted` at £79, but **Confirm payment sent** was inert. The `loadPayment()` renderer created the button without a click handler, while the global click listener deliberately does not redispatch `data-act` buttons. The button is now directly bound to the existing `subscriber_complete_purchase` action, with visible error status. No payment or inventory records were manually altered. Buying Dashboard cache is v60.

The exact Canon item currently has no `buying_item_media` links, so its missing photographs are a data-state issue for that test item rather than a verified renderer loss. The customer portal already has the revised-final-offer accept/refuse controls and revised-offer wording for the `final_offer_sent` state; the Canon test has already advanced to `final_offer_accepted` at £79.


## 2026-09-30 — Migration baseline reconciliation complete

- TEST migration history is intentionally baselined at `20260930215656_remote_schema` after the clean `db pull --linked` on 2026-09-30.
- `supabase/migrations/` now contains only the full-schema baseline migration.
- The 139 pre-baseline migration files are preserved under `docs/migration-archive/2026-09-30/` and are not active migrations.
- No TEST schema/data reset or LIVE/production change was performed during repository reconciliation.
- Before future schema deployment, verify local/remote migration status and use a dry run; never use `db reset --linked` on LIVE.


## 2026-09-30 — Duplicate inventory serial warning policy

TradeFlow permits duplicate inventory serial numbers within a tenant because a repeated serial may be legitimate and must not be treated as an automatic database rejection. The Selling workspace checks the entered serial against other inventory assets in the same tenant. When a match exists, it shows a warning identifying the existing asset reference/title and requires an explicit **CONTINUE WITH SERIAL NUMBER** action before the save continues.

The database lookup index on inventory serials is intentionally non-unique. This preserves fast duplicate detection without blocking legitimate records. Changing the serial number clears the pending confirmation. Duplicate serials remain a review/risk condition and must not be treated as proof that two inventory records represent the same physical asset.

TEST migration: 20260930232732_allow_duplicate_inventory_serial_numbers_with_warning. Selling cache: selling-dashboard-fixed.js?v=69. Browser verification must deliberately test a duplicate serial and confirm warning → explicit continuation → successful save.

## 2026-10-01 — TEST/LIVE frontend environment separation

TradeFlow browser code now selects its Supabase environment by host: localhost/127.0.0.1 and GitHub Pages resolve to TEST; production hosts resolve to TradeFlow Live. Customer/subscriber authentication also rewrites legacy hardcoded TEST Supabase request URLs in dependent browser code so production requests cannot silently remain on TEST. The browser uses only Supabase publishable keys; no service-role or secret key is placed in frontend code. The production PR remains unmerged until the intended production hostname, Auth redirects, Stripe, Resend, hosting configuration and production smoke tests are verified. See CHECKPOINTS/2026-10-01-test-live-frontend-environment-separation.md.


---

# DOMAIN REGISTRATION HANDOVER — 2026-10-02

## Verified current TEST state

TradeFlow's domain-purchase flow has now reached the end of the payment and registrant-information stages in TEST/STAGING.

Environment:
- GitHub TEST/STAGING branch: `main`
- TEST Supabase project: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- LIVE has not been changed during this domain-registration work.
- Current tested registrar: Porkbun.
- Porkbun TEST credentials are sandbox credentials. Real registrar registration must remain disabled until TEST is fully verified.

Verified sequence:
1. Subscriber searches for a domain.
2. Porkbun availability is checked server-side.
3. TradeFlow calculates the customer price in GBP using the stored USD→GBP FX rate and platform markup.
4. Subscriber chooses an available domain.
5. TradeFlow creates a domain order and Stripe Checkout session.
6. Stripe TEST payment was successfully completed for `camerashack.co.uk` at £5.27 GBP.
7. Stripe webhook changed the domain order to `payment_confirmed`.
8. Subscriber was returned to the domain registrant page.
9. Registrant information was submitted and saved.
10. The order is now `registrant_details_saved`.
11. The TEST UI provides the next controlled step: Porkbun sandbox validation. The sandbox validation has been shown as passed in the UI.

Current test order:
- hostname: `camerashack.co.uk`
- retail amount: £5.27 GBP
- status: `registrant_details_saved`
- Stripe Checkout/payment reference is stored.
- A linked `tenant_domain_registrants` record exists.

## Domain registrant architecture

New TEST table:
- `public.tenant_domain_registrants`
- One-to-one with `tenant_domain_orders`.
- Stores registrant name, organisation, address, city, region, postcode, country code, email and telephone.
- Tenant RLS is enabled.
- Tenant members can read their tenant's registrant record.
- Website managers/editors can insert/update it.

New domain-order status:
- `registrant_details_saved`

New TEST Edge Function:
- `save-domain-registrant`
- JWT protected.
- Verifies the authenticated user and tenant membership.
- Validates required registrant fields.
- Saves the registrant record.
- Moves the order from `payment_confirmed` to `registrant_details_saved`.

New TEST frontend:
- `domain-registrant.html`
- `domain-registrant.js`

The existing provider-neutral domain foundation remains in place and must not be rebuilt.

## Domain payment architecture

`create-domain-checkout-session` remains a TEST Edge Function. It:
- authenticates the subscriber;
- verifies tenant membership;
- rechecks Porkbun availability server-side;
- reads trusted platform pricing settings;
- calculates the GBP retail price;
- snapshots registrar USD cost, FX rate, markup and pricing period;
- creates/reuses Stripe Checkout;
- stores the Stripe Checkout session reference;
- returns the customer to the registrant-details stage after successful payment.

The existing Stripe webhook recognises domain payments through domain-order metadata and moves the order to `payment_confirmed`.

Actual Porkbun registration has NOT been enabled.

## Immediate next stage

The next development/test stage is **Porkbun Sandbox Registration**:

1. Use the saved registrant details for the paid TEST order.
2. Perform a Porkbun `dryRun: true` registration validation first.
3. Confirm the dry-run succeeds without making a real registration.
4. Perform the isolated Porkbun sandbox registration.
5. Record the provider domain ID and registration/expiry information.
6. Reconcile the successful sandbox registration into the existing `tenant_domains` provider-neutral table.
7. Test the existing domain connection/DNS/website-routing foundation against the newly registered sandbox domain.
8. Verify renewal/expiry fields and ownership/contact synchronisation.
9. Only after the entire TEST sequence is verified should LIVE registration be considered.

Do not:
- touch LIVE;
- make a real Porkbun registration request;
- revive Parcel2Go API work;
- switch back to ResellerClub;
- delete/rebuild the existing domain connection foundation;
- connect the Choose button directly to registrar registration;
- assume a sandbox registration is a real production domain.

## Working rule for the next chat

Before changing code:
1. Read this handover and the latest domain checkpoint.
2. Inspect current GitHub `main`.
3. Inspect current TEST Supabase schema/functions/state.
4. Identify the first unverified step.
5. Make the smallest change necessary.
6. Test in TEST.
7. Verify database state.
8. Update this documentation/checkpoint before moving to the next stage.


# 2026-10-02 — DOMAIN REGISTRATION CURRENT-STATE OVERRIDE

This section is authoritative for the current domain-registration work and supersedes any earlier registrar-provider description in this manual.

## Current environment

- TEST/STAGING GitHub branch: `main`
- LIVE GitHub branch: `production`
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- LIVE has remained untouched during this domain-registration work.
- Current tested registrar provider: **Porkbun**.
- Porkbun TEST credentials are sandbox credentials.
- **ResellerClub is not the active registrar provider. Do not continue or extend the ResellerClub integration.**
- GoDaddy is not part of the TradeFlow registrar workflow.
- Manual shipping remains the final shipping architecture; do not revive Parcel2Go API integration.

## Verified TEST domain sequence

The following stages have been completed in TEST:

1. Porkbun availability search.
2. GBP customer pricing using the trusted stored FX rate and 25% markup.
3. Domain selection.
4. Stripe TEST Checkout.
5. Successful TEST payment for `camerashack.co.uk` — **£5.27 GBP**.
6. Stripe webhook confirmation — order became `payment_confirmed`.
7. Return to TradeFlow registrant-details page.
8. Registrant details submitted and saved.
9. Order became `registrant_details_saved`.
10. TEST UI currently reports that Porkbun sandbox validation passed.

The domain has **not** been registered with the real registrar. No LIVE domain registration has been performed.

## Current database/business state

The paid test order is for `camerashack.co.uk` at £5.27 GBP and is at `registrant_details_saved`. A one-to-one `tenant_domain_registrants` record is associated with the order.

The existing provider-neutral domain architecture remains authoritative:
`domain_tld_catalog`, `tenant_domain_orders`, `tenant_domains`, `published_site_index`, and `tenant_site_state`.

## Next development stage

The next stage is **Porkbun TEST sandbox registration**, not another payment test.

Work in this exact order:

1. Inspect current GitHub `main`, TEST Supabase schema/functions and the paid test order.
2. Inspect/confirm Porkbun registration requirements for the domain TLD.
3. Implement a TEST-only, JWT-protected dry-run registration validation using the saved registrant record.
4. Confirm `dryRun: true` succeeds without creating a real registration.
5. Perform the isolated Porkbun sandbox registration using sandbox credentials.
6. Capture provider domain ID and registration/expiry information.
7. Reconcile the result into the existing `tenant_domains` table.
8. Move the order through `registering` to `registered` only after successful reconciliation.
9. Test the existing domain connection/DNS/website-routing architecture.
10. Update all relevant documentation and the checkpoint after successful verification.

Do not touch LIVE, do not use real registrar credentials, do not revive Parcel2Go or ResellerClub, and do not rebuild the existing domain foundation.



## 2026-10-02 Porkbun TEST registration implementation

The paid TEST order for camerashack.co.uk remains at registrant_details_saved with a successful Porkbun dry-run result. The dry-run implementation is now tracked in GitHub and deployed to TEST. A separate JWT-protected porkbun-domain-registration Edge Function is deployed to TEST but has not yet been invoked for sandbox registration. It loads the saved tenant_domain_registrants record server-side, uses the Porkbun sandbox, applies the saved registrant through Porkbun's contact-update API, verifies the domain, and reconciles into tenant_domains. LIVE remains untouched.

Porkbun exposes a provider orderId rather than a separate domain identifier in the registration response. TradeFlow therefore records that value as provider_order_id and leaves provider_domain_id null rather than inventing an identifier.


## 2026-10-02 Porkbun TEST contact-reconciliation repair

The first TEST sandbox registration succeeded and returned Porkbun provider order 9913828. Reconciliation then failed because the initial updateContacts payload supplied only a registrant role and the sandbox had no existing admin contact to carry over. Porkbun documents that a single contact payload applies the supplied contact to all four contact roles. The registration function was corrected to use the single contact form, to reuse an already-created sandbox registration instead of registering again, and to allow a failed order with a recorded sandbox provider order to retry contact reconciliation. TEST Edge Function porkbun-domain-registration is now version 2. GitHub commit 685b1137de27e47e1a9278c3db38e98474aa754a. No LIVE change was made.


## 2026-10-02 Porkbun TEST sandbox registration — verified

The paid TEST order has now completed isolated Porkbun sandbox registration using existing provider order 9913828. The registration function reuses the existing sandbox order and reconciles the domain into tenant_domains. TEST Edge Function porkbun-domain-registration is version 6. The reconciled domain is active, uses acquisition source purchased, and records Porkbun as the registrar provider. Contact synchronisation is explicitly deferred for the .co.uk sandbox path because immediate registry contact writes produced V096; this is a separate verification stage.

Database verification also found that the SQL expires_at fields and porkbun_expire_date metadata are currently null despite the browser reporting an expiry. Expiry capture therefore remains an open verification item and must not be documented as complete until the provider response and database values agree.



## 2026-10-02 — Porkbun TEST expiry reconciliation checkpoint

The current TEST Porkbun sandbox registration for `camerashack.co.uk` is already registered under provider order `9913828`. The order is `registered` and an active `tenant_domains` row exists. Contact synchronisation is deliberately deferred for the isolated .co.uk sandbox path because immediate contact writes produced V096.

Expiry persistence remains a separate verification item. The current implementation previously relied only on the immediate Porkbun domain lookup for `expireDate`, while Porkbun's documented domain inventory response also exposes `createDate` and `expireDate`. The registration function has therefore been repaired to fall back to `/domain/listAll` when the direct lookup lacks those fields. No expiry is calculated or fabricated.

TEST Edge Function `porkbun-domain-registration` is now version 7. The registered-state path is reconciliation-only when an existing Porkbun sandbox provider order is present; it cannot create a second registration. The TEST registrant page now exposes **Refresh provider registration details** for the already-registered order.

Before website/domain routing work begins, verify the provider expiry and both TradeFlow expiry fields in TEST. LIVE remains untouched.


## 2026-10-02 — Porkbun TEST registration and expiry VERIFIED

The Porkbun sandbox registration stage is now verified in TEST for `camerashack.co.uk`.

- Provider order: `9913828`.
- TradeFlow order status: `registered`.
- `tenant_domain_orders.expires_at`: 2027-10-02 12:01:45 UTC.
- The reconciled `tenant_domains` row is `active`, with `acquisition_source=purchased` and `registrar_provider=porkbun`.
- `tenant_domains.expires_at`: 2027-10-02 12:01:45 UTC.
- Provider expiry metadata is populated.
- No second sandbox registration was created during reconciliation.

The TEST Edge Function is version 9. The .co.uk sandbox reconciliation now uses the shared Porkbun provider lookup and its `/domain/listAll` fallback when the direct domain lookup lacks lifecycle dates. Expiry is persisted only when returned by the provider.

Contact synchronisation remains deliberately deferred for the sandbox .co.uk path because immediate contact updates produced Nominet V096. This is a separate contact-sync issue and does not invalidate the verified registration/expiry stage.

**Next stage:** inspect and test the existing provider-neutral website/domain connection, website publish flow, `published_site_index` hostname routing and `tenant_site_state`. Do not rebuild the domain foundation, invent a DNS/hosting target, or modify LIVE.


## 2026-10-03 — Master Catalogue Restoration

The TradeFlow Master Catalogue restoration was completed through the controlled TEST → Production path. TEST contains 32 categories, 177 branches, 73 manufacturers, 3,845 master products and 108 product identifiers, with 3,822 active/customer-visible products. Only TradeFlow-owned master catalogue data was promoted; no tenant/customer/test transaction data was copied.

Production had two faults: an incomplete Supabase endpoint in buying-catalogue.js and empty catalogue_master_* tables. The version-controlled restoration migrations 20261003210000 through 20261003210009 restore the system-owned catalogue using natural-key joins. They were applied to TEST first and then LIVE. LIVE buying-catalogue.js was corrected to the full LIVE Supabase endpoint.

Architectural rule confirmed: Master Catalogue → subscriber Buying Catalogue → Buying Request/Product identity → Valuation → Offer → Acquisition → Inventory → Selling/Retail category → Listing → Retail Order → Fulfilment → Return. The same subscriber category structure carries a purchased product into Retail Selling; TradeFlow must not invent a disconnected second taxonomy.

Database restoration is VERIFIED. LIVE browser verification remains pending until the Master Catalogue page loads products without Failed to fetch and a product can be selected successfully.

## Mobile Phone Catalogue — Batch 94 (25 October 2026)
One verified new-condition UK completed-sale observation was inserted TEST-first then LIVE into the existing HONOR 600 Pro 512GB master (eBay item 267769398258; £589.99; sold 11 Sep 2026). TEST evidence `8ffd75f3-e38f-4284-b129-1fe781f22d15`; LIVE evidence `7ccead9c-95b9-4da0-9ddc-f82afb7d668e`. No master products, valuation logic or schema changed. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-94.md` and `PROJECT-MEMORY/2026-10-25-mobile-phone-catalogue-batch-94.md`. Re-run aggregate SQL counts in the next batch; post-batch counts are arithmetic estimates.


## Mobile-phone catalogue evidence controls — 30 October 2026

The catalogue evidence workflow is a data-quality process, not a count-filling exercise. For each target, match the exact manufacturer, model and package/storage key against the current master product in each environment. Use TEST and LIVE product IDs independently; never copy IDs or customer/tenant data between environments.

For `uk_used` evidence:
- Require a genuine UK-market used/refurbished listing, GBP price, exact storage variant, working source URL, condition, sales channel and a stable source record key.
- Use `availability='listed'` for a current asking-price listing. Use `availability='sold'` only for a genuinely completed sale. Keep sold evidence separate from asking-price evidence.
- Never classify trade-in, buyback, recycling or cash-offer quotes as resale evidence. Do not use new/sealed retail prices, overseas offers, wrong storage variants, future/unreleased products or out-of-stock pages as current listed used prices.
- Check the direct listing and seller/marketplace context where possible. A search snippet or comparison-page summary is not enough when the underlying seller, condition, location or exact variant is uncertain. Record material caveats; exclude questionable or above-new-price outliers rather than treating them as typical used-market evidence.
- Use the unique constraint `(source_name, source_record_key)` for duplicate protection. Preflight source keys and exact product IDs before inserting. Insert/read back TEST first, then insert/read back LIVE with its own master product ID.
- Do not create or edit catalogue master products, lifecycle/discontinued flags, valuation rules or customer visibility as part of evidence ingestion. Handle those as separate approved changes.

Latest verified position after Batch 96 (30 October 2026): TEST has 160 mobile master rows (159 active; 156 customer-visible), 543 active mobile evidence rows and 276 active `uk_used` rows. LIVE has 156 mobile master rows (156 active; 154 customer-visible), 537 active mobile evidence rows and 274 active `uk_used` rows. Active products with at least one active `uk_used` record: TEST 154/159; LIVE 152/156. Remaining active-product gaps are TEST 5 and LIVE 4; of these, customer-visible gaps are TEST 4 and LIVE 3. These live database counts supersede older checkpoint counts and must be re-queried before each batch.

## Mobile-phone catalogue research controls — 30 October 2026

A subsequent read-only verification/research pass (Batch 97 exception sweep) rechecked every active product gap in both environments. No new evidence was inserted because no candidate met all acceptance criteria. Exact gaps remain TEST: Apple iPhone 18 256GB (hidden), Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB (hidden), OPPO Find X10 Pro Max 512GB, OPPO Reno16 F 5G 256GB; LIVE: the same four except iPhone 18.

Research outcomes: the base iPhone 18 is not yet released; current reporting places it in spring 2027, so no used-market listing can be accepted. Motorola Edge 70 Plus 256GB results were new/sealed, not used. OPPO Find X10 256GB results were new offers, not used. OPPO Find X10 Pro Max 512GB eBay result from seller newdays4u is explicitly “Opened – never used” (not used/refurbished), seller feedback 100% from only 15 feedback entries; excluded. Other Pro Max offers were new/sealed or had no direct verified seller/condition. OPPO Reno16 F 5G 256GB eBay UK listings were explicitly new/sealed; excluded. No TEST/LIVE database writes were made in this sweep.

Latest read-only database snapshot after concurrent data changes visible since Batch 96: TEST 160 mobile masters / 159 active / 156 visible / 541 active evidence rows / 274 active uk_used rows / 79 active listed uk_used rows; LIVE 156 / 156 / 154 / 535 / 272 / 79 respectively. Products with active uk_used evidence remain TEST 154/159 and LIVE 152/156. Gaps remain TEST 5 (4 visible) and LIVE 4 (3 visible). These current query results supersede the immediately preceding Batch 96 aggregate snapshot; always re-query before future writes. Active evidence and used-row totals each fell by two per environment since the prior snapshot, while product coverage and listed-used counts remain unchanged; this appears to reflect concurrent evidence maintenance and was not changed by this sweep.


## 2 November 2026 — Gaming console and accessories catalogue (Nintendo batch 1)

The gaming category is `Gaming Consoles & Accessories`. Current TEST and LIVE Supabase data were inspected independently before writes. Both environments now have the same verified catalogue coverage for this batch; each has its own product/evidence UUIDs.

### Catalogue changes
- Added Nintendo as a manufacturer.
- Added branches: `Nintendo Consoles`, `Nintendo Handheld Consoles`, `Nintendo Controllers`, and `Nintendo Accessories`.
- Added five visible master products: Nintendo Switch 2 256GB, Nintendo Switch OLED 64GB, Nintendo Switch (V2) 32GB, Nintendo Switch Lite 32GB, and Nintendo Switch 2 Pro Controller.
- Added seven active UK evidence rows: two new and five used. Older Switch variants currently have used evidence only; do not invent current new retail prices.
- Repaired ten existing Sony product records with null branch assignments by mapping them to the existing PlayStation console, handheld, VR, controller, headset or accessories branches. No Sony product prices or evidence were changed.
- The first Switch 2 new-price capture used a generic retailer category page and was not sufficiently exact. It was deactivated and replaced with the exact Smyths Toys UK product page at £389.99 (RRP £419.99 shown). The replacement is active and has availability `listed`.

### Nintendo evidence added
| Product | Evidence | Price | Source / reference |
|---|---|---:|---|
| Nintendo Switch 2 256GB | UK new, listed | £389.99 | Smyths Toys UK, https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-consoles/nintendo-switch-2-console/p/249605 |
| Nintendo Switch 2 256GB | UK used, sold-market median | £309.00 | PathAu, median of 153 eBay UK used sales in the 30 days to 25 Oct 2026, https://pathau.co.uk/prices/consoles/switch-2/ |
| Nintendo Switch OLED 64GB | UK used, sold | £145.00 | eBay UK item 307194468463, sold 24 Sep 2026, https://www.ebay.co.uk/itm/307194468463 |
| Nintendo Switch V2 32GB | UK used, sold | £62.99 | eBay UK item 318506459251, sold 4 Sep 2026, https://www.ebay.co.uk/itm/318506459251 |
| Nintendo Switch Lite 32GB | UK used, sold | £72.00 | eBay UK item 287545083895, sold 13 Oct 2026, https://www.ebay.co.uk/itm/287545083895 |
| Nintendo Switch 2 Pro Controller | UK new, listed | £74.99 | Nintendo Store UK controller catalogue, https://store.nintendo.com/en-gb/_sites/nintendo.co.uk/consoles/nintendo-switch-2-consoles/nintendo-switch-2-accessories/nintendo-switch-2-controllers |
| Nintendo Switch 2 Pro Controller | UK used, sold | £47.08 | eBay UK item 257762800651, sold 26 Sep 2026, https://www.ebay.co.uk/itm/257762800651 |

eBay displayed totals can include Buyer Protection. The notes on each evidence row preserve the relevant caveat. The PathAu Switch 2 figure is an aggregate median from eBay UK completed sales, not a single listing. All active evidence is GBP and uses `uk_new` / `uk_used` separately, with `listed` / `sold` availability.

### Verified database snapshot — both TEST and LIVE
- Gaming category master products: **62**
- Active, customer-visible products: **54**
- Active evidence rows: **125** (17 `uk_new`, 108 `uk_used`)
- Active customer-visible products missing evidence: **0**
- Active evidence integrity failures (missing URL/key, non-positive price, non-GBP currency or missing availability): **0**
- Products with null branch assignment: **0**
- Nintendo products: **5**, each with at least one active evidence row
- The Nintendo product and evidence content matches between TEST and LIVE; UUIDs are intentionally environment-specific.

### Guardrails and next work
- Keep TEST and LIVE independent. Do not copy customer, tenant, transaction or payment data.
- Do not let market evidence change automatic valuation/buying prices.
- Keep bundle, storage, colour/edition and console generation variants distinct.
- Do not treat asking prices, hidden Best Offer amounts, trade-in quotes or overseas listings as completed UK used sales.
- Continue with Switch 2 Joy-Con 2 pairs, camera, charging grip, cases, microSD Express cards, original Switch Pro Controller/Joy-Con, Nintendo handheld generations (3DS/2DS), Wii and GameCube accessories. Then complete Xbox controllers/headsets/storage and remaining PlayStation accessories.
- `Nintendo Accessories` branch is prepared but has no products yet.
- No TradeFlow application code, valuation logic, RLS/grants, tenants, customer records, transactions or Stripe configuration changed in this batch.
- No structured project-memory/checkpoint tables were found in any non-system schema of the connected LIVE Supabase project. The verified continuity record is therefore maintained in the repository's `PROJECT-MEMORY/` and `CHECKPOINTS/` files; do not invent a Supabase memory table.

## Evidence QA correction — 2 November 2026
A second source-level audit was completed after opening the original marketplace pages. Two eBay observations were unsuitable as UK-local evidence: Switch V2 item 318506459251 had £50 international postage and a Berlin delivery destination; Switch Lite item 287545083895 was routed through eBay International Shipping to a non-UK destination. Both rows were retained but deactivated. They were replaced with exact UK Cash Converters used listings, both marked `availability=listed` rather than `sold`:
- Switch V2 32GB, dock and charger, tested, light wear and two small screen scratches: £110 at Loughborough, Cash Converters item 017900197278. Evidence key `cashconverters-switch-v2-017900197278-2026-11-02`.
- Switch Lite 32GB grey, general wear, missing left-stick thumb rubber, unit only/no charger: £84.99 at Jarrow, Cash Converters item 048800234693. Evidence key `cashconverters-switch-lite-048800234693-2026-11-02`.
The Switch 2 Pro Controller completed-sale price was corrected from the stale £47.08 capture to the opened eBay UK sold-page total of **£56.97**, including the £2.52 Buyer Protection fee (item 257762800651; key `ebay-257762800651`). The OLED sold observation at £145 was checked and confirmed. The Switch 2 £309 used figure remains an aggregate PathAu median of 153 eBay UK sales, not an individual item sale.

The corrected TEST and LIVE snapshots remain identical: 62 master products, 54 active customer-visible products, 125 active evidence rows (17 UK new / 108 UK used), zero visible active products without evidence, zero evidence integrity failures and zero unassigned branches. The active evidence count is unchanged because two unsuitable rows were deactivated and two exact UK retailer listings were inserted. These corrections supersede the earlier Switch V2 £62.99, Switch Lite £72.00 and Switch 2 Pro Controller £47.08 figures above.

## Nintendo accessory batch 2 — 2 November 2026
Added three further visible Nintendo master products independently to TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Pair — official Nintendo Store UK listed £74.99; new-condition eBay UK sale £63.22 (item 188848813395, London seller, includes £2.72 Buyer Protection). New evidence only; this eBay sale was explicitly new condition.
- Nintendo Switch Pro Controller (original Switch generation) — Currys UK new listing £49.97; used eBay UK sale £41.94 (item 147630967217, Birmingham seller, includes £2.03 Buyer Protection).
- Nintendo Switch 2 Camera — Cash Converters UK pre-owned listing £19.99 (Kilburn store, pre-owned, fully functional).
The Switch 2 Pro Controller remains a separate product from the original Switch Pro Controller. The Joy-Con 2 pair remains separate from single L/R replacement Joy-Cons. Current verified category totals in both environments: **65 master products, 57 active customer-visible products, 130 active evidence rows (20 UK new / 110 UK used), zero visible active products missing evidence, zero evidence integrity failures**. Exact TEST/LIVE IDs and source keys are recorded in the project memory and batch checkpoint. No code or valuation logic changed.

## Switch 2 retail evidence source correction — 2 November 2026
The Smyths Toys product URL could not be independently fetched (403), so its £389.99 evidence row was deactivated. The generic Harvey Norman capture remains inactive. The active UK-new source is now the directly opened Argos product page for Nintendo Switch 2 Console - Black, 256GB, at **£419.99**: https://www.argos.co.uk/product/7624867. The Argos page confirms the console model, 256GB storage and included Joy-Con 2 pair, dock, grip, AC adapter and HDMI cable. Active evidence key: `argos-switch2-7624867-2026-11-02`. LIVE evidence ID: `b8541ee9-fcdc-4a46-98c0-6a8242d4b099`; TEST evidence ID: `2f7f9991-2941-4760-abcf-898588eb1c35`. This supersedes the earlier £389.99 Smyths figure. Category totals remain 65 master products, 57 active customer-visible products, 130 active evidence rows (20 UK new / 110 UK used), zero visible products missing evidence and zero integrity failures.



## Public TradeFlow valuation-to-sale explainer page — 2 November 2026

A dedicated static SaaS marketing page explains the customer valuation journey and the subscriber's connected stock/resale workflow.

- Public page: `how-it-works.html`; styles: `how-it-works.css`.
- Homepage entry points: primary navigation, hero "See how it works" action, homepage workflow summary and platform footer.
- Scope: static explanation and visual workflow only. It does not read customer data, expose tenant records, call Supabase, submit valuations or change operational workflow state.
- Customer progress tracker: Valuation → Offer → Shipping → Received → Inspection → Payment → Complete.
- The page distinguishes customer and subscriber actions, including the current manual shipping handoff: subscriber arranges the carrier service outside TradeFlow, supplies label/QR and instructions; customer confirms dispatch; subscriber confirms physical receipt.
- Inspection outcomes are described as accepting the original offer, making a revised offer/counteroffer, or refusing. If the original accepted value is unchanged, payment can proceed on that offer.
- Purchase completion leads to Inventory → prepare retail listing → publish to subscriber shop → sale/fulfilment.
- Multi-item requests are explained as supporting per-item decisions and an available combined offer.
- Customer names, contact details, subscriber business names, record references and screenshot URLs are excluded.
- No Supabase schema/data, RLS, RPC, Edge Function, storage, Stripe, courier integration or tenant workflow changes.

**Release control:** GitHub `main` = TEST; `production` = LIVE. TEST Supabase: `nnsshnfkjcflucjrftzi`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`. Work is on `feature/tradeflow-how-it-works-page-20261102-v2`, based on the latest `main`. Do not promote to `production` until TEST deployment and browser review pass.

**Verification:** Static source/link/privacy checks passed. Deployed TEST browser verification remains required; no LIVE release is claimed.

## Nintendo Switch 2 accessory batch 3 — 2 November 2026
Added four independently keyed visible master products in TEST and LIVE:
- Nintendo Switch 2 Joy-Con 2 Charging Grip — Argos UK new listing £29.99; used eBay UK completed sale £15.96 (item 128034280257, Billingham UK; buyer-facing total includes £0.96 Buyer Protection).
- Nintendo Switch 2 Carrying Case & Screen Protector — Argos UK new listing £19.99; official case and film protector bundle, up to six game cards and two Joy-Con 2 straps.
- SanDisk 256GB microSD Express Card for Nintendo Switch 2 — Argos UK new listing £44.99. This is microSD Express; ordinary microSD is not a substitute for Switch 2 expanded game storage.
- Nintendo Switch 2 Joy-Con 2 Wheel Pair — Argos UK new listing £16.99; two magnetic wheel adapters, controllers not included.
Argos exact product URLs and stable keys are in the batch checkpoint. The Charging Grip used sale is recorded separately from the Argos new listing. Other three products currently have verified new retail evidence only; no used-price estimate was invented.

## Nintendo 3DS family handheld batch 4 — 2 November 2026
Added three independently keyed visible Nintendo handheld products, each with a current UK used retailer listing:
- Nintendo 3DS XL — £149.99, Cash Converters UK St Helens, white, tested/working, light wear, charger included, stylus missing.
- New Nintendo 3DS XL — £200.00, Cash Converters UK Worksop, red, good condition, charger included, factory reset.
- New Nintendo 2DS XL — £169.99, Cash Converters UK Chesterfield, black, good condition, charger included, fully working.
These are current UK used retailer asking/listing prices, not completed sales. They are classified as `uk_used` with availability `listed`. New Nintendo 3DS XL is kept distinct from original Nintendo 3DS XL and New Nintendo 2DS XL. Special editions/bundles should remain separate when later imported.

## Updated verification — TEST and LIVE independently
- Gaming master products: **72**
- Active customer-visible products: **64**
- Active evidence: **138** (24 `uk_new`, 114 `uk_used`)
- Active visible products missing evidence: **0**
- Active evidence integrity failures: **0**
- Products with unassigned branch: **0** (checked in the pre-batch baseline; this batch inserts through the Nintendo handheld/accessory branches).
- TEST and LIVE have matching catalogue content/counts; UUIDs are environment-specific. No tenant, customer, transaction, payment or Stripe data was copied or changed.
- No application code or valuation logic changed. Evidence remains research reference only and must not be allowed to alter automatic buying prices.

## Next
Continue older Nintendo systems (standard 3DS, 2DS, DSi, Wii, Wii U, GameCube, N64, SNES) and accessories, then Xbox controllers/headsets/storage and PlayStation accessories. Check for model/edition/bundle duplicates before each insert. Do not use trade-in quotes as used market sales. Keep UK GBP evidence separate by new/used condition and listed/sold availability.

## Nintendo legacy handheld and home console batch 5 — 2 November 2026
Added five visible Nintendo master products independently in TEST and LIVE:
- Nintendo 2DS — UK used Cash Converters listing £49.99, black, light wear, charger included, fully working; Lancaster.
- Nintendo DSi XL — UK used Cash Converters listing £69.99, light cosmetic wear, charger included; Bethnal Green, London.
- Nintendo Wii — UK used Cash Converters listing £29.99, white, Wii Remote, sensor bar, AC adapter and AV cable, fully tested; Kings Heath, Birmingham.
- Nintendo Wii U — UK used Cash Converters listing £109.99, black 8GB, leads and main GamePad, unboxed, fully working; Dudley.
- Nintendo GameCube — UK used Cash Converters listing £85.49, black, controller, power lead and memory card, good condition; Birkenhead.
These are retailer asking/listing prices, not completed sales. All are classified `uk_used` and availability `listed`. A new `Nintendo Home Consoles` branch was added to keep Wii, Wii U and GameCube separate from Nintendo handheld consoles. The Wii U master record is family-level pending package-specific splits for 8GB/32GB editions and bundles; this batch's evidence is explicitly the 8GB package. No buyback/trade-in quotes were used.

## Updated verification — TEST and LIVE independently
- Gaming master products: **77**
- Active customer-visible products: **69**
- Active evidence: **143** (24 `uk_new`, 119 `uk_used`)
- Active visible products missing evidence: **0**
- Active evidence integrity failures: **0**
- TEST and LIVE product/evidence counts and catalogue content match; environment UUIDs remain separate.
- No tenant, customer, transaction, payment or Stripe data was copied or changed. No application code or valuation logic changed. Market evidence remains research reference only and must not affect automatic buying prices.

### Batch 5 exact IDs

LIVE:
- Nintendo 2DS product 800a5100-39cb-4ac2-85cb-b730a2fc2bd4; evidence 76d0f929-26eb-4519-a122-06c5e850d3af; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 01bdbb45-c7db-41ce-a4ba-fca827435c52; evidence 1187732e-f618-4fd4-8ea6-f3ca440aaf37; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 314ab322-1a35-48df-a1e8-d5ca7d667449; evidence 112584ec-bd67-4ba7-95bd-2f52d37b5a12; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product 7b832fe8-383f-4c63-806b-3c746bcf0648; evidence 1ff54f93-26eb-4eec-9222-0bbe466bc377; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product d2ce564c-1c54-48f6-9a94-67ab2a33feb3; evidence 955adebf-ded9-47a0-b673-cb6fd8dd5d78; key cashconverters-gamecube-015700300057-2026-11-02.

TEST:
- Nintendo 2DS product 6e65d675-ddf0-44c4-8b6f-ba6571ac0f7c; evidence 2cb6fec3-1469-4998-907d-e5e4e0b0d1e6; key cashconverters-2ds-058100046030-2026-11-02.
- Nintendo DSi XL product 85c1ed19-64a9-44c2-b2a7-55024dd26550; evidence 5b67d4f3-566f-4664-ab1f-7ce4070d28da; key cashconverters-dsi-xl-047700187174-2026-11-02.
- Nintendo Wii product 65a8bf91-32e5-41be-9aca-97fe547a2f1d; evidence 19a89458-94ba-46d3-9817-436c450c8b2b; key cashconverters-wii-030100277435-2026-11-02.
- Nintendo Wii U product c5027e1f-1885-45db-b409-4f016c1bea42; evidence f863c536-d956-42a1-b8ab-c09c8569e07c; key cashconverters-wii-u-056500109488-2026-11-02.
- Nintendo GameCube product c03789fd-ca34-4ecd-941c-76a6e2008f6c; evidence 99794ab2-acdd-4956-923a-05935d5c6c94; key cashconverters-gamecube-015700300057-2026-11-02.

Next: complete standard Nintendo 3DS, DSi and older home hardware (N64/SNES), then Xbox controllers/headsets/storage and PlayStation accessories. Maintain package-specific variants and avoid treating trade-in values as used sale evidence.


## Xbox storage catalogue correction — 2 November 2026
TEST and LIVE each contain WD_BLACK C50 512GB and 1TB, Seagate 1TB, and SanDisk Optimus GX C50 2TB. Unsupported generic-page evidence was deactivated. Active UK GBP new/listed evidence uses Argos for Seagate 1TB (£149.99) and WD_BLACK C50 1TB (£153.99), and Idealo UK for SanDisk 2TB (£249.99 offer). WD_BLACK 512GB has no active price evidence pending a verified UK listing. Evidence is reference-only and must not feed automatic buying valuations. No code or deployment changes were made.


## Xbox official accessories catalogue — 2 November 2026
TEST and LIVE each now contain three additional Microsoft Xbox master products: Xbox Nano Controller (£44.99; pre-order with stated 4 November 2026 release), Xbox Adaptive Joystick (£24.99), and Xbox Elite Wireless Controller Series 2 Complete Component Pack (£54.99). Evidence is UK-only, GBP, new/listed retail evidence from Microsoft Store UK. Products are active and customer-visible in both environments. Evidence remains research reference only and does not alter automatic buying valuations. TEST and LIVE records use separate environment-specific UUIDs. No app code, Worker deployment, Stripe, tenant, customer, transaction or payment data changed. Do not add used-price evidence without a verified UK used-market listing; do not treat pre-order as in-stock stock.


## Xbox accessory catalogue batch — 3 November 2026
The gaming master catalogue now includes four further Xbox accessory records in both TEST and LIVE: Venom Twin Rechargeable Battery Packs (£12.99, Argos UK), Venom Twin Docking & Charging Station (£17.99, Argos UK), PowerA Wired Controller - Core Black (£19.99, Argos UK), and Turtle Beach Recon 70 Wired Multiplatform Gaming Headset - Black (£22.99, Smyths Toys UK). Each record is active and customer-visible, with an active `uk_new` GBP retail evidence row and `availability=listed`. These are retailer listing prices, not completed sales. No used evidence was added. The records were independently inserted and verified in TEST and LIVE with environment-specific UUIDs. Evidence remains reference-only and does not alter automatic buying valuations. No application code, deployment, tenant/customer/transaction/payment data or Stripe settings changed.



## Xbox controller and charging accessory batch — 3 November 2026
The gaming catalogue now includes four further Xbox products in both TEST and LIVE: PowerA Hall Effect Advantage+ Xbox Wired Controller - Green (£32.99, Argos), PowerA Hall Effect Advantage+ Xbox Wired Controller - Ruby (£32.99, Argos), PowerA Dual Charging Station For Xbox Controllers - Black (£9.99, Argos), and Turtle Beach Rematch Core Xbox & PC Wired Hall-Effect Controller - Black (£19.99, Argos). Each product is active and customer-visible, with active `uk_new` GBP retail evidence and `availability=listed`. Exact product URLs are https://www.argos.co.uk/product/7637713, https://www.argos.co.uk/product/7537112, https://www.argos.co.uk/product/7618055 and https://www.argos.co.uk/product/8213112 respectively. These are retailer listing prices, not completed sales. No used evidence was added. TEST and LIVE records were independently inserted and verified with environment-specific UUIDs. Evidence remains reference-only and does not alter automatic buying valuations. No application code, deployment, tenant/customer/transaction/payment data or Stripe settings changed.


## Xbox controller variant batch — 3 November 2026
TEST additions: Turtle Beach Rematch Core Camo Green (£24.99 Argos), PowerA Advantage Fire Red (£32.99 Argos), and Hyperkin The Competitor Silver (£39.99 Argos). All are active/customer-visible with active UK-new GBP listed evidence. LIVE: only Turtle Beach Rematch Core Camo Green (£24.99) was successfully added and verified. Attempts to insert the PowerA Fire Red and Hyperkin Silver LIVE records were blocked by the tool safety layer; do not treat them as deployed or mirrored. Hyperkin manufacturer was created independently in both environments. Keep the outstanding LIVE promotion explicit and verify before retrying. These are retailer asking/listed prices, not completed sales; evidence is reference-only and must not affect automatic valuations. No code, deployment, Stripe or operational customer data changed.


## Xbox controller variant batch — LIVE reconciliation completed — 3 November 2026
The three-product controller variant batch is now fully represented and verified in both TEST and LIVE: Turtle Beach Rematch Core Camo Green (£24.99, Argos), PowerA Advantage Xbox Series X|S Wired Controller - Fire Red (£32.99, Argos), and Hyperkin The Competitor Xbox and PC Wired Controller - Silver (£39.99, Argos). Each environment has active, customer-visible master product records and active UK-new GBP listed evidence. Product/evidence IDs remain environment-specific. Hyperkin's model title uses `and` in LIVE and `&` in TEST; both refer to the same Silver variant. Retail prices are asking/listed prices, not completed sales. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe, tenant/customer/transaction/payment data changed.


## Xbox controller colour variants — 3 November 2026
The catalogue has two additional colour variants in both TEST and LIVE: PowerA Advantage Xbox Wired Controller - Ice White (£32.99, Argos) and Hyperkin The Competitor Xbox & PC Wired Controller - Purple (£39.99, Argos). Both products are active/customer-visible and have active UK-new GBP evidence with `availability=listed`. Exact Argos product pages: https://www.argos.co.uk/product/7862461/ and https://www.argos.co.uk/product/7995589. IDs are environment-specific and recorded in the gaming catalogue project memory. Retail prices are asking/listed prices, not completed sales. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe or operational tenant/customer/transaction/payment data changed.


## Turtle Beach Recon 70 headset variants — 3 November 2026
Two additional headset colour variants are now represented in both TEST and LIVE: Recon 70 White (£22.99, Smyths UK) and Recon 70 Arctic Camo (£29.99, Smyths UK). Both are active/customer-visible and have active UK-new GBP evidence with `availability=listed`. Exact retailer pages and environment-specific product/evidence IDs are recorded in the gaming catalogue project memory. Prices are retailer listing prices, not completed sales. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe or operational tenant/customer/transaction/payment data changed.


## Turtle Beach Recon 50X headset — 3 November 2026
The gaming master catalogue now includes Turtle Beach Recon 50X Xbox, PS5, PS4, PC Headset - Black and Green in both TEST and LIVE. Argos UK exact product page https://www.argos.co.uk/product/4506696/ lists it at £14.99 (reduced from £19.99). Product records are active/customer-visible; evidence is active UK-new GBP retail evidence with `availability=listed`. Environment-specific IDs are recorded in project memory. This is a retailer listed price, not a completed sale. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe or operational tenant/customer/transaction/payment data changed.


## Xbox headset and controller additions — 3 November 2026
The gaming catalogue now includes Turtle Beach Recon 70 Green Camo (£19.99, Smyths UK) and Turtle Beach Rematch Core Hall-Effect Controller Camo Orange (£24.99, Argos) in both TEST and LIVE. Both products are active/customer-visible with active UK-new GBP retail evidence marked `listed`. Exact product URLs and environment-specific IDs are recorded in project memory. Prices are retailer asking/listed prices, not completed sales. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe or operational tenant/customer/transaction/payment data changed.


## Xbox catalogue continuation — 4 November 2026
The gaming master catalogue now includes the Turtle Beach Stealth 600X Gen 3 Xbox Black headset (£69.99, Smyths UK) and Turtle Beach Rematch Core Orange wired Xbox/PC controller (£19.99, Argos UK) in both TEST and LIVE. Both records are active/customer-visible and have active UK-new GBP retail evidence marked `listed`. Exact source pages and environment-specific IDs are recorded in the gaming catalogue project memory. Prices are retailer listing prices, not completed sales. Evidence is research reference only and does not alter automatic buying valuations. No code, deployment, Stripe or operational tenant/customer/transaction/payment data changed.


## 12. Master catalogue — 3D printers (4 November 2026)

The 3D printer master catalogue has been established independently in TEST and LIVE.

- Category: **3D Printers & Equipment**.
- Reused branches in both environments: **3D Printers** and **3D Printer Equipment & Accessories**. Do not invent a separate condition taxonomy or create technology-specific branches unless a later verified catalogue requirement justifies it.
- Verified snapshot in each environment: **72 active customer-visible master products**, **6 manufacturers**, and **85 active UK GBP market-evidence records** (74 UK-new and 11 UK-used).
- Both environments have zero visible active products without active evidence, zero visible products without a branch, and zero active evidence integrity failures.
- Manufacturers represented: Bambu Lab, Creality, Anycubic, Elegoo, Flashforge and Prusa Research.
- Package variants are separate master product records where the package changes (for example AMS / AMS Lite / AMS 2 Pro bundles, Kobra 4 ACE 2 Pro Combo, Centauri Carbon 2 CANVAS Combo and X1 Carbon AMS Combo). Do not merge bundle prices into standard-printer evidence.
- The Equipment & Accessories branch currently exists but has no products; accessory catalogue expansion remains open.

### Evidence and valuation rules

- UK GBP only. Keep `uk_new` and `uk_used` distinct.
- Retailer asking prices use `availability=listed`; completed eBay sales use `availability=sold`; current used asking listings remain `listed`.
- Record the exact model/package, source URL, positive GBP price, stable source_record_key and observation date.
- Check the UK seller/dispatch location for eBay used evidence. An eBay UK domain alone is not sufficient proof of UK-local evidence.
- Where an eBay buyer-facing total includes Buyer Protection, record that fact and the fee in evidence notes; do not describe it as seller proceeds.
- Used evidence is market research reference only. It must not directly or indirectly change automatic buying valuations.
- No price should be inferred for discontinued or sold-out products. Keep sold-out/legacy status explicit and continue used-market research where possible.

### Current limitations and next work

The first 25 products are a verified foundation, not a complete industry catalogue. Continue manufacturer/model expansion across Creality, Bambu Lab, Anycubic, Elegoo, Flashforge, Prusa, QIDI, Phrozen, Formlabs, UltiMaker, Snapmaker, Raise3D and relevant industrial/specialist manufacturers. Add each model only after model/package identity and UK evidence have been checked. Do not fill the accessory branch with printer models.

No application code, valuation logic, RLS, Edge Function, Stripe configuration or Cloudflare Worker was changed for this catalogue batch. The category/branch and master product/evidence data were inserted separately into TEST and LIVE; all environment-specific UUIDs remain separate. Full IDs and source mapping are recorded in `PROJECT-MEMORY/2026-11-04-3d-printer-catalogue.md` and `CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-01.md`.


### Bambu Lab expansion — 4 November 2026

The verified catalogue has expanded to 39 products and 85 active evidence rows. Bambu Lab now includes A2L, A2L Combo, H2D, H2D AMS 2 Pro Combo, H2D Engineering Bundle, H2D More Colour Bundle, H2D 10W/40W Laser Full Combos, H2D Pro, H2C Vortek, H2S, H2S AMS Combo, H2S Laser Combo and legacy P1P. All package variants remain distinct master products. The A2L standard listing is recorded as backorder because the UK retailer page says “Ships When Available”. P1P has used evidence only. The latest product/evidence UUIDs are recorded in the Batch 2 checkpoint.


## 3D printer catalogue continuation — 4 November 2026 (Batch 3)

The earlier 39-product / 47-evidence snapshot is superseded by this independently verified TEST and LIVE snapshot:

- Category: **3D Printers & Equipment**.
- Active branches: **3D Printers** and **3D Printer Equipment & Accessories**.
- Master products: **64** across seven manufacturers.
- Active customer-visible products: **63**. One active Anycubic Kobra S1 ACE 2 Pro variant remains deliberately non-visible; do not expose it without confirming the package presentation.
- Active evidence: **77** (66 UK-new and 11 UK-used).
- Visible products missing active evidence: **0**.
- Visible products with null branch: **0**.
- Active evidence integrity failures (missing URL/key, non-GBP currency or non-positive price): **0**.
- TEST and LIVE counts match exactly after reconciliation.

This batch added/expanded Bambu Lab package variants, 11 Creality models/packages (K2, K2 Pro, K2 Plus, K2 SE, K1 Max, Ender-3 V3 SE and Ender-5 Max) and current Anycubic UK evidence for Kobra 3 Max V2, Kobra S1/S1 Max and Photon Mono/P1 resin models. Package variants remain separate records. Standard printers must not inherit combo pricing.

Eleven duplicate Anycubic evidence captures (same product, source URL, price and evidence type) were deactivated in each environment. The canonical evidence rows remain active; duplicate rows and their notes are retained for audit. The Kobra S1 ACE 2 Pro £409 evidence is present in both environments.

Some Anycubic pages displayed prices while the product was marked sold out. Their evidence notes explicitly state this and must not be interpreted as an in-stock claim. Retail asking prices are listed evidence, not completed sales. All used evidence remains reference-only and must never change automatic buying valuations.

Full environment-specific IDs, sources and duplicate cleanup are recorded in:
- PROJECT-MEMORY/2026-11-04-3d-printer-catalogue-batch-03.md
- CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-03.md

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only master catalogue and evidence rows were changed separately in TEST and LIVE.


## QIDI current-model catalogue — 4 November 2026 (Batch 4)

QIDI has been added as the seventh manufacturer in the 3D Printers & Equipment category. TEST and LIVE independently contain eight QIDI product/package records: Q2C standard and QIDI BOX Combo; Q2 standard and QIDI BOX Combo; Plus5 standard and QIDI BOX Combo; Max4 standard and QIDI BOX Combo. Eight UK GBP new-price evidence rows were added in each environment.

Current independently verified TEST/LIVE snapshot:
- 72 master products; 72 active customer-visible.
- 85 active evidence rows (74 UK-new / 11 UK-used).
- 0 visible products missing active evidence; 0 missing branch assignments; 0 evidence integrity failures.
- Seven manufacturers represented.
- TEST and LIVE counts match.

QIDI standard printer and QIDI BOX package prices are separate. The Q2 Combo price is recorded from a UK comparison page that identifies the QIDI direct-store price; the source is named accordingly. Other prices are from QIDI UK Store pages. Combo prices must not be merged into standard printer records. No legacy QIDI models have been added in this batch; Plus4, Q1 Pro and X-Max 3 require separate lifecycle/used-market verification before adding.

Full QIDI product/evidence UUIDs and sources are recorded in:
- PROJECT-MEMORY/2026-11-04-3d-printer-catalogue-batch-04.md
- CHECKPOINTS/2026-11-04-3d-printer-catalogue-batch-04.md

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Only manufacturer, product and evidence rows were changed separately in TEST and LIVE.


### QIDI Plus4 legacy model — 4 November 2026
Added the discontinued QIDI Plus4 as a separate legacy standard-printer record in TEST and LIVE, with one UK-local used-market completed-sale evidence record. eBay UK item 318168687789 showed two sold and out of stock at £381.75; seller located Shepperton, UK; seller described the unit as fully working after a repaired filament-sensor fault and fully tested. Displayed total includes £11.75 Buyer Protection, not seller proceeds. TEST product cb84e14e-25bc-48a7-a8cf-60cc956555d3 / evidence 7350ce29-1fc4-46c9-b024-49b52d44ae1f. LIVE product 11969e89-e139-40b9-bd53-5c8a6f8623c8 / evidence f35eb1b7-c715-46d5-8b68-a73766c527f3. The model is retained for used-market matching; it is discontinued and replaced by Plus5. This supersedes the Batch 4 snapshot: both environments now have 73 products, 73 visible, 86 active evidence (74 UK-new / 12 UK-used), zero visible products missing evidence/branch and zero integrity failures.


### Multi-manufacturer expansion — 4 November 2026

The current independently verified snapshot is **72 active customer-visible products across seven manufacturers** and **85 active UK GBP evidence rows** (74 `uk_new`, 11 `uk_used`) in both TEST and LIVE. Manufacturers: Bambu Lab, Creality, Anycubic, Elegoo, Flashforge, Prusa Research and QIDI.

The catalogue now includes the Creality Ender-3 V3 SE, Ender-5 Max, K1 Max and K2/K2 Plus/K2 Pro/K2 SE families, including standard and CFS bundle variants; Anycubic Kobra S1/S1 Max/Kobra 3 Max V2 families and Photon Mono M7/M7 Pro/M7 Max/Mono 4/P1 Max resin printers; and QIDI Max4, Plus5, Q2, Q2C and legacy Plus4, including QIDI BOX bundles. Package variants remain distinct records.

The QIDI Plus4 UK used sale is recorded in both environments at £381.75 (Shepperton, UK; £11.75 Buyer Protection included in the buyer-facing total). QIDI Q2 Combo £559 is from a UK comparison page reporting the QIDI UK direct-store price and is dated 6 October 2026. Anycubic Photon Mono M7 Max is recorded at £599 with `availability=sold_out`, not as available stock. Full IDs and source mapping are in the Batch 3 checkpoint.


### Sega legacy-console coverage extension — 4 November 2026

The Sega home-console catalogue was extended and independently checked in TEST and LIVE. The current Sega manufacturer scope has **17 active customer-visible product records and 22 active UK-used GBP evidence rows** in each environment. All 17 visible products have active evidence; the Sega evidence scope has zero malformed active rows. TEST and LIVE use separate product/evidence UUIDs.

This continuation confirms the following distinct systems and current evidence:
- **Sega SG-1000** — existing active evidence £449.00, eBay UK item 168355445875, boxed/complete and seller-described as fully working: https://www.ebay.co.uk/itm/168355445875. TEST product 4812bf9a-c2e7-4816-b1c8-b7476c299347; LIVE product a3a44c72-5b00-4376-8f4c-d9eb7e9b44ec. Existing active evidence remains TEST 9150ba6d-37ed-41c2-b702-465fb4b59bbf / LIVE 330d3837-300d-41d4-9f24-1a3c2ec34d15.
- **Sega Mark III** — additional active evidence £225.81, eBay UK product/listing page 11023766971, boxed NTSC-J system described as tested and working with cosmetic wear: https://www.ebay.co.uk/p/11023766971. TEST product f6365657-eab9-4003-b45a-c78aa940b8eb / evidence 8c089af3-5df9-4b60-ba2d-ae736b904412; LIVE product 3917a14e-a664-4aec-8b93-00d023858e9b / evidence 5ec96c9e-2ee4-4fc4-86a7-3e097823f834. Existing distinct listing evidence at £173.80 (item 318928337003) remains active.
- **Sega Pico** — additional active evidence £155.58, eBay UK item 307172144334, UK private-seller auction with two games and cables/adaptors, condition stated Very Good: https://www.ebay.co.uk/itm/307172144334. TEST product e2ce884b-2f6f-4e0b-858b-985ee32758a3 / evidence 10a432ed-c288-408a-983e-4dad2fac8028; LIVE product 4d50ecbf-ad3a-4519-8ff2-6d38d0a6e51a / evidence 79ec6b4f-0fa5-4ede-85fe-ced960b982c5. Existing distinct listing evidence at £155.58 (item 307149542948) remains active.

All three product records were already present in both environments when this evidence pass was completed; no duplicate master products were created. A duplicate SG-1000 evidence row for the same £449 listing was identified and deactivated, retaining the pre-existing active row: TEST duplicate evidence 1e031e68-8092-4813-8dba-03c38a8f1b9a; LIVE duplicate evidence a48731eb-e515-4817-aef5-d58e56ca9b91. Do not reactivate these duplicate rows.

The “Master System Plus” label is treated as a bundle/retail package, not a separate console generation. SG-1000 II remains a separate research candidate but was not added in this pass because the surfaced UK listing did not expose a verified direct item URL. Prices above are asking/listing prices, not completed sales. All evidence is reference-only and does not alter automatic valuation. No application code, valuation logic, tenant/customer/transaction/payment data, Stripe configuration or deployment was changed.


### Sega SG-1000 II addition — 4 November 2026

Added the distinct **Sega SG-1000 II** model and one active `uk_used` evidence row independently to TEST and LIVE. Source: eBay UK item 326736515664, £271.07, seller states tested; outer box damage, scratches and dirt. The seller explicitly states the unit is Japanese 100V NTSC-J and requires a suitable voltage transformer for UK mains: https://www.ebay.co.uk/itm/326736515664. TEST product 3a84835c-eb7a-4789-965e-f46b67dd0f30 / evidence c0ddca07-826b-4a04-bd28-41c97288394a; LIVE product 77cff0e9-bfda-4107-ad79-65804fd00ffc / evidence d8f36aae-1373-42b5-9535-6b60540d9e8a.

Post-insert verification in both environments: **18 active customer-visible Sega products, 23 active UK-used GBP evidence rows, zero visible products missing active evidence, and zero malformed evidence rows**. The 100V transformer requirement is retained in both the product notes and evidence notes; do not imply the Japanese console can be connected directly to UK mains. Asking price only, not a completed sale. No code, valuation logic, tenant/customer/transaction/payment data, Stripe settings or deployment changed.


### Gaming controller evidence parity repair — 5 November 2026

A fresh LIVE/TEST audit found that the PlayStation Controllers branch had matching product records but TEST was missing three active UK-used evidence records that were already present in LIVE for the existing Sony DualShock 3 Wireless Controller - Black. Reinserted the three missing evidence records into TEST only, using the exact original UK eBay item URLs, observed GBP prices, sale dates, condition classifications, notes and stable source keys:
- £15.99, eBay item 800496127743, TEST evidence 37e770dc-1900-4424-8922-425a9870c7d5 (ps3-ds3-black-800496127743).
- £24.72, eBay item 206595246997, TEST evidence ca62ef8c-d304-4dc5-961b-95bba0675fb6 (ps3-ds3-black-nearmint-206595246997); retain the near-mint condition and buyer-protection-total note.
- £6.91, eBay item 800734415651, TEST evidence dd610da3-633a-4d71-85eb-7f0b8522d79a (ps3-ds3-black-spares-800734415651); explicitly classify as spares/repairs, not working-controller evidence.

Post-repair verification in both LIVE and TEST: Nintendo Controllers 6 active evidence rows (4 UK-new / 2 UK-used); PlayStation Controllers 10 (2 UK-new / 8 UK-used); Xbox Controllers 17 (15 UK-new / 2 UK-used). The three controller branches now match. No product records, category/branch records, valuation logic, tenant/customer/transaction/payment data, Stripe configuration, application code or Worker deployment were changed. Evidence remains reference-only. Continue with additional exact-variant controller research only after checking duplicates in both environments; keep new and used evidence distinct and UK GBP only.


### PlayStation DualSense colour and limited-edition controller expansion — 5 November 2026

Added eight distinct Sony PlayStation controller products independently to TEST and LIVE under the existing Gaming Consoles & Accessories > PlayStation Controllers branch, each with one active UK-new GBP retail evidence record and a stable source key:
- DualSense Chroma Indigo Wireless Controller — £69.99, GAME UK.
- DualSense Chroma Pearl Wireless Controller — £69.99, GAME UK.
- DualSense Hyperpop Remix Green Wireless Controller — £74.99, official PlayStation UK.
- DualSense Hyperpop Rhythm Blue Wireless Controller — £74.99, official PlayStation UK.
- DualSense Hyperpop Techno Red Wireless Controller — £74.99, official PlayStation UK.
- DualSense 007 First Light Limited Edition Wireless Controller — £74.99, official PlayStation UK.
- DualSense Wireless Controller - Grey Camo — £64.99, GAME UK.
- DualSense Wireless Controller - Cobalt Blue — £69.99, GAME UK.

Research references: GAME UK controller catalogue https://www.game.co.uk/playstation/accessories/controllers/ and official PlayStation UK controllers https://www.playstation.com/en-gb/accessories/controllers/shop-all/. Retail prices are observed new-product prices, not used-market sale prices. Used evidence has not been fabricated or inferred from new retail prices.

Both environments inserted 8 products and 8 evidence records. Post-insert LIVE and TEST verification matches: PlayStation Controllers now has 11 active customer-visible products and 18 active evidence rows (10 UK-new / 8 UK-used); Nintendo Controllers remains 3 products / 6 evidence; Xbox Controllers remains 15 products / 17 evidence. All 29 active products across the three controller branches are customer-visible and have at least one active evidence row. No duplicates were created by this batch. No code, valuation logic, tenant/customer/transaction/payment data, Stripe configuration or Worker deployment was changed. Continue with Nintendo Switch 2 third-party controllers and additional Xbox editions after exact-variant duplicate checks in both environments.


### 3D printer catalogue expansion — Batch 5 — 5 November 2026

Expanded the existing 3D Printers branch independently in TEST and LIVE. Added nine ELEGOO models (Neptune 4, Neptune 4 Pro, Neptune 4 Plus, Neptune 4 Max, Mars 5, Mars 5 Ultra, Saturn 4, Jupiter 2 and OrangeStorm Giga) plus the discontinued QIDI X-Max 3 legacy model. Added nine UK-new GBP retailer observations and one UK-used completed-sale observation. Printer-only variants remain separate from wash/cure and other accessory bundles. OrangeStorm Giga is recorded as pre-order, not in-stock. QIDI X-Max 3 is marked discontinued according to QIDI UK.

Verified independently after both writes: 128 active customer-visible products in each environment; 141 active evidence rows (126 uk_new / 15 uk_used); zero visible products missing evidence or branch; zero duplicate active source_record_key groups; zero missing evidence URLs/keys, invalid prices, non-GBP prices or uk_new condition mismatches. The twelve manufacturers and their product counts are: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3 and Ultimaker 8.

The QIDI X-Max 3 UK eBay sale is £361.42, sold 30 July 2026 (item 406940086609); the displayed total includes £11.42 Buyer Protection and is not seller proceeds. Nine ELEGOO UK retail observations are £169, £189, £279, £377, £154, £231, £299, £699 and £2,049 respectively; exact product URLs and evidence IDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-05.md.

No new category or branch was created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. This was database-only catalogue and evidence work; no Worker deployment was required. TEST and LIVE use environment-specific manufacturer, product and evidence UUIDs. Continue TEST-first, then mirror to LIVE, and never infer used values from new retail prices.


### FLSUN 3D printer expansion — Batch 6 — 5 November 2026

Added FLSUN as a new active manufacturer and added four standard FDM printer models independently in TEST and LIVE: S1, T1, S1 Pro and T1-PRO. Each model has one UK GBP new-market evidence row with its observed stock state preserved: S1 £499 in stock at 3D Prima; T1 £500 backordered at 123-3D; S1 Pro £1,299 out of stock at the FLSUN UK Store; T1-PRO £509 out of stock at the FLSUN UK Store. Do not present the backordered or out-of-stock items as available now.

Post-write verification matches independently in TEST and LIVE: 132 active customer-visible products; 145 active evidence rows (130 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP rows or uk_new condition mismatches. FLSUN has four active products. Exact UUID mapping and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-06.md.

No new category or branch was created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work; no Worker deployment required. Preserve the stock-state notes and do not infer used prices from retail asking prices.


### FLSUN evidence freshness correction — 5 November 2026

Final source review found that the official FLSUN UK Store S1 Pro and T1-PRO pages were last crawled about five months before this review. Their £1,299 and £509 observations are retained as historical price references only: observed_at is NULL, availability is “Historical listing; current availability unconfirmed”, and their source keys are marked historical. Do not present either as a current available offer. The S1 Pro direct page could not be fetched during review.

A newer UK T1-PRO retailer observation was added separately: 3DShop UK £365.00, marked in stock and ready for dispatch (page last crawled about four weeks before review), https://3dshop.uk/shop/flsun-t1pro/. TEST evidence UUID b7fb29b9-4d1c-4928-9f10-b9cb90dbf862; LIVE evidence UUID a35fd5f9-72ad-4314-9230-b01a08756517. The older FLSUN UK £509 record remains historical and is not merged with the 3DShop offer.

Latest independent TEST/LIVE snapshot supersedes the earlier Batch 6 total: 132 active customer-visible products; 146 active evidence rows (131 uk_new / 15 uk_used); zero missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, invalid prices, non-GBP evidence or uk_new condition mismatches.


### ELEGOO resin printer catalogue expansion — Batch 7 — 5 November 2026

Added four previously missing ELEGOO resin printer models independently in TEST and LIVE: Mars 4, Mars 4 Ultra, Saturn 3 and Saturn 3 Ultra. Each has one active UK-new GBP price observation. Mars 4 £149 and Mars 4 Ultra £189 are from their official UK product pages. Saturn 3 £214 and Saturn 3 Ultra £239 are from the ELEGOO UK Saturn Series collection's latest indexed capture (about one month before review); stock is unconfirmed and those two prices must be rechecked before valuation or customer quotation. Printer-only prices; wash/cure bundles excluded.

Independent TEST/LIVE verification after Batch 7: 136 active customer-visible products; 150 active evidence rows (135 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Exact environment-specific product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-07.md.

No category or branch created. No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work; no Worker deployment required.


### Nintendo Switch 2 third-party controller expansion — 5 November 2026

Expanded Gaming Consoles & Accessories > Nintendo Controllers independently in TEST and LIVE. Added five distinct third-party controller products with one active UK-new GBP evidence row each:
- PowerA Advantage Wireless Controller for Nintendo Switch 2 - Black — £34.99, Smyths Toys UK.
- 8BitDo Pro 3 Wireless Controller for Nintendo Switch 2 - Purple — £59.99, Argos UK.
- Turtle Beach Afterglow Wave Wireless Controller for Nintendo Switch 2 - Black — £41.99, Smyths Toys UK.
- PowerA Advantage Wired Controller for Nintendo Switch 2 - Mario Time — £12.99, Smyths Toys UK.
- PowerA Advantage Wireless Controller for Nintendo Switch 2 - Mario and Friends — £29.99, Smyths Toys UK.

Research URLs: Smyths Switch 2 controller listings https://www.smythstoys.com/uk/en-gb/gaming-and-tech/gaming-controllers/nintendo-switch-2-controllers/c/nintendo-switch-2-controllers and Argos Switch 2 controller catalogue https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-2-controllers/c%3A1054685/. All entries use GBP, item_condition New, source URLs and stable source_record_key values. Retail asking prices are not completed-sale prices. No used evidence was inferred from new prices.

Recovery note: a prior interrupted attempt had inserted the PowerA Advantage Wireless Black product into TEST without evidence or LIVE parity. This pass completed the missing TEST evidence and inserted the matching LIVE product/evidence, then independently verified the final parity. No duplicate products were created.

Post-insert verification in both LIVE and TEST: Nintendo Controllers has 8 active customer-visible products and 11 active evidence rows (9 UK-new / 2 UK-used); all 8 visible products have at least one active evidence row. Product and evidence rows match between environments. Existing official Nintendo Switch 2 Joy-Con 2 and Pro Controller records were retained unchanged. No category/branch creation, code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue work; no Worker deployment required. Continue with remaining verified Gioteck, HORI, CRKD, Deltaco, Snakebyte and other exact Switch 2 controller variants after manufacturer and duplicate checks in both environments.


### 3D printer catalogue expansion — Batch 8 — 5 November 2026

Added two verified ELEGOO printer-only models independently in TEST and LIVE:
- Neptune 3 Pro — £127.00 UK new, ELEGOO UK. The official UK product page identifies the exact model and FDM specification, offers the standard new printer option and lists the UK delivery guidance for in-stock goods. Source: https://uk.elegoo.com/collections/elegoo-products-dc/products/elegoo-neptune-3-pro-fdm-3d-printer-225x225x280mm
- Saturn 2 (8K) — £350.00 UK new, 123-3D UK. Exact 8K model and SKU DKI00121; retailer explicitly says backordered/available to order with estimated 10–14 days, so do not describe as in stock. Source: https://www.123-3d.co.uk/collections/3d-printers/products/elegoo-saturn-2-8k-3d-printer

Neptune 3 Plus was not added because the official UK page is sold out. Neptune 3 Max was not added as a new-price item because only sold-out/new and pre-owned listings were found. Mars 3 Pro was not added because current UK retailer evidence is not dependable enough to treat as an available new offer; other retailer pages show sold out. No unsupported legacy models or bundles were introduced.

Post-insert independent category-scoped verification in both TEST and LIVE: 138 active and customer-visible 3D printer products; 152 active evidence rows (137 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Counts are for the 3D Printers category only, not the entire master catalogue.

Exact Batch 8 product/evidence UUIDs are recorded in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-08.md. TEST and LIVE use independent environment-specific UUIDs. UK GBP only; printer-only variants kept separate from bundles; used evidence remains reference-only and must not affect automatic valuation. Database-only change: no schema, code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. No Worker deployment required.


### 3D printer catalogue expansion — Batch 9 — 5 November 2026

Expanded Flashforge in TEST and LIVE with three verified printer-only models:
- Creator 5 — £719.00 UK new; official Flashforge UK page shows In Stock and advertises a £100 automatic cart discount. Source: https://uk.flashforge.com/products/flashforge-creator-5
- Creator 5 Pro — £849.00 UK new; official Flashforge UK page shows In Stock and advertises a £100 automatic cart discount. Source: https://uk.flashforge.com/products/flashforge-creator-5-pro
- Guider 3 Ultra — £2,999.00 UK new; official Flashforge UK page states shipment direct from China warehouse, shipping in 30 days. It is not represented as UK-stocked. Source: https://uk.flashforge.com/products/guider-3-ultra-3d-printer

Creator 5 and Creator 5 Pro are separate models, not package variants; the Pro includes an enclosed frame, active heated chamber and HEPA/carbon filtration. Guider 3 Ultra is a large-format dual-extruder CoreXY model. Advertised list prices were recorded; Creator 5 and Creator 5 Pro product pages separately advertise £100 automatically applied at checkout, so verify checkout price before quoting.

Post-insert independent category-scoped verification in both TEST and LIVE: 141 active customer-visible 3D printer products; 155 active evidence rows (140 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. Counts are for the 3D Printers category only.

Exact Batch 9 product/evidence UUIDs are recorded in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-09.md. TEST and LIVE use independent environment-specific UUIDs. UK GBP only; used evidence remains reference-only and must not affect automatic valuation. Database-only change; no Worker deployment required.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 2

Added and verified 11 further Nintendo Switch 2 controller products and 11 UK-new evidence rows in both LIVE and TEST. Six manufacturer records were added in each environment: Gioteck, Snakebyte, HORI, CRKD, Deltaco and GXTrust. No existing manufacturer or product rows were overwritten.

Products and observed UK GBP new prices (observed 2026-11-05):
- Gioteck WX5+ Wireless RGB Controller — Dark Camo: £24.99 (Smyths Toys UK)
- Gioteck WX5 Bluetooth Wireless Controller — Black: £19.99 (Smyths Toys UK)
- Snakebyte GamePad S2 Wireless Pro: £10.00 (Smyths Toys UK)
- Snakebyte GamePad RGB S2 Wireless Pro: £9.99 (Smyths Toys UK)
- HORI Wireless HORIPAD Turbo — Pokémon Pixel Green: £54.99 (Argos)
- HORI Wireless HORIPAD Turbo — Pokémon Pixel Red: £54.99 (Argos)
- CRKD Nitro Deck 2 — Smoke Black: £89.99 (Argos)
- CRKD ATOM+ Mini Bluetooth Controller — Retro Purple: £28.99 (Argos)
- Deltaco GAM-198-T RGB Wireless Controller — Clear: £19.99 (Argos)
- Deltaco GAM-196 Ergonomic Controller — Black: £29.99 (Argos)
- GXTrust Muta Wireless Controller — Red/Blue: £24.99 (Argos)

Research listing URLs:
- Smyths Toys UK: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/gaming-controllers/nintendo-switch-2-controllers/c/nintendo-switch-2-controllers
- Argos: https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-2-controllers/c%3A1054685/

Evidence is stored as uk_new, GBP, item_condition New, with observed_at timestamp, source URL, retailer, and stable source_record_key. These are advertised retail asking prices, not completed-sale prices. No used evidence was inferred from retail listings. CRKD Nitro Deck 2 is a handheld controller/grip device and remains recorded as a controller product, not as a conventional standalone gamepad.

Post-insert verification, separately run in both environments for the Nintendo Controllers branch: 19 active customer-visible products; 22 active evidence rows (20 uk_new / 2 uk_used); zero visible products missing evidence; zero invalid active evidence rows (missing URL/key, non-positive price or non-GBP currency). The 11 new product rows and 11 evidence rows match by model, package key, source and price in LIVE and TEST. Existing eight Nintendo controller products and their prior evidence were retained. The prior batch's counts were 8 products / 11 evidence; new totals are 19 / 22.

Database-only catalogue change. No Worker deployment, code, schema, valuation logic, RLS, Edge Function, Stripe, tenant, customer, order, payment or custom-domain data changed. Used evidence remains reference-only and must not affect automatic valuation. Exact product/evidence UUIDs are recorded in CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-02.md.


### 3D printer catalogue expansion — Batch 10 — 5 November 2026 (corrected final state)

Expanded Prusa Research and Flashforge in TEST and LIVE. A final current-source cross-check was performed before locking the checkpoint.

New printer-only models:
- Prusa CORE One+ (Gen 2) — £909.00 advertised from-price, Fabinity UK; in stock, two purchase options, so confirm assembly/configuration before quotation. Source: https://www.fabinity.com/brands/prusa
- Prusa CORE One L+ — £1,829.00, Fabinity UK; in stock. Source: https://www.fabinity.com/brands/prusa
- Prusa XL+ Single-Tool — £2,099.00, Fabinity UK; ships in 4–5 weeks. Source: https://www.fabinity.com/brands/prusa
- Flashforge CJ270 — £3,499.00, official Flashforge UK. The product page still carries pre-order timeline language (first 100 units scheduled to ship 15 October, later orders in purchase order); current fulfilment is not independently confirmed. Record as listed with availability caveat, not as confirmed in-stock. Source: https://uk.flashforge.com/products/flashforge-cj270

Current Flashforge collection snapshot confirms AD5X £299, Adventurer 5M £209 and Adventurer 5M Pro £339. These match the prior 4 November evidence already stored for those models. An intermediate Batch 10 observation from an older cached collection page showed £359/£259/£399; those three evidence rows were deactivated and retained as historical only, not used as current prices. Latest collection source: https://uk.flashforge.com/collections/3d-printers

Post-correction independent category-scoped verification in both TEST and LIVE: 145 active customer-visible 3D printer products; 159 active evidence rows (144 uk_new / 15 uk_used); 13 manufacturers; zero visible products missing evidence or branch; zero duplicate active source keys; zero missing evidence URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. TEST and LIVE counts match exactly.

Exact environment-specific product/evidence UUIDs are in CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-10.md. All active evidence is UK GBP, New and source-linked. Printer-only models remain separate from kits/accessories; used evidence remains reference-only and must not affect automatic valuation. Database-only catalogue/evidence change; no schema, application code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. No Worker deployment required.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 3

Added 13 further Nintendo Switch 2 compatible controllers and 13 UK-new market-evidence rows in both LIVE and TEST. Existing manufacturer records were reused; no manufacturer duplication was introduced.

Products and observed Argos UK new asking prices (2026-11-05):
- Gioteck WX5+ Crayons — £24.99
- Gioteck WX5+ Pink Swirl — £24.99
- Gioteck WX5+ Doodle — £24.99
- CRKD ATOM+ Mini Pal Grey — £28.99
- CRKD ATOM+ Mini Glacier Blue — £28.99
- CRKD ATOM+ Mini Smoke Black — £28.99
- CRKD ULT PRO Smoke Black — £64.99
- HORI Wireless HORIPAD Turbo Kirby & Waddle Dee — £64.99
- Turtle Beach Afterglow RGB Wired Clear — £24.99
- Turtle Beach Afterglow Wave RGB Wired — £19.99
- Turtle Beach Afterglow RGB Wireless — £49.99
- Turtle Beach Rematch Mario & Luigi — £54.99
- Turtle Beach Rematch Rosalina — £54.99

Source listing: https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-2-controllers/c%3A1054685/. Gioteck product family listing: https://www.gioteck.com/collections/brand-new-wx5-switch-2-controllers. Evidence rows are uk_new, GBP, condition New, with source URL, source key and observation timestamp. Retail asking prices are not completed-sale prices. No used evidence was inferred. 

Post-insert verification in both LIVE and TEST: Nintendo Controllers branch totals are now 32 active customer-visible products and 35 active evidence rows (33 uk_new / 2 uk_used); zero visible products missing evidence. This batch independently verifies 13 products and 13 active evidence rows in each environment, all with positive GBP prices, source keys and New condition. Product/evidence model, package key, source and price parity was checked across environments. Used evidence remains reference-only and must not affect automatic valuation.

Database-only catalogue update. No Worker deployment, application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment or custom-domain data changed. Exact environment-specific UUIDs are recorded in CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-03.md.

### 3D printer catalogue expansion — Batch 11 — 5 November 2026

Added two Prusa Research printer-only products in TEST and LIVE:
- Original Prusa SL1S SPEED — £1,999 UK new evidence from Fabinity. The listing has an explicitly selectable printer-only option; optional CW1S wash/cure bundle is excluded. Recheck before quotation. Source: https://www.fabinity.com/product/original-prusa-sl1s-speed-3d-printer-cw1s-bundle
- Prusa Pro HT90 — £10,600 UK new evidence from 123-3D UK; listing marked backordered. Source: https://www.123-3d.co.uk/products/prusa-pro-ht90-3d-printer

TEST product UUIDs: SL1S SPEED 8d7c7b10-8f01-4d3e-a101-000000000401; Pro HT90 8d7c7b10-8f01-4d3e-a101-000000000402. TEST evidence UUIDs: 8d7c7b10-8f01-4d3e-a101-000000000411 and 8d7c7b10-8f01-4d3e-a101-000000000412.
LIVE product UUIDs: SL1S SPEED 9d7c7b10-8f01-4d3e-a101-000000000401; Pro HT90 9d7c7b10-8f01-4d3e-a101-000000000402. LIVE evidence UUIDs: 9d7c7b10-8f01-4d3e-a101-000000000411 and 9d7c7b10-8f01-4d3e-a101-000000000412.

Independent category-scoped verification in TEST and LIVE after insertion: 147 active customer-visible products; 161 active evidence rows (146 uk_new / 15 uk_used); 13 manufacturers. Zero visible products missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, non-positive prices, non-GBP evidence or uk_new condition mismatches. TEST and LIVE match exactly.

No schema, application code, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. Database-only catalogue/evidence work. Used evidence remains reference-only and must not affect automatic valuation.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 4
Added 11 further products and 11 UK-new evidence rows to both LIVE and TEST: PowerA Advantage Wireless Mario Kart World (£37.99), Super Mario (£49.99), Pokémon (£54.99), Pikachu Moments (£49.99), Advantage Wired Black (£14.99), Advantage Wired Mushroom Kingdom (£14.99); Turtle Beach Rematch Wireless Black (£39.99), Mario Kart World (£54.99), Koopa Troop (£54.99), Rematch The Legend of Zelda (£24.97); GXTrust Muta Wired White (£24.99). Retailer sources: Argos https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-2-controllers/c%3A1054685/ and Currys https://www.currys.co.uk/gaming/controllers/controllers/nintendo-switch-2-controllers. Evidence is UK GBP new retail asking prices, not completed-sale prices. Both environments now have 43 active customer-visible Nintendo controller products and 46 active evidence rows (44 UK-new / 2 UK-used); zero visible products lack active evidence. The 11 additions match across LIVE and TEST by model/package/source/price. No Worker deployment, code/schema/valuation/RLS/Edge Function/Stripe or tenant/transaction data changes. Exact UUIDs are in CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-04.md. Used evidence remains reference-only and excluded from automatic valuation.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 5
Added two further confirmed Switch 2-compatible controllers to both LIVE and TEST, with active UK-new GBP evidence:
- Freaks and Geeks Wireless Controller — Dragon Blossom, £29.99 at Argos. Argos confirms compatibility with Switch 2, original Switch, Switch OLED and PC; EAN 3701625906025. Brand/manufacturer record added as Freaks and Geeks (Trade Invaders).
- DragonShock FIFA WorldCup 26 AURORA+ Wireless Controller — England, £44.99 at Argos. The Argos EAN 5061111810167 is identified by DragonShock's distributor catalogue as the AURORA+ England Switch 2 model; added under manufacturer DragonShock, not FIFA.
Sources: https://www.argos.co.uk/product/8535508 ; https://www.argos.co.uk/product/8384467 ; https://cld.eu/en/publisher/dragonshock .

Nintendo Controllers branch totals in both environments: 45 active customer-visible products, 48 active evidence rows, and zero visible products without active evidence. The new records are matched between LIVE and TEST by model, package key, source and price. No Worker deployment, schema/application/valuation changes, or tenant/transaction data changes. Used evidence remains reference-only and excluded from automatic valuation. Exact IDs are recorded in CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-05.md.


### 3D printer catalogue update — Batch 12 — 5 November 2026
Creality Ender-3 V3 Neo (£199; standard option marked in stock) and Ender-3 V3 Mega (£519; dispatch timing not confirmed) were added to TEST and LIVE with UK GBP new-price evidence. Standard printer records exclude optional Neo Combo/CFS nano packages. Sources: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer and https://store.creality.com/uk/collections/ender-series-3d-printer. Both environments verified at 149 active visible products and 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers, with no integrity exceptions. UUIDs: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-12.md. No application/schema/valuation or Worker changes; used evidence remains reference-only.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 6
Added five Nintendo-branded Switch 2 variants to LIVE and TEST with UK-new GBP evidence: Joy-Con 2 (L) Light Blue £41.99; Joy-Con 2 (R) Light Red £41.99; Joy-Con 2 Pair Light Purple/Light Green £64.95; Joy-Con 2 Pair Blue/Light Yellow £64.99; Pro Controller The Legend of Zelda 40th Anniversary Edition £74.99. Sources: Argos Switch 2 controller listing and Currys Zelda Pro Controller product page. Both environments now have 50 active visible Nintendo controller products and 53 active evidence rows (51 UK-new / 2 UK-used), with zero visible products missing active evidence. LIVE/TEST matched. No deployment, code/schema/valuation or tenant/transaction changes. Used evidence remains reference-only and excluded from automatic valuation. Exact details: CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-06.md.


### Catalogue reconciliation note — 5 November 2026
Following the Batch 12 Creality update, parallel TEST catalogue activity added active HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) entries with active UK-new evidence. These are not yet in LIVE. Current category read: TEST 151 active visible products / 165 active evidence; LIVE 149 / 163. Audit the existing TEST records and mirror them to LIVE with environment-specific IDs; do not duplicate them in TEST. An additional duplicate Ender-3 V3 Neo record is already inactive and hidden. See CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-12.md for the detailed status.


## 2026-11-05 follow-on reconciliation note — original Switch Joy-Con pair variants
During the first pass over the wider original Nintendo Switch catalogue, two additional original Switch Joy-Con pair entries were inserted into LIVE only: Purple & Orange (£59.99) and Neon Red & Blue (£59.99), both with Argos UK-new evidence. The corresponding TEST writes were blocked before completion, and the two records must not be treated as parity-synced. Current branch totals after these two LIVE-only rows: LIVE 52 active visible products / 55 active evidence; TEST 50 active visible products / 53 active evidence. The two LIVE rows have active evidence; no products were left without evidence. Reconcile these exact package keys in TEST (or deactivate the LIVE-only entries if the intended scope changes) before declaring full Nintendo branch parity or copying any other original-Switch additions. No tenant/transaction data or application code changed. Source listing: https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-controllers/c%3A812401/ .


### Original Switch Joy-Con parity restored — 5 November 2026
The two original Nintendo Switch Joy-Con pairs previously added to LIVE only have now been mirrored into TEST with separate environment-specific product and evidence IDs. Purple & Orange (£59.99): LIVE product f409f8d2-b33f-43e7-9653-10196e1c30ad, LIVE evidence 36baf450-c126-42dd-807c-a92b9a93f0c5; TEST product b6652973-4e6f-4aa5-8bfc-724aff468546, TEST evidence 8897ea0a-24df-4e04-87bd-d8b5d5df1b36. Neon Red & Blue (£59.99): LIVE product d4796c49-a994-4339-af61-48b0c35726f7, LIVE evidence 62ce8bb4-b068-4fa9-9454-7f7a5b11958b; TEST product 10a21c36-726e-4494-91a9-8a72642896a0, TEST evidence 32f5232f-589f-47be-83f9-9475c53b7105. Both use Argos UK-new GBP evidence and are separate from Switch 2 Joy-Con 2 variants. Rechecked using distinct product and evidence counts: LIVE 52 active customer-visible products / 55 active evidence; TEST 52 / 55; zero visible products missing active evidence in either environment. Original Switch branch parity is restored. No Worker deployment, application code, schema, valuation, tenant, customer, order or payment data changed.

### 2026-11-05 Nintendo controller catalogue Batch 7
Original Switch Joy-Con parity restored and seven further original Switch variants added in both LIVE and TEST: Joy-Con Blue/Neon Yellow £59.99; Joy-Con Purple/Green £40.19; GameSir Nova Lite Space Purple, Pink and Grey £17.99 each; HORI Split Pad Pro Black £39.99; HORI Wired HORIPAD Turbo Zelda £22.99. Each has active UK-new GBP Argos evidence. GameSir manufacturer added to both environments. Verified independent totals: LIVE 59 active visible products / 62 active evidence; TEST 59 / 62; zero visible products missing evidence. Exact IDs and sources are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-07.md. No Worker deployment or code/schema/valuation/tenant/transaction changes; used evidence remains reference-only.


### 2026-11-05 original Nintendo Switch controller Batch 8 — PDP REALMz
Added PDP REALMz Wireless Shadow Space ARK (£15.99) and PDP REALMz Wired Tails Seaside Hill Zone (£7.99) to both LIVE and TEST, each with active UK-new GBP Argos evidence. PDP manufacturer added in both environments. Independent totals: LIVE 61 active visible products / 64 active evidence; TEST 61 / 64; zero visible products missing active evidence. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-08.md. No Worker deployment or application/schema/valuation/tenant/transaction changes.


### Reconciliation completed — Creality HALOT resin models — 5 November 2026
HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) from parallel TEST catalogue work have now been mirrored to LIVE with printer-only UK-new evidence. Optional resin/wash-cure bundles excluded. TEST product UUIDs a17c7b10-8f01-4d3e-a101-000000000502/503; TEST evidence UUIDs a17c7b10-8f01-4d3e-a101-000000000512/513. LIVE product UUIDs c3d4e5f6-7081-49ab-9234-000000000502/503; LIVE evidence UUIDs c3d4e5f6-7081-49ab-9234-000000000512/513. Sources: https://store.creality.com/uk/products/halot-x1-neo-resin-3d-printer and https://store.creality.com/uk/products/halot-x1-max-resin-3d-printer. Current fulfilment is unconfirmed; delivery estimates on indexed pages are stale/past.

TEST and LIVE each now report 151 active customer-visible 3D printer products and 165 active evidence rows (150 uk_new / 15 uk_used). LIVE confirms both product and evidence rows. TEST integrity check: zero missing evidence/branches, duplicate active source keys, missing URLs/keys, invalid/non-GBP prices or uk_new condition mismatches. Earlier pending-sync note is superseded. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 9

Added four additional original Nintendo Switch-family compatible controllers independently to LIVE and TEST, each with active UK-new GBP Argos evidence:
- PowerA Enhanced Switch & PC Wireless Controller — Kirby: £24.99; Argos https://www.argos.co.uk/product/7868290/.
- PowerA Enhanced Switch Wireless Controller — Mario Peek A Boo: £29.99 current promotional listing (was £39.99); Argos https://www.argos.co.uk/product/7570289/.
- Turtle Beach Rematch Wireless Switch Controller — Mario Bricks: £49.99; Argos https://www.argos.co.uk/product/7818848/.
- Turtle Beach Rematch Wireless Switch Controller — Donkey Kong: £49.99; Argos https://www.argos.co.uk/product/7811089/.

Each record is a separate visible Controller product with a unique package key and source_record_key. Manufacturer records were reused (PowerA and Turtle Beach); no manufacturer duplicates created. All evidence is UK-new, GBP, item_condition New, availability listed, and source-linked. Mario Bricks and Donkey Kong Rematch models are also Switch 2 compatible (C Button unavailable); they are retained in the shared Nintendo Controllers branch because the products also support the original Switch family. Used evidence remains reference-only and does not alter automatic valuation.

Independent post-insert verification in both environments: 65 active customer-visible Nintendo Controllers products and 68 active evidence rows; zero visible products missing active evidence; zero active evidence integrity exceptions (source URL/key, positive price, GBP currency and condition classification). Product/evidence counts and product package keys match between LIVE and TEST; environment-specific UUIDs are listed in the Batch 9 checkpoint. Database-only change: no Worker deployment, application/schema/valuation/RLS/Edge Function/Stripe or tenant/customer/order/payment changes.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 10

Added four additional original Switch-family controller products independently to LIVE and TEST with UK-new GBP Argos evidence:
- CRKD Nitro Deck Handheld Controller — White: £34.99 current Argos listing (was £49.99), compatible with Switch and OLED; not Switch Lite. https://www.argos.co.uk/product/8563903/.
- CRKD Nitro Deck — Cuddle Team Leader Fortnite Edition: £49.99, compatible with Switch and OLED. https://www.argos.co.uk/product/7658352/.
- PowerA Enhanced Wired Controller — Cosmic Purple: £19.99. https://www.argos.co.uk/product/7551356/.
- PowerA Enhanced Wired Controller — Green: £19.99. https://www.argos.co.uk/product/7265635/.

Reused existing CRKD and PowerA manufacturers. Separate colour/design package keys were used; no existing product rows were overwritten. All evidence is UK-new GBP, New, listed, with Argos URL and stable key. Independent verification in both environments: 69 active customer-visible Nintendo Controllers products / 72 active evidence rows; zero visible products missing active evidence; zero evidence integrity exceptions. LIVE and TEST totals match. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-10.md. Database-only update; no Worker deployment, code/schema/valuation or tenant/transaction changes. Used evidence remains reference-only.


### Creality catalogue reconciliation — three models, 5 November 2026
A parallel catalogue agent had already added canonical standard-package records for SPARKX i7 (£239), HALOT-MAGE S 14K (£439) and HALOT-R6 (£119) in both environments while a separate insertion was being prepared. The second, duplicate printer-only rows were therefore soft-deactivated and hidden; no canonical records were deleted. Canonical TEST product IDs: d51a8e10-7c21-4a91-9e01-000000000601/602/603; TEST evidence IDs: d51a8e10-7c21-4a91-9e01-000000000611/612/613. Canonical LIVE product IDs: e62b9f21-8d32-4ba2-8f12-000000000601/602/603; LIVE evidence IDs: e62b9f21-8d32-4ba2-8f12-000000000611/612/613. Inactive duplicate TEST IDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603 and evidence c7e4a901-6b32-4d8f-9a21-000000000611/612/613. Inactive duplicate LIVE IDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603 and evidence d8f5b012-7c43-4e9a-a321-000000000611/612/613.

Sources: SPARKX i7 single printer option £239 — https://store.creality.com/uk/products/sparkx-i7-3d-printer (Autofill/CFS/colour bundles excluded; fulfilment unconfirmed because indexed delivery estimate is stale); HALOT-MAGE S 14K standalone £439 — https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer (official page stated in stock, estimated delivery 2–6 Nov 2026); HALOT-R6 standalone £119 — https://store.creality.com/uk/products/halot-r6-resin-3d-printer (indexed delivery estimate stale; current fulfilment unconfirmed). Resin, filament and wash/cure bundles are excluded.

Verified after duplicate deactivation: TEST and LIVE each have 154 active customer-visible 3D printer products and 168 active evidence rows (153 uk_new / 15 uk_used), 13 manufacturers. Both environments have zero visible products missing active evidence, zero duplicate active source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only and does not affect automatic valuation. Full record history: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-13.md.


### Creality K1 catalogue addition — 5 November 2026
Added standalone Creality K1 Speedy printer to both TEST and LIVE, recorded as model K1 / standard printer. UK official price observation £299.00; the product page and current UK collection show it sold out, so current availability is not claimed. It is not marked discontinued because the manufacturer has not explicitly stated that. Source: https://store.creality.com/uk/products/k1-speedy-3d-printer. TEST product f3a6c812-9d54-4eab-b432-000000000701, evidence f3a6c812-9d54-4eab-b432-000000000711; LIVE product a4b7d923-0e65-4fbc-c543-000000000701, evidence a4b7d923-0e65-4fbc-c543-000000000711. Independent TEST/LIVE totals now match at 155 active visible 3D printer products and 169 active evidence rows (154 UK-new / 15 UK-used). Detailed checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-14.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 11

Added three additional original Switch-compatible controller products independently to LIVE and TEST, with active UK-new GBP Argos evidence:
- Konix Hello Kitty Nintendo Switch Wired Controller: £15.99; Argos product 729/4606. 3m wired controller with vibration and screenshot button; compatible with Switch, OLED and PC; supplier confirms Switch 1 only. https://www.argos.co.uk/product/7294606.
- CRKD NEO S Wireless Controller — Fortnite Festival Edition (Purple Wave): £44.99 current promotional Argos price (was £59.99); wireless, detachable five-fret attachment, Hall Effect thumbsticks, remappable rear buttons; Switch/OLED/PC/mobile/Smart TV compatible. https://www.argos.co.uk/product/7183638.
- CRKD NEO S Wireless Controller — Peely Fortnite Edition: £59.99; wireless, Hall Effect thumbsticks, remappable rear buttons and charging dock; Switch/OLED/PC/mobile/Smart TV compatible. https://www.argos.co.uk/product/7188846.

Konix manufacturer row was newly created separately in LIVE and TEST; existing CRKD manufacturer rows were reused. Duplicate preflight found no Konix or NEO S products in the Nintendo Controllers branch. Independent post-insert verification in both environments: 72 active customer-visible products / 75 active evidence rows; zero visible products missing active evidence; zero active evidence integrity exceptions. LIVE and TEST totals match. Exact UUIDs are recorded in CHECKPOINTS/2026-11-05-original-switch-controller-batch-11.md. Database-only change; no Worker deployment, application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. Used evidence remains reference-only and does not affect automatic valuation.


### Creality printer-only additions and parallel-record reconciliation — 5 November 2026
Three additional Creality models were brought into the active catalogue in TEST and LIVE using the existing `printer-only` product records rather than creating duplicate standard-package rows:
- SPARKX i7 — £239 for the i7 Single variant only. Autofill (£269), Nano Combo (£299), Color Combo (£339) and CFS Lite accessories are excluded. Source: https://store.creality.com/uk/products/sparkx-i7-3d-printer. The indexed delivery estimate is stale; current stock/dispatch is unconfirmed.
- HALOT-MAGE S 14K — £439 standalone printer; resin and wash/cure bundles excluded. Source: https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer. The page crawl was six days old and showed in stock with estimated delivery 2–6 November 2026.
- HALOT-R6 — £119 standalone printer; resin/accessories excluded. Source: https://store.creality.com/uk/products/halot-r6-resin-3d-printer. Page crawl was about one month old; current fulfilment is unconfirmed.

TEST product UUIDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603. TEST active evidence UUIDs: f73c9d20-9e43-4cb4-9a23-000000000611/612/613. LIVE product UUIDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603. LIVE active evidence UUIDs: d8f5b012-7c43-4e9a-a321-000000000611/612/613. Both sets are printer-only records and were activated only after evidence was attached. Temporary duplicate `standard` package records created during the parallel write were deactivated/hidden and retained for audit; they are not customer-visible.

Post-change category verification: TEST has 154 active customer-visible products and 168 active evidence rows (153 UK-new / 15 UK-used); LIVE has 154 active customer-visible products and 169 active evidence rows (154 UK-new / 15 UK-used). Both environments returned no active customer-visible products without active evidence. The one-row active-evidence count difference remains to be reconciled; do not state that evidence totals are identical until that check is completed. Evidence remains UK-only and GBP-only; used-market evidence remains reference-only and must not affect automatic valuation. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 12

Added CRKD Nitro Deck+ Controller for Nintendo Switch — Black independently to LIVE and TEST with active UK-new GBP Argos evidence at £69.99. Argos product 763/2543 confirms compatibility with standard Nintendo Switch and Switch OLED only; it does not support Switch Lite or Switch 2. It is a handheld grip/controller with Hall Effect sticks and triggers, programmable side kicks/back buttons and TV dockability via USB-C HDMI. Source: https://www.argos.co.uk/product/7632543/.

Duplicate preflight found no Nitro Deck+ product in either Nintendo Controllers branch. Existing CRKD manufacturer rows were reused. Independent post-insert verification in both environments: 73 active customer-visible products / 76 active evidence rows; zero visible products missing active evidence. LIVE and TEST totals match. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-12.md. Database-only update; no Worker deployment, application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. Used evidence remains reference-only and does not affect automatic valuation.


### Creality HALOT-X1 standalone addition — 5 November 2026
Added the standalone HALOT-X1 resin printer to TEST and LIVE at £579 GBP, separate from HALOT-X1 Neo/Max and separate from the X1 Combo (£599) and All-in-One (£699) options. Official source: https://store.creality.com/uk/products/halot-x1-combo-resin-3d-priner-for-miniatures-and-terrain?country=GB&currency=GBP. Page states In Stock / UK local warehouse, but the estimated delivery 19–23 Oct 2026 is past; current dispatch should be reconfirmed. TEST product a9c8d034-1f76-40cd-8e65-000000000801, evidence a9c8d034-1f76-40cd-8e65-000000000811; LIVE product b0d9e145-2087-41de-9f76-000000000801, evidence b0d9e145-2087-41de-9f76-000000000811. TEST and LIVE independently verified at 156 active visible 3D printer products and 170 active evidence rows (155 UK-new / 15 UK-used), with zero visible products missing evidence, zero duplicate active source keys and zero invalid active evidence. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-15.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


### Follow-on Creality K1 SE and final parity correction — 5 November 2026
Added Creality K1 SE as a legacy printer-only catalogue record in both environments. Official Creality UK collection lists £229 and marks it Sold Out; this is historical UK-new price evidence only, not a current purchase offer. Source: https://store.creality.com/uk/collections/creality-could-3d-printers. TEST product/evidence UUIDs aa83d910-2f44-4b7a-9c31-000000000701/711; LIVE UUIDs bb94ea21-3a55-4c8b-8d42-000000000701/711. K1 SE remains a visible model reference, with sold-out availability explicitly recorded.

Final independent category verification after this addition: TEST and LIVE each have 157 active customer-visible products and 171 active evidence rows (156 UK-new / 15 UK-used). Both environments return zero active visible products without active evidence. The previously noted one-row evidence difference is resolved; product/evidence totals now match. All evidence remains UK GBP. Used-market evidence remains reference-only and does not affect automatic valuation. No Worker deployment or code/schema/valuation/transactional changes.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 13

Added two CRKD Gibson Les Paul Pro Edition guitar controllers independently to LIVE and TEST with active UK-new GBP Argos evidence:
- CRKD Gibson Les Paul Alpine White Pro Edition Guitar Controller — £119.99; Argos product 978/7087. Argos confirms Nintendo Switch 1, Switch OLED and Switch 2 compatibility. https://www.argos.co.uk/product/9787087.
- CRKD Gibson Les Paul Blueberry Burst Pro Edition Guitar Controller — £119.99; Argos product 778/1906. Argos confirms Nintendo Switch 1 and Switch OLED compatibility. https://www.argos.co.uk/product/7781906.

Duplicate preflight found no Gibson products in either Nintendo Controllers branch. Existing CRKD manufacturer records were reused; no manufacturer rows were added. Product/evidence UUIDs are environment-specific and recorded in CHECKPOINTS/2026-11-05-original-switch-controller-batch-13.md. Independent post-insert verification: LIVE and TEST each have 75 active customer-visible products / 78 active evidence rows, zero visible products missing active evidence, and zero invalid active evidence rows (including missing source URL/key, non-positive price, non-GBP currency or invalid UK-new condition). LIVE and TEST counts match. Database-only change; no Worker deployment, application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. Used evidence remains reference-only and does not affect automatic valuation.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 14

Added CRKD Gibson Les Paul Cherry Sunburst Pro Edition Collector Bundle Guitar Controller independently to LIVE and TEST with active UK-new GBP Argos evidence at £179.99 (reduced from £199.99), Argos product 848/7292: https://www.argos.co.uk/product/8487292. This is a distinct collector bundle containing Pro Mechanical Neck, Solo Mechanical Neck, branded guitar backpack, strap, pins, cable and stickers; it is not a duplicate of the Alpine White or Blueberry Burst standalone Pro Edition listings. Argos confirms Nintendo Switch 1, Switch OLED and Switch 2 compatibility. Duplicate preflight found no Cherry Sunburst product in either Nintendo Controllers branch; existing CRKD manufacturer rows reused. LIVE product/evidence UUIDs: b29b16fd-2f00-48f1-b89a-5f3ce5032ee5 / 1608ddd6-837f-45e3-ba92-717a748a06d1. TEST product/evidence UUIDs: 64d3d0cd-1a53-4f10-94cd-3261c3a1bafa / 9d5e1bc9-8676-4f17-acfb-4fda75064dcc. Independent verification: LIVE and TEST each have 76 active customer-visible products / 79 active evidence rows, zero visible products missing active evidence and zero invalid active evidence. No Worker deployment, application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. Used evidence remains reference-only and does not affect automatic valuation.


## 3D printer catalogue evidence and package expansion — 5 November 2026 (batch 14)

This was a database-only catalogue update applied independently to TEST and LIVE. The canonical category remains `3d-printers-equipment`. No application code, schema, RLS, valuation logic, Edge Functions, tenants, customers, orders, payments or Worker deployments were changed.

### New products and UK evidence

Added two distinct Original Prusa XL+ printer configurations in both environments:
- XL+ / Two-Toolhead — £2,675 GBP, EDS3D: https://eds3d.co.uk/products/original-prusa-xl-two-toolhead-3d-printer
- XL+ / Five-Toolhead — £3,530 GBP, EDS3D: https://eds3d.co.uk/products/original-prusa-xl-five-toolhead-3d-printer

These are printer configurations, not accessory/upgrade-only records. Their product-specific stock and dispatch timing are not confirmed; the evidence records the reseller's listed prices and the qualification.

Additional UK-new price evidence was attached to existing exact product/package records:
- Bambu Lab P1P — £399; manufacturer page gives conflicting availability (lead-time text says in stock, purchase CTA says sold out).
- QIDI Plus4 — £569; selector says in stock but the embedded product variant reports unavailable.
- Anycubic Photon Mono M5s — £549; official page reports sold out. It remains active because the source did not explicitly confirm discontinuation.
- Bambu Lab X1 Carbon Standard Printer — £919; official page reports sold out and a UK reseller confirms the model is no longer manufactured.
- QIDI Q1 Pro — £299; official UK page confirms discontinued/no longer in production.
- QIDI X-Max 3 — £499; official UK page confirms discontinued/no longer in production and its variant reports unavailable.

All six additional prices are stored as observed UK-new market evidence with availability qualifiers; none is represented as confirmed current stock. QIDI Q1 Pro, QIDI X-Max 3 and both Bambu X1 Carbon packages (Standard Printer and AMS Combo) are inactive and hidden from the customer-facing catalogue. Their historic evidence is retained. QIDI X-Plus 3 remains active; do not mark it discontinued without explicit manufacturer confirmation.

### Stable identifiers

LIVE:
- XL+ Two-Toolhead product `fb964376-c098-4723-a22a-fb5ee12587e5`; evidence `98206eac-d425-47a8-89eb-0ff2b49b5ec4`.
- XL+ Five-Toolhead product `bc3b2121-57af-41ca-a165-02895627cdb9`; evidence `39609ff5-3aab-43ac-9b86-73ef4c076950`.

TEST:
- XL+ Two-Toolhead product `d6b95041-45b3-46c4-9cc2-97828fdab7af`; evidence `387d8e7e-5942-43c6-bd9a-f85c99a175ca`.
- XL+ Five-Toolhead product `2fda6830-8d17-4047-bfd8-e8797337859a`; evidence `4578e7bd-c890-4904-8cb3-1a5960fcf337`.

The six other UK-new evidence records use stable source keys dated 2026-11-05:
`uk-new:bambu-lab:p1p:standard:2026-11-05`,
`uk-new:qidi:plus4:standard:2026-11-05`,
`uk-new:anycubic:photon-mono-m5s:standard:2026-11-05`,
`uk-new:bambu-lab:x1-carbon:standard:2026-11-05`,
`uk-new:qidi:q1-pro:standard:2026-11-05`,
`uk-new:qidi:x-max-3:standard:2026-11-05`.

### Verification and operating rules

Final independent verification:
- LIVE: 162 product rows, 155 active/customer-visible, 7 inactive; 179 active evidence rows (164 UK-new / 15 UK-used), covering 159 products.
- TEST: 163 product rows, 155 active/customer-visible, 8 inactive; 179 active evidence rows (164 UK-new / 15 UK-used), covering 159 products.
- Both environments have zero active visible products without active evidence, zero duplicate active evidence source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency).
- Active catalogue and evidence totals are aligned. TEST has one additional inactive/hidden Creality Ender-3 V3 Neo / Printer only duplicate row with no LIVE counterpart. Retain it hidden; do not delete or reactivate it as part of routine parity work.

All evidence remains UK GBP. UK-used evidence is reference-only and must never feed automatic valuation. Sold-out, discontinued, stale-delivery and stock-conflict listings must retain their explicit availability qualification and must not be presented as confirmed available stock. No Worker deployment is required for these database-only changes.


### Anycubic printer catalogue batch 15 — 5 November 2026
Added Anycubic Kobra 4 / Standard Printer (£279) and Photon Mono 4 Ultra / Standard Resin Printer (£279) to TEST and LIVE. Kobra 4 is separate from the ACE 2 Pro Combo; its UK page shows Early Bird Pre-sale, Add to cart and 24-hour shipping, so fulfilment requires reconfirmation: https://uk.anycubic.com/products/kobra-4-3d-printer. Photon Mono 4 Ultra is standalone; UK page shows Add to cart and a 24-hour shipping estimate, but current stock is not independently reconfirmed: https://uk.anycubic.com/products/photon-mono-4-ultra. Added Photon P1 Max UK-new evidence at £849; the page says Pre Order NEW and its 1–10 October 2026 shipping estimate has passed, so fulfilment is unconfirmed: https://uk.anycubic.com/products/photon-p1-max-best-large-resin-3d-printer. Previous £799 evidence retained. Verification: LIVE 164 product rows / 157 active visible / 182 active evidence (167 UK-new, 15 UK-used); TEST 165 / 157 / 182. Both have zero missing active evidence, duplicate active product/source keys or invalid active evidence. All evidence UK GBP; used evidence is reference-only. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-17.md. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.


### 3D printer catalogue batch 18 — Sovol range and Anycubic Photon P1 configurations (5 November 2026)
Added Sovol as a new master manufacturer and six UK-priced product configurations to TEST and LIVE: SV08 Max Standard (£809), SV08 Max Enclosure Combo (£968), SV08 Standard (£389), SV08 Enclosure Combo (£519), M1D Essential (£1,100), and M1D Advanced (£1,320). All six have official Sovol UK GBP evidence. SV08 Max and SV08 pages show sold-out/notify status; the SV08 mid-October dispatch estimate has passed. M1D is a pre-order with estimated late-November to mid-December 2026 dispatch, but its page also shows sold-out/notify status; do not present as confirmed stock. Sources: https://sovol.uk/products/sovol-sv08-max-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-sv08-3d-printer ; https://sovol.uk/collections/3d-printer/products/sovol-m1d-3d-printer.

Added Anycubic Photon P1 Dual-Color / Dual-Material Platform Bundle as a distinct package configuration (£469 UK-new evidence; official page shows sold out): https://uk.anycubic3d.com/products/photon-p1-dual-color-and-dual-material-printing. Added a fresh 5 November standard Photon P1 UK-new price observation (£449, sold out), retaining the previous 4 November observation rather than overwriting it: https://uk.anycubic3d.com/products/photon-p1-resin-3d-printer.

Verification after this batch: LIVE 171 product rows / 164 active visible / 190 active evidence (175 UK-new, 15 UK-used); TEST 172 / 164 / 190. Both have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid active evidence (missing source URL/key, non-positive price or non-GBP currency). Both contain 14 manufacturers; Sovol has 6 products and Anycubic 21. UK-used evidence remains reference-only and does not affect automatic valuation. Keep sold-out, pre-order and expired-delivery qualifications intact. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.


### Original Nintendo Switch controller catalogue — Batch 15 (5 November 2026)
Added four CRKD NEO S variants independently to LIVE and TEST, each with one active UK-new GBP Selfridges evidence record:
- NEO S Retro Gold Edition — £29.99 (Selfridges reduced from £49.99): https://www.selfridges.com/GB/en/product/crkd-neo-s-retro-gold-edition-nintendo-switch-controller_R04386313/
- NEO S Blossom Edition by POPeART — £29.99 (reduced from £49.99): https://www.selfridges.com/GB/en/product/crkd-neo-s-blossom-edition-by-popeart-nintendo-switch-controller_R04386311/
- NEO S Raven Fortnite Edition with Charging Dock — £34.99 (reduced from £59.99): https://www.selfridges.com/GB/en/product/crkd-neo-s-raven-fortnite-edition-with-charging-dock_R04481400/
- NEO S Rocket League Gold Edition with Charging Dock — £59.99: https://www.selfridges.com/GB/en/product/crkd-neo-s-rocket-league-gold-edition_R04417225/

All four are original Nintendo Switch / Switch OLED-compatible NEO S controllers. The two Fortnite/Rocket League bundles include their respective charging docks; Raven also includes its Viceroy Mark I Glider code. These are separate packages from the previously catalogued Peely and Purple Wave NEO S products. Duplicate preflight found no matching product keys in either environment. Existing CRKD manufacturer records were reused.

LIVE product/evidence UUIDs:
- Retro Gold: da77ef86-a91b-4def-aa75-e3c42f928f42 / 2fcb358c-7aac-49a9-bbf4-d2b13cf13243
- Blossom POPeART: ef09af0b-4c1d-42ef-b3db-07eb0dde67b8 / b76c0ecb-4264-4c35-b1e1-621a5bdfdfdb
- Raven Fortnite Dock: 84bef6bd-225a-4e30-8df2-ee8c263a9a56 / cd2e878b-5dbb-415b-9372-2f0ccd3aa9c8
- Rocket League Gold Dock: 9641c3d3-340a-4b45-bf89-d4de8aeaa294 / c64a1f7f-3c82-4e58-8bfa-70866003efb0

TEST product/evidence UUIDs:
- Retro Gold: d7175a65-077a-4621-bd91-6754b9625d81 / ed9cb5a2-2e72-4124-8e0f-126c3241429e
- Blossom POPeART: e95c93da-3800-43ce-8857-08152c06e1c8 / 315e2a93-e599-4a25-b9a8-06dfebbdbbe4
- Raven Fortnite Dock: 48f8e850-fe20-446e-8d2a-5f8adc4c8332 / 272a8d68-c279-44d2-be69-9983f10d3ac8
- Rocket League Gold Dock: 82346c00-3806-4a28-96f3-e47bd6b59cf0 / 3ebb8d33-f707-4c08-9ce1-b53927f5e4a8

Post-insert independent verification: LIVE and TEST each have 80 active customer-visible products and 83 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type outside UK-new/UK-used, non-GBP currency, non-positive price, missing URL/key, or UK-new condition other than New). The four new records have matching model/package keys, source URLs, evidence types and prices in both environments. All evidence is UK GBP; advertised asking prices are not completed sale prices. Used evidence remains reference-only and does not affect automatic valuation.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment/custom-domain data changed. No Cloudflare Worker deployment is required for these database-only catalogue additions. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-15.md.


### Original Nintendo Switch controller catalogue — Batch 16 (5 November 2026)
Added CRKD NEO S Classic Clear Edition to both LIVE and TEST with active UK-new GBP evidence from Very at £39.99. The Very listing specifies charger included and offers Add to basket: https://www.very.co.uk/crkd-neo-s-classic-clear/1601312390.prd. CRKD's official NEO S product documentation confirms Switch compatibility. Duplicate preflight found no Classic Clear package in either Nintendo Controllers branch; existing CRKD manufacturer rows were reused.

LIVE product/evidence UUID: b6950fc8-ace2-41f8-aabd-7efc9459a8ef / e52a5a16-943a-4e27-9dd6-3d1309186502.
TEST product/evidence UUID: 2ea7b4a3-aa56-47c5-b5f5-419a94eb0f8f / 301369a6-4e1b-44b9-a05b-45bd77b9b55b.

Post-insert verification: LIVE and TEST each have 81 active customer-visible products and 84 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type, currency, price, URL/key and UK-new condition checks). Counts and package identity match across environments. Price is an advertised UK retail asking price, not a completed sale.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-16.md.


### Original Nintendo Switch controller catalogue — Batch 17 (5 November 2026)
Added eight CRKD ATOM Collectible Keychain Controller colour variants independently to LIVE and TEST, each with active UK-new GBP Selfridges evidence at £17.99. Selfridges groups eight colours in one UK listing: https://www.selfridges.com/GB/en/product/crkd-atom-keychain-nintendo-switch-controller_R04386317/. CRKD's official product page confirms Nintendo Switch, PC/Mac, mobile/tablet and Smart TV compatibility, Bluetooth wireless connection, up to 10 hours play time, four shoulder buttons and wrist strap: https://crkd.gg/products/crkd-atom.

The eight catalogue variants use CRKD's official colour names, mapping Selfridges' selector labels Blue/Grey/Pink to Sky Blue/CRKD Grey/Hot Pink respectively:
- Atomic Purple
- Sky Blue
- Glacier Blue
- CRKD Grey
- Leaf Green
- Hot Pink
- PAL Grey
- Yuzu Yellow

The manufacturer lists three additional colours (OG Black, OG Grey and Retro Purple); they were not imported because the current Selfridges listing does not show them among its eight colour options. Continue to seek reliable UK GBP evidence before adding those variants. ATOM Keychain is distinct from the already catalogued ATOM+ Mini.

LIVE product/evidence UUIDs:
- Atomic Purple: 54dbba64-1371-4848-bf3e-0a71c751b3ad / b56648fd-f38b-4680-9424-cadd12f167c4
- Sky Blue: 93f9845c-926e-4691-be35-a5c2665697c2 / 05d8ab9b-7ac0-46c8-ba62-57d5ae27598d
- Glacier Blue: b28a4cd4-4afe-49f9-8fce-fe197e038d13 / 70765841-f17d-4c77-9bec-f9f4c11d00c1
- CRKD Grey: 7046290a-f4b0-404c-b02c-e8be7de1ad01 / 14b6d62f-bb1e-435a-93bc-4c0f146bcfdd
- Leaf Green: 40cc6482-c5fc-421b-8de7-ea9475cf3fbb / ada38578-a6b6-4916-bc08-a0920d55981a
- Hot Pink: 01946bda-895e-4a9e-8eae-21a4c5464dfe / ee9c1af8-93c4-4e48-8374-44f40e0b386c
- PAL Grey: c81b1034-8bc3-43b0-a525-3a72c1b5ef6f / b9e3dc0c-cdfe-4638-bfe0-bb79e6630ca0
- Yuzu Yellow: a6f87157-55df-46b6-97cf-c86fb5174b1c / dcf4770b-43b6-4ade-af9a-d9a0e7e3ba82

TEST product/evidence UUIDs:
- Atomic Purple: 3e9c3dd2-42ba-4c70-b0c9-03c3fa51b27c / 4ad9ea25-6b5e-4fa6-b636-3f495c0362fd
- Sky Blue: 0177d2d6-39b7-48aa-862c-1e1c7eca9abc / 4dc87048-3cb1-4a6c-a6a0-14d6315072ba
- Glacier Blue: b87cecda-aaeb-4140-b613-2ad48e916e17 / 9a877a06-ce60-4743-afe7-902654872b1b
- CRKD Grey: 9b2b0076-dcf8-49bc-9510-5ec37f1f2c85 / f3dc0ac4-54e8-49a1-a4a3-f892c88f78f0
- Leaf Green: 680316a4-cacd-4026-b96a-af390ad5f520 / 655eb17b-268d-4324-a6f5-2c0a42110284
- Hot Pink: b10704db-dff1-4da9-b7e9-2165e1deac87 / 0221d30a-7982-49a1-af39-09888ae26088
- PAL Grey: cedac7ce-b587-4352-ad8f-703a36c25bbd / 95e8103a-ff99-46a7-b439-77504fcccd1a
- Yuzu Yellow: b091e1a5-76c4-43b2-9c99-dae1bcff4153 / 1518490d-57cb-42dd-8ab7-1d183d010079

Post-insert verification: LIVE and TEST each have 89 active customer-visible products and 92 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type, currency, price, URL/key and UK-new condition checks). The eight package keys, prices, source URLs, evidence types and currency match across environments. The £17.99 value is the advertised UK retail asking price for the colour-selectable listing, not a completed sale.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-17.md.


### Original Nintendo Switch controller catalogue — Batch 18 (5 November 2026)
Added three further CRKD NEO S colour variants independently to LIVE and TEST, each with active UK-new GBP marketplace evidence at £39.99:
- Electric Pink — Idealo UK listing: https://www.idealo.co.uk/compare/204670656/crkd-neo-s-electric-pink-edition.html
- Junkyard Edition by POPeART — https://www.idealo.co.uk/compare/204670658/crkd-neo-s-junkyard-edition-by-popeart.html
- Orange Zest Edition — https://www.idealo.co.uk/compare/204670661/crkd-neo-s-orange-zest-edition.html

Idealo's 30 October 2026 08:10 UTC snapshot showed £39.99 marketplace offers from Redoctane Labs Limited and marked these offers in stock. CRKD official NEO S documentation confirms Nintendo Switch compatibility. The evidence observed_at is retained as 30 October 2026 rather than being misrepresented as a 5 November observation. Duplicate preflight found no matching package keys in either environment; existing CRKD manufacturer records were reused.

LIVE product/evidence UUIDs:
- Electric Pink: 12ca0308-984c-4a81-9af3-e25050a3d513 / 6d58f72b-de07-49b5-aeb8-b4c8e871b5ef
- Junkyard POPeART: 3cb09e9d-5426-4d29-a108-3e7c5f465c44 / 5511f3f0-851d-4f9b-8cc8-b83c0aff1098
- Orange Zest: ad5177fa-3957-4b6d-a2d2-bca550b0a3bd / 961f9ad1-cd4b-4231-be26-e6146f2302c2

TEST product/evidence UUIDs:
- Electric Pink: cfa7932b-9578-4331-805f-478b61833869 / 733ce5f7-68ff-4972-8eb7-dab040be5ad0
- Junkyard POPeART: d92a4405-2aba-484b-9ad9-7b3941c16096 / 07dd5c3a-b755-4dbd-a1ec-50136b3d1cc0
- Orange Zest: 98c93a39-16a5-4dbe-a933-ad615a26011a / d252952f-0daa-420c-ba7f-4b340fd4c7d2

Post-insert verification: LIVE and TEST each have 92 active customer-visible products and 95 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type, currency, price, URL/key and UK-new condition checks). New package keys, prices, source URLs, evidence types and currencies match across environments. Evidence prices are advertised marketplace asking prices, not completed sale prices; availability and observation timestamp are retained from the Idealo snapshot.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-18.md.


### Sovol 3D printer catalogue — Batch 19 (5 November 2026)

Added three missing Sovol configurations independently to LIVE and TEST, with active UK-new GBP evidence:
- SV06 ACE / Standard Printer — £210; official UK page https://sovol.uk/products/sovol-sv06-ace. Page displays Sold Out / Notify me alongside conflicting limited-stock wording; availability unconfirmed.
- SV06 ACE / SH02 Filament Box Combo — £269; same official UK page. Page displays Sold Out / Notify me; availability unconfirmed.
- Zero / Standard Printer — £249 sale price; official UK page https://sovol.uk/products/sovol-zero-3d-printer. Page says only 8 left in the UK warehouse but also displays Sold Out / Notify me; availability unconfirmed. Product classified as enclosed CoreXY FDM printer.

LIVE product/evidence UUIDs:
- SV06 ACE Standard: 8453c386-45e0-413b-9f70-43fb428ae919 / 418a0008-2c75-4c2b-a3c8-2c82442794c4
- SV06 ACE SH02 combo: 49872fc8-73c9-43be-8784-c2e5fae98e36 / 48c985f9-531a-4f88-b478-2712a47e26f4
- Zero Standard: 479484f0-eb4b-40cb-ae86-3e0f16f3968c / a9794fb9-f81c-440f-89fe-72d607d7860c

TEST product/evidence UUIDs:
- SV06 ACE Standard: 5c823ba8-8707-4fe4-af76-d69f1d58eaab / 935a6d29-281a-4c16-b0aa-999cef5bb404
- SV06 ACE SH02 combo: 366983ef-d69b-4466-9941-e776934485da / c19f0335-a97a-4bb0-90bd-547a295eafae
- Zero Standard: 2f6670e9-aa1f-4cbf-b6e1-e49d6165724b / 476a0073-7b7f-46ea-a120-861c96ea4e4d

Post-insert read-back, scoped to the 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 174 | 167 | 7 | 193 | 178 | 15 |
| TEST | 175 | 167 | 8 | 193 | 178 | 15 |

Both environments have zero active visible products missing active evidence, zero duplicate active product keys, zero duplicate active evidence source keys, and zero invalid/missing evidence or invalid UK-new evidence. UK-used evidence remains reference-only and does not affect automatic valuation. TEST retains its pre-existing additional hidden product row; no deletion or reactivation was performed. No app code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-19.md.


### Original Nintendo Switch controller catalogue — Batch 19 (5 November 2026)
Added three more CRKD NEO S colour variants independently to LIVE and TEST, each with active UK-new GBP price evidence at £39.99 from the Idealo UK comparison snapshot dated 30 October 2026 08:10 UTC:
- Splatter POPeART Edition — https://www.idealo.co.uk/compare/204670657/crkd-neo-s-splatter-popeart-edition.html
- Atomic Red Edition — https://www.idealo.co.uk/compare/204670659/crkd-neo-s-atomic-red-edition.html
- Emerald Green Edition — https://www.idealo.co.uk/compare/204670660/crkd-neo-s-emerald-green-edition.html

CRKD's official NEO S pages confirm Nintendo Switch compatibility. The Idealo snapshot lists UK prices but does not confirm current stock for these individual variants; availability is therefore explicitly recorded as "Price listed; stock not confirmed". Do not represent these as confirmed in-stock. Duplicate preflight found no matching package keys in either environment; existing CRKD manufacturer rows reused.

LIVE product/evidence UUIDs:
- Splatter POPeART: 1d39bf99-b6fd-4d91-bbc9-25b7511a67dd / 58c15442-6c57-4d8e-af8e-59e798e3152d
- Atomic Red: edbf2936-c65b-437b-8ed8-923d23ec10a1 / 62ae4c1f-bfbe-4c19-80c2-8d8d58fb26e8
- Emerald Green: cc3538ad-119d-4ff7-93d7-ae51f4657994 / 40293a66-11be-4815-9b94-f6ec2c7d7252

TEST product/evidence UUIDs:
- Splatter POPeART: 82b22201-e4cb-4344-9494-af61ecb9f26e / 851a7921-9ac9-4c52-9ed8-aeaf42544bc9
- Atomic Red: b852df42-a66e-4d9c-bdf9-bd9778050c45 / 61ac340c-e38c-4ae0-bbf9-2930bd26a7a2
- Emerald Green: c24b0c65-998d-4a09-83e4-bafa54c18a6c / a520665e-2721-4ca2-8d27-9629efabcaaa

Post-insert verification: LIVE and TEST each have 95 active customer-visible products and 98 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type, currency, price, URL/key and UK-new condition checks). The three package keys, prices, source URLs, evidence types and currency match across environments. Price evidence is an advertised marketplace asking price, not a completed sale; source observation date and stock qualification are retained.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-19.md.


### Original Nintendo Switch controller catalogue — Batch 20 (5 November 2026)
Added two official Nintendo Joy-Con pairs to LIVE and TEST with active UK-new GBP Play Pixels evidence at £64.99 each (reduced from £79.99; retailer listing states in stock):
- Neon Green / Neon Pink — SKU 12630, EAN 045496430795, MPN HAC-A-JAFAA(EUR): https://www.playpixels.co.uk/products/nintendo-official-switch-joy-con-controller-pair-neon-green-neon-pink-switch
- Pastel Pink / Pastel Yellow — SKU 29548, EAN 4902370551112, MPN HAC-A-JAVAF: https://www.playpixels.co.uk/collections/nintendo-switch-controllers-switch/products/nintendo-official-switch-joy-con-controller-pair-neon-pink-neon-yellow

Both listings confirm original Nintendo Switch compatibility, wireless Bluetooth, motion controls and rechargeable Joy-Con batteries. The Pastel Pink/Yellow listing notes that Japanese-language packaging may be supplied, while confirming compatibility with UK Switch consoles. Duplicate preflight found neither package in either Nintendo Controllers branch; existing Nintendo manufacturer rows reused.

LIVE product/evidence UUIDs:
- Neon Green/Pink: ae5792ab-3381-4c27-95f7-bffa34beda98 / dc4bed85-04f4-4157-8966-71ceebd8d995
- Pastel Pink/Yellow: ec23eb67-b0a5-4188-8d80-b2b5bbbbc125 / 776ae77c-0189-472a-9c97-2888a1e4fad5

TEST product/evidence UUIDs:
- Neon Green/Pink: af3e7838-fa68-4a1e-b4a9-2190bc25f00e / 935c0dad-e609-4816-90a4-e6cd03a5c376
- Pastel Pink/Yellow: 6281fcf8-3be0-4f01-867f-eeb27e2bd519 / 79613d19-33bc-47e3-9c23-2adc88f4de62

Post-insert verification: LIVE and TEST each have 97 active customer-visible products and 100 active evidence rows. Both have zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence (evidence type, currency, price, URL/key and UK-new condition checks). The two package keys, prices, source URLs, evidence types and currencies match across environments. Prices are advertised retail asking prices, not completed sales.

Nintendo's official accessories catalogue also identifies other Joy-Con colour pairings, including Grey, Neon Yellow/Neon Yellow, and the pastel pairs. Existing Purple/Green and Purple/Orange records appear to correspond to the Pastel Purple/Pastel Green and Neon Purple/Neon Orange families, but retain their current package identities until their exact source evidence is reconciled. Continue researching missing official colour variants with UK GBP evidence.

No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-20.md.


### WEEFUN 3D printer catalogue — Batch 20 (5 November 2026)

Added WEEFUN as a distinct manufacturer and four compact FDM printer configurations independently to LIVE and TEST, each with active UK-new GBP marketplace evidence:
- Tina2 / Standard Printer — £164.59; UK Amazon price-tracker listing: https://www.3dprinterdeals.co.uk/printers/brand/weefun
- TINA2C / Standard Printer — £179.99; UK offer tracker: https://www.3d-pioneer.com/en/printers/weefun-tina2c
- TINA2S / Standard Printer — £217.79; UK offer tracker: https://www.3d-pioneer.com/en/printers/weefun-tina2s
- Tina2 Plus / Standard Printer — £219.54; UK Amazon price-tracker listing: https://www.3dprinterdeals.co.uk/printers/brand/weefun

These are Amazon UK new-offer asking prices surfaced by third-party trackers, not manufacturer-direct prices. Evidence notes explicitly require seller, delivery and checkout-price verification. WEEFUN is recorded as the marketplace-listed brand. ENTINA Tina2C/Tina2 Plus listings were not merged into WEEFUN or added as duplicate models in this batch; brand identity and exact product equivalence remain to be reconciled before adding ENTINA.

LIVE manufacturer UUID: 1e398b32-e14f-4c96-b0dc-9f6fc2a74d32.
LIVE product/evidence UUIDs:
- Tina2: b36f86b5-0046-4fd8-8ee5-6898b0328264 / 96aab21d-3724-4c79-a124-d0f06a9cb457
- TINA2C: a13f221b-2af6-434d-a13d-a8ab9ba6ea7e / eacafdf5-4584-4894-a087-7c08bf6f46f8
- TINA2S: 101eb395-98d1-4cf7-9fd9-6af8359aeb76 / b0a5bf55-05f9-4957-8a00-bff649cbfd73
- Tina2 Plus: d3af1d04-f14e-4e5e-984c-625cbc317aa3 / 2ba35afa-4607-403b-9c62-a65b7d1d7623

TEST manufacturer UUID: 2ba8e6a5-490c-48b0-b8c4-035d171d5ed5.
TEST product/evidence UUIDs:
- Tina2: 666224ff-85b9-4f69-ac75-49bfbc967533 / d761a9eb-215f-4122-9ef1-0c01f8e3567e
- TINA2C: 9bfc345e-ffb9-4185-9f41-0b30cc06b4c4 / 5ebc4577-ca76-4402-b8ab-1ee4a5682954
- TINA2S: 879fe4c9-25ec-4f69-87b6-fb116b35686d / 747d14eb-13da-4df9-9918-5129ecfa9065
- Tina2 Plus: 0d46c5f0-4355-49ef-b338-8026d85fdb6d / 1a82fce8-8ffe-4828-bb6b-e39aabffa894

Post-insert read-back, scoped to the 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 178 | 171 | 7 | 197 | 182 | 15 |
| TEST | 179 | 171 | 8 | 197 | 182 | 15 |

Both environments have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid/missing evidence. UK-used evidence remains reference-only and does not affect automatic valuation. No application code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment/custom-domain data changed. No Worker deployment required. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-20.md.


### ENTINA / WEEFUN Tina2 naming and duplicate-key review — Batch 21 (5 November 2026)

Researched ENTINA's official Tina2C/Tina2 Plus/Tina2S lineup and WEEFUN's own Tina2C/Tina2S pages. ENTINA Tina2C has a UK Amazon tracker observation at £208.00 (new condition; last seen approximately 31 October 2026): https://www.3dprinterdeals.co.uk/item/entina-tina2c-3d-printer-friendly-for-beginners-ready-to-print-in-5/B0GQSR943V. ENTINA's official product page confirms the separate ENTINA brand and the Tina2C model: https://www.entina3d.com/products/entina-3d-printer-tina2c.

A trial ENTINA Tina2C master row and evidence record were inserted and immediately reverted in both environments after the global branch-level duplicate-key check identified the same model/package key as the already-catalogued WEEFUN TINA2C. No ENTINA product/evidence row remains, and no manufacturer row remains from that trial. This avoids leaving duplicate product keys or claiming the two brand listings are separate hardware without a confirmed model distinction. The existing WEEFUN TINA2C remains unchanged. Revisit only if the catalogue key strategy is deliberately extended to support same-model brand variants or reliable evidence proves a distinct configuration.

Post-revert verification remains unchanged from Batch 20: LIVE 178 products / 171 active visible / 197 active evidence (182 UK-new, 15 UK-used); TEST 179 / 171 / 197. Both have zero missing active visible evidence and zero duplicate product keys. No Worker deployment or app/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-21.md.


## Nintendo controller catalogue expansion — 5 November 2026

The Nintendo Controllers master-catalogue branch received two additional verified HORI products in both TEST and LIVE:

- HORI Mario Kart Racing Wheel Pro Mini for Nintendo Switch 2 — Red (EAN-13 4961818042445).
- HORI Mario Kart Racing Wheel Pro Deluxe for Nintendo Switch 2 — Red & Black (EAN-13 4961818042469).

Both are active and customer-visible, assigned to the existing Nintendo Controllers branch, and recorded as controller products. Each has two UK-new retail evidence observations dated 5 November 2026:

- Pro Mini: Smyths Toys UK £69.99; Argos £74.99.
- Pro Deluxe: Very £104.99; Argos £119.99.

Evidence is GBP, New condition, with retailer source URLs and source-record keys. Product identifiers are recorded against the master products. No UK-used evidence was added; existing UK-used evidence remains reference-only and must not affect automatic valuation.

Verified result in each environment after the update: 99 active/customer-visible Nintendo controller products; 102 active UK-new evidence rows covering all 99 products; 2 active UK-used evidence rows covering 2 products. There are zero active visible products missing any active evidence or UK-new evidence. TEST and LIVE counts and research rows match.

An existing package-key collision remains: two older records in this branch use the generic key `single-controller`. It predates this batch and was not changed because the records were not established as duplicate products. Do not delete or merge them without checking their actual model/package identity and prior history. The two HORI additions use distinct product-specific package keys.

This was a database-only catalogue/evidence update. No Worker deployment, application-code change, schema migration, tenant/customer/order/payment change, or valuation-rule change was made.


## Additional Nintendo controller products — 5 November 2026

Two further products were added independently to the TEST and LIVE Nintendo Controllers branches:

- Nintendo Switch 2 Pro Controller — Resident Evil Requiem Edition. EAN-13 0045496321840. UK-new observations: Argos £69.99, Currys £74.99, Very £83.99.
- Nintendo GameCube (GCN) Controller — Nintendo Classics. Nintendo Store UK £58.99. This is a Nintendo Switch 2 wireless controller, exclusive to Nintendo Switch Online members; the Nintendo Store item identifier is recorded as a non-GTIN identifier.

All four observations are dated 5 November 2026 and include source links. Both products are active/customer-visible and have active UK-new evidence. The GameCube membership restriction is retained in the product notes.

Post-update verified totals in each environment: 101 active/customer-visible Nintendo controller products; 106 active UK-new evidence rows covering all 101 products; 2 active UK-used reference rows covering 2 products. No active visible product is missing active evidence or UK-new evidence. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment change was made.


### Geeetech and Artillery 3D printer additions — Batch 22 (5 November 2026)

Added three distinct printer configurations independently to LIVE and TEST, with active UK-new GBP evidence:
- Geeetech M1S / Standard Printer — £185.00, official Geeetech GBP store listing: https://www.geeetech.com/index.php?currency=GBP&main_page=product_info&products_id=1085. The page has a ship-from selector; verify UK warehouse selection and checkout total.
- Artillery M1 Pro / Standard Printer — £299.00 sale price (£349.00 regular), official UK page https://uk.artillery3d.com/products/m1-carbon. Page reports Out of stock.
- Artillery M1 Pro S1 / Standard Printer — £319.00 sale price (£349.00 regular), official UK page https://uk.artillery3d.com/products/m1-pro-s1. Page reports Out of stock.

Stock status for both Artillery models is explicitly recorded as out of stock; prices are current official UK observations, not claims of availability. Geeetech M1 (non-S1) was not added because the GBP price evidence varied between £128 and £150 in different captures; defer until price and source page are reconciled. Artillery Sidewinder X4/X3 variants were not added because the official product-series listing marks them sold out and no reliable current UK printer price was established in this batch.

LIVE IDs:
- Geeetech manufacturer dc71aafe-1eec-43d4-832e-2f37918455ee; M1S product 16387858-242f-4ed3-962a-4262250e0af6; evidence dec25b70-c9c5-4d5c-8d7a-ddab4c74e63e.
- Artillery manufacturer 6ade46dc-dd65-4b96-948c-050c5678ad97; M1 Pro product 03f5d9f9-cf09-4ffc-85d8-87eb81972402; evidence bddeb903-6c0c-4586-875b-0f0ad6b68fda.
- M1 Pro S1 product 9a2cec2d-b2f2-4dcf-b9f3-7f82b23b5c6f; evidence 4fe5e6bf-ab50-463e-b1a1-be0058584db1.

TEST IDs:
- Geeetech manufacturer 6bf26f3d-805a-44f2-9655-b36a84b40fdc; M1S product d2c6a15b-3e58-4ff0-8342-3605457f7462; evidence 38f855d6-4d22-4893-af4e-772e30558a9f.
- Artillery manufacturer 4f7a1362-534e-4ccd-9c32-0c61667a82f3; M1 Pro product 8ca46de2-cc0d-495f-8b78-bd14a7397a7f; evidence 41c13355-eddc-40eb-a4a3-d435ac347bc7.
- M1 Pro S1 product e85b8a23-6862-4439-863c-fddf1ed75d78; evidence 214de6e3-84af-46b6-91ac-4c19c63ff874.

Post-insert read-back, scoped to 3D Printers branch:
| Environment | Products | Active visible | Inactive/hidden | Active evidence | UK-new | UK-used |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 181 | 174 | 7 | 200 | 185 | 15 |
| TEST | 182 | 174 | 8 | 200 | 185 | 15 |

Both environments have zero active visible products missing evidence, zero duplicate active product keys, zero duplicate active evidence source keys and zero invalid/missing evidence. UK-used evidence remains reference-only and does not affect automatic valuation. No app code, schema, valuation logic, RLS, Edge Functions, Stripe or tenant/customer/order/payment data changed. No Worker deployment. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-22.md.


## Nintendo Switch 2 controller accessories — 5 November 2026

Two official Nintendo Switch 2 controller accessories were added independently to TEST and LIVE under Gaming Consoles & Accessories / Gaming / Controller:

- Nintendo Switch 2 Joy-Con 2 Wheel Pair — one light blue and one light red steering-wheel attachment. Argos UK-new evidence: £16.99, https://www.argos.co.uk/product/7624661/. EAN-13 0045496321383 verified from Argos listing and recorded in TEST identifiers.
- Nintendo Switch 2 Joy-Con 2 Charging Grip — black grip with USB charging cable and mappable GL/GR buttons. Argos £29.99, https://www.argos.co.uk/product/7624692/; John Lewis £25.99, https://www.johnlewis.com/nintendo-joy-con-2-charging-grip-black/p113587848. EAN-13 0045496321376 verified from Argos listing and recorded in TEST and LIVE identifiers.

The Joy-Con 2 wheels do not include controllers and are only for Joy-Con 2. The charging grip also excludes Joy-Con 2 controllers and is not compatible with original Switch Joy-Con. Both records are active/customer-visible. Three UK-new evidence rows were recorded per environment, GBP/New with source URLs and 5 November 2026 observation timestamps.

Current verified Nintendo Controllers totals in both environments: 103 active/customer-visible products; 109 active UK-new evidence rows covering all 103 products; 2 active UK-used reference rows covering 2 products. No active visible product is missing active evidence or UK-new evidence. This supersedes the prior 101 products / 106 UK-new evidence totals. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment change was made.


## PlayStation controller batch — 5 November 2026
Five DualSense models were added in TEST and LIVE: Midnight Black £59.99, Starlight Blue £59.99, Cosmic Red £59.99, Nova Pink £59.99 and Chroma Teal £64.99, each with UK-new Argos evidence. Both branches now have 16 active products and 15 UK-new evidence rows covering 15 products. One older DualShock 3 record has no UK-new evidence and is retained for legacy review. No deployment or code/schema/valuation changes.


## PlayStation pre-order batch — 5 November 2026
Added DualSense Edge Midnight Black (£189.99 Argos), GTA VI Black Limited Edition (£74.99 pre-order) and GTA VI White Limited Edition (£74.99 pre-order) to TEST and LIVE. GTA VI editions release 19 November 2026. Final verified totals match: 19 active products and 19 UK-new evidence rows covering 18 products. One legacy DualShock 3 Black remains without UK-new evidence. No deployment or code/schema changes.


## PlayStation Gran Turismo Limited Edition — 5 November 2026

Added independently to TEST and LIVE: DualSense Wireless Controller - Gran Turismo Limited Edition, model CFI-ZCT2WZMX, UK pre-order price £74.99, release date 10 December 2026. Three active UK-new GBP/New Retail pre-order evidence rows per environment:
- PlayStation Direct: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/gran-turismo-limited-edition/
- Argos: https://www.argos.co.uk/product/9906844 (EAN 711719072836 verified from retailer listing)
- Smyths Toys: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/playstation-5/playstation-5-accessories/playstation-5-dualsense-wireless-controller-gran-turismo-limited-edition/p/266465

Product active/customer-visible in both environments. Product IDs: TEST 777420ef-7ac3-4151-ae40-9691eeba3493; LIVE 3892048b-c072-421c-be1a-78181e7785ef. Verified branch totals in each environment: 20 active/customer-visible products, 22 active UK-new evidence rows covering 19 products. The legacy Sony DualShock 3 Wireless Controller - Black remains the one product without UK-new evidence and is retained for legacy/discontinued review. No Worker deployment, app code/schema/valuation/RLS/Edge Function, tenant/customer/order/payment/Stripe changes. TEST and LIVE updated independently.


## 3D printer catalogue continuation — ELEGOO and FLSUN batch (5 November 2026)

Added and evidenced three previously missing ELEGOO configurations independently in LIVE and TEST:
- Centauri Carbon 2 standard (without CANVAS): £259.00 GBP; https://uk.elegoo.com/products/centauri-carbon-2
- Centauri 2 standard (without CANVAS): £179.00 GBP; https://uk.elegoo.com/products/centauri-2
- Centauri 2 CANVAS 4-colour Combo: £219.00 GBP; https://uk.elegoo.com/products/centauri-2-combo
The existing Centauri Carbon 2 CANVAS combo was already present in both environments and was not duplicated. Official ELEGOO UK pages show the UK shipping territory and pricing; checkout shipping is calculated separately. Source prices observed 5 November 2026.

Product/evidence IDs — LIVE:
- Centauri Carbon 2 standard: product 5063b4eb-0300-4fdc-9845-2f90c4d42764; evidence c35bab99-2ec6-4d43-b76e-ef093e1f2724.
- Centauri 2 standard: product 6d562965-b9a7-4f89-a495-24b32993a26c; evidence e50b55df-65ee-4db8-818f-47b7c3222d58.
- Centauri 2 CANVAS combo: product 9b3dc3cb-9e64-4253-b389-9f27bbaa61ee; evidence b5312394-0f51-4815-8c0b-cc727f6e6f12.

Product/evidence IDs — TEST:
- Centauri Carbon 2 standard: product f5b16bc4-23ed-4406-b1cc-1c26ef57aefe; evidence fe2eeabd-5d76-4f4c-a44b-7a3e97860af8.
- Centauri 2 standard: product 9c1be54d-8251-432a-96f3-77dc428d11cf; evidence f004ef0f-47e1-4eee-9ecc-2e4c5cb85bb4.
- Centauri 2 CANVAS combo: product 39cce755-195f-48a9-ab45-06106460bbba; evidence e03010e5-ebd4-4725-9189-b9702aaa388c.

Resolved the incomplete FLSUN T1 MAX record from the previous continuation. The official FLSUN UK collection lists £459.00 sale / £599.00 regular and marks it in stock: https://uk.store.flsun3d.com/collections/3d-printer-new. Evidence is now present in both environments. LIVE product a22e38a9-8de5-4bdf-a3ab-4b5e110ee101 / evidence 2f51f375-8931-4b1e-aa43-49bf6809217c. TEST product 5d1797a2-0f28-4efb-8d31-e318ee2da3bf / evidence 7d21abe5-21b2-4b59-ac75-52150d52050e. Product notes were corrected to match the current official collection's in-stock status.

Verified 3D Printers branch totals after inserts:
| Environment | Products | Active visible | Active evidence | UK-new | Missing visible evidence |
|---|---:|---:|---:|---:|---:|
| LIVE | 185 | 178 | 204 | 189 | 0 |
| TEST | 186 | 178 | 204 | 189 | 0 |

Both environments: zero duplicate active product keys and zero duplicate active evidence source keys. Previous hidden/inactive counts remain 7 LIVE and 8 TEST. UK-used evidence remains reference-only and excluded from automatic valuation. TEST and LIVE were updated independently. No application code, schema, valuation logic, RLS, Edge Functions, Worker, Stripe, tenant/customer/order/payment data changed. No Worker deployment required.

## PlayStation additional special editions — 5 November 2026
Added independently in TEST and LIVE:
- DualSense Wireless Controller - Icon Blue Special Edition, model CFI-ZCT2WZBX, £74.99; two active UK-new GBP/New Retail evidence rows from PlayStation UK and PlayStation Direct.
- DualSense Wireless Controller - Marvel's Wolverine Adamantium Limited Edition, model CFI-ZCT2WZKX, £74.99; two active UK-new GBP/New Retail evidence rows from PlayStation UK and PlayStation Direct.

Direct evidence URLs:
- Icon Blue: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/icon-blue-special-edition/ and https://direct.playstation.com/en-gb/buy-accessories/dualsense-wireless-controller-icon-blue-special-edition-for-ps5-pc-mac-mobile
- Wolverine Adamantium: https://www.playstation.com/en-gb/accessories/dualsense-wireless-controller/buy-now/product/marvels-wolverine-adamantium-limited-edition/ and https://direct.playstation.com/en-gb/buy-accessories/dualsense-wireless-controller-marvels-wolverine-adamantium-limited-edition-for-ps5-pc-mac-mobile

Combined with the Gran Turismo Limited Edition batch, verified TEST and LIVE branch totals now match at 22 active/customer-visible products and 26 active UK-new evidence rows covering 21 products. The only uncovered product remains the pre-existing Sony DualShock 3 Wireless Controller - Black. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes.


## Creality Ender-3 V3 Neo evidence and CFS nano combo — 5 November 2026

The existing Ender-3 V3 Neo standard printer record was confirmed in both environments and refreshed with the current official UK printer-only price £199.00. Added a distinct CFS nano four-colour Combo configuration at £289.00; official product page labels the combo as pre-order and includes a 2 kg filament promotion. Source: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer. The official Creality UK comparison article (20 October 2026) distinguishes the Neo and Mega specifications and quotes Neo £199 / Mega £519: https://store.creality.com/uk/blogs/buying-guides/ender-3-v3-neo-vs-mega. Ender-3 V3 Mega was not added in this batch because current UK listing presents it as a promotional filament bundle from £519 and a clean printer-only / combo split was not sufficiently confirmed.

LIVE: existing Neo standard product b2c3d4e5-6f70-489a-8123-000000000101 refreshed evidence 4c43d533-c79d-48b0-ae4f-096bec842734 (£199); new CFS nano combo product 2c3eaeea-7828-4289-9e3b-5fb0eefd65c6 / evidence 2b52ae5c-d138-47b7-bade-9a8fe5c0d171 (£289).
TEST: existing Neo standard product a1b2c3d4-5e6f-4789-9012-000000000101 refreshed evidence 20fda591-e7d9-4102-8a3a-e8fbc141ad41 (£199); new CFS nano combo product e26954ad-9225-4195-9a18-757163eb8e64 / evidence 1fb1de2e-410e-4806-8311-e22c0a227dd7 (£289).

Verified totals after this addition: LIVE 186 products / 179 active visible / 206 active evidence / 191 UK-new; TEST 187 products / 179 active visible / 206 active evidence / 191 UK-new. Both environments have zero active visible products missing active evidence. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.

## Xbox controller expansion — 5 November 2026

Added independently in TEST and LIVE under the existing Xbox Controllers branch: Ice Breaker, Heart Breaker and Storm Breaker Special Editions (Microsoft Store £64.99 each); Gears of War E-Day Limited Edition (Smyths £79.99, John Lewis and Microsoft Store £84.99); Forza Horizon 6 Limited Edition (Argos £69.99, Currys £84.99). All five are active/customer-visible with active UK-new GBP/New Retail evidence, direct source URLs, stable source_record_key and 5 November 2026 observation dates. Microsoft's Breaker page exposes the three variants as selectable configurations. Gears of War E-Day's Microsoft page still showed a pre-order CTA after the stated 29 September release, so evidence availability is Listed, not in-stock. Forza Horizon 6 released 21 May 2026.

Verified TEST and LIVE each: 20 active/customer-visible Xbox controller products; 23 active UK-new evidence rows covering all 20 products; zero visible products missing UK-new evidence. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes. TEST and LIVE updated independently.


## Bambu Lab H3C addition — 5 November 2026

Added Bambu Lab H3C with AMS H3 Combo as a distinct package in both LIVE and TEST. Bambu Lab's official launch post dated 3 November 2026 explicitly lists the UK H3C + AMS H3 price at £2,199 including tax. Source: https://blog.bambulab.com/tool-changer-game-changer-bambu-lab-presents-h3c-the-defining-new-generation-of-3d-printers/. This is a bundled configuration; no standalone printer price is inferred. Availability and dispatch timing are recorded as requiring confirmation on the UK store.

LIVE product e33286e7-1083-41e5-8677-ce147bf754cd; evidence bf9e3cba-d469-43d3-a0b2-5bf75b9f2bf3. TEST product 9149695d-2cd7-428c-bf52-b22ac3d85245; evidence aeb43102-77aa-4934-bfd3-42ea0463bd65.

Verified 3D Printers totals after this addition: LIVE 187 products / 180 active visible / 207 active evidence / 192 UK-new; TEST 188 products / 180 active visible / 207 active evidence / 192 UK-new. Both environments have zero active visible products missing active evidence. Other recently released models in the catalogue were checked (Bambu A2L and X2D, Anycubic Kobra S1 Max and Kobra X, Flashforge Creator 5 and Creator 5 Pro, Prusa CORE One L+ and XL+); existing product records and current UK-new evidence were present, so no duplicates were created. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.

## Xbox controller expansion batch 2 — 5 November 2026

Added independently to TEST and LIVE:
- Xbox Wireless Controller - X25 Special Edition — £74.99, UK-new evidence from Currys, Microsoft Store and Argos; OG Green translucent 25th anniversary edition, Currys product code 618171.
- GameSir G7 Pro Xbox & PC Wired Controller - White — £89.99 Argos; EAN 6936685222267.
- GameSir G7 SE Xbox Wired Controller - White — Argos £49.99 and B&Q £44.99; EAN 6936685220676.
- GameSir G7 SE Xbox Wired Controller - Grey — Argos £49.99; EAN 6936685221642.
- Xbox Wireless Controller - Robot White — £49.99 Argos; EAN 889842611564.
- Xbox Wireless Controller - Pulse Red — £49.99 Argos; EAN 889842707113.
- Xbox Wireless Controller - Velocity Green — £49.99 Argos; EAN 889842896480.
- Xbox Wireless Controller - Deep Pink — £49.99 Argos; EAN 889842875577.

All eight products are active/customer-visible with active UK-new GBP/New Retail evidence and stable source_record_key values. TEST and LIVE final read-back both verify 28 active/customer-visible Xbox controller products and 34 active UK-new evidence rows covering all 28 products. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes. TEST and LIVE were updated independently.


## Creality Ender-3 V4 Combo and Bambu Lab H3C — 5 November 2026

Added Bambu Lab H3C + AMS H3 Combo at the official UK launch price £2,199 including tax (official announcement 3 November 2026): https://blog.bambulab.com/tool-changer-game-changer-bambu-lab-presents-h3c-the-defining-new-generation-of-3d-printers/. LIVE product/evidence e33286e7-1083-41e5-8677-ce147bf754cd / bf9e3cba-d469-43d3-a0b2-5bf75b9f2bf3; TEST 9149695d-2cd7-428c-bf52-b22ac3d85245 / aeb43102-77aa-4934-bfd3-42ea0463bd65. This is the AMS H3 combo, not a standalone price.

Added Creality Ender-3 V4 CFS Combo using GM Crafts UK evidence £289 (was £349), Add to basket and free UK delivery: https://www.gmcrafts.co.uk/product/creality-ender-3-v4-combo/. LIVE product/evidence bbf4ef13-c073-4fe2-a1ed-54975e9151a8 / 401c9eaf-6153-45ab-add1-2f7bdcbbed30; TEST 2bcf22b1-a2fa-412c-81d8-6e074e95fd81 / 9a9177a2-e720-4e8a-8caa-f50771be7029.

Verified 3D Printers totals: LIVE 188 products / 181 active visible / 208 active evidence / 193 UK-new; TEST 189 / 181 / 208 / 193. Zero visible products missing active evidence in either environment. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment.

## Further 3D printer catalogue continuation — 5 November 2026

Added Flashforge Adventurer 5X independently to LIVE and TEST. The official Flashforge UK store lists £279.00 GBP, reduced from £449.00, as its entry-level multicolour printer. Source: https://uk.flashforge.com/ (official UK store homepage). Price observed 5 November 2026; delivery and final checkout availability to be confirmed in checkout.
- LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874; evidence 219b6262-fd23-4329-b22c-904387ea8e80.
- TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220; evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Also completed the prior Creality Ender-3 V4 CFS Combo addition at £289.00, sourced from GM Crafts UK (https://www.gmcrafts.co.uk/product/creality-ender-3-v4-combo/), with Add to Basket and free UK delivery shown. LIVE product bbf4ef13-c073-4fe2-a1ed-54975e9151a8 / evidence 401c9eaf-6153-45ab-add1-2f7bdcbbed30; TEST product 2bcf22b1-a2fa-412c-81d8-6e074e95fd81 / evidence 9a9177a2-e720-4e8a-8caa-f50771be7029.

Verified recent-model coverage: Creality HALOT-X1 Neo and HALOT-X1 Max already have current UK-new evidence in both environments (Neo £199; Max £1,599); Flashforge CJ270 already exists with UK-new evidence; Anycubic Kobra 3 Max V2 standard and combo and Photon P1 Max already exist with active UK-new evidence; no duplicates were added. Existing Bambu Lab A2L/X2D, Anycubic Kobra S1 Max/Kobra X, Flashforge Creator 5/Creator 5 Pro, and Prusa CORE One L+/XL+ were also confirmed present with active UK-new evidence in the previous check. UK-new evidence remains the price source; UK-used stays reference-only.

Verified 3D Printers totals after this continuation:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Visible products missing evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 189 | 182 | 209 | 194 | 15 | 0 |
| TEST | 190 | 182 | 209 | 194 | 15 | 0 |

Both environments: zero duplicate product keys. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required. TEST and LIVE were updated independently.

## Additional 3D printer catalogue additions — 5 November 2026

Added Flashforge Adventurer 5X standard multicolour printer at £279.00 GBP (official UK store price reduced from £449.00): https://uk.flashforge.com/. LIVE product 3200eb99-8cf7-46dc-bad8-b3cfa8b8d874 / evidence 219b6262-fd23-4329-b22c-904387ea8e80; TEST product 7f266b64-c0c2-4dd1-80fc-fea0e1761220 / evidence 8114b3fd-0d2c-4b9d-8fc5-281b33dc889b.

Added distinct Anycubic Kobra X Combo (base 7-colour package, expandable to 19 colours) at £429.00 GBP: https://uk.anycubic.com/products/kobra-x-combo-3d-printer. Official product page states ships in 24 hours and free express shipping. LIVE product 634078d8-39d8-4bf1-b01a-c391f481d4ec / evidence 14e0207a-f4d0-4d17-bd1b-9bc52078a976; TEST product 834e5612-67da-4ad2-be67-1bf4b638ea7d / evidence da4e3863-e612-4654-b706-69fe76cf3e20.

Also completed the previous Ender-3 V4 CFS Combo addition at £289.00 from GM Crafts UK; product/evidence IDs and source are recorded in the immediately preceding continuation section. Verified that HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) already have current UK-new evidence in both environments; no duplicates were created. Flashforge CJ270 and Anycubic Kobra 3 Max V2 / Photon P1 Max already have active UK-new evidence in both environments.

Verified 3D Printers totals after this batch:
| Environment | Products | Active visible | Active evidence | UK-new | UK-used | Missing visible evidence |
|---|---:|---:|---:|---:|---:|---:|
| LIVE | 190 | 183 | 210 | 195 | 15 | 0 |
| TEST | 191 | 183 | 210 | 195 | 15 | 0 |

Both environments have zero duplicate product keys and zero active visible products missing evidence. UK-used remains reference-only and excluded from automatic valuation. LIVE and TEST were updated independently. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant/customer/order/payment changes. No Worker deployment required.

## Gaming console catalogue continuation — 5 November 2026

The Gaming Consoles & Accessories catalogue was continued in both TEST and LIVE. A separate Nintendo Switch 2 The Legend of Zelda 40th Anniversary 256GB console master was added at £429.99 UK-new (Smyths Toys UK). The existing Zelda 40th Anniversary Pro Controller now has three independent retailer observations: Argos £64.99, Currys £74.99 and Smyths £79.99. Xbox Wireless Controller — Shock Blue was mirrored from TEST into LIVE with its £59.99 Argos UK-new evidence. Three exact PlayStation handheld observations (PSP-2000 £69.43 sold, PSP Go £140 listed, PS Vita OLED £138.98 sold) were mirrored into LIVE. Three existing evidence rows with null URLs were repaired using direct retailer URLs.

Final independent verification in both environments: 277 active master products, 269 active customer-visible products, 376 active evidence rows (211 UK-new / 165 UK-used), one visible product without any evidence, zero evidence integrity failures and zero duplicate active source keys. The single no-evidence product is WD_BLACK C50 Expansion Card 512GB (Xbox Accessories); continue sourcing an exact UK price rather than inventing one. A further 85 visible products lack UK-new evidence; do not infer new prices for older/used-only products.

All additions are separate environment-specific records. UK-used evidence remains reference-only and does not affect automatic buying valuation. Database-only work: no app code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment or Cloudflare Worker changes; no Worker deployment. Exact IDs and source keys are in `CHECKPOINTS/2026-11-05-gaming-console-catalogue-continuation-batch-01.md` and the aggregate gaming memory file.


### WD_BLACK C50 512GB evidence gap closed — 5 November 2026

Added the missing UK-new observation for the exact WD_BLACK C50 Expansion Card 512GB product in TEST and LIVE at £169.99. Source: disks.co.uk Amazon UK price tracker, https://www.disks.co.uk/drive/wd-black-c50-storage-expansion-card-for-xbox-series-x/B0C44B1VSH. Stable key: disksco-wd-black-c50-512gb-uk-new-20261105. LIVE evidence fbe726d0-7a02-4652-ae29-84468640d38c; TEST evidence 107c14fb-5c2a-4921-b858-a36a8a35a477. The tracker states its Amazon UK feed refreshed within minutes, but the Amazon detail page was not independently accessible during capture. The £169.99 observation is 55.4% above the displayed 30-day average (£109.37); retain the caveat and do not treat it as a representative market value or confirmed checkout price.

Final gaming catalogue verification now matches in both environments: 277 active products, 269 active visible products, 377 active evidence rows (212 UK-new / 165 UK-used), zero visible products missing all evidence, zero active evidence integrity failures and zero duplicate active source keys. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/Worker changes; no deployment. Updated checkpoint and aggregate memory record the exact IDs and caveat.

 
## Gaming catalogue continuation — batch 02, 5 November 2026

Added six new active, customer-visible gaming master products across Nintendo Switch 2 controllers and accessories in both TEST and LIVE: PowerA Pokémon Mega Evolutions controller (£39.99), Venom 10-in-1 sports pack (£29.99), PowerA Mario & Yoshi wireless controller (£39.99), PowerA Dark Heather Grey Slim Case (£14.99), PowerA Mario & Yoshi Protection Case (£14.99 promotional price) and SanDisk Mario 256GB microSD Express card (£44.99). Each has a Smyths UK-new evidence row and an exact package key. Existing records were checked first; no duplicate product masters were created.

Added further Smyths/Argos UK-new evidence to existing masters: Joy-Con 2 Light Purple/Light Green pair (Smyths £64.99; Argos £64.95 retained), Gioteck WX5+ Dark Camo (Argos £21.99; Smyths £24.99 retained), DualSense 007 First Light Limited Edition (Smyths £69.99; PlayStation UK £74.99 retained), DualSense GTA VI White Limited Edition (Smyths £74.99; PlayStation Direct £74.99 retained), and Xbox Forza Horizon 6 Limited Edition controller (Smyths £69.99; Argos £69.99 and Currys £84.99 retained).

Final independently queried totals match in both environments: 283 active gaming products, 275 active visible products, 388 active evidence rows (223 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures and zero duplicate active source keys. Branch-level product/visible/evidence counts match across all 20 gaming branches. This batch added 6 product masters and 11 evidence rows to each environment.

UK-used remains reference-only and does not affect automatic buying valuation. No application code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment. Exact IDs, source keys, source URLs and variant notes are recorded in `CHECKPOINTS/2026-11-05-gaming-catalogue-continuation-batch-02.md`.


## Mobile phone catalogue reconciliation — 5 November 2026 (batch 108)

The shared mobile-phone master catalogue and UK market evidence were reconciled across TradeFlow LIVE (`gxsrajtqzdjvmceqcpgv`) and TEST (`nnsshnfkjcflucjrftzi`). Two verified Galaxy S23 128GB observations already present in TEST were copied to the matching LIVE master using the same stable source keys: Idealo UK new asking-price observation £274.99 (observed 26 October 2026; evidence ID LIVE `5e5dbb34-7aea-40e7-a6e7-b31dca0e54db`, TEST `a528b5a8-e670-48d2-89ab-9f25b8526350`) and completed UK eBay damaged-condition sale £160.41 including the £6.90 Buyer Protection fee (evidence ID LIVE `92d69093-ba7b-46df-89b8-505c02a84901`, TEST `d3360ca8-50af-4840-8b7a-f46259286283`). The TEST eBay observation was corrected to the sold-page total and condition `Used - damaged`. The sold listing is explicitly cracked but fully working and must remain a damaged-condition comparator, not a normal-condition benchmark.

Post-write verification: both environments now have 562 active mobile evidence rows (266 UK-new, 296 UK-used), 154 active products with UK-used evidence, and 156 customer-visible active products. LIVE has 158 active mobile products and zero products missing all evidence; TEST has 159 active products and one product with no evidence. The sole product-key difference is TEST-only `iPhone 18 256 GB`, which remains hidden and unverified. Do not copy, activate, publish, deactivate or delete it without a separately verified product decision. The four common used-evidence gaps remain Motorola Edge 70 Plus 256GB, OPPO Find X10 256GB, OPPO Find X10 Pro Max 512GB and OPPO Reno16 F 5G 256GB; no qualifying exact-variant UK used listing was accepted in this research pass.

No application code, schema, valuation logic, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes; no deployment. UK-used evidence remains reference-only and does not feed automatic buying valuation. Full details and research exclusions are recorded in `CHECKPOINTS/2026-11-05-mobile-phone-catalogue-reconciliation-batch-108.md` and `PROJECT-MEMORY/2026-11-05-mobile-phone-catalogue-reconciliation-batch-108.md`.


## Mobile phone used-evidence research continuation — batch 109, 5 November 2026

Rechecked the four shared UK-used evidence gaps in LIVE and TEST before research. Both environments still agree on 562 active mobile evidence rows (266 UK-new / 296 UK-used), 154 active products with UK-used evidence, 156 customer-visible products, and the same four common UK-used gaps. LIVE remains at 158 active products with zero products missing all evidence; TEST remains at 159 active products with one hidden, unverified TEST-only `iPhone 18 256 GB` with no evidence. Do not copy or activate that TEST-only record without product verification.

Research leads found but not imported because item-level source validation was incomplete:
- OPPO Reno16 F 5G 256GB: eBay UK search results surfaced a `Certified - Refurbished` listing at £379.99 from seller `fistech_uk` (99.6% positive feedback). A seller-store page was checked, but the specific listing was not present in the accessible current store result and no direct item URL, dispatch location or full condition details could be verified. Do not use the category/search URL as an item-specific evidence URL; hold pending direct listing verification. The iD Mobile product page confirms the exact 256GB variant and describes Excellent / Very Good / Good refurb grades with 12-month warranty, but the displayed £479 is a new price, not a refurb price.
- OPPO Find X10 Pro Max 512GB: eBay UK search results surfaced a `Pre-owned` listing at £1,073.08 plus £11.95 postage under the title `Oppo Find X10 Pro Max 512GB 12GB RAM Grey UK Version BARGAIN`. The direct listing URL, seller identity, and detailed condition could not be verified; do not import the category-page result.
- OPPO Find X10 256GB: results remained new or `Opened – never used`; no qualifying used listing found.
- Motorola Edge 70 Plus 256GB: no qualifying used listing found. Current UK new listings are not used evidence (Argos £499.99; MoneySavingExpert price-comparison page £529.99). Model release shown as September 2026, so used supply may be limited.

No evidence rows were added or modified in this pass. Exact-variant UK GBP rules and direct item URL requirement remain in force. UK-used evidence remains reference-only and must not feed automatic buying valuation. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment. Research notes are in `CHECKPOINTS/2026-11-05-mobile-phone-used-research-batch-109.md` and `PROJECT-MEMORY/2026-11-05-mobile-phone-used-research-batch-109.md`.


## Mobile phone used-evidence research — batch 110, 5 November 2026

Rechecked exact-variant UK marketplace results for the four common mobile used-evidence gaps. New search leads remain unfit for import:
- OPPO Reno16 F 5G 8GB/256GB: eBay UK search results show a Certified - Refurbished offer at £379.99 from fistech_uk (99.6% positive, 273 feedback) with free delivery/returns. The search result does not expose a direct item URL, seller dispatch location or full refurb grading/description. A separate direct item page found for this model is £439.99 NEW and is not used evidence. Do not enter the £379.99 search result without opening and verifying the actual item.
- OPPO Find X10 Pro Max 512GB: eBay category/search results show an apparent Pre-owned result at £1,276.42 plus £11.50 postage, but no direct item URL or item-level condition/seller location was verifiable. Direct page found at £1,293.70 is New and located in Forest Row, UK; another result at £1,120.23 is Opened – never used. Neither qualifies as used evidence.
- OPPO Find X10 12GB/256GB: exact UK-model result at £876.03 is Opened – never used; another exact 256GB Global Version listing at £999.99 is dispatched from India. Exclude both from UK-used evidence.
- Motorola Edge 70 Plus 256GB: targeted eBay searches did not return a verifiable exact used listing. Do not substitute Edge 70 base/Pro/Fusion or other storage variants.

No database evidence rows were added or changed. LIVE and TEST remain aligned on shared catalogue evidence; TEST-only hidden/unverified iPhone 18 256GB remains untouched. UK-used evidence is reference-only and excluded from automatic valuation. See `CHECKPOINTS/2026-11-05-mobile-phone-used-research-batch-110.md` and matching project-memory record. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment.


## Gaming catalogue continuation — batch 03, 5 November 2026

TEST was updated and independently read back before the matching LIVE write. Added one active, customer-visible Nintendo Switch 2 AC Adapter master to Nintendo Accessories, exact package single-ac-adapter-black, with four active UK-new GBP retailer observations: Smyths £21.99, Currys £21.99, EE £19.99 and Argos £24.99. The official adapter is the black replacement power supply with detachable cable, compatible with the Switch 2 console and dock.

Added Smyths UK-new observations to the existing Switch 2 Joy-Con 2 Charging Grip (£29.99) and Joy-Con 2 Wheel Pair (£14.99) masters in both existing catalogue branches (Nintendo Accessories and Nintendo Controllers). No new masters were created for these already-catalogued products. The wheel pair is two magnetic wheel adapters; Joy-Con controllers are not included. The charging grip is sold separately from Joy-Con controllers. The existing used grip observation and all previous retailer evidence were retained.

Sources:
- Smyths AC Adapter £21.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-ac-adapter/p/249615
- Currys AC Adapter £21.99: https://www.currys.co.uk/products/nintendo-switch-2-ac-adapter-10281817.html
- EE AC Adapter £19.99: https://ee.co.uk/products/nintendo-switch-2-ac-adapter
- Argos AC Adapter £24.99: https://www.argos.co.uk/product/7624812/
- Smyths Joy-Con 2 grip and wheel listing: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203

Environment-specific IDs:
- AC Adapter product: TEST e54ae54b-1e58-4be5-9b0a-56142d941244; LIVE 26987446-1a04-4f2a-8970-72079a0a583f.
- AC Adapter evidence (Smyths, Currys, EE, Argos): TEST 4dd4eac2-de01-4d1f-82dc-2d42ae9678fa, 1b9462ae-807d-4e4a-81d6-5221d92b37ff, a334b8de-de3b-4350-8de4-d9231f536798, 5c20cf58-b9dd-482e-9329-a3ef1f89fee9; LIVE 1884d558-e2f7-4add-8ca3-088ed1bf9796, 41b8ab83-e760-49a9-a4f1-72dee2a14738, 101751bd-efb4-4d66-abb9-94c8650aec83, 31f2a943-8fa3-414d-8cf0-9a439b9b461f.
- Charging Grip Smyths evidence (Accessories branch): TEST d8669b3f-4552-4780-a6ba-ef2cd8b11604; LIVE 3d4156cf-edf7-4148-b10c-f17fcc92cc5a. Controllers branch: TEST f133249c-ab0d-4f20-9331-052271a61f83; LIVE f04cb182-882c-45d1-a712-a70119478300.
- Joy-Con 2 Wheel Pair Smyths evidence (Accessories branch): TEST 9239582f-f8ce-4c63-ba8f-61e045134884; LIVE c319a31e-0382-4397-9c2e-93a78c094690. Controllers branch: TEST 75b5641d-a89c-4f6d-880b-3e81f3afa745; LIVE 2381ed36-361c-4ef3-a2fa-88b48a533d7b.

Independent post-write verification in both databases: 284 active gaming products, 276 active customer-visible products, 396 active evidence rows (231 UK-new / 165 UK-used), zero visible products missing all evidence, zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branch counts match between LIVE and TEST. Nintendo Accessories now has 10 active products / 10 visible / 16 evidence; Nintendo Controllers has 105 / 105 / 119. The eight added evidence rows are all UK-new GBP; no existing UK-used evidence was changed. UK-used remains reference-only and does not feed automatic buying valuation.

No application code, schema, RLS, RPC, Edge Function, valuation, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment. No TEST business data copied to LIVE. Exact TEST/LIVE product and evidence IDs are environment-specific as listed above.


## Gaming catalogue evidence continuation — batch 04, 5 November 2026

Added five active UK-new GBP retailer observations to the existing Nintendo Switch 2 Camera master in Nintendo Accessories; no duplicate product master was created. Captured prices: Smyths £34.99 promotional (was £44.99; Click & Collect in stock, delivery unavailable), Argos £49.99, Currys £44.99, John Lewis £44.99 and EE £45.00. The camera remains a separate Switch 2 USB-C camera product; its existing UK-used Cash Converters £19.99 observation was retained and remains classified as used/reference-only.

Sources:
- Smyths £34.99: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/nintendo-switch-2-camera/p/249607
- Argos £49.99: https://www.argos.co.uk/product/7624599
- Currys £44.99: https://www.currys.co.uk/products/nintendo-switch-2-camera-10281819.html
- John Lewis £44.99: https://www.johnlewis.com/nintendo-switch-2-camera-black/p113587836
- EE £45.00: https://ee.co.uk/products/nintendo-switch-2-camera

Evidence IDs: TEST b5e9070b-2065-4ce1-808f-c7c50f2a7678 (Smyths), 5f85d615-b670-4931-ae43-3f8998772a09 (Argos), a100d555-6e54-4a78-9fcc-0a684fc138e5 (Currys), c6637563-09c3-4bf2-ac03-a29f6aa588c2 (John Lewis), 97bc47e7-7811-48d2-9c3b-f1656bb97992 (EE). LIVE: f5d15edd-57a9-461c-9bc0-269b1b77a9df (Smyths), 1727641c-7c81-4669-b3f8-8480c942737f (Argos), 1780870e-ec5a-407b-9557-0555dbb6b4d2 (Currys), f67f0592-b4d0-4466-be75-dc260ff51804 (John Lewis), c4c82385-dbb6-4282-81ef-5e561215d3a9 (EE).

Post-write verification in both environments: 284 active gaming products, 276 active customer-visible products, 401 active evidence rows (236 UK-new / 165 UK-used), zero visible products missing all active evidence, zero active evidence integrity failures and zero duplicate active source keys. All 20 gaming branch counts match; Nintendo Accessories now has 10 active products / 10 visible / 21 evidence. No product master, code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Worker changes. No deployment. UK-used remains reference-only and does not affect automatic buying valuation.


## Mobile phone used-evidence research — batch 111, 5 November 2026

Rechecked LIVE and TEST against batch 110, then expanded searches to UK refurbished retailers, eBay UK, Gumtree and current launch/retail pages. No new used-evidence row passed item-level validation:
- Motorola Edge 70 Plus 256GB: eBay UK results contain Edge 70 base, Edge 70 Max, Edge 70 Pro, Edge 70 Fusion and other storage variants, but no exact Edge 70 Plus 256GB pre-owned listing. Newport Mobiles' £430 listing is explicitly new/sealed. MoneySavingExpert currently shows the exact 256GB model released September 2026 and no refurbished result even with refurb filtering; this supports the lack of a verified UK refurb offer, not a used price. Sources: https://www.ebay.co.uk/shop/motorola-edge-plus?_nkw=motorola+edge+plus ; https://www.moneysavingexpert.com/cheap-mobile-finder/sim-free/motorola/edge-70-plus/ .
- OPPO Reno16 F 5G 8GB/256GB: eBay category result still shows £379.99 Certified - Refurbished from fistech_uk (99.6%, 273 feedback), but no direct item link, dispatch location or grading details were exposed. The separate direct £439.99 UK Version listing is new/sealed. Official OPPO UK currently lists Reno16 F 5G from £349, but that is a new price and does not constitute used evidence. Sources: https://www.ebay.co.uk/shop/oppo-reno-5g?_nkw=oppo+reno+5g ; https://www.ebay.co.uk/itm/407078357250 ; https://www.oppo.com/uk/smartphones/series-find-x/find-x3-neo/specs/ .
- OPPO Find X10 12GB/256GB: UK retail/contract sources show new SIM-free prices (£999–£1,099), and EE confirms exact 256GB/12GB spec and launch 28 October 2026. No UK used/refurb item found; exact used market remains unverified. Sources: https://ee.co.uk/products/oppo-find-x10-sim-free ; https://www.idmobile.co.uk/sim-free-phones/oppo-find-x10 .
- OPPO Find X10 Pro Max 12GB/512GB: current eBay search results include a pre-owned category result at £1,276.42 + £11.50 postage but no direct item URL/seller/condition details; exact direct eBay item pages inspected were new/sealed, and Gumtree's £999 listing explicitly says brand new, sealed and never opened. EE confirms 512GB/12GB and launch 28 October 2026. No used candidate accepted. Sources: https://www.ebay.co.uk/b/bn_74893092 ; https://www.ebay.co.uk/itm/820280763288 ; https://www.gumtree.com/p/oppo/oppo-find-x10-pro-with-hasselblad-kit-or-find-x9-ultra/1804314977 ; https://ee.co.uk/products/oppo-find-x10-pro-max-sim-free .

No database evidence rows were inserted or changed in batch 111. New, sealed, opened-never-used, overseas and category-only results remain excluded from UK-used evidence. The recent release dates (Sep 2026 / 28 Oct 2026) explain thin resale supply but do not justify estimated prices. UK-used remains reference-only and excluded from automatic valuation. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment. See `CHECKPOINTS/2026-11-05-mobile-phone-used-research-batch-111.md` and project memory.


## Mobile phone catalogue research and aligned evidence update — batch 112, 5 November 2026

Added one verified UK-new retail observation to the matching Reno16 F 5G 8GB/256GB master in both LIVE and TEST:
- Currys product page: https://www.currys.co.uk/products/oppo-reno16-f-5g-256-gb-purple-black-10306159.html
- £399.00 GBP, New, SIM-free, 8GB RAM / 256GB, Currys shows Available for delivery. Observed 5 November 2026.
- Stable source key: `mobile-new-oppo-reno16f5g-256gb-currys-10306159-20261105`.
- LIVE evidence ID `db7f42a1-cd18-41d3-b4c3-c583a329cb6a`; TEST evidence ID `189ce5b8-d2f4-4a55-a4a9-9fa7571df760`.
This is a new retail asking price only, not a used/refurbished benchmark or completed sale.

Additional used-market research did not produce an accepted exact-variant used listing:
- Reno16 F 5G 8GB/256GB: eBay UK still shows Certified - Refurbished £379.99 from fistech_uk (99.6%, 273 feedback), but result has no direct item URL, dispatch location or refurb-grade details. Do not import the search result. Exact Currys £399.00 new listing is now recorded above.
- Find X10 12GB/256GB: eBay UK direct search results identify exact UK-model listings at £821.20 / £876.03 as Opened – never used; exclude from used evidence. Brand-new listings are also present.
- Find X10 Pro Max 12GB/512GB: search results still surface a Pre-owned listing £1,073.08 + £11.95, but no direct item URL or verifiable seller/location/condition details were obtained. Hold; do not import category result.
- Motorola Edge 70 Plus 8GB/256GB: no exact UK used listing found. Current Currys new listing £499.00 confirms exact 8GB/256GB and availability; this does not count as used evidence. Source: https://www.currys.co.uk/products/motorola-edge-70-plus-256-gb-pantone-mountain-view-10310979.html .

Post-write verification: both environments now have 563 active mobile evidence rows (267 UK-new / 296 UK-used), 154 products with UK-used evidence and 156 customer-visible products. LIVE remains 158 active products / 4 missing used / 0 missing any evidence; TEST remains 159 / 5 / 1 because its hidden, unverified iPhone 18 256GB is TEST-only. The shared evidence addition is aligned exactly; product master difference remains intentionally untouched.

UK-used remains reference-only and excluded from automatic valuation. No code/schema/valuation/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment. See `CHECKPOINTS/2026-11-05-mobile-phone-catalogue-batch-112.md` and project memory.


## Gaming catalogue evidence continuation — batch 05, 5 November 2026

Added three UK-new GBP observations to existing masters in TEST and LIVE: Nintendo Switch 2 Carrying Case & Screen Protector — Smyths £17.99 promotional and Currys £20.99; HORI Wireless HORIPAD Turbo Kirby & Waddle Dee — Smyths £39.99. Existing Argos evidence retained (£19.99 case; £64.99 Kirby controller). Sources: https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/c/SM06040203 ; https://www.currys.co.uk/products/nintendo-switch-2-carrying-case-and-screen-protector-black-10281818.html ; https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/hori-wireless-horipad-turbo-for-nintendo-switch-2-kirby-and-waddle-dee/p/259385 . TEST evidence IDs: 8b79c8ab-ba49-4f63-8820-330505ff31e9, 4e27b24f-644d-4956-9e57-9c539f4889ff, 26873d05-eea3-47cd-aa77-703dd61540b5. LIVE IDs: 36d02bcf-2c54-4351-bffc-61af9f833b4d, ec8f5e06-5362-45de-aab7-934b064893d5, 85f80133-13c5-404a-ade1-f5ad25ac06a6.

Both DBs verified: 284 active gaming products, 276 visible, 404 active evidence (239 UK-new / 165 UK-used); zero visible products missing evidence, zero integrity failures, zero duplicate source keys; all 20 branches aligned. Nintendo Accessories 10/10/23; Nintendo Controllers 105/105/120 (products/visible/evidence). No new masters or used rows. UK-used remains reference-only. No code/schema/valuation/Stripe/tenant/customer/order/payment/Worker changes and no deployment.


## Mobile phone catalogue alignment and integrity reconciliation — batch 113, 5 November 2026

Rechecked the current LIVE and TEST mobile-phone catalogue and batch 112 checkpoint. This revealed one active TEST evidence row attached to an already-retired invalid product variant: Pixel 11 128GB. TEST product e3ed0762-1709-4881-8568-e97272bd79ff was explicitly retired on 23 October 2026 because Google Store UK confirms Pixel 11 starts at 256GB. Its MyMobiles UK £594 new-price evidence row (1a21bf68-2959-4ade-bfbb-7b0fa33218da, source key mobile-new-pixel-11-128gb-mymobiles-20261026) was therefore deactivated in TEST while preserving the row and audit history. The retired product itself was not changed. No evidence for this invalid 128GB variant was copied to LIVE.

Also reconciled observed metadata drift on matching evidence rows: TEST Galaxy S22 128GB and iPhone 15 128GB conditions/notes were aligned to the more specific LIVE descriptions; LIVE Motorola Edge 70 256GB source label/channel/notes were aligned to the fuller TEST description; Galaxy S23 128GB Idealo channel and Galaxy Z Fold7 1TB Samsung new-price condition/channel were normalised across both environments. No price, source URL, product master, condition class beyond the verified labels, or valuation behaviour was changed.

Post-reconciliation verification (active products only):
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active mobile products | 156 | 156 |
| Active evidence rows attached to active products | 563 | 563 |
| UK-new | 267 | 267 |
| UK-used | 296 | 296 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |
| Active evidence attached to inactive mobile products | 0 | 0 |

A row-by-row comparison confirms the 563 active evidence records now match across LIVE and TEST by model, storage variant, evidence type, source URL, observed price, condition and sales channel. Descriptive note wording and some recorded observation timestamps still differ slightly between environments; these were retained rather than overwritten because they do not change the underlying observation and may contain useful capture detail. Product-master counts remain intentionally different by one because the hidden, unverified TEST-only iPhone 18 256GB remains untouched. Do not copy, activate, publish, deactivate or delete that iPhone 18 without separate verification and approval.

The four common used-evidence gaps remain: Motorola Edge 70 Plus 8GB/256GB; OPPO Find X10 12GB/256GB; OPPO Find X10 Pro Max 12GB/512GB; OPPO Reno16 F 5G 8GB/256GB. New UK research found no qualifying direct item-level used/refurbished listing for any of these exact variants. Reno16 F eBay UK still surfaces £379.99 Certified - Refurbished without a direct item URL, dispatch location or grade details; Find X10 surfaced UK-model results at £821.20/£876.03 but they are Opened – never used or otherwise not item-level verified; Find X10 Pro Max category results marked pre-owned lack direct item-level verification while direct Gumtree/eBay examples are new/sealed; Motorola Edge 70 Plus has no exact UK used listing. Do not import these as used evidence. UK-used evidence remains reference-only and excluded from automatic valuation.

No new mobile evidence rows were added in batch 113. No code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes; no deployment. See CHECKPOINTS/2026-11-05-mobile-phone-catalogue-alignment-batch-113.md and project memory.


## Gaming catalogue expansion — batch 06, 5 November 2026

Added a distinct HORI Piranha Plant Camera for Nintendo Switch 2 master to Nintendo Accessories in TEST, verified, then independently added the matching master to LIVE. It is different from Nintendo's official Switch 2 Camera: the HORI model is the plant-shaped detachable camera with flexible neck, Warp Pipe base, adjustable clip, USB-C cable and 3.5mm adapter. Package key piranha-plant-camera-green.

Five active UK-new GBP observations per environment: John Lewis £22.95 (https://www.johnlewis.com/nintendo-hori-piranha-plant-camera-for-nintendo-switch-2/p113587839); Argos £33.99 (https://www.argos.co.uk/product/7624609/); Very £33.99 (https://www.very.co.uk/nintendo-switch-2-piranha-plant-camera-for-switch-2/1601136130.prd); GAME £33.99, out of stock (https://www.game.co.uk/nintendo-nintendo-piranha-plant-camera-for-nintendo-switch-2-753575); Selfridges £39.99 (https://www.selfridges.com/GB/en/product/hori-piranha-plant-camera-for-nintendo-switch-2_R04473556/).

Product IDs TEST d7e37ea0-1191-4e57-9693-3600b609da06 / LIVE 0dede96e-8cb7-4dc6-82df-507999c5820c. TEST evidence IDs: 50615da5-c5b3-477e-bdcf-57ae77165e91, 23bd205f-dc34-4eba-a822-fa9613e2106c, cc18c1b3-0016-4731-ab17-97b38224ca16, 2df85e9b-6a60-4f97-8d37-92e387c05714, c09b43c1-1947-46aa-b280-de134e7e8dc1. LIVE evidence IDs: 0a5dd84e-6156-4160-9057-6a6d7343ef4f, 108da92a-af16-46a6-ba76-090b7920a77b, c16ab86b-e25d-463a-bae4-d43cae7ecb00, 82878b4a-398f-4167-b9b1-f970d1ed1f4d, 158e7cdf-3d58-4f4a-abda-4c5795ce976a.

Both environments verified: 285 active gaming products, 277 visible, 409 active evidence (244 UK-new / 165 UK-used), zero visible products missing evidence, zero integrity failures, zero duplicate active source keys; all 20 branches match. Nintendo Accessories 11 active products / 11 visible / 28 evidence. One product master and five UK-new observations added per environment. UK-used remains reference-only and does not affect automatic buying valuation. No code/schema/RLS/RPC/Edge Function/valuation/Stripe/tenant/customer/order/payment/ownership/Worker changes; no deployment.


## Mobile catalogue UK market evidence expansion — batch 114, 5 November 2026

Continued the mobile-phone UK market research and kept shared catalogue evidence aligned in LIVE and TEST. Rechecked batch 113 checkpoint and both current Supabase environments before writing. Existing master products and exact variant IDs were confirmed; both source URLs and stable source keys were checked for active duplicates before insertion.

Two additional verified UK-new retailer observations were inserted into both environments:

1. Motorola Edge 70 Plus, 8GB RAM / 256GB, Mountain View — Argos direct product page https://www.argos.co.uk/product/9654763 ; £499.99 GBP; New; observed 5 November 2026; availability recorded as listed because the page offers Add to trolley but requires a postcode check to confirm local stock/delivery. Stable key: mobile-new-motorola-edge70plus-256gb-argos-9654763-20261105. LIVE evidence ID 4af13ff5-a357-4a9f-91c6-4c252c51fc19; TEST evidence ID 28e2260c-03b9-4f20-ac67-1e86995df5aa. Master product IDs remain LIVE 4da6cf8a-bc1d-4012-ae23-43214d32ee22 / TEST 018599e7-86a6-4b50-a267-5d2ccddb8076.

2. OPPO Find X10 Pro Max, 12GB RAM / 512GB, Luna White — Currys direct product page https://www.currys.co.uk/products/oppo-find-x10-pro-max-512-gb-luna-white-10312083.html ; £1,499.00 GBP; New; observed 5 November 2026; availability recorded as listed because the captured page shows price and exact RAM/storage but did not explicitly confirm stock. Stable key: mobile-new-oppo-findx10promax-512gb-currys-10312083-20261105. LIVE evidence ID fc8e9167-0cc1-4455-87f5-e23b01ee2f1e; TEST evidence ID acabf972-24c1-44e4-83b2-23af2ec59542. Master product IDs remain LIVE 93cb19f9-8a90-4d9e-a02d-a1c70ab471a2 / TEST d026d651-5d8a-483a-8732-bec0efcba445.

These are new-retail asking prices only, not used/refurbished evidence or completed sales. No used price was imported. Research did not verify a direct item-level UK used/refurbished listing for any of the four outstanding variants. The Reno16 F £379.99 Certified - Refurbished eBay lead remains search-only without a direct item URL and refurbishment grade. Find X10 results remain opened-never-used/new or unverified at item level. Find X10 Pro Max category results lack direct verified condition/seller detail; its current direct UK retailer pages are new. Motorola Edge 70 Plus used/refurbished results remain absent; MSE's refurb filter showed no Pristine refurbished result, while the Argos listing is new. Other model variants are not substitutes.

Post-write database verification:
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active mobile products | 156 | 156 |
| Active evidence rows | 565 | 565 |
| UK-new evidence | 269 | 269 |
| UK-used evidence | 296 | 296 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |
| Active evidence attached to inactive products | 0 | 0 |

All 565 active evidence rows match by model, package/storage variant, evidence type, source URL, observed price, condition and sales channel; no row differences or duplicate insertions were found. Product-master counts retain the intentional one-product difference: hidden, unverified TEST-only iPhone 18 256GB remains untouched. Do not copy, activate, publish, deactivate or delete it without separate verification and approval.

The four common used-evidence gaps remain: Motorola Edge 70 Plus 8GB/256GB; OPPO Find X10 12GB/256GB; OPPO Find X10 Pro Max 12GB/512GB; OPPO Reno16 F 5G 8GB/256GB. UK-used evidence remains reference-only and excluded from automatic valuation.

No code, schema, valuation, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No deployment.


## 8 November 2026 — Gemma 3D printer evidence-capture behaviour

Gemma's 3D-printer research path separates page discovery, direct-page capture, local model extraction and ChatGPT review. A timeout in the local model must not discard a successfully fetched page: the worker retains the raw page text, visible GBP price mentions, identity/package snippets and stock/condition observations, and may append an unverified enrichment to an exact matching unreviewed queue row.

On 8 November, the LIVE K1 Max official UK page returned 17 visible GBP mentions. The useful distinctions included £589 standard printer, £729 crossed-out price, £140 saving, and separate Combo/accessory/gift-card offers. These must not be treated as independent product prices. The extraction timed out; the raw page was retained and the row remained `needs_research`. No approval or catalogue import occurred.

Production PR #293 (`3b55d43acec4ad4abb5f8e5b9530f169d3c1d3f3`) refined only the 3D-printer extraction prompt. It preserves compact price contexts and recent bounded guidance, requires one structured observation per page/source ID, and instructs Gemma to report machine-only versus Combo/bundle variants, price context, condition, stock, UK delivery and uncertainty without deciding evidence suitability. CI passed 50/50 tests.

**Operational boundary:** the merge updates GitHub production source only. The Research PC's already-running worker does not hot-reload this file. Let its current task finish, then run the existing TradeFlow updater once against the confirmed TradeFlow installation and existing private TradeFlow `.env`. Do not alter PowerShell launcher logic, Ollama settings, credentials or the separate GearCashOut configuration. Verify the next run before marking the prompt change live on the PC.


## 10 November 2026 — Final retirement status: local research-worker platform

The owner has retired the local category research-worker platform and its new-evidence lab-search workflow. This is a completed retirement boundary, not a pause or an instruction to reinstall it.

The owner dashboard HTML, JavaScript and stylesheet on this branch contain no worker-control or common-room UI. The local worker README, updater and Node entry point have been deleted from this branch. On LIVE, the equivalent owner dashboard controls and polling/queue/source-management/message UI were removed, and the remaining retired CSS selectors were deleted.

LIVE worker/control-plane RPC execution has been revoked for service_role, authenticated and anon. The applied retirement migration is recorded in `supabase/migrations/20261110173027_retire_research_agent_runtime_permissions_20261110.sql`. Historical migration files remain because they are required to reproduce the applied schema history.

Preservation boundary: do not delete catalogue products, categories, manufacturer/model/package data, shared market evidence, tenant/customer/subscriber data, Stripe settings, published subscriber websites, historical task/activity/message rows, research queue rows or source registry rows. These historical records are retained for audit; they are not an active worker service. No database tables or historical rows were dropped as part of retirement.

The owner ran the no-backup PC removal script. The confirmed installation folders, scheduled tasks and worker shortcuts were removed. Ollama remains installed; final model-list verification and Chrome web-app uninstall confirmation are still outstanding. No local backup was created, as explicitly requested.

Any future market research supplied for catalogue use remains review-only until the owner/ChatGPT independently verifies exact product/package identity, GBP price, condition, availability and direct source evidence. Do not automatically approve or import findings. The retired worker platform must not be restarted or rebuilt as part of ordinary catalogue maintenance.
