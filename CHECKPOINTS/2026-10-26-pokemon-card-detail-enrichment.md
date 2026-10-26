# Pokémon TCG detail enrichment preparation — 26 October 2026

## Purpose
Prepare a reproducible, evidence-backed way to fill missing card categories without guessing from names or exposing collector records through TradeFlow's ordinary buying catalogue.

## Verified current state
- TradeFlow LIVE Supabase: `gxsrajtqzdjvmceqcpgv`.
- TradeFlow TEST Supabase: `nnsshnfkjcflucjrftzi`.
- LIVE contains 42,453 `pokemon_tcg_cards` rows.
- 23,604 English-language rows have null `card_category`.
- Their `source_payload` identifies them as TCGdex set-summary records; summary payloads do not contain the category.
- Example verified from the original TCGdex source: `data/Base/Base Set 2/1.ts`, card Alakazam, category `Pokemon`. Its source blob SHA matches the SHA stored on the TradeFlow card row.
- TCGdex full card records expose the category needed for a supported update. Allowed categories in the script are `Pokemon`, `Trainer`, and `Energy`.

## Code and documentation
- Added `scripts/pokemon-tcg-enrich-details.mjs` on `main`, commit `78f3f811b127b0974e499a0b5b787ee808a41579`.
- Updated AI Operating Manual on `main`, commit `eb43d6935dbe6ad958feb28095d83ebb06a25953`.
- Updated Human User Manual on `main`, commit `99d9aa56209d55a6a25ef4bdc497c226e509b77c`.

## Script behaviour and safety
- Dry-run by default; `--write` is required for database updates.
- Reads English rows whose `card_category` is null, fetches the full TCGdex card record using `source_payload.summary.id`, validates the category against the three supported values, and merges the detail into the existing JSON payload.
- PATCH is constrained to the exact row ID and `card_category IS NULL`, so it does not overwrite an already classified row.
- Batch limit is 250; default is 25.
- Does not modify catalogue master products, valuation functions, variants, tenant/customer records, or public visibility.
- Credentials are supplied only through environment variables; no secrets are committed.

## Status
**Prepared, not yet runtime-tested. No database rows were changed by this work.** The previous LIVE sync remains intact.

## Next safe action
1. Execute a small dry-run (limit 5–10) against TEST.
2. Review fetched categories and error/skip counts.
3. Execute a small TEST write (limit 5–10) and verify category values plus preservation of source payload.
4. If successful, process the remaining English rows in bounded batches with retry/error logging and reconcile counts after each batch.
5. Only after TEST validation, repeat against LIVE in bounded batches.
6. Record actual results and update this checkpoint and manuals. Do not delete the 58 LIVE-only path-based duplicate records as part of this task.


## LIVE category reconciliation batch — 26 October 2026

A small, TEST-first reconciliation was completed for 57 English card rows whose LIVE category was blank. Their exact `card_key` and card name matched TEST records already marked `source_parsed`; the category `Pokemon` was copied only for these matching records. This comprised 12 cards from key family `2011bw`, 20 from `2012bw` / `2014xy`, and 25 from `2014xy` / `2015xy` / `2016xy`. All 57 LIVE updates returned the expected card keys and `Pokemon` category. A separate read-back confirmed representative records from each group.

LIVE English unclassified count decreased from 23,604 to 23,547. No source payload details were added in this batch; the standalone API enrichment script has still not been runtime-tested. Continue with exact TEST-to-LIVE key/name/category reconciliation in bounded batches, and separately complete full-detail payload enrichment when a secure runtime is available. Do not infer categories from names.
