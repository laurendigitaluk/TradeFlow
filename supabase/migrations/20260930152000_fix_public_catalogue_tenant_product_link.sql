-- Fix public customer valuation product linkage.
-- The public catalogue must return the subscriber's tenant_buying_products.id,
-- because customer_submit_buying_request validates buying_product_id against
-- that tenant-scoped table and automatic research/rules are keyed to the same id.

CREATE OR REPLACE FUNCTION public.get_public_buying_catalogue(p_tenant_id uuid)
 RETURNS TABLE(product_id uuid, category_id uuid, category_name text, category_slug text, category_description text, branch_name text, manufacturer text, model text, package_name text, product_type text, catalogue_category text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
select
  bp.id,
  s.category_id,
  c.name,
  c.slug,
  c.description,
  cb.name,
  bp.manufacturer,
  bp.model,
  bp.package_name,
  mp.product_type,
  mp.catalogue_category
from public.tenant_catalogue_selections s
join public.tenants t
  on t.id=s.tenant_id
 and t.status='active'
join public.categories c
  on c.id=s.category_id
 and c.tenant_id=s.tenant_id
 and c.active
 and c.buying_enabled
left join public.category_branches cb
  on cb.id=s.branch_id
 and cb.tenant_id=s.tenant_id
left join public.catalogue_master_products mp
  on mp.id=s.master_product_id
 and mp.active
 and mp.customer_visible
join public.tenant_buying_products bp
  on bp.tenant_id=s.tenant_id
 and bp.category_id=s.category_id
 and bp.branch_id=s.branch_id
 and bp.active=true
 and lower(bp.manufacturer)=lower(coalesce(nullif(s.manufacturer,''),(select cm.name from public.catalogue_master_manufacturers cm where cm.id=mp.manufacturer_id)))
 and lower(bp.model)=lower(coalesce(nullif(s.model,''),mp.model))
 and lower(coalesce(bp.package_name,''))=lower(coalesce(nullif(s.package_name,''),mp.package_name,''))
where s.tenant_id=p_tenant_id
  and s.active
  and s.buying_enabled
  and s.website_visible
order by
  c.sort_order nulls last,
  c.name,
  bp.manufacturer,
  bp.model,
  bp.package_name;
$function$;
