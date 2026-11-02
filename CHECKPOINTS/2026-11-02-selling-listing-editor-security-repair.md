# Checkpoint — 2 November 2026 — Selling Listing Editor Repair

## Failure
Selling → Edit Listing showed a duplicated GoPro HERO8 Black title and could not save changes to retail asking price. LIVE listing `LST-20261102-BA831BAE` was £0.00. Purchase cost £123.00 is separate and must never be copied into asking price.

## Root cause
Authenticated direct UPDATE on `public.listings` is revoked in both environments. Existing RLS policy requires tenant selling permission, but the browser PATCH also requires a table privilege. The editor attempted direct PATCH and received `permission denied for table listings`. Structured Manufacturer/Model/Package values also duplicated the model when Package equalled Model.

## Repair
- Added `supabase/migrations/20261102130000_subscriber_update_listing_details.sql`.
- Added `public.subscriber_update_listing_details`: SECURITY DEFINER; requires authenticated user, tenant-scoped `selling.manage`, and `module.selling`; validates title, price and currency; refuses sold/delisted records; updates title, description, asking_price, currency, listing_data and updated_at only. Does not change status, tenant, asset, channel, category, quantity or ownership.
- Revoked public/anon execution; granted authenticated execution only. Direct table UPDATE remains denied.
- Selling JS calls the RPC instead of direct PATCH; `canonicalSellingTitle()` builds Manufacturer + Model and includes Package only when distinct. New listing description starts blank rather than copying structured private submission fields.
- Bumped Selling JS cache to v92.

## Environments
- TEST `nnsshnfkjcflucjrftzi`: migration applied; RPC exists; authenticated EXECUTE true; anon EXECUTE false.
- LIVE `gxsrajtqzdjvmceqcpgv`: migration applied; RPC exists; authenticated EXECUTE true; anon EXECUTE false.
- Authenticated direct UPDATE on listings remains false in both. No TEST business data copied to LIVE. No LIVE listing data changed.

## GitHub
Branch: `fix/selling-listing-edit-security-20261102-v2`, created from current `production` after the catalog agent advanced production during this repair. Includes migration, Selling JS, HTML cache bump, five manuals, system handbook, diagnostic roadmap, checkpoint and project memory.

## Outstanding
Cloudflare deployment and browser save/reload remain unverified. Confirm the existing GoPro listing can be edited, a user-selected retail asking price saved, refreshed, and displayed in Selling and the public shop. Do not substitute the £123 purchase cost.
