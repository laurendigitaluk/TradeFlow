-- Stripe Connect: persist connected-account identity and durable refund intent.
-- Candidate migration only. Do not apply to LIVE until the atomic webhook RPC is
-- implemented and the complete migration/function set passes disposable-DB tests.

alter table public.retail_checkout_attempts
  add column if not exists stripe_account_id text,
  add column if not exists refund_status text not null default 'not_required',
  add column if not exists stripe_refund_id text,
  add column if not exists refund_idempotency_key text,
  add column if not exists last_event_id text,
  add column if not exists last_event_type text;

alter table public.retail_checkout_attempts
  drop constraint if exists retail_checkout_attempts_refund_status_check;

alter table public.retail_checkout_attempts
  add constraint retail_checkout_attempts_refund_status_check
  check (refund_status in (
    'not_required',
    'required',
    'requested',
    'succeeded',
    'failed',
    'reconciliation_required'
  ));

create unique index if not exists retail_checkout_attempts_refund_idempotency_key_uidx
  on public.retail_checkout_attempts (refund_idempotency_key)
  where refund_idempotency_key is not null;

create unique index if not exists retail_checkout_attempts_stripe_refund_id_uidx
  on public.retail_checkout_attempts (stripe_refund_id)
  where stripe_refund_id is not null;

comment on column public.retail_checkout_attempts.stripe_account_id is
  'Connected Stripe account used to create this exact Checkout Session; validated against event.account before settlement.';

comment on column public.retail_checkout_attempts.refund_status is
  'Durable refund workflow state; never infer success from an HTTP response timeout or refund-list search.';

comment on column public.retail_checkout_attempts.refund_idempotency_key is
  'Stable per-attempt Stripe refund idempotency key reused across retries and crash recovery.';
