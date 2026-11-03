# Project Memory — Owner-editable public pages — 3 November 2026

User asked to be able to build and edit TradeFlow's public **How It Works** and **Examples** pages from the platform owner dashboard. Do not keep making one-off static HTML edits as the normal workflow.

Authoritative distinction:
- Platform public marketing pages: platform-owner CMS, two page slugs only.
- Subscriber Website Builder: tenant-scoped, controls each subscriber's storefront. Do not reuse subscriber tenant content tables for platform marketing pages.

Current implementation on feature branch `feature/owner-editable-public-pages-20261103`, targeting `cloudflare-test`:
- `platform-owner-dashboard.html` adds Public Website Pages panel.
- `platform-public-pages-editor.js` generic nested editor with save draft, preview draft, publish, repeatable/reorderable lists/cards.
- `platform-public-pages.js` public renderer shared by `how-it-works.html`, `examples.html`, `index.html`.
- TEST owner dashboard connection corrected from retired Supabase project to `nnsshnfkjcflucjrftzi` using current TEST publishable key from wrangler config.
- New TEST table `public.platform_public_pages`; RLS enabled; no direct client table access. Owner RPCs validate active platform membership. Public read RPC exposes published content only.
- Draft and published JSON seeded for both pages. Four fixed screenshot slots on How It Works permit title/description/image URL/alt/caption edits; blank image URL preserves embedded WebP screenshot. Images are changed by URL; no upload/storage bucket is implemented in this iteration.
- Examples cards, copy, mockup nav/hero/product labels are editable; list order and add/remove supported.
- TEST migration `20261103183000_owner_editable_public_pages` applied and recorded.

Verified:
- Database row read-back and screenshot slot count.
- RPC grants.
- JS parse checks passed.
- Retired project URL absent from platform owner dashboard JS.
Not verified:
- Authenticated browser journey, draft persistence/preview, publish effect and Cloudflare TEST deployment.
- No LIVE changes.

Next:
1. Create/review PR into `cloudflare-test`.
2. Deploy via established TEST Worker process; verify runtime.
3. Browser acceptance as listed in `CHECKPOINTS/2026-11-03-owner-editable-public-pages.md`.
4. Do not promote to LIVE without explicit user approval.


The follow-up migration `20261103183500_owner_public_pages_explicit_deny.sql` adds explicit deny policies for `anon` and `authenticated` direct table access. Security read-back confirmed RLS enabled, two deny policies, no direct SELECT privilege, owner RPCs executable only by authenticated users, and public read RPC executable by anon. The Supabase advisor still reports the public `platform_public_page_get(text)` SECURITY DEFINER function; this is intentional because it returns only published JSON for the two allow-listed page slugs, while direct table access remains denied. This finding is documented, not ignored.


## Merge and deployment status — 3 November 2026
- PR #204 merged into `cloudflare-test` with merge commit `204b3bbc286018d49ad1f4700ba2964c0bbbef28`.
- TEST branch HEAD was read back at that merge commit. The `production` branch was not modified by this work.
- GitHub reports no workflow runs or commit statuses for this commit. The TEST Worker URL could not be independently opened from the available browser check, so Cloudflare deployment/runtime remains unverified.
- Next browser check: open `https://tradeflow-test.leannelaurenlowe.workers.dev/platform-owner-dashboard.html`, hard-refresh, sign in, and confirm the Public Website Pages editor. Do not treat the GitHub merge as proof of deployment.


## Parallel LIVE delivery update — 3 November 2026
The user confirmed that TradeFlow is being built in LIVE and TEST simultaneously. Matching owner-editable public page CMS code has now also been merged to LIVE PR #205, merge commit `f3cabb78556ccca1898d459c68c09acb5bb54f8a`. LIVE branch is `production`, Worker `tradeflow`, Supabase `gxsrajtqzdjvmceqcpgv`. LIVE migrations `20261103183000_owner_editable_public_pages` and `20261103183500_owner_public_pages_explicit_deny` were applied successfully. LIVE How It Works page and stylesheet were added because the page did not exist on production. LIVE editor/renderer use LIVE Supabase URL/key. Each environment retains separate page content. No customer/tenant/transaction/Stripe data copied.

Both branches now contain the feature. Cloudflare deployment/runtime and authenticated browser acceptance remain unverified because direct Worker URLs could not be opened by the available browser check. The screenshot of TEST showing the old menu and Failed to fetch is consistent with an older Worker asset still being served; it does not prove the merged branch source is faulty. Check actual Worker deployment commit and browser network request before altering auth configuration.
