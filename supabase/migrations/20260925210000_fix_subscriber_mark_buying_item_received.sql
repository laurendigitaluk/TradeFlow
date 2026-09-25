-- Fix subscriber receiving action so it does not lock the buying item with a joined SELECT FOR UPDATE.
-- The action validates the current shipping state, then performs the two state updates directly.
create or replace function public.subscriber_mark_buying_item_received(p_tenant_id uuid, p_buying_item_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, private
as $function$
begin
  if auth.uid() is null or not private.has_tenant_permission(p_tenant_id,auth.uid(),'buying.manage') then
    raise exception 'Not authorised to manage buying';
  end if;

  if not exists (
    select 1 from public.buying_items bi
    where bi.tenant_id=p_tenant_id and bi.id=p_buying_item_id
      and bi.purchase_stage in ('shipping','received')
  ) then
    raise exception 'The item must be on its way before it can be received';
  end if;

  if not exists (
    select 1 from public.buying_item_shipping s
    where s.tenant_id=p_tenant_id and s.buying_item_id=p_buying_item_id
      and s.shipping_status in ('in_transit','received')
  ) then
    raise exception 'Customer has not confirmed that the item is on its way';
  end if;

  update public.buying_items
  set purchase_stage='received',
      item_received_at=coalesce(item_received_at,now()),
      purchase_stage_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id and id=p_buying_item_id;

  update public.buying_item_shipping
  set shipping_status='received',
      shipping_status_updated_at=now(),
      updated_at=now()
  where tenant_id=p_tenant_id and buying_item_id=p_buying_item_id;

  return true;
end;
$function$;
