# TradeFlow Subscriber Dashboard — Developer Diagnostic Roadmap

**Status:** Living roadmap  
**Date:** 19 September 2026  
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


## Reset Pricing Path — 19 September 2026User action: select products → Reset selected prices → first click arms a warning → second click within five seconds confirms → delete the selected `tenant_buying_condition_rules` rows and clear legacy product-level automatic/manual base-price fields → reload matrix. Changing UK New/UK Used only changes the selected reference preview and does not silently delete stored pricing.


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

## Buying Catalogue — master catalogue, entitlement and selector diagnostic — 19 September 2026

### User action
Subscriber opens **What We Buy / Buying Catalogue**.

### Entry page
- `buying-catalogue.html`
- `buying-catalogue.js`
- `subscriber-auth.js`
- `subscriber-auth-controls.js`
- `subscriber-tenant-context.js`

### Intended data flow
Subscriber Auth
→ authenticated session
→ active tenant membership
→ `seed_tenant_master_catalogue(tenant_id)` when the tenant has the pre-filled catalogue entitlement
→ tenant-owned `categories` / `category_branches` / `tenant_buying_manufacturers` / `tenant_buying_products`
→ selected Category
→ category product scope
→ Manufacturer filter
→ Branch
→ product/research/condition-rule matrix.

The master catalogue is a TradeFlow-owned copy in:
- `catalogue_master_categories`
- `catalogue_master_branches`
- `catalogue_master_manufacturers`
- `catalogue_master_products`

It does not read GearCashOut at runtime and is not used as a GearCashOut pricing/research reference.

### Actual selector repair
The current GitHub controller called `loadCategoryScope()` but did not define it. The repair adds that function so the selected tenant category first loads its products and then populates the manufacturer filter. `loadBranches()` then runs for the selected category. Category slugs are de-duplicated before rendering. HTML now loads `buying-catalogue.js?v=17`.

The screenshot supplied during the repair reported **“LocalStorage is not defined”**. The current GitHub source did not contain a matching `LocalStorage` identifier, so that exact deployed-browser message is treated as a stale/deployed-runtime symptom rather than being attributed to a source line that does not exist. The cache-buster was advanced and the definite selector initialisation fault was repaired.

### Subscription boundary
The live `catalogue.pre_filled` feature is enabled for Enhanced and Catalogue and disabled for Basic. The active Catalogue plan remains present.

### Current verification
Database checks passed for:
- master catalogue counts;
- package feature flags;
- no duplicate tenant category slugs;
- removal of the known stale `Drone` and `Tripod/Support` test-tenant aliases;
- canonical Drones branch structure;
- preservation of the unrelated custom Accessories category and manually added Canon product.

**Browser verification remains OPEN.**

### Browser test to run next
1. Hard refresh the deployed Buying Catalogue (Ctrl+F5).
2. Confirm Category is populated.
3. Select **Cameras**.
4. Confirm Manufacturer populates and select **Canon**.
5. Confirm Branch populates and select **Digital**.
6. Confirm the matrix loads Canon products.
7. Confirm New/Used research remains read-only.
8. Confirm condition percentages/manual overrides remain tenant-specific.
9. Do not expect Basic tenants to auto-seed the pre-filled catalogue; use an Enhanced/Catalogue entitlement for that test.

### Known failure points
- Subscriber auth/session not resolved.
- Pre-filled feature not entitled.
- Category scope request fails.
- Manufacturer scope request fails.
- Branch request fails.
- Tenant product/research request fails.
- Browser serves stale controller despite cache-buster.
- Existing custom categories coexist with the master catalogue by design; only exact duplicate slugs are suppressed in the selector.


## 2026-09-19 — Master catalogue test boundary and cache repair

The master catalogue remains a TradeFlow-owned copy: 32 categories, 178 branches, 73 manufacturers and 3,845 products. The seed path is:

Subscriber auth → tenant context → seed_tenant_master_catalogue(tenant_id) when catalogue.pre_filled is enabled → tenant categories → category_branches → tenant_buying_manufacturers → tenant_buying_products → Buying Catalogue selectors.

