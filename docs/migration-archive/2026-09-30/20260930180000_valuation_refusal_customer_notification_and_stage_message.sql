alter table public.notification_templates
  drop constraint if exists notification_templates_event_code_check;

alter table public.notification_templates
  add constraint notification_templates_event_code_check
  check (event_code = any (array[
    'offer_sent','offer_accepted','offer_refused','item_received','item_dispatched',
    'payment_sent','order_confirmation','order_dispatched','order_shipping_ready',
    'return_received','refund_issued','valuation_received','valuation_manual_required',
    'customer_buying_request_received','payment_bank_details_required','valuation_refused'
  ]::text[]));

create or replace function public.subscriber_refuse_buying_item_valuation(
  p_tenant_id uuid,p_buying_item_id uuid,p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path = 'pg_catalog','public'
as $function$
declare
  v_actor uuid:=auth.uid();
  v_stage text;
  v_offer_id uuid;
  v_offer_status text;
  v_customer_id uuid;
  v_customer_email text;
  v_customer_name text;
  v_item_title text;
  v_item_reference text;
  v_request_reference text;
  v_payload jsonb;
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then
    raise exception 'Permission required: buying.manage';
  end if;

  select purchase_stage into v_stage
  from public.buying_items
  where tenant_id=p_tenant_id and id=p_buying_item_id
  for update;

  if not found then raise exception 'Buying item not found'; end if;

  if coalesce(v_stage,'none') not in
    ('none','submitted','under_review','valued','offer_ready','awaiting_item','shipping') then
    raise exception 'This transaction cannot be refused at its current stage';
  end if;

  select o.id,o.status into v_offer_id,v_offer_status
  from public.offers o
  where o.tenant_id=p_tenant_id
    and o.buying_item_id=p_buying_item_id
    and o.offer_type='initial'
  order by o.created_at desc
  limit 1;

  if v_offer_id is not null and v_offer_status='published' then
    update public.offers
    set status='refused',responded_at=coalesce(responded_at,now()),updated_at=now()
    where id=v_offer_id and tenant_id=p_tenant_id and status='published';

    insert into public.workflow_transitions(
      tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id
    ) values(
      p_tenant_id,'offer',v_offer_id,'published','refused',
      coalesce(p_notes,'Valuation refused by subscriber.'),
      jsonb_build_object('source','buying_dashboard','reason','valuation_refused'),v_actor
    );
  end if;

  select br.customer_id,c.email,
    trim(coalesce(c.first_name,'')||' '||coalesce(c.last_name,'')),
    coalesce(bi.title,'your item'),bi.item_reference,br.request_reference
  into v_customer_id,v_customer_email,v_customer_name,
    v_item_title,v_item_reference,v_request_reference
  from public.buying_items bi
  join public.buying_requests br on br.tenant_id=bi.tenant_id and br.id=bi.buying_request_id
  join public.customers c on c.tenant_id=br.tenant_id and c.id=br.customer_id
  where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id;

  update public.buying_items
  set purchase_stage='offer_refused',purchase_stage_updated_at=now(),updated_at=now()
  where tenant_id=p_tenant_id and id=p_buying_item_id;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id
  ) values(
    p_tenant_id,'buying_item',p_buying_item_id,coalesce(v_stage,'none'),'offer_refused',
    coalesce(p_notes,'Valuation refused by subscriber.'),
    jsonb_build_object('source','buying_dashboard','reason','valuation_refused','customer_notified',true),
    v_actor
  );

  v_payload:=jsonb_build_object(
    'customer_name',coalesce(v_customer_name,''),
    'item_title',v_item_title,
    'item_reference',v_item_reference,
    'request_reference',v_request_reference,
    'reason',coalesce(p_notes,'The business has decided not to proceed with this item.'),
    'offer_reference',case when v_offer_id is not null
      then (select offer_reference from public.offers where id=v_offer_id) else null end
  );

  insert into public.notification_event_log(
    tenant_id,event_code,entity_type,entity_id,payload
  ) values(p_tenant_id,'valuation_refused','buying_item',p_buying_item_id,v_payload)
  on conflict (tenant_id,event_code,entity_type,entity_id) do nothing;

  if v_customer_email is not null and btrim(v_customer_email)<>'' then
    perform private.queue_customer_notification(
      p_tenant_id,'valuation_refused','buying_item',p_buying_item_id,
      v_customer_email,v_customer_name,v_payload
    );
  end if;

  return jsonb_build_object(
    'buying_item_id',p_buying_item_id,
    'status','offer_refused',
    'offer_id',v_offer_id,
    'customer_notified',true
  );
end;
$function$;

insert into public.notification_templates(
  tenant_id,event_code,template_code,subject_template,body_template,enabled,is_system
) values(
  null,'valuation_refused','system_valuation_refused',
  'We will not be proceeding with your item',
  'Hello {{customer_name}},<br><br>We have reviewed your item <strong>{{item_title}}</strong> ({{item_reference}}) and have decided not to proceed with the purchase.<br><br>Your request reference is <strong>{{request_reference}}</strong>.<br><br>If you have already sent the item, please contact the business for return instructions.',
  true,true
)
on conflict (tenant_id,event_code) do update set
  template_code=excluded.template_code,
  subject_template=excluded.subject_template,
  body_template=excluded.body_template,
  enabled=excluded.enabled,
  is_system=excluded.is_system,
  updated_at=now();

