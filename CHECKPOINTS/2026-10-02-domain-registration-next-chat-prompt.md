# TRADEFLOW CONTINUATION PROMPT — DOMAIN REGISTRATION NEXT STAGE — 2026-10-02

You are continuing work on the existing TradeFlow project for Lauren Digital. Do not rebuild the architecture. Continue from the verified TEST state below.

## Environment and branch rules

- GitHub repository: `laurendigitaluk/TradeFlow`
- TEST/STAGING branch: `main`
- LIVE branch: `production`
- TEST Supabase project: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`
- TEST One remains the known-good baseline.
- LIVE must not be modified while completing this TEST work.
- Never run `supabase db reset --linked` against LIVE.
- Do not touch the separate Action-Buyer-UK project.
- Manual shipping is final. Do not revive Parcel2Go API integration.
- Do not switch back to ResellerClub.
- Porkbun is the current tested domain registrar.
- Porkbun TEST credentials are sandbox credentials.

## Current verified domain workflow

The domain purchase flow has been successfully tested through payment and registrant information:

1. Subscriber searches for a domain.
2. TradeFlow checks availability through Porkbun.
3. TradeFlow calculates the customer price in GBP using the trusted platform FX rate and markup.
4. Subscriber chooses an available domain.
5. TradeFlow creates a `tenant_domain_orders` record.
6. TradeFlow creates a GBP Stripe Checkout session.
7. TEST Stripe payment was successfully completed for `camerashack.co.uk` at £5.27.
8. Stripe webhook successfully changed the order to `payment_confirmed`.
9. Subscriber returned to the TradeFlow domain registrant page.
10. Registrant details were entered and saved.
11. The order is now `registrant_details_saved`.
12. The TEST UI shows the next stage as Porkbun sandbox validation and reports that sandbox validation passed.

Current TEST order:
- Domain: `camerashack.co.uk`
- Retail price: £5.27 GBP
- Status: `registrant_details_saved`
- Stripe payment reference is stored.
- A linked `tenant_domain_registrants` record exists.

## Current domain pricing

Owner-controlled TEST pricing settings:
- Customer currency: GBP
- Markup: 25%
- Stored USD→GBP rate: 0.74549089 GBP per USD
- FX basis: Bank of England XUMAUSS, 12-month average
- Period: October 2025 through September 2026
- Review threshold: 5%
- Last reviewed: 2026-10-02

Formula:
customer price = round(registrar USD price × stored GBP/USD rate × (1 + markup/100), 2)

Existing paid orders preserve the pricing snapshot.

## Existing domain architecture — preserve it

Provider-neutral domain foundation already exists:
- `domain-settings.html`
- `domain-settings.js`
- `public-site.css`
- `public-site.html`
- `public-site.js`
- `subscriber-website.html`
- `subscriber-website-manual.html`
- `website-builder.html`
- `website-builder.js`
- `domain_tld_catalog`
- `tenant_domain_orders`
- `tenant_domains`
- `published_site_index`
- `tenant_site_state`

Do not delete or rebuild this foundation.

## New domain registration stage

Added:
- `tenant_domain_registrants` — one-to-one with `tenant_domain_orders`
- domain order status: `registrant_details_saved`
- `save-domain-registrant` JWT-protected Edge Function
- `domain-registrant.html`
- `domain-registrant.js`

The registrant record contains:
- legal name
- organisation
- address
- city
- region
- postcode
- country code
- email
- telephone
- confirmation timestamp

RLS is enabled.

## Next task: Porkbun Sandbox Registration

Do this in controlled stages.

### Stage 1 — inspect before changing anything

First inspect:
- latest GitHub `main`
- latest TEST Supabase schema
- `tenant_domain_orders`
- `tenant_domain_registrants`
- `tenant_domains`
- current Porkbun Edge Functions
- current domain checkpoint
- current manuals

Confirm the actual TEST order is still `camerashack.co.uk` with status `registrant_details_saved`.

### Stage 2 — build dry-run validation

Create a TEST-only, JWT-protected registration validation function.

Requirements:
- authenticate the subscriber/tenant
- load the paid domain order
- load the linked registrant record
- do not trust registrant data supplied by the browser when the order record already exists
- verify the order is `registrant_details_saved`
- verify the domain is still available as appropriate
- call Porkbun sandbox registration with `dryRun: true`
- use the Porkbun registration requirements for the domain TLD
- return a clear validation result
- do not modify `tenant_domains` on dry-run
- do not perform real registration
- record useful diagnostic metadata without storing secrets

### Stage 3 — perform isolated Porkbun sandbox registration

Only after dry-run succeeds:
- call Porkbun sandbox registration
- use the saved registrant information
- use the sandbox API credentials only
- use one year initially
- use the Porkbun sandbox registration endpoint
- capture provider domain ID
- capture expiry/registration information
- capture provider response safely
- do not expose API credentials in frontend code or logs

### Stage 4 — reconcile into TradeFlow

After successful sandbox registration:
- create/update the existing `tenant_domains` record
- link it to the tenant and domain order
- record provider/registrar identity
- record provider domain ID
- record hostname
- record expiry
- record registration status
- mark the order `registered` only after reconciliation succeeds
- preserve the original payment and pricing snapshots

The database should represent the sequence clearly:
`payment_confirmed` → `registrant_details_saved` → `registering` → `registered`

If registration fails:
- use `failed`
- preserve the failure reason
- do not falsely mark the domain registered
- do not lose the paid-order record.

### Stage 5 — test existing domain connection

After sandbox registration:
- use the existing provider-neutral domain connection architecture
- test the domain's connection/routing configuration
- verify the tenant website can use the domain
- do not rebuild the website builder or public-site architecture
- verify DNS/connection state before proceeding to LIVE.

### Stage 6 — document and checkpoint

After each successful stage:
- verify TEST database state
- update the checkpoint
- update system handbook
- update backend manual
- update human user manual
- update AI operating manual
- record the exact Edge Function versions and GitHub commits
- keep LIVE explicitly marked untouched.

## Safety rules

Never:
- register a real production domain during TEST
- use LIVE Porkbun credentials in TEST
- enable production registration before TEST is complete
- revive Parcel2Go API
- switch back to ResellerClub
- delete the existing domain connection foundation
- bypass Stripe payment confirmation
- allow a browser to directly call Porkbun with registrar credentials
- store registrar API secrets in GitHub/frontend code
- assume sandbox success equals production success.

## Current important commits

Domain registrant frontend:
- `764e55d9edaa3587fdae65d512853be260eedd15`
- `5c8b9c4a43a4ce1fd778dc121a89165821d41a41`

Tracked domain checkout function source:
- `e69994d4c7d4bb992fad96d6c848c5966d074434`

Tracked registrant save function:
- `ae70d45fa61cf4ebc2374703667d25c9213d6c13`

Registrant database migration:
- `107d436229845e1cd13038f15e88381e7ef436b1`

Registrant status migration:
- `e51ca9ceddbfd7a1fff57d4975649b8b1f4c3930`

Latest domain checkpoint update:
- `ea301ddd4cb3403887c7101a9b2543c98a31dd51`

Documentation updates:
- System handbook: `289fed62489bb7e025d14311a3a21b2829f26049`
- Backend manual: `bfeaa4c046b401af37c68d092edf6b938486835c`
- Human manual: `4f2fa79bfdab5a83910ac878fe34bfdf4a4af102`
- AI operating manual: `939c5d267bb1003c6346d7055b75182d31608c9b`

## How to work in the next chat

Start by saying you have read this continuation prompt, then independently inspect the current GitHub and TEST Supabase state. Do not assume the commits above are the current HEAD if newer work exists.

Do not make a broad rebuild.

Find the first unverified step in the TEST domain-registration sequence, make the smallest safe change, test it, verify the database, and then update the documentation/checkpoint before proceeding.

The next immediate objective is:

**Porkbun TEST sandbox registration for the already-paid `camerashack.co.uk` order, beginning with a dry-run validation.**

LIVE remains untouched.
