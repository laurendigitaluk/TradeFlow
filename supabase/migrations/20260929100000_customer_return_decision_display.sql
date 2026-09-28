-- Expose customer retail return decision metadata and secure return labels
drop function if exists public.customer_get_returns(uuid);
create function public.customer_get_returns(p_tenant_id uuid)
returns table(
  return_id uuid, return_reference text, return_type text, status text,
  order_id uuid, order_item_id uuid, reason_code text, reason text,
  requested_at timestamptz, authorised_at timestamptz, received_at timestamptz,
  inspected_at timestamptz, resolved_at timestamptz, closed_at timestamptz,
  refund_amount numeric, currency text, metadata jsonb
)
language plpgsql stable security definer set search_path=pg_catalog,public
as $$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  return query
  select r.id,r.return_reference,r.return_type,r.status,r.order_id,r.order_item_id,
         r.reason_code,r.reason,r.requested_at,r.authorised_at,r.received_at,
         r.inspected_at,r.resolved_at,r.closed_at,r.refund_amount,r.currency,r.metadata
  from public.returns r
  join public.customers c on c.tenant_id=r.tenant_id and c.id=r.customer_id
  where r.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by r.created_at desc;
end;
$$;
grant execute on function public.customer_get_returns(uuid) to authenticated;

drop policy if exists tradeflow_media_customer_return_label_subscriber_insert on storage.objects;
create policy tradeflow_media_customer_return_label_subscriber_insert
on storage.objects for insert to authenticated
with check (
  bucket_id='tradeflow-media'
  and (storage.foldername(name))[2]='returns'
  and private.is_tenant_member(((storage.foldername(name))[1])::uuid,auth.uid())
);

drop policy if exists tradeflow_media_customer_return_label_subscriber_select on storage.objects;
create policy tradeflow_media_customer_return_label_subscriber_select
on storage.objects for select to authenticated
using (
  bucket_id='tradeflow-media'
  and (storage.foldername(name))[2]='returns'
  and private.is_tenant_member(((storage.foldername(name))[1])::uuid,auth.uid())
);

drop policy if exists tradeflow_media_customer_return_label_customer_select on storage.objects;
create policy tradeflow_media_customer_return_label_customer_select
on storage.objects for select to authenticated
using (
  bucket_id='tradeflow-media'
  and (storage.foldername(name))[2]='returns'
  and exists (
    select 1 from public.returns r
    join public.customers c on c.id=r.customer_id and c.tenant_id=r.tenant_id
    where r.tenant_id=((storage.foldername(name))[1])::uuid
      and r.id=((storage.foldername(name))[3])::uuid
      and c.auth_user_id=auth.uid()
  )
);
