create or replace function public.subscriber_publish_shipping_handoff(
 p_tenant_id uuid,p_acquisition_id uuid,p_shipping_method text,p_shipping_label_url text default null,
 p_shipping_label_storage_path text default null,p_shipping_qr_url text default null,p_shipping_qr_storage_path text default null,
 p_shipping_carrier text default null,p_shipping_service text default null,p_shipping_tracking_number text default null,
 p_shipping_instructions text default null,p_shipping_provider text default null,p_shipping_provider_connection_id uuid default null
) returns jsonb language plpgsql security definer set search_path=public,private as $function$
declare v_status text; v_id uuid;
begin
 if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'acquisitions.manage') then raise exception 'Not authorised to manage acquisitions'; end if;
 if p_shipping_method not in ('subscriber_override','automated') then raise exception 'Invalid shipping method'; end if;
 if p_shipping_method='subscriber_override' and coalesce(p_shipping_label_url,'')='' and coalesce(p_shipping_label_storage_path,'')='' and coalesce(p_shipping_qr_url,'')='' and coalesce(p_shipping_qr_storage_path,'')='' then raise exception 'Add a shipping label or QR code before publishing the shipping handoff'; end if;
 if p_shipping_method='automated' and (p_shipping_provider is null or p_shipping_provider_connection_id is null) then raise exception 'Integrated shipping requires a connected provider'; end if;
 select status into v_status from public.acquisitions where id=p_acquisition_id and tenant_id=p_tenant_id for update;
 if v_status is null then raise exception 'Acquisition not found'; end if;
 update public.acquisitions set shipping_method=p_shipping_method,
 shipping_label_url=case when p_shipping_method='subscriber_override' then p_shipping_label_url else shipping_label_url end,
 shipping_label_storage_path=case when p_shipping_method='subscriber_override' then p_shipping_label_storage_path else shipping_label_storage_path end,
 shipping_qr_url=case when p_shipping_method='subscriber_override' then p_shipping_qr_url else shipping_qr_url end,
 shipping_qr_storage_path=case when p_shipping_method='subscriber_override' then p_shipping_qr_storage_path else shipping_qr_storage_path end,
 shipping_carrier=case when p_shipping_method='subscriber_override' then p_shipping_carrier else shipping_carrier end,
 shipping_service=case when p_shipping_method='subscriber_override' then p_shipping_service else shipping_service end,
 shipping_tracking_number=case when p_shipping_method='subscriber_override' then p_shipping_tracking_number else shipping_tracking_number end,
 shipping_instructions=p_shipping_instructions,shipping_provider=p_shipping_provider,
 shipping_provider_connection_id=p_shipping_provider_connection_id,
 shipping_status=case when p_shipping_method='automated' then 'ready_for_customer_quote' else 'ready_for_customer' end,
 shipping_status_updated_at=now(),posted_at=case when p_shipping_method='subscriber_override' then now() else posted_at end,updated_at=now()
 where id=p_acquisition_id and tenant_id=p_tenant_id returning id into v_id;
 if v_status='accepted' then perform public.transition_workflow_entity('acquisition',p_acquisition_id,'accepted','awaiting_item','Subscriber shipping handoff published.'); end if;
 return jsonb_build_object('ok',true,'acquisition_id',v_id,'status','awaiting_item');
end;$function$;
revoke execute on function public.subscriber_publish_shipping_handoff(uuid,uuid,text,text,text,text,text,text,text,text,text,text,uuid) from public,anon;
grant execute on function public.subscriber_publish_shipping_handoff(uuid,uuid,text,text,text,text,text,text,text,text,text,text,uuid) to authenticated;