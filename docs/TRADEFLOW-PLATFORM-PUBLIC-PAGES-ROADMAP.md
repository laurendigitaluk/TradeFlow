# TradeFlow Platform Public Pages — Diagnostic Roadmap
Date: 3 November 2026
Status: How It Works is source-managed static accordion HTML/CSS; Examples remains database-backed CMS. Owner browser and Cloudflare deployment acceptance pending.

## Scope and boundary
This is the platform owner's CMS for two TradeFlow marketing pages:
- `how-it-works.html`
- `examples.html`
- Homepage Examples preview in `index.html`

It is separate from the subscriber Website Builder. The subscriber builder remains tenant-scoped and uses `tenant_site_state`, `site_revisions`, `published_site_index` and subscriber tenant ownership. Do not route platform marketing content through those subscriber tables.

## Environment
- Repository: `laurendigitaluk/TradeFlow`
- TEST branch: `cloudflare-test`; feature branch: `feature/owner-editable-public-pages-20261103`
- TEST Worker: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE branch: `production`; LIVE Worker: `tradeflow`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- Retired project `twfbmjwwqzxdxvclxbun` is forbidden.
- LIVE code is maintained on the parallel production feature branch; LIVE public page content is stored separately from TEST.

## User action → front end
1. Platform owner opens `/platform-owner-dashboard.html`.
2. Owner signs in using the existing `tradeflow_platform_owner_session` session.
3. Sidebar → **Public Website Pages**.
4. Select **How It Works** or **Examples**.
5. Edit nested text fields, image URLs, repeatable process lists, responsibility lists, example cards and product labels. Lists can be added, removed and reordered where supported. The four How It Works screenshot slots are fixed to preserve the existing page layout.
6. **Save draft** persists privately; **Preview draft** opens the public page with authenticated draft preview; **Open published page** opens the published version.
7. **Publish page** copies draft content to the public version.

## Code map
- `platform-owner-dashboard.html`: owner navigation and CMS panel; CSS cache-buster v5; editor script loaded after owner dashboard JS.
- `platform-owner-dashboard.js`: platform owner authentication and API client. The stale retired TEST Supabase URL/key were replaced with the authoritative TEST URL/publishable key from `wrangler.jsonc`.
- `platform-public-pages-editor.js`: generic nested content editor, list controls, save/publish RPCs and draft preview link.
- `platform-public-pages.js`: public read-only renderer; applies published content on How It Works, Examples and homepage Examples preview; supports owner-only draft preview.
- `how-it-works.html`, `examples.html`, `index.html`: load the shared public renderer.
- `platform-owner-dashboard.css`: editor layout styles.

## Database and security
TEST table:
- `public.platform_public_pages`
- `slug` primary key limited to `how-it-works` and `examples`.
- `draft_content` JSONB, `published_content` JSONB, `is_published`, owner/update/publish audit fields.
- RLS enabled. Direct anon/authenticated table privileges revoked; no direct client table read/write path.

RPCs:
- `platform_owner_get_public_pages()`: authenticated active `platform_memberships` owner gate; returns draft and publish metadata.
- `platform_owner_save_public_page(text,text,jsonb)`: active owner gate, slug/title/object/size validation, updates draft only.
- `platform_owner_publish_public_page(text)`: active owner gate, copies draft to published content.
- `platform_public_page_get(text)`: public read-only, returns published JSON only.

All owner RPCs are SECURITY DEFINER with fixed search_path and explicit active platform membership checks. Public function exposes only the published JSON for the two allow-listed slugs. No tenant ID, customer data, transaction data, Stripe details or subscriber website data are involved.

## Data flow
Owner editor → authenticated REST RPC → platform_public_pages.draft_content → owner draft preview via owner RPC.
Publish action → published_content/is_published → public REST RPC → shared renderer → page DOM.
Examples content is reused by standalone Examples and homepage Examples preview.
Image replacement uses a URL field; blank URL preserves the existing embedded screenshot. No upload/storage bucket was added.

