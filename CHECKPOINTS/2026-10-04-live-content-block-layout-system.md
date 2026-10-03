# CHECKPOINT — 2026-10-04 LIVE Website Builder Content Block Layout System

## Environment
The Website Builder is being built and tested directly in LIVE. The branch `production` is the active LIVE source. TEST is not being used for this phase.

## Restore point
`checkpoint-live-layout-system-20261004` was created from production commit `de2b9ef51fe0e6ba860b482c3e67e10392f62772` before this feature work.

## Implemented
- Added persisted homepage `layout_blocks` content data.
- Added editable Text/Image content-block switching for the homepage hero title and primary/secondary hero image areas.
- Added proportional image resizing using a locked aspect-ratio value.
- Added drag positioning for layout blocks within bounded offsets.
- Added image upload/remove handling for layout blocks.
- Added public-site rendering of the saved layout-block positions, sizes and Text/Image type.
- Added responsive CSS and cache-busting for the builder and public site.

## Existing architecture preserved
- Existing `site_revisions` draft/publish system.
- Existing tenant/media handling.
- Existing template selection.
- Existing banner behaviour.
- Existing public-site renderer.

## Verification status
Code implementation is complete in production source. Browser acceptance testing has NOT yet been completed.

## Next verification
1. Refresh the LIVE Website Builder.
2. Confirm the current subscriber/site loads.
3. Test hero title Text → Image.
4. Upload an image into the switched block.
5. Drag the block slightly.
6. Resize from the corner and confirm proportions remain locked.
7. Switch Image → Text.
8. Test the primary hero image and secondary image.
9. Save draft.
10. Open LIVE draft preview.
11. Publish.
12. Compare the published website with the builder preview.
13. Test desktop and narrow viewport behaviour.

Do not declare the feature fully complete until the browser checks pass.
