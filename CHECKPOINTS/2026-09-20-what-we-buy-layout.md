# What We Buy Layout Alignment — 20 September 2026

## User-observed issue

After the previous preview/live parity repair, the What We Buy section still differed visually:

- Builder showed the heading and explanatory text side-by-side.
- Public page stacked them vertically.
- Public page showed a product count such as "126 products", which is not useful in the customer selling journey.
- Public page showed "View all categories", which duplicates the guided selling flow.
- Category cards lacked a visual image area, making the section look disconnected from the template design.

## Change

The What We Buy section is now designed as a visual selling-entry section rather than a catalogue count display.

### Builder and public page now both show

- Heading and explanatory text in a two-column intro.
- A visual category-image placeholder beside the intro.
- Category cards with a visual image area beside category information.
- No product-count display.
- No "View all categories" link.
- Category CTA is "Sell this type →" and routes into the guided selling journey.

The existing top-level "What do you have to sell?" selling prompt remains the primary customer CTA.

## Validation

- `website-builder.js`: syntax PASS.
- `public-site.js`: syntax PASS.
- Builder/public asset versions bumped to v43.
- No database or catalogue data changes.

## Remaining browser verification

Hard-refresh builder and customer site at the same browser width and confirm the What We Buy section has the same structure, spacing, image boxes, category cards and typography.
