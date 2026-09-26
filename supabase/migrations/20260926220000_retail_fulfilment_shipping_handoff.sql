-- Retail fulfilment shipping handoff. Replay of the live 2026-09-26 implementation.

alter table public.fulfilments
  add column if not exists shipping_method text,
  add column if not exists shipping_provider text,
  add column if not exists shipping_service_url text,
  add column if not exists shipping_instructions text,
  add column if not exists label_storage_path text,
  add column if not exists qr_url text,
  add column if not exists qr_storage_path text,
  add column if not exists customer_sent_at timestamptz;

alter table public.notification_templates drop constraint if exists notification_templates_event_code_check;
alter table public.notification_templates add constraint notification_templates_event_code_check check (event_code = any(array['offer_sent','offer_accepted','offer_refused','item_received','item_dispatched','payment_sent','order_confirmation','order_dispatched','order_shipping_ready','return_received','refund_issued','valuation_received','valuation_manual_required','customer_buying_request_received']));

drop policy if exists tradeflow_media_retail_fulfilment_customer_select on storage.objects;
create policy tradeflow_media_retail_fulfilment_customer_select on storage.objects as permissive for select to authenticated using (
 bucket_id='tradeflow-media' and (storage.foldername(name))[2]='fulfilments' and exists (
   select 1 from public.fulfilments f join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
   where f.tenant_id::text=(storage.foldername(name))[1] and f.id::text=(storage.foldername(name))[3] and c.auth_user_id=auth.uid()
 )
);

update public.notification_templates set event_code='order_shipping_ready',subject_template='Your order is ready for dispatch',body_template='Your order {{order_reference}} is ready for dispatch.\n\nItem(s): {{item_summary}}\nShipping service: {{shipping_service}}\nCarrier: {{carrier}}\nTracking number: {{tracking_number}}\nTracking link: {{tracking_url}}\nParcel: {{parcel_summary}}\n\nShipping instructions:\n{{shipping_instructions}}\n\nThe shipping label and/or QR code is available in your TradeFlow customer portal. Open {{portal_url}} to view the shipping details and files.',enabled=true,is_system=true,updated_at=now() where template_code='system_order_shipping_ready';
insert into public.notification_templates(event_code,template_code,subject_template,body_template,enabled,is_system)
select 'order_shipping_ready','system_order_shipping_ready','Your order is ready for dispatch','Your order {{order_reference}} is ready for dispatch.\n\nItem(s): {{item_summary}}\nShipping service: {{shipping_service}}\nCarrier: {{carrier}}\nTracking number: {{tracking_number}}\nTracking link: {{tracking_url}}\nParcel: {{parcel_summary}}\n\nShipping instructions:\n{{shipping_instructions}}\n\nThe shipping label and/or QR code is available in your TradeFlow customer portal. Open {{portal_url}} to view the shipping details and files.',true,true
where not exists(select 1 from public.notification_templates where template_code='system_order_shipping_ready');

