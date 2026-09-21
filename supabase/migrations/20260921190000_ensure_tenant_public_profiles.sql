-- Ensure every active tenant has an authoritative public business profile.
-- This is required by customer-facing website and portal branding.
insert into public.tenant_public_profiles (tenant_id, business_name)
select t.id, t.name
from public.tenants t
where t.status='active'
on conflict (tenant_id) do nothing;

create or replace function public.subscriber_create_business(p_name text, p_slug text, p_plan_code text)
returns uuid
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
  v_user uuid := auth.uid();
  v_plan uuid;
  v_tenant uuid;
  v_slug text;
  v_trial_end timestamptz;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Business name is required'; end if;
  if p_plan_code not in ('basic','enhanced','catalogue') then raise exception 'Invalid plan'; end if;

  select id into v_plan
  from public.plans
  where code=p_plan_code and active=true
  limit 1;

  if v_plan is null then raise exception 'Selected plan is not available'; end if;

  v_slug := lower(regexp_replace(trim(coalesce(p_slug,p_name)),'[^a-zA-Z0-9]+','-','g'));
  v_slug := trim(both '-' from v_slug);
  if v_slug='' then raise exception 'A valid business name or slug is required'; end if;

  if exists(select 1 from public.tenants where slug=v_slug) then
    v_slug := v_slug || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,8);
  end if;

  v_trial_end := now() + interval '30 days';

  insert into public.tenants(name,slug,status,settings)
  values(trim(p_name),v_slug,'active','{}'::jsonb)
  returning id into v_tenant;

  insert into public.tenant_public_profiles(tenant_id,business_name)
  values(v_tenant,trim(p_name));

  insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at)
  values(v_tenant,v_user,'owner','active',now());

  insert into public.tenant_subscriptions(
    tenant_id,plan_id,status,started_at,trial_end,current_period_start,current_period_end,metadata
  )
  values(
    v_tenant,v_plan,'trialing',now(),v_trial_end,now(),v_trial_end,
    jsonb_build_object('source','subscriber_signup')
  );

  return v_tenant;
end;
$function$;