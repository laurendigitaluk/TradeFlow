# All Ten Website Templates — Homepage Parity — 20 September 2026

## Scope

The subscriber Website Builder contains ten homepage templates:

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

## Changes

The common homepage content structure has been made template-independent so the same subscriber content model is used after every hero design:

- Hero
- What We Buy introduction with image area
- What We Sell introduction with image area
- Published retail products only when available
- Editable homepage tile grid
- Footer

The builder-only selling prompt was removed so the preview no longer contains content that the published homepage does not show.

The shared buying/selling section layout is explicitly aligned in both builder and public CSS for desktop and mobile widths.

All ten hero templates remain available and their existing visual identities are retained.

## Validation

- `website-builder.js`: syntax PASS.
- `public-site.js`: syntax PASS.
- All ten hero classes found in both renderers.
- Builder-only selling prompt no longer rendered.
- Public selling prompt is not inserted into the homepage renderer.
- Assets bumped to v46.
- No Supabase schema/data changes.

## Browser test

Each of the ten templates should be selected in the builder and compared with the published homepage at the same viewport width. Confirm the hero design is retained while the common content below it remains structurally identical.
