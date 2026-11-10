-- Repair LIVE Cloud AI catalogue picker matching for full manufacturer + model searches.
-- Applied directly to TradeFlow LIVE on 2026-11-10; this migration records the exact source-controlled definition.
create or replace function public.platform_owner_search_cloud_ai_catalogue(
 p_search text,
 p_category_slug text default null,
 p_limit integer default 50
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
 v_rows jsonb;
begin
 if not public.platform_cloud_ai_owner_check() then
  raise exception 'Platform owner access required';
 end if;
 if length(trim(coalesce(p_search,''))) < 2 then
  raise exception 'Enter at least two characters to search the master catalogue';
 end if;
 select coalesce(jsonb_agg(to_jsonb(x) order by x.manufacturer_name,x.model,x.package_name),'[]'::jsonb)
 into v_rows
 from (
  select p.id product_id, c.slug category_slug, coalesce(nullif(trim(p.catalogue_category),''),c.name) category_name,
         m.name manufacturer_name, p.model, p.package_name
  from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  where p.active
    and (nullif(trim(coalesce(p_category_slug,'')),'') is null or c.slug=p_category_slug)
    and (
      lower(m.name) like '%'||lower(trim(p_search))||'%'
      or lower(p.model) like '%'||lower(trim(p_search))||'%'
      or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%'
      or lower(concat_ws(' ',m.name,p.model,p.package_name)) like '%'||lower(trim(p_search))||'%'
    )
  order by m.name,p.model,p.package_name
  limit least(greatest(coalesce(p_limit,50),1),100)
 ) x;
 return jsonb_build_object('products',v_rows);
end;
$function$;
revoke all on function public.platform_owner_search_cloud_ai_catalogue(text,text,integer) from public, anon;
grant execute on function public.platform_owner_search_cloud_ai_catalogue(text,text,integer) to authenticated;
