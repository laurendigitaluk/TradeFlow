create or replace function public.add_master_buying_products_filtered_v2_with_tradein(
 p_tenant_id uuid,
 p_category_id uuid default null,
 p_branch_id uuid default null,
 p_manufacturer_id uuid default null,
 p_search text default null,
 p_model_name text default null,
 p_package_name text default null,
 p_set_name text default null,
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
 v_ids uuid[] := array[]::uuid[];
begin
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'categories.view') then
  raise exception 'Tenant user is not authorised to add Buying catalogue products';
 end if;
 select coalesce(array_agg(p.id),'{}'::uuid[]) into v_ids
 from public.catalogue_master_products p
 where p.active
 and (p_category_id is null or p.category_id=p_category_id)
 and (p_branch_id is null or p.branch_id=p_branch_id)
 and (p_manufacturer_id is null or p.manufacturer_id=p_manufacturer_id)
 and (nullif(trim(coalesce(p_model_name,'')),'') is null or trim(coalesce(p.model,''))=trim(p_model_name))
 and (nullif(trim(coalesce(p_package_name,'')),'') is null or trim(coalesce(p.package_name,''))=trim(p_package_name))
 and (nullif(trim(coalesce(p_set_name,'')),'') is null or trim(split_part(coalesce(p.package_name,''),'#',1))=trim(p_set_name))
 and (nullif(trim(coalesce(p_search,'')),'') is null or lower(coalesce(p.model,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.package_name,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.product_type,'')) like '%'||lower(trim(p_search))||'%' or lower(coalesce(p.notes,'')) like '%'||lower(trim(p_search))||'%');
 select coalesce(array_agg(distinct s.master_product_id),'{}'::uuid[]) into v_existing
 from public.tenant_catalogue_selections s
 where s.tenant_id=p_tenant_id and s.master_product_id=any(v_ids) and s.active and s.buying_enabled;
 v_result:=public.add_master_buying_products_filtered_v2(
  p_tenant_id,p_category_id,p_branch_id,p_manufacturer_id,p_search,p_model_name,p_package_name,p_set_name,
  p_mode,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage,
  null,null,null,null,null
 );
 if p_mode='automatic' then
  if (p_sealed_trade_in_percentage is not null and p_sealed_trade_in_percentage not between 0 and 100) or
     (p_opened_never_used_trade_in_percentage is not null and p_opened_never_used_trade_in_percentage not between 0 and 100) or
     (p_excellent_trade_in_percentage is not null and p_excellent_trade_in_percentage not between 0 and 100) or
     (p_good_trade_in_percentage is not null and p_good_trade_in_percentage not between 0 and 100) or
     (p_poor_trade_in_percentage is not null and p_poor_trade_in_percentage not between 0 and 100) then
    raise exception 'Trade-in percentages must be between 0 and 100';
  end if;
  foreach v_id in array v_ids loop
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
      poor_trade_in_percentage=p_poor_trade_in_percentage, updated_at=now()
     where tenant_id=p_tenant_id and buying_product_id=v_bp_id;
    end if;
   end if;
  end loop;
 end if;
 return v_result;
end;
$function$;
revoke all on function public.add_master_buying_products_filtered_v2_with_tradein(uuid,uuid,uuid,uuid,text,text,text,text,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) from public;
grant execute on function public.add_master_buying_products_filtered_v2_with_tradein(uuid,uuid,uuid,uuid,text,text,text,text,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric) to authenticated;