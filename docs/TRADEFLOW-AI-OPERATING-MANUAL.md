# TradeFlow AI Operating Manual & Continuity Base

**Status:** Living operational document  
**Version:** 4.2  
**Date:** 18 September 2026  
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

## 9. Category investigation — 17 September 2026
The category query and RLS path were verified independently: Test Business A contains active Buying/Selling `Drones`; the exact category SELECT returns `Drones` for the authenticated Test Business A owner; and category permissions are present.

The browser symptom therefore moved the investigation to subscriber authentication. The Categories screenshot showed the controller itself reporting `Sign in through the TradeFlow test environment before opening Categories.` The subscriber pages were reading the temporary **customer** test-lab storage keys (`tradeflow_testlab_publishable_key` / `tradeflow_testlab_session`), while Platform Owner administration deliberately uses its own session and does not authenticate subscriber workspaces.

The earlier REST repair also remains: subscriber GET/HEAD requests omit unnecessary JSON `Content-Type`, category reads have a 10-second timeout, and runtime diagnostics load before the controller.

## 10. Dedicated subscriber authentication repair — 17 September 2026
`subscriber-auth.js` now supplies a separate test-environment subscriber authentication context. It uses `tradeflow_subscriber_publishable_key` and `tradeflow_subscriber_session`, signs in Owner/Admin/Staff accounts by email/password, verifies active membership in the selected Test Business A/B tenant, sets tenant context and never stores the password.

`subscriber-auth-bridge.js` is a compatibility layer for the existing Category, Inventory and Selling controllers. It translates their legacy storage-key reads to the dedicated subscriber session only on those subscriber workspace pages and reloads after a new login. It does not overwrite the Customer Test Lab session.

`subscriber-auth-controls.js` connects the existing workspace Sign out button to the dedicated subscriber session.

The dedicated authentication layer is now wired into Categories, Inventory and Selling. This is temporary test-environment infrastructure, not the final production authentication/onboarding architecture.

## 11. Inventory/media foundation
Inventory remains protected by `guard_inventory_asset_status_entry()` and `transition_workflow_entity()`.

New product creation is exposed in `inventory-dashboard.html`. It creates a `received` inventory asset, assigns a category, stores dynamic property values and can upload multiple photographs.

Media architecture:
- private Storage bucket: `tradeflow-media`;
- `media_assets` stores object metadata and retention fields;
- `inventory_asset_media` links photographs to products;
- `listing_media` links photographs to listings;
- Selling carries inventory media links into a newly created listing.

When an inventory asset or listing enters `sold`, attached media receives a 90-day retention expiry; leaving `sold` clears the expiry. This is a retention timer, not yet the physical deletion job. Physical deletion must use Supabase Storage. Scheduled cleanup via Cron/pg_net is not yet configured.

## 12. Finance / external payment checkpoint
059–060 harden payment/ledger access and workflow authority. No `module.finance` feature is to be invented.

`record_retail_order_payment()` is the internal subscriber capture path. `customer_create_order_payment()` is the customer-side idempotency boundary.

External Stripe boundary:
- `create-stripe-checkout-session`: JWT-protected server-side Checkout creation;
- `stripe-payment-webhook`: signed Stripe event verification and reconciliation;
- `process_external_payment_event()`: protected database reconciliation;
- `payment_provider_events`: provider/event idempotency.

Stripe test configuration is complete server-side, but persistent browser payment verification remains open.

## 13. Selling/Listings and Orders
Selling uses ready-for-sale inventory, active selling channels/categories and central workflow authority. New listings inherit inventory media.

Retail Orders hardening is 062. Customer checkout requires an authenticated active customer, accepts a published listing, creates a pending-payment order, reserves the listing and enters the Stripe boundary. Subscriber internal payment capture advances paid orders and creates finance records.

## 14. Fulfilment and Returns
Fulfilment lifecycle authority: `awaiting → label → dispatched → delivered`, with return branches. Direct status edits are guarded.

