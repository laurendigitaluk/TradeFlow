# TradeFlow AI Operating Manual & Continuity Base


> **CURRENT SHIPPING ARCHITECTURE — 25 September 2026**
>
> The current TradeFlow shipping architecture is **subscriber-managed shipping services with manual handoff**. The former Parcel2Go API/connected-provider route is **retired and must not be used or reintroduced from the older sections of this document**.
>
> **Current flow:** Subscriber opens **Settings → Shipping Settings**, selects the shipping services they use from the TradeFlow service catalogue, and saves them. Those services appear in the Buying shipping handoff. The subscriber uses the chosen provider's official website/service outside TradeFlow and pays the shipping provider directly. The subscriber then returns to TradeFlow and uploads the shipping label and, where applicable, QR code, plus carrier/service, tracking number and customer instructions. TradeFlow stores the handoff against the existing acquisition/buying item and sends the shipping information to the customer. The customer can open/print the label or QR code and confirms when the item has been sent. The subscriber then confirms receipt and proceeds to **Inspection**.
>
> TradeFlow **does not create Parcel2Go quotes, book Parcel2Go shipments, process shipping payments, or require Parcel2Go API credentials** in this current flow. Do not add direct courier credentials or an automated shipping-payment path unless the architecture is deliberately changed, tested and checkpointed.
>
> **Documentation rule:** Sections below dated before this architecture change may describe earlier experiments or implementation history. They are retained for audit continuity, but they are **historical records, not current operating instructions**. Current code, current Supabase state and this section take precedence.

**Status:** Living operational document  
**Version:** 4.6  
**Date:** 4 November 2026  
**Project:** TradeFlow

## 1. Purpose
AI continuity companion for TradeFlow. It records architectural truth, decisions, faults, verification state and exact stopping point so future sessions resume without guessing.



## 1A. Permanent TEST → LIVE environment architecture — 30 September 2026

Authoritative backend operations manual: `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`.

TradeFlow now uses a deliberate two-environment release model.

### GitHub branches

The single repository is:

`laurendigitaluk/TradeFlow`

The permanent branch roles are:

- **`main` = TEST / STAGING code.** All normal development, repairs, migrations, browser fixes and feature work are made here first.
- **`production` = LIVE release code.** This branch represents the exact code approved for the live TradeFlow environment. It must only receive a tested release from `main`.

There is deliberately **not** a second GitHub repository for Live. GitHub branches provide the code separation while Supabase projects provide the database/runtime separation.

### Supabase projects

- **TradeFlow TEST:** `nnsshnfkjcflucjrftzi`, eu-west-2.
- **TradeFlow LIVE:** `gxsrajtqzdjvmceqcpgv`, eu-west-2, ACTIVE_HEALTHY (current project inventory checked 2 November 2026).

The TEST database contains deliberate test tenants, customers, orders, returns and other test data. LIVE must be a fresh production database built from the version-controlled migration history and must never be populated by copying TEST customer/transaction data.

### Exact release path

`feature/fix work` → `main` → TEST Supabase/browser verification → release checkpoint → promote the approved commit to `production` → apply the same version-controlled migrations/functions/configuration to LIVE → production smoke test.

A Git commit is not evidence that LIVE works. LIVE is only considered released after the production database migration state, Edge Functions/configuration and browser smoke tests have been verified.

### Database rule

Database structure changes belong in timestamped `supabase/migrations/` files. Do not make an unrecorded production schema change in Supabase Studio and then continue development from memory. Production changes must be reproducible from Git.

### Data rule

TEST and LIVE data are separate. Never copy TEST customers, customer bank details, test payments, test orders or other test transaction data into LIVE.

### Shipping rule

The production shipping architecture is manual. Parcel2Go API, Parcel2Go checkout, quote creation and payment-link shipping flows are retired and must not be reintroduced.

### Branch safety

The `production` branch is a release branch. It must not become the place where experimental fixes are made. The next development change starts from `main` or a feature/checkpoint branch based on `main`, is tested in TEST, and is then promoted.

This separation follows the project's existing Live Launch & Test/Production Runbook and the standard practice of keeping staging and production environments separate.


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
- GitHub repository: `laurendigitaluk/TradeFlow`.
- **TEST branch:** `main`.
- **LIVE release branch:** `production`.
- Current TEST Release Candidate before this documentation/release-branch promotion: `ec6536818522a0e89d08f9defa68f557259cf280`.
- TEST Supabase: `nnsshnfkjcflucjrftzi`, eu-west-2, ACTIVE_HEALTHY.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`, eu-west-2, ACTIVE_HEALTHY. The earlier project-creation status is historical and superseded.
- Test One remains the frozen known-good historical baseline and must not be overwritten.
- Current TEST security hardening includes restricted client execution of SECURITY DEFINER functions and hardened payment/ledger trigger search paths.
- Manual shipping is authoritative; Parcel2Go API/checkout/payment-link shipping is retired.

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

The subscriber Business Dashboard is now deliberately separate from Website management. The daily operational flow is Buying → purchased → Inventory / Ready for sale → Selling → Orders → Fulfilment → Returns. Acquisitions remains an internal accounting/audit record and is not a separate user-facing workflow stage. Customers and Finance sit alongside the flow as supporting business functions. Website Builder is not embedded in this operational dashboard.

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


## Website Builder usability correction — 18 September 2026

The Website Builder was revised so a subscriber can understand and operate the template/page workflow without relying on hidden controls.

The builder now has explicit template buttons, a four-step navigation strip and a page index with an **Edit page** link for every available page. The page library covers business information, contact, legal/policy content, buying, FAQs, delivery/returns, payments, warranty/guarantees, complaints, Shop and Customer account. Recommended pages are shown by default; optional pages can be written without being placed in site navigation.

The builder preview also shows enabled page links. Page guidance is deliberately written as instructions for a business owner, including what information belongs on Terms & Conditions, Privacy Policy, Cookie Policy, Business Information and other customer-facing pages.

Important data-model rule: a Buying/Selling category is one `categories` record with `buying_enabled` and `selling_enabled` flags. Do not implement or document a second automatically-created selling category unless the database model is deliberately changed and audited.

The category and inventory frontend controllers now take the active tenant from the authenticated subscriber context instead of hardcoded test tenant maps. This preserves the existing tenant/RLS boundary while allowing newly provisioned subscribers to use those workspaces.

**State:** Implemented on main; browser verification remains open.


## Website Builder branded media, selling-page editing and domain entry — 18 September 2026

The Website Builder now supports a real visual-branding workflow. Homepage and page images can be uploaded to the tenant-scoped public website-media bucket, while upload/delete/update operations remain protected by tenant website permissions. Public visibility is intentional for assets used by published customer websites. citeturn0search0turn0search1

The Buying/Sell-to-us page and Retail Shop page are editable for business-specific presentation. Retail product records remain driven by Inventory and Selling; the builder does not duplicate operational product data.

The dashboard now links to Website URL management. Custom domains are stored in tenant_domains as pending until the hosting/DNS verification layer is defined. Do not hard-code a DNS target or mark a domain active without ownership/connection verification.

The publish RPC now accepts content schema version 2 as well as the legacy version 1.

**State:** Implemented on main; browser verification required.


## Visual Website Builder checkpoint — 18 September 2026

The Website Builder now follows a visual page-first workflow. Do not reintroduce a form-first page editor unless explicitly requested. The intended subscriber interaction is: choose a page → see the full page → click text to edit → add/replace an image on the page → save draft → publish.

The Buying / Sell to us page and Retail Shop page are intentionally editable content areas. Their transaction/product data remains connected to the existing operational workflow. Retail products are supplied by Inventory and Selling; buying requests remain connected to the Buying/Acquisitions chain.

The builder stores branding logo_url under site.branding and continues using tenant-scoped Storage uploads plus media_assets metadata. The public renderer reads the branding logo and page content from published site content.

Do not claim custom-domain automatic hosting is complete merely because the Website URL page exists. Domain records are still pending until the hosting target and ownership verification/routing boundary are implemented.

## Premium homepage checkpoint — 18 September 2026

Treat the subscriber homepage as a two-sided customer entry point. Do not reduce it to a generic brochure page. The intended structure is: premium hero → clear buying/selling split → visual `What we buy` tiles → visual `What we sell` tiles → trust/process strip → retail shop content.

The subscriber can choose 6, 8 or 10 homepage tiles. Tile copy and images are edited directly on the page. Product records must not be created in the Website Builder; selling tiles route to the existing Retail Shop, whose actual listings remain controlled by Inventory and Selling.

The Premium Marketplace template is a starting visual design, not a replacement for the subscriber's existing content.

## Subscriber Website Builder entitlement repair — 18 September 2026

When a newly created subscriber can authenticate but the Website Builder shows **Website could not be loaded**, check the subscription capability path before changing Builder RLS. The failure found here was a trialing subscription with trial_end null; private.has_tenant_feature() therefore returned false for website.editor and website.publish, correctly blocking the tenant's website state under existing RLS.

Migration 065_repair_subscriber_trial_entitlement_window.sql makes the signup RPC create the same 30-day trial window already used by the existing subscriber test pattern and backfills the affected trialing record. Live feature checks for the affected subscriber now return true for website.editor and website.publish.

Do not weaken tenant_site_state or site_revisions RLS to solve this class of error. First verify membership, active subscription status/window and the required plan feature.

**Status:** Implemented Live; browser refresh still required for final UI verification.


## Website branding, social and review settings — 18 September 2026

When extending subscriber website presentation, keep layout/template selection separate from tenant-controlled brand settings. The current Builder stores colour values under site.theme, social profiles under site.social and review links under site.reviews.

The supported colour controls are accent, text, page background, header/navigation, buying section, selling section and footer. Quick palettes are convenience presets only and can be edited afterwards.

Social settings support Facebook, Instagram, LinkedIn, YouTube, TikTok and X. Subscribers may enable website share buttons. Review links are subscriber-supplied labels and HTTPS/HTTP URLs, limited to four entries in the current UI.

Do not treat third-party reviews or social profiles as TradeFlow-verified information. Do not expose arbitrary non-web protocols from subscriber-entered URLs.

**Status:** Implemented in GitHub; live browser verification remains open.


## Restore checkpoint — 18 September 2026

This document is part of the locked TradeFlow stopping point for 18 September 2026. GitHub restore branch: checkpoint-tradeflow-20260918-premium-builder-final. Current main checkpoint commit: 0acc8d7ecca0de368172bf4fec1d746f11279dbd. Live Supabase includes migration repair_subscriber_trial_entitlement_window. Continue tomorrow from this checkpoint; do not modify GearCashOut.


## Domain purchasing foundation — 19 September 2026

The existing `tenant_domains` model was inspected before change. It already handled tenant-scoped custom-domain connection and published-site routing. The database has now been extended for a future built-in domain purchasing flow.

### Live database objects

`domain_tld_catalog`
- TLD catalogue and provider-neutral pricing configuration.
- Stores registration, renewal and transfer price fields without hard-coding a registrar.
- Availability is not treated as authoritative; final availability/pricing must be checked with the registrar immediately before purchase.

`tenant_domain_orders`
- Tenant-scoped domain registration/renewal/transfer order ledger.
- Tracks hostname/TLD, term, status, retail amount, registrar cost, payment references, provider references, purchase/expiry dates, auto-renew and failure state.
- RLS uses the existing tenant membership and website-management/editor permission boundaries.

`tenant_domains` extensions
- `acquisition_source`: connected / purchased / transferred.
- Registrar/provider identifiers, registration/expiry timestamps, auto-renew and non-secret provider metadata.

### Architectural decision

TradeFlow should eventually expose a Shopify-style flow:

**Subscriber Dashboard → Website/Domain → search domain → real-time availability/price check → customer confirmation → payment → registrar registration → domain record activation → DNS/hosting routing → SSL → published website.**

The database now supports that lifecycle without choosing a registrar or storing provider secrets.

The current `domain-settings.html` page remains a custom-domain connection screen and must not be described as a domain purchasing system. It currently creates/updates a pending `tenant_domains` record.
### Provider boundary

Registrar integration must be server-side. Do not place registrar API credentials in browser JavaScript, public GitHub code or tenant-visible database fields. Provider-specific identifiers may be stored; secrets must remain in server-side secrets/Edge Function configuration.

As of 19 September 2026, current Cloudflare Registrar documentation describes a Search → authoritative Check → Registration workflow and warns that availability/pricing from search is not the source of truth. Its Registrar API also has extension and premium-domain limitations, so provider/TLD support must be verified before committing to a production registrar design. citeturn2search0turn2search1

### Verification state

**Database foundation: Implemented and schema-verified.**

**Purchase UI/payment/registrar/DNS/SSL lifecycle: Proposed/Planned.**

### Continuity rule

Do not add provider-specific purchase code until the registrar, payment boundary, ownership/registrant model and multi-subscriber hosting/DNS architecture have been selected and audited against current GitHub/Supabase state.



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

Homepage hero images are explicitly independent: homepage.image_url is the main image and homepage.image_url2 is the optional second image. The builder labels these controls accordingly and does not reuse the first image automatically. Homepage tile images remain independently stored per tile. Uploaded images use contain behaviour so the complete photograph remains visible.

Header branding was refined so an uploaded logo is shown instead of also displaying the editable business-name text beside it. Logo dimensions preserve the complete image proportion within the responsive header. If no logo is uploaded, the business name remains editable text.


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
- `tenant_buying_products`: exact manufacturer/model/package records that a subscriber buys, with active status, automatic percentage of researched UK New price, optional manual offer price, and pricing notes.
- `tenant_buying_research`: product-level research evidence with UK New, UK Used/Other and Overseas evidence types, source, URL, observed price, currency, condition, availability, notes and checked timestamp.

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


## Buying Research / Condition Model Update — 19 September 2026
The subscriber buying catalogue now has five conditions: Sealed, Opened Never Used, Excellent, Good, Poor. UK New research feeds the first two; UK Used research feeds the last three. Research evidence is read-only in What We Buy. Subscriber-entered research is recorded through Research Centre in `tenant_buying_research`. Future Gemma research should write compatible evidence into the same tenant-scoped table and must not bypass RLS or fabricate evidence.


## Buying Price Calculation Update — 19 September 2026
Gemma/research automation must continue to write evidence into `tenant_buying_research`. Subscriber pricing is not locked to one research type: each condition has its own selected reference (`uk_new` or `uk_used`), percentage, and optional exact manual override. Manual override takes priority over research-based calculation. Do not fabricate a reference price when research is absent.


## Buying Catalogue Structure — 19 September 2026
Use the canonical hierarchy Category → Branch / Type → Manufacturer → Model. Do not treat manufacturer as the first subdivision of a category. Research, pricing rules and products should retain their tenant/category/branch/product relationships. Example: Cameras → Digital → Canon → EOS 750D.


## Bulk Buying Pricing Profiles — 19 September 2026
The subscriber can apply a predefined percentage ladder to all products in the selected branch. The four current profiles start at 70%, 60%, 50%, or 40% for Sealed and step down through Opened Never Used, Excellent, Good and Poor. Bulk application must not overwrite research or manual override fields.


## Selectable Bulk Pricing — 19 September 2026
When bulk pricing is applied, update only `tenant_buying_condition_rules` reference-type and percentage fields. Never overwrite research evidence or manual override prices. The selected manufacturer/model filters define the visible selection scope; explicit product selection is authoritative.


## Universal Research Basis Rule — 19 September 2026
The selected automatic reference is product-level, not condition-level. For a selected product, all five conditions use the same chosen research basis; only their percentages differ. Missing selected-basis research must not be replaced with another evidence type without explicit subscriber action.


## Manual Override Precedence — 19 September 2026
A non-null manual override is authoritative for that condition. Automatic percentage output may still be displayed for comparison but must not be treated as the active buying price. Clearing the manual override returns the condition to the automatic percentage path.


## Buying Price Reset Safety — 19 September 2026
Never silently delete pricing rules when a research basis changes. A basis change may make automatic pricing unavailable, but stored rules remain until the subscriber explicitly uses the two-step Reset selected prices action. Resetting clears percentages, reference choices and manual overrides for the selected products.


## Standalone Master Catalogue — 19 September 2026
- The TradeFlow master catalogue is an independent snapshot. GearCashOut / Action Buyer UK may be used only as the initial import source; never query its live catalogue for subscriber operations.
- Do not copy or use GearCashOut retailer-price evidence, research evidence or market-pricing fields as TradeFlow buying references. Subscriber pricing must come from TradeFlow's own research and condition-pricing rules.
- Current imported master snapshot: 34 categories, 179 branches/types, 73 manufacturers, 3,845 products and 108 product identifiers.
- The current live entitlement is `catalogue.pre_filled` on the **Catalogue** plan. Do not silently move this entitlement to Enhanced.
- The protected seed RPC copies master data into tenant-owned catalogue tables. After seeding, treat tenant data as independent and do not create runtime dependencies on the source snapshot.
- Buying-catalogue startup now calls the seed RPC for eligible Catalogue tenants. The seed is idempotent through `tenant_catalogue_state`.
- The What We Buy script also contains the two-step reset handler. Never replace the protected reset with a one-click destructive action.


## 19 September 2026 — Master catalogue entitlement expanded

The independent TradeFlow master catalogue remains a separate snapshot from GearCashOut / Action Buyer UK. The catalogue.pre_filled entitlement has now been enabled for all three active customer-facing plans: **Basic, Enhanced and Catalogue**. Each plan receives the same unlimited category/product/subcategory entitlement configuration. This changes access entitlement only; it does not create a runtime dependency on GearCashOut and does not import GearCashOut research or pricing evidence into subscriber buying references.

Verification: live plan_features confirms catalogue.pre_filled enabled for Basic, Enhanced and Catalogue. The actual tenant catalogue seed/copy path remains tenant-owned and must continue to use the TradeFlow master snapshot.


## 19 September 2026 — Master catalogue duplicate-category cleanup

After importing the standalone TradeFlow master catalogue, inspect the copied category tree for obvious duplicate category records before relying on it for subscriber selection. GearCashOut is the source snapshot only; it must not be queried by subscriber runtime code and must not be modified during cleanup.

The live TradeFlow master catalogue was cleaned as follows:
- Drone was merged into canonical Drones, including its product and branch.
- Tripod/Support was merged into canonical Tripods; its products were moved and its duplicate Tripods branch was merged into the existing canonical branch.
- The duplicate category records were then deleted.
Do not automatically merge broader/similar category names merely because they contain overlapping words. Categories such as Cameras and Camera & Video require a deliberate taxonomy decision before consolidation.

The migration was applied to TradeFlow only and verified by re-querying the category records. The next browser step is to refresh What We Buy and verify that the cleaned master category list is what the subscriber selector consumes.


## 2026-09-19 — Buying Catalogue Master Copy & Cascading Selectors

- The subscriber Buying Catalogue uses the TradeFlow-local master catalogue tables (catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers, catalogue_master_products) as the seed source. The subscriber copy is tenant-owned in categories, category_branches, tenant_buying_manufacturers, and tenant_buying_products and does not query GearCashOut at runtime or use GearCashOut research/pricing for valuations.
- The current master snapshot contains 32 categories, 178 branches, 73 manufacturers and 3,837 active products. The test subscriber has its own tenant copy and can diverge independently.
- Buying Catalogue selectors are now cascading: Category → relevant Manufacturers → relevant Branches for the selected manufacturer → Models in the selected branch/manufacturer. Changing an upstream selection resets and reloads downstream selections rather than leaving unrelated values available.
- buying-catalogue.js commit ff575e5204f7cb3efc12284a5109be0610334a5b implements the selector dependency logic. buying-catalogue.html commit 34771b980131a4be683179ecf6f6f8b5a21ce2c9 changes Model to a dependent select and cache-busts the JS to v16.
- Syntax check passed with new Function() after the selector change. Live browser verification is still required after a hard refresh.

## 21. Buying master catalogue and selector repair — 19 September 2026

The subscriber Buying Catalogue is now backed by a standalone TradeFlow master catalogue copy rather than any live GearCashOut query.

Verified live TradeFlow master data:
- 32 categories
- 178 branches
- 73 manufacturers
- 3,845 products

The subscriber seed RPC copies from `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_manufacturers` and `catalogue_master_products` only. It does not reference GearCashOut.

Package boundary:
- Basic: `catalogue.pre_filled = false`
- Enhanced: `catalogue.pre_filled = true`
- Catalogue: `catalogue.pre_filled = true`

A current source inspection found the Buying Catalogue calling an undefined `loadCategoryScope()` during category startup. This was repaired so category products are loaded before the manufacturer filter and branch selection are initialised. The controller cache-buster is now `v17`.

The existing test tenant was cleaned of stale `Drone` and `Tripod/Support` aliases while preserving the unrelated custom `Accessories` category and the manually entered Canon product.

State: **Implemented + database tested; browser verification remains open.**


## 2026-09-19 — Master catalogue package boundary and cache repair

The TradeFlow master catalogue is a standalone copy used to seed eligible subscriber catalogues. It contains 32 categories, 178 branches, 73 manufacturers and 3,845 products. Runtime tenant buying logic reads tenant-owned catalogue records after seeding; it does not query GearCashOut.

The catalogue.pre_filled feature is enabled for Enhanced and Catalogue and disabled for Basic. The current browser test tenant is Basic, so it should not be expected to receive the master catalogue until the test entitlement is changed or an Enhanced/Catalogue tenant is used.

The Buying Catalogue controller contains loadCategoryScope(). The deployed page was still reporting that function as undefined, indicating stale deployed JavaScript rather than a missing current source function. buying-catalogue.html now loads controller version v18. Development-only explanatory master-catalogue banner text was removed from the page.

State: Implemented + database verified; browser verification OPEN.




## 19 September 2026 — Master catalogue selection boundary

Gemma and future research automation must treat the TradeFlow master catalogue as a separate taxonomy/product snapshot. Subscriber selection is recorded in `tenant_catalogue_selections`; do not query GearCashOut / Action Buyer UK at runtime.

Research and pricing evidence remain separate from catalogue identity. Selecting a master product for Buying creates/activates the tenant-owned `tenant_buying_products` record; it does not copy or adopt GearCashOut retailer prices, research evidence or valuation decisions.

The subscriber UI now supports product-level Buying and Selling Website activation. Category and branch records are created automatically for selected master products. Custom categories remain tenant-only and are used when a required product is not present in the master catalogue.

AI agents must not silently enable products, alter subscription entitlement, or import external pricing evidence as a consequence of catalogue selection. Catalogue identity, subscriber activation, research evidence and buying-price configuration are separate concerns.



### 19 September 2026 — Buying Prices no longer seeds the entire tenant catalogue

The separate Buying Prices workspace no longer calls `seed_tenant_master_catalogue()` when it opens. Catalogue activation is now an explicit subscriber action on Catalogue & Categories. Buying Prices works on products already selected for Buying and remains responsible for condition percentages, research basis and manual overrides. The legacy seed RPC remains available for controlled migration/maintenance but is no longer the normal subscriber page startup path.


## 2026-09-19 — Catalogue workflow rule

For subscriber catalogue work, treat the TradeFlow master catalogue as an independent copy. Do not introduce runtime reads from GearCashOut / Action Buyer UK. Enhanced/Catalogue subscribers select master products from the unified Buying Catalogue; selection creates the tenant category/branch/manufacturer and buying product automatically. If no research-based or manual buying price is configured, valuation must remain manual rather than inventing a price.


### Post-change verification — 2026-09-19
Verified the catalogue selection RPC under an authenticated test identity: 3,822 active/customer-visible master products were returned. Transaction-scoped activation produced the expected tenant category/branch/product and blank pricing, then was rolled back.

## 19 September 2026 — Buying Catalogue / Pricing architecture update

Gemma and future TradeFlow automation must treat the TradeFlow master catalogue as an independent product taxonomy. The source tables are `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_manufacturers` and `catalogue_master_products`. GearCashOut is not a runtime data source for TradeFlow and must not be queried for subscriber pricing.

Subscriber Buying configuration is now controlled from `buying-catalogue.html` / `buying-catalogue.js`. The automation boundary is:
**master product → subscriber buying mode → tenant category/branch/manufacturer/product → pricing configuration → Buying valuation**.

Modes are:
- `off`: product is not active for the subscriber's Buying workflow;
- `manual`: a tenant product-level manual buying price may be stored;
- `automatic`: condition percentages are stored in `tenant_buying_condition_rules` and use the configured UK New/UK Used research references.

The protected RPC `configure_master_catalogue_buying_product()` is the authoritative write path for this master-product-to-tenant configuration. Automation must not bypass it by directly creating tenant categories/products when the user is selecting a master catalogue item.

Research remains separate from subscriber pricing configuration. The subscriber pricing page must not edit research evidence. Automatic valuation continues to use `calculate_buying_item_valuation()`; product-level manual buying price now takes precedence before condition-based automatic pricing.

No runtime integration with GearCashOut is permitted for this workflow.


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


## Live Buying Workflow Dashboard Repair — 21 September 2026

When diagnosing the subscriber Buying/workflow screens, start with the live GitHub main branch and live Supabase state. Do not recreate the buying architecture.

### Confirmed failure
The subscriber dashboard queried the live buying data successfully but then attempted to write the acquisition count to count-received, while the HTML element is count-acquisitions. That null DOM reference threw inside the workflow renderer and caused the catch block to display Workflow status could not be loaded. Open Buying for the full record.

### Repair
The dashboard now writes to count-acquisitions and counts active acquisitions from the existing workflow statuses. buying-dashboard.html also cache-busts buying-dashboard.js to v10.

### Structured customer fields
The authoritative field metadata column is category_fields.label. Never query or render category_fields.name. The existing subscriber_get_buying_item_customer_details path returns the customer, request notes, item data and structured field values using label.

### Security boundary
No tenant/RLS architecture was changed. The repair is UI/controller-only. Existing tenant-scoped REST/RPC access remains the source of truth.

## Accepted Offer → Shipping Label Handoff — 21 September 2026

### Correct lifecycle
Customer accepts published offer → acquisition exists with status `accepted` → subscriber must send/provide shipping label → acquisition moves to `awaiting_item` → customer receives label/instructions → customer posts item → receiving workflow continues.

### Important state rule
Do not use only `buying_requests.status` or `buying_items.status` to decide whether the customer has accepted. The live test exposed a valid accepted offer/acquisition while the request and item statuses still showed `offer_ready`. Subscriber workflow rendering now checks the accepted offer and linked acquisition first.

### Existing shipping infrastructure
`acquisitions` already contains `shipping_label_url`, `shipping_carrier`, `shipping_service`, `shipping_tracking_number`, `shipping_instructions` and `posted_at`. `customer_get_acquisition_shipping()` exposes these fields to the authenticated customer. Do not create duplicate shipping tables for this workflow.

### Subscriber action
The current subscriber Buying detail provides a shipping handoff form. Publishing the label updates the existing acquisition and uses `transition_workflow_entity()` for `accepted` → `awaiting_item`. No direct acquisition status update is used.

### Customer side
The Customer Portal's accepted-sale message now describes the next step as awaiting the subscriber's shipping label. Its existing shipping handover section remains the source for the label, instructions, tracking and customer post confirmation.

## Buying Dashboard Acquisition Query Regression — 21 September 2026

A live browser test showed the accepted-offer UI repair was not taking effect. Inspection of `buying-dashboard.js` found that both `load()` and `refreshBuyingStatus()` destructured an `acquisitions` result and used it to derive the accepted state, but their `Promise.all()` arrays did not include the acquisitions REST query. This left `acquisitions` undefined/empty and caused the accepted-state test to fall through to the approved valuation state.

Repair rule: when accepted-state logic depends on an existing linked table, verify the table query is present in every data-loading path that supplies the derived state. The repair adds the existing tenant-scoped acquisitions query to both loading paths. No schema, RLS, or workflow architecture change is required.


## Acquisition SELECT Grant Regression — 21 September 2026

The follow-up browser test returned `permission denied for table acquisitions`. Database inspection showed the existing `acquisitions_subscription_select` RLS policy was present and the owner role had `acquisitions.view`, but the PostgREST `authenticated` role lacked table-level `SELECT` on `public.acquisitions`. It also lacked `UPDATE`, which would have blocked the later shipping handoff PATCH. The repair migration grants `SELECT, UPDATE` to `authenticated`; existing RLS policies continue to enforce tenant permission and the buying subscription feature.


## Duplicate Lifecycle Renderer Repair — 21 September 2026

Deep code audit found two lifecycle presentation paths: the request-level state correctly derived `offer_accepted` from the accepted offer/acquisition, while `loadItemFinancials()` separately rendered a legacy approved-valuation/no-offer message when its local offer query was empty. This was the second renderer capable of contradicting the authoritative request state. The repair passes `requestStatus` into `loadItemFinancials()` and explicitly prevents the pending-offer message when the request is `offer_accepted`. The existing status refresh is now started after the initial load so an already-open workspace can update when the customer accepts an offer.

## Accepted Offer Visibility and Customer Field RPC Repairs — 21 September 2026

When an accepted offer appears as an approved valuation/no-offer state in the subscriber Buying page, do not assume the frontend renderer is the remaining fault. Test the REST reads under the actual authenticated role.

The live root cause was policy composition: offers_subscription_select and acquisitions_subscription_select were RESTRICTIVE SELECT policies with no permissive SELECT policy on those tables. PostgreSQL therefore returned zero rows rather than an error. The existing permission checks were correct. Migration repair_offer_and_acquisition_select_policies added permissive tenant-member SELECT policies and left the restrictive subscription permission/feature checks intact.

A separate customer-detail error, CASE types jsonb and text cannot be matched, came from subscriber_get_buying_item_customer_details(). Its CASE expression returned text for text-like fields and jsonb for other branches. Migration repair_subscriber_customer_field_json_types converts text-like values with to_jsonb().

Diagnostic rule: for an apparently missing accepted offer, verify table grants, then SELECT-policy composition (at least one permissive policy plus all restrictive policies), then the frontend mapping. A zero-row RLS result is different from a permission error and can silently force fallback lifecycle states.

## Shipping Label Upload and Resend — 21 September 2026

The accepted-offer shipping handoff now supports two label sources:

- **Shipping label URL** — paste the label URL supplied by the carrier.
- **Uploaded shipping label** — upload a PDF, PNG or JPEG directly to TradeFlow.

Uploaded labels are stored in the existing private `tradeflow-media` bucket under the tenant/acquisition path. The customer can access only the label belonging to their own acquisition. The subscriber can open/print the label from the Buying or Acquisition workspace.

The shipping handoff action is now **Send shipping label to customer** initially, then **Save & resend shipping label** when a label already exists. This republishes the current label/instructions to the customer portal without creating a duplicate acquisition or offer.

The Customer Portal shows **Open / print shipping label** and **Download shipping label** when an uploaded label exists. Signed links are generated on demand rather than permanently exposing the private storage object.


## Shipping Service Override — 21 September 2026

Shipping is deliberately modelled as a route on the existing acquisitions record, not as a second acquisition/shipping entity.

New acquisition fields:
- shipping_method: subscriber_override or automated;
- shipping_qr_url;
- shipping_qr_storage_path.

Current production behaviour defaults existing/new acquisitions to subscriber_override until the Voila automated integration is connected. The UI exposes the future automated route but disables it rather than pretending it is operational.

Subscriber override sources are:
1. label URL;
2. uploaded label;
3. QR code URL;
4. uploaded QR image.

A valid manual handoff may contain a label, QR code, or both. Publishing continues to use the existing acquisition workflow transition accepted → awaiting_item.

Uploaded QR images use the existing private tradeflow-media bucket and the same tenant/acquisition path structure as shipping labels. The existing customer storage SELECT policy matches the acquisition path and customer identity, so no broad public storage policy is introduced.

The customer RPC customer_get_acquisition_shipping() now returns the shipping method and QR sources in addition to the existing label/tracking fields.

### Future Voila integration boundary

Do not put Voila credentials in subscriber JavaScript. The intended automated route is a server-side/Edge Function integration that calls Voila, stores the returned label/tracking data on the existing acquisition, and exposes the resulting handoff through the same customer portal. Voila documentation describes API accounts, courier credentials, label creation, tracking and webhooks. Consult the current Voila API documentation when implementing that layer.


## Shipping Cost Boundary — 21 September 2026

Shipping for customer selling/acquisition requests is customer-paid and customer-arranged. Do not introduce TradeFlow shipping charges, customer shipping invoices, shipping reimbursements, shipping expenses, or shipping-margin calculations into the acquisition/offer model. Shipping label and tracking data are operational handoff data only.

The existing `acquisitions.shipping_*` fields remain the authoritative handoff record. Automated Voila integration must preserve this boundary: it may obtain/generate the operational label and tracking information through the configured courier connection, but it must not create a TradeFlow shipping payment or expense ledger.

## Connected shipping implementation
Parcel2Go is the first automated shipping provider implementation. The subscriber-owned provider connection is stored securely, the customer can request a server-side quote, choose a service and receive Parcel2Go's payment/deeplink. Shipping money never passes through TradeFlow. Future work must add signed Parcel2Go webhooks, post-payment label retrieval and tracking synchronisation before describing the route as fully automated.


### Shipping state authority — 22 September 2026

Do not infer that the customer has sent an item from `posted_at`, `shipping_status=ready_for_customer`, or publication of a shipping handoff. `acquisitions.customer_sent_at` is the authoritative customer confirmation timestamp. Before it is set, the subscriber state is Awaiting item from customer. `customer_mark_acquisition_posted` sets `customer_sent_at` and `shipping_status=in_transit`. The authoritative acquisition workflow status remains `awaiting_item` until the subscriber confirms receipt; the Buying Dashboard derives the visible **Item on its way — awaiting receipt** stage from the customer-sent shipping state.

`shipping_service_url` is a provider/service link and must never be rendered as the physical shipping label or QR asset. Physical label and QR download/print actions use the private storage paths. Shipping provider connections are tenant-wide and are shared by Buying/acquisitions and Retail Shop sales/fulfilment.


## 22 September 2026 — Shipping handoff recovery and receipt authority

The shipping handoff has three distinct data concepts and they must not be conflated:
1. provider/service website link (shipping_service_url);
2. physical shipping label (shipping_label_url or shipping_label_storage_path);
3. physical QR code (shipping_qr_url or shipping_qr_storage_path).

The physical label/QR controls operate on the actual private storage asset. Provider links are informational navigation only.

Customer confirmation is recorded by customer_mark_acquisition_posted, which sets customer_sent_at and shipping_status=in_transit. The acquisition workflow status remains awaiting_item until receipt. Subscriber UI derives the visible **Item on its way — awaiting receipt** state from the customer-sent shipping state.

Receipt authority is subscriber_mark_acquisition_received, which checks tenant acquisition-management permission, requires awaiting_item plus shipping_status=in_transit, performs the authoritative awaiting_item → received workflow transition, then records shipping_status=received.

A material diagnostic lesson from the September 2026 test: uploaded label files can exist in storage.objects even when the acquisition's label path has been lost/null. Therefore, when a subscriber reports a missing label, inspect the acquisition record and the exact tenant/acquisition storage path before assuming the physical file was deleted. Restore the acquisition reference where the correct private object is still present.


## 2026-09-22 — Receipt workflow root cause and repair

Investigated the live receipt path before changing code. The existing `subscriber_mark_acquisition_received` RPC correctly authenticates the subscriber and uses `transition_workflow_entity`, and the live test acquisition `ACQ-B11FB7341903` is now `received` with `received_at` recorded. The main defect was downstream state presentation: the customer renderer did not have an explicit received/inspection stage, while the subscriber Buying renderer mapped received acquisitions back to the generic shipping state. A targeted frontend repair now exposes `received` and `inspection` states. The receipt RPC was also hardened so acquisition-item records are synchronised through authoritative transitions. Frontend cache versions were advanced and both modified JavaScript files passed parse-only syntax checks. The next investigation is inspection/valuation status separation; do not collapse accepted offer, acquisition value, approved valuation, inspection/revaluation and final valuation.


## 2026-09-22 — Purchasing inspection implementation

The next workflow after receipt is now implemented in the Subscriber Buying/Purchasing workspace rather than the legacy Acquisition test workspace. New `buying-inspection.js` is loaded by `buying-dashboard.html` and provides the received-stage CTA, inspection form, evidence-photo upload and completion routing.

Database authority:
- `subscriber_start_acquisition_inspection(uuid, uuid)` creates/reuses the inventory asset and uses `transition_workflow_entity` for acquisition, acquisition-item and inventory-asset status changes.
- `subscriber_complete_acquisition_inspection(uuid, uuid, text, boolean, text, text, jsonb)` records the inspection in `inventory_inspections`, updates the linked inventory asset, and only sends an item to Sales when the inspection outcome is `ready_for_sale` and the required confirmation checks pass.

The inspection metadata preserves the customer-description snapshot, condition confirmation, checklist results and discrepancies. Repair/testing outcomes remain in Purchasing/Repairs. Sales receives the completed inspection as read-only through the ready-for-sale inventory path.


## 2026-09-22 — Corrected post-receipt architecture

Do not interpret inspection complete as immediate Sales readiness. The accepted acquisition offer and the post-inspection final offer are separate records. A passed inspection creates an authoritative completed inspection and moves acquisition/acquisition-item to finalised, but leaves the linked inventory asset in inspection until the final offer is accepted and the subsequent payment process completes.

The Buying dashboard owns the received CTA and inspection UI. The post-inspection workspace creates a separate approved trading_values record and a final offer; it does not overwrite the original accepted offer.

Customer-facing copy must not expose the internal role term subscriber. Use customer/business-facing wording such as the business or the website.


## 2026-09-22 — Inspection CTA ownership and customer wording follow-up

The inspection CTA is now handled by the main Buying dashboard as the authoritative workflow controller. The supplemental inspection workspace delegates its `START INSPECTION` click to that controller when available, preventing the CTA from appearing clickable while being owned by a separate polling script. Customer selling-status wording has also been removed from the internal `subscriber` terminology, including receipt and inspection messages. Browser cache versions were incremented for the Buying and customer dashboard scripts.


## 2026-09-22 — Inspection notice and direct Testing navigation

AI operating note — when diagnosing Purchasing receipt/inspection UI, treat acquisitions.status as authoritative for the open-request workflow notice rather than relying solely on the buying request status. The inspection workspace provides a direct Testing link using inventory-dashboard.html?status=testing&asset=<inventory_asset_id>; do not invent a separate testing state machine.

## 2026-09-22 — Pre-acquisition purchasing boundary is authoritative

The previous implementation incorrectly used acquisitions and inventory_assets as soon as the customer's initial offer was accepted/received. This is now superseded.

Authoritative boundary:

- buying_items.purchase_stage is the state machine for the period before purchase.
- buying_item_shipping stores shipping/receipt handoff data before acquisition.
- buying_item_inspections stores inspection outcomes before acquisition.
- buying_item_media stores inspection photographs before acquisition.
- acquisitions, acquisition_items, payment_records, and inventory_assets are created only by subscriber_complete_purchase, after a **final offer has been accepted by the customer** and the **bank payment has been recorded**.

Purchase-stage values currently used are: none, awaiting_item, shipping, received, inspection, testing, repair, return_pending, final_offer_required, final_offer_sent, final_offer_accepted, final_offer_refused, payment_pending, and purchased.

Do not reintroduce an acquisition/inventory record at receipt, inspection start, inspection completion, or final-offer creation. The initial accepted offer is not the purchase. The final accepted offer is not the purchase until payment is recorded.

Relevant RPCs:
- subscriber_publish_buying_item_shipping_handoff
- subscriber_mark_buying_item_received
- subscriber_start_buying_item_inspection
- subscriber_complete_buying_item_inspection
- subscriber_publish_final_offer
- subscriber_complete_purchase
- customer_get_pre_acquisition_shipping
- customer_mark_buying_item_posted

The customer selling-status RPC now reads buying_items.purchase_stage first. The customer portal and Buying dashboard therefore remain aligned without deriving pre-purchase stages from acquisitions.

### Additional boundary repair — acquisition visibility

Customer-facing and subscriber-facing acquisition lists now restrict acquisition visibility to paid/completed purchases. Pre-acquisition stages are represented by buying_items.purchase_stage instead. Initial and revised customer offers both enter the pre-acquisition receipt workflow when accepted; only final offers can lead to final_offer_accepted and payment-gated purchase creation.

## 2026-09-22 — Dashboard attention visibility

The business dashboard must not derive active purchasing work solely from acquisitions. Pre-acquisition stages live on buying_items.purchase_stage and must be included in the live workflow/job board. In particular, received, inspection, testing, repair, return_pending, final_offer_required and final_offer_accepted are actionable pre-purchase stages.

The Buying inspection state also exposes an **OPEN INSPECTION** shortcut. This is navigation only and must not mutate workflow state.
## 2026-09-22 — Inspection navigation target

When linking to the inspection from Buying, target `#tradeflow-inspection-workspace`, not `#item-detail`. The inspection workspace is an embedded section on the Buying request page; there is no separate inspection HTML page.
## 2026-09-22 — Async inspection navigation

