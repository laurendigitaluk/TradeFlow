-- Narrow, tenant-authorised replacement for direct inventory_assets UPDATE from Selling.
-- Do not grant authenticated broad UPDATE access to public.inventory_assets.
create or replace function public.subscriber_update_inventory_asset_sales_fields(
  p_tenant_id uuid,
  p_asset_id uuid,
  p_serial_number text,
  p_location text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_updated_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not private.has_tenant_permission(p_tenant_id, auth.uid(), 'inventory.manage')
     or not private.has_tenant_feature(p_tenant_id, 'module.inventory') then
    raise exception 'Inventory management permission required';
  end if;

  update public.inventory_assets ia
     set serial_number = nullif(trim(p_serial_number), ''),
         location = nullif(trim(p_location), ''),
         updated_at = now()
   where ia.tenant_id = p_tenant_id
     and ia.id = p_asset_id
  returning ia.id into v_updated_id;

  if v_updated_id is null then
    raise exception 'Inventory asset not found for this business';
  end if;

  return jsonb_build_object('ok', true, 'asset_id', v_updated_id);
end;
$function$;

revoke all on function public.subscriber_update_inventory_asset_sales_fields(uuid, uuid, text, text) from public, anon;
grant execute on function public.subscriber_update_inventory_asset_sales_fields(uuid, uuid, text, text) to authenticated;
