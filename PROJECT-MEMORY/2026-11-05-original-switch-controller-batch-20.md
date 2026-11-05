# Project Memory — Original Nintendo Switch Controller Catalogue Batch 20
Date: 5 November 2026
Repository: laurendigitaluk/TradeFlow

Added two official Nintendo Joy-Con pairs to LIVE and TEST:
- Neon Green/Neon Pink — £64.99, Play Pixels UK, SKU 12630, EAN 045496430795.
- Pastel Pink/Pastel Yellow — £64.99, Play Pixels UK, SKU 29548, EAN 4902370551112. Retailer notes Japanese-language packaging may be supplied but confirms UK Switch compatibility.

Both listings were in stock when observed and include UK GBP evidence. Exact product/evidence UUIDs and source URLs are in CHECKPOINTS/2026-11-05-original-switch-controller-batch-20.md.

Verified LIVE and TEST each have 97 active customer-visible products / 100 active evidence rows; zero visible products missing active evidence, zero duplicate active evidence source keys and zero invalid active evidence. Package keys, prices, URLs and evidence metadata match across environments.

Nintendo official accessories documentation also identifies Grey, Neon Yellow/Neon Yellow, Neon Purple/Neon Orange, Pastel Purple/Pastel Green and Pastel Pink/Pastel Yellow. Existing Purple/Green and Purple/Orange records may be these exact colour pairs, but do not alter their identity without reconciling the underlying product and evidence. Research Grey and Neon Yellow/Neon Yellow pairs for UK GBP new-price evidence.

No Worker deployment required for database-only additions. No application/schema/valuation/RLS/Edge Function/Stripe/tenant/customer/order/payment/custom-domain changes. Used evidence remains reference-only and does not affect automatic valuation.


## Subsequent update — HORI Switch 2 racing wheels — 5 November 2026

Two additional products were added independently to LIVE and TEST:
- HORI Mario Kart Racing Wheel Pro Mini for Nintendo Switch 2 — Red; EAN-13 4961818042445; product-specific package key hori-mario-kart-racing-wheel-pro-mini-switch-2.
- HORI Mario Kart Racing Wheel Pro Deluxe for Nintendo Switch 2 — Red & Black; EAN-13 4961818042469; product-specific package key hori-mario-kart-racing-wheel-pro-deluxe-switch-2.

Dated UK-new evidence checked 5 November 2026:
- Pro Mini: Smyths Toys UK £69.99 (https://www.smythstoys.com/uk/en-gb/gaming-and-tech/nintendo-switch-2/nintendo-switch-2-accessories/hori-mario-kart-racing-wheel-pro-mini-for-nintendo-switch-2/p/259402); Argos £74.99 (https://www.argos.co.uk/product/9661811).
- Pro Deluxe: Very £104.99 (https://www.very.co.uk/hori-mario-kart-racing-wheel-pro-deluxe-for-nintendo-switch-nintendo-switch-2/1601312358.prd); Argos £119.99 (https://www.argos.co.uk/product/9575646).

Four active UK-new evidence rows were recorded in GBP, New condition, with observed_at 2026-11-05 14:25:00 UTC and stable source_record_key values. Both products are active/customer-visible and have verified EAN identifiers.

Post-update verified totals in both environments: 99 active customer-visible Nintendo controller products; 102 active UK-new evidence rows covering all 99 products; 2 active UK-used reference rows covering 2 products; zero active visible products missing active evidence or UK-new evidence. This supersedes the earlier 97 products / 100 evidence count above.

An existing generic package_key collision remains: two older records use single-controller. This was not introduced by this update and is not confirmed to represent duplicate products. Leave unchanged pending model/package identity and insertion-history review. No Worker deployment or application/schema/valuation/RLS/Edge Function/tenant/customer/order/payment changes. TEST and LIVE remain independent.
