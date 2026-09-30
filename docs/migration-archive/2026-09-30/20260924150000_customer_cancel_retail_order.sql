-- Customer cancellation for retail orders that have not been paid or fulfilled.
create or replace function public.customer_cancel_retail_order(
  p_tenant_id uuid,
  p_order_id uuid,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path='pg_catalog','public'
as $function$
declare
  v_customer_id uuid;
  v_order public.retail_orders%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;
  perform private.require_tenant_feature(p_tenant_id,'module.orders');
  v_customer_id := private.customer_id_for_current_user(p_tenant_id);
  if v_customer_id is null then
    raise exception 'Customer account not found';
  end if;
  select * into v_order
  from public.retail_orders
  where tenant_id=p_tenant_id and id=p_order_id and customer_id=v_customer_id
  for update;
  if v_order.id is null then
    raise exception 'Order not found or not owned by current customer';
  end if;
  if v_order.status not in ('initiated','pending_payment') then
    raise exception 'This order can no longer be cancelled';
  end if;
  update public.retail_orders
  set status='cancelled',cancelled_at=now(),updated_at=now()
  where tenant_id=p_tenant_id and id=p_order_id;
  insert into public.workflow_transitions(tenant_id,entity_type,entity_id,from_status,to_status,actor_user_id,notes,metadata)
  values(p_tenant_id,'retail_order',p_order_id,v_order.status,'cancelled',auth.uid(),nullif(trim(p_reason),''),jsonb_build_object('source','customer_action'));
  return jsonb_build_object('order_id',v_order.id,'order_reference',v_order.order_reference,'status','cancelled');
end;
$function$;
revoke all on function public.customer_cancel_retail_order(uuid,uuid,text) from public,anon;
grant execute on function public.customer_cancel_retail_order(uuid,uuid,text) to authenticated;
