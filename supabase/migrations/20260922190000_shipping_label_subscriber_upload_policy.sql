-- Allow authenticated tenant members to upload subscriber-managed shipping label/QR files.
-- Files are still private and customer access remains governed by the existing customer SELECT policy.
create policy tradeflow_media_shipping_label_subscriber_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'tradeflow-media'
  and (storage.foldername(name))[2] = 'acquisitions'
  and private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())
);
