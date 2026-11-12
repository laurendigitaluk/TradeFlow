# Project Memory — Manual Queue Reconciliation (12 November 2026)

TradeFlow LIVE manual queue review: 10 `needs_research` records were rechecked. Seven have matching evidence rows already present in LIVE shared_market_evidence, so no duplicate inserts were made. Exact queue-to-evidence mappings, source URLs and notes are in CHECKPOINTS/2026-11-12-manual-research-queue-reconciliation.md.

Current verified 3D-printer source references:
- Bambu Lab A1 Standard: 3D Prima £215 inc VAT (existing row 62ea3f7e-34aa-4f5c-9c3e-fd426ffcc95e, In Stock 50+); Additive-X reverified £189 inc VAT / £157.50 ex VAT (existing row 054e117b-088e-4b16-a72f-0cdf0eaf50ed, In Stock / Next Working Day).
- Anycubic Kobra 4 Standard £159 inc VAT (row ae7a2f85-ff95-4c22-8bf0-b856ed46142c).
- Kobra 3 Max V2 Standard £379 inc VAT (row f2a40d41-73d3-4c5c-8bd6-e2724c80df39); 4-Color Combo £519 inc VAT (row 0c749755-ad08-4a78-8d79-c19aca8deb21); separate Kobra 3 Max V2 + ACE 2 Pro Combo £499 inc VAT (row 24e67af8-e9bf-44ea-b515-c8226a1dec9e).
- Kobra S1 ACE 2 Pro 4-Color Combo: £409 (row b10534b7-fd71-493f-89f5-cbeab5c7927b) and £449 (row 746d8f16-8a0f-48dc-9b07-350d74a787ac) from separate current UK pages. Older £409 record from same £449 page deactivated as duplicate.
- PS5 Digital Edition 825GB official £519.99 RRP is currently out of stock; duplicate official record deactivated. Active reference row ac2f42ba-b7dc-4fb9-a5ca-1a28b04d5a87 now carries `out_of_stock`.

Three queue records remain unresolved and must not be forced into wrong catalogue packages:
1. Kobra 3 Max V2 All-in-One Bundle £641 includes camera, printhead assembly, adhesive and 4KG PLA; no exact catalogue package master.
2. PS5 825GB two-controller bundle Amazon listing has no visible price; Argos exact bundle £559.99, Add to trolley, local stock requires postcode. This is not the standard one-controller package.
3. Older PS5 Amazon ASIN B08H98GVK8 has no current price and model-generation identity needs checking.

Queue remains 10 needs_research because no owner-review workflow status was altered. Seven already have matching evidence rows; three remain genuinely unresolved. No auth impersonation used.

Batches 01–13 currently contain 268 observations, 261 active (142 UK New, 119 UK Used), seven inactive. UK Used remains reference-only. TEST, Stripe, schema, master catalogue and valuation logic untouched.


## 12 November 2026 — availability semantics and valuation behavior confirmed

Current LIVE `calculate_buying_item_valuation` selects latest active `uk_new` GBP shared evidence; it filters active flag, price and currency but does not filter availability. The catalogue page RPC similarly returns active UK New/UK Used prices separately without excluding out-of-stock status. This is consistent with the user's earlier decision (30 Aug / 1 Sep 2026) to retain genuine UK GBP prices even when sold out, ended or unavailable, with availability and checked date recorded. Do not bulk-deactivate out-of-stock UK New records or change valuation logic without explicit owner approval. `is_active` means valid retained price observation, not guaranteed current stock. UK Used remains reference-only and is excluded from automatic valuation by evidence_type filter.

No availability-driven bulk deactivation or valuation code change was made in this review. Duplicate PlayStation UK price row was deactivated only as a same-seller/same-model/same-package/same-price duplicate; one active out-of-stock RRP observation remains. Caddx Peanut/Walnut out-of-stock references remain active, as required by the evidence-retention rule.