No GearCashOut runtime dependency is present in the seed function definition. GearCashOut research/pricing is not used for TradeFlow buying valuation.

The live feature boundary is Basic disabled, Enhanced enabled, Catalogue enabled. The current test tenant is Basic, so a blank/limited tenant catalogue is expected until an eligible test subscription is used.

The browser screenshot reported loadCategoryScope is not defined; current source contains that function, so the deployed page was treated as stale-controller/caching rather than a database selector failure. The page controller cache-buster is now v18 and the temporary development explanatory banner has been removed.

Next browser verification: hard-refresh with an Enhanced/Catalogue test tenant, confirm the master categories populate, then test Category → Manufacturer → Branch → Model and confirm tenant-specific pricing/research remains separate.




## 19 September 2026 — Unified Catalogue & Categories diagnostic path

**User action:** Open Catalogue & Categories → choose category/branch/product → toggle Buying and/or Selling Website.

**Page:** `categories.html`

**Controller:** `category-management.js`

**Master read path:** `get_master_catalogue_for_selection(tenant_id)` → `catalogue_master_categories`, `catalogue_master_branches`, `catalogue_master_manufacturers`, `catalogue_master_products`.

**Tenant selection path:** `tenant_catalogue_selections` stores the subscriber's master-product activation state.

**Activation path:** `activate_master_catalogue_products(tenant_id, master_product_ids, buying_enabled, selling_enabled)`.

**Automatic tenant structure:** the activation RPC creates missing `categories`, `category_branches` and `tenant_buying_manufacturers` records. If Buying is enabled it creates the normal tenant `tenant_buying_products` record used by the existing Buying/Valuation flow.

**Selling boundary:** product selection marks the tenant catalogue product as live for the Selling Website; actual inventory/listing publication remains downstream in the existing Inventory → Selling workflow.

**Security:** the read RPC and activation RPC require authenticated tenant permission and the relevant Buying/Selling feature. No GearCashOut table or runtime API is called.

**Failure points to test:** subscriber auth/tenant context; catalogue feature entitlement; master RPC response; selection RLS; activation RPC; automatic category/branch creation; tenant buying-product creation; Selling Website visibility downstream.

**Verification state:** Implemented; authenticated browser journey still OPEN.



### 19 September 2026 — Buying Prices no longer seeds the entire tenant catalogue

The separate Buying Prices workspace no longer calls `seed_tenant_master_catalogue()` when it opens. Catalogue activation is now an explicit subscriber action on Catalogue & Categories. Buying Prices works on products already selected for Buying and remains responsible for condition percentages, research basis and manual overrides. The legacy seed RPC remains available for controlled migration/maintenance but is no longer the normal subscriber page startup path.


## 2026-09-19 — Buying Catalogue consolidation repair

Observed failure: the subscriber test account showed an empty master catalogue because it was on Basic, while `catalogue.pre_filled` is intentionally an Enhanced/Catalogue entitlement. The test tenant was moved to Enhanced trial for testing.

Architecture change: `buying-catalogue.html` is now the single subscriber workflow for master-product selection and buying-price configuration. `categories.html` redirects to it. The page loads the TradeFlow master catalogue through `get_master_catalogue_for_selection()`, filters category/branch/manufacturer/model client-side, and activates selections through `activate_master_catalogue_products()`. Activation creates tenant category/branch/manufacturer records and a tenant buying product automatically. No buying price means manual valuation/quote.

Verification: TradeFlow master catalogue counts match the copied source dataset (3,845 total; 3,822 active/customer-visible; 102 catalogue categories; 34 main categories; 155 product types; 73 manufacturers). Test tenant entitlement now reports both `catalogue.pre_filled=true` and `module.buying=true`. `buying-catalogue.js` syntax checked successfully after the consolidation.


### Post-change verification — 2026-09-19
Authenticated test of get_master_catalogue_for_selection returned 3,822 products for the Enhanced test tenant. Transaction-scoped activation of a sample Autel Alpha returned the expected subscriber category/branch and blank buying-price fields; rollback confirmed no test data was persisted.

