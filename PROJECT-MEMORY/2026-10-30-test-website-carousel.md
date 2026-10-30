# Project Memory — 2026-10-30 — TEST Website Carousel / Slider

- User approved a reusable carousel component in the existing single Fully Editable Website Builder template. The user explicitly corrected that ten templates had been removed; do not reintroduce a template family. Different background presets/custom colours remain available.
- Implemented in TEST branch cloudflare-test only. Pre-change restore branch: checkpoint-pre-carousel-test-20261030.
- TEST Supabase is nnsshnfkjcflucjrftzi; LIVE is gxsrajtqzdjvmceqcpgv. Retired TEST twfbmjwwqzxdxvclxbun must never be used. LIVE was not changed.
- Carousel modes: Image Gallery, Sliding Cards, Full Content Slides. Slide fields: image, heading, description, CTA label and destination. Add/remove/reorder, maximum 12; settings include slide/fade, arrows/dots/both/none and optional autoplay interval. Supports public arrows/dots, keyboard, swipe, responsive card counts, hover/focus pause and reduced motion.
- JSON storage only: site.homepage.carousel and site.pages[].carousel inside existing site_revisions.content. Existing image bucket tradeflow-site-media and media_assets reused. No DB schema change or data write.
- TEST code source uses the production single-template editor/public renderer as the baseline, with TEST auth/Worker separation preserved and public runtime pointed at the current TEST project. Test branch had drifted and still contained old ten-template code, so this baseline alignment was necessary before the carousel work.
- Static parse and CSS brace checks passed. Browser, deployment, Save/Reload/Preview/Publish and interaction acceptance remain pending. Git commit does not prove Cloudflare deployment. Do not port to LIVE until TEST acceptance succeeds.


## Final source verification — 30 October 2026

- Follow-up hardening: homepage carousel is included in image-reference cleanup; responsive dots rebuild on resize; image-only mode CSS class corrected; touch-action permits vertical page scrolling; autoplay pauses when tab hidden and respects reduced motion.
- TEST subscriber-auth.js no longer references retired project twfbmjwwqzxdxvclxbun. It selects current TEST project nnsshnfkjcflucjrftzi for TEST/local hosts.
- Final static JavaScript parse checks passed for website-builder.js, public-site.js and subscriber-auth.js; CSS brace checks passed. TEST database read-only count: 3 site_revisions rows, 3 drafts, 0 published; no database writes performed.
- Code commits: builder JS 6d36feca276e7f0f7f709f6cd5f4eecc8ffcbf07; public JS 83732f2c78969f3077a0ee855f7fb041532e150b; subscriber auth aa4ace21b7c91ddfbf4ace6a5a1caf181cf00a9f. Restore branch: checkpoint-pre-carousel-test-20261030.
- TEST Worker deployment and browser acceptance remain pending; no Cloudflare deploy connection was available. LIVE remains untouched.