Returns require authenticated customer ownership and eligible order state. Lifecycle authority is `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

## 15. Customer dashboard browser repair — VERIFIED LIVE
Customer browser faults were traced to navigation interception, session handoff timing and an invalid `esc()` quote mapping. The controller was repaired and cache-busted to `v11`.

Customer Buying category loading was separately isolated because Test Business A lacks `module.orders`; the aggregate customer data `Promise.all()` can reject before categories load. `customer-dashboard-nav.js` independently calls secure `customer_get_buying_categories()` after portal reveal. No subscription capability was changed.

## 16. Subscriber JavaScript loading repair — 17 September 2026
Categories, Inventory and Selling all showed `Loading…`. The shared malformed `esc()` mapping was a JavaScript parse fault. Category was repaired in place; clean repaired Inventory and Selling runtimes were deployed. Inventory signed-URL requests also explicitly send JSON content type.

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
The database/RLS category path is verified. The previous browser symptom was traced to subscriber pages reading the customer test-lab session rather than a subscriber session. Dedicated subscriber authentication and a compatibility bridge are now deployed to Categories, Inventory and Selling. **Live browser verification of subscriber sign-in and category loading remains open.**

**Next safe action:** hard refresh Categories. If the dedicated subscriber sign-in dialog appears, sign in using an active Test Business A Owner/Admin/Staff account and select Test Business A. After the page reloads, verify `Drones` appears in Categories. Then verify the same subscriber session populates Inventory and Selling category selectors. Do not alter subscriptions, category data or RLS to work around this authentication issue.


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

When reasoning about subscriber capability, treat **Basic** as the complete operational Buy & Sell core and **Enhanced** as Basic plus all currently defined add-ons. Do not revive the retired Buying/Selling/Buy & Sell/Business/Advanced plan structure in new code. Capability enforcement remains feature-based through the existing subscription layer; plan names are presentation/catalogue concepts.


## 21. Stage 1 build checkpoint — 18 September 2026

Stage 1 means building the TradeFlow SaaS product-entry layer and the Platform Owner control layer.

Do not merge these concepts:
1. TradeFlow SaaS homepage — markets the subscription.
2. Platform Owner dashboard — manages the TradeFlow platform.
3. Subscriber business dashboard — private operational workspace for one subscriber tenant.
4. Subscriber customer-facing website — built by the subscriber and used by that subscriber's customers.

The current Stage 1 implementation adds platform-owner-dashboard.html, platform-owner-dashboard.js and platform-owner-dashboard.css. The owner page authenticates through Supabase Auth, verifies active platform membership through the tenant-independent platform_memberships boundary and uses the existing platform_admin_list_tenants() RPC for platform-level tenant/subscription summaries.

Next safe test: verify the SaaS homepage and its Basic/Enhanced onboarding routes, then verify Platform Owner sign-in and subscriber dashboard entry separately. Do not use the tenant public storefront as the TradeFlow homepage.


## 22. Subscription model and AI continuity checkpoint — 18 September 2026

The current TradeFlow commercial model has three active customer-facing plans:

- **Basic** — the complete operational Buy & Sell core. The subscriber configures their own categories and subcategories and can configure the available website templates/colours, add a logo and add image content.
- **Enhanced** — Basic plus the currently defined higher-tier capabilities: staff management, staff messaging, audit, analytics, integrations and market intelligence.
- **Catalogue** — Enhanced plus a TradeFlow-provided starting catalogue of categories, subcategories and products. The exact commercial quantities for categories, subcategories and products are intentionally **not yet decided** and must not be invented.

The plan catalogue is now database-authoritative: basic, enhanced and catalogue are active; legacy buying, selling, buy_sell, business and advanced codes are inactive for historical auditability. Capability enforcement remains feature-based through the subscription entitlement layer. Do not create separate applications for the plans.

The Catalogue plan currently has a catalogue.pre_filled entitlement with unset quantity limits. The entitlement records the commercial capability boundary; it does **not** mean that catalogue data is already being copied into new tenants. Actual catalogue seeding is a later implementation step.

The Platform Owner layer now has the protected platform_admin_manage_subscription boundary:
- upgrade can move a tenant only to a higher active plan;
- close cancels the latest subscription and archives the tenant while retaining stored business data.

These controls are internal platform administration, not completed Stripe recurring billing. Provider price IDs, Stripe subscription lifecycle/webhooks and automatic non-payment enforcement remain separate implementation work. Never describe the current Owner controls as a complete payment/subscription billing system.

The SaaS homepage, subscriber signup and Owner Dashboard have been updated for the three-plan model. Current state is **Implemented / database-verified** for the plan catalogue, entitlements, signup acceptance and protected Owner RPC boundary. The latest three-plan homepage/signup/Owner Dashboard UI changes still require browser verification. Do not mark them Verified Live until that browser test has been completed.

### AI memory/continuity rule

This manual is part of the persistent project continuity record. When a material TradeFlow change is made, the AI must keep the Master Roadmap, System Handbook, this AI Operating Manual and available structured project memory/checkpoints aligned. If no actual structured memory store exists, do not invent one or claim that a database memory record was updated. The current Supabase schema has no dedicated memory, learning or knowledge table identified during the 18 September 2026 inspection.

When resuming work, retrieve current GitHub and live Supabase state before relying on this checkpoint. Treat this document as recorded project knowledge, not as a substitute for live verification.

**Current next safe action:** browser-test the TradeFlow SaaS homepage, Catalogue signup selection and Platform Owner Dashboard three-plan display/actions. Do not create or close a real subscriber merely to test destructive subscription controls, and do not implement Catalogue seeding until the commercial quantity limits are explicitly decided.


## 23. SaaS homepage redesign checkpoint — 18 September 2026

The TradeFlow SaaS homepage has been visually rebuilt with a professional navy/orange brand system and a new TradeFlow SVG logo. The page now presents the platform through a hero, connected workflow, feature sections, three plans, illustrative website examples, facts CTA, legal/support links and signup/sign-in actions.

Important architecture decision: **Business URL / slug is not a public signup field.** Initial subscriber signup is for account/business identity and plan selection. Website URL/domain configuration belongs in the authenticated subscriber portal under website/business settings. The backend may generate an initial internal slug as required, but the subscriber should configure the public URL through the portal.

The example website cards are illustrative compositions. Do not present them as actual customer screenshots unless an authorised source is supplied. GearCashOut remains a reference/template system and must not be modified.

Current state: **Implemented, not browser-verified.** Browser verification is required before marking the redesigned homepage Verified Live.


## 24. Subscriber application shell checkpoint — 18 September 2026

Stage 1 subscriber UI work is implemented on branch subscriber-shell-stage1. The change is intentionally a shell over the existing backend and operational controllers, not a backend rewrite. Existing tenant isolation, subscription feature checks, permissions, RPCs, workflow authority and database objects remain the source of truth.

Changed files:
- subscriber-dashboard.html — rebuilt the subscriber entry page as the common business workspace shell while preserving links to existing workspaces.
- subscriber-dashboard.css — introduced the restrained application-shell styling while retaining shared classes used by existing subscriber pages.

The subscriber dashboard now loads subscriber-auth.js before subscriber-tenant-context.js and binds the existing sign-out control to the dedicated subscriber sign-out function.

Catalogue is intentionally held back from subscriber operational rollout. It remains an active database plan, but it must not be added to the operational UI or seeded into tenants until Gemma is ready to maintain/update the product catalogue. Do not invent commercial limits or remove the active plan.

Verification state: Implemented / not Verified Live. Browser verification is required before merging the staging branch to main.

Safe continuation: verify the shell first, then extend the same application shell around existing Buying, Acquisitions, Inventory, Selling, Orders, Fulfilment, Returns, Customers and Website areas without duplicating their backend logic.

## Subscriber reset and dashboard/template checkpoint — 18 September 2026

The legacy subscriber test setup has been closed for the next onboarding test. Test-lab tenants were archived and their subscriptions cancelled. The Platform Owner Auth account `leannelaurenlowe@hotmail.com` remains intact. Two orphaned test Auth users were removed. Do not recreate the old Test Business A/B/C identities merely to test the subscriber shell; use the normal subscriber signup flow for the next account.

Platform Owner remains a separate platform-level boundary. Never grant the Platform Owner automatic tenant membership to subscriber businesses. Future subscriber-approved maintenance/support access must be an explicit, auditable capability and is not a general tenant-access shortcut.

The subscriber dashboard now exposes the signed-in business, email and tenant role, with an Account dialog for the active tenant. Catalogue is intentionally not exposed as an operational subscriber module until Gemma is able to maintain the product catalogue.

Website templates now include six distinct starting layouts: Business, Buy & Sell, Services, Editorial, Minimal and Retail. Template selection is stored in the existing site revision content and rendered by the public site without changing the publication or tenant security boundary.

**Current state:** Database cleanup **Verified**; dashboard and template changes **Implemented / not browser-verified**. Next safe action is a fresh subscriber signup through the public TradeFlow onboarding flow, followed by one browser test of account identity and dashboard entry.

## Subscriber dashboard workflow separation — 18 September 2026

The subscriber Business Dashboard is now deliberately separate from Website management. The daily business flow is Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns. Customers and Finance sit alongside the flow as supporting business functions. Website Builder is not embedded in this operational dashboard.

`subscriber-website.html` is the separate website-management entry point. It provides the Website Builder, public preview and return path to the Business Dashboard. This matches the intended subscriber behaviour: build/publish the website once, then return to it only for later changes.

Subscriber auth now locks protected page content until the dedicated subscriber session and active membership have been verified.

**Current state:** Implemented on staging; browser verification required.

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
