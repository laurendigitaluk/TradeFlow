-- Accept the customer-facing condition values used by the public valuation wizard.
-- Keep the stored/rule keys canonical while allowing the current UI labels/values
-- to drive the automatic valuation path.

CREATE OR REPLACE FUNCTION public.customer_submit_buying_request(p_tenant_id uuid, p_notes text DEFAULT NULL::text, p_items jsonb DEFAULT '[]'::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_customer_id uuid;
  v_request_id uuid;
  v_item jsonb;
  v_field jsonb;
  v_category_id uuid;
  v_field_id uuid;
  v_item_id uuid;
  v_product_id uuid;
  v_product record;
  v_rule record;
  v_research record;
  v_sort integer := 0;
  v_reference text;
  v_field_type text;
  v_value jsonb;
  v_required_count integer;
  v_supplied_count integer;
  v_condition text;
  v_reference_type text;
  v_percentage numeric;
  v_manual_price numeric;
  v_base_price numeric;
  v_amount numeric;
  v_trade_amount numeric;
  v_trade_percentage numeric;
  v_trade_manual_price numeric;
  v_valuation_id uuid;
  v_offer_id uuid;
  v_offer_amount numeric;
begin
  if auth.uid() is null then raise exception 'authentication required'; end if;
  if exists (
    select 1 from public.tenant_memberships tm
    where tm.tenant_id=p_tenant_id and tm.user_id=auth.uid() and tm.status='active'
  ) then
    raise exception 'subscriber accounts cannot submit customer buying requests for their own business';
  end if;
  perform private.require_tenant_feature(p_tenant_id,'module.buying');
  v_customer_id := private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items)=0 then raise exception 'at least one item is required'; end if;

  v_reference := 'BR-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
  insert into public.buying_requests(tenant_id,customer_id,request_reference,status,source,notes,submitted_at)
  values(p_tenant_id,v_customer_id,v_reference,'submitted','customer_portal',nullif(btrim(coalesce(p_notes,'')),''),now())
  returning id into v_request_id;

  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'buying_request',v_request_id,'draft','submitted',auth.uid(),nullif(btrim(coalesce(p_notes,'')),''),'{"source":"customer_portal"}'::jsonb);

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_sort := v_sort + 1;
    begin v_category_id := (v_item->>'category_id')::uuid; exception when others then raise exception 'invalid category id'; end;
    if not exists(select 1 from public.categories c where c.tenant_id=p_tenant_id and c.id=v_category_id and c.active and c.buying_enabled) then raise exception 'invalid buying category'; end if;

    v_product_id := null;
    if nullif(btrim(coalesce(v_item->>'buying_product_id','')),'') is not null then
      begin v_product_id := (v_item->>'buying_product_id')::uuid; exception when others then raise exception 'invalid buying product id'; end;
      select bp.*
      into v_product
      from public.tenant_buying_products bp
      where bp.id=v_product_id and bp.tenant_id=p_tenant_id and bp.active=true;
      if not found then raise exception 'selected buying product is not active for this subscriber'; end if;
      if v_product.category_id is distinct from v_category_id then raise exception 'selected buying product does not belong to the selected buying category'; end if;
    end if;

    insert into public.buying_items(
      tenant_id,buying_request_id,category_id,item_reference,status,title,description,quantity,sort_order,item_condition,buying_product_id,branch_id
    )
    values(
      p_tenant_id,v_request_id,v_category_id,'BI-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'submitted',
      nullif(btrim(coalesce(v_item->>'title','')),''),
      nullif(btrim(coalesce(v_item->>'description','')),''),
      greatest(coalesce((v_item->>'quantity')::integer,1),1),
      v_sort,
      nullif(btrim(coalesce(v_item->>'condition','')),''),
      v_product_id,
      case when v_product_id is null then null else v_product.branch_id end
    )
    returning id into v_item_id;

    insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
    values(p_tenant_id,'buying_item',v_item_id,'draft','submitted',auth.uid(),null,'{"source":"customer_portal"}'::jsonb);

    if jsonb_typeof(coalesce(v_item->'fields','[]'::jsonb)) <> 'array' then raise exception 'item fields must be an array'; end if;

    select count(*) into v_required_count
    from public.category_fields f
    where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.required_for_buying and f.customer_visible;

    select count(*) into v_supplied_count
    from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) x
    where nullif(x->>'field_id','') is not null;

    if v_supplied_count > (select count(*) from public.category_fields f where f.tenant_id=p_tenant_id and f.category_id=v_category_id and f.customer_visible) then raise exception 'too many category fields supplied'; end if;

    for v_field in select value from jsonb_array_elements(coalesce(v_item->'fields','[]'::jsonb)) loop
      begin v_field_id := (v_field->>'field_id')::uuid; exception when others then raise exception 'invalid field id'; end;
      select f.field_type into v_field_type
      from public.category_fields f
      where f.tenant_id=p_tenant_id and f.id=v_field_id and f.category_id=v_category_id and f.customer_visible;
      if not found then raise exception 'invalid field for category'; end if;
      v_value := v_field->'value';
      if v_value is null or v_value='null'::jsonb then raise exception 'field value is required'; end if;

      if v_field_type='select' then
        if jsonb_typeof(v_value)<>'string' or not exists(
          select 1 from public.category_field_options o
          where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=(v_value #>> '{}') and o.active
        ) then raise exception 'invalid select option'; end if;
      elsif v_field_type='multiselect' then
        if jsonb_typeof(v_value)<>'array' then raise exception 'multiselect value must be an array'; end if;
        if exists(
          select 1 from jsonb_array_elements_text(v_value) selected(value)
          where not exists(
            select 1 from public.category_field_options o
            where o.tenant_id=p_tenant_id and o.category_id=v_category_id and o.field_id=v_field_id and o.value=selected.value and o.active
          )
        ) then raise exception 'invalid multiselect option'; end if;
      end if;

      if v_field_type in ('text','textarea','email','phone','url','select','multiselect') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_text)
        values(p_tenant_id,v_item_id,v_field_id,case when jsonb_typeof(v_value)='string' then v_value #>> '{}' else v_value::text end);
      elsif v_field_type in ('number','currency') then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_number)
        values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::numeric);
      elsif v_field_type='boolean' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_boolean)
        values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::boolean);
      elsif v_field_type='date' then
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_date)
        values(p_tenant_id,v_item_id,v_field_id,(v_value #>> '{}')::date);
      else
        insert into public.buying_item_field_values(tenant_id,buying_item_id,field_id,value_json)
        values(p_tenant_id,v_item_id,v_field_id,v_value);
      end if;
    end loop;

    if v_required_count > 0 then
      select count(*) into v_supplied_count
      from public.buying_item_field_values v
      join public.category_fields f on f.tenant_id=v.tenant_id and f.id=v.field_id
      where v.tenant_id=p_tenant_id and v.buying_item_id=v_item_id and f.required_for_buying and f.customer_visible
        and (v.value_text is not null or v.value_number is not null or v.value_boolean is not null or v.value_date is not null or v.value_json is not null);
      if v_supplied_count <> v_required_count then raise exception 'required category fields are missing'; end if;
    end if;

    if v_product_id is not null then
      select bp.* into v_product
      from public.tenant_buying_products bp
      where bp.id=v_product_id and bp.tenant_id=p_tenant_id and bp.active=true;

      v_amount := null;
      v_trade_amount := null;
      v_base_price := null;
      v_reference_type := null;
      v_percentage := null;
      v_trade_percentage := null;

      if v_product.manual_offer_price is not null then
        v_amount := v_product.manual_offer_price;
      else
        select * into v_rule
        from public.tenant_buying_condition_rules r
        where r.tenant_id=p_tenant_id and r.buying_product_id=v_product_id
        limit 1;

        if found then
          v_condition := lower(nullif(btrim(coalesce(v_item->>'condition','')),''));
          v_condition := case v_condition
            when 'factory-sealed' then 'sealed'
            when 'opened-unused' then 'opened_never_used'
            when 'opened_never_used' then 'opened_never_used'
            when 'sealed' then 'sealed'
            when 'excellent' then 'excellent'
            when 'good' then 'good'
            when 'fair' then 'poor'
            when 'damaged' then 'poor'
            when 'not-working' then 'poor'
            when 'not_working' then 'poor'
            when 'poor' then 'poor'
            else v_condition
          end;

          v_percentage := case v_condition
            when 'sealed' then v_rule.sealed_percentage
            when 'opened_never_used' then v_rule.opened_never_used_percentage
            when 'excellent' then v_rule.excellent_percentage
            when 'good' then v_rule.good_percentage
            when 'poor' then v_rule.poor_percentage
          end;
          v_trade_percentage := case v_condition
            when 'sealed' then v_rule.sealed_trade_in_percentage
            when 'opened_never_used' then v_rule.opened_never_used_trade_in_percentage
            when 'excellent' then v_rule.excellent_trade_in_percentage
            when 'good' then v_rule.good_trade_in_percentage
            when 'poor' then v_rule.poor_trade_in_percentage
          end;
          v_manual_price := case v_condition
            when 'sealed' then v_rule.sealed_manual_price
            when 'opened_never_used' then v_rule.opened_never_used_manual_price
            when 'excellent' then v_rule.excellent_manual_price
            when 'good' then v_rule.good_manual_price
            when 'poor' then v_rule.poor_manual_price
          end;
          v_trade_manual_price := case v_condition
            when 'sealed' then v_rule.sealed_trade_in_manual_price
            when 'opened_never_used' then v_rule.opened_never_used_trade_in_manual_price
            when 'excellent' then v_rule.excellent_trade_in_excellent_trade_in_manual_price
            when 'good' then v_rule.good_trade_in_manual_price
            when 'poor' then v_rule.poor_trade_in_manual_price
          end;
          v_reference_type := case v_condition
            when 'sealed' then v_rule.sealed_reference_type
            when 'opened_never_used' then v_rule.opened_never_used_reference_type
            when 'excellent' then v_rule.excellent_reference_type
            when 'good' then v_rule.good_reference_type
            when 'poor' then v_rule.poor_reference_type
          end;

          if v_manual_price is not null or v_trade_manual_price is not null then
            v_amount := v_manual_price;
            v_trade_amount := v_trade_manual_price;
          elsif v_reference_type in ('uk_new','uk_used') and v_percentage is not null then
            select tr.observed_price,tr.price_currency,tr.source_name,tr.source_url,tr.checked_at
            into v_research
            from public.tenant_buying_research tr
            where tr.tenant_id=p_tenant_id
              and tr.buying_product_id=v_product_id
              and tr.evidence_type=v_reference_type
              and tr.observed_price is not null
              and upper(coalesce(tr.price_currency,'GBP'))='GBP'
            order by tr.checked_at desc
            limit 1;

            if found then
              v_base_price := v_research.observed_price;
              v_amount := round(v_base_price*v_percentage/100,2);
              v_trade_amount := case when v_trade_percentage is null then null else round(v_base_price*v_trade_percentage/100,2) end;
            end if;
          end if;
        end if;
      end if;

      if v_amount is not null or v_trade_amount is not null then
        v_offer_amount := coalesce(v_amount,v_trade_amount);

        insert into public.trading_values(
          tenant_id,buying_item_id,method,status,amount,currency,confidence,calculated_at,
          cash_price,trade_in_price,notes,metadata
        )
        values(
          p_tenant_id,v_item_id,'automatic','draft',v_offer_amount,'GBP',null,now(),
          v_amount,v_trade_amount,'Automatic buying catalogue valuation',
          jsonb_build_object('source','customer_submission','buying_product_id',v_product_id,'reference_type',v_reference_type,'base_price',v_base_price,'percentage',v_percentage,'trade_in_percentage',v_trade_percentage)
        )
        returning id into v_valuation_id;

        update public.trading_values
        set status='approved',approved_at=now(),approved_by=null,updated_at=now()
        where id=v_valuation_id and tenant_id=p_tenant_id;

        insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
        values(p_tenant_id,'trading_value',v_valuation_id,'draft','approved',auth.uid(),'Automatic valuation approved from customer submission','{"source":"customer_submission","valuation":"automatic"}'::jsonb);

        insert into public.offers(
          tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,status,amount,currency,created_by,offer_mode
        )
        values(
          p_tenant_id,v_item_id,v_valuation_id,'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'initial','draft',v_offer_amount,'GBP',auth.uid(),
          case when v_amount is not null then 'cash' else 'trade_in' end
        )
        returning id into v_offer_id;

        update public.offers
        set status='published',published_at=now(),updated_at=now()
        where id=v_offer_id and tenant_id=p_tenant_id;

        insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
        values(p_tenant_id,'offer',v_offer_id,'draft','published',auth.uid(),'Automatic offer published from customer submission','{"source":"customer_submission","valuation":"automatic"}'::jsonb);
      end if;
    end if;
  end loop;

  return v_request_id;
end;
$function$;