# TradeFlow Subscriber Dashboard — Developer Diagnostic Roadmap

**Status:** Living roadmap  
**Date:** 18 September 2026  
**Purpose:** Map the subscriber business application shell without duplicating or replacing the existing backend workflows.

## 1. Product boundary

TradeFlow has four distinct layers:

1. TradeFlow SaaS marketing website.
2. Platform Owner administration.
3. Subscriber private business dashboard.
4. Subscriber customer-facing website.

This roadmap covers layer 3 only.

The subscriber dashboard is an application shell over the existing tenant-scoped backend. It must not become a second business-logic layer.

## 2. Current entry point

User action:
- Subscriber signs in and enters the business workspace.

Front-end entry:
- subscriber-dashboard.html
- subscriber-dashboard.css
- subscriber-auth.js
- subscriber-tenant-context.js

Authentication/data flow:
Subscriber Auth
→ Supabase Auth session
→ subscriber_get_my_memberships()
→ selected tenant membership
→ tenant_id / role
→ subscriber tenant context
→ existing workspace controller
→ tenant-scoped RPC/table/RLS
→ visible business result.

## 3. Existing operational destinations

The shell currently links to these real existing pages:

- buying-dashboard.html
- acquisition-dashboard.html
- inventory-dashboard.html
- selling-dashboard.html
- orders-dashboard.html
- fulfilment-dashboard.html
- returns-dashboard.html
- finance-dashboard.html
- categories.html
- website-builder.html

Do not invent replacement pages until the existing page/controller has been inspected.

## 4. Security boundary

Tenant boundary:
- public.tenants
- public.tenant_memberships
- authenticated subscriber session
- private.has_tenant_feature()
- private.require_tenant_feature()
- private.has_tenant_permission()
- private.has_tenant_role()
- tenant-scoped RLS policies

Tenant roles:
- owner
- admin
- staff

Platform Owner is separate and must never be introduced as a tenant role.

## 5. Subscription boundary

Authoritative objects:
- public.plans
- public.plan_features
- public.tenant_subscriptions
- private.has_tenant_feature()
- private.require_tenant_feature()

Current active plans:
- Basic
- Enhanced
- Catalogue

Catalogue is intentionally held back from operational subscriber rollout until Gemma can maintain/update the TradeFlow product catalogue. Do not remove the active Catalogue plan and do not seed catalogue data merely to make the UI appear complete.

## 6. Website Builder boundary

Existing entry:
- website-builder.html
- website-builder.js

Existing persistence:
- tenant_site_state
- site_revisions
- tenant_domains
- published_site_index
- publish_site_revision()
- get_published_site_preview()
- get_published_sites()

Do not replace the revision/publishing architecture while improving the shell.

## 7. Dashboard build sequence

Stage 1:
- common subscriber shell
- authentication loading order
- tenant identity
- navigation groups
- responsive layout
- dashboard entry page

Stage 2:
- real dashboard work queue
- authenticated live summary data
- needs-attention actions
- website status

Stage 3:
- apply common shell consistently to existing operational pages
- preserve each page's existing controller and backend calls

Stage 4:
- Website workspace
- genuine template layouts
- branding/content controls
- preview/publish/domain areas

Stage 5:
- feature-aware navigation
- staff, messaging, analytics, audit, integrations and market intelligence where entitled

## 8. Failure points to investigate first

1. Subscriber authentication promise does not load.
2. Tenant membership cannot be resolved.
3. URL tenant_id differs from authenticated tenant.
4. Workspace controller starts before subscriber tenant context.
5. Controller uses legacy customer/test-lab session state.
6. Feature gate rejects the tenant correctly.
7. Permission/RLS rejects an operation correctly.
8. Front-end navigation points to a nonexistent or placeholder destination.
9. Existing controller is broken independently of the shell.
10. Website Builder revision/publishing state becomes inconsistent.

Never weaken RLS or subscription enforcement to hide one of these failures.

## 9. Change-control rule

For every shell change:

Current GitHub main
→ relevant existing file
→ live Supabase object
→ smallest UI change
→ static/runtime test
→ representative authenticated browser test
→ verify no existing workflow regression
→ update System Handbook
→ update AI Operating Manual
→ update this roadmap/checkpoint.

Verification states remain:
**Proposed → Implemented → Tested → Verified Live.**

## 10. Current checkpoint

Stage 1 shell is implemented on branch subscriber-shell-stage1.

