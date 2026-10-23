# BusinessFlow

Standalone starter for a simple general-purpose website builder for small businesses and service providers.

## Scope

- Homepage and basic service-business page preview/editor.
- Built-in pages for Home, Services, Recent Projects, About and Contact, plus temporary custom-page creation.
- No TradeFlow catalogue, buying/selling, inventory, customer, shipping or transaction features.
- No Supabase, authentication, persistent storage, Stripe, analytics, or third-party service connection.
- The only planned external relationship is a link to the Lauren Digital public homepage, LaurenDigital.co.uk.

## Current limitation

This is a prototype, not a finished production builder. Edits are held in memory and are lost when the page refreshes. Save, publish, uploads and actual contact-form submissions are not implemented.

## Environments

- TEST: separate Worker named `businessflow-test`.
- LIVE: separate Worker named `businessflow-live`, only after TEST acceptance checks pass.
- No custom domains are configured. Use Workers.dev URLs until deployment and access settings are verified.
- Do not reuse TradeFlow secrets, projects, Workers, DNS, or data.

## Local development

With Node.js and Wrangler installed:

```sh
npx wrangler dev --config wrangler.businessflow-test.jsonc
```

Deploy TEST only after confirming the intended Cloudflare account and isolated credentials:

```sh
npx wrangler deploy --config wrangler.businessflow-test.jsonc
```

Deploy LIVE only after TEST is verified and release is approved:

```sh
npx wrangler deploy --config wrangler.businessflow-live.jsonc
```

Never commit secrets or paste them into chat.

## Repository status

This starter is staged on the isolated `businessflow-standalone-bootstrap-20261023` branch in the TradeFlow repository because the connected GitHub tools do not expose a create-new-repository action. It is not yet an independent repository. Create a separate repository named `BusinessFlow` and transfer only this folder and its two deployment configs there. Do not merge this branch into TradeFlow production or TEST.
