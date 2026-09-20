-- Remove the pre-trade-in overload of the catalogue pricing RPC.
do $$
declare r record;
begin
 for r in
   select p.oid::regprocedure as proc
   from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public'
     and p.proname='configure_master_catalogue_buying_product_pricing'
     and p.pronargs <> 29
 loop
   execute 'drop function '||r.proc;
 end loop;
end $$;