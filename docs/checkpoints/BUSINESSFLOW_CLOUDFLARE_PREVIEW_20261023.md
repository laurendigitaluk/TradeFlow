# BusinessFlow Dedicated Cloudflare Preview — 2026-10-23

## Decision
BusinessFlow preview uses a separate Cloudflare Worker deployment, named `businessflow-review`. It must not be routed through the existing TradeFlow Worker.

## Files
- `wrangler.businessflow.jsonc`: dedicated deployment configuration.
- `businessflow-preview-worker.js`: minimal static-asset worker; no Supabase bindings, environment variables, authentication, or TradeFlow imports.
- `businessflow-preview/index.html`: isolated review prototype served at the deployment root.

## Deployment
From the repository checkout at this feature branch, deploy only the dedicated config:
```sh
npx wrangler deploy --config wrangler.businessflow.jsonc
```
This requires an authorised Cloudflare login and the Wrangler CLI. Confirm the account and deployment name before executing. The expected Workers.dev address is associated with the worker name `businessflow-review`; do not guess a URL before Cloudflare confirms it.

## Isolation checks
- Dedicated worker name and config; does not edit `wrangler.jsonc` used by TradeFlow.
- No LIVE/TEST Supabase URL, key, bindings, or database requests in the dedicated worker/config.
- Prototype has no external script or stylesheet imports and is marked `noindex,nofollow`.
- No custom domain is configured in this preview setup.
- No deployment was performed as part of this checkpoint. GitHub commits are not proof of Cloudflare deployment.
- Do not add a custom domain or connect persistence until the independent preview has been tested and an isolated data/access design is approved.

## Git / safety
Branch: `feature/businessflow-isolated-builder-review-20261023`.
Do not merge into `production` or the shared TEST branch. No TradeFlow LIVE resources, routing, database, or secrets were changed.
