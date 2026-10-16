# Stripe Connect Runtime Review — 16 October 2026

Branch: `feature/live-stripe-connect-onboarding-20261015`  
LIVE database inspected read-only: `gxsrajtqzdjvmceqcpgv`  
Release blocker: [Issue #152](https://github.com/laurendigitaluk/TradeFlow/issues/152)

## Scope and safety

This review inspected the deployed LIVE definitions of `public.process_external_payment_event` and `public.customer_create_order_payment` using a read-only SQL query. No rows, schema, Edge Functions, Stripe accounts, or charges were changed. The candidate migration remains unapplied.

## Confirmed findings

### 1. Event deduplication currently occurs before state validation

The LIVE `process_external_payment_event` first checks `payment_provider_events` for `(provider,event_id)` and immediately returns `true` if found. This is normal for a successfully completed prior event, but it also means the function does not revalidate the requested payment identity or reconcile unfinished external side effects on a replay. A new atomic attempt-aware RPC should distinguish a fully processed event from a durable in-progress/reconciliation state rather than treating every existing event row as proof that all work is complete.

### 2. The current function records provider events at the end

For a new event, the function mutates payment/order/inventory state and inserts the provider event near the end of the transaction. PostgreSQL rolls back these changes together if the function raises an exception, which is useful. However, the function is not sufficient on its own for the Connect attempt lifecycle: it has no checkout-attempt identity or connected-account argument and cannot atomically update an exact attempt status.

### 3. A false result is not a completed refund workflow

For a paid event where the payment was cancelled locally or the listing is no longer available, the function returns `false` before inserting the provider event. The current webhook then attempts a Stripe refund outside the database transaction and subsequently calls the payment RPC again with a synthetic cancellation event. This is not a durable refund state machine. The Stripe refund call lacks an explicit stable idempotency key in the inspected code; checking recent refunds after an error is not a reliable replacement for idempotency and persisted refund/reconciliation status.

### 4. Existing payment helper has retail side effects that must be preserved carefully

On accepted retail payment, the helper updates the payment and order, writes workflow and ledger entries, marks the listing sold, and updates the linked inventory asset. On cancellation, it can cancel an eligible order and restore reserved listing/inventory state. An attempt-aware replacement must preserve the relevant credit-hold and ledger behavior, lock rows consistently, and prevent stale expiry events from triggering cancellation or stock restoration.

### 5. Reservation and payment eligibility are not yet one coherent lifecycle

The candidate `reserve_retail_checkout_attempt` only accepts payment statuses `pending` or `processing`, and it reuses a latest attempt in `creating` or `open`. The webhook guard deliberately does not expire attempts yet. A future atomic event RPC must define exactly when an attempt becomes `expired`, how a retry becomes eligible, and what happens if an old Session succeeds after a newer attempt has started.

## Required next implementation

1. Add a connected-account identity to the persisted checkout attempt or prove it through an unambiguous, locked active-connection lookup within the atomic operation.
2. Add a service-role-only transactional RPC that resolves the exact attempt by Checkout Session ID or stored PaymentIntent ID, verifies tenant and connected account, checks amount/currency, deduplicates the event, invokes the validated retail payment transition in the same transaction, and updates attempt status without allowing stale events to regress state.
3. Give refunds a stable Stripe idempotency key derived from the payment/attempt, plus durable refund-requested/refunded/reconciliation state. A retry must safely resume the same refund.
4. Test duplicate/concurrent events, out-of-order expiry and success, PaymentIntent-only recovery, stock-unavailable late success, credit holds, ledger invariants, and unchanged domain/SaaS flows in a disposable database and Stripe test environment.
5. Run SQL/migration tests, Deno typecheck/lint, and CI against the exact candidate commit.

## Release status

**Blocked.** Do not merge, apply the migration to LIVE, or deploy Edge Functions until the implementation and tests above pass review. Preserve the DJI Osmo Action 6 Adventure Combo transaction (sale £125, acquisition cost £70, seller payment already marked paid by bank transfer).
