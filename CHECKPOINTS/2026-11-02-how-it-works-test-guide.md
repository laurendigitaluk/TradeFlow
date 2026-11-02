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
