# LIVE Pre-launch Security Checkpoint — 1 November 2026

## Subscriber signup checkout — deployed
- Supabase LIVE: `gxsrajtqzdjvmceqcpgv` (EU West 2).
- Edge Function `subscriber-create-checkout-session`: version 13, ACTIVE, JWT verification enabled.
- Migration `guard_subscriber_signup_subscription_collisions`: applied, recorded as version `20261101130118`.
- LIVE RPC verified after application: per-user advisory lock; idempotent same-subscription retry; reject different subscription ID for an existing active member without updating the existing subscription.
- LIVE origin allowlist: TradeFlow subdomain, Lauren Digital apex/www, LIVE workers.dev host. No Referer fallback; exact-origin CORS.
- Active membership lookup is fail-closed and blocks a new subscription for an account with an existing active business.
- Stripe Checkout uses a stable per-user idempotency key and existing plan, Price IDs and trial settings.
- TEST Stripe is not required for this LIVE deployment and was not changed.
- No Stripe products, prices, API secrets, dashboard settings, customer records, payment records or existing subscription rows were changed.
- Deployment and database state confirmed by re-reading the deployed function and RPC and checking migration registry.
- Browser checkout, real Stripe checkout and full webhook E2E remain unverified.

## WebP hardening
Website Builder, inventory and retail listing image conversion remains on the isolated hardening branch unless separately promoted. Do not assume it is live from this checkout release.
