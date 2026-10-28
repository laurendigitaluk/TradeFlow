-- Add independent trade-in percentages to bulk add without changing existing active products.
create or replace function public.add_master_buying_products_bulk_with_tradein(
 p_tenant_id uuid,
 p_master_product_ids uuid[],
 p_mode text default 'manual',
 p_sealed_percentage numeric default null,
 p_opened_never_used_percentage numeric default null,
 p_excellent_percentage numeric default null,
 p_good_percentage numeric default null,
 p_poor_percentage numeric default null,
 p_sealed_trade_in_percentage numeric default null,
 p_opened_never_used_trade_in_percentage numeric default null,
 p_excellent_trade_in_percentage numeric default null,
 p_good_trade_in_percentage numeric default null,
 p_poor_trade_in_percentage numeric default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $function$
declare
 v_result jsonb;
 v_id uuid;
 v_bp_id uuid;
 v_existing uuid[] := array[]::uuid[];
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then
   raise exception 'Tenant user is not authorised to configure Buying catalogue';
 end if;
 if not private.has_tenant_feature(p_tenant_id,'module.buying') then
   raise exception 'Buying is not enabled for this subscription';
 end if;
 if p_mode='automatic' and (
   coalesce(p_sealed_trade_in_percentage,-1) not between 0 and 100 and p_sealed_trade_in_percentage is not null or
   coalesce(p_opened_never_used_trade_in_percentage,-1) not between 0 and 100 and p_opened_never_used_trade_in_percentage is not null or
   coalesce(p_excellent_trade_in_percentage,-1) not between 0 and 100 and p_excellent_trade_in_percentage is not null or
   coalesce(p_good_trade_in_percentage,-1) not between 0 and 100 and p_good_trade_in_percentage is not null or
   coalesce(p_poor_trade_in_percentage,-1) not between 0 and 100 and p_poor_trade_in_percentage is not null
 ) then raise exception 'Trade-in percentages must be between 0 and 100'; end if;

 select coalesce(array_agg(distinct s.master_product_id),'{}'::uuid[]) into v_existing
 from public.tenant_catalogue_selections s
 join public.catalogue_master_products p on p.id=s.master_product_id
 join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
 join public.tenant_buying_products bp on bp.tenant_id=s.tenant_id
  and bp.branch_id is not distinct from s.branch_id
  and lower(bp.manufacturer)=lower(m.name) and lower(bp.model)=lower(p.model)
  and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,'')) and bp.active
 where s.tenant_id=p_tenant_id and s.master_product_id=any(coalesce(p_master_product_ids,'{}'::uuid[]))
  and s.buying_enabled and s.active;

 v_result := public.add_master_buying_products_bulk(
  p_tenant_id,p_master_product_ids,p_mode,p_sealed_percentage,p_opened_never_used_percentage,
  p_excellent_percentage,p_good_percentage,p_poor_percentage,null,null,null,null,null
 );

 if p_mode='automatic' then
  foreach v_id in array coalesce(p_master_product_ids,'{}'::uuid[]) loop
   if not (v_id=any(v_existing)) then
    select bp.id into v_bp_id
    from public.tenant_catalogue_selections s
    join public.catalogue_master_products p on p.id=s.master_product_id
    join public.catalogue_master_manufacturers m on m.id=p.manufacturer_id
    join public.tenant_buying_products bp on bp.tenant_id=s.tenant_id
      and bp.branch_id is not distinct from s.branch_id
      and lower(bp.manufacturer)=lower(m.name) and lower(bp.model)=lower(p.model)
      and lower(coalesce(bp.package_name,''))=lower(coalesce(p.package_name,''))
    where s.tenant_id=p_tenant_id and s.master_product_id=v_id and s.active and s.buying_enabled
    order by bp.updated_at desc limit 1;
    if v_bp_id is not null then
     update public.tenant_buying_condition_rules set
      sealed_trade_in_percentage=p_sealed_trade_in_percentage,
      opened_never_used_trade_in_percentage=p_opened_never_used_trade_in_percentage,
      excellent_trade_in_percentage=p_excellent_trade_in_percentage,
      good_trade_in_percentage=p_good_trade_in_percentage,
      poor_trade_in_percentage=p_poor_trade_in_percentage,
      updated_at=now()
     where tenant_id=p_tenant_id and buying_product_id=v_bp_id;
    end if;
   end if;
  end loop;
 end if;
 return v_result;
end;
$function$;

revoke all on function public.add_master_buying_products_bulk_with_tradein(uuid,uuid[],text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) from public;
grant execute on function public.add_master_buying_products_bulk_with_tradein(uuid,uuid[],text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) to authenticated;