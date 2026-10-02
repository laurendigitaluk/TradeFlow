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

## Chat-close documentation state — 2026-10-02

Before doing any new work, treat the current TEST state as authoritative rather than relying on older registrar references elsewhere in the repository.

The current registrar is **Porkbun**. ResellerClub and GoDaddy are not current TradeFlow registrar providers. Manual shipping remains final; do not revive Parcel2Go API work.

The payment and registrant stages are closed test stages:
- `camerashack.co.uk`
- £5.27 GBP TEST Stripe payment
- `payment_confirmed`
- registrant record saved
- `registrant_details_saved`

The browser currently reports Porkbun sandbox validation passed. The next chat must independently inspect the implementation/logs before treating that as proof of a successful Porkbun API dry run.

### Exact next objective

Build/verify the smallest TEST-only Porkbun registration path:

**saved paid order → load saved registrant → Porkbun registration requirements → `dryRun: true` → sandbox registration → `tenant_domains` reconciliation → `registered` → existing domain connection/DNS test.**

Do not repeat Stripe payment testing unless a dependency fails. Do not make a real registrar registration.

### Documentation state

At chat close, the authoritative manuals were updated:
- System handbook commit: `b43c4f1e4c50e3f76736fe5b4467567e4cdeb878`
- AI operating manual commit: `f1d588b0897853ad47e14ed14cba97d714e1ab16`
- Backend manual commit: `3dbd30089233bb09654936c9c838d94215a96d9c`
- Human manual commit: `608157346b586325912847b552a672d1004b37fc`

The next chat should update these manuals and the checkpoint again after the sandbox-registration stage is actually verified.



## CURRENT STATE OVERRIDE — 2026-10-02 expiry reconciliation repair

The earlier sections describing the next task as a first sandbox registration are historical and are superseded by this section.

The TEST sandbox registration has already succeeded for `camerashack.co.uk` using provider order `9913828`. TradeFlow order status is `registered`, and one active `tenant_domains` row exists with `acquisition_source=purchased` and `registrar_provider=porkbun`. Contact synchronisation remains deliberately deferred for the .co.uk sandbox path because immediate contact updates produced V096 and repeated provider notifications.

The remaining unverified item in this stage is **expiry persistence**. Direct TEST database verification showed both order and tenant-domain `expires_at` are null, even though the browser previously displayed “Expiry: recorded”. No date should be invented.

A repair is now deployed as Porkbun registration Edge Function version 7. It:
- keeps the existing provider order and never creates a second sandbox registration when reconciling an already-registered sandbox order;
- reads Porkbun domain details server-side;
- falls back to Porkbun `/domain/listAll` when the direct lookup lacks `expireDate` or `createDate`;
- persists the provider expiry only when Porkbun actually returns it;
- allows the registered TEST page to refresh provider registration details.

Immediate next action:
1. Open the existing TEST registrant page for the already-paid order.
2. Press **Refresh provider registration details** once.
3. Verify `tenant_domain_orders.expires_at` and `tenant_domains.expires_at` directly in TEST.
4. Verify the provider expiry metadata is populated.
5. Only then proceed to the existing provider-neutral website connection and `published_site_index` hostname routing.

Do not register the domain again. Do not touch LIVE. Do not rebuild the domain foundation.


## CURRENT STATE OVERRIDE — 2026-10-02 expiry persistence VERIFIED

The TEST Porkbun sandbox registration and expiry reconciliation are now verified end-to-end for `camerashack.co.uk`.

Verified TEST database state:
- `tenant_domain_orders.status = registered`
- provider order: `9913828`
- `tenant_domain_orders.expires_at = 2027-10-02 12:01:45+00`
- `tenant_domains.status = active`
- `tenant_domains.acquisition_source = purchased`
- `tenant_domains.registrar_provider = porkbun`
- `tenant_domains.expires_at = 2027-10-02 12:01:45+00`
- order metadata contains `porkbun_expire_date = 2027-10-02 12:01:45`
- no second registration was created.

The expiry repair path is therefore closed. The current TEST Edge Function is version 9. The .co.uk sandbox reconciliation now uses the shared provider lookup, including the direct Porkbun domain lookup and `/domain/listAll` fallback when required.

Contact synchronisation remains deliberately deferred for the sandbox .co.uk path because immediate contact updates produced Nominet V096. This does not block the verified sandbox registration/expiry stage.

### Next stage

Proceed to the existing provider-neutral website/domain connection and hostname routing architecture. First inspect the current GitHub implementation and TEST Supabase state for `published_site_index`, `tenant_site_state`, website publish flow, `public-site.js`, and domain settings. Do not invent a hosting/DNS target and do not rebuild the domain foundation.

LIVE remains untouched.

## POST-CHATBOT CONTINUATION — REAL DOMAIN / LAUREN DIGITAL LAUNCH

The immediate work before returning to this domain stage is to complete and test the TradeFlow chatbot.

When the chatbot is complete, resume here by auditing the current GitHub, TEST Supabase, Cloudflare TEST Worker, manuals and checkpoints. Do not assume the earlier state is unchanged.

The chatbot is staged as:
1. Subscriber read-only assistant.
2. Customer read-only assistant.
3. Controlled messaging/enquiries.
4. Controlled actions only after earlier phases are proven.

The chatbot must use the approved manuals/documentation and permitted tenant context, must not have unrestricted SQL/database access, and must not cross tenant boundaries.

The permanent company identity is Lauren Digital. TradeFlow is the SaaS/product name for subscriber websites.

The next domain work is NOT to force `camerashack.co.uk` through Cloudflare. That domain is a Porkbun sandbox registration and Cloudflare correctly reports that it is not a real registered public zone.

Current Cloudflare TEST Worker:
`tradeflow-test.leannelaurenlowe.workers.dev`

Branch:
`cloudflare-test`

TEST Supabase:
`twfbmjwwqzxdxvclxbun`

No custom domain is currently attached to the TEST Worker.

After chatbot completion:
1. Choose the permanent Lauren Digital domain.
2. Purchase the genuine domain.
3. If needed, purchase one inexpensive genuine test domain.
4. Use the genuine test domain to prove real DNS → Cloudflare → TEST Worker → TEST Supabase → published subscriber website.
5. Verify tenant routing and environment isolation.
6. Configure the permanent Lauren Digital production domain separately.
7. Only then move to final production launch testing.

Do not touch LIVE or production DNS while carrying out the TEST custom-domain proof.

See `CHECKPOINTS/2026-10-02-chatbot-to-real-domain-launch.md` for the preserved state.
