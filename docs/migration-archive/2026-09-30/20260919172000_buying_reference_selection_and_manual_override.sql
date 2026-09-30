alter table public.tenant_buying_condition_rules
  add column if not exists sealed_reference_type text not null default 'uk_new',
  add column if not exists opened_never_used_reference_type text not null default 'uk_new',
  add column if not exists excellent_reference_type text not null default 'uk_used',
  add column if not exists good_reference_type text not null default 'uk_used',
  add column if not exists poor_reference_type text not null default 'uk_used',
  add column if not exists sealed_manual_price numeric(10,2),
  add column if not exists opened_never_used_manual_price numeric(10,2),
  add column if not exists excellent_manual_price numeric(10,2),
  add column if not exists good_manual_price numeric(10,2),
  add column if not exists poor_manual_price numeric(10,2);

alter table public.tenant_buying_condition_rules drop constraint if exists tenant_buying_condition_rules_reference_types_ck;
alter table public.tenant_buying_condition_rules add constraint tenant_buying_condition_rules_reference_types_ck check (
 sealed_reference_type in ('uk_new','uk_used') and opened_never_used_reference_type in ('uk_new','uk_used') and excellent_reference_type in ('uk_new','uk_used') and good_reference_type in ('uk_new','uk_used') and poor_reference_type in ('uk_new','uk_used')
);
alter table public.tenant_buying_condition_rules drop constraint if exists tenant_buying_condition_rules_manual_prices_ck;
alter table public.tenant_buying_condition_rules add constraint tenant_buying_condition_rules_manual_prices_ck check (
 (sealed_manual_price is null or sealed_manual_price >= 0) and (opened_never_used_manual_price is null or opened_never_used_manual_price >= 0) and (excellent_manual_price is null or excellent_manual_price >= 0) and (good_manual_price is null or good_manual_price >= 0) and (poor_manual_price is null or poor_manual_price >= 0)
);

create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
 v_item record; v_product record; v_rule record; v_research_new record; v_research_used record;
 v_pct numeric; v_base numeric; v_manual numeric; v_condition text; v_source text; v_url text; v_ref text;
begin
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;
 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition into v_item from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;
 v_condition:=v_item.item_condition;
 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id into v_product from public.tenant_buying_products bp where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
 select * into v_rule from public.tenant_buying_condition_rules r where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition); end if;
 v_pct:=case v_condition when 'sealed' then v_rule.sealed_percentage when 'opened_never_used' then v_rule.opened_never_used_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
 v_manual:=case v_condition when 'sealed' then v_rule.sealed_manual_price when 'opened_never_used' then v_rule.opened_never_used_manual_price when 'excellent' then v_rule.excellent_manual_price when 'good' then v_rule.good_manual_price when 'poor' then v_rule.poor_manual_price end;
 v_ref:=case v_condition when 'sealed' then v_rule.sealed_reference_type when 'opened_never_used' then v_rule.opened_never_used_reference_type when 'excellent' then v_rule.excellent_reference_type when 'good' then v_rule.good_reference_type when 'poor' then v_rule.poor_reference_type end;
 if v_manual is not null then return jsonb_build_object('mode','manual_override','reason','manual_override_configured','condition',v_condition,'amount',v_manual,'currency','GBP','percentage',v_pct,'reference_type',v_ref,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 if v_ref='uk_new' then
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
  v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
 else
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_used from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_used' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
  v_base:=v_research_used.observed_price; v_source:=v_research_used.source_name; v_url:=v_research_used.source_url;
 end if;
 if v_base is null then return jsonb_build_object('mode','manual','reason','no_research_for_selected_reference','condition',v_condition,'percentage',v_pct,'reference_type',v_ref); end if;
 if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base,'reference_type',v_ref); end if;
 return jsonb_build_object('mode','automatic','reason','percentage_of_selected_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'percentage',v_pct,'base_price',v_base,'currency','GBP','reference_type',v_ref,'source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
end; $$;
revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;