Do not rely on a plain hash jump to the inspection workspace because `buying-inspection.js` creates `#tradeflow-inspection-workspace` asynchronously. The Buying dashboard navigation must wait for that element and then call `scrollIntoView`.
## 2026-09-22 — Workflow dashboard CTA

The live dashboard must count `purchase_stage` values independently of acquisition records. `inspection`, `testing`, `repair`, `return_pending`, `final_offer_required` and `final_offer_accepted` belong in **Needs attention**. Inspection rows must link to `buying-dashboard.html?request=<request_id>#tradeflow-inspection-workspace`; the Buying page reads the request parameter, opens that request and scrolls to the rendered inspection workspace.

## 2026-09-23 — Purchase boundary audit

Treat buying_items.purchase_stage as the authoritative pre-acquisition workflow. Never create acquisitions or inventory from initial offer acceptance, receipt, inspection, testing or repair.

The only purchase-completion path is final_offer_accepted -> record outbound bank payment -> create acquisition/acquisition item/inventory asset. Database triggers now enforce this boundary.

The business dashboard uses subscriber_get_business_workflow as its authoritative workflow read model. Do not rebuild the dashboard by assuming acquisitions exist for pre-purchase stages.

The repository currently has migration-history drift from live Supabase changes made on 2026-09-22. Before future database refactoring, reconcile the remote migration history into supabase/migrations so the repository and live schema are reproducible.

## 2026-09-23 — Inspection navigation/rendering repair

The previous async-navigation repair was incomplete because the navigation code waited for the inspection workspace but did not actively force the renderer when the element was absent. In addition, buying-inspection.js performed the optional buying_item_media lookup before appending the workspace, so a media lookup failure could abort rendering entirely.

Current contract:
- OPEN INSPECTION prevents the native hash action.
- It invokes window.tradeflowRefreshInspectionWorkspace() when the workspace is absent.
- The renderer appends the inspection workspace even when inspection-media lookup fails.
- The renderer returns a success flag and reports core rendering errors visibly.

## 2026-09-23 — Sales Channel administration foundation

Sales Channels is now a configurable tenant-scoped management layer rather than a fixed display of virtual marketplaces. The current page supports CRUD-style administration within the existing sales_channels RLS/permission model: authenticated subscribers with selling.manage and module.selling may create, edit, disable and remove channel records.

The test tenant was seeded with eBay, Amazon and Other channel records, all initially active=false and settings.connection_status='not_connected'. TradeFlow Website remains the active storefront channel. Connection instructions are stored in the existing settings JSONB field as editable connection_instructions; no new credential fields were introduced and no marketplace secrets are stored in the browser.

Removal is intentionally guarded: a channel with active listings is disabled rather than deleted, preserving listing history and asset/channel relationships. A channel with no active listings can be deleted. The core TradeFlow Website channel is not removable from this page.

The eBay guidance reflects the current eBay OAuth/Inventory API requirements: seller authorization uses OAuth user access, application scopes must cover the required methods, and publishing Inventory API offers requires an inventory location plus payment, fulfillment and return business policies. The Amazon guidance reflects current SP-API onboarding: developer/application registration, approved roles, and seller authorization via the applicable OAuth/Login with Amazon or private self-authorization route.

Actual marketplace OAuth/API handshakes are deliberately not simulated by changing a status flag. The next integration stage must add secure server-side credential handling, connection callbacks, token refresh/revocation handling and channel-specific listing synchronization.



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



## Documentation catch-up — Test One restore baseline — 23 September 2026

This document is synchronised with the locked Test One baseline.

### Known-good end-to-end path

New subscriber/business → new subscriber customer → customer request/selling journey → buying/valuation → offer → inspection → payment/bank-detail handoff → purchase completion → Inventory → Selling → Sales Channels → published retail website listing.

### Locked restore point

- GitHub repository: `laurendigitaluk/TradeFlow`
- Restore branch: `checkpoint-test-one-20260923`
- Functional baseline commit: `80c6e20b4fa89b37ed6fab2480fb1eb46293a0d1`
- Checkpoint documentation commit on the restore branch: `ea00d6ae238f6e47c4798b73ec6340ade2c2d5fd`
- Supabase project: `nnsshnfkjcflucjrftzi`

### Test Two rule

Test Two is a new validation run against this known-good baseline. Do not overwrite or redesign working Test One behaviour merely because a Test Two step fails. Identify the first failing boundary, compare it with this checkpoint, and repair only the required layer.

### Remaining identified subscriber website work

The remaining subscriber-facing website feature is payment processing for the subscriber's own **Subscribe / receive payments** journey. This is separate from the already completed customer purchase/payment workflow used during Test One.

### Channel state

The Sales Channels foundation is part of the Test One baseline. The physical Inventory asset remains the single stock master record. TradeFlow Website is the active storefront channel; eBay, Amazon and Other are configurable tenant channels but are not actually connected to external marketplace APIs yet.

### Verification language

Use these states precisely: **Implemented in GitHub**, **Live DB verified**, **Browser verified**, and **Checkpointed**. Do not call something browser verified unless it has actually been exercised in the browser.


## Website Builder branding consolidation — 23 September 2026

The subscriber Website Builder now treats customer-facing branding as one grouped control area. The **Branding** section owns the website logo and homepage banner, while Business Settings retains business identity/contact data. Do not reintroduce duplicate logo/banner upload controls into Business Settings.

Implementation notes:
- website-builder.js loads the draft `site.branding.logo_url` and `site.branding.banner_url` when those keys are present, so an explicit draft removal is not silently replaced by profile fallback data;
- the Builder preview uses the branding banner as the primary hero image, matching the public-site renderer, with the homepage hero image as fallback;
- the public renderer now respects an explicitly published empty `site.branding.logo_url`, allowing a subscriber to remove a logo without the older profile value reappearing;
- the current Camerashack tenant profile and draft were reconciled with the existing tenant-scoped logo/banner assets;
- Business Settings branding upload controls were removed; its website identity panel now links to Website Builder → Branding.

Do not mark this change as browser-verified unless the Builder Branding section, draft preview and public homepage have actually been exercised in the browser.


## Website banner display correction — 24 September 2026

The dedicated `site.branding.banner_url` is rendered as a compact horizontal branding slot in the **What We Sell** title area, replacing the normal shop logo/title image slot. It is not rendered as a page-wide banner beneath navigation. Homepage hero imagery remains separate. The Builder preview mirrors this same placement. This is the authoritative presentation of the dedicated banner.


## 24 September 2026 — Buying dashboard active/completed separation
The subscriber Buying dashboard must distinguish active buying work from completed purchases. If a buying item has `purchase_stage='purchased'` or is linked to an acquisition with `status='paid'`, treat it as completed and do not render it in the active request workspace or expose create/approve valuation or create/publish offer controls as outstanding work. Completed purchases belong in the dedicated Completed purchases section. Closed requests are excluded from active work.

## 24 September 2026 — Customer portal completed sales and order cancellation

Customer portal separation rules:
- Do not present buying_requests with status='closed' as active customer selling requests.
- Treat buying_items.purchase_stage='purchased' and paid/completed acquisitions as completed purchase history.
- Display paid/completed acquisitions in **Completed sales to Camera Shack** rather than active accepted-sales work.
- Keep accepted but not yet paid acquisitions in **Accepted sales & payment**.
- Customer selling-request counters must exclude completed/closed selling work.

Retail order cancellation:
- Customer cancellation is implemented through customer_cancel_retail_order(p_tenant_id,p_order_id,p_reason).
- The RPC authenticates the customer, verifies tenant ownership of the order, permits cancellation only from initiated or pending_payment, records cancelled_at, and writes a workflow_transitions audit record.
- Do not expose customer cancellation for paid, fulfilment, completed, refunded, or already-cancelled orders.


## 24 September 2026 — Parcel2Go shipping integration standard

Use Parcel2Go as TradeFlow's single integrated multi-carrier provider. Do not reintroduce separate Royal Mail, Evri, Yodel, DPD, DHL, UPS or FedEx credential setup unless the architecture is explicitly changed and checkpointed.

For each tenant, the normal setup is:
1. Subscriber enters Parcel2Go Client ID and Client Secret in Shipping Settings.
2. TradeFlow stores the secret in Supabase Vault through the tenant-authorized connection RPC.
3. TradeFlow tests OAuth server-side through the shipping-provider-test Edge Function.
4. Successful authentication changes the tenant connection to connected.
5. Buying uses the connected Parcel2Go account as the integrated shipping connection.

Never place the Client Secret in browser code, ordinary public table columns, logs, or customer-visible responses. Credential testing must not create a shipment.

Parcel2Go's official API documents OAuth2 client credentials, live/sandbox separation, quoting, orders, payments, labels and tracking. Sandbox and live credentials are separate, so do not test a sandbox credential against the live host. citeturn2view0turn3view0

Verification state: browser verified on 24 September 2026 for the Camerashack test subscriber against Parcel2Go Live. The connection displayed Connected and reported that authentication passed with no shipment created.

Implementation note: the Buying dashboard's integrated shipping selector now presents Parcel2Go as the fixed integrated provider rather than asking the subscriber to choose among multiple direct providers.


## Initial offer workflow — 24 September 2026

For buying-dashboard work, treat the initial offer as a single manual offer stage containing two optional values: **Cash** and **Trade-in**. Do not restore the old separate `Create & publish offer` box or an initial offer-type selector. The subscriber sends the manual cash and/or trade-in values to the customer from this single stage.

Automatic catalogue pricing always takes precedence. If an automatic valuation is active, do not allow a manual initial valuation or initial offer to replace it. Automatic pricing creates the authoritative valuation and initial offer option(s), while previously published initial/revised offers are superseded.

Customer acceptance selects one initial option. The other published initial/revised option must be superseded. Acceptance moves the item into the shipping/receipt workflow. Do not create a final offer at this point. Only after the item is received and inspection is passed should the item move to `final_offer_required`, where the existing final-offer workflow creates and publishes the post-inspection offer.


## Initial offer workflow clarification — 24 September 2026

The customer must see the cash and trade-in choices together as one offer. Do not create two simultaneous published initial offer records for the two choices. Use the single offer record linked to the valuation; the customer acceptance choice is `cash` or `trade_in`, and the accepted amount is recorded on that offer.


## 24 September 2026 — Integrated Parcel2Go shipping implementation

The subscriber Buying dashboard now owns the Parcel2Go shipping handoff UI directly. The flow is: accepted initial offer → enter parcel dimensions → request Parcel2Go quotes → select a courier service → explicitly create the shipment → complete payment in Parcel2Go. The new parcel2go-subscriber-shipping Edge Function keeps provider credentials server-side, validates buying.manage permission, reads the subscriber's connected Parcel2Go connection, uses the customer's delivery address and subscriber collection address, and stores the resulting shipping order/payment/tracking/label references against buying_item_shipping. Manual shipping remains the fallback. Do not claim the integrated quote/order flow is browser-verified until it has been exercised with a real customer delivery address and Parcel2Go test/live account.


## 24 September 2026 — Customer delivery-address diagnostic fix

The live `public.customer_addresses.address_type` contract allows `primary`, `billing`, `shipping` and `other`; `delivery` is not a valid stored value. The customer-facing **Delivery address** label therefore maps internally to `address_type=shipping`.

For the Test Two issue, `customer-dashboard.js` was corrected so the Delivery option and Add delivery address action use `shipping`. The integrated Parcel2Go Edge Function had the opposite stale lookup and was corrected from `delivery` to `shipping`, then redeployed as version 3. No schema change was made. Final browser verification is to request a Parcel2Go quote and confirm the existing customer shipping address is accepted.


## 24 September 2026 — Test Two valuation display and shipping message clarification

When a customer has accepted a trade-in offer, the customer portal should display the accepted offer amount rather than presenting the underlying cash valuation as the single “Valuation” figure. Test Two has an approved manual trading value of cash £50 and trade-in £55, with the £55 trade-in offer accepted. The customer dashboard now resolves accepted offers by buying item and displays the accepted amount, while also showing the underlying cash/trade-in values. The Buying dashboard Parcel2Go text now describes the saved Delivery address as the source used by Parcel2Go instead of implying that the address is necessarily missing.
## 25 September 2026 — Mandatory regression gate after Test Two loading failure

