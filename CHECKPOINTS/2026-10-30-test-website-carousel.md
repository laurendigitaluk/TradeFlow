# Checkpoint — 2026-10-30 — TEST Website Builder Carousel / Slider

## Branch and restore
- Implementation target: cloudflare-test.
- Pre-change restore branch: checkpoint-pre-carousel-test-20261030.
- TEST Worker: tradeflow-test; TEST Supabase: nnsshnfkjcflucjrftzi.
- LIVE branch/Worker/database were not changed.

## Baseline inspected
- Current production Website Builder is the single Fully Editable template with drag-and-drop layout boxes, editable global header, custom/preset backgrounds and SEO JSON fields.
- The TEST branch source had drifted behind that baseline and still exposed the retired ten-template picker / older hero editor. TEST source was brought forward from the current production Website Builder and public renderer while retaining the TEST subscriber-auth/Worker boundary. Public runtime was corrected to use current TEST project ID nnsshnfkjcflucjrftzi and LIVE project ID gxsrajtqzdjvmceqcpgv; retired project twfbmjwwqzxdxvclxbun is not used.
- TEST database inspected read-only. Existing site_revisions records were not modified. No schema or data migration was applied.

## Feature
- Optional Carousel / Slider component on Home, What We Buy, What We Sell, and content pages.
- Modes: Image Gallery, Sliding Cards, Full Content Slides.
- Per-slide image, heading, description, CTA text and internal/external destination; add/remove/reorder, maximum 12.
- Settings: slide/fade transition, arrows/dots/both/none, optional autoplay and interval.
- Public runtime: responsive card layout, arrows, dots, keyboard, touch/pointer swipe, pause on hover/focus and reduced motion.
- Persistence in existing site_revisions.content JSON only: site.homepage.carousel and site.pages[].carousel. No new tables/RPCs/Edge Functions.
- Images reuse tradeflow-site-media and media_assets.

## Code files
website-builder.html/js/css, public-site.html/js/css. Cache-bust values incremented. System Handbook, AI Operating Manual, Human User Manual, Backend User Manual and Subscriber Website Manual updated. Diagnostic roadmap created.

## Verification status
- Static JavaScript parse checks: passed before commit.
- CSS brace-balance checks: passed before commit.
- Supabase TEST project status: ACTIVE_HEALTHY; read-only check only.
- Browser/editor/preview/publish and Cloudflare Worker deployment checks: PENDING. No Cloudflare deployment action is available in the current connected tools; do not describe the feature as live in TEST until the Worker serves the new assets and browser checks pass.
- LIVE untouched. Do not promote until TEST acceptance passes.


## Follow-up hardening and final source verification — 30 October 2026

- Fixed homepage carousel image-reference collection so cleanup retains any media still referenced by a homepage slide.
- Fixed responsive navigation dots on card carousels and image-only mode styling; added touch-action pan-y and autoplay pause while document hidden.
- Removed retired TEST project fallback from TEST subscriber-auth.js; TEST auth now selects nnsshnfkjcflucjrftzi on TEST/local hosts. Website Builder instructions now reflect one editable template and background choices.
- Final source commits: website-builder.js 6d36feca276e7f0f7f709f6cd5f4eecc8ffcbf07; website-builder.css b4f29669d2e1f68feefadb180f524c049a67c9e6; website-builder.html fdc9b056157a20a037e7c82ff7d21390e56a530a; public-site.js 83732f2c78969f3077a0ee855f7fb041532e150b; public-site.css 9cfb15c9b540b217623a713894fe22bd2a212f72; public-site.html ec07850cb808608640687db6e140090ecbe60e83; subscriber-auth.js aa4ace21b7c91ddfbf4ace6a5a1caf181cf00a9f.
- Static builder/public/auth JavaScript parse checks passed; builder/public CSS brace checks passed. Read-only TEST database query: 3 site_revisions rows, all 3 draft, 0 published; latest revision timestamp unchanged at 2026-10-30 18:57:12 UTC. No TEST database rows were changed for this feature.
- Deployment/browser verification remains pending: no Cloudflare deployment connection is available in this session and the public TEST Worker asset endpoint could not be fetched for verification. Do not claim deployed or promote to LIVE until the TEST Worker serves these assets and acceptance tests pass.
- LIVE code, database, tenant content and published websites remain untouched.


## Worker routing review

Read-only inspection of TEST wrangler.jsonc and worker/index.js confirmed the tradeflow-test Worker has TRADEFLOW_ENV=test, current TEST Supabase URL/key variables, ASSETS from the repository root, and JavaScript LIVE-to-TEST endpoint rewriting. subscriber-auth.js now selects the current TEST project. This confirms source configuration only; deployed Worker version remains unverified because no Cloudflare deployment connection or accessible public runtime was available.
