-- Allow unchanged accepted initial offers to be paid after inspection.
-- Revised final offers continue to require final_offer_accepted.
create or replace function public.subscriber_complete_purchase(
  p_tenant_id uuid,
  p_buying_item_id uuid,
  p_payment_method text,
  p_payment_reference text,
  p_payment_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path to 'public','private'
as $function$
declare
  v_actor uuid:=auth.uid();
  v_item public.buying_items%rowtype;
  v_offer public.offers%rowtype;
  v_customer_id uuid;
  v_customer_email text;
  v_customer_name text;
  v_bank public.customer_bank_details%rowtype;
  v_acq uuid;
  v_acq_item uuid;
  v_asset uuid;
  v_payment uuid;
  v_currency text;
  v_amount numeric;
  v_item_title text;
  v_item_reference text;
  v_payment_payload jsonb;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
  if not private.has_tenant_permission(p_tenant_id,v_actor,'finance.manage') then raise exception 'Permission required: finance.manage'; end if;

  select * into v_item from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
  if v_item.id is null then raise exception 'Buying item not found'; end if;
  if v_item.purchase_stage not in ('final_offer_required','final_offer_accepted') then
    raise exception 'The item must be ready for payment before payment can be recorded';
  end if;

  select * into v_offer from public.offers
  where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id and status='accepted'
    and ((v_item.purchase_stage='final_offer_accepted' and offer_type='final')
      or (v_item.purchase_stage='final_offer_required' and offer_type='initial'))
  order by responded_at desc nulls last,created_at desc limit 1;
  if v_offer.id is null then raise exception 'No accepted offer exists for this item'; end if;

  select br.customer_id,c.email,trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,''))
    into v_customer_id,v_customer_email,v_customer_name
  from public.buying_requests br join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where br.tenant_id=p_tenant_id and br.id=v_item.buying_request_id;
  if v_customer_id is null then raise exception 'Customer not found for buying item'; end if;

  select * into v_bank from public.customer_bank_details where tenant_id=p_tenant_id and customer_id=v_customer_id;
  if v_bank.id is null then raise exception 'Customer bank details are required before payment can be recorded'; end if;
  if nullif(trim(coalesce(p_payment_reference,'')),'') is null then raise exception 'Bank payment reference is required before payment can be recorded'; end if;

  v_amount:=v_offer.amount;
  v_currency:=coalesce(v_offer.currency,'GBP');
  v_item_title:=coalesce(v_item.title,'your item');
  v_item_reference:=v_item.item_reference;

  insert into public.payment_records(tenant_id,payment_reference,payment_type,status,direction,amount,currency,customer_id,payment_method,notes,metadata,requested_at,processed_at,created_by)
  values(p_tenant_id,trim(p_payment_reference),'seller_payment','paid','outbound',v_amount,v_currency,v_customer_id,nullif(trim(p_payment_method),''),
    nullif(trim(p_payment_notes),''),
    jsonb_build_object('source',case when v_offer.offer_type='final' then 'post_inspection_final_offer' else 'post_inspection_initial_offer' end,'buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'offer_type',v_offer.offer_type,'bank_details_on_file',true,'account_holder_name',v_bank.account_holder_name,'sort_code_last4',right(v_bank.sort_code,2),'account_number_last4',right(v_bank.account_number,4)),
    now(),now(),v_actor) returning id into v_payment;

  insert into public.acquisitions(tenant_id,acquisition_reference,status,customer_id,source_offer_id,currency,agreed_total,payment_total,accepted_at,finalised_at,paid_at,metadata,created_by)
  values(p_tenant_id,'ACQ-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'paid',v_customer_id,v_offer.id,v_currency,v_amount,v_amount,now(),now(),now(),
    jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'offer_id',v_offer.id,'payment_record_id',v_payment),v_actor) returning id into v_acq;

  insert into public.acquisition_items(tenant_id,acquisition_id,buying_item_id,offer_id,status,agreed_amount,final_amount,currency,paid_at,finalised_at,metadata)
  values(p_tenant_id,v_acq,p_buying_item_id,v_offer.id,'paid',v_amount,v_amount,v_currency,now(),now(),jsonb_build_object('source','final_offer_payment')) returning id into v_acq_item;

  update public.payment_records set acquisition_id=v_acq,updated_at=now() where id=v_payment;

  insert into public.inventory_assets(tenant_id,acquisition_item_id,buying_item_id,category_id,branch_id,asset_reference,status,title,description,condition_grade,customer_condition,quantity,purchase_price,current_value,currency,notes,metadata,received_at,created_by)
  values(p_tenant_id,v_acq_item,v_item.id,v_item.category_id,v_item.branch_id,null,'ready_for_sale',v_item.title,v_item.description,
    (select condition_grade from public.buying_item_inspections where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id order by created_at desc limit 1),
    v_item.item_condition,coalesce(v_item.quantity,1),v_amount,null,v_currency,'Created only after final offer acceptance, bank details and payment.',
    jsonb_build_object('source','final_offer_payment','buying_item_id',p_buying_item_id,'acquisition_id',v_acq,'offer_id',v_offer.id,'payment_record_id',v_payment),
    coalesce(v_item.item_received_at,now()),v_actor) returning id into v_asset;

  update public.buying_items set purchase_stage='purchased',purchased_at=now(),purchase_stage_updated_at=now(),updated_at=now()
  where tenant_id=p_tenant_id and id=p_buying_item_id;

  v_payment_payload:=jsonb_build_object('customer_name',v_customer_name,'item_title',v_item_title,'item_reference',v_item_reference,'payment_amount',v_amount,'currency',v_currency,'payment_reference',trim(p_payment_reference),'payment_type','seller_payment');
  insert into public.notification_event_log(tenant_id,event_code,entity_type,entity_id,payload)
  values(p_tenant_id,'payment_sent','payment_record',v_payment,v_payment_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;
  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(p_tenant_id,'payment_sent','payment_record',v_payment,v_customer_email,v_customer_name,v_payment_payload);
  end if;

  return jsonb_build_object('payment_record_id',v_payment,'acquisition_id',v_acq,'acquisition_item_id',v_acq_item,'inventory_asset_id',v_asset,'status','purchased');
end;
$function$;
