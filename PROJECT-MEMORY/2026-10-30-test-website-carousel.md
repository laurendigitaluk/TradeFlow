# Project Memory — 2026-10-30 — TEST Website Carousel / Slider

- User approved a reusable carousel component in the existing single Fully Editable Website Builder template. The user explicitly corrected that ten templates had been removed; do not reintroduce a template family. Different background presets/custom colours remain available.
- Implemented in TEST branch cloudflare-test only. Pre-change restore branch: checkpoint-pre-carousel-test-20261030.
- TEST Supabase is nnsshnfkjcflucjrftzi; LIVE is gxsrajtqzdjvmceqcpgv. Retired TEST twfbmjwwqzxdxvclxbun must never be used. LIVE was not changed.
- Carousel modes: Image Gallery, Sliding Cards, Full Content Slides. Slide fields: image, heading, description, CTA label and destination. Add/remove/reorder, maximum 12; settings include slide/fade, arrows/dots/both/none and optional autoplay interval. Supports public arrows/dots, keyboard, swipe, responsive card counts, hover/focus pause and reduced motion.
- JSON storage only: site.homepage.carousel and site.pages[].carousel inside existing site_revisions.content. Existing image bucket tradeflow-site-media and media_assets reused. No DB schema change or data write.
- TEST code source uses the production single-template editor/public renderer as the baseline, with TEST auth/Worker separation preserved and public runtime pointed at the current TEST project. Test branch had drifted and still contained old ten-template code, so this baseline alignment was necessary before the carousel work.
- Static parse and CSS brace checks passed. Browser, deployment, Save/Reload/Preview/Publish and interaction acceptance remain pending. Git commit does not prove Cloudflare deployment. Do not port to LIVE until TEST acceptance succeeds.
