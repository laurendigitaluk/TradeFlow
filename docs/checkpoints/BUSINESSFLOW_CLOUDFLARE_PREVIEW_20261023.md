# BusinessFlow Dedicated Cloudflare Preview — 2026-10-23

- Custom-page naming hardened: new pages start with their own heading/body values; adding or renaming a page rejects case-insensitive duplicate names, including collisions with built-in navigation labels.

- Rename consistency fix: when a custom page uses its default heading, renaming the page now updates that heading as well; a separately edited heading is preserved. Duplicate-name rejection remains in place.

- Accessibility refinement: added a clearly visible keyboard focus outline for buttons, links, inputs, textareas, and selects to make keyboard navigation easier to follow.

## Decision
BusinessFlow's intended customer-facing platform domain is **`businessflow.laurendigital.co.uk`**, alongside the existing `tradeflow.laurendigital.co.uk`. BusinessFlow must use a separate Cloudflare Worker deployment and must not be routed through the existing TradeFlow Worker.

The current Worker is a review prototype named `businessflow-review`. Keep it on its separate Workers.dev preview while the prototype is being checked. Do not point the production BusinessFlow subdomain at the unfinished review prototype. Attach `businessflow.laurendigital.co.uk` to the dedicated BusinessFlow deployment only when the intended BusinessFlow site is ready and verified.

## Files
- `wrangler.businessflow.jsonc`: dedicated deployment configuration.
- `businessflow-preview-worker.js`: minimal static-asset worker; no Supabase bindings, environment variables, authentication, or TradeFlow imports.
- `businessflow-preview/index.html`: isolated review prototype served at the deployment root.
- `businessflow-builder-review.html`: editable source copy for the prototype; keep this in sync with the deployed static asset.

## Preview deployment
From the repository checkout at this feature branch, deploy only the dedicated config:
```sh
npx wrangler deploy --config wrangler.businessflow.jsonc
```
This requires an authorised Cloudflare login and the Wrangler CLI. Confirm the Cloudflare account and deployment name before executing. Do not guess a Workers.dev URL; use the address Cloudflare returns.

## Isolation checks
- Dedicated worker name and config; does not edit `wrangler.jsonc` used by TradeFlow.
- No LIVE/TEST Supabase URL, key, bindings, or database requests in the dedicated worker/config.
- Prototype has no external script or stylesheet imports and is marked `noindex,nofollow`.
- Navigation supports Home, Services, Recent Projects, Contact, About Us, and added pages. Non-home pages now use a shared page layout with editable page heading and body content in the browser-only prototype. This is still not server-persisted, and advanced per-page sections, image uploads, form handling, and publishing are not implemented.
- `businessflow.laurendigital.co.uk` is the target domain, but it is **not configured or attached yet**.
- No Cloudflare deployment was performed as part of this checkpoint. GitHub commits are not proof of Cloudflare deployment.
- Do not connect persistence until an isolated data/access design is approved.

## Latest prototype change
- Added editable heading/body fields for each non-home page.
- Selecting a non-home page shows its own content in the shared page shell; editing those fields updates the preview immediately.
- The standalone source and Cloudflare static asset were updated together and verified to have identical content hashes.
- CTA destination input now permits common safe destinations (`https://`, `http://`, `mailto:`, `tel:`, `/`, and `#`) and falls back to `#` for unsupported schemes such as `javascript:` or `data:`.
- Static review confirms no externally loaded JavaScript or CSS. Browser interaction testing and Cloudflare deployment remain pending.
- This is static/source-level validation only; interactive browser testing and Cloudflare deployment are still pending.

## Git / safety
Branch: `feature/businessflow-isolated-builder-review-20261023`.
Do not merge into `production` or the shared TEST branch. No TradeFlow LIVE resources, routing, database, DNS, or secrets were changed.


## Follow-up navigation fix — 2026-10-23
- Corrected preview navigation so Home scrolls to the home page, while Services, Recent Projects, Contact, About Us, and custom pages scroll to the shared custom-page view rather than trying to find a DOM element whose ID is the selected page ID.
- Removed a redundant page-filter expression; the navigation list now iterates directly over the page list.
- Updated `businessflow-builder-review.html` and `businessflow-preview/index.html`; both now have the same content/blob SHA (`6af1059b42f578e11cb5a691cfdf5f5a9c598a22`).
- Source-level checks only. A real browser interaction test and Cloudflare deployment remain outstanding; no deployment or production-domain change was performed.


## Follow-up preview clarity fix — 2026-10-23
- Updated the editor's introductory note to state plainly that changes exist only in memory and will be lost on refresh or close; no data is saved or published.
- Updated the bottom notice to clarify that Save/Publish are not implemented and persistent storage/publishing require a separately approved isolated data model and access rules.
- Source and preview HTML are byte-identical after the change (blob SHA `541f6f8d5d8efbc62857f64689209c4695845514`).
- Source-level validation only; no browser-based interaction test or deployment has been performed.


