create or replace function public.subscriber_get_returns(p_tenant_id uuid)
returns table(id uuid,return_reference text,return_type text,status text,customer_id uuid,order_id uuid,order_item_id uuid,acquisition_id uuid,acquisition_item_id uuid,inventory_asset_id uuid,reason_code text,reason text,customer_notes text,staff_notes text,requested_at timestamptz,authorised_at timestamptz,received_at timestamptz,inspected_at timestamptz,resolved_at timestamptz,closed_at timestamptz,refund_amount numeric,currency text)
language plpgsql stable security definer set search_path=pg_catalog,public
as $function$
begin
 if auth.uid() is null then raise exception 'Authentication required'; end if;
 if not private.has_tenant_permission(p_tenant_id,auth.uid(),'returns.view') then raise exception 'Permission required: returns.view'; end if;
 if not (private.has_tenant_feature(p_tenant_id,'module.buying') or private.has_tenant_feature(p_tenant_id,'module.orders')) then raise exception 'Returns module is not enabled for this business'; end if;
 return query select r.id,r.return_reference,r.return_type,r.status,r.customer_id,r.order_id,r.order_item_id,r.acquisition_id,r.acquisition_item_id,r.inventory_asset_id,r.reason_code,r.reason,r.customer_notes,r.staff_notes,r.requested_at,r.authorised_at,r.received_at,r.inspected_at,r.resolved_at,r.closed_at,r.refund_amount,r.currency from public.returns r where r.tenant_id=p_tenant_id order by r.requested_at desc nulls last,r.created_at desc;
end;
$function$;
grant execute on function public.subscriber_get_returns(uuid) to authenticated;
