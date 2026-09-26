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
**Version:** 4.3  
**Date:** 19 September 2026  
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
- Supabase project: `twfbmjwwqzxdxvclxbun`

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