## 2026-09-19 — Unified Buying Pricing & Master Catalogue diagnostic roadmap

### User action
Subscriber opens **Buying → What We Buy / Buying Pricing** and searches the TradeFlow master catalogue.

### Entry
- `buying-catalogue.html`
- `buying-catalogue.js`
- `subscriber-auth.js`
- `subscriber-auth-controls.js`
- `subscriber-tenant-context.js`

### Master read path
Subscriber auth
→ `get_master_catalogue_for_selection(tenant_id)`
→ `catalogue_master_categories` / `catalogue_master_branches` / `catalogue_master_manufacturers` / `catalogue_master_products`
→ client-side category / branch / manufacturer / model filters
→ product row.

### Pricing write path
Product row → Mode = Manual or Automatic
→ `configure_master_catalogue_buying_product(tenant_id, master_product_id, mode, pricing)`
→ tenant `categories`
→ tenant `category_branches`
→ tenant `tenant_buying_manufacturers`
→ tenant `tenant_catalogue_selections`
→ tenant `tenant_buying_products`
→ if Automatic: `tenant_buying_condition_rules`.

Mode = Off / Reset:
→ same protected RPC
→ tenant selection `buying_enabled=false`
→ tenant buying product inactive
→ manual/automatic buying price configuration cleared
→ master catalogue product remains untouched.

### Downstream valuation
Buying item + condition
→ `calculate_buying_item_valuation()`
→ product-level manual price first
→ otherwise condition manual override
→ otherwise selected UK New/UK Used research × percentage
→ otherwise manual valuation/quote fallback.

### Visual state
- Inactive: light red/pink
- Active Buying without price: light green
- Manual offer: light yellow
- Automatic rule: light grey

### Security / separation
The master catalogue is TradeFlow-owned and independent of GearCashOut. No runtime GearCashOut request is used. Subscriber writes are protected by tenant permission and subscription feature checks inside the RPC.

### Verification
Code syntax check: PASS.
Database migrations: applied successfully.
Authenticated browser test of the new consolidated pricing workflow: OPEN.


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


## 21 September 2026 — Live Buying Workflow Dashboard Failure Repair

### User action
Subscriber opens the Business Dashboard and expects the Transactions in progress workflow summary to load.

### Entry point
- subscriber-dashboard.html
- Inline live-workflow controller in subscriber-dashboard.html

### First failure found
The Supabase reads were not the first failure. The controller successfully assembled requests, items, valuations, offers and acquisitions, then attempted to write the acquisition count to count-received. The page actually contains id=count-acquisitions. The null element access threw and the catch block replaced the workflow list with the generic load-failure message.

### Repair
- Keep the existing workflow/data model.
- Write the acquisition count to count-acquisitions.
- Count active acquisition statuses using the existing acquisition records.
- Preserve green/yellow/blue workflow semantics.
- Do not alter tenant boundaries or customer/request data.

### Buying detail path
buying-dashboard.html → buying-dashboard.js → tenant-scoped buying requests/items → subscriber_get_buying_item_customer_details → category_fields.label + buying_item_field_values → trading values → offers.

The Buying controller cache-buster was advanced from v9 to v10 to avoid a stale browser controller masking the source fix.

### Verified live test state at diagnosis
- Tenant: Camerashack
- Request: BR-744BA41BDC
- Item: BI-1D805A5FD3
- Customer: TEST CS CUST
- Approved valuation: £100.00, method manual, status approved
- Current live offer after subsequent customer action: £100.00, status accepted

### Known historical fault
Older Buying controller versions attempted to use category_fields.name. The real column is category_fields.label. Current source and the existing customer-detail RPC use label. If that error appears after deployment, check browser cache/controller version before changing the database schema.

## 21 September 2026 — Accepted Offer Shipping Handoff

### User action
Customer accepts the published offer.

### Expected flow
Published offer → customer accepts → acquisition status `accepted` → subscriber sees **Offer accepted — send customer shipping label** → subscriber publishes label/instructions → acquisition `awaiting_item` → customer sees shipping handoff → customer posts item.

