# TradeFlow AI Operating Manual & Continuity Base

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