## Known failure points and checks
- If owner dashboard fails at sign-in, verify TEST URL/key in `platform-owner-dashboard.js`; never use the retired project.
- If page editor does not load, inspect owner RPC auth and `platform_memberships.status='active'`.
- If draft does not save, inspect RPC payload, JSON size and owner gate.
- If public page remains old, confirm publish action, `is_published`, public RPC result, Worker commit and cache-busted script URL.
- If draft preview shows published content, check same-origin owner session key and owner RPC result.
- A GitHub merge is not proof of Cloudflare deployment.

## Verification completed
- TEST table and RPCs created; migration `20261103183000_owner_editable_public_pages` applied and recorded.
- Seeded current How It Works and Examples content in draft/published JSON.
- Read-back confirmed both pages published and four fixed screenshot slots editable.
- Function grants checked: anon can execute public read; authenticated can execute owner read.
- JavaScript parse checks passed for `platform-owner-dashboard.js`, `platform-public-pages-editor.js`, and `platform-public-pages.js`.
- Retired Supabase URL no longer appears in `platform-owner-dashboard.js`.

## Still required
1. Browser-test owner sign-in at TEST dashboard.
2. Confirm Public Website Pages editor loads both pages.
3. Change one draft field, save, reload and confirm persistence.
4. Preview draft and confirm public content remains unchanged.
5. Publish in TEST and verify How It Works, Examples and homepage Examples preview update.
6. Confirm mobile layout and image URL replacement.
7. Verify Cloudflare TEST deployment commit/runtime.
8. Do not promote to LIVE without explicit approval.


The follow-up migration `20261103183500_owner_public_pages_explicit_deny.sql` adds explicit deny policies for `anon` and `authenticated` direct table access. Security read-back confirmed RLS enabled, two deny policies, no direct SELECT privilege, owner RPCs executable only by authenticated users, and public read RPC executable by anon. The Supabase advisor still reports the public `platform_public_page_get(text)` SECURITY DEFINER function; this is intentional because it returns only published JSON for the two allow-listed page slugs, while direct table access remains denied. This finding is documented, not ignored.


## Merge and deployment status — 3 November 2026
- PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- TEST branch HEAD was read back at that merge commit. The `production` branch was not modified by this work.
- GitHub reports no workflow runs or commit statuses for this commit. The TEST Worker URL could not be independently opened from the available browser check, so Cloudflare deployment/runtime remains unverified.
- Next browser check: open `https://tradeflow-test.leannelaurenlowe.workers.dev/platform-owner-dashboard.html`, hard-refresh, sign in, and confirm the Public Website Pages editor. Do not treat the GitHub merge as proof of deployment.


## Final LIVE merge/deployment status — 3 November 2026
- LIVE PR #205 merged into `production` with merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`.
- TEST PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- LIVE and TEST database migrations applied and access-control read-back verified; each database has its own two page records.
- JavaScript syntax checks passed for owner dashboard, editor and renderer in LIVE; environment URL/key checks passed.
- Direct Worker URL checks for LIVE and TEST were inaccessible through the available browser tool. Cloudflare deployment commit/runtime and owner browser flow remain unverified. Do not state deployment is complete until the Worker version and browser flow are confirmed.
- The user confirmed simultaneous LIVE and TEST development. Continue keeping code behaviour aligned and content/data isolated.


## Platform-owner visual public page designer — 3 November 2026

The owner-facing Public Website Pages editor is being upgraded from the rejected nested text form to a visual, free-position canvas. The subscriber Website Builder remains unchanged and its locked baseline is not reopened.

