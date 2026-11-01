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


## Subscriber billing interval correction — 1 November 2026
- Applied LIVE migration `preserve_subscriber_billing_interval`, registry version `20261101131036`.
- Finalisation maps exact configured annual/monthly Stripe Price IDs to `year`/`month`; unknown IDs fail closed. Subscription updates preserve the interval unless the incoming price matches a configured ID.
- Verified RPC definitions and migration registry. Existing subscription rows and all Stripe configuration/records were left unchanged.
- LIVE deployed webhook version 16 contains connected-account code absent from GitHub production and hardening branch; do not redeploy it until source reconciliation is complete.
- Browser signup, real Stripe Checkout and full webhook E2E remain outstanding.


## Email-confirmation resume path — 1 November 2026
- `subscriber-signup.js` persists selected billing interval in Auth metadata and pending browser signup state (commit `cc6b9e898a8f35f7ae5e6c24b2e9b2e5825136ce`).
- `subscriber-login.html` resumes checkout using the pending interval only when its email matches the signed-in account, otherwise using Auth metadata then monthly fallback (commit `92068c1ed9c9477141d6d1857273b7bdd9c74d63`).
- Pending signup state is cleared after a membership is found. Browser/email-confirmation E2E still required.


## Deployed LIVE webhook v16 source-drift finding — 1 November 2026

- Preserved the exact deployed LIVE `stripe-payment-webhook` version 16 entrypoint in `PROJECT-MEMORY/SNAPSHOTS/2026-11-01-live-stripe-payment-webhook-v16.ts` (commit `e40442c84d682f60ef0c80e98e87226a58c1ad0d`). This is an evidence snapshot only; it is not a deployable replacement.
- The deployed v16 source contains `account.updated` handling and connected-account validation/refund logic. The GitHub `production` and `security/prelaunch-hardening-20261101` function files are the same older blob and omit those deployed branches. Do not redeploy either older copy over LIVE.
- The deployed source references `admin.from(...)` in the legacy domain-order payment path but has no `admin` declaration/import in the entrypoint. This is a likely runtime ReferenceError if that retired domain-order branch is invoked. Do not invoke the retired flow; investigate and repair it separately after the deployed source is reconciled. The subscriber signup branch does not use this identifier.
- Production frontend commits for billing interval persistence are in GitHub, but no GitHub CI/check runs are attached to the commit and the deployed Cloudflare Worker/static response could not be independently verified in this session. Treat the frontend change as committed, not yet deployment-verified.

## Checkpoint addendum — subscriber TEST endpoint routing

- Corrected retired TEST Supabase references in `subscriber-login.html` and `subscriber-signup.js` to current TEST project `nnsshnfkjcflucjrftzi` and current TEST publishable key.
- Signup detector explicitly recognises `tradeflow-test.leannelaurenlowe.workers.dev`.
- Commits: `0bd129a2c2645a6919b8b7f2408d7d1cfa905145`, `301508f507d88e2cb960390ae02f042ffece3a18`, `eaa66db4835f49cb51c4c97e6b656eda4e729f1d`.
- Static verification only; no live browser/Worker verification. Do not treat the commits as a deployed release.

## Webhook review branch refresh — 1 November 2026

- The first webhook review branch diverged after subsequent production commits. A clean replacement branch was created from the latest `production` head (`aac33ed248ce3a7c9a22efd8ce7b5ee606cd24d3`) to avoid carrying unrelated divergence.
- Current review branch: `reconcile/live-stripe-webhook-v16-20261101-v2`; webhook reconciliation commit `d60e50919eae2f6e46d0c2176088c6a1cc427629`.
- The replacement branch starts from current production, including the subscriber TEST routing corrections. Only the reconciled webhook source is added to this branch; current LIVE remains webhook v16 until review/testing.
