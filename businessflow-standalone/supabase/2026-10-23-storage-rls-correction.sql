-- BusinessFlow Storage RLS correction.
-- The original policy accidentally used storage.foldername(s.name), which
-- checked the site's display name rather than the Storage object's path.
-- Scope all access to files under <owned-site-uuid>/<filename>.

drop policy if exists "Owners can view their BusinessFlow assets" on storage.objects;
drop policy if exists "Owners can upload their BusinessFlow assets" on storage.objects;
drop policy if exists "Owners can update their BusinessFlow assets" on storage.objects;
drop policy if exists "Owners can delete their BusinessFlow assets" on storage.objects;

create policy "Owners can view their BusinessFlow assets"
on storage.objects for select to authenticated
using (
  bucket_id = 'businessflow-assets'
  and exists (
    select 1 from public.businessflow_sites s
    where s.id::text = (storage.foldername(objects.name))[1]
      and s.owner_id = (select auth.uid())
  )
);

create policy "Owners can upload their BusinessFlow assets"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'businessflow-assets'
  and exists (
    select 1 from public.businessflow_sites s
    where s.id::text = (storage.foldername(objects.name))[1]
      and s.owner_id = (select auth.uid())
  )
);

create policy "Owners can update their BusinessFlow assets"
on storage.objects for update to authenticated
using (
  bucket_id = 'businessflow-assets'
  and exists (
    select 1 from public.businessflow_sites s
    where s.id::text = (storage.foldername(objects.name))[1]
      and s.owner_id = (select auth.uid())
  )
)
with check (
  bucket_id = 'businessflow-assets'
  and exists (
    select 1 from public.businessflow_sites s
    where s.id::text = (storage.foldername(objects.name))[1]
      and s.owner_id = (select auth.uid())
  )
);

create policy "Owners can delete their BusinessFlow assets"
on storage.objects for delete to authenticated
using (
  bucket_id = 'businessflow-assets'
  and exists (
    select 1 from public.businessflow_sites s
    where s.id::text = (storage.foldername(objects.name))[1]
      and s.owner_id = (select auth.uid())
  )
);
