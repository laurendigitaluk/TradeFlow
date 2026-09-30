-- Subscriber shipping override foundation.
-- Existing label upload/URL support remains intact; this adds an explicit manual/automated mode and QR-code sources.

alter table public.acquisitions
  add column if not exists shipping_method text not null default 'subscriber_override',
  add column if not exists shipping_qr_url text,
  add column if not exists shipping_qr_storage_path text;

alter table public.acquisitions
  drop constraint if exists acquisitions_shipping_method_check;

alter table public.acquisitions
  add constraint acquisitions_shipping_method_check
  check (shipping_method in ('automated','subscriber_override'));

comment on column public.acquisitions.shipping_method is 'Shipping route for the acquisition: automated courier integration or subscriber override/manual shipping.';
comment on column public.acquisitions.shipping_qr_url is 'Optional customer-facing QR code URL supplied by the subscriber shipping service.';
comment on column public.acquisitions.shipping_qr_storage_path is 'Optional private tradeflow-media path for a subscriber-supplied QR code image.';

grant select, update on table public.acquisitions to authenticated;