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


## Stage 1R — Website branding and business extras — 18 September 2026

**Builder controls:** website-builder.html → design-controls / business-extras.

**Stored state:** website-builder.js → buildContent() → site.theme, site.social, site.reviews inside the existing site JSON.

**Public rendering:** public-site.html → site-extras → public-site.js → renderBusinessExtras(site).

**Colours:** accent, text, page background, header/navigation, buying section, selling section and footer are applied as CSS custom properties. The selected template remains the layout/typography layer.

**Social:** Facebook, Instagram, LinkedIn, YouTube, TikTok and X profile links are rendered when supplied.

**Sharing:** optional website share controls use the browser Web Share API where available, with Facebook/LinkedIn share links as fallbacks.

**Reviews:** up to four subscriber-supplied review-site links are rendered as external links.

**Security boundary:** no tenant/RLS changes were made. External URLs are restricted to HTTP/HTTPS at public render time.

**Final browser verification:** change a colour, add one social link, add one review link, Save Draft, Publish, then verify the public site.


## Restore checkpoint — 18 September 2026

This document is part of the locked TradeFlow stopping point for 18 September 2026. GitHub restore branch: checkpoint-tradeflow-20260918-premium-builder-final. Current main checkpoint commit: 0acc8d7ecca0de368172bf4fec1d746f11279dbd. Live Supabase includes migration repair_subscriber_trial_entitlement_window. Continue tomorrow from this checkpoint; do not modify GearCashOut.


## Stage 1S — Domain purchasing database foundation — 19 September 2026

### User path

Future target:

**Subscriber Dashboard → Website/Domain → domain search → authoritative availability/price check → payment → registrar registration → tenant domain activation → DNS/hosting → SSL → published site.**

Current implemented path:

**Subscriber Dashboard → Website URL → `domain-settings.html` → `domain-settings.js` → `tenant_domains` pending record.**

### Database objects

Existing:
- `tenant_domains`
- `published_site_index`
- `publish_site_revision()`

Added:
- `domain_tld_catalog`
- `tenant_domain_orders`

Extended:
- `tenant_domains.acquisition_source`
- `tenant_domains.registrar_provider`
- `tenant_domains.registrar_domain_id`
- `tenant_domains.registered_at`
- `tenant_domains.expires_at`
- `tenant_domains.auto_renew`
- `tenant_domains.provider_metadata`

### Failure points

1. Domain search data is stale or not authoritative.
2. Domain becomes unavailable between search and purchase.
3. Registrar/provider does not support the selected TLD or premium domain.
4. Payment succeeds but registrar registration fails or remains asynchronous.
5. Registrar succeeds but tenant domain activation is not reconciled.
6. DNS/hosting target is not configured for multi-subscriber routing.
7. SSL issuance/renewal fails.
8. Auto-renew state diverges between TradeFlow and registrar.
9. Provider secrets are exposed to the browser or database.
10. Domain order can be accessed across tenants.

### Diagnostic rule

Trace domain purchase as:

**User action → domain UI → server-side availability/check → payment boundary → registrar registration → provider status/reconciliation → `tenant_domain_orders` → `tenant_domains` → DNS/hosting → `published_site_index` → public renderer.**

Do not mark domain purchasing Verified Live until a real end-to-end test has demonstrated the full chain. Do not invent the registrar, DNS target or provider-specific API path before those components are selected and inspected.

**Database foundation:** Implemented and schema-verified.  
**Purchase flow:** Planned.



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


## Buying Catalogue / Research Centre — 19 September 2026
User path: Subscriber → Buying → What We Buy → category/branch/manufacturer/model → condition percentages. Management actions use `categories`, `category_branches`, and `tenant_buying_manufacturers`; product rules use `tenant_buying_products` and `tenant_buying_condition_rules`; research is read-only here from `tenant_buying_research`. Research path: Subscriber → Research Centre → product → UK New/UK Used evidence → save → latest evidence becomes the reference price in What We Buy. Automatic valuation calls `calculate_buying_item_valuation`; missing condition pricing or research returns manual fallback. Security depends on existing tenant RLS plus `private.can_tenant` for buying-managed tables.


## Buying Price Basis / Override Path — 19 September 2026
For each condition the user can choose UK New or UK Used as the automatic basis, enter a percentage, and optionally enter an exact manual override. Frontend state is persisted in `tenant_buying_condition_rules`; the valuation path is `buying-dashboard.js` → `calculate_buying_item_valuation`. RPC precedence: manual override → selected research basis + percentage → manual fallback if research/percentage is unavailable. Research remains read-only on What We Buy.


## Catalogue Management Navigation — 19 September 2026
Management flow: open What We Buy → Manage → select Category → view all Branches / Types for that category → select Branch → view manufacturers/products in that branch. This replaces the previous ambiguous side-by-side category/branch editing layout. Main catalogue filtering follows the same Category → Branch → Manufacturer → Model hierarchy.


## Bulk Pricing Profile Path — 19 September 2026
User action: What We Buy → select branch → choose Quick pricing rule → Update all products. Frontend builds one condition-rule payload per product and upserts `tenant_buying_condition_rules`. Scope is the selected branch. Research and manual override fields are deliberately excluded from the bulk update.