- Owner can add text boxes, image boxes and screenshot boxes; select a box and edit its text, image, alt text, background, layout and numeric position/size; drag boxes directly on the canvas; resize with the corner handle; duplicate and delete boxes; and upload/replace/remove images.
- The page canvas stores its composition in `draft_content.visual_layout` JSONB within the existing `public.platform_public_pages` records. Existing draft/publish owner RPCs remain the persistence boundary. Published How It Works and Examples pages render the saved visual layout; homepage Examples preview continues to use its existing card renderer.
- Original embedded How It Works screenshots remain the public fallback when a screenshot box has no uploaded replacement.
- New public bucket `platform-public-media` accepts PNG/JPEG/WebP up to 8 MB. Storage insert/update/delete policies require an authenticated user with an active `platform_memberships` row and restrict object paths to that user's UUID. Public read is via the public bucket. Existing subscriber bucket/policies are not weakened.
- TEST project `nnsshnfkjcflucjrftzi` and LIVE project `gxsrajtqzdjvmceqcpgv` each received migration `20261103210000_platform_public_media_owner_uploads`. No page content was copied between environments.
- Feature branches: `feature/platform-public-visual-builder-test-20261103` and `feature/platform-public-visual-builder-live-20261103`. PRs and Cloudflare deployment/browser acceptance remain pending. JavaScript syntax was checked in the connector runtime for the visual editor and public renderer in both branches. Database bucket and three owner-only write policies were read back in both projects.
- Known acceptance still required: open owner dashboard in both environments; test drag, resize, add/delete/duplicate, upload, save, draft preview, publish, mobile rendering, and verify original screenshots remain until replaced. A GitHub merge is not proof of Cloudflare deployment.


## Merge status — 3 November 2026
- LIVE PR #206 merged into `production` at `d08f4f156452d066cd39dad7943f8e39e38985d1`.
- TEST PR #207 merged into `cloudflare-test` at `04989110d3fd49ab0bcf152e34819cc38193ac5d`.
- Both branch heads were read back at their merge commits. GitHub reports no commit statuses and zero Actions workflow runs for either head. The Worker dashboard URLs could not be opened through the available browser check. Cloudflare deployment and browser acceptance therefore remain unverified; do not tell the user the feature is live until that is checked.


Final editor refinement: free-position text/image/screenshot boxes are independently draggable and resizable on the canvas (x/y/width/height are also editable in the inspector). Full-width image boxes are rendered as images rather than hidden, and the owner canvas stacks split layouts on narrow screens. TEST visual editor URL/key were checked against TEST's own existing owner editor configuration; LIVE remains on LIVE Supabase. These refinements are included in the merged branches.


## Independent text and media boxes; unnumbered page copy — 4 November 2026
The owner visual page editor now creates text-only boxes and image/screenshot-only boxes. They are independent objects with separate drag, resize, x/y/width/height controls; text boxes no longer contain empty image columns, and media boxes no longer carry heading/body fields. Existing screenshot captions/titles are imported as their own text boxes next to independent media boxes. Public rendering follows the same independent object model. Automatic sequence labels (01/02/03), ordered-list markers and leading PART/step number prefixes are removed from How It Works copy. This is a presentation/editor change only: no Supabase schema, public page data, subscriber builder, tenant/customer records, or LIVE/TEST content was migrated or copied.

## Duplicate public-page copy correction — 4 November 2026
The owner visual editor's first-time layout conversion previously imported the comparison heading/paragraph and then imported the first screenshot's identical heading/paragraph again, creating two text boxes above the same screenshot. `platform-public-pages-visual-editor.js` now de-duplicates text blocks by normalized heading while retaining the screenshot box. The conversion also strips leading numeric/Part/Step prefixes before creating text blocks. This does not split a heading from its paragraph: each text box remains one independently movable text element containing its optional heading and body, while image/screenshot boxes remain separate independent elements. No saved `visual_layout` existed in either environment at the time of diagnosis; legacy `draft_content` remains unchanged until the owner saves a draft. No database schema, published content, tenant/customer data, or subscriber Website Builder code is changed.

## Public catalogue browser and navigation mega-menu — 5 November 2026

### User journey
- Any public TradeFlow marketing/legal page shows a **Catalogue & AI Research** dropdown in the top navigation.
- Dropdown categories load from the environment's own Supabase public read RPC and link to `catalogue-research.html?category=<slug>#browse-catalogue`.
- Catalogue & AI Research page contains a searchable, paginated live master-catalogue browser.

