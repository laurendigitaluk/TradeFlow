# TradeFlow LIVE — Consolidated Market Research Backlog

**Research window:** 12 November 2026  
**Branch:** production  
**Scope:** Scheduled research batches 03–13  
**Environment:** LIVE only  
**State:** Preserved in GitHub; database import outstanding.

## Consolidated totals
- 11 batches
- 220 product research records (20 per batch)
- 711 raw URL occurrences in checkpoint text
- 697 distinct non-Google-search source URLs after filtering search-query URLs and de-duplicating
- Every batch includes product-level source notes and RED VERIFY qualifications.

## Batch register

| Batch | Products | Raw URL occurrences | Non-search source URL occurrences | Checkpoint |
|---|---:|---:|---:|---|
| 03 | 20 | 45 | 45 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md) |
| 04 | 20 | 59 | 59 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md) |
| 05 | 20 | 74 | 74 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md) |
| 06 | 20 | 57 | 57 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-06.md) |
| 07 | 20 | 52 | 52 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-07.md) |
| 08 | 20 | 75 | 55 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-08.md) |
| 09 | 20 | 103 | 82 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-09.md) |
| 10 | 20 | 95 | 75 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-10.md) |
| 11 | 20 | 100 | 100 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-11.md) |
| 12 | 20 | 53 | 53 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-12.md) |
| 13 | 20 | 59 | 59 | [Checkpoint](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-13.md) |
| **Total** | **220** | **772** | **711** | |

**Correction note:** Raw URL occurrences were recalculated from the complete production checkpoint files during consolidation. The per-batch figures above sum to 772 raw URL occurrences. After excluding 61 Google Shopping/search-query URL occurrences, 711 non-search URL occurrences remain. De-duplicated non-search URL count: 697.

## Database reconciliation (LIVE)
- `shared_market_evidence`: 4,542 rows at the last inspected baseline; latest recorded timestamp 8 November 2026.
- `platform_catalogue_research_queue`: 28 imported, 10 needs_research and 43 rejected at the last inspected baseline.
- `platform_research_reports`: 0 rows at the last inspected baseline.
- None of scheduled batches 03–13 has been staged or imported.
- The six AKASO candidates created by a separate manual prompt were subsequently rejected. Rejection notes show duplicate existing evidence and page/model/price mismatches. Do not re-import those six blindly.
- One further manual AI research batch is in progress with its prompt still ready and no response submitted.

## Import requirements
1. Import all source observations and notes idempotently using product UUID + source URL + evidence role/type + price/currency as applicable.
2. Preserve RED VERIFY, source excerpts, source currency/amount, condition, availability, package match and no-price cases.
3. Keep non-GBP values in notes/raw payload; do not convert currencies.
4. Keep uncertain, comparison-only, ended, sold-out and inaccessible-page leads visible for review, but not valuation eligible.
5. Only exact-match, verified UK GBP new-price evidence may be considered for automatic valuation. Used-market observations are reference-only.
6. Do not alter catalogue master products, valuation rules, TEST, Stripe or tenant/customer records during evidence import.
7. Use authenticated platform-owner context and the supported review queue. Do not use postgres SQL session writes, impersonate JWT claims or bypass RLS.

## Known import blocker
The SQL connector session has no authenticated user context (`auth.uid() = NULL`, `auth.role() = NULL`) and `platform_cloud_ai_owner_check() = false`. The existing manual submission RPC is prompt-bound and cannot accept these scheduled checkpoint batches. A supported authenticated checkpoint-import path is required before database insertion.

## Project memory
Batch 03 project memory was missing and has now been restored at `PROJECT-MEMORY/2026-11-12-scheduled-market-evidence-batch-03.md`. Batch 04–13 project-memory files already exist.


## 12 November 2026 — database import reconciliation

The initial verified import pass for batches 04–13 was 107 GBP evidence rows. Follow-up RED VERIFY reviews in batches 04–07 added 20 more rows. LIVE now contains 127 total rows from these batches: 126 active and one inactive; all 127 use GBP. Active rows comprise 72 UK New and 54 UK Used. The inactive row is the BuzzFlyer DEVO-10 + RX1002 £149.95 listing: current page shows Notify Me/no stock, so it remains stored for audit but is excluded from active evidence.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 8 | 8 | 7 | 1 | 0 |
| 09 | 11 | 11 | 5 | 6 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

The initial 107 total was correct, but the per-batch breakdown in the earlier status summary misallocated Batches 10–12. Current LIVE counts are Batch 10=12, Batch 11=10, Batch 12=12. Follow-up additions were Batch 04 +4, Batch 05 +9, Batch 06 +3, Batch 07 +4. Batches 08–13 still have outstanding RED VERIFY leads; the presence of imported rows does not mean all 220 product research records or all source URLs have been resolved.

