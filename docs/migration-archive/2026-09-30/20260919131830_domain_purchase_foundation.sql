-- TradeFlow domain purchasing foundation
-- This migration is intentionally idempotent because the live database foundation
-- was applied during the 19 September 2026 implementation session before the
-- repository migration record was committed.

create table if not exists public.domain_tld_catalog (
  id uuid primary key default gen_random_uuid(),
  tld text not null,
  active boolean not null default true,
  registration_price numeric(12,2),
  renewal_price numeric(12,2),
  transfer_price numeric(12,2),
  currency text not null default 'GBP',
  default_registration_years integer not null default 1,
  max_registration_years integer not null default 10,
  provider_code text,
  provider_product_code text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint domain_tld_catalog_tld_chk check (tld = lower(trim(tld)) and tld like '.%' and length(tld) between 2 and 63),
  constraint domain_tld_catalog_currency_chk check (currency = upper(trim(currency)) and length(currency)=3),
  constraint domain_tld_catalog_years_chk check (default_registration_years between 1 and max_registration_years and max_registration_years between 1 and 99),
  constraint domain_tld_catalog_prices_chk check (coalesce(registration_price,0) >= 0 and coalesce(renewal_price,0) >= 0 and coalesce(transfer_price,0) >= 0),
  constraint domain_tld_catalog_tld_unique unique (tld)
);

create table if not exists public.tenant_domain_orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  domain_id uuid references public.tenant_domains(id) on delete set null,
  operation text not null default 'register',
  hostname text not null,
  tld text not null,
  term_years integer not null default 1,
  status text not null default 'pending_payment',
  currency text not null default 'GBP',
  retail_amount numeric(12,2) not null default 0,
  registrar_cost numeric(12,2),
  payment_provider text,
  payment_reference text,
  provider_order_id text,
  provider_domain_id text,
  purchased_at timestamptz,
  expires_at timestamptz,
  auto_renew boolean not null default true,
  failure_reason text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tenant_domain_orders_operation_chk check (operation = any (array['register','renew','transfer'])),
  constraint tenant_domain_orders_status_chk check (status = any (array['pending_payment','payment_failed','submitted','registering','registered','failed','cancelled','refunded'])),
  constraint tenant_domain_orders_hostname_chk check (hostname = lower(trim(hostname)) and length(hostname) between 3 and 253),
  constraint tenant_domain_orders_tld_chk check (tld = lower(trim(tld)) and tld like '.%' and length(tld) between 2 and 63),
  constraint tenant_domain_orders_years_chk check (term_years between 1 and 99),
  constraint tenant_domain_orders_currency_chk check (currency = upper(trim(currency)) and length(currency)=3),
  constraint tenant_domain_orders_amount_chk check (retail_amount >= 0 and (registrar_cost is null or registrar_cost >= 0))
);

alter table public.tenant_domains
  add column if not exists acquisition_source text not null default 'connected',
  add column if not exists registrar_provider text,
  add column if not exists registrar_domain_id text,
  add column if not exists registered_at timestamptz,
  add column if not exists expires_at timestamptz,
  add column if not exists auto_renew boolean not null default false,
  add column if not exists provider_metadata jsonb not null default '{}'::jsonb;

do $$
begin
  if not exists (select 1 from pg_constraint where conname='tenant_domains_acquisition_source_chk') then
    alter table public.tenant_domains add constraint tenant_domains_acquisition_source_chk
      check (acquisition_source = any (array['connected','purchased','transferred'])) not valid;
  end if;
end $$;

alter table public.tenant_domains validate constraint tenant_domains_acquisition_source_chk;

create unique index if not exists tenant_domains_registrar_domain_id_uidx on public.tenant_domains(registrar_provider, registrar_domain_id) where registrar_domain_id is not null;
create index if not exists tenant_domain_orders_tenant_created_idx on public.tenant_domain_orders(tenant_id, created_at desc);
create index if not exists tenant_domain_orders_status_idx on public.tenant_domain_orders(status);
create index if not exists tenant_domain_orders_domain_idx on public.tenant_domain_orders(domain_id);

alter table public.domain_tld_catalog enable row level security;
alter table public.tenant_domain_orders enable row level security;
revoke all on public.domain_tld_catalog from anon, authenticated;
revoke all on public.tenant_domain_orders from anon, authenticated;
grant select on public.domain_tld_catalog to anon, authenticated;
grant select, insert, update, delete on public.tenant_domain_orders to authenticated;

drop policy if exists domain_tld_catalog_active_read_anon on public.domain_tld_catalog;
create policy domain_tld_catalog_active_read_anon on public.domain_tld_catalog for select to anon using (active=true);
drop policy if exists domain_tld_catalog_active_read_authenticated on public.domain_tld_catalog;
create policy domain_tld_catalog_active_read_authenticated on public.domain_tld_catalog for select to authenticated using (active=true);
drop policy if exists tenant_domain_orders_member_select on public.tenant_domain_orders;
create policy tenant_domain_orders_member_select on public.tenant_domain_orders for select to authenticated using (private.is_tenant_member(tenant_id));
drop policy if exists tenant_domain_orders_manage_insert on public.tenant_domain_orders;
create policy tenant_domain_orders_manage_insert on public.tenant_domain_orders for insert to authenticated with check (private.can_tenant(tenant_id,'website.manage'::text,'website.editor'::text));
drop policy if exists tenant_domain_orders_manage_update on public.tenant_domain_orders;
create policy tenant_domain_orders_manage_update on public.tenant_domain_orders for update to authenticated using (private.can_tenant(tenant_id,'website.manage'::text,'website.editor'::text)) with check (private.can_tenant(tenant_id,'website.manage'::text,'website.editor'::text));
drop policy if exists tenant_domain_orders_manage_delete on public.tenant_domain_orders;
create policy tenant_domain_orders_manage_delete on public.tenant_domain_orders for delete to authenticated using (private.can_tenant(tenant_id,'website.manage'::text,'website.editor'::text));

insert into public.domain_tld_catalog (tld,currency,metadata)
values ('.co.uk','GBP','{"pricing_status":"provider_required"}'::jsonb),('.uk','GBP','{"pricing_status":"provider_required"}'::jsonb),('.com','GBP','{"pricing_status":"provider_required"}'::jsonb)
on conflict (tld) do nothing;

comment on table public.domain_tld_catalog is 'TradeFlow domain TLD catalogue and pricing foundation. Availability is provider-driven at search time; registrar credentials are never stored here.';
comment on table public.tenant_domain_orders is 'Tenant-scoped domain registration, renewal and transfer order ledger. Payment and registrar references are provider-neutral.';
comment on column public.tenant_domains.acquisition_source is 'How the domain entered TradeFlow: connected externally, purchased through TradeFlow, or transferred in.';
comment on column public.tenant_domains.registrar_provider is 'Provider-neutral registrar identifier; secrets are stored outside the database.';
comment on column public.tenant_domains.registrar_domain_id is 'Provider-side domain identifier for purchased/transferred domains.';
comment on column public.tenant_domains.provider_metadata is 'Non-secret provider state needed for domain lifecycle reconciliation.';
