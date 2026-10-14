-- Keep inventory status synchronisation behind a narrow tenant-authorised RPC.
create or replace function public.subscriber_sync_inventory_asset_status(
  p_tenant_id uuid,
  p_asset_id uuid,
  p_expected_status text,
  p_new_status text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_status text;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'inventory.manage')
     or not private.has_tenant_feature(p_tenant_id, 'module.inventory') then
    raise exception 'Inventory management permission required';
  end if;

  if not (
    (p_expected_status = 'ready_for_sale' and p_new_status = 'listed')
    or (p_expected_status = 'listed' and p_new_status = 'ready_for_sale')
  ) then
    raise exception 'Invalid inventory status transition';
  end if;

  update public.inventory_assets ia
     set status = p_new_status,
         updated_at = now()
   where ia.tenant_id = p_tenant_id
     and ia.id = p_asset_id
     and ia.status = p_expected_status
  returning ia.status into v_status;

  if v_status is null then
    select ia.status into v_status
      from public.inventory_assets ia
     where ia.tenant_id = p_tenant_id
       and ia.id = p_asset_id;

    if v_status is null then
      raise exception 'Inventory asset not found for this business';
    end if;
    if v_status <> p_new_status then
      raise exception 'Inventory status changed; refresh and try again';
    end if;
  end if;

  return jsonb_build_object('ok', true, 'asset_id', p_asset_id, 'status', v_status);
end;
$function$;

revoke all on function public.subscriber_sync_inventory_asset_status(uuid, uuid, text, text) from public, anon;
grant execute on function public.subscriber_sync_inventory_asset_status(uuid, uuid, text, text) to authenticated;
