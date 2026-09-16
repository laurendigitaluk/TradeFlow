# TradeFlow Master Build Roadmap & Verification Register

**Version:** 2.0  
**Date:** 16 September 2026  
**Purpose:** Living record of TradeFlow architecture, verified security boundaries, business-domain build progress and exact stopping point.

## Authority
Current GitHub code + current Supabase state + structured project memory/checkpoints + verified live behaviour. Uninspected connections are **AMBER / Not yet audited**.

**Status meanings:** GREEN = verified live; AMBER = audit/implementation required; BLUE = partially implemented/tested; RED = not built; OUTSIDE CORE = deliberately excluded.

## Architecture baseline
TradeFlow is a generic multi-tenant Buy & Sell SaaS. `tenant_id` is the primary tenant security boundary.

**TradeFlow Platform → Platform Owner → subscriber tenant → tenant owner/admin/staff → customers**

Tenant roles are exactly `owner`, `admin`, `staff`. Platform Owner is a separate platform-level security boundary and is never a tenant role.

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
| 9 | Acquisition & acquisition items | BLUE | 056–057 hardened; workspace supports lifecycle progression and explicit inventory hand-off. |
| 10 | Fulfilment | AMBER | Operational workflow remains to be built/audited. |
| 11 | Inventory | BLUE | 058 hardened; dedicated workspace manages assets and controlled lifecycle. Browser verification remains. |
| 12 | Selling/listings | BLUE | Selling workspace now implemented: tenant-scoped listings, sales-channel/category/ready-inventory selection, creation and controlled listing lifecycle. Browser verification remains. |
| 13 | Retail orders | AMBER | Customer boundary tested; complete workflow remains. |
| 14 | Returns | AMBER | Full lifecycle remains. |
| 15 | Finance/payment | BLUE | 059 permission hardening plus 060 workflow authority; Finance workspace has payment/ledger creation and controlled status actions. Browser verification remains. |
| 16 | Notifications/email | AMBER | Provider/integration audit remains. |
| 17 | Staff roles/permissions/audit | BLUE | Security lab 19/19; complete management workflow remains. |
| 18 | Premium staff messenger | RED / future | No verified core implementation. |
| 19 | Public storefront / subscriber websites | BLUE | Website revision architecture and public renderer implemented; full public read/auth/custom-domain journey remains. |
| 20 | Authoritative workflow/RLS/grants | BLUE | Multiple domains now have explicit authority; final pass remains. |
| 21 | Platform Owner/Admin | BLUE | Foundation and privileged paths implemented; final browser regression remains. |

## Customer-facing SaaS build checkpoint — 16 September 2026
Implemented in GitHub:
- Website Builder and tenant-specific public storefront renderer.
- Customer authentication/test-lab registration and tenant-specific dashboard.
- Customer buying-request submission.
- Customer published-offer Accept/Refuse actions using existing secure RPCs.
- Subscriber Buying workspace for review, valuation and offer publication.
- Subscriber Acquisition workspace for acquisition/item lifecycle progression.
- Explicit inventory creation from received acquisition items.
- Dedicated Inventory workspace for tenant inventory listing, filtering, asset-detail editing and lifecycle transitions through `transition_workflow_entity()`.
- Subscriber Finance workspace for payment and ledger records, with controlled creation and lifecycle actions through the existing workflow authority.
- Dedicated Selling/Listings workspace using the existing `listings`, `sales_channels`, `categories` and `inventory_assets` model.

These are **Implemented**, not automatically **Verified Live**. Persistent authenticated browser testing remains the verification step.

## Acquisition → Finance → Inventory → Selling position
The live schema contains structural links across these domains. Live inspection did not find an automatic trigger/function that creates payment, ledger, or inventory records merely from acquisition status changes. The operational handoff is therefore explicit.

**Offer accepted → acquisition → receipt/inspection → finance records as required → inventory asset → ready for sale → listing.**

Inventory authority: **received → inspection → testing → repair → ready_for_sale → listed → reserved → sold**, with supported return/write-off/archive branches.

Listing authority: **draft → ready → published → reserved/sold/delisted**, with reserved able to return to published or progress to sold/delisted.

## Selling/Listings implementation
The new `selling-dashboard.html` / `selling-dashboard.js` workspace:
- loads tenant listings with status filtering;
- loads active tenant sales channels;
- loads active tenant categories with `selling_enabled=true`;
- offers only tenant inventory currently at `ready_for_sale` for new listings;
- creates a listing in `draft` and immediately advances it to `ready` through `transition_workflow_entity()`;
- exposes publish/reserve/sold/delist lifecycle actions through the same authoritative workflow RPC;
- displays listing detail and inventory/channel/category links.

The live database confirms `listings`, `listing_events`, `sales_channels` and the central `listing` workflow transitions, plus permission/subscription-aware RLS on listings, events and channels.

No direct listing status PATCH is used by the workspace.

## Production onboarding — OPEN
The development foundation still contains an authenticated tenant insertion path with `with check (true)` and temporary test-lab onboarding. Required sequence:
**Platform Owner / approved onboarding → tenant → initial owner → subscription → tenant owner/admin/staff management.**

## Verification standard
For every business domain trace:
**User action → page → front-end controller → Supabase call → RPC/query → table/view → trigger/function/RLS/grants → status transition → external integration → visible result → verification state.**

Do not mark a feature complete solely because code is committed. A transactional rollback test proves database behaviour, not a persistent browser journey.

## Documentation set
- `TRADEFLOW-MASTER-ROADMAP.md`
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`

Material changes must capture what/why, affected code/backend objects, decision, fault/lesson, test, live verification, stopping point and next action. Structured project memory/checkpoint data should also be updated where available.

## Current stopping point — 16 September 2026
Selling/Listings has now moved from AMBER build status to **BLUE / Implemented, browser verification open**. Finance workflow authority is also hardened through migration 060.

**Next build action:** continue the Selling operational layer into retail orders/customer checkout, using the existing listing → order → fulfilment → returns architecture. Do not invent automatic handoffs where the live schema does not establish them.