CREATE OR REPLACE FUNCTION public.subscriber_save_retail_fulfilment_shipping(p_tenant_id uuid, p_fulfilment_id uuid, p_shipping_method text, p_shipping_provider text DEFAULT NULL::text, p_shipping_service_url text DEFAULT NULL::text, p_shipping_carrier text DEFAULT NULL::text, p_shipping_service text DEFAULT NULL::text, p_shipping_tracking_number text DEFAULT NULL::text, p_shipping_tracking_url text DEFAULT NULL::text, p_shipping_label_url text DEFAULT NULL::text, p_shipping_label_storage_path text DEFAULT NULL::text, p_shipping_qr_url text DEFAULT NULL::text, p_shipping_qr_storage_path text DEFAULT NULL::text, p_shipping_instructions text DEFAULT NULL::text, p_weight numeric DEFAULT NULL::numeric, p_length numeric DEFAULT NULL::numeric, p_width numeric DEFAULT NULL::numeric, p_height numeric DEFAULT NULL::numeric, p_notes text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_f public.fulfilments%rowtype; v_o public.retail_orders%rowtype;
v_existing_status text; v_should_notify boolean:=false; v_parcel_id uuid;
v_item_summary text; v_parcel_summary text; v_idempotency text;
begin
 if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'fulfilment.manage') then raise exception 'Not authorised to manage fulfilment'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_label_url,'')='' and coalesce(p_shipping_label_storage_path,'')='' and coalesce(p_shipping_qr_url,'')='' and coalesce(p_shipping_qr_storage_path,'')='' then
   raise exception 'Add a shipping label or QR code before completing the shipping handoff';
 end if;
 if p_shipping_method='automated' and (p_shipping_provider is null or p_shipping_service_url is null) then
   raise exception 'Integrated shipping requires a configured provider';
 end if;

 select * into v_f from public.fulfilments where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
 if not found then raise exception 'Fulfilment not found'; end if;
 select * into v_o from public.retail_orders where tenant_id=p_tenant_id and id=v_f.retail_order_id for update;
 if not found then raise exception 'Retail order not found'; end if;
 if v_o.payment_status<>'paid' or v_o.status not in ('paid','fulfilment','completed') then raise exception 'Retail order is not paid and ready for fulfilment'; end if;

 v_existing_status:=v_f.status; v_should_notify:=v_existing_status='awaiting';

 update public.fulfilments set
   shipping_method=p_shipping_method,shipping_provider=p_shipping_provider,shipping_service_url=p_shipping_service_url,
   shipping_instructions=p_shipping_instructions,carrier=p_shipping_carrier,service=p_shipping_service,
   tracking_number=p_shipping_tracking_number,tracking_url=p_shipping_tracking_url,
   label_url=coalesce(nullif(p_shipping_label_url,''),label_url),
   label_storage_path=coalesce(nullif(p_shipping_label_storage_path,''),label_storage_path),
   qr_url=coalesce(nullif(p_shipping_qr_url,''),qr_url),
   qr_storage_path=coalesce(nullif(p_shipping_qr_storage_path,''),qr_storage_path),
   recipient_name=coalesce(recipient_name,v_o.customer_name),recipient_email=coalesce(recipient_email,v_o.customer_email),
   shipping_address=coalesce(shipping_address,v_o.shipping_address),notes=coalesce(p_notes,notes),
   customer_sent_at=case when v_should_notify then now() else customer_sent_at end,updated_at=now()
 where tenant_id=p_tenant_id and id=p_fulfilment_id;

 select p.id into v_parcel_id from public.fulfilment_parcels p
 where p.tenant_id=p_tenant_id and p.fulfilment_id=p_fulfilment_id order by p.created_at limit 1 for update;

 if v_parcel_id is null then
   insert into public.fulfilment_parcels(tenant_id,fulfilment_id,parcel_reference,status,carrier,service,tracking_number,tracking_url,weight,length,width,height,label_url,notes,metadata)
   values(p_tenant_id,p_fulfilment_id,'PAR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),'label',
          p_shipping_carrier,p_shipping_service,p_shipping_tracking_number,p_shipping_tracking_url,
          p_weight,p_length,p_width,p_height,coalesce(nullif(p_shipping_label_url,''),null),p_notes,
          jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider))
   returning id into v_parcel_id;
 else
   update public.fulfilment_parcels set status=case when status='awaiting' then 'label' else status end,
     carrier=p_shipping_carrier,service=p_shipping_service,tracking_number=p_shipping_tracking_number,tracking_url=p_shipping_tracking_url,
     weight=p_weight,length=p_length,width=p_width,height=p_height,label_url=coalesce(nullif(p_shipping_label_url,''),label_url),
     notes=coalesce(p_notes,notes),metadata=coalesce(metadata,'{}'::jsonb)||jsonb_build_object('shipping_method',p_shipping_method,'provider',p_shipping_provider),updated_at=now()
   where tenant_id=p_tenant_id and id=v_parcel_id;
 end if;

 if v_existing_status='awaiting' then
   perform public.transition_workflow_entity('fulfilment',p_fulfilment_id,'awaiting','label',auth.uid(),
     'Shipping label/QR and customer handoff completed.',jsonb_build_object('source','retail_fulfilment_shipping','parcel_id',v_parcel_id));
 end if;

 select string_agg(case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,', ' order by i.created_at)
 into v_item_summary from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_o.id;
 v_parcel_summary:=trim(coalesce(case when p_weight is not null then p_weight::text||' kg' end,'Weight not recorded')||
   case when p_length is not null or p_width is not null or p_height is not null then ' · '||coalesce(p_length::text,'?')||' × '||coalesce(p_width::text,'?')||' × '||coalesce(p_height::text,'?')||' cm' else '' end);

 if v_should_notify and v_o.customer_email is not null then
   v_idempotency:='order_shipping_ready:'||p_fulfilment_id::text;
   if not exists(select 1 from public.notification_queue q where q.idempotency_key=v_idempotency) then
     insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for)
     values(p_tenant_id,'order_shipping_ready',v_o.customer_email,v_o.customer_name,'Your order is ready for dispatch','system_order_shipping_ready',
       jsonb_build_object('order_reference',v_o.order_reference,'item_summary',coalesce(v_item_summary,'Your order'),
         'shipping_service',coalesce(p_shipping_service,'—'),'carrier',coalesce(p_shipping_carrier,'—'),
         'tracking_number',coalesce(p_shipping_tracking_number,'—'),'tracking_url',coalesce(p_shipping_tracking_url,'—'),
         'parcel_summary',v_parcel_summary,'shipping_instructions',coalesce(p_shipping_instructions,'Follow the shipping instructions shown in your customer portal.'),
         'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'),
       'queued',0,v_idempotency,now());
   end if;
 end if;
 return jsonb_build_object('ok',true,'fulfilment_id',p_fulfilment_id,'status','label','parcel_id',v_parcel_id,'notification_queued',v_should_notify and v_o.customer_email is not null);
