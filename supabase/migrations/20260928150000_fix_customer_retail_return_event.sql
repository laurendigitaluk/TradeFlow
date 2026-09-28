-- Fix customer retail return creation audit.
-- A newly-created return has no previous workflow status, so workflow_transitions
-- cannot represent its initial requested state because from_status is NOT NULL.
-- Record the initial request in the dedicated return_events audit table instead.

create or replace function public.customer_request_return(
  p_tenant_id uuid,
  p_order_item_id uuid,
  p_reason_code text,
  p_reason text,
  p_customer_notes text
)
returns uuid
language plpgsql
security definer
set search_path to 'pg_catalog','public'
as $function$
declare
  v_customer_id uuid;
  v_order_id uuid;
  v_asset_id uuid;
  v_return_id uuid;
  v_fulfilment_status text;
begin
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  if auth.uid() is null then raise exception 'Authentication required'; end if;

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Customer account not found'; end if;

  select oi.order_id,oi.inventory_asset_id into v_order_id,v_asset_id
  from public.retail_order_items oi
  join public.retail_orders o on o.tenant_id=oi.tenant_id and o.id=oi.order_id
  where oi.tenant_id=p_tenant_id
    and oi.id=p_order_item_id
    and o.customer_id=v_customer_id
    and o.status in ('paid','fulfilment','completed')
  limit 1;
  if v_order_id is null then raise exception 'Order item is not eligible for return'; end if;

  select f.status into v_fulfilment_status
  from public.fulfilments f
  where f.tenant_id=p_tenant_id and f.retail_order_id=v_order_id
  order by f.created_at desc limit 1;

  if v_fulfilment_status not in ('dispatched','delivered') then
    raise exception 'A return can be requested once the order has been shipped';
  end if;

  if exists(
    select 1 from public.returns r
    where r.tenant_id=p_tenant_id and r.order_item_id=p_order_item_id
      and r.return_type='customer_retail'
      and r.status not in ('rejected','refunded','replaced','closed')
  ) then
    raise exception 'A return request already exists for this item'; 
  end if;

  insert into public.returns(
    tenant_id,return_type,status,customer_id,order_id,order_item_id,
    inventory_asset_id,reason_code,reason,customer_notes,created_by
  )
  values(
    p_tenant_id,'customer_retail','requested',v_customer_id,v_order_id,p_order_item_id,
    v_asset_id,p_reason_code,p_reason,p_customer_notes,auth.uid()
  )
  returning id into v_return_id;

  insert into public.return_events(
    tenant_id,return_id,event_type,from_status,to_status,notes,actor_user_id
  )
  values(
    p_tenant_id,v_return_id,'requested',null,'requested',
    'Customer retail return requested from customer portal.',auth.uid()
  );

  return v_return_id;
end;
$function$;