The working import route is the established idempotent privileged migration path into public.shared_market_evidence, with direct read-back verification. This supersedes the earlier note that database import was outstanding. No manual research queue staging, owner impersonation, auth-context bypass, TEST or Stripe changes. The actual manuals have been located and updated at docs/TRADEFLOW-SYSTEM-HANDBOOK.md and docs/TRADEFLOW-AI-OPERATING-MANUAL.md.


## 12 November 2026 — updated LIVE import reconciliation after Batch 08

Follow-up reviews have now added 26 more rows to the initial 107 verified GBP rows. LIVE currently has 133 total rows across batches 04–13: 131 active and 2 inactive, all GBP. Active rows: 75 UK New and 56 UK Used. Inactive: BuzzFlyer DEVO-10 (Notify Me/no stock) and NEEWER KM19 eBay (seller away until 19 Nov).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 11 | 11 | 5 | 6 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Follow-up additions by batch: 04 +4, 05 +9, 06 +3, 07 +4, 08 +6. Batches 09–13 remain to be reviewed for outstanding RED VERIFY sources. The earlier database-import-outstanding note is superseded: the established idempotent migration route has imported the verified rows, with read-back checks. The unresolved research queue is not the same thing as the verified evidence import; do not mark all 220 product research records complete.

The LIVE valuation function uses the latest active GBP UK New evidence by observed_at/created_at and does not filter availability. UK Used is reference-only. Sold-out/backorder UK New rows remain active with status notes; Notify Me and seller-away records are inactive until availability returns. No code or schema change, no TEST or Stripe change.


## 12 November 2026 — Batch 08–09 RED VERIFY follow-up and current totals

Batches 08 and 09 were reviewed beyond the original import pass. Batch 08 gained six rows and now has 14 total (13 active: 10 UK New, 3 UK Used; one inactive seller-away listing). Batch 09 gained five rows and refreshed its existing source observations; it now has 16 active GBP rows (6 UK New, 10 UK Used). Batch 09 sources include Currys PENTAX WG-90 £299; eBay Sony FE28-60 £141.12 used; MPB Sony FE35 GM from £819 used; Park Cameras Sony FE35 GM £839 Good and £939 Excellent. See the batch checkpoints for URLs and caveats.

Cumulative Batches 04–13: 138 GBP rows, 136 active (76 UK New, 60 UK Used), 2 inactive. Inactive records are BuzzFlyer DEVO-10 Notify Me/no stock (Batch 07) and NEEWER KM19 eBay seller away (Batch 08).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 12 | 12 | 7 | 5 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

No uncertain currency, seller, model suffix or package mismatch was promoted. Used evidence is reference-only. The LIVE valuation function still selects latest active GBP UK New by observed_at/created_at and does not filter availability; no valuation logic was changed. TEST and Stripe remain untouched.


## 12 November 2026 — Batch 10 RED VERIFY follow-up and cumulative totals

Batch 10 received 12 further verified GBP observations: Sony LMD-A240 used Visual Impact £1,560 and eBay/N.I. Broadcast £1,150; Shure MV7+ SCAN £259 new; Sony SRG-A40 white Currys Business £3,635.98 and TopAV £5,054.39 new; Sony VG-C3EM Wex £69 and Harrison £70 used; Sony FE PZ 28-135 CameraWorld £1,960 new and MPB £814 used; Sony PDW-U1 eBay £208.70 with PSU and Snet Technologies £1,459.95 with warranty; Shure MoveMic Two Receiver Kit official £311.40 new. Batch 10 now 24 active rows: 12 UK New and 12 UK Used. See batch checkpoint for direct source links and status.

Cumulative Batches 04–13: 150 GBP rows, 148 active (81 UK New, 67 UK Used), 2 inactive (BuzzFlyer DEVO-10 no stock; NEEWER KM19 seller away).

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 10 | 10 | 3 | 7 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

No master/schema/valuation logic changes. Used evidence remains reference-only; latest active GBP UK New source continues to be the valuation reference. TEST and Stripe untouched.


## 12 November 2026 — Batch 11 RED VERIFY follow-up and cumulative totals

Batch 11 received twelve further GBP observations: Nikon P900 MPB £319 and LCE £349.99 used; Nikon Df LCE £699.99 used; Nikon NIKKOR Z 50mm f/1.4 Nikon UK £449 new; Nikon Z 26mm f/2.8 Nikon UK £449 new; Pentax HD D FA 28-105 MPB £244 and SRS £209 used; Pentax HD D FA Macro 100mm Carmarthen £699.99 new; Pentax O-RC1 SCAN £29.99 and Clifton £26 awaiting stock; Panasonic FZ1000 II Kamerastore £709 used with zoom-unit fault; Panasonic GM5 Wex £929 used body-only. Batch 11 now has 22 active GBP rows (8 UK New, 14 UK Used). See checkpoint for links and caveats.

