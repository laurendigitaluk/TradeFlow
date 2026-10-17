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


## Refund worker candidate added — 16 October 2026

Candidate code is now present on the feature branch:
- Migration `20261016170000_retail_checkout_refund_worker_rpcs.sql` adds service-role-only `claim_retail_checkout_refund` and `finish_retail_checkout_refund` RPCs. A `requested` intent is reclaimable after a crash, and the attempt's stable idempotency key is checked before final state is written.
- Edge Function `supabase/functions/process-retail-checkout-refund/index.ts` retrieves the exact Checkout Session using its pinned connected-account context, checks paid status, PaymentIntent, amount and currency, then requests a full refund with a stable Stripe idempotency key. It persists Stripe-confirmed outcomes and keeps transient errors retryable.
- The webhook invokes the worker for `refund_required` outcomes and for duplicate event deliveries while the attempt remains `required` or `requested`.
- The worker also supports a service-role-only batch mode (no `attempt_id`) that scans up to 20 durable pending intents, intended for a scheduled recovery caller.

**Not yet verified:** no Deno typecheck, SQL migration application on disposable PostgreSQL, automated concurrency/crash-recovery tests, Stripe test-mode refund, or CI run has been executed on these changes. The batch mode has not been scheduled/configured. Do not deploy this candidate or apply the migration to LIVE.

**Remaining release blockers:** test refund API timeout after Stripe accepts the request; test database write failure after Stripe response; verify retry returns the same refund using the same key; test pending/failed refund states, missing PaymentIntent, amount/currency/account/session mismatches, duplicate/out-of-order events, and the full regression suite. Review whether Stripe API permanent failures should remain in reconciliation rather than automatic retry. Reconcile the feature branch's divergence before release.


## Follow-up webhook routing correction — 16 October 2026

A further source review found that the webhook's generic lifecycle guard returned early for every `checkout.session.expired` event before the connected-account attempt-aware branch could see it. The feature-branch webhook was corrected in commit `54013c8a7e9faf522166c9fe716be5ad22fad963`: Connect-scoped retail Session expiry can now reach the attempt-aware RPC; PaymentIntent-only events and platform-context retail expiry remain blocked pending explicit reconciliation.

The latest comparison reports this feature branch as **108 commits ahead and 2 behind** `production`, still diverged from the same merge base `dc5e0dfeabd0f86e98a1b709e01c31b1185cb5a1`. The repository integration decision remains blocked until the two production-only commits and the broader feature diff are reviewed. No CI status checks or workflow runs were returned for the latest candidate commits.


## Long-delay refund recovery guard — 16 October 2026

The candidate worker now checks the connected account's Stripe refund list for a refund tagged with the exact `tradeflow_checkout_attempt_id` before issuing another refund. The stable idempotency key remains the primary retry mechanism; the metadata lookup is a secondary recovery guard for a delayed retry after Stripe's idempotency-key retention window. A matching succeeded/pending/failed refund is reconciled into the database instead of blindly posting another refund. Commit: `d7f5b1d39f9355e61fce74250baeb85bdeb52f46`.

This is still untested source code. The lookup must be exercised in Stripe test mode, including a simulated crash after Stripe accepts the refund but before the database write, and a delayed retry. Do not deploy.


## Lock-order correction — 16 October 2026

A source review identified a potential deadlock: checkout reservation locks the payment row before the attempt row, while the candidate settlement/refund claim paths previously locked the attempt before the payment. Both candidate paths have now been changed to read the attempt identity without a lock, then lock payment first and the exact attempt second, re-reading the attempt under lock. Commits: `260602e25e23e21da4c1277c033bbe68eafc6ca9` (settlement migration) and `9a3f2e981023e480bea6ea6c1c0cde4e7530dadf` (refund worker RPC migration).

This is a source-level concurrency correction only. Validate with concurrent PostgreSQL tests that race checkout reservation, expiry/success webhook settlement, and refund claims. Do not deploy until tested.


## Asynchronous payment failure handling — 16 October 2026

Source review found that `checkout.session.async_payment_failed` was not included in the attempt-aware Connect retail Session event set. The handler returned without recording the attempt-level failure. Commit `bb4001785446440645078869b034868c617fae93` now routes this event to the existing atomic `failed` transition and includes it in the Connect retail release guard. This is source-only and untested. Validate the event with Stripe test mode and confirm the failed attempt can be retried without affecting subscription/domain checkout. The feature branch currently compares as diverged from `production`, with feature-only and production-only commits still requiring review; review divergence before release. Do not deploy.

## Terminal payment event persistence — review withdrawn, 16 October 2026

An initial source review proposed an extra event insert in the successful paid branch (commit `11049bf110a4da05b3078b59b83a56a7ad9fc88a`). Deeper control-flow review found it redundant/unreachable for the stated terminal-payment case: the attempt-aware RPC already checks terminal payment statuses before calling the legacy helper. The extra insert was removed in commit `4d0848f6b65945d52362d0cb7cbaa7889613e584`. Do not treat the original proposal as a confirmed defect or fix. The candidate remains untested and must not be deployed.

