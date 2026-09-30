-- TradeFlow migration 057: make acquisition lifecycle status changes authoritative.
-- Direct client updates must not be able to bypass transition_workflow_entity().
-- The central workflow function is SECURITY DEFINER owned by postgres, so its
-- legitimate status updates execute as postgres and remain permitted.

create or replace function public.guard_acquisition_status_entry()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Acquisition status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$$;

create or replace function public.guard_acquisition_item_status_entry()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if current_user <> 'postgres' then
      raise exception 'Acquisition item status must be changed through transition_workflow_entity';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists acquisitions_status_entry_guard on public.acquisitions;
create trigger acquisitions_status_entry_guard
before update of status on public.acquisitions
for each row execute function public.guard_acquisition_status_entry();

drop trigger if exists acquisition_items_status_entry_guard on public.acquisition_items;
create trigger acquisition_items_status_entry_guard
before update of status on public.acquisition_items
for each row execute function public.guard_acquisition_item_status_entry();
