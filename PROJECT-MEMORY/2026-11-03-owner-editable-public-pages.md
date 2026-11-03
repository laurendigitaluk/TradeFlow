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
