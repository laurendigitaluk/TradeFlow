-- In-Store Valuation completion/decline repair
-- Allows the dedicated in-store transaction to move from its initial 'none' stage
-- directly to purchased, because the counter transaction has already been checked.
create or replace function public.subscriber_complete_in_store_purchase(
 p_tenant_id uuid,p_buying_item_id uuid,p_purchase_price numeric,p_condition_grade text,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_bp public.tenant_buying_products%rowtype; v_master_id uuid; v_inv uuid;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_purchase_price is null or p_purchase_price<0 then raise exception 'Enter a valid purchase price'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage not in ('none','offer_ready','valued','submitted') then raise exception 'This item is not ready for an in-store purchase'; end if;
 select * into v_bp from public.tenant_buying_products where id=v_item.buying_product_id and tenant_id=p_tenant_id and active=true;
 if not found then raise exception 'Buying catalogue product not found'; end if;
 select mp.id into v_master_id from public.catalogue_master_products mp join public.catalogue_master_manufacturers cm on cm.id=mp.manufacturer_id where lower(cm.name)=lower(v_bp.manufacturer) and lower(mp.model)=lower(v_bp.model) and lower(coalesce(mp.package_name,''))=lower(coalesce(v_bp.package_name,'')) and mp.active=true order by mp.customer_visible desc limit 1;
 update public.buying_items set item_condition=coalesce(p_condition_grade,item_condition),purchase_stage='purchased',purchase_stage_updated_at=now(),purchased_at=now(),item_received_at=coalesce(item_received_at,now()),inspection_completed_at=now(),updated_at=now() where id=v_item.id;
 insert into public.inventory_assets(tenant_id,buying_item_id,category_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,dynamic_values,metadata,received_at,ready_for_sale_at,created_by,branch_id,catalogue_product_id)
 values(p_tenant_id,v_item.id,v_item.category_id,'IA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'ready_for_sale',coalesce(v_item.title,v_bp.package_name),v_item.description,coalesce(p_condition_grade,v_item.item_condition),v_item.item_condition,1,p_purchase_price,p_purchase_price,'GBP',p_notes,'{}'::jsonb,jsonb_build_object('source','in_store','staff_inspected',true,'id_check_recorded',true),now(),now(),v_actor,v_bp.branch_id,v_master_id) returning id into v_inv;
 return jsonb_build_object('buying_item_id',v_item.id,'inventory_asset_id',v_inv,'purchase_stage','purchased','inventory_status','ready_for_sale');
end $$;

create or replace function public.subscriber_decline_in_store_valuation(
 p_tenant_id uuid,p_buying_item_id uuid,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_metadata jsonb;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 select coalesce(metadata,'{}'::jsonb) into v_metadata from public.buying_items where id=p_buying_item_id and tenant_id=p_tenant_id for update;
 if not found then raise exception 'Buying item not found'; end if;
 update public.buying_items set metadata=v_metadata||jsonb_build_object('in_store_declined',true,'declined_at',now(),'declined_notes',p_notes),updated_at=now() where id=p_buying_item_id and tenant_id=p_tenant_id;
 return jsonb_build_object('buying_item_id',p_buying_item_id,'declined',true);
end $$;

-- Allow a completed in-store purchase to create its linked Inventory asset.
-- In-store purchases are already physically received and checked at the counter,
-- so they do not have an acquisition/payment record from the online workflow.
create or replace function public.guard_inventory_creation_boundary()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_acq record;
  v_item_stage text;
  v_source text:=coalesce(new.metadata->>'source','');
  v_buying_source text;
begin
  if new.acquisition_item_id is null then
    if v_source='in_store' then
      if new.created_by is null or new.created_by <> auth.uid() then
        raise exception 'In-store inventory must be created by the authenticated subscriber user';
      end if;
      if new.buying_item_id is null then
        raise exception 'In-store inventory requires a buying item';
      end if;
      if not private.has_tenant_feature(new.tenant_id,'module.inventory')
         or not private.has_tenant_permission(new.tenant_id,auth.uid(),'inventory.manage') then
        raise exception 'In-store inventory creation is not authorised for this subscriber';
      end if;
      select purchase_stage, metadata->>'source'
        into v_item_stage, v_buying_source
      from public.buying_items
      where tenant_id=new.tenant_id and id=new.buying_item_id;
      if v_buying_source <> 'in_store' or v_item_stage <> 'purchased' then
        raise exception 'In-store inventory requires a completed in-store purchase';
      end if;
      if new.catalogue_product_id is null then
        raise exception 'In-store inventory requires a catalogue product';
      end if;
      return new;
    end if;

    if v_source <> 'manual_inventory' then
      raise exception 'Inventory assets without an acquisition must use the manual inventory creation path';
    end if;
    if new.created_by is null or new.created_by <> auth.uid() then
      raise exception 'Manual inventory must be created by the authenticated subscriber user';
    end if;
    if not private.has_tenant_feature(new.tenant_id,'module.inventory')
       or not private.has_tenant_permission(new.tenant_id,auth.uid(),'inventory.manage') then
      raise exception 'Manual inventory creation is not authorised for this subscriber';
    end if;
    if new.catalogue_product_id is null then
      raise exception 'Manual inventory requires a catalogue product';
    end if;
    return new;
  end if;

  select a.id,a.status,a.paid_at,a.metadata,ai.buying_item_id
    into v_acq
  from public.acquisition_items ai
  join public.acquisitions a on a.tenant_id=ai.tenant_id and a.id=ai.acquisition_id
  where ai.tenant_id=new.tenant_id and ai.id=new.acquisition_item_id;

  if v_acq.id is null or v_acq.status not in ('paid','completed') or v_acq.paid_at is null then
    raise exception 'Inventory assets require a completed acquisition';
  end if;

  select purchase_stage into v_item_stage
  from public.buying_items
  where tenant_id=new.tenant_id and id=v_acq.buying_item_id;

  if v_item_stage not in ('final_offer_accepted','purchased','final_offer_required') then
    raise exception 'Inventory assets require an accepted offer and completed payment or trade-in credit';
  end if;

  if coalesce(v_acq.metadata->>'source','')='trade_in_credit' then
    if not exists(
      select 1 from public.trade_in_transactions t
      where t.tenant_id=new.tenant_id and t.acquisition_id=v_acq.id and t.status='credited'
    ) then
      raise exception 'Trade-in inventory requires a posted customer credit transaction';
    end if;
  elsif not exists(
    select 1 from public.payment_records p
    where p.tenant_id=new.tenant_id and p.acquisition_id=v_acq.id and p.status='paid' and p.direction='outbound'
  ) then
    raise exception 'Inventory assets require a recorded acquisition payment';
  end if;

  return new;
end;
$function$;
