# TradeFlow Checkpoint — Domain Pricing Controls — 2026-10-02

## Environment
- TEST/STAGING Git branch: `main`
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv` — not changed in this work.
- Porkbun is the current tested registrar provider for domain availability/pricing.
- ResellerClub is not the active provider and its Cloudflare/egress boundary remains documented separately.

## Completed tonight
- Added platform-owner domain pricing settings in TEST.
- Default domain markup: 25%.
- Customer currency: GBP.
- Fixed USD-to-GBP rate: 0.74549089 GBP per USD.
- FX basis: Bank of England XUMAUSS, 12-month average covering 2025-10-01 to 2026-09-30.
- FX monitoring threshold: 5%.
- Last reviewed: 2026-10-02.
- Added Owner Dashboard controls for markup, FX rate, FX period, review threshold and review date.
- Added a Bank of England monitoring link and a notice explaining that the stored rate is fixed until the owner reviews/updates it.
- Porkbun domain availability Edge Function upgraded to version 5. It now reads the trusted pricing settings server-side and returns a GBP customer price for available domains.
- Domain search cards now display the customer price in GBP rather than the Porkbun USD registrar price.
- Added order pricing snapshot fields to `tenant_domain_orders` so future paid orders can preserve registrar USD cost, FX rate, markup and FX period.
- Removed stale ResellerClub wording from the subscriber Website URL page.
- No domain registration or Stripe domain checkout was enabled by this change.

## Pricing rule
Customer price = round( registrar USD price × stored GBP/USD rate × (1 + markup% / 100), 2 ).

The pricing settings are server-read by the Porkbun availability function. Frontend values are display-only and are not trusted for future payment/order creation.

## Next step
When work resumes, build the domain purchase/payment stage separately:
1. Choose domain.
2. Recheck availability and price server-side.
3. Create `tenant_domain_orders` row with a pricing snapshot.
4. Create GBP Stripe Checkout session for that exact retail amount.
5. Process Stripe webhook.
6. Only after payment is confirmed, call Porkbun registration.
7. Reconcile registration result and create/update `tenant_domains`.
8. Add registrant/ownership data, DNS/hosting connection and renewal lifecycle.

Do not connect the current Choose button directly to Porkbun registration.

## GitHub
Latest TEST `main` commit at checkpoint: `3cc2208e62702ee68d909a103d646bd985043822`.

Relevant commits immediately before this checkpoint:
- `749283c6f1738eaec44d49851c65e4d2fa70d35b` — Owner Dashboard domain pricing controls.
- `aef090248dd88f54e99d63f30dc21ed6e5d8d9c5` — GBP customer prices on domain cards.
- `fb760a1d5f108c1481808a9e95a0d7163c6366e7` — domain pricing migration record.
- `466d6061fd3cf27e35a6b9342005e9022783bf22` — tracked Porkbun pricing Edge Function.
- `b04bec6dbe39fed4037000d19dc12fa141232b96` — stale registrar wording removed.

## Supabase
- Migrations applied to TEST: `20261002023000_domain_pricing_controls`, followed by `20261002023500_domain_pricing_rls_cleanup`.
- Porkbun Edge Function: `porkbun-domain-availability`, active version 5, JWT verification enabled.
- LIVE was not modified.

## Domain payment stage added on 2026-10-02
- Added TEST Edge Function `create-domain-checkout-session`, JWT protected.
- It authenticates the subscriber, verifies tenant membership, rechecks availability and current Porkbun USD cost server-side, calculates the trusted GBP retail price, creates/refreshes `tenant_domain_orders`, and creates a GBP Stripe Checkout session.
- Stripe metadata carries `tenant_id`, `domain_order_id` and `hostname`.
- Added `payment_confirmed` as a domain-order status.
- Updated the existing TEST Stripe webhook to recognise domain payments and move the domain order to `payment_confirmed` after Stripe confirms payment.
- The subscriber Choose button now starts the secure checkout flow.
- Actual Porkbun registration is intentionally NOT triggered yet. Registrant ownership/contact information still needs to be captured and verified before a paid domain is submitted to the registrar. Porkbun's current API requires registration contact information and supports sandbox registration/testing, so this remains the next controlled stage.
- LIVE remains untouched.
