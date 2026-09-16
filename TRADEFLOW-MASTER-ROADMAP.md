# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.3  
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
| 10 | Fulfilment | BLUE | New subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and controls listing lifecycle. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout RPC/UI. Customer checkout creates a pending-payment order, links the listing/item and reserves the published listing; browser verification remains. |
| 14 | Returns | BLUE | Return-request security hardened and subscriber Returns workspace implemented; browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening plus Finance workspace. Persistent browser verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Fulfilment and Returns checkpoint — 16 September 2026
Migration `harden_fulfilment_returns_workflow_v2` applied live. Fulfilment retains subscription-aware `fulfilment.view/manage` access and now has a status-entry guard preventing direct client status edits. Returns legacy broad member/admin policies were removed so the subscription-aware returns policies are authoritative. Returns also has a status-entry guard.

Existing workflow authority is used for:
- Fulfilment: `awaiting → label → dispatched → delivered`, with dispatched/delivered → returned.
- Returns: `requested → authorised/rejected/closed → awaiting_return → received → inspected → approved/rejected → refunded/replaced/closed`.

Customer return creation was hardened through `customer_request_return()`: an authenticated active customer may request a return only for their own tenant order item and only when the order is `paid`, `fulfilment` or `completed`. The return is created in `requested` status and recorded in workflow history.

Implemented GitHub workspaces:
- `fulfilment-dashboard.html` / `fulfilment-dashboard.js` — subscriber fulfilment creation and controlled status progression.
- `returns-dashboard.html` / `returns-dashboard.js` — subscriber return review and controlled status progression.
- Customer dashboard updated to expose the existing order/shop flow and customer return/fulfilment data endpoints.
- Subscriber dashboard navigation now exposes Fulfilment and Returns.

These are **Implemented**, not **Verified Live**. No external carrier, shipping-label provider or automatic fulfilment creation has been assumed.

## Operational chain
**Buying → Valuation → Offer → Customer response → Acquisition → Finance/Payment → Inventory → Selling/Listing → Retail Order → Customer Checkout → Fulfilment → Return (when applicable).**

Automatic handoffs remain deliberately limited to database behaviour actually established by the live schema/RPCs. Explicit operational actions are used where automatic creation was not established.

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
Fulfilment and Returns operational workspaces and workflow hardening are implemented. Persistent browser verification remains open. Payment integration, shipping-provider integration and production onboarding remain open.

**Next build action:** complete customer return UI and fulfilment visibility, then move into payment integration and persistent browser verification.