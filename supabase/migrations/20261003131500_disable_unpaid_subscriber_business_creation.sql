create or replace function public.subscriber_create_business(p_name text,p_slug text,p_plan_code text) returns uuid language plpgsql security definer set search_path to 'pg_catalog','public'
as $function$
begin raise exception 'TradeFlow subscription checkout is required before a subscriber business can be created'; end
$function$;