# Checkpoint — TradeFlow How It Works public page
Date: 2 November 2026
Branch: `feature/tradeflow-how-it-works-page-20261102-v2` (based on latest TEST branch `main`)
Scope: public SaaS marketing page only.

## Delivered
- Added `how-it-works.html` with a customer-facing explanation of the seven-stage buying tracker.
- Added `how-it-works.css` with responsive workflow cards, customer/subscriber responsibility panels, detailed stage explanations and separate post-purchase Inventory → Selling → shop → fulfilment path.
- Updated `index.html` navigation, hero action, homepage workflow summary and footer.
- Added `docs/TRADEFLOW-PUBLIC-VALUATION-EXPLAINER-ROADMAP.md`.
- Updated System Handbook, AI Operating Manual and Master Roadmap.
- Excluded screenshot-derived customer names/contact details, subscriber business names, record references and screenshot URLs.

## Workflow content rules
- Customer progress: Valuation → Offer → Shipping → Received → Inspection → Payment → Complete.
- Multi-item decisions: per-item or available combined offer.
- Shipping: subscriber arranges carrier outside TradeFlow and supplies label/QR/instructions; customer confirms dispatch; subscriber confirms receipt.
- Inspection: accept original offer, revised offer/counteroffer, or refusal. Unchanged original accepted value can proceed without a revised offer.
- Payment: subscriber records method/reference and confirms sent; no automated payout claim.
- Post-purchase: Inventory → retail listing → published subscriber shop → sale/fulfilment.

## Environment and data boundary
- GitHub `main` = TEST; `production` = LIVE.
- TEST Supabase: `nnsshnfkjcflucjrftzi`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- No Supabase schema/data/RLS/RPC/Edge Function/Storage/Stripe/courier changes.
- No project-memory/checkpoint tables found in TEST non-system schemas; repository `PROJECT-MEMORY` and `CHECKPOINTS` are the continuity layer.

## Verification
Static source checks passed: all relative links resolve, no duplicate IDs, no screenshot-derived personal/business identifiers or external URLs, all seven stages and stock/resale stages present.
Deployed TEST browser review remains pending. Not merged to `main`, not promoted to `production`, and not verified LIVE.
