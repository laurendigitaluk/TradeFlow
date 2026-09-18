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
