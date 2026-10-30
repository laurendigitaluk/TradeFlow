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
