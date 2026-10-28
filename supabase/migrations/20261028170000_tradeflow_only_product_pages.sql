-- TradeFlow-only product page boundary.
-- Keep legacy rows for history, but hide them and prevent the TradeFlow owner API
-- from returning or reactivating non-TradeFlow product pages.

update public.platform_product_pages
set status = 'hidden',
    updated_at = now()
where slug in ('businessflow', 'studioflow')
  and status <> 'hidden';

create or replace function public.platform_owner_get_product_pages()
returns setof public.platform_product_pages
language plpgsql
security definer
set search_path to 'public', 'auth'
as $function$
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Active platform owner access required';
  end if;

  return query
  select *
  from public.platform_product_pages
  where slug = 'tradeflow'
  order by slug;
end;
$function$;

create or replace function public.platform_owner_update_product_page(
  p_slug text,
  p_product_name text,
  p_status text,
  p_headline text,
  p_tagline text,
  p_description text,
  p_button_label text,
  p_button_url text
)
returns public.platform_product_pages
language plpgsql
security definer
set search_path to 'public', 'auth'
as $function$
declare
  result_row public.platform_product_pages;
begin
  if auth.uid() is null or not exists (
    select 1 from public.platform_memberships pm
    where pm.user_id = auth.uid() and pm.status = 'active'
  ) then
    raise exception 'Active platform owner access required';
  end if;

  if p_slug <> 'tradeflow' then
    raise exception 'Only the TradeFlow product page is managed by this application';
  end if;

  if p_status not in ('published', 'coming_soon', 'hidden') then
    raise exception 'Invalid product status';
  end if;

  if length(trim(coalesce(p_product_name,''))) not between 1 and 80
     or length(trim(coalesce(p_headline,''))) not between 1 and 180
     or length(coalesce(p_tagline,'')) > 300
     or length(coalesce(p_description,'')) > 2000
     or length(coalesce(p_button_label,'')) > 80
     or length(coalesce(p_button_url,'')) > 500 then
    raise exception 'One or more fields exceed the allowed length or are empty';
  end if;

  update public.platform_product_pages
  set product_name = trim(p_product_name),
      status = p_status,
      headline = trim(p_headline),
      tagline = coalesce(p_tagline,''),
      description = coalesce(p_description,''),
      button_label = coalesce(p_button_label,''),
      button_url = coalesce(p_button_url,''),
      updated_at = now(),
      updated_by = auth.uid()
  where slug = 'tradeflow'
  returning * into result_row;

  if not found then
    raise exception 'TradeFlow product page not found';
  end if;

  return result_row;
end;
$function$;
