# AKASO 20-product manual research review — 12 November 2026

**LIVE manual batch:** `cb0e7020-c4b0-4bc7-ae68-03dea4752263`  
**Prompt:** `4e9d16d5-baae-4fb7-8617-2e3a0a829cb5`  
**Prompt status at retrieval:** `ready`  
**Scope:** 20 AKASO action-camera product/package records  
**Disposition:** 10 comparison-only findings; 10 no exact qualifying UK GBP package price.

## Findings and exclusions

The complete `tradeflow_manual_research_v1` response is saved in the companion JSON file. Every supplied product UUID appears in findings or not_found. No USD prices were converted.

- idealo UK: Brave 7 Standard £159.99 and 64GB microSD £169.99. These are comparison-only; the retailer click-through failed and the page is stale.
- PriceSpy UK: Brave 7 LE with 64GB microSD £149.99. Comparison-only; retailer pages not opened and page is stale.
- eBay UK: Brave 7 LE Full Accessory Bundle £145.95, four available. It does not prove the requested Motorcycle Bundle accessories. The same listing URL is already attached to two LIVE package masters; do not duplicate or assume package equivalence.
- YPC: Brave 8 with 64GB card £244.99, but price is recorded as of 29 July 2026 and is not a current verified retailer checkout offer. Not a Diving, Vlog or Standalone package.
- eBay UK: Brave 8 Lite used listing displays £123.55, but Best Offer was accepted and actual sale price is undisclosed. Package not stated. Existing active UK New £199.99 evidence already exists for the Standalone master.
- eBay UK: EK7000 used listing £64.27 with 60-in-1 accessory kit. Exact model, different package; private seller and no returns.

No exact UK GBP offers were verified for Brave 7 Super/Vlog, Brave 7 LE Diving/Vlog, Brave 8 Lite Diving/Vlog/SD, or EK7000 Diving/Vlog/SD packages.

## Ten outstanding LIVE research-queue records reviewed

| Candidate | Review outcome |
|---|---|
| PS5 Digital 825GB — Amazon ASIN B0HHFXFS8C | £559.99 capture is the **Two DualSense Controllers Bundle**, not a standard single-controller package. Sony UK and Argos show that bundle at £559.99; comparison-only until package identity is corrected. |
| PS5 Digital 825GB — Amazon ASIN B08H98GVK8 | Older ASIN / older generation page; captured £610 offer is from third-party seller diamond limited. Sony UK current 825GB digital edition is £519.99 but out of stock. Do not use the third-party price as an unqualified standard reference. |
| Bambu Lab A1 Standard — 3D Prima | £215.00, 50+ in stock, VAT included, delivery excluded. Same source/price already exists as active LIVE evidence; no duplicate. |
| Anycubic Kobra 4 Standard | Official UK page £159.00, GB VAT included, Add to Cart, estimated shipping in 24 hours. Existing Kobra 4 Standard master has older £279 evidence. New candidate for import once authorization passes. |
| Anycubic Kobra 3 Max V2 Standard | Official UK page £379.00; active LIVE £379.00 evidence already exists. No duplicate. |
| Anycubic Kobra 3 Max V2 4-Color Combo (two source URLs) | Official UK page £519.00; active LIVE £519.00 evidence already exists. Separate £641 All-in-One bundle has extra accessories and is not the same package. No duplicate. |
| Anycubic Kobra S1 4-Color Combo (two source URLs) | Official UK pages show £409.00 and £449.00 for separate product/version descriptions. LIVE already contains active £409 and £449 evidence on distinct package masters. Do not merge or duplicate. |

Only one new queue import candidate emerged: Anycubic Kobra 4 Standard at £159.00. The two PS5 candidates require package/generation resolution; the other printer observations are already represented in LIVE.

## Authorization gate

LIVE SQL returned `auth.uid() = NULL` with role `postgres`. The project checkpoint requires authenticated owner context before prompt submission, queue review writes, evidence imports or dashboard messages. No database write was attempted.

Therefore the AKASO prompt remains `ready`; the ten queue records remain `needs_research`; Anycubic Kobra 4 £159.00 and Hubsan Zino Pro H117P £356.80 remain verified import candidates, not inserted rows. No dashboard message was posted.

