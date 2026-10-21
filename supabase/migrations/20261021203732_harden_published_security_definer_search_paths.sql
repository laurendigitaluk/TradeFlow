-- Defense-in-depth: public-facing SECURITY DEFINER functions use only schema-qualified application objects.
-- Keep the existing execution grants and function bodies unchanged.
ALTER FUNCTION public.get_published_site_by_slug(text) SET search_path = '';
ALTER FUNCTION public.get_published_site_preview(uuid) SET search_path = '';
ALTER FUNCTION public.get_published_sites() SET search_path = '';
ALTER FUNCTION public.get_published_store_listing_media(uuid) SET search_path = '';
ALTER FUNCTION public.get_published_store_listings(uuid) SET search_path = '';
ALTER FUNCTION public.is_published_tradeflow_media(text, text) SET search_path = '';
