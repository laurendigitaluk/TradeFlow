create or replace function public.platform_owner_create_complimentary_subscriber(
  p_user_id uuid,
  p_business_name text,
  p_business_slug text,
  p_owner_email text
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tenant_id uuid;
  v_plan_id uuid;
  v_email text;
begin
  if not private.is_platform_owner(auth.uid()) then
    raise exception 'Active platform-owner access is required' using errcode='42501';
  end if;
  if p_user_id is null or nullif(trim(p_business_name),'') is null
     or nullif(trim(p_business_slug),'') is null or nullif(trim(p_owner_email),'') is null then
    raise exception 'Business name, slug, owner email and invited user are required' using errcode='22023';
  end if;
  select lower(u.email) into v_email from auth.users u where u.id=p_user_id;
  if v_email is null or v_email <> lower(trim(p_owner_email)) then
    raise exception 'Invited user email could not be verified' using errcode='22023';
  end if;
  if exists(select 1 from public.tenant_memberships tm where tm.user_id=p_user_id and tm.role_code='owner' and tm.status='active') then
    raise exception 'This user already owns an active subscriber business' using errcode='23505';
  end if;
  if exists(select 1 from public.tenants t where t.slug=lower(trim(p_business_slug))) then
    raise exception 'That business URL is already in use. Choose a different business name.' using errcode='23505';
  end if;
  select p.id into v_plan_id from public.plans p where p.code='enhanced' and p.active=true limit 1;
  if v_plan_id is null then
    raise exception 'The TradeFlow plan is not configured in this environment' using errcode='55000';
  end if;
  insert into public.tenants(name,slug,status,settings)
  values(trim(p_business_name),lower(trim(p_business_slug)),'active',
    jsonb_build_object('complimentary_access',true,'provisioned_by_platform_owner',true))
  returning id into v_tenant_id;
  insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at)
  values(v_tenant_id,p_user_id,'owner','active',now());
  insert into public.tenant_subscriptions(
    tenant_id,plan_id,status,billing_provider,provider_status,started_at,current_period_start,
    metadata,provider_metadata
  ) values (
    v_tenant_id,v_plan_id,'active','manual','complimentary',now(),now(),
    jsonb_build_object('complimentary',true,'granted_by_platform_owner',auth.uid(),'reason','Platform-owner complimentary access'),
    jsonb_build_object('billing_exempt',true,'stripe_required',false)
  );
  return v_tenant_id;
end;
$$;
revoke all on function public.platform_owner_create_complimentary_subscriber(uuid,text,text,text) from public, anon;
grant execute on function public.platform_owner_create_complimentary_subscriber(uuid,text,text,text) to authenticated;
