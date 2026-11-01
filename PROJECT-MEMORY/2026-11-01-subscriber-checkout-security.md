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


## LIVE subscriber billing interval correction — 1 November 2026

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`. Applied migration `preserve_subscriber_billing_interval`, registry version `20261101131036`.
- `public.subscriber_finalize_signup` now derives `tenant_subscriptions.billing_interval` from the exact active `enhanced` plan Stripe Price ID: configured annual Price ID maps to `year`; monthly Price ID maps to `month`. Unknown or missing Price IDs fail closed before tenant provisioning.
- `public.subscriber_sync_subscription` now updates the interval only when the incoming Price ID matches that plan's configured monthly or annual Price ID. Null or unrecognised Price IDs preserve the stored interval.
- Existing per-user advisory lock and same-subscription idempotency/collision protection are preserved. Function signatures and SECURITY DEFINER/search_path settings remain unchanged.
- Verified the applied RPC definitions and migration registry. Existing LIVE subscription rows were not rewritten. The one historical Stripe row remains cancelled/monthly; the complimentary manual entitlement remains active and unchanged.
- LIVE plan read-only check: £59.99/month, £499.99/year, GBP, 30-day trial; both configured Stripe Price IDs present. No Stripe settings or records changed.
- Browser checkout and webhook E2E remain unverified. Do not initiate a real LIVE checkout without an agreed controlled test plan.

## Webhook source reconciliation — outstanding

- LIVE deployed `stripe-payment-webhook` remains ACTIVE version 16. Its deployed source contains connected-account handling for `account.updated` and connected-account retail payment/refund validation.
- GitHub `production` and `security/prelaunch-hardening-20261101` copies have the same older blob and do not contain those deployed additions. This is confirmed source drift, not an authorised reason to overwrite the deployed function.
- Do not redeploy the repository copy or modify the deployed webhook until the full deployed source is reconciled into version control and its payment-provider/connected-account behaviour is reviewed.
- No matching subscriber checkout/webhook requests appeared in the available recent LIVE function logs. This is not proof that Stripe has never sent events; it only means no recent matching requests were returned in the queried window.