### Live test finding
For `BR-744BA41BDC` / `BI-1D805A5FD3`, the live offer is `accepted` and the acquisition is `accepted`, while `buying_requests.status` and `buying_items.status` still show `offer_ready`. The workflow must therefore derive the customer-facing lifecycle from the offer/acquisition records rather than assuming the older request/item status is authoritative for the handoff.

### Existing database support
The live `acquisitions` table already contains the shipping handoff fields. No migration was required. The customer RPC `customer_get_acquisition_shipping()` already exposes them to the authenticated customer portal.

### Repair
- Buying workflow recognises accepted offer/acquisition state.
- Accepted state is amber/action-required for the subscriber.
- Subscriber can publish shipping label URL, carrier, service, tracking number and instructions from the Buying request.
- Existing workflow transition changes accepted acquisition to `awaiting_item` after the label is published.
- Customer Portal accepted-stage wording now points to the shipping-label handoff.

### Failure points
- Stale Buying controller cache.
- Accepted offer hidden by an incorrect query/RLS path.
- Subscriber lacks `acquisitions.manage` permission.
- Shipping label URL omitted.
- Direct status mutation bypassing `transition_workflow_entity()`.
- Customer portal not refreshing `customer_get_acquisition_shipping()` after publication.

## 21 September 2026 — Duplicate Lifecycle Renderer Finding

When the dashboard list and request header show the accepted stage but the item Offer box still says no offer was sent, inspect for independent item-level financial renderers. `buying-dashboard.js` had `renderRequests()/showRequest()` deriving lifecycle from offer/acquisition, while `loadItemFinancials()` independently rendered an approved-valuation/no-offer fallback. These paths could disagree. The repair binds the item financial renderer to the request lifecycle state and starts the existing status refresh timer on initial page load. Cache-buster: v12.

## 21 September 2026 — Accepted Offer RLS and Customer Field RPC Repair

### User action
Subscriber opens buying-dashboard.html after the customer has already accepted the £100 offer.

### Observed state
The page still displayed **Valuation approved — offer not yet sent**, and the item Offer panel displayed **No offer has been sent yet**. The page also displayed a customer-field error: **CASE types jsonb and text cannot be matched**.

### Database diagnosis
The live database contained exactly one accepted £100 offer and one linked accepted acquisition. The subscriber's tenant permissions were correct. However, offers_subscription_select and acquisitions_subscription_select were RESTRICTIVE SELECT policies with no permissive SELECT policy. Under PostgreSQL RLS composition, that produced zero rows for the authenticated subscriber. The frontend therefore fell back to the approved-valuation state instead of seeing the accepted offer.

### Repair
Migration repair_offer_and_acquisition_select_policies adds:
- offers_select_members — permissive SELECT for authenticated tenant members;
- acquisitions_select_members — permissive SELECT for authenticated tenant members.

The existing restrictive subscription permission/feature policies remain in force and continue to require the appropriate tenant permission and buying/offers feature.

### Customer field repair
Migration repair_subscriber_customer_field_json_types changes the text-like CASE branches in subscriber_get_buying_item_customer_details() to return jsonb via to_jsonb(). Authenticated-role verification returned the live customer/request payload successfully.

### Verified result
Authenticated-role SQL now sees offer OFF-9E44199AB6F3 as accepted (£100) and the linked acquisition as accepted. The customer-detail RPC returns without the CASE-type error. The frontend's existing v12 controller should now derive offer_accepted and present the shipping-label handoff rather than the pre-offer message.

### Browser verification still required
Hard-refresh the current Buying page and reopen BR-744BA41BDC. Confirm the old pre-offer messages are absent, the accepted £100 offer is shown, the shipping handoff form is visible, and the customer details load without the CASE error. No shipping label should be published until an actual test label URL is available.

## 21 September 2026 — Shipping Label Upload and Resend

The accepted-offer shipping handoff now supports two label sources:

- **Shipping label URL** — paste the label URL supplied by the carrier.
- **Uploaded shipping label** — upload a PDF, PNG or JPEG directly to TradeFlow.

