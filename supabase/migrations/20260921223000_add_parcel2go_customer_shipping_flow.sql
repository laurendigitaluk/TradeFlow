create table if not exists public.shipping_quote_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  acquisition_id uuid not null references public.acquisitions(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  provider text not null check (provider in ('parcel2go','sendcloud','shippo')),
  provider_connection_id uuid not null references public.shipping_provider_connections(id),
  status text not null default 'quoted' check (status in ('quoted','order_created','paid','cancelled','expired','error')),
  request_payload jsonb not null default '{}'::jsonb,
  response_payload jsonb not null default '{}'::jsonb,
  selected_service jsonb,
  provider_order_id text,
  payment_url text,
  tracking_url text,
  label_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists shipping_quote_sessions_acquisition_idx on public.shipping_quote_sessions(acquisition_id,created_at desc);
create index if not exists shipping_quote_sessions_customer_idx on public.shipping_quote_sessions(customer_id,created_at desc);
alter table public.shipping_quote_sessions enable row level security;
drop policy if exists shipping_quote_sessions_member_select on public.shipping_quote_sessions;
create policy shipping_quote_sessions_member_select on public.shipping_quote_sessions
for select to authenticated using (private.is_tenant_member(tenant_id,auth.uid()));
drop policy if exists shipping_quote_sessions_customer_select on public.shipping_quote_sessions;
create policy shipping_quote_sessions_customer_select on public.shipping_quote_sessions
for select to authenticated using (
  exists (select 1 from public.customers c where c.id=shipping_quote_sessions.customer_id and c.auth_user_id=auth.uid() and c.tenant_id=shipping_quote_sessions.tenant_id)
);
revoke insert,update,delete on public.shipping_quote_sessions from authenticated;
grant select on public.shipping_quote_sessions to authenticated;
alter table public.acquisitions
  add column if not exists shipping_quote_session_id uuid references public.shipping_quote_sessions(id),
  add column if not exists shipping_provider_order_id text,
  add column if not exists shipping_payment_url text,
  add column if not exists shipping_parcel_weight numeric,
  add column if not exists shipping_parcel_length numeric,
  add column if not exists shipping_parcel_width numeric,
  add column if not exists shipping_parcel_height numeric;