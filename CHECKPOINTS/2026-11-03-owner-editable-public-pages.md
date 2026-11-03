# Checkpoint — Owner-editable public pages (3 November 2026)

## Scope
Add platform-owner editing for TradeFlow public marketing pages **How It Works** and **Examples**, including the homepage Examples preview. Separate from subscriber Website Builder.

## Branch and environment
- Feature branch: `feature/owner-editable-public-pages-20261103`
- Intended target: `cloudflare-test`
- TEST Worker: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE `production`, Worker `tradeflow`, Supabase `gxsrajtqzdjvmceqcpgv` unchanged.
- Retired Supabase project `twfbmjwwqzxdxvclxbun` not used.

## Implementation
- Added **Public Website Pages** to `platform-owner-dashboard.html`.
- Added generic nested JSON editor in `platform-public-pages-editor.js`: text fields, long descriptions, image URL fields, repeatable lists/cards, reorder/add/remove where supported, save draft, preview draft and publish.
- Four How It Works screenshot slots are fixed to preserve current layout. Each supports editable title, description, image URL, alt text and caption. Blank image URL retains the existing embedded WebP screenshot.
- Added shared renderer `platform-public-pages.js` to How It Works, Examples and homepage.
- Corrected stale retired TEST Supabase URL/key in `platform-owner-dashboard.js` to the authoritative TEST values from `wrangler.jsonc`.
- Added owner editor CSS and cache-busting.
- Added migration `supabase/migrations/20261103183000_owner_editable_public_pages.sql`.

## Database
- TEST `public.platform_public_pages` created with RLS enabled and direct client table access revoked.
- Seeded `how-it-works` and `examples` draft/published JSON content.
- Owner-only RPCs: `platform_owner_get_public_pages()`, `platform_owner_save_public_page(text,text,jsonb)`, `platform_owner_publish_public_page(text)`.
- Public read-only RPC: `platform_public_page_get(text)`.
- Active platform membership checked inside each owner SECURITY DEFINER function; fixed search_path.
- Migration applied to TEST and recorded in migration history.
- No subscriber tenant, customer, transaction, domain, Stripe or inventory data changed.

## Verification
- Database read-back: both rows present and published; four How It Works screenshot slots present.
- Public read RPC anon execute grant verified; authenticated owner RPC execute grant verified.
- JavaScript syntax parse: owner dashboard, editor and public renderer all PASS.
- Retired project URL removed from owner dashboard source.
- Cloudflare deployment and authenticated browser workflow NOT YET VERIFIED.

## Browser acceptance still required
1. Open TEST `/platform-owner-dashboard.html`; sign in.
2. Confirm Public Website Pages editor loads both pages.
3. Edit text/list/card, save draft, reload and confirm persistence.
4. Preview draft; verify published page remains unchanged.
5. Publish and confirm How It Works, Examples and homepage preview update.
6. Test image URL replacement and responsive layout.
7. Confirm Cloudflare TEST deployment commit/runtime.
8. Keep LIVE untouched unless explicitly approved.


The follow-up migration `20261103183500_owner_public_pages_explicit_deny.sql` adds explicit deny policies for `anon` and `authenticated` direct table access. Security read-back confirmed RLS enabled, two deny policies, no direct SELECT privilege, owner RPCs executable only by authenticated users, and public read RPC executable by anon. The Supabase advisor still reports the public `platform_public_page_get(text)` SECURITY DEFINER function; this is intentional because it returns only published JSON for the two allow-listed page slugs, while direct table access remains denied. This finding is documented, not ignored.


## Merge and deployment status — 3 November 2026
- PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- TEST branch HEAD was read back at that merge commit. The `production` branch was not modified by this work.
- GitHub reports no workflow runs or commit statuses for this commit. The TEST Worker URL could not be independently opened from the available browser check, so Cloudflare deployment/runtime remains unverified.
- Next browser check: open `https://tradeflow-test.leannelaurenlowe.workers.dev/platform-owner-dashboard.html`, hard-refresh, sign in, and confirm the Public Website Pages editor. Do not treat the GitHub merge as proof of deployment.