Uploaded labels are stored in the existing private `tradeflow-media` bucket under the tenant/acquisition path. The customer can access only the label belonging to their own acquisition. The subscriber can open/print the label from the Buying or Acquisition workspace.

The shipping handoff action is now **Send shipping label to customer** initially, then **Save & resend shipping label** when a label already exists. This republishes the current label/instructions to the customer portal without creating a duplicate acquisition or offer.

The Customer Portal shows **Open / print shipping label** and **Download shipping label** when an uploaded label exists. Signed links are generated on demand rather than permanently exposing the private storage object.


## 21 September 2026 — Subscriber Shipping Service Override

### User action
After a customer accepts an offer, the subscriber wants to use their own courier/shipping service instead of the future TradeFlow/Voila automated route.

### Entry points
- buying-dashboard.html
- buying-dashboard.js
- acquisition-dashboard.html
- acquisition-dashboard.js
- Customer Portal customer-dashboard.js

### Data model
Existing public.acquisitions remains the authoritative shipping handoff record.

Added:
- shipping_method — subscriber_override or automated;
- shipping_qr_url;
- shipping_qr_storage_path.

The existing shipping label URL/file fields remain authoritative for labels.

### Subscriber override path

Accepted acquisition
→ Shipping method = Use my own shipping service
→ subscriber enters a label URL and/or QR URL
OR
→ uploads a label and/or QR image
→ optional carrier/service/tracking/instructions
→ save/send handoff
→ existing accepted → awaiting_item transition
→ customer portal reads the same acquisition.

A label is no longer the only valid handoff artifact: a QR code alone is allowed.

### Storage/security

QR uploads use the existing private tradeflow-media bucket under the tenant/acquisition path. The existing customer storage policy restricts access to the exact acquisition belonging to the authenticated customer. No public storage object is created.

### Automated route boundary

The UI contains an **Automated courier — Voila (coming next)** option but it is disabled until the Voila connection is implemented. This is intentional: the platform must not allow an apparently automated route that has no live carrier credentials or label-generation path.

### Future Voila implementation

Planned automated path:

TradeFlow server
→ Voila API
→ selected courier
→ label + tracking response
→ existing acquisition shipping fields
→ Customer Portal.

Voila documentation currently supports API accounts, courier registration, label creation and webhook-based tracking. The eventual integration should keep API credentials server-side and should not introduce a second shipping state machine.


## 21 September 2026 — Customer-Paid Shipping Boundary

### User requirement
The customer selling an item to a subscriber is responsible for arranging and paying for shipping. TradeFlow and the subscriber do not collect, pay or reimburse the customer's shipping cost as part of the TradeFlow acquisition.

### Implementation rule
- Accepted offer amount remains the complete TradeFlow offer amount.
- No shipping amount is added to the offer or acquisition financial totals.
- No customer shipping payment is created in TradeFlow.
- No TradeFlow shipping expense or reimbursement is recorded.
- Shipping labels, QR codes, courier/service names, tracking and instructions remain operational handoff data only.
- Subscriber override remains available per acquisition.
- Future Voila automation must preserve the same financial boundary.

### Customer Portal wording
The customer is explicitly told that they are responsible for arranging and paying for shipping. The portal can display the subscriber's label/QR/instructions without becoming a shipping payment processor.

## 2026-09-21 — Parcel2Go connected customer shipping
The accepted-offer shipping workflow now supports a subscriber-connected Parcel2Go route. The subscriber connects their own Parcel2Go account in Settings; credentials remain server-side. Buying can enable connected Parcel2Go shipping on an accepted acquisition. The Customer Portal can then request a Parcel2Go quote using the customer's saved address and entered parcel dimensions, select a service, and create an unpaid Parcel2Go order. The customer is sent to Parcel2Go for payment. TradeFlow does not collect, pay or reimburse shipping costs. Remaining diagnostic stages are Parcel2Go webhook verification, post-payment label retrieval, and tracking synchronisation.


### 22 September 2026 — shipping handoff state correction

