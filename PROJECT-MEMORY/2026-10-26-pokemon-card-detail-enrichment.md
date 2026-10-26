# Pokémon TCG detail enrichment — project memory — 26 October 2026

The Pokémon collector catalogue has 23,604 English-language card rows in LIVE with null `card_category`. These are TCGdex set-summary payloads, not full card details. Do not infer a card category from its name. The original TCGdex source files provide full card detail and the stored source blob SHA matches the source record for the verified Alakazam example.

A safe standalone script was added to TradeFlow `main`: `scripts/pokemon-tcg-enrich-details.mjs`, commit `78f3f811b127b0974e499a0b5b787ee808a41579`. It retrieves the TCGdex detail via `source_payload.summary.id`, validates category against `Pokemon`, `Trainer`, and `Energy`, and merges details only into rows still lacking a category. Dry-run is default; `--write` is required. Default batch size is 25, hard maximum 250. No DB changes were made by this preparation.

AI Operating Manual update: `eb43d6935dbe6ad958feb28095d83ebb06a25953`. Human User Manual update: `99d9aa56209d55a6a25ef4bdc497c226e509b77c`.

Next: run a small TEST dry-run, then a small TEST write and read-back verification. Scale in batches only after that passes. Do not run against LIVE before TEST validation. Keep collector records isolated from the ordinary catalogue/valuation system and preserve the 58 LIVE-only duplicate-path records pending separate reversible cleanup planning.
