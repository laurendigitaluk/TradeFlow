create or replace function public.subscriber_transition_retail_fulfilment(
  p_tenant_id uuid,p_fulfilment_id uuid,p_expected_from text,p_to_status text,p_notes text default null
) returns jsonb language plpgsql security definer set search_path='' as $function$
declare
  v_f public.fulfilments%rowtype; v_o public.retail_orders%rowtype; v_tracking_url text;
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'fulfilment.manage') then
    raise exception 'Not authorised to manage fulfilment';
  end if;
  select * into v_f from public.fulfilments where tenant_id=p_tenant_id and id=p_fulfilment_id for update;
  if not found then raise exception 'Fulfilment not found'; end if;
  if v_f.status<>p_expected_from then raise exception 'Fulfilment status changed. Refresh and try again.'; end if;
  select * into v_o from public.retail_orders where tenant_id=p_tenant_id and id=v_f.retail_order_id for update;
  if not found then raise exception 'Retail order not found'; end if;
  if p_to_status not in ('dispatched','delivered','returned') then raise exception 'Invalid retail fulfilment transition: %',p_to_status; end if;

  if p_to_status='dispatched' then
    if v_o.status='paid' then
      perform public.transition_workflow_entity(p_tenant_id,'retail_order',v_o.id,'paid','fulfilment',
        coalesce(p_notes,'Shipment dispatched.'),
        jsonb_build_object('source','selling-dashboard','fulfilment_id',p_fulfilment_id));
    elsif v_o.status<>'fulfilment' then
      raise exception 'Retail order is not in a dispatchable state: %',v_o.status;
    end if;

    v_tracking_url:=nullif(trim(v_f.tracking_url),'');
    if v_tracking_url is null and nullif(trim(v_f.tracking_number),'') is not null then
      case lower(regexp_replace(coalesce(v_f.carrier,v_f.service,''),'[^a-z0-9]','','g'))
        when 'evri' then v_tracking_url:='https://www.evri.com/track-a-parcel';
        when 'royalmail' then v_tracking_url:='https://www.royalmail.com/track-your-item';
        when 'dpd' then v_tracking_url:='https://www.dpd.co.uk/track';
        when 'inpost' then v_tracking_url:='https://inpost.co.uk/tracking';
        when 'dhl' then v_tracking_url:='https://www.dhl.com/gb-en/home/tracking.html';
        when 'ups' then v_tracking_url:='https://www.ups.com/gb/en/track';
        when 'parcels2go' then v_tracking_url:='https://www.parcel2go.com/tracking';
        else null;
      end case;
    end if;

    perform public.transition_workflow_entity(p_tenant_id,'fulfilment',p_fulfilment_id,'label','dispatched',
      coalesce(p_notes,'Shipment dispatched.'),
      jsonb_build_object('source','selling-dashboard','retail_order_id',v_o.id));

    update public.fulfilments
      set tracking_url=coalesce(v_tracking_url,tracking_url),dispatched_at=coalesce(dispatched_at,now()),updated_at=now()
      where tenant_id=p_tenant_id and id=p_fulfilment_id;

    if v_o.customer_email is not null and not exists(
      select 1 from public.notification_queue q where q.idempotency_key='order_dispatched:'||p_fulfilment_id::text
    ) then
      insert into public.notification_queue(
        tenant_id,event_code,recipient_email,recipient_name,subject,template_code,payload,status,attempts,idempotency_key,scheduled_for
      ) values(
        p_tenant_id,'order_dispatched',v_o.customer_email,v_o.customer_name,'Your order has been dispatched','system_order_dispatched',
        jsonb_build_object(
          'order_reference',v_o.order_reference,
          'item_summary',(select string_agg(case when i.quantity>1 then i.quantity::text||' × ' else '' end||i.title,', ' order by i.created_at)
            from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=v_o.id),
          'shipping_service',coalesce(v_f.service,'—'),'carrier',coalesce(v_f.carrier,'—'),
          'tracking_number',coalesce(v_f.tracking_number,'—'),'tracking_url',coalesce(v_tracking_url,v_f.tracking_url,'—'),
          'shipping_instructions',coalesce(v_f.shipping_instructions,''),
          'portal_url','https://laurendigitaluk.github.io/TradeFlow/customer-dashboard.html'
        ),'queued',0,'order_dispatched:'||p_fulfilment_id::text,now()
      );
    end if;

  elsif p_to_status='delivered' then
    perform public.transition_workflow_entity(p_tenant_id,'fulfilment',p_fulfilment_id,'dispatched','delivered',
      coalesce(p_notes,'Fulfilment delivered.'),jsonb_build_object('source','retail_fulfilment_dashboard'));
  else
    perform public.transition_workflow_entity(p_tenant_id,'fulfilment',p_fulfilment_id,'dispatched','returned',
      coalesce(p_notes,'Fulfilment returned.'),jsonb_build_object('source','retail_fulfilment_dashboard'));
  end if;

  return jsonb_build_object('ok',true,'fulfilment_id',p_fulfilment_id,'status',p_to_status,'retail_order_id',v_o.id,
    'retail_order_status',case when p_to_status='dispatched' then 'fulfilment' else v_o.status end,
    'tracking_url',coalesce(v_tracking_url,v_f.tracking_url));
end;
$function$;