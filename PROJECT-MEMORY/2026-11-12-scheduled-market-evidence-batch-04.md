# TradeFlow LIVE Project Memory — Scheduled Market Evidence Batch 04

**Date:** 12 November 2026  
**Branch:** production  
**Environment:** TradeFlow LIVE only  
**Checkpoint:** `CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-04.md`

## Run outcome

Completed page-level research for the next 20 active LIVE catalogue masters that had no active shared_market_evidence. Selection used no SQL OFFSET. Before research, all 20 were rechecked and each had zero active evidence, zero matching outstanding queue candidates and zero matching outstanding manual AI prompts.

Continuity sources read: scheduled market evidence batch 02 checkpoint and project memory, plus batch 03 checkpoint. All UUIDs in prior scheduled checkpoints were excluded. All manual prompt product sets were excluded (one completed prompt and one ready/in-progress prompt, each covering 20 products). The 10 LIVE queue candidates with needs_research status were also excluded.

## Products researched

| LIVE product ID | Product | Main result |
|---|---|---|
| 00b78f50-3b57-4ff5-bfdf-554942669ca8 | Sony FE 85mm F1.4 GM II | Sony UK £1,799; ProAV £1,698 inc VAT; Cotswold £1,049 page / Shopping £1,004 discrepancy — RED VERIFY |
| 02467f84-18d4-46db-b045-1038a52e791c | RØDE Wireless GO II | Dual-channel £239 RadioActive; £180 inc VAT Production Gear with sold-out/one-left conflict; Ubuy GBP 158 excluding landed charges; eBay used £99.99 — RED VERIFY |
| 02a01cd0-e018-49c2-81fb-2bfc45917022 | Autel EVO Lite 6K Enterprise Basic Bundle | EUR 1,619 French/German references; US Premium package USD 2,059; no exact UK GBP basic bundle |
| 037bf6aa-c253-47f5-a629-b369161acf48 | Z CAM EVF EV101 | ProAV £958.80 inc VAT; CVP £895 inc VAT; Production Gear £895 sold out; manufacturer specs confirmed |
| 03a54715-6098-401e-91ba-9140a55f6901 | Sony DSR-PD175P | Used/refurbished £400 Kabayo; £3,357 Photospecialist on order |
| 03ebaec4-f328-4744-b8b5-7355eb03e182 | Olympus VF-4 | MPB five used from £146–£164; eBay Japan £235.23 |
| 04533da4-4a56-493a-93f7-f928a84ae237 | Hubsan ZINO 2+ | £519.99 exact UK listing sold out; £599.99 extra-battery bundle sold out; Fruugo £799 unavailable/unbranded seller |
| 0510c179-9f73-493a-b139-96890a49d875 | Nikon D2HS | Sold UK eBay £114.25 incl Buyer Protection; faulty rear LCD Best Offer listing displayed £91.52 but accepted price hidden; Shopping junk listing £220.19 — RED VERIFY |
| 0517047c-a570-420a-878e-6f5590fffd59 | DJI Matrice 350 RTK | Drone Sales UK Basic Combo £10,959 with aircraft/RC Plus/WB37/2×TB65/BS65 etc.; QuadRotor £8,389 smaller package — RED VERIFY package alias |
| 05e9a890-ea1b-4712-ade3-18210908defa | Hubsan MINI 7 | Aerion specs confirmed; Brazilian price R$ 5.999,99 only, no GBP |
| 0b135055-2325-49bf-af9e-673434e179cb | Skydio 2 | Ended eBay listing £750 auction figure / £1,050 Buy It Now, no confirmed sale; £500 parts-not-working listing |
| 0e19c5f6-3c26-4fe7-a23c-2cb0f7e6ea4e | Nikon F-801 | Camera Centre UK £99 used body; Shopping kit £149.20 includes Sigma lens; F-801s £109.19 is suffix mismatch |
| 0ff8aa32-9e56-4ee3-8039-5aaf06e84031 | NEEWER Pro 340cm C Stand | Official page from £175.99; exact SC340AW variant confirmed but selected price/stock unclear — RED VERIFY |
| 15cdcd88-f159-43cb-b0ac-54547b220723 | Bebob V150microC | ProAV £406.80 inc VAT / £339 ex VAT; backorder wording conflicts with “in stock”; CVP Shopping result £406.80 |
| 1bff3357-d9bc-4441-80c1-4d5de1c5cd4d | Nikon AF-S DX 18-200mm VR II | MPB Shopping £87.95; eBay £106.04/£170.10; LCE £149.99 used; Microglobe £539.35 inc VAT with unclear current stock |
| 1c0fd153-450e-4201-b9dc-98b9d65daf73 | Casio EX-ZR3000 | eBay Japan seller £190.70 current; ended £268.56; older US$324.29 result left in USD, not converted |
| 1c14094a-4ac9-431b-bee9-c5deb57546ab | Sony HXC-D70L | Close HXC-D70 used camera channel £4,000, but no L suffix; 3 stock — RED VERIFY |
| 1d189a97-6ad9-42f2-a1e9-3f8c690e06e4 | NEEWER NS14S 30×120 softbox | Official page from £52.99, 30×120 NS14S option; generic package text says NS12S — RED VERIFY |
| 1dd0ad3d-1f21-4c8f-8220-b2fa3da64861 | Nikon Nikonos III | Castle Cameras £134 used, in stock; includes lens, strap/bracket and untested strobe |
| 1ea7d671-95d5-483a-bb32-eeed10f364b7 | Olympus FL-50R | Kamerastore £87 used certified, in stock; eBay ended £79.35; LCE £89.99 FS-FL50R close nomenclature |

All detailed source URLs, package notes, availability, condition and exact uncertainty reasons are in the paired checkpoint. Non-GBP amounts were not converted.

## Queue staging limitation

Owner-auth check on LIVE returned:

- `auth.uid() = null`
- `auth.role() = null`
- `platform_cloud_ai_owner_check() = false`

Therefore no authenticated platform-owner RPC could be safely used. No direct queue-table write, claim impersonation or RLS bypass was attempted. **Zero batch 04 candidates were staged as pending_review.** The checkpoint is the recovery record for a later authenticated run.

## No other changes

No master products, schema, valuation logic or automatic valuation prices were created or changed. No TEST or Stripe operations were performed.

## Next scheduled run

Read batch 04 checkpoint and this project-memory file first. Exclude these 20 product IDs and all IDs from earlier scheduled checkpoints. Exclude products covered by outstanding LIVE queue candidates and outstanding manual AI prompts. Recheck evidence and candidate status immediately before researching the next 20; use no fixed OFFSET. If owner auth remains null or owner check false, record the next batch in new checkpoint and project-memory files without writing directly to the queue.
