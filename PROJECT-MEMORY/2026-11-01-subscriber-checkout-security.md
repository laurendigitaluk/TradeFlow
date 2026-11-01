# Project Memory — Subscriber Checkout Security Hardening — 1 November 2026

- Workstream: TradeFlow LIVE pre-launch security hardening.
- Repository: `laurendigitaluk/TradeFlow`.
- Working branch: `security/prelaunch-hardening-20261101`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv` (EU West 2). Current TEST Supabase: `nnsshnfkjcflucjrftzi`. Retired TEST project `twfbmjwwqzxdxvclxbun` must not be used.
- Verified platform-owned LIVE origins for subscriber signup: `https://tradeflow.laurendigital.co.uk`, `https://laurendigital.co.uk`, `https://www.laurendigital.co.uk`, `https://tradeflow.leannelaurenlowe.workers.dev`. TEST Worker, subscriber-owned domains, owner host and other product hosts are excluded from LIVE. When deployed to current TEST project `nnsshnfkjcflucjrftzi`, the same source selects a separate TEST-only allowlist containing only `https://tradeflow-test.leannelaurenlowe.workers.dev`, based on the exact `SUPABASE_URL` hostname.
- LIVE `subscriber-create-checkout-session` was version 12 and accepted unvalidated Origin/Referer values for Stripe return URLs. It had no Stripe idempotency key and did not check whether the authenticated user already had an active tenant membership.
- LIVE `stripe-payment-webhook` was version 16. It verifies Stripe signatures and calls `public.subscriber_finalize_signup(...)` for subscription Checkout completion.
- LIVE `subscriber_finalize_signup` previously overwrote an existing tenant subscription's Stripe subscription ID when the user already had an active tenant membership. The database has a unique index on (billing_provider, provider_subscription_id), but that does not prevent replacing the existing subscription reference.
- Candidate Edge Function hardening committed to this branch: strict HTTPS platform-origin allowlist, origin-bound CORS, no Referer fallback, fail-closed active-membership lookup, stable per-user Stripe idempotency key (request-level protection while Stripe retains the key; no persistent checkout-attempt ledger is included). Existing plan/price/trial parameters were preserved.
- Candidate SQL migration `supabase/migrations/20261101130000_guard_subscriber_signup_subscription_collisions.sql` serialises finalisation per Auth user, accepts a retry only for the exact same Stripe subscription ID and rejects a different subscription ID without mutating the existing subscription.
- Added developer diagnostic roadmap `docs/DEVELOPER-DIAGNOSTIC-ROADMAP-SUBSCRIBER-CHECKOUT.md`.
- Stripe products, prices, secrets, settings, customer/payment records and subscription rows were not changed. No LIVE or TEST Edge Function deployment or database migration application was performed.
- No checkout, webhook, browser or Stripe Sandbox tests have yet been run. Do not describe the changes as tested or deployed. Next step: inspect the candidate diff, apply the migration to current TEST only when ready, test against TEST Stripe configuration without copying LIVE secrets/data, then verify and review before any LIVE promotion.


## LIVE release update — 1 November 2026

**Production deployment completed after direct inspection of the LIVE database function signatures and current LIVE Edge Function.**

- Supabase project: `gxsrajtqzdjvmceqcpgv` (TradeFlow Live, EU West 2).
- `subscriber-create-checkout-session` deployed successfully as version **13**, with JWT verification still enabled.
- LIVE database migration `guard_subscriber_signup_subscription_collisions` applied successfully and recorded as migration version `20261101130118`.
- The LIVE `subscriber_finalize_signup(uuid,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb)` definition was re-read after migration and confirmed to contain the per-user advisory lock, same-Stripe-subscription retry guard and rejection of a different subscription ID for an existing active member.
- The deployed checkout source was re-read from Supabase and confirmed to contain the strict LIVE origin allowlist, no Referer fallback, exact-origin CORS, active-membership lookup, and stable per-user Stripe idempotency key.
- The current TEST project and its Stripe configuration were not used or changed. TEST Stripe is not a prerequisite for this LIVE deployment.
- Stripe products, prices, API secrets, dashboard settings, customer records, payment records and existing subscription rows were not changed.
- No live payment or customer signup was initiated during deployment. Full browser checkout and webhook E2E verification remain outstanding; do not describe the checkout journey as fully tested until those tests are completed.
