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
