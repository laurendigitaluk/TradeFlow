# Website Template Alignment & Colour Pass — 20 September 2026

## Scope
This pass continues the homepage template tidy-up without changing the database or customer/account workflow.

## Changes
- All ten template selections now have a distinct automatic colour palette.
- Selecting a template applies its palette to accent, page, header, buying, selling and footer colours.
- Existing manual colour controls remain available after the automatic palette is applied.
- The builder What We Buy homepage area now renders connected category cards with a visual image area when a selected catalogue product has an image, category name, product count, description and “Sell this type” action.
- The public What We Buy homepage now uses the same category-card structure and routes each category into the guided selling journey.
- The builder What We Sell homepage preview now matches the public treatment more closely: product image when available, category, title, price and “View & buy” action.
- Shared builder CSS was added for the buying/selling cards at desktop, tablet and mobile widths.
- Asset versions bumped to v49.

## Templates
The ten template identities remain distinct:
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
The common customer content structure remains aligned below the hero: What We Buy, What We Sell, homepage tiles and footer.

## Validation
- website-builder.js: syntax PASS.
- public-site.js: syntax PASS.
- Branch is 5 commits ahead of main, 0 behind.
- No Supabase migrations or data changes.
- No customer account or valuation changes.

## Browser verification still required
1. Open the builder.
2. Select each of the ten templates.
3. Confirm the automatic palette changes with the template.
4. Confirm the What We Buy cards retain the same structure and connect into the selling journey.
5. Confirm What We Sell cards show image, title and price when inventory data exists.
6. Compare builder preview with public preview at the same viewport width.
7. Check mobile layout.
8. Confirm manual colour changes still override the automatic palette and persist after Save draft.

## Branch
template-alignment-colour-pass

## Follow-up pass

- Homepage tile counts expanded to 3, 4, 6, 8, 9, 10 and 12.
- Homepage tile columns expanded to 2, 3 and 4 per row.
- Added 12 real default tile slots so the 12-tile option is functional rather than cosmetic.
- What We Buy and What We Sell image controls are protected from homepage drag handling.
- Hero, What We Buy, What We Sell, category, product and tile image placeholders no longer display instructional placeholder text in the template/public renderers.
- Public and builder image areas remain neutral visual spaces until an image is supplied.
- JavaScript syntax checks pass after the follow-up changes.


## Quick palette expansion — 20 September 2026
- Expanded Website Builder Quick palettes from 4 presets to 18 coordinated presets.
- Presets now cover professional, warm, dark, clean, ocean, emerald, royal, sunset, citrus, berry, coral, sky, forest, plum, teal, electric, rose and monochrome directions.
- Each preset defines the full seven-colour brand system: accent/brand, text, page background, header/navigation, buying section, selling section and footer.
- Palette metadata includes a short description and is kept separate from the saved theme colour values.
- Quick palette buttons now show a colour swatch and wrap cleanly in the sidebar.
- Manual colour controls remain available for individual fine-tuning after selecting a preset.
- No Supabase migrations or data changes.
- website-builder.js syntax check: PASS.


## Template-specific styling pass — 20 September 2026
- Added a second alignment layer across all ten templates so the shared homepage structure remains consistent while the buying, selling, shop and tile sections retain template-specific visual identities.
- Editorial uses restrained editorial dividers and flat cards.
- Classic uses heritage borders, serif section headings and squared cards.
- Grid uses darker structural treatment and tighter card geometry.
- Studio uses larger section typography and image-led card depth.
- Horizon uses softer rounded cards and cool spacing.
- Field uses rugged low-radius treatment and darker structural contrast.
- Business uses compact professional cards with restrained elevation.
- Luxe uses fine gold-toned borders and understated surfaces.
- Commerce uses tighter product-card geometry and stronger price emphasis.
- Impact uses bold accent-edge cards and heavier section typography.
- Matching template-specific rules were added to both builder preview and public customer site via the active template identity.
- No Supabase migrations or data changes.


## Interaction polish — 20 September 2026
- Added restrained hover lift to homepage tiles and connected buying/selling/product cards in both builder and public site.
- Card images receive a subtle 3.5% scale on hover where hover input is available.
- Added keyboard-visible focus states using the active template accent colour.
- Added small hover movement to key navigation/actions without introducing excessive animation.
- Added reduced-motion handling for card transitions.
- Mobile layouts do not rely on hover movement.
- No Supabase migrations or data changes.

## Batch status
- Visual system changes are accumulated on the template-alignment-colour-pass branch.
- Ready to apply the accumulated visual batch to main after final branch comparison.
- Browser verification remains a post-deployment check because browser/computer tooling is not available in this workspace.


## Website background system v2 — 20 September 2026
- Reworked the website background model so specialist preset backgrounds and brand-colour surfaces are separate systems.
- Added explicit **Preset background** and **Custom colours** modes in the Website Builder.
- Selecting a specialist preset automatically activates preset mode.
- Selecting Custom colours disables the specialist background layer while retaining the selected preset for later reuse.
- Switching between modes no longer destroys the selected preset.
- Changing individual brand colours or a quick palette no longer changes the active background mode or removes the selected specialist background.
- Builder and public-site rendering now receive the same saved `background_mode` setting.
- Preset backgrounds are rendered as an independent visual layer above section colour surfaces, while section colours remain independently editable.
- Asset versions bumped for the builder and public site to reduce stale-cache issues.
- No Supabase migrations or schema/data changes.
- `website-builder.js` syntax check: PASS.
- `public-site.js` syntax check: PASS.
- PR #22 merged to main as `39e5a230284e8f2ce1c7d9302eb8a53c5d3c5a10`.
- Browser verification remains pending after GitHub Pages deployment.

## Public background rendering repair — 20 September 2026
- After deployment testing, the public customer page showed **"backgroundMode is not defined"** and stopped rendering.
- Root cause: `applyContent()` in `public-site.js` used `backgroundMode` when setting `document.body.dataset.backgroundMode` without declaring it first.
- Repaired by deriving the mode from the saved site theme: `custom` remains custom; every other value falls back safely to `preset`.
- PR #23 merged to main as `5ba3ebc1a2b7c0cc8c6ca36f684b12d1b9f697de`.
- Full `public-site.js` syntax check after merge: PASS.
- No Supabase schema or data changes.
- This repair explains why the public page reported the background error instead of rendering the selected background/template correctly.
