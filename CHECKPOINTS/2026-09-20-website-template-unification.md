# TradeFlow Website Template Unification Checkpoint — 20 September 2026

## Branch
`website-template-unification`

Base: `main`

## Purpose
Rebuild the subscriber Website Builder/public template system so subscribers can set up a usable customer website quickly while keeping **What We Buy** and **What We Sell** equally prominent and automatically connected to TradeFlow data.

## Problem repaired
The previous public site contained a legacy static shell plus a newer template renderer. A blank business name was also falling back to the platform name `TradeFlow`, which produced duplicate/incorrect branding in Preview.

The builder and public site also had CSS drift: the builder contained the current ten fresh templates, while the public stylesheet still contained older template families.

## Changes made
- Replaced the public-site HTML shell with a clean loading container.
- Rebuilt `public-site.js` around the current ten template IDs.
- Removed the public renderer's `TradeFlow` business-name fallback.
- Blank subscriber names now display as `Your business`.
- Added dynamic **What We Buy** dropdown navigation populated from the connected Buying Catalogue.
- Added prominent direct **What We Sell** navigation.
- Buying category pages now expose connected products and a category-specific Start Selling route.
- Retail shop/homepage selling sections remain connected to published Inventory → Selling products.
- Replaced `public-site.css` with a public-only stylesheet matching the builder's ten fresh template layouts and responsive behaviour.
- Updated public asset cache versions to `v=40`.
- Added tenant-aware link handling for custom domains.
- Added builder navigation for What We Buy / What We Sell.
- Simplified builder instructions into a four-step setup: logo/name, colours, template, preview/publish.
- Added explicit `Your business` branding placeholder when no logo/name has been entered.

## Ten templates
1. Editorial
2. Classic
3. Grid
4. Studio
5. Horizon
6. Field
7. Business
8. Luxe
9. Commerce
10. Impact

## Data model
No Supabase schema or data changes were made by this rebuild.

The public site continues to read:
- published website content
- `get_public_buying_catalogue`
- `get_published_store_listings`

Draft Preview continues to read the current draft revision for the authenticated subscriber.

## Validation completed
- JavaScript syntax check passed for `public-site.js`.
- JavaScript syntax check passed for `website-builder.js`.
- Confirmed public-site HTML no longer contains the old static `site-brand`, `site-name`, topbar shell or TradeFlow title fallback.
- Confirmed public CSS no longer contains the old legacy template selector family.
- Confirmed public renderer contains the What We Buy dropdown and What We Sell navigation.
- Compared branch with main after the complete rebuild/documentation pass: 16 commits ahead, 0 behind.

## Not done
- No third-party website template was purchased or copied into TradeFlow.
- No production merge to `main` was made in this checkpoint.
- Browser-level visual acceptance testing still needs to be performed after the branch is deployed/previewed.

## Acceptance test
For a clean subscriber:
1. Open Website Builder.
2. Confirm no TradeFlow business name is prefilled.
3. Add logo/name and colours.
4. Choose each of the ten templates.
5. Save draft.
6. Open Preview.
7. Confirm the public site uses the same template selected in the builder.
8. Confirm What We Buy opens and expands with the connected categories.
9. Confirm What We Sell goes to the retail shop.
10. Add/remove a Buying Catalogue category and confirm the public navigation updates without editing the website template.
11. Add/remove a published retail product and confirm the selling section/shop updates.
12. Test mobile navigation and category selection.
13. Publish only after the preview matches the builder.

## Future-proofing rule
The website template is a presentation layer. Catalogue categories, product selection, pricing and inventory must remain in TradeFlow's connected business systems. New products/categories should make the website expand automatically rather than requiring a template rebuild.
