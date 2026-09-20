-- TradeFlow: add automatic/manual trade-in pricing alongside buying prices.
-- Trade-in percentages/overrides are optional so existing automatic buying rules remain valid.

alter table public.tenant_buying_condition_rules
  add column if not exists sealed_trade_in_percentage numeric(6,2),
  add column if not exists opened_never_used_trade_in_percentage numeric(6,2),
  add column if not exists excellent_trade_in_percentage numeric(6,2),
  add column if not exists good_trade_in_percentage numeric(6,2),
  add column if not exists poor_trade_in_percentage numeric(6,2),
  add column if not exists sealed_trade_in_manual_price numeric(10,2),
  add column if not exists opened_never_used_trade_in_manual_price numeric(10,2),
  add column if not exists excellent_trade_in_manual_price numeric(10,2),
  add column if not exists good_trade_in_manual_price numeric(10,2),
  add column if not exists poor_trade_in_manual_price numeric(10,2);

alter table public.tenant_buying_condition_rules drop constraint if exists tenant_buying_condition_rules_trade_in_pricing_ck;
alter table public.tenant_buying_condition_rules add constraint tenant_buying_condition_rules_trade_in_pricing_ck check (
  (sealed_trade_in_percentage is null or sealed_trade_in_percentage between 0 and 100) and
  (opened_never_used_trade_in_percentage is null or opened_never_used_trade_in_percentage between 0 and 100) and
  (excellent_trade_in_percentage is null or excellent_trade_in_percentage between 0 and 100) and
  (good_trade_in_percentage is null or good_trade_in_percentage between 0 and 100) and
  (poor_trade_in_percentage is null or poor_trade_in_percentage between 0 and 100) and
  (sealed_trade_in_manual_price is null or sealed_trade_in_manual_price >= 0) and
  (opened_never_used_trade_in_manual_price is null or opened_never_used_trade_in_manual_price >= 0) and
  (excellent_trade_in_manual_price is null or excellent_trade_in_manual_price >= 0) and
  (good_trade_in_manual_price is null or good_trade_in_manual_price >= 0) and
  (poor_trade_in_manual_price is null or poor_trade_in_manual_price >= 0)
);

drop function if exists public.configure_master_catalogue_buying_product_pricing(uuid,uuid,text,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,numeric,text,text,text,text,text);

create or replace function public.configure_master_catalogue_buying_product_pricing(
 p_tenant_id uuid,p_master_product_id uuid,p_mode text,p_manual_price numeric default null,
 p_sealed_percentage numeric default null,p_opened_never_used_percentage numeric default null,p_excellent_percentage numeric default null,p_good_percentage numeric default null,p_poor_percentage numeric default null,
 p_sealed_manual_price numeric default null,p_opened_never_used_manual_price numeric default null,p_excellent_manual_price numeric default null,p_good_manual_price numeric default null,p_poor_manual_price numeric default null,
 p_sealed_reference_type text default 'uk_new',p_opened_never_used_reference_type text default 'uk_new',p_excellent_reference_type text default 'uk_used',p_good_reference_type text default 'uk_used',p_poor_reference_type text default 'uk_used',
 p_sealed_trade_in_percentage numeric default null,p_opened_never_used_trade_in_percentage numeric default null,p_excellent_trade_in_percentage numeric default null,p_good_trade_in_percentage numeric default null,p_poor_trade_in_percentage numeric default null,
 p_sealed_trade_in_manual_price numeric default null,p_opened_never_used_trade_in_manual_price numeric default null,p_excellent_trade_in_manual_price numeric default null,p_good_trade_in_manual_price numeric default null,p_poor_trade_in_manual_price numeric default null
)
returns jsonb language plpgsql security definer set search_path=''
as $function$
declare v_result jsonb;
begin
 if p_sealed_reference_type not in ('uk_new','uk_used') or p_opened_never_used_reference_type not in ('uk_new','uk_used') or p_excellent_reference_type not in ('uk_new','uk_used') or p_good_reference_type not in ('uk_new','uk_used') or p_poor_reference_type not in ('uk_new','uk_used') then raise exception 'Research reference must be uk_new or uk_used'; end if;
 if (p_sealed_trade_in_percentage is not null and (p_sealed_trade_in_percentage<0 or p_sealed_trade_in_percentage>100))
 or (p_opened_never_used_trade_in_percentage is not null and (p_opened_never_used_trade_in_percentage<0 or p_opened_never_used_trade_in_percentage>100))
 or (p_excellent_trade_in_percentage is not null and (p_excellent_trade_in_percentage<0 or p_excellent_trade_in_percentage>100))
 or (p_good_trade_in_percentage is not null and (p_good_trade_in_percentage<0 or p_good_trade_in_percentage>100))
 or (p_poor_trade_in_percentage is not null and (p_poor_trade_in_percentage<0 or p_poor_trade_in_percentage>100)) then raise exception 'Trade-in percentages must be between 0 and 100'; end if;
 v_result:=public.configure_master_catalogue_buying_product(p_tenant_id,p_master_product_id,p_mode,p_manual_price,p_sealed_percentage,p_opened_never_used_percentage,p_excellent_percentage,p_good_percentage,p_poor_percentage);
 if lower(trim(coalesce(p_mode,'')))='automatic' then
  update public.tenant_buying_condition_rules r set
   sealed_manual_price=p_sealed_manual_price,opened_never_used_manual_price=p_opened_never_used_manual_price,excellent_manual_price=p_excellent_manual_price,good_manual_price=p_good_manual_price,poor_manual_price=p_poor_manual_price,
   sealed_reference_type=p_sealed_reference_type,opened_never_used_reference_type=p_opened_never_used_reference_type,excellent_reference_type=p_excellent_reference_type,good_reference_type=p_good_reference_type,poor_reference_type=p_poor_reference_type,
   sealed_trade_in_percentage=p_sealed_trade_in_percentage,opened_never_used_trade_in_percentage=p_opened_never_used_trade_in_percentage,excellent_trade_in_percentage=p_excellent_trade_in_percentage,good_trade_in_percentage=p_good_trade_in_percentage,poor_trade_in_percentage=p_poor_trade_in_percentage,
   sealed_trade_in_manual_price=p_sealed_trade_in_manual_price,opened_never_used_trade_in_manual_price=p_opened_never_used_trade_in_manual_price,excellent_trade_in_manual_price=p_excellent_trade_in_manual_price,good_trade_in_manual_price=p_good_trade_in_manual_price,poor_trade_in_manual_price=p_poor_trade_in_manual_price,updated_at=now()
  where r.tenant_id=p_tenant_id and r.buying_product_id=(v_result->>'buying_product_id')::uuid;
 end if;
 return v_result;
