-- TradeFlow migration 058: harden inventory access and lifecycle authority.
-- Remove legacy tenant-member policies so inventory access is controlled by
-- inventory.view/manage plus the module.inventory subscription capability.
-- Prevent direct client status mutation; inventory lifecycle changes must use
-- transition_workflow_entity().

drop policy if exists inventory_assets_insert_members on public.inventory_assets;
drop policy if exists inventory_assets_select_members on public.inventory_assets;
drop policy if exists inventory_assets_update_members on public.inventory_assets;
drop policy if exists inventory_assets_delete_admins on public.inventory_assets;

create or replace function public.guard_inventory_asset_status_entry()
returns trigger
language plpgsql
set search_path to 'pg_catalog', 'public'
as $$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Inventory asset status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists inventory_assets_status_entry_guard on public.inventory_assets;
create trigger inventory_assets_status_entry_guard
before update on public.inventory_assets
for each row execute function public.guard_inventory_asset_status_entry();
