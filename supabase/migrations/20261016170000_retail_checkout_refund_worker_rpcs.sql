-- Stripe Connect retail refund worker state transitions.
-- Candidate only: validate on disposable PostgreSQL before any deployment.

create or replace function public.claim_retail_checkout_refund(p_attempt_id uuid)
returns table (
  claim_status text,
  attempt_id uuid,
  tenant_id uuid,
  payment_id uuid,
  stripe_account_id text,
  stripe_session_id text,
  stripe_payment_intent_id text,
  refund_idempotency_key text,
  payment_amount numeric,
  payment_currency text
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_attempt public.retail_checkout_attempts%rowtype;
  v_payment public.payment_records%rowtype;
  v_payment_found boolean := false;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'Service role required';
  end if;

  -- Read attempt identity without locking, then acquire locks in the same
  -- payment -> attempt order as checkout reservation and webhook settlement.
  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.id = p_attempt_id;

  if not found then
    return query select 'not_found'::text, null::uuid, null::uuid, null::uuid,
      null::text, null::text, null::text, null::text, null::numeric, null::text;
    return;
  end if;

  select p.* into v_payment
    from public.payment_records p
   where p.id = v_attempt.payment_id
     and p.tenant_id = v_attempt.tenant_id
     and p.retail_order_id is not null
   for update;
  v_payment_found := found;

  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.id = p_attempt_id
   for update;

  if not found then
    return query select 'not_found'::text, null::uuid, null::uuid, null::uuid,
      null::text, null::text, null::text, null::text, null::numeric, null::text;
    return;
  end if;

  if v_attempt.refund_status = 'succeeded' then
    return query select 'already_succeeded'::text, v_attempt.id, v_attempt.tenant_id,
      v_attempt.payment_id, v_attempt.stripe_account_id, v_attempt.stripe_session_id,
      v_attempt.stripe_payment_intent_id, v_attempt.refund_idempotency_key,
      null::numeric, null::text;
    return;
  end if;

  if v_attempt.refund_status not in ('required', 'requested') then
    return query select 'not_claimable'::text, v_attempt.id, v_attempt.tenant_id,
      v_attempt.payment_id, v_attempt.stripe_account_id, v_attempt.stripe_session_id,
      v_attempt.stripe_payment_intent_id, v_attempt.refund_idempotency_key,
      null::numeric, null::text;
    return;
  end if;

  if not v_payment_found
     or coalesce(v_attempt.stripe_account_id, '') = ''
     or coalesce(v_attempt.stripe_session_id, '') = ''
     or coalesce(v_attempt.refund_idempotency_key, '') = ''
     or coalesce(v_payment.amount, 0) <= 0
     or coalesce(v_payment.currency, '') = '' then
    update public.retail_checkout_attempts
       set refund_status = 'reconciliation_required',
           last_error = 'Refund identity or retail payment amount/currency is incomplete.',
           updated_at = now()
     where id = v_attempt.id;
    return query select 'reconciliation_required'::text, v_attempt.id,
      v_attempt.tenant_id, v_attempt.payment_id, v_attempt.stripe_account_id,
      v_attempt.stripe_session_id, v_attempt.stripe_payment_intent_id,
      v_attempt.refund_idempotency_key, null::numeric, null::text;
    return;
  end if;

  -- 'requested' is deliberately reclaimable: a worker may have crashed after
  -- Stripe accepted the request but before persisting the response. Stripe's
  -- stable idempotency key is the recovery boundary.
  update public.retail_checkout_attempts
     set refund_status = 'requested', last_error = null, updated_at = now()
   where id = v_attempt.id;

  return query select 'claimed'::text, v_attempt.id, v_attempt.tenant_id,
    v_attempt.payment_id, v_attempt.stripe_account_id, v_attempt.stripe_session_id,
    v_attempt.stripe_payment_intent_id, v_attempt.refund_idempotency_key,
    v_payment.amount, upper(v_payment.currency);
end;
$function$;

create or replace function public.finish_retail_checkout_refund(
  p_attempt_id uuid,
  p_refund_idempotency_key text,
  p_refund_status text,
  p_stripe_refund_id text default null,
  p_payment_intent_id text default null,
  p_error text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_attempt public.retail_checkout_attempts%rowtype;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'Service role required';
  end if;

  if p_refund_status not in ('requested', 'succeeded', 'failed', 'reconciliation_required') then
    raise exception 'Invalid refund status';
  end if;
  if p_refund_status = 'succeeded' and coalesce(p_stripe_refund_id, '') = '' then
    raise exception 'Stripe refund ID is required for succeeded status';
  end if;

  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.id = p_attempt_id
   for update;

  if not found then
    return jsonb_build_object('outcome', 'not_found');
  end if;

  if v_attempt.refund_idempotency_key is distinct from p_refund_idempotency_key then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'idempotency_key_mismatch');
  end if;

  if v_attempt.refund_status = 'succeeded' then
    return jsonb_build_object('outcome', 'already_succeeded',
      'stripe_refund_id', v_attempt.stripe_refund_id);
  end if;

  if p_payment_intent_id is not null
     and v_attempt.stripe_payment_intent_id is not null
     and v_attempt.stripe_payment_intent_id is distinct from p_payment_intent_id then
    update public.retail_checkout_attempts
       set refund_status = 'reconciliation_required',
           last_error = 'Retrieved PaymentIntent does not match the attempt.',
           updated_at = now()
     where id = v_attempt.id;
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'payment_intent_mismatch');
  end if;

  update public.retail_checkout_attempts
     set refund_status = p_refund_status,
         stripe_refund_id = coalesce(stripe_refund_id, p_stripe_refund_id),
         stripe_payment_intent_id = coalesce(stripe_payment_intent_id, p_payment_intent_id),
         last_error = nullif(left(coalesce(p_error, ''), 1000), ''),
         updated_at = now()
   where id = v_attempt.id;

  return jsonb_build_object('outcome', p_refund_status,
    'stripe_refund_id', coalesce(v_attempt.stripe_refund_id, p_stripe_refund_id));
end;
$function$;

revoke all on function public.claim_retail_checkout_refund(uuid) from public, anon, authenticated;
grant execute on function public.claim_retail_checkout_refund(uuid) to service_role;
revoke all on function public.finish_retail_checkout_refund(uuid, text, text, text, text, text) from public, anon, authenticated;
grant execute on function public.finish_retail_checkout_refund(uuid, text, text, text, text, text) to service_role;
