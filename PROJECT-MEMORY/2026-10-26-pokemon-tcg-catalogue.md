# Project Memory — Pokémon TCG Catalogue (2026-10-26)

## Goal
Build a source-verified Pokémon TCG identification catalogue with categories, sets, cards, language data and distinct printing/variant identity where supported. Not a valuation project; do not collect/import card prices.

## Verified source state
- Source repository: https://github.com/tcgdex/cards-database
- Source commit: `cbddf7e54033b1b58e44af1049c88832e55b94d0` on `master`.
- Recursive tree: 43,681 entries / 43,199 blobs / not truncated.
- 40,658 numbered card-file paths in international and Asian-language source directories; this is not a unique card count.

## Database changes
TEST project `nnsshnfkjcflucjrftzi` and LIVE project `gxsrajtqzdjvmceqcpgv` have collector-specific tables `pokemon_tcg_categories`, `pokemon_tcg_sets`, `pokemon_tcg_cards`, `pokemon_tcg_card_variants`. RLS enabled, no end-user policies. Existing master catalogue and `calculate_buying_item_valuation(...)` left unchanged.

Base Set `base1` exists in both environments: 102 expected, 102 imported, 102 distinct collector numbers, 0 missing English names. Set status reconciled. Each card stores source path, blob SHA, source commit and original source record text in JSONB payload. No prices imported.

## Important next step
Build and run a reproducible bulk importer for all remaining source sets/families; keep the source record/variant distinctions and reconcile every set. Test collector data isolation from normal buying catalogue and valuation before expanding LIVE. Current overall coverage is only 1 category / 1 set / 102 cards, so the overall catalogue is not complete. Preserve TCGdex attribution/licence and do not submit AI-generated data to the source project.
