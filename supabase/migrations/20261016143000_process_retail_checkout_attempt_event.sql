-- Candidate only: atomic settlement boundary for Stripe Connect retail checkout attempts.
-- Do not apply to LIVE before disposable PostgreSQL and Stripe test-mode validation.

create or replace function public.process_retail_checkout_attempt_event(
  p_event_id text,
  p_event_type text,
  p_tenant_id uuid,
  p_connected_account_id text,
  p_checkout_session_id text,
  p_payment_intent_id text,
  p_new_status text,
  p_amount numeric,
  p_currency text,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_attempt public.retail_checkout_attempts%rowtype;
  v_payment public.payment_records%rowtype;
  v_result boolean;
  v_seen boolean;
  v_amount numeric;
  v_currency text;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'Service role required';
  end if;

  if coalesce(p_event_id, '') = '' or coalesce(p_event_type, '') = ''
     or coalesce(p_connected_account_id, '') = ''
     or coalesce(p_checkout_session_id, '') = ''
     or p_new_status is null
     or p_new_status not in ('paid', 'failed', 'expired') then
    raise exception 'Invalid retail checkout event arguments';
  end if;

  -- Lock the exact attempt first; a PaymentIntent ID is corroborating identity,
  -- never a substitute for the canonical Checkout Session ID.
  -- Match the Session without a row lock first so we can acquire locks in
  -- the same payment -> attempt order used by reserve_retail_checkout_attempt.
  -- Locking attempt -> payment here could deadlock against a concurrent retry.
  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.tenant_id = p_tenant_id
     and a.stripe_session_id = p_checkout_session_id;

  if not found then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'attempt_not_found');
  end if;

  select p.* into v_payment
    from public.payment_records p
   where p.id = v_attempt.payment_id
     and p.tenant_id = p_tenant_id
     and p.retail_order_id is not null
   for update;

  if not found then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'payment_record_not_found');
  end if;

  -- Re-read and lock the exact attempt only after its payment row is locked.
  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.id = v_attempt.id
   for update;

  if not found or v_attempt.stripe_session_id is distinct from p_checkout_session_id then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'attempt_changed_during_lock');
  end if;

  if v_attempt.stripe_account_id is distinct from p_connected_account_id then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'connected_account_mismatch');
  end if;

  if p_payment_intent_id is not null
     and v_attempt.stripe_payment_intent_id is not null
     and v_attempt.stripe_payment_intent_id is distinct from p_payment_intent_id then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'payment_intent_mismatch');
  end if;

  v_amount := round(coalesce(v_payment.amount, 0)::numeric, 2);
  v_currency := upper(coalesce(v_payment.currency, ''));
  if round(coalesce(p_amount, -1)::numeric, 2) is distinct from v_amount
     or upper(coalesce(p_currency, '')) is distinct from v_currency then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'amount_or_currency_mismatch');
  end if;

  select exists (
    select 1 from public.payment_provider_events e
     where e.provider = 'stripe' and e.event_id = p_event_id
  ) into v_seen;

  if v_seen then
    return jsonb_build_object('outcome', 'duplicate', 'attempt_id', v_attempt.id,
      'refund_status', v_attempt.refund_status);
  end if;

  if v_attempt.status = 'completed' then
    return jsonb_build_object('outcome', 'reconciliation_required', 'reason', 'attempt_already_completed');
  end if;

  if p_new_status = 'expired' then
    if v_attempt.status = 'open' then
      update public.retail_checkout_attempts
         set status = 'expired', last_event_id = p_event_id,
             last_event_type = p_event_type, updated_at = now()
       where id = v_attempt.id;
    end if;
    insert into public.payment_provider_events(provider, event_id, event_type, metadata)
    values ('stripe', p_event_id, p_event_type,
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('checkout_attempt_id', v_attempt.id));
    return jsonb_build_object('outcome', 'expired', 'attempt_id', v_attempt.id);
  end if;

  if p_new_status = 'failed' then
    if v_attempt.status in ('creating', 'open') then
      update public.retail_checkout_attempts
         set status = 'failed', last_event_id = p_event_id,
             last_event_type = p_event_type, updated_at = now()
       where id = v_attempt.id;
    end if;
    insert into public.payment_provider_events(provider, event_id, event_type, metadata)
    values ('stripe', p_event_id, p_event_type,
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('checkout_attempt_id', v_attempt.id));
    return jsonb_build_object('outcome', 'failed', 'attempt_id', v_attempt.id);
  end if;

  -- An expiry/failure belongs to its exact attempt even if the payment row now
  -- points at a newer Session. Do not let stale lifecycle events affect that row.
  -- A paid event from a different, non-null Session is a second charge candidate:
  -- persist a refund intent for this exact attempt instead of passing it to the
  -- legacy settlement RPC or silently treating it as the canonical payment.
  if p_new_status = 'paid'
     and v_payment.provider_payment_id is not null
     and v_payment.provider_payment_id is distinct from p_checkout_session_id then
    update public.retail_checkout_attempts
       set refund_status = 'required',
           refund_idempotency_key = coalesce(refund_idempotency_key,
             'tradeflow-refund-' || v_attempt.id::text),
           last_event_id = p_event_id, last_event_type = p_event_type, updated_at = now()
     where id = v_attempt.id;
    insert into public.payment_provider_events(provider, event_id, event_type, metadata)
    values ('stripe', p_event_id, p_event_type,
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
        'checkout_attempt_id', v_attempt.id,
        'settlement_outcome', 'refund_required',
        'reason', 'payment_session_mismatch'
      ));
    return jsonb_build_object('outcome', 'refund_required', 'attempt_id', v_attempt.id,
      'refund_status', 'required', 'reason', 'payment_session_mismatch');
  end if;

  -- A previous attempt may have settled the order already. Do not infer that
  -- this attempt won merely because the legacy RPC returns true for terminal rows.
  if v_payment.status in ('paid', 'refunded', 'partially_refunded', 'cancelled', 'failed') then
    update public.retail_checkout_attempts
       set refund_status = case when v_payment.status = 'paid' then 'reconciliation_required' else 'required' end,
           refund_idempotency_key = coalesce(refund_idempotency_key,
             'tradeflow-refund-' || v_attempt.id::text),
           last_event_id = p_event_id, last_event_type = p_event_type, updated_at = now()
     where id = v_attempt.id;
    insert into public.payment_provider_events(provider, event_id, event_type, metadata)
    values ('stripe', p_event_id, p_event_type,
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('checkout_attempt_id', v_attempt.id,
        'settlement_outcome', 'refund_required'));
    return jsonb_build_object('outcome', 'refund_required', 'attempt_id', v_attempt.id,
      'refund_status', case when v_payment.status = 'paid' then 'reconciliation_required' else 'required' end);
  end if;

  -- Reuse existing transactional business effects (credit holds, ledger,
  -- listing/inventory and order workflow) only after identity validation.
  v_result := public.process_external_payment_event(
    'stripe', p_event_id, p_event_type, p_tenant_id, v_payment.id,
    p_checkout_session_id, 'paid', v_amount, v_currency,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
      'stripe_event_id', p_event_id,
      'stripe_checkout_session_id', p_checkout_session_id,
      'stripe_payment_intent_id', p_payment_intent_id,
      'stripe_connected_account_id', p_connected_account_id,
      'checkout_attempt_id', v_attempt.id
    )
  );

  select p.* into v_payment from public.payment_records p
   where p.id = v_attempt.payment_id and p.tenant_id = p_tenant_id
   for update;

  if v_result and v_payment.status = 'paid' then
    update public.retail_checkout_attempts
       set status = 'completed', refund_status = 'not_required',
           stripe_payment_intent_id = coalesce(stripe_payment_intent_id, p_payment_intent_id),
           last_event_id = p_event_id, last_event_type = p_event_type, updated_at = now()
     where id = v_attempt.id;
    return jsonb_build_object('outcome', 'applied', 'attempt_id', v_attempt.id);
  end if;

  -- A late payment or unavailable listing can be rejected by the existing
  -- transition. Record durable refund intent in the same transaction.
  update public.retail_checkout_attempts
     set refund_status = 'required',
         refund_idempotency_key = coalesce(refund_idempotency_key,
           'tradeflow-refund-' || v_attempt.id::text),
         last_event_id = p_event_id, last_event_type = p_event_type, updated_at = now()
   where id = v_attempt.id;
  insert into public.payment_provider_events(provider, event_id, event_type, metadata)
  values ('stripe', p_event_id, p_event_type,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('checkout_attempt_id', v_attempt.id,
      'settlement_outcome', 'refund_required'));
  return jsonb_build_object('outcome', 'refund_required', 'attempt_id', v_attempt.id,
    'refund_status', 'required');
end;
$function$;

revoke all on function public.process_retail_checkout_attempt_event(text, text, uuid, text, text, text, text, numeric, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.process_retail_checkout_attempt_event(text, text, uuid, text, text, text, text, numeric, text, jsonb)
  to service_role;
