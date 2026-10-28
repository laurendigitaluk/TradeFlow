create or replace function public.apply_buying_catalogue_bulk_with_tradein(
 p_tenant_id uuid,
 p_master_product_ids uuid[] default null,
 p_mode text default 'automatic',
 p_sealed_percentage numeric default null,
 p_opened_never_used_percentage numeric default null,
 p_excellent_percentage numeric default null,
 p_good_percentage numeric default null,
 p_poor_percentage numeric default null,
 p_sealed_manual_price numeric default null,
 p_opened_never_used_manual_price numeric default null,
 p_excellent_manual_price numeric default null,
 p_good_manual_price numeric default null,
 p_poor_manual_price numeric default null,
 p_all_matching boolean default false,
 p_category_id uuid default null,
 p_branch_id uuid default null,
 p_manufacturer_id uuid default null,
 p_search text default null,
 p_sealed_trade_in_percentage numeric default null,
 p_opened_never_used_trade_in_percentage numeric default null,
 p_excellent_trade_in_percentage numeric default null,
 p_good_trade_in_percentage numeric default null,
 p_poor_trade_in_percentage numeric default null
) returns jsonb language plpgsql security definer set search_path='' as $$
declare v_result jsonb; v_search text:=nullif(trim(coalesce(p_search,'')),'');
begin
 if lower(coalesce(p_mode,'automatic'))='automatic' then
  if (p_sealed_trade_in_percentage is not null and p_sealed_trade_in_percentage not between 0 and 100)
  or (p_opened_never_used_trade_in_percentage is not null and p_opened_never_used_trade_in_percentage not between 0 and 100)
  or (p_excellent_trade_in_percentage is not null and p_excellent_trade_in_percentage not between 0 and 100)
  or (p_good_trade_in_percentage is not null and p_good_trade_in_percentage not between 0 and 100)
  or (p_poor_trade_in_percentage is not null and p_poor_trade_in_percentage not between 0 and 100) then
   raise exception 'Trade-in percentages must be blank or between 0 and 100';
  end if;
 end if;
 v_result:=public.apply_buying_catalogue_bulk(p_tenant_id,p_master_product_ids,p_mode,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,p_sealed_manual_price,p_opened_never_used_manual_price,p_excellent_manual_price,p_good_manual_price,p_poor_manual_price,p_all_matching,p_category_id,p_branch_id,p_manufacturer_id,p_search);
 if lower(coalesce(p_mode,'automatic'))='automatic' then
  update public.tenant_buying_condition_rules r set
   sealed_trade_in_percentage=p_sealed_trade_in_percentage,
   opened_never_used_trade_in_percentage=p_opened_never_used_trade_in_percentage,
   excellent_trade_in_percentage=p_excellent_trade_in_percentage,
   good_trade_in_percentage=p_good_trade_in_percentage,
   poor_trade_in_percentage=p_poor_trade_in_percentage, updated_at=now()
  from public.tenant_catalogue_selections s
  join public.catalogue_master_products p on p.id=s.master_product_id
  join public.tenant_buying_products bp on bp.tenant_id=s.tenant_id
   and bp.category_id=s.category_id and bp.branch_id is not distinct from s.branch_id
   and lower(bp.manufacturer)=lower(s.manufacturer) and lower(bp.model)=lower(s.model)
   and lower(coalesce(bp.package_name,''))=lower(coalesce(s.package_name,''))
  where r.tenant_id=p_tenant_id and r.buying_product_id=bp.id
   and s.tenant_id=p_tenant_id and s.active and s.buying_enabled and p.active and p.customer_visible
   and ((not coalesce(p_all_matching,false) and s.master_product_id=any(coalesce(p_master_product_ids,array[]::uuid[])))
    or (coalesce(p_all_matching,false)
     and (p_category_id is null or p.category_id=p_category_id)
     and (p_branch_id is null or p.branch_id=p_branch_id)
     and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
     and (v_search is null or lower(coalesce(p.model,'')) like '%'||lower(v_search)||'%'
      or lower(coalesce(p.package_name,'')) like '%'||lower(v_search)||'%'
      or lower(coalesce(p.product_type,'')) like '%'||lower(v_search)||'%'
      or lower(coalesce(p.notes,'')) like '%'||lower(v_search)||'%')));
 end if;
 return v_result;
end; $$;
revoke all on function public.apply_buying_catalogue_bulk_with_tradein(uuid,uuid[],text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,boolean,uuid,uuid,uuid,text,numeric,numeric,numeric,numeric,numeric) from public, anon;
grant execute on function public.apply_buying_catalogue_bulk_with_tradein(uuid,uuid[],text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,boolean,uuid,uuid,uuid,text,numeric,numeric,numeric,numeric,numeric) to authenticated;