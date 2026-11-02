# Project Memory — TradeFlow How It Works Public Explainer
Date: 2 November 2026

A new static public TradeFlow SaaS page is being added to explain the full valuation-to-sale journey using the user's paired subscriber/customer dashboard screenshots as process reference.

## Branch and environments
- Feature branch: `feature/tradeflow-how-it-works-page-20261102`, based on `main`.
- GitHub `main` is TEST; GitHub `production` is LIVE.
- Supabase TEST: `nnsshnfkjcflucjrftzi`.
- Supabase LIVE: `gxsrajtqzdjvmceqcpgv`.
- No Supabase data/schema changes are part of this feature.
- No project-memory/checkpoint tables were found in the TEST non-system schemas; repository files are the current continuity layer.

## Files
- `how-it-works.html`: static public process explainer.
- `how-it-works.css`: responsive styles.
- `index.html`: navigation, hero, workflow summary and footer links.
- `docs/TRADEFLOW-PUBLIC-VALUATION-EXPLAINER-ROADMAP.md`: page diagnostic map.
- System Handbook, AI Operating Manual and Master Roadmap updated.

## Process described
Customer item selection/details/photos → valuation request → subscriber cash/trade-in valuation → customer offer choice (including multi-item individual/combined decisions) → subscriber-arranged manual shipping handoff → customer dispatch confirmation → subscriber receipt confirmation → physical inspection → original offer acceptance/revised final offer/refusal → subscriber-recorded payment → completed purchase → Inventory → retail listing → published subscriber shop → sale/fulfilment.

## Privacy and claims
The public page must not contain customer names, customer contact details, subscriber business names, record IDs, screenshot URLs or private data. It must not claim automated courier booking, courier payment processing, or automated customer payouts. The page is explanatory/static and must not call Supabase or read tenant records.

## State
Implemented on feature branch. Static validation and deployed TEST browser review pending. No LIVE release.
