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
