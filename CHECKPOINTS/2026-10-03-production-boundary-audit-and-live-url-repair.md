# Checkpoint — 2026-10-03 Production Boundary Audit and LIVE URL Repair

## Purpose

Deep audit of the LIVE release boundary after reports that parts of TradeFlow could still revert to the former TEST site.

## Verified production repairs

The following production frontend assets were verified clean of the TEST Supabase URL/key and old GitHub Pages customer portal URL:

- customer-dashboard.js
- buying-dashboard.js
- inventory-dashboard.js
- selling-dashboard.js
- settings.js
- returns-dashboard.js
- customers.js
- finance-dashboard.js
- buying-catalogue.js
- domain-settings.js
- subscriber-dashboard.html
- platform-plans.js

Two previously missed production frontend references were repaired:

- subscriber-dashboard.html — TEST Supabase URL changed to LIVE.
- platform-plans.js — TEST Supabase URL and publishable key changed to LIVE.

## LIVE database repair

Four LIVE PostgreSQL functions were found to contain the retired GitHub Pages customer portal URL:

- subscriber_complete_retail_fulfilment_shipping
- subscriber_request_customer_bank_details
- subscriber_save_retail_fulfilment_shipping
- subscriber_transition_retail_fulfilment

They were repaired in LIVE so notification payloads derive the customer portal URL from the tenant's active primary domain. No TEST/GitHub Pages fallback remains in those functions.

Current LIVE tenant_domains table has no rows, so a tenant without an active primary domain currently receives an empty portal_url rather than an obsolete TEST URL. This is intentional and must not be replaced with a guessed global domain.

## Stripe repair

LIVE Edge Function create-stripe-checkout-session was versioned to v2.

The old GitHub Pages fallback was removed. Checkout now derives its return origin from the browser Origin header or Referer origin and returns a clear error if no usable origin can be determined.

## Edge Function audit

LIVE Edge Functions checked:

- create-stripe-checkout-session
- customer-selling-submit
- process-notification-queue
- public-listing-media
- stripe-payment-webhook
- tradeflow-assistant

No TEST Supabase URL, old GitHub Pages URL, workers.dev test URL, localhost URL, or 127.0.0.1 reference was found in their current source.

## Worker boundary

production wrangler configuration intentionally retains both TEST and LIVE Supabase values because worker/index.js performs an environment-aware replacement:

- TRADEFLOW_ENV=production selects LIVE.
- TRADEFLOW_ENV=test selects TEST.

This is deliberate environment separation and is not a production leak.

customer-auth.js also intentionally retains TEST configuration for localhost, 127.0.0.1, GitHub Pages, and the named TEST workers.dev hostname. Its production branch selects LIVE.

## Re-audit result

The targeted production frontend assets are clean of the retired TEST Supabase URL/key and old GitHub Pages URL.

The LIVE database routine scan is clean of:

- TEST Supabase URL
- TEST workers.dev hostname
- localhost
- 127.0.0.1
- old GitHub Pages customer portal URL

## Remaining verification

Browser-level LIVE E2E still needs to be performed after deployment/cache propagation. This checkpoint does not claim that browser E2E has passed.

The next LIVE test should verify:

1. Public plans page loads LIVE data.
2. Subscriber dashboard remains on LIVE.
3. Customer portal links stay on the LIVE tenant domain.
4. Checkout success/cancel returns to the same LIVE origin.
5. Customer-to-subscriber Assistant messaging works end-to-end.
6. No navigation redirects to the former TEST site.

## Important rule

Do not globally remove TEST references from environment-aware test code. Only unconditional production-dangerous references should be removed.
