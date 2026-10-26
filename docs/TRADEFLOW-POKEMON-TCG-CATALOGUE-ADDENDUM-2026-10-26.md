# TradeFlow Pokémon TCG Collector Catalogue — Addendum

Date: 2026-10-26

## Scope
Create a source-attributed Pokémon TCG identification catalogue, including categories/series, sets, card identities and distinct printing/variant data where the source supports it. This is not a valuation project: do not research or import prices.

## Source baseline
- Repository: https://github.com/tcgdex/cards-database
- Branch: master
- Commit: `cbddf7e54033b1b58e44af1049c88832e55b94d0`
- Recursive tree: 43,681 entries; 43,199 blobs; `truncated=false`.
- Numbered card-file paths: 40,658 across international and Asian-language data. These are file paths, not unique card/printing counts.

## Database status
Both TEST project `nnsshnfkjcflucjrftzi` and LIVE project `gxsrajtqzdjvmceqcpgv` now have collector-only tables: `pokemon_tcg_categories`, `pokemon_tcg_sets`, `pokemon_tcg_cards`, `pokemon_tcg_card_variants`. RLS is enabled on all four; no end-user policies are added. No existing master catalogue or valuation function was modified.

Base Set (`base1`) is loaded in both environments and reconciled: 102 expected, 102 imported, 102 unique collector numbers, 0 missing English names. Records retain source paths, blob SHAs, source commit and original source record text. Current coverage is one category, one set, 102 cards; overall catalogue is not complete.

## Next work
1. Build a reproducible bulk importer for the remaining sets and language families.
2. Preserve set, language, collector number and printing/variant distinctions.
3. Reconcile actual records against each source set's expected count; flag duplicates and exceptions.
4. Test that collector records cannot appear in normal customer buying catalogue results and that valuation behaviour is unchanged.
5. Add further LIVE data only after TEST import and reconciliation checks.

Preserve source attribution and MIT licence notice in distributed data. Do not submit AI-generated card data to TCGdex. No card prices were imported.
