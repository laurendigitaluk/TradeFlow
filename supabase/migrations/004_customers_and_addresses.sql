create table public.customers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  auth_user_id uuid references auth.users(id) on delete set null,
  customer_reference text not null,
  first_name text not null,
  last_name text,
  email text,
  phone text,
  status text not null default 'active' check (status in ('active','inactive','archived')),
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, customer_reference)
);

create index customers_tenant_idx on public.customers (tenant_id);
create index customers_tenant_email_idx on public.customers (tenant_id, lower(email));
create index customers_auth_user_idx on public.customers (auth_user_id);

create table public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  customer_id uuid not null,
  address_type text not null default 'primary' check (address_type in ('primary','billing','shipping','other')),
  recipient_name text,
  company_name text,
  line1 text not null,
  line2 text,
  city text not null,
  county text,
  postcode text not null,
  country_code text not null default 'GB',
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, customer_id) references public.customers(tenant_id, id) on delete restrict
);

create index customer_addresses_customer_idx on public.customer_addresses (tenant_id, customer_id);
create unique index customer_addresses_one_default_per_type on public.customer_addresses (tenant_id, customer_id, address_type) where is_default;

create or replace function public.generate_customer_reference()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.customer_reference is null or btrim(new.customer_reference) = '' then
    new.customer_reference := 'CUS-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$$;

create trigger customers_generate_reference
before insert on public.customers
for each row execute function public.generate_customer_reference();

create trigger customers_set_updated_at
before update on public.customers
for each row execute function public.set_updated_at();

create trigger customer_addresses_set_updated_at
before update on public.customer_addresses
for each row execute function public.set_updated_at();

alter table public.customers enable row level security;
alter table public.customer_addresses enable row level security;

create policy customers_select_members on public.customers for select to authenticated using (private.is_tenant_member(tenant_id));
create policy customers_insert_members on public.customers for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy customers_update_members on public.customers for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy customers_delete_admins on public.customers for delete to authenticated using (private.is_tenant_admin(tenant_id));

create policy customer_addresses_select_members on public.customer_addresses for select to authenticated using (private.is_tenant_member(tenant_id));
create policy customer_addresses_insert_members on public.customer_addresses for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy customer_addresses_update_members on public.customer_addresses for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy customer_addresses_delete_admins on public.customer_addresses for delete to authenticated using (private.is_tenant_admin(tenant_id));
