create or replace function public.customer_accept_offer(
  p_tenant_id uuid,p_offer_id uuid,p_response_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
  v_customer_id uuid; v_item_id uuid; v_offer_type text; v_offer_status text;
  v_offer_amount numeric; v_offer_mode text; v_expires_at timestamptz; v_item_stage text;
  v_other record;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.offers');
  if auth.uid() is null then raise exception 'authentication required'; end if;
  v_customer_id:=private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then raise exception 'customer account not linked to tenant'; end if;
  select o.buying_item_id,o.offer_type,o.offer_mode,o.status,o.amount,o.expires_at
    into v_item_id,v_offer_type,v_offer_mode,v_offer_status,v_offer_amount,v_expires_at
  from public.offers o
  join public.buying_items bi on bi.tenant_id=o.tenant_id and bi.id=o.buying_item_id
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  where o.tenant_id=p_tenant_id and o.id=p_offer_id and br.customer_id=v_customer_id
  for update of o;
  if v_item_id is null then raise exception 'offer not found or not owned by current customer'; end if;
  if v_offer_status<>'published' then raise exception 'offer is not available for acceptance'; end if;
  if v_expires_at is not null and v_expires_at<=now() then raise exception 'offer has expired'; end if;
  select purchase_stage into v_item_stage from public.buying_items where tenant_id=p_tenant_id and id=v_item_id for update;
  update public.offers set status='accepted',responded_at=now(),response_notes=p_response_notes,updated_at=now()
  where tenant_id=p_tenant_id and id=p_offer_id;
  insert into public.offer_events(tenant_id,offer_id,event_type,from_status,to_status,amount,notes,actor_user_id)
  values(p_tenant_id,p_offer_id,'accepted','published','accepted',v_offer_amount,p_response_notes,auth.uid());
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'offer',p_offer_id,'published','accepted',auth.uid(),p_response_notes,jsonb_build_object('source','customer_action','offer_mode',v_offer_mode));
  if v_offer_type in ('initial','revised') then
    if v_item_stage not in ('offer_ready','none','final_offer_refused') then raise exception 'This item is not available to begin the receipt workflow'; end if;
    for v_other in
      select id from public.offers
      where tenant_id=p_tenant_id and buying_item_id=v_item_id and id<>p_offer_id
        and offer_type in ('initial','revised') and status='published'
      order by created_at
    loop
      perform public.transition_workflow_entity(p_tenant_id,'offer',v_other.id,'published','superseded',
        'Superseded because the customer accepted another initial offer.',
        jsonb_build_object('source','customer_action','accepted_offer_id',p_offer_id));
    end loop;
    update public.buying_items set purchase_stage='awaiting_item',purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  elsif v_offer_type='final' then
    if v_item_stage<>'final_offer_sent' then raise exception 'Final offer cannot be accepted at the current purchase stage'; end if;
    update public.buying_items set purchase_stage='final_offer_accepted',final_offer_accepted_at=now(),purchase_stage_updated_at=now(),updated_at=now()
    where tenant_id=p_tenant_id and id=v_item_id;
  else
    raise exception 'Unsupported offer type for purchase workflow';
  end if;
  return null;
end;
$function$;

revoke execute on function public.customer_accept_offer(uuid,uuid,text) from public,anon;
grant execute on function public.customer_accept_offer(uuid,uuid,text) to authenticated;

create or replace function public.subscriber_publish_final_offer(
  p_tenant_id uuid,p_buying_item_id uuid,p_amount numeric,p_notes text default null
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
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
  if p_amount<0 then raise exception 'Final offer amount cannot be negative'; end if;
  select purchase_stage,currency into v_stage,v_currency from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_stage is null then raise exception 'Buying item not found'; end if;
  if v_stage<>'final_offer_required' then raise exception 'Final offer can only be sent after a passed inspection'; end if;
  select br.customer_id,c.email,trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,''))
    into v_customer_id,v_customer_email,v_customer_name
  from public.buying_items bi
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;
  if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;
  insert into public.trading_values(tenant_id,buying_item_id,method,status,amount,currency,cash_price,trade_in_price,confidence,calculated_at,notes,metadata)
  values(p_tenant_id,p_buying_item_id,'manual','draft',p_amount,coalesce(v_currency,'GBP'),p_amount,null,null,now(),coalesce(p_notes,'Final post-inspection valuation'),jsonb_build_object('source','post_inspection_final_valuation','inspection_required',true))
  returning id into v_value_id;
  perform public.transition_workflow_entity(p_tenant_id,'trading_value',v_value_id,'draft','approved',coalesce(p_notes,'Final post-inspection valuation approved'),jsonb_build_object('source','post_inspection_final_valuation'));
  insert into public.offers(tenant_id,buying_item_id,trading_value_id,offer_reference,offer_type,status,amount,currency,created_by)
  values(p_tenant_id,p_buying_item_id,v_value_id,'OF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),'final','draft',p_amount,coalesce(v_currency,'GBP'),v_actor)
  returning id into v_offer_id;
  perform public.transition_workflow_entity(p_tenant_id,'offer',v_offer_id,'draft','published','Final post-inspection offer published to customer.',jsonb_build_object('source','post_inspection_final_offer','inspection_id',(select id from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1)));
  update public.buying_items set purchase_stage='final_offer_sent',purchase_stage_updated_at=now(),updated_at=now() where tenant_id=p_tenant_id and id=p_buying_item_id;
  v_payload:=jsonb_build_object('customer_name',v_customer_name,'item_title',(select coalesce(title,'your item') from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),'item_reference',(select item_reference from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id),'offer_reference',(select offer_reference from public.offers where tenant_id=p_tenant_id and id=v_offer_id),'offer_amount',p_amount,'currency',coalesce(v_currency,'GBP'),'offer_type','final');
  insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload)
  values(p_tenant_id,'offer_sent','offer',v_offer_id,v_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
  if v_customer_email is not null and btrim(v_customer_email)<>'' then perform private.queue_customer_notification(p_tenant_id,'offer_sent','offer',v_offer_id,v_customer_email,v_customer_name,v_payload); end if;
  return jsonb_build_object('valuation_id',v_value_id,'offer_id',v_offer_id,'status','final_offer_sent');
end;
$function$;