-- Fix subscriber custom-domain status visibility.
-- This read-only RPC is scoped to the caller's active tenant membership.
-- It must not depend on the website permission/feature gate because that gate
-- can legitimately block a status read while the subscriber still needs to
-- see the connection workflow for their own tenant.
create or replace function public.subscriber_get_custom_domain_status()
returns table(
  action_id uuid,
  tenant_domain_id uuid,
  hostname text,
  domain_status text,
  status text,
  notes text,
  metadata jsonb,
  created_at timestamptz
)
language plpgsql
security definer
set search_path to 'pg_catalog', 'public', 'private'
as $function$
declare
  v_user_id uuid := auth.uid();
  v_tenant_id uuid;
begin
  if v_user_id is null then
    raise exception 'Authentication required';
  end if;

  select tm.tenant_id
    into v_tenant_id
  from public.tenant_memberships tm
  join public.tenants t on t.id = tm.tenant_id
  where tm.user_id = v_user_id
    and tm.status = 'active'
    and t.status = 'active'
  order by tm.joined_at desc nulls last
  limit 1;

  if v_tenant_id is null then
    return;
  end if;

  return query
  select
    a.id,
    d.id,
    d.hostname,
    d.status,
    a.status,
    a.notes,
    a.metadata,
    a.created_at
  from public.platform_owner_domain_actions a
  join public.tenant_domains d
    on d.id = a.tenant_domain_id
   and d.tenant_id = v_tenant_id
  where a.tenant_id = v_tenant_id
  order by a.created_at desc
  limit 1;
end;
$function$;

revoke all on function public.subscriber_get_custom_domain_status() from public, anon;
grant execute on function public.subscriber_get_custom_domain_status() to authenticated;
