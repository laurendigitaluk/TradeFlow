# Developer Diagnostic Roadmap — Website Builder Carousel / Slider (TEST)

Date: 30 October 2026
Status: Implemented in TEST source; deployment/browser acceptance pending
Environment: cloudflare-test / tradeflow-test / nnsshnfkjcflucjrftzi

## User action and entry points
- Subscriber opens Website Builder (website-builder.html), selects Home, What We Buy, What We Sell, or a content page, and uses the Carousel / Slider panel.
- Subscriber adds slides, edits content in the preview, uploads images, chooses button destinations, orders slides and configures navigation/transition/autoplay.
- Save Draft persists the site JSON; Preview renders the draft; Publish promotes the draft through the existing site publication workflow.

## Front-end files and functions
- website-builder.html: sidebar container #carousel-controls, existing image file input and builder script loading.
- website-builder.js: renderCarouselControls (settings, add/remove/reorder); renderCarouselEditor (inline slide editor); currentCarousel / carouselForScope (page state); renderHome and renderPage (component placement); bindEditor (inline text and existing image-action wiring); uploadImage / removeImage (existing media lifecycle); buildContent / loadContent (JSON persistence).
- public-site.html loads the published renderer and stylesheet.
- public-site.js: renderPublicCarousel creates public markup; bindPublicCarousels binds arrows, dots, keyboard and swipe, autoplay and pause; renderHome, renderBuyingPage, renderShopPage, renderContentPage include page components; applyContent injects the rendered page.
- website-builder.css and public-site.css hold editor/public responsive and reduced-motion styles.

## Data and services
- Persistence: existing public.site_revisions.content JSON; Home path site.homepage.carousel; other page path site.pages[].carousel.
- Draft pointer: existing public.tenant_site_state.draft_revision_id; publication remains existing publish_site_revision RPC and published revision flow.
- Media: existing tradeflow-site-media Storage bucket and public.media_assets metadata; upload/delete uses existing builder functions. No new table, migration, RPC, Edge Function, or provider integration.
- Tenant boundary: authenticated tenant ID is obtained from subscriber auth; existing RLS and tenant filter continue to guard draft reads/writes. Never copy TEST site content into LIVE.
- Runtime: GitHub TEST branch → Cloudflare Worker tradeflow-test → TEST Supabase. Worker URL/key replacement must resolve to nnsshnfkjcflucjrftzi; never use retired project twfbmjwwqzxdxvclxbun.

## Expected data flow
1. Editor initializes current page carousel from site.homepage.carousel or site.pages[].carousel.
2. Settings and slide edits mutate in-memory page JSON; image upload writes file to existing bucket and metadata to media_assets.
3. Save Draft PATCHes existing draft revision content via existing site_revisions API call.
4. Reload reconstructs carousel from saved JSON.
5. Preview loads draft content into public-site.js renderer; Publish uses existing RPC; public site reads published content.
6. Public runtime binds controls and responds to arrows, dots, keyboard, swipe and optional autoplay.

## Failure points and checks
- Missing #carousel-controls or stale JS/CSS cache version → editor panel/controls missing.
- normalizeCarousel or JSON path mismatch → carousel disappears after reload.
- carousel:<scope>:<slideId> image target mismatch → upload/remove affects wrong slide or fails.
- Missing bindPublicCarousels() after app.innerHTML → controls render but do not respond.
- Cards viewport calculation / resize → cards clip or navigation stops early.
- Invalid custom URL → CTA must not emit unsafe protocol; renderer only accepts HTTP(S).
- Autoplay timer must pause on hover/focus and must not run under reduced-motion preference.
- Worker endpoint substitution/auth context → requests must stay on TEST project only.
- Existing known Website Builder parse failure: 30 October TEST repair 5836eb4... plus cache-bust bbdcb94...; preserve the current working script and re-run full JS parse check after edits.

## TEST acceptance checklist
- Only the Fully Editable template is presented; existing hero/global header drag, resize, text formatting, backgrounds, SEO, buying/selling sections remain intact.
- Add/remove carousel on Home, Buying, Shop and content page; verify component order on Home.
- Test Image Gallery, Sliding Cards and Full Content Slides; add/reorder/remove up to 12 slides.
- Upload, replace and remove images; verify old media is only deleted when no longer referenced.
- Verify CTA text and internal/external destination; reject unsafe external schemes.
- Save Draft, reload, Preview draft, Publish and confirm public revision output.
- Test desktop arrows/dots, keyboard, mobile swipe, card counts at breakpoints, autoplay on/off, pause on hover/focus, reduced motion.
- Confirm all REST calls target TEST Supabase and no LIVE data changes.

## Promotion gate
No LIVE code or data has been changed. Promote only after TEST Worker deployment and browser acceptance. Rebase/port the feature selectively to current production; do not merge the highly diverged branches wholesale.
