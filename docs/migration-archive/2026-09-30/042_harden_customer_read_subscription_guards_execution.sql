-- Migration 042: make customer read subscription guards execute as hard preconditions.
-- The prior SQL read-RPC form used a VOID guard inside a WHERE expression; PostgreSQL could
-- optimize that expression without invoking the guard. These functions are intentionally
-- converted to PL/pgSQL so the guard is executed with PERFORM before RETURN QUERY.

CREATE OR REPLACE FUNCTION public.customer_get_trade_ins(p_tenant_id uuid)
RETURNS TABLE(trade_in_id uuid, trade_in_reference text, status text, valuation_method text, trading_value numeric, cash_price numeric, trade_in_price numeric, credit_amount numeric, currency text, requested_at timestamptz, valued_at timestamptz, accepted_at timestamptz, received_at timestamptz, credited_at timestamptz, completed_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.trade_in');
  return query
  select t.id, t.trade_in_reference, t.status, t.valuation_method, t.trading_value,
         t.cash_price, t.trade_in_price, t.credit_amount, t.currency, t.requested_at,
         t.valued_at, t.accepted_at, t.received_at, t.credited_at, t.completed_at
  from public.trade_in_transactions t
  join public.customers c on c.tenant_id=t.tenant_id and c.id=t.customer_id
  where t.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by t.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_order_trade_ins(p_tenant_id uuid)
RETURNS TABLE(bridge_id uuid, retail_order_id uuid, trade_in_transaction_id uuid, credit_amount numeric, currency text, status text, applied_at timestamptz, reversed_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.trade_in');
  return query
  select b.id, b.retail_order_id, b.trade_in_transaction_id, b.credit_amount, b.currency,
         b.status, b.applied_at, b.reversed_at
  from public.retail_order_trade_ins b
  join public.retail_orders o on o.tenant_id=b.tenant_id and o.id=b.retail_order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  join public.trade_in_transactions t on t.tenant_id=b.tenant_id and t.id=b.trade_in_transaction_id and t.customer_id=c.id
  where b.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by b.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_orders(p_tenant_id uuid)
RETURNS TABLE(order_id uuid, order_reference text, channel_id uuid, status text, currency text, subtotal numeric, shipping_total numeric, tax_total numeric, discount_total numeric, total numeric, payment_status text, placed_at timestamptz, paid_at timestamptz, completed_at timestamptz, cancelled_at timestamptz, trade_in_credit_total numeric, amount_due numeric, pricing_version text)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.orders');
  return query
  select o.id, o.order_reference, o.channel_id, o.status, o.currency, o.subtotal, o.shipping_total,
         o.tax_total, o.discount_total, o.total, o.payment_status, o.placed_at, o.paid_at,
         o.completed_at, o.cancelled_at, o.trade_in_credit_total, o.amount_due, o.pricing_version
  from public.retail_orders o
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where o.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by o.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_order_items(p_tenant_id uuid)
RETURNS TABLE(order_item_id uuid, order_id uuid, listing_id uuid, inventory_asset_id uuid, quantity integer, title text, unit_price numeric, discount_amount numeric, tax_amount numeric, line_total numeric, currency text, created_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.orders');
  return query
  select oi.id, oi.order_id, oi.listing_id, oi.inventory_asset_id, oi.quantity, oi.title,
         oi.unit_price, oi.discount_amount, oi.tax_amount, oi.line_total, oi.currency, oi.created_at
  from public.retail_order_items oi
  join public.retail_orders o on o.tenant_id=oi.tenant_id and o.id=oi.order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where oi.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by oi.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_fulfilments(p_tenant_id uuid)
RETURNS TABLE(fulfilment_id uuid, retail_order_id uuid, fulfilment_reference text, status text, carrier text, service text, tracking_number text, tracking_url text, recipient_name text, dispatched_at timestamptz, delivered_at timestamptz, returned_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.fulfilment');
  return query
  select f.id, f.retail_order_id, f.fulfilment_reference, f.status, f.carrier, f.service,
         f.tracking_number, f.tracking_url, f.recipient_name, f.dispatched_at,
         f.delivered_at, f.returned_at
  from public.fulfilments f
  join public.retail_orders o on o.tenant_id=f.tenant_id and o.id=f.retail_order_id
  join public.customers c on c.tenant_id=o.tenant_id and c.id=o.customer_id
  where f.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by f.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_returns(p_tenant_id uuid)
RETURNS TABLE(return_id uuid, return_reference text, return_type text, status text, order_id uuid, order_item_id uuid, reason_code text, reason text, requested_at timestamptz, authorised_at timestamptz, received_at timestamptz, inspected_at timestamptz, resolved_at timestamptz, closed_at timestamptz, refund_amount numeric, currency text)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.orders');
  return query
  select r.id, r.return_reference, r.return_type, r.status, r.order_id, r.order_item_id,
         r.reason_code, r.reason, r.requested_at, r.authorised_at, r.received_at,
         r.inspected_at, r.resolved_at, r.closed_at, r.refund_amount, r.currency
  from public.returns r
  join public.customers c on c.tenant_id=r.tenant_id and c.id=r.customer_id
  where r.tenant_id=p_tenant_id and c.auth_user_id=auth.uid()
  order by r.created_at desc;
end;
$function$;
