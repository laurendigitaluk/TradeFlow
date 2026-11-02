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
