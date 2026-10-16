# Stripe Connect Checkout Lifecycle Review — 16 October 2026

Branch: `feature/live-stripe-connect-onboarding-20261015`
Latest checkout commit: `aa000aeb34e904e2f13c43919f4da76ae218bd37`
Related issue: [#152 — complete checkout-attempt-aware webhook lifecycle](https://github.com/laurendigitaluk/TradeFlow/issues/152)

## Status

**Not safe to merge or deploy.** This review is based on the current feature-branch source. The reservation migration has not been applied to a database, no PostgreSQL validation was performed, and the latest checkout commit has no associated workflow run in the available GitHub Actions query. No LIVE resources were changed.

## Current implementation facts

### Checkout function

- Calls `customer_get_retail_order_for_checkout` to validate customer access and requires `pending_payment`.
- Calls `customer_create_order_payment` using a stable order-level idempotency key.
- Reads one active LIVE Stripe customer-payments connection and checks the connected account's controller settings and capabilities.
- Calls `reserve_retail_checkout_attempt`, then uses its attempt idempotency key for Stripe Checkout Session creation.
- Stores the Checkout Session ID on the attempt, then links the payment record to the Checkout Session.
- If the Stripe request succeeds but the database write fails, it returns an error and expects the customer to retry. Recovery depends on Stripe returning the same session for the same idempotency key and the reservation still being in `creating`; this has not been tested.

### Reservation migration

The RPC returns these columns: `attempt_id`, `attempt_number`, `idempotency_key`, `attempt_status`, `stripe_session_id`, `session_expires_at`, `created_new`. These names match the checkout function's currently accessed fields.

The RPC locks the payment row and allows reservation only while the payment status is `pending` or `processing`. A new attempt is permitted only when the previous attempt is not `creating` or `open`. This makes attempt-state updates essential to any expiry/retry design.

The service-role check uses `current_setting('request.jwt.claim.role', true)`. This exact check still requires validation in the intended Supabase/PostgREST execution context. RLS/grants and migration syntax also remain untested.

### Webhook — blocking issues

The current webhook is not attempt-aware:

1. It does not look up `retail_checkout_attempts` by the exact Checkout Session ID or update attempt status after successful event processing.
2. It maps `checkout.session.expired` to payment status `cancelled`, while the reservation RPC rejects payments outside `pending`/`processing`. The retry state machine is therefore incomplete.
3. It uses `object.id` as `p_provider_payment_id` for both Checkout Session and PaymentIntent events. Those are different Stripe identifiers, so PaymentIntent events can conflict with the payment record that stores the Checkout Session ID.
4. It uses the general payment-event RPC for session expiry, but the consequences for order cancellation and inventory restoration need to be coordinated with exact attempt identity and late success.
5. The existing conflict-refund path is not a complete idempotent refund/dispute state machine.

## Required implementation order

1. Specify payment, order, and checkout-attempt transitions, including retry after confirmed expiry and late payment.
2. Implement an atomic service-role-only event RPC that checks tenant, connected account, exact Checkout Session/PaymentIntent relationship, event idempotency, payment/order status, and attempt status.
3. Update the webhook to use that RPC, and update attempt status only as part of the same atomic database transition.
4. Use the Checkout Session ID for session events and validate the PaymentIntent ID against the session/attempt record for PaymentIntent events.
5. Make a new checkout attempt possible only after the old attempt is safely terminal and the order/payment remains eligible. Do not cancel the payment record merely because a session expires if a retry is intended.
6. Add automated SQL and Edge Function tests for concurrent calls, duplicate and out-of-order events, expired-session retry, Stripe create-session interruption, PaymentIntent mapping, and late success after inventory release.
7. Run type/lint checks and CI on the exact candidate commit, then perform integration tests in a confirmed safe non-live-money environment.

## Safety constraints

- Do not merge or deploy this feature branch yet.
- Do not apply the candidate migration to LIVE or create connected accounts or charges.
- Keep platform SaaS subscriptions and platform-owned domain payments on their existing platform-account flows.
- Preserve the existing DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment marked paid by bank transfer).
