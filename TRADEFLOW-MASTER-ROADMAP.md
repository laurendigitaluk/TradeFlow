# TradeFlow Master Build Roadmap & Verification Register

**Version:** 1.7  
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
| 5 | Buying | BLUE | Customer submission and subscriber buying workspace implemented; persistent browser verification remains. |
| 6 | Media/storage | AMBER | Exact ownership, object paths and access workflow remain to be audited. |
| 7 | Trading Value / valuation | BLUE | 052 RLS plus 054–055 integrity/state-entry repairs and subscriber valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; subscriber acquisition workspace now supports operational status progression and inventory hand-off. Live browser verification remains. |
| 10 | Fulfilment | AMBER | Operational workflow remains to be built/audited. |
| 11 | Inventory | BLUE | Subscriber inventory hand-off UI now creates linked received assets; dedicated inventory workspace and full lifecycle remain. |
| 12 | Selling/listings | AMBER | Lifecycle remains to be built/audited. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete workflow remains. |
| 14 | Returns | AMBER | Full lifecycle remains. |
| 15 | Finance/payment | BLUE | Subscriber Finance workspace now exposes existing payment and ledger structures; posting/payment workflow and live verification remain. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Customer-facing SaaS build checkpoint — 16 September 2026
The build has moved from the prolonged broad audit into the subscriber/customer-facing SaaS layer while retaining the existing database security architecture.

Implemented in GitHub:
- Website Builder connected to tenant site revisions and publication service.
- Tenant-specific public storefront renderer.
- Customer authentication/test-lab registration and tenant-specific dashboard.
- Customer buying-request submission.
- Customer published-offer Accept/Refuse actions using the existing secure RPCs.
- Subscriber Buying workspace for review, valuation and offer publication.
- Subscriber Acquisition workspace for acquisition/item lifecycle progression.
- Inventory asset creation from received acquisition items with tenant-scoped source links.
- Subscriber Finance workspace for existing payment and ledger records.

These are **Implemented**, not automatically **Verified Live**. Persistent authenticated browser testing remains the verification step.

## Acquisition → Finance → Inventory workflow position
The live schema contains structural links from acquisitions to payment records and from acquisitions/inventory to ledger entries. Live inspection did not find an automatic trigger/function that creates payment, ledger or inventory records merely from acquisition status changes. The new subscriber workspaces therefore use explicit user actions and existing authoritative workflow services rather than assuming automation.

Current operational path:
**Offer accepted → acquisition created → awaiting item → received → inspection → finalised → paid → completed**, with explicit inventory creation from the acquisition-item hand-off and explicit finance records rather than implicit status side effects.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. These are not the production SaaS onboarding model.

Required sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

Never create a `platform_owner` tenant role or permit self-claiming platform ownership.

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

Material changes must capture what/why, affected code/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
The security hardening baseline remains intact. The active build track is now the operational subscriber SaaS: Buying → Offers → Acquisitions → Finance/Inventory, followed by Selling, Listings, Orders, Fulfilment and Returns.

**Next build action:** continue the dedicated Inventory workspace and connect its lifecycle to the existing acquisition hand-off, then complete Finance payment/ledger actions. Keep production onboarding and final browser verification as tracked open items rather than blocking forward development.