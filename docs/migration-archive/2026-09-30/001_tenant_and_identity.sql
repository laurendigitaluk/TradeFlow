create schema if not exists private;

create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  status text not null default 'active' check (status in ('active','suspended','archived')),
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);

create unique index tenants_slug_key on public.tenants (lower(slug));

create table public.tenant_memberships (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  user_id uuid not null references auth.users(id) on delete restrict,
  role_code text not null default 'staff' check (role_code in ('owner','admin','staff')),
  status text not null default 'active' check (status in ('invited','active','suspended','removed')),
  invited_at timestamptz,
  joined_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, user_id)
);

create index tenant_memberships_user_id_idx on public.tenant_memberships (user_id);
create index tenant_memberships_tenant_status_idx on public.tenant_memberships (tenant_id, status);

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

create trigger tenants_set_updated_at
before update on public.tenants
for each row execute function public.set_updated_at();

create trigger tenant_memberships_set_updated_at
before update on public.tenant_memberships
for each row execute function public.set_updated_at();

create or replace function private.is_tenant_member(p_tenant_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.tenant_memberships tm
    where tm.tenant_id = p_tenant_id
      and tm.user_id = p_user_id
      and tm.status = 'active'
  );
$$;

create or replace function private.is_tenant_admin(p_tenant_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.tenant_memberships tm
    where tm.tenant_id = p_tenant_id
      and tm.user_id = p_user_id
      and tm.status = 'active'
      and tm.role_code in ('owner','admin')
  );
$$;

revoke all on function private.is_tenant_member(uuid, uuid) from public, anon, authenticated;
revoke all on function private.is_tenant_admin(uuid, uuid) from public, anon, authenticated;

grant execute on function private.is_tenant_member(uuid, uuid) to authenticated;
grant execute on function private.is_tenant_admin(uuid, uuid) to authenticated;

alter table public.tenants enable row level security;
alter table public.tenant_memberships enable row level security;

create policy tenants_select_members
on public.tenants
for select
to authenticated
using (private.is_tenant_member(id));

create policy tenants_insert_authenticated
on public.tenants
for insert
to authenticated
with check (true);

create policy tenants_update_admins
on public.tenants
for update
to authenticated
using (private.is_tenant_admin(id))
with check (private.is_tenant_admin(id));

create policy tenants_delete_admins
on public.tenants
for delete
to authenticated
using (private.is_tenant_admin(id));

create policy memberships_select_self_or_admin
on public.tenant_memberships
for select
to authenticated
using (
  user_id = auth.uid()
  or private.is_tenant_admin(tenant_id)
);

create policy memberships_insert_admins
on public.tenant_memberships
for insert
to authenticated
with check (private.is_tenant_admin(tenant_id));

create policy memberships_update_admins
on public.tenant_memberships
for update
to authenticated
using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));

create policy memberships_delete_admins
on public.tenant_memberships
for delete
to authenticated
using (private.is_tenant_admin(tenant_id));

comment on table public.tenants is 'TradeFlow SaaS tenant/business security boundary.';
comment on table public.tenant_memberships is 'Maps authenticated users to TradeFlow tenants and establishes owner/admin/staff access.';
comment on function private.is_tenant_member(uuid, uuid) is 'Security helper for tenant membership checks; intentionally not exposed to anonymous clients.';
comment on function private.is_tenant_admin(uuid, uuid) is 'Security helper for tenant administration checks; intentionally not exposed to anonymous clients.';
