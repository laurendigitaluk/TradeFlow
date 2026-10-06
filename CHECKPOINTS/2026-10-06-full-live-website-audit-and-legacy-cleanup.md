# TradeFlow — Full LIVE Website Audit and Legacy Cleanup — 2026-10-06

## Purpose

This checkpoint records the full website/source/documentation audit performed against the current LIVE architecture while Cloudflare nameserver propagation is pending.

## Current authoritative architecture

- LIVE GitHub branch: `production`.
- LIVE Supabase: `gxsrajtqzdjvmceqcpgv5`.
- LIVE application path: GitHub → Cloudflare Worker → LIVE Supabase.
- Website Builder publication remains separate from application deployment:
  **Edit → Save Draft → Preview → Publish → published revision becomes LIVE → fresh draft**.
- The 5 October Website Builder baseline is locked and must not be redesigned or structurally altered unless explicitly reopened.
- Shipping is manual subscriber-managed shipping. Parcel2Go API/checkout/payment-link shipping is retired.
- Subscriber domains are customer-owned. TradeFlow does not purchase, renew or pay for subscriber domains and does not request registrar passwords.

## Current domain architecture

Subscriber:
**buy/own domain → enter hostname in Website URL → connection request → Platform Owner prepares connection → exact DNS instructions → subscriber applies DNS → DNS/SSL/routing verification → active domain**

The LIVE Platform Owner workflow is phased:
1. Review request.
2. Prepare connection automatically.
3. Give customer DNS instructions.
4. Verify DNS.
5. Verify SSL/HTTPS.
6. Verify tenant routing.
7. Activate domain.

Activation is database-guarded and requires all three verification flags.

## Cloudflare infrastructure position

- `laurendigital.co.uk` has been purchased directly through Porkbun as the Lauren Digital/TradeFlow infrastructure domain.
- Cloudflare Free zone setup is in progress.
- Porkbun nameservers have been changed to the Cloudflare-assigned nameservers.
- Cloudflare is currently waiting for nameserver propagation.
- The zone must not be treated as active until Cloudflare reports it active.
- Automatic custom-hostname preparation is implemented in LIVE through `platform-prepare-custom-domain`.
- Its source is now version-controlled at `supabase/functions/platform-prepare-custom-domain/index.ts`.
- Required server-side configuration remains `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID` and `CLOUDFLARE_SAAS_CNAME_TARGET`.

## Cleanup completed

Removed from LIVE production source because they are retired or unused:
- `domain-purchase.html`
- `domain-purchase.js`
- `domain-registrant.html`
- `domain-registrant-live.html`
- `domain-registrant.js`
- retired domain purchase/checkout/availability/registration/dry-run/reconciliation/registrant-save Edge Function source
- Parcel2Go customer/subscriber Edge Function source
- ResellerClub availability Edge Function source
- unused shipping-provider test Edge Function source
- unused duplicate Inventory runtime
- unused duplicate Selling runtime
- unused customer-dashboard auth-fix runtime

The active `domain-settings.html/js` workflow was preserved.

## Supabase audit result

LIVE currently contains the active domain connection objects:
- `tenant_domains`
- `platform_owner_domain_actions`
- `subscriber_request_custom_domain()`
- `subscriber_get_custom_domain_status()`
- `platform_owner_list_domain_actions()`
- `platform_owner_update_domain_action()`
- `platform-prepare-custom-domain`

Historical domain-order/pricing tables and already-deployed retired functions remain in LIVE for now. They were not destructively removed because dependency proof is not complete and the available project connector does not expose Edge Function deletion. They are not part of the current subscriber Website URL workflow.

Supabase security/performance advisor findings were reviewed. Existing broader findings were not changed blindly during this cleanup.

## Documentation updated

Current operating architecture was updated in:
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-BACKEND-USER-MANUAL.md`
- `TRADEFLOW-MASTER-ROADMAP.md`

The human manual no longer presents the retired TradeFlow domain-purchase/registration path as a current user workflow.

Historical checkpoints remain intentionally preserved as audit/restore evidence. They are not current operating instructions.

## Next action

Wait for Cloudflare nameserver propagation. Once the zone is Active, continue with:
1. confirm Cloudflare zone ID;
2. configure the actual fallback/origin routing for TradeFlow;
3. configure the actual Cloudflare SaaS CNAME target;
4. enable/verify Cloudflare for SaaS;
5. save the real zone ID/CNAME target as server-side secrets;
6. test automatic preparation against the existing pending subscriber domain request;
7. verify DNS, SSL and tenant routing before activation.

Do not invent DNS targets or mark a domain active before verification.
