insert into public.plans(code,name,description,active,sort_order,website_visible,monthly_price,annual_price,currency)
values('enhanced','TradeFlow','The complete TradeFlow Buy & Sell workspace. One month free trial, then £59.99 per month.',true,0,true,59.99,null,'GBP')
on conflict (code) do update set
  name=excluded.name,description=excluded.description,active=true,sort_order=0,website_visible=true,
  monthly_price=59.99,annual_price=null,currency='GBP',updated_at=now();

create or replace function public.provision_subscriber_business_from_stripe(
  p_user_id uuid,p_name text,p_slug text,p_plan_code text,p_provider_customer_id text,
  p_provider_subscription_id text,p_provider_price_id text,p_provider_status text,
  p_trial_end timestamptz,p_period_start timestamptz,p_period_end timestamptz,p_metadata jsonb default '{}'::jsonb
) returns uuid language plpgsql security definer set search_path to 'pg_catalog','public' as $function$
declare v_plan public.plans; v_tenant uuid; v_slug text; v_existing uuid;
begin
  if coalesce(auth.role(),'') <> 'service_role' then raise exception 'Service role required'; end if;
  if p_user_id is null then raise exception 'User is required'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Business name is required'; end if;
  if p_plan_code <> 'enhanced' then raise exception 'The TradeFlow subscription plan is required'; end if;
  select id into v_existing from public.tenant_memberships where user_id=p_user_id and role_code='owner' and status='active' order by joined_at desc nulls last limit 1;
  if v_existing is not null then return (select tenant_id from public.tenant_memberships where id=v_existing); end if;
  select * into v_plan from public.plans where code='enhanced' and active=true limit 1;
  if v_plan.id is null then raise exception 'TradeFlow plan is not available'; end if;
  v_slug := lower(regexp_replace(trim(coalesce(p_slug,p_name)),'[^a-zA-Z0-9]+','-','g'));
  v_slug := trim(both '-' from v_slug);
  if v_slug='' then raise exception 'A valid business name or slug is required'; end if;
  if exists(select 1 from public.tenants where slug=v_slug) then v_slug := v_slug || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,8); end if;
  insert into public.tenants(name,slug,status,settings) values(trim(p_name),v_slug,case when p_provider_status in ('trialing','active') then 'active' else 'pending' end,'{}'::jsonb) returning id into v_tenant;
  insert into public.tenant_public_profiles(tenant_id,business_name) values(v_tenant,trim(p_name));
  insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at) values(v_tenant,p_user_id,'owner',case when p_provider_status in ('trialing','active') then 'active' else 'inactive' end,now());
  insert into public.tenant_subscriptions(tenant_id,plan_id,status,billing_provider,provider_customer_id,provider_subscription_id,provider_price_id,billing_interval,provider_status,current_period_start,current_period_end,trial_end,started_at,metadata,provider_metadata)
  values(v_tenant,v_plan.id,case when p_provider_status in ('trialing','active') then p_provider_status else 'incomplete' end,'stripe',p_provider_customer_id,p_provider_subscription_id,p_provider_price_id,'month',p_provider_status,p_period_start,p_period_end,p_trial_end,now(),coalesce(p_metadata,'{}'::jsonb),jsonb_build_object('stripe_subscription_id',p_provider_subscription_id));
  return v_tenant;
end;
$function$;

revoke all on function public.provision_subscriber_business_from_stripe(uuid,text,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb) from public,anon,authenticated;
grant execute on function public.provision_subscriber_business_from_stripe(uuid,text,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb) to service_role;
