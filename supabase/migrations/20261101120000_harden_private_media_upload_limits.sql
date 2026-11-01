-- TradeFlow security hardening: constrain private tenant media uploads.
-- Preserve the bucket's private visibility and existing tenant-scoped storage policies.
-- 5 MiB per object; photographs and shipping labels/QR files only.
update storage.buckets
set public = false,
    file_size_limit = 5242880,
    allowed_mime_types = array[
      'image/jpeg',
      'image/png',
      'image/webp',
      'application/pdf'
    ]
where id = 'tradeflow-media';

-- Keep the public website-image bucket's existing 5 MiB image-only policy unchanged.
