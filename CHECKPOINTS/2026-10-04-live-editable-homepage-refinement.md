# CHECKPOINT — 2026-10-04 LIVE Editable Homepage Refinement

## Restore point
Pre-refinement LIVE branch:
- `checkpoint-live-before-editable-builder-refinement-20261004`

## LIVE implementation now
The Website Builder has been refined into a clean subscriber-facing editable top section.

### Top editor
- One default text box.
- One default image box.
- Subscriber can add additional text boxes.
- Subscriber can add additional image boxes.
- Subscriber can add logo and banner elements.
- Subscriber can add call-to-action buttons.
- Elements can be dragged and resized.
- Text controls:
  - horizontal alignment: left / centre / right
  - vertical alignment: top / centre / bottom
  - font
  - text size
  - text colour
  - line spacing
  - letter spacing
- CTA controls:
  - button text
  - internal TradeFlow page selection
  - custom URL
- Element delete and resize handles are hidden until an element is selected, preventing the previous unexplained orange square from appearing on the clean template.
- Logo/banner uploads now immediately refresh the Branding sidebar as well as the canvas; they no longer wait for a draft save/reload.
- The accidental duplicated JavaScript tail from the first LIVE implementation was removed. LIVE builder now has one `loadContent` and one `initBuilder`.

### Customer-facing website
- Public homepage renders text, images and CTA buttons from the editable layout.
- Header label `What We Sell` is now displayed as **Visit Our Retail Shop**.
- Added **Request a Quote** dropdown.
- Dropdown includes Start a quote plus available buying categories, each opening the relevant selling/quote journey.
- Category links preselect the chosen category in the existing selling wizard.
- Dropdown works by hover/focus and click/touch.

### Existing lower homepage
- What We Buy / What We Sell tile areas remain underneath the editable top section.

## Verification still required in browser
1. Hard refresh LIVE Website Builder.
2. Confirm exactly one starter text box and one starter image box.
3. Select text box and verify all text controls.
4. Add and delete extra text/image boxes.
5. Add a logo and banner and confirm they appear immediately in the Branding sidebar and canvas.
6. Add a CTA button and verify internal page selection and custom URL.
7. Drag and resize elements.
8. Save draft and preview.
9. Publish and verify public LIVE website.
10. Verify Request a Quote dropdown and category preselection.
11. Verify Visit Our Retail Shop label.
12. Confirm lower What We Buy / What We Sell tiles remain intact.
