# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.5  
**Date:** 16 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. **Platform Owner is a separate platform-level security boundary and is never a tenant role.**

## Current environment
- GitHub: `laurendigitaluk/TradeFlow`, branch `main`.
- Supabase: `twfbmjwwqzxdxvclxbun`, region `eu-west-2`.
- Recorded health checkpoint: ACTIVE_HEALTHY.
- Recorded public-table checkpoint: RLS enabled across 60/60 public tables.
- GearCashOut is reference material only and must not be modified during TradeFlow work.

## Master roadmap

| # | Domain | Status | Current evidence / next action |
|---|---|---|---|
| 1 | Tenant & identity | AMBER | Production onboarding still must replace/harden development authenticated tenant-insert/test-lab paths. |
| 2 | Subscriptions & capability gating | GREEN | Capability layer implemented; Buying 17/17 and Selling 17/17 customer subscription tests recorded. |
| 3 | Categories, fields & options | AMBER | Buying dynamic option validation hardened; complete category/UI audit remains. |
| 4 | Customers & addresses | GREEN | Customer security/isolation checkpoint 34/34. |
| 5 | Buying | BLUE | 049–051 hardened validation, submission events and authoritative workflow. Persistent UI flow remains unverified. |
| 6 | Media/storage | AMBER | Exact ownership, object paths and access workflow remain to be audited. |
| 7 | Trading Value / valuation | BLUE | 052 RLS plus 054–055 integrity/state-entry repairs. Full calculation/approval/UI audit remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs. Full lifecycle/UI remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened tenant access, source-offer uniqueness and status authority. Receipt/inspection/payment/inventory handoff remains. |
| 10 | Fulfilment | AMBER | Operational workflow audit remains. |
| 11 | Inventory | AMBER | Handoff is schema-connected but automatic creation was not found; audit remains. |
| 12 | Selling/listings | AMBER | Lifecycle audit remains. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete workflow audit remains. |
| 14 | Returns | AMBER | Full lifecycle audit remains. |
| 15 | Finance/payment | AMBER | FKs exist but automatic posting was not found; audit/hardening remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture exists; subscriber Website Builder now reads/saves drafts and publishes through the existing `publish_site_revision` service. Full public rendering, custom domains and customer-auth journey remain. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Subscriber website build checkpoint — 16 September 2026
The existing website architecture was used rather than creating a second content store. The live database contains `tenant_site_state`, `site_revisions` and `published_site_index`, and the existing `public.publish_site_revision(p_tenant_id,p_revision_id)` service controls publication.

The GitHub Website Builder was connected to that architecture:
- resolves the authenticated subscriber's active tenant membership, or accepts an explicit `tenant_id` when the account belongs to multiple tenants;
- loads the tenant's current draft revision;
- maps the builder's business name, headline, accent colour and template selection into `site_revisions.content` using `schema_version: 1`;
- saves the draft through the existing RLS-protected `site_revisions` update path;
- publishes through the existing `publish_site_revision` RPC rather than directly changing publication state;
- after publication, reloads the newly-created current draft revision;
- carries the selected tenant through the customer-dashboard preview link.

Affected files:
- `website-builder.html`
- `website-builder.js`

Verification state: **Implemented in GitHub; live authenticated browser verification still required.** No claim is made that the public storefront renderer or custom-domain routing is complete.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. These are not the production SaaS onboarding model.

Required sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

## Acquisition handoff finding
The acquisition tables are structurally connected to inventory and finance, but live inspection did not find an automatic public function/trigger that creates inventory, payment or ledger records from acquisition status changes. This remains an implementation/verification item and is not assumed to exist.

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a feature complete solely because code is committed. A transactional rollback test proves database behaviour, not a persistent browser journey.

## Deliberately outside generic core
GearCashOut specialist catalogue, evidence/research, AI research queue and specialist pricing structures remain outside TradeFlow unless explicitly added as modules.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected code/backend objects, architectural decision, fault/lesson, test, live verification, stopping point and next safe action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
The core security checkpoints remain intact. The build has now moved from the prolonged domain audit into the subscriber/customer-facing SaaS layer. The first live-backed Website Builder path is implemented against the existing tenant website revision architecture.

**Next build action:** continue the subscriber website/customer experience: make the subscriber dashboard invoke the builder cleanly, then build the tenant-specific public storefront renderer and customer account/dashboard journey. Keep acquisition/inventory/finance handoff as a separate open workflow item rather than blocking the customer-facing build.
