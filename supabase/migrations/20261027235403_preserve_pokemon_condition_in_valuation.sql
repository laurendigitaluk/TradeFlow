-- Pokémon grades use the same five per-product pricing slots as the standard conditions.
-- The editor presents Pokémon-specific labels for Pokémon products, while these canonical
-- item_condition values are retained on the buying item and inspection record.
CREATE OR REPLACE FUNCTION public.calculate_buying_item_valuation(p_tenant_id uuid, p_buying_item_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $function$
DECLARE
 v_item record;
 v_product record;
 v_rule record;
 v_research_new record;
 v_shared_new record;
 v_pct numeric;
 v_base numeric;
 v_manual numeric;
 v_trade_pct numeric;
 v_trade_manual numeric;
 v_condition text;
 v_original_condition text;
 v_is_pokemon boolean := false;
 v_source text;
 v_url text;
 v_use_shared boolean := true;
 v_master_product_id uuid;
BEGIN
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then
   raise exception 'Not authorised to calculate buying valuation';
 end if;

 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition
 into v_item
 from public.buying_items bi
 where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;

 if not found then return jsonb_build_object('mode','manual','reason','buying_item_not_found'); end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;

 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id,bp.manual_offer_price,c.name category_name
 into v_product
 from public.tenant_buying_products bp
 left join public.categories c on c.id=bp.category_id
 where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;

 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
 v_original_condition := v_item.item_condition;
 v_is_pokemon := lower(coalesce(v_product.category_name,'')) like '%pokemon trading cards%' or lower(coalesce(v_product.category_name,'')) like '%pokémon trading cards%';
 if v_product.manual_offer_price is not null then
   return jsonb_build_object('mode','manual_override','reason','manual_product_price_configured','amount',v_product.manual_offer_price,'trade_in_amount',null,'currency','GBP','manufacturer',v_product.manufacturer,'model',v_product.model);
 end if;

 v_condition:=case v_item.item_condition
   when 'factory-sealed' then 'sealed'
   when 'opened-unused' then 'opened_never_used'
   when 'opened_never_used' then 'opened_never_used'
   when 'sealed' then 'sealed'
   when 'excellent' then 'excellent'
   when 'good' then 'good'
   when 'fair' then 'poor'
   when 'damaged' then 'poor'
   when 'not-working' then 'poor'
   when 'not_working' then 'poor'
   when 'poor' then 'poor'
   -- Pokémon collector grades are distinct input values and stay intact on the item.
   -- Their per-product rule slots are labelled with Pokémon grades in the editor.
   when 'near_mint' then 'sealed'
   when 'lightly_played' then 'opened_never_used'
   when 'moderately_played' then 'excellent'
   when 'heavily_played' then 'good'
   else v_item.item_condition
 end;

 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
 select * into v_rule from public.tenant_buying_condition_rules r
 where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',case when v_is_pokemon then v_original_condition else v_condition end); end if;

 v_pct:=case v_condition
   when 'sealed' then v_rule.sealed_percentage
   when 'opened_never_used' then v_rule.opened_never_used_percentage
   when 'excellent' then v_rule.excellent_percentage
   when 'good' then v_rule.good_percentage
   when 'poor' then v_rule.poor_percentage
 end;
 v_manual:=case v_condition
   when 'sealed' then v_rule.sealed_manual_price
   when 'opened_never_used' then v_rule.opened_never_used_manual_price
   when 'excellent' then v_rule.excellent_manual_price
   when 'good' then v_rule.good_manual_price
   when 'poor' then v_rule.poor_manual_price
 end;
 v_trade_pct:=case v_condition
   when 'sealed' then v_rule.sealed_trade_in_percentage
   when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage
   when 'excellent' then v_rule.excellent_trade_in_percentage
   when 'good' then v_rule.good_trade_in_percentage
   when 'poor' then v_rule.poor_trade_in_percentage
 end;
 v_trade_manual:=case v_condition
   when 'sealed' then v_rule.sealed_trade_in_manual_price
   when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price
   when 'excellent' then v_rule.excellent_trade_in_manual_price
   when 'good' then v_rule.good_trade_in_manual_price
   when 'poor' then v_rule.poor_trade_in_manual_price
 end;

 if v_manual is not null or v_trade_manual is not null then
   return jsonb_build_object('mode','manual_override','reason','manual_condition_price_configured','condition',case when v_is_pokemon then v_original_condition else v_condition end,'amount',v_manual,'trade_in_amount',v_trade_manual,'currency','GBP','percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new','manufacturer',v_product.manufacturer,'model',v_product.model);
 end if;

 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at
 into v_research_new
 from public.tenant_buying_research tr
 where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id
   and tr.evidence_type='uk_new' and tr.observed_price is not null
   and upper(coalesce(tr.price_currency,'GBP'))='GBP'
 order by tr.checked_at desc limit 1;

 if not found or v_research_new.observed_price is null then
   select coalesce((t.settings->>'use_shared_evidence')::boolean,true)
   into v_use_shared from public.tenants t where t.id=p_tenant_id;
   if coalesce(v_use_shared,true) then
     v_master_product_id:=public.resolve_master_product_for_tenant_package(v_product.manufacturer,v_product.model,v_product.package_name);
     if v_master_product_id is not null then
       select sme.observed_price,sme.price_currency,sme.source_name,sme.source_url,sme.observed_at
       into v_shared_new
       from public.shared_market_evidence sme
       where sme.master_product_id=v_master_product_id and sme.evidence_type='uk_new'
         and sme.is_active=true and sme.observed_price is not null
         and upper(coalesce(sme.price_currency,'GBP'))='GBP'
       order by sme.observed_at desc nulls last,sme.created_at desc limit 1;
     end if;
   end if;
   if v_shared_new.observed_price is null then
     return jsonb_build_object('mode','manual','reason','no_research_for_uk_new','condition',case when v_is_pokemon then v_original_condition else v_condition end,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new');
   end if;
   v_base:=v_shared_new.observed_price; v_source:=v_shared_new.source_name; v_url:=v_shared_new.source_url;
 else
   v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
 end if;

 if v_pct is null then
   return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',case when v_is_pokemon then v_original_condition else v_condition end,'base_price',v_base,'reference_type','uk_new','trade_in_percentage',v_trade_pct);
 end if;

 return jsonb_build_object(
   'mode','automatic','reason','percentage_of_uk_new_reference','condition',case when v_is_pokemon then v_original_condition else v_condition end,
   'amount',round(v_base*v_pct/100,2),
   'trade_in_amount',case when v_trade_pct is null then null else round(v_base*v_trade_pct/100,2) end,
   'percentage',v_pct,'trade_in_percentage',v_trade_pct,'base_price',v_base,'currency','GBP',
   'reference_type','uk_new','source_name',v_source,'source_url',v_url,
   'manufacturer',v_product.manufacturer,'model',v_product.model
 );
END;
$function$;
