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


## Email-confirmation checkout resume correction — 1 November 2026

- Production `subscriber-signup.js` now includes the selected `billing_interval` in Supabase Auth user metadata as well as the existing pending-signup browser record (commit `cc6b9e898a8f35f7ae5e6c24b2e9b2e5825136ce`).
- Production `subscriber-login.html` now resumes checkout with the saved monthly/annual choice when the pending signup email matches the authenticated account; it falls back to the Auth metadata interval and then monthly only when no saved selection exists (commit `92068c1ed9c9477141d6d1857273b7bdd9c74d63`).
- The pending signup record is cleared when the account already has an active membership and the user is sent to the subscriber dashboard.
- Static source inspection confirms the selected interval is passed into `subscriber-create-checkout-session`. Browser verification remains outstanding; do not claim the email-confirmation route has passed end-to-end testing.


## Deployed LIVE webhook v16 source-drift finding — 1 November 2026

- Preserved the exact deployed LIVE `stripe-payment-webhook` version 16 entrypoint in `PROJECT-MEMORY/SNAPSHOTS/2026-11-01-live-stripe-payment-webhook-v16.ts` (commit `e40442c84d682f60ef0c80e98e87226a58c1ad0d`). This is an evidence snapshot only; it is not a deployable replacement.
- The deployed v16 source contains `account.updated` handling and connected-account validation/refund logic. The GitHub `production` and `security/prelaunch-hardening-20261101` function files are the same older blob and omit those deployed branches. Do not redeploy either older copy over LIVE.
- The deployed source references `admin.from(...)` in the legacy domain-order payment path but has no `admin` declaration/import in the entrypoint. This is a likely runtime ReferenceError if that retired domain-order branch is invoked. Do not invoke the retired flow; investigate and repair it separately after the deployed source is reconciled. The subscriber signup branch does not use this identifier.
- Production frontend commits for billing interval persistence are in GitHub, but no GitHub CI/check runs are attached to the commit and the deployed Cloudflare Worker/static response could not be independently verified in this session. Treat the frontend change as committed, not yet deployment-verified.

## Follow-up — correct retired TEST project references in signup/login

Production `subscriber-login.html` and `subscriber-signup.js` were found to contain the retired TEST Supabase project `twfbmjwwqzxdxvclxbun`. Both were corrected to current TEST project `nnsshnfkjcflucjrftzi` and its current publishable key. The signup runtime detector now explicitly recognises `tradeflow-test.leannelaurenlowe.workers.dev`, matching login. Commits: `0bd129a2c2645a6919b8b7f2408d7d1cfa905145`, `301508f507d88e2cb960390ae02f042ffece3a18`, `eaa66db4835f49cb51c4c97e6b656eda4e729f1d`. Static checks only; deployment and browser verification remain outstanding.

## Webhook review branch refresh — 1 November 2026

- The first webhook review branch diverged after subsequent production commits. A clean replacement branch was created from the latest `production` head (`aac33ed248ce3a7c9a22efd8ce7b5ee606cd24d3`) to avoid carrying unrelated divergence.
- Current review branch: `reconcile/live-stripe-webhook-v16-20261101-v2`; draft PR [#192](https://github.com/laurendigitaluk/TradeFlow/pull/192). The branch has been rebased to latest production and is one commit ahead, zero behind.
- The replacement branch starts from current production, including the subscriber TEST routing corrections. Only the reconciled webhook source is added to this branch; current LIVE remains webhook v16 until review/testing.


## Webhook source reconciliation completed in review branch — 1 November 2026

- Re-read LIVE `stripe-payment-webhook` source and confirmed it remains ACTIVE version 16; no deployment or LIVE payment mutation was made.
- Re-read the preserved v16 source snapshot and current PR branch source. The branch contains the deployed connected-account `account.updated` handling, tenant/account matching, connected-account payment/refund routing and refund idempotency protections.
- The review branch repairs the three undefined `admin.from(...)` calls in the legacy domain-order path using service-role REST GET/PATCH requests. Expired-order PATCH remains constrained to `status=eq.pending_payment`.
- Current branch `reconcile/live-stripe-webhook-v16-20261101-v2`; draft PR #192. Compared with `production`: exactly 1 commit ahead, 0 behind; only `supabase/functions/stripe-payment-webhook/index.ts` changed (16 additions, 12 deletions). No PR reviews or inline review threads were present at recheck.
- Static source checks: no remaining `admin` references; connected-account and conflict-refund protections present; domain-order expiry guard present. These are source inspections, not runtime tests.
- Runtime execution, signed Stripe event replay and webhook integration tests remain outstanding because a Deno runtime/test environment is not currently available. Do not merge or deploy until these checks can be run against the exact PR source.
- User does not need to run LIVE website tests now. Do not create a Stripe checkout/payment or alter the Adventure Outpost complimentary account for this work.
