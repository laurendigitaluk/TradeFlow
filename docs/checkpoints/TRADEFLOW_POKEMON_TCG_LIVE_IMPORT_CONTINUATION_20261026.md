# Pokémon TCG LIVE import — continuation checkpoint (2026-10-26)

**Target:** TradeFlow LIVE Supabase `gxsrajtqzdjvmceqcpgv`. TEST untouched.  
**Source:** `tcgdex/cards-database`, `master`, commit `cbddf7e54033b1b58e44af1049c88832e55b94d0`; recursive tree was not truncated.

## Verified LIVE status

- 311 products in `Pokémon Trading Cards`.
- 311 `tcgdex_card_id` source identifiers.
- 0 products customer-visible; all remain active but hidden pending review.
- No prices or valuation rules imported/changed.
- Categories: Pokémon Trading Cards → branches Pokémon, Trainer Cards, Energy Cards.
- Stable key: `tcgdex:<set-id>/<collector-number>`.

## Imported sets

| Set | ID | Official count | Source card files | LIVE rows |
|---|---|---:|---:|---:|
| Base Set | base1 | 102 | 102 | 102 |
| Jungle | base2 | 64 | 64 | 64 |
| Fossil | base3 | 62 | 62 | 62 |
| Team Rocket | base5 | 82 | 83 | 83 |
| **Total** | | | | **311** |

## Open quality issues

- Team Rocket source metadata says 82 official cards but the repository contains 83 files, including #83 Dark Raichu. Keep the mismatch flagged; do not silently drop it.
- Some Team Rocket rows use minimal product fields and need rarity/illustrator/HP notes enriched from the source before publication.
- Fossil #49 Horsea's source illustrator is Mitsuhiro Arita; its product note was initially entered incorrectly and still needs correction.
- Keep all products hidden until metadata, variants, source identifiers, and catalogue query paths are reviewed.
- Do not infer prices or alter valuation logic.

## Next

Continue with the next English set in small idempotent batches; check official counts against file counts, add source identifiers, verify counts after each set, and enrich incomplete notes. The connected GitHub update operation blocked replacement of the very large AI Operating Manual and System Handbook; this checkpoint is the current durable handover.
