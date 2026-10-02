-- LIVE release cleanup: restore production serial uniqueness and remove TEST-only helper RPCs.
-- The duplicate-serial warning migration was a TEST-only experiment and must not remain active in LIVE.

drop index if exists public.inventory_assets_tenant_serial_idx;

create unique index inventory_assets_tenant_serial_idx
  on public.inventory_assets using btree (tenant_id, serial_number)
  where serial_number is not null;

drop function if exists public.test_lab_current_customer();
drop function if exists public.test_lab_current_customer_v2();
