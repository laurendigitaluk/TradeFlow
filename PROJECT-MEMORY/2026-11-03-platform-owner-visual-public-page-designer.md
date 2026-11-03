# CHECKPOINT — Platform Owner Visual Public Page Designer — 3 November 2026



## Platform-owner visual public page designer — 3 November 2026

Replace the rejected nested text form with a drag-and-drop visual canvas for the How It Works and Examples public pages. This is separate from the locked subscriber Website Builder. Owner can add text, image and screenshot boxes; drag them to position; resize them; edit text, image alt text, background, layout and numeric position/size; duplicate/delete; upload/replace/remove images; and save draft, preview and publish through the existing owner RPCs. Composition is stored in `draft_content.visual_layout` in `public.platform_public_pages`.

A new `platform-public-media` public bucket accepts PNG/JPEG/WebP up to 8 MB. Write policies require an authenticated active `platform_memberships` record and an object path prefixed with the user's UUID. Original embedded How It Works screenshots remain the public fallback until replaced. Migration `20261103210000_platform_public_media_owner_uploads` has been applied separately to TEST (`nnsshnfkjcflucjrftzi`) and LIVE (`gxsrajtqzdjvmceqcpgv`). Bucket and three owner-write policies were read back in both. JS syntax parsed in the connector runtime for editor and renderer in both feature branches. PR merge, Cloudflare deployment and browser acceptance remain pending; test drag/resize/upload/save/preview/publish and mobile layout before calling complete.

## Environment separation
- LIVE: `feature/platform-public-visual-builder-live-20261103` → `production`; Supabase `gxsrajtqzdjvmceqcpgv`.
- TEST: `feature/platform-public-visual-builder-test-20261103` → `cloudflare-test`; Supabase `nnsshnfkjcflucjrftzi`.
- Do not copy content or uploads between projects. No subscriber, customer, transaction, inventory, Stripe or domain data changed.

## Remaining acceptance
Merge each PR, verify Cloudflare Worker deployment separately, then browser-test drag, resize, add/delete/duplicate, image upload, draft save/reload, preview, publish and mobile display in each environment. A GitHub merge is not proof of deployment.
