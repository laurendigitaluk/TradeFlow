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
- No LIVE code or data has been changed.

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
