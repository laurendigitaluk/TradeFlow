create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references public.tenants(id) on delete restrict,
  storage_bucket text not null,
  storage_path text not null,
  original_filename text,
  mime_type text,
  byte_size bigint,
  width integer,
  height integer,
  checksum text,
  status text not null default 'active' check (status in ('pending','active','deleted','quarantined')),
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (tenant_id, id),
  unique (tenant_id, storage_bucket, storage_path),
  check (byte_size is null or byte_size >= 0),
  check (width is null or width > 0),
  check (height is null or height > 0)
);

create table public.buying_item_media (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  buying_item_id uuid not null,
  media_asset_id uuid not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  unique (buying_item_id, media_asset_id),
  foreign key (tenant_id, buying_item_id) references public.buying_items(tenant_id, id) on delete cascade,
  foreign key (tenant_id, media_asset_id) references public.media_assets(tenant_id, id) on delete restrict
);

create index media_assets_tenant_created_idx on public.media_assets (tenant_id, created_at desc);
create index buying_item_media_item_idx on public.buying_item_media (tenant_id, buying_item_id, sort_order);

create or replace function public.media_assets_set_updated_at()
returns trigger language plpgsql set search_path = pg_catalog as $$
begin new.updated_at = now(); return new; end; $$;
create trigger media_assets_set_updated_at before update on public.media_assets for each row execute function public.media_assets_set_updated_at();

alter table public.media_assets enable row level security;
alter table public.buying_item_media enable row level security;

create policy media_assets_select_members on public.media_assets for select to authenticated using (private.is_tenant_member(tenant_id));
create policy media_assets_insert_members on public.media_assets for insert to authenticated with check (private.is_tenant_member(tenant_id) and (created_by is null or created_by = auth.uid()));
create policy media_assets_update_members on public.media_assets for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy media_assets_delete_admins on public.media_assets for delete to authenticated using (private.is_tenant_admin(tenant_id));

create policy buying_item_media_select_members on public.buying_item_media for select to authenticated using (private.is_tenant_member(tenant_id));
create policy buying_item_media_insert_members on public.buying_item_media for insert to authenticated with check (private.is_tenant_member(tenant_id));
create policy buying_item_media_update_members on public.buying_item_media for update to authenticated using (private.is_tenant_member(tenant_id)) with check (private.is_tenant_member(tenant_id));
create policy buying_item_media_delete_members on public.buying_item_media for delete to authenticated using (private.is_tenant_member(tenant_id));

comment on table public.media_assets is 'Tenant-scoped metadata for uploaded media; storage objects are addressed by bucket/path and are not exposed by this table alone.';
comment on table public.buying_item_media is 'Tenant-scoped association between buying items and media assets.';
