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
