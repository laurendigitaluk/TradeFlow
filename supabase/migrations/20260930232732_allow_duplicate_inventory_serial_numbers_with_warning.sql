drop index if exists public.inventory_assets_tenant_serial_idx;

create index inventory_assets_tenant_serial_idx
  on public.inventory_assets (tenant_id, serial_number)
  where serial_number is not null;
