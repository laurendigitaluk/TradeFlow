alter table public.buying_items add column if not exists buying_product_id uuid references public.tenant_buying_products(id) on delete set null;
create index if not exists buying_items_buying_product_idx on public.buying_items(tenant_id,buying_product_id);

create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_item record;
  v_product record;
  v_research record;
  v_amount numeric;
begin
  if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then
    raise exception 'Not authorised to calculate buying valuation';
  end if;
  select bi.id, bi.tenant_id, bi.buying_product_id into v_item
  from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
  if not found then raise exception 'Buying item not found'; end if;
  if v_item.buying_product_id is null then
    return jsonb_build_object('mode','manual','reason','product_not_selected','amount',null);
  end if;
  select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.automatic_percentage,bp.manual_offer_price
    into v_product from public.tenant_buying_products bp
  where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
  if not found then
    return jsonb_build_object('mode','manual','reason','buying_product_not_found','amount',null);
  end if;
  if v_product.automatic_percentage is null then
    return jsonb_build_object('mode','manual','reason','manual_offer_required','amount',v_product.manual_offer_price,'manufacturer',v_product.manufacturer,'model',v_product.model);
  end if;
  select tr.id,tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at
    into v_research from public.tenant_buying_research tr
  where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id
    and tr.evidence_type='uk_new' and tr.observed_price is not null
    and upper(coalesce(tr.price_currency,'GBP'))='GBP'
  order by tr.checked_at desc limit 1;
  if not found then
    return jsonb_build_object('mode','manual','reason','no_uk_new_research','amount',v_product.manual_offer_price,'manufacturer',v_product.manufacturer,'model',v_product.model);
  end if;
  v_amount=round(v_research.observed_price * v_product.automatic_percentage / 100,2);
  return jsonb_build_object('mode','automatic','reason','percentage_of_researched_uk_new',
    'amount',v_amount,'percentage',v_product.automatic_percentage,'base_price',v_research.observed_price,
    'currency','GBP','source_name',v_research.source_name,'source_url',v_research.source_url,
    'checked_at',v_research.checked_at,'manufacturer',v_product.manufacturer,'model',v_product.model);
end;
$$;
revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;