-- Subscriber payment-method settings.
create table if not exists public.tenant_payment_methods (
 id uuid primary key default gen_random_uuid(),
 tenant_id uuid not null references public.tenants(id) on delete cascade,
 method_code text not null,
 display_name text not null,
 enabled boolean not null default true,
 instructions text,
 sort_order integer not null default 0,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(tenant_id,method_code)
);
create index if not exists tenant_payment_methods_tenant_idx on public.tenant_payment_methods(tenant_id,sort_order);
alter table public.tenant_payment_methods enable row level security;
drop policy if exists tenant_payment_methods_select on public.tenant_payment_methods;
create policy tenant_payment_methods_select on public.tenant_payment_methods for select to authenticated using (private.is_tenant_member(tenant_id));
drop policy if exists tenant_payment_methods_write on public.tenant_payment_methods;
create policy tenant_payment_methods_write on public.tenant_payment_methods for all to authenticated using (private.is_tenant_admin(tenant_id)) with check (private.is_tenant_admin(tenant_id));
grant select,insert,update,delete on public.tenant_payment_methods to authenticated;