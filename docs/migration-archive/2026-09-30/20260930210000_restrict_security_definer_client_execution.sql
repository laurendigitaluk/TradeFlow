DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT p.oid::regprocedure AS fn
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prosecdef = true
  LOOP
    EXECUTE format('REVOKE EXECUTE ON FUNCTION %s FROM PUBLIC, anon', r.fn);
  END LOOP;
END $$;

REVOKE SELECT ON TABLE public.published_site_preview FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.get_public_buying_catalogue(uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_site_preview(uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_sites() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_store_listing_media(uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_published_store_listings(uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.public_get_available_plans() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.is_published_tradeflow_media(text, text) TO anon, authenticated;
