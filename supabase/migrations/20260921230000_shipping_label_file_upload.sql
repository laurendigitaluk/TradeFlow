-- Shipping label upload support
-- Stores uploaded labels in the existing private tradeflow-media bucket.
-- Customer access is limited to the exact acquisition belonging to the signed-in customer.

alter table public.acquisitions
  add column if not exists shipping_label_storage_path text;

drop policy if exists "tradeflow_media_shipping_label_customer_select" on storage.objects;

create policy "tradeflow_media_shipping_label_customer_select"
on storage.objects
as permissive
for select
to authenticated
using (
  bucket_id = 'tradeflow-media'
  and (storage.foldername(name))[2] = 'acquisitions'
  and exists (
    select 1
    from public.acquisitions a
    join public.customers c
      on c.id = a.customer_id
     and c.tenant_id = a.tenant_id
    where a.tenant_id::text = (storage.foldername(name))[1]
      and a.id::text = (storage.foldername(name))[3]
      and c.auth_user_id = auth.uid()
  )
);

drop function if exists public.customer_get_acquisition_shipping(uuid);

create function public.customer_get_acquisition_shipping(p_tenant_id uuid)
returns table(
  acquisition_id uuid,
  acquisition_reference text,
  status text,
  currency text,
  agreed_total numeric,
  accepted_at timestamptz,
  received_at timestamptz,
  finalised_at timestamptz,
  paid_at timestamptz,
  completed_at timestamptz,
  shipping_label_url text,
  shipping_label_storage_path text,
  shipping_carrier text,
  shipping_service text,
  shipping_tracking_number text,
  shipping_instructions text,
  posted_at timestamptz
)
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_customer_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  limit 1;

  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  return query
  select a.id,
         a.acquisition_reference,
         a.status,
         a.currency,
         a.agreed_total,
         a.accepted_at,
         a.received_at,
         a.finalised_at,
         a.paid_at,
         a.completed_at,
         a.shipping_label_url,
         a.shipping_label_storage_path,
         a.shipping_carrier,
         a.shipping_service,
         a.shipping_tracking_number,
         a.shipping_instructions,
         a.posted_at
  from public.acquisitions a
  where a.tenant_id = p_tenant_id
    and a.customer_id = v_customer_id
  order by a.created_at desc;
end;
$function$;

grant execute on function public.customer_get_acquisition_shipping(uuid) to authenticated, service_role;