Review correction (16 October 2026): a deeper control-flow check found that the proposed terminal-payment event insert in commit `11049bf110a4da05b3078b59b83a56a7ad9fc88a` was redundant/unreachable in the successful branch because the attempt-aware RPC already checks terminal payment statuses before calling the legacy helper. The insert has been removed in commit `4d0848f6b65945d52362d0cb7cbaa7889613e584`. Do not treat the earlier note as a confirmed defect or fix. The broader checkout/refund implementation remains untested and blocked from release.


## Refund reconciliation pagination — 16 October 2026

A further review found the metadata recovery lookup inspected only the first 100 refunds for the PaymentIntent. The worker now follows Stripe list pagination until it finds the exact `tradeflow_checkout_attempt_id` metadata, exhausts the list, or reaches a defensive 100-page ceiling; incomplete pagination remains retryable rather than allowing a new refund request. Commit: `29fcf17c1079a152aeeba92a6b8742e9ddab3956`. This correction is source-only and has not been run through Deno or Stripe test mode. Add tests for a matching refund on page two, no matching refund across multiple pages, API pagination errors, and the defensive ceiling. Do not deploy.

## Authoritative payment-model decision — 16 October 2026

The owner has already confirmed that TradeFlow must **not collect application fees or transaction commission** on subscriber retail sales. Subscriber payments are direct charges on each subscriber's own connected Stripe account; TradeFlow subscription billing remains separate. Do not ask the owner to decide this again or treat commission policy as an unresolved blocker.

The candidate source creates accounts with `controller.fees.payer=account`, `controller.losses.payments=stripe`, and `controller.stripe_dashboard.type=full`, then validates these settings before allowing checkout. Checkout sends `Stripe-Account` and does not set `application_fee_amount`. This aligns with the intended no-commission model. Stripe's documentation states that for direct charges the connected account bears Stripe fees, refunds and chargeback costs, while Stripe covers connected-account loss liability under the Stripe-managed loss configuration; TradeFlow is not configured to collect a transaction fee. See [Stripe Connect pricing and account-loss responsibility](https://stripe.com/gb/connect/pricing) and [Stripe direct-charge guidance](https://support.stripe.com/questions/what-should-i-know-about-using-direct-charges?locale=en-GB). Account terms, eligibility and actual account configuration still govern; this is not a guarantee against every possible platform-level contractual liability.

The earlier notes in this document/manual describing the charge model or commission policy as undecided, or saying retail checkout still charges through the platform account, are superseded by this checkpoint. Remaining release blockers are Stripe test-mode lifecycle/recovery tests, reconciliation of the broader feature/production branch history, investigation of the failed `tradeflow-test` preview, and validation against the actual LIVE schema and business side effects. The specific subscriber settings overlap was reviewed and corrected on the feature branch, with CI passing. The branch remains unreleased; do not merge, deploy or apply candidate migrations to LIVE without explicit authorization. Preserve the DJI Osmo Action 6 Adventure Combo test transaction.


## Cloudflare `tradeflow-test` preview configuration — 17 October 2026

The owner supplied Cloudflare build-log screenshots for failed preview build `2ee928b4` on feature branch `feature/live-stripe-connect-onboarding-20261015`. The first actionable error is explicit: **Wrangler configuration is missing a `previews` block**. The Cloudflare build uses deploy command `npx wrangler preview`, with no build command and root directory `/`.

Feature-branch commit `7dffd54c68fc721beb78c42052a01690f6bf1406` adds the `previews` block to `wrangler.jsonc` following the shape printed by Cloudflare. Preview variables set `TRADEFLOW_ENV=test`, and the configured source/target values allow the Worker to rewrite LIVE Supabase URL/key literals to the separate TEST project's public URL/key in preview-served JavaScript. The normal Worker `vars` remain unchanged. This is a candidate configuration correction only; Cloudflare must run a new preview build before the fix is considered verified.

**Next verification:** confirm the new `tradeflow-test` build passes the deployment stage, then browser-check that preview API traffic goes only to TEST Supabase. If it fails again, capture the first error from the new build. Do not alter the production Worker, production environment variables, LIVE Supabase, Stripe, or the protected DJI Osmo Action 6 Adventure Combo test transaction.


## Cloudflare `tradeflow-test` preview schema error — 17 October 2026 (follow-up)

The owner uploaded the full log for failed build `ca1b7639-4000-4ca5-90d1-5ca480c80a68`. The first actionable error states that `previews` must be an object but was supplied as an array. This supersedes the earlier description that the remaining issue was a missing `previews` block. Feature-branch-only correction committed in `31e6c66b1a5da40e5cab13f1af6f87d24cc88284`: `previews` is now an object with `vars`, setting `TRADEFLOW_ENV=test` and the URL/key pairs required for Worker substitution. Production top-level vars are unchanged. **Status: awaiting a fresh Cloudflare build and browser verification; not yet proven fixed.** Next: inspect the next `tradeflow-test` build, then verify preview API requests target TEST Supabase only. No merge, deployment, LIVE migration, Stripe mutation, or changes to the protected DJI Osmo Action 6 Adventure Combo transaction.
