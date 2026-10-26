-- Separate internal master-catalogue access from public/customer visibility.
-- Internal buying/selection flows use active status. Public catalogue still
-- checks customer_visible and tenant-specific website_visible.
do $$
declare r record; d text;
begin
  for r in
    select p.oid
    from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='public'
      and p.proname in (
        'get_master_buying_catalogue_facets',
        'get_master_buying_catalogue_page_filtered',
        'get_master_buying_catalogue_page',
        'add_master_buying_products_filtered',
        'configure_master_catalogue_buying_products_filtered',
        'get_master_catalogue_for_selection'
      )
  loop
    d := pg_get_functiondef(r.oid);
    d := replace(d, 'p.active and p.customer_visible', 'p.active');
    d := replace(d, 'p2.active and p2.customer_visible', 'p2.active');
    execute d;
  end loop;
end $$;
