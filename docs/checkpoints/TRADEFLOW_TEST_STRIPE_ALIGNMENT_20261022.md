# TradeFlow TEST Stripe Alignment Checkpoint — 22 October 2026

## Scope
- Environment changed: TEST only.
- TEST Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project and Stripe configuration were not changed.
- Product/category/shared-evidence database work remains outside this workstream.

## Change applied
- Added an explicit Stripe mode guard to `subscriber-create-checkout-session` on branch `test/stripe-connect-test-mode-repair-20261020`.
- TEST defaults `TRADEFLOW_STRIPE_MODE` to `test` and checks the configured `STRIPE_SECRET_KEY` prefix against the expected mode before creating a subscription Checkout Session.
- A mismatch or missing/invalid key now fails closed with HTTP 503 instead of attempting checkout using an unknown Stripe mode.
- Source commit: `44183f0d4284e558a1aad64b1cc82bb541319c1a`.

## Deployment
- Deployed `subscriber-create-checkout-session` to TEST only.
- Supabase reported the function ACTIVE at version 11 with JWT verification enabled.
- No LIVE function was deployed or modified.

## Verification and limits
- Deployment status is confirmed by Supabase.
- The source-level mode guard is present in the deployed version.
- A real subscriber checkout was not initiated because this would require a controlled test subscriber and confirmation that TEST Stripe secrets and webhook endpoints are configured. Secret values were not read or logged.
- Remaining Stripe acceptance checks: confirm the TEST project's `STRIPE_SECRET_KEY` is a Stripe test-mode key, `TRADEFLOW_STRIPE_MODE=test`, matching TEST webhook signing secrets/endpoints, then run signup checkout and webhook completion using Stripe test mode.
- This checkpoint does not claim full TEST/LIVE feature parity or end-to-end Stripe acceptance. Branch commit-count differences are not, by themselves, evidence of broken functionality.
