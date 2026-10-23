# BusinessFlow Dedicated Cloudflare Preview — 2026-10-23

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
- This is static/source-level validation only; interactive browser testing and Cloudflare deployment are still pending.

## Git / safety
Branch: `feature/businessflow-isolated-builder-review-20261023`.
Do not merge into `production` or the shared TEST branch. No TradeFlow LIVE resources, routing, database, DNS, or secrets were changed.
