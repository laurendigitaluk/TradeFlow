-- TradeFlow: queue the customer notification when a final post-inspection offer is published.
-- The customer portal already handles the final-offer response and bank-detail collection.
-- This migration connects the existing notification infrastructure to the final-offer workflow.

create or replace function public.subscriber_publish_final_offer(
  p_tenant_id uuid,
  p_buying_item_id uuid,
  p_amount numeric,
  p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path to 'public','private'
as $function$
declare
  v_actor uuid:=auth.uid();
  v_stage text;
  v_currency text;
  v_value_id uuid;
  v_offer_id uuid;
  v_customer_id uuid;
  v_customer_email text;
  v_customer_name text;
  v_payload jsonb;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
    raise exception 'Permission required: buying.manage';
  end if;
  if p_amount<0 then
    raise exception 'Final offer amount cannot be negative';
  end if;

  select purchase_stage,currency into v_stage,v_currency
  from public.buying_items
  where tenant_id=p_tenant_id and id=p_buying_item_id
  for update;

  if v_stage is null then raise exception 'Buying item not found'; end if;
  if v_stage<>'final_offer_required' then
    raise exception 'Final offer can only be sent after a passed inspection';
  end if;

  select br.customer_id,c.email,trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,''))
    into v_customer_id,v_customer_email,v_customer_name
  from public.buying_items bi
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;

  insert into public.trading_values(
    tenant_id,buying_item_id,method,status,amount,currency,cash_price,
    trade_in_price,confidence,calculated_at,notes,metadata
  )
  values(
    p_tenant_id,p_buying_item_id,'manual','draft',p_amount,coalesce(v_currency,'GBP'),
    p_amount,null,null,now(),coalesce(p_notes,'Final post-inspection valuation'),
    jsonb_build_object('source','post_inspection_final_valuation','inspection_required',true)
  )
  returning id into v_value_id;

  perform public.transition_workflow_entity(
    p_tenant_id,'trading_value',v_value_id,'draft','approved',
    coalesce(p_notes,'Final post-inspection valuation approved'),
    jsonb_build_object('source','post_inspection_final_valuation')
  );

  insert into public.offers(
    tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,status,amount,currency,created_by
  )
  values(
    p_tenant_id,p_buying_item_id,v_value_id,
    'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),
    'final','draft',p_amount,coalesce(v_currency,'GBP'),v_actor
  )
  returning id into v_offer_id;

  perform public.transition_workflow_entity(
    p_tenant_id,'offer',v_offer_id,'draft','published',
    'Final post-inspection offer published to customer.',
    jsonb_build_object(
      'source','post_inspection_final_offer',
      'inspection_id',(
        select id from public.buying_item_inspections
        where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id
        order by created_at desc limit 1
      )
    )
  );

  update public.buying_items
  set purchase_stage='final_offer_sent',purchase_stage_updated_at=now(),updated_at=now()
  where tenant_id=p_tenant_id and id=p_buying_item_id;

  v_payload:=jsonb_build_object(
    'customer_name',v_customer_name,
    'item_title',(select coalesce(title,'your item') from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),
    'item_reference',(select item_reference from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),
    'offer_reference',(select offer_reference from public.offers where tenant_id=p_tenant_id and id=v_offer_id),
    'offer_amount',p_amount,
    'currency',coalesce(v_currency,'GBP'),
    'offer_type','final'
  );

  insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload)
  values(p_tenant_id,'offer_sent','offer',v_offer_id,v_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;

  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(
      p_tenant_id,'offer_sent','offer',v_offer_id,
      v_customer_email,v_customer_name,v_payload
    );
  end if;

  return jsonb_build_object('valuation_id',v_value_id,'offer_id',v_offer_id,'status','final_offer_sent');
end;
$function$;
