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
1. Recovered the deployed TEST onboarding and both webhook handlers into this isolated branch; checkout was also recovered from the deployed TEST function.
2. Added explicit environment/key mode checks to onboarding and checkout, and event-mode checks to both webhook handlers. Existing connections are checked against the expected mode.
3. Added `wrangler.test.jsonc` targeting only the new TEST project; its publishable-key entries are placeholders and must not be deployed until replaced with the correct public keys.
4. Static source assertions pass for the onboarding key gate, persisted mode, existing-account mode mismatch, checkout key/account mode checks, both webhook event-mode checks, and new TEST project routing.
5. Remaining: validate TypeScript by deploying only to new TEST, configure TEST-only secrets, verify Stripe webhook endpoint destinations, then run onboarding, checkout, webhook and failure/refund regression tests.
6. Update operator and AI manuals after runtime tests pass.

## Secret handling
Do not put secret values in source control or chat. Configure STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET and STRIPE_CONNECT_WEBHOOK_SECRET only in the new TEST project's Edge Function secrets, using Stripe test-mode credentials and the matching endpoint signing secrets.

## Current status
A dedicated branch exists: `test/stripe-connect-test-mode-repair-20261020`. The deployed TEST Connect source has been restored into the branch and mode guards have been added. No functions have been deployed from this branch and no secrets have been changed. LIVE remains untouched. Static assertions pass, but compilation/runtime and end-to-end purchase testing are still outstanding.
