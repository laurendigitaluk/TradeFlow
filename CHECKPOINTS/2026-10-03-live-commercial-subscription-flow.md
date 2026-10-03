# TradeFlow Checkpoint — 2026-10-03 LIVE Commercial Subscription Flow

## Decision
Launch TradeFlow with one commercial subscriber plan:
- £59.99 GBP per month
- 30-day / one-month free trial
- no annual price configured yet.

## LIVE database
Project: TradeFlow Live (`gxsrajtqzdjvmceqcpgv`)

The `enhanced` plan is active and website-visible at £59.99/month with `trial_days=30`. Stripe Product/Price IDs are pending owner creation from Owner Dashboard.

New service-role-only RPCs: `subscriber_finalize_signup`, `subscriber_sync_subscription`.
The legacy `subscriber_create_business` path is disabled so it cannot create an unpaid subscriber tenant.

## LIVE Edge Functions
- `platform-create-stripe-product` v1 — owner-authenticated.
- `subscriber-create-checkout-session` v1 — subscriber-authenticated.
- `stripe-payment-webhook` v2 — retains customer payment handling and now provisions/synchronizes subscriber subscriptions.

## Frontend
- Owner Dashboard shows monthly price, trial days and Stripe billing identifiers.
- Owner can create the LIVE Stripe Product and recurring monthly Price.
- Public plan page shows £59.99/month and 30-day trial.
- Subscriber signup creates the Auth account then starts Stripe subscription Checkout.
- If email confirmation is required, subscriber login resumes subscription checkout after authentication.
- Successful Stripe checkout lands on `subscriber-signup-success.html`, which waits for webhook-driven tenant provisioning.
- Existing pre-repair subscriber accounts carrying signup metadata are sent to subscription checkout rather than the old unpaid business-creation path.
- Subscriber accounts remain separate from the platform Owner Dashboard.

## Verification status
Implementation is deployed to LIVE Supabase and committed to production GitHub. Full browser E2E is not yet passed.

## Next manual step
1. Open LIVE Owner Dashboard.
2. In Plans, confirm £59.99 and 30 days.
3. Click Set up Stripe billing (or Create Stripe billing).
4. Confirm Stripe Product and monthly Price IDs appear.
5. Use a fresh subscriber account or the existing `valley-discounts@outlook.com` account.
6. Complete LIVE Stripe subscription checkout.
7. Confirm the webhook creates the subscriber business and the user reaches Subscriber Dashboard.
8. Confirm Owner Dashboard lists the real subscriber business with a trialing subscription.

Do not return to the old direct `subscriber_create_business` flow and do not reintroduce the TEST/Camerashack launch path.