create or replace function public.customer_get_selling_status(p_tenant_id uuid)
returns table(
  request_id uuid,request_reference text,buying_item_id uuid,item_reference text,item_title text,
  request_status text,item_status text,stage text,message text,manual_notification_sent boolean
)
language plpgsql
stable
security definer
set search_path=''
as $function$
declare v_customer_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  limit 1;

  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  return query
  select r.id,r.request_reference,bi.id,bi.item_reference,bi.title,r.status,bi.status,
    case
      when bi.purchase_stage='awaiting_item'
       and not exists(
         select 1 from public.buying_item_shipping s
         where s.tenant_id=bi.tenant_id and s.buying_item_id=bi.id
           and (nullif(s.shipping_label_url,'') is not null
             or nullif(s.shipping_label_storage_path,'') is not null
             or nullif(s.shipping_qr_url,'') is not null
             or nullif(s.shipping_qr_storage_path,'') is not null)
       ) then 'awaiting_shipping_label'
      when bi.purchase_stage='final_offer_required'
       and exists(
         select 1 from public.offers o
         where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id
           and o.offer_type='initial' and o.status='accepted'
       ) then 'final_offer_accepted'
      when bi.purchase_stage <> 'none' then bi.purchase_stage
      when exists(
        select 1 from public.offers o
        where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published'
      ) then 'offer_ready'
      when exists(
        select 1 from public.trading_values tv
        where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved'
      ) then 'valued'
      when exists(
        select 1 from public.notification_event_log nel
        where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required'
          and nel.entity_type='buying_item' and nel.entity_id=bi.id
      ) then 'manual_valuation'
      when bi.status in ('submitted','under_review') then 'valuation_in_progress'
      else 'submitted'
    end,
    case
      when bi.purchase_stage='offer_refused'
        then 'We have decided not to proceed with this item. The purchase will not go ahead.'
      when bi.purchase_stage='awaiting_item'
       and not exists(
         select 1 from public.buying_item_shipping s
         where s.tenant_id=bi.tenant_id and s.buying_item_id=bi.id
           and (nullif(s.shipping_label_url,'') is not null
             or nullif(s.shipping_label_storage_path,'') is not null
             or nullif(s.shipping_qr_url,'') is not null
             or nullif(s.shipping_qr_storage_path,'') is not null)
       ) then 'You have accepted the offer. You will receive your shipping label and instructions soon.'
      when bi.purchase_stage='awaiting_item'
        then 'Your shipping label and instructions are ready. Send the item and confirm when it has been handed to the courier.'
      when bi.purchase_stage='shipping'
        then 'You have confirmed that the item has been sent. The business is now awaiting receipt.'
      when bi.purchase_stage='received'
        then 'The business has received your item. It is waiting for inspection.'
      when bi.purchase_stage='inspection'
        then 'Your item is currently being inspected.'
      when bi.purchase_stage='testing'
        then 'Your item has been routed for testing. It has not been purchased yet.'
      when bi.purchase_stage='repair'
        then 'Your item has been routed for repair. It has not been purchased yet.'
      when bi.purchase_stage='return_pending'
        then 'The item was refused during inspection and is awaiting return to you.'
      when bi.purchase_stage='final_offer_required'
       and exists(
         select 1 from public.offers o
         where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id
           and o.offer_type='initial' and o.status='accepted'
       ) then
        case when exists(
          select 1 from public.offers o
          where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id
            and o.offer_type='initial' and o.offer_mode='trade_in' and o.status='accepted'
        )
        then 'Your item has passed inspection. The agreed trade-in value is being added to your customer credit account.'
        else 'Your item has passed inspection. The business is now completing payment to your bank.'
        end
      when bi.purchase_stage='final_offer_sent'
        then 'A revised final offer has been sent. Review it and accept or refuse it.'
      when bi.purchase_stage='final_offer_accepted'
        then 'You accepted the revised final offer. The business is now completing payment.'
      when bi.purchase_stage='final_offer_refused'
        then 'The revised final offer was refused. The item remains outside the purchase and inventory process.'
      when bi.purchase_stage='purchased'
        then 'The item has been purchased and added to the business inventory. If this was a trade-in, the agreed value has been added to your trade-in credits.'
      when exists(
        select 1 from public.offers o
        where o.tenant_id=bi.tenant_id and o.buying_item_id=bi.id and o.status='published'
      ) then 'Your offer is ready to review.'
      when exists(
        select 1 from public.trading_values tv
        where tv.tenant_id=bi.tenant_id and tv.buying_item_id=bi.id and tv.status='approved'
      ) then 'Your valuation has been completed.'
      when exists(
        select 1 from public.notification_event_log nel
        where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required'
          and nel.entity_type='buying_item' and nel.entity_id=bi.id
      ) then 'We cannot automatically value this item. Your item has been sent for manual valuation.'
      else 'We have received your selling request and it is currently being reviewed.'
    end,
    exists(
      select 1 from public.notification_event_log nel
      where nel.tenant_id=bi.tenant_id and nel.event_code='valuation_manual_required'
        and nel.entity_type='buying_item' and nel.entity_id=bi.id
    )
  from public.buying_items bi
  join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
  where bi.tenant_id=p_tenant_id and r.customer_id=v_customer_id
  order by bi.created_at desc,bi.sort_order;
end;
$function$;
