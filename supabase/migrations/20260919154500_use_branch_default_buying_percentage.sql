create or replace function public.calculate_buying_item_valuation(p_tenant_id uuid,p_buying_item_id uuid)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_item record; v_product record; v_branch record; v_research record; v_percentage numeric; v_amount numeric;
begin
 if not private.can_tenant(p_tenant_id,'valuation.manage','module.valuation') then raise exception 'Not authorised to calculate buying valuation'; end if;
 select bi.id,bi.tenant_id,bi.buying_product_id into v_item from public.buying_items bi where bi.id=p_buying_item_id and bi.tenant_id=p_tenant_id;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.buying_product_id is null then return jsonb_build_object('mode','manual','reason','product_not_selected','amount',null); end if;
 select bp.id,bp.manufacturer,bp.model,bp.package_name,bp.automatic_percentage,bp.manual_offer_price,bp.branch_id into v_product from public.tenant_buying_products bp where bp.id=v_item.buying_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
 if not found then return jsonb_build_object('mode','manual','reason','buying_product_not_found','amount',null); end if;
 select cb.default_buying_percentage into v_branch from public.category_branches cb where cb.id=v_product.branch_id and cb.tenant_id=p_tenant_id and cb.active=true;
 v_percentage:=coalesce(v_product.automatic_percentage,v_branch.default_buying_percentage);
 if v_percentage is null then return jsonb_build_object('mode','manual','reason','manual_offer_required','amount',v_product.manual_offer_price,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 select tr.id,tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at into v_research from public.tenant_buying_research tr where tr.tenant_id=p_tenant_id and tr.buying_product_id=v_product.id and tr.evidence_type='uk_new' and tr.observed_price is not null and upper(coalesce(tr.price_currency,'GBP'))='GBP' order by tr.checked_at desc limit 1;
 if not found then return jsonb_build_object('mode','manual','reason','no_uk_new_research','amount',v_product.manual_offer_price,'percentage',v_percentage,'manufacturer',v_product.manufacturer,'model',v_product.model); end if;
 v_amount=round(v_research.observed_price*v_percentage/100,2);
 return jsonb_build_object('mode','automatic','reason','percentage_of_researched_uk_new','amount',v_amount,'percentage',v_percentage,'base_price',v_research.observed_price,'currency','GBP','source_name',v_research.source_name,'source_url',v_research.source_url,'checked_at',v_research.checked_at,'manufacturer',v_product.manufacturer,'model',v_product.model);
end; $$;
revoke execute on function public.calculate_buying_item_valuation(uuid,uuid) from public,anon;
grant execute on function public.calculate_buying_item_valuation(uuid,uuid) to authenticated;