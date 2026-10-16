# Stripe Connect Atomic RPC Design — 16 October 2026

Status: implementation design only; no database migration or deployment performed.

## Why a narrow wrapper is insufficient

The LIVE `process_external_payment_event` is a SECURITY DEFINER function with the signature:

`(p_provider text, p_event_id text, p_event_type text, p_tenant_id uuid, p_payment_id uuid, p_provider_payment_id text, p_new_status text, p_amount numeric, p_currency text, p_metadata jsonb)`

Its current behavior:
- returns `true` immediately if `payment_provider_events(provider,event_id)` already exists;
- checks `payment_records.provider_payment_id` against the supplied provider ID;
- returns `false` without recording the event when a cancelled payment receives a late paid event, or when the retail listing is unavailable;
- mutates payment/order, workflow transitions, credit holds, ledger, listing and inventory inside its own SQL transaction;
- handles cancellation by cancelling eligible orders and releasing reserved listing/inventory.

Calling this function inside a new outer PostgreSQL function would be transactionally nested in the same SQL transaction, but its early return semantics still do not expose enough information to safely decide whether the exact checkout attempt should be completed, expired, or refunded. The new RPC must not blindly treat every `true` result as proof that the event was newly applied.

## Proposed RPC contract

Implement a new service-role-only RPC, provisionally named `process_retail_checkout_attempt_event`, that accepts:
- Stripe event ID and event type;
- tenant ID and connected-account ID from the verified Connect webhook context;
- Checkout Session ID and optional PaymentIntent ID;
- amount in minor units and currency;
- supported transition (`paid`, `failed`, `expired`);
- safe event metadata.

It should resolve the attempt by the unique Session ID, or by the stored PaymentIntent ID only after verifying the associated Session/account on Stripe. It must never treat Session and PaymentIntent IDs as interchangeable.

## Required schema additions

Add to `retail_checkout_attempts`:
- `stripe_account_id text not null` once account identity is established at session creation;
- `refund_status text not null default 'not_required'` with explicit states such as `not_required`, `required`, `requested`, `succeeded`, `failed`, `reconciliation_required`;
- `stripe_refund_id text`;
- `refund_idempotency_key text unique`;
- `last_event_id text` and `last_event_type text` for audit visibility (event dedupe remains in `payment_provider_events`).

Before adding these fields, confirm all naming, nullability and existing row assumptions on a disposable database.

## Transaction algorithm

1. Require `service_role` and validate all required identities.
2. Lock the event identity (unique provider/event ID) and exact attempt/payment/order rows in a consistent order.
3. Reject tenant, account, amount, currency, Session, PaymentIntent or payment-record identity mismatches without mutating business state.
4. If the event has already been fully processed, return a distinct `duplicate` outcome. If it is in a reconciliation state, return that state rather than silently treating it as complete.
5. For `checkout.session.expired`, mark only the exact attempt expired if it is still current/open. Do not cancel the retail order, release inventory, or release credit solely because one Session expired.
6. For a verified paid Session, call the existing payment transition only after confirming the order is eligible and the exact provider Session identity matches. Preserve credit-hold, ledger, workflow, listing and inventory effects. Update the attempt to `completed` in the same transaction only if the payment transition was applied successfully.
7. If the payment transition says the order/payment cannot accept the late success, atomically record `refund_status='required'`, the exact attempt, and event identity without fulfilling the order. Do not call Stripe from SQL.
8. For a failed event, mark only that attempt failed; do not cancel/release order stock unless a separate policy and atomic check explicitly requires it.
9. Insert/dedupe provider event records in the same transaction as the state transition. Avoid synthetic provider events that obscure the original Stripe event identity.
10. Return a typed outcome such as `applied`, `duplicate`, `expired`, `refund_required`, or `reconciliation_required`.

## Refund worker / Edge Function

For `refund_required`:
- Retrieve/confirm the PaymentIntent on the exact connected account.
- Call Stripe Refunds API with `Stripe-Account: acct_...` and a stable idempotency key derived from tenant/payment/attempt (not event delivery ID).
- Persist the refund ID and status after Stripe responds.
- If the process crashes after Stripe accepts the refund but before persistence, retry with the same idempotency key and reconcile the Stripe response.
- Do not fulfil the order or release inventory twice; do not claim a refund succeeded until Stripe confirms it.
- Do not rely on listing recent refunds as the primary idempotency mechanism.

## Concurrency and recovery rules

- Same payment: checkout reservation remains serialized by payment row lock.
- Same event: one transaction wins; duplicate delivery returns a distinct duplicate outcome.
- Old expiry after newer attempt: only the matching attempt changes; current attempt/order remains unchanged.
- Old attempt succeeds after retry: do not accept it merely because the order is still pending; determine whether the order can still be fulfilled under a single-winner policy. If not, mark refund required.
- PaymentIntent ID missing on Session creation: retrieve the exact Session using the connected-account header and reconcile its PaymentIntent before associating a PaymentIntent event.
- Stripe API timeout: preserve the existing attempt idempotency key and reconcile before opening another attempt.
- Event replay after refund: return the stored refund/reconciliation state and never create a second refund.

## Release tests

