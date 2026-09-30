drop policy if exists tenants_insert_authenticated on public.tenants;
drop policy if exists tenants_delete_admins on public.tenants;

create or replace function private.create_tenant_with_owner(p_name text, p_slug text)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
  v_slug text := lower(trim(p_slug));
  v_name text := trim(p_name);
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;
  if v_name = '' then raise exception 'Tenant name is required'; end if;
  if v_slug = '' or v_slug !~ '^[a-z0-9]+([a-z0-9-]*[a-z0-9])?$' then
    raise exception 'Tenant slug must contain lowercase letters, numbers and hyphens only';
  end if;
  if exists (select 1 from public.tenants where lower(slug) = v_slug) then
    raise exception 'Tenant slug is already in use';
  end if;
  insert into public.tenants (name, slug) values (v_name, v_slug) returning id into v_tenant_id;
  insert into public.tenant_memberships (tenant_id, user_id, role_code, status, joined_at)
  values (v_tenant_id, v_user_id, 'owner', 'active', now());
  return v_tenant_id;
end;
$$;

revoke all on function private.create_tenant_with_owner(text, text) from public, anon, authenticated;
grant execute on function private.create_tenant_with_owner(text, text) to authenticated;

comment on function private.create_tenant_with_owner(text, text) is 'Atomically creates a TradeFlow tenant and makes the authenticated caller its owner.';
