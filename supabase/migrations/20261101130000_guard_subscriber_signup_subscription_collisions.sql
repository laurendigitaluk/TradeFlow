-- Prevent duplicate subscriber signup sessions from replacing an existing tenant subscription.
-- This migration is code-only until deliberately applied to the current TEST project and verified.

CREATE OR REPLACE FUNCTION public.subscriber_finalize_signup(
  p_user_id uuid,
  p_business_name text,
  p_plan_code text,
  p_customer_id text,
  p_subscription_id text,
  p_price_id text,
  p_subscription_status text,
  p_trial_end timestamp with time zone,
  p_current_period_start timestamp with time zone,
  p_current_period_end timestamp with time zone,
  p_metadata jsonb DEFAULT '{}'::jsonb
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_plan uuid;
  v_existing uuid;
  v_existing_subscription uuid;
  v_tenant uuid;
BEGIN
  IF auth.role() <> 'service_role' THEN
    RAISE EXCEPTION 'Not authorised';
  END IF;

  IF p_user_id IS NULL THEN
    RAISE EXCEPTION 'Subscriber user is required';
  END IF;
  IF nullif(trim(p_business_name), '') IS NULL THEN
    RAISE EXCEPTION 'Business name is required';
  END IF;
  IF p_plan_code <> 'enhanced' THEN
    RAISE EXCEPTION 'The TradeFlow subscription plan is required';
  END IF;
  IF nullif(trim(p_subscription_id), '') IS NULL THEN
    RAISE EXCEPTION 'Stripe subscription ID is required';
  END IF;

  -- Serialise finalisation per Auth user so concurrent webhook deliveries
  -- cannot create two active TradeFlow tenants for the same user.
  PERFORM pg_advisory_xact_lock(hashtextextended(p_user_id::text, 0));

  SELECT id
    INTO v_plan
    FROM public.plans
   WHERE code = 'enhanced'
     AND active = true
   LIMIT 1;

  IF v_plan IS NULL THEN
    RAISE EXCEPTION 'TradeFlow plan is not available';
  END IF;

  SELECT tm.tenant_id
    INTO v_existing
    FROM public.tenant_memberships tm
   WHERE tm.user_id = p_user_id
     AND tm.status = 'active'
   ORDER BY tm.joined_at
   LIMIT 1;

  IF v_existing IS NOT NULL THEN
    -- A retried webhook for the exact same Stripe subscription is safe:
    -- return the already-provisioned tenant without mutating its subscription.
    SELECT ts.id
      INTO v_existing_subscription
      FROM public.tenant_subscriptions ts
     WHERE ts.tenant_id = v_existing
       AND ts.plan_id = v_plan
       AND ts.billing_provider = 'stripe'
       AND ts.provider_subscription_id = p_subscription_id
     LIMIT 1;

    IF v_existing_subscription IS NOT NULL THEN
      RETURN v_existing;
    END IF;

    -- Never replace a complimentary, manual, or different paid subscription.
    RAISE EXCEPTION 'Subscriber already has an active TradeFlow business; refusing to replace its existing subscription.';
  END IF;

  INSERT INTO public.tenants(name, slug, status, settings)
  VALUES (
    trim(p_business_name),
    trim(both '-' from lower(regexp_replace(trim(p_business_name), '[^a-zA-Z0-9]+', '-', 'g')))
      || '-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
    'active',
    '{}'::jsonb
  )
  RETURNING id INTO v_tenant;

  INSERT INTO public.tenant_public_profiles(tenant_id, business_name)
  VALUES (v_tenant, trim(p_business_name));

  INSERT INTO public.tenant_memberships(tenant_id, user_id, role_code, status, joined_at)
  VALUES (v_tenant, p_user_id, 'owner', 'active', now());

  INSERT INTO public.tenant_subscriptions(
    tenant_id,
    plan_id,
    status,
    billing_provider,
    provider_customer_id,
    provider_subscription_id,
    provider_price_id,
    billing_interval,
    provider_status,
    trial_end,
    started_at,
    current_period_start,
    current_period_end,
    metadata,
    provider_metadata
  )
  VALUES (
    v_tenant,
    v_plan,
    coalesce(nullif(p_subscription_status, ''), 'trialing'),
    'stripe',
    p_customer_id,
    p_subscription_id,
    p_price_id,
    'month',
    p_subscription_status,
    p_trial_end,
    now(),
    p_current_period_start,
    p_current_period_end,
    coalesce(p_metadata, '{}'::jsonb),
    coalesce(p_metadata, '{}'::jsonb)
  );

  RETURN v_tenant;
END
$function$;