## Selectable Product Pricing Path — 19 September 2026
User flow: Category → Branch → optional Manufacturer/Model filter → checkbox products → choose UK New or UK Used → choose percentage profile → Apply pricing to selected. The frontend upserts only condition rule reference and percentage fields for selected product IDs. The matrix then recalculates against the selected research basis. Manual overrides remain stored and take precedence during valuation.


## Universal Reference Preview — 19 September 2026
Bulk pricing flow now previews the selected UK New/UK Used reference across every condition of selected products before persistence. `Apply pricing to selected` upserts the same reference type into all five condition-rule reference fields plus the selected percentage profile. Missing research on the chosen basis is surfaced rather than silently substituted.


## Active Buying Price Display — 19 September 2026
What We Buy condition cells now expose the effective pricing state: ACTIVE BUYING PRICE — MANUAL or ACTIVE BUYING PRICE — AUTOMATIC. Manual override input changes update the active-price preview immediately. Clearing the input switches the preview back to automatic. Persistence remains through `tenant_buying_condition_rules`, and valuation RPC precedence is manual override before automatic calculation.


## Reset Pricing Path — 19 September 2026
User action: select products → Reset selected prices → first click arms a warning → second click within five seconds confirms → delete the selected `tenant_buying_condition_rules` rows and clear legacy product-level automatic/manual base-price fields → reload matrix. Changing UK New/UK Used only changes the selected reference preview and does not silently delete stored pricing.


## Catalogue Loading Repair — 19 September 2026
- Added a 15-second timeout to catalogue REST requests so a stalled Supabase request cannot leave the page apparently frozen indefinitely.
- Category loading is now isolated from manufacturer loading: categories and branches can initialise even if the manufacturer endpoint fails.
- Loading failures are surfaced in the page message area rather than silently leaving empty selectors.
- The catalogue script cache-buster is now v15.


## Standalone Master Catalogue Path — 19 September 2026
User flow for an eligible Catalogue-plan subscriber: sign in → What We Buy → startup invokes `public.seed_tenant_master_catalogue(tenant_id)` → TradeFlow copies the standalone master categories, branches, manufacturers and products into that tenant's own catalogue → existing Category → Manufacturer → Branch selectors load from the tenant copy. The RPC checks `buying.manage`, `module.buying` and `catalogue.pre_filled`; non-Catalogue plans are not seeded.
Master data path: `catalogue_master_categories` → `catalogue_master_branches` → `catalogue_master_manufacturers` → `catalogue_master_products` → tenant `categories`, `category_branches`, `tenant_buying_manufacturers`, `tenant_buying_products`.
No runtime request goes to GearCashOut. GearCashOut research/retailer pricing is not used by this path.
Initial imported snapshot verified at 34 categories, 179 branches, 73 manufacturers, 3,845 products and 108 identifiers.


## 19 September 2026 — Master catalogue duplicate-category cleanup

Diagnostic path: GearCashOut source snapshot → one-time TradeFlow master import → TradeFlow catalogue_master_* tables → subscriber catalogue seeding → tenant-owned category/branch/manufacturer/product records. There is no runtime GearCashOut dependency.

The imported TradeFlow master catalogue contained two clear duplicate category structures:

1. Drone was merged into Drones. The one product and its Drone branch were moved to the canonical Drones category.
2. Tripod/Support was merged into Tripods. Its two products were moved to the canonical category and its duplicate Tripods branch was merged into the existing canonical branch before the old branch/category were removed.

The cleanup was executed only in the TradeFlow Supabase project. It does not modify GearCashOut. The duplicate category records were re-queried and confirmed absent. Drones now has 541 products and Tripods has 4 products in the canonical branch.

The remaining similarly named categories have deliberately not been auto-merged because the current evidence does not prove they represent the same taxonomy. This prevents an over-aggressive cleanup from moving legitimate product classes.

Verification state: database cleanup Tested/Verified at database boundary. Subscriber browser selector open for live verification.


## 2026-09-19 — Buying Catalogue Master Copy & Cascading Selectors

- The subscriber Buying Catalogue uses the TradeFlow-local master catalogue tables (catalogue_master_categories, catalogue_master_branches, catalogue_master_manufacturers, catalogue_master_products) as the seed source. The subscriber copy is tenant-owned in categories, category_branches, tenant_buying_manufacturers, and tenant_buying_products and does not query GearCashOut at runtime or use GearCashOut research/pricing for valuations.
- The current master snapshot contains 32 categories, 178 branches, 73 manufacturers and 3,837 active products. The test subscriber has its own tenant copy and can diverge independently.
- Buying Catalogue selectors are now cascading: Category → relevant Manufacturers → relevant Branches for the selected manufacturer → Models in the selected branch/manufacturer. Changing an upstream selection resets and reloads downstream selections rather than leaving unrelated values available.
- buying-catalogue.js commit ff575e5204f7cb3efc12284a5109be0610334a5b implements the selector dependency logic. buying-catalogue.html commit 34771b980131a4be683179ecf6f6f8b5a21ce2c9 changes Model to a dependent select and cache-busts the JS to v16.
- Syntax check passed with new Function() after the selector change. Live browser verification is still required after a hard refresh.
