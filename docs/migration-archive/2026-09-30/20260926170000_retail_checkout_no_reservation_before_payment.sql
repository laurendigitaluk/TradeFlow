-- Live definitions for the no-reservation retail checkout lifecycle.
CREATE OR REPLACE FUNCTION public.customer_create_retail_order(p_tenant_id uuid, p_listing_id uuid, p_shipping_address jsonb DEFAULT '{}'::jsonb, p_billing_address jsonb DEFAULT '{}'::jsonb, p_notes text DEFAULT NULL::text)
 RETURNS TABLE(order_id uuid, order_reference text, status text, total numeric, currency text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_listing public.listings%rowtype;
  v_order_id uuid; v_order_reference text;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select l.* into v_listing from public.listings l
  where l.tenant_id=p_tenant_id and l.id=p_listing_id
  for update;
  if not found then raise exception 'Listing not found'; end if;
  if v_listing.status <> 'published' then raise exception 'Listing is no longer available'; end if;
  if coalesce(v_listing.quantity,0)<1 then raise exception 'Listing has no available quantity'; end if;

  insert into public.retail_orders as ro(
    tenant_id,customer_id,channel_id,status,currency,subtotal,shipping_total,tax_total,discount_total,total,
    payment_status,customer_email,customer_name,shipping_address,billing_address,notes,metadata,
    trade_in_credit_total,amount_due
  ) values(
    p_tenant_id,v_customer_id,v_listing.channel_id,'pending_payment',v_listing.currency,v_listing.asking_price,0,0,0,
    v_listing.asking_price,'unpaid',
    (select email from public.customers where id=v_customer_id and tenant_id=p_tenant_id),
    trim((select first_name||' '||coalesce(last_name,'') from public.customers where id=v_customer_id and tenant_id=p_tenant_id)),
    coalesce(p_shipping_address,'{}'::jsonb),coalesce(p_billing_address,'{}'::jsonb),p_notes,
    jsonb_build_object('source','customer_checkout'),0,v_listing.asking_price
  ) returning ro.id,ro.order_reference into v_order_id,v_order_reference;

  insert into public.retail_order_items(
    tenant_id,order_id,listing_id,inventory_asset_id,quantity,title,unit_price,discount_amount,tax_amount,line_total,currency,metadata
  ) values(
    p_tenant_id,v_order_id,v_listing.id,v_listing.asset_id,1,v_listing.title,v_listing.asking_price,0,0,
    v_listing.asking_price,v_listing.currency,jsonb_build_object('source','customer_checkout')
  );

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order_id,'initiated','pending_payment',v_actor,'Customer checkout',
    jsonb_build_object('source','customer_checkout')
  );

  return query select v_order_id,v_order_reference,'pending_payment'::text,v_listing.asking_price,v_listing.currency;
end;
$function$


CREATE OR REPLACE FUNCTION public.customer_create_retail_order_from_basket(p_tenant_id uuid, p_listing_ids jsonb, p_shipping_address jsonb DEFAULT '{}'::jsonb, p_billing_address jsonb DEFAULT '{}'::jsonb, p_notes text DEFAULT NULL::text)
 RETURNS TABLE(order_id uuid, order_reference text, status text, total numeric, currency text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public'
AS $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_order_id uuid; v_order_reference text;
  v_currency text; v_total numeric:=0; v_count integer:=0; v_listing public.listings%rowtype;
  v_listing_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_listing_ids is null or jsonb_typeof(p_listing_ids)<>'array' or jsonb_array_length(p_listing_ids)=0 then
    raise exception 'Basket is empty';
  end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids)
  loop
    select l.* into v_listing from public.listings l
    where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then
      raise exception 'A basket item is no longer available';
    end if;
    if v_currency is null then v_currency:=v_listing.currency;
    elsif v_currency is distinct from v_listing.currency then raise exception 'Basket items must use the same currency'; end if;
    v_total:=v_total+coalesce(v_listing.asking_price,0); v_count:=v_count+1;
  end loop;

  insert into public.retail_orders as ro(
    tenant_id,customer_id,channel_id,status,currency,subtotal,shipping_total,tax_total,discount_total,total,
    payment_status,customer_email,customer_name,shipping_address,billing_address,notes,metadata,trade_in_credit_total,amount_due
  ) values(
    p_tenant_id,v_customer_id,null,'pending_payment',v_currency,v_total,0,0,0,v_total,'unpaid',
    (select email from public.customers where id=v_customer_id and tenant_id=p_tenant_id),
    trim((select first_name||' '||coalesce(last_name,'') from public.customers where id=v_customer_id and tenant_id=p_tenant_id)),
    coalesce(p_shipping_address,'{}'::jsonb),coalesce(p_billing_address,'{}'::jsonb),p_notes,
    jsonb_build_object('source','customer_basket_checkout','basket_count',v_count),0,v_total
  ) returning ro.id,ro.order_reference into v_order_id,v_order_reference;

  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids)
  loop
    select l.* into v_listing from public.listings l
    where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then
      raise exception 'A basket item became unavailable during checkout';
    end if;
    insert into public.retail_order_items(
      tenant_id,order_id,listing_id,inventory_asset_id,quantity,title,unit_price,discount_amount,tax_amount,line_total,currency,metadata
    ) values(
      p_tenant_id,v_order_id,v_listing.id,v_listing.asset_id,1,v_listing.title,v_listing.asking_price,0,0,
      v_listing.asking_price,v_listing.currency,jsonb_build_object('source','customer_basket_checkout')
    );
  end loop;

  insert into public.workflow_transitions(
    tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata
  ) values(
    p_tenant_id,'retail_order',v_order_id,'initiated','pending_payment',v_actor,'Customer basket checkout',
    jsonb_build_object('source','customer_basket_checkout')
  );

  return query select v_order_id,v_order_reference,'pending_payment'::text,v_total,v_currency;
