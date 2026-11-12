# TradeFlow LIVE — Scheduled Market-Evidence Research Memory — Batch 05

**Date:** 12 November 2026  
**Checkpoint:** CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md  
**Repository branch:** production  
**Environment:** LIVE only

## Outcome

Completed page-level market research for the next 20 eligible active LIVE catalogue master products with no active shared_market_evidence. All product IDs, source URLs, observed prices/currencies, condition, availability, package details and uncertainties are in the paired Batch 05 checkpoint.

No candidate was staged into platform_catalogue_research_queue. The current LIVE connection reports auth.uid() = null, auth.role() = null and public.platform_cloud_ai_owner_check() = false. No direct table write, claim impersonation or RLS bypass was attempted.

## Continuity and selection rules applied

Read scheduled checkpoints and project-memory continuity beginning with Batch 02, then Batch 03 and Batch 04. Excluded all 102 unique product UUIDs listed across scheduled checkpoints 02–04. Also excluded every product ID in the two manual AI research prompts (one completed prompt with 20 product IDs and one ready prompt with 20 product IDs), and all 10 outstanding LIVE research-queue candidates.

LIVE queue status at this run:
- imported: 28
- needs_research: 10
- rejected: 43
- pending_review: 0

No fixed SQL OFFSET was used. Selection used dynamic anti-joins against prior checkpoint IDs, manual prompt product arrays, outstanding queue candidates and active shared_market_evidence. The selected 20 products were rechecked immediately before research and again after research; each had zero active evidence, zero matching outstanding queue candidates and zero matching outstanding manual prompts.

## Batch 05 product IDs

1. 1f8831cc-a4e7-4f1f-9727-b2de60469701 — Casio EX-ZR5100 / Standard Package
2. 2038e2fa-0e43-4d5b-92c5-91964315461e — Insta360 Flow 2 Series / Insta360 Flow 2 Series
3. 20681866-47b8-429b-aef6-342c4ff61e78 — Yuneec Typhoon Q500+ / Typhoon Q500+ 4K
4. 21fd7701-aa4e-4e2f-a67e-0657dae50cd9 — Sony UWP-D22 / UWP-D22 Wireless Microphone System
5. 2288bc72-5e68-433b-813d-10b4f26efb2d — Sony HDC-1700 / Standard
6. 248de94f-60c1-47f4-90b6-f988548d5217 — Nikon D5000 / Nikon D5000
7. 24e8c2f9-eca7-41e2-8996-40e48fa3f064 — Nikon 1 S2 / Nikon 1 S2 Camera
8. 268f9e67-6c24-4374-844d-1dfc7bc67bf7 — Olympus PEN E-PL1s / Standard
9. 26be6789-9baf-493a-9de3-192258d04896 — Sony HXC-100K / Standard
10. 2a8fd8f9-7254-4a02-b7b1-ebf70a18c8d0 — Skydio X10D Propellers / X10D Propellers
11. 2abd478f-a522-4f17-b5d7-ae83e4503d74 — Walkera Runner 250 / Standard Package
12. 2c73d311-c15f-48c1-afa0-615dee60a8cc — RØDE Wireless GO (3rd Gen) / Standard Item
13. 2cd63711-f718-4f0a-9776-63d87d3a335c — AJA PAK Dock Pro / AJA PAK Dock Pro
14. 2db58348-c226-436e-91f2-fd97921f585e — Sony HXR-NX30 / Standard
15. 3002ffef-5df4-4697-b832-35991c275351 — Sony FE 24-70mm F2.8 GM II / Standard
16. 300415f7-5866-4546-b3ad-43523ab8145a — Z CAM ZOLAR Vega 30C / ZOLAR Vega 30C RGBAW LED Light Panel
17. 31e7b9ff-d653-4b2d-aeb9-2bb933033cf4 — CaddxFPV Walksnail Avatar HD Mini 1s Lite Camera / Walksnail Avatar HD Mini 1s Lite Camera
18. 323e8f7e-1a8b-4d7e-87f6-28de0cf0d0e0 — Sony SRG-300H / Standard Package
19. 33dc29a5-ed39-4118-bd0a-df3b7c75936a — Nikon Nikkor-H Auto 50mm f/2 / Standard
20. 34cecfb5-9fbc-404c-b003-6c2f52f4898d — Sony HVR-Z7E / Standard Package

