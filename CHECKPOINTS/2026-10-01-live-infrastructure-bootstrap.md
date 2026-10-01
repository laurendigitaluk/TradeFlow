# TradeFlow LIVE Infrastructure Bootstrap — 2026-10-01

## Purpose
Record the controlled initial setup of the existing TradeFlow Live Supabase project from the tested TradeFlow release.

## LIVE project
- Project: TradeFlow Live
- Ref: gxsrajtqzdjvmceqcpgv
- Region: eu-west-2
- Status at bootstrap: ACTIVE_HEALTHY
- No TEST customer/business data copied.

## Database
The LIVE database was initialized from the version-controlled baseline:
- remote schema baseline
- duplicate inventory serial warning policy
- storage bucket configuration
- storage bucket settings

LIVE verification after bootstrap:
- 93 public tables
- 178 public functions
- 78 public triggers
- RLS enabled on the public tables reported by the schema audit.

## Storage
Version-controlled storage configuration is now applied to TEST and LIVE:
- tradeflow-media: private, mixed operational/customer media
- tradeflow-site-media: public, 5 MB maximum, PNG/JPEG/WebP

The existing storage object policies from the baseline migration remain authoritative.

## Edge Functions deployed to LIVE
Deployed from the current main source:
- create-stripe-checkout-session — JWT required
- customer-selling-submit — JWT required
- process-notification-queue — custom cron-secret authentication, JWT disabled
- public-listing-media — public endpoint with application-level publication checks, JWT disabled
- stripe-payment-webhook — Stripe signature validation endpoint, JWT disabled

Obsolete Parcel2Go API functions and the TEST-only shipping provider test function were deliberately not deployed because the current TradeFlow shipping architecture is manual.

## Secrets/configuration still outstanding
Production secrets/configuration must be completed before real transactions:
- Stripe secret key
- Stripe webhook secret
- Resend API key
- notification processor secret
- production Auth/redirect configuration
- production hosting/Cloudflare environment configuration
- any other environment-specific provider configuration required by the final release.

Secrets must be entered through the appropriate production secret/configuration mechanism and never committed to GitHub.

## Release control
The production promotion PR remains open. This checkpoint does not authorize merging to production.

Next controlled phase:
1. Configure Production secrets/Auth/hosting.
2. Verify Edge Functions and Storage.
3. Perform Production subscriber/customer smoke tests.
4. Perform tenant-isolation checks.
5. Complete Production payment/webhook test.
6. Review release PR and promote only after all Production checks pass.

No TEST reset, LIVE reset, or destructive database operation was performed.
