# Stripe Connect TEST Repair — 20 October 2026

## Scope
This branch is isolated from production. Do not merge or deploy to LIVE.

## Confirmed TEST environment
- New TEST Supabase project: nnsshnfkjcflucjrftzi
- TEST URL: https://nnsshnfkjcflucjrftzi.supabase.co
- Stripe Connect onboarding and webhook functions are deployed in TEST but their source files are missing from the production function directory.
- The deployed onboarding function requires a live-mode Stripe secret and writes connections as live mode.
- The deployed retail checkout function rejects connected-account records unless livemode is true.
- The Worker configuration currently references the retired TEST project twfbmjwwqzxdxvclxbun.

## Required repair sequence
1. Recover the exact deployed TEST function source and retain a read-only baseline.
2. Implement explicit test/live mode separation in Connect onboarding, checkout and webhook handlers.
3. Create a Worker configuration dedicated to the new TEST project; never change LIVE routing in this branch.
4. Confirm each Stripe webhook endpoint and signing secret independently.
5. Add automated/static checks for test-mode key enforcement and event mode matching.
6. Deploy only to new TEST after source review; run onboarding, checkout, webhook and refund/failed-payment tests.
7. Update operator and AI manuals after tests pass.

## Secret handling
Do not put secret values in source control or chat. Configure STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET and STRIPE_CONNECT_WEBHOOK_SECRET only in the new TEST project's Edge Function secrets, using Stripe test-mode credentials and the matching endpoint signing secrets.

## Current status
No code has been deployed or secrets changed. LIVE remains untouched. The test-mode repair is not yet complete or verified.
