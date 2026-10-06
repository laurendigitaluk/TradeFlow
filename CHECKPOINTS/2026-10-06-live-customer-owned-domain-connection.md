# LIVE Customer-Owned Domain Connection — 2026-10-06

## Decision
TradeFlow LIVE no longer sells or registers domains for subscribers. The only supported model is **subscriber-owned domains**.

## LIVE workflow
Subscriber buys/owns domain with their chosen registrar.
→ Subscriber opens Website → Website URL.
→ Subscriber enters hostname.
→ TradeFlow creates a connection request.
→ Platform Owner prepares the approved hosting connection and exact DNS instructions.
→ Subscriber applies DNS instructions at their registrar.
→ TradeFlow verifies DNS, SSL and tenant routing.
→ Domain is activated only after all three checks pass.
→ The active hostname is mapped to the tenant's current published website through `published_site_index`.

## LIVE implementation
- `public.subscriber_request_custom_domain(text)`
- `public.subscriber_get_custom_domain_status()`
- `public.platform_owner_list_domain_actions()`
- `public.platform_owner_update_domain_action(uuid,text,text,jsonb)`
- `public.platform_owner_domain_actions`
- `tenant_domains.acquisition_source = customer_owned`
- Owner Dashboard now contains Domain Connection Requests.
- Subscriber Website URL page no longer offers TradeFlow domain purchase.

## Safety rules
- Do not revive Porkbun automatic registration.
- Do not request registrar passwords.
- Do not invent DNS targets.
- Do not mark a domain active without DNS, SSL and tenant-routing verification.
- Subscriber authentication is unchanged.
- Website Builder layout is unchanged.
- LIVE is the build environment; do not move this work to TEST.

## Remaining operational step
The exact Cloudflare/hosting target still has to be supplied by the approved LIVE hosting configuration before DNS instructions are issued. The application deliberately does not invent that target.
