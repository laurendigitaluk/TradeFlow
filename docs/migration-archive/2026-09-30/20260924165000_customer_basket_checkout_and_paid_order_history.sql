-- Pre-payment products remain in the customer basket and are not customer orders.
-- Checkout creates the retail order only when the customer proceeds to payment.

create or replace function public.customer_create_retail_order_from_basket(
  p_tenant_id uuid,p_listing_ids jsonb,p_shipping_address jsonb default '{}'::jsonb,p_billing_address jsonb default '{}'::jsonb,p_notes text default null
)
returns table(order_id uuid,order_reference text,status text,total numeric,currency text)
language plpgsql security definer set search_path='pg_catalog','public'
as $function$
declare
  v_actor uuid:=auth.uid(); v_customer_id uuid; v_order_id uuid; v_order_reference text;
  v_currency text; v_total numeric:=0; v_count integer:=0; v_listing public.listings%rowtype; v_listing_id uuid;
begin
  if v_actor is null then raise exception 'Authentication required'; end if;
  if p_listing_ids is null or jsonb_typeof(p_listing_ids)<>'array' or jsonb_array_length(p_listing_ids)=0 then raise exception 'Basket is empty'; end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=v_actor and c.status='active' limit 1;
  if v_customer_id is null then raise exception 'Active customer account required'; end if;
  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids) loop
    select l.* into v_listing from public.listings l where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    if not found or v_listing.status<>'published' or coalesce(v_listing.quantity,0)<1 then raise exception 'A basket item is no longer available'; end if;
    if v_currency is null then v_currency:=v_listing.currency; elsif v_currency is distinct from v_listing.currency then raise exception 'Basket items must use the same currency'; end if;
    v_total:=v_total+coalesce(v_listing.asking_price,0); v_count:=v_count+1;
  end loop;
  insert into public.retail_orders(tenant_id,customer_id,channel_id,status,currency,subtotal,shipping_total,tax_total,discount_total,total,payment_status,customer_email,customer_name,shipping_address,billing_address,notes,metadata,trade_in_credit_total,amount_due)
  values(p_tenant_id,v_customer_id,null,'pending_payment',v_currency,v_total,0,0,0,v_total,'unpaid',
    (select email from public.customers where id=v_customer_id and tenant_id=p_tenant_id),
    trim((select first_name||' '||coalesce(last_name,'') from public.customers where id=v_customer_id and tenant_id=p_tenant_id)),
    coalesce(p_shipping_address,'{}'::jsonb),coalesce(p_billing_address,'{}'::jsonb),p_notes,
    jsonb_build_object('source','customer_basket_checkout','basket_count',v_count),0,v_total)
  returning id,order_reference into v_order_id,v_order_reference;
  for v_listing_id in select value::uuid from jsonb_array_elements_text(p_listing_ids) loop
    select l.* into v_listing from public.listings l where l.tenant_id=p_tenant_id and l.id=v_listing_id for update;
    insert into public.retail_order_items(tenant_id,order_id,listing_id,inventory_asset_id,quantity,title,unit_price,discount_amount,tax_amount,line_total,currency,metadata)
    values(p_tenant_id,v_order_id,v_listing.id,v_listing.asset_id,1,v_listing.title,v_listing.asking_price,0,0,v_listing.asking_price,v_listing.currency,jsonb_build_object('source','customer_basket_checkout'));
    update public.listings set status='reserved',reserved_at=coalesce(reserved_at,now()),updated_at=now() where tenant_id=p_tenant_id and id=v_listing.id and status='published';
    if not found then raise exception 'A basket item became unavailable during checkout'; end if;
    insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
    values(p_tenant_id,'listing',v_listing.id,'published','reserved',v_actor,'Reserved by customer basket checkout',jsonb_build_object('source','customer_basket_checkout','order_id',v_order_id));
  end loop;
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'retail_order',v_order_id,'initiated','pending_payment',v_actor,'Customer basket checkout',jsonb_build_object('source','customer_basket_checkout'));
  return query select v_order_id,v_order_reference,'pending_payment'::text,v_total,v_currency;
end;
$function$;
revoke all on function public.customer_create_retail_order_from_basket(uuid,jsonb,jsonb,jsonb,text) from public,anon;
grant execute on function public.customer_create_retail_order_from_basket(uuid,jsonb,jsonb,jsonb,text) to authenticated;

create or replace function public.customer_get_orders(p_tenant_id uuid)
returns table(order_id uuid,order_reference text,channel_id uuid,status text,currency text,subtotal numeric,shipping_total numeric,tax_total numeric,discount_total numeric,total numeric,payment_status text,placed_at timestamptz,paid_at timestamptz,completed_at timestamptz,cancelled_at timestamptz,trade_in_credit_total numeric,amount_due numeric,pricing_version text)
language plpgsql stable security definer set search_path='pg_catalog','public'
as $function$
begin
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  return query select o.id,o.order_reference,o.channel_id,o.status,o.currency,o.subtotal,o.shipping_total,o.tax_total,o.discount_total,o.total,o.payment_status,o.placed_at,o.paid_at,o.completed_at,o.cancelled_at,o.trade_in_credit_total,o.amount_due,o.pricing_version
  from public.retail_orders o join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where o.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
    and (o.payment_status='paid' or o.status in ('paid','fulfilment','completed','partially_refunded','refunded'))
  order by coalesce(o.paid_at,o.completed_at,o.created_at) desc;
end;
$function$;
revoke all on function public.customer_get_orders(uuid) from public,anon;
grant execute on function public.customer_get_orders(uuid) to authenticated;
