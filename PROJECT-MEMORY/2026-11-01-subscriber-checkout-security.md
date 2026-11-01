# Project Memory — LIVE Subscriber Checkout Security — 1 November 2026

- Repository production branch now contains the deployed subscriber checkout function and collision-guard migration.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (EU West 2).
- `subscriber-create-checkout-session` deployed as version 13, ACTIVE, JWT verification enabled.
- Migration `guard_subscriber_signup_subscription_collisions` applied and registered as `20261101130118`.
- LIVE RPC `subscriber_finalize_signup` verified after application. It serialises per user, accepts only exact same-subscription retries and rejects a different Stripe subscription ID when an active membership already exists.
- LIVE checkout allowlist includes `https://tradeflow.laurendigital.co.uk`, `https://laurendigital.co.uk`, `https://www.laurendigital.co.uk`, and `https://tradeflow.leannelaurenlowe.workers.dev`. It no longer trusts Referer or wildcard CORS.
- Checkout checks active membership before Stripe session creation and uses stable per-user Stripe idempotency.
- TEST Stripe configuration is not required for LIVE work and was not changed.
- Stripe products, prices, API secrets, dashboard settings, customer records, payment records and existing subscription rows were not changed.
- Deployment and migration registry confirmed. Browser checkout and webhook E2E still require verification.
- WebP changes remain isolated on the hardening branch and are not included in this production checkout release.
