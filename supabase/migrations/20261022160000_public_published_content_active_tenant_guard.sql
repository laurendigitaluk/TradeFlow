-- Ensure public website and listing endpoints stop serving content when a tenant is inactive.
-- The private helper is deliberately not exposed through PostgREST; EXECUTE is granted only
-- so RLS policies can evaluate the active-tenant predicate for anonymous public reads.

GRANT EXECUTE ON FUNCTION private.is_active_tenant(uuid) TO anon;

DROP POLICY IF EXISTS tenant_public_profiles_public_read ON public.tenant_public_profiles;
CREATE POLICY tenant_public_profiles_public_read
  ON public.tenant_public_profiles
  FOR SELECT
  TO anon, authenticated
  USING ((SELECT private.is_active_tenant(tenant_id)));

DROP POLICY IF EXISTS published_site_index_public_select ON public.published_site_index;
CREATE POLICY published_site_index_public_select
  ON public.published_site_index
  FOR SELECT
  TO anon, authenticated
  USING ((SELECT private.is_active_tenant(tenant_id)));

CREATE OR REPLACE FUNCTION public.get_published_site_preview(p_tenant_id uuid)
RETURNS TABLE(tenant_id uuid, revision_number integer, content jsonb, published_at timestamptz)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT sr.tenant_id, sr.revision_number, sr.content, sr.published_at
  FROM public.site_revisions sr
  JOIN public.tenant_site_state ts
    ON ts.published_revision_id = sr.id
   AND ts.tenant_id = sr.tenant_id
  JOIN public.tenants t
    ON t.id = sr.tenant_id
   AND t.status = 'active'
  WHERE sr.tenant_id = p_tenant_id
    AND sr.status = 'published'
  LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_published_sites()
RETURNS TABLE(tenant_id uuid, revision_number integer, content jsonb, published_at timestamptz)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT ts.tenant_id, sr.revision_number, sr.content, sr.published_at
  FROM public.tenant_site_state ts
  JOIN public.site_revisions sr
    ON sr.id = ts.published_revision_id
   AND sr.tenant_id = ts.tenant_id
   AND sr.status = 'published'
  JOIN public.tenants t
    ON t.id = ts.tenant_id
   AND t.status = 'active';
$function$;

CREATE OR REPLACE FUNCTION public.get_published_store_listing_media(p_tenant_id uuid)
RETURNS TABLE(listing_id uuid, storage_bucket text, storage_path text, original_filename text, sort_order integer)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT lm.listing_id, ma.storage_bucket, ma.storage_path, ma.original_filename, lm.sort_order
  FROM public.listing_media lm
  JOIN public.listings l
    ON l.id = lm.listing_id
   AND l.tenant_id = lm.tenant_id
   AND l.status = 'published'
  JOIN public.tenants t
    ON t.id = l.tenant_id
   AND t.status = 'active'
  JOIN public.media_assets ma
    ON ma.id = lm.media_asset_id
   AND ma.tenant_id = lm.tenant_id
  JOIN public.categories c
    ON c.id = l.category_id
   AND c.tenant_id = l.tenant_id
   AND c.active = true
   AND c.selling_enabled = true
  JOIN public.sales_channels sc
    ON sc.id = l.channel_id
   AND sc.tenant_id = l.tenant_id
   AND sc.active = true
  JOIN public.tenant_site_state ts
    ON ts.tenant_id = l.tenant_id
  JOIN public.site_revisions sr
    ON sr.id = ts.published_revision_id
   AND sr.tenant_id = l.tenant_id
   AND sr.status = 'published'
  WHERE l.tenant_id = p_tenant_id
  ORDER BY lm.listing_id, lm.sort_order, ma.created_at;
$function$;

CREATE OR REPLACE FUNCTION public.get_published_store_listings(p_tenant_id uuid)
RETURNS TABLE(listing_id uuid, listing_reference text, title text, description text, asking_price numeric, currency text, quantity integer, category_name text, listing_data jsonb)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT l.id, l.listing_reference, l.title, l.description, l.asking_price,
         l.currency, l.quantity, c.name, l.listing_data
  FROM public.listings l
  JOIN public.tenants t
    ON t.id = l.tenant_id
   AND t.status = 'active'
  JOIN public.categories c
    ON c.id = l.category_id
   AND c.tenant_id = l.tenant_id
  JOIN public.sales_channels sc
    ON sc.id = l.channel_id
   AND sc.tenant_id = l.tenant_id
  JOIN public.tenant_site_state ts
    ON ts.tenant_id = l.tenant_id
  JOIN public.site_revisions sr
    ON sr.id = ts.published_revision_id
   AND sr.tenant_id = l.tenant_id
   AND sr.status = 'published'
  WHERE l.tenant_id = p_tenant_id
    AND l.status = 'published'
    AND c.active = true
    AND c.selling_enabled = true
    AND sc.active = true
  ORDER BY l.created_at DESC;
$function$;

CREATE OR REPLACE FUNCTION public.is_published_tradeflow_media(p_bucket_id text, p_name text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path TO ''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.media_assets ma
    JOIN public.listing_media lm
      ON lm.media_asset_id = ma.id
     AND lm.tenant_id = ma.tenant_id
    JOIN public.listings l
      ON l.id = lm.listing_id
     AND l.tenant_id = lm.tenant_id
     AND l.status = 'published'
    JOIN public.tenants t
      ON t.id = l.tenant_id
     AND t.status = 'active'
    JOIN public.categories c
      ON c.id = l.category_id
     AND c.tenant_id = l.tenant_id
     AND c.active = true
     AND c.selling_enabled = true
    JOIN public.sales_channels sc
      ON sc.id = l.channel_id
     AND sc.tenant_id = l.tenant_id
     AND sc.active = true
    JOIN public.tenant_site_state ts
      ON ts.tenant_id = l.tenant_id
    JOIN public.site_revisions sr
      ON sr.id = ts.published_revision_id
     AND sr.tenant_id = l.tenant_id
     AND sr.status = 'published'
    WHERE ma.storage_bucket = p_bucket_id
      AND ma.storage_path = p_name
  );
$function$;
