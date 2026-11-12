# Checkpoint — Camera catalogue evidence research batch 02

Date: 11 November 2026
Repository: laurendigitaluk/TradeFlow
Branch: production
Target: TradeFlow LIVE (`gxsrajtqzdjvmceqcpgv`)
Scope: next 10 active Cameras products with at least one missing UK new/used evidence type, following batch 01. All ten had a missing `uk_used` record. Research only.

## Product order and findings
1. Blackmagic Design — PYXIS 6K PL — new evidence exists; used missing. Camera Price Buster shows no used listing and current new UK prices; no used listing found.
2. Blackmagic Design — Studio Camera 4K Plus G2 — new exists; used missing. CVP used product page explicitly says no used unit currently available. MPB result is Studio Camera 4K Plus (not G2), £749; not an exact model match, excluded.
3. Blackmagic Design — Studio Camera 4K Pro G2 — new exists; used missing. CVP exact-model used page says no used unit currently available. No other exact UK used listing found.
4. Blackmagic Design — Studio Camera 6K Pro — new exists; used missing. CVP direct used ex-showroom listing: £1,580.40 ex VAT, Excellent, in stock. VAT-exclusive so not accepted as consumer-price evidence; retained as comparison lead. Camera Price Buster reports no current used stock and historic Wex prices only (£1,339–£1,899 from 2024–2025).
5. Blackmagic Design — URSA Broadcast G2 — new exists; used missing. Found an EU used listing at €3,473 VAT-exclusive; excluded from UK evidence. UK results surfaced new-only listings.
6. Blackmagic Design — URSA Cine 12K LF — new exists; used missing. MPB direct UK listing: £5,509, Excellent, one available, PL fit. Exact base model but mount/package should be reconciled before linking. UsedLens index independently shows 2 UK listings from £5,339 (MPB and eBay), but is an aggregator, not direct evidence.
7. Blackmagic Design — URSA Cine 12K LF + EVF — new exists; used missing. No UK used listing for exact +EVF package found. Do not substitute the base camera listing.
8. Blackmagic Design — URSA Cine 12K LF 100G — new exists (two active records); used missing. No UK used listing for exact 100G package found. Do not substitute base 12K LF listings.
9. Blackmagic Design — URSA Cine 12K LF Body — new exists; used missing. No UK used listing for exact body-only package found. Do not substitute base package or 100G body.
10. Blackmagic Design — URSA Cine 17K 65 — new exists; used missing. A used Adorama listing was found but is US-market; excluded. No UK used evidence found.

## Outcome
- 10 products checked; all ten were missing UK used evidence.
- Two useful UK direct used-price leads found: Studio Camera 6K Pro (CVP, ex VAT) and URSA Cine 12K LF PL fit (MPB, £5,509, Excellent). Neither is ready for automatic import without VAT/package validation.
- UsedLens UK index for URSA Cine 12K LF: 2 listings, from £5,339, typical £5,424; aggregator-only comparison.
- No candidates submitted to review queue; no catalogue or `shared_market_evidence` rows changed.
- Foreign-market, VAT-exclusive, historic, out-of-stock and non-exact package listings were not accepted as direct evidence.

## Next batch
Continue with the next 10 active LIVE Cameras products with missing `uk_new` or `uk_used` evidence, skipping the first 20 products already researched.


## Verified used-source follow-up imports — 12 November 2026

Two exact UK used offers were imported and read back into LIVE:
- Blackmagic Studio Camera 6K Pro, CVP ex-showroom unit, product code CINSTUDMFT/G26PDK, serial 13537384, £1,580.40 ex VAT, Excellent, in stock for immediate delivery, 90-day warranty. Full box contents recorded: camera, sun shade, tripod mount/plate, turret dust cap, 12V DC PSU, welcome wallet, DaVinci Resolve card and sticker. This is UK Used reference-only; the source price is ex VAT.
- Blackmagic URSA Cine 12K LF, MPB SKU 3704604, PL Fit, £5,509, Excellent, one available, 12-month warranty. Includes EF mount, 24V 250W power supply, handle, top rod mount, V-Lock battery plate and Wi-Fi antennas. Matched to existing URSA Cine 12K LF Standard master with PL-fit and accessory details retained. UK Used reference-only.

Batch 02 now has 2 active records (0 UK New, 2 UK Used). Evidence IDs/source keys are in LIVE shared_market_evidence with batch02-followup prefixes.

Remaining exact used gaps stay unresolved: PYXIS 6K PL, Studio Camera 4K Plus G2, Studio Camera 4K Pro G2, URSA Broadcast G2, URSA Cine 12K LF + EVF, URSA Cine 12K LF 100G, URSA Cine 12K LF Body and URSA Cine 17K 65. No UK direct exact used offers found; do not substitute base/+EVF/100G/body variants or US/EU listings.
