# Pokémon TCG Catalogue — Checkpoint 2026-10-26

- Source: `tcgdex/cards-database`, commit `cbddf7e54033b1b58e44af1049c88832e55b94d0`.
- Recursive tree verified: 43,681 entries; 43,199 blobs; not truncated.
- Source inventory includes 40,658 numbered card-file paths; not a unique-card count.
- Created collector-only tables in TEST and LIVE: `pokemon_tcg_categories`, `pokemon_tcg_sets`, `pokemon_tcg_cards`, `pokemon_tcg_card_variants`; RLS enabled, no end-user policies.
- Base Set (`base1`) loaded in both environments: 102/102 expected records, 102 unique collector numbers, no missing English names. Set marked reconciled.
- No prices imported. Existing buying catalogue and valuation function were not modified.
- Remaining: build bulk importer; load remaining sets/languages; reconcile expected counts and variants; regression-test non-exposure and valuation flow. Overall catalogue is not complete.
