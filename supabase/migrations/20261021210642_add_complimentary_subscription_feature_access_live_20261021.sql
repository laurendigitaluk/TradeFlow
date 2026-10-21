-- Allow explicitly active, non-ended complimentary subscriptions to receive plan features in LIVE.
-- Complimentary access still requires an active plan and enabled feature; this does not create or bill subscriptions.
CREATE OR REPLACE FUNCTION private.has_tenant_feature(p_tenant_id uuid, p_feature_code text)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $function$
  SELECT coalesce(p_tenant_id IS NOT NULL AND nullif(trim(p_feature_code), '') IS NOT NULL, false)
     AND EXISTS (
       SELECT 1
       FROM public.tenant_subscriptions ts
       JOIN public.plans pl
         ON pl.id = ts.plan_id
        AND pl.active = true
       JOIN public.plan_features pf
         ON pf.plan_id = pl.id
        AND pf.enabled = true
        AND pf.feature_code = p_feature_code
       WHERE ts.tenant_id = p_tenant_id
         AND (
           (ts.status = 'trialing' AND ts.trial_end IS NOT NULL AND ts.trial_end > now())
           OR
           (ts.status IN ('active','past_due') AND ts.current_period_end IS NOT NULL AND ts.current_period_end > now())
           OR
           (ts.status = 'active' AND ts.billing_provider = 'manual' AND ts.provider_status = 'complimentary')
         )
         AND (ts.ended_at IS NULL OR ts.ended_at > now())
     );
$function$;
