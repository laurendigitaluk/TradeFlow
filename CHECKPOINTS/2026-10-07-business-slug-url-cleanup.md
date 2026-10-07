# Checkpoint — 2026-10-07 — Business Slug URLs

## Decision
Subscriber-facing URLs must not expose the internal tenant UUID.

The tenant UUID remains the authoritative internal identifier in Supabase, authentication state, API requests and tenant-scoped database operations. It is no longer written into normal subscriber browser URLs.

## LIVE change
The LIVE TradeFlow Worker is now connected to:
- https://tradeflow.laurendigital.co.uk

The existing LIVE Worker remains the application origin. No new Worker was created.

## URL model
For the platform subdomain, a subscriber public website can be addressed using a business slug:
- `?business=adventure-outpost`

Instead of:
- `?tenant_id=b2a17a9f-dee6-4b2b-9b0d-a4f9b7836f52`

For the current Adventure Outpost tenant, the stored tenant slug was changed from:
- `adventure-outpost-f8c8c4ea`

to:
- `adventure-outpost`

The tenant UUID remains unchanged.

## Database
LIVE Supabase project:
- `gxsrajtqzdjvmceqcpgv`

Added:
- `public.get_published_site_by_slug(text)`
  - SECURITY DEFINER
  - resolves an active tenant's slug to its published website
  - returns tenant id, tenant name/slug, revision and content
- `public.subscriber_get_my_tenant_slug(uuid)`
  - SECURITY DEFINER
  - returns the exact slug only for an authenticated active subscriber membership

The migration is recorded in:
`supabase/migrations/20261007213000_public_site_business_slug_urls.sql`

## Production source changes
Updated:
- `subscriber-auth.js`
  - tenant selection remains in localStorage/auth state
  - removes legacy `tenant_id` URL parameter
- `subscriber-tenant-context.js`
  - removes legacy `tenant_id` URL parameter instead of re-inserting it
- `subscriber-website.html`
  - draft preview links now use the business slug
- `public-site.js`
  - supports `business=`
  - resolves published and draft preview websites by business slug
  - preserves tenant UUID only as an internal/backward-compatible fallback

All three modified JavaScript files passed syntax validation after the change.

## Safety
- Authentication was not changed.
- Tenant UUIDs remain internal.
- Tenant-scoped database operations still use UUIDs.
- No Website Builder content or publishing workflow was changed.
- No Cloudflare Worker routing was changed by this code change.
- No customer-owned domain workflow was changed.

## Verification
Database verification confirmed:
- Adventure Outpost remains active.
- Published revision 1 remains assigned.
- `get_published_site_by_slug('adventure-outpost')` resolves the correct tenant and published revision.

## Next verification
After the production Worker receives the current production branch changes:
1. Refresh the LIVE TradeFlow platform.
2. Confirm subscriber dashboard URL no longer contains `tenant_id`.
3. Open Website → Preview website.
4. Confirm the preview URL uses `business=adventure-outpost`.
5. Confirm the published website loads and navigation preserves the business slug.
6. Confirm subscriber sign-in and tenant switching remain functional.
