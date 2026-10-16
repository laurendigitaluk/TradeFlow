-- Isolated contract fixture for candidate Stripe Connect SQL tests.
-- This is not the production schema and must never be run against LIVE.
create extension if not exists pgcrypto;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role; end if;
end $$;

create table public.payment_records (
  id uuid primary key,
  tenant_id uuid not null,
  retail_order_id uuid not null,
  amount numeric(12,2) not null,
  currency text not null,
  status text not null,
  provider_payment_id text,
  provider text,
  payment_method text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.payment_provider_events (
  id bigint generated always as identity primary key,
  provider text not null,
  event_id text not null,
  event_type text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (provider, event_id)
);

-- Stub the pre-existing business transition used by the candidate settlement RPC.
-- It intentionally models only the payment status/event boundary; it does not
-- pretend to validate the full TradeFlow ledger, inventory, credit, or order flow.
create or replace function public.process_external_payment_event(
  p_provider text,
  p_event_id text,
  p_event_type text,
  p_tenant_id uuid,
  p_payment_id uuid,
  p_provider_payment_id text,
  p_new_status text,
  p_amount numeric,
  p_currency text,
  p_metadata jsonb
) returns boolean
language plpgsql
as $function$
begin
  insert into public.payment_provider_events(provider, event_id, event_type, metadata)
  values (p_provider, p_event_id, p_event_type, coalesce(p_metadata, '{}'::jsonb));

  -- Test-only failure injection models a downstream transition that records
  -- the provider event but declines the business-state transition.
  if coalesce(p_metadata->>'force_reject', 'false') = 'true' then
    return false;
  end if;

  update public.payment_records
     set status = p_new_status,
         provider = p_provider,
         provider_payment_id = p_provider_payment_id,
         updated_at = now()
   where id = p_payment_id
     and tenant_id = p_tenant_id
     and amount = p_amount
     and upper(currency) = upper(p_currency);

  return found;
end;
$function$;
