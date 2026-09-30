CREATE OR REPLACE FUNCTION public.process_external_payment_event(p_provider text, p_event_id text, p_event_type text, p_tenant_id uuid, p_payment_id uuid, p_provider_payment_id text, p_new_status text, p_amount numeric, p_currency text, p_metadata jsonb DEFAULT '{}'::jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_payment public.payment_records%rowtype;
  v_order public.retail_orders%rowtype;
  v_existing uuid;
begin
  if current_setting('request.jwt.claim.role', true) <> 'service_role' then
    raise exception 'Service role required';
  end if;
  if p_provider is null or p_event_id is null or p_event_type is null then
    raise exception 'Provider event identity required';
  end if;
  if p_new_status not in ('paid','failed','cancelled') then
    raise exception 'Unsupported external payment status';
  end if;

  insert into public.payment_provider_events(provider,event_id,event_type,metadata)
  values(p_provider,p_event_id,p_event_type,coalesce(p_metadata,'{}'::jsonb))
  on conflict(provider,event_id) do nothing
  returning id into v_existing;
  if v_existing is null then return true; end if;

  select * into v_payment
  from public.payment_records
  where tenant_id=p_tenant_id and id=p_payment_id
  for update;
  if not found then raise exception 'Payment record not found'; end if;
  if p_provider_payment_id is not null
     and coalesce(v_payment.provider_payment_id,'') <> p_provider_payment_id
  then
    raise exception 'Provider payment mismatch';
  end if;
  if v_payment.amount <> p_amount
     or upper(v_payment.currency) <> upper(p_currency)
  then
    raise exception 'Payment amount or currency mismatch';
  end if;
  if v_payment.status in ('paid','failed','cancelled','refunded','partially_refunded') then
    return true;
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
  )
  values(
    p_tenant_id,'payment_record',v_payment.id,v_payment.status,p_new_status,null,
    'External payment provider status update',
    jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
  );

  if v_payment.retail_order_id is not null and p_new_status in ('paid','cancelled') then
    select * into v_order
    from public.retail_orders
    where tenant_id=p_tenant_id and id=v_payment.retail_order_id
    for update;
    if not found then raise exception 'Retail order not found'; end if;

    if p_new_status='paid' then
      if v_order.status <> 'pending_payment' then
        raise exception 'Retail order is not awaiting payment';
      end if;

      update public.retail_orders
      set status='paid',
          payment_status='paid',
          paid_at=coalesce(paid_at,now()),
          amount_due=0,
          placed_at=coalesce(placed_at,now()),
          updated_at=now()
      where tenant_id=p_tenant_id and id=v_order.id;

      insert into public.workflow_transitions(
        tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
      )
      values(
        p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',null,
        'External payment provider confirmed payment',
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
      );

      insert into public.ledger_entries(
        tenant_id,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
        description,reference_type,reference_id,metadata
      )
      values(
        p_tenant_id,'payment','credit','posted',p_amount,p_currency,v_order.customer_id,v_order.id,
        'Retail order payment','retail_order',v_order.id,
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
      );

      update public.listings l
      set status='sold',
          sold_at=coalesce(l.sold_at,now()),
          updated_at=now()
      where l.tenant_id=p_tenant_id
        and l.status='reserved'
        and l.id in (
          select i.listing_id
          from public.retail_order_items i
          where i.tenant_id=p_tenant_id
            and i.order_id=v_order.id
            and i.listing_id is not null
        );

      update public.inventory_assets ia
      set status='sold',
          sold_at=coalesce(ia.sold_at,now()),
          updated_at=now()
      where ia.tenant_id=p_tenant_id
        and ia.status in ('listed','reserved')
        and ia.id in (
          select i.inventory_asset_id
          from public.retail_order_items i
          where i.tenant_id=p_tenant_id
            and i.order_id=v_order.id
            and i.inventory_asset_id is not null
        );

    elsif p_new_status='cancelled' and v_order.status in ('initiated','pending_payment') then
      update public.retail_orders
      set status='cancelled',
          cancelled_at=coalesce(cancelled_at,now()),
          updated_at=now()
      where tenant_id=p_tenant_id and id=v_order.id;

      insert into public.workflow_transitions(
        tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
      )
      values(
        p_tenant_id,'retail_order',v_order.id,v_order.status,'cancelled',null,
        'Stripe Checkout session expired or was cancelled',
        jsonb_build_object('source','external_payment_provider','provider',p_provider,'event_id',p_event_id)
      );

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
            and i.order_id=v_order.id
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
            and i.order_id=v_order.id
            and i.inventory_asset_id is not null
        );
    end if;
  end if;

  return true;
end;
$function$