- Separate subscriber handoff publication from customer confirmation using `customer_sent_at`.
- Customer Portal must consolidate shipping assets in the selling-request status card; do not maintain a second duplicate Send your item section.
- Provider/service links are separate from physical label/QR assets. Download/Print controls must operate on private uploaded storage assets.
- Subscriber Buying and Acquisition dashboards must remain Awaiting item until `customer_sent_at` is populated. Only then show Item on its way / awaiting receipt.
- Shared Shipping Settings are tenant-wide and apply to both Buying/acquisition operations and Retail Shop sales/fulfilment.


## 22 September 2026 — Shipping handoff → customer sent → receipt roadmap

### Expected route
Subscriber accepts offer
→ Send shipping label
→ physical label/QR stored on acquisition
→ publish handoff
→ acquisition awaiting_item
→ customer sees label/QR/instructions
→ customer clicks **Item sent**
→ customer_sent_at populated + shipping_status=in_transit
→ subscriber sees **Item on its way — awaiting receipt**
→ subscriber clicks **Confirm item received**
→ authoritative acquisition awaiting_item → received
→ existing acquisition received → inspection.

### Physical asset diagnostic
If the customer cannot see a label:
1. inspect acquisitions.shipping_label_url;
2. inspect acquisitions.shipping_label_storage_path;
3. inspect acquisitions.shipping_qr_url;
4. inspect acquisitions.shipping_qr_storage_path;
5. inspect private tradeflow-media under <tenant_id>/acquisitions/<acquisition_id>/;
6. if an orphaned private label exists, restore the acquisition reference;
7. use the subscriber resend/replace control;
8. verify the customer portal receives a signed URL.

Never substitute shipping_service_url for the physical label.

### Receipt diagnostic
If the customer has clicked **Item sent**:
- verify customer_sent_at;
- verify shipping_status=in_transit;
- acquisition status should remain awaiting_item;
- subscriber Buying should display **Item on its way — awaiting receipt**;
- **Confirm item received** must call subscriber_mark_acquisition_received;
- successful receipt must create the authoritative awaiting_item → received transition;
- then the existing **received → inspection** control becomes available.

Do not create a separate shipping state machine for this workflow.


## 2026-09-22 — Diagnostic finding: receipt is backend-authoritative, presentation was stale

**Path:** Customer confirms item sent → subscriber Buying dashboard → `subscriber_mark_acquisition_received` → `transition_workflow_entity(acquisition, awaiting_item → received)` → acquisition `received_at` → customer/subscriber status renderers → inspection.

**Verified live:** `ACQ-B11FB7341903` is `received`; `received_at` is populated; `shipping_status` is `received`. The authoritative workflow log records `awaiting_item → received`. The acquisition item was still `accepted`, exposing a secondary synchronisation defect; the receipt RPC has been hardened to move item state through `accepted → awaiting_item → received` using the authoritative transition mechanism.

**Frontend repair:** `buying-dashboard.js` now preserves `received` and `inspection` rather than mapping them back to `shipping`; `customer-dashboard.js` now explicitly displays received/inspection stages; cache versions were bumped (`buying-dashboard.js` v31, `customer-dashboard.js` v43). Both files passed syntax parsing.

**Next diagnostic target:** acquisition `received → inspection`, then inspection findings and valuation/revaluation. Keep offer acceptance, approved valuation, acquisition agreed value, inspection/revaluation and final valuation as distinct concepts.


## 2026-09-22 — Received → Purchasing Inspection diagnostic and repair

**User action:** Subscriber has received an acquisition and needs an obvious next action.

**Expected route:** Received → **START INSPECTION** → Purchasing inspection workspace → compare customer submission → record condition/accessories/serial/technical checks → record discrepancies and evidence → choose outcome → Ready for Resale/Sales or Testing/Repair/Hold.

**Root problem found:** The live acquisition was correctly at `received`, but the Buying dashboard had no operational CTA or inspection workspace. The older Acquisition dashboard contained only generic workflow transitions and was not the intended Purchasing experience.

**Repair:** Added `buying-inspection.js` to the live Buying dashboard. It provides a persistent received-stage action, starts inspection through the authoritative RPC, creates the linked inventory asset, and presents the full inspection form in Purchasing.

