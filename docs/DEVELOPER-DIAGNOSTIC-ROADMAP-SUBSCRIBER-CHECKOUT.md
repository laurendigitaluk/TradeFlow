# Developer Diagnostic Roadmap — Subscriber Signup & Subscription Checkout

**Production status (1 November 2026):** LIVE checkout Edge Function version 13 is deployed; subscription-collision migration is applied to LIVE. Browser checkout/webhook E2E remains outstanding.

## User journey
`subscriber-signup.html` → `subscriber-signup.js` → Supabase Auth → `subscriber-create-checkout-session` → Stripe Checkout → `subscriber-signup-success.html` → `stripe-payment-webhook` → `subscriber_finalize_signup`.

## LIVE environment
- Supabase project: `gxsrajtqzdjvmceqcpgv` (EU West 2).
- Edge Function: `subscriber-create-checkout-session`, version 13, JWT verification enabled.
- Webhook: `stripe-payment-webhook`, version 16 at last inspection.
- RPC: `public.subscriber_finalize_signup(uuid,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb)`.
- Membership check: `public.subscriber_get_my_memberships()`.

## Origin and CORS boundary
LIVE accepts only:
- `https://tradeflow.laurendigital.co.uk`
- `https://laurendigital.co.uk`
- `https://www.laurendigital.co.uk`
- `https://tradeflow.leannelaurenlowe.workers.dev`

No Referer fallback. CORS is bound to the validated Origin. TEST worker, subscriber-owned domains, SceneSource, Platform Owner, StudioFlow and BusinessFlow origins are not permitted for LIVE signup.

## Checkout controls
1. Validate HTTPS Origin against the exact LIVE allowlist.
2. Validate the Supabase bearer token.
3. Call `subscriber_get_my_memberships()`; fail closed if lookup fails; reject an existing active membership.
4. Read the existing `enhanced` plan and configured Stripe Price ID; do not create or modify Stripe products/prices.
5. Create subscription Checkout with existing trial settings and stable per-user Stripe idempotency key.
6. Build return URLs from the validated Origin only.

Stripe idempotency protects requests only while Stripe retains the key result; there is no permanent checkout-attempt ledger. If webhook finalisation is unresolved beyond the retention window, reconcile the completed Stripe session before permitting a new attempt.

## Webhook and database
The webhook verifies Stripe signatures, retrieves the Stripe subscription and calls `subscriber_finalize_signup`.

LIVE migration `guard_subscriber_signup_subscription_collisions` was applied and recorded as `20261101130118`. The RPC now:
- takes a per-user advisory transaction lock;
- returns idempotently only if the same Stripe subscription ID is already linked to that user's active tenant;
- rejects a different subscription ID without updating the existing subscription;
- provisions a tenant, public profile, owner membership and subscription only when no active membership exists.

## Failure points
- 403: Origin is not on the LIVE allowlist.
- 401: Auth token invalid or missing.
- 503: active membership lookup failed; checkout must not continue.
- 409: account already has a business, or Stripe idempotency parameters conflict.
- Webhook/RPC failure: inspect Stripe delivery, signature, retrieved subscription and RPC exception. Never overwrite an existing complimentary/manual/paid subscription to force completion.

## Verification still required
- Real browser signup from each supported LIVE origin.
- Existing subscriber and complimentary account rejection.
- Monthly and annual checkout return paths.
- Successful checkout → webhook → tenant provisioning → subscriber dashboard.
- Duplicate webhook for same subscription.
- Different subscription ID collision rejected and existing subscription unchanged.
- Cancellation, expiry and retry handling.
- No live payment should be created solely for a test without an explicitly agreed test plan.

TEST Stripe is not required for this LIVE work and was not changed. Stripe settings, products, prices, secrets, payment/customer records and existing subscription rows were not modified during deployment.


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

## Subscriber TEST endpoint correction — 1 November 2026

