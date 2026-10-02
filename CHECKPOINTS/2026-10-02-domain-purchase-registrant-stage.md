# TradeFlow Checkpoint — Domain Purchase & Registrant Stage — 2026-10-02

## Environment
- TEST/STAGING branch: `main`
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv` — untouched.
- Current registrar provider: Porkbun.
- Porkbun TEST credentials are sandbox credentials; no LIVE registrar registration has been enabled.

## Verified in TEST
1. Domain search and Porkbun availability work.
2. Customer pricing is calculated in GBP using the stored platform FX rate and 25% markup.
3. Customer selected `camerashack.co.uk`.
4. Stripe TEST Checkout was completed for £5.27.
5. Stripe webhook changed the order to `payment_confirmed`.
6. Registrant details were submitted and saved.
7. Current TEST order:
   - hostname: `camerashack.co.uk`
   - status: `registrant_details_saved`
   - retail amount: £5.27 GBP
   - Stripe Checkout session reference is stored.
8. Current registrant record exists in `tenant_domain_registrants` and is linked one-to-one to the domain order.
9. The TEST UI currently displays a Porkbun sandbox validation section and reports that sandbox validation passed.

## Registrant data architecture
- Added `tenant_domain_registrants`.
- One registrant record is linked to one `tenant_domain_orders` row.
- Tenant RLS permits tenant members to read and website managers/editors to insert/update.
- Added `registrant_details_saved` domain-order status.
- Added JWT-protected `save-domain-registrant` Edge Function.
- Added TEST page `domain-registrant.html` and `domain-registrant.js`.

## Payment architecture
- `create-domain-checkout-session` remains TEST-only and server-rechecks Porkbun availability/pricing.
- Stripe webhook sets domain orders to `payment_confirmed`.
- Actual Porkbun registration is still NOT enabled in the live environment.

## Current next stage
Use Porkbun sandbox registration only.
- First perform/retain a dry-run validation.
- Then, only after the dry-run is successful, perform the isolated Porkbun sandbox registration.
- Reconcile the sandbox registration into `tenant_domains`.
- Record provider domain ID and expiry.
- Then test domain contact synchronisation and the existing provider-neutral domain connection/website routing.
- Do not enable real Porkbun registration until the complete TEST sequence is verified.

## Safety boundary
Porkbun's current API documentation confirms that sandbox keys isolate registrations from the real registry and charges, and that `dryRun: true` rehearses registration without performing it. The production registration step must remain disabled until TEST is fully verified.

## GitHub commits from this stage
- `764e55d9edaa3587fdae65d512853be260eedd15` — domain registrant page.
- `5c8b9c4a43a4ce1fd778dc121a89165821d41a41` — registrant page JavaScript.
- `e69994d4c7d4bb992fad96d6c848c5966d074434` — tracked checkout function source.
- `ae70d45fa61cf4ebc2374703667d25c9213d6c13` — tracked registrant save function.
- `107d436229845e1cd13038f15e88381e7ef436b1` — registrant migration.
- `e51ca9ceddbfd7a1fff57d4975649b8b1f4c3930` — registrant status migration.
- TEST `create-domain-checkout-session` is active at version 2.

## Do not
- Do not touch LIVE.
- Do not revive Parcel2Go API work.
- Do not switch back to ResellerClub.
- Do not send a real Porkbun registration request.

## Documentation updated at chat close
The following authoritative manuals were updated with this handover and next-stage rules:
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Latest documentation commits:
- System handbook: `289fed62489bb7e025d14311a3a21b2829f26049`
- Backend manual: `bfeaa4c046b401af37c68d092edf6b938486835c`
- Human manual: `4f2fa79bfdab5a83910ac878fe34bfdf4a4af102`
- AI operating manual: `939c5d267bb1003c6346d7055b75182d31608c9b`