## Safeguards and counts

No TEST, Stripe, schema, master-product, tenant/customer or valuation data was changed. Last confirmed cumulative evidence remains **236 GBP observations: 232 active (127 UK New, 105 UK Used), four inactive**. UK Used remains reference-only.

## Validator preflight correction — 12 November 2026

The companion JSON was checked against the current LIVE `platform_owner_submit_manual_ai_research_response` validator and corrected before any submission. The original file lacked `catalogue_package_name`, `source_kind` and `page_access`, and several `package_match` values did not agree with the exact LIVE product snapshot. The corrected file now carries the exact catalogue package for every finding, source-kind/page-access metadata, and conservative source-package names/matches. The EK7000 listing is explicitly recorded as the 60-in-1 accessory-kit package; the Brave 8 Lite sold listing remains package-not-stated. All ten findings remain `comparison_only`; none is promoted to catalogue evidence. All 20 selected products are covered by ten findings and ten not-found entries.

This is a production-branch checkpoint correction only. No Supabase write was made: the prompt remains `ready` because the available SQL session has no authenticated owner JWT. If submitted through the owner-authenticated dashboard, this report will stage comparison references for review; it will **not** import records into `shared_market_evidence`. The ten separate queue records and the Kobra 4 / Hubsan import candidates remain unchanged.


## Follow-up: Anycubic Kobra 4 queue candidate resolved to existing master — 12 November 2026

The outstanding `needs_research` candidate `5c951409-c951-4f35-be87-884eba7968cc` was rechecked against the current official UK Anycubic page. The page's explicit variant selector separates standalone Kobra 4 (£159) from Kobra 4 Combo (4 colours, £259); GB VAT is included. The standalone printer is estimated to ship within 24 hours and has free express shipping, 14-day no-reason returns, 30-day after-sales guarantee and one-year printer warranty. Do not take the page's top-level £259 Combo price as the Standard Printer price.

Imported and read back against existing LIVE master Kobra 4 / Standard Printer `c673eabf-716d-4ca9-b6eb-9acba6e593a3`:
- Evidence row `ae7a2f85-ff95-4c22-8bf0-b856ed46142c`
- £159.00 GBP, UK New, in_stock
- Source https://uk.anycubic3d.com/products/kobra-4-3d-printer
- source_record_key `manual-ai-queue-kobra4-standard-anycubic-159-20261112`

The evidence import is complete. The original queue candidate remains `needs_research` because changing its workflow status requires the authenticated owner queue-status route; no direct status mutation, RLS bypass or auth impersonation was used. No master/schema/valuation change. TEST and Stripe untouched.


## Follow-up: Anycubic Kobra 3 Max V2 and Kobra S1 queue candidates — 12 November 2026

Reopened the current official UK Anycubic product pages and mapped each candidate to an exact existing LIVE master/package. New imports:

1. Queue candidate `4d0b836d-b426-49ad-b08b-becb5862d511` — Kobra 3 Max V2 + ACE 2 Pro Combo. Official UK price £499 inc GB VAT, reduced from £849; Add to Cart, estimated shipping 24 hours, free express delivery, 14-day returns and one-year printer warranty. Packing list explicitly includes one ACE 2 Pro, printer frame, printhead, touchscreen, support rod, cables and spool holder. Specifications state standard 4 colours, expandable up to 8; this is not a four-ACE/16-colour bundle. Imported to existing Kobra 3 Max V2 / 4-Color Combo master `e01ce831-0efa-4923-848e-efd218d72518` as UK New GBP £499. Evidence row `24e67af8-e9bf-44ea-b515-c8226a1dec9e`. Source https://uk.anycubic3d.com/products/kobra-3-max-v2-ace-2-pro-combo.
2. Queue candidate `80871180-1cf6-4f68-b7ff-98cf459ab287` — Kobra S1 + ACE 2 Pro Combo. Official UK price £409 inc GB VAT, reduced from £599; one ACE 2 Pro, four-colour base package, estimated shipping 24 hours, free express delivery, 14-day returns and one-year printer warranty. Imported to existing Kobra S1 / ACE 2 Pro 4-Color Combo master `c7b0b645-2cc6-4e22-b782-e4f8010d5088` as UK New GBP £409. Evidence row `b10534b7-fd71-493f-89f5-cbeab5c7927b`. Source https://uk.anycubic3d.com/products/kobra-s1-ace-2-pro-combo.

