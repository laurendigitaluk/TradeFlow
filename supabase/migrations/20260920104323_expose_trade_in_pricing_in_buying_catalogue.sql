-- Expose the condition trade-in fields through the existing catalogue page RPCs.
do $$
declare r record; d text;
begin
 for r in
   select p.oid
   from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='public'
     and p.proname in ('get_tenant_buying_catalogue_page','get_master_buying_catalogue_page_filtered')
 loop
   select pg_get_functiondef(r.oid) into d;
   d:=replace(
     d,
     'r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,',
     'r.sealed_manual_price,r.opened_never_used_manual_price,r.excellent_manual_price,r.good_manual_price,r.poor_manual_price,'||
     'r.sealed_trade_in_percentage,r.opened_never_used_trade_in_percentage,r.excellent_trade_in_percentage,r.good_trade_in_percentage,r.poor_trade_in_percentage,'||
     'r.sealed_trade_in_manual_price,r.opened_never_used_trade_in_manual_price,r.excellent_trade_in_manual_price,r.good_trade_in_manual_price,r.poor_trade_in_manual_price,'
   );
   execute d;
 end loop;
end $$;