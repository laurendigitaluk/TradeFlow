# TradeFlow Production Security Release Candidate — 2026-09-30

## Scope
Final TEST security/release-candidate audit before creating the separate Production Supabase project.

## Verified TEST state
- Supabase project: twfbmjwwqzxdxvclxbun
- Region: eu-west-2
- GitHub repository: laurendigitaluk/TradeFlow
- TEST schema, latest migrations, workflow functions, storage policies and Edge Functions were inspected.
- TEST One remains the frozen known-good baseline.
- Manual shipping remains the definitive architecture. Parcel2Go API/checkout/payment-link workflow must not be reintroduced.

## Security hardening applied
### SECURITY DEFINER RPC execution
Previously, many SECURITY DEFINER functions inherited PUBLIC/anon execution. This included administrative catalogue functions and subscriber/customer workflow functions.

Migration:
- supabase/migrations/20260930210000_restrict_security_definer_client_execution.sql

Action:
- Revoke EXECUTE from PUBLIC and anon for all public SECURITY DEFINER functions.
- Restore anon/authenticated execution only for deliberately public read/media RPCs:
  - get_public_buying_catalogue
  - get_published_site_preview
  - get_published_sites
  - get_published_store_listing_media
  - get_published_store_listings
  - public_get_available_plans
  - is_published_tradeflow_media

The protected customer/subscriber/admin RPCs retain their authenticated grants and their existing tenant/auth/permission checks.

### published_site_preview
The SECURITY DEFINER view was directly selectable by anon/authenticated. Direct SELECT was revoked from PUBLIC, anon and authenticated. The controlled get_published_site_preview RPC remains the public route.

### Trigger search paths
Migration:
- supabase/migrations/20260930211000_harden_payment_ledger_trigger_search_path.sql

The payment and ledger status trigger guard functions now use an explicit pg_catalog search_path, removing the mutable-search-path warning without changing workflow behaviour.

## Verification
After hardening:
- Anonymous SECURITY DEFINER RPC surface contains only the seven deliberate public read/media functions above.
- published_site_preview direct SELECT is false for anon and authenticated.
- Generic workflow transition function requires authenticated tenant membership, the correct permission, the required module feature, a valid transition and an expected current status.
- Automatic valuation calculation requires tenant valuation permission and the valuation module.
- Customer return requests require an authenticated customer linked to the tenant.
- Subscriber purchase/payment functions require the relevant buying/finance permissions.
- Storage bucket model remains:
  - tradeflow-media: private
  - tradeflow-site-media: public, image-only, 5 MB limit
- Customer/subscriber shipping and return-label storage policies remain authenticated and tenant/customer scoped.

## Remaining advisor findings
These are not treated as launch blockers by themselves:
- RLS-enabled catalogue/reference tables with no direct policies because they are reached through controlled functions.
- pg_net in public schema.
- Leaked-password protection disabled in Auth.
- Authenticated SECURITY DEFINER warnings for client-facing functions that already implement tenant membership/permission checks.
- Public SECURITY DEFINER warnings for the seven intentionally public RPC/media helpers.

## Edge Functions
- process-notification-queue has verify_jwt=false but requires the TradeFlow cron secret before processing anything.
- stripe-payment-webhook has verify_jwt=false and validates the Stripe signature before processing.
- public-listing-media is intentionally public and only returns media for published listings.
- Parcel2Go Edge Functions remain deployed from historical TEST work but are not part of the current manual-shipping workflow; do not reintroduce them into the application flow.

## Release candidate source
After the security migrations are committed, main contains the complete tested application plus these two security migrations. Production must be created as a fresh database from version-controlled migrations; do not copy TEST data.

## Next step
1. Confirm the TEST security audit remains clean after the new migrations.
2. Treat current main as the Production Release Candidate.
3. Confirm the Supabase organization/project creation cost before creating the separate Production project.
4. Create the fresh Production Supabase project in eu-west-2.
5. Apply all version-controlled migrations to Production.
6. Configure Production secrets/Auth/Edge Functions and the production site environment.
7. Run a clean production smoke test using a new customer/subscriber account and no TEST transactional data.
