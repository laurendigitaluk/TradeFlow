# TradeFlow checkpoint — customer-owned domain connection

Date: 6 October 2026

## Decision

TradeFlow will no longer offer the previous automatic customer domain purchase/registrar-registration workflow.

The approved model is:

Customer buys and owns the domain
→ customer enters the domain in TradeFlow
→ TradeFlow creates a domain-connection request
→ Platform Owner receives an owner-dashboard action notification
→ Platform Owner prepares the approved TradeFlow/Cloudflare custom-domain connection
→ customer receives exact DNS instructions
→ customer applies the DNS records at their registrar
→ TradeFlow verifies DNS and SSL/HTTPS
→ domain becomes active and routes to the correct subscriber website.

## Subscriber responsibilities

The subscriber:

- buys the domain from a registrar of their choice;
- keeps the domain in their own registrar account;
- pays the registrar directly;
- keeps the domain renewed;
- keeps registrar contact/registrant information accurate;
- enters the domain under Website → Website URL in TradeFlow;
- applies only the DNS records supplied by TradeFlow;
- never provides their registrar password to TradeFlow.

## Platform Owner responsibilities

The Platform Owner:

- receives a DOMAIN CONNECTION REQUIRED action;
- verifies the subscriber and requested hostname;
- checks for duplicate/conflicting domain records;
- prepares the custom-domain connection using the approved hosting architecture;
- supplies exact DNS instructions;
- verifies DNS;
- verifies SSL/HTTPS;
- confirms the hostname routes to the correct tenant website;
- activates the domain;
- closes the outstanding owner action.

## Important boundary

TradeFlow must not invent DNS targets, request registrar credentials, or mark a domain active without DNS/SSL and tenant-routing verification.

## Current implementation position

The subscriber Website Manual and Human User Manual have been updated on the TEST/main branch with the new customer-owned domain instructions.

The subscriber Website URL page has been updated on TEST/main to remove the customer-facing automatic-purchase path and explain the new process.

The internal Backend/Owner Manual now documents the Platform Owner procedure.

The next implementation step is the actual Platform Owner dashboard notification/action workflow and the corresponding domain connection verification controls.

This checkpoint does not promote anything to LIVE.


## 2026-10-06 — owner action workflow implemented in TEST/main

The customer-owned domain request is now wired to an authoritative TEST Supabase workflow.

### Subscriber side
- domain-settings.js no longer creates/updates tenant_domains directly for a custom-domain request.
- It calls subscriber_request_custom_domain(p_hostname).
- The RPC validates the subscriber tenant/website permission, normalises the hostname, prevents a domain already attached to another tenant from being requested, creates or resets the pending tenant_domains record, and creates/reopens the corresponding Platform Owner action atomically.
- The retired automatic purchase-order code has been removed from the subscriber domain-settings controller.
- Subscriber guidance now explicitly tells the subscriber to wait for the Platform Owner's exact DNS instructions.

### Platform Owner side
- New TEST table: public.platform_owner_domain_actions.
- New owner-only RPCs:
  - platform_owner_list_domain_actions()
  - platform_owner_update_domain_action(...)
- The Platform Owner dashboard now has a Domain connections area with open-action count.
- The owner can review the business/domain request, record notes, set the action state, and store the exact DNS record information once the approved hosting target is known.
- The UI explicitly prevents the workflow from implying that a DNS target should be invented.
- An action cannot be marked completed by the RPC unless the domain itself is already active with both verified_at and activated_at set. This prevents manual closure from substituting for DNS/SSL/routing verification.

### Important current boundary
The actual hosting/Cloudflare custom-hostname provisioning and DNS/SSL verification layer is not yet implemented by this change. The owner dashboard therefore does not invent or apply DNS targets and does not mark domains active. That remains the next technical stage after inspecting the existing published-site/hosting architecture.

### TEST migration
- supabase/migrations/20261006142730_customer_owned_domain_owner_actions.sql
- Applied successfully to TEST Supabase.
- GitHub main contains the same version-controlled migration.

Nothing from this change has been promoted to LIVE.
