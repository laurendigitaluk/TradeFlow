create or replace function public.platform_public_catalogue_browse(
  p_query text default null, p_category_slug text default null,
  p_page integer default 1, p_page_size integer default 24
) returns jsonb
language plpgsql stable security definer
set search_path = public, pg_catalog
as $function$
declare
  v_query text := nullif(btrim(coalesce(p_query, '')), '');
  v_category text := nullif(btrim(coalesce(p_category_slug, '')), '');
  v_page integer := greatest(1, coalesce(p_page, 1));
  v_page_size integer := least(48, greatest(1, coalesce(p_page_size, 24)));
  v_total bigint := 0;
  v_categories jsonb := '[]'::jsonb;
  v_products jsonb := '[]'::jsonb;
begin
  select coalesce(jsonb_agg(jsonb_build_object('slug',c.slug,'name',c.name,'product_count',x.product_count) order by c.sort_order,c.name),'[]'::jsonb)
  into v_categories from public.catalogue_master_categories c
  join lateral (select count(*)::bigint as product_count from public.catalogue_master_products p where p.category_id=c.id and p.active=true and p.customer_visible=true) x on x.product_count>0
  where c.active=true;
  select count(*)::bigint into v_total from public.catalogue_master_products p
  join public.catalogue_master_categories c on c.id=p.category_id and c.active=true
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id and m.active=true
  where p.active=true and p.customer_visible=true
  and (v_category is null or c.slug=v_category)
  and (v_query is null or concat_ws(' ',m.name,p.model,p.package_name,p.product_type,p.catalogue_category) ilike '%'||v_query||'%');
  select coalesce(jsonb_agg(jsonb_build_object('category',c.name,'category_slug',c.slug,'manufacturer',m.name,'model',p.model,'package',p.package_name,'product_type',p.product_type,'branch',b.name) order by c.sort_order,m.name,p.model,p.package_name),'[]'::jsonb)
  into v_products from (
    select p.* from public.catalogue_master_products p
    join public.catalogue_master_categories c on c.id=p.category_id and c.active=true
    join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id and m.active=true
    where p.active=true and p.customer_visible=true
    and (v_category is null or c.slug=v_category)
    and (v_query is null or concat_ws(' ',m.name,p.model,p.package_name,p.product_type,p.catalogue_category) ilike '%'||v_query||'%')
    order by p.category_id,p.manufacturer_id,p.model,p.package_name
    limit v_page_size offset (v_page-1)*v_page_size
  ) p join public.catalogue_master_categories c on c.id=p.category_id
  join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
  left join public.catalogue_master_branches b on b.id=p.branch_id;
  return jsonb_build_object('categories',v_categories,'products',v_products,'total',v_total,'page',v_page,'page_size',v_page_size,'total_pages',case when v_total=0 then 0 else ceil(v_total::numeric/v_page_size)::integer end);
end;
$function$;
revoke all on function public.platform_public_catalogue_browse(text,text,integer,integer) from public;
grant execute on function public.platform_public_catalogue_browse(text,text,integer,integer) to anon,authenticated;
comment on function public.platform_public_catalogue_browse(text,text,integer,integer) is
'Public read-only catalogue browser. Exposes only active customer_visible product names and category/manufacturer/branch labels with pagination. Never returns evidence, identifiers, tenant data, prices, buying rules or internal notes.';
