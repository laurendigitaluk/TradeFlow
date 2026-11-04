# Checkpoint — Public catalogue and AI research page — 4 November 2026

## User request
Add a public landing-page link and sample page showing the growing range of product categories and explaining how AI-assisted research adds and refreshes UK market evidence. Implement in TEST and LIVE for user review.

## Implementation
- New static page: `catalogue-research.html`.
- New responsive stylesheet: `catalogue-research.css`.
- Add navigation link to the landing page and How It Works page.
- Use the existing shared public header, footer, typography, navy/amber palette and CTA styles.
- Text-led page only: no screenshots or illustrative images.

## Content
- Category examples: drones; phones/tablets; cameras/lenses; gaming; 3D printers; metal detectors; laptops/computers; audio/video; trading cards/collectibles.
- Explain catalogue growth as ongoing and the examples as illustrative, not exhaustive.
- Describe exact model/variant matching, UK market research, duplicate/mismatch checks, evidence source and observation metadata, and ongoing refresh as research progresses.
- Distinguish UK new-market evidence (may support automatic valuation guidance where supported) from used-market observations (reference only, not a direct automatic valuation input).
- Explain that the master catalogue is separate from each business's own website listings and the business makes the final offer decision.

## Safety and environment boundaries
- No Supabase schema or data changes are required for this static page.
- Do not copy catalogue, evidence, tenant, customer, transaction, domain, Stripe or subscription data between environments.
- LIVE and TEST catalogue counts differed during the read-only preflight; do not hard-code a single product/category/evidence count on the public page.
- Keep TEST and LIVE releases separate and verify the corresponding Worker and public route after merge/deployment.

## Branches
- TEST: `feature/catalogue-ai-research-page-test-20261104` (base `cloudflare-test`).
- LIVE: `feature/catalogue-ai-research-page-live-20261104` (base `production`).

## Verification still required
- PR preview build and page rendering.
- TEST deployment and desktop/mobile navigation/page checks.
- Then merge/promote the same change to LIVE and independently verify the LIVE Worker and route.
