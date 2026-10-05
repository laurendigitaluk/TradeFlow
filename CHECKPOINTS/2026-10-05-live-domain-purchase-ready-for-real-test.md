# Checkpoint — 2026-10-05 — LIVE Domain Purchase Ready for Real-Domain Test

## Current position

TradeFlow LIVE has now reached the real Stripe checkout stage for a domain purchase.

The test journey was taken as far as possible without actually spending money on a real domain.

### Verified working

1. Subscriber opens **Website URL** in LIVE.
2. Selects **Buy a new domain**.
3. Searches Porkbun availability.
4. Porkbun availability is returned successfully.
5. LIVE domain pricing settings are read successfully from `platform_domain_pricing_settings`.
6. Customer pricing is calculated correctly using:
   - Porkbun registrar USD cost
   - USD → GBP rate: `0.74549089`
   - Markup: `25%`
   - Formula: `USD cost × 0.74549089 × 1.25`
7. Example verified:
   - Porkbun cost: `$5.66`
   - Customer price: `£5.27`
8. The LIVE domain-order creation stage has been repaired.
   - Missing LIVE pricing-audit columns were added to `tenant_domain_orders`:
     - `registrar_cost_usd`
     - `fx_rate_gbp_per_usd`
     - `markup_percent`
     - `pricing_source`
     - `pricing_period_start`
     - `pricing_period_end`
9. The browser has now successfully reached **Stripe Checkout** for the selected domain.
10. Stripe checkout displays the domain registration charge of **£5.27**.

## Current stopping point

Do NOT make a real payment yet as part of this checkpoint.

The next meaningful test requires purchasing a genuinely inexpensive available domain so the complete LIVE workflow can be verified end-to-end.

Current verified stopping point:

**Porkbun availability → correct LIVE GBP pricing → domain order creation → Stripe Checkout (£5.27)**

## Next test

Purchase a cheap genuine domain through the LIVE flow.

Before paying, verify:
- correct domain
- correct displayed GBP price
- Stripe checkout is LIVE/production, not TEST
- payment amount matches the calculated domain price

After payment, verify the complete post-payment chain:
1. Stripe payment succeeds.
2. Stripe webhook is received by LIVE.
3. Domain order becomes payment-confirmed.
4. Registrant-details stage is reached.
5. Registrant details can be saved.
6. LIVE domain registration is performed with the production Porkbun API.
7. Registration succeeds and is idempotent.
8. Domain expiry is stored.
9. `tenant_domains` is updated correctly.
10. The domain can then proceed to the website-hosting/hostname connection stage.

## Important LIVE caution

The domain registration Edge Function still requires a dedicated production-readiness audit before assuming it is safe for a real purchase. Historical code contains TEST/sandbox-oriented behaviour and must not be treated as production-ready merely because Stripe Checkout has been reached.

Specifically audit:
- LIVE Porkbun production API credentials
- sandbox vs production flags
- registration function
- Stripe webhook
- registrant-details flow
- expiry capture
- `tenant_domain_orders` status transitions
- `tenant_domains` activation
- idempotency/retry behaviour
- removal of remaining TEST-only wording from LIVE functions

## Database / Git state

LIVE Supabase:
`gxsrajtqzdjvmceqcpgv`

LIVE pricing configuration:
- markup: 25%
- USD/GBP: 0.74549089
- source: Bank of England
- period: 2025-10-01 through 2026-09-30

Recent production migrations:
- `20261005200000_duplicate_domain_pricing_rules_to_live.sql`
- `20261005201500_fix_live_domain_pricing_grants.sql`
- `20261005203000_add_domain_order_pricing_snapshot_columns.sql`

Pricing snapshot migration commit:
`cae5798635f9bebc4e2f776245ca083a67f83686`

## Website Builder lock

The Website Builder is a separate locked baseline and must not be altered as part of this domain-purchase test.

Checkpoint:
`CHECKPOINTS/2026-10-05-standard-website-builder-locked.md`

Do not redesign, resize, reposition, or restructure the locked builder layout while completing the domain purchase test.
