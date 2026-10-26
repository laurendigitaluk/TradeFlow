# Pokémon TCG LIVE catalogue sync — 26 October 2026

## Purpose
Continue the existing TradeFlow collector-focused Pokémon TCG identification catalogue. This is not a pricing or valuation project.

## Environments
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- TEST Supabase project: `nnsshnfkjcflucjrftzi`
- Repository: `laurendigitaluk/TradeFlow`, production branch.

## Changes made
- Compared TEST and LIVE by stable card keys and variant composite keys.
- Added 5 set metadata records missing from LIVE.
- Copied 10,583 missing card records from TEST to LIVE using idempotent inserts; existing LIVE rows were not overwritten or deleted.
- Copied 528 missing variant records from TEST to LIVE, linked through each card's stable `card_key`.
- Existing 39 category rows were already present in both environments; all LIVE sets have a category assignment.

## Verified state after sync
| Table | LIVE | TEST |
|---|---:|---:|
| `pokemon_tcg_categories` | 39 | 39 |
| `pokemon_tcg_sets` | 574 | 569 |
| `pokemon_tcg_cards` | 42,453 | 42,395 |
| `pokemon_tcg_card_variants` | 1,895 | 1,071 |

- Every TEST card key is present in LIVE.
- Every TEST variant key pair (`card_key + variant_key`) is present in LIVE.
- LIVE retains 58 cards not present in TEST, all attached to `asia:BW:path:BW8a`. A direct comparison confirmed that all 58 exactly duplicate cards under `asia:BW:BW8a` (same collector number, name, language, source path and blob SHA). They were deliberately retained; do not delete or merge until a separately approved, reversible cleanup is planned.
- LIVE has a master category `Pokémon Trading Cards` with 327 master product rows; all are hidden from customer visibility and package keys are unique. Do not bulk-create all collector cards in `catalogue_master_products` or expose collector-only records to ordinary buying/valuation. Dedicated `pokemon_tcg_*` tables are the source of truth for collector data.

## Outstanding data quality
- 23,604 LIVE cards have null `card_category`. Many retain only TCGdex set-summary payloads, which do not establish card type. Do not infer a type from card name alone; retrieve full card detail and update only when supported by source data.
- Reconcile the 58 LIVE-only path-based cards against the corresponding non-path set key before any deduplication.
- Continue set-level expected-count reconciliation and source completeness review. Do not claim full source completeness from the current row counts.
- No card prices or market evidence were added. No ordinary valuation logic, tenant data, or existing product records were changed.

## Import safety
- Inserts used stable source keys and `ON CONFLICT DO NOTHING`.
- LIVE-only records and IDs were preserved.
- Re-query counts and key coverage before each future batch; never use row counts alone to decide whether a card is missing.
