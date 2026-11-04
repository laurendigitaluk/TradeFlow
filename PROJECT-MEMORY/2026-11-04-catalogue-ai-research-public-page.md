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
