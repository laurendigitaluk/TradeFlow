alter table public.plans add column if not exists trial_days integer not null default 30;
alter table public.plans drop constraint if exists plans_trial_days_check;
alter table public.plans add constraint plans_trial_days_check check (trial_days between 0 and 3650);
drop function if exists public.platform_owner_update_plan(uuid,text,text,boolean,numeric,numeric,text,text,text,text);
create or replace function public.platform_owner_update_plan(p_plan_id uuid,p_name text,p_description text,p_website_visible boolean,p_monthly_price numeric,p_annual_price numeric,p_currency text,p_trial_days integer,p_stripe_product_id text,p_stripe_monthly_price_id text,p_stripe_annual_price_id text) returns public.plans language plpgsql security definer set search_path to ''
as $function$
declare v_plan public.plans; v_currency text;
begin
if not private.is_platform_owner(auth.uid()) then raise exception 'Not authorised'; end if;
if p_plan_id is null then raise exception 'Plan is required'; end if;
if nullif(trim(p_name),'') is null then raise exception 'Plan name is required'; end if;
if p_monthly_price is not null and p_monthly_price < 0 then raise exception 'Monthly price cannot be negative'; end if;
if p_annual_price is not null and p_annual_price < 0 then raise exception 'Annual price cannot be negative'; end if;
if p_trial_days is null or p_trial_days < 0 or p_trial_days > 3650 then raise exception 'Trial must be between 0 and 3650 days'; end if;
v_currency := upper(nullif(trim(p_currency),''));
if v_currency is null then v_currency := 'GBP'; end if;
if v_currency !~ '^[A-Z]{3}$' then raise exception 'Currency must be a 3-letter code'; end if;
if nullif(trim(coalesce(p_stripe_product_id,'')),'') is not null and trim(p_stripe_product_id) !~ '^prod_[A-Za-z0-9]+$' then raise exception 'Stripe Product ID must start with prod_'; end if;
if nullif(trim(coalesce(p_stripe_monthly_price_id,'')),'') is not null and trim(p_stripe_monthly_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe monthly Price ID must start with price_'; end if;
if nullif(trim(coalesce(p_stripe_annual_price_id,'')),'') is not null and trim(p_stripe_annual_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe annual Price ID must start with price_'; end if;
update public.plans set name=trim(p_name),description=nullif(trim(coalesce(p_description,'')),''),website_visible=coalesce(p_website_visible,false),monthly_price=p_monthly_price,annual_price=p_annual_price,currency=v_currency,trial_days=p_trial_days,stripe_product_id=nullif(trim(coalesce(p_stripe_product_id,'')),''),stripe_monthly_price_id=nullif(trim(coalesce(p_stripe_monthly_price_id,'')),''),stripe_annual_price_id=nullif(trim(coalesce(p_stripe_annual_price_id,'')),''),updated_at=now()
where id=p_plan_id and code='enhanced' and active=true returning * into v_plan;
if v_plan.id is null then raise exception 'TradeFlow plan not found'; end if; return v_plan;
end $function$;
grant execute on function public.platform_owner_update_plan(uuid,text,text,boolean,numeric,numeric,text,integer,text,text,text) to authenticated;
insert into public.plans(code,name,description,active,sort_order,website_visible,monthly_price,annual_price,currency,trial_days)
select 'enhanced','TradeFlow','The complete TradeFlow workspace for running and growing a Buy & Sell business.',true,1,true,59.99,null,'GBP',30
where not exists(select 1 from public.plans where code='enhanced');
update public.plans set name='TradeFlow',description='The complete TradeFlow workspace for running and growing a Buy & Sell business.',active=true,website_visible=true,monthly_price=59.99,annual_price=null,currency='GBP',trial_days=30,updated_at=now() where code='enhanced';
create or replace function public.subscriber_finalize_signup(p_user_id uuid,p_business_name text,p_plan_code text,p_customer_id text,p_subscription_id text,p_price_id text,p_subscription_status text,p_trial_end timestamptz,p_current_period_start timestamptz,p_current_period_end timestamptz,p_metadata jsonb default '{}'::jsonb) returns uuid language plpgsql security definer set search_path to 'pg_catalog','public'
as $function$
declare v_plan uuid; v_existing uuid; v_tenant uuid;
begin
if auth.role() <> 'service_role' then raise exception 'Not authorised'; end if;
if p_user_id is null then raise exception 'Subscriber user is required'; end if;
if nullif(trim(p_business_name),'') is null then raise exception 'Business name is required'; end if;
if p_plan_code <> 'enhanced' then raise exception 'The TradeFlow subscription plan is required'; end if;
select id into v_plan from public.plans where code='enhanced' and active=true limit 1;
if v_plan is null then raise exception 'TradeFlow plan is not available'; end if;
select tm.tenant_id into v_existing from public.tenant_memberships tm where tm.user_id=p_user_id and tm.status='active' order by tm.joined_at limit 1;
if v_existing is not null then
update public.tenant_subscriptions set billing_provider='stripe',provider_customer_id=coalesce(p_customer_id,provider_customer_id),provider_subscription_id=coalesce(p_subscription_id,provider_subscription_id),provider_price_id=coalesce(p_price_id,provider_price_id),provider_status=coalesce(p_subscription_status,provider_status),status=coalesce(p_subscription_status,status),trial_end=coalesce(p_trial_end,trial_end),current_period_start=coalesce(p_current_period_start,current_period_start),current_period_end=coalesce(p_current_period_end,current_period_end),provider_metadata=coalesce(p_metadata,provider_metadata),updated_at=now() where tenant_id=v_existing and plan_id=v_plan;
return v_existing;
end if;
insert into public.tenants(name,slug,status,settings) values(trim(p_business_name),trim(both '-' from lower(regexp_replace(trim(p_business_name),'[^a-zA-Z0-9]+','-','g'))) || '-' || substr(replace(gen_random_uuid()::text,'-',''),1,8),'active','{}'::jsonb) returning id into v_tenant;
insert into public.tenant_public_profiles(tenant_id,business_name) values(v_tenant,trim(p_business_name));
insert into public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at) values(v_tenant,p_user_id,'owner','active',now());
insert into public.tenant_subscriptions(tenant_id,plan_id,status,billing_provider,provider_customer_id,provider_subscription_id,provider_price_id,billing_interval,provider_status,trial_end,started_at,current_period_start,current_period_end,metadata,provider_metadata)
values(v_tenant,v_plan,coalesce(nullif(p_subscription_status,''),'trialing'),'stripe',p_customer_id,p_subscription_id,p_price_id,'month',p_subscription_status,p_trial_end,now(),p_current_period_start,p_current_period_end,coalesce(p_metadata,'{}'::jsonb),coalesce(p_metadata,'{}'::jsonb));
return v_tenant;
end $function$;
revoke all on function public.subscriber_finalize_signup(uuid,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb) from public,anon,authenticated;
grant execute on function public.subscriber_finalize_signup(uuid,text,text,text,text,text,text,timestamptz,timestamptz,timestamptz,jsonb) to service_role;