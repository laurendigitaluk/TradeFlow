-- Return shipping does not require uploading a copy of the shipping label to TradeFlow.
create or replace function public.subscriber_publish_buying_item_return_shipping(
 p_tenant_id uuid,p_buying_item_id uuid,p_shipping_method text default 'subscriber_override',
 p_shipping_label_url text default null,p_shipping_label_storage_path text default null,
 p_shipping_qr_url text default null,p_shipping_qr_storage_path text default null,
 p_shipping_carrier text default null,p_shipping_service text default null,
 p_shipping_tracking_number text default null,p_shipping_tracking_url text default null,
 p_shipping_instructions text default null,p_shipping_provider text default null,p_shipping_service_url text default null)
returns jsonb language plpgsql security definer set search_path to 'public','private'
as $function$
declare v_actor uuid:=auth.uid();v_stage text;
begin
 if v_actor is null or not private.has_tenant_permission(p_tenant_id,v_actor,'buying.manage') then raise exception 'Permission required: buying.manage'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 select purchase_stage into v_stage from public.buying_items where tenant_id=p_tenant_id and id=p_buying_item_id for update;
 if v_stage is null then raise exception 'Buying item not found'; end if;
 if v_stage<>'return_pending' then raise exception 'Buying item is not awaiting return shipping'; end if;
 if coalesce(trim(p_shipping_tracking_number),'')='' then raise exception 'Enter the return tracking number before sending the return update'; end if;
 insert into public.buying_item_return_shipping(
  tenant_id,buying_item_id,shipping_method,shipping_label_url,shipping_label_storage_path,
  shipping_qr_url,shipping_qr_storage_path,shipping_carrier,shipping_service,
  shipping_tracking_number,shipping_tracking_url,shipping_instructions,shipping_provider,
  shipping_service_url,shipping_status,shipping_status_updated_at,shipped_at)
 values(
  p_tenant_id,p_buying_item_id,p_shipping_method,p_shipping_label_url,p_shipping_label_storage_path,
  p_shipping_qr_url,p_shipping_qr_storage_path,p_shipping_carrier,p_shipping_service,
  p_shipping_tracking_number,p_shipping_tracking_url,p_shipping_instructions,p_shipping_provider,
  p_shipping_service_url,'return_shipped',now(),now())
 on conflict(buying_item_id) do update set
  shipping_method=excluded.shipping_method,
  shipping_label_url=coalesce(excluded.shipping_label_url,buying_item_return_shipping.shipping_label_url),
  shipping_label_storage_path=coalesce(excluded.shipping_label_storage_path,buying_item_return_shipping.shipping_label_storage_path),
  shipping_qr_url=coalesce(excluded.shipping_qr_url,buying_item_return_shipping.shipping_qr_url),
  shipping_qr_storage_path=coalesce(excluded.shipping_qr_storage_path,buying_item_return_shipping.shipping_qr_storage_path),
  shipping_carrier=excluded.shipping_carrier,shipping_service=excluded.shipping_service,
  shipping_tracking_number=excluded.shipping_tracking_number,shipping_tracking_url=excluded.shipping_tracking_url,
  shipping_instructions=excluded.shipping_instructions,shipping_provider=excluded.shipping_provider,
  shipping_service_url=excluded.shipping_service_url,shipping_status='return_shipped',
  shipping_status_updated_at=now(),shipped_at=now(),updated_at=now();
 insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,notes,metadata,actor_user_id)
 values(p_tenant_id,'buying_item',p_buying_item_id,'return_pending','return_shipped',
  coalesce(p_shipping_instructions,'Return shipped to customer.'),
  jsonb_build_object('source','buying_return_shipping','tracking_number',p_shipping_tracking_number),v_actor);
 return jsonb_build_object('ok',true,'buying_item_id',p_buying_item_id,'status','return_shipped');
end;$function$;
grant execute on function public.subscriber_publish_buying_item_return_shipping(uuid,uuid,text,text,text,text,text,text,text,text,text,text,text,text) to authenticated;