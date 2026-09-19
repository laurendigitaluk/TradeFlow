# TradeFlow Homepage Content Cleanup — 20 September 2026

## User-observed issues

After the What We Buy layout correction, the homepage still contained fixed instructional/demo content that subscribers could not edit:

- What We Sell introduction lacked the same image area as What We Buy.
- Homepage tile cards contained hard-coded orange labels such as WHAT WE BUY / WHAT WE SELL.
- Default tile CTAs contained fixed phrases such as Sell to us, View product and View shop.
- The homepage contained a fixed More to explore heading and instructional description.
- The trust row contained fixed copy about buying, retail and TradeFlow connection.
- Those fixed strings made the template look like a finished TradeFlow demo rather than a blank, editable subscriber website.

## Changes

- What We Sell now uses the same two-column introduction structure as What We Buy, including a visual image area.
- Removed fixed tile category labels from builder and public renderer.
- New homepage tiles start with blank title, description and CTA fields.
- Existing known demo placeholder values are cleaned when loaded by the builder so they do not remain as uneditable-looking demo copy.
- Removed the fixed More to explore heading and instructional text; the tile grid remains.
- Removed the fixed trust/information row from the homepage.
- The tile images, titles, descriptions and CTA text remain subscriber-editable.
- Public rendering only outputs tile text that is actually present.
- Asset versions bumped to v44.

## Validation

- `website-builder.js`: syntax PASS.
- `public-site.js`: syntax PASS.
- No Supabase schema or catalogue changes.
- Guided selling journey remains unchanged.

## Browser verification

After deployment, hard-refresh both builder and public site and verify:

1. What We Buy and What We Sell introductions have matching side-by-side structure.
2. Image area is visible on both sections.
3. No fixed orange WHAT WE BUY / WHAT WE SELL labels appear on homepage tiles.
4. No More to explore heading/instructional copy appears.
5. No TradeFlow connection/trust row appears.
6. Tiles remain editable and can be populated with subscriber-specific image, title, description and CTA.