**Sales boundary:** A passed inspection transitions the inventory asset `inspection → ready_for_sale` and finalises the acquisition/item. Sales must treat the completed inspection as read-only. Failed technical/condition checks route to Testing, Repair, or Hold and do not enter Sales.


## 2026-09-22 — Root cause and correction: START INSPECTION + final-offer stage

Observed: The live page still displayed the old "The subscriber has received the item" notice and clicking the expected inspection action did not advance the acquisition.

Root cause: The new supplemental inspection controller was not sufficient as the authoritative received-stage CTA. Its polling controller also cached the request reference, so later refreshes could skip the workflow read. The primary Buying dashboard still contained the old received notice.

Correction: The primary buying-dashboard.js now renders the received-stage START INSPECTION action and directly calls subscriber_start_acquisition_inspection. Script cache versions were bumped in buying-dashboard.html.

Final-offer architecture correction: The inspection completion RPC no longer moves the inventory asset to ready_for_sale. After a passing inspection it leaves the asset in inspection, finalises the acquisition/acquisition-item, and marks the next stage as final_offer. The Buying inspection workspace then creates a separate approved post-inspection valuation and final offer. Sales must not receive the item until the customer accepts that final offer and the payment workflow completes.


## 2026-09-22 — Inspection CTA ownership and customer wording follow-up

The inspection CTA is now handled by the main Buying dashboard as the authoritative workflow controller. The supplemental inspection workspace delegates its `START INSPECTION` click to that controller when available, preventing the CTA from appearing clickable while being owned by a separate polling script. Customer selling-status wording has also been removed from the internal `subscriber` terminology, including receipt and inspection messages. Browser cache versions were incremented for the Buying and customer dashboard scripts.


## 2026-09-22 — Inspection start RPC root cause

The START INSPECTION click was reaching the live RPC, but the RPC failed with PostgreSQL error `trigger functions can only be called as triggers`. Root cause: subscriber_start_acquisition_inspection called public.generate_asset_reference() as a normal scalar function. The live generate_asset_reference function is a trigger-returning function used by the inventory_assets INSERT trigger, so it cannot be called directly. The RPC was repaired to generate the AST reference inline while retaining the existing inventory trigger. The Buying dashboard live-status notice was also corrected so received/inspection states cannot be overwritten by the old shipping message.

## 2026-09-22 — Pre-acquisition purchase workflow correction

### Root architectural fault

The received-item inspection flow had been attached to the acquisitions and inventory_assets entities. That caused a customer-owned item to appear as purchased before inspection, final-offer acceptance and payment.

### Correct diagnostic boundary

For any customer selling request, first inspect buying_items.purchase_stage. Do not use the presence of an acquisition as evidence that the customer has been paid. An acquisition is now a post-payment record.

### Correct state path

none → awaiting_item → shipping → received → inspection → final_offer_required → final_offer_sent → final_offer_accepted → purchased

Alternative pre-purchase routes are inspection → testing, inspection → repair, inspection → return_pending, and final_offer_sent → final_offer_refused.

### Repair implemented

- Added pre-acquisition shipping, inspection and inspection-media storage.
- Reworked customer initial/final offer acceptance so neither creates an acquisition.
- Added dedicated receipt/inspection/final-offer/purchase RPCs.
- Added a payment-gated purchase RPC which creates acquisition/inventory only after final-offer acceptance and bank payment.
- Changed customer selling status and portal shipping to use the pre-acquisition workflow.
- Changed the Buying dashboard to use purchase_stage and removed generic buying-item transition buttons while an item is in the purchase workflow.
- Changed the Acquisitions workspace to show only paid/completed acquisitions.
- Repaired the current test item by removing its provisional acquisition/inventory records and retaining its shipping data against the buying item.

### Verification target

After a hard refresh, the current Canon EOS R7 test item must show **Inspection in progress** in Buying, must not appear in Acquisitions, and must not appear in Inventory. Completing the inspection as accepted must show **Final offer required**, not create an inventory asset. Only after the customer accepts the final offer and staff records payment should the acquisition and inventory record appear.
