create table public.buying_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  customer_id uuid not null,
  request_reference text not null,
  status text not null default 'draft' check (status in ('draft','submitted','under_review','valued','offer_ready','closed')),
  source text not null default 'customer_portal' check (source in ('customer_portal','staff','import','api')),
  notes text,
  submitted_at timestamptz,
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, request_reference),
  foreign key (tenant_id, customer_id) references public.customers(tenant_id, id) on delete restrict
);

create index buying_requests_tenant_status_idx on public.buying_requests (tenant_id, status);
create index buying_requests_customer_idx on public.buying_requests (tenant_id, customer_id, created_at desc);

create table public.buying_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  buying_request_id uuid not null,
  category_id uuid not null,
  item_reference text not null,
  status text not null default 'draft' check (status in ('draft','submitted','under_review','valued','offer_ready','closed')),
  title text,
  description text,
  quantity integer not null default 1 check (quantity > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, item_reference),
  foreign key (tenant_id, buying_request_id) references public.buying_requests(tenant_id, id) on delete restrict,
  foreign key (tenant_id, category_id) references public.categories(tenant_id, id) on delete restrict
);

create index buying_items_request_idx on public.buying_items (tenant_id, buying_request_id, sort_order);
create index buying_items_category_idx on public.buying_items (tenant_id, category_id);

create table public.buying_item_field_values (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  buying_item_id uuid not null,
  field_id uuid not null,
  value_text text,
  value_number numeric,
  value_boolean boolean,
  value_date date,
  value_json jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, buying_item_id, field_id),
  foreign key (tenant_id, buying_item_id) references public.buying_items(tenant_id, id) on delete cascade,
  foreign key (tenant_id, field_id) references public.category_fields(tenant_id, id) on delete restrict,
  check (num_nonnulls(value_text, value_number, value_boolean, value_date, value_json) = 1)
);

create index buying_item_field_values_item_idx on public.buying_item_field_values (tenant_id, buying_item_id);
create index buying_item_field_values_field_idx on public.buying_item_field_values (tenant_id, field_id);

create or replace function public.generate_buying_request_reference()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.request_reference is null or btrim(new.request_reference) = '' then
    new.request_reference := 'REQ-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$$;

create or replace function public.generate_buying_item_reference()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if new.item_reference is null or btrim(new.item_reference) = '' then
    new.item_reference := 'ITEM-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  end if;
  return new;
end;
$$;

create trigger buying_requests_generate_reference before insert on public.buying_requests for each row execute function public.generate_buying_request_reference();
create trigger buying_items_generate_reference before insert on public.buying_items for each row execute function public.generate_buying_item_reference();
create trigger buying_requests_set_updated_at before update on public.buying_requests for each row execute function public.set_updated_at();
create trigger buying_items_set_updated_at before update on public.buying_items for each row execute function public.set_updated_at();
create trigger buying_item_field_values_set_updated_at before update on public.buying_item_field_values for each row execute function public.set_updated_at();

alter table public.buying_requests enable row level security;
alter table public.buying_items enable row level security;
alter table public.buying_item_field_values enable row level security;

create policy buying_requests_select_members on public.buying_requests for select to authenticated using (private.is_tenant_member(tenant_id));
create policy buying_requests_insert_members on public.buying_requests for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy buying_requests_update_members on public.buying_requests for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy buying_requests_delete_admins on public.buying_requests for delete to authenticated using (private.is_tenant_admin(tenant_id));

create policy buying_items_select_members on public.buying_items for select to authenticated using (private.is_tenant_member(tenant_id));
create policy buying_items_insert_members on public.buying_items for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy buying_items_update_members on public.buying_items for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy buying_items_delete_admins on public.buying_items for delete to authenticated using (private.is_tenant_admin(tenant_id));

create policy buying_item_field_values_select_members on public.buying_item_field_values for select to authenticated using (private.is_tenant_member(tenant_id));
create policy buying_item_field_values_insert_members on public.buying_item_field_values for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy buying_item_field_values_update_members on public.buying_item_field_values for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy buying_item_field_values_delete_admins on public.buying_item_field_values for delete to authenticated using (private.is_tenant_admin(tenant_id));
