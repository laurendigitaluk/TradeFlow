# TradeFlow Checkpoint — 2026-10-07 — LIVE Branded URL and Business Slug Routing

## Verified position

LIVE production now has a branded platform URL:

`https://tradeflow.laurendigital.co.uk`

Cloudflare:
- zone: `laurendigital.co.uk`
- zone is active on the Free plan;
- existing Worker: `tradeflow`;
- Custom Domain: `tradeflow.laurendigital.co.uk`;
- no second Worker created.

Browser verification:
- public TradeFlow homepage loads over HTTPS;
- subscriber Sign In works;
- Adventure Outpost authenticates;
- Adventure Outpost Business Dashboard loads.

## URL cleanup

The internal `tenant_id` remains the authoritative tenant/security identifier.

Subscriber-facing URL cleanup now uses a URL-safe business slug where appropriate:
- Business: `Adventure Outpost`
- Slug: `adventure-outpost`

The subscriber workspace resolves the slug through `subscriber_get_my_tenant_slug` and removes the legacy `tenant_id` query parameter from the visible browser URL after tenant context is established.

The internal UUID remains in local authenticated state and database/API operations where required.

## Current code boundary

Relevant production files:
- `subscriber-auth.js`
- `subscriber-tenant-context.js`
- `subscriber-website.html`
- `public-site.js`

Relevant RPCs:
- `subscriber_get_my_tenant_slug(uuid)`
- `get_published_site_by_slug(text)`

The URL cleanup does not alter the Website Builder, publishing workflow, authentication model, customer-owned domain workflow or Cloudflare Worker configuration.

## Lauren Digital structure

Lauren Digital is the parent/company brand. TradeFlow is a Lauren Digital product.

Planned:
- `laurendigital.co.uk` — parent/company site;
- `tradeflow.laurendigital.co.uk` — TradeFlow;
- future product subdomains as products are completed.

A future parent homepage and separate owner-only login route are planned only; they are not current implementation scope.

## Domain architecture guardrail

Subscriber-owned domains remain the current customer-domain model. The retired TradeFlow/Porkbun subscriber purchase/registration workflow must not be reintroduced.

`laurendigital.co.uk` is Lauren Digital infrastructure and was purchased directly through Porkbun. It is not a subscriber tenant domain.

## Documentation state

Updated:
- AI Operating Manual
- Backend User Manual
- Human User Manual
- System Handbook
- Master Roadmap
- Subscriber Website Manual
- Project Memory

Next chat must read this checkpoint before making URL, Worker, Cloudflare or tenant-routing changes.