end;$function$;

do $$
declare r record;
begin
 for r in select p.oid::regprocedure as proc from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='configure_master_catalogue_buying_product_pricing' loop
  execute 'revoke execute on function '||r.proc||' from public, anon';
  execute 'grant execute on function '||r.proc||' to authenticated';
 end loop;
end $$;

create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path=''
as $function$
declare v_item record; v_product record; v_rule record; v_research_new record; v_research_used record;
 v_pct numeric; v_base numeric; v_manual numeric; v_trade_pct numeric; v_trade_manual numeric; v_condition text; v_source text; v_url text; v_ref text;
begin
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;
 select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition into v_item from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;
 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id,bp.manual_offer_price into v_product from public.tenant_buying_products bp where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
 if v_product.manual_offer_price is not null then return jsonb_build_object('mode','manual_override','reason','manual_product_price_configured','amount',v_product.manual_offer_price,'trade_in_amount',null,'currency','GBP','manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 v_condition:=v_item.item_condition;
 if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
 select * into v_rule from public.tenant_buying_condition_rules r where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition); end if;
 v_pct:=case v_condition when 'sealed' then v_rule.sealed_percentage when 'opened_never_used' then v_rule.opened_never_used_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
 v_manual:=case v_condition when 'sealed' then v_rule.sealed_manual_price when 'opened_never_used' then v_rule.opened_never_used_manual_price when 'excellent' then v_rule.excellent_manual_price when 'good' then v_rule.good_manual_price when 'poor' then v_rule.poor_manual_price end;
 v_trade_pct:=case v_condition when 'sealed' then v_rule.sealed_trade_in_percentage when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage when 'excellent' then v_rule.excellent_trade_in_percentage when 'good' then v_rule.good_trade_in_percentage when 'poor' then v_rule.poor_trade_in_percentage end;
 v_trade_manual:=case v_condition when 'sealed' then v_rule.sealed_trade_in_manual_price when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price when 'excellent' then v_rule.excellent_trade_in_manual_price when 'good' then v_rule.good_trade_in_manual_price when 'poor' then v_rule.poor_trade_in_manual_price end;
 v_ref:=case v_condition when 'sealed' then v_rule.sealed_reference_type when 'opened_never_used' then v_rule.opened_never_used_reference_type when 'excellent' then v_rule.excellent_reference_type when 'good' then v_rule.good_reference_type when 'poor' then v_rule.poor_reference_type end;
 if v_manual is not null or v_trade_manual is not null then return jsonb_build_object('mode','manual_override','reason','manual_condition_price_configured','condition',v_condition,'amount',v_manual,'trade_in_amount',v_trade_manual,'currency','GBP','percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type',v_ref,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 if v_ref='uk_new' then
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
  v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
 else
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_used from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_used' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
  v_base:=v_research_used.observed_price; v_source:=v_research_used.source_name; v_url:=v_research_used.source_url;
 end if;
 if v_base is null then return jsonb_build_object('mode','manual','reason','no_research_for_selected_reference','condition',v_condition,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'reference_type',v_ref); end if;
 if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base,'reference_type',v_ref,'trade_in_percentage',v_trade_pct); end if;
 return jsonb_build_object('mode','automatic','reason','percentage_of_selected_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'trade_in_amount',case when v_trade_pct is null then null else round(v_base*v_trade_pct/100,2) end,'percentage',v_pct,'trade_in_percentage',v_trade_pct,'base_price',v_base,'currency','GBP','reference_type',v_ref,'source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
end;$function$;
revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;