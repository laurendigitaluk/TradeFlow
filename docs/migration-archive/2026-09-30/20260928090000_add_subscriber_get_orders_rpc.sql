create or replace function public.subscriber_get_orders(p_tenant_id uuid)
returns table(
 id uuid,
 order_reference text,
 customer_id uuid,
 channel_id uuid,
 status text,
 currency text,
 total numeric,
 payment_status text,
 customer_email text,
 customer_name text,
 shipping_address jsonb,
 billing_address jsonb,
 notes text,
 amount_due numeric,
 placed_at timestamptz,
 paid_at timestamptz,
 completed_at timestamptz,
 cancelled_at timestamptz,
 created_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.is_tenant_member(p_tenant_id,auth.uid()) then raise exception 'Tenant membership required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'orders.view') then raise exception 'Orders view permission required'; end if;
 if not private.has_tenant_feature(p_tenant_id,'module.orders') then raise exception 'Orders module is not enabled for this tenant'; end if;
 return query
 select o.id,o.order_reference,o.customer_id,o.channel_id,o.status,o.currency,o.total,o.payment_status,
        o.customer_email,o.customer_name,o.shipping_address,o.billing_address,o.notes,o.amount_due,
        o.placed_at,o.paid_at,o.completed_at,o.cancelled_at,o.created_at
 from public.retail_orders o
 where o.tenant_id=p_tenant_id
 order by o.created_at desc;
end;
$$;

grant execute on function public.subscriber_get_orders(uuid) to authenticated;