- Production `subscriber-login.html` and `subscriber-signup.js` contained the retired TEST project ref `twfbmjwwqzxdxvclxbun`. Updated both to the current TEST project `nnsshnfkjcflucjrftzi` and its current publishable key from the committed `wrangler.jsonc`.
- Added the explicit `tradeflow-test.leannelaurenlowe.workers.dev` hostname to the signup script's TEST detector, matching the login page. This avoids depending solely on Worker source rewriting to select TEST.
- Commits: login `0bd129a2c2645a6919b8b7f2408d7d1cfa905145`; signup TEST endpoint `301508f507d88e2cb960390ae02f042ffece3a18`; explicit hostname `eaa66db4835f49cb51c4c97e6b656eda4e729f1d`.
- Static source inspection confirms both files reference current TEST and no longer contain the retired TEST ref/key. Browser/Worker runtime verification and Cloudflare deployment are still outstanding.

## Webhook review branch refresh — 1 November 2026

- The first webhook review branch diverged after subsequent production commits. A clean replacement branch was created from the latest `production` head (`aac33ed248ce3a7c9a22efd8ce7b5ee606cd24d3`) to avoid carrying unrelated divergence.
- Current review branch: `reconcile/live-stripe-webhook-v16-20261101-v2`; draft PR [#192](https://github.com/laurendigitaluk/TradeFlow/pull/192). The branch has been rebased to latest production and is one commit ahead, zero behind.
- The replacement branch starts from current production, including the subscriber TEST routing corrections. Only the reconciled webhook source is added to this branch; current LIVE remains webhook v16 until review/testing.


## Webhook reconciliation follow-up — 1 November 2026

**Current state:** LIVE `stripe-payment-webhook` remains ACTIVE version 16. Its exact deployed source is preserved in `PROJECT-MEMORY/SNAPSHOTS/2026-11-01-live-stripe-payment-webhook-v16.ts`. The reconciled source is now in draft PR #192 on `reconcile/live-stripe-webhook-v16-20261101-v2`.

- The PR branch includes deployed `account.updated` connected-account status handling, tenant/account matching, connected-account retail payment/refund routing and the `tradeflow-conflict-refund-` idempotency key.
- The three undefined `admin.from(...)` calls in the legacy domain-order path are replaced with service-role REST requests. Expiry PATCH is guarded by `status=eq.pending_payment`.
- Latest compare against `production`: one commit ahead, zero behind; only the webhook entrypoint changed. No review submissions or inline review threads at recheck.
- Static checks pass for absence of `admin` references and presence of connected-account/refund protections. This is not runtime verification.
- **Outstanding gate:** execute the exact PR source in an isolated Deno environment, test signature rejection/acceptance, account updates, connected-account match/mismatch, subscription RPC calls, domain-order paid/expired paths and conflict refund idempotency; then perform signed Stripe test-event replay. Do not merge or deploy before this gate passes.
- User LIVE website testing is not required now. Do not initiate real checkout/payment or change Adventure Outpost complimentary access for this work.


## Review branch v3 correction — 1 November 2026

- PR #192 was found three commits behind after project documentation updates landed on `production`; it was closed without merge and superseded.
- Clean branch `reconcile/live-stripe-webhook-v16-20261101-v3` now starts from production commit `467efced09203a8a9ab5489123edd2d93ff03ec5`.
- Draft PR #193: https://github.com/laurendigitaldigitaluk/TradeFlow/pull/193. Verified compare: one commit ahead, zero behind; only webhook entrypoint changed.
- Static checks confirm source reconciliation and domain-order fix. Runtime Deno execution and signed Stripe event replay remain outstanding; do not merge or deploy until complete.
- LIVE remains webhook v16. No LIVE user test/payment is required now; preserve Adventure Outpost complimentary account.


## Webhook review branch v4 and Deno type-check workflow — 1 November 2026

- Earlier PRs #192 and #193 were superseded as production documentation commits advanced their base branches. Neither was merged.
- Clean branch `reconcile/live-stripe-webhook-v16-20261101-v4` is based on current production and carries the reconciled webhook entrypoint, the Deno type-check workflow and the associated documentation updates. PR #194 is the intended review vehicle.
- `.github/workflows/stripe-webhook-check.yml` runs `deno check supabase/functions/stripe-payment-webhook/index.ts` on relevant pull requests. This is a compiler/type-check gate only; signed Stripe event replay and handler behaviour tests are still required.
- Do not merge/deploy until the Deno check and controlled webhook behaviour tests pass. LIVE remains on webhook v16; no LIVE test/payment is required from the user now.
