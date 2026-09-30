create table public.shipping_provider_connections (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  provider text not null,
  status text not null default 'not_connected',
  connection_type text not null default 'subscriber_account',
  provider_account_id text,
  display_name text,
  auth_mode text,
  capabilities jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  connected_at timestamptz,
  disconnected_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shipping_provider_connections_provider_check check (provider in ('parcel2go','sendcloud','shippo')),
  constraint shipping_provider_connections_status_check check (status in ('not_connected','pending','connected','error','disconnected')),
  constraint shipping_provider_connections_type_check check (connection_type = 'subscriber_account'),
  unique (tenant_id, provider)
);

alter table public.shipping_provider_connections enable row level security;
grant select, insert, update, delete on public.shipping_provider_connections to authenticated;

create policy shipping_provider_connections_member_read
on public.shipping_provider_connections for select to authenticated
using (private.is_tenant_member(tenant_id, auth.uid()));

create policy shipping_provider_connections_admin_write
on public.shipping_provider_connections for all to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'))
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'));

alter table public.acquisitions
  add column shipping_provider text,
  add column shipping_provider_connection_id uuid references public.shipping_provider_connections(id) on delete set null,
  add column shipping_provider_shipment_id text,
  add column shipping_tracking_url text,
  add column shipping_status text,
  add column shipping_status_updated_at timestamptz;

comment on table public.shipping_provider_connections is
'Tenant-owned shipping aggregator connections. TradeFlow does not own or pay shipping accounts.';

comment on column public.acquisitions.shipping_provider is
'Aggregator used for operational shipping/tracking; customer/subscriber shipping costs remain outside TradeFlow.';
