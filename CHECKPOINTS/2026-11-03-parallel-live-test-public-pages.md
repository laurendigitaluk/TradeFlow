# Checkpoint — Parallel LIVE and TEST public page editor — 3 November 2026

## User decision
User confirmed TradeFlow public page editing is being built in LIVE and TEST simultaneously. Maintain matching feature behaviour in both environments; do not make TEST a prerequisite for LIVE.

## Scope
Platform owner CMS for public marketing pages **How It Works** and **Examples**, including homepage Examples preview. Separate from subscriber Website Builder.

## Environments
- TEST branch `cloudflare-test`; Worker `tradeflow-test`; Supabase `nnsshnfkjcflucjrftzi`.
- LIVE branch `production`; Worker `tradeflow`; Supabase `gxsrajtqzdjvmceqcpgv`.
- Current LIVE feature branch: `feature/owner-editable-public-pages-live-20261103`.
- TEST PR #204 merged; TEST branch has CMS source.
- Retired project `twfbmjwwqzxdxvclxbun` forbidden.
- Environment-specific renderer/editor JS credentials are set to the matching Supabase project. Do not copy TEST URL/key into LIVE or vice versa.

## Database
Migrations applied to both projects:
- `20261103183000_owner_editable_public_pages`
- `20261103183500_owner_public_pages_explicit_deny`

Creates `public.platform_public_pages`, seeded with `how-it-works` and `examples` content (insert on conflict do nothing). RLS enabled; explicit deny policies and direct table grants revoked. Owner RPCs require active `platform_memberships`; public read RPC returns only published content for allow-listed slugs. Owner memberships exist in both environments. Each database keeps its own independent copy of page content.

## LIVE code branch implementation
- `platform-owner-dashboard.html`: adds Public Website Pages menu/panel, editor script, cache-busting.
- `platform-owner-dashboard.js`: existing LIVE owner authentication retained; added editor initial load after sign-in and on restored session.
- `platform-public-pages-editor.js`: owner editor; LIVE Supabase URL and publishable key.
- `platform-public-pages.js`: shared public renderer; LIVE Supabase URL and publishable key.
- `how-it-works.html` and `how-it-works.css`: added to LIVE (the guide file was absent from production branch).
- `examples.html` and `index.html`: connected to public renderer.
- `platform-owner-dashboard.css`: editor styles appended without replacing existing LIVE styling.
- Migration source files and both manuals updated.

## Features
- Edit text, descriptions, process/responsibility lists, examples cards, order, screenshot title/caption/alt text and image URLs.
- Four screenshot slots remain fixed; blank image URL preserves embedded high-resolution image.
- Save draft, preview draft and publish separately.
- No direct image-file upload yet.
- Public pages read published JSON only.
- No subscriber Website Builder, tenant, customer, transaction, inventory, Stripe or domain data changed.

## Verification completed
- LIVE migration applied successfully, including explicit deny policies.
- TEST migrations previously applied successfully.
- LIVE has one active platform membership; TEST has one active platform membership.
- JavaScript syntax checks passed for LIVE owner dashboard, editor and public renderer.
- LIVE editor/renderer contain LIVE URL/key.
- LIVE public How It Works page added because it was missing from production branch.
- Browser sign-in, editing, save/preview/publish and Cloudflare deployment not yet verified.

## Next
1. Finish PR from `feature/owner-editable-public-pages-live-20261103` into `production`.
2. Confirm production branch has same feature as TEST, with LIVE-specific API credentials.
3. Verify LIVE and TEST Cloudflare deployment separately.
4. Browser-test owner sign-in and CMS in both.
5. Save draft, preview, publish and verify all public views in each environment.
6. Keep page content independent across environments.


## Final LIVE merge/deployment status — 3 November 2026
- LIVE PR #205 merged into `production` with merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`.
- TEST PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- LIVE and TEST database migrations applied and access-control read-back verified; each database has its own two page records.
- JavaScript syntax checks passed for owner dashboard, editor and renderer in LIVE; environment URL/key checks passed.
- Direct Worker URL checks for LIVE and TEST were inaccessible through the available browser tool. Cloudflare deployment commit/runtime and owner browser flow remain unverified. Do not state deployment is complete until the Worker version and browser flow are confirmed.
- The user confirmed simultaneous LIVE and TEST development. Continue keeping code behaviour aligned and content/data isolated.
