-- Subscriber business profile and production customer portal foundation.
-- Live changes were applied to project twfbmjwwqzxdxvclxbun before this
-- migration file was committed so the repository remains reproducible.

create table if not exists public.tenant_public_profiles (
  tenant_id uuid primary key references public.tenants(id) on delete cascade,
  business_name text,
  public_email text,
  public_phone text,
  address_line1 text,
  address_line2 text,
  city text,
  county text,
  postcode text,
  country_code text not null default 'GB',
  description text,
  logo_url text,
  show_email boolean not null default true,
  show_phone boolean not null default true,
  show_address boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.tenant_public_profiles enable row level security;
revoke all on table public.tenant_public_profiles from anon, authenticated;
grant select on table public.tenant_public_profiles to anon, authenticated;
grant insert, update on table public.tenant_public_profiles to authenticated;

create or replace function private.is_active_tenant(p_tenant_id uuid)
returns boolean language sql stable security definer set search_path = ''
as $function$
  select exists (
    select 1 from public.tenants t
    where t.id = p_tenant_id and t.status = 'active'
  );
$function$;

revoke execute on function private.is_active_tenant(uuid) from public, anon, authenticated;
grant execute on function private.is_active_tenant(uuid) to anon, authenticated;

create policy "tenant_public_profiles_public_read"
on public.tenant_public_profiles for select to anon, authenticated
using ((select private.is_active_tenant(tenant_id)));

create policy "tenant_public_profiles_manage_insert"
on public.tenant_public_profiles for insert to authenticated
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'));

create policy "tenant_public_profiles_manage_update"
on public.tenant_public_profiles for update to authenticated
using (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'))
with check (private.has_tenant_permission(tenant_id, auth.uid(), 'tenant.manage'));

create or replace function public.customer_register_for_tenant(
  p_tenant_id uuid, p_first_name text, p_last_name text default null, p_phone text default null
)
returns uuid language plpgsql security definer set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_customer_id uuid;
  v_email text;
  v_first_name text := btrim(coalesce(p_first_name, ''));
  v_last_name text := nullif(btrim(coalesce(p_last_name, '')), '');
  v_phone text := nullif(btrim(coalesce(p_phone, '')), '');
begin
  if v_user_id is null then raise exception 'Authentication required'; end if;
  if p_tenant_id is null then raise exception 'Subscriber business is required'; end if;
  if v_first_name = '' then raise exception 'First name is required'; end if;
  if not exists (
    select 1 from public.tenants t
    where t.id=p_tenant_id and t.status='active'
  ) then raise exception 'Subscriber business is not available'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_user_id limit 1;
  if v_customer_id is not null then return v_customer_id; end if;

  select u.email into v_email from auth.users u where u.id=v_user_id;
  insert into public.customers(tenant_id,auth_user_id,first_name,last_name,email,phone,status)
  values(p_tenant_id,v_user_id,v_first_name,v_last_name,v_email,v_phone,'active')
  returning id into v_customer_id;
  return v_customer_id;
end;
$function$;

revoke execute on function public.customer_register_for_tenant(uuid,text,text,text) from public, anon;
grant execute on function public.customer_register_for_tenant(uuid,text,text,text) to authenticated;

create or replace function public.customer_update_profile(
  p_tenant_id uuid, p_first_name text, p_last_name text default null, p_phone text default null
)
returns void language plpgsql security definer set search_path = ''
as $function$
declare
  v_user_id uuid := auth.uid();
  v_first_name text := btrim(coalesce(p_first_name, ''));
begin
  if v_user_id is null then raise exception 'Authentication required'; end if;
  if v_first_name='' then raise exception 'First name is required'; end if;
  update public.customers
  set first_name=v_first_name,
      last_name=nullif(btrim(coalesce(p_last_name,'')),''),
      phone=nullif(btrim(coalesce(p_phone,'')),'')
  where tenant_id=p_tenant_id and auth_user_id=v_user_id;
  if not found then raise exception 'Customer account not found for this subscriber'; end if;
end;
$function$;

revoke execute on function public.customer_update_profile(uuid,text,text,text) from public, anon;
grant execute on function public.customer_update_profile(uuid,text,text,text) to authenticated;

create unique index if not exists customers_tenant_auth_user_unique
on public.customers(tenant_id,auth_user_id) where auth_user_id is not null;

create or replace function public.touch_tenant_public_profile_updated_at()
returns trigger language plpgsql security invoker set search_path = ''
as $function$
begin new.updated_at=now(); return new; end;
$function$;

drop trigger if exists tenant_public_profiles_set_updated_at on public.tenant_public_profiles;
create trigger tenant_public_profiles_set_updated_at
before update on public.tenant_public_profiles
for each row execute function public.touch_tenant_public_profile_updated_at();

insert into public.tenant_public_profiles(tenant_id,business_name)
select t.id,t.name from public.tenants t
where not exists (select 1 from public.tenant_public_profiles p where p.tenant_id=t.id);
