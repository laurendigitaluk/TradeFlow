-- Keep category and branch references aligned across Buying, Inventory, Selling and dynamic properties.
create or replace function public.sync_category_branch_reference()
returns trigger
language plpgsql
set search_path = public, pg_catalog
as $$
declare resolved_branch uuid;
begin
  if new.branch_id is null then
    select b.id into resolved_branch
    from public.category_branches b
    where b.tenant_id=new.tenant_id and b.category_id=new.category_id and b.active=true
    order by b.sort_order,b.created_at limit 1;
    if resolved_branch is null then
      raise exception 'No active branch exists for category %', new.category_id;
    end if;
    new.branch_id=resolved_branch;
  else
    if not exists (
      select 1 from public.category_branches b
      where b.tenant_id=new.tenant_id and b.category_id=new.category_id and b.id=new.branch_id
    ) then
      raise exception 'Branch % does not belong to category %', new.branch_id, new.category_id;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists category_fields_sync_branch on public.category_fields;
create trigger category_fields_sync_branch
before insert or update of tenant_id,category_id,branch_id on public.category_fields
for each row execute function public.sync_category_branch_reference();

drop trigger if exists buying_items_sync_branch on public.buying_items;
create trigger buying_items_sync_branch
before insert or update of tenant_id,category_id,branch_id on public.buying_items
for each row execute function public.sync_category_branch_reference();

drop trigger if exists inventory_assets_sync_branch on public.inventory_assets;
create trigger inventory_assets_sync_branch
before insert or update of tenant_id,category_id,branch_id on public.inventory_assets
for each row execute function public.sync_category_branch_reference();

drop trigger if exists listings_sync_branch on public.listings;
create trigger listings_sync_branch
before insert or update of tenant_id,category_id,branch_id on public.listings
for each row execute function public.sync_category_branch_reference();
