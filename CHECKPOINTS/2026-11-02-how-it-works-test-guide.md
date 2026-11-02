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
