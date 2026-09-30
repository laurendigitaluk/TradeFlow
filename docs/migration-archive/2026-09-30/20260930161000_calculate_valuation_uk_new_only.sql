-- The subscriber-side valuation calculator uses UK New research only.
-- UK Used research remains view-only.
-- Customer-facing condition values are normalised to the canonical rule keys.

CREATE OR REPLACE FUNCTION public.calculate_buying_item_valuation(p_tenant_id uuid, p_buying_item_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_item record;
 v_product record;
 v_rule record;
 v_research_new record;
 v_pct numeric;
 v_base numeric;
 v_manual numeric;
 v_trade_pct numeric;
 v_trade_manual numeric;
 v_condition text;
 v_source text;
 v_url text;
begin
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;
 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition into v_item from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;
 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id,bp.manual_offer_price into v_product from public.tenant_buying_products bp where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
 if v_product.manual_offer_price is not null then return jsonb_build_object('mode','manual_override','reason','manual_product_price_configured','amount',v_product.manual_offer_price,'trade_in_amount',null,'currency','GBP','manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 v_condition:=case v_item.item_condition
   when 'factory-sealed' then 'sealed' when 'opened-unused' then 'opened_never_used' when 'opened_never_used' then 'opened_never_used'
   when 'sealed' then 'sealed' when 'excellent' then 'excellent' when 'good' then 'good' when 'fair' then 'poor'
   when 'damaged' then 'poor' when 'not-working' then 'poor' when 'not_working' then 'poor' when 'poor' then 'poor' else v_item.item_condition end;
 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
 select * into v_rule from public.tenant_buying_condition_rules r where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition); end if;
 v_pct:=case v_condition when 'sealed' then v_rule.sealed_percentage when 'opened_never_used' then v_rule.opened_never_used_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
 v_manual:=case v_condition when 'sealed' then v_rule.sealed_manual_price when 'opened_never_used' then v_rule.opened_never_used_manual_price when 'excellent' then v_rule.excellent_manual_price when 'good' then v_rule.good_manual_price when 'poor' then v_rule.poor_manual_price end;
 v_trade_pct:=case v_condition when 'sealed' then v_rule.sealed_trade_in_percentage when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage when 'excellent' then v_rule.excellent_trade_in_percentage when 'good' then v_rule.good_trade_in_percentage when 'poor' then v_rule.poor_trade_in_percentage end;
 v_trade_manual:=case v_condition when 'sealed' then v_rule.sealed_trade_in_manual_price when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price when 'excellent' then v_rule.excellent_trade_in_manual_price when 'good' then v_rule.good_trade_in_manual_price when 'poor' then v_rule.poor_trade_in_manual_price end;
 if v_manual is not null or v_trade_manual is not null then
   return jsonb_build_object('mode','manual_override','reason','manual_condition_price_configured','condition',v_condition,'amount',v_manual,'trade_in_amount',v_trade_manual,'currency','GBP','percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new','manufacturer',v_product.manufacturer,'model',v_product.model);
 end if;
 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new
 from public.tenant_buying_research tr
 where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
 order by tr.checked_at desc limit 1;
 if not found or v_research_new.observed_price is null then
   return jsonb_build_object('mode','manual','reason','no_research_for_uk_new','condition',v_condition,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type','uk_new');
 end if;
 v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
 if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base,'reference_type','uk_new','trade_in_percentage',v_trade_pct); end if;
 return jsonb_build_object('mode','automatic','reason','percentage_of_uk_new_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'trade_in_amount',case when v_trade_pct is null then null else round(v_base*v_trade_pct/100,2) end,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'base_price',v_base,'currency','GBP','reference_type','uk_new','source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
end;
$function$;