The Test Two Buying dashboard remained on its static loading placeholders because buying-dashboard.js had a JavaScript parse error. The specific fault was an unescaped ASCII apostrophe inside a single-quoted JavaScript string in the Parcel2Go shipping handoff text (customer's). This prevented the entire controller from executing. The earlier asynchronous loading repair was therefore not the first failing boundary.

From this point forward, every material front-end repair must pass this gate before it is treated as implemented:
- inspect the current controller and all scripts loaded by the page;
- identify the first executable boundary before changing database state;
- run a JavaScript syntax check over every changed controller and directly loaded companion controller;
- verify the page script cache-buster matches the repaired controller; verify navigation links into the page use the current page cache key as well, not merely the controller's cache key;
- preserve Test One and existing Test Two restore checkpoints;
- never delete/reseed test data merely to work around an unproven browser failure;
- only then perform the one requested browser test.

The Buying dashboard now has an inline startup diagnostic and controller startup marker. If the controller fails to load in future, the page should identify a script-loading/runtime boundary instead of leaving the user with an unexplained loading screen.

The repaired files are syntax-verified. A subsequent audit found a second cache-version mismatch: the Business Dashboard Buying links still used `?v=58` while the Buying page controller had advanced to `v59`. Those navigation links have now been synchronized to `?v=59` in commit `6207f0ca4b028351ebee149598898a563ccf1f58`. This does not yet count as Browser Verified; the next test is the deployed GitHub Pages Buying dashboard after the latest cache-bust has published.


## 25 September 2026 — Buying dashboard rendering regression found after cache repair

When the latest Test Two browser screenshots were compared with the current source, two defects remained despite the earlier cache-version repair.

- The customer description parser converted literal \\n sequences to real newline characters and then used the wrong split expression, so the entire customer submission remained one line. This is corrected by splitting on actual newline characters after conversion.
- The controller already returned status-approved for submitted, but the Buying stylesheet did not define that class (nor the related review/offer/refused status classes). The status therefore remained visually neutral. Explicit status-pill state styling has been added.

Before changing code, the live Test Two record was checked: request BR-4C34C6F633, item BI-9D1C8F01FB, item status submitted, customer CUS-E82930637A58, and two media records. No test data was reset or modified.

The Buying page/controller cache keys are now v6/v60 and the three Business Dashboard Buying links are synchronized to v60. Browser verification remains the only outstanding verification state.


## 25 September 2026 — Buying customer-detail parser correction

A further browser screenshot showed that the earlier newline fix was not sufficient. The key/value regular expression still contained `\\s` rather than `\s`, so labels followed by colons were not separated into individual fields. This is now corrected. The Submitted review stage has also been changed from a green approval-style presentation to a greyed stage, with a neutral Submitted pill, matching the intended meaning of a customer submission awaiting review.

Latest cache keys: Buying CSS v7, Buying controller v61, Business Dashboard Buying navigation v61. Browser verification remains pending.


## Test Two — Current Shipping Workflow State (25 September 2026)

The buying shipping workflow no longer uses Parcel2Go API integration. TradeFlow's current model is subscriber-managed shipping: the subscriber selects supported shipping services in Shipping Settings, obtains the label/service directly from the provider, then uploads the label/QR code, carrier, service, tracking number and dispatch information to TradeFlow. The customer receives those shipping files and instructions through the Customer Portal. TradeFlow does not purchase shipping or collect the customer's shipping cost.

After the customer confirms dispatch, the subscriber Buying workflow is **Awaiting item**. The subscriber view retains the dispatch date, shipping service, carrier and tracking number. After **Confirm item received**, the buying item moves to **received** and the next required step is **Inspection**. The received state must be green and must not show the receive button again. The Inspection state must be green and provide the inspection controls.

Do not restore the retired Parcel2Go API flow or the old post-acceptance message claiming that the business will create the shipping label after acceptance. The Customer Portal's accepted-offer block is informational only; the live stage/status message determines what the customer needs to do next.


## 25 September 2026 — Test Two inspection workflow correction
The current unified buying workflow is: customer confirms dispatch → subscriber confirms item received → subscriber explicitly starts inspection → inspection is completed → accepted inspection proceeds to final offer → customer accepts final offer → payment → Inventory. The Start inspection control must call the `subscriber_start_buying_item_inspection` RPC and change `buying_items.purchase_stage` from `received` to `inspection`; the inspection completion control then calls `subscriber_complete_buying_item_inspection`. Do not treat the inspection form as available while the database stage remains `received`. Parcel2Go API shipping remains retired; shipping labels/services are subscriber-managed and paid directly to the selected carrier/service.


## 25 September 2026 — Post-inspection trade-in decision model
Do not use the old generic `final_offer_required` UI as an instruction to send a final offer automatically. After inspection, compare the accepted trade-in amount with the revised inspected value. If unchanged, add the accepted amount directly to the customer's trade-in credit account. If changed, send a revised final offer and wait for customer acceptance/refusal. If refused, close the trade-in. Use the dedicated subscriber RPCs for credit/refusal; do not recreate credit or acquisition records in browser JavaScript. Trade-in credit is not a bank transfer. The physical item becomes an Inventory asset when the credit is posted.


## 25 September 2026 — Customer credit account
Use `customer_credit_accounts` as the customer-facing stored balance for trade-in credit. The balance is updated server-side by `subscriber_credit_trade_in`; browser code must not alter balances directly. `customer_get_credit_account` exposes the authenticated customer's balance. Do not treat an unchanged accepted trade-in as a revised final offer; the customer journey moves from Inspection to Payment/credit processing.


### Post-inspection decision flow correction — 25 September 2026
Inspection is a decision point, not automatically a Final Offer stage. After an inspection, the subscriber must choose one of four paths: **pay the accepted cash offer to the customer's bank**, **credit the accepted trade-in value to the customer's Trade-in Credit Account**, **refuse/close the transaction**, or **send a revised final offer only when the value has changed**. The customer portal should remain on Payment for an unchanged accepted offer. It should move to Offer only when a revised final offer is actually published. Do not describe every post-inspection transaction as a final-offer step.


## Inventory catalogue architecture correction — 25 September 2026

The Inventory product-entry path has been corrected at the architecture level. Inventory is a physical-stock workspace and must not populate its Add Product controls from the buying-only tenant_buying_products path. The authoritative product source for direct Inventory creation is the tenant's selected master catalogue, exposed through get_inventory_product_catalogue(p_tenant_id). The operator flow is Manufacturer → Category → Product; the product determines the tenant category/branch mapping automatically.

The database now records inventory_assets.catalogue_product_id for directly catalogued stock. Manual Inventory creation uses metadata.source = manual_inventory. The existing acquisition boundary remains intact for purchased stock: acquisition-linked Inventory assets still require a completed acquisition, payment/trade-in completion and the existing workflow authority. The Inventory creation guard now supports the two explicit creation paths rather than rejecting every non-acquisition asset.

This resolves the previous architectural mistake where Inventory was made dependent on the Buying catalogue implementation and tenant buying categories. It is not a cache or browser patch.

Verification: live Supabase contains 261 active selected catalogue products for Camerashack across 3 manufacturers; the new Inventory catalogue RPC returns those 261 products for an authorised tenant user. A rollback-only authenticated INSERT test confirmed the new manual path is accepted when explicitly marked manual_inventory, while an unmarked direct INSERT remains blocked.


## CURRENT RETAIL CHECKOUT ARCHITECTURE — 26 September 2026

The retail purchase journey has been rebuilt to match the documented basket model:

**Shop → Product → Buy this item → Basket → Sign in if required → Proceed to payment → Retail Order → Stripe / Customer Credit → My Orders**

### Basket rules

The basket is a customer-side pre-order state.

- Adding a product to the basket does **not** create a retail order.
- Removing a product removes it from the basket.
- A retail order is created only when the customer proceeds to payment.
- Listing reservation therefore happens at payment initiation, not when the product is merely viewed or added to the basket.
- Unpaid/pre-payment orders remain outside My Orders.

### Authentication

The canonical customer session remains:

`tradeflow_customer_session`

No separate checkout session is used.

The retail basket is tenant-scoped and is stored only as pre-order browser state. Customer account data, addresses, credit and orders remain database-backed and authenticated.

### Payment

Internet payment uses the existing:

`create-stripe-checkout-session`

Edge Function and the existing Stripe webhook/payment-record chain.

Customer credit uses:

`customer_pay_retail_order_with_credit`

The customer credit account remains server-authoritative. The Test Two Camerashack customer has £55.00 GBP credit.

### Separation of workflows

Retail purchasing must remain separate from the customer selling/trade-in workflow.

Do not route a retail **Buy this item** action through the **My Sale** / valuation / offer / acquisition portal.

### Retired checkout code

The obsolete standalone checkout route and the later integrated purchase controller have been removed. Do not recreate them or reintroduce a second checkout session state without a deliberate architectural change and checkpoint.


## 26 September 2026 — Retail checkout lifecycle separation repair

The retail checkout audit identified three independent lifecycle faults in the rebuilt Basket path.

1. The Stripe checkout Edge Function was validating a newly-created `pending_payment` retail order through `customer_get_orders()`. That RPC intentionally returns only paid/fulfilled/completed purchase history, so a legitimate pending order could not be found by the Stripe session function. The Edge Function now validates the pending order through the dedicated authenticated `customer_get_retail_order_for_checkout(p_tenant_id,p_order_id)` RPC.
2. `customer_cancel_retail_order` cancelled the order but did not release the reserved `listings` row. It now releases listing reservations and any linked reserved inventory asset, and cancels active payment attempts. Customer credit is not touched.
3. `process_external_payment_event` marked a Stripe retail order paid but did not complete the corresponding listing/inventory lifecycle. Successful external payment now moves the linked listing and inventory asset to `sold`. Stripe `checkout.session.expired` is also treated as a cancellation for an unpaid retail order, releasing the reservation.

The current Basket controller persists the pending retail order ID in `tradeflow_customer_pending_retail_order`, validates that it belongs to the current Basket listing, supports cancelling/removing a pending purchase, and returns Stripe cancellation to the Basket rather than My Sale. The Basket controller cache key is now `customer-basket.js?v=2`.

The Customer Portal selling RPC was audited separately. The Nikon COOLPIX P1100 shown in My Sale is backed by the existing Test Two `buying_items`/selling workflow and is not the retail order created by the current retail test. The current retail pending order is a separate `retail_orders` record for the EOS R1 Body Only. Therefore the repair does not hide or rewrite selling records merely to make the screenshot appear correct. My Sale remains driven by `customer_get_selling_status`; My Orders remains driven by `customer_get_orders`, which only exposes paid/completed retail history.

The existing Stripe Edge Functions remain in use: `create-stripe-checkout-session` version 11 and `stripe-payment-webhook` version 5. No new payment provider or checkout architecture was introduced.

Verification state: live Supabase functions and database lifecycle changes verified; browser verification still required. Test One remains frozen.


### 26 September 2026 — Customer-credit checkout constraint repair
Browser Test Two exposed: `new row for relation "payment_records" violates check constraint "payment_records_payment_type_check"`. Live inspection showed the constraint permits `customer_payment`, `seller_payment`, `refund`, `payout`, `expense`, and `other`; it does not permit `customer_credit`. The `customer_pay_retail_order_with_credit()` RPC was therefore failing before payment completion because it inserted `payment_type='customer_credit'`. The minimal repair was to retain `payment_method='customer_credit'` while setting `payment_type='customer_payment'`. No constraint broadening was introduced. This keeps transaction type and payment method semantically separate and preserves the existing database contract.

The live function was replaced through migration `20260926160000_fix_retail_credit_payment_type`. A real credit payment was not executed during backend verification because that would spend the customer's live £55 credit; browser verification should now exercise the intended credit payment path once the user is ready to make the purchase.


### 26 September 2026 — Retail checkout must not reserve stock before payment
Browser Test Two exposed a deeper lifecycle issue: customer_create_retail_order() and customer_create_retail_order_from_basket() were changing a live listing from published to reserved when the customer merely proceeded to payment. This made an unpaid/abandoned checkout capable of taking a product off the public shop.

The live functions were corrected in migration 20260926170000_retail_checkout_no_reservation_before_payment. They still validate that the listing is currently published when the checkout order is created, but they no longer modify listing status. The pending retail order therefore does not block other customers from seeing or buying the item.

customer_pay_retail_order_with_credit() now locks the linked listing at the point of actual customer-credit payment and requires it still to be published before deducting credit and creating the paid payment record. It then changes the listing to sold and the linked inventory asset to sold.

External payment processing was also hardened in migration 20260926173000_retail_payment_claim_after_payment. A successful external payment is accepted only if the linked listing is still published. If another customer has already bought it, the database leaves the payment/order unpaid and the Stripe webhook refunds the conflicting payment and cancels that retail order. This preserves live-shop availability while preventing double sale.

The Test Two EOS R1 pending order was cancelled and the listing verified as published with no reservation. Customer credit remains £55. No payment was made during this reset.
### 26 September 2026 — Retail order detail and fulfilment lifecycle

The retail checkout lifecycle now separates payment completion from dispatch. Successful payment marks every `retail_order_item` listing and linked inventory asset sold and creates one `fulfilments` record in `awaiting` status. The subscriber may record the label and transition `awaiting → label`, then transition `label → dispatched`. The customer portal reads fulfilment status/tracking through `customer_get_order_details()` and displays `Shipped` when fulfilment status is `dispatched`.

The customer My Orders UI no longer presents only an order reference and total. It groups order items under each paid order and shows fulfilment/tracking details. The subscriber Selling UI now keeps paid listings in a separate Sold section rather than mixing them with available listings.

Multi-item payment was hardened in migration `20260926200000_retail_order_fulfilment_and_multi_item_payment`: customer-credit payment and external payment processing validate and claim every item in the retail order before completing payment. The same migration adds `customer_get_order_details()` and creates the fulfilment record at payment time. Existing paid Test Two order `ORD-20260926-71DCBDEC` was backfilled with fulfilment `FUL-17C5EB082D09` in `awaiting` state.


### 26 September 2026 — Retail fulfilment shipping handoff rule

When repairing or extending retail dispatch, use the established Buying shipping handoff as the reference implementation. Do not create a separate shipping settings model for Sales.

The Fulfilment UI must provide:
- saved Shipping Settings services and provider links;
- the paid order and exact item(s) being shipped;
- recipient name/email and delivery address;
- packed parcel weight and length/width/height;
- carrier, service, tracking number and tracking URL;
- printable shipping label upload/view/print;
- printable QR code upload/view/print;
- shipping instructions;
- a single completion action that persists the handoff, moves awaiting to label, and queues the customer notification.

Customer notification must include the order reference, item(s), shipping service/carrier, tracking information, parcel measurements, instructions and Customer Portal link. Do not claim email delivery has occurred merely because the queue row was created; the notification processor must still deliver it.

Security boundary:
- subscriber writes use subscriber_save_retail_fulfilment_shipping() and subscriber_transition_retail_fulfilment();
- subscriber reads use subscriber_get_retail_fulfilment_shipping();
- customer reads use customer_get_retail_fulfilment_shipping();
- customer access to uploaded fulfilment files is limited by storage policy to the customer's own paid order.

Shipping research rule: parcel weight/dimensions must represent the packed shipment, including packaging. Use measured values where possible rather than guessing from product specifications.



### 26 September 2026 — Retail fulfilment handoff reliability and UI boundary

Current implementation rule: keep the retail Fulfilment UI as a **shipping handoff recorder**, not a second courier-booking form. The subscriber selects a service from Shipping Settings, opens the provider, books/pays there, then returns to TradeFlow with the provider-issued label/QR, carrier, service and tracking.

Do not re-add mandatory weight/length/width/height fields to the current handoff screen unless the architecture deliberately moves parcel booking into TradeFlow. Those measurements remain important at provider-booking time and can remain persisted in fulfilment_parcels, but the simplified handoff RPC preserves existing values when the UI sends nulls.

The save boundary is subscriber_save_retail_fulfilment_shipping(). The latest reliability migration performs awaiting → label directly after authorisation and records the workflow transition, rather than delegating the status change to the generic workflow function. Frontend save errors must remain visible in the handoff panel; do not silently swallow upload or RPC failures.

For Selling startup issues, use cache-busted script references and a single guarded boot path before investigating database reads. A page stuck on Loading after navigation but working after refresh is first treated as a deployment/cache/startup problem, not as evidence that the sold-items RPC is empty.



### 26 September 2026 — Retail customer shipping visibility and returns

Do not expose retail outbound shipping labels or QR codes in the customer My Orders UI. The subscriber is the sender and needs those files; the customer is the recipient and needs shipment status, carrier/service, tracking and dispatch notification.

Use the existing subscriber_transition_retail_fulfilment() path for Mark as sent. Its dispatched branch records the dispatch timestamp and queues order_dispatched with item, carrier/service, tracking and portal details.

Retail returns are customer-initiated only after fulfilment is delivered. The UI calls customer_request_return() per delivered order item. The live RPC now writes return_type='customer_retail', checks the authenticated customer's ownership, requires delivered fulfilment and blocks duplicate active return requests.

Customer Portal startup must wait for customer-auth.js session restoration before calling customer_get_profile or other authenticated customer RPCs. A transient “login is not registered” message on first navigation indicates an auth/profile startup race, not a missing customer record, when a refresh immediately resolves it.


## 2026-09-26 — Retail Mark as Sent / customer dispatch handoff repair

- Selling → Sold → **MARK AS SENT** is now one atomic server-side action.
- The action advances the paid retail order from `paid` to `fulfilment` and the fulfilment from `label` to `dispatched` in the same transaction. The browser no longer performs a second retail-order transition after the fulfilment RPC, preventing the previous post-success failure that could leave the button apparently non-responsive.
- On dispatch, TradeFlow retains the carrier/service and tracking number, derives an official carrier tracking-page URL when none was supplied for supported carriers, and queues the `order_dispatched` customer notification with the tracking information.
- Customer My Orders remains recipient-focused: no outbound label/QR controls. Once dispatched it shows the shipping service/carrier, tracking number, and an explicit **Track item →** link when a tracking URL is available.
- After **MARK AS SENT**, Selling → Sold should show the shipment as **Shipped** with no further outbound action. Return handling remains a separate customer-return workflow and should only become actionable when a return has actually been requested.
- Production migration: `20260926225000_retail_fulfilment_mark_sent_atomic`.


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



## 2026-09-26 — Stripe payment-method configuration boundary
- Subscriber payment-method controls live in `public.tenant_payment_methods` and the subscriber Settings UI.
- For retail Stripe Checkout, the Edge Function must read the tenant's enabled `card`, `link`, `klarna`, and `amazon_pay` rows and construct the `allowed_payment_method_types[]` filter. Never trust a browser-supplied payment-method list.
- Card is mandatory for this retail checkout implementation. Do not permit a subscriber toggle to remove the base card method.
- Apple Pay must not be added as `payment_method_types[]` or `allowed_payment_method_types[]`: Stripe documents it as a wallet without an API enum. Treat Apple Pay availability as Stripe-managed wallet/card eligibility.
- Stripe eligibility remains authoritative even when a tenant method is enabled.
- When diagnosing a checkout screenshot, distinguish **TradeFlow tenant configuration** from **Stripe account-level eligibility** and from **customer/device eligibility**.
- Production migration: `20260926233000_subscriber_stripe_payment_method_controls`; Edge Function `create-stripe-checkout-session` deployed as version 12.


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


## 26 September 2026 — Multi-session concurrency diagnostic checkpoint

A live Test Two concurrency test is now exercising four independent browser sessions: Platform Owner, Camerashack subscriber, and two Camerashack customers.

### Required diagnostic order
When concurrent-session behaviour is reported:
1. Identify the browser/session identity.
2. Identify the authenticated Auth user.
3. Identify the tenant ID.
4. Identify the customer ID where the session is customer-facing.
5. Identify the request/order/fulfilment/payment record involved.
6. Check the live RPC and RLS/security boundary before changing code.
7. Compare against the last known-good checkpoint before making a repair.

Do not treat separate Auth sessions as a conflict merely because they belong to the same subscriber tenant. Two customers can legitimately have separate customer sessions and separate buying requests in one tenant.

### 26 September live audit
- Platform Owner membership for leannelaurenlowe@hotmail.com is active.
- Camerashack has one active subscriber owner membership.
- Two separate Camerashack customer records are active.
- Two separate submitted buying requests are present: one for Test Three and one for Leanne Lowe.
- Retail state is consistent with the current test history: one paid £75 order awaiting fulfilment and one paid £49.91 order already dispatched.
- No active customer-credit holds or processing/initiated payment attempts remain.
- A historical pending Stripe payment record remains against the already-paid £49.91 test order; the external-payment conflict/refund guard must remain intact.

### Owner Dashboard repair
The concurrent browser screenshot exposed escapeAttr is not defined in platform-owner-dashboard.js. The minimal repair was to define escapeAttr() as a wrapper around the existing escapeHtml() function. No database migration was required and no subscriber/customer code was changed.

GitHub commit: c9bceb23e97d2d2f879a29d77f8c0e68c1fd9447.

Never overwrite a working previous-step repair while diagnosing concurrency. Make the smallest isolated change, verify it, then update this checkpoint and the manuals.


## 26 September 2026 — Platform Owner email setting repair

The Platform Owner sending-email save path must remain platform-owner-only. A valid address such as info@scenesource.co.uk must pass validation. The live repair corrected an over-escaped domain-dot regex in platform_owner_save_email(). Do not weaken private.is_platform_owner(auth.uid()) or bypass the RPC with direct client writes.

Production migration: 20260926212000_fix_platform_owner_email_validation.


## 26 September 2026 — Commercial plan control boundary

When changing commercial plans, preserve the distinction between operational availability and public sales visibility:
- `plans.active` controls whether the plan remains an operational plan;
- `plans.website_visible` controls whether it appears on the public website/new signup.

Use the platform-owner RPCs for mutations. Never expose Stripe secret credentials to browser code or store them in public plan records. Public plan reads must use `public_get_available_plans()`, which intentionally excludes Stripe identifiers.

Current live migration: `20260926220000_platform_commercial_plan_controls`.


## 26 September 2026 — Commercial plan consolidation

Treat enhanced as the canonical internal plan code and TradeFlow as its public commercial name. Do not recreate or migrate the active Camerashack subscription merely to rename the plan.

Only the canonical TradeFlow plan should be active/website-visible for new subscriptions. Legacy plan rows may remain inactive for historical subscriptions and test records.

Owner Dashboard plan controls are platform-owner-only and must remain behind the existing platform-owner RPC boundary. The owner may change display name, description, website visibility, prices, currency and Stripe Product/Price IDs.

Do not reintroduce Basic/Enhanced/Catalogue upgrade logic unless the commercial model is deliberately changed again.

## Platform email verification rule

Saving the Platform Owner sender address only records the sender and sets its verification state to pending. It does not create a confirmation email. The notification processor requires a verified sender/domain before sending. Never mark the sender verified from browser code or bypass the provider verification boundary.


## 2026-09-28 — End-to-end customer-to-sales audit finding
Follow current code and live Supabase rather than historical documentation when tracing the customer selling workflow. A fresh submission `BR-9FBCBE5008` / `BI-63F5AAA6AB` proves the customer submission boundary is functioning.

First substantive valuation boundary: `buying_items.buying_product_id` is null because `customer-selling-submit` sends category/title/description/condition but does not bind the selected catalogue product. `calculate_buying_item_valuation` therefore returns manual/product_not_selected. Do not infer an automatic valuation from the customer's typed model text alone.

Second boundary: reconcile the public selling condition values with the valuation engine's condition vocabulary before claiming automatic valuation works for all conditions.

Subscriber session storage still has legacy localStorage fallbacks; multi-account/tab testing should treat this as a session-isolation risk. Notification queue delivery also remains unresolved and must be reported separately from portal/database workflow success.

Verification language remains mandatory: Implemented in GitHub, Live DB verified, Browser verified. Do not promote the fresh end-to-end path to Browser verified until it has actually been exercised stage by stage.


## 2026-09-28 — Fresh test UI repairs
For the fresh Nikon Nikkormat EL Standard test, do not change server-side purchase-stage logic to solve the current presentation issues. The repairs are confined to the Buying/customer UI: manual valuation CTA cleanup, clearer awaiting-item wording, 4×6 portrait/A4 print rendering, and direct revised-final-offer button handling with visible errors. Verify each in the browser before making any further backend change.


## 2026-09-28 — Customer valuation condition vocabulary repair
The customer selling form uses customer-facing condition values such as `factory-sealed`, `opened-unused`, `fair`, `damaged`, and `not-working`. The authoritative `buying_items.item_condition` constraint accepts `sealed`, `opened_never_used`, `excellent`, `good`, and `poor`. The `customer-selling-submit` Edge Function now normalises the customer-facing values at the submission boundary before calling `customer_submit_buying_request`: factory-sealed→sealed, opened-unused→opened_never_used, excellent→excellent, good→good, fair/damaged/not-working→poor. No customer-facing wording was removed.


## 2026-09-28 — Inspection decision and testing/repair continuation
At the inspection stage, the subscriber can now choose: Accept original offer, Make a counter offer, Send for testing, Send for repair, or Refuse purchase. A counter offer requires a different value from the accepted offer and is sent as the revised final offer after the inspection is recorded. Testing and repair stages now provide a completion action that returns the item to inspection/offer decision, plus a refusal action. The customer shipping label remains a stored handoff asset; if its storage path/URL is absent, the label was not stored for that item and must not be reconstructed or treated as available.


## 2026-09-28 — Revised final offer currency-source repair

A fresh browser test exposed column "currency" does not exist in subscriber_publish_final_offer. Root cause was confirmed against the live schema: buying_items has no currency column. The function previously attempted to select purchase_stage,currency from buying_items.

Repair migration 20260928161000_fix_final_offer_currency_source changes only the currency source: purchase stage is read from buying_items; currency is taken from the latest accepted offer and falls back to GBP. Do not add a currency column to buying_items to solve this incident.

Current test state remains BI-29E78F3A13, final_offer_required, accepted initial offer £99. Browser verification must confirm that a different revised amount creates a published final offer and moves the item to final_offer_sent. Do not manually advance the item or create a final offer in SQL if the browser test fails.


## 2026-09-28 — Revised offer approved-valuation uniqueness repair

The revised-offer workflow reached the database after the currency repair but failed because `trading_values_one_approved_per_item_idx` permits only one approved trading value per buying item. The existing £99 initial valuation was still approved.

Do not drop or weaken the unique index. `subscriber_publish_final_offer` now supersedes the existing approved trading value through `transition_workflow_entity` before approving the new post-inspection valuation. The transaction remains atomic and no test record should be manually advanced.


## 2026-09-28 — Revised offer current-state rendering

The revised final-offer backend is now live and produces a published final offer. A UI data-selection defect was found in the customer portal: descending offers were converted to an object by buying item, allowing an older offer to overwrite the newest offer. The customer dashboard now retains the first/newest offer for each item.

For `final_offer_sent`, when the newest offer is a published final offer, customer-facing wording is **Revised offer sent** / **Revised offer received**, with Accept and Refuse actions. The subscriber Buying workspace displays the revised amount and waits for customer response; it must not keep an editable sent-offer control active.

Do not create or copy media records to make a test photo appear. Verify `buying_item_media` and `media_assets` for the exact buying item before diagnosing photo display.


## 2026-09-28 — Final payment button binding repair

The final-offer acceptance path exposed an inert **Confirm payment sent** button. Root cause: the `final_offer_accepted` renderer (`loadPayment`) created a `data-act="pay"` button without binding it, while the global click listener intentionally does not redispatch these actions. The button is now directly bound to the existing payment action; cache is v60. No database records were manually advanced.

The Canon EOS R8 test is currently `final_offer_accepted` at £79 and requires browser verification of payment. The exact item has zero `buying_item_media` links; do not invent media. The customer portal already implements **Revised offer received** plus accept/refuse controls for `final_offer_sent`; the current Canon test has already moved beyond that state after acceptance.


## Automatic Buying Valuation Basis — 30 September 2026
Automatic buying valuation percentages are always applied to the latest subscriber-scoped **UK New** research price. All five condition percentages (sealed, opened/never used, excellent, good and poor) use UK New as their automatic basis.

UK Used research is evidence for viewing/comparison only. It must never be selected or substituted as the automatic calculation basis. If UK New research is absent, the automatic valuation path must return the manual-valuation fallback. Do not substitute UK Used research merely because it exists.

When an automatic pricing rule is saved, all condition reference fields must be stored as `uk_new`, regardless of legacy or client-supplied reference values. Existing legacy condition reference fields are normalised to `uk_new` by the migration that introduced this rule.


## 2026-09-30 — TEST migration-history clean-baseline repair

The TradeFlow TEST Supabase project `nnsshnfkjcflucjrftzi` remains the authoritative TEST database. The remote migration-history records `20260930181936` and `20260930182507` were removed from `supabase_migrations.schema_migrations` as a history repair only; no business-table data was changed and no schema rollback was performed. The corresponding current function definitions remain present in TEST and match the replacement version-controlled migrations `20260930200000_exclude_completed_return_from_workflow_list` and `20260930201500_customer_initial_offer_refusal_closes_buying_item`.

This repair is part of the clean-baseline workstream. The next local step is to verify the dedicated `TradeFlow-Clean-Baseline-20260930` workspace has an empty `supabase/migrations` directory, then run `supabase db pull` against TEST and inspect the generated baseline before committing or replacing any migration history. Do not alter LIVE, the `production` branch, Test One, or the existing version-controlled migration set until that baseline has been verified.


## 2026-09-30 — TEST migration-history reset completed for clean baseline

The TEST Supabase migration-history table was reset to zero rows. This changed only `supabase_migrations.schema_migrations`; it did not reset, drop, or alter application schema or business data. Immediate verification after the reset reports 0 migration-history rows, 93 public tables and 178 public functions. The purpose is to allow the empty local `supabase/migrations` workspace to perform the documented initial `db pull` against the actual TEST schema and generate one authoritative baseline migration. Do not run `db push`, `db reset --linked`, or any further migration-repair commands until that generated baseline has been inspected.


## 2026-09-30 — TEST clean baseline pull completed
The TEST Supabase migration-history reset was followed by a successful clean `supabase db pull --linked` using pg-delta. The generated local baseline is `supabase/migrations/20260930215656_remote_schema.sql`, and TEST migration history now contains exactly that one applied baseline entry. The TEST schema was verified to remain intact (93 public tables, 178 public functions). Do not run `db push`, `db reset --linked`, or further migration repair while the baseline is being reconciled with GitHub.


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


## 2026-10-01 — ResellerClub registrar integration checkpoint

The registrar decision is now **ResellerClub**. Previous GoDaddy investigation is abandoned and must not be resumed. The existing TradeFlow domain foundation is provider-neutral and remains authoritative: `domain_tld_catalog`, `tenant_domain_orders`, `tenant_domains`, `published_site_index` and `tenant_site_state` are not to be deleted or rebuilt.

ResellerClub's current REST Sandbox has been independently verified before TradeFlow integration. Sandbox Web Pro ID / X-User-Id `1347028` and the Sandbox API key were accepted. Country API returned 200, Domains/TLD Catalog returned 200, the documented `mybrand-test-12345.com` availability request returned 200/available, and a `.co.uk` availability request returned 200/unknown. `unknown` must remain distinct from `available`; it means the registry did not return a definitive availability result and should be retried later.

The first TradeFlow integration is availability-only. A TEST Edge Function `resellerclub-domain-availability` has been deployed with JWT verification enabled. It accepts a tenant-scoped subscriber request, verifies active `tenant_memberships`, calls ResellerClub server-side, and returns `available`, `unavailable`, or `unknown`. ResellerClub credentials must never be placed in browser code.

The working source branch is `resellerclub-domain-availability-20261001`. It contains the Edge Function source plus the initial subscriber domain-search page. The branch is not yet a production release. The normal purchase flow, customer pricing, Stripe payment, customer/contact creation, registration, DNS/hosting connection, renewal and failure/refund handling remain disabled until each stage is separately verified.

TEST Edge Function secrets required: `RESELLERCLUB_API_KEY`, `RESELLERCLUB_X_USER_ID` (Sandbox value `1347028`) and `RESELLERCLUB_API_BASE_URL` (Sandbox `https://api.sandbox.resellerclub.com/v2`). The API key must be entered directly into Supabase Edge Function Secrets and must never be pasted into chat, GitHub or frontend code. Supabase documents project secrets as the correct place for Edge Function credentials.

No LIVE Supabase project, `production` branch, Stripe production flow or real domain registration has been changed by this registrar work.


## Domain registration workflow — 2026-10-02 TEST
The domain purchase path is now split into controlled stages. Stripe payment completion moves `tenant_domain_orders` to `payment_confirmed`. The next stage captures legal registrant data in `tenant_domain_registrants` through the JWT-protected `save-domain-registrant` Edge Function and then moves the order to `registrant_details_saved`. Do not bypass this stage or call Porkbun registration directly from the browser. The next implementation stage is a server-side Porkbun sandbox dry run/registration using the stored registrant data, with idempotency and reconciliation into `tenant_domains`. LIVE is not to be modified until the complete TEST lifecycle is verified.


## Domain registration integration — current TEST state (2026-10-02)
- TEST provider: Porkbun sandbox API.
- Stripe domain payment is proven through `create-domain-checkout-session` -> Stripe Checkout -> `stripe-payment-webhook` -> `payment_confirmed`.
- Registrant data is stored in `tenant_domain_registrants` and protected by tenant membership/website permissions.
- `save-domain-registrant` is JWT protected and advances the order to `registrant_details_saved`; update errors must be surfaced rather than ignored.
- `porkbun-domain-registration-dry-run` is JWT protected. It checks TLD registration requirements and calls Porkbun `/domain/create/{domain}` with `dryRun:true` and a zero/current quoted cost. No registration or charge occurs during this step.
- Provider-specific finding: the current Porkbun create request schema does not carry arbitrary per-order registrant contacts. Porkbun exposes `/domain/updateContacts/{domain}` separately, and .uk/.co.uk contact changes may invoke address validation. Do not assume the saved TradeFlow registrant can be supplied directly to the create call. The sandbox must prove the safe sequence before LIVE registration is enabled.
- LIVE is untouched.


---

# DOMAIN REGISTRATION HANDOVER — 2026-10-02

## Verified current TEST state

TradeFlow's domain-purchase flow has now reached the end of the payment and registrant-information stages in TEST/STAGING.

Environment:
- GitHub TEST/STAGING branch: `main`
- TEST Supabase project: `nnsshnfkjcflucjrftzi`
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
- TEST Supabase: `nnsshnfkjcflucjrftzi`
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



## 2026-10-02 Porkbun TEST registration checkpoint

Do not touch LIVE. TEST order camerashack.co.uk is still registrant_details_saved; the saved registrant exists; no tenant_domains row exists yet; and the order metadata records porkbun_dry_run_would_succeed=true. The next action is the TEST UI button Register in TEST sandbox. The registration function is server-side and uses the saved registrant record, Porkbun sandbox credentials, idempotency, provider verification, and reconciliation before setting the order to registered.


## 2026-10-02 Porkbun TEST repair

Observed first sandbox attempt: registration succeeded, contact reconciliation failed with INVALID_INPUT because no existing admin contact was available to carry over. Do not re-register the domain. The provider order is already recorded as 9913828. Version 2 of the registration function reuses that sandbox registration and applies the TradeFlow registrant as the single Porkbun contact payload. The next test is to press Register in TEST sandbox again.


## 2026-10-02 Porkbun TEST sandbox registration — operating checkpoint

Registration is now a verified TEST stage: provider order 9913828 is reused, the order is registered, and an active tenant_domains row exists with acquisition source purchased and registrar provider porkbun. porkbun-domain-registration is TEST version 6.

Do not treat contact synchronization as complete. The .co.uk sandbox path deliberately records contact_sync_deferred=true because immediate contact updates produced V096 and repeated registrant notifications. Also do not treat expiry capture as complete: database expires_at and porkbun_expire_date are currently null.

Next work: resolve expiry capture/verification, then test the existing published_site_index hostname routing and provider-neutral website connection architecture. Do not rebuild it and do not touch LIVE.



## 2026-10-02 — Current Porkbun TEST expiry-reconciliation rule

When continuing the Porkbun domain-registration workflow, treat the existing sandbox registration as authoritative: provider order 9913828 is already registered for the TEST order. Never re-register it merely to recover missing expiry data.

The current Edge Function is version 7. For an already-registered sandbox order it performs reconciliation only. It reads the Porkbun domain record and falls back to `/domain/listAll` when the direct lookup lacks `expireDate` or `createDate`. Persist only provider-returned expiry data; do not calculate or invent a date.

Immediate verification target is the TEST order's two `expires_at` fields plus the Porkbun expiry metadata. After expiry is verified, continue with the existing provider-neutral domain connection and `published_site_index` routing. Do not rebuild the domain foundation and do not touch LIVE.


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


## 2026-10-23 — Mobile phone catalogue batch 01 (Samsung Galaxy A37/A57)

A controlled mobile-phone catalogue batch was added to TEST and then promoted to LIVE after checking the official Samsung UK product pages.

### Database result

- TEST category: `Mobile Phones`, category ID `f10be666-dd02-43f6-ba38-fac09b4008f2`; branch ID `a622bd9f-da55-437a-b4c0-a4dbd448a7d6`.
- TEST now has 100 mobile-phone product variants and 21 linked evidence rows (baseline before this batch: 95 products / 16 evidence rows).
- LIVE did not previously have a `mobile-phones` category, branch, or exact-name phone manufacturers. LIVE now has category ID `90fda02e-ec5e-4e2c-bc30-11dab560781d`, branch ID `0369d691-4950-4dfc-9f8e-9d8cd5f80ab0`, and the 11 phone manufacturer records required by the current TEST phone catalogue.
- LIVE now has 5 mobile-phone product variants and 5 linked evidence rows for this batch. No other TEST products were copied to LIVE as part of this batch.

### Variants and UK new-price evidence

| Product variant | Official Samsung UK list price | Evidence availability |
|---|---:|---|
| Galaxy A37 5G 128 GB | £419 | Listed; stock not explicitly confirmed |
| Galaxy A37 5G 256 GB | £519 | In stock |
| Galaxy A57 5G 128 GB | £479 | Listed; stock not explicitly confirmed |
| Galaxy A57 5G 256 GB | £549 | In stock |
| Galaxy A57 5G 512 GB | £769 | Listed; stock not explicitly confirmed |

Sources: [Samsung UK Galaxy A37 5G buy page](https://www.samsung.com/uk/smartphones/galaxy-a/galaxy-a37-5g/buy/) and [Samsung UK Galaxy A57 5G product page](https://www.samsung.com/uk/smartphones/galaxy-a/galaxy-a57-5g-awesome-gray-256gb-sm-a576bzadeub/buy/). Prices recorded are the page's list prices, not code-based promotional prices. Availability is recorded conservatively where the page did not explicitly confirm stock.

### Validation and next action

- TEST and LIVE were queried independently after insertion.
- All five LIVE evidence rows link to the intended product variants, use GBP, have positive prices, non-empty official UK source URLs, unique source keys, and active status.
- This batch contains new-price evidence only; no used-market evidence or valuation recommendation was inferred from it.
- Continue in substantial but controlled batches: add/verify variants and UK used/new evidence in TEST, then promote each checked batch to LIVE without waiting for the whole mobile catalogue. Do not promote unevidenced catalogue seeds as if their prices were verified.
- Do not replace or deactivate existing phone records as part of this work. Preserve discontinued models for used-device valuation and distinguish historical launch prices from current new prices.


## 2026-10-23 — Mobile phone catalogue batch 02 (Galaxy S26 FE and Z foldables)

A second official-price batch was added to TEST and promoted to LIVE after variant-level source checks.

### Products and evidence

| Product variant | UK new list price | Availability recorded |
|---|---:|---|
| Galaxy S26 FE 128 GB | £699 | In stock |
| Galaxy S26 FE 256 GB | £799 | In stock |
| Galaxy S26 FE 512 GB | £949 | Listed; stock not explicitly confirmed |
| Galaxy Z Fold8 256 GB | £1,699 | In stock |
| Galaxy Z Fold8 512 GB | £1,869 | Listed; stock not explicitly confirmed |
| Galaxy Z Fold8 1 TB | £2,209 | Listed; stock not explicitly confirmed |
| Galaxy Z Flip8 256 GB | £1,149 | Listed; stock not explicitly confirmed |

Sources: [Samsung UK Galaxy S26 family buy page](https://www.samsung.com/uk/smartphones/galaxy-s26/buy/), [Samsung UK Galaxy Z Fold8 buy page](https://www.samsung.com/uk/smartphones/galaxy-z-fold8/buy/), and [Samsung Business UK Galaxy Z Flip8 buy page](https://www.samsung.com/uk/business/smartphones/galaxy-z/galaxy-z-flip8-mint-256gb-sm-f776blggeub/buy/). Prices are the displayed variant prices; separately advertised cashback or checkout promotions are not mixed into the recorded list prices.

### Verification

- TEST now contains 106 mobile-phone variants and 28 linked evidence rows.
- LIVE now contains 12 mobile-phone variants and 12 linked evidence rows, including both completed batches.
- LIVE evidence integrity check: zero missing URLs, source keys, product links, non-positive prices, or non-GBP values.
- Batch 02 includes seven new-price evidence rows. It does not include used-market evidence and must not be treated as a complete valuation dataset.
- Continue validating in TEST and promoting verified batches promptly to LIVE. Do not bulk-promote unevidenced legacy seed rows.


## 2026-10-23 — Mobile phone catalogue batch 03 (iPhone 18 Pro storage variants)

Apple UK pricing evidence was added for the full 256GB, 512GB, 1TB and 2TB storage tiers of both iPhone 18 Pro and iPhone 18 Pro Max.

| Model | 256 GB | 512 GB | 1 TB | 2 TB |
|---|---:|---:|---:|---:|
| iPhone 18 Pro | £1,199 | £1,399 | £1,799 | £2,399 |
| iPhone 18 Pro Max | £1,299 | £1,499 | £1,899 | £2,499 |

Sources: [Apple UK Business iPhone 18 Pro purchase page](https://www.apple.com/uk-business/shop/buy-iphone/iphone-18-pro) and [Apple UK iPhone 18 Pro Max purchase page](https://www.apple.com/uk-edu/shop/buy-iphone/iphone-18-pro/6.9-inch-display-512gb-silver). These are page-listed storage prices, excluding trade-in and financing. The Apple pages can show colour-specific price differences, so the evidence notes retain that caveat.

### Verification
- TEST now has 110 Mobile Phones product variants and 36 linked evidence records.
- LIVE now has 20 Mobile Phones product variants and 20 linked evidence records, including the three completed batches.
- LIVE integrity check: 0 missing source URLs, 0 missing source keys, 0 non-positive prices, 0 non-GBP values and 0 inactive evidence rows.
- The four new storage variants were added to TEST; all eight Pro/Pro Max storage variants and their eight new-price evidence rows are now present in LIVE.
- No used-market evidence was added in this batch. Continue separate used-market research and keep price types distinct.


## 2026-10-23 — Mobile phone catalogue batch 04 (iPhone 17e and Pixel 10a)

Added and promoted three evidence-backed phone variants in a controlled TEST → LIVE batch:

| Product variant | Current UK new price observed | Source / caveat |
|---|---:|---|
| Apple iPhone 17e 256 GB | £699 | Apple UK purchase page; current price, not the March 2026 launch price |
| Apple iPhone 17e 512 GB | £899 | Apple UK purchase page; current price, not the March 2026 launch price |
| Google Pixel 10a 128 GB | £599 | Google Store UK “From £599”; page confirms 128 GB is an available storage option |

Sources: [Apple UK iPhone 17e purchase page](https://www.apple.com/uk/shop/buy-iphone/iphone-17e/6.1-inch-display-256gb-black), [Apple iPhone 17e launch announcement](https://www.apple.com/uk/newsroom/2026/03/apple-introduces-iphone-17e/), and [Google Store UK Pixel 10a](https://store.google.com/gb/product/pixel_10a?hl=en-GB). Google advertised a Pixel Buds 2a bundle ending 3 November; the bundle was not deducted from the handset price.

### Verification
- TEST now contains 116 Mobile Phones product variants and 44 linked evidence rows.
- LIVE now contains 27 Mobile Phones product variants and 28 linked evidence rows.
- The three batch-04 evidence rows are active, GBP-denominated, positive-priced, URL-backed and linked to the intended exact model/storage variants.
- LIVE-wide integrity check returned zero missing URLs, missing source keys, non-positive prices, non-GBP values, inactive evidence rows or broken product links.
- Pixel 10a 256 GB is present in TEST as a catalogue variant but was deliberately not promoted and has no price evidence yet: the official Google Store page confirmed that storage option but did not expose a variant-specific price in the page content retrieved. Verify the exact price before promoting it.
- No used-market evidence was added. Continue separately with completed/sold UK used evidence; new prices are not valuation recommendations.


## 2026-10-23 — Mobile phone catalogue batch 05 (iPhone 17 and Pixel 10a 256 GB)

Added and promoted three evidence-backed variants:

| Product variant | UK new price observed | Source |
|---|---:|---|
| Apple iPhone 17 256 GB | £899 | [Apple UK purchase page](https://www.apple.com/uk/shop/buy-iphone/iphone-17/6.3-inch-display-256gb-white) |
| Apple iPhone 17 512 GB | £1,099 | [Apple UK purchase page](https://www.apple.com/uk/shop/buy-iphone/iphone-17/6.3-inch-display-256gb-white) |
| Google Pixel 10a 256 GB | £599 | [Argos product page](https://www.argos.co.uk/product/7939318) |

Prices observed 23 Oct 2026. Apple lists both iPhone 17 storage tiers across multiple colours. Argos identifies the Pixel 10a 256 GB variant and displays £599; stock/delivery needs a postcode check, so evidence is marked listed rather than confirmed in stock.

### Evidence-quality correction
A pre-existing TEST evidence row for iPhone 17 256 GB pointed to a generic giffgaff catalogue error URL and did not substantiate its £959 price. That row has been marked inactive and retained for audit history. It was replaced by product-specific Apple UK evidence at £899. Do not use the retired row for pricing or valuation.

### Verification
- TEST: 116 Mobile Phones product variants; 47 total evidence rows, of which 46 are active (one retired bad-source row retained for audit).
- LIVE: 30 Mobile Phones product variants and 31 active evidence rows.
- LIVE-wide integrity check: zero missing URLs, missing source keys, non-positive prices, non-GBP values, inactive evidence rows or broken product links.
- No used-market evidence added in this batch. New prices are not valuation recommendations.


## 2026-10-23 — Mobile phone catalogue batch 06 (Google Pixel 11 family base variants)

Added and promoted base-storage variants with current UK new-price evidence:

| Product variant | UK new price / RRP | Evidence source |
|---|---:|---|
| Google Pixel 11 256 GB | £879 | [Google Store UK](https://store.google.com/gb/product/pixel_11?hl=en-GB) |
| Google Pixel 11 Pro 256 GB | £1,079 | [Google Store UK](https://store.google.com/gb/product/pixel_11_pro?hl=en-GB) |
| Google Pixel 11 Pro XL 256 GB | £1,279 | [TechInOut UK price comparison](https://techinout.com/pixel-11-uk-price-comparison/) — secondary RRP source, article updated 14 Oct 2026 |
| Google Pixel 11 Pro Fold 256 GB | £1,799 | [Google Store UK](https://store.google.com/gb/product/pixel_11_pro_fold?hl=en-GB) |

### Evidence-quality correction
A TEST Pixel 11 128 GB seed was invalid: Google Store UK confirms the Pixel 11 starts at 256 GB. Its active giffgaff evidence also pointed to a generic catalogue error URL. The 128 GB product was marked inactive and hidden from customers, and the bad evidence row was marked inactive. Both remain in TEST for audit history; do not promote or use them for valuation.

### Verification
- TEST: 117 total Mobile Phones product rows; 116 active/customer-visible. 51 evidence rows total, 49 active and 2 retired bad-source rows.
- LIVE: 34 active/customer-visible Mobile Phones products and 35 active evidence rows.
- LIVE-wide evidence integrity: zero missing URLs, missing source keys, non-positive prices, non-GBP values or broken product links; all 35 evidence rows are active.
- This batch adds new-price evidence only; used-market evidence remains a separate workstream.


## 2026-10-23 — Mobile phone catalogue batch 07 (Google Pixel 11 higher storage tiers)

Added and promoted seven higher-storage variants with UK RRP evidence from Mobile Phones UK’s Pixel 11 series price table (published Aug 2026). These are launch RRP references, not live retailer offers; retailer prices and stock can vary.

| Product variant | UK RRP |
|---|---:|
| Pixel 11 512 GB | £999 |
| Pixel 11 Pro 512 GB | £1,199 |
| Pixel 11 Pro 1 TB | £1,429 |
| Pixel 11 Pro XL 512 GB | £1,399 |
| Pixel 11 Pro XL 1 TB | £1,629 |
| Pixel 11 Pro Fold 512 GB | £1,919 |
| Pixel 11 Pro Fold 1 TB | £2,149 |

Source: [Mobile Phones UK — Pixel 11 series UK prices](https://www.mobile-phones.co.uk/news/made-by-google-2026-pixel-11-series). The previously promoted base-storage Pixel 11 family variants remain separately evidenced against current Google Store pages (except Pro XL 256 GB, which uses a secondary UK RRP reference).

### Verification
- TEST: 124 total product rows, 123 active; 58 evidence rows total, 56 active (two retired bad-source/invalid-seed rows retained for audit).
- LIVE: 41 active product variants and 42 evidence rows.
- LIVE-wide integrity: zero missing source URLs, source keys, non-positive prices, non-GBP values, inactive evidence rows or broken product links.
- No used-market evidence added. Research completed/sold UK used prices separately from new-price/RRP evidence.



## 2026-10-23 — Mobile phone catalogue batch 08 (additional storage-specific completed-sale evidence)

Added/promoted six UK completed-sale records for exact storage variants:
- Apple iPhone 15 256 GB — £238.35, sold 7 Oct 2026: https://www.ebay.co.uk/itm/377548449194
- Samsung Galaxy S23 256 GB — £197.61, sold 8 Sep 2026: https://www.ebay.co.uk/itm/298615747269
- Apple iPhone 14 256 GB — £344.99, sold 1 Oct 2026: https://www.ebay.co.uk/itm/178542006119 (condition “Opened – never used”; not a normal used-condition comparable)
- Apple iPhone 15 Pro 256 GB — £386.83, sold 4 Oct 2026: https://www.ebay.co.uk/itm/366701964664
- Samsung Galaxy S24 256 GB — £268.15, sold 4 Aug 2026: https://www.ebay.co.uk/itm/128000546242
- Google Pixel 9 256 GB — £292.20, sold 20 Jul 2026: https://www.ebay.co.uk/itm/298511562847

All are `uk_used` and `availability=sold`, with exact storage matching and source keys. Some displayed totals include buyer-protection fees and should not be treated as seller proceeds or guaranteed buy-in values. Keep the iPhone 14 “Opened – never used” condition distinct from ordinary used condition.

## 2026-10-23 — Mobile phone catalogue batch 09 (11 additional UK completed-sale variants)

Promoted 11 existing TEST phone variants and their linked UK used-market completed-sale evidence to LIVE. These are used-sale observations, not current new prices or guaranteed valuations. Several displayed prices include eBay Buyer Protection fees; listings with Best Offer may not disclose the accepted seller proceeds.

| Product variant | Observed UK completed-sale price | Evidence note |
|---|---:|---|
| Apple iPhone 13 128 GB | £150.00 | Completed eBay sale; battery health, lock status and grade not confirmed |
| Apple iPhone 14 128 GB | £171.08 | Displayed price includes £6.08 Buyer Protection |
| Apple iPhone 15 128 GB | £310.58 | Pristine condition; listing stated 90% battery health; includes £10.58 Buyer Protection |
| Apple iPhone 15 Pro 128 GB | £371.58 | Used condition; includes £11.58 Buyer Protection |
| Apple iPhone 16 128 GB | £366.50 | Best Offer was available; includes £11.50 Buyer Protection |
| Google Pixel 8 128 GB | £155.58 | Unlocked used phone; includes £5.58 Buyer Protection; grade/battery not fully confirmed |
| Google Pixel 9 128 GB | £279.58 | Used; Best Offer available; includes £9.58 Buyer Protection |
| Motorola Edge 50 Neo 256 GB | £199.00 | SIM-free sale; listing mentioned warranty; fine-grained condition not confirmed |
| Nothing Phone (3a) 128 GB | £208.70 | Used, unlocked UK version; Best Offer available; includes £8.70 Buyer Protection |
| Samsung Galaxy S22 128 GB | £139.99 | Used, unlocked, described as Good |
| Samsung Galaxy S24 128 GB | £243.31 | Used, excellent condition, boxed; includes £8.41 Buyer Protection |

### Batch 09 verification and data-quality correction
- TEST: 124 product rows (123 active); 64 phone evidence rows (61 active, 3 inactive retained for audit).
- LIVE: 58 active/customer-visible phone variants and 59 active phone evidence rows (42 UK new-price/RRP and 17 UK used-sale rows).
- LIVE phone evidence integrity check: 0 missing source URLs, missing source keys, non-positive prices, non-GBP prices, inactive evidence rows or orphaned evidence.
- Retired the TEST Samsung Galaxy S26 256 GB evidence row sourced from a generic giffgaff error URL. The product remains in TEST, but the £749 observation is inactive and must not be used until a product-specific source is verified.
- No duplicate active phone variants were found in the LIVE duplicate check.


## 2026-10-23 — Mobile phone catalogue batch 10 (four more completed-sale variants)

Added and promoted exact-storage UK completed/sold eBay evidence for four older iPhone variants:

| Product variant | Observed buyer-facing sold total | Sale date | Source |
|---|---:|---|---|
| Apple iPhone 13 256 GB | £238.25 | 25 Jun 2026 | [eBay UK item 137310801288](https://www.ebay.co.uk/itm/137310801288) |
| Apple iPhone 15 Plus 128 GB | £300.25 | 17 Sep 2026 | [eBay UK item 800655157429](https://www.ebay.co.uk/itm/800655157429) |
| Apple iPhone 15 Pro Max 256 GB | £447.44 | 8 Oct 2026 | [eBay UK item 860018814903](https://www.ebay.co.uk/itm/860018814903) |
| Apple iPhone 16 256 GB | £483.41 | 12 Oct 2026 | [eBay UK item 336839783241](https://www.ebay.co.uk/itm/336839783241) |

Records are marked as UK used evidence with sold availability, condition “Used”, GBP, exact storage, stable source keys and direct completed-listing URLs. All four displayed totals include buyer protection fees; notes state these are buyer-facing totals, not seller proceeds or guaranteed trade-in/buy-in values.

### Verification snapshot after batch 10
- TEST: 124 total phone products, 123 active; 68 evidence rows total, 65 active, including 23 active sold rows. There are 59 visible variants without active evidence still awaiting verification.
- LIVE: 62 active/customer-visible phone variants and 63 active evidence rows, including 21 active sold rows. No active visible LIVE variants were found without active evidence.
- Integrity: zero missing source URLs/keys, non-positive prices, non-GBP values, or broken product links.
- Continue separating completed-sale evidence from new-price, promotional-price, and RRP evidence.


## 2026-10-23 — Mobile phone catalogue batch 11 (four further completed-sale variants)

Added and promoted exact-storage UK completed/sold eBay evidence for four iPhone variants:

| Product variant | Observed buyer-facing sold total | Sale date | Source |
|---|---:|---|---|
| Apple iPhone 15 512 GB | £391.92 | 16 Sep 2026 | [eBay UK item 820135278514](https://www.ebay.co.uk/itm/820135278514) |
| Apple iPhone 16 Plus 128 GB | £417.54 | 22 Oct 2026 | [eBay UK item 377587247150](https://www.ebay.co.uk/itm/377587247150) |
| Apple iPhone 16 Pro 256 GB | £447.44 | 12 Oct 2026 | [eBay UK item 137835281735](https://www.ebay.co.uk/itm/137835281735) |
| Apple iPhone 16 Pro Max 256 GB | £600.33 | 8 Oct 2026 | [eBay UK item 336826938879](https://www.ebay.co.uk/itm/336826938879) |

All records are UK used, sold availability, condition Used, GBP, exact storage, direct listing URLs and stable source keys. Displayed totals include Buyer Protection fees; they are buyer-facing totals, not seller proceeds or guaranteed buy-in values.

### Verification snapshot after batch 11
- TEST: 124 total phone products (123 active); 72 evidence rows total (69 active), including 27 active sold rows. 55 visible variants remain without active evidence.
- LIVE: 66 active/customer-visible phone variants and 67 active evidence rows, including 25 active sold rows. No active visible LIVE variants lack active evidence.
- Integrity: zero missing source URLs/keys, non-positive prices, non-GBP values, or broken product links.


## 2026-10-23 — Mobile phone catalogue batch 12 (five Samsung/Android completed-sale variants)

Added and promoted exact-storage UK completed/sold evidence for five variants:

| Product variant | Observed buyer-facing sold total | Sale date | Source |
|---|---:|---|---|
| Samsung Galaxy S25 128 GB | £359.99 | 15 Aug 2026 | [eBay UK item 188756779985](https://www.ebay.co.uk/itm/188756779985) |
| Samsung Galaxy S25 256 GB | £419.99 | 17 Jun 2026 | [eBay UK item 157995784914](https://www.ebay.co.uk/itm/157995784914) |
| Samsung Galaxy S25 Ultra 256 GB | £513.92 | 6 Oct 2026 | [eBay UK item 800756844624](https://www.ebay.co.uk/itm/800756844624) |
| Nothing Phone (3) 256 GB | £397.60 | 17 Sep 2026 | [eBay UK item 377499796395](https://www.ebay.co.uk/itm/377499796395) |
| Xiaomi 14T 256 GB | £320.75 | 11 Jul 2026 | [eBay UK item 397370297752](https://www.ebay.co.uk/itm/397370297752) |

All records are UK used, sold availability, condition Used, GBP, exact storage, direct listing URLs and stable source keys. Buyer Protection is explicitly recorded where the listing showed it; the displayed prices are not seller proceeds or guaranteed buy-in values.

### Verification snapshot after batch 12
- TEST: 124 total phone products (123 active); 77 evidence rows total (74 active), including 32 active sold rows. 50 visible variants remain without active evidence.
- LIVE: 71 active/customer-visible phone variants and 72 active evidence rows, including 30 active sold rows. No active visible LIVE variants lack active evidence.
- Integrity: zero missing source URLs/keys, non-positive prices, non-GBP values, or broken product links.


## 2026-10-23 — Mobile phone catalogue batch 13 (four further Android completed-sale variants)

Added and promoted exact-storage UK completed/sold evidence for four Android variants:

| Product variant | Observed sold total | Sale date | Source |
|---|---:|---|---|
| HONOR 200 256 GB | £172.03 | 21 May 2026 | [eBay UK item 187670881934](https://www.ebay.co.uk/itm/187670881934) |
| HONOR 400 256 GB | £186.58 | 18 Sep 2026 | [eBay UK item 366670331900](https://www.ebay.co.uk/itm/366670331900) |
| Motorola Razr 50 Ultra 512 GB | £229.58 | 21 Sep 2026 | [eBay UK item 278393659598](https://www.ebay.co.uk/itm/278393659598) |
| OPPO Find X9 Pro 512 GB | £690.00 | 7 Jul 2026 | [eBay UK item 366518048620](https://www.ebay.co.uk/itm/366518048620) |

All records are UK used completed sales, exact storage, sold availability, condition Used, GBP, direct listing URLs and stable source keys. Buyer Protection is noted where shown in the listing; the displayed total is not seller proceeds or a guaranteed buy-in value.

### Verification snapshot after batch 13
- TEST: 124 total phone products (123 active); 81 evidence rows total (78 active), including 36 active sold rows. 46 visible variants remain without active evidence.
- LIVE: 75 active/customer-visible phone variants and 76 active evidence rows, including 34 active sold rows. No active visible LIVE variants lack active evidence.
- Integrity: zero missing source URLs/keys, non-positive prices, non-GBP values, or broken product links.


## 2026-10-23 — Mobile phone catalogue batch 14 (five completed-sale records)

Added exact-variant UK completed-sale evidence for:
| Product variant | Observed sold total | Date | Source |
|---|---:|---|---|
| Google Pixel 10 256 GB | £449.99 | 7 Oct 2026 | [eBay UK](https://www.ebay.co.uk/itm/407267301332) |
| Google Pixel 10 Pro 256 GB | £609.95 | 5 Aug 2026 | [eBay UK](https://www.ebay.co.uk/itm/307091345876) |
| Samsung Galaxy S26 256 GB | £494.99 | 2 Sep 2026 | [eBay UK](https://www.ebay.co.uk/itm/407150921934) |
| OnePlus 13 256 GB | £394.18 | 3 Aug 2026 | [eBay UK](https://www.ebay.co.uk/itm/236978715643) |
| HONOR Magic8 Pro 512 GB | £600.16 | 18 Sep 2026 | [eBay UK](https://www.ebay.co.uk/itm/800677196007) |

Evidence notes preserve condition, Buyer Protection and Best Offer caveats. Galaxy S26 listing title states 100% battery health and 0 cycle count but condition is still listed Used; Pixel 10 Pro is described as excellent; HONOR Magic8 Pro as mint with 100% battery and 99 cycles. These totals are buyer-facing observations, not guaranteed buying offers.



## 2026-10-23 — Mobile phone catalogue batch 15 (three completed-sale records)

Added exact-variant UK completed-sale evidence for:
| Product variant | Observed sold total | Date | Source |
|---|---:|---|---|
| OPPO Find X9 512 GB | £550.00 | 26 Sep 2026 | [eBay UK](https://www.ebay.co.uk/itm/407244892731) |
| Nothing Phone (4a) 256 GB | £320.75 | 17 Aug 2026 | [eBay UK](https://www.ebay.co.uk/itm/298564725017) |
| Samsung Galaxy A27 5G 128 GB | £163.83 | 12 Oct 2026 | [eBay UK](https://www.ebay.co.uk/itm/287639692280) |

Caveats are explicit: OPPO Find X9 listing includes bundle extras and Buyer Protection; Nothing Phone (4a) displayed total includes £10.75 Buyer Protection and Best Offer was accepted; Galaxy A27 5G condition is “Opened – never used” and includes £5.85 Buyer Protection. Keep opened-never-used condition separate from ordinary used comparables.

### Verification snapshot after batch 15
- TEST: 124 phone products (123 active); 89 evidence rows total, 86 active and 3 inactive retained for audit. 38 active customer-visible variants remain without active evidence.
- LIVE: 83 active customer-visible phone variants; 84 active evidence rows, including 42 UK used completed-sale rows.
- LIVE: zero active visible variants without active evidence; zero missing source URLs/keys, non-positive prices, non-GBP evidence or broken product links.
- Continue promoting verified batches regularly; do not let checked TEST evidence accumulate in a backlog.



## 2026-10-23 — Mobile phone catalogue batch 16 (four completed-sale records)

Added exact-variant UK completed-sale evidence:
| Product variant | Displayed sold total | Sale date | Source |
|---|---:|---|---|
| Google Pixel 10 Pro XL 256 GB | £567.70 | 1 Oct 2026 | [eBay UK](https://www.ebay.co.uk/itm/189020010405) |
| OnePlus 12 256 GB | £336.00 | 29 Jun 2026 | [eBay UK](https://www.ebay.co.uk/itm/178216794034) |
| Xiaomi 14T Pro 512 GB | £330.92 | 3 Oct 2026 | [eBay UK](https://www.ebay.co.uk/itm/168756250622) |
| Motorola Razr 70 Ultra 512 GB | £732.50 | 6 Oct 2026 | [eBay UK](https://www.ebay.co.uk/itm/178541991583) |

Evidence notes retain Buyer Protection and Best Offer caveats. Pixel 10 Pro XL is listed as excellent; OnePlus 12 as Used; Xiaomi 14T Pro as Used with Best Offer accepted; Motorola Razr 70 Ultra as “Opened – never used” with Best Offer accepted. Do not treat buyer-facing totals as seller proceeds or guaranteed buying offers; keep opened-never-used separate from ordinary used comparables.

### Verification snapshot after batch 16
- TEST: 124 phone products (123 active); 93 evidence rows total, 90 active and 3 inactive retained for audit. 34 active visible variants remain without active evidence.
- LIVE: 87 active customer-visible phone variants and 88 active evidence rows, including 46 UK used completed-sale rows.
- LIVE integrity check: zero missing URLs/keys, non-positive prices, non-GBP evidence or broken product links. No active visible LIVE variants lack active evidence.



Batch 17 phone catalogue update, 23 Oct 2026. Six UK sold records added and promoted: iPhone 16e 128GB £361.42; iPhone 17 Pro 256GB £873.70; iPhone 17 Pro 512GB £861.08; iPhone 17 Pro Max 256GB £875.04; Galaxy S26 Ultra 256GB £666.42; Galaxy S26 Ultra 512GB £742.67. See CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-17.md. TEST: 124 products (123 active), 99 evidence (96 active), 28 visible variants without evidence. LIVE: 93 visible active variants, 94 evidence rows including 52 used-sale rows. Integrity passed; zero visible variants without evidence. Sale totals include buyer protection where stated and are not guaranteed buying offers.

Mobile phone catalogue batch 18 (23 Oct 2026): Two UK completed-sale records added and promoted: iPhone 17 Pro Max 512 GB £949.99 (sold 12 Sep; excellent, 100% battery health, 133 cycles) and OnePlus 15R 256 GB £459.00 (sold 10 Jul; UK version, unlocked, mint, 100% battery health). Source URLs and notes are in CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-18.md.

After batch 18: TEST has 124 products (123 active), 101 evidence rows (98 active, 3 inactive for audit), and 26 active visible variants without evidence. LIVE has 95 active customer-visible variants and 96 active evidence rows, including 54 UK used completed-sale rows. LIVE integrity check passed; no active visible variant lacks evidence.

Phone catalogue batch 19 (23 Oct 2026): Added and promoted three UK sold records for HONOR 600 Pro 512 GB (£595.25), HONOR Magic V6 512 GB (£1,125.21), and Nothing Phone (4a) Pro 256 GB (£371.58). See CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-19.md. Condition, Best Offer and Buyer Protection notes are retained.

Current snapshot: TEST 124 products (123 active), 104 evidence rows (101 active, 3 inactive), 23 visible variants without active evidence. LIVE 98 active visible products, 99 active evidence rows including 57 used-sale rows. Recheck integrity at next batch close.

Batch 20 phone catalogue: OPPO A6 Pro 5G 256 GB, £180.00, completed sale 19 July 2026, certified refurbished. Source https://www.ebay.co.uk/itm/287441531751. See CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-20.md. Keep refurbished condition separate from ordinary used and new/RRP evidence. LIVE now has 99 active visible variants; integrity failures 0; missing-evidence visible variants 0.

## Mobile phone catalogue continuity — batch 21 (23 October 2026)

TradeFlow mobile-phone market evidence work is continuing in Supabase TEST first, then promptly promoting validated batches to LIVE. Current state after Batch 21:
- TEST: 126 active customer-visible phone variants; 112 evidence rows total, 109 active and 3 inactive retained for audit; 15 active visible variants lack active evidence.
- LIVE: 107 active customer-visible phone variants; 107 active evidence rows including 58 UK used completed-sale rows; zero active visible variants missing active evidence and zero integrity failures.
- Batch 21 added seven UK new-price/listing evidence rows: HONOR 600 256 GB £599.99 manufacturer-store list price; HONOR 600 Smart 128 GB £249.99 Argos; Xiaomi 17T 256 GB £549 promotional price vs £649 original; Xiaomi 17T Pro 512 GB £699 promotional price vs £849 original; HONOR Magic8 Lite 256 GB £349.99 after-coupon price; Samsung Galaxy S26+ 256 GB £1,179 Samsung UK in-stock listing; Samsung Galaxy A27 5G 256 GB £209.99 current UK eBay listing, condition Opened – never used; secondary-market listing, not completed-sale or sealed-new evidence.
- Xiaomi 17T/17T Pro campaign prices expire 27 October 2026 or earlier if stock runs out. Recheck/retire promotional evidence after expiry; never silently treat a promo price as evergreen RRP.
- TEST has 126 active visible variants in the current query, up from 123 in the Batch 20 checkpoint. Use current database results as authoritative and identify the additional rows while working through remaining gaps.
- Continue exact model/storage validation, direct source URLs, GBP positive prices, stable source keys, conservative availability and separation of new offers from completed-sale evidence. Do not use the OnePlus 15 listing that item specifics identify as OnePlus 10 Pro, or any search result that redirects to unrelated products.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-21.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-21.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next action: resolve the 15 remaining TEST variants without active evidence, then re-query and promote each validated batch to LIVE.

## Mobile phone catalogue continuity — batch 22 (23 October 2026)

Batch 22 added and promoted Samsung Galaxy S25+ 256 GB at £770.00 from a current sealed/boxed UK eBay business-seller listing (Kent, more than 10 available at observation). Source: https://www.ebay.co.uk/itm/168750596099. This is a listing price, not completed-sale evidence.

Latest snapshot:
- TEST: 126 active visible variants; 113 evidence rows (110 active, 3 inactive for audit); 14 active visible variants without active evidence.
- LIVE: 108 active visible variants; 108 active evidence rows; 58 UK completed-sale rows with availability=sold, plus one secondary-market listing row with availability=listed and condition “Opened – never used”. LIVE integrity failures: 0; active visible variants missing active evidence: 0.
- Samsung Galaxy A27 5G 256 GB direct listing https://www.ebay.co.uk/itm/287456740841 was checked after insertion and explicitly says “Opened – never used”; its evidence was corrected to `uk_used`, condition “Opened – never used”, availability `listed`. Do not treat it as sealed new or a completed sale.
- A purported OPPO Reno13 5G 256 GB sale URL redirected to an OPPO Reno4 Pro 5G product page with mismatched identifiers; rejected. The official OnePlus UK page labels OnePlus 15 “Coming soon”; the misleading eBay listing identifying OnePlus 10 Pro remains rejected.
- Batch 22 checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-22.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-22.md`; aggregate memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: resolve 14 remaining TEST variants without active evidence. Continue exact-variant UK source validation, promote checked batches promptly, and recheck Xiaomi 17T/17T Pro promotional prices after 27 Oct 2026.


## Mobile phone catalogue continuity — batch 23 (23 October 2026)

Batch 23 added official Xiaomi UK listed prices with availability explicitly set to `coming_soon`: REDMI Note 15 6 GB/128 GB £179 and REDMI Note 15 Pro 5G 8 GB/256 GB £349. Source: https://www.mi.com/uk/event/redmi-note-15-series/. Do not treat these as in-stock prices.

Two unverified TEST product seeds were hidden from customer visibility pending official identity/release confirmation: Apple iPhone 18 256 GB and Nothing Phone (4b) 128 GB. Both remain active and neither is marked discontinued or deleted. Notes were updated for HMD Skyline, Motorola Edge 70/Edge 70 Pro 256 GB, moto g37, OnePlus 15, Redmi Note 15 and realme variants to record unresolved exact SKU/UK availability.

Latest snapshot:
- TEST: 124 active visible variants; 115 evidence rows (112 active, 3 inactive for audit); 10 active visible variants without evidence.
- LIVE: 110 active visible variants; 110 active evidence rows; 58 UK completed-sale rows where availability=sold, plus one secondary-market listing row with availability=listed and condition “Opened – never used”. LIVE integrity failures: 0; active visible variants missing active evidence: 0.
- Reject the OPPO Reno13 URL that redirects to an OPPO Reno4 Pro product page. Do not reuse Motorola 512 GB pricing for 256 GB variants. OnePlus 15 is officially “Coming soon”; no UK price verified. Recheck Xiaomi 17T/17T Pro promo prices after 27 Oct 2026.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-23.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-23.md`; aggregate memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: resolve the remaining 10 visible TEST variants without active evidence, promote validated batches promptly and rerun LIVE integrity checks.


## Mobile phone catalogue continuity — batch 24 (23 October 2026)

Batch 24 added seven exact-variant UK evidence rows to TEST and LIVE:
- HMD Skyline 8GB/256GB £334.69 PriceSpy UK offer shown in stock (lowest-price indicator £229 had no direct offer link).
- Motorola Edge 70 Pro 8GB/256GB £499 from GSMSpecs' Amazon UK price reference dated 11 Oct; secondary source, recheck checkout.
- Motorola moto g37 5G 128GB £189.99 Argos, stock postcode-dependent.
- Nothing Phone (3a) Pro 256GB £342.99 excellent-refurbished UK eBay listing, seller Stockport; asking price only.
- OPPO Reno13 5G 256GB £254.27 Currys Clearance excellent-refurbished listing, currently out of stock with 21 sold historically; not an individual verified sale.
- realme 14 Pro+ 5G 12GB/512GB £745 new UK eBay listing from KICKmobiles in Kensington; long dispatch/import-fee caveats.
- REDMI Note 15 Pro+ 5G 12GB/512GB sold UK listing displayed £179.56 on 23 Sep; includes £6.36 Buyer Protection and Best Offer caveat.

Motorola Edge 70 256GB was hidden from TEST customer visibility because exact UK 256GB SKU was not verified; UK retailer listings found were 512GB. It remains active, not discontinued.

Latest snapshot:
- TEST: 123 active visible variants; 122 evidence rows (119 active, 3 inactive); 2 active visible variants without evidence.
- LIVE: 117 active visible variants; 117 active evidence rows; 59 UK completed-sale rows and 2 secondary-market listed rows. LIVE integrity failures: 0; active visible variants missing active evidence: 0.
- Remaining visible gaps: OnePlus 15 256GB (current official UK checkout price not verified; do not use false listing identifying OnePlus 10 Pro) and realme GT 7 Pro 512GB (Germany/China seller evidence rejected as non-UK-local).
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-24.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-24.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: research only these two remaining gaps with exact-variant UK sources. Recheck Xiaomi 17T/17T Pro promotion after 27 Oct 2026.


## Mobile phone catalogue continuity — batch 25 (23 October 2026)

Batch 25 added a realme GT 7 Pro 5G 12GB/512GB Orange global-version UK eBay listing at £986.25. The seller is located in London; condition is “Opened – never used”; page showed 2 available and 1 sold. Seller feedback is only 83.3% positive with low listing volume and the price is unusually high. This is a `uk_used` listing observation, not a completed sale or typical market value. Source: https://www.ebay.co.uk/itm/226935746106.

Only one visible TEST gap remains: OnePlus 15 256GB. Official UK page https://www.oneplus.com/uk/launch/oneplus-15 currently says “Coming soon”. The early-bird terms refer to a 2025 campaign; do not treat the £849 figure from a dated community post as a current UK checkout price.

Latest snapshot:
- TEST: 123 active visible variants; 123 evidence rows (120 active, 3 inactive); one visible variant without active evidence.
- LIVE: 118 active visible variants; 118 active evidence rows; 59 UK completed-sale rows, 3 secondary-market listed rows, and one separately classified out-of-stock refurbished listing. LIVE integrity failures: 0; visible variants missing active evidence: 0.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-25.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-25.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: resolve OnePlus 15 only when a current exact-variant UK source provides verifiable price/availability. Recheck Xiaomi 17T/17T Pro campaign after 27 Oct 2026.


## Mobile phone catalogue continuity — batch 26 (23 October 2026)

Resolved the final active visible TEST evidence gap: OnePlus 15 5G 12GB/256GB Black SIM-free, £849 new-price reference from MyMobiles' October 2026 deal page, which identifies OnePlus as seller. Source: https://www.mymobiles.com/phones/oneplus/15-deals. The linked official OnePlus page currently shows Notify me/early-bird material, so evidence availability is `listed`, not `in_stock`. Stable key: `mobile-new-oneplus15-256gb-mymobiles-oneplus-20261023`.

The purported realme GT 7 Pro 512GB sold listing at https://www.ebay.co.uk/itm/267681249311 was rejected for the 512GB product because item specifics say 256GB/12GB RAM. Another 512GB sale from a Frankfurt, Germany seller remains rejected as non-UK-local evidence.

Latest snapshot:
- TEST: 123 active visible variants; 124 evidence rows (121 active, 3 inactive); zero visible variants missing active evidence.
- LIVE: 119 active visible variants; 119 active evidence rows; 59 UK completed-sale rows and 3 secondary-market listed rows. LIVE integrity failures: 0; visible variants missing active evidence: 0.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-26.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-26.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: continue expanding the catalogue with additional exact-variant UK phone models and evidence. Recheck Xiaomi 17T/17T Pro campaign after 27 Oct 2026.


## Mobile phone catalogue continuity — batch 27 (23 October 2026)

Added six exact UK variants and matching evidence in TEST and LIVE:
- Apple iPhone Duo 256GB £1,999; 512GB £2,199; 1TB £2,599; 2TB £3,199. Official Apple UK buy page. Apple availability begins 23 Oct 2026, but the buy page still says pre-order / available starting 10.23; evidence is `listed`, not `in_stock`.
- Samsung Galaxy A18 4G 128GB £249 from Currys: https://www.currys.co.uk/products/samsung-galaxy-a18-128-gb-light-blue-10311352.html.
- Motorola Edge 70 Plus 8GB/256GB £499 from Currys: https://www.currys.co.uk/products/motorola-edge-70-plus-256-gb-pantone-mountain-view-10310979.html.
- Check postcode-dependent stock/delivery before representing either Currys listing as available for a particular customer.

Latest snapshot:
- TEST: 129 active visible variants; 130 evidence rows (127 active, 3 inactive); zero visible variants missing active evidence.
- LIVE: 125 active visible variants; 125 active evidence rows; 59 UK completed-sale rows. LIVE integrity failures: 0; visible variants missing active evidence: 0.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-27.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-27.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: continue adding newly released UK models and exact storage variants. Recheck Xiaomi 17T/17T Pro campaign after 27 Oct 2026.


## Mobile phone catalogue continuity — batch 28 (23 October 2026)

Added three exact UK variants to TEST and LIVE:
- Motorola Edge 70 Plus 8GB/256GB £499 from Currys: https://www.currys.co.uk/products/motorola-edge-70-plus-256-gb-pantone-mountain-view-10310979.html.
- OPPO Find X10 12GB/256GB £1,099 from EE: https://ee.co.uk/products/oppo-find-x10-sim-free. Pre-order; launch expected 28 Oct 2026; availability `coming_soon`.
- OPPO Find X10 Pro Max 12GB/512GB £1,499 from EE: https://ee.co.uk/products/oppo-find-x10-pro-max-sim-free. Pre-order; launch expected 28 Oct 2026; availability `coming_soon`.

Latest snapshot:
- TEST: 131 active visible variants; 132 evidence rows (129 active, 3 inactive); zero visible variants missing active evidence.
- LIVE: 127 active visible variants; 127 active evidence rows; 59 UK completed-sale rows. LIVE integrity failures: 0; visible variants missing active evidence: 0.
- Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-28.md`; batch memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-28.md`; aggregate: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.
- Next: continue adding exact UK smartphone models and variants; recheck OPPO pre-orders after 28 Oct and Xiaomi 17T/17T Pro campaign after 27 Oct 2026.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 31)
The current phone-catalogue checkpoint is `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-31.md`; aggregate research notes are in `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.

Current verified position: TEST has 130 active customer-visible phone variants and 147 evidence rows (138 active, 9 inactive retained for audit). LIVE has 128 active customer-visible variants and 142 evidence rows (136 active, 6 inactive retained for audit). LIVE has 62 active UK used completed-sale rows, 3 UK used/listed rows, zero active visible variants missing evidence, and zero active evidence integrity failures.

Recent updates include Nothing Phone (4b) 8GB/128GB official UK price £299 and OnePlus 15 12GB/256GB UK price reference £849. The OnePlus 15 source is a price reference only; availability is listed, not confirmed in stock. Xiaomi 17T/17T Pro campaign prices (£549/£699) must be rechecked after 27 October 2026. Keep TEST → LIVE promotion regular, and preserve exact variant, source, price-type, availability and condition caveats. Do not use eBay item 257792354372 as OnePlus 15 evidence because its item specifics identify OnePlus 10 Pro.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 32)
The current phone catalogue checkpoint is `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-32.md`; aggregate evidence notes are in `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue.md`.

Two OPPO variants were added and promoted from TEST to LIVE: Reno16 F 5G 8GB/256GB at £479 and Reno16 5G 8GB/512GB at £699, sourced from official OPPO UK pricing guidance. The current OPPO UK smartphone catalogue labels both out of stock; keep evidence availability as `out_of_stock` until current stock is verified.

Current verified position: TEST has 132 active customer-visible variants and 149 evidence rows (140 active, 9 inactive retained for audit). LIVE has 130 active customer-visible variants and 144 evidence rows (138 active, 6 inactive retained for audit), including 62 UK used completed-sale rows and 3 UK used/listed rows. LIVE has no visible variants missing active evidence and zero active evidence integrity failures. Recheck Xiaomi 17T/17T Pro promotional prices after 27 October 2026.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 33)
Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-33.md`; project memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-33.md`.

Added and promoted official UK new-price evidence for iPhone 18 Pro 256GB (£1,199), iPhone 18 Pro Max 256GB (£1,299), iPhone Duo 256GB (£1,999), and Google Pixel 11 Pro 256GB (£1,079). Added a £497 UK comparison price for Motorola Edge 70 Plus 256GB; confirm the Mobiles.co.uk code and checkout total before treating it as a final price.

Exact-variant controls: the OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB comparison rows were made inactive because the summary source did not explicitly confirm storage capacity. Both products are hidden from customer visibility in TEST and LIVE pending exact-variant evidence. Do not reactivate based only on model-level price results.

Current verified position: TEST has 130 active customer-visible variants and 156 evidence rows (145 active, 11 inactive). LIVE has 128 active customer-visible variants and 151 evidence rows (143 active, 8 inactive), including 62 UK used completed-sale rows and 3 used/listed rows. Both environments have zero active visible variants missing active evidence; LIVE active evidence integrity failures are zero. Recheck Xiaomi 17T / 17T Pro campaign prices after 27 October 2026 and keep OnePlus 15 availability unconfirmed until direct checkout is verified.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 34)
Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-34.md`; project memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-34.md`.

Added exact official Apple UK prices to TEST and LIVE: iPhone 18 Pro 512GB (£1,399), iPhone 18 Pro Max 512GB (£1,499), and iPhone Duo 512GB (£2,199). Preserve each as a new-price reference, not a used value or buying offer.

Verified position: TEST 130 active customer-visible variants and 159 evidence rows (148 active, 11 inactive). LIVE 128 active customer-visible variants and 154 evidence rows (146 active, 8 inactive), including 62 UK used completed-sale rows and 3 used/listed rows. Both environments have zero active visible variants missing active evidence; LIVE active evidence integrity failures are zero. Keep OPPO Find X10 256GB and Samsung Galaxy A18 4G 128GB hidden pending exact-capacity evidence; recheck Xiaomi 17T/17T Pro after 27 October; OnePlus 15 stock remains unconfirmed.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 35)
Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-35.md`; project memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-35.md`.

Added exact official Apple UK new prices in TEST and LIVE for iPhone 18 Pro 1TB (£1,799) and 2TB (£2,399), iPhone 18 Pro Max 1TB (£1,899) and 2TB (£2,499), and iPhone Duo 1TB (£2,599) and 2TB (£3,199). Keep these classified as new list-price evidence, not used-market values or buy offers.

Current verified position: TEST has 130 active customer-visible variants and 165 evidence rows (154 active, 11 inactive). LIVE has 128 active customer-visible variants and 160 evidence rows (152 active, 8 inactive), including 62 UK used completed-sale rows and 3 used/listed rows. Both environments have zero visible active variants missing active evidence; LIVE active evidence integrity failures are zero. Continue hiding OPPO Find X10 256GB and Galaxy A18 4G 128GB until exact storage is verified; recheck Xiaomi promotion after 27 October; OnePlus 15 availability is still unconfirmed.


## Mobile phone catalogue evidence continuity — 23 October 2026 (Batch 36)
Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-36.md`; project memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-36.md`.

Added exact official Google Store UK new-price evidence to TEST and LIVE: Pixel 11 256GB / 12GB RAM (£879), Pixel 11 512GB / 12GB RAM (£999), and Pixel 11 Pro 512GB / 16GB RAM (£1,199). Keep trade-in bonuses separate from device price and treat current offers as checkout-dependent where noted.

Current verified position: TEST 130 active customer-visible variants and 168 evidence rows (157 active, 11 inactive). LIVE 128 active customer-visible variants and 163 evidence rows (155 active, 8 inactive), including 62 UK used completed-sale rows and 3 used/listed rows. No active visible variants are missing evidence; LIVE integrity failures are zero. Continue hiding OPPO Find X10 256GB and Galaxy A18 4G 128GB pending exact capacity evidence, recheck Xiaomi campaign after 27 October, and do not mark OnePlus 15 in stock without checkout proof.


## Mobile phone catalogue evidence update — Batch 37 (23 October 2026)
Checkpoint: `CHECKPOINTS/2026-10-23-mobile-phone-catalogue-batch-37.md`; project memory: `PROJECT-MEMORY/2026-10-23-mobile-phone-catalogue-batch-37.md`.

Added in TEST and promoted to LIVE: Samsung Galaxy S25 128GB used completed sale (£339.99, eBay UK, 19 Oct; displayed total includes Buyer Protection); Samsung Galaxy A37 5G 128GB / 6GB RAM new listing (£399, Argos; postcode-dependent stock, listed rather than confirmed in stock); Apple iPhone 16 128GB used completed sale (£369.03, eBay UK, 3 Oct; displayed total includes £14.03 Buyer Protection); Samsung Galaxy S24 128GB used completed sale (£271.19, eBay UK, 17 Sep; displayed total includes £11.19 Buyer Protection). All used sale prices are buyer-facing totals, not seller proceeds.

Verified snapshot: TEST 130 active customer-visible variants, 172 evidence rows (161 active, 11 inactive), 67 active UK used completed-sale rows; LIVE 128 active customer-visible variants, 167 evidence rows (159 active, 8 inactive), 65 active UK used completed-sale rows. Both have zero active visible variants missing active evidence, zero active evidence integrity failures, and zero duplicate active source keys. Maintain TEST-first validation, prompt LIVE promotion, and the distinction between completed sales, asking prices and buyer-facing totals including fees. Recheck Xiaomi 17T / 17T Pro after 27 October and OPPO Find X10 after 28 October 2026.


## Mobile catalogue evidence update — 24 October 2026 (Batch 38)
Current checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-38.md`; project memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-38.md`.

Three UK completed-sale records (Galaxy S24 128GB, Pixel 9 128GB, iPhone 16 128GB) were inserted in TEST, promoted to LIVE, and read back in both environments. Phone-category snapshot: TEST 175 evidence rows (164 active, 11 inactive), 70 active used-sale rows; LIVE 170 evidence rows (162 active, 8 inactive), 68 active used-sale rows. Both have 0 visible active variants missing active evidence and 0 checked integrity failures or duplicate active source keys.

Operational note: an intermittent tool safety block is not a database error. Distinguish tool-layer blocks from returned PostgreSQL errors. Do not assume `source_record_key` has a unique constraint: an `ON CONFLICT (source_record_key)` insert returned PostgreSQL 42P10. Check the key is absent first, use a plain insert, then read the row back in TEST and LIVE. Preserve historical observations when a live listing later displays a different fee-inclusive total; investigate rather than silently rewriting history. Buyer Protection totals are not seller proceeds.


## Mobile catalogue evidence update — 24 October 2026 (Batch 39)
Current checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-39.md`; project memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-39.md`.

Three UK completed-sale records (Galaxy S24 128GB, Pixel 9 128GB, iPhone 16 128GB) were inserted in TEST, promoted to LIVE, and read back in both environments. Phone-category snapshot: TEST 178 evidence rows (167 active, 11 inactive), 73 active used-sale rows; LIVE 173 evidence rows (165 active, 8 inactive), 71 active used-sale rows. Both have zero active visible variants missing active evidence and zero checked integrity failures or duplicate active source keys.

Preserve condition and transaction caveats: Pixel 9 listing notes chipped paint; iPhone 16 Best Offer was accepted; eBay Buyer Protection totals are buyer-facing, not seller proceeds. If old listing totals change, investigate revisions/relisting and preserve observation history rather than silently overwriting. Continue TEST-first validation and prompt LIVE promotion.


## Mobile catalogue evidence update — 24 October 2026 (Batch 40)
Checkpoint: `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-40.md`; project memory: `PROJECT-MEMORY/2026-10-24-mobile-phone-catalogue-batch-40.md`.

Three UK completed-sale rows (Galaxy S24 128GB, iPhone 16 128GB White, Pixel 9 256GB Porcelain) were inserted in TEST, promoted to LIVE, and read back from both environments. Phone-category snapshot: TEST 181 evidence rows (170 active, 11 inactive), 76 active UK used-sale rows; LIVE 176 evidence rows (168 active, 8 inactive), 74 active UK used-sale rows. Both have zero visible active variants missing evidence and zero checked integrity failures or duplicate active source keys.

Buyer Protection amounts are part of the buyer-facing total, not seller proceeds. Preserve Best Offer and condition notes. When live pages change, do not silently rewrite historical observations. Continue TEST-first and promote validated batches promptly.


### Mobile phone catalogue — Batch 41 (24 October 2026)
Three completed UK eBay sale observations were inserted in TEST, verified against the correct 128GB master products, then promoted to LIVE and read-back verified: Galaxy S24 128GB Marble Grey £249.99 (item 800671014611, 17 Sep); Pixel 9 128GB Porcelain £315.67 including £10.67 Buyer Protection, Best Offer accepted (item 128115577878, 5 Oct); iPhone 16 128GB Ultramarine £381.75 including £11.75 Buyer Protection, Best Offer accepted (item 318875321713, 16 Sep). Source URLs and stable keys are in the Batch 41 checkpoint.

Post-batch phone metrics: TEST 130 active visible variants, 173 active phone evidence rows and 79 active UK used completed-sale rows; LIVE 128, 171 and 77 respectively. No visible active phone variant lacks active evidence; phone evidence has zero URL/key/positive GBP price integrity failures and zero duplicate active source keys. A whole-table scan reports unrelated overseas USD evidence (one TEST row, two LIVE rows); keep this separate from phone metrics and do not modify it in this batch. Preserve historical records when eBay totals change. Buyer Protection totals are buyer-facing, and accepted Best Offer may mean the displayed total does not equal seller proceeds.


### Mobile phone catalogue — Batch 42 and Batch 43 (24 October 2026)
Batch 42 was independently verified active in both environments. Batch 43 added and promoted three distinct UK eBay completed-sale observations: iPhone 16 128GB Teal £429.70 including £12.54 Buyer Protection (item 287579080965; relisting caveat); iPhone 16 128GB Ultramarine £440.00 (item 366668186600; title says “NO FLAWS” but description mentions refurbishment/moderate wear, so do not normalise as pristine); Galaxy S24 128GB Purple £269.25 including £9.25 Buyer Protection (item 198530912410; Best Offer accepted). See Batch 43 checkpoint for URLs, timestamps and stable keys.

Fresh post-batch metrics: TEST 179 active phone evidence rows and 85 active UK used completed-sale rows; LIVE 177 active phone evidence rows and 83 active UK used completed-sale rows. Both environments have zero phone-scoped URL/key/positive GBP price/currency integrity failures and zero duplicate active source keys. Continue TEST-first then promote validated evidence promptly. Do not overwrite historical observations for relistings or changing displayed totals; Buyer Protection totals are buyer-facing, not seller proceeds, and contradictory condition descriptions must remain explicit caveats.


### Mobile phone catalogue — Batch 44 (24 October 2026)
Three more UK eBay completed-sale observations were added to TEST and promoted to LIVE: Pixel 9 128GB Obsidian £347.76 including £11.19 Buyer Protection, Best Offer accepted (item 298415131329); iPhone 16 128GB Ultramarine £374.67 including £11.63 Buyer Protection, 90% battery health (item 327147326675); Galaxy S24 128GB Marble Grey £368.00 (item 376877291140; fee not separately captured). See Batch 44 checkpoint for exact URLs and stable keys.

Post-batch metrics: TEST 182 active phone evidence rows and 88 active UK used completed-sale rows; LIVE 180 active phone evidence rows and 86 active UK used completed-sale rows. Both have zero phone-scoped evidence integrity failures and zero duplicate active source keys. Continue TEST-first then promote promptly; never infer seller proceeds from buyer-facing totals and do not overwrite historical observations.


### Mobile phone catalogue — Batch 45 (24 October 2026)
Three UK eBay completed-sale observations were added to TEST then promoted to LIVE: iPhone 15 128GB Light Blue £327.83 including £10.87 Buyer Protection, 7 bids (item 168659039520); iPhone 15 128GB Black unlocked, described as excellent with good battery health, £330.92 including £10.92 Buyer Protection (item 377366853347); Galaxy S24 256GB Black £268.15 including £9.21 Buyer Protection (item 128000546242; Best Offer acceptance not confirmed). See Batch 45 checkpoint for URLs and stable keys.

Post-batch metrics: TEST 185 active phone evidence rows and 91 active UK used completed-sale rows; LIVE 183 active phone evidence rows and 89 active UK used completed-sale rows. Both have zero phone-scoped evidence integrity failures and zero duplicate active source keys. Preserve historical observations and do not infer seller proceeds from buyer-facing totals.


### Mobile phone catalogue — Batch 46 (24 October 2026)
Three UK eBay completed-sale observations were added to TEST and promoted to LIVE: iPhone 15 128GB Black £253.75 including £8.75 Buyer Protection, Best Offer accepted (item 800710234384); iPhone 15 128GB Black £258.92 including £8.92 Buyer Protection, Best Offer accepted (item 377436509526); Galaxy S24 256GB Grey unlocked £309.55 including £10.55 Buyer Protection, Best Offer accepted (item 336549983134). See Batch 46 checkpoint for URLs and stable keys.

Post-batch metrics: TEST 188 active phone evidence rows and 94 active UK used completed-sale rows; LIVE 186 active phone evidence rows and 92 active UK used completed-sale rows. Both have zero phone-scoped evidence integrity failures and zero duplicate active source keys. Keep Buyer Protection-inclusive amounts buyer-facing, preserve Best Offer notes, and do not overwrite historical observations.


### Mobile phone catalogue — Batch 47 (24 October 2026)
Three UK eBay completed-sale observations were added to TEST and promoted to LIVE: iPhone 15 128GB Black, 93% battery health, £322.84 including £10.78 Buyer Protection (item 377552504716; Best Offer acceptance not confirmed); iPhone 15 128GB unlocked, listing title states 100% battery health and excellent condition, £291.90 including £11.90 Buyer Protection (item 366731563762); Galaxy S24 128GB Purple unlocked dual SIM, £258.92 including £8.92 Buyer Protection (item 227389511234). See Batch 47 checkpoint for URLs and stable keys.

Post-batch metrics: TEST 191 active phone evidence rows and 97 active UK used completed-sale rows; LIVE 189 active phone evidence rows and 95 active UK used completed-sale rows. Both have zero phone-scoped evidence integrity failures and zero duplicate active source keys. Preserve caveats, do not infer seller proceeds from buyer-facing totals, and retain historical observations.


### Mobile phone catalogue — Batch 48 (24 October 2026)
Three UK eBay completed-sale observations were added to TEST and promoted to LIVE: iPhone 16 128GB White, cracked back/damaged, £295.08 including £10.08 Buyer Protection, Best Offer accepted (item 398370939162); Galaxy S24 256GB White £186.58 including £6.58 Buyer Protection (item 366534598634; retain as a low-price observation pending condition review); iPhone 15 128GB White A3090 £248.58 including £8.58 Buyer Protection (item 178513141590; accepted-offer status not confirmed). See Batch 48 checkpoint for URLs and stable keys.

Post-batch metrics: TEST 194 active phone evidence rows and 100 active UK used completed-sale rows; LIVE 192 active phone evidence rows and 98 active UK used completed-sale rows. Both have zero phone-scoped evidence integrity failures and zero duplicate active source keys. Keep condition caveats explicit and do not infer seller proceeds from buyer-facing totals.



## Batch 49 — 24 October 2026
Added three fresh UK eBay used-phone completed-sale observations, checked the stable source keys absent in TEST and LIVE before insertion, inserted to TEST first, then promoted the same observations to LIVE.

1. Apple iPhone 15 128GB Blue, factory unlocked — £269.25 displayed buyer total, including £9.25 Buyer Protection; sold 23 Sep 2026. The item price/seller proceeds are not separately captured. https://www.ebay.co.uk/itm/398420637687. Key: `mobile-used-sold-iphone15-128gb-ebay-398420637687-20260923`.
2. Apple iPhone 15 128GB Black — £265.99 displayed buyer total, including £10.99 Buyer Protection; Best Offer accepted; sold 27 Sep 2026. The accepted item price/seller proceeds are not separately shown. https://www.ebay.co.uk/itm/188991253809. Key: `mobile-used-sold-iphone15-128gb-ebay-188991253809-20260927`.
3. Apple iPhone 16 128GB Green, locked to Sky Mobile — £391.92 displayed buyer total, including £11.92 Buyer Protection; sold 22 Aug 2026. Keep the network-lock caveat; this is not directly comparable with unlocked devices. https://www.ebay.co.uk/itm/800546931991. Key: `mobile-used-sold-iphone16-128gb-ebay-800546931991-20260822`.

Post-batch integrity checks (phone category joined through each environment's own category ID):
- TEST: 197 active phone evidence rows; 103 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.
- LIVE: 195 active phone evidence rows; 101 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 49 keys active.

The integrity check intentionally tests URL presence/HTTP format rather than restricting all existing evidence to eBay URLs, since the phone catalogue includes other valid source types. Preserve Buyer Protection totals as buyer-facing totals, not seller proceeds. Continue TEST-first and promote validated evidence promptly.


## Mobile phone catalogue — Batch 50 (24 October 2026)

Added three fresh UK eBay iPhone 15 128GB completed-sale observations. Stable keys were checked absent in both environments before insertion; records were inserted into TEST first and then promoted to LIVE.

1. iPhone 15 128GB White, unlocked — £217.58 displayed buyer total including £7.58 Buyer Protection; sold 11 Sep 2026. Listing title says “Read Description”; underlying caveat is not fully established in the captured extract, so retain this caveat-bearing observation and do not assume typical working condition. https://www.ebay.co.uk/itm/278364248917. Key: `mobile-used-sold-iphone15-128gb-ebay-278364248917-20260911`.
2. iPhone 15 128GB Black with box — £258.92 displayed buyer total including £8.92 Buyer Protection; Best Offer accepted; sold 22 Sep 2026. Listing says seller relisted this item or one like it, so preserve this observation separately from other records. https://www.ebay.co.uk/itm/318900425831. Key: `mobile-used-sold-iphone15-128gb-ebay-318900425831-20260922`.
3. iPhone 15 128GB White — £207.25 displayed buyer total including £7.25 Buyer Protection; Best Offer accepted; sold 2 Aug 2026. Explicitly marked “For parts or not working”; do not use as a typical working-phone benchmark. https://www.ebay.co.uk/itm/366574722022. Key: `mobile-used-sold-iphone15-128gb-ebay-366574722022-20260802`.

Post-batch checks using each environment's own phone-category ID:
- TEST: 200 active phone evidence rows; 106 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.
- LIVE: 198 active phone evidence rows; 104 active UK used completed-sale rows; zero basic phone-scoped URL/key/positive GBP price/currency failures; zero duplicate active source-key groups; all three Batch 50 keys active.

Buyer Protection totals are buyer-facing totals, not seller proceeds. Keep “Read Description”, relisting and non-working caveats explicit. Continue TEST-first, promote validated evidence promptly, and avoid overwriting historical listing observations.


## Mobile phone catalogue — Batch 51 (24 October 2026)
Two iPhone 15 128GB UK eBay completed-sale records were verified, inserted into TEST, and promoted to LIVE. One unlocked Black sale displayed £281.50 including £11.50 Buyer Protection with Best Offer accepted; one Black “For parts or not working” sale displayed £49.56 including £2.16 Buyer Protection. Keep buyer-facing totals distinct from seller proceeds and exclude the parts-only sale from working-phone benchmarks. Verified counts: TEST 202 active phone evidence / 108 active UK used sold; LIVE 200 / 106. Both environments have zero basic phone evidence integrity failures and zero duplicate active source keys. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-51.md`.


## Mobile phone catalogue — Batch 52 (24 October 2026)
Two UK eBay completed-sale records were added to TEST and promoted to LIVE: iPhone 15 128GB Pink (£309.99 displayed; boxed, very good condition, 88% battery health; Best Offer acceptance unconfirmed) and Galaxy S24 128GB with a faulty fingerprint sensor (£110 displayed including Buyer Protection; explicitly non-working/parts only). Exclude the Galaxy S24 record from working-phone benchmarks. TEST: 204 active phone evidence / 110 active UK used sold. LIVE: 202 / 108. Both environments have zero basic phone evidence integrity failures and zero duplicate active source keys. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-52.md`.


## Mobile phone catalogue — Batch 53 (24 October 2026)
Two Pixel 9 128GB UK eBay completed-sale observations were added TEST-first then LIVE: £299.99 (15 June) and £269.95 (24 July; listing title states 99% battery health). Best Offer acceptance and fee details are not confirmed in captured sources. An existing Galaxy S24 128GB sale was verified in both environments and not duplicated. TEST: 206 active phone evidence / 112 active UK used sold; LIVE: 204 / 110; zero basic integrity failures and zero duplicate active source keys. Preflight source keys globally before insertion. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-53.md`.


## Mobile phone catalogue — Batch 54 (24 October 2026)
Two Pixel 9 128GB Porcelain UK eBay completed-sale observations were added TEST-first then LIVE: Used £291.89 on 24 May (includes £11.90 Buyer Protection; Best Offer accepted; postage separate) and Opened - never used £349.99 on 14 August (Buyer Protection fee not captured; do not blend with ordinary used benchmarks). Both keys were read-after-write verified active in both environments. TEST: 208 active phone evidence / 114 active UK used sold; LIVE: 206 / 112. A false-positive search result for a phone case was rejected and not inserted. Continue global stable-key preflight and preserve condition/fee caveats. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-54.md`.


## Mobile phone catalogue — Batch 55 (24 October 2026)
Seven UK eBay completed-sale observations were added TEST-first then LIVE: four iPhone 14 128GB and three Pixel 8 128GB. Preserve the iPhone battery-health notes (77% and 78%) and the Pixel 8 GrapheneOS/custom-OS caveat; Buyer Protection totals are buyer-facing, not seller proceeds. One candidate was already present and was not duplicated. Galaxy A15/A16 candidates were deferred because there are no matching master products. TEST: 215 active phone evidence / 121 active UK used sold; LIVE: 213 / 119; zero basic integrity failures and duplicate active keys in both. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-55.md`.


## Mobile phone catalogue — Batch 56 (24 October 2026)
Batch 56 reconciled the previously uncertain LIVE record for iPhone 14 128GB eBay item 366661027705 (£188.66) and added two Pixel 8 128GB completed sales: item 267790609007 (£159.95 including Buyer Protection; fee breakdown not captured) and item 188937928681 (£179.99; Good cosmetic condition, no accessories). All three records were confirmed active in both TEST and LIVE. Two iPhone 16 128GB candidates were already present and not duplicated. Post-batch counts: TEST 218 active phone evidence / 124 active UK used sold; LIVE 216 / 122. Duplicate active source-key groups: zero in both; the two-row environment difference remains. A further multi-row insert was blocked and was not counted as completed. Continue global key and URL preflight, TEST-first, then LIVE, and verify each write. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-56.md`.


## Mobile phone catalogue — Batch 57 (24 October 2026)
Added two verified UK eBay sales in TEST and LIVE: iPhone 15 128GB Black, 82% battery health, displayed £238.25 (item 407192517582); and Galaxy S22 128GB, displayed £80.00 (item 398437617494; Best Offer accepted, seller proceeds not independently confirmed, possible outlier). Existing iPhone 15 candidates were not duplicated. TEST: 220 active phone evidence / 126 active UK used sold; LIVE: 218 / 124. Both new rows were read-back verified in both environments. Full duplicate-key aggregate audit was blocked by tool safety checks this run, so only the new candidates' clean preflight is confirmed. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-57.md`.


## Mobile phone catalogue — Batch 58 (24 October 2026)
Batch 58 added iPhone 15 Pro 128GB Natural Titanium, immaculate with original box, eBay item 227530529279, sold 21 September 2026 at £402.08 displayed including £12.08 Buyer Protection. Exact URL/key preflight was clear; the row was inserted TEST-first then LIVE and read-back verified active in both. iPhone 15 Plus 128GB Blue item 800655157429 was already present in both environments and was not duplicated. TEST has 221 active phone evidence rows; LIVE has 219. Last confirmed UK used/sold counts remain TEST 126 and LIVE 124 because recount was blocked. Full duplicate-key aggregate audit was not completed. Continue global source-key and URL preflight, TEST-first writes, then LIVE writes, and verify each write. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-58.md`.


## Mobile phone catalogue — Batch 59 (24 October 2026)
Batch 59 added iPhone 15 Pro 128GB Black, eBay item 206515412317, sold 1 September 2026. The displayed £302.94 includes £10.34 Buyer Protection; seller proceeds are not independently confirmed. Exact URL and stable-key preflights were empty in TEST and LIVE. The row was inserted TEST-first, then LIVE, and read-back verified active in both. The iPhone 15 Plus Blue item 800655157429 was already present in both and was not duplicated. Active phone evidence counts: TEST 222, LIVE 220. Last confirmed UK used/sold counts remain TEST 126 and LIVE 124 because they were not refreshed. Full aggregate duplicate-key audit remains outstanding. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-59.md`.


## Mobile phone catalogue — Batch 60 (24 October 2026)
Batch 60 added two iPhone 15 Pro 128GB Black Titanium sold observations after URL/key preflight in both environments. Item 206070231627: £379.99 displayed including Buyer Protection; 90% battery health, fair/acceptable cosmetic condition with obvious wear, seller states fully tested/working, charger included. Separate read-back confirmed active in TEST and LIVE. Item 206112400829: £199.99 displayed including Buyer Protection; shattered rear glass and faulty non-genuine replacement screen, explicitly classified For parts or not working. TEST read-back succeeded; LIVE insert response confirmed the row but separate read-back was blocked. Counts: TEST 224 active phone evidence; LIVE 222. UK used/sold subtotals were not refreshed (last confirmed TEST 126 / LIVE 124). Full aggregate duplicate-key audit remains outstanding. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-60.md`.


## Mobile phone catalogue count refresh — 24 October 2026
Post-Batch-60 count refresh: TEST 224 active phone evidence / 130 active `uk_used` + `sold` rows; LIVE 222 / 128. The `uk_used` + `sold` filter includes the explicitly labelled parts/repair observation and must not be described as working-only. Two-row environment difference remains; full duplicate-key aggregate audit is outstanding.

Stable-key audit refresh (24 October 2026): no duplicate active non-null source-record-key groups were found across shared evidence in TEST or LIVE. Do not treat repeated generic catalogue URLs as duplicate evidence by themselves.


## Mobile phone catalogue — Batch 61 (24 October 2026)
Batch 61 added iPhone 15 Pro 128GB Black Titanium, eBay item 900018786339, sold 19 October 2026 at £404.50 displayed including £14.50 Buyer Protection. Listing title describes mint condition and 100% battery health; no charger included. Seller proceeds are unconfirmed. URL and stable-key preflights were clear; TEST-first then LIVE insertions and read-back were successful. Pixel 9 item 820179580133 was already present in both environments and was not duplicated. Counts: TEST 225 active phone evidence, LIVE 223; last refreshed active `uk_used` + `sold` counts remain TEST 130 / LIVE 128. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-61.md`.


## Mobile phone catalogue — Batch 62 (24 October 2026)
Batch 62 added Google Pixel 9 128GB Obsidian, eBay item 147349812276, sold 28 June 2026, displayed £243.42 including £8.42 Buyer Protection. Listing title describes acceptable condition, 99% battery health and warranty through 27 November 2027. Exact URL/key preflight, TEST-first then LIVE insertion, and read-back verification succeeded. Counts: TEST 226 active phone evidence, LIVE 224; active `uk_used` + `sold` subtotals not refreshed (last confirmed TEST 130 / LIVE 128). See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-62.md`.


## Mobile phone catalogue — Batch 63 (24 October 2026)
Batch 63 added a Google Pixel 9 128GB GrapheneOS UK eBay sold observation (item 267700928563, 15 July 2026, displayed £299.00). The listing describes cosmetic B condition with minor casing marks and small screen scratches. GrapheneOS is custom OS; do not mix with stock-OS price comparisons. URL/key preflight and stable-key read-back confirmed the record active in TEST and LIVE. Counts: TEST 227 active phone evidence / 133 `uk_used` + `sold`; LIVE 225 / 131. This subtotal includes parts/repair evidence. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-63.md`.


## Mobile phone catalogue — Batch 64 (24 October 2026)
Batch 64 added Google Pixel 9 128GB Obsidian eBay item 407029495464, sold 29 June 2026 at displayed £272.00. Listing says unlocked and “Great” condition. Seller is based in London, but the listing showed international postage; treat as UK eBay seller evidence, not confirmed UK-destination evidence. Buyer Protection and seller net proceeds were not confirmed. URL/key preflight and stable-key read-back verified active in both TEST and LIVE. Counts: TEST 228 active phone evidence / 134 `uk_used` + `sold`; LIVE 226 / 132. The latter subtotal includes parts/repair observations. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-64.md`.


## Mobile phone catalogue — Batch 65 (24 October 2026)
Batch 65 added two iPhone 15 128GB parts/repair completed-sale records: Black item 267734454669 at £192.00 displayed and Blue item 267749501196 at £157.00 displayed. Both prices include Buyer Protection; seller proceeds and fee breakdown are not confirmed. Both listings explicitly state parts/not working. Exact URL/key preflight was empty in TEST and LIVE; rows were inserted TEST-first, then LIVE, and read-back verified active in both. The Samsung Galaxy S24 item 257702271643 was already present and not duplicated. Counts: TEST 230 active phone evidence / 136 active uk_used + sold; LIVE 228 / 134. Three intervening Pixel 9 rows and these two rows explain the five-row increase per environment since Batch 61. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-65.md`.


## Mobile phone catalogue — Batch 66 (24 October 2026)
Batch 66 added iPhone 15 Pro 128GB Blue Titanium UK eBay sale item 298501695479, sold 23 July 2026. Displayed £360.72 includes £11.41 Buyer Protection; listing says fully working, factory reset, original box but missing accessories, seven bids. Seller proceeds are not independently confirmed. URL/key preflight was empty in TEST and LIVE; inserted TEST-first then LIVE, with read-back verification in both. Counts: TEST 231 active phone evidence / 137 active uk_used + sold; LIVE 229 / 135. Used/sold totals include parts/repair rows. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-66.md`.


## Mobile phone catalogue — Batch 68 (24 October 2026)
Batch 68 added iPhone 15 Pro Max 256GB Natural Titanium, eBay item 128012606222, sold 8 August 2026 with three bids. Displayed £399.88 includes £14.29 Buyer Protection; seller proceeds unconfirmed. Listing title says Excellent condition but eBay condition field says Used. URL/key preflight was empty in both environments; inserted TEST-first then LIVE, with read-back verification in both. Counts: TEST 233 active phone evidence / 139 active uk_used + sold; LIVE 231 / 137. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-68.md`.


## Mobile phone catalogue — Batch 69 (24 October 2026)
Batch 69 added two iPhone 15 Pro Max 256GB completed sales: Grey with retail box, item 298621751352, displayed £444.64 including £12.78 Buyer Protection; and Silver, item 327278174330, displayed £439.66 including £12.70 Buyer Protection. The Silver listing says the seller relisted this item or one like it, so do not assume it represents a unique device. Seller proceeds are unconfirmed. URL/key preflight was empty; both rows were inserted TEST-first then LIVE and read-back verified in both. Counts: TEST 235 active phone evidence / 141 active uk_used + sold; LIVE 233 / 139. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-69.md`.


## Mobile phone catalogue — Batch 70 (24 October 2026)
Batch 70 added iPhone 15 Pro Max 256GB unlocked, item 298539408905, sold 4 August 2026. Two bids; displayed £463.08 includes £13.08 Buyer Protection. Listing says Used and unlocked; no additional condition details were confirmed. Seller proceeds are unconfirmed. URL/key preflight was empty in both environments; TEST-first and LIVE insertions were read-back verified. Counts: TEST 236 active phone evidence / 142 active uk_used + sold; LIVE 234 / 140. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-70.md`.


## Mobile phone catalogue — Batch 71 (24 October 2026)
Batch 71 added iPhone 16 Pro 256GB Desert Titanium, eBay item 820212891404, sold 8 October 2026, displayed £567.85 including £17.85 Buyer Protection. Best Offer was enabled; seller proceeds are unconfirmed. URL/key preflight was clear, TEST insert/read-back succeeded, then LIVE insert/read-back succeeded. Counts: TEST 237 active phone evidence / 143 active uk_used + sold; LIVE 235 / 141. Two-row difference persists; active duplicate non-null stable keys: 0 in each environment. See `CHECKPOINTS/2026-10-24-mobile-phone-catalogue-batch-71.md`.


## Mobile phone catalogue — Batch 72 (25 October 2026)
Batch 72 added iPhone 16 Pro Max 256GB Black eBay item 128132786202, sold 19 October 2026, displayed £527.16 including £14.13 Buyer Protection. The listing disclosed a replaced back; seller proceeds are unconfirmed. Exact URL/key preflight was clear, TEST insert/read-back succeeded, then LIVE insert/read-back succeeded. Derived counts from Batch 71 baseline: TEST 238 active phone evidence / 144 active uk_used + sold; LIVE 236 / 142. Full aggregate recount and broad duplicate-key audit remain outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-72.md`.


## Mobile phone catalogue — Batch 73 (25 October 2026)
Added three Samsung Galaxy S25 UK used/sold observations to TEST and LIVE: item 158245363724 (128GB Grey, £345 displayed including Buyer Protection), 206384194701 (256GB, £389.99 displayed, Best Offer accepted), and 128101722692 (128GB, £347.18 including £11.18 Buyer Protection, Best Offer accepted). Exact URL/key preflight was clear; TEST insert/read-back preceded LIVE, and all six records were verified. Direct Mobile Phones category counts: TEST 241 active evidence / 147 active uk_used+sold; LIVE 239 / 145. The two-row difference remains. Global duplicate-key aggregation is still outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-73.md`.


## Mobile phone catalogue — Batch 74 (25 October 2026)
Added Google Pixel 10 Pro 256GB Porcelain, eBay item 336731607825, sold 19 Aug 2026 at displayed £498.67 including £13.67 Buyer Protection. TEST and LIVE inserts/read-backs verified after clean URL/key preflight. Direct Mobile Phones counts: TEST 242 active evidence / 148 active uk_used+sold; LIVE 240 / 146. The two-row difference persists; global duplicate-key aggregation remains outstanding. See `CHECKPOINTS/2026-10-25-mobile-phone-catalogue-batch-74.md`.

## Batch 94 — 25 October 2026
One verified new-condition UK completed-sale observation added to the existing HONOR 600 Pro 512GB master in TEST and LIVE. The Batch 94 checkpoint and project-memory file contain the source, evidence IDs, exclusions and verification notes. No master products, valuation logic or schema changed. Re-run aggregate SQL counts before starting the next batch.


## Pokémon TCG collector catalogue — 2026-10-26 checkpoint

The collector catalogue has been started as an isolated dataset, not as ordinary customer-buying products. No changes were made to `calculate_buying_item_valuation(...)` or to the existing catalogue query functions.

Verified source baseline: `tcgdex/cards-database`, branch `master`, commit `cbddf7e54033b1b58e44af1049c88832e55b94d0`. The recursive Git tree returned 43,681 entries (43,199 blobs) and was not truncated. Its inventory contains 40,658 individual numbered card-file paths across international and Asian-language data directories; this is a file count, not a count of unique cards or printings.

The first set, Base Set (`base1`), has been loaded into both TradeFlow TEST (Supabase project `nnsshnfkjcflucjrftzi`) and LIVE (project `gxsrajtqzdjvmceqcpgv`). Verification on both environments: official expected count 102; imported records 102; unique collector numbers 102; missing English names 0. Set status is `reconciled`. Card rows retain source paths, blob SHAs, source commit, and original source record text in `source_payload`. No card prices were researched or imported.

Collector-specific tables created in both environments: `pokemon_tcg_categories`, `pokemon_tcg_sets`, `pokemon_tcg_cards`, and `pokemon_tcg_card_variants`. RLS is enabled on all four tables and no end-user policies have been added, so these records are not exposed through the ordinary customer catalogue. The current seed is only one category, one set and 102 cards; it is not the full Pokémon catalogue. Do not claim overall completion or import other sets until they are retrieved and reconciled.

Next: implement a reproducible bulk importer for the remaining source families and set metadata; preserve language and distinct printing/variant identity; reconcile set-level expected counts and duplicates; validate RLS and ensure the standard buying catalogue and valuation flow cannot return collector-only rows. Use TEST for verification before subsequent LIVE additions. Keep the TCGdex attribution/licence notice with any distributed dataset and do not submit AI-generated data to the source project.


## Pokémon TCG full-detail enrichment — 26 October 2026

A read-only LIVE audit found 23,604 English-language card rows with null `card_category`. Their `source_payload` identifies them as TCGdex set-summary records; it does not contain a category. Do not infer category from a card name.

A reproducible standalone batch script was added on `main`: `scripts/pokemon-tcg-enrich-details.mjs` (commit `78f3f811b127b0974e499a0b5b787ee808a41579`). It uses the existing `source_payload.summary.id` to retrieve the full TCGdex card record and accepts only the documented categories `Pokemon`, `Trainer`, or `Energy`. On write, it updates only rows whose `card_category` is still null and merges the retrieved detail into `source_payload`; it does not touch the ordinary product catalogue, valuation logic, variants, tenants, or customer data.

**Safety and current status:** dry-run is the default; `--write` is required to update rows. The script has not yet been executed or runtime-verified. Run a small dry-run and then a small TEST write first, verify category values and preserved source payload, then scale in batches. Do not run against LIVE until TEST batch results have been verified. Supply `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` through the secure runtime environment; never commit credentials. The batch size is limited to 250 per run.


## LIVE category reconciliation batch — 26 October 2026

A small, TEST-first reconciliation was completed for 57 English card rows whose LIVE category was blank. Their exact `card_key` and card name matched TEST records already marked `source_parsed`; the category `Pokemon` was copied only for these matching records. This comprised 12 cards from key family `2011bw`, 20 from `2012bw` / `2014xy`, and 25 from `2014xy` / `2015xy` / `2016xy`. All 57 LIVE updates returned the expected card keys and `Pokemon` category. A separate read-back confirmed representative records from each group.

LIVE English unclassified count decreased from 23,604 to 23,547. No source payload details were added in this batch; the standalone API enrichment script has still not been runtime-tested. Continue with exact TEST-to-LIVE key/name/category reconciliation in bounded batches, and separately complete full-detail payload enrichment when a secure runtime is available. Do not infer categories from names.


## Mobile-phone catalogue evidence operating rules — 30 October 2026

The product catalogue evidence stream is separate from product-master creation and valuation logic. Use the dedicated catalogue addendum and dated batch checkpoints for the current per-product evidence state.

**Evidence acceptance:** match manufacturer + exact model + exact storage/package variant; require a UK source, GBP price, working listing URL, explicit condition, sales channel and unique source record key. Store resale asking prices as `evidence_type='uk_used'` with `availability='listed'`. Store completed sales separately with `availability='sold'` only when the listing is genuinely confirmed sold. Do not convert trade-in/buyback/recycling quotes into used-market prices. Do not mix new prices, overseas listings, wrong storage variants, out-of-stock pages or future/unverified models into current used asking-price evidence.

**TEST/LIVE sequence:** re-query both databases before every batch. Resolve the correct local `catalogue_master_products.id` in TEST and LIVE independently. Preflight `(source_name, source_record_key)`, insert and read back TEST, then insert and read back LIVE. Never reuse a TEST product ID in LIVE. Do not alter customer, tenant, ownership or transaction data. Do not create master products or change lifecycle/visibility/valuation settings as part of evidence ingestion.

**Quality control:** direct-source checks take priority over snippets. Record source, condition and delivery/Buyer Protection caveats. Reject questionable seller/location/variant matches and anomalous used prices above the new retail price rather than using them to reduce missing counts. An out-of-stock refurb page is historical context, not an active listed asking price. A database insert is not complete until its returned row and subsequent read-back are verified in both environments.

Latest verified Batch 96 database position (30 October 2026): TEST 160 mobile masters / 159 active / 156 visible / 276 active UK-used rows; LIVE 156 mobile masters / 156 active / 154 visible / 274 active UK-used rows. Active products with any active UK-used evidence: TEST 154/159; LIVE 152/156. Re-query before the next batch; these values replace earlier mobile-catalogue snapshots.

## Mobile-phone catalogue — Batch 97 exception sweep, 30 October 2026

Rechecked all currently active missing-UK-used-evidence products in TEST and LIVE. This is a nine-environment-record sweep (five TEST gaps, four LIVE gaps; four shared products), rather than a full ten because only nine active environment gaps remain. No evidence inserts were made: every candidate failed at least one acceptance criterion.

- Apple iPhone 18 256GB (TEST only, hidden): the base iPhone 18 is not released; current reporting says spring 2027. No used-market listing exists to accept.
- Motorola Edge 70 Plus 256GB (TEST + LIVE): surfaced exact-variant offers were new/sealed, including a UK version; not used/refurbished.
- OPPO Find X10 256GB (TEST + LIVE, hidden): surfaced exact-variant UK listings were new; no qualifying used listing.
- OPPO Find X10 Pro Max 512GB (TEST + LIVE): eBay UK search surfaced seller newdays4u at £1,047.67/£1,073.08, but the direct search detail labels the listing “Opened – never used”; seller had 100% positive feedback from 15 feedback entries. Excluded because the requested evidence requires used/refurbished condition. Other offers were new/sealed or seller/location/condition could not be independently established.
- OPPO Reno16 F 5G 256GB (TEST + LIVE): eBay UK exact-variant offers were explicitly new/sealed (e.g. £439.99); excluded.

No database changes were made. Fresh current totals: TEST 160 mobile masters, 159 active, 156 visible, 541 active evidence rows, 274 active uk_used rows, 79 listed uk_used; LIVE 156, 156, 154, 535, 272, 79 respectively. Products with active uk_used evidence: TEST 154/159; LIVE 152/156. Remaining active gaps: TEST 5 (4 visible), LIVE 4 (3 visible). Evidence row totals decreased by two in each environment since the Batch 96 snapshot, but coverage counts and listed-used totals did not change; this appears to be concurrent evidence maintenance, not an action in Batch 97.

Source references checked: eBay UK search/listing pages for Motorola Edge 70 Plus, OPPO Find X10, OPPO Find X10 Pro Max and OPPO Reno16 F; official OPPO UK series hub and model details; Tech Advisor iPhone 18 release timeline. No source was promoted into Supabase because none met all evidence criteria.


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


## Catalogue evidence operating note — 2 November 2026
Retro console records must distinguish original hardware from later mini re-releases (for example, original Super Nintendo Entertainment System versus Super Nintendo Classic Mini). Check LIVE and TEST independently before insertion, preserve environment-specific UUIDs, use UK GBP sources only, and classify retailer asking prices as `availability=listed` rather than completed sales. Catalogue evidence remains reference-only and must not change automatic buying valuations. Database-only catalogue changes do not require Cloudflare Worker deployments.


## Xbox storage catalogue correction — 2 November 2026
TEST and LIVE each contain WD_BLACK C50 512GB and 1TB, Seagate 1TB, and SanDisk Optimus GX C50 2TB. The initial unsupported generic-page evidence rows were deactivated. Active UK GBP new/listed evidence now uses Argos for Seagate 1TB (£149.99) and WD_BLACK C50 1TB (£153.99), and Idealo UK for SanDisk 2TB (£249.99 offer). WD_BLACK 512GB has no active price evidence pending a verified UK retailer listing. Evidence remains reference-only and does not feed automatic buying valuations. No code or deployment changes were made. Maintain separate TEST and LIVE UUIDs.


## Xbox official accessories catalogue — 2 November 2026
TEST and LIVE each now contain three additional Microsoft Xbox master products: Xbox Nano Controller (£44.99; pre-order with stated 4 November 2026 release), Xbox Adaptive Joystick (£24.99), and Xbox Elite Wireless Controller Series 2 Complete Component Pack (£54.99). Evidence is UK-only, GBP, new/listed retail evidence from Microsoft Store UK. Products are active and customer-visible in both environments. Evidence remains research reference only and does not alter automatic buying valuations. TEST and LIVE records use separate environment-specific UUIDs. No app code, Worker deployment, Stripe, tenant, customer, transaction or payment data changed. Do not add used-price evidence without a verified UK used-market listing; do not treat pre-order as in-stock stock.


## Gaming catalogue update — 3 November 2026
Four Xbox accessory products were added and independently verified in both TEST and LIVE: Venom Twin Rechargeable Battery Packs (£12.99 Argos), Venom Twin Docking & Charging Station (£17.99 Argos), PowerA Wired Controller - Core Black (£19.99 Argos), and Turtle Beach Recon 70 Wired Multiplatform Gaming Headset - Black (£22.99 Smyths Toys). All are active/customer-visible and have active UK-new GBP retailer evidence with availability `listed`. Treat these as current asking/listed prices, not completed sales. No used evidence was inferred. Keep TEST and LIVE product/evidence UUIDs separate. Evidence is reference-only and must not change automatic buying valuations. No app code, deployment, Stripe, tenant, customer, transaction or payment data was changed.



## Gaming catalogue update — Xbox accessories, 3 November 2026
Four additional Xbox products have been added and independently verified in TEST and LIVE: PowerA Hall Effect Advantage+ controllers in Green (£32.99) and Ruby (£32.99), PowerA Dual Charging Station for Xbox Controllers - Black (£9.99), and Turtle Beach Rematch Core Xbox & PC Wired Hall-Effect Controller - Black (£19.99). All have active customer-visible master records and active UK-new GBP retailer evidence with `availability=listed`. Source pages are exact Argos product pages. Treat prices as current retailer asking/listed prices, not completed sales. Do not infer used prices. Maintain separate environment-specific UUIDs. Evidence is reference-only and must not alter automatic buying valuations. No app code, deployment, Stripe, tenant, customer, transaction or payment data changed.


## Xbox controller variant batch — 3 November 2026
TEST additions: Turtle Beach Rematch Core Camo Green (£24.99 Argos), PowerA Advantage Fire Red (£32.99 Argos), and Hyperkin The Competitor Silver (£39.99 Argos). All are active/customer-visible with active UK-new GBP listed evidence. LIVE: only Turtle Beach Rematch Core Camo Green (£24.99) was successfully added and verified. Attempts to insert the PowerA Fire Red and Hyperkin Silver LIVE records were blocked by the tool safety layer; do not treat them as deployed or mirrored. Hyperkin manufacturer was created independently in both environments. Keep the outstanding LIVE promotion explicit and verify before retrying. These are retailer asking/listed prices, not completed sales; evidence is reference-only and must not affect automatic valuations. No code, deployment, Stripe or operational customer data changed.


## Xbox controller variant batch — LIVE reconciliation completed — 3 November 2026
The earlier partial promotion is now reconciled: TEST and LIVE both contain Turtle Beach Rematch Core Camo Green (£24.99 Argos), PowerA Advantage Xbox Series X|S Wired Controller - Fire Red (£32.99 Argos), and Hyperkin The Competitor Xbox and PC Wired Controller - Silver (£39.99 Argos). Final queries in both environments confirmed active, customer-visible product records and active `uk_new` GBP evidence with `availability=listed`. Product/evidence UUIDs are separate per environment. Note the minor title punctuation difference for Hyperkin (`and` in LIVE versus `&` in TEST); it is the same Silver variant. These are retailer asking/listed prices, not completed sales. Evidence is reference-only and must not affect automatic valuations. No application code, deployment, Stripe or operational customer data changed.


## Xbox controller colour variants — 3 November 2026
Added and verified in both TEST and LIVE: PowerA Advantage Xbox Wired Controller - Ice White (£32.99 Argos, https://www.argos.co.uk/product/7862461/) and Hyperkin The Competitor Xbox & PC Wired Controller - Purple (£39.99 Argos, https://www.argos.co.uk/product/7995589). Each has an active customer-visible master product and active `uk_new` GBP evidence marked `listed`. Environment-specific product/evidence IDs are recorded in `PROJECT-MEMORY/2026-11-02-gaming-console-catalogue.md`. Exact duplicate checks were performed before insertion. These are retailer asking/listed prices, not completed sales; evidence is reference-only and must not affect automatic valuations. No code, deployment, Stripe or operational customer data changed.


## Turtle Beach Recon 70 headset variants — 3 November 2026
Added and verified in both TEST and LIVE: Recon 70 White (£22.99 Smyths UK) and Recon 70 Arctic Camo (£29.99 Smyths UK). Both have active customer-visible master records and active `uk_new` GBP evidence marked `listed`. Exact source URLs and environment-specific IDs are recorded in `PROJECT-MEMORY/2026-11-02-gaming-console-catalogue.md`. Duplicate checks were performed in both environments. Prices are retailer listing prices, not completed sales. Evidence is reference-only and must not affect automatic valuations. No application code, deployment, Stripe or operational customer data changed.


## Turtle Beach Recon 50X headset — 3 November 2026
Added to TEST and LIVE: Turtle Beach Recon 50X Xbox, PS5, PS4, PC Headset - Black and Green, £14.99 at Argos UK (was £19.99), exact page https://www.argos.co.uk/product/4506696/. Both environments received separate product/evidence IDs. Product active/customer-visible; evidence active `uk_new`, GBP, New, Retail and `listed`. Duplicate checks were clear. Treat this as a retailer asking/listed price, not a completed sale. Evidence is reference-only and must not affect automatic valuations. No application code, deployment, Stripe or operational customer data changed.


## Xbox headset and controller additions — 3 November 2026
Added and verified in TEST and LIVE: Turtle Beach Recon 70 Green Camo headset (£19.99 Smyths UK) and Turtle Beach Rematch Core Hall-Effect Controller Camo Orange (£24.99 Argos). Both have active customer-visible master records and active `uk_new` GBP evidence marked `listed`. Exact source URLs and environment-specific IDs are recorded in the gaming catalogue project memory. Duplicate checks were clear in both environments. Treat prices as retailer listed/asking prices, not completed sales. Evidence is reference-only and must not affect automatic valuations. No application code, deployment, Stripe or operational customer data changed.


## Xbox catalogue continuation — 4 November 2026
Added and verified in both TEST and LIVE: Turtle Beach Stealth 600X Gen 3 Wireless Multiplatform Gaming Headset for Xbox - Black (£69.99, Smyths UK) and Turtle Beach Rematch Core Wired Xbox, PC Controller - Orange (£19.99, Argos UK). Both have active customer-visible master product records and active UK-new GBP evidence marked `listed`. Exact retailer URLs and environment-specific IDs are recorded in `PROJECT-MEMORY/2026-11-02-gaming-console-catalogue.md`. Duplicate checks were clear in both environments. Prices are retailer asking/listed prices, not completed sales; evidence remains reference-only and must not affect automatic valuations. No application code, deployment, Stripe or operational customer data changed.


## 1B. 3D printer catalogue operating checkpoint — 4 November 2026

The 3D printer master catalogue is being expanded as data-only catalogue work. Current verified TEST and LIVE snapshot: category **3D Printers & Equipment**, existing branches **3D Printers** and **3D Printer Equipment & Accessories**, 72 active customer-visible products across seven manufacturers, and 85 active UK GBP evidence rows (74 `uk_new`, 11 `uk_used`). Both environments independently pass the current evidence/branch integrity checks.

### Mandatory continuation procedure

1. Read the current 3D printer project-memory and checkpoint files before adding more models.
2. Inspect both TEST and LIVE separately. Do not assume matching UUIDs or copy TEST IDs into LIVE.
3. Reuse the existing category and the two existing branches. The equipment/accessories branch is reserved for actual accessories and currently has no products.
4. Keep standard printers and package variants separate. AMS, AMS Lite, AMS 2 Pro, multi-colour systems, wash/cure bundles and enclosure packages must not share one evidence row when the contents differ.
5. Research exact model names and manufacturer specifications first; then collect UK-only GBP evidence. Use retailer listings for new prices and exact UK-located used listings/completed sales for used prices.
6. Record source URL, date, availability, item condition, price, stable source_record_key and buyer-protection caveats. A current asking listing is not a completed sale.
7. Used-market evidence is reference-only and must not be used to overwrite or calculate automatic buying valuations.
8. After each material data batch, verify TEST and LIVE product/evidence totals, active evidence coverage, GBP/source URL integrity and non-null branch assignments. Update both manuals plus the relevant project-memory and checkpoint files.

No new condition system is required for 3D printers. Use the established TradeFlow condition and product/package model; the Pokémon TCG-specific condition detail remains an exception for trading cards only. The full first-batch IDs and evidence mapping are in the 4 November 2026 3D printer checkpoint.


### Bambu Lab expansion — 4 November 2026

The latest independently verified snapshot is 39 products and 85 active UK GBP evidence rows (36 new, 11 used) in each environment. Batch 2 added 14 Bambu Lab model/package records: A2L, A2L Combo, H2D standard, H2D AMS 2 Pro Combo, H2D Engineering Bundle, H2D More Colour Bundle, H2D 10W and 40W Laser Full Combos, H2D Pro, H2C Vortek AMS 2 Pro Combo, H2S standard, H2S AMS 2 Pro Combo, H2S 10W Laser Combo and P1P legacy standard. The A2L standard evidence is marked backorder; P1P has used-only evidence. Keep all package variants separate and do not infer new pricing for legacy products.


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

Current verified TEST/LIVE snapshot: 72 active customer-visible products, seven manufacturers, 85 active UK GBP evidence rows (74 new, 11 used). Both environments have zero visible products without active evidence, zero null branch assignments, and zero evidence integrity failures.

Additional model coverage now includes Creality Ender-3 V3 SE, Ender-5 Max, K1 Max and K2/K2 Plus/K2 Pro/K2 SE standard and CFS bundles; Anycubic Kobra S1, S1 Max and Kobra 3 Max V2 package variants plus Photon Mono M7 family, Mono 4 and P1 Max; and QIDI Max4, Plus5, Q2, Q2C and Plus4. The QIDI Plus4 used sale evidence is present in both environments. Continue to reuse the same two branches and exact package variants. Do not invent extra branches or condition systems.


### Sega legacy-console coverage extension — 4 November 2026

The Sega home-console catalogue was extended and independently checked in TEST and LIVE. The current Sega manufacturer scope has **17 active customer-visible product records and 22 active UK-used GBP evidence rows** in each environment. All 17 visible products have active evidence; the Sega evidence scope has zero malformed active rows. TEST and LIVE use separate product/evidence UUIDs.

This continuation confirms the following distinct systems and current evidence:
- **Sega SG-1000** — existing active evidence £449.00, eBay UK item 168355445875, boxed/complete and seller-described as fully working: https://www.ebay.co.uk/itm/168355445875. TEST product 4812bf9a-c2e7-4816-b1c8-b7476c299347; LIVE product a3a44c72-5b00-4376-8f4c-d9eb7e9b44ec. Existing active evidence remains TEST 9150ba6d-37ed-41c2-b702-465fb4b59bbf / LIVE 330d3837-300d-41d4-9f24-1a3c2ec34d15.
- **Sega Mark III** — additional active evidence £225.81, eBay UK product/listing page 11023766971, boxed NTSC-J system described as tested and working with cosmetic wear: https://www.ebay.co.uk/p/11023766971. TEST product f6365657-eab9-4003-b45a-c78aa940b8eb / evidence 8c089af3-5df9-4b60-ba2d-ae736b904412; LIVE product 3917a14e-a664-4aec-8b93-00d023858e9b / evidence 5ec96c9e-2ee4-4fc4-86a7-3e097823f834. Existing distinct listing evidence at £173.80 (item 318928337003) remains active.
- **Sega Pico** — additional active evidence £155.58, eBay UK item 307172144334, UK private-seller auction with two games and cables/adaptors, condition stated Very Good: https://www.ebay.co.uk/itm/307172144334. TEST product e2ce884b-2f6f-4e0b-858b-985ee32758a3 / evidence 10a432ed-c288-408a-983e-4dad2fac8028; LIVE product 4d50ecbf-ad3a-4519-8ff2-6d38d0a6e51a / evidence 79ec6b4f-0fa5-4ede-85fe-ced960b982c5. Existing distinct listing evidence at £155.58 (item 307149542948) remains active.

All three product records were already present in both environments when this evidence pass was completed; no duplicate master products were created. A duplicate SG-1000 evidence row for the same £449 listing was identified and deactivated, retaining the pre-existing active row: TEST duplicate evidence 1e031e68-8092-4813-8dba-03c38a8f1b9a; LIVE duplicate evidence a48731eb-e515-4817-aef5-d58e56ca9b91. Do not reactivate these duplicate rows.

The “Master System Plus” label is treated as a bundle/retail package, not a separate console generation. SG-1000 II remains a separate research candidate but was not added in this pass because the surfaced UK listing did not expose a verified direct item URL. Prices above are asking/listing prices, not completed sales. All evidence is reference-only and does not alter automatic valuation. No application code, valuation logic, tenant/customer/transaction/payment data, Stripe configuration or deployment was changed.


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


### Prusa 3D printer catalogue — Batch 11 — 5 November 2026
Added Original Prusa SL1S SPEED (£1,999; printer-only option, CW1S bundle excluded) and Prusa Pro HT90 (£10,600; backordered) in TEST and LIVE, each with UK GBP new-price evidence. Sources: https://www.fabinity.com/product/original-prusa-sl1s-speed-3d-printer-cw1s-bundle and https://www.123-3d.co.uk/products/prusa-pro-ht90-3d-printer. TEST product IDs 8d7c7b10-8f01-4d3e-a101-000000000401/402 and evidence IDs 8d7c7b10-8f01-4d3e-a101-000000000411/412. LIVE product IDs 9d7c7b10-8f01-4d3e-a101-000000000401/402 and evidence IDs 9d7c7b10-8f01-4d3e-a101-000000000411/412. Both environments independently verified at 147 active visible products, 161 active evidence (146 UK-new / 15 UK-used), 13 manufacturers, with no integrity exceptions. No Worker deployment or application/schema/valuation changes. Used evidence remains reference-only.


## 2026-11-05 Switch 2 controller batch 4
Added 11 PowerA, Turtle Beach and GXTrust controller editions with UK-new GBP evidence in both LIVE and TEST. Sources: Argos and Currys UK Switch 2 controller listings. Branch totals now 43 active visible products and 46 active evidence rows (44 UK-new, 2 UK-used), with no visible product missing active evidence. The new rows match across environments. Retail prices are asking prices, not completed sales. Used evidence remains reference-only and excluded from automatic valuation. No deployment, schema, code, valuation, tenant or transaction changes. UUID checkpoint: CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-04.md.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 5
Added two further confirmed Switch 2-compatible controllers to both LIVE and TEST, with active UK-new GBP evidence:
- Freaks and Geeks Wireless Controller — Dragon Blossom, £29.99 at Argos. Argos confirms compatibility with Switch 2, original Switch, Switch OLED and PC; EAN 3701625906025. Brand/manufacturer record added as Freaks and Geeks (Trade Invaders).
- DragonShock FIFA WorldCup 26 AURORA+ Wireless Controller — England, £44.99 at Argos. The Argos EAN 5061111810167 is identified by DragonShock's distributor catalogue as the AURORA+ England Switch 2 model; added under manufacturer DragonShock, not FIFA.
Sources: https://www.argos.co.uk/product/8535508 ; https://www.argos.co.uk/product/8384467 ; https://cld.eu/en/publisher/dragonshock .

Nintendo Controllers branch totals in both environments: 45 active customer-visible products, 48 active evidence rows, and zero visible products without active evidence. The new records are matched between LIVE and TEST by model, package key, source and price. No Worker deployment, schema/application/valuation changes, or tenant/transaction data changes. Used evidence remains reference-only and excluded from automatic valuation. Exact IDs are recorded in CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-05.md.


### Creality Ender-3 V3 Neo and Mega — 3D printer catalogue Batch 12 — 5 November 2026
Added two distinct Creality models in TEST and LIVE with UK GBP new-price evidence. Ender-3 V3 Neo: £199, Creality UK listing marks the standard printer option in stock; optional Neo Combo is excluded. Source https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer. Ender-3 V3 Mega: £519 from Creality UK Ender-series collection; standard printer only, CFS nano combo excluded; immediate dispatch/stock timing not confirmed. Source https://store.creality.com/uk/collections/ender-series-3d-printer. TEST product IDs a1b2c3d4-5e6f-4789-9012-000000000101/102; TEST evidence IDs a1b2c3d4-5e6f-4789-9012-000000000111/112. LIVE product IDs b2c3d4e5-6f70-489a-8123-000000000101/102; LIVE evidence IDs b2c3d4e5-6f70-489a-8123-000000000111/112. Independently verified both environments at 149 active visible products, 163 active evidence rows (148 UK-new / 15 UK-used), 13 manufacturers; zero missing evidence/branch, duplicate active source keys, missing URLs/keys, invalid prices/currency or UK-new condition mismatches. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment. Used evidence remains reference-only.


## 2026-11-05 Nintendo Switch 2 controller catalogue — Batch 6
Added five Nintendo-branded Switch 2 variants to LIVE and TEST with UK-new GBP evidence: Joy-Con 2 (L) Light Blue £41.99; Joy-Con 2 (R) Light Red £41.99; Joy-Con 2 Pair Light Purple/Light Green £64.95; Joy-Con 2 Pair Blue/Light Yellow £64.99; Pro Controller The Legend of Zelda 40th Anniversary Edition £74.99. Both environments now have 50 active visible Nintendo controller products and 53 active evidence rows (51 UK-new / 2 UK-used), with zero visible products missing active evidence. LIVE/TEST matched. No deployment, code/schema/valuation or tenant/transaction changes. Used evidence remains reference-only. Checkpoint: CHECKPOINTS/2026-11-05-gaming-controller-catalogue-batch-06.md.


### 3D printer catalogue reconciliation — parallel Creality resin entries
After Batch 12 verification, a further TEST read found active Creality HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) entries, each with active UK-new evidence. They are not in LIVE yet and were not part of Batch 12's 149/163 verified baseline. Current read: TEST 151 active visible products / 165 active evidence (150 UK-new / 15 UK-used); LIVE 149 / 163 (148 UK-new / 15 UK-used). Audit the exact TEST rows before mirroring; do not create duplicate TEST products. A duplicate Ender-3 V3 Neo row was found already inactive and hidden; keep it as audit history.


## 2026-11-05 reconciliation note — original Switch Joy-Con pairs
Two original Switch Joy-Con pairs (Purple & Orange and Neon Red & Blue, £59.99 each) were added to LIVE only with Argos UK-new evidence. TEST mirroring was blocked before completion. Current Nintendo Controllers branch totals: LIVE 52 active visible products / 55 active evidence; TEST 50 / 53. Both LIVE additions have evidence, but parity is not restored. Reconcile the two package keys in TEST or deactivate the LIVE-only entries before claiming full parity or continuing further original-Switch imports. Source: https://www.argos.co.uk/browse/technology/video-games-and-consoles/nintendo/nintendo-switch-controllers/c%3A812401/ .


### Original Switch Joy-Con parity restored — 5 November 2026
The two original Nintendo Switch Joy-Con pairs previously added to LIVE only have now been mirrored into TEST with separate environment-specific product and evidence IDs. Purple & Orange (£59.99): LIVE product f409f8d2-b33f-43e7-9653-10196e1c30ad, LIVE evidence 36baf450-c126-42dd-807c-a92b9a93f0c5; TEST product b6652973-4e6f-4aa5-8bfc-724aff468546, TEST evidence 8897ea0a-24df-4e04-87bd-d8b5d5df1b36. Neon Red & Blue (£59.99): LIVE product d4796c49-a994-4339-af61-48b0c35726f7, LIVE evidence 62ce8bb4-b068-4fa9-9454-7f7a5b11958b; TEST product 10a21c36-726e-4494-91a9-8a72642896a0, TEST evidence 32f5232f-589f-47be-83f9-9475c53b7105. Both use Argos UK-new GBP evidence and are separate from Switch 2 Joy-Con 2 variants. Rechecked using distinct product and evidence counts: LIVE 52 active customer-visible products / 55 active evidence; TEST 52 / 55; zero visible products missing active evidence in either environment. Original Switch branch parity is restored. No Worker deployment, application code, schema, valuation, tenant, customer, order or payment data changed.

### 2026-11-05 Nintendo controller catalogue Batch 7
Original Switch Joy-Con parity restored. Added seven more original Switch variants to LIVE and TEST with active UK-new GBP Argos evidence: Joy-Con Blue/Neon Yellow £59.99; Joy-Con Purple/Green £40.19; GameSir Nova Lite Space Purple, Pink and Grey £17.99 each; HORI Split Pad Pro Black £39.99; HORI Wired HORIPAD Turbo Zelda £22.99. GameSir manufacturer was added in both environments. Independently verified totals: LIVE 59 active visible products / 62 active evidence; TEST 59 / 62; zero visible products missing evidence. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-07.md. No Worker deployment or code/schema/valuation/tenant/transaction changes. Used evidence remains reference-only.


### 2026-11-05 original Nintendo Switch controller Batch 8 — PDP REALMz
Added PDP REALMz Wireless Shadow Space ARK (£15.99) and PDP REALMz Wired Tails Seaside Hill Zone (£7.99) to LIVE and TEST with active UK-new GBP Argos evidence. PDP manufacturer added in both environments. Independent totals: LIVE 61 active visible products / 64 active evidence; TEST 61 / 64; zero visible products missing active evidence. Checkpoint: CHECKPOINTS/2026-11-05-original-switch-controller-batch-08.md. No Worker deployment or application/schema/valuation/tenant/transaction changes.


### Reconciliation completed — Creality HALOT resin models — 5 November 2026
HALOT-X1 Neo (£199) and HALOT-X1 Max (£1,599) from parallel TEST catalogue work have now been mirrored to LIVE with printer-only UK-new evidence. Optional resin/wash-cure bundles excluded. TEST product UUIDs a17c7b10-8f01-4d3e-a101-000000000502/503; TEST evidence UUIDs a17c7b10-8f01-4d3e-a101-000000000512/513. LIVE product UUIDs c3d4e5f6-7081-49ab-9234-000000000502/503; LIVE evidence UUIDs c3d4e5f6-7081-49ab-9234-000000000512/513. Sources: https://store.creality.com/uk/products/halot-x1-neo-resin-3d-printer and https://store.creality.com/uk/products/halot-x1-max-resin-3d-printer. Current fulfilment is unconfirmed; delivery estimates on indexed pages are stale/past.

TEST and LIVE each now report 151 active customer-visible 3D printer products and 165 active evidence rows (150 uk_new / 15 uk_used). LIVE confirms both product and evidence rows. TEST integrity check: zero missing evidence/branches, duplicate active source keys, missing URLs/keys, invalid/non-GBP prices or uk_new condition mismatches. Earlier pending-sync note is superseded. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 9

Added four additional original Nintendo Switch-family compatible controllers independently to LIVE and TEST, each with active UK-new GBP Argos evidence:
- PowerA Enhanced Switch & PC Wireless Controller — Kirby: £24.99; https://www.argos.co.uk/product/7868290/.
- PowerA Enhanced Switch Wireless Controller — Mario Peek A Boo: £29.99 current promotional listing (was £39.99); https://www.argos.co.uk/product/7570289/.
- Turtle Beach Rematch Wireless Switch Controller — Mario Bricks: £49.99; https://www.argos.co.uk/product/7818848/.
- Turtle Beach Rematch Wireless Switch Controller — Donkey Kong: £49.99; https://www.argos.co.uk/product/7811089/.

Existing PowerA and Turtle Beach manufacturer rows were reused. All evidence is UK-new, GBP, New, listed and source-linked. Mario Bricks and Donkey Kong also work with Switch 2 (C Button unavailable), while retaining original Switch family compatibility. Used evidence remains reference-only and does not alter automatic valuation.

Independent verification in both environments: 65 active customer-visible Nintendo Controllers products; 68 active evidence rows; zero visible products missing evidence; zero active evidence integrity exceptions. LIVE and TEST product/evidence counts and package keys match. Exact environment-specific UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-09.md. Database-only change; no Worker deployment, code/schema/valuation or tenant/transaction changes.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 10

Added four further original Switch-family compatible products to LIVE and TEST with active UK-new GBP Argos evidence: CRKD Nitro Deck White (£34.99 current listing, was £49.99; Switch/OLED only), CRKD Nitro Deck Cuddle Team Leader Fortnite Edition (£49.99; Switch/OLED), PowerA Enhanced Wired Cosmic Purple (£19.99), and PowerA Enhanced Wired Green (£19.99). Existing CRKD and PowerA manufacturer rows were reused. Independent verification in both environments: 69 active visible Nintendo Controllers products / 72 active evidence rows; zero visible products missing evidence; zero active evidence integrity exceptions. LIVE and TEST match. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-10.md. No Worker deployment or application/schema/valuation/tenant/transaction changes. Used evidence remains reference-only.


### Creality catalogue reconciliation — three models, 5 November 2026
A parallel catalogue agent had already added canonical standard-package records for SPARKX i7 (£239), HALOT-MAGE S 14K (£439) and HALOT-R6 (£119) in both environments while a separate insertion was being prepared. The second, duplicate printer-only rows were therefore soft-deactivated and hidden; no canonical records were deleted. Canonical TEST product IDs: d51a8e10-7c21-4a91-9e01-000000000601/602/603; TEST evidence IDs: d51a8e10-7c21-4a91-9e01-000000000611/612/613. Canonical LIVE product IDs: e62b9f21-8d32-4ba2-8f12-000000000601/602/603; LIVE evidence IDs: e62b9f21-8d32-4ba2-8f12-000000000611/612/613. Inactive duplicate TEST IDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603 and evidence c7e4a901-6b32-4d8f-9a21-000000000611/612/613. Inactive duplicate LIVE IDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603 and evidence d8f5b012-7c43-4e9a-a321-000000000611/612/613.

Sources: SPARKX i7 single printer option £239 — https://store.creality.com/uk/products/sparkx-i7-3d-printer (Autofill/CFS/colour bundles excluded; fulfilment unconfirmed because indexed delivery estimate is stale); HALOT-MAGE S 14K standalone £439 — https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer (official page stated in stock, estimated delivery 2–6 Nov 2026); HALOT-R6 standalone £119 — https://store.creality.com/uk/products/halot-r6-resin-3d-printer (indexed delivery estimate stale; current fulfilment unconfirmed). Resin, filament and wash/cure bundles are excluded.

Verified after duplicate deactivation: TEST and LIVE each have 154 active customer-visible 3D printer products and 168 active evidence rows (153 uk_new / 15 uk_used), 13 manufacturers. Both environments have zero visible products missing active evidence, zero duplicate active source keys and zero invalid active evidence (missing URL/key, non-positive price or non-GBP currency). No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes; no Worker deployment. Used evidence remains reference-only and does not affect automatic valuation. Full record history: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-13.md.


### Creality K1 catalogue addition — 5 November 2026
Added standalone Creality K1 Speedy printer to both TEST and LIVE, recorded as model K1 / standard printer. UK official price observation £299.00; the product page and current UK collection show it sold out, so current availability is not claimed. It is not marked discontinued because the manufacturer has not explicitly stated that. Source: https://store.creality.com/uk/products/k1-speedy-3d-printer. TEST product f3a6c812-9d54-4eab-b432-000000000701, evidence f3a6c812-9d54-4eab-b432-000000000711; LIVE product a4b7d923-0e65-4fbc-c543-000000000701, evidence a4b7d923-0e65-4fbc-c543-000000000711. Independent TEST/LIVE totals now match at 155 active visible 3D printer products and 169 active evidence rows (154 UK-new / 15 UK-used). Detailed checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-14.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 11

Added three additional original Switch-compatible products to LIVE and TEST with active UK-new GBP Argos evidence: Konix Hello Kitty Wired Controller (£15.99; Switch/OLED/PC; Switch 1 only); CRKD NEO S Fortnite Festival Purple Wave (£44.99 promotional price, was £59.99; wireless with detachable five-fret attachment, Hall Effect sticks); and CRKD NEO S Peely Fortnite (£59.99; wireless with Hall Effect sticks and charging dock). New Konix manufacturer rows were created separately in both environments; existing CRKD rows reused. Duplicate preflight found no matching Konix/NEO S products. Independent verification: both environments now have 72 active visible Nintendo Controllers products / 75 active evidence rows, zero visible products missing evidence and zero active evidence integrity exceptions. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-11.md. No Worker deployment or application/schema/valuation/tenant/transaction changes; used evidence remains reference-only.


### Creality printer-only additions and parallel-record reconciliation — 5 November 2026
Three additional Creality models were brought into the active catalogue in TEST and LIVE using the existing `printer-only` product records rather than creating duplicate standard-package rows:
- SPARKX i7 — £239 for the i7 Single variant only. Autofill (£269), Nano Combo (£299), Color Combo (£339) and CFS Lite accessories are excluded. Source: https://store.creality.com/uk/products/sparkx-i7-3d-printer. The indexed delivery estimate is stale; current stock/dispatch is unconfirmed.
- HALOT-MAGE S 14K — £439 standalone printer; resin and wash/cure bundles excluded. Source: https://store.creality.com/uk/products/halot-mage-s-14k-resin-3d-printer. The page crawl was six days old and showed in stock with estimated delivery 2–6 November 2026.
- HALOT-R6 — £119 standalone printer; resin/accessories excluded. Source: https://store.creality.com/uk/products/halot-r6-resin-3d-printer. Page crawl was about one month old; current fulfilment is unconfirmed.

TEST product UUIDs: c7e4a901-6b32-4d8f-9a21-000000000601/602/603. TEST active evidence UUIDs: f73c9d20-9e43-4cb4-9a23-000000000611/612/613. LIVE product UUIDs: d8f5b012-7c43-4e9a-a321-000000000601/602/603. LIVE active evidence UUIDs: d8f5b012-7c43-4e9a-a321-000000000611/612/613. Both sets are printer-only records and were activated only after evidence was attached. Temporary duplicate `standard` package records created during the parallel write were deactivated/hidden and retained for audit; they are not customer-visible.

Post-change category verification: TEST has 154 active customer-visible products and 168 active evidence rows (153 UK-new / 15 UK-used); LIVE has 154 active customer-visible products and 169 active evidence rows (154 UK-new / 15 UK-used). Both environments returned no active customer-visible products without active evidence. The one-row active-evidence count difference remains to be reconciled; do not state that evidence totals are identical until that check is completed. Evidence remains UK-only and GBP-only; used-market evidence remains reference-only and must not affect automatic valuation. No schema/application/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment changes. No Worker deployment required.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 12

Added CRKD Nitro Deck+ Controller for Nintendo Switch — Black (£69.99 Argos) independently in LIVE and TEST with active UK-new GBP evidence. Compatible with standard Switch and OLED only, not Switch Lite or Switch 2. Duplicate preflight found no Nitro Deck+ product in either Nintendo Controllers branch; existing CRKD manufacturer rows reused. Independent verification: both environments now have 73 active visible products / 76 active evidence rows and zero visible products missing evidence. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-12.md. No Worker deployment or application/schema/valuation/tenant/transaction changes; used evidence remains reference-only.


### Creality HALOT-X1 standalone addition — 5 November 2026
Added the standalone HALOT-X1 resin printer to TEST and LIVE at £579 GBP, separate from HALOT-X1 Neo/Max and separate from the X1 Combo (£599) and All-in-One (£699) options. Official source: https://store.creality.com/uk/products/halot-x1-combo-resin-3d-priner-for-miniatures-and-terrain?country=GB&currency=GBP. Page states In Stock / UK local warehouse, but the estimated delivery 19–23 Oct 2026 is past; current dispatch should be reconfirmed. TEST product a9c8d034-1f76-40cd-8e65-000000000801, evidence a9c8d034-1f76-40cd-8e65-000000000811; LIVE product b0d9e145-2087-41de-9f76-000000000801, evidence b0d9e145-2087-41de-9f76-000000000811. TEST and LIVE independently verified at 156 active visible 3D printer products and 170 active evidence rows (155 UK-new / 15 UK-used), with zero visible products missing evidence, zero duplicate active source keys and zero invalid active evidence. Checkpoint: CHECKPOINTS/2026-11-05-3d-printer-catalogue-batch-15.md. No Worker deployment or application/schema/valuation/transaction changes. Used evidence remains reference-only.


### Follow-on Creality K1 SE and final parity correction — 5 November 2026
Added Creality K1 SE as a legacy printer-only catalogue record in both environments. Official Creality UK collection lists £229 and marks it Sold Out; this is historical UK-new price evidence only, not a current purchase offer. Source: https://store.creality.com/uk/collections/creality-could-3d-printers. TEST product/evidence UUIDs aa83d910-2f44-4b7a-9c31-000000000701/711; LIVE UUIDs bb94ea21-3a55-4c8b-8d42-000000000701/711. K1 SE remains a visible model reference, with sold-out availability explicitly recorded.

Final independent category verification after this addition: TEST and LIVE each have 157 active customer-visible products and 171 active evidence rows (156 UK-new / 15 UK-used). Both environments return zero active visible products without active evidence. The previously noted one-row evidence difference is resolved; product/evidence totals now match. All evidence remains UK GBP. Used-market evidence remains reference-only and does not affect automatic valuation. No Worker deployment or code/schema/valuation/transactional changes.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 13

Added two CRKD Gibson Les Paul Pro Edition guitar controllers independently to LIVE and TEST with active UK-new GBP Argos evidence: Alpine White Pro Edition (£119.99; Argos 978/7087; Switch 1, OLED and Switch 2) and Blueberry Burst Pro Edition (£119.99; Argos 778/1906; Switch 1 and OLED). Sources: https://www.argos.co.uk/product/9787087 and https://www.argos.co.uk/product/7781906. Duplicate preflight found no Gibson products in either Nintendo Controllers branch; existing CRKD manufacturer records reused. Exact environment-specific product/evidence IDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-13.md. Independent verification: LIVE 75 active visible products / 78 active evidence; TEST 75 / 78; zero visible products missing active evidence and zero invalid active evidence rows in either environment. No Worker deployment or application/schema/valuation/tenant/transaction changes. Used evidence remains reference-only.


## 2026-11-05 original Nintendo Switch controller catalogue — Batch 14

Added CRKD Gibson Les Paul Cherry Sunburst Pro Edition Collector Bundle Guitar Controller independently to LIVE and TEST with active UK-new GBP Argos evidence at £179.99 (was £199.99), Argos product 848/7292: https://www.argos.co.uk/product/8487292. Collector bundle includes Pro Mechanical Neck, Solo Mechanical Neck, branded guitar backpack, strap, pins, cable and stickers. Argos confirms Switch 1, OLED and Switch 2 compatibility. This is distinct from the Alpine White and Blueberry Burst Pro Edition standard listings. Duplicate preflight found no Cherry Sunburst product in either branch; CRKD manufacturer rows reused. Exact UUIDs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-14.md. Independent verification: LIVE and TEST each have 76 active visible products / 79 active evidence rows, zero visible products missing evidence and zero invalid active evidence. No Worker deployment or application/schema/valuation/tenant/transaction changes. Used evidence remains reference-only.


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


## Nintendo Controllers continuation — Batch 5 — 5 November 2026

### Completed

Added the following HORI products to the existing Nintendo Controllers branch in both TradeFlow environments:

| Product | EAN-13 | UK-new observations checked 5 November 2026 |
|---|---|---|
| Mario Kart Racing Wheel Pro Mini for Nintendo Switch 2 — Red | 4961818042445 | Smyths Toys UK £69.99; Argos £74.99 |
| Mario Kart Racing Wheel Pro Deluxe for Nintendo Switch 2 — Red & Black | 4961818042469 | Very £104.99; Argos £119.99 |

Each product has two active `uk_new` evidence rows, with source URLs, GBP currency, New condition, retailer name, observed_at timestamp and a stable source_record_key. Both products are active/customer-visible and have verified EAN identifiers. No used-market evidence was fabricated or added.

### Verified database position

Nintendo Controllers branch, independently checked in both projects:

- TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- 99 active products; 99 customer-visible.
- 102 active UK-new evidence rows, covering all 99 products.
- 2 active UK-used evidence rows, covering 2 products.
- Zero active visible products missing active evidence.
- Zero active visible products missing UK-new evidence.
- TEST and LIVE counts and new evidence records match.

The previous Batch 4 checkpoint reported 43 products / 46 evidence rows. The current database position supersedes that earlier snapshot; do not use the older count when resuming.

### Known item for later review

Two existing Nintendo controller products share the generic package_key `single-controller`. This predates Batch 5 and was not changed. It is a package-key collision, not yet proven to be duplicate product records. Inspect exact model/package identities and the historical insertion before deciding whether to change it. The two new HORI products use distinct product-specific keys.

### Next stopping point

Continue the Nintendo controller completeness audit for additional UK-sold Switch 2 controllers, racing-wheel/controller variants and remaining Nintendo controller families. Check product identity and existing package keys before every insert. Once Nintendo is reconciled, continue with PlayStation controllers, then Xbox controllers. Keep TEST and LIVE separate and apply each database-only batch independently to both.

No Worker deployment or application-code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment change was part of Batch 5.


## Nintendo controller continuation — additional products — 5 November 2026

Added independently to TEST and LIVE:
- Nintendo Switch 2 Pro Controller — Resident Evil Requiem Edition; EAN-13 0045496321840; Argos £69.99, Currys £74.99, Very £83.99 (three UK-new observations).
- Nintendo GameCube (GCN) Controller — Nintendo Classics; Nintendo Store UK £58.99 (one UK-new observation). Nintendo Switch 2 only and purchase restricted to Nintendo Switch Online members. Nintendo Store item ID recorded as a non-GTIN identifier.

Both products are active/customer-visible. All four new UK-new evidence rows are dated 5 November 2026 and have source URLs. Current verified Nintendo Controllers totals in both environments: 101 active/customer-visible products, 106 active UK-new evidence rows covering all 101 products, 2 UK-used reference rows covering 2 products, and zero active visible products missing any active or UK-new evidence.

The Grey and Neon Yellow/Neon Yellow original Joy-Con pair research remains open: official colour variants are confirmed, but current reliable UK new-retailer evidence was not sufficient to add them. Do not invent a current price or use stale listings as current evidence.

Next: finish the remaining Nintendo controller completeness audit, then move to PlayStation controllers and Xbox controllers. Database-only work; no Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.


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


## Nintendo Switch 2 controller accessories — Batch continuation — 5 November 2026

Added two official Nintendo Switch 2 controller accessories independently in TEST and LIVE:
1. Nintendo Switch 2 Joy-Con 2 Wheel Pair — light blue and light red wheel attachments, Joy-Con 2 controllers not included. Argos UK-new £16.99; https://www.argos.co.uk/product/7624661/. EAN-13 0045496321383 verified from Argos and recorded in TEST identifier data.
2. Nintendo Switch 2 Joy-Con 2 Charging Grip — black, USB charging cable and mappable GL/GR buttons, Joy-Con 2 controllers not included. Argos £29.99; https://www.argos.co.uk/product/7624692/; John Lewis £25.99; https://www.johnlewis.com/nintendo-joy-con-2-charging-grip-black/p113587848. EAN-13 0045496321376 recorded in TEST and LIVE identifier data.

Three active UK-new evidence rows per environment, GBP/New, with source URLs and observation date 5 November 2026. Both products active/customer-visible. Current verified totals in both environments: 103 active/customer-visible products; 109 UK-new evidence rows covering all 103 products; 2 UK-used reference rows covering 2 products; zero active visible products missing active evidence or UK-new evidence. This supersedes the 101/106 totals in the preceding addendum.

The wheel pair and charging grip are accessories rather than standalone electronic controllers; they are included here because Nintendo lists them within its Switch 2 controller/accessory range and they materially affect controller functionality. Keep the explicit compatibility notes: wheel pair only fits Joy-Con 2; charging grip only fits Joy-Con 2 and controllers are not included.

No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes. TEST and LIVE remain separate.


## PlayStation DualSense expansion — 5 November 2026
Added five DualSense colour variants independently in TEST and LIVE: Midnight Black £59.99, Starlight Blue £59.99, Cosmic Red £59.99, Nova Pink £59.99 and Chroma Teal £64.99. One active UK-new GBP/New Argos evidence row with direct product URL per model. Both environments now have 16 active/customer-visible PlayStation controller products and 15 UK-new evidence rows covering 15 products. The pre-existing Sony DualShock 3 Wireless Controller - Black is the one active product without UK-new evidence; leave unchanged for legacy/discontinued research rather than adding stale or fabricated pricing. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes.


## PlayStation batch 2 — 5 November 2026
Added DualSense Edge Midnight Black (£189.99 Argos), GTA VI Black Limited Edition (£74.99 pre-order), and GTA VI White Limited Edition (£74.99 pre-order) in TEST and LIVE. GTA VI editions release 19 November 2026. TEST verified: 19 products, 19 UK-new evidence rows covering 18 products; one older DualShock 3 remains without UK-new evidence. LIVE product count is 19; recheck evidence count before asserting exact parity. No deployment or code/schema changes.


## PlayStation batch 2 — 5 November 2026
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


## Xbox controller expansion — 5 November 2026

Added independently in TEST and LIVE under the existing Xbox Controllers branch:
- Xbox Wireless Controller - Ice Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Heart Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Storm Breaker Special Edition — Microsoft Store £64.99.
- Xbox Wireless Controller - Gears of War E-Day Limited Edition — Smyths £79.99; John Lewis £84.99; Microsoft Store £84.99.
- Xbox Wireless Controller - Forza Horizon 6 Limited Edition — Argos £69.99; Currys £84.99.

All 5 products are active/customer-visible. Each evidence row is active UK-new, GBP, New, Retail, dated 5 November 2026, with a direct retailer/product URL and stable source_record_key. Microsoft Breaker variants share the official Breaker-series product page, which exposes Ice Breaker, Heart Breaker and Storm Breaker as selectable configurations. Forza Horizon 6 release date 21 May 2026. Gears of War E-Day release date 29 September 2026; the Microsoft page still presents a pre-order CTA after that date, so availability is recorded as Listed rather than claiming in-stock.

Verified TEST and LIVE each: 20 active/customer-visible Xbox controller products; 23 active UK-new evidence rows covering all 20 products. No visible product in this branch is missing UK-new evidence. No Worker deployment or code/schema/valuation/RLS/Edge Function/tenant/customer/order/payment/Stripe changes. TEST and LIVE updated independently.


## Creality Ender-3 V3 Neo evidence and CFS nano combo — 5 November 2026

The existing Ender-3 V3 Neo standard printer record was confirmed in both environments and refreshed with the current official UK printer-only price £199.00. Added a distinct CFS nano four-colour Combo configuration at £289.00; official product page labels the combo as pre-order and includes a 2 kg filament promotion. Source: https://store.creality.com/uk/products/creality-ender-3-v3-neo-3d-printer. The official Creality UK comparison article (20 October 2026) distinguishes the Neo and Mega specifications and quotes Neo £199 / Mega £519: https://store.creality.com/uk/blogs/buying-guides/ender-3-v3-neo-vs-mega. Ender-3 V3 Mega was not added in this batch because current UK listing presents it as a promotional filament bundle from £519 and a clean printer-only / combo split was not sufficiently confirmed.

LIVE: existing Neo standard product b2c3d4e5-6f70-489a-8123-000000000101 refreshed evidence 4c43d533-c79d-48b0-ae4f-096bec842734 (£199); new CFS nano combo product 2c3eaeea-7828-4289-9e3b-5fb0eefd65c6 / evidence 2b52ae5c-d138-47b7-bade-9a8fe5c0d171 (£289).
TEST: existing Neo standard product a1b2c3d4-5e6f-4789-9012-000000000101 refreshed evidence 20fda591-e7d9-4102-8a3a-e8fbc141ad41 (£199); new CFS nano combo product e26954ad-9225-4195-9a18-757163eb8e64 / evidence 1fb1de2e-410e-4806-8311-e22c0a227dd7 (£289).

Verified totals after this addition: LIVE 186 products / 179 active visible / 206 active evidence / 191 UK-new; TEST 187 products / 179 active visible / 206 active evidence / 191 UK-new. Both environments have zero active visible products missing active evidence. No app code, schema, valuation, RLS, Edge Function, Worker, Stripe, tenant, customer, order or payment changes. No Worker deployment required.