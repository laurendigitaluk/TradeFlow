drop function if exists public.customer_get_acquisition_shipping(uuid);
create or replace function public.customer_get_acquisition_shipping(p_tenant_id uuid)
returns table(
 acquisition_id uuid, acquisition_reference text, status text, currency text, agreed_total numeric,
 accepted_at timestamptz, received_at timestamptz, finalised_at timestamptz, paid_at timestamptz, completed_at timestamptz,
 shipping_method text, shipping_provider text, shipping_provider_order_id text, shipping_quote_session_id uuid,
 shipping_payment_url text, shipping_tracking_url text, shipping_status text, shipping_status_updated_at timestamptz,
 shipping_label_url text, shipping_label_storage_path text, shipping_qr_url text, shipping_qr_storage_path text,
 shipping_carrier text, shipping_service text, shipping_tracking_number text, shipping_instructions text, posted_at timestamptz,
 shipping_parcel_weight numeric, shipping_parcel_length numeric, shipping_parcel_width numeric, shipping_parcel_height numeric
)
language plpgsql security definer set search_path to ''
as $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select a.id,a.acquisition_reference,a.status,a.currency,a.agreed_total,a.accepted_at,a.received_at,a.finalised_at,a.paid_at,a.completed_at,
 a.shipping_method,a.shipping_provider,a.shipping_provider_order_id,a.shipping_quote_session_id,a.shipping_payment_url,a.shipping_tracking_url,
 a.shipping_status,a.shipping_status_updated_at,a.shipping_label_url,a.shipping_label_storage_path,a.shipping_qr_url,a.shipping_qr_storage_path,
 a.shipping_carrier,a.shipping_service,a.shipping_tracking_number,a.shipping_instructions,a.posted_at,
 a.shipping_parcel_weight,a.shipping_parcel_length,a.shipping_parcel_width,a.shipping_parcel_height
 from public.acquisitions a where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id order by a.created_at desc;
end;$function$;
grant execute on function public.customer_get_acquisition_shipping(uuid) to authenticated;
grant execute on function public.customer_get_acquisition_shipping(uuid) to service_role;