Existing exact evidence rechecked; no duplicate imports:
- Queue candidate `198d5c55-cf65-4f93-8d2b-675f66325b97` — Kobra 3 Max V2 Standard Printer: current official page £379 inc VAT, standalone printer without ACE 2 Pro, ships in 24 hours. Existing active LIVE row `f2a40d41-73d3-4c5c-8bd6-e2724c80df39` already captures this exact source/price.
- Queue candidate `54c85f90-d808-401a-85fe-f6b03b20735f` — Kobra 3 Max V2 Combo 4 colours: current official page £519 inc VAT, separate 8-colour option £705. Existing active LIVE row `0c749755-ad08-4a78-8d79-c19aca8deb21` already captures the exact 4-colour offer.
- Queue candidate `540226bc-ca36-48dd-9591-e07b07427697` — Kobra S1 ACE 2 Pro Combo: current official page £449 inc VAT for 4 colours; separate 8-colour option £635. Existing active LIVE row `746d8f16-8a0f-48dc-9b07-350d74a787ac` already captures this exact offer.
- Queue candidate `495eaf7f-b6ba-42e7-84b3-04bbe4ab4a5b` — Kobra 3 Max V2 All-in-One Bundle remains unresolved: £641 offer includes additional camera, printhead assembly, adhesives and 4KG filament, so it is not the standard 4-Color Combo. Do not attach it to that master.

All imported rows were read back from LIVE. Queue records remain `needs_research` until the authenticated owner queue-status workflow is available; no direct queue status mutation or RLS bypass was used. Remaining queue candidates: two PlayStation 5 Digital Edition listings and Bambu Lab A1 (no matching master found), plus the Kobra 3 Max V2 all-in-one bundle package mismatch. Global LIVE shared_market_evidence now 4,808 total, 4,750 active, 58 inactive. TEST, Stripe, schema, master catalogue and valuation logic untouched.


## Follow-up: Bambu Lab A1 refreshed; PlayStation 5 candidates held for exact package verification — 12 November 2026

### Bambu Lab A1
The manual AI queue candidate `8c18a064-c2e3-4bfd-a1a9-5660254acec7` was matched to existing LIVE Bambu Lab A1 / Standard Printer master `6c70c94c-279f-4b46-931f-e99c421c9473`. No new master product or duplicate evidence row was created. Reopened 3D Prima's direct UK page and refreshed existing evidence row `62ea3f7e-34aa-4f5c-9c3e-fd426ffcc95e`: £215.00 GBP including VAT (delivery excluded), In Stock (50+), SKU 12558, EAN 6975337039150, MPN PF002-A-EU. This is the Standard Printer only; AMS Lite is not included and remains a separate package master. Source https://www.3dprima.co.uk/bambu-lab/bambu-lab-a1-12558. Read-back confirmed current stock and exact product/package.

### PlayStation 5 queue candidates
- `14ee4607-66d6-4fb4-9973-95fc493f99b3` / Amazon ASIN B0HHFXFS8C is the PS5 Digital Edition 825GB bundle with **two DualSense controllers**. It is not the existing single-controller 825 GB Digital Edition package, so no evidence was attached to that master. PlayStation Direct's matching bundle page lists £559.99 but currently states Out of stock. Keep package mismatch / unavailable state visible.
- `aeb85439-6781-4cfd-8740-f88606aa1994` / Amazon ASIN B08H98GVK8 is the original PS5 Digital Edition (825GB, 2020 generation), not the current PS5 Slim Digital model. Amazon UK page returned 503 and no current exact UK retailer offer was verified. Do not substitute the current Slim Digital £519.99 evidence or foreign-currency price.
- Existing PS5 Slim Digital / 825 GB master `cb599ad1-5800-4aca-9a83-f77b3fca7950` already has active official PlayStation Direct UK evidence at £519.99; kept separate from both candidates.

The three queue records remain `needs_research` pending authenticated owner queue-status workflow; no direct status mutation or RLS bypass. TEST, Stripe, schema, master catalogue and valuation logic untouched.
