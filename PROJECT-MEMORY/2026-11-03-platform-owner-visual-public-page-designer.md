# CHECKPOINT — Platform Owner Visual Public Page Designer — 3 November 2026

## Intent
Replace the rejected nested text-form CMS with a drag-and-drop visual editor for TradeFlow How It Works and Examples public pages. User explicitly requested text boxes, image boxes, screenshot boxes, free positioning and resizing, using the subscriber Website Builder interaction pattern but with fewer options.

## Boundaries
- Do not change the locked subscriber Website Builder or tenant site publishing flow.
- Do not mix LIVE and TEST page content, uploads, auth sessions or database records.
- Do not change customer, tenant, transaction, inventory, Stripe or custom-domain data.

## Implementation
- `platform-public-pages-visual-editor.js` and `platform-public-pages-visual-editor.css` provide canvas, add text/image/screenshot boxes, drag positioning, corner resizing, x/y/width/height inspector, layout, background, text, duplicate/delete, upload/replace/remove, draft save, preview and publish.
- Composition is saved in `platform_public_pages.draft_content.visual_layout` via existing owner RPCs.
- `platform-public-pages.js` renders published visual layouts. Existing How It Works embedded screenshots are retained as fallback for screenshot boxes without uploaded replacement images.
- `platform-public-media` is a separate public image bucket, max 8 MB, PNG/JPEG/WebP. Write policies require active platform membership and UUID-prefixed paths.

## Environments
- LIVE branch feature: `feature/platform-public-visual-builder-live-20261103`; LIVE Supabase `gxsrajtqzdjvmceqcpgv`.
- TEST branch feature: `feature/platform-public-visual-builder-test-20261103`; TEST Supabase `nnsshnfkjcflucjrftzi`.
- Migration `20261103210000_platform_public_media_owner_uploads` applied separately to both databases; bucket and three owner-write policies read back in both.

## Verification / remaining
- Visual editor and public renderer JavaScript syntax parsed successfully in the connector runtime for both branches.
- Confirm the owner dashboard, image upload, drag/resize, save/reload, draft preview, publish, desktop/mobile rendering in both environments after PR merge and Cloudflare deployment.
- Do not claim runtime deployment or browser acceptance until verified.


## Merge status — 3 November 2026
- LIVE PR #206 merged into `production` at `d08f4f156452d066cd39dad7943f8e39e38985d1`.
- TEST PR #207 merged into `cloudflare-test` at `04989110d3fd49ab0bcf152e34819cc38193ac5d`.
- Both branch heads were read back at their merge commits. GitHub reports no commit statuses and zero Actions workflow runs for either head. The Worker dashboard URLs could not be opened through the available browser check. Cloudflare deployment and browser acceptance therefore remain unverified; do not tell the user the feature is live until that is checked.
