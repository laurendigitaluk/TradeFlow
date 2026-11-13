# TradeFlow LIVE — Drone evidence research checkpoint (13 November 2026)

## Scope and safeguards

- Environment: LIVE Supabase project `gxsrajtqzdjvmceqcpgv` only.
- TEST project and TEST data untouched.
- LIVE Stripe untouched.
- Pokémon Trading Cards excluded from this equipment evidence-research workload; no Pokémon catalogue records changed.
- No master catalogue products, package definitions, categories, aliases, schema, RLS or valuation logic changed.
- All inserted observations are GBP and linked to exact existing `catalogue_master_products.id` values.
- `uk_used` observations are comparison/reference only and must not enter automatic valuation. Existing valuation contract remains latest active GBP `uk_new` observation by `observed_at` then `created_at`; do not change it.
- New-condition prices that are sold out or pre-order remain valid historical/current price observations when the page explicitly shows a price; availability is recorded truthfully.

## Batch 01 — 20 products reviewed

- 8 UK New observations inserted and read back; 6 products gained first UK New coverage and 2 received additional independent/fresh observations.
- 12 products held where no exact UK GBP source/package match could be verified.
- Sources and observations:
  - Autel EVO II Dual 640T Rugged Bundle V3 — Scan UK £4,768.99, pre-order.
  - Autel EVO II Pro 6K RTK Rugged Bundle V3 — Scan UK £3,058.99, pre-order.
  - Autel EVO Lite Standard Bundle — Scan UK £976.99, pre-order.
  - Autel EVO Lite 640T Enterprise Plus Combo — Photospecialist UK £3,444.00, on order.
  - Autel EVO II Dual 640T Enterprise Bundle V3 — BuzzFlyer UK £5,359.00, in stock.
  - Autel EVO Lite+ Standard Bundle — Scan UK £1,055.99, fresh pre-order observation; previous observation retained.
  - BetaFPV Aquila16 Brushless Quadcopter — HobbyRC UK £84.35, out of stock.
  - BetaFPV Aquila20 FPV Kit — HobbyRC UK £221.55, in stock.
- 12 held: Autel Alpha; Autel EVO; Autel EVO II Pro V3 Enterprise Bundle; EVO Lite 640T Enterprise Basic and Premium Combos; EVO Lite 6K Enterprise Basic, Plus and Premium Bundles; EVO Max 4N V2, 4NZ V2 and 4T V2; BetaFPV Air65 & Air75 Wisp Limited Edition.
- Air65/Air75 product pages were also checked but not imported where receiver/VTX selections were ambiguous.
- Batch 01 dashboard status message: `Drones — 20-product research batch 01: 8 verified UK New observations added to LIVE`.

## Batch 02 — 20 products reviewed

- 9 evidence observations inserted and read back: 8 UK New and 1 UK Used, across 9 exact existing master products.
- 11 products held for exact source/package/variant uncertainty.
- Imported:
  - BetaFPV Cetus Pro FPV Kit — Unmanned Tech UK £199.95, out of stock.
  - BetaFPV Cetus X ELRS Kit — Senetic UK £217.76, out of stock.
  - BetaFPV Meteor75 Pro analogue/ELRS whoop — HobbyRC UK £85.00, out of stock.
  - BetaFPV Meteor75 Pro analogue FPV Kit — HobbyRC UK £170.00, in stock.
  - BetaFPV Meteor75 Pro P1 HD — HobbyRC UK £113.30, out of stock.
  - DJI Mavic 2 Zoom with Smart Controller — MPB UK £519.00 used, Excellent, one listed item (SKU 3974221).
  - DJI Mini 4K Fly More Combo — Drone Safe Store UK £399.00, out of stock; exact SKU/EAN 6941565980397.
  - EMAX Tinyhawk II Freestyle RTF — BuzzFlyer UK £214.95, out of stock.
  - EMAX Tinyhawk III RTF Kit — HobbyRC UK £231.30, in stock.
- Held: Autel EVO Nano Standard Bundle; BetaFPV Aquila20 standalone; Cetus X HD FPV Kit; Meteor65 Pro II O4; Meteor75 Pro II O4; Pavo Pico; Pavo20 Pocket; Pavo25 V2; Pavo30; Pavo35; DJI Matrice 350 RTK Standard Package. Reasons include no exact UK GBP source, ambiguous VTX/receiver selection, or source package mismatch (e.g. DJI Matrice Worry-Free Basic Combo vs catalogue Standard Package).
- Batch 02 dashboard status message: `Drones — 20-product research batch 02: 9 verified UK market observations added to LIVE`.

