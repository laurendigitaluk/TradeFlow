# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.4  
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
| 10 | Fulfilment | BLUE | Subscriber fulfilment workspace and lifecycle controls implemented; browser verification remains. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | 061 hardened; Selling workspace creates listings from ready-for-sale inventory and controls listing lifecycle. Browser verification remains. |
| 13 | Retail orders | BLUE | 062 hardening plus customer checkout and subscriber Orders workspace. Orders can now use controlled payment capture that creates the payment record, posts the matching ledger entry and advances the order to paid. Browser verification remains. |
| 14 | Returns | BLUE | Return-request security hardened and subscriber Returns workspace implemented; customer visibility/actions implemented. Browser verification remains. |
| 15 | Finance/payment | BLUE | 059–060 permission/workflow hardening plus Finance workspace and retail-order payment capture. External payment-provider integration remains open. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Fulfilment and Returns checkpoint — 16 September 2026
Migration `harden_fulfilment_returns_workflow_v2` applied live. Fulfilment retains subscription-aware `fulfilment.view/manage` access and now has a status-entry guard preventing direct client status edits. Returns legacy broad member/admin policies were removed so the subscription-aware returns policies are authoritative. Returns also has a status-entry guard.

Customer return creation is hardened through `customer_request_return()`: an authenticated active customer may request a return only for their own tenant order item and only when the order is `paid`, `fulfilment` or `completed`. The return is created in `requested` status and recorded in workflow history. Customer dashboard visibility uses the existing secure `customer_get_returns()` and `customer_get_fulfilments()` functions.

## Retail payment capture checkpoint — 16 September 2026
A new SECURITY DEFINER RPC, `record_retail_order_payment()`, is live. It requires authentication, the tenant `orders` capability, `finance.manage` and `orders.manage`. It locks the target order, requires `pending_payment`, requires the supplied amount to equal the current `amount_due`, creates a `payment_records` row as an inbound paid customer payment, creates a matching posted `ledger_entries` credit, sets the retail order payment status to `paid` and amount due to zero, then advances the order through the central workflow authority to `paid`.

The subscriber Orders workspace now uses this RPC for **Record payment & mark paid** instead of directly changing the order status. This deliberately represents internal/subscriber-recorded payment; it is **not** a Stripe/PayPal or other external gateway integration. External provider collection/webhooks remain open.

## Selling / fulfilment operational chain
Selling creates listings from `ready_for_sale` inventory. Customer checkout creates a `pending_payment` retail order and reserves the listing. Subscriber payment capture can move that order to `paid`, after which the Fulfilment workspace can create an `awaiting` fulfilment and progress it through dispatch/delivery.

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
Customer return visibility/actions and internal retail payment capture are implemented. External payment-provider integration, shipping-provider integration, production onboarding and persistent browser verification remain open.

**Next build action:** integrate an external payment-provider boundary without putting provider secrets in the browser, then perform the persistent browser verification pass across Orders → Payment → Fulfilment → Returns.