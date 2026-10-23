# BusinessFlow — Product Scope and Environment Plan

Status: agreed scope for the initial standalone website-builder product
Date: 2026-10-23

## Product definition

BusinessFlow is a simple general-purpose website builder for small businesses and service providers, including roofers, builders, tradespeople, and other local businesses. It reuses the appropriate visual/editor concepts from the TradeFlow website builder but is an independent product.

## Initial scope

- A business homepage with editable business name, text, colours, calls to action, and content cards.
- Standard pages such as Services, Projects, About, and Contact.
- Ability to add and manage additional custom pages.
- A clear edit/preview workflow.
- A small set of reusable, service-business-friendly templates.
- Mobile-responsive pages and accessible, understandable controls.

## Explicit exclusions for the initial version

- No TradeFlow product catalogue, buying, acquisitions, inventory, sales, shipping, or transaction features.
- No connection to TradeFlow's Supabase projects, tables, authentication, customer records, or APIs.
- No Stripe integration in TEST or LIVE at this stage. Subscription billing may be planned separately later.
- No domain registration or customer-domain publishing until a later, separately verified phase.
- No claim that the current prototype saves or publishes websites: its current edits are temporary and are lost on refresh.
- No external integrations other than the planned link to the shared Lauren Digital public homepage.

## Relationship to Lauren Digital

LaurenDigital.co.uk remains the shared public-facing parent-company homepage. BusinessFlow is a separate product. A link to the parent homepage is acceptable; this does not mean BusinessFlow shares TradeFlow's runtime, data, secrets, or deployment.

## Environment model

### BusinessFlow TEST
- Used for development, template work, bug fixing, and end-to-end testing.
- Must have its own Worker/service and environment configuration.
- Must not use TradeFlow LIVE or TEST resources.
- No real billing or production customer data.
- Access and exposure must be intentionally configured before use.

### BusinessFlow LIVE
- Separate Worker/service and configuration from BusinessFlow TEST.
- Remains unpublished or restricted until TEST checks pass and the deployment is verified.
- No Stripe, database, authentication, or publishing integration until those features are separately designed and approved.
- Promotes only reviewed and tested code from BusinessFlow TEST.

## Isolation and release rules

1. Keep BusinessFlow source and deployment configuration independent from TradeFlow's production deployment.
2. Do not modify TradeFlow LIVE, TradeFlow TEST, its production branch, shared Worker, DNS, Supabase projects, or data as part of BusinessFlow work.
3. Do not reuse TradeFlow credentials, secrets, or environment variables.
4. Use separate deployment configuration and explicit environment names for BusinessFlow TEST and LIVE.
5. Never connect a production domain or expose a LIVE release until the deployed build, access settings, and rollback path have been checked.
6. Treat the current review prototype as a starting point, not a production-ready builder. Before describing the product as ready, implement and test the agreed save/publish behaviour or clearly keep those features out of scope.
7. Add external integrations only when their purpose, permissions, data handling, and environment separation are documented.

## Current checkpoint

The isolated review prototype exists on branch `feature/businessflow-isolated-builder-review-20261023` in the TradeFlow repository. It has no persistent saving, authentication, database, image upload, working contact form, or publish workflow. Its source/static-preview identity and source-level checks were previously verified; Cloudflare deployment and real-browser interaction tests remain unverified.

## Next steps

1. Establish an independent BusinessFlow repository if repository-creation access is available; otherwise keep the prototype isolated until a clean repository can be created.
2. Set up distinct BusinessFlow TEST and LIVE deployments without touching TradeFlow.
3. Deploy TEST and verify the editor in a browser.
4. Fix issues in TEST and run the acceptance checklist.
5. Only then prepare LIVE, with access restrictions and rollback verified.
6. Keep the Lauren Digital homepage link as the only planned external relationship for the initial version. Stripe remains explicitly deferred.