## LIVE read-back after Batch 02

- `shared_market_evidence`: 4,859 total / 4,797 active / 62 inactive.
- Active UK New: 2,330.
- Active UK Used: 2,467.
- Active Drones products: 541.
- Drones still without active UK New evidence: 378.
- Drones still without active UK Used evidence: 368.

## Research controls and continuation

- Research 20 distinct existing products per batch; evidence rows may be more or fewer than products.
- Record source, direct URL, GBP price, condition, availability and exact model/package notes. Do not infer or substitute a similar model, bundle, receiver, controller or VTX.
- Do not invent UK Used sale prices. Use a completed-sale label only when the source confirms the item sold; otherwise preserve listing/ended/out-of-stock state.
- Keep historical source observations separate; do not overwrite good existing evidence or deactivate records without a verified reason.
- Record all reviewed master product UUIDs in each dashboard message's `metadata.reviewed_product_ids` so subsequent batches cannot reselect the same products.
- Before Batch 03, use these UUIDs to exclude Batch 01 and 02 products; continue with the next 20 active Drone products without active evidence.



## Batch 03 — 20 products reviewed (13 November 2026)

- 3 verified GBP observations inserted and read back across 2 exact LIVE master products: EMAX Tinyhawk Lite RTF — Unmanned Tech UK £134.95 New/out of stock; HobbyRC UK £140.90 New/out of stock; FIMI X8 SE 2020 — eBay UK completed Used sale £47.40 (underlying item price, excluding £2.16 Buyer Protection fee), ended 25 September 2026. The used record is reference-only.
- 18 products held: BetaFPV Air65 (Racing/Freestyle variant not resolved), Air75 (ELRS/TBS variant not resolved), FIMI A3, FIMI X6, FIMI X8 Pro, FIMI X8 SE 2022, Mi Drone 1080P, Mitu Mini Drone, X8 Mini, X8 Mini V2, X8 Pro 2025, X8 SE, X8 SE 2022 V2, X8 Tele, X8T V384 (no exact UK GBP source), X8T V640 (conflicting current/cached price snapshots; live price/availability recheck required), Freefly Alta 6 (manufacturer discontinued; old sold-out new price not used as an active valuation reference), and Freefly Alta 8 (eBay listing's item specifics say Remote Control and do not confirm the standard drone package).
- Dashboard status message: `Drones — 20-product research batch 03: 3 verified observations added to LIVE`. Reviewed UUIDs are saved in metadata to prevent duplicate selection.
- LIVE after Batch 03: 4,862 evidence rows total / 4,800 active / 62 inactive; 2,332 active UK New and 2,468 active UK Used. Drones remain 541 active products; 377 without active UK New and 367 without active UK Used.



## Batch 04 — 20 products reviewed (13 November 2026)

- 4 verified GBP observations inserted and read back across 3 exact LIVE master products: GEPRC Vapor-X5 HD O4 Pro ELRS24 GPS — HobbyRC UK £359.95 New/out of stock; eBay UK completed Used sale £297.40 item price (excluding £10.50 Buyer Protection fee), sold 30 September 2026; GEPRC Vapor-X5 WTFPV ELRS 2.4G with GPS — eBay UK £227.91 New, five available, MPN GP107470, seller located Ivybridge, England; Holy Stone HS110G — eBay UK completed Used sale £26.35 item price (excluding £1.46 Buyer Protection fee), sold 29 September 2026.
- 17 held: Freefly Alta X, Alta X Gen2, Alta X Gen2 NDAA, Astro, Astro Max standard, Astro Max NDAA/Blue standard, Astro Max NDAA/Blue with LR1 payload, Astro Max Mapping Essentials, Astro Max Mapping Essentials NDAA/Blue (no exact UK GBP sources); GEPRC CineLog30 V3 O4 Pro ELRS (receiver/price ambiguity), CineLog35 V2 Analog (receiver variants), DarkStar20 ELRS (unverified seller source); Holy Stone H4831, HS110D, HS180, HS210FS and HS210P (no sufficiently reliable current exact UK GBP retail evidence).
- Dashboard status message: `Drones — 20-product research batch 04: 4 verified observations added to LIVE`. Reviewed UUIDs are saved in metadata to prevent reselection.
- LIVE after Batch 04: 4,866 evidence rows total / 4,804 active / 62 inactive; 2,334 active UK New and 2,470 active UK Used. Drones remain 541 active products; 375 without active UK New and 365 without active UK Used.
