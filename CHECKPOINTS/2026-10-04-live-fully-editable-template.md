# CHECKPOINT — 2026-10-04 LIVE Fully Editable Website Template

## Scope
LIVE production branch. This checkpoint records the replacement of the fixed homepage hero/template treatment with a single fully editable top-of-page canvas.

## Safety
A pre-change restore branch was created from production:
- `checkpoint-live-before-full-editable-template-20261004`

No TEST/main code was promoted wholesale.

## LIVE changes
- Website Builder now uses a single **Fully editable** template option.
- The top homepage area is represented by persistent `homepage.editable_elements` JSON.
- Subscriber can add text box, image box, logo and banner.
- Text boxes support font, size, colour, alignment, vertical alignment, line spacing and letter spacing.
- Elements can be moved and resized in the builder.
- Existing logo/banner URLs can seed editable elements.
- New image uploads can target editable hero elements.
- Public website renders the same saved editable elements.
- Existing buying/selling tile sections remain below the editable top area.
- Legacy template rendering remains in the code as a fallback for older content, but the builder now selects the fully editable template.

## Verification required
1. Open LIVE Website Builder.
2. Confirm the single Fully editable template is shown.
3. Confirm logo/banner/text/image boxes can be added.
4. Drag each element around the top canvas.
5. Resize text and image boxes.
6. Select text and test font, size, colour, left/centre/right alignment, vertical alignment, line spacing and letter spacing.
7. Upload a logo and banner and position them independently.
8. Save draft.
9. Open Preview.
10. Publish and confirm the customer-facing LIVE website matches the saved layout.
11. Confirm What We Buy / What We Sell tiles remain below the editable top area.
12. Test desktop and narrow viewport.

## Release rule
This is a LIVE-first build. Do not switch back to main/TEST for the current acceptance work. Once the LIVE version is accepted as the known-good product state, it can become the basis for the future TEST baseline.
