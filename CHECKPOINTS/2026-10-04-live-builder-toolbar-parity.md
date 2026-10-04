# Website Builder Toolbar Parity — 2026-10-04

## Change
Corrected the Website Builder shared/top-page toolbar structure and presentation.

## Verified implementation
- Shared top section now uses the same five primary add controls as Top of page:
  - Add text box
  - Add image box
  - Add call-to-action button
  - Add logo
  - Add banner
- Shared top section and Top of page toolbars use the same light neutral toolbar treatment rather than black.
- A clear vertical gap separates the Shared top section canvas from the Top of page toolbar.
- Removed the misleading inline Ad banner spacer from the Top of page toolbar.
- When no shared banner exists, the Shared top section canvas displays an explicit Add banner box underneath its toolbar.
- Shared CTA elements have editable button text and link controls.
- Website Builder asset cache versions were advanced to CSS v93 and JS v118.
- Changes are based on the restored live builder state at commit 24d960aad0360ab4d4476b9fe70cdb55a6903eb3.

## Branch
live-website-builder-toolbar-fix-20261004

## Do not regress
Do not restore the black toolbar treatment or reintroduce the builder-menu-ad-space element. The Shared top section and Top of page controls are intended to remain visually consistent.