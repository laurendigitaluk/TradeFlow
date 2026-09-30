-- Platform-owner commercial plan controls.
-- Separates operational plan activation from public commercial visibility,
-- stores display pricing and Stripe Product/Price references, and keeps all
-- mutations behind the platform-owner boundary.
alter table public.plans
  add column if not exists website_visible boolean not null default false,
  add column if not exists monthly_price numeric(12,2),
  add column if not exists annual_price numeric(12,2),
  add column if not exists currency text not null default 'GBP',
  add column if not exists stripe_product_id text,
  add column if not exists stripe_monthly_price_id text,
  add column if not exists stripe_annual_price_id text;

update public.plans
set website_visible = case when code in ('basic','enhanced') then true else false end
where code in ('basic','enhanced','catalogue');

create or replace function public.platform_owner_get_plans()
returns setof public.plans
language sql security definer set search_path=''
as $function$
  select p from public.plans p
  where private.is_platform_owner(auth.uid())
  order by p.sort_order,p.name;
$function$;

create or replace function public.platform_owner_update_plan(
  p_plan_id uuid,p_name text,p_description text,p_website_visible boolean,
  p_monthly_price numeric,p_annual_price numeric,p_currency text,
  p_stripe_product_id text,p_stripe_monthly_price_id text,p_stripe_annual_price_id text
)
returns public.plans
language plpgsql security definer set search_path=''
as $function$
declare v_plan public.plans; v_currency text;
begin
  if not private.is_platform_owner(auth.uid()) then raise exception 'Not authorised'; end if;
  if p_plan_id is null then raise exception 'Plan is required'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Plan name is required'; end if;
  if p_monthly_price is not null and p_monthly_price < 0 then raise exception 'Monthly price cannot be negative'; end if;
  if p_annual_price is not null and p_annual_price < 0 then raise exception 'Annual price cannot be negative'; end if;
  v_currency := upper(nullif(trim(p_currency),''));
  if v_currency is null then v_currency := 'GBP'; end if;
  if v_currency !~ '^[A-Z]{3}$' then raise exception 'Currency must be a 3-letter code'; end if;
  if nullif(trim(coalesce(p_stripe_product_id,'')),'') is not null and trim(p_stripe_product_id) !~ '^prod_[A-Za-z0-9]+$' then raise exception 'Stripe Product ID must start with prod_'; end if;
  if nullif(trim(coalesce(p_stripe_monthly_price_id,'')),'') is not null and trim(p_stripe_monthly_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe monthly Price ID must start with price_'; end if;
  if nullif(trim(coalesce(p_stripe_annual_price_id,'')),'') is not null and trim(p_stripe_annual_price_id) !~ '^price_[A-Za-z0-9]+$' then raise exception 'Stripe annual Price ID must start with price_'; end if;
  update public.plans
  set name=trim(p_name),description=nullif(trim(coalesce(p_description,'')),''),
      website_visible=coalesce(p_website_visible,false),monthly_price=p_monthly_price,
      annual_price=p_annual_price,currency=v_currency,
      stripe_product_id=nullif(trim(coalesce(p_stripe_product_id,'')),''),
      stripe_monthly_price_id=nullif(trim(coalesce(p_stripe_monthly_price_id,'')),''),
      stripe_annual_price_id=nullif(trim(coalesce(p_stripe_annual_price_id,'')),''),
      updated_at=now()
  where id=p_plan_id and code in ('basic','enhanced','catalogue') and active=true
  returning * into v_plan;
  if v_plan.id is null then raise exception 'Commercial plan not found'; end if;
  return v_plan;
end
$function$;

create or replace function public.public_get_available_plans()
returns table(id uuid,code text,name text,description text,monthly_price numeric,annual_price numeric,currency text,sort_order integer)
language sql security definer set search_path=''
as $function$
  select p.id,p.code,p.name,p.description,p.monthly_price,p.annual_price,p.currency,p.sort_order
  from public.plans p where p.active=true and p.website_visible=true order by p.sort_order,p.name;
$function$;

revoke all on function public.platform_owner_get_plans() from public,anon,authenticated;
revoke all on function public.platform_owner_update_plan(uuid,text,text,boolean,numeric,numeric,text,text,text,text) from public,anon,authenticated;
revoke all on function public.public_get_available_plans() from public,anon,authenticated;
grant execute on function public.platform_owner_get_plans() to authenticated;
grant execute on function public.platform_owner_update_plan(uuid,text,text,boolean,numeric,numeric,text,text,text,text) to authenticated;
grant execute on function public.public_get_available_plans() to anon,authenticated;