Changed:
- subscriber-dashboard.html
- subscriber-dashboard.css
- System Handbook
- AI Operating Manual

No Supabase schema, RLS policy, RPC, Edge Function or existing operational controller was changed.

Live browser verification remains open before merging this staging branch to main.

## Checkpoint — legacy test reset and subscriber UX update — 18 September 2026

### Security boundary
The Platform Owner account remains separate from subscriber tenant membership. The legacy test tenants were archived and their subscriptions cancelled. The Platform Owner Auth identity `leannelaurenlowe@hotmail.com` was retained. Future subscriber-approved maintenance access is a separate capability to design and audit; it is not implemented by granting Platform Owner normal tenant membership.

### Subscriber dashboard
The dashboard is now the clear private business entry point. It identifies the active business, signed-in email, tenant role and tenant ID, while retaining links to the existing operational workspaces. The dashboard shell does not create replacement controllers or duplicate backend workflows.

### Website templates
The builder now presents six starting layouts and persists the selected template in the existing `site_revisions.content.site.template` field. The public renderer reads that value and applies a matching visual layout. The six current templates are Business, Buy & Sell, Services, Editorial, Minimal and Retail.

### Test protocol
Do not use the archived test tenants for the new subscriber browser test. Create a new account through `subscriber-signup.html` using a selected current plan, then verify: signup → Auth account → `subscriber_create_business()` → tenant membership → subscription → subscriber dashboard → visible account identity. Only after that should the operational workspace links be tested.

**Current state:** database reset verified; dashboard/template implementation staged; live browser verification open.

## Workflow and website separation checkpoint — 18 September 2026

The subscriber dashboard is now structured around the operational chain: Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns. Website management is deliberately outside that chain.

The new `subscriber-website.html` page is a separate tenant-scoped website area that links into the existing Website Builder and public renderer. No website builder controls are required on the daily Business Dashboard.

The dedicated subscriber auth layer now hides protected page content until membership verification completes. A valid subscriber session is required before the dashboard or website-management area becomes usable.

**Next browser test:** create a fresh subscriber through the normal onboarding flow, confirm the new account reaches the Business Dashboard, verify the operational flow/navigation, then open Website → Website Builder and confirm the separate area works.

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

### User path
Subscriber Dashboard → Website → Website Builder → choose template → Business Details → Website Pages → Edit page → Preview → Save Draft → Publish.

### Template controller
- `website-builder.html` renders ten starting-template buttons.
- `website-builder.js` uses delegated template-button handling and persists the selected template in the existing website revision content.
- `website-builder.css` supplies the visual variants.

### Page controller
- `website-builder.html` renders the page index and editor host.
- `website-builder.js` renders each page editor from `pageDefinitions` and stores page title/body/SEO fields in `site.pages` inside the existing revision content.
- The public renderer in `public-site.js` builds navigation from enabled pages and renders a selected page from published content.

### Available page library
About us; Business Information; Contact; Terms & Conditions; Privacy Policy; Cookie Policy; Delivery & Returns; Sell to us; How it works; FAQ; Payments; Warranty & Guarantees; Complaints; Shop; Customer account.

### Data-flow note
Buying/Selling category behaviour remains one category row with capability flags. The builder guidance must not imply a second database category is automatically created.

### Additional controller hardening
`category-management.js` and `inventory-dashboard-fixed.js` now obtain the active tenant from the authenticated subscriber context instead of hardcoded test tenant maps. Browser verification must confirm a newly provisioned subscriber can open both linked areas without losing tenant isolation.

**Current state:** Implemented on main; browser verification required.


## Website Builder media/domain expansion — 18 September 2026

### Media path
Subscriber Dashboard → Website → Website Builder → Business Details / Website Pages → choose image → tenant-scoped Supabase Storage upload → media_assets metadata → image URL stored in website draft → Save Draft → Publish → public website renders the image.

The Storage bucket is tradeflow-site-media, with a tenant UUID as the first path segment. The bucket is public for published-site delivery; authenticated upload/update/delete policies require tenant website-management permissions. Supabase's current documentation confirms that public buckets expose file URLs publicly while write operations can remain protected by RLS policies. citeturn0search0turn0search1

### Selling-side branding
The shop page is now labelled Retail Shop in the builder and can contain subscriber-written introductory text and a page image. Published product cards remain supplied by get_published_store_listings().

### Domain path
Subscriber Dashboard → Website URL → enter hostname → tenant_domains pending record. Final automatic activation requires an agreed multi-subscriber hosting/DNS target and ownership verification. Once a domain is active, publish_site_revision() refreshes published_site_index, and public-site.js already resolves a site by hostname.

### Publication compatibility
publish_site_revision() now accepts schema versions 1 and 2 so the current builder's schema_version:2 content can be published without changing the existing draft/published architecture.

**Current state:** Implemented on main; browser verification required.


## Stage 1N — Visual Website Builder diagnostic checkpoint — 18 September 2026

User action → `subscriber-dashboard.html` → Website Management → `website-builder.html` → authenticated subscriber session/tenant context → `tenant_site_state` → current draft `site_revisions` → visual page editor → `site.branding`, `site.homepage`, `site.pages`, `site.theme`, `site.template` → tenant-scoped `tradeflow-site-media` Storage upload → `media_assets` metadata → Save Draft PATCH to current draft → Publish via `public.publish_site_revision()` → `published_site_index` / public website renderer.

Direct editing paths:
- Home page: site name, homepage headline, introduction and homepage image.
- Sell to us / Buying: page title, body and page image.
- Retail Shop: page title, body and page image; product listings remain supplied by Inventory → Selling.
- Other pages: page title, body and optional page image.
- Customer Account: TradeFlow-managed preview/portal boundary; not a normal editable content page.

Known failure points to test:
1. Subscriber authentication/tenant context missing.
2. Current draft revision missing or not tenant-scoped.
3. Storage policy rejects a tenant-scoped image upload.
4. `media_assets` metadata insert fails after a successful upload, leaving a possible orphaned object.
5. Draft save fails because the current revision is stale or inaccessible.
6. Publish fails at the existing website permission/RPC boundary.
7. Public renderer fails to load published content or product listings.
8. Custom domain remains pending until DNS/ownership/hosting routing is actually implemented.

**Verification state:** Code implemented on main. Browser verification remains open.

## Stage 1O — Premium homepage diagnostic checkpoint — 18 September 2026

User action → Website Builder → Home page → premium visual homepage → edit headline/introduction → edit buying/selling headings → select 6/8/10 tiles → edit tile copy → add/replace tile images → Save Draft → existing `site_revisions` draft content → Publish → public `public-site.html` renderer.

Homepage data path:
- `site.homepage.headline`
- `site.homepage.intro`
- `site.homepage.image_url`
- `site.homepage.tile_count`
- `site.homepage.buy_heading` / `buy_intro`
- `site.homepage.sell_heading` / `sell_intro`
- `site.homepage.tiles[]`

Selling tile content is presentation-only. Published product records continue to come from `get_published_store_listings()` and the Inventory → Selling workflow.

Verification required: confirm 6/8/10 tile selection, direct text editing, per-tile image upload, save, publish and public rendering for a real subscriber tenant.

## Stage 1P — Website Builder load entitlement repair — 18 September 2026

**Observed user action:** Subscriber opens Website Builder.

**Browser page:** website-builder.html.

**Frontend chain:** subscriber-auth.js → subscriber-tenant-context.js → website-builder.js → loadDraft().

**Failure point:** loadDraft() requests tenant_site_state and site_revisions. Their SELECT policies require tenant membership plus the website.editor feature.

**Root cause:** subscriber_create_business() created the new subscription as trialing without trial_end. The existing private.has_tenant_feature() capability rule requires trial_end to be in the future for a trialing subscription, so the authenticated subscriber could exist without receiving website capability.

**Repair:** Migration 065_repair_subscriber_trial_entitlement_window.sql sets a 30-day trial window for new subscriber onboarding and backfills the affected trialing record.

**Live database verification:** affected subscriber is an active tenant member; website.editor=true; website.publish=true.

**Expected flow after repair:** authenticated subscriber → tenant context → active website capability → tenant_site_state draft → site_revisions draft content → visual editor render.

**Final browser verification:** hard refresh Website Builder and confirm the stored draft renders in the canvas.


## Stage 1Q — Website Builder Home navigation repair — 18 September 2026

The Website Builder could render a stored page but leave the editor on About us, making the premium Home canvas difficult to reach. The navigation runtime has been hardened so page selection is explicit, the Home selection is represented as page=home in the Builder URL, and a requested page is accepted only when it matches a valid Builder page.

The runtime cache has been bumped to website-builder.js?v=12.

**Status:** Implemented in GitHub. Final browser verification: hard refresh the Builder, click **Home page** in the left Website Pages list, then confirm the premium homepage canvas appears and can be edited.
