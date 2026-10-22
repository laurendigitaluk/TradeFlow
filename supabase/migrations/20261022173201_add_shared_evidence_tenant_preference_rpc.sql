create or replace function public.subscriber_set_shared_evidence_preference(p_tenant_id uuid, p_enabled boolean)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
begin
  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'categories.view') then
    raise exception 'Tenant user is not authorised to change shared evidence settings';
  end if;
  if not private.has_tenant_feature(p_tenant_id, 'module.buying') then
    raise exception 'Buying is not enabled for this subscription';
  end if;
  update public.tenants
     set settings = coalesce(settings, '{}'::jsonb) || jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true)),
         updated_at = now()
   where id = p_tenant_id;
  if not found then raise exception 'Tenant not found'; end if;
  return jsonb_build_object('use_shared_evidence', coalesce(p_enabled, true));
end;
$function$;

revoke all on function public.subscriber_set_shared_evidence_preference(uuid, boolean) from public, anon;
grant execute on function public.subscriber_set_shared_evidence_preference(uuid, boolean) to authenticated;
