# Developer Diagnostic Roadmap — Subscriber Signup & Subscription Checkout

**Status:** Checkout hardening candidate committed to isolated branch only. No deployment or end-to-end test is claimed.

## 1. User action and front-end entry points

1. Visitor opens `subscriber-signup.html` on a platform-owned TradeFlow domain.
2. `subscriber-signup.js` validates the form, creates the Supabase Auth account through `/auth/v1/signup`, and stores the pending signup details locally.
3. With an access token, the browser calls `/functions/v1/subscriber-create-checkout-session`.
4. If email confirmation is required, the user signs in through `subscriber-login.html`; the login page can resume checkout from the user's signup metadata.
5. Successful Stripe Checkout returns to `subscriber-signup-success.html`, which waits for webhook-driven tenant provisioning.

## 2. Platform hostname boundary

The current Worker hostname routing is defined in `worker/index.js`. The platform-owned LIVE TradeFlow entry point is `https://tradeflow.laurendigital.co.uk`; the Lauren Digital parent domains `https://laurendigital.co.uk` and `https://www.laurendigital.co.uk` also serve the TradeFlow marketing homepage. The Worker also has the LIVE `tradeflow.leannelaurenlowe.workers.dev` hostname.

The LIVE signup Edge Function must accept only those four verified HTTPS origins. It must not trust `Referer`, TEST Worker hosts, subscriber-owned custom domains, StudioFlow/BusinessFlow hosts, or the Platform Owner host. When the same source is deployed to the current TEST Supabase project (`nnsshnfkjcflucjrftzi`), it selects a separate TEST-only allowlist containing only `https://tradeflow-test.leannelaurenlowe.workers.dev`. The allowlist is selected from the exact `SUPABASE_URL` hostname, so the TEST hostname is never accepted by the LIVE project.

## 3. Edge Function — checkout session

**Source:** `supabase/functions/subscriber-create-checkout-session/index.ts`  
**LIVE deployment:** `subscriber-create-checkout-session`, currently deployed version 12 at the time of inspection.

Expected sequence:

1. Validate the request `Origin` against the exact HTTPS allowlist; reject missing, malformed, opaque, non-HTTPS or unknown origins.
2. Apply CORS only to the validated origin.
3. Require and validate the Supabase bearer token through `/auth/v1/user`.
4. Call `subscriber_get_my_memberships()` with the caller's bearer token. Fail closed if the lookup fails; reject accounts that already have an active business.
5. Load the active `enhanced` plan from `public.plans`; select the existing monthly or annual Stripe Price ID. Do not create or modify Stripe products or prices here.
6. Create a Stripe subscription Checkout Session with the existing trial period and a stable per-user Stripe idempotency key.
7. Build `success_url` and `cancel_url` only from the validated platform origin.

## 4. Stripe webhook and database provisioning

**Edge Function:** `stripe-payment-webhook` (LIVE version 16 at inspection).  
**Database RPC:** `public.subscriber_finalize_signup(...)`.

The webhook verifies the Stripe signature, handles `checkout.session.completed` in subscription mode, retrieves the subscription from Stripe, then calls `subscriber_finalize_signup`.

The RPC creates:
- `public.tenants` row;
- `public.tenant_public_profiles` row;
- `public.tenant_memberships` owner row;
- `public.tenant_subscriptions` row.

Relevant existing protection includes the unique `tenant_subscriptions_provider_subscription_idx` on (billing_provider, provider_subscription_id) and the one-current-subscription-per-tenant partial unique index.

The previous RPC defect was that an existing active membership caused the RPC to update that tenant's subscription with the incoming Stripe subscription ID. The candidate migration now serialises finalisation per Auth user, returns idempotently only when the incoming Stripe subscription ID already belongs to that user's existing TradeFlow tenant, and rejects a different subscription ID without changing the existing subscription.

## 5. Relevant data and dependencies

| Layer | Current dependency |
|---|---|
| Auth | Supabase Auth user and bearer token |
| Plan | `public.plans` (`enhanced`, active, existing Stripe Price IDs, trial_days) |
| Membership | `public.tenant_memberships` |
| Tenant | `public.tenants`, `public.tenant_public_profiles` |
| Subscription | `public.tenant_subscriptions` |
| Idempotent membership lookup | `public.subscriber_get_my_memberships()` |
| Finalisation | `public.subscriber_finalize_signup(...)` |
| Checkout | Stripe Checkout Sessions API |
| Webhook | Stripe signature verification and subscription retrieval |
| Hosting | Cloudflare Worker `tradeflow` and its platform-owned hostnames |

## 6. Failure points and diagnostics

- **403 origin denied:** inspect browser `Origin`, exact hostname and Worker route. Do not add subscriber domains to the platform allowlist.
- **401 authentication:** inspect Auth signup/confirmation and current bearer token.
- **503 membership lookup:** inspect `subscriber_get_my_memberships()`, Supabase REST reachability and caller token forwarding. Do not proceed to Stripe when membership cannot be checked.
- **409 existing business:** expected protection; direct the user to sign in rather than creating another subscription.
- **409 Stripe idempotency conflict:** a checkout attempt already exists for that user with different parameters; do not bypass the key to create another session. The stable per-user key protects retries only while Stripe retains its idempotency result; this candidate does not add a permanent checkout-attempt ledger. If webhook finalisation is unresolved after the key's retention window, reconcile the completed Stripe session before allowing a new attempt.
- **Webhook failure:** inspect Stripe signature, webhook delivery, subscription retrieval and the exact RPC exception. Do not overwrite existing tenant subscription data to make the webhook succeed.
- **Subscription collision:** compare the incoming Stripe subscription ID with the tenant's existing `tenant_subscriptions.provider_subscription_id`; never replace a complimentary/manual/different paid subscription.

## 7. Known fix history and constraints

- Existing commercial flow uses the `enhanced` plan and a 30-day trial; current plan price/Stripe IDs are authoritative database values.
- The checkout function must not create Stripe products/prices or alter Stripe settings.
- Retail customer checkout is a separate function: `create-stripe-checkout-session`. Do not conflate customer order payments with subscriber signup subscriptions.
- LIVE and TEST Supabase projects remain separate. The retired TEST project `twfbmjwwqzxdxvclxbun` must not be used.
- The checkout origin fix, RPC migration and documentation are candidates on `security/prelaunch-hardening-20261101` only. They have not been deployed or applied to either database.

## 8. Required TEST-only verification before promotion

1. Allowed TradeFlow LIVE-origin allowlist values are accepted by a controlled unit/request test; arbitrary origin, TEST Worker, SceneSource/customer domain, StudioFlow, BusinessFlow and missing Origin are rejected.
2. CORS preflight returns the exact allowed origin and never wildcard access.
3. A user with no active membership can create a checkout session.
4. A user with an active complimentary or paid membership is rejected before Stripe is called.
5. Repeating the same request for the same user reuses the same Stripe Checkout session through idempotency.
6. Repeating with different billing parameters while the idempotency key is active returns a conflict and does not create a second session.
7. A duplicate webhook for the same Stripe subscription returns the existing tenant without changing its subscription row.
8. A webhook with a different subscription ID for a user who already has an active membership is rejected; the existing subscription row remains unchanged.
9. Verify monthly and annual checkout amounts/trial metadata using TEST Stripe only. Do not run a LIVE payment or copy LIVE Stripe secrets/records into TEST.
10. Confirm tenant provisioning, membership and subscription states after the webhook; verify no duplicate tenant or subscription is created.


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