end;
$function$
\n\nCREATE OR REPLACE FUNCTION public.subscriber_transition_retail_fulfilment(p_tenant_id uuid, p_fulfilment_id uuid, p_expected_from text, p_to_status text, p_notes text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_f public.fulfilments%rowtype; v_o public.retail_orders%rowtype;
begin
 if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'fulfilment.manage') then raise exception 'Not authorised to manage fulfilment'; end if;
 select * into v_f from public.fulfilments where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
 if not found then raise exception 'Fulfilment not found'; end if;
 if v_f.status<>p_expected_from then raise exception 'Fulfilment status changed. Refresh and try again.'; end if;
 select * into v_o from public.retail_orders where tenant_id=p_tenant_id and id=v_f.retail_order_id;
 if not found then raise exception 'Retail order not found'; end if;
 perform public.transition_workflow_entity('fulfilment',p_fulfilment_id,p_expected_from,p_to_status,auth.uid(),coalesce(p_notes,'Fulfilment status updated.'),jsonb_build_object('source','retail_fulfilment_dashboard'));
 if p_to_status='dispatched' then
   update public.fulfilments set dispatched_at=coalesce(dispatched_at,now()),updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id;
   if v_o.customer_email is not null and not exists(select 1 from public.notification_queue q where q.idempotency_key='order_dispatched:'||p_fulfilment_id::text) then
     insert into public.notification_queue(tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for)
     values(p_tenant_id,'order_dispatched',v_o.customer_email,v_o.customer_name,'Your order has been dispatched','system_order_dispatched',
       jsonb_build_object('order_reference',v_o.order_reference,'item_summary',(select string_agg(i.quantity::text||' × '||i.title,', ' order by i.created_at) from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_o.id),
         'shipping_service',coalesce(v_f.service,'—'),'carrier',coalesce(v_f.carrier,'—'),'tracking_number',coalesce(v_f.tracking_number,'—'),
         'tracking_url',coalesce(v_f.tracking_url,'—'),'shipping_instructions',coalesce(v_f.shipping_instructions,''),'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'),
       'queued',0,'order_dispatched:'||p_fulfilment_id::text,now());
   end if;
 elsif p_to_status='delivered' then
   update public.fulfilments set delivered_at=coalesce(delivered_at,now()),updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id;
 elsif p_to_status='returned' then
   update public.fulfilments set returned_at=coalesce(returned_at,now()),updated_at=now() where tenant_id=p_tenant_id and id=p_fulfilment_id;
 end if;
 return jsonb_build_object('ok',true,'fulfilment_id',p_fulfilment_id,'status',p_to_status);
