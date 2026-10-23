# BusinessFlow isolated builder review checkpoint — 2026-10-23

## Status
Initial isolated front-end review prototype committed to:
- Branch: `feature/businessflow-isolated-builder-review-20261023`
- Base: `test/stripe-connect-test-mode-repair-20261020`
- Commit: `69cf0d7c4c8d79e1c7ec2cfeb78dd138ce423ff0`

## Scope delivered
Added `businessflow-builder-review.html`, a standalone client-side prototype for a general service-business website:
- Business name / logo text, headline, supporting copy, CTA label/destination and accent colour controls.
- Service section copy and optional homepage sections (why choose us, projects, testimonials, contact).
- Example service-business website preview with desktop/mobile width toggle.
- Local page navigation prototype with add/rename actions.
- No external dependencies and no Supabase/API requests.
- Explicit noindex/nofollow and visible TEST REVIEW ONLY label.

## Isolation guarantees in this prototype
- Does not import or modify TradeFlow Website Builder JS/CSS.
- Does not authenticate or access tenant data.
- Does not call Supabase or any Edge Function.
- Does not read/write product catalogue, buying, inventory, sales, customer, transaction, market evidence, or TradeFlow website revision tables.
- Editing state is in-memory in the current browser tab only. No server save or publish behaviour is claimed.

## Important limitations / next stage
This is a review prototype, not the integrated production-capable builder. Page controls currently demonstrate UI behaviour only; per-page content editing, persistent drafts, preview URLs, enquiry form submission, and publish flow are not connected. Do not expose as a customer-ready product or promote to LIVE.

Before persistence is added, decide and implement a separately permissioned BusinessFlow data model (or another demonstrably isolated mechanism), validate RLS and public publishing boundaries, and ensure no writes to TradeFlow operational records. Prefer the existing TEST Supabase project to avoid extra project costs, but only if isolation can be proven. No new paid project/service authorised.

## Environment / branch safety note
At checkpoint creation, the known TEST branch and production are substantially diverged (TEST branch comparison showed 133 commits ahead and 120 behind production). Do not merge or rebase blindly. The locked standard website builder checkpoint is a reference only; its branch is stale relative to production by 433 commits and must not be used as a development base.

## Verification
- GitHub accepted the new file commit.
- Static review of source: standalone HTML/CSS/JS, no Supabase endpoints, keys, imports, or external script requests.
- Browser interaction and deployment preview have not yet been run; those remain required before calling this a user-reviewable deployed TEST site.
