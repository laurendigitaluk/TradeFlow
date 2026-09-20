create or replace function public.customer_submit_buying_request(
  p_tenant_id uuid,
  p_notes text default null,
  p_items jsonb default '[]'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
as $function$
declare
  v_customer_id uuid; v_request_id uuid; v_item jsonb; v_field jsonb;
  v_category_id uuid; v_field_id uuid; v_item_id uuid; v_sort integer := 0;
  v_reference text; v_field_type text; v_value jsonb; v_required_count integer; v_supplied_count integer;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if exists (select 1 from public.tenant_memberships tm where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active') then
    raise exception 'subscriber accounts cannot submit customer buying requests for their own business';
  end if;
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  v_customer_id := private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
  if jsonb_typeof(p_items)<>'array' or jsonb_array_length(p_items)=0 then raise exception 'at least one item is required'; end if;
  v_reference := 'BR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at)
  values(p_tenant_id,v_customer_id,v_reference,'submitted','customer_portal',nullif(btrim(coalesce(p_notes,'')),''),now()) returning id into v_request_id;
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'buying_request',v_request_id,'draft','submitted',auth.uid(),nullif(btrim(coalesce(p_notes,'')),''),'{"source":"customer_portal"}'::jsonb);
  for v_item in select value from jsonb_array_elements(p_items) loop
    v_sort:=v_sort+1;
    begin v_category_id:=(v_item->>'category_id')::uuid; exception when others then raise exception 'invalid category id'; end;
    if not exists(select 1 from public.categories c where c.tenant_id=p_tenant_id and c.id=v_category_id and c.active and c.buying_enabled) then raise exception 'invalid buying category'; end if;
    insert into public.buying_items(tenant_id,buying_request_id,category_id,item_reference,status,title,description,quantity,sort_order)
    values(p_tenant_id,v_request_id,v_category_id,'BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'submitted',nullif(btrim(coalesce(v_item->>'title','')),''),nullif(btrim(coalesce(v_item->>'description','')),''),greatest(coalesce((v_item->>'quantity')::integer,1),1),v_sort) returning id into v_item_id;
    insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
    values(p_tenant_id,'buying_item',v_item_id,'draft','submitted',auth.uid(),null,'{"source":"customer_portal"}'::jsonb);
    if jsonb_typeof(coalesce(v_item->'fields','[]'::jsonb))<>'array' then raise exception 'item fields must be an array'; end if;
    select count(*) into v_required_count from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.required_for_buying and f.customer_visible;
    select count(*) into v_supplied_count from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) x where nullif(x->>'field_id','') is not null;
    if v_supplied_count>(select count(*) from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.customer_visible) then raise exception 'too many category fields supplied'; end if;
    for v_field in select value from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) loop
      begin v_field_id:=(v_field->>'field_id')::uuid; exception when others then raise exception 'invalid field id'; end;
      select f.field_type into v_field_type from public.category_fields f where f.tenant_id=p_tenant_id and f.id=v_field_id and f.category_id=v_category_id and f.customer_visible;
      if not found then raise exception 'invalid field for category'; end if;
      v_value:=v_field->'value'; if v_value is null or v_value='null'::jsonb then raise exception 'field value is required'; end if;
      if v_field_type='select' then
        if jsonb_typeof(v_value)<>'string' or not exists(select 1 from public.category_field_options o where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=(v_value#>>'{}') and o.active) then raise exception 'invalid select option'; end if;
      elsif v_field_type='multiselect' then
        if jsonb_typeof(v_value)<>'array' then raise exception 'multiselect value must be an array'; end if;
        if exists(select 1 from jsonb_array_elements_text(v_value) selected(value) where not exists(select 1 from public.category_field_options o where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=selected.value and o.active)) then raise exception 'invalid multiselect option'; end if;
      end if;
      if v_field_type in ('text','textarea','email','phone','url','select','multiselect') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_text) values(p_tenant_id,v_item_id,v_field_id,case when jsonb_typeof(v_value)='string' then v_value#>>'{}' else v_value::text end);
      elsif v_field_type in ('number','currency') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_number) values(p_tenant_id,v_item_id,v_field_id,(v_value#>>'{}')::numeric);
      elsif v_field_type='boolean' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_boolean) values(p_tenant_id,v_item_id,v_field_id,(v_value#>>'{}')::boolean);
      elsif v_field_type='date' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_date) values(p_tenant_id,v_item_id,v_field_id,(v_value#>>'{}')::date);
      else
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_json) values(p_tenant_id,v_item_id,v_field_id,v_value);
      end if;
    end loop;
    if v_required_count>0 then
      select count(*) into v_supplied_count from public.buying_item_field_values v join public.category_fields f on f.tenant_id=v.tenant_id and f.id=v.field_id
      where v.tenant_id=p_tenant_id and v.buying_item_id=v_item_id and f.required_for_buying and f.customer_visible and (v.value_text is not null or v.value_number is not null or v.value_boolean is not null or v.value_date is not null or v.value_json is not null);
      if v_supplied_count<>v_required_count then raise exception 'required category fields are missing'; end if;
    end if;
  end loop;
  return v_request_id;
end;
$function$;

revoke all on function public.customer_submit_buying_request(uuid,text,jsonb) from public;
grant execute on function public.customer_submit_buying_request(uuid,text,jsonb) to authenticated;
