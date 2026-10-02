create table if not exists public.tenant_domain_registrants (
 id uuid primary key default gen_random_uuid(),
 tenant_id uuid not null references public.tenants(id) on delete cascade,
 domain_order_id uuid not null unique references public.tenant_domain_orders(id) on delete cascade,
 registrant_name text not null, organisation text, address_line1 text not null, address_line2 text,
 city text not null, region text, postal_code text not null, country_code text not null default 'GB',
 email text not null, phone text not null, confirmed_at timestamptz not null default now(),
 metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.tenant_domain_registrants enable row level security;
drop policy if exists tenant_domain_registrants_select on public.tenant_domain_registrants;
create policy tenant_domain_registrants_select on public.tenant_domain_registrants for select using (private.is_tenant_member(tenant_id));
drop policy if exists tenant_domain_registrants_insert on public.tenant_domain_registrants;
create policy tenant_domain_registrants_insert on public.tenant_domain_registrants for insert with check (private.can_tenant(tenant_id,'website.manage','website.editor'));
drop policy if exists tenant_domain_registrants_update on public.tenant_domain_registrants;
create policy tenant_domain_registrants_update on public.tenant_domain_registrants for update using (private.can_tenant(tenant_id,'website.manage','website.editor')) with check (private.can_tenant(tenant_id,'website.manage','website.editor'));
create index if not exists tenant_domain_registrants_tenant_idx on public.tenant_domain_registrants(tenant_id);
create or replace function public.touch_tenant_domain_registrants_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists tenant_domain_registrants_updated_at on public.tenant_domain_registrants;
create trigger tenant_domain_registrants_updated_at before update on public.tenant_domain_registrants for each row execute function public.touch_tenant_domain_registrants_updated_at();