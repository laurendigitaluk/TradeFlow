-- Normalize the in-store UI condition values to the existing buying_items condition contract.
create or replace function public.subscriber_create_in_store_valuation(
  p_tenant_id uuid,
  p_customer_first_name text,
  p_customer_last_name text,
  p_customer_email text,
  p_customer_phone text,
  p_category_id uuid,
  p_buying_product_id uuid,
  p_item_condition text,
  p_serial_number text,
  p_notes text
) returns jsonb
language plpgsql security definer set search_path to 'pg_catalog','public'
as $function$
declare
  v_actor uuid:=auth.uid();
  v_customer uuid;
  v_request uuid;
  v_item uuid;
  v_ref text;
  v_req_ref text;
  v_condition text;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
    raise exception 'Permission required: buying.manage';
  end if;
  if nullif(trim(p_customer_first_name),'') is null then raise exception 'Customer first name is required'; end if;
  if nullif(trim(p_item_condition),'') is null then raise exception 'Item condition is required'; end if;

  v_condition:=case lower(trim(p_item_condition))
    when 'factory-sealed' then 'sealed'
    when 'sealed' then 'sealed'
    when 'opened-unused' then 'opened_never_used'
    when 'opened_never_used' then 'opened_never_used'
    when 'excellent' then 'excellent'
    when 'good' then 'good'
    when 'fair' then 'poor'
    when 'damaged' then 'poor'
    when 'not-working' then 'poor'
    when 'not_working' then 'poor'
    when 'poor' then 'poor'
    else lower(trim(p_item_condition))
  end;

  if v_condition not in ('sealed','opened_never_used','excellent','good','poor') then
    raise exception 'Unsupported item condition: %',p_item_condition;
  end if;

  if not exists(select 1 from public.tenant_buying_products bp where bp.id=p_buying_product_id and bp.tenant_id=p_tenant_id and bp.category_id=p_category_id and bp.active=true) then
    raise exception 'Selected catalogue product is not active for this category';
  end if;

  insert into public.customers(tenant_id,customer_reference,first_name,last_name,email,phone,status,notes,metadata)
  values(p_tenant_id,'CUS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),trim(p_customer_first_name),nullif(trim(p_customer_last_name),''),nullif(trim(p_customer_email),''),nullif(trim(p_customer_phone),''),'active','In-store valuation customer',jsonb_build_object('source','in_store')) returning id into v_customer;

  v_req_ref:='BR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at)
  values(p_tenant_id,v_customer,v_req_ref,'submitted','staff',coalesce(p_notes,'In-store valuation'),now()) returning id into v_request;

  v_ref:='BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.buying_items(tenant_id,buying_request_id,category_id,buying_product_id,item_reference,status,title,description,quantity,sort_order,item_condition,purchase_stage)
  select p_tenant_id,v_request,bp.category_id,bp.id,v_ref,'submitted',bp.package_name,bp.package_name,1,1,v_condition,'none'
  from public.tenant_buying_products bp where bp.id=p_buying_product_id returning id into v_item;

  if v_item is null then raise exception 'Selected catalogue product could not be created'; end if;

  update public.buying_items
  set metadata=jsonb_build_object('source','in_store','serial_number',nullif(trim(p_serial_number),''),'customer_condition',v_condition,'notes',p_notes)
  where id=v_item;

  return jsonb_build_object('customer_id',v_customer,'request_id',v_request,'buying_item_id',v_item,'request_reference',v_req_ref,'item_reference',v_ref);
end $function$;