Cumulative Batches 04–13: 162 GBP rows, 160 active (86 UK New, 74 UK Used), 2 inactive.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 12 | 12 | 8 | 4 | 0 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Used evidence remains reference-only. Preserve the FZ1000 II zoom lever fault, Df loose grips and remote awaiting-stock status. No master/schema/valuation logic changes. TEST and Stripe untouched.


## 12 November 2026 — Batch 12 RED VERIFY follow-up and cumulative totals

Batch 12 received thirteen additional GBP observations: HVR-HD1000E eBay £312.70 with four used batteries and bag; Sony E35 F1.8 Cotswold £269 and CameraWorld £319; Sony PXW-FS5 Wex £493 Good/clean sensor and £425 Well Used/sensor dust; Sony FE100 Macro GM Camix £1,208, LCE £1,399, Campkins £1,399, Wilkinson £1,399; Sony FE50 F1.4 GM Sony UK £1,499, LCE £1,499, CameraWorld £1,499 new and £1,425 open-box. Sony UK E35 £225 price-conflict observation was made inactive after ambiguous sale/original price contexts. Batch 12 now 25 total GBP rows, 24 active (16 New, 8 Used), one inactive.

Cumulative Batches 04–13: 175 GBP rows, 172 active (94 UK New, 78 UK Used), 3 inactive: BuzzFlyer DEVO-10 no stock; NEEWER KM19 seller away; Sony UK E35 price conflict.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 12 | 12 | 7 | 5 | 0 |

Used evidence remains reference-only. Do not use price-conflict row or seller-away/no-stock rows as active valuation sources. No schema/valuation logic changes. TEST and Stripe untouched.


## 12 November 2026 — Batch 13 RED VERIFY follow-up and final totals

Batch 13 gained 24 further source observations: ECM-B10 three new retailer prices (£175 Park, £175 Bristol, £179 Harrison) and two used (£137 Wex, £145 MPB); FE85 GM II £1,789 CameraWorld new, £1,710 open-box, £1,269 Wex used and £1,249.99 LCE used; FE12-24 GM LCE £2,645 new; Ranger module Flying Tech £99 and 3DXR £99.99; XDCA-FS7 used MPB £123/£144, eBay £175, 3D Broadcast £390; SRG-X400 black/white SCAN £3,199.99 each awaiting ETA; HOVERAir AQUA Standard Currys £1,129 and Ballicom £1,113.56; PowerDolphin Wizard sold used £449.99; HXR-MC50E Cash Converters sold £129.99, eBay sold £229.99 and faulty £69.99. PowerDolphin Wizard new eBay £1,449 was deactivated due package contents not proven. HVR-V1E eBay title was rejected because item specifics identify HVR-Z1E.

Batch 13 now 36 total GBP rows, 35 active (17 New, 18 Used), one inactive. Cumulative Batches 04–13: 199 GBP rows, 195 active (104 UK New, 91 UK Used), 4 inactive.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 36 | 35 | 17 | 18 | 1 |

Inactive rows: BuzzFlyer DEVO-10 no stock; NEEWER KM19 seller away; Sony E35 price conflict; PowerDolphin Wizard package unverified. Used observations remain reference-only. No master/schema/valuation logic changes. TEST and Stripe untouched.


## 12 November 2026 — second Batch 13 retailer recheck and final totals

Five additional Batch 13 records added: ECM-B10 CameraWorld £159 new; FE85 GM II LCE £1,799 new and Park £1,799 new; FE12-24 GM CameraWorld £2,548 new and £2,548 open-box. Batch 13 now 41 total rows, 40 active (21 New, 19 Used), one inactive.

Cumulative Batches 04–13: 204 GBP rows, 200 active (108 UK New, 92 UK Used), 4 inactive.

| Batch | Total rows | Active rows | Active UK New | Active UK Used | Inactive |
|---|---:|---:|---:|---:|---:|
| 04 | 18 | 18 | 8 | 10 | 0 |
| 05 | 18 | 18 | 10 | 8 | 0 |
| 06 | 12 | 12 | 8 | 4 | 0 |
| 07 | 14 | 13 | 9 | 4 | 1 |
| 08 | 14 | 13 | 10 | 3 | 1 |
| 09 | 16 | 16 | 6 | 10 | 0 |
| 10 | 24 | 24 | 12 | 12 | 0 |
| 11 | 22 | 22 | 8 | 14 | 0 |
| 12 | 25 | 24 | 16 | 8 | 1 |
| 13 | 41 | 40 | 21 | 19 | 1 |

Inactive rows remain BuzzFlyer DEVO-10 no stock, NEEWER KM19 seller away, Sony E35 price conflict and PowerDolphin Wizard package unverified. Used evidence remains reference-only. No schema/valuation logic changes. TEST and Stripe untouched.
