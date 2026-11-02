# Checkpoint — 2 November 2026 — Selling Listing Editor Repair

## Failure
Selling → Edit Listing displayed the existing title twice and could not save changes to the retail asking price. LIVE GoPro listing `LST-20261102-BA831BAE` was saved at £0.00. Its £123.00 purchase price is separate and must not be copied into the retail asking price.

## Root cause
Authenticated direct UPDATE on `public.listings` is revoked in both environments. The editor attempted a direct PostgREST PATCH and received `permission denied for table listings`. Structured Manufacturer/Model/Package fields also duplicated the model when Package equalled Model.

## Repair
- Added `supabase/migrations/20261102130000_subscriber_update_listing_details.sql`.
- Added `public.subscriber_update_listing_details`: SECURITY DEFINER; authenticated user; tenant-scoped `selling.manage` and `module.selling`; validates editable listing fields; refuses sold/delisted records; updates only title, description, asking price, currency, listing_data and updated_at. Does not alter status, tenant, asset, channel, category, quantity or ownership.
- Revoked public/anon execution; granted authenticated execution only. Direct table UPDATE remains denied.
- Selling JS calls the RPC instead of PATCH; `canonicalSellingTitle()` composes Manufacturer + Model and includes Package only when distinct. New listing description starts blank rather than copying internal structured submission fields.
- Bumped `selling-dashboard.html` script cache to v92.

## Environments
- TEST `nnsshnfkjcflucjrftzi`: migration applied; RPC exists; authenticated EXECUTE true; anon EXECUTE false.
- LIVE `gxsrajtqzdjvmceqcpgv`: migration applied; RPC exists; authenticated EXECUTE true; anon EXECUTE false.
- Authenticated direct UPDATE on listings remains false in both. No TEST business data copied to LIVE. No LIVE listing data was changed.

## GitHub
Branch: `fix/selling-listing-edit-security-20261102`, based on `production` at branch creation. Includes migration, Selling JS, HTML cache bump, System Handbook, AI Operating Manual, Backend Operations Manual, Backend User Manual, Human User Manual and Subscriber Dashboard Diagnostic Roadmap.

## Outstanding verification
Cloudflare deployment and browser save/reload have not yet been verified. Do not call complete until the existing GoPro listing can be edited, a user-selected asking price saved, page refreshed, and the same price/title confirmed in Selling and the public shop.
