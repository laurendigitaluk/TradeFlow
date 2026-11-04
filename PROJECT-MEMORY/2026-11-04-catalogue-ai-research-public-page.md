# Project memory — Public catalogue and AI research page — 4 November 2026

The user requested a dedicated public landing-page destination explaining that TradeFlow's product catalogue is continually expanding into thousands of products, and showing how AI-assisted research checks and refreshes UK market evidence.

Implementation:
- `catalogue-research.html` with `catalogue-research.css`.
- Link from landing-page navigation and How It Works navigation.
- Match existing TradeFlow public styling (shared header/footer, navy/amber palette, typography and buttons).
- Text-led responsive layout; no screenshots or illustrative images.
- Category examples: drones, phones/tablets, cameras/lenses, gaming, 3D printers, metal detectors, computers, audio/video and collectibles.
- Explain ongoing additions, exact product/variant matching, UK source research, duplicate/mismatch checks, source-linked evidence metadata and continued refresh.
- UK new-market evidence may support automatic valuation guidance where supported; used-market observations are reference only and do not directly determine automatic buying valuations.
- Master catalogue selection does not automatically publish a product to a business's own website. Business retains the final buying decision.

No Supabase schema/data changes are part of this public page. TEST and LIVE catalogue datasets are distinct and were not synced; read-only preflight showed different counts. Do not hard-code a global catalogue count or move tenant/customer/transaction/Stripe/subscription data between environments.

Branches:
- TEST: `feature/catalogue-ai-research-page-test-20261104`, based on `cloudflare-test`.
- LIVE: `feature/catalogue-ai-research-page-live-20261104`, based on `production`.

Do not claim completion until TEST PR preview, TEST Worker deployment, and desktop/mobile route checks pass; then repeat promotion and independent verification for LIVE.

## Release update — 4 November 2026
- LIVE PR #231 merged into `production`: `0381801bd37b7d0b5b9bf3949455de2d81866c83`.
- The page and both navigation links are present in the merged LIVE source.
- Cloudflare deployment status and browser rendering could not be independently confirmed from the available deployment/status interfaces in this session. Do not mark LIVE runtime verification complete until checked in the browser.
- TEST PR #230 merged into `cloudflare-test`: `13fc852a767f2cec134acc304e42b56beb76caec`.
- No Supabase project-memory/checkpoint tables were found in the linked LIVE or TEST databases; the durable checkpoint and project memory are maintained in the repository files above. No database write was made.

## Navigation consistency follow-up — 4 November 2026
The Catalogue & AI Research top-nav link was initially added only to the homepage and How It Works. User screenshot showed it missing on Plans & Features. Corrected all primary public pages: plans, examples, contact-us, terms, privacy, and ensured homepage, How It Works and Catalogue & AI Research retain it. Link order: immediately after Plans & Features. Standardise Contact Us label; remove legacy About label. No Supabase/database changes. TEST and LIVE source branches are maintained independently; confirm Worker deployment and browser rendering after merge.
