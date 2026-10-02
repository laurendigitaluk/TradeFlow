# TradeFlow LIVE Release Audit — 2026-10-03

## Purpose
Controlled production release preparation after confirmation that the separate **TradeFlow Live** Supabase project exists.

## Environments
- TEST GitHub: `main`
- LIVE GitHub release branch: `production`
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv`
- LIVE region: `eu-west-2`
- LIVE project status at bootstrap: `ACTIVE_HEALTHY`

## Audit findings

### GitHub
The previous `production` branch was 239 commits behind current `main` and still contained hard-coded TEST Supabase URLs in subscriber/customer/platform authentication files.

Current `main` contains the hostname-based environment selector:
- localhost / 127.0.0.1 / GitHub Pages → TEST
- production hostnames → LIVE

The LIVE publishable Supabase configuration is:
`https://gxsrajtqzdjvmceqcpgv.supabase.co`

The current main code also contains the provider-neutral TradeFlow Assistant and the customer-to-subscriber messaging implementation.

### TEST-only exclusion
The migration `20260930232732_allow_duplicate_inventory_serial_numbers_with_warning` is explicitly TEST-only and is excluded from this production release. The production release therefore retains the unique tenant/serial index from the baseline schema.

Known historical TEST fixture migrations are not present in the current production-release migration set.

### LIVE database
The LIVE bootstrap checkpoint records that the separate LIVE database was initialized from the version-controlled baseline and storage configuration, with no TEST customer/business data copied.

The LIVE bootstrap also recorded the following Edge Functions as deployed:
- create-stripe-checkout-session
- customer-selling-submit
- process-notification-queue
- public-listing-media
- stripe-payment-webhook

Manual shipping remains the production architecture. Parcel2Go API functions are not part of the intended LIVE workflow.

## Required LIVE configuration still needing direct verification
The connected Supabase tool in this chat does not currently have permission to inspect the LIVE project directly, so these cannot be honestly marked LIVE-verified here:
- current LIVE migration history
- current LIVE AI provider settings/messaging tables
- current LIVE Edge Function versions after the later TEST work
- LIVE Auth redirect/site URLs
- LIVE Stripe secrets/webhook configuration
- LIVE notification email/Resend configuration
- LIVE Storage/RLS/grants after later migrations
- LIVE Cloudflare deployment target

The code release is therefore prepared, but database/configuration parity is not being falsely represented as verified.

## Release contents
The release branch is based on current `main), with the TEST-only duplicate-serial migration removed.

It includes the current:
- LIVE/TEST frontend environment separation
- subscriber/customer authentication repairs
- buying/valuation/offer/acquisition/inventory/selling/order/fulfilment/return work
- manual shipping architecture
- domain pricing/payment/registrant-stage code
- provider-neutral AI owner controls
- subscriber Assistant
- customer Assistant
- customer-to-subscriber assistant conversations
- in-store workflow work

## Safety boundary
Do not use the production database for development or debugging.
Do not copy TEST data into LIVE.
Do not enable a real Porkbun registration path merely because TEST sandbox registration succeeded.
Do not revive Parcel2Go or ResellerClub.
Do not treat a GitHub promotion as proof that LIVE database migrations/functions/secrets are deployed.

## First LIVE acceptance test
After LIVE database/configuration parity is verified:
1. Create a brand-new subscriber business.
2. Confirm subscription/capabilities.
3. Build/publish its website.
4. Create a brand-new customer account against that subscriber.
5. Test Customer Assistant.
6. Test customer → subscriber message handoff.
7. Test subscriber reply → customer.
8. Run the core buying journey from a fresh submission.
9. Verify tenant isolation.
10. Then proceed through inventory/selling/retail purchase as applicable.

## Verification language
Use only:
- **Implemented in GitHub**
- **LIVE DB verified**
- **Browser verified**

when that evidence actually exists.
