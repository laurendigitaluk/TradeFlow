-- Migration: retail order fulfilment, customer order detail, and atomic multi-item payment.
-- Applied live as 2026-09-26. This file is the source-controlled replay of the live function definitions.

CREATE OR REPLACE FUNCTION public.customer_get_order_details(p_tenant_id uuid)
 RETURNS TABLE(order_id uuid, order_reference text, order_status text, payment_status text, currency text, subtotal numeric, shipping_total numeric, total numeric, amount_due numeric, paid_at timestamp with time zone, placed_at timestamp with time zone, completed_at timestamp with time zone, item_id uuid, listing_id uuid, inventory_asset_id uuid, item_title text, item_quantity integer, item_unit_price numeric, item_line_total numeric, fulfilment_id uuid, fulfilment_reference text, fulfilment_status text, carrier text, service text, tracking_number text, tracking_url text, label_url text, dispatched_at timestamp with time zone, delivered_at timestamp with time zone)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_customer_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  return query
  select
    o.id,o.order_reference,o.status,o.payment_status,o.currency,o.subtotal,o.shipping_total,o.total,o.amount_due,
    o.paid_at,o.placed_at,o.completed_at,
    i.id,i.listing_id,i.inventory_asset_id,i.title,i.quantity,i.unit_price,i.line_total,
    f.id,f.fulfilment_reference,f.status,f.carrier,f.service,f.tracking_number,f.tracking_url,f.label_url,
    f.dispatched_at,f.delivered_at
  from public.retail_orders o
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  join public.retail_order_items i on i.tenant_id=o.tenant_id and i.order_id=o.id
  left join lateral (
    select f1.*
    from public.fulfilments f1
    where f1.tenant_id=o.tenant_id and f1.retail_order_id=o.id
    order by f1.created_at desc
    limit 1
  ) f on true
  where o.tenant_id=p_tenant_id
    and c.auth_user_id=auth.uid()
    and (o.payment_status='paid' or o.status in ('paid','fulfilment','completed','partially_refunded','refunded'))
  order by coalesce(o.paid_at,o.completed_at,o.created_at) desc,i.created_at;
end;
$function$


CREATE OR REPLACE FUNCTION public.customer_pay_retail_order_with_credit(p_tenant_id uuid, p_order_id uuid)
 RETURNS TABLE(order_id uuid, order_reference text, status text, amount numeric, currency text, remaining_credit numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
  v_account public.customer_credit_accounts%rowtype;
  v_item record;
  v_payment_id uuid;
  v_ledger_id uuid;
  v_remaining numeric;
  v_bad boolean := false;
  v_item_count integer := 0;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id
  from public.customers c
  where c.tenant_id=p_tenant_id
    and c.auth_user_id=v_actor
    and c.status='active'
  limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select o.* into v_order
  from public.retail_orders o
  where o.tenant_id=p_tenant_id
    and o.id=p_order_id
    and o.customer_id=v_customer_id
  for update;
  if not found then raise exception 'Order not found'; end if;
  if v_order.status<>'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
  if coalesce(v_order.amount_due,0)<=0 then raise exception 'Order has no amount due'; end if;

  -- Lock and validate every physical item before taking any credit.
  for v_item in
    select i.id as item_id, i.listing_id, i.inventory_asset_id
    from public.retail_order_items i
    where i.tenant_id=p_tenant_id and i.order_id=p_order_id
    order by i.listing_id
    for update
  loop
    v_item_count := v_item_count + 1;
    if v_item.listing_id is null then
      v_bad := true;
      continue;
    end if;

    perform 1
    from public.listings l
    where l.tenant_id=p_tenant_id
      and l.id=v_item.listing_id
      and l.status='published'
      and coalesce(l.quantity,0)>=1
    for update;

    if not found then v_bad := true; end if;
  end loop;

  if v_item_count=0 then raise exception 'Order contains no products'; end if;
  if v_bad then
    raise exception 'One or more products in this order are no longer available';
  end if;

  select a.* into v_account
  from public.customer_credit_accounts a
  where a.tenant_id=p_tenant_id
    and a.customer_id=v_customer_id
  for update;
  if not found then raise exception 'Customer credit account not found'; end if;
  if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then
    raise exception 'Customer credit currency does not match the order';
  end if;
  if coalesce(v_account.balance,0)<v_order.amount_due then
    raise exception 'Insufficient customer credit';
  end if;

  insert into public.payment_records(
    tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
    customer_id,retail_order_id,notes,created_by,processed_at
  ) values(
    p_tenant_id,
    'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'customer_payment','paid','inbound',v_order.amount_due,v_order.currency,'customer_credit',
    v_customer_id,v_order.id,'Retail order paid using customer credit account.',v_actor,now()
  )
  returning id into v_payment_id;

  insert into public.ledger_entries(
    tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
    description,reference_type,reference_id,created_by,posted_at
  ) values(
    p_tenant_id,
    'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'payment','credit','posted',v_order.amount_due,v_order.currency,v_customer_id,v_order.id,
    'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now()
  )
  returning id into v_ledger_id;

  update public.customer_credit_accounts
  set balance=balance-v_order.amount_due,updated_at=now()
  where id=v_account.id
  returning balance into v_remaining;

  update public.retail_orders
  set status='paid',payment_status='paid',paid_at=now(),amount_due=0,updated_at=now()
  where tenant_id=p_tenant_id and id=v_order.id;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',v_actor,
    'Retail order paid using customer credit',
    jsonb_build_object('source','customer_credit','payment_id',v_payment_id,'ledger_id',v_ledger_id)
  );

  -- Payment claims every item atomically; no partial basket sale.
  for v_item in
    select i.listing_id, i.inventory_asset_id
    from public.retail_order_items i
    where i.tenant_id=p_tenant_id and i.order_id=p_order_id
    order by i.listing_id
  loop
    update public.listings l
    set status='sold',sold_at=coalesce(l.sold_at,now()),updated_at=now()
    where l.tenant_id=p_tenant_id and l.id=v_item.listing_id and l.status='published';

    if v_item.inventory_asset_id is not null then
      update public.inventory_assets ia
      set status='sold',sold_at=coalesce(ia.sold_at,now()),updated_at=now()
      where ia.tenant_id=p_tenant_id and ia.id=v_item.inventory_asset_id and ia.status in ('listed','reserved');
    end if;
  end loop;

  -- Create the customer fulfilment record at payment time so the subscriber
  -- has a concrete order to prepare for dispatch.
  insert into public.fulfilments(
    tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
    shipping_address,notes,metadata
  )
  select
    p_tenant_id,v_order.id,
    'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'awaiting',
    v_order.customer_name,v_order.customer_email,
    coalesce(v_order.shipping_address,'{}'::jsonb),
    'Retail order paid; fulfilment awaiting shipping label.',
    jsonb_build_object('source','retail_payment','payment_id',v_payment_id)
  where not exists (
    select 1 from public.fulfilments f
    where f.tenant_id=p_tenant_id and f.retail_order_id=v_order.id
  );

  return query
  select v_order.id,v_order.order_reference,'paid'::text,v_order.total,v_order.currency,v_remaining;
