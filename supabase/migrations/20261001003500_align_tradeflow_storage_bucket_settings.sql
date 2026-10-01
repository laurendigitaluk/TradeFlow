-- Keep published site media constrained to image files.
update storage.buckets
set public = true,
    file_size_limit = 5242880,
    allowed_mime_types = array['image/png','image/jpeg','image/webp']
where id = 'tradeflow-site-media';

-- Operational/customer media remains private and supports the mixed file types
-- used by labels, returns and customer/inventory media.
update storage.buckets
set public = false,
    file_size_limit = null,
    allowed_mime_types = null
where id = 'tradeflow-media';