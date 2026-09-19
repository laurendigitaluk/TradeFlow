alter table public.tenant_buying_condition_rules
  drop constraint if exists tenant_buying_condition_rules_percentages_ck;

alter table public.tenant_buying_condition_rules
  rename column new_sealed_percentage to sealed_percentage;

alter table public.tenant_buying_condition_rules
  add column if not exists opened_never_used_percentage numeric(6,2);

update public.buying_items
set item_condition = 'opened_never_used'
where item_condition in ('new_sealed','never_used','opened');

alter table public.buying_items
  drop constraint if exists buying_items_item_condition_ck;

alter table public.buying_items
  add constraint buying_items_item_condition_ck
  check (item_condition is null or item_condition in ('sealed','opened_never_used','excellent','good','poor'));

alter table public.tenant_buying_condition_rules
  add constraint tenant_buying_condition_rules_percentages_ck
  check (
    coalesce(sealed_percentage,0) between 0 and 100
    and coalesce(opened_never_used_percentage,0) between 0 and 100
    and coalesce(excellent_percentage,0) between 0 and 100
    and coalesce(good_percentage,0) between 0 and 100
    and coalesce(poor_percentage,0) between 0 and 100
  );

create table if not exists public.tenant_buying_manufacturers (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete cascade,
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, name)
);

create unique index if not exists tenant_buying_manufacturers_lower_name_uq
  on public.tenant_buying_manufacturers (tenant_id, lower(name));

alter table public.tenant_buying_manufacturers enable row level security;

drop policy if exists tenant_buying_manufacturers_select on public.tenant_buying_manufacturers;
drop policy if exists tenant_buying_manufacturers_insert on public.tenant_buying_manufacturers;
drop policy if exists tenant_buying_manufacturers_update on public.tenant_buying_manufacturers;
drop policy if exists tenant_buying_manufacturers_delete on public.tenant_buying_manufacturers;

create policy tenant_buying_manufacturers_select on public.tenant_buying_manufacturers for select
  using (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_manufacturers_insert on public.tenant_buying_manufacturers for insert
  with check (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_manufacturers_update on public.tenant_buying_manufacturers for update
  using (private.can_tenant(tenant_id,'buying.manage','module.buying'))
  with check (private.can_tenant(tenant_id,'buying.manage','module.buying'));
create policy tenant_buying_manufacturers_delete on public.tenant_buying_manufacturers for delete
  using (private.can_tenant(tenant_id,'buying.manage','module.buying'));

insert into public.tenant_buying_manufacturers (tenant_id,name)
select distinct tenant_id, trim(manufacturer)
from public.tenant_buying_products
where nullif(trim(manufacturer),'') is not null
on conflict do nothing;

create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare
  v_item record; v_product record; v_rule record; v_research_new record; v_research_used record;
  v_pct numeric; v_base numeric; v_condition text; v_source text; v_url text;
begin
  if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then
    raise exception 'Not authorised to calculate buying valuation';
  end if;
  select bi.id,bi.tenant_id,bi.buying_product_id,bi.item_condition into v_item
  from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
  if not found then raise exception 'Buying item not found'; end if;
  if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected'); end if;
  v_condition:=v_item.item_condition;
  if v_condition is null then return jsonb_build_object('mode','manual','reason','condition_required'); end if;
  select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.branch_id into v_product
  from public.tenant_buying_products bp
  where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
  if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found'); end if;
  select * into v_rule from public.tenant_buying_condition_rules r
  where r.tenant_id=p_tenant_id and r.buying_product_id=v_product.id limit 1;
  if not found then return jsonb_build_object('mode','manual','reason','condition_pricing_not_configured','condition',v_condition,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_new
  from public.tenant_buying_research tr
  where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new'
    and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
  order by tr.checked_at desc limit 1;
  select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research_used
  from public.tenant_buying_research tr
  where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_used'
    and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP'
  order by tr.checked_at desc limit 1;
  if v_condition in ('sealed','opened_never_used') then
    v_base:=v_research_new.observed_price; v_source:=v_research_new.source_name; v_url:=v_research_new.source_url;
  else
    v_base:=v_research_used.observed_price; v_source:=v_research_used.source_name; v_url:=v_research_used.source_url;
  end if;
  v_pct:=case v_condition
    when 'sealed' then v_rule.sealed_percentage
    when 'opened_never_used' then v_rule.opened_never_used_percentage
    when 'excellent' then v_rule.excellent_percentage
    when 'good' then v_rule.good_percentage
    when 'poor' then v_rule.poor_percentage
  end;
  if v_base is null then
    return jsonb_build_object('mode','manual','reason',case when v_condition in ('sealed','opened_never_used') then 'no_uk_new_research' else 'no_uk_used_research' end,'condition',v_condition,'percentage',v_pct);
  end if;
  if v_pct is null then return jsonb_build_object('mode','manual','reason','condition_percentage_not_set','condition',v_condition,'base_price',v_base); end if;
  return jsonb_build_object('mode','automatic','reason','condition_percentage_of_reference','condition',v_condition,'amount',round(v_base*v_pct/100,2),'percentage',v_pct,'base_price',v_base,'currency','GBP','source_name',v_source,'source_url',v_url,'manufacturer',v_product.manufacturer,'model',v_product.model);
end; $$;

revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;
