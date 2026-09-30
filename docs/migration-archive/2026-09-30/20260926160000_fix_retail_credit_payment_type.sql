-- Fix retail customer-credit payment type to match payment_records_payment_type_check.
-- payment_type describes the payment transaction; payment_method identifies customer credit.
create or replace function public.customer_pay_retail_order_with_credit(
  p_tenant_id uuid,p_order_id uuid
)
returns table(order_id uuid,order_reference text,status text,amount numeric,currency text,remaining_credit numeric)
language plpgsql security definer set search_path = ''
as $function$
declare
  v_actor uuid := auth.uid();
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
  v_account public.customer_credit_accounts%rowtype;
  v_payment_id uuid;
  v_ledger_id uuid;
  v_remaining numeric;
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
  select a.* into v_account from public.customer_credit_accounts a
  where a.tenant_id=p_tenant_id and a.customer_id=v_customer_id for update;
  if not found then raise exception 'Customer credit account not found'; end if;
  if upper(coalesce(v_account.currency,'GBP'))<>upper(coalesce(v_order.currency,'GBP')) then raise exception 'Customer credit currency does not match the order'; end if;
  if coalesce(v_account.balance,0)<v_order.amount_due then raise exception 'Insufficient customer credit'; end if;

  insert into public.payment_records(
    tenant_id,payment_reference,payment_type,status,direction,amount,currency,payment_method,customer_id,retail_order_id,notes,created_by,processed_at
  ) values(
    p_tenant_id,'PAY-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'customer_payment','paid','inbound',v_order.amount_due,v_order.currency,'customer_credit',v_customer_id,v_order.id,
    'Retail order paid using customer credit account.',v_actor,now()
  ) returning id into v_payment_id;

  insert into public.ledger_entries(
    tenant_id,entry_reference,entry_type,direction,status,amount,currency,customer_id,retail_order_id,description,reference_type,reference_id,created_by,posted_at
  ) values(
    p_tenant_id,'LED-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),
    'payment','credit','posted',v_order.amount_due,v_order.currency,v_customer_id,v_order.id,'Retail order paid using customer credit','payment_record',v_payment_id,v_actor,now()
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

  update public.listings l set status='sold',sold_at=coalesce(l.sold_at,now()),updated_at=now()
  where l.tenant_id=p_tenant_id and l.id in (
    select roi.listing_id from public.retail_order_items roi
    where roi.tenant_id=p_tenant_id and roi.order_id=p_order_id and roi.listing_id is not null
  ) and l.status='reserved';

  update public.inventory_assets ia set status='sold',sold_at=coalesce(ia.sold_at,now()),updated_at=now()
  where ia.tenant_id=p_tenant_id and ia.id in (
    select roi.inventory_asset_id from public.retail_order_items roi
    where roi.tenant_id=p_tenant_id and roi.order_id=p_order_id and roi.inventory_asset_id is not null
  ) and ia.status in ('listed','reserved');

  return query select v_order.id,v_order.order_reference,'paid'::text,v_order.total,v_order.currency,v_remaining;
end;
$function$;
