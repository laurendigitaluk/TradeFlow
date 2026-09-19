# TradeFlow Website Template Preview Parity — 20 September 2026

## Purpose

Correct the subscriber Website Builder so its homepage preview represents the published customer-facing homepage more faithfully.

## Findings

The builder and public renderer had drifted in several concrete areas:

- The builder showed non-editable numbered labels such as `01 / WHAT WE BUY` and `02 / WHAT WE SELL`, while the customer page rendered the same labels.
- The public homepage did not render the saved homepage tile collection at all, even though the builder allowed subscribers to edit and save those tiles.
- The builder exposed the homepage block order, while the public renderer used a fixed order.
- The public selling prompt existed on the live homepage but was absent from the builder preview.
- Shared buying/selling card dimensions had drifted between builder CSS and public CSS.
- Browser asset versions were behind the new parity changes, so stale cached CSS/JS could continue to display an older layout.

## Changes on branch

Branch: `website-preview-parity`

Updated:

- `website-builder.js`
- `website-builder.css`
- `website-builder.html`
- `public-site.js`
- `public-site.css`
- `public-site.html`

### Behaviour

- Removed the numbered `01 / WHAT WE BUY` and `02 / WHAT WE SELL` section labels from the editable homepage preview.
- Added the customer-facing "What do you have to sell?" prompt to the builder preview.
- Added public rendering for saved homepage tiles, respecting the saved tile count (6, 8 or 10) and tile images/text.
- Public homepage now follows the saved homepage block order.
- Aligned public buying/selling card dimensions with the builder.
- Bumped builder and public asset versions to v42.

## Validation

- `website-builder.js` syntax: PASS.
- `public-site.js` syntax: PASS.
- Branch is based directly on current `main` after the guided customer selling journey merge.

## Remaining verification

After deployment, compare the builder and customer-facing site at the same browser width and hard refresh both sides. Verify:

1. Hero text wraps the same way.
2. Hero image frame shape is the same.
3. What We Buy heading and description remain side-by-side.
4. No numbered section labels appear.
5. What We Sell matches the builder.
6. Homepage tiles appear publicly with the same count, order, images and text.
7. Changes to tile content in the builder are visible on the customer site after publishing.
