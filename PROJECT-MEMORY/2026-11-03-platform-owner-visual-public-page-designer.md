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


## Merge status — 3 November 2026
- LIVE PR #206 merged into `production` at `d08f4f156452d066cd39dad7943f8e39e38985d1`.
- TEST PR #207 merged into `cloudflare-test` at `04989110d3fd49ab0bcf152e34819cc38193ac5d`.
- Both branch heads were read back at their merge commits. GitHub reports no commit statuses and zero Actions workflow runs for either head. The Worker dashboard URLs could not be opened through the available browser check. Cloudflare deployment and browser acceptance therefore remain unverified; do not tell the user the feature is live until that is checked.


Final editor refinement: free-position text/image/screenshot boxes are independently draggable and resizable on the canvas (x/y/width/height are also editable in the inspector). Full-width image boxes are rendered as images rather than hidden, and the owner canvas stacks split layouts on narrow screens. TEST visual editor URL/key were checked against TEST's own existing owner editor configuration; LIVE remains on LIVE Supabase. These refinements are included in the merged branches.


## Independent text and media boxes; unnumbered page copy — 4 November 2026
The owner visual page editor now creates text-only boxes and image/screenshot-only boxes. They are independent objects with separate drag, resize, x/y/width/height controls; text boxes no longer contain empty image columns, and media boxes no longer carry heading/body fields. Existing screenshot captions/titles are imported as their own text boxes next to independent media boxes. Public rendering follows the same independent object model. Automatic sequence labels (01/02/03), ordered-list markers and leading PART/step number prefixes are removed from How It Works copy. This is a presentation/editor change only: no Supabase schema, public page data, subscriber builder, tenant/customer records, or LIVE/TEST content was migrated or copied.

## Change verification
The current source and environment mapping were checked before modification. LIVE and TEST public page tables contain the same two published slugs; neither environment has a saved visual_layout in draft_content at this checkpoint, so the new independent layout is generated from existing page content on first editor load. Existing public-page RPCs and media bucket policies remain unchanged.

## Duplicate public-page copy correction — 4 November 2026
The owner visual editor's first-time layout conversion previously imported the comparison heading/paragraph and then imported the first screenshot's identical heading/paragraph again, creating two text boxes above the same screenshot. `platform-public-pages-visual-editor.js` now de-duplicates text blocks by normalized heading while retaining the screenshot box. The conversion also strips leading numeric/Part/Step prefixes before creating text blocks. This does not split a heading from its paragraph: each text box remains one independently movable text element containing its optional heading and body, while image/screenshot boxes remain separate independent elements. No saved `visual_layout` existed in either environment at the time of diagnosis; legacy `draft_content` remains unchanged until the owner saves a draft. No database schema, published content, tenant/customer data, or subscriber Website Builder code is changed.
