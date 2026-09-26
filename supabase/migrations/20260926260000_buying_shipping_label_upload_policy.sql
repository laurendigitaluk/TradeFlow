-- Allow subscriber-managed buying shipping labels/QR files to be uploaded to the private media bucket.
-- This is deliberately scoped to buying-item shipping paths and tenant membership.
-- It does not change the retail fulfilment shipping upload path.
create policy tradeflow_media_buying_item_shipping_subscriber_insert
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'tradeflow-media'
  and (storage.foldername(name))[2] = 'buying-items'
  and (
    (storage.foldername(name))[4] like 'shipping-label-%'
    or (storage.foldername(name))[4] like 'shipping-qr-%'
  )
  and private.is_tenant_member(((storage.foldername(name))[1])::uuid, auth.uid())
);
