-- In-store workflow separation and receipt reference
-- In-store valuations are a counter-only workflow. Once accepted they go directly
-- to Inventory and must not appear in the online Buying / Internet Offers queue.

create or replace function public.subscriber_get_business_workflow(p_tenant_id uuid)
returns table(
  request_id uuid,
  request_reference text,
  request_status text,
  buying_item_id uuid,
  title text,
  purchase_stage text,
  amount numeric,
  currency text,
  offer_status text,
  offer_type text,
  acquisition_id uuid,
  acquisition_reference text,
  acquisition_status text
)
language plpgsql
stable security definer
set search_path to 'pg_catalog','public'
as $function$
begin
  if auth.uid() is null or not exists(
    select 1
    from public.tenant_memberships tm
    join public.roles r on r.code=tm.role_code and r.active
    join public.role_permissions rp on rp.role_id=r.id
    join public.permissions p on p.id=rp.permission_id and p.active and p.code='buying.view'
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then
    raise exception 'Permission required: buying.view';
  end if;

  return query
  select
    br.id, br.request_reference, br.status, bi.id, bi.title, bi.purchase_stage,
    coalesce(final_offer.amount,initial_offer.amount,tv.cash_price,tv.amount),
    coalesce(final_offer.currency,initial_offer.currency,tv.currency,'GBP'),
    coalesce(final_offer.status,initial_offer.status),
    coalesce(final_offer.offer_type,initial_offer.offer_type),
    a.id, a.acquisition_reference, a.status
  from public.buying_requests br
  join public.buying_items bi
    on bi.tenant_id=br.tenant_id and bi.buying_request_id=br.id
  left join lateral (
    select o.* from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='final'
    order by o.created_at desc limit 1
  ) final_offer on true
  left join lateral (
    select o.* from public.offers o
    where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.offer_type='initial'
    order by o.created_at desc limit 1
  ) initial_offer on true
  left join lateral (
    select tv.* from public.trading_values tv
    where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved'
    order by tv.approved_at desc nulls last,tv.created_at desc limit 1
  ) tv on true
  left join lateral (
    select a.* from public.acquisitions a
    where a.tenant_id=bi.tenant_id and a.source_offer_id=coalesce(final_offer.id,initial_offer.id)
    order by a.created_at desc limit 1
  ) a on true
  where br.tenant_id=p_tenant_id
    and coalesce(bi.metadata->>'source','') <> 'in_store'
    and bi.purchase_stage <> 'offer_refused'
    and not (
      bi.purchase_stage='return_pending'
      and exists(
        select 1 from public.buying_item_return_shipping rs
        where rs.tenant_id=bi.tenant_id
          and rs.buying_item_id=bi.id
          and rs.shipping_status='return_shipped'
      )
    )
    and (
      bi.purchase_stage <> 'none'
      or br.status in ('submitted','under_review','valued','offer_ready')
    )
  order by br.created_at desc,bi.sort_order;
end;
$function$;

create or replace function public.subscriber_complete_in_store_purchase(
 p_tenant_id uuid,p_buying_item_id uuid,p_purchase_price numeric,p_condition_grade text,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare
  v_actor uuid:=auth.uid();
  v_item public.buying_items%rowtype;
  v_bp public.tenant_buying_products%rowtype;
  v_master_id uuid;
  v_inv uuid;
  v_purchased_at timestamptz;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_purchase_price is null or p_purchase_price<0 then raise exception 'Enter a valid purchase price'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage not in ('none','offer_ready','valued','submitted') then raise exception 'This item is not ready for an in-store purchase'; end if;
 select * into v_bp from public.tenant_buying_products where id=v_item.buying_product_id and tenant_id=p_tenant_id and active=true;
 if not found then raise exception 'Buying catalogue product not found'; end if;
 select mp.id into v_master_id
 from public.catalogue_master_products mp
 join public.catalogue_master_manufacturers cm on cm.id=mp.manufacturer_id
 where lower(cm.name)=lower(v_bp.manufacturer)
   and lower(mp.model)=lower(v_bp.model)
   and lower(coalesce(mp.package_name,''))=lower(coalesce(v_bp.package_name,''))
   and mp.active=true
 order by mp.customer_visible desc limit 1;
 v_purchased_at:=now();
 update public.buying_items
 set item_condition=coalesce(p_condition_grade,item_condition),
     purchase_stage='purchased',
     purchase_stage_updated_at=v_purchased_at,
     purchased_at=v_purchased_at,
     item_received_at=coalesce(item_received_at,v_purchased_at),
     inspection_completed_at=v_purchased_at,
     updated_at=v_purchased_at
 where id=v_item.id;
 insert into public.inventory_assets(
   tenant_id,buying_item_id,category_id,asset_reference,status,title,description,
   condition_grade,customer_condition,quantity,purchase_price,current_value,currency,
   notes,dynamic_values,metadata,received_at,ready_for_sale_at,created_by,branch_id,catalogue_product_id
 )
 values(
   p_tenant_id,v_item.id,v_item.category_id,
   'IA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),
   'ready_for_sale',
   coalesce(v_item.title,v_bp.package_name),
   v_item.description,
   coalesce(p_condition_grade,v_item.item_condition),
   v_item.item_condition,
   1,p_purchase_price,p_purchase_price,'GBP',
   p_notes,'{}'::jsonb,
   jsonb_build_object('source','in_store','staff_inspected',true,'id_check_recorded',true),
   v_purchased_at,v_purchased_at,v_actor,v_bp.branch_id,v_master_id
 ) returning id into v_inv;
 return jsonb_build_object(
   'buying_item_id',v_item.id,
   'item_reference',v_item.item_reference,
   'inventory_asset_id',v_inv,
   'purchase_stage','purchased',
   'inventory_status','ready_for_sale',
   'purchased_at',v_purchased_at
 );
end $$;
