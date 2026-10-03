# CHECKPOINT — 2026-10-04 Website Builder Image Proportion Fix

## Scope
TEST development branch only (`main`). No production/LIVE deployment was made.

## Problem observed
The Website Builder was rendering uploaded banner and template images inside fixed-height or letterboxed boxes. This produced visible empty/white space around artwork and made the editor preview differ from the intended customer-facing layout.

## Decision
Uploaded artwork should preserve its intrinsic aspect ratio. The image should determine the height of its image slot where practical; empty image slots remain editable placeholders.

The subscriber banner remains a single title-banner treatment. Its wrapper should follow the uploaded banner rather than creating a second large hero box.

## Changes
- Updated `website-builder.css` on `main` so uploaded template images use width 100%, automatic height, and no fixed minimum/max height.
- Updated banner image slots so uploaded images are not letterboxed by fixed-height containers.
- Updated `public-site.css` on `main` so the published banner uses the same proportional treatment.
- Bumped `website-builder.css` cache version from v66 to v67.
- Bumped `public-site.css` cache version from v12 to v13.

## Commits
- Website builder media fit: `eaf1d578d8436b4533d683ba4087d7cf731dd0c1`
- Public banner media fit: `fe28ab3c4d257d994d4ae6c8fdf39bfbb04c8bb0`
- Website builder cache-bust: `386d0061420fddad699b488a99aaf11f50d1eba2`
- Public site cache-bust: `c6a6e1bad55e2e8b5d117719ddad24553c6ca403`

## Verification still required
Test in TEST before any promotion:
1. Upload/select a wide banner.
2. Confirm there are no artificial white/empty side areas around the banner.
3. Confirm left/centre/right banner positioning still works.
4. Test a wide, square and portrait uploaded image in template image slots.
5. Confirm the empty image placeholder still provides an Add image control.
6. Compare the builder preview with the published/preview customer website.
7. Test at desktop and narrow viewport sizes.
8. Only after successful TEST verification consider promotion to production.

## Release rule
Do not copy these changes to `production` until TEST verification passes.