## Research handling rules confirmed

- Keep sold-out and historical listings with their URL and availability note.
- Keep unverified direct sellers and Shopping product cards with the URL and a RED VERIFY note.
- Keep closest-model/package evidence only when defensible, and explicitly state suffix, variant, bundle or accessory mismatches.
- Leave the GBP price blank where only a non-GBP source exists; preserve its displayed currency and amount without conversion.
- Leave camera-only price blank where only a complete camera+VTX kit is found.
- Do not import uncertain prices into automatic valuation.
- Do not create/alter master products, schema or valuation logic.

The Batch 05 checkpoint records the following key uncertainties: Casio EX-ZR5100 has only foreign-currency sold listings; Insta360 Flow 2 Series is an umbrella master with multiple editions/bundles; Q500 listings without plus are comparison-only; UWP-D22 prices are K33 frequency variants and availability differs; HDC-1700 listing includes a CCU; Nikon 1 S2 Shopping result has a lens-package discrepancy; Olympus E-PL1s listings are overseas/out of stock; HXC-100K exact suffix was not found; Skydio X10D propellers have no exact listing; Walkera Runner 250 current Shopping listing could not be opened; RØDE and Sony HXR-NX30 Shopping cards could not be opened and show price differences; AJA and ZOLAR pages have contradictory stock/backorder labels; Walksnail sources are full VTX+camera kits, not camera-only; Sony SRG-300H eBay page text did not expose prices; Nikon LCE listing redirected; HVR-Z7E eBay listing has unusual shipping/import wording.

## Next scheduled run

Read this file and CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-05.md first. Exclude all 20 Batch 05 IDs and all earlier scheduled checkpoint IDs. Re-read LIVE queue candidates and manual AI research prompts; exclude products they cover. Select the next 20 active LIVE masters with no active shared evidence using dynamic anti-joins and no fixed OFFSET. Recheck evidence, queue and prompt status immediately before research. Continue manufacturer/UK-retailer/marketplace/Google Shopping searches and click through to product pages. Preserve uncertain links with RED VERIFY and no invented/converted prices. Check owner auth before staging; if auth.uid() is null or owner check false, do not write to the queue and create the next checkpoint plus project-memory file. Do not touch TEST, Stripe, master products, schema or valuation logic.


## 12 November 2026 — Batch 05 RED VERIFY follow-up

Nine further exact source observations were imported into LIVE and read back: RØDE Wireless GO Gen 3 — Disc DJ Store £179, Jessops £179, Wex £159 (blue, limited stock), Westend DJ £179.99; Sony FE 24-70mm F2.8 GM II — LCE £1,699 and CameraWorld £1,813; Sony SRG-300H — eBay current listing £567.55 and ended listing £491.34 including £16.34 Buyer Protection (not a confirmed completed sale); Nikon Nikkor-H Auto 50mm f/2 — eBay £71.05, seller in Basingstoke. Exact links, conditions, seller and availability notes are in the paired checkpoint.

Batch 05 now has 18 active GBP rows (10 UK New, 8 UK Used). Nine follow-up rows were added with idempotent source keys. Used evidence remains reference-only and is not selected by LIVE calculate_buying_item_valuation(uuid,uuid). The PPP Cameras £60 lens price remains RED VERIFY because the product page displays GBP while its terms still state prices are in EUR. The LCE Nikon D5000 £49.99 listing remains RED VERIFY because the reopened page did not expose current price/stock. No master data, schema, valuation logic, TEST or Stripe changes.
