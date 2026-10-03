drop function if exists public.public_get_available_plans();
create or replace function public.public_get_available_plans()
returns table(id uuid,code text,name text,description text,monthly_price numeric,annual_price numeric,currency text,sort_order integer,trial_days integer)
language sql security definer set search_path to ''
as $function$
select p.id,p.code,p.name,p.description,p.monthly_price,p.annual_price,p.currency,p.sort_order,p.trial_days from public.plans p where p.active=true and p.website_visible=true order by p.sort_order,p.name;
$function$;
grant execute on function public.public_get_available_plans() to anon,authenticated;