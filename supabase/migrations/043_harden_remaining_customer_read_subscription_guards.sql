-- Migration 043: harden the remaining customer read RPCs so subscription guards are
-- unconditional execution preconditions, matching migration 042.

CREATE OR REPLACE FUNCTION public.customer_get_profile(p_tenant_id uuid)
RETURNS TABLE(customer_id uuid, customer_reference text, first_name text, last_name text, email text, phone text, status text)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.customer_portal');
  return query
  select c.id, c.customer_reference, c.first_name, c.last_name, c.email, c.phone, c.status
  from public.customers c
  where c.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  limit 1;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_addresses(p_tenant_id uuid)
RETURNS TABLE(address_id uuid, address_type text, recipient_name text, company_name text, line1 text, line2 text, city text, county text, postcode text, country_code text, is_default boolean)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.customer_portal');
  return query
  select a.id, a.address_type, a.recipient_name, a.company_name, a.line1, a.line2,
         a.city, a.county, a.postcode, a.country_code, a.is_default
  from public.customer_addresses a
  join public.customers c
    on c.tenant_id = a.tenant_id and c.id = a.customer_id
  where a.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by a.is_default desc, a.created_at;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_buying_requests(p_tenant_id uuid)
RETURNS TABLE(request_id uuid, request_reference text, status text, source text, submitted_at timestamptz, closed_at timestamptz, created_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  return query
  select r.id, r.request_reference, r.status, r.source, r.submitted_at, r.closed_at, r.created_at
  from public.buying_requests r
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where r.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by r.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_buying_items(p_tenant_id uuid)
RETURNS TABLE(item_id uuid, request_id uuid, category_id uuid, item_reference text, status text, title text, description text, quantity integer, sort_order integer, created_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  return query
  select i.id, i.buying_request_id, i.category_id, i.item_reference, i.status,
         i.title, i.description, i.quantity, i.sort_order, i.created_at
  from public.buying_items i
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where i.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by i.created_at desc, i.sort_order;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_trading_values(p_tenant_id uuid)
RETURNS TABLE(trading_value_id uuid, buying_item_id uuid, method text, status text, amount numeric, cash_price numeric, trade_in_price numeric, currency text, confidence numeric, calculated_at timestamptz, approved_at timestamptz, effective_from timestamptz, effective_to timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.valuation');
  return query
  select tv.id, tv.buying_item_id, tv.method, tv.status, tv.amount, tv.cash_price,
         tv.trade_in_price, tv.currency, tv.confidence, tv.calculated_at, tv.approved_at,
         tv.effective_from, tv.effective_to
  from public.trading_values tv
  join public.buying_items i
    on i.tenant_id = tv.tenant_id and i.id = tv.buying_item_id
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where tv.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
    and tv.status in ('approved','superseded')
  order by tv.calculated_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_offers(p_tenant_id uuid)
RETURNS TABLE(offer_id uuid, buying_item_id uuid, offer_reference text, offer_type text, status text, amount numeric, currency text, expires_at timestamptz, published_at timestamptz, responded_at timestamptz, response_notes text)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.offers');
  return query
  select o.id, o.buying_item_id, o.offer_reference, o.offer_type, o.status, o.amount,
         o.currency, o.expires_at, o.published_at, o.responded_at, o.response_notes
  from public.offers o
  join public.buying_items i
    on i.tenant_id = o.tenant_id and i.id = o.buying_item_id
  join public.buying_requests r
    on r.tenant_id = i.tenant_id and r.id = i.buying_request_id
  join public.customers c
    on c.tenant_id = r.tenant_id and c.id = r.customer_id
  where o.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by o.created_at desc;
end;
$function$;

CREATE OR REPLACE FUNCTION public.customer_get_acquisitions(p_tenant_id uuid)
RETURNS TABLE(acquisition_id uuid, acquisition_reference text, status text, currency text, agreed_total numeric, payment_total numeric, accepted_at timestamptz, received_at timestamptz, finalised_at timestamptz, paid_at timestamptz, completed_at timestamptz)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','public'
AS $function$
begin
  perform private.require_tenant_feature(p_tenant_id, 'module.buying');
  return query
  select a.id, a.acquisition_reference, a.status, a.currency, a.agreed_total, a.payment_total,
         a.accepted_at, a.received_at, a.finalised_at, a.paid_at, a.completed_at
  from public.acquisitions a
  join public.customers c
    on c.tenant_id = a.tenant_id and c.id = a.customer_id
  where a.tenant_id = p_tenant_id
    and c.auth_user_id = auth.uid()
  order by a.created_at desc;
end;
$function$;
