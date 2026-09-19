# TradeFlow Checkpoint — 19 September 2026 — Unified Buying Pricing Catalogue

## Decision
Buying pricing and master-product selection are one workflow. A subscriber should not create a category, branch, manufacturer or product separately before configuring a buying price.

## Independent catalogue
TradeFlow has its own copied master catalogue in Supabase:
- 32 categories
- 178 branches
- 73 manufacturers
- 3,822 active/customer-visible products

The copy is independent of GearCashOut. TradeFlow does not query GearCashOut at runtime and GearCashOut research/pricing is not used as TradeFlow buying evidence.

## Subscriber workflow
Buying → What We Buy / Buying Pricing → filter/search master product → choose:
- Off
- Manual
- Automatic

Manual or Automatic immediately creates/links the tenant category, branch, manufacturer and buying product through the protected `configure_master_catalogue_buying_product()` RPC.

## Pricing states
- Inactive = light red/pink
- Active Buying without configured price = light green
- Manual offer = light yellow
- Automatic pricing rule = light grey

## Pricing storage
Manual: `tenant_buying_products.manual_offer_price`.

Automatic: `tenant_buying_condition_rules` five condition percentages:
Sealed, Opened/Never Used, Excellent, Good, Poor.

Default research basis:
- Sealed / Opened-Never Used → UK New
- Excellent / Good / Poor → UK Used

## Reset
Off/Reset clears the subscriber's manual/automatic buying price configuration and deactivates the tenant buying product. The master catalogue product is never deleted.

## Downstream valuation
`calculate_buying_item_valuation()` now checks product-level manual price first, then condition manual override, then automatic research × percentage, then manual fallback.

## Implementation
- buying-catalogue.html: `cc0e228ebda87113d2a65dbb026f7ef634909dbb`
- buying-catalogue.js: `900705eb3112284cbd21e16141ffafd252a3089d`
- migration: `master_catalogue_pricing_control`
- migration: `manual_product_price_in_buying_valuation`

## Verification
- JS syntax: PASS
- Supabase migrations: PASS
- Browser verification of Manual/Automatic/Off workflow: OPEN
- GearCashOut: unchanged
