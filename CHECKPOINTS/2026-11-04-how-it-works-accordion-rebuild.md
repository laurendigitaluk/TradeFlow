# Checkpoint — How It Works accordion rebuild — 4 November 2026

## User decision
Discard the screenshot-led How It Works page and visual-canvas approach. Replace it with a simple public page containing expandable drop-down sections, matching the TradeFlow landing page. No page screenshots or illustrative images. Include GearCashOut.co.uk as an example website.

## Implementation
- `how-it-works.html`: rebuilt as a static source-managed page with 10 native HTML accordion sections.
- `how-it-works.css`: compact styling aligned to `platform.css` (dark navy/amber, matching typography, buttons, spacing and responsive behaviour).
- `platform-public-pages.js`: How It Works no longer reads or applies the previous CMS JSON/visual layout; Examples rendering remains unchanged.
- `platform-public-pages-visual-editor.js`: How It Works removed from the visual page editor; Examples remains editable there.
- Shared site header/footer and navigation retained. GearCashOut link opens externally with safe rel attributes.

## Content
1. TradeFlow subscription — one launch plan, £59.99/month after 30-day free trial.
2. Business website template.
3. Website Builder and draft/preview/publish.
4. Master product catalogue and AI-assisted research; UK new-market evidence may support automatic valuation guidance; used-market evidence is reference only.
5. Connecting the business's Stripe payment account for retail customer payments; separate from TradeFlow subscription billing.
6. Customer valuation submission, business review, cash/trade-in offers, customer decision and inspection.
7. Business-managed customer payment; TradeFlow records payment and purchase completion but does not automatically pay customers.
8. Manual shipping settings and handoff; carrier booking/payment is outside TradeFlow.
9. Inventory, listing preparation, retail shop, orders and fulfilment.
10. Day-to-day dashboard and business management.

## Boundaries
- Subscriber Website Builder, customer/tenant workflows, Stripe configuration, catalogue data and all operational data remain untouched.
- Existing public page database rows are retained but ignored for How It Works rendering. No database migration or data write is required.
- Do not claim Cloudflare deployment until the matching Worker commit and browser rendering are verified independently.

## Branches
- LIVE: `feature/how-it-works-accordion-live-20261104` based on `production`.
- TEST: `feature/how-it-works-accordion-test-20261104` based on `cloudflare-test`.
- PRs and Cloudflare deployments are pending.


## Follow-up routing correction — 4 November 2026
The LIVE homepage was still routing its header "How it works" link and hero "See how it works" CTA to the old homepage `#how` preview section. TEST already routed both links to the dedicated guide. LIVE was corrected in PR #218, merged to `production` as `69ac4df6c171a767daee30777a576ad27a93c3ac`. Verified source in both branches now targets `how-it-works.html` for the header and hero CTA. The user screenshot showed the Cloudflare production rebuild queued; deployment and live browser rendering remain to be confirmed. No Supabase/database/customer/tenant/payment data changed.
