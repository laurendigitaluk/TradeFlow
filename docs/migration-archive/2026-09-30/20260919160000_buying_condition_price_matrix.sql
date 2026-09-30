create table if not exists public.tenant_buying_condition_rules (
 id uuid primary key default gen_random_uuid(),
 tenant_id uuid not null references public.tenants(id) on delete cascade,
 buying_product_id uuid not null references public.tenant_buying_products(id) on delete cascade,
 new_sealed_percentage numeric(6,2),
 never_used_percentage numeric(6,2),
 opened_percentage numeric(6,2),
 excellent_percentage numeric(6,2),
 good_percentage numeric(6,2),
 poor_percentage numeric(6,2),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(tenant_id,buying_product_id),
 constraint tenant_buying_condition_rules_percentages_ck check (coalesce(new_sealed_percentage,0) between 0 and 100 and coalesce(never_used_percentage,0) between 0 and 100 and coalesce(opened_percentage,0) between 0 and 100 and coalesce(excellent_percentage,0) between 0 and 100 and coalesce(good_percentage,0) between 0 and 100 and coalesce(poor_percentage,0) between 0 and 100)
);
alter table public.tenant_buying_condition_rules enable row level security;
create policy tenant_buying_condition_rules_select on public.tenant_buying_condition_rules for select using (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_condition_rules_insert on public.tenant_buying_condition_rules for insert with check (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_condition_rules_update on public.tenant_buying_condition_rules for update using (private.can_tenant(tenant_id,'buying.manage','module.buying')) with check (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_condition_rules_delete on public.tenant_buying_condition_rules for delete using (private.can_tenant(tenant_id,'buying.manage','module.buying'));
alter table public.buying_items add column if not exists item_condition text;
alter table public.buying_items add constraint buying_items_item_condition_ck check (item_condition is null or item_condition in ('new_sealed','never_used','opened','excellent','good','poor'));
create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_item record; v_product record; v_rule record; v_research_new record; v_research_used record; v_pct numeric; v_base numeric; v_condition text; v_source text; v_url text;
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
 if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
 select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_used from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_used' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
 if v_condition in ('new_sealed','never_used','opened') then v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url; else v_base:=v_research_used.observed_price; v_source:=v_research_used.source_name; v_url:=v_research_used.source_url; end if;
 v_pct:=case v_condition when 'new_sealed' then v_rule.new_sealed_percentage when 'never_used' then v_rule.never_used_percentage when 'opened' then v_rule.opened_percentage when 'excellent' then v_rule.excellent_percentage when 'good' then v_rule.good_percentage when 'poor' then v_rule.poor_percentage end;
 if v_base is null then return jsonb_build_object('mode','manual','reason',case when v_condition in ('new_sealed','never_used','opened') then 'no_uk_new_research' else 'no_uk_used_research' end,'condition',v_condition,'percentage',v_pct); end if;
 if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base); end if;
 return jsonb_build_object('mode','automatic','reason','condition_percentage_of_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'percentage',v_pct,'base_price',v_base,'currency','GBP','source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
end; $$;
revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;