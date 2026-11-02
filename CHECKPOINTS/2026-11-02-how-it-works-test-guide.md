# Checkpoint — Public How It Works guide on TEST

Date: 2 November 2026
Scope: TradeFlow public static website only.

## Environment authority
- TEST GitHub branch: `cloudflare-test`
- TEST Cloudflare Worker: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi`
- LIVE GitHub branch: `production`
- LIVE Cloudflare Worker: `tradeflow`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- Retired Supabase `twfbmjwwqzxdxvclxbun`: never use.

## Change
- Add concise visual `how-it-works.html` with seven customer stages and separate post-purchase stock path.
- Add responsive `how-it-works.css`.
- Update homepage navigation, hero CTA, workflow summary and footer to open the page.
- Keep homepage examples gallery unchanged.
- No backend, Supabase, Stripe, courier or customer-data changes.

## Process contract
Valuation → Offer → Shipping → Received → Inspection → Payment → Complete.
Then Inventory → Prepare listing → Publish to shop → Sale & fulfilment.
Subscriber arranges shipping outside TradeFlow. Subscriber records payment; no automatic customer payout. Original accepted offer can proceed without repeat acceptance if inspection does not change it.

## Deployment
This checkpoint targets TEST only. Cloudflare TEST Worker is connected to the `cloudflare-test` branch. Verify its deployment history and exact Worker URL after merge. LIVE `production` and Worker `tradeflow` must remain unchanged.

## Known risk / history
- `main` and `cloudflare-test` are substantially diverged; never merge `main` wholesale to obtain this static page. Transfer only scoped reviewed files.
- Earlier attempts used incorrect Worker URLs. The authoritative TEST Worker is `tradeflow-test`.


## Real screenshots embedded — 2 November 2026
The public page now embeds four optimised WebP screenshots directly in `how-it-works.html`: customer progress, inspection decision, inventory and customer-facing shop. Internal item references and the inventory asset identifier were obscured; customer names, URLs, emails, bank details and transaction references are not displayed. The screenshot sections explain the real screens alongside the process. CSS is cache-busted to `how-it-works.css?v=3`. Static HTML/CSS only; no backend or Supabase dependency.

Prepared on feature branch `feature/how-it-works-real-screenshots-20261102` for TEST only. Target TEST Worker: `tradeflow-test`. No Supabase, Stripe, tenant/customer data or LIVE configuration changed. After merge, verify the Cloudflare TEST deployment and inspect the page at `https://tradeflow-test.leannelaurenlowe.workers.dev/how-it-works.html`, including mobile layout and all four screenshots. GitHub merge alone does not prove deployment. Do not promote to LIVE without explicit approval.


## Presentation correction — 2 November 2026
Following review of the first published layout, the seven-stage tile strip was removed. The page is now a screenshot-led walkthrough: four full, real TradeFlow screen examples appear immediately after the hero, before the process explanation. They show customer progress, subscriber inspection decision, inventory and the public customer shop. Screenshots are large, alternating text/image sections, with the original embedded WebP images retained; no generated or mock screenshots. The stage sequence is now a simple numbered list rather than cards. Screenshot images are eager-loaded only for the first image and lazy-loaded for the remaining examples. The page remains static HTML/CSS and TEST-only. Confirm the Cloudflare TEST deployment after merge; no LIVE promotion without approval.


## Customer and subscriber side-by-side examples — 2 November 2026

The opening of the How It Works page now directly compares the two sides of the platform in one responsive, two-column section, under the headline “Two sides of every TradeFlow transaction”. The left example shows the subscriber business dashboard and is captioned “The business manages buying and selling”. The right example shows the customer valuation wizard at the category-selection step and is captioned “The customer chooses what they have to sell”. Both are crops from the user's actual supplied side-by-side screenshot, not generated illustrations. Browser chrome and taskbars are excluded. Subscriber business/account identity fields are blurred. The pair is presented before the later workflow examples.

The separate later screenshot walkthrough retains the real subscriber inspection decision, inventory and customer-facing shop screens. The redundant customer-progress example has been removed. The comparison is one composite WebP screenshot, followed by three later examples (four embedded images total). Stylesheet cache key is `how-it-works.css?v=4`; the comparison stacks on narrow screens. The seven process stages remain a plain numbered sequence, not tiles/cards.

This is static HTML/CSS on TEST only, with no backend, Supabase or Stripe changes. Branch: `feature/customer-subscriber-side-by-side-20261102`, intended base: `cloudflare-test`, Worker: `tradeflow-test`. No LIVE configuration, customer records or tenant data were changed. After merge, verify the new TEST Worker deployment and confirm the pair is side by side at desktop width and stacked at mobile width. Do not promote to LIVE without explicit approval.


## Final comparison layout correction — 2 November 2026
The side-by-side introduction uses one composite WebP screenshot, not two duplicated images. It visibly shows the redacted subscriber dashboard on the left and the customer valuation wizard on the right, with two separate explanatory captions underneath. The caption on the customer side reads “The customer chooses what they have to sell”. The remaining walkthrough retains three separate real screenshots: inspection decision, inventory and public shop. Total embedded images: four. Stylesheet URL: `how-it-works.css?v=5`. Desktop shows the two screenshot panes side by side within the composite; the two captions stack on mobile. This is the definitive intended presentation for the next TEST deployment.


## Original-resolution screenshot replacement — 2 November 2026
The four screenshots on the public How It Works page have been rebuilt from the original full-resolution desktop captures, rather than reusing the earlier reduced 720px images. The opening composite is 2058 × 486 pixels and preserves the subscriber business dashboard on the left beside the customer valuation wizard on the right. The inspection decision, inventory and customer shop captures are each approximately 1024 × 486 pixels. All are delivered as separate WebP assets at quality 88, with responsive CSS that does not impose a low max-height or resample the source to 720px. Browser chrome/taskbars were cropped; subscriber business name/email/account labels and the public shop footer business name/test-only description were obscured. No customer identity, personal email, bank details or transaction references are published.

Asset paths: `how-it-works-assets/comparison.webp`, `inspection-decision.webp`, `inventory.webp`, and `customer-shop.webp`. Page stylesheet cache-buster: `how-it-works.css?v=6`. Static website only; no Supabase, Stripe, tenant/customer data or LIVE configuration changed. After merge, verify the Cloudflare TEST Worker serves the four assets and that the comparison remains side-by-side on desktop. Do not promote to LIVE without explicit approval.
