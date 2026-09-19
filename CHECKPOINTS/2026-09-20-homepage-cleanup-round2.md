# TradeFlow Homepage Cleanup Round 2 — 20 September 2026

## User-observed issues

The homepage still showed fixed selling prompts and connected catalogue cards that should not appear as permanent website content:

- Orange READY TO SELL / What do you have to sell? prompt on the homepage.
- A What We Buy category card for Drone, including catalogue wording and Sell this type.
- Empty-state instructional text in What We Sell.

## Changes

- Removed the homepage selling prompt. The guided selling journey remains available through the dedicated selling page/navigation.
- Removed homepage buying category cards. The What We Buy section now retains only its editable heading/description and visual image area.
- Removed the What We Sell empty-state instruction. The section remains present; published retail products are rendered automatically when available.
- Builder and public renderer now use the same simplified structure.
- Asset versions bumped to v45.
- No Supabase schema or catalogue data changed.

## Behaviour

When retail inventory is published through Inventory → Selling, the What We Sell product cards will automatically appear in the homepage section. When there are no published products, the section is intentionally quiet rather than displaying system instructions.

The dedicated guided selling journey is unchanged.
