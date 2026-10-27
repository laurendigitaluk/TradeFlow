-- Subscriber buying configuration is independent of public storefront visibility.
-- Keep public-site visibility checks in public catalogue queries; only remove the predicate
-- from internal subscriber configure/add and My Buying Catalogue functions.
DO $migration$
DECLARE
  fn regprocedure;
  def text;
  changed text;
  targets regprocedure[] := ARRAY[
    'public.configure_master_catalogue_buying_product(uuid,uuid,text,numeric,numeric,numeric,numeric,numeric,numeric)'::regprocedure,
    'public.add_master_buying_products_filtered_v2(uuid,uuid,uuid,uuid,text,text,text,text,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric)'::regprocedure,
    'public.get_tenant_buying_catalogue_facets(uuid,uuid,uuid)'::regprocedure,
    'public.get_tenant_buying_catalogue_page(uuid,uuid,uuid,uuid,text,integer,integer)'::regprocedure
  ];
BEGIN
  FOREACH fn IN ARRAY targets LOOP
    def := pg_get_functiondef(fn);
    changed := replace(def, 'p.active and p.customer_visible', 'p.active');
    changed := replace(changed, 'and p.active and p.customer_visible', 'and p.active');
    IF changed = def THEN
      RAISE EXCEPTION 'Expected customer visibility predicate not found in %; refusing to silently skip fix', fn;
    END IF;
    EXECUTE changed;
  END LOOP;
END
$migration$;
