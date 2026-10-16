# Stripe Connect Release Blockers — 16 October 2026

Repository: `laurendigitaluk/TradeFlow`  
Branch: `feature/live-stripe-connect-onboarding-20261015`  
Pull request: [#151](https://github.com/laurendigitaluk/TradeFlow/pull/151)  
LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`

## Release status

**Do not merge or deploy.** This document records verified blockers from read-only inspection of the LIVE SQL definitions and feature-branch source. No LIVE database changes, Stripe account creation, or customer charges were made.

## Verified blocker 1 — checkout-attempt race

The LIVE function `public.customer_create_order_payment(p_tenant_id, p_order_id, p_idempotency_key)` locks the retail order while it checks ownership/status and creates or reuses a payment record. Its transaction finishes before the Edge Function makes the Stripe API request.

The function reuses a pending/processing payment record for the order even when a new idempotency key is supplied. The feature-branch Edge Function generates a fresh UUID and Stripe idempotency key on each request. Concurrent calls can consequently use different Stripe idempotency keys for one payment record, create separate Checkout Sessions, and overwrite the saved session ID.

### Required design

- Add a database-backed checkout-attempt version/reservation with an atomic operation per payment record.
- Ensure concurrent requests for the same active attempt use the same Stripe idempotency key.
- Persist the attempt identity and Stripe session identity; verify the identity before updating the payment record or returning the Checkout URL.
- Allow a new attempt only after the previous session is confirmed expired/cancelled and the database atomically advances the attempt version.
- Include recovery for a function interruption during session creation; a permanent payment-ID idempotency key is not sufficient because a genuinely new session may be required after expiry.
- Add automated tests for concurrent calls, repeated calls, expired-session retry, failed-session retry, stale responses, and interruption/recovery.

Do not use a newly generated UUID on every request as the sole duplicate-prevention mechanism.

## Verified blocker 2 — external payment-event state machine is incomplete

The LIVE `public.process_external_payment_event(...)` function currently accepts only `paid`, `failed`, and `cancelled`. It returns early when the payment is already in a terminal status, including `refunded` and `partially_refunded`. The current function therefore does not implement refund or dispute lifecycle transitions.

### Required design

- Define allowed payment transitions, including partial/full refunds and dispute opened/updated/won/lost states where supported by the product model.
- Make event processing idempotent and safe for duplicate, delayed, and out-of-order events.
- Preserve immutable payment/ledger history and reconcile Stripe refund/dispute amounts before changing local state.
- Ensure a later success or failure event cannot reverse a legitimate refund or dispute outcome.
- Confirm the event identity and connected-account tenant mapping before mutating records.
- Preserve platform-owned SaaS subscription and legacy domain-payment handling; connected-account retail events must not mutate platform-owned records.

## Verified blocker 3 — expiry and late-payment interaction

The current function can cancel an unpaid retail order and restore its listing and inventory. Stripe may deliver events late or out of order, so checkout expiry must not accidentally release stock after a successful payment, and a late successful payment for a cancelled/unavailable order must follow an explicit reconciliation/refund path.

### Required tests

- Session expires before payment.
- Customer completes payment while an expiry event is delayed or already queued.
- Duplicate expiry and success events arrive in different orders.
- A second checkout attempt is created only after the first session is confirmed expired.
- A payment succeeds after the order/listing has become unavailable; any refund is idempotent and scoped to the connected account.
- Webhook retries occur after partial processing or a temporary Stripe/API/database failure.

## Release gates

1. Inspect and reconcile the feature branch's two commits behind `production`; do not force-sync or blindly merge.
2. Implement checkout-attempt reservation in a version-controlled migration and matching Edge Function changes on the feature branch only.
3. Implement and test the payment-event state machine and connected-account webhook handling.
4. Run type/lint checks and automated tests against the exact candidate commit; obtain visible CI evidence.
5. Test in a confirmed safe non-live-money environment. Do not use a LIVE account or charge as a test.
6. Verify the existing platform SaaS subscription flow remains unchanged.
7. Update the human, backend, system and AI manuals with results that have actually been verified.
8. Only then prepare a release review. No deployment is authorised by this checkpoint.

## Existing transaction to preserve

The previously recorded DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment marked paid by bank transfer) must remain unchanged during this work.


## 16 October 2026 — reservation migration candidate added (not release-ready)

Candidate migration: `supabase/migrations/20261016120000_retail_checkout_attempt_reservation.sql` (feature branch only).

It introduces a private-by-default `retail_checkout_attempts` table and service-role-only `reserve_retail_checkout_attempt` RPC. The RPC locks the payment row, returns the same attempt/idempotency key for `creating` or `open` attempts, and advances the attempt number only after the prior attempt has been explicitly marked terminal. A stale `creating` attempt is intentionally not automatically replaced, because the Stripe request may still be in flight.

**This is only a schema/RPC candidate, not a completed checkout fix.** The checkout Edge Function has not yet been wired to this RPC, and webhook code does not yet update the attempt lifecycle. The migration has not been applied to LIVE and has not been validated by a PostgreSQL migration/test run. Before use, validate function permissions and service-role claims in the actual PostgREST environment, then implement the Edge Function and webhook changes together. In particular, webhook events for an older session must be matched to the exact attempt/session and must not be rejected or applied merely because the payment record now points at a newer session.

Latest candidate commit: `830903e974bd9dce88df97d0c0145947f2d16f37`. Re-fetch the file and run migration/test validation before relying on this checkpoint.

## 16 October 2026 — checkout function wired to reservation candidate (still not release-ready)

Feature-branch commit: `c149ef6e365e617424db7a24bb9d241b9bb3603e`.

The checkout Edge Function now calls `reserve_retail_checkout_attempt` after obtaining the payment record and uses the returned stable idempotency key for the Stripe Checkout Session request. It attempts to reuse the session stored on that exact attempt, and writes the resulting session ID and expiry to the attempt row before linking the session to the payment record. The previous per-request random idempotency key was removed.

This is an **unvalidated implementation step**, not a complete concurrency fix. The webhook does not yet advance attempt statuses or safely process events against the exact attempt. Recovery after Stripe creates a session but the function fails before saving the session ID still needs an explicit, tested path. The current implementation must not be deployed until those gaps are closed.

Additional required checks:
- Type-check/lint the updated Edge Function.
- Verify the PostgREST return shape for `reserve_retail_checkout_attempt` and service-role claim check.
- Test simultaneous requests where one request persists the session before another.
- Test the failure window between Stripe session creation and attempt persistence.
- Ensure the webhook can safely handle events for a session whose ID was created but not yet persisted locally.



## 16 October 2026 — unsafe legacy retail webhook settlement blocked on feature branch

Feature-branch commit: `d186934af4f2da031bbf209f603519c565d12be1`.

The Stripe webhook now returns a retryable HTTP 503 for retail Connect Checkout Session and PaymentIntent lifecycle events rather than passing them into `process_external_payment_event` without exact attempt binding. Platform subscription and domain-order branches remain ahead of this guard and are not targeted by it.

This is a deliberate safety stop, not a functioning settlement implementation: retail Connect payments will not be settled by this candidate webhook until the attempt-aware atomic RPC and its refund/recovery path are implemented and tested. Repeated 503 responses can eventually exhaust Stripe's automatic retry window, so this branch must not be deployed as a customer-facing production webhook. No LIVE deployment or payment was made.


## Candidate implementation checkpoint — 16 October 2026

- Candidate migration `20261016143000_process_retail_checkout_attempt_event.sql` introduces service-role-only `process_retail_checkout_attempt_event`. It locks the exact attempt and payment, validates tenant/account/Session/optional PaymentIntent/amount/currency, handles expiry per-attempt, calls the existing payment transition for verified paid Sessions, and records a durable refund intent when the existing transition rejects a late success.
- The webhook now routes connected-account retail Checkout Session events (`completed`, `async_payment_succeeded`, `expired`) through that RPC. PaymentIntent-only lifecycle events remain deliberately blocked because they cannot safely be mapped to the canonical Session without reconciliation.
- This is candidate code, not a release-ready implementation. Refund execution/recovery is still missing; account/event edge cases and all SQL semantics require disposable-database tests. The function depends on the existing `process_external_payment_event` behavior and has not been typechecked or integration-tested. Do not deploy or apply migrations to LIVE.


## Follow-up inspection and candidate correction — 16 October 2026

The initial GitHub comparison at the start of this follow-up inspection (before the checkpoint commits below) reported the feature branch as **71 commits ahead and 2 behind** `production`, with divergent history. Recheck the branch comparison before any integration decision. The merge base remains `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`; production head observed during this inspection is `419dc34b42bb60b175b65e9beacb430a195c7a00`. The integration branch is separate and must not be merged or rebased blindly.

Read-only inspection of the LIVE `process_external_payment_event` definition confirmed that it checks `payment_records.provider_payment_id` against the supplied Checkout Session ID and has terminal-state early returns. The candidate attempt-aware RPC previously rejected all payment-session mismatches before handling expiry/failure or recording a refund intent. This prevented a late paid event from an older attempt from entering the durable refund queue.

Candidate migration `20261016143000_process_retail_checkout_attempt_event.sql` was amended in commit `565fc9e2b74be58ed83122691b9e904f6bfa30de` so:
- exact-attempt expiry/failure events can be handled without being blocked solely because the payment row now references a newer Session;
- a paid event for an attempt whose Session differs from a different, non-null canonical payment Session records `refund_status='required'`, a stable attempt-based refund idempotency key, and the original event identity, then returns `refund_required`;
- the guard does not treat a missing canonical Session ID as proof that the payment is a superseded attempt.

**Validation status:** source-level edit only. No disposable PostgreSQL migration test, Deno check, Stripe test-mode refund, automated lifecycle test, or CI success has been verified. Refund execution/recovery is still not implemented, and the NULL canonical Session recovery case remains unresolved. Do not apply this migration to LIVE or deploy the webhook.