- SQL: role restriction, tenant isolation, connected-account mismatch, Session/PaymentIntent mismatch, amount/currency mismatch, concurrent duplicate events, duplicate event after partial recovery, stale expiry, late success, unavailable listing, credit hold, ledger consistency, no duplicate inventory changes.
- Edge: signature verification, Connect account header on retrieval/refund, stable refund idempotency key, crash after Stripe refund success before DB update, repeated event delivery, Session creation timeout/retry.
- Regression: platform SaaS subscriptions and platform domain orders remain on their existing flow; the DJI Osmo Action 6 Adventure Combo payment/acquisition records remain unchanged.
- CI: migration application on disposable PostgreSQL, SQL assertions, Deno typecheck/lint and test suite on exact candidate commit.

## Safety gate

This design is not executable evidence. It must be implemented and reviewed on the feature branch, tested in disposable infrastructure and Stripe test mode, and reconciled against current production before any merge. Do not apply the candidate migration to LIVE or deploy functions as part of this design step.


## Incremental implementation progress — 16 October 2026

The candidate checkout path now pins `stripe_account_id` to the attempt before the first Stripe Checkout Session request. Retry logic rejects an attempt whose recorded account differs from the currently verified connected account. This closes the account-switching gap when a Stripe request succeeds remotely but its response is lost. The reservation RPC's role check was also changed to fail closed when the JWT role claim is missing (`IS DISTINCT FROM 'service_role'`).

A follow-on candidate migration adds durable connected-account and refund workflow columns, including a unique refund idempotency key. These changes are on the feature branch only. They are not a substitute for the attempt-aware settlement RPC: webhook settlement and refund recovery remain incomplete. No Deno typecheck, disposable PostgreSQL migration test, Stripe test-mode integration test, LIVE migration, or deployment has been performed.


## Candidate implementation checkpoint — 16 October 2026

- Candidate migration `20261016143000_process_retail_checkout_attempt_event.sql` introduces service-role-only `process_retail_checkout_attempt_event`. It locks the exact attempt and payment, validates tenant/account/Session/optional PaymentIntent/amount/currency, handles expiry per-attempt, calls the existing payment transition for verified paid Sessions, and records a durable refund intent when the existing transition rejects a late success.
- The webhook now routes connected-account retail Checkout Session events (`completed`, `async_payment_succeeded`, `expired`) through that RPC. PaymentIntent-only lifecycle events remain deliberately blocked because they cannot safely be mapped to the canonical Session without reconciliation.
- This is candidate code, not a release-ready implementation. Refund execution/recovery is still missing; account/event edge cases and all SQL semantics require disposable-database tests. The function depends on the existing `process_external_payment_event` behavior and has not been typechecked or integration-tested. Do not deploy or apply migrations to LIVE.


## Superseded-session guard correction — 16 October 2026

A source review found that the candidate RPC's early `payment_records.provider_payment_id` equality check blocked expiry/failure processing for an exact older attempt and returned only `reconciliation_required` for a late paid event from a superseded Session. The candidate migration was amended in commit `565fc9e2b74be58ed83122691b9e904f6bfa30de`: expiry/failure are now handled against the matched attempt, while a paid event whose Session differs from a different non-null canonical Session records a durable `refund_status='required'` intent and returns `refund_required`.

This remains source-level candidate work. It has not been tested on disposable PostgreSQL, and the missing canonical Session ID recovery case is still unresolved. The RPC only records refund intent; no Stripe refund is executed by SQL, and the separate idempotent refund worker/recovery path remains a release blocker.


## Refund worker implementation candidate — 16 October 2026

Candidate migration `20261016170000_retail_checkout_refund_worker_rpcs.sql` adds service-role-only claim/finalize RPCs. The claim RPC locks the attempt, verifies the related retail payment record and amount/currency inputs, and returns the pinned connected account, exact Checkout Session, stored PaymentIntent if present, and stable refund idempotency key. A `requested` intent is reclaimable to support crash recovery. The finalizer checks the same idempotency key, avoids regressing an already-succeeded refund, and persists refund ID, PaymentIntent and status.

Candidate Edge Function `process-retail-checkout-refund` retrieves the exact Session in the connected-account context, validates the Session ID, paid state, PaymentIntent, amount and currency, then requests a full refund with the stable attempt key. It persists success only when Stripe returns `succeeded`; pending refunds remain retryable, while mismatches and permanent API rejection move to reconciliation. The webhook calls the worker for new refund intents and duplicate deliveries while an intent remains pending. A service-role-only batch mode scans up to 20 pending intents for a future scheduler/recovery caller.

This implementation is still source-only and untested. The batch recovery caller has not been scheduled. No LIVE migration or deployment is permitted until disposable PostgreSQL, Deno and Stripe test-mode tests pass.


### Delayed recovery after Stripe idempotency retention

The candidate worker now lists refunds for the exact PaymentIntent in the pinned connected account and reconciles a prior refund whose `metadata.tradeflow_checkout_attempt_id` matches the attempt before issuing another refund. This supplements, but does not replace, the stable Stripe idempotency key. It is intended to avoid duplicate refunds if recovery is delayed beyond Stripe's idempotency-key retention period. This path remains untested and must be verified in Stripe test mode.


### Lock ordering correction

The candidate settlement RPC and refund-claim RPC now acquire locks in the same order as checkout reservation: identify the attempt without locking, lock its payment row, then re-read and lock the exact attempt. This avoids the previously identified payment/attempt lock inversion. Validate with disposable PostgreSQL concurrency/deadlock tests; source inspection is not proof that the concurrency cases pass.
