# TradeFlow Public Valuation-to-Sale Explainer — Diagnostic Roadmap

Date: 2 November 2026
Status: Prepared for TEST deployment on the authoritative `cloudflare-test` branch.

## Purpose and boundary
Static public explanation of the customer buying journey and subscriber post-purchase stock/resale journey. This is not an operational workflow and has no live data dependencies.

## Deployment map
- Repository: `laurendigitaluk/TradeFlow`
- TEST source branch: `cloudflare-test`
- TEST Worker: `tradeflow-test`
- TEST Supabase: `nnsshnfkjcflucjrftzi` (not used by this page)
- LIVE source branch: `production`
- LIVE Worker: `tradeflow` (do not modify without approval)
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv` (not used by this page)
- Retired Supabase project `twfbmjwwqzxdxvclxbun` must never be used.

## User entry points
- Homepage navigation → `how-it-works.html`
- Homepage hero CTA → `how-it-works.html`
- Homepage workflow summary → `how-it-works.html`
- Homepage footer → `how-it-works.html`

## Front-end files
- `index.html`: public entry links.
- `how-it-works.html`: seven-stage buying journey, responsibility split, post-purchase stock path.
- `how-it-works.css`: responsive process layout.
- `platform.css`: shared header, buttons and footer.
- `wrangler.jsonc`: TEST Worker config on `cloudflare-test`; do not copy production config.

## Data/service dependencies
None. No Supabase tables, RPCs, triggers, RLS, Edge Functions, Auth, Storage, Stripe, courier integration, customer or tenant data.

## Process described
1. Valuation: customer submits details, condition and photographs; subscriber reviews.
2. Offer: customer accepts cash/trade-in or declines.
3. Shipping: subscriber arranges carrier outside TradeFlow and supplies label/QR, tracking and instructions.
4. Received: customer confirms dispatch; subscriber separately confirms physical receipt.
5. Inspection: subscriber accepts original offer, revises it, or refuses.
6. Payment: subscriber records payment; no automated payout.
7. Complete: item moves into inventory.
8. Resale: Inventory → prepare listing → publish to shop → sale and fulfilment.

## Verification and failure points
- Check homepage entry links resolve to the guide.
- Confirm `how-it-works.css` and shared `platform.css` load.
- Confirm responsive layout at desktop/tablet/mobile.
- Confirm no personal/customer/business identifiers or live API calls.
- Confirm Cloudflare TEST deployment shows the intended `cloudflare-test` commit.
- Confirm TEST URL serves HTTP 200 and guide content; do not infer deployment from GitHub merge alone.
- Confirm LIVE `production` branch and `tradeflow` Worker remain unchanged.
