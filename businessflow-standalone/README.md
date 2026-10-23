# BusinessFlow

Standalone starter for a general-purpose website builder for small businesses and service providers.

## Current implementation

- Responsive service-business website editor and live preview.
- Built-in pages for Home, Services, Recent Projects, About and Contact, plus temporary custom pages.
- Subscriber sign-up, sign-in and sign-out through the dedicated BusinessFlow Supabase project.
- Save and reload website drafts from `public.businessflow_sites` and `public.businessflow_pages`.
- Private `businessflow-assets` Storage bucket with per-site owner policies; browser upload UI is not implemented yet.
- Row-level security is enabled on the BusinessFlow tables. No service-role key is used in the browser.
- No TradeFlow catalogue, buying/selling, inventory, customer, shipping or transaction features.
- No Stripe or subscription billing integration yet.
- Publishing is not implemented: saved websites remain drafts and are not publicly served.
- The editor loads Supabase JS from jsDelivr; production deployment should pin and self-host or otherwise review this dependency.

## Supabase TEST project

- Project: `BusinessFlow`
- Project ref: `ktvvtdrdwlazfsgkfedo`
- Region: `eu-west-2`
- API URL: `https://ktvvtdrdwlazfsgkfedo.supabase.co`
- Uses the publishable browser key only. Never put a service-role key in frontend code.
- Tables: `businessflow_sites`, `businessflow_pages`.
- Storage bucket: `businessflow-assets` (private, 10 MB max per object).
- RLS restricts website/page access and storage access to the authenticated site owner.

The HTML currently points at this project for development and TEST only. Before any LIVE release, configure a separate LIVE Supabase project and use environment-specific public URL/key settings. Do not ship the TEST project configuration as LIVE.

## Current limitations and test notes

- Sign-up may require email confirmation according to the Supabase Auth settings.
- Save creates or updates a draft and replaces its page records; Load restores the latest draft for the signed-in subscriber.
- Image upload, custom domain mapping, public page rendering, real contact form submission, subscriptions and publishing remain unfinished.
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

This starter is staged on the isolated `businessflow-standalone-bootstrap-20261023` branch in the TradeFlow repository because the connected GitHub tools do not expose a create-new-repository action. It is not yet an independent repository. Transfer only this folder and its two deployment configs to a separate repository named `BusinessFlow`. Do not merge this branch into TradeFlow production or TEST.