### Front-end entry points
- `catalogue-nav.js`: loads category list/counts for the mega-menu on all public pages; on the catalogue page it also handles product search, category filter, page navigation and result rendering.
- `catalogue-nav.css`: shared mega-menu styling and responsive/mobile layout.
- `catalogue-browser.css`: search/filter/result/pagination styling.
- `catalogue-research.html`: browse UI at `#browse-catalogue`.
- Navigation is present on homepage, How It Works, Plans, Examples, Contact Us, Terms, Privacy and Catalogue & AI Research.

### Data path and security
- Browser → Supabase REST RPC `public.platform_public_catalogue_browse(text,text,integer,integer)`.
- RPC returns active categories with public counts and paginated active `customer_visible` product labels only.
- Public product fields: category, category slug, manufacturer, model, package name, product type and branch name.
- No direct client SELECT is granted on master catalogue tables; existing deny-direct-client-access RLS policies remain in force.
- RPC is SECURITY DEFINER with fixed `search_path = public, pg_catalog`, no tenant parameter, read-only, and grants EXECUTE to anon/authenticated. It does not return evidence, IDs, prices, notes, valuation settings or tenant/customer data.
- TEST project `nnsshnfkjcflucjrftzi`; LIVE project `gxsrajtqzdjvmceqcpgv`. JS URL and publishable key must remain environment-specific.
- Migration `20261105010000_platform_public_catalogue_browser.sql` applied independently in TEST and LIVE.
- Page size defaults to 24 and is clamped to 48; never load the complete catalogue in one browser request.

### Failure points / acceptance
- Empty dropdown: check script loaded, correct environment URL/key, RPC execute grants, active category/product data.
- No product results: check category slug, active/customer_visible flags, manufacturer/category active flags and RPC response.
- Search mismatch: inspect the RPC's manufacturer/model/package/product_type matching; do not expose internal notes or evidence as a workaround.
- Category URL not filtering first page: ensure query string is read before the initial RPC request.
- Verify dropdown keyboard/click/mobile operation, search, category filter, result cards and pagination in both TEST and LIVE browsers. GitHub merge alone does not prove Worker deployment.



## Current source-of-truth correction — 7 November 2026

- `how-it-works.html` is the published source of truth for the How It Works guide. It contains ten native HTML `details` accordion sections, with presentation in `how-it-works.css`. It is text-only and does not load `platform-public-pages.js`.
- The old `platform_public_pages` row for `how-it-works` remains in TEST and LIVE for historical continuity, but the static guide does not consume its `draft_content` or `published_content`.
- The Owner Dashboard's legacy CMS editor still loads the How It Works row. Saving that record does not alter the static public guide. The dashboard now displays an explicit note so the limitation is not mistaken for a working publish path. If in-dashboard editing is required later, it needs a deliberate accordion-schema/editor/renderer implementation; do not silently re-enable the old screenshot/visual-layout renderer.
- `examples` remains the database-backed editable public page and uses the existing owner save/publish RPCs.
- The How It Works source has ten accordions covering subscription, website template, Website Builder, catalogue/research, payment setup, valuation, customer payment, shipping, inventory/retail and day-to-day management. It includes a GearCashOut example link. Browser rendering still requires authenticated desktop/mobile acceptance; source inspection alone is not live verification.


## Owner dashboard accordion layout — 7 November 2026

The Platform Owner dashboard now has a consistent collapsible-section layout on branch `feature/owner-dashboard-dropdown-sections-20261107` (PR [#266](https://github.com/laurendigitaluk/TradeFlow/pull/266)). It wraps the existing product pages, subscriber businesses, domain requests, plans, public pages, Gemma, complimentary-subscriber and platform-email panels in native `details` elements. Sidebar hash navigation opens the selected panel. No RPC, database, authentication or permission behaviour is changed by the layout work.
