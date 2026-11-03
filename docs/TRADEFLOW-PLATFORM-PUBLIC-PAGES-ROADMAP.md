# TradeFlow Platform Public Pages — Diagnostic Roadmap
Date: 3 November 2026
Status: Implemented on feature branch; TEST database migration applied; browser/deployment acceptance pending.

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
- LIVE code has now been updated in parallel through PR #205; see the parallel LIVE delivery update below. LIVE data remains in its own Supabase project.

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
8. User explicitly confirmed parallel LIVE and TEST development; keep the two branches and databases aligned without sharing tenant/customer data.


The follow-up migration `20261103183500_owner_public_pages_explicit_deny.sql` adds explicit deny policies for `anon` and `authenticated` direct table access. Security read-back confirmed RLS enabled, two deny policies, no direct SELECT privilege, owner RPCs executable only by authenticated users, and public read RPC executable by anon. The Supabase advisor still reports the public `platform_public_page_get(text)` SECURITY DEFINER function; this is intentional because it returns only published JSON for the two allow-listed page slugs, while direct table access remains denied. This finding is documented, not ignored.


## Merge and deployment status — 3 November 2026
- PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- TEST branch HEAD was read back at that merge commit. The `production` branch was not modified by this work.
- GitHub reports no workflow runs or commit statuses for this commit. The TEST Worker URL could not be independently opened from the available browser check, so Cloudflare deployment/runtime remains unverified.
- Next browser check: open `https://tradeflow-test.leannelaurenlowe.workers.dev/platform-owner-dashboard.html`, hard-refresh, sign in, and confirm the Public Website Pages editor. Do not treat the GitHub merge as proof of deployment.


## Parallel LIVE delivery update — 3 November 2026
The user confirmed that TradeFlow is being built in LIVE and TEST simultaneously. Matching owner-editable public page CMS code has now also been merged to LIVE PR #205, merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`. LIVE branch is `production`, Worker `tradeflow`, Supabase `gxsrajtqzdjvmceqcpgv`. LIVE migrations `20261103183000_owner_editable_public_pages` and `20261103183500_owner_public_pages_explicit_deny` were applied successfully. LIVE How It Works page and stylesheet were added because the page did not exist on production. LIVE editor/renderer use LIVE Supabase URL/key. Each environment retains separate page content. No customer/tenant/transaction/Stripe data copied.

Both branches now contain the feature. Cloudflare deployment/runtime and authenticated browser acceptance remain unverified because direct Worker URLs could not be opened by the available browser check. The screenshot of TEST showing the old menu and Failed to fetch is consistent with an older Worker asset still being served; it does not prove the merged branch source is faulty. Check actual Worker deployment commit and browser network request before altering auth configuration.


## Platform-owner visual public page designer — 3 November 2026

Replace the rejected nested text form with a drag-and-drop visual canvas for the How It Works and Examples public pages. This is separate from the locked subscriber Website Builder. Owner can add text, image and screenshot boxes; drag them to position; resize them; edit text, image alt text, background, layout and numeric position/size; duplicate/delete; upload/replace/remove images; and save draft, preview and publish through the existing owner RPCs. Composition is stored in `draft_content.visual_layout` in `public.platform_public_pages`.

A new `platform-public-media` public bucket accepts PNG/JPEG/WebP up to 8 MB. Write policies require an authenticated active `platform_memberships` record and an object path prefixed with the user's UUID. Original embedded How It Works screenshots remain the public fallback until replaced. Migration `20261103210000_platform_public_media_owner_uploads` has been applied separately to TEST (`nnsshnfkjcflucjrftzi`) and LIVE (`gxsrajtqzdjvmceqcpgv`). Bucket and three owner-write policies were read back in both. JS syntax parsed in the connector runtime for editor and renderer in both feature branches. PR merge, Cloudflare deployment and browser acceptance remain pending; test drag/resize/upload/save/preview/publish and mobile layout before calling complete.