end;
$function$


CREATE OR REPLACE FUNCTION public.customer_pay_retail_order_with_credit(p_tenant_id uuid, p_order_id uuid)
 RETURNS TABLE(order_id uuid, order_reference text, status text, amount numeric, currency text, remaining_credit numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_order public.retail_orders%rowtype;
  v_account public.customer_credit_accounts%rowtype; v_listing public.listings%rowtype;
  v_payment_id uuid; v_ledger_id uuid; v_remaining numeric;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');

  select c.id into v_customer_id from public.customers c
  where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;

  select o.* into v_order from public.retail_orders o
  where o.tenant_id=p_tenant_id and o.id=p_order_id and o.customer_id=v_customer_id for update;
  if not found then raise exception 'Order not found'; end if;
  if v_order.status<>'pending_payment' then raise exception 'Order is not awaiting payment'; end if;
  if coalesce(v_order.amount_due,0)<=0 then raise exception 'Order has no amount due'; end if;

  select l.* into v_listing
  from public.listings l
  where l.tenant_id=p_tenant_id
    and l.id=(select i.listing_id from public.retail_order_items i where i.tenant_id=p_tenant_id and i.order_id=p_order_id order by i.created_at limit 1)
  for update;
  if not found then raise exception 'Product is no longer available'; end if;
  if v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then
    raise exception 'This product has already been purchased by another customer or is no longer available';
  end if;

  select a.* into v_account from public.customer_credit_accounts a
  where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id for update;
  if not found then raise exception 'Customer credit account not found'; end if;
  if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then
    raise exception 'Customer credit currency does not match the order';
  end if;
  if coalesce(v_account.balance,0)<v_order.amount_due then raise exception 'Insufficient customer credit'; end if;

  insert into public.payment_records(
    tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,
    customer_id,retail_order_id,notes,created_by,processed_at
  ) values(
    p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'customer_payment','paid','inbound',v_order.amount_due,v_order.currency,'customer_credit',
    v_customer_id,v_order.id,'Retail order paid using customer credit account.',v_actor,now()
  ) returning id into v_payment_id;

  insert into public.ledger_entries(
    tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,
    description,reference_type,reference_id,created_by,posted_at
  ) values(
    p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'payment','credit','posted',v_order.amount_due,v_order.currency,v_customer_id,v_order.id,
    'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now()
  ) returning id into v_ledger_id;

  update public.customer_credit_accounts set balance=balance-v_order.amount_due,updated_at=now()
  where id=v_account.id returning balance into v_remaining;

  update public.retail_orders set status='paid',payment_status='paid',paid_at=now(),amount_due=0,updated_at=now()
  where tenant_id=p_tenant_id and id=v_order.id;

  perform public.transition_workflow_entity(
    p_tenant_id,'retail_order',v_order.id,'pending_payment','paid',
    'Retail order paid using customer credit',
    jsonb_build_object('source','customer_credit','payment_id',v_payment_id,'ledger_id',v_ledger_id)
  );

  update public.listings set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
  where tenant_id=p_tenant_id and id=v_listing.id and status='published';

  update public.inventory_assets set status='sold',sold_at=coalesce(sold_at,now()),updated_at=now()
  where tenant_id=p_tenant_id and id=v_listing.asset_id and status in ('listed','reserved');

  return query select v_order.id,v_order.order_reference,'paid'::text,v_order.total,v_order.currency,v_remaining;
end;
$function$

