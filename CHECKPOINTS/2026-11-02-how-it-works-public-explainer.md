# Checkpoint — TradeFlow How It Works public page
Date: 2 November 2026
Branch: `feature/tradeflow-how-it-works-page-20261102` (based on TEST branch `main`)
Scope: public SaaS marketing page only.

## Delivered
- Added `how-it-works.html` with a customer-facing explanation of the seven-stage buying tracker.
- Added `how-it-works.css` with responsive visual workflow cards, customer/subscriber responsibility panels, detailed stage explanations, and the separate post-purchase Inventory → Selling → shop → fulfilment path.
- Updated `index.html` navigation, hero action, homepage workflow summary and footer to link to the new page.
- Added `docs/TRADEFLOW-PUBLIC-VALUATION-EXPLAINER-ROADMAP.md`.
- Updated the System Handbook, AI Operating Manual and Master Roadmap.
- Removed all screenshot-derived customer names/contact details, subscriber business names, record references and screenshot URLs from the public copy.

## Workflow content rules
- Customer progress stages: Valuation → Offer → Shipping → Received → Inspection → Payment → Complete.
- Multi-item decisions: per-item or available combined offer.
- Shipping: subscriber arranges the carrier outside TradeFlow and supplies label/QR/instructions; customer confirms dispatch; subscriber confirms receipt. No courier booking or courier payment is claimed.
- Inspection: accept original offer, revised offer/counteroffer, or refusal. An unchanged original accepted value can proceed to payment without a revised offer.
- Payment: subscriber records method/reference and confirms sent; no automated payout claim.
- Post-purchase: Inventory → prepare retail listing → publish to subscriber website → sale/fulfilment.

## Environment and data boundary
- GitHub `main` is TEST; `production` is LIVE.
- TEST Supabase: `nnsshnfkjcflucjrftzi`; LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- No Supabase schema/data/RLS/RPC/Edge Function/Storage/Stripe/courier changes.
- No project-memory/checkpoint tables were found in the TEST project's non-system schemas; repository `PROJECT-MEMORY` and `CHECKPOINTS` are the continuity record.

## Verification status
Implemented on feature branch. Source/link/privacy checks and deployed TEST browser review remain pending. Not merged to `main`, not promoted to `production`, and not verified LIVE.
