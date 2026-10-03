# CHECKPOINT — 2026-10-04 LIVE layout interaction correction

The first LIVE content-block implementation was tested in the Website Builder and was not usable as delivered.

Observed:
- Text/Image controls caused boxes to disappear.
- Layout blocks did not remain independently movable.
- Movement visually reverted.
- Adjacent text behaved as though it belonged to the same selectable/movable area.
- Image/logo block had no usable frame or resize affordance.
- Resize/move controls were not usable.

Correction applied in LIVE production:
- Added a dedicated editable hero banner layout block.
- Added fallback loading so existing hero images are retained in layout blocks.
- Banner upload/removal now synchronises with its layout block.
- Layout blocks are now independently draggable from their own surface/handle.
- Text editing remains separate from movement.
- Resize remains proportional using the block aspect ratio.
- Builder blocks now have visible frames and always-visible controls.
- Image rendering uses contain rather than stretching/cropping.
- Published renderer now reads the hero banner layout block.

Restore point before this correction:
`checkpoint-live-layout-interaction-fix-20261004`

Browser acceptance testing after this correction is still required. Do not declare the Website Builder layout system complete until the user confirms movement, resizing, Text/Image switching, save, preview and publish behaviour in LIVE.
