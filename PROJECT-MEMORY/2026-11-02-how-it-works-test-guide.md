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
