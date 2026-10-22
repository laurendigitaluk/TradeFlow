-- Resolve a tenant package to one canonical master product.
-- Exact package labels and explicitly curated aliases are supported; ambiguous matches fail closed.
CREATE OR REPLACE FUNCTION public.resolve_master_product_for_tenant_package(
  p_manufacturer text,
  p_model text,
  p_package_name text
)
RETURNS uuid
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
  v_master_product_id uuid;
  v_match_count integer;
BEGIN
  WITH candidate_products AS (
    SELECT mp.id
    FROM public.catalogue_master_products mp
    JOIN public.catalogue_master_manufacturers mm ON mm.id = mp.manufacturer_id
    WHERE mp.active = true
      AND lower(trim(mm.name)) = lower(trim(coalesce(p_manufacturer, '')))
      AND lower(trim(mp.model)) = lower(trim(coalesce(p_model, '')))
      AND lower(trim(coalesce(mp.package_name, ''))) = lower(trim(coalesce(p_package_name, '')))
    UNION
    SELECT mp.id
    FROM public.catalogue_master_products mp
    JOIN public.catalogue_master_manufacturers mm ON mm.id = mp.manufacturer_id
    JOIN public.catalogue_master_product_package_aliases pa ON pa.master_product_id = mp.id AND pa.is_active = true
    WHERE mp.active = true
      AND lower(trim(mm.name)) = lower(trim(coalesce(p_manufacturer, '')))
      AND lower(trim(mp.model)) = lower(trim(coalesce(p_model, '')))
      AND pa.alias_key = lower(regexp_replace(trim(coalesce(p_package_name, '')), '[^a-zA-Z0-9]+', '-', 'g'))
  )
  SELECT count(*), min(id::text)::uuid
    INTO v_match_count, v_master_product_id
  FROM candidate_products;

  IF v_match_count <> 1 THEN
    RETURN NULL;
  END IF;

  RETURN v_master_product_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.resolve_master_product_for_tenant_package(text, text, text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.resolve_master_product_for_tenant_package(text, text, text) TO service_role;
