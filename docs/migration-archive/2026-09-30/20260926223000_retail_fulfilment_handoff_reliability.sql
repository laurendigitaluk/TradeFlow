create or replace function public.subscriber_save_retail_fulfilment_shipping(
  p_tenant_id uuid,
  p_fulfilment_id uuid,
  p_shipping_method text,
  p_shipping_provider text default null,
  p_shipping_service_url text default null,
  p_shipping_carrier text default null,
  p_shipping_service text default null,
  p_shipping_tracking_number text default null,
  p_shipping_tracking_url text default null,
  p_shipping_label_url text default null,
  p_shipping_label_storage_path text default null,
  p_shipping_qr_url text default null,
  p_shipping_qr_storage_path text default null,
  p_shipping_instructions text default null,
  p_weight numeric default null,
  p_length numeric default null,
  p_width numeric default null,
  p_height numeric default null,
  p_notes text default null
)
returns jsonb
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_f public.fulfilments%rowtype;
  v_o public.retail_orders%rowtype;
  v_existing_status text;
  v_should_notify boolean:=false;
  v_parcel_id uuid;
  v_item_summary text;
  v_parcel_summary text;
  v_idempotency text;
  v_actor uuid:=auth.uid();
begin
  if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'fulfilment.manage') then
    raise exception 'Not authorised to manage fulfilment';
  end if;

  if p_shipping_method not in ('subscriber_override','automated') then
    raise exception 'Invalid shipping method';
  end if;

  if p_shipping_method='subscriber_override'
     and coalesce(p_shipping_label_url,'')=''
     and coalesce(p_shipping_label_storage_path,'')=''
     and coalesce(p_shipping_qr_url,'')=''
     and coalesce(p_shipping_qr_storage_path,'')='' then
    raise exception 'Add a shipping label or QR code before completing the shipping handoff';
  end if;

  if p_shipping_method='automated'
     and (p_shipping_provider is null or p_shipping_service_url is null) then
    raise exception 'Integrated shipping requires a configured provider';
  end if;

  select * into v_f from public.fulfilments
  where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
  if not found then raise exception 'Fulfilment not found'; end if;

  select * into v_o from public.retail_orders
  where tenant_id=p_tenant_id and id=v_f.retail_order_id for update;
  if not found then raise exception 'Retail order not found'; end if;

  if v_o.payment_status<>'paid' or v_o.status not in ('paid','fulfilment','completed') then
    raise exception 'Retail order is not paid and ready for fulfilment';
  end if;

  v_existing_status:=v_f.status;
  v_should_notify:=v_existing_status='awaiting';

  update public.fulfilments set
    shipping_method=p_shipping_method,
    shipping_provider=p_shipping_provider,
    shipping_service_url=p_shipping_service_url,
    shipping_instructions=p_shipping_instructions,
    carrier=p_shipping_carrier,
    service=p_shipping_service,
    tracking_number=p_shipping_tracking_number,
    tracking_url=p_shipping_tracking_url,
    label_url=coalesce(nullif(p_shipping_label_url,''),label_url),
    label_storage_path=coalesce(nullif(p_shipping_label_storage_path,''),label_storage_path),
    qr_url=coalesce(nullif(p_shipping_qr_url,''),qr_url),
    qr_storage_path=coalesce(nullif(p_shipping_qr_storage_path,''),qr_storage_path),
    recipient_name=coalesce(recipient_name,v_o.customer_name),
    recipient_email=coalesce(recipient_email,v_o.customer_email),
    shipping_address=coalesce(shipping_address,v_o.shipping_address),
    notes=coalesce(p_notes,notes),
    customer_sent_at=case when v_should_notify then now() else customer_sent_at end,
    updated_at=now()
  where tenant_id=p_tenant_id and id=p_fulfilment_id;

  select p.id into v_parcel_id
  from public.fulfilment_parcels p
  where p.tenant_id=p_tenant_id and p.fulfilment_id=p_fulfilment_id
  order by p.created_at limit 1 for update;

  if v_parcel_id is null then
    insert into public.fulfilment_parcels(
      tenant_id,fulfilment_id,parcel_reference,status,carrier,service,tracking_number,tracking_url,
      weight,length,width,height,label_url,notes,metadata
    )
    values(
      p_tenant_id,p_fulfilment_id,
      'PAR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
      'label',
      p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,
      p_weight,p_length,p_width,p_height,coalesce(nullif(p_shipping_label_url,''),null),p_notes,
      jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider)
    )
    returning id into v_parcel_id;
  else
    update public.fulfilment_parcels set
      status=case when status='awaiting' then 'label' else status end,
      carrier=coalesce(p_shipping_carrier,carrier),
      service=coalesce(p_shipping_service,service),
      tracking_number=coalesce(p_shipping_tracking_number,tracking_number),
      tracking_url=coalesce(p_shipping_tracking_url,tracking_url),
      weight=coalesce(p_weight,weight),
      length=coalesce(p_length,length),
      width=coalesce(p_width,width),
      height=coalesce(p_height,height),
      label_url=coalesce(nullif(p_shipping_label_url,''),label_url),
      notes=coalesce(p_notes,notes),
      metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider),
      updated_at=now()
    where tenant_id=p_tenant_id and id=v_parcel_id;
  end if;

  if v_existing_status='awaiting' then
    update public.fulfilments
    set status='label',updated_at=now()
    where tenant_id=p_tenant_id and id=p_fulfilment_id and status='awaiting';

    insert into public.workflow_transitions(
      tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
    )
    values(
      p_tenant_id,'fulfilment',p_fulfilment_id,'awaiting','label',v_actor,
      'Shipping label/QR and customer handoff completed.',
      jsonb_build_object('source','retail_fulfilment_shipping','parcel_id',v_parcel_id)
    );
  end if;

  select string_agg(
    case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,
    ', ' order by i.created_at
  ) into v_item_summary
  from public.retail_order_items i
  where i.tenant_id=p_tenant_id and i.order_id=v_o.id;

  v_parcel_summary:=trim(
    coalesce(
      case when p_weight is not null then p_weight::text||' kg' end,
      'Parcel measurements recorded with the shipping provider'
    ) ||
    case when p_length is not null or p_width is not null or p_height is not null
      then ' · '||coalesce(p_length::text,'?')||' × '||coalesce(p_width::text,'?')||' × '||coalesce(p_height::text,'?')||' cm'
      else '' end
  );

  if v_should_notify and v_o.customer_email is not null then
    v_idempotency:='order_shipping_ready:'||p_fulfilment_id::text;
    if not exists(select 1 from public.notification_queue q where q.idempotency_key=v_idempotency) then
      insert into public.notification_queue(
        tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for
      )
      values(
        p_tenant_id,'order_shipping_ready',v_o.customer_email,v_o.customer_name,
        'Your order is ready for dispatch','system_order_shipping_ready',
        jsonb_build_object(
          'order_reference',v_o.order_reference,
          'item_summary',coalesce(v_item_summary,'Your order'),
          'shipping_service',coalesce(p_shipping_service,'—'),
          'carrier',coalesce(p_shipping_carrier,'—'),
          'tracking_number',coalesce(p_shipping_tracking_number,'—'),
          'tracking_url',coalesce(p_shipping_tracking_url,'—'),
          'parcel_summary',v_parcel_summary,
          'shipping_instructions',coalesce(p_shipping_instructions,'Follow the shipping instructions shown in your customer portal.'),
          'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'
        ),
        'queued',0,v_idempotency,now()
      );
    end if;
  end if;

  return jsonb_build_object(
    'ok',true,'fulfilment_id',p_fulfilment_id,'status','label',
    'parcel_id',v_parcel_id,
    'notification_queued',v_should_notify and v_o.customer_email is not null
  );
end;
$function$;