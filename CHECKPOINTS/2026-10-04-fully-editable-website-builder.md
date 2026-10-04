# Checkpoint — 2026-10-04 — Fully Editable Website Builder

## Branch
`cloudflare-test`

## Purpose
Replace the repeated fixed-template homepage layout fixes with one fully editable homepage canvas.

## Implemented
- One homepage design called **Fully editable**.
- Add Text Box.
- Add Image Box.
- Add Logo.
- Add Banner.
- Drag elements directly on the canvas.
- Resize elements from the corner.
- Select an element and edit text font, size, colour, alignment, letter spacing, line spacing and weight.
- Image fit and corner radius controls.
- Replace/delete selected images.
- Existing tile section remains below the editable canvas.
- Existing What We Buy / What We Sell connected sections remain below the editable canvas.
- Saved composition is stored in `site.homepage.hero_elements`.
- Public customer website renders the same `hero_elements` composition.
- Existing legacy template data remains as a fallback when a draft has no `hero_elements`.
- Existing media bucket and `media_assets` metadata workflow is reused.
- No LIVE changes made.

## Relevant commits
- Website builder canvas implementation: `bd5b99751485cf45c352697833dafcd5ee2f4a14`
- Published renderer: `40f126e35fea0f930bc98720a13c78c550173fc7`
- Asset cache-busting: `7a8756c0b399198919ccc362c7b4cad9e1a728f2`
- Documentation: `21c9cc8195f44387f2f2cad0b95a9df3bc1bf95c`

## Restore point
Before this redesign, branch `checkpoint-pre-full-editable-website-builder-20261004` was created from TEST commit `090702938a7e1236369dc38f286ed44691dacb4b`.

## Required browser acceptance
1. Open TEST Website Builder.
2. Confirm only Fully editable design is presented.
3. Add text box, edit text, drag it, resize it.
4. Confirm text controls change the selected element.
5. Add image box and upload an image.
6. Drag and resize the image.
7. Add logo and position it.
8. Add banner and position it.
9. Save draft and reload; positions and styling must persist.
10. Open Preview website; the published preview must reproduce the same composition.
11. Confirm tiles and connected What We Buy / What We Sell sections remain below.
12. Publish only after TEST acceptance.

LIVE remains untouched until TEST acceptance is complete.
