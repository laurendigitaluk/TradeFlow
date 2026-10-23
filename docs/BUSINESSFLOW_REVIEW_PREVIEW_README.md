# BusinessFlow review preview

This is an isolated, temporary review build for the BusinessFlow website-builder concept. It is not the production BusinessFlow site.

## Safety boundary

- Deploy only from `feature/businessflow-isolated-builder-review-20261023`.
- Use the dedicated `wrangler.businessflow.jsonc` configuration and Worker name `businessflow-review`.
- Do not use the TradeFlow `wrangler.jsonc`, TradeFlow Worker, or TradeFlow Supabase projects.
- The review preview has no authentication, database persistence, image uploads, working contact form, or publish/save implementation. Edits are held in browser memory and disappear on refresh.
- Do not attach `businessflow.laurendigital.co.uk` to this review build. Keep the target domain unattached until the product is ready and separately verified.

## Manual preview deployment

The workflow is `.github/workflows/businessflow-review-preview.yml`. It is designed to run manually and has a branch guard that allows deployment only when the selected ref is `feature/businessflow-isolated-builder-review-20261023`.

The workflow requires these GitHub Actions repository secrets to be configured by a repository administrator:

- `CLOUDFLARE_API_TOKEN` — a Cloudflare API token with only the permissions needed to deploy this Worker.
- `CLOUDFLARE_ACCOUNT_ID` — the intended Cloudflare account identifier.

Never commit these values or paste them into chat, source files, or workflow logs.

### Important GitHub Actions limitation

GitHub's `workflow_dispatch` UI generally requires the workflow file to exist on the repository's default branch before the workflow can be dispatched from the Actions tab. This preview workflow is intentionally isolated on the feature branch and has not been copied to the default branch because doing so would modify a shared branch outside the approved isolation boundary.

Therefore, the deployment workflow may not be visible/dispatchable from GitHub's Actions UI until a repository administrator deliberately chooses an approved way to expose the manual workflow. Do not merge this branch or copy the workflow into `production` or TEST just to make the button appear. An authorised operator can instead deploy this feature branch from a secured environment using Wrangler and the dedicated config, or separately approve a narrowly scoped workflow-dispatch enablement change.

When deployment succeeds, use the exact Workers.dev URL reported by Cloudflare/Wrangler. Do not guess the URL. Confirm the page loads before sharing it for review.

## Verification checklist after deployment

1. Confirm the deployed Worker is named `businessflow-review` and uses `wrangler.businessflow.jsonc`.
2. Open the exact Workers.dev URL returned by the deployment.
3. Test editor inputs, section toggles, CTA destination handling, page navigation, custom-page creation/renaming, and service/project card add/remove controls.
4. Refresh the page and confirm the prototype clearly communicates that unsaved edits are lost.
5. Confirm no TradeFlow login, catalogue, customer records, transaction flows, or Supabase calls are present.
6. Do not attach the production BusinessFlow subdomain or add persistence until separately approved.

## Current status

Source-level checks and source/static-preview byte identity have been verified. A real browser interaction test and a Cloudflare deployment have **not** yet been completed, so there is no verified preview URL at this checkpoint.
