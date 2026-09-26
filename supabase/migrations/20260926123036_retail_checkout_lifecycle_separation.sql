CREATE OR REPLACE FUNCTION public.customer_get_retail_order_for_checkout(p_tenant_id uuid, p_order_id uuid)
 RETURNS TABLE(order_id uuid, order_reference text, status text, payment_status text, currency text, subtotal numeric, shipping_total numeric, tax_total numeric, discount_total numeric, total numeric, amount_due numeric, placed_at timestamp with time zone, listing_id uuid, inventory_asset_id uuid, title text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_customer_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id
    into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and c.status='active'
  limit 1;

  if v_customer_id is null then
    raise exception 'Active customer account required';
  end if;

  return query
  select
    o.id,
    o.order_reference,
    o.status,
    o.payment_status,
    o.currency,
    o.subtotal,
    o.shipping_total,
    o.tax_total,
    o.discount_total,
    o.total,
    o.amount_due,
    o.placed_at,
    roi.listing_id,
    roi.inventory_asset_id,
    roi.title
  from public.retail_orders o
  left join lateral (
    select i.listing_id, i.inventory_asset_id, i.title
    from public.retail_order_items i
    where i.tenant_id=o.tenant_id
      and i.order_id=o.id
    order by i.created_at
    limit 1
  ) roi on true
  where o.tenant_id=p_tenant_id
    and o.id=p_order_id
    and o.customer_id=v_customer_id
    and o.status='pending_payment';
end;
$function$


CREATE OR REPLACE FUNCTION public.customer_cancel_retail_order(p_tenant_id uuid, p_order_id uuid, p_reason text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and c.status='active'
  limit 1;

  if v_customer_id is null then
    raise exception 'Customer account not found';
  end if;

  select *
    into v_order
  from public.retail_orders
  where tenant_id=p_tenant_id
    and id=p_order_id
    and customer_id=v_customer_id
  for update;

  if v_order.id is null then
    raise exception 'Order not found or not owned by current customer';
  end if;

  if v_order.status not in ('initiated','pending_payment') then
    raise exception 'This order can no longer be cancelled';
  end if;

  update public.retail_orders
  set status='cancelled',
      cancelled_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id
    and id=p_order_id;

  update public.listings l
  set status='published',
      reserved_at=null,
      updated_at=now()
  where l.tenant_id=p_tenant_id
    and l.status='reserved'
    and l.id in (
      select i.listing_id
      from public.retail_order_items i
      where i.tenant_id=p_tenant_id
        and i.order_id=p_order_id
        and i.listing_id is not null
    );

  update public.inventory_assets ia
  set status='listed',
      updated_at=now()
  where ia.tenant_id=p_tenant_id
    and ia.status='reserved'
    and ia.id in (
      select i.inventory_asset_id
      from public.retail_order_items i
      where i.tenant_id=p_tenant_id
        and i.order_id=p_order_id
        and i.inventory_asset_id is not null
    );

  update public.payment_records pr
  set status='cancelled',
      processed_at=coalesce(pr.processed_at,now()),
      updated_at=now()
  where pr.tenant_id=p_tenant_id
    and pr.retail_order_id=p_order_id
    and pr.status in ('pending','processing');

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  )
  values(
    p_tenant_id,
    'retail_order',
    p_order_id,
    v_order.status,
    'cancelled',
    auth.uid(),
    nullif(trim(p_reason),''),
    jsonb_build_object('source','customer_action')
  );

  return jsonb_build_object(
    'order_id',v_order.id,
    'order_reference',v_order.order_reference,
    'status','cancelled'
  );
end;
$function$


revoke execute on function public.customer_get_retail_order_for_checkout(uuid,uuid) from public, anon;
grant execute on function public.customer_get_retail_order_for_checkout(uuid,uuid) to authenticated;
