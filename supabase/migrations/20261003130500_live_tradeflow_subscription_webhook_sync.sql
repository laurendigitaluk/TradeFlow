create or replace function public.subscriber_sync_subscription(p_subscription_id text,p_status text,p_customer_id text,p_price_id text,p_trial_end timestamptz,p_current_period_start timestamptz,p_current_period_end timestamptz,p_cancel_at_period_end boolean default false,p_provider_metadata jsonb default '{}'::jsonb) returns boolean language plpgsql security definer set search_path to 'pg_catalog','public'
as $function$
declare v_id uuid;
begin
if auth.role() <> 'service_role' then raise exception 'Not authorised'; end if;
if nullif(trim(p_subscription_id),'') is null then raise exception 'Subscription ID is required'; end if;
update public.tenant_subscriptions set status=case when p_status='canceled' then 'cancelled' when p_status='active' then 'active' when p_status='trialing' then 'trialing' when p_status='past_due' then 'past_due' when p_status='unpaid' then 'unpaid' when p_status='paused' then 'paused' else p_status end,billing_provider='stripe',provider_customer_id=coalesce(p_customer_id,provider_customer_id),provider_subscription_id=p_subscription_id,provider_price_id=coalesce(p_price_id,provider_price_id),billing_interval='month',provider_status=p_status,trial_end=coalesce(p_trial_end,trial_end),current_period_start=coalesce(p_current_period_start,current_period_start),current_period_end=coalesce(p_current_period_end,current_period_end),cancel_at_period_end=coalesce(p_cancel_at_period_end,cancel_at_period_end),ended_at=case when p_status='canceled' then coalesce(ended_at,now()) else ended_at end,provider_metadata=coalesce(p_provider_metadata,provider_metadata),updated_at=now()
where provider_subscription_id=p_subscription_id returning id into v_id;
return v_id is not null;
end $function$;
revoke all on function public.subscriber_sync_subscription(text,text,text,text,timestamptz,timestamptz,timestamptz,boolean,jsonb) from public,anon,authenticated;
grant execute on function public.subscriber_sync_subscription(text,text,text,text,timestamptz,timestamptz,timestamptz,boolean,jsonb) to service_role;