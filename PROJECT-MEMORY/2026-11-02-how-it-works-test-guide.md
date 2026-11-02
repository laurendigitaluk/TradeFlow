# Project Memory — TradeFlow public process guide

Updated: 2 November 2026

Authoritative deployment mapping:
- TEST: GitHub `cloudflare-test` → Cloudflare Worker `tradeflow-test` → Supabase `nnsshnfkjcflucjrftzi`.
- LIVE: GitHub `production` → Cloudflare Worker `tradeflow` → Supabase `gxsrajtqzdjvmceqcpgv`.
- Retired Supabase `twfbmjwwqzxdxvclxbun` is prohibited.
- `main` is not the TEST deployment branch. The `main` and `cloudflare-test` branches are substantially diverged; do not merge them wholesale.

Public guide:
- Files: `how-it-works.html`, `how-it-works.css`.
- Homepage entry points: navigation, hero CTA, workflow summary and footer.
- Static HTML/CSS only; no Supabase or external service calls.
- Process: Valuation → Offer → Shipping → Received → Inspection → Payment → Complete, followed by Inventory → Prepare listing → Publish to shop → Sale & fulfilment.
- Shipping is subscriber-arranged outside TradeFlow. Payment is subscriber-recorded; no automated payout is represented.
- Keep customer/subscriber buying process separate from retail inventory/selling.
- Deploy and verify on TEST only; do not touch LIVE without explicit approval.


## Real screenshots embedded — 2 November 2026
The public page now embeds four optimised WebP screenshots directly in `how-it-works.html`: customer progress, inspection decision, inventory and customer-facing shop. Internal item references and the inventory asset identifier were obscured; customer names, URLs, emails, bank details and transaction references are not displayed. The screenshot sections explain the real screens alongside the process. CSS is cache-busted to `how-it-works.css?v=3`. Static HTML/CSS only; no backend or Supabase dependency.

Prepared on feature branch `feature/how-it-works-real-screenshots-20261102` for TEST only. Target TEST Worker: `tradeflow-test`. No Supabase, Stripe, tenant/customer data or LIVE configuration changed. After merge, verify the Cloudflare TEST deployment and inspect the page at `https://tradeflow-test.leannelaurenlowe.workers.dev/how-it-works.html`, including mobile layout and all four screenshots. GitHub merge alone does not prove deployment. Do not promote to LIVE without explicit approval.


## Presentation correction — 2 November 2026
Following review of the first published layout, the seven-stage tile strip was removed. The page is now a screenshot-led walkthrough: four full, real TradeFlow screen examples appear immediately after the hero, before the process explanation. They show customer progress, subscriber inspection decision, inventory and the public customer shop. Screenshots are large, alternating text/image sections, with the original embedded WebP images retained; no generated or mock screenshots. The stage sequence is now a simple numbered list rather than cards. Screenshot images are eager-loaded only for the first image and lazy-loaded for the remaining examples. The page remains static HTML/CSS and TEST-only. Confirm the Cloudflare TEST deployment after merge; no LIVE promotion without approval.


## Customer and subscriber side-by-side examples — 2 November 2026

The opening of the How It Works page now directly compares the two sides of the platform in one responsive, two-column section, under the headline “Two sides of every TradeFlow transaction”. The left example shows the subscriber business dashboard and is captioned “The business manages buying and selling”. The right example shows the customer valuation wizard at the category-selection step and is captioned “The customer chooses what they have to sell”. Both are crops from the user's actual supplied side-by-side screenshot, not generated illustrations. Browser chrome and taskbars are excluded. Subscriber business/account identity fields are blurred. The pair is presented before the later workflow examples.

The separate later screenshot walkthrough retains the real subscriber inspection decision, inventory and customer-facing shop screens. The redundant customer-progress example has been removed. There are now five embedded WebP images in the page: two in the side-by-side introduction and three later examples. Stylesheet cache key is `how-it-works.css?v=4`; the comparison stacks on narrow screens. The seven process stages remain a plain numbered sequence, not tiles/cards.

This is static HTML/CSS on TEST only, with no backend, Supabase or Stripe changes. Branch: `feature/customer-subscriber-side-by-side-20261102`, intended base: `cloudflare-test`, Worker: `tradeflow-test`. No LIVE configuration, customer records or tenant data were changed. After merge, verify the new TEST Worker deployment and confirm the pair is side by side at desktop width and stacked at mobile width. Do not promote to LIVE without explicit approval.
