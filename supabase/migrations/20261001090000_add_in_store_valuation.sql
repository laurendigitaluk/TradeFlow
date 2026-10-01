-- In-Store Valuation: staff-assisted purchase path
-- Uses the existing catalogue/valuation engine and bypasses online shipping/inspection.
create or replace function public.subscriber_create_in_store_valuation(
 p_tenant_id uuid,p_customer_first_name text,p_customer_last_name text,p_customer_email text,p_customer_phone text,
 p_category_id uuid,p_buying_product_id uuid,p_item_condition text,p_serial_number text,p_notes text
) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_customer uuid; v_request uuid; v_item uuid; v_ref text; v_req_ref text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if nullif(trim(p_customer_first_name),'') is null then raise exception 'Customer first name is required'; end if;
 insert into public.customers(tenant_id,customer_reference,first_name,last_name,email,phone,status,notes,metadata)
 values(p_tenant_id,'CUS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),trim(p_customer_first_name),nullif(trim(p_customer_last_name),''),nullif(trim(p_customer_email),''),nullif(trim(p_customer_phone),''),'active','In-store valuation customer',jsonb_build_object('source','in_store')) returning id into v_customer;
 v_req_ref:='BR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at) values(p_tenant_id,v_customer,v_req_ref,'submitted','staff',coalesce(p_notes,'In-store valuation'),now()) returning id into v_request;
 v_ref:='BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into public.buying_items(tenant_id,buying_request_id,category_id,buying_product_id,item_reference,status,title,description,quantity,sort_order,item_condition,purchase_stage)
 select p_tenant_id,v_request,p.category_id,p.id,v_ref,'submitted',p.package_name,p.package_name,1,1,p_item_condition,'submitted' from public.catalogue_master_products p where p.id=p_buying_product_id and p.category_id=p_category_id and p.active=true returning id into v_item;
 if v_item is null then raise exception 'Selected product is not active for this category'; end if;
 update public.buying_items set metadata=jsonb_build_object('source','in_store','serial_number',nullif(trim(p_serial_number),''),'customer_condition',p_item_condition,'notes',p_notes) where id=v_item;
 return jsonb_build_object('customer_id',v_customer,'request_id',v_request,'buying_item_id',v_item,'request_reference',v_req_ref,'item_reference',v_ref);
end $$;

create or replace function public.subscriber_complete_in_store_purchase(p_tenant_id uuid,p_buying_item_id uuid,p_purchase_price numeric,p_condition_grade text,p_notes text) returns jsonb language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_item public.buying_items%rowtype; v_inv uuid; v_product public.catalogue_master_products%rowtype;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_purchase_price is null or p_purchase_price<0 then raise exception 'Enter a valid purchase price'; end if;
 select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if not found then raise exception 'Buying item not found'; end if;
 if v_item.purchase_stage not in ('offer_ready','valued','submitted') then raise exception 'This item is not ready for an in-store purchase'; end if;
 select * into v_product from public.catalogue_master_products where id=v_item.buying_product_id;
 update public.buying_items set item_condition=coalesce(p_condition_grade,item_condition),purchase_stage='purchased',purchase_stage_updated_at=now(),purchased_at=now(),item_received_at=coalesce(item_received_at,now()),inspection_completed_at=now(),updated_at=now() where id=v_item.id;
 insert into public.inventory_assets(tenant_id,buying_item_id,category_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,dynamic_values,metadata,received_at,ready_for_sale_at,created_by,branch_id,catalogue_product_id)
 values(p_tenant_id,v_item.id,v_item.category_id,'IA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'ready_for_sale',coalesce(v_item.title,v_product.package_name),v_item.description,coalesce(p_condition_grade,v_item.item_condition),v_item.item_condition,1,p_purchase_price,p_purchase_price,'GBP',p_notes,'{}'::jsonb,jsonb_build_object('source','in_store','staff_inspected',true),now(),now(),v_actor,v_product.branch_id,v_product.id) returning id into v_inv;
 return jsonb_build_object('buying_item_id',v_item.id,'inventory_asset_id',v_inv,'purchase_stage','purchased','inventory_status','ready_for_sale');
end $$;

create or replace function public.subscriber_attach_in_store_photo(p_tenant_id uuid,p_buying_item_id uuid,p_storage_path text,p_original_filename text,p_mime_type text,p_byte_size bigint,p_sort_order integer) returns uuid language plpgsql security definer set search_path=pg_catalog,public as $$
declare v_actor uuid:=auth.uid(); v_media uuid;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if not exists(select 1 from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id) then raise exception 'Buying item not found'; end if;
 insert into public.media_assets(tenant_id,storage_bucket,storage_path,original_filename,mime_type,byte_size,status,created_by,asset_kind,retention_policy)
 values(p_tenant_id,'tradeflow-media',p_storage_path,p_original_filename,p_mime_type,p_byte_size,'active',v_actor,'buying_item','business') returning id into v_media;
 insert into public.buying_item_media(tenant_id,buying_item_id,media_asset_id,sort_order) values(p_tenant_id,p_buying_item_id,v_media,coalesce(p_sort_order,0));
 return v_media;
end $$;