end;
$function$


CREATE OR REPLACE FUNCTION public.process_external_payment_event(p_provider text, p_event_id text, p_event_type text, p_tenant_id uuid, p_payment_id uuid, p_provider_payment_id text, p_new_status text, p_amount numeric, p_currency text, p_metadata jsonb DEFAULT '{}'::jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_payment public.payment_records%rowtype;
  v_order public.retail_orders%rowtype;
  v_item record;
  v_existing uuid;
  v_item_count integer := 0;
  v_bad boolean := false;
begin
  if current_setting('request.jwt.claim.role',true)<>'service_role' then
    raise exception 'Service role required';
  end if;
  if p_provider is null or p_event_id is null or p_event_type is null then
    raise exception 'Provider event identity required';
  end if;
  if p_new_status not in ('paid','failed','cancelled') then
    raise exception 'Unsupported external payment status';
  end if;

  select id into v_existing
  from public.payment_provider_events
  where provider=p_provider and event_id=p_event_id
  limit 1;
  if v_existing is not null then return true; end if;

  select * into v_payment
  from public.payment_records
  where tenant_id=p_tenant_id and id=p_payment_id
  for update;
  if not found then raise exception 'Payment record not found'; end if;
  if p_provider_payment_id is not null
     and coalesce(v_payment.provider_payment_id,'')<>p_provider_payment_id then
    raise exception 'Provider payment mismatch';
  end if;
  if v_payment.amount<>p_amount or upper(v_payment.currency)<>upper(p_currency) then
    raise exception 'Payment amount or currency mismatch';
  end if;
  if v_payment.status in ('paid','failed','cancelled','refunded','partially_refunded') then
    return true;
  end if;

  if v_payment.retail_order_id is not null and p_new_status='paid' then
    select * into v_order
    from public.retail_orders
    where tenant_id=p_tenant_id and id=v_payment.retail_order_id
    for update;
    if not found then raise exception 'Retail order not found'; end if;
    if v_order.status<>'pending_payment' then raise exception 'Retail order is not awaiting payment'; end if;

    for v_item in
      select i.listing_id
      from public.retail_order_items i
      where i.tenant_id=p_tenant_id and i.order_id=v_order.id
      order by i.listing_id
      for update
    loop
      v_item_count := v_item_count + 1;
      perform 1
      from public.listings l
      where l.tenant_id=p_tenant_id
        and l.id=v_item.listing_id
        and l.status='published'
        and coalesce(l.quantity,0)>=1
      for update;
      if not found then v_bad := true; end if;
    end loop;

    if v_item_count=0 then raise exception 'Retail order contains no products'; end if;
    -- Caller will refund if Stripe payment has already been captured.
    if v_bad then return false; end if;
  end if;

  update public.payment_records
  set status=p_new_status,
      provider=p_provider,
      provider_payment_id=coalesce(provider_payment_id,p_provider_payment_id),
      processed_at=now(),
      updated_at=now(),
      metadata=coalesce(metadata,'{}'::jsonb)||coalesce(p_metadata,'{}'::jsonb)
  where tenant_id=p_tenant_id and id=p_payment_id;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'payment_record',v_payment.id,v_payment.status,p_new_status,null,
    'External payment provider status update',
    jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
  );

  if v_payment.retail_order_id is not null and p_new_status='paid' then
    update public.retail_orders
    set status='paid',payment_status='paid',paid_at=coalesce(paid_at,now()),
        amount_due=0,placed_at=coalesce(placed_at,now()),updated_at=now()
    where tenant_id=p_tenant_id and id=v_order.id;

    insert into public.workflow_transitions(
      tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
    ) values(
      p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',null,
      'External payment provider confirmed payment',
      jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
    );

    insert into public.ledger_entries(
      tenant_id,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
      description,reference_type,reference_id,metadata
    ) values(
      p_tenant_id,'payment','credit','posted',p_amount,p_currency,v_order.customer_id,v_order.id,
      'Retail order payment','retail_order',v_order.id,
      jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
    );

    for v_item in
      select i.listing_id,i.inventory_asset_id
      from public.retail_order_items i
      where i.tenant_id=p_tenant_id and i.order_id=v_order.id
      order by i.listing_id
    loop
      update public.listings l
      set status='sold',sold_at=coalesce(l.sold_at,now()),updated_at=now()
      where l.tenant_id=p_tenant_id and l.id=v_item.listing_id and l.status='published';

      if v_item.inventory_asset_id is not null then
        update public.inventory_assets ia
        set status='sold',sold_at=coalesce(ia.sold_at,now()),updated_at=now()
        where ia.tenant_id=p_tenant_id and ia.id=v_item.inventory_asset_id and ia.status in ('listed','reserved');
      end if;
    end loop;

    insert into public.fulfilments(
      tenant_id,retail_order_id,fulfilment_reference,status,recipient_name,recipient_email,
      shipping_address,notes,metadata
    )
    select
      p_tenant_id,v_order.id,
      'FUL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
      'awaiting',
      v_order.customer_name,v_order.customer_email,
      coalesce(v_order.shipping_address,'{}'::jsonb),
      'Retail order paid; fulfilment awaiting shipping label.',
      jsonb_build_object('source','retail_payment','payment_id',v_payment.id)
    where not exists (
      select 1 from public.fulfilments f
      where f.tenant_id=p_tenant_id and f.retail_order_id=v_order.id
    );

  elsif v_payment.retail_order_id is not null and p_new_status='cancelled' then
    select * into v_order
    from public.retail_orders
    where tenant_id=p_tenant_id and id=v_payment.retail_order_id
    for update;

    if found and v_order.status in ('initiated','pending_payment') then
      update public.retail_orders
      set status='cancelled',cancelled_at=coalesce(cancelled_at,now()),updated_at=now()
      where tenant_id=p_tenant_id and id=v_order.id;

      insert into public.workflow_transitions(
        tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
      ) values(
        p_tenant_id,'retail_order',v_order.id,v_order.status,'cancelled',null,
        'External payment provider cancelled or refunded unpaid retail order',
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
      );

      update public.listings l
      set status='published',reserved_at=null,updated_at=now()
      where l.tenant_id=p_tenant_id
        and l.status='reserved'
        and l.id in (
          select i.listing_id
          from public.retail_order_items i
          where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.listing_id is not null
        );

      update public.inventory_assets ia
      set status='listed',updated_at=now()
      where ia.tenant_id=p_tenant_id
        and ia.status='reserved'
        and ia.id in (
          select i.inventory_asset_id
          from public.retail_order_items i
          where i.tenant_id=p_tenant_id and i.order_id=v_order.id and i.inventory_asset_id is not null
        );
    end if;
  end if;

  insert into public.payment_provider_events(provider,event_id,event_type,metadata)
  values(p_provider,p_event_id,p_event_type,coalesce(p_metadata,'{}'::jsonb))
  on conflict(provider,event_id) do nothing;

  return true;
end;
$function$


grant execute on function public.customer_get_order_details(uuid) to authenticated;
