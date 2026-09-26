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
**Version:** 4.4  
**Date:** 19 September 2026  
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