## Built-in page layout improvement — 2026-10-23
- Built distinct preview layouts for the Services and Recent Projects pages, using service/project cards rather than displaying only a generic text shell.
- The Contact page now shows the configured contact details and a clear notice that enquiry submission is not yet implemented.
- Page-specific card content is created with DOM APIs and `textContent`; custom page heading/body content remains text-only to avoid treating user-entered text as HTML.
- Updated source and dedicated static preview together. Source-level checks only; browser interaction testing and Cloudflare deployment remain pending.


## Editable service and project cards — 2026-10-23
- Added editor fields for three service cards and three project cards (each title and description).
- The homepage cards and the dedicated Services/Recent Projects page cards now use the same editor values and update as fields change.
- Card labels and descriptions are inserted using DOM `textContent`, not interpreted as HTML.
- Changes remain temporary in browser memory only; no persistence, publishing, upload or form submission was added.
- Source and static preview are synced together. Browser-based interaction testing and Cloudflare deployment remain pending.


## Editable card counts — 2026-10-23
- Added Add/Remove controls for service and project cards, with a minimum of one and maximum of eight cards of each type.
- The editor hides fields for removed cards and uses the active counts for homepage, Services and Recent Projects preview layouts.
- Card text remains inserted via DOM `textContent`. Card count/content remains temporary browser state; refresh discards edits.
- JavaScript syntax validation passed for the source file. This is not a browser interaction test. The preview is still not deployed; Cloudflare deployment and real browser testing remain pending.

- Follow-up correctness check: added the hidden editor fields for cards 4–8 and wired their input events, so increasing the count reveals usable fields instead of referencing missing elements. JavaScript syntax validation passed; no real browser interaction test or deployment has occurred.

## Manual deployment workflow prepared — 2026-10-23
- Added `.github/workflows/businessflow-review-preview.yml` on the isolated feature branch. It is manual-only (`workflow_dispatch`) and refuses to deploy unless the selected ref is `feature/businessflow-isolated-builder-review-20261023`.
- It deploys only `wrangler.businessflow.jsonc` using Wrangler v4, with Cloudflare credentials read from GitHub Actions secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
- The workflow has not been run. It cannot deploy until both repository secrets are configured and a user with GitHub Actions access manually runs it. No secrets were created, requested in chat, or exposed.
- The worker config remains Workers.dev-only; this workflow does not attach `businessflow.laurendigital.co.uk` or change TradeFlow deployment/DNS.


## CTA destination hardening — 2026-10-23
- Tightened the CTA allow-list so protocol-relative destinations beginning `//` are rejected rather than treated as root-relative paths. Supported explicit schemes remain `https://`, `http://`, `mailto:`, and `tel:`, plus same-site root-relative paths beginning with a single `/` and fragment links beginning `#`.
- Updated `businessflow-builder-review.html` and `businessflow-preview/index.html` sequentially; both are byte-identical (blob SHA `675643aa1e47c927c15ba808e325c3f7fabaa6c3`).
- Source-level confirmation only. No browser interaction test or Cloudflare deployment has been completed; no TradeFlow resources or DNS were changed.


## Navigation interaction refinement — 2026-10-23
- Updated the navigation link click handler to prevent the browser's default hash jump before switching to the selected page in the preview. This avoids competing scroll behaviour between the URL fragment and the editor's shared page shell.
- Updated source and static preview sequentially and confirmed matching blob SHA `c83a5a6cc49d5c6fc0995fdd32787a8e816ad3e1`.
- This is a source-level fix only; it has not been exercised in a real browser. The preview remains undeployed and isolated from TradeFlow.


## Dedicated-page card refresh fix — 2026-10-23
- Fixed the Services and Recent Projects page preview so adding or removing cards immediately rebuilds the visible card grid on the currently selected page, rather than leaving stale cards until navigation changes.
- Rebuilt card elements with DOM APIs and `textContent` to preserve the text-only rendering approach.
- Updated source and static preview sequentially and confirmed matching blob SHA `d7b7298918c82e0e12b3b4483e2fe524d4a28e1c`.
- Source-level change only. Browser interaction testing and Cloudflare deployment remain pending; no TradeFlow LIVE/TEST resources or DNS were changed.


## Custom page removal control — 2026-10-23
- Added a Remove custom page control to the temporary page editor. It only removes user-added pages; Home, Services, Recent Projects, About Us, and Contact are protected from removal.
- Removal asks for confirmation, returns the preview to Home, and refreshes navigation. The editor remains memory-only, so this does not delete persisted data or affect a published site.
- Updated source and preview sequentially and verified matching blob SHA `6f1ba1eecf6b3d8b213594ff2dfa23848f317a4a`.
- Source-level change only. Browser testing and Cloudflare deployment are still pending; TradeFlow LIVE/TEST and DNS remain untouched.