end;
$function$
\n\nCREATE OR REPLACE FUNCTION public.subscriber_get_retail_fulfilment_shipping(p_tenant_id uuid)
 RETURNS TABLE(fulfilment_id uuid, retail_order_id uuid, fulfilment_reference text, fulfilment_status text, order_reference text, customer_name text, customer_email text, shipping_address jsonb, total numeric, currency text, items jsonb, shipping_method text, shipping_provider text, shipping_service_url text, carrier text, service text, tracking_number text, tracking_url text, label_url text, label_storage_path text, qr_url text, qr_storage_path text, shipping_instructions text, parcel jsonb, created_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if auth.uid() is null or not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 return query
 select f.id,f.retail_order_id,f.fulfilment_reference,f.status,o.order_reference,o.customer_name,o.customer_email,o.shipping_address,o.total,o.currency,
   coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'title',i.title,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total,
     'inventory_asset_id',i.inventory_asset_id,'asset_reference',ia.asset_reference,'condition',coalesce(ia.condition_grade,ia.customer_condition),
     'description',ia.description,'serial_number',ia.serial_number) order by i.created_at)
     from public.retail_order_items i left join public.inventory_assets ia on ia.tenant_id=i.tenant_id and ia.id=i.inventory_asset_id
     where i.tenant_id=o.tenant_id and i.order_id=o.id),'[]'::jsonb),
   f.shipping_method,f.shipping_provider,f.shipping_service_url,f.carrier,f.service,f.tracking_number,f.tracking_url,
   f.label_url,f.label_storage_path,f.qr_url,f.qr_storage_path,f.shipping_instructions,
   (select jsonb_build_object('id',p.id,'parcel_reference',p.parcel_reference,'status',p.status,'weight',p.weight,'length',p.length,'width',p.width,'height',p.height,'label_url',p.label_url,'notes',p.notes,'metadata',p.metadata)
    from public.fulfilment_parcels p where p.tenant_id=f.tenant_id and p.fulfilment_id=f.id order by p.created_at limit 1),
   f.created_at
 from public.fulfilments f join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
 where f.tenant_id=p_tenant_id order by f.created_at desc;
end;$function$
\n\nCREATE OR REPLACE FUNCTION public.customer_get_retail_fulfilment_shipping(p_tenant_id uuid)
 RETURNS TABLE(fulfilment_id uuid, retail_order_id uuid, order_reference text, fulfilment_reference text, fulfilment_status text, carrier text, service text, tracking_number text, tracking_url text, shipping_method text, shipping_provider text, shipping_service_url text, shipping_instructions text, label_url text, label_storage_path text, qr_url text, qr_storage_path text, shipping_address jsonb, items jsonb, parcel jsonb)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 perform private.require_tenant_feature(p_tenant_id,'module.orders');
 return query
 select f.id,f.retail_order_id,o.order_reference,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,
   f.shipping_method,f.shipping_provider,f.shipping_service_url,f.shipping_instructions,f.label_url,f.label_storage_path,f.qr_url,f.qr_storage_path,o.shipping_address,
   coalesce((select jsonb_agg(jsonb_build_object('id',i.id,'title',i.title,'quantity',i.quantity,'unit_price',i.unit_price,'line_total',i.line_total) order by i.created_at)
     from public.retail_order_items i where i.tenant_id=o.tenant_id and i.order_id=o.id),'[]'::jsonb),
   (select jsonb_build_object('id',p.id,'parcel_reference',p.parcel_reference,'weight',p.weight,'length',p.length,'width',p.width,'height',p.height,'label_url',p.label_url,'notes',p.notes)
    from public.fulfilment_parcels p where p.tenant_id=f.tenant_id and p.fulfilment_id=f.id order by p.created_at limit 1)
 from public.fulfilments f join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
 join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
 where f.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
 order by f.created_at desc;
end;$function$

