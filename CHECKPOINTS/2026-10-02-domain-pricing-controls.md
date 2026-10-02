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


## Domain purchase and registrant stage — 2026-10-02
- TEST Stripe domain checkout was completed successfully for `camerashack.co.uk` at £5.27 GBP.
- TEST `tenant_domain_orders` confirms status `payment_confirmed`, Stripe provider/reference and Stripe event metadata. No Porkbun registration has been performed.
- Added `tenant_domain_registrants` to store the paid order's legal registrant contact details separately from the domain order.
- Added `registrant_details_saved` as a domain-order status.
- Added TEST Edge Function `save-domain-registrant` to validate and save registrant details for the authenticated tenant member.
- Added `domain-registrant.html` / `domain-registrant.js` as the post-payment registrant details page.
- Domain checkout success URL now goes to the registrant details page. Re-entry against an already-paid order is blocked instead of creating a duplicate payment order.
- Next controlled stage: validate registrant details in the TEST UI, then implement Porkbun sandbox `dryRun` and sandbox registration, followed by reconciliation into `tenant_domains`.
- LIVE remains untouched.

## Current TEST domain order
- `camerashack.co.uk` — £5.27 GBP — `payment_confirmed` — order `59409e55-5426-4b0b-9020-4615244e5d83`.


## Domain payment + registrant stage verified 2026-10-02
- TEST Stripe payment for the domain purchase completed successfully.
- TEST domain order for the current test domain reached `payment_confirmed` through the Stripe webhook.
- Added `tenant_domain_registrants` with tenant/order-scoped RLS.
- Added subscriber registrant-details page and protected `save-domain-registrant` Edge Function.
- Registrant details were successfully saved during TEST.
- Found and repaired a legacy duplicate `tenant_domain_orders` status constraint that still excluded `registrant_details_saved`. The TEST order was then advanced to `registrant_details_saved`.
- Added protected `porkbun-domain-registration-dry-run` Edge Function.
- The next UI action is **Validate registration**, which calls Porkbun's sandbox dry-run only. It does not register or charge anything.
- Porkbun's current API documentation confirms sandbox registrations are isolated/no-charge, `dryRun:true` performs pre-flight validation without creating or charging, and `/domain/getRegistrationRequirements/{tld}` should be checked before registration. citeturn4view0turn6view0
- Important provider finding: current Porkbun `/domain/create/{domain}` request schema does not accept per-order registrant contact fields; Porkbun exposes `/domain/updateContacts/{domain}` separately. For address-validated TLDs including .uk/.co.uk, contact updates can invoke address validation. This must be tested in sandbox before any LIVE registration design is finalised. citeturn5view2turn7view0
- LIVE Supabase remains untouched.
