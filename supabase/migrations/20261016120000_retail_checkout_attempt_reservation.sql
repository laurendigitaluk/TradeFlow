-- Stripe Connect: durable, serialized retail checkout attempts.
-- Feature branch only. This migration must not be applied to LIVE until the
-- Edge Function and webhook changes are reviewed and tested together.

create table if not exists public.retail_checkout_attempts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  payment_id uuid not null references public.payment_records(id) on delete restrict,
  attempt_number integer not null check (attempt_number > 0),
  idempotency_key text not null unique,
  status text not null default 'creating'
    check (status in ('creating','open','expired','failed','completed','cancelled')),
  stripe_session_id text,
  stripe_payment_intent_id text,
  session_expires_at timestamptz,
  last_error text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (payment_id, attempt_number),
  unique (stripe_session_id)
);

create unique index if not exists retail_checkout_attempts_payment_intent_uidx
  on public.retail_checkout_attempts (stripe_payment_intent_id)
  where stripe_payment_intent_id is not null;

create index if not exists retail_checkout_attempts_tenant_payment_idx
  on public.retail_checkout_attempts (tenant_id, payment_id, attempt_number desc);

alter table public.retail_checkout_attempts enable row level security;
revoke all on public.retail_checkout_attempts from public, anon, authenticated;
grant select, insert, update, delete on public.retail_checkout_attempts to service_role;

-- Serializes reservation per payment record. Repeated/concurrent requests get
-- the same attempt and Stripe idempotency key. A new key is issued only after
-- the prior attempt is explicitly terminal; a stale 'creating' attempt is
-- deliberately not auto-replaced because its Stripe request may still be in flight.
create or replace function public.reserve_retail_checkout_attempt(
  p_tenant_id uuid,
  p_payment_id uuid
)
returns table (
  attempt_id uuid,
  attempt_number integer,
  idempotency_key text,
  attempt_status text,
  stripe_session_id text,
  session_expires_at timestamptz,
  created_new boolean
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_payment public.payment_records%rowtype;
  v_attempt public.retail_checkout_attempts%rowtype;
  v_next integer;
begin
  if current_setting('request.jwt.claim.role', true) is distinct from 'service_role' then
    raise exception 'Service role required';
  end if;

  select p.* into v_payment
    from public.payment_records p
   where p.tenant_id = p_tenant_id
     and p.id = p_payment_id
     and p.retail_order_id is not null
   for update;

  if not found then
    raise exception 'Retail checkout payment not found';
  end if;
  if v_payment.status not in ('pending','processing') then
    raise exception 'Payment is not eligible for checkout';
  end if;

  select a.* into v_attempt
    from public.retail_checkout_attempts a
   where a.tenant_id = p_tenant_id
     and a.payment_id = p_payment_id
   order by a.attempt_number desc
   limit 1
   for update;

  if found and v_attempt.status in ('creating','open') then
    return query select v_attempt.id, v_attempt.attempt_number,
      v_attempt.idempotency_key, v_attempt.status, v_attempt.stripe_session_id,
      v_attempt.session_expires_at, false;
    return;
  end if;

  v_next := coalesce(v_attempt.attempt_number, 0) + 1;
  insert into public.retail_checkout_attempts (
    tenant_id, payment_id, attempt_number, idempotency_key, status
  ) values (
    p_tenant_id, p_payment_id, v_next,
    'tradeflow-checkout-' || p_payment_id::text || '-attempt-' || v_next::text || '-' || gen_random_uuid()::text,
    'creating'
  )
  returning * into v_attempt;

  return query select v_attempt.id, v_attempt.attempt_number,
    v_attempt.idempotency_key, v_attempt.status, v_attempt.stripe_session_id,
    v_attempt.session_expires_at, true;
end;
$function$;

revoke all on function public.reserve_retail_checkout_attempt(uuid, uuid) from public, anon, authenticated;
grant execute on function public.reserve_retail_checkout_attempt(uuid, uuid) to service_role;
