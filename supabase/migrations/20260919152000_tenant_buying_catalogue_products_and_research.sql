create table if not exists public.tenant_buying_products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete restrict,
  branch_id uuid not null references public.category_branches(id) on delete restrict,
  manufacturer text not null,
  model text not null,
  package_name text,
  active boolean not null default true,
  automatic_percentage numeric(6,2),
  manual_offer_price numeric(12,2),
  pricing_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tenant_buying_products_percentage_ck check (automatic_percentage is null or (automatic_percentage >= 0 and automatic_percentage <= 100)),
  constraint tenant_buying_products_manual_price_ck check (manual_offer_price is null or manual_offer_price >= 0),
  constraint tenant_buying_products_pricing_ck check (automatic_percentage is null or manual_offer_price is null)
);

create unique index if not exists tenant_buying_products_identity_uq
on public.tenant_buying_products(tenant_id, branch_id, lower(manufacturer), lower(model), lower(coalesce(package_name,'')));

create index if not exists tenant_buying_products_tenant_branch_idx
on public.tenant_buying_products(tenant_id, branch_id);

create table if not exists public.tenant_buying_research (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  buying_product_id uuid not null references public.tenant_buying_products(id) on delete cascade,
  evidence_type text not null check (evidence_type in ('uk_new','uk_used','overseas')),
  source_name text not null,
  source_url text,
  observed_price numeric(12,2),
  price_currency text not null default 'GBP',
  item_condition text,
  availability text,
  notes text,
  checked_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

create index if not exists tenant_buying_research_product_idx
on public.tenant_buying_research(tenant_id, buying_product_id, evidence_type, checked_at desc);

alter table public.tenant_buying_products enable row level security;
alter table public.tenant_buying_research enable row level security;

revoke all on table public.tenant_buying_products from anon, authenticated;
revoke all on table public.tenant_buying_research from anon, authenticated;
grant select, insert, update, delete on table public.tenant_buying_products to authenticated;
grant select, insert, update, delete on table public.tenant_buying_research to authenticated;

create policy "tenant_buying_products_select" on public.tenant_buying_products
for select to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));
create policy "tenant_buying_products_insert" on public.tenant_buying_products
for insert to authenticated with check ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));
create policy "tenant_buying_products_update" on public.tenant_buying_products
for update to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')))
with check ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));
create policy "tenant_buying_products_delete" on public.tenant_buying_products
for delete to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));

create policy "tenant_buying_research_select" on public.tenant_buying_research
for select to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));
create policy "tenant_buying_research_insert" on public.tenant_buying_research
for insert to authenticated with check ((select private.can_tenant(tenant_id,'buying.manage','module.buying')) and created_by = (select auth.uid()));
create policy "tenant_buying_research_update" on public.tenant_buying_research
for update to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')))
with check ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));
create policy "tenant_buying_research_delete" on public.tenant_buying_research
for delete to authenticated using ((select private.can_tenant(tenant_id,'buying.manage','module.buying')));

create or replace function public.touch_tenant_buying_products_updated_at()
returns trigger language plpgsql security definer set search_path = ''
as $$ begin new.updated_at = now(); return new; end; $$;

drop trigger if exists tenant_buying_products_touch on public.tenant_buying_products;
create trigger tenant_buying_products_touch before update on public.tenant_buying_products
for each row execute function public.touch_tenant_buying_products_updated_at();

revoke execute on function public.touch_tenant_buying_products_updated_at() from public, anon, authenticated;
