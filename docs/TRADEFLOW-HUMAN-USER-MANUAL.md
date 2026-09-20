# TradeFlow Human User Manual

## Restore checkpoint — 18 September 2026

This document records the known-good stopping point for continuing TradeFlow development.

### Website Builder
The subscriber Website Builder is a visual, page-first editor with the current expanded template set:

1. Business
2. Premium Marketplace
3. Buy & Sell
4. Services
5. Editorial
6. Minimal
7. Retail
8. Professional
9. Bold
10. Classic
11. Local Business

The Premium Marketplace homepage is designed for a two-sided business and presents:
- professional hero
- buying and selling introduction
- visual What We Buy tiles
- visual What We Sell tiles
- trust information
- connected retail shop below the homepage

Homepage tile choices are 6, 8 or 10. Tiles can have their own title, description and image.

### Branding
Subscriber-controlled website colours are available for:
- Brand/accent
- Text
- Page background
- Header/navigation
- Buying section
- Selling section
- Footer

Quick palettes are available for Professional, Warm, Dark and Clean.

### Social, sharing and reviews
Subscribers can add:
- Facebook
- Instagram
- LinkedIn
- YouTube
- TikTok
- X

Website share buttons can be enabled or disabled.

Up to four review-site links can be added, such as Google Reviews, Trustpilot, Reviews.io or Feefo. TradeFlow displays subscriber-supplied external links; it does not verify third-party review profiles.

### Website workflow
Website content is saved as the existing site JSON within site_revisions. Images use the tenant-scoped tradeflow-site-media Storage bucket. Products remain connected to Inventory → Selling rather than being manually entered into the Website Builder.

The subscriber flow remains:
Buying → Acquisitions → Inventory → Selling → Orders → Fulfilment → Returns.

### Subscriber onboarding repair
New subscriber onboarding now creates a 30-day trial window. The repair is migration 065, repair_subscriber_trial_entitlement_window.

The affected test subscriber's live database capability checks were verified for:
- tenant membership
- website.editor
- website.publish

No RLS or tenant security boundary was weakened.

### Restore point
GitHub restore branch:
checkpoint-tradeflow-20260918-premium-builder

Restore branch base:
7f03b3964add0857ebc0ec3bcce2bf0d7113c80c

Live Supabase migration state includes:
repair_subscriber_trial_entitlement_window

### Status
The code and database checkpoint are saved. Browser verification of the newest branding/social/review controls remains the next testing task when development resumes.

Do not modify GearCashOut while working on this TradeFlow checkpoint.


## Website domains and future domain purchasing — 19 September 2026

TradeFlow can already store a custom website address against your business. The current **Website URL** area is for connecting a domain you already own.

A future TradeFlow domain service is now supported by the database design. The intended customer journey is:

1. Open **Website / Domain** in the business dashboard.
2. Search for a domain name.
3. See current availability and price.
4. Choose the domain and registration period.
5. Pay through TradeFlow.
6. TradeFlow registers the domain through its domain provider.
7. TradeFlow connects the domain to the customer's website and enables the required SSL/hosting routing.
8. The domain appears in the business account with its registration and renewal information.

The database now records the information needed for purchased domains, including registration status, provider reference, purchase amount, expiry date and auto-renewal state.

**Important:** the domain-purchase button/search/checkout and automatic DNS/hosting connection are not yet live. The current Website URL page only records a domain as pending for later connection.

Domain availability and prices will be checked with the selected registrar at the time of purchase; the prices stored in TradeFlow's TLD catalogue are configuration/pricing data, not a promise of current availability.




## Website Builder final refinement pass — 19 September 2026

The subscriber Website Builder has now received the agreed refinement pass before final browser review. Added: controlled typography options (font style, hero/section/body/navigation size levels), button styles, header styles, footer styles, optional homepage section visibility, optional second images for the homepage hero and content pages, and cleaner image controls with Add/Replace/Remove behavior. Homepage tiles remain unnumbered and directly editable.

Public rendering now consumes the saved typography, section visibility and multi-image settings. Asset cache versions are refreshed and both Builder and public runtime syntax have been checked. This is **Implemented in GitHub, not yet browser-verified**. Final verification should cover Builder preview, Save Draft, Publish, public site, responsive layout and the new controls.


## Draft preview and can_tenant permission repair — 19 September 2026

Browser verification exposed two separate issues. First, authenticated Website Builder operations were failing with `permission denied for function can_tenant`. The live database had the required RLS policies calling `private.can_tenant(uuid,text,text)`, but EXECUTE was only granted to postgres. Live migration `fix_authenticated_can_tenant_execute` restored EXECUTE to the authenticated role without changing the SECURITY DEFINER function or weakening tenant/feature checks. The migration is recorded in `supabase/migrations/066_fix_authenticated_can_tenant_execute.sql`.

Second, the Builder's previous `Open public website` link attempted to load the published-site path. A newly created subscriber may have a draft but no published revision, so that path correctly reports that no published website exists. The Builder link has therefore been renamed **Preview website** and now opens an authenticated draft-preview mode. The preview reads the signed-in subscriber's draft through existing RLS-protected `tenant_site_state` and `site_revisions` access; it does not expose drafts anonymously. The public site remains the published-site path and will work after the subscriber publishes a revision.

Validation: Builder and public-site JavaScript syntax checked OK; live EXECUTE grant confirmed for authenticated. Browser end-to-end preview verification remains the next user check.


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
