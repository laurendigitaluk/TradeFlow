-- Align TEST public plan RPC shape and commercial display price with LIVE.
-- Stripe product/price IDs intentionally remain TEST-only configuration and are not copied.
UPDATE public.plans
SET annual_price = 499.99,
    updated_at = now()
WHERE code = 'enhanced'
  AND currency = 'GBP'
  AND monthly_price = 59.99
  AND trial_days = 30
  AND annual_price IS NULL;

DO $check$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.plans
    WHERE code = 'enhanced'
      AND currency = 'GBP'
      AND monthly_price = 59.99
      AND annual_price = 499.99
      AND trial_days = 30
      AND active = true
      AND website_visible = true
  ) THEN
    RAISE EXCEPTION 'TEST enhanced plan did not match the expected commercial configuration';
  END IF;
END
$check$;

-- TEST's public RPC was missing trial_days compared with LIVE. No dependent database objects were found.
DROP FUNCTION public.public_get_available_plans();

CREATE FUNCTION public.public_get_available_plans()
RETURNS TABLE(
  id uuid,
  code text,
  name text,
  description text,
  monthly_price numeric,
  annual_price numeric,
  currency text,
  sort_order integer,
  trial_days integer
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT p.id,p.code,p.name,p.description,p.monthly_price,p.annual_price,
         p.currency,p.sort_order,p.trial_days
  FROM public.plans p
  WHERE p.active=true AND p.website_visible=true
  ORDER BY p.sort_order,p.name;
$function$;

REVOKE ALL ON FUNCTION public.public_get_available_plans() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.public_get_available_plans() TO anon, authenticated, service_role;
