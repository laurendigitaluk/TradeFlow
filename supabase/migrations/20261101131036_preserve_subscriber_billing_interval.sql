CREATE OR REPLACE FUNCTION public.subscriber_finalize_signup(p_user_id uuid,p_business_name text,p_plan_code text,p_customer_id text,p_subscription_id text,p_price_id text,p_subscription_status text,p_trial_end timestamptz,p_current_period_start timestamptz,p_current_period_end timestamptz,p_metadata jsonb DEFAULT '{}'::jsonb)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public' AS $$
DECLARE v_plan uuid; v_interval text; v_existing uuid; v_existing_subscription uuid; v_tenant uuid;
BEGIN
 IF auth.role()<>'service_role' THEN RAISE EXCEPTION 'Not authorised'; END IF;
 IF p_user_id IS NULL OR nullif(trim(p_business_name),'') IS NULL OR p_plan_code<>'enhanced' OR nullif(trim(p_subscription_id),'') IS NULL THEN RAISE EXCEPTION 'Invalid subscriber signup details'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::text,0));
 SELECT id,CASE WHEN p_price_id=stripe_annual_price_id THEN 'year' WHEN p_price_id=stripe_monthly_price_id THEN 'month' ELSE NULL END
 INTO v_plan,v_interval FROM public.plans WHERE code='enhanced' AND active=true LIMIT 1;
 IF v_plan IS NULL OR v_interval IS NULL THEN RAISE EXCEPTION 'TradeFlow plan or Stripe price is not configured'; END IF;
 SELECT tenant_id INTO v_existing FROM public.tenant_memberships WHERE user_id=p_user_id AND status='active' ORDER BY joined_at LIMIT 1;
 IF v_existing IS NOT NULL THEN
  SELECT id INTO v_existing_subscription FROM public.tenant_subscriptions WHERE tenant_id=v_existing AND plan_id=v_plan AND billing_provider='stripe' AND provider_subscription_id=p_subscription_id LIMIT 1;
  IF v_existing_subscription IS NOT NULL THEN RETURN v_existing; END IF;
  RAISE EXCEPTION 'Subscriber already has an active TradeFlow business; refusing to replace its existing subscription.';
 END IF;
 INSERT INTO public.tenants(name,slug,status,settings) VALUES(trim(p_business_name),trim(both '-' from lower(regexp_replace(trim(p_business_name),'[^a-zA-Z0-9]+','-','g')))||'-'||substr(replace(gen_random_uuid()::text,'-',''),1,8),'active','{}'::jsonb) RETURNING id INTO v_tenant;
 INSERT INTO public.tenant_public_profiles(tenant_id,business_name) VALUES(v_tenant,trim(p_business_name));
 INSERT INTO public.tenant_memberships(tenant_id,user_id,role_code,status,joined_at) VALUES(v_tenant,p_user_id,'owner','active',now());
 INSERT INTO public.tenant_subscriptions(tenant_id,plan_id,status,billing_provider,provider_customer_id,provider_subscription_id,provider_price_id,billing_interval,provider_status,trial_end,started_at,current_period_start,current_period_end,metadata,provider_metadata)
 VALUES(v_tenant,v_plan,coalesce(nullif(p_subscription_status,''),'trialing'),'stripe',p_customer_id,p_subscription_id,p_price_id,v_interval,p_subscription_status,p_trial_end,now(),p_current_period_start,p_current_period_end,coalesce(p_metadata,'{}'::jsonb),coalesce(p_metadata,'{}'::jsonb));
 RETURN v_tenant;
END $$;

CREATE OR REPLACE FUNCTION public.subscriber_sync_subscription(p_subscription_id text,p_status text,p_customer_id text,p_price_id text,p_trial_end timestamptz,p_current_period_start timestamptz,p_current_period_end timestamptz,p_cancel_at_period_end boolean DEFAULT false,p_provider_metadata jsonb DEFAULT '{}'::jsonb)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','public' AS $$
DECLARE v_id uuid;
BEGIN
 IF auth.role()<>'service_role' THEN RAISE EXCEPTION 'Not authorised'; END IF;
 IF nullif(trim(p_subscription_id),'') IS NULL THEN RAISE EXCEPTION 'Subscription ID is required'; END IF;
 UPDATE public.tenant_subscriptions ts SET
  status=CASE WHEN p_status='canceled' THEN 'cancelled' WHEN p_status IN ('active','trialing','past_due','unpaid','paused') THEN p_status ELSE p_status END,
  billing_provider='stripe',provider_customer_id=coalesce(p_customer_id,ts.provider_customer_id),
  provider_subscription_id=p_subscription_id,provider_price_id=coalesce(p_price_id,ts.provider_price_id),
  billing_interval=CASE WHEN p_price_id IS NULL THEN ts.billing_interval
   WHEN EXISTS(SELECT 1 FROM public.plans p WHERE p.id=ts.plan_id AND p.stripe_annual_price_id=p_price_id) THEN 'year'
   WHEN EXISTS(SELECT 1 FROM public.plans p WHERE p.id=ts.plan_id AND p.stripe_monthly_price_id=p_price_id) THEN 'month'
   ELSE ts.billing_interval END,
  provider_status=p_status,trial_end=coalesce(p_trial_end,ts.trial_end),
  current_period_start=coalesce(p_current_period_start,ts.current_period_start),current_period_end=coalesce(p_current_period_end,ts.current_period_end),
  cancel_at_period_end=coalesce(p_cancel_at_period_end,ts.cancel_at_period_end),
  ended_at=CASE WHEN p_status='canceled' THEN coalesce(ts.ended_at,now()) ELSE ts.ended_at END,
  provider_metadata=coalesce(p_provider_metadata,ts.provider_metadata),updated_at=now()
 WHERE ts.provider_subscription_id=p_subscription_id RETURNING ts.id INTO v_id;
 RETURN v_id IS NOT NULL;
END $$;