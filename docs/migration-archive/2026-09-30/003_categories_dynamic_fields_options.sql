create table public.categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  name text not null,
  slug text not null,
  description text,
  active boolean not null default true,
  buying_enabled boolean not null default true,
  selling_enabled boolean not null default true,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id)
);

create unique index categories_tenant_slug_key
  on public.categories (tenant_id, lower(slug));
create index categories_tenant_active_sort_idx
  on public.categories (tenant_id, active, sort_order, name);

create table public.category_fields (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  category_id uuid not null,
  field_key text not null,
  label text not null,
  field_type text not null check (field_type in ('text','textarea','number','currency','boolean','date','select','multiselect','email','phone','url')),
  required_for_buying boolean not null default false,
  required_for_selling boolean not null default false,
  customer_visible boolean not null default true,
  staff_visible boolean not null default true,
  valuation_relevant boolean not null default false,
  sort_order integer not null default 0 check (sort_order >= 0),
  validation_config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, category_id, field_key),
  foreign key (tenant_id, category_id)
    references public.categories(tenant_id, id) on delete restrict
);

create index category_fields_tenant_category_sort_idx
  on public.category_fields (tenant_id, category_id, sort_order, label);

create table public.category_field_options (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  category_id uuid not null,
  field_id uuid not null,
  value text not null,
  label text not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, field_id, value),
  foreign key (tenant_id, field_id)
    references public.category_fields(tenant_id, id) on delete restrict,
  foreign key (tenant_id, category_id)
    references public.categories(tenant_id, id) on delete restrict
);

create index category_field_options_tenant_field_sort_idx
  on public.category_field_options (tenant_id, field_id, sort_order, label);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger categories_set_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

create trigger category_fields_set_updated_at
before update on public.category_fields
for each row execute function public.set_updated_at();

create trigger category_field_options_set_updated_at
before update on public.category_field_options
for each row execute function public.set_updated_at();

alter table public.categories enable row level security;
alter table public.category_fields enable row level security;
alter table public.category_field_options enable row level security;

create policy categories_select_members
on public.categories
for select to authenticated
using (private.is_tenant_member(tenant_id));

create policy categories_insert_admins
on public.categories
for insert to authenticated
with check (private.is_tenant_admin(tenant_id));

create policy categories_update_admins
on public.categories
for update to authenticated
using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));

create policy categories_delete_admins
on public.categories
for delete to authenticated
using (private.is_tenant_admin(tenant_id));

create policy category_fields_select_members
on public.category_fields
for select to authenticated
using (private.is_tenant_member(tenant_id));

create policy category_fields_insert_admins
on public.category_fields
for insert to authenticated
with check (private.is_tenant_admin(tenant_id));

create policy category_fields_update_admins
on public.category_fields
for update to authenticated
using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));

create policy category_fields_delete_admins
on public.category_fields
for delete to authenticated
using (private.is_tenant_admin(tenant_id));

create policy category_field_options_select_members
on public.category_field_options
for select to authenticated
using (private.is_tenant_member(tenant_id));

create policy category_field_options_insert_admins
on public.category_field_options
for insert to authenticated
with check (private.is_tenant_admin(tenant_id));

create policy category_field_options_update_admins
on public.category_field_options
for update to authenticated
using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));

create policy category_field_options_delete_admins
on public.category_field_options
for delete to authenticated
using (private.is_tenant_admin(tenant_id));

comment on table public.categories is 'Tenant-defined product/service categories used by TradeFlow buying and selling flows.';
comment on table public.category_fields is 'Tenant-defined dynamic fields for a category; these replace hard-coded specialist product attributes.';
comment on table public.category_field_options is 'Selectable options for category fields such as select and multiselect fields.';
