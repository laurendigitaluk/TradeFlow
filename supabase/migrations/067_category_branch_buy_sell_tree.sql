-- Add a subscriber-owned category -> branch -> property hierarchy shared by Buying and Selling.
create table public.category_branches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  category_id uuid not null,
  name text not null,
  slug text not null,
  description text,
  active boolean not null default true,
  buying_enabled boolean not null default true,
  selling_enabled boolean not null default true,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  foreign key (tenant_id, category_id)
    references public.categories(tenant_id, id) on delete restrict
);

create unique index category_branches_tenant_category_slug_key
  on public.category_branches (tenant_id, category_id, lower(slug));
create index category_branches_tenant_category_sort_idx
  on public.category_branches (tenant_id, category_id, active, sort_order, name);

alter table public.category_fields
  add column branch_id uuid,
  add column enabled_for_buying boolean not null default true,
  add column enabled_for_selling boolean not null default true;

alter table public.category_fields
  add constraint category_fields_tenant_branch_fk
  foreign key (tenant_id, branch_id)
  references public.category_branches(tenant_id, id)
  on delete restrict;

alter table public.buying_items add column branch_id uuid;
alter table public.buying_items
  add constraint buying_items_tenant_branch_fk
  foreign key (tenant_id, branch_id)
  references public.category_branches(tenant_id, id) on delete restrict;

alter table public.inventory_assets add column branch_id uuid;
alter table public.inventory_assets
  add constraint inventory_assets_tenant_branch_fk
  foreign key (tenant_id, branch_id)
  references public.category_branches(tenant_id, id) on delete restrict;

alter table public.listings add column branch_id uuid;
alter table public.listings
  add constraint listings_tenant_branch_fk
  foreign key (tenant_id, branch_id)
  references public.category_branches(tenant_id, id) on delete restrict;

create index category_fields_tenant_branch_sort_idx on public.category_fields (tenant_id, branch_id, sort_order, label);
create index buying_items_tenant_branch_idx on public.buying_items (tenant_id, branch_id);
create index inventory_assets_tenant_branch_idx on public.inventory_assets (tenant_id, branch_id);
create index listings_tenant_branch_idx on public.listings (tenant_id, branch_id);

create or replace function public.ensure_category_default_branch()
returns trigger language plpgsql security definer
set search_path = public, pg_catalog
as $$
begin
  if not exists (select 1 from public.category_branches b where b.tenant_id=new.tenant_id and b.category_id=new.id) then
    insert into public.category_branches
      (tenant_id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order)
    values
      (new.tenant_id,new.id,new.name,new.slug,new.description,new.active,new.buying_enabled,new.selling_enabled,0);
  end if;
  return new;
end;
$$;

create trigger categories_create_default_branch
after insert on public.categories
for each row execute function public.ensure_category_default_branch();

insert into public.category_branches
  (tenant_id,category_id,name,slug,description,active,buying_enabled,selling_enabled,sort_order)
select c.tenant_id,c.id,c.name,c.slug,c.description,c.active,c.buying_enabled,c.selling_enabled,0
from public.categories c
where not exists (select 1 from public.category_branches b where b.tenant_id=c.tenant_id and b.category_id=c.id);

update public.category_fields f set branch_id=b.id
from public.category_branches b
where b.tenant_id=f.tenant_id and b.category_id=f.category_id and f.branch_id is null;

update public.buying_items i set branch_id=b.id
from public.category_branches b
where b.tenant_id=i.tenant_id and b.category_id=i.category_id and i.branch_id is null;

update public.inventory_assets a set branch_id=b.id
from public.category_branches b
where b.tenant_id=a.tenant_id and b.category_id=a.category_id and a.branch_id is null;

update public.listings l set branch_id=b.id
from public.category_branches b
where b.tenant_id=l.tenant_id and b.category_id=l.category_id and l.branch_id is null;

create trigger category_branches_set_updated_at
before update on public.category_branches
for each row execute function public.set_updated_at();

alter table public.category_branches enable row level security;

create policy category_branches_select_members on public.category_branches
for select to authenticated using (private.is_tenant_member(tenant_id));
create policy category_branches_insert_admins on public.category_branches
for insert to authenticated with check (private.is_tenant_admin(tenant_id));
create policy category_branches_update_admins on public.category_branches
for update to authenticated using (private.is_tenant_admin(tenant_id))
with check (private.is_tenant_admin(tenant_id));
create policy category_branches_delete_admins on public.category_branches
for delete to authenticated using (private.is_tenant_admin(tenant_id));

comment on table public.category_branches is 'Tenant category branches used to structure and independently enable buying/selling paths.';
comment on column public.category_fields.branch_id is 'Branch that owns this dynamic product property.';
comment on column public.category_fields.enabled_for_buying is 'Whether this property is included in the Buying path.';
comment on column public.category_fields.enabled_for_selling is 'Whether this property is included in the Selling path.';
