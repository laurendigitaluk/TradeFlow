-- Customer selling journey: valuations, acquisition shipping and posted confirmation
create or replace function public.customer_get_selling_valuations(p_tenant_id uuid)
returns table(trading_value_id uuid,request_id uuid,request_reference text,buying_item_id uuid,method text,status text,amount numeric,cash_price numeric,trade_in_price numeric,currency text,confidence numeric,calculated_at timestamptz,approved_at timestamptz,effective_from timestamptz,effective_to timestamptz)
language plpgsql stable security definer set search_path=''
as $function$
declare v_customer_id uuid;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 return query
 select tv.id,r.id,r.request_reference,bi.id,tv.method,tv.status,tv.amount,tv.cash_price,tv.trade_in_price,tv.currency,tv.confidence,tv.calculated_at,tv.approved_at,tv.effective_from,tv.effective_to
 from public.trading_values tv join public.buying_items bi on bi.tenant_id=tv.tenant_id and bi.id=tv.buying_item_id join public.buying_requests r on r.tenant_id=bi.tenant_id and r.id=bi.buying_request_id
 where tv.tenant_id=p_tenant_id and r.customer_id=v_customer_id order by tv.calculated_at desc;
end;
$function$;

create or replace function public.customer_mark_acquisition_posted(p_tenant_id uuid,p_acquisition_id uuid)
returns void language plpgsql security definer set search_path=''
as $function$
declare v_customer_id uuid; v_status text; v_posted_at timestamptz;
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 select c.id into v_customer_id from public.customers c where c.tenant_id=p_tenant_id and c.auth_user_id=auth.uid() limit 1;
 if v_customer_id is null then raise exception 'Customer account not found'; end if;
 select a.status,a.posted_at into v_status,v_posted_at from public.acquisitions a where a.tenant_id=p_tenant_id and a.id=p_acquisition_id and a.customer_id=v_customer_id for update;
 if v_status is null then raise exception 'Acquisition not found'; end if;
 if v_posted_at is not null then return; end if;
 if v_status not in ('accepted','awaiting_item','shipping') then raise exception 'This acquisition is not currently awaiting the item'; end if;
 update public.acquisitions set posted_at=now(),status='shipping',updated_at=now() where tenant_id=p_tenant_id and id=p_acquisition_id;
end;
$function$;

revoke all on function public.customer_get_selling_valuations(uuid) from public,anon;
grant execute on function public.customer_get_selling_valuations(uuid) to authenticated;
revoke all on function public.customer_mark_acquisition_posted(uuid,uuid) from public,anon;
grant execute on function public.customer_mark_acquisition_posted(uuid,uuid) to authenticated;