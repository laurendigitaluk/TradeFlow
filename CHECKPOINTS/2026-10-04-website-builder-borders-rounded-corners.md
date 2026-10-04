# Checkpoint — Website Builder Borders & Rounded Corners

Date: 4 October 2026
Branch: production

## Change

The editable homepage canvas now supports optional borders and rounded corners on text and image elements.

Controls:
- Border: None / Solid / Dashed / Dotted / Double
- Border width: 1px / 2px / 3px / 4px
- Border colour
- Round corners: Square / 2px / 4px / 8px / 12px / 20px / Fully round

## Implementation

- `website-builder.js` stores `borderRadius`, renders the controls, and applies the selected values live.
- `website-builder.css` uses the stored border variables and keeps the editor selection outline separate from the user's border.
- Existing elements default to square corners and retain backward compatibility.
- Builder assets were cache-bumped so the new JS/CSS load.

Commits:
- JS: `4321e9bea51cdc6a2a8aa8d903672e956af61bb1`
- CSS: `8dba5889960c1413166f834e1eb830f4bf6b8f9a`
- HTML asset bump: `b26f73238f84ad87eaa0b22126f5b0221558c147`
- Handbook: `97b0ee740c792fee10c0638dd61d2ced19010ad6`
- AI Operating Manual: `8baf74c448b18213606ce924114343bf8bbfefd3`

## Verification required

Browser verification is still required:
1. Select a text box.
2. Confirm Border controls appear.
3. Choose Solid and a border colour/width.
4. Change Round corners and confirm the box rounds immediately.
5. Select an image box and confirm the same controls work and clip the image corners correctly.
6. Save Draft, reload, and confirm the settings persist.
7. Preview and Publish, then confirm the published site retains the chosen border/radius.
8. Confirm Border = None leaves no forced border on the published element.
