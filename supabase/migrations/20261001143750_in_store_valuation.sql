-- In-Store Valuation: staff-assisted purchase path
-- Uses the same tenant buying catalogue and existing valuation engine as the online selling journey.
create or replace function public.subscriber_create_in_store_valuation(
 p_tenant_id uuid,p_customer_first_name text,p_customer_last_name text,p_customer_email text,p_customer_phone text,
 p_category_id uuid,p_buying_product_id uuid,p_item_condition text,p_serial_number text,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_customer uuid; v_request uuid; v_item uuid; v_ref text; v_req_ref text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if nullif(trim(p_customer_first_name),'') is null then raise exception 'Customer first name is required'; end if;
 if nullif(trim(p_item_condition),'') is null then raise exception 'Item condition is required'; end if;
 if not exists(select 1 from public.tenant_buying_products bp where bp.id=p_buying_product_id and bp.tenant_id=p_tenant_id and bp.category_id=p_category_id and bp.active=true) then raise exception 'Selected catalogue product is not active for this category'; end if;
 insert into public.customers(tenant_id,customer_reference,first_name,last_name,email,phone,status,notes,metadata)
 values(p_tenant_id,'CUS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),trim(p_customer_first_name),nullif(trim(p_customer_last_name),''),nullif(trim(p_customer_email),''),nullif(trim(p_customer_phone),''),'active','In-store valuation customer',jsonb_build_object('source','in_store')) returning id into v_customer;
 v_req_ref:='BR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at) values(p_tenant_id,v_customer,v_req_ref,'submitted','staff',coalesce(p_notes,'In-store valuation'),now()) returning id into v_request;
 v_ref:='BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into public.buying_items(tenant_id,buying_request_id,category_id,buying_product_id,item_reference,status,title,description,quantity,sort_order,item_condition,purchase_stage)
 select p_tenant_id,v_request,bp.category_id,v_ref,'submitted',bp.package_name,bp.package_name,1,1,p_item_condition,'none' from public.tenant_buying_products bp where bp.id=p_buying_product_id returning id into v_item;
 if v_item is null then raise exception 'Selected catalogue product could not be created'; end if;
 update public.buying_items set metadata=jsonb_build_object('source','in_store','serial_number',nullif(trim(p_serial_number),''),'customer_condition',p_item_condition,'notes',p_notes) where id=v_item;
 return jsonb_build_object('customer_id',v_customer,'request_id',v_request,'buying_item_id',v_item,'request_reference',v_req_ref,'item_reference',v_ref);
end $$;

create or replace function public.subscriber_record_in_store_id_check(
 p_tenant_id uuid,p_buying_item_id uuid,p_id_type text,p_id_copied boolean,p_legal_right_to_sell text,p_missing_items text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_metadata jsonb;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_id_copied is not true then raise exception 'Customer ID must be produced and copied'; end if;
 if lower(coalesce(p_legal_right_to_sell,'')) <> 'yes' then raise exception 'Customer must confirm the legal right to sell the item'; end if;
 if not exists(select 1 from public.buying_items where id=p_buying_item_id and tenant_id=p_tenant_id) then raise exception 'Buying item not found'; end if;
 select coalesce(metadata,'{}'::jsonb) into v_metadata from public.buying_items where id=p_buying_item_id for update;
 update public.buying_items set metadata=v_metadata||jsonb_build_object('in_store_id_check',jsonb_build_object('id_type',p_id_type,'id_produced_and_copied',true,'legal_right_to_sell',p_legal_right_to_sell,'missing_items',p_missing_items,'checked_at',now())),updated_at=now() where id=p_buying_item_id;
 return jsonb_build_object('buying_item_id',p_buying_item_id,'id_check_recorded',true);
end $$;

create or replace function public.subscriber_complete_in_store_purchase(
 p_tenant_id uuid,p_buying_item_id uuid,p_purchase_price numeric,p_condition_grade text,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_bp public.tenant_buying_products%rowtype; v_master_id uuid; v_inv uuid;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_purchase_price is null or p_purchase_price<0 then raise exception 'Enter a valid purchase price'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage not in ('offer_ready','valued','submitted') then raise exception 'This item is not ready for an in-store purchase'; end if;
 select * into v_bp from public.tenant_buying_products where id=v_item.buying_product_id and tenant_id=p_tenant_id and active=true;
 if not found then raise exception 'Buying catalogue product not found'; end if;
 select mp.id into v_master_id from public.catalogue_master_products mp join public.catalogue_master_manufacturers cm on cm.id=mp.manufacturer_id where lower(cm.name)=lower(v_bp.manufacturer) and lower(mp.model)=lower(v_bp.model) and lower(coalesce(mp.package_name,''))=lower(coalesce(v_bp.package_name,'')) and mp.active=true order by mp.customer_visible desc limit 1;
 update public.buying_items set item_condition=coalesce(p_condition_grade,item_condition),purchase_stage='purchased',purchase_stage_updated_at=now(),purchased_at=now(),item_received_at=coalesce(item_received_at,now()),inspection_completed_at=now(),updated_at=now() where id=v_item.id;
 insert into public.inventory_assets(tenant_id,buying_item_id,category_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,dynamic_values,metadata,received_at,ready_for_sale_at,created_by,branch_id,catalogue_product_id)
 values(p_tenant_id,v_item.id,v_item.category_id,'IA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'ready_for_sale',coalesce(v_item.title,v_bp.package_name),v_item.description,coalesce(p_condition_grade,v_item.item_condition),v_item.item_condition,1,p_purchase_price,p_purchase_price,'GBP',p_notes,'{}'::jsonb,jsonb_build_object('source','in_store','staff_inspected',true,'id_check_recorded',true),now(),now(),v_actor,v_bp.branch_id,v_master_id) returning id into v_inv;
 return jsonb_build_object('buying_item_id',v_item.id,'inventory_asset_id',v_inv,'purchase_stage','purchased','inventory_status','ready_for_sale');
end $$;