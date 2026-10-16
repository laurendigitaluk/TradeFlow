# Stripe Connect Checkout/Webhook State Machine — Implementation Contract

Date: 16 October 2026
Branch: `feature/live-stripe-connect-onboarding-20261015`
Related release blocker: [Issue #152](https://github.com/laurendigitaluk/TradeFlow/issues/152)

## Purpose

This document is the implementation contract for making checkout attempts, payment records, retail orders, Stripe webhook events, and inventory transitions consistent. It is not evidence that the implementation is complete or tested.

## Required identity model

- `retail_checkout_attempts.id` identifies a TradeFlow checkout attempt.
- `retail_checkout_attempts.stripe_session_id` is the canonical Stripe Checkout Session identifier for that attempt.
- Store the associated PaymentIntent ID separately on the attempt when known. A PaymentIntent ID must never be substituted for the Checkout Session ID.
- Every attempt is scoped to one tenant and one payment record. Resolve the tenant's active `customer_payments` Stripe connection and require its connected account ID to match the signed Connect event's `event.account`.
- Checkout Session events must match the exact attempt by Session ID. PaymentIntent events must match the stored PaymentIntent ID and its attempt; the payment event is then associated with that attempt's canonical Checkout Session ID for compatibility with the existing payment record.
- A webhook's metadata is supporting context, not sufficient identity proof on its own. Verify it against the persisted attempt, payment, order, and connected account.

## State machine

### Attempt states

| Current state | Event/condition | Allowed next state | Required behavior |
|---|---|---|---|
| `creating` | Stripe Session successfully persisted | `open` | Save Session ID, expiry, and any known PaymentIntent ID. |
| `creating` | Stripe definitively rejects Session creation | `failed` | Record a safe error summary; retry may reserve a new attempt only after failure is confirmed. |
| `creating` | Request outcome is ambiguous or function interrupted | `creating` | Retry using the same Stripe idempotency key; do not create a replacement attempt until reconciled. |
| `open` | Exact Session expires, and no paid/success state exists | `expired` | Mark only that attempt expired. Do not cancel the order/payment or release stock solely because the Session expired. |
| `open` | Exact Session is paid and the payment/order transition succeeds | `completed` | Persist attempt completion in the same database transaction as payment/order processing. |
| `expired` / `failed` | A new checkout is requested and the order remains eligible | new attempt in `creating` | Lock payment/order and reserve the next attempt atomically. |
| terminal state | Duplicate or older event | unchanged | Record/deduplicate the event; never regress a completed attempt. |

`cancelled` must not be used as a synonym for Session expiry. Reserve it for an explicit business cancellation with a separately specified inventory and refund policy.

### Payment and order invariants

1. A payment can become paid only after a verified event maps to the exact attempt and its connected account, with amount and currency matching the expected payment.
2. An expired Session does not by itself mean the retail order is cancelled. The order remains `pending_payment` and the payment remains eligible for retry unless a distinct business rule cancels the order.
3. Inventory can be restored only by an explicit, serialized order-cancellation transition. A stale Session expiry cannot restore inventory if a later attempt exists or the order has been paid.
4. Once an order is paid, older `failed` or `expired` events cannot regress its payment/order state.
5. If a verified payment succeeds after the order has been cancelled or its stock is no longer available, do not mark the order fulfilled. Start an idempotent refund on the same connected account and record the refund/reconciliation outcome durably.
6. A refund request needs its own stable idempotency key. Querying recent refunds is not a substitute for idempotency and durable refund state.
7. Duplicate event delivery must not repeat inventory movements, cancellation, or refund side effects.

## Atomic database operation requirements

The new service-role-only RPC must perform all local state changes in one database transaction:

1. Validate service-role execution.
2. Lock the attempt, payment, order, and relevant inventory/listing rows in a consistent lock order.
3. Verify tenant, active connected account, Session ID/PaymentIntent mapping, amount, currency, and allowed current statuses.
4. Insert/deduplicate the Stripe event using the existing unique event identity.
5. Apply only an allowed state transition. For paid events, invoke/reimplement the validated payment processing path within this transaction rather than committing an event row before business state changes.
6. Update attempt state only after the corresponding payment/order operation succeeds.
7. Return a structured outcome such as `applied`, `duplicate`, `expired_attempt`, `late_success_requires_refund`, or `rejected_mismatch`.

If an existing helper cannot be called safely inside the same transaction, refactor the underlying transition logic into a shared internal database function. Do not call one RPC and then separately PATCH attempt state from the Edge Function; that leaves a race window.

## Edge Function requirements

- Verify Stripe's signature against the raw request body, including multiple `v1` signatures where applicable and a bounded timestamp tolerance.
- Handle only explicitly supported event types; acknowledge irrelevant event types without mutation.
- For Connect events, use the connected-account context for all Stripe API calls involving that payment.
- Never use `object.id` interchangeably for Session and PaymentIntent IDs.
- Do not PATCH `retail_checkout_attempts` separately after the business RPC.
- Do not cancel the order or restore inventory on `checkout.session.expired` unless the atomic transition proves that the exact attempt is still current and a separate order-cancellation policy explicitly requires it.
- If refunding late/invalid success, use a stable Stripe idempotency key derived from the exact attempt/payment, then persist the refund result and reconciliation status. Repeated delivery must safely resume.

## Required tests

### SQL tests
- Reservation is serialized for concurrent calls on one payment.
- Two tenants cannot reference each other's attempt/payment/account.
- Non-service-role execution is rejected.
- A stale `creating` attempt is not replaced automatically.
- Expiry marks only the exact current attempt and leaves the order/payment eligible for retry.
- An expired attempt can be followed by a new attempt without duplicate inventory changes.
- Session/PaymentIntent mismatches and amount/currency mismatches are rejected.
- Event insert and business-state transition roll back together on error.
- Duplicate and out-of-order events cannot regress completed payment/order state.

### Edge Function tests
- Stripe Session creation timeout followed by retry recovers the same Session with the same idempotency key.
- Two simultaneous checkout requests return the same open Session.
- Session expiry followed by retry creates a new attempt only after expiry is confirmed.
- Checkout Session paid and PaymentIntent succeeded events map to the same attempt without provider-ID confusion.
- Old Session expiry after a newer Session is open is harmless.
- Late success after stock release produces one connected-account-scoped refund and no fulfilment.
- Repeated late-success events do not create repeated refunds.
- Platform SaaS subscription and platform domain-order events continue to use their existing platform-account flow.
- The DJI Osmo Action 6 Adventure Combo transaction is unchanged.

## Release gate

Do not close issue #152, merge, or deploy until:
- the migration is reviewed and successfully applied in a disposable/non-live test database;
- database tests and Edge Function tests pass;
- TypeScript/lint checks and CI run on the exact candidate commit;
- test Stripe events validate connected-account identity and idempotency in a safe test environment;
- the candidate diff is reviewed against current production;
- no LIVE migration, Edge Function deployment, connected account, or charge has been performed without explicit authorization.
