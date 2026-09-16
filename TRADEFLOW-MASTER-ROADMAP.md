# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.2  
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
| 7 | Trading Value / valuation | BLUE | 052 plus 054–055 integrity/state-entry repairs and subscriber valuation UI. Persistent live journey remains. |
| 8 | Offers & offer events | BLUE | 053–055 integrity repairs plus customer accept/refuse UI. Persistent live journey remains. |
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; workspace supports lifecycle progression and explicit inventory hand-off. |
| 10 | Fulfilment | AMBER | Operational workflow remains to be built/audited. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and controls listing lifecycle. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout RPC/UI. Customer checkout creates a pending-payment order, links the listing/item and reserves the published listing; browser verification remains. |
| 14 | Returns | AMBER | Full lifecycle remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening plus Finance workspace. Persistent browser verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Customer-facing and subscriber operational build checkpoint — 16 September 2026
Implemented in GitHub:
- Website Builder and tenant-specific public storefront renderer.
- Customer authentication/test-lab registration and tenant-specific dashboard.
- Customer buying-request submission.
- Customer published-offer Accept/Refuse actions using existing secure RPCs.
- Subscriber Buying, Acquisition, Inventory, Finance, Selling/Listings and Orders workspaces.
- Explicit inventory creation from received acquisition items.
- Selling listings created from `ready_for_sale` inventory and advanced through the central workflow authority.
- Retail orders created from published listings, with linked order items and controlled status progression.
- Customer store listing RPC and authenticated one-item checkout RPC.
- Customer dashboard now exposes Shop and My Orders.

These are **Implemented**, not automatically **Verified Live**. Persistent authenticated browser testing remains the verification step.

## Selling → Orders position
Migration 061 hardens listings, listing events and sales channels to subscription/permission-aware policies and prevents direct listing status edits. The central workflow authority supports:
**draft → ready → published → reserved/sold/delisted**, with reserved → published/sold/delisted.

The Selling workspace loads active channels, selling-enabled categories and ready-for-sale inventory, and creates draft listings before moving them to ready through the workflow RPC.

Migration 062 hardens retail orders and order items to `orders.view/manage` plus `module.orders`; retail order trade-ins additionally require `module.trade_in`. Direct retail-order status changes are blocked by `guard_retail_order_status_entry()`.

The customer checkout implementation adds `customer_get_store_listings()` and `customer_create_retail_order()`. Checkout requires an authenticated active customer for the tenant, accepts only a published listing, creates the order as `pending_payment`, creates its linked order item, and reserves the listing. The checkout operation records workflow transitions for the order and listing. Payment processing itself is not integrated yet.

Order lifecycle authority is:
**initiated → pending_payment → paid → fulfilment → completed**, with supported cancellation/refund branches.

## Acquisition → Finance → Inventory → Selling → Orders
The live schema contains structural links between these domains, but automatic record creation must not be assumed. Explicit operational actions currently move the process forward:
**Offer accepted → acquisition → receipt/inspection → finance/payment → inventory → ready_for_sale → listing → order.**

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

Material changes must capture what/why, affected files/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
Retail Orders now has an authenticated customer checkout path in addition to the subscriber Orders workspace. Checkout/payment integration and persistent browser verification remain open.

**Next build action:** continue into fulfilment and returns, then complete payment integration and persistent browser verification.