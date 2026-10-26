# TradeFlow LIVE Pokémon TCG Catalogue Import Checkpoint — 2026-10-26

## Environment and source

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (TradeFlow Live).
- TEST was not modified.
- Source repository: https://github.com/tcgdex/cards-database
- Source branch: `master`
- Source commit: `cbddf7e54033b1b58e44af1049c88832e55b94d0`
- Recursive tree response: `truncated=false`; tree contains 43,681 entries.

## LIVE import confirmed

| Set | TCGdex set ID | Source official count | LIVE product records |
|---|---|---:|---:|
| Base Set | `base1` | 102 | 102 |
| Jungle | `base2` | 64 | 64 |
| Fossil | `base3` | 62 | 62 |
| **Total** | | **228** | **228** |

A separate verification query returned 228 source identifiers of type `tcgdex_card_id` from `TCGdex cards-database`. Each source key is set-aware: `tcgdex:<set-id>/<collector-number>`. The product records use the existing master catalogue schema; no new tables or valuation functions were created.

## Category structure

- Master category: `Pokémon Trading Cards` (`pokemon-trading-cards`).
- Branches: `Pokémon`, `Trainer Cards`, `Energy Cards`.
- Manufacturer used for the first three English Wizards-era sets: `Wizards of the Coast`.
- Cards are assigned to the branch matching the source `category` value.
- Product `package_name` preserves set and collector number, so same-name cards in different sets remain separate.

## Visibility and valuation safety

- All 228 imported products are active but `customer_visible=false` pending review.
- No card prices or market values were imported.
- No automatic valuation logic, quote logic, tenant data, published website data, or Stripe configuration was changed.
- Source-declared variant counts are recorded as source metadata. Variants have not been split into separate product rows unless represented by distinct source card records.

## Known data-quality exception

Fossil #49 (`Horsea`) was imported from the correct source file and has the correct set-aware product key. Independent source inspection confirmed the illustrator is `Mitsuhiro Arita`; its product note was initially entered as `Ken Sugimori`. An attempted correction was blocked by the connected SQL safety checks and has not been verified as applied. Correct this note in a permitted minimal write before treating the Fossil metadata batch as fully reconciled.

## Continue from here

1. Continue importing verified English sets in source order, beginning with Team Rocket.
2. Confirm each set's official count and exact card-file list before insertion.
3. Keep product writes idempotent using the set ID and collector number.
4. Add matching `tcgdex_card_id` identifiers with exact source URLs.
5. Verify imported counts and unique keys after every set.
6. Keep `customer_visible=false` until the card records, variant handling, source attribution, and catalogue-query behaviour are reviewed.
7. Update the TradeFlow AI Operating Manual and System Handbook with this checkpoint. The large existing manual files could not be safely replaced through the current GitHub update operation; this checkpoint is the durable handover for the current batch.
