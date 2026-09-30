# TradeFlow checkpoint — 2026-09-30 — Customer automatic valuation product linkage and research fallback

## Problem
A customer completed the public valuation journey for a product configured for automatic pricing, but the subscriber Buying workspace showed no product-specific research and no customer price was created.

## Root cause
The public Buying Catalogue RPC did not return the exact subscriber Buying Catalogue product ID. The public valuation wizard therefore submitted only category/manufacturer/model/package text. The customer submission boundary created the buying item without `buying_product_id`, so the valuation engine correctly returned `product_not_selected`.

Research is tenant-scoped and product-scoped. Research from another subscriber cannot be used for Camerashack.

## Repair
- `get_public_buying_catalogue` now returns `product_id`.
- `public-site.js` now resolves the exact selected catalogue product and submits `buying_product_id`.
- `customer-selling-submit` passes that product ID to the customer submission RPC.
- `customer_submit_buying_request` validates that the selected product belongs to the current tenant, is active, and belongs to the selected category.
- When a linked product has an applicable automatic rule and matching UK New/UK Used research, the customer submission now automatically creates and approves the trading value and publishes the initial offer.
- If no applicable research exists, no automatic valuation is created and the request remains in the normal manual valuation workflow.
- Subscriber Buying research display now says exactly `No research for this product.` when no product-specific evidence exists.
- The valuation fallback now says `No research for this product — manual valuation required.`
- Customer submission Edge Function deployed as version 5.
- Public-site cache bumped to v84.
- Buying dashboard cache bumped to v61.

## Current Camerashack verification
The Canon Cinema EOS C50 Camera Body is present in the Camerashack public Buying Catalogue with product ID `26733e54-b06b-4c76-abeb-550ff3f4fcfd`, but the existing failed test item `BI-FC9C2C8F26` is still unlinked and Camerashack currently has no automatic pricing rule or research row for that product.

The only current research row found in the database belongs to tenant `subscriber test 1`, not Camerashack. It must not be copied across tenants.

## Test procedure
1. In Camerashack Buying Catalogue, open the exact Canon Cinema EOS C50 Camera Body.
2. Save a complete Automatic Pricing rule for the desired condition, including its research basis.
3. Confirm research exists for the same Camerashack tenant and exact product.
4. Submit a fresh customer valuation selecting that exact product.
5. Expected with research: buying item is linked to the product, automatic trading value is approved, initial offer is published, and the customer sees the price without staff clicking Check valuation.
6. Expected without research: subscriber workspace shows `No research for this product.`, no automatic price is created, and the item is available for manual valuation.
7. Verify tenant isolation: research from another subscriber is never used.

## Commits
- Database migration: `a4e2b20cda11e87cc388ff5660a12151d58b381f`
- Customer submission Edge Function source: `c4efe508d9527dbc688f4bdbc9341e8f81c0204d`
- Public valuation product linkage: `294aec9f1a0e449514a796645bb4de6a38af4965`
- Public-site cache refresh: `13c4babe5c512bccc96e063c8a6b6ac65fe7288b`
- Buying dashboard no-research fallback: `d9b8e657c3773069991be1f37505cc75de798785`
- Buying dashboard cache refresh: `05bcd7dd1438f8e81971ccb17b003e66b8d80f8f`


## Follow-up failure found during end-to-end retest
After the first repair, a fresh customer submission reached the final step but failed with: selected buying product is not active for this subscriber.

The exact cause was an ID mismatch:
- get_public_buying_catalogue was returning the master catalogue product ID.
- customer_submit_buying_request expects the subscriber's tenant_buying_products.id.
- Camerashack C50 master product ID: 26733e54-b06b-4c76-abeb-550ff3f4fcfd.
- Camerashack C50 tenant buying product ID: a10a230b-02fa-4a14-a545-39a2641aa592.

A second compatibility issue was also identified: the public wizard submits opened-unused, while the automatic pricing rules use the canonical key opened_never_used.

## Follow-up repair
- get_public_buying_catalogue now resolves the public selection to the active subscriber tenant_buying_products.id.
- The public catalogue only exposes a selected product when a matching active tenant buying product exists.
- customer_submit_buying_request now normalizes current customer-facing condition values to the canonical automatic-pricing rule keys, including opened-unused to opened_never_used and factory-sealed to sealed.
- Current Camerashack C50 automatic rule is present:
  - opened/never used: 65%
  - reference: UK new
  - excellent: 60%, UK used
  - good: 50%, UK used
  - poor: 40%, UK used
  - sealed: 70%, UK new
- Current Camerashack C50 research is present:
  - UK new observed price: £2,549
- Therefore an opened/never-used fresh C50 submission should calculate £1,656.85 (65% of £2,549), approve the automatic trading value, publish the initial offer, and return the customer to the customer dashboard.

## New commits
- Public catalogue tenant-product linkage migration: 0676a39fae11955afee8d40541678f2cfeea830f
- Condition normalization migration: 5b68fbda4180f10b295d0771e0fc8ea51495c998


## Automatic pricing basis clarified — 30 September 2026
The intended pricing rule is now explicit: every automatic condition percentage is calculated against the latest **UK New** research price for the same subscriber and exact buying product.

- Sealed: percentage of UK New
- Opened / Never Used: percentage of UK New
- Excellent: percentage of UK New
- Good: percentage of UK New
- Poor: percentage of UK New
- UK Used research is view-only evidence and is never an automatic calculation basis.
- If UK New research is unavailable, automatic valuation falls back to manual valuation.
- Automatic pricing configuration now forces all condition reference fields to `uk_new` and the Buying Catalogue editor no longer allows a UK Used automatic basis.
- The subscriber-side `calculate_buying_item_valuation` function now uses UK New only, matching the customer-submission automatic path.

For the current Camerashack C50, UK New research is £2,549. The configured 60% Excellent rule therefore has an expected automatic price of £1,529.40. A fresh Excellent customer submission should now use that amount automatically.

## New commits
- Automatic pricing UK New-only database migration: c37bd475cf4eb72b17ce63f9c7b950ea7646244d
- UK New-only valuation calculator migration: 70bb6186a79e99a338bd1901b47756036753c772
- Buying Catalogue UI: 83fa1491a8896c021bc29141e5a984cd0732dbe7
- Buying Catalogue cache refresh: 80ae99a63e0355410ba0ad2bbe2313a14609eca4
- Human manual update: 0d1f23e6346ee82c106f4eee9692b9e98d12f1b2
- AI operating manual update: 3f38a9d823db3e9cbd7e095ce02193cb50de1316


## Buying valuation controls repaired — 30 September 2026
The Buying dashboard now supports the complete pre-acceptance valuation decision:
- Automatic valuation can be checked and published idempotently without creating duplicate initial offers.
- Manual override is available even when an automatic valuation exists; it replaces/supersedes the previous approved valuation and any published initial offer, then publishes the manual offer.
- Refuse valuation is available for both automatic and manual valuation paths before purchase/fulfilment. A published initial offer is marked refused and the buying item is moved to the refused section.
- Existing items created before the automatic valuation fix can be rechecked; if an approved valuation exists but no offer exists, the dashboard can now create the offer and mark the item offer-ready.

TEST commits:
- Buying valuation controls: d5a3539aa641f0d8e819314218430d4f5fa5562f
- Buying dashboard cache: 0bbd9cef5dd942ca25b86045c9df752833a861d3
- Valuation/refusal RPCs applied in TEST migrations 20260930170000_buying_valuation_override_refusal_flow and 20260930171000_manual_buying_valuation_override
