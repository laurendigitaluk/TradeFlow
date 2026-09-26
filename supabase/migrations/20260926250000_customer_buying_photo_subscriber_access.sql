-- Allow authenticated subscriber members to view customer-supplied buying photographs.
-- Customer photos remain private; access is tenant-scoped.
drop policy if exists tradeflow_media_customer_buying_subscriber_select on storage.objects;
create policy tradeflow_media_customer_buying_subscriber_select
on storage.objects
for select
to authenticated
using (
  bucket_id='tradeflow-media'
  and (storage.foldername(name))[2]='customer-buying'
  and private.is_tenant_member(((storage.foldername(name))[1])::uuid,auth.uid())
);