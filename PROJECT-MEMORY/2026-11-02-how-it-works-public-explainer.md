# Project Memory — TradeFlow How It Works Public Explainer
Date: 2 November 2026

A new static public TradeFlow SaaS page explains the valuation-to-sale workflow using the paired subscriber/customer dashboard screenshots as process reference.

## Branch and environments
- Feature branch: `feature/tradeflow-how-it-works-page-20261102-v2`, based on latest `main`.
- GitHub `main` is TEST; GitHub `production` is LIVE.
- Supabase TEST: `nnsshnfkjcflucjrftzi`.
- Supabase LIVE: `gxsrajtqzdjvmceqcpgv`.
- No Supabase data/schema changes are part of this feature.
- No project-memory/checkpoint tables found in TEST non-system schemas; repository continuity files are used.

## Files
- `how-it-works.html`: static public process explainer.
- `how-it-works.css`: responsive visual styles.
- `index.html`: homepage navigation, hero, workflow summary and footer links.
- `docs/TRADEFLOW-PUBLIC-VALUATION-EXPLAINER-ROADMAP.md`: page diagnostic map.
- System Handbook, AI Operating Manual and Master Roadmap updated.

## Process
Customer item selection/details/photos → valuation request → subscriber cash/trade-in valuation → customer offer choice (including multi-item per-item/combined decisions) → subscriber-arranged manual shipping handoff → customer dispatch confirmation → subscriber receipt confirmation → physical inspection → original offer/revised final offer/refusal → subscriber-recorded payment → completed purchase → Inventory → retail listing → published subscriber shop → sale/fulfilment.

## Privacy and claims
No customer names, contact details, subscriber business names, record IDs, screenshot URLs or private data. Do not claim automated courier booking, courier payment processing or automated customer payouts. The page is static and does not call Supabase or read tenant records.

## State
Implemented on feature branch. Static source checks passed. Deployed TEST browser review pending. No